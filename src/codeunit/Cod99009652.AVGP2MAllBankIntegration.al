codeunit 99009652 "AVG P2M AllBank Integration"
{
    TableNo = "LSC POS Menu Line";
    //Todo Create Function for Multiple HTTP Calling
    var
        LSCGlobalRec: Record "LSC POS Menu Line";
        LSCStore: Record "LSC Store";
        LSCPOSTerminal: Record "LSC POS Terminal";
        LSCFunctionalityProfile: Record "LSC POS Func. Profile";
        LSCPOSTransLineRec: Record "LSC POS Trans. Line";
        LSCPOSTransactionCU: Codeunit "LSC POS Transaction";
        LSCPOSFunctionsCU: Codeunit "LSC POS Functions";
        LSCPOSCtrlInterfaceCU: Codeunit "LSC POS Control Interface";
        LSCPOSSession: Codeunit "LSC POS Session";
        AVGPOSSession: Codeunit "AVG POS Session";
        AVGPOSFunctions: Codeunit "AVG POS Functions";
        TypeHelper: Codeunit "Type Helper";
        AVGFunctions: Codeunit "AVG Functions";
        QRPHHelper: Codeunit "PH QR Code Helper";

    trigger OnRun()
    begin
        LSCGlobalRec := Rec;
        LSCPOSTerminal.GET(LSCPOSSession.TerminalNo());
        LSCStore.GET(LSCPOSTerminal."Store No.");
        LSCFunctionalityProfile.GET(LSCPOSSession.FunctionalityProfileID());
        IF LSCPOSTransLineRec.GET(LSCGlobalRec."Current-RECEIPT", LSCGlobalRec."Current-LINE") THEN;
        AVGFunctions.SetGlobalLSCPOSMenuLine(LSCGlobalRec);
        if not IntializedP2M() then begin
            AVGPOSSession.AVGPOSErrorMessages('P2M Customizations is not Initialized.');
            exit;
        end;
        CASE Rec.Command of
            'P2MGETDTO':
                P2MGetDto();
            'P2MGENERATEQR':
                P2MGenerateQR(LSCGlobalRec.Parameter);
            'P2MPAYMENTCHECK':
                P2MPaymentCheck(true, LSCPOSSession.GetValue('P2MMERCTOKEN'));
            'P2MCANCEL':
                P2MCancel();
            'P2MWAITRESPONSE':
                P2MWaitResponse(LSCGlobalRec.Parameter);
            'P2MRESPONSETESTER':
                ProcessP2MResponse('0000000701000000595', LSCPOSTerminal);
        // 'P2MACCTINQ':
        //     P2MAccountInquiry(true);
        // 'P2MACCTSOA':
        //     P2MAccountSOA(true);

        END;
        Rec := LSCGlobalRec;
    end;

    local procedure P2MGetDto(): Text;
    var
        StrBuilder: DotNet StringBuilder;
        P2M_Tdt, P2MResponse : Text;
        P2M_ResReturnCode: Text;
        LSCPOSTerminalLoc: Record "LSC POS Terminal";
    begin

        if not LSCPOSTerminalLoc.Get(LSCPOSSession.TerminalNo()) then
            exit;

        clear(P2M_Tdt);
        P2M_Tdt := TypeHelper.GetCurrUTCDateTimeISO8601();
        StrBuilder := StrBuilder.StringBuilder();
        StrBuilder.Append('<Account.Info');
        StrBuilder.Append(StrSubstNo(' cmd="%1"', 'dto'));
        StrBuilder.Append(StrSubstNo(' tdt="%1"', P2M_Tdt));
        StrBuilder.Append('/>');
        clear(P2MResponse);
        P2MResponse := PostP2MHttpRequest(LSCPOSTerminalLoc."P2M URL", StrBuilder.ToString(), 'text/xml', LSCPOSTerminalLoc."P2M SoapAction URL");
        IF P2MResponse <> '' then begin
            clear(P2M_ResReturnCode);
            P2M_ResReturnCode := GetResponseXMLByPath(P2MResponse, 'ReturnCode');
            if P2M_ResReturnCode = '0' then
                exit(GetResponseXMLByPath(P2MResponse, 'dto'));
        end;
    end;

    local procedure P2MGenerateQR(pTenderTypeCode: Code[20])
    begin
        LSCPOSSession.SetValue('P2MTENDERTYPE', pTenderTypeCode);
        LSCPOSTransactionCU.OpenNumericKeyboard('Amount to Pay', 0, LSCPOSFunctionsCU.FormatAmountToShow(LSCPOSTransactionCU.GetOutstandingBalance()), 99009652);
        exit;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction", OnAfterKeyboardTriggerToProcess, '', false, false)]
    local procedure OnAfterKeyboardTriggerToProcess(InputValue: Text; KeyboardTriggerToProcess: Integer; var Rec: Record "LSC POS Transaction"; var IsHandled: Boolean);
    var
        AmountToPay: Decimal;
        InvalidAmtMsg: Label 'Invalid Amount.', Locked = true;
        ExceededAmtMsg: Label 'Exceeded Amount.', Locked = true;
    begin
        case KeyboardTriggerToProcess of
            99009652:
                begin

                    if not evaluate(AmountToPay, InputValue) then begin
                        AVGPOSSession.AVGPOSErrorMessages(InvalidAmtMsg);
                        IsHandled := true;
                        exit;
                    end;

                    if AmountToPay = 0 then begin
                        IsHandled := true;
                        exit;
                    end;

                    if AmountToPay > LSCPOSTransactionCU.GetOutstandingBalance() then begin
                        AVGPOSSession.AVGPOSErrorMessages(ExceededAmtMsg);
                        IsHandled := true;
                        exit;
                    end;
                    if InputValue <> '' then begin
                        P2MGenerateQREx(LSCPOSSession.GetValue('P2MTENDERTYPE'), AmountToPay);
                        IsHandled := true;
                    end;
                end;
        end;
    end;

    local procedure P2MGenerateQREx(pTenderTypeCode: Code[20]; pAmount: Decimal)
    var
        StrBuilder: DotNet StringBuilder;
        P2M_Id, P2M_SecretKey, P2M_Tdt, P2M_Token, P2M_BodyRawRequest, P2M_Response, P2M_ResMerchToken, P2M_ResQrph, P2M_ResReturnCode : Text;
        CryptoMgt: Codeunit "Cryptography Management";
        CrpytoAlgo: Option MD5,SHA1,SHA256,SHA384,SHA512;
        LSCPOSTerminalRecLoc: Record "LSC POS Terminal";
        P2MRefNo: Text;
        P2MRefNoMD5: Text[35];
    begin
        if not LSCPOSTerminalRecLoc.Get(LSCPOSSession.TerminalNo()) then
            exit;
        clear(P2M_Tdt);
        P2M_Tdt := P2MGetDto();
        clear(P2M_Token);
        clear(P2M_BodyRawRequest);
        P2M_Id := LSCPOSTerminalRecLoc."P2M Access ID";
        P2M_SecretKey := LSCPOSTerminalRecLoc."P2M Secret Key";
        P2M_Token := CryptoMgt.GenerateHash(P2M_Id + P2M_SecretKey + P2M_Tdt, CrpytoAlgo::SHA1);
        clear(P2MRefNo);
        P2MRefNo := AVGPOSFunctions.AVGCreateStandardGuidFormat(LSCPOSTerminalRecLoc, 'P2M');
        if P2MRefNo = '' then
            P2MRefNo := LSCPOSTransactionCU.GetReceiptNo();
        clear(P2MRefNoMD5);
        P2MRefNoMD5 := CryptoMgt.GenerateHash(P2MRefNo, CrpytoAlgo::MD5);
        LSCPOSSession.SetValue('P2MREFNO', P2MRefNoMD5);
        StrBuilder := StrBuilder.StringBuilder();
        StrBuilder.Append('<Account.Info');
        StrBuilder.Append(StrSubstNo(' id="%1"', P2M_Id));
        StrBuilder.Append(StrSubstNo(' tdt="%1"', P2M_Tdt));
        StrBuilder.Append(StrSubstNo(' token="%1"', P2M_Token));
        StrBuilder.Append(StrSubstNo(' cmd="%1"', 'MERC-QR-REQ'));
        StrBuilder.Append(StrSubstNo(' rf="%1"', P2MRefNoMD5));
        StrBuilder.Append(StrSubstNo(' amt="%1"', LSCPOSFunctionsCU.FormatAmount(pAmount)));
        StrBuilder.Append(StrSubstNo(' merc_tid="%1"', '0'));
        StrBuilder.Append(StrSubstNo(' make_static_qr="%1"', '0'));
        StrBuilder.Append(' />');
        P2M_BodyRawRequest := StrBuilder.ToString();
        if LSCPOSTerminalRecLoc."P2M Prompt API Messages" then
            AVGPOSFunctions.AVGPOSMessage(StrSubstNo('Request: %1', P2M_BodyRawRequest));
        clear(P2M_Response);
        P2M_Response := PostP2MHttpRequest(LSCPOSTerminalRecLoc."P2M URL", P2M_BodyRawRequest, 'text/xml', LSCPOSTerminalRecLoc."P2M SoapAction URL");
        if LSCPOSTerminalRecLoc."P2M Prompt API Messages" then
            AVGPOSFunctions.AVGPOSMessage(StrSubstNo('Response: %1', P2M_Response));
        IF P2M_Response <> '' then begin
            P2M_ResReturnCode := GetResponseXMLByPath(P2M_Response, 'ReturnCode');
            IF P2M_ResReturnCode = '0' then begin
                P2M_ResMerchToken := GetResponseXMLByPath(P2M_Response, 'merc_token');
                P2M_ResQrph := GetResponseXMLByPath(P2M_Response, 'qrph');
                LSCPOSSession.SetValue('P2MMERCTOKEN', P2M_ResMerchToken);
                Commit();
                CreateP2MQRCode(LSCPOSTerminalRecLoc."No.", P2M_ResQrph, pTenderTypeCode);
            end else
                AVGPOSSession.AVGPOSErrorMessages(GetResponseXMLByPath(P2M_Response, 'ErrorMsg'));
        end;
    end;

    local procedure P2MPaymentCheck(pCommand: Boolean; pMercToken: Text): Text
    var
        StrBuilder: DotNet StringBuilder;
        P2M_Id, P2M_SecretKey, P2M_Tdt, P2M_Token, P2M_BodyRawRequest, P2M_Response, P2M_ResMerchToken, P2M_ResReturnCode : Text;
        CryptoMgt: Codeunit "Cryptography Management";
        CrpytoAlgo: Option MD5,SHA1,SHA256,SHA384,SHA512;
        ErrorMsgResponse: Text;
        LSCPOSTerminalLoc: Record "LSC POS Terminal";
    begin
        if not LSCPOSTerminalLoc.Get(LSCPOSSession.TerminalNo()) then
            exit;
        clear(ErrorMsgResponse);
        clear(P2M_Tdt);
        P2M_Tdt := P2MGetDto();
        clear(P2M_Token);
        clear(P2M_BodyRawRequest);
        P2M_Id := LSCPOSTerminalLoc."P2M Access ID";
        P2M_SecretKey := LSCPOSTerminalLoc."P2M Secret Key";
        P2M_Token := CryptoMgt.GenerateHash(P2M_Id + P2M_SecretKey + P2M_Tdt, CrpytoAlgo::SHA1);
        StrBuilder := StrBuilder.StringBuilder();
        StrBuilder.Append('<Account.Info');
        StrBuilder.Append(StrSubstNo(' id="%1"', P2M_Id));
        StrBuilder.Append(StrSubstNo(' tdt="%1"', P2M_Tdt));
        StrBuilder.Append(StrSubstNo(' token="%1"', P2M_Token));
        StrBuilder.Append(StrSubstNo(' cmd="%1"', 'MERC-PAY-CHK'));
        StrBuilder.Append(StrSubstNo(' merc_token="%1"', pMercToken));
        StrBuilder.Append(' />');
        P2M_BodyRawRequest := StrBuilder.ToString();
        if pCommand then
            if LSCPOSTerminalLoc."P2M Prompt API Messages" then
                AVGPOSFunctions.AVGPOSMessage(StrSubstNo('Request: %1', P2M_BodyRawRequest));
        clear(P2M_Response);
        P2M_Response := PostP2MHttpRequest(LSCPOSTerminalLoc."P2M URL", P2M_BodyRawRequest, 'text/xml', LSCPOSTerminalLoc."P2M SoapAction URL");
        if pCommand then
            if LSCPOSTerminalLoc."P2M Prompt API Messages" then
                AVGPOSFunctions.AVGPOSMessage(StrSubstNo('Response: %1', P2M_Response));
        IF P2M_Response <> '' then begin
            P2M_ResReturnCode := GetResponseXMLByPath(P2M_Response, 'ReturnCode');
            ErrorMsgResponse := GetResponseXMLByPath(P2M_Response, 'ErrorMsg');
            IF P2M_ResReturnCode = '0' then begin
                P2M_ResMerchToken := GetResponseXMLByPath(P2M_Response, 'merc_token');
                if pCommand then
                    AVGPOSSession.AVGPOSMessages(ErrorMsgResponse)
            end else
                if pCommand then
                    AVGPOSSession.AVGPOSErrorMessages(ErrorMsgResponse);
            if not pCommand then
                exit(ErrorMsgResponse);
        end;
    end;

    local procedure P2MCancel()
    var
        StrBuilder: DotNet StringBuilder;
        P2M_Id, P2M_SecretKey, P2M_Tdt, P2M_Token, P2M_BodyRawRequest, P2M_Response, P2M_ResMerchToken, P2M_ResReturnCode : Text;
        CryptoMgt: Codeunit "Cryptography Management";
        CrpytoAlgo: Option MD5,SHA1,SHA256,SHA384,SHA512;
    begin
        clear(P2M_Tdt);
        P2M_Tdt := P2MGetDto();
        clear(P2M_Token);
        clear(P2M_BodyRawRequest);
        P2M_Id := LSCPOSTerminal."P2M Access ID";
        P2M_SecretKey := LSCPOSTerminal."P2M Secret Key";
        P2M_Token := CryptoMgt.GenerateHash(P2M_Id + P2M_SecretKey + P2M_Tdt, CrpytoAlgo::SHA1);
        StrBuilder := StrBuilder.StringBuilder();
        StrBuilder.Append('<Account.Info');
        StrBuilder.Append(StrSubstNo(' id="%1"', P2M_Id));
        StrBuilder.Append(StrSubstNo(' tdt="%1"', P2M_Tdt));
        StrBuilder.Append(StrSubstNo(' token="%1"', P2M_Token));
        StrBuilder.Append(StrSubstNo(' cmd="%1"', 'MERC-CANCEL'));
        StrBuilder.Append(StrSubstNo(' merc_token="%1"', LSCPOSSession.GetValue('P2MMERCTOKEN')));
        StrBuilder.Append(' />');
        P2M_BodyRawRequest := StrBuilder.ToString();
        if LSCPOSTerminal."P2M Prompt API Messages" then
            AVGPOSFunctions.AVGPOSMessage(StrSubstNo('Request: %1', P2M_BodyRawRequest));
        clear(P2M_Response);
        P2M_Response := PostP2MHttpRequest(LSCPOSTerminal."P2M URL", P2M_BodyRawRequest, 'text/xml', LSCPOSTerminal."P2M SoapAction URL");
        if LSCPOSTerminal."P2M Prompt API Messages" then
            AVGPOSFunctions.AVGPOSMessage(StrSubstNo('Response: %1', P2M_Response));
        IF P2M_Response <> '' then begin
            P2M_ResReturnCode := GetResponseXMLByPath(P2M_Response, 'ReturnCode');
            IF P2M_ResReturnCode = '0' then begin
                P2M_ResMerchToken := GetResponseXMLByPath(P2M_Response, 'merc_token');
                AVGPOSSession.AVGPOSErrorMessages(GetResponseXMLByPath(P2M_Response, 'ErrorMsg'));
            end else
                AVGPOSSession.AVGPOSErrorMessages(GetResponseXMLByPath(P2M_Response, 'ErrorMsg'));
        end;
    end;

    local procedure PostP2MHttpRequest(pURL: Text; pRequestBody: Text; pContentType: Text; pSoapAction: Text): Text
    var
        LSCHttpWrapper: Codeunit "LSC Http Wrapper";
    begin
        LSCHttpWrapper.ClearVars();
        LSCHttpWrapper.ClearHeaders();
        LSCHttpWrapper.Url(pURL);
        LSCHttpWrapper.SetHeader('Content-Type', pContentType);
        IF pSoapAction <> '' THEN
            LSCHttpWrapper.SetHeader('SoapAction', pSoapAction);
        LSCHttpWrapper.Method('POST');
        LSCHttpWrapper.RequestText(pRequestBody);
        if LSCHttpWrapper.Send() then
            exit(LSCHttpWrapper.ResponseText());
    end;

    local procedure GetP2MHttpRequest(pReceiptNo: Text; pPOSTerminalRec: Record "LSC POS Terminal"): Boolean
    var
        LSCHttpWrapper: Codeunit "LSC Http Wrapper";
        JObject, JObject2, JObject3 : JsonObject;
        JToken, JToken2 : JsonToken;
        JsonReq: Text;
        ResponseTextLoc: Text;
        Auth: Text;
        JArray: JsonArray;
        LJToken: list of [JsonToken];
        Counter: Integer;
    begin

        clear(JsonReq);
        JObject.Add('username', pPOSTerminalRec."P2M Username");
        JObject.Add('password', pPOSTerminalRec."P2M Password");
        JObject.WriteTo(JsonReq);

        clear(ResponseTextLoc);
        ResponseTextLoc := PostP2MHttpRequest(pPOSTerminalRec."P2M Internal Url" + '/auth', JsonReq, 'application/json', '');
        IF ResponseTextLoc <> '' then begin
            JObject2.ReadFrom(ResponseTextLoc);
            JObject2.SelectToken('accessToken', JToken);
            clear(Auth);
            if JToken.IsValue then
                Auth := JToken.AsValue().AsText();
        end;

        if Auth = '' then
            exit;

        LSCHttpWrapper.ClearVars();
        LSCHttpWrapper.ClearHeaders();
        LSCHttpWrapper.Url(pPOSTerminalRec."P2M Internal Url" + pPOSTerminalRec."P2M Internal Endpt. P2M" + pReceiptNo + '/' + LSCPOSSession.GetValue('P2MMERCTOKEN'));
        LSCHttpWrapper.SetHeader('Content-Type', 'application/json');
        LSCHttpWrapper.SetHeader('Authorization', StrSubstNo('Bearer %1', Auth));
        LSCHttpWrapper.Method('GET');
        if LSCHttpWrapper.Send() then begin
            if pPOSTerminalRec."P2M Prompt API Messages" then
                AVGPOSFunctions.AVGPOSMessage(StrSubstNo('Response: %1', LSCHttpWrapper.ResponseText()));
            JObject3.ReadFrom(LSCHttpWrapper.ResponseText());
            LJToken := JObject3.Values;
            foreach JToken2 in LJToken do
                if JToken2.IsArray then
                    JArray := JToken2.AsArray();
        end;
        clear(Counter);
        for Counter := 0 to (JArray.Count - 1) do begin
            LSCPOSSession.SetValue('P2MMERCTOKEN', GetResponseJsonByPath(LSCHttpWrapper, 'data[' + format(Counter) + '].merc_token'));
            LSCPOSSession.SetValue('P2MAMOUNT', GetResponseJsonByPath(LSCHttpWrapper, 'data[' + format(Counter) + '].amount'));
            LSCPOSSession.SetValue('P2MBANKREF', GetResponseJsonByPath(LSCHttpWrapper, 'data[' + format(Counter) + '].bank_reference'));
            LSCPOSSession.SetValue('P2MPAYMENTREF', GetResponseJsonByPath(LSCHttpWrapper, 'data[' + format(Counter) + '].payment_reference'));
            LSCPOSSession.SetValue('P2MPAYMENTCHANNEL', GetResponseJsonByPath(LSCHttpWrapper, 'data[' + format(Counter) + '].payment_channel'));
            LSCPOSSession.SetValue('P2MPAYMENTDATETIME', GetResponseJsonByPath(LSCHttpWrapper, 'data[' + format(Counter) + '].payment_datetime'));
            LSCPOSSession.SetValue('P2MSTATUS', GetResponseJsonByPath(LSCHttpWrapper, 'data[' + format(Counter) + '].status'));
            LSCPOSSession.SetValue('P2MMESSAGE', GetResponseJsonByPath(LSCHttpWrapper, 'data[' + format(Counter) + '].message'));
        end;
    end;

    procedure GetResponseJsonByPath(pLSCHttpWrapper: Codeunit "LSC Http Wrapper"; pPath: Text): Text;
    var
        JTokenLocal: JsonToken;
        ResponseText: Text;
        ResponsePathJObject: JsonObject;
    begin
        CLEAR(ResponsePathJObject);
        ResponsePathJObject := pLSCHttpWrapper.ResponseJson();
        IF NOT ResponsePathJObject.SelectToken(pPath, JTokenLocal) then
            EXIT('');
        CLEAR(ResponseText);
        JTokenLocal := pLSCHttpWrapper.GetResponseJsonByPath(pPath);
        IF JTokenLocal.WriteTo(ResponseText) then BEGIN
            IF ResponseText.Contains('null') THEN
                ResponseText := ResponseText.Replace('null', '');
            IF ResponseText.Contains('"') THEN
                ResponseText := ResponseText.Replace('"', '');
        END ELSE
            ResponseText := '';
        EXIT(ResponseText);
    end;

    local procedure GetResponseXMLByPath(pXMLResponse: Text; pPath: Text): Text;
    var
        XElement: DotNet CustXElement;
        XName: DotNet CustXName;
    begin
        IF pXMLResponse = '' then
            exit;
        XElement := XElement.Parse(pXMLResponse);
        EXIT(XElement.Attribute(XName.Get(pPath)).Value);
    end;

    local procedure CreateP2MQRCode(pTerminalNo: Code[20]; pQRPH: Text; pTenderTypeCode: Code[20])
    var
        QRPHBlob: Codeunit "Temp Blob";
        InStr: InStream;
    begin
        IF QRPHHelper.GenerateQRCodeImage(pQRPH, QRPHBlob) then begin
            QRPHBlob.CreateInStream(InStr);
            DisplayQRCode(pTerminalNo, InStr, pTenderTypeCode);
        end;
    end;

    local procedure IntializedP2M(): Boolean
    begin
        IF not LSCPOSTerminal."Enable P2M Pay" then
            exit(false);

        if LSCPOSTerminal."P2M URL" = '' then
            exit(false);

        if LSCPOSTerminal."P2M Access ID" = '' then
            exit(false);

        if LSCPOSTerminal."P2M Secret Key" = '' then
            exit(false);

        if LSCPOSTerminal."P2M SoapAction URL" = '' then
            exit(false);

        if LSCPOSTerminal."P2M Webhook Secret" = '' then
            exit(false);

        if (LSCPOSTerminal."P2M Username" = '') or (LSCPOSTerminal."P2M Password" = '') then
            exit(false);

        if LSCPOSTerminal."P2M Internal Url" = '' then
            exit(false);

        if LSCPOSTerminal."P2M Internal Endpt. P2M" = '' then
            exit(false);

        // if LSCPOSTerminal."P2M Internal Endpt. Instapay" = '' then
        //     exit(false);

        // if LSCPOSTerminal."P2M Internal Endpt. Pesonet" = '' then
        //     exit(false);
        exit(true);
    end;

    procedure DisplayQRCode(pTerminalNo: Code[20]; pInStr: InStream; pTenderTypeCode: Code[20])
    var
        LSCTenderTypeLoc: Record "LSC Tender Type";
        recID: RecordId;
        LSCRetailImage: Record "LSC Retail Image";
        LSCRetailImageLink: Record "LSC Retail Image Link";
    begin
        LSCRetailImage.LockTable();
        LSCRetailImage.Init();
        LSCRetailImage.Code := pTerminalNo + 'ALLBANKQR';
        LSCRetailImage.Description := pTerminalNo + 'ALLBANK QR';
        LSCRetailImage."Image Mediaset".ImportStream(pInStr, '');
        if not LSCRetailImage.Insert then
            LSCRetailImage.Modify;

        LSCTenderTypeLoc.Get(LSCPOSSession.StoreNo(), pTenderTypeCode);

        clear(recID);
        recID := LSCTenderTypeLoc.RecordId;

        LSCRetailImageLink.LockTable();
        // if LSCRetailImageLink.Get(Format(recID), LSCRetailImage.Code) then
        //     exit;
        LSCRetailImageLink.Validate("Record Id", Format(recID));
        LSCRetailImageLink."Image Id" := LSCRetailImage.Code;
        LSCRetailImageLink.Validate(Description);
        if not LSCRetailImageLink.Insert() then
            LSCRetailImageLink.Modify();
        AVGPOSSession.AVGPOSMessages('Customer may now scan QR code displayed on POS screen.');
#pragma warning disable AL0432
        LSCPOSSession.SetPosPicture(recID, 0);
#pragma warning restore AL0432
        Commit();
        LSCPOSCtrlInterfaceCU.PostEvent('RUNCOMMAND', 'P2MWAITRESPONSE', pTenderTypeCode, '');
    end;

    procedure P2MWaitResponse(pTenderTypeCode: Code[20])
    var
        ExpiredTime: Time;
        WaitTime: Integer;
        bolOK: Boolean;
        ExpiredTimeText: Text;
        Window: Dialog;
        ExpiredTimeDuration: Duration;
        LSCPOSTerminalLoc: Record "LSC POS Terminal";
        AmountText: Text;
    begin
        if not LSCPOSTerminalLoc.Get(LSCPOSSession.TerminalNo()) then
            exit;
        clear(WaitTime);
        WaitTime := LSCPOSTerminalLoc."P2M Wait Response Min." * 60000;
        if LSCPOSTerminalLoc."P2M Wait Response Min." = 0 then
            WaitTime := 120000; // 2 Minutes or 120,000 miliseconds

        clear(ExpiredTimeText);
        clear(ExpiredTime);
        ExpiredTimeText := format(TIME + WaitTime);
        if Evaluate(ExpiredTime, ExpiredTimeText) then;
        Commit();

        Window.Open('Customer is Paying......\' +
                    'Please do not Close, Interrupt or Press Any button to prevent any problem during the transaction.\' +
                    'Waiting Response: #1####');
        clear(bolOK);
        Clear(ExpiredTimeDuration);
        while ((ExpiredTime > time) AND (NOT bolOK)) do begin
            bolOK := StrPos(P2MPaymentCheck(false, LSCPOSSession.GetValue('P2MMERCTOKEN')), 'received') <> 0;
            ExpiredTimeDuration := ExpiredTime - Time;
            Window.Update(1, ExpiredTimeDuration);
            if ((ExpiredTime = Time) OR (bolOK)) then
                break;

        end;

        if bolOK then begin
            Window.Close();
            ProcessP2MResponse(LSCPOSSession.GetValue('P2MREFNO'), LSCPOSTerminalLoc);
            Commit();

            clear(AmountText);
            AmountText := LSCPOSSession.Getvalue('P2MAMOUNT');
            LSCPOSTransactionCU.SetCurrInput(AmountText);
            LSCPOSTransactionCU.TenderKeyPressed(pTenderTypeCode);
        end else begin
            DeleteP2MRetailImage(LSCPOSTerminalLoc."No.");
            Commit();
            AVGPOSSession.AVGPOSMessages('Session Expired.\Please Try Again.');
            LSCPOSCtrlInterfaceCU.PostEvent('RUNCOMMAND', 'P2MCANCEL', '', '');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnBeforeInsertPaymentLine, '', false, false)]
    local procedure OnBeforeInsertPaymentLine(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var TenderTypeCode: Code[10]; Balance: Decimal; PaymentAmount: Decimal; STATE: Code[10]; var isHandled: Boolean);
    begin
        IF LSCPOSSession.Getvalue('P2MMERCTOKEN') <> '' then begin
            POSTransLine."P2M Merch Token" := LSCPOSSession.Getvalue('P2MMERCTOKEN');
            IF Evaluate(POSTransLine."P2M Amount", LSCPOSSession.Getvalue('P2MAMOUNT')) then;
            IF Evaluate(POSTransLine."P2M Bank Refrence", LSCPOSSession.GetValue('P2MBANKREF')) then;
            POSTransLine."P2M Payment Reference" := LSCPOSSession.Getvalue('P2MPAYMENTREF');
            POSTransLine."P2M Payment Channel" := LSCPOSSession.Getvalue('P2MPAYMENTCHANNEL');
            POSTransLine."P2M Payment Date & Time" := LSCPOSSession.Getvalue('P2MPAYMENTDATETIME');
            POSTransLine."P2M Status" := LSCPOSSession.Getvalue('P2MSTATUS');
            POSTransLine."P2M Message" := LSCPOSSession.GetValue('P2MMESSAGE');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnAfterInsertPaymentLine, '', false, false)]
    local procedure OnAfterInsertPaymentLine(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var TenderTypeCode: Code[10]; var SkipCommit: Boolean);
    begin
        IF LSCPOSSession.Getvalue('P2MMERCTOKEN') <> '' then
            ClearP2MValues();
    end;

    local procedure ProcessP2MResponse(pReceiptNo: Text; pPOSTerminalRec: Record "LSC POS Terminal"): Boolean
    begin
        exit(GetP2MHttpRequest(pReceiptNo, pPOSTerminalRec));
    end;

    procedure DeleteP2MRetailImage(pPOSTerminal: Code[20])
    var
        LSCRetailImage: Record "LSC Retail Image";
        LSCRetailImageLink: Record "LSC Retail Image Link";
    begin
        if LSCRetailImage.Get(pPOSTerminal + 'ALLBANKQR') then begin
            LSCRetailImageLink.SetCurrentKey("Image Id");
            LSCRetailImageLink.SetRange("Image Id", LSCRetailImage.Code);
            if LSCRetailImageLink.FindSet() then
                LSCRetailImageLink.DeleteAll();
            LSCRetailImage.Delete();
        end;
    end;

    // local procedure P2MAccountInquiry(pCommand: Boolean): Text
    // var
    //     StrBuilder: DotNet StringBuilder;
    //     P2M_Id, P2M_SecretKey, P2M_Tdt, P2M_Token, P2M_BodyRawRequest, P2M_Response : Text;
    //     CryptoMgt: Codeunit "Cryptography Management";
    //     CrpytoAlgo: Option MD5,SHA1,SHA256,SHA384,SHA512;
    //     ErrorMsgResponse: Text;
    //     LSCPOSTerminalLoc: Record "LSC POS Terminal";
    // begin
    //     if not LSCPOSTerminalLoc.Get(LSCPOSSession.TerminalNo()) then
    //         exit;
    //     clear(ErrorMsgResponse);
    //     clear(P2M_Tdt);
    //     P2M_Tdt := P2MGetDto();
    //     clear(P2M_Token);
    //     clear(P2M_BodyRawRequest);
    //     P2M_Id := LSCPOSTerminalLoc."P2M Access ID";
    //     P2M_SecretKey := LSCPOSTerminalLoc."P2M Secret Key";
    //     P2M_Token := CryptoMgt.GenerateHash(P2M_Id + P2M_SecretKey + P2M_Tdt, CrpytoAlgo::SHA1);
    //     StrBuilder := StrBuilder.StringBuilder();
    //     StrBuilder.Append('<Account.Info');
    //     StrBuilder.Append(StrSubstNo(' id="%1"', P2M_Id));
    //     StrBuilder.Append(StrSubstNo(' tdt="%1"', P2M_Tdt));
    //     StrBuilder.Append(StrSubstNo(' token="%1"', P2M_Token));
    //     StrBuilder.Append(StrSubstNo(' cmd="%1"', 'ACCOUNT-INQ'));
    //     StrBuilder.Append(StrSubstNo(' acctno="%1"', '003-24-00028-8'));
    //     StrBuilder.Append(' />');
    //     P2M_BodyRawRequest := StrBuilder.ToString();

    //     clear(P2M_Response);
    //     P2M_Response := PostP2MHttpRequest(LSCPOSTerminalLoc."P2M URL", P2M_BodyRawRequest, 'text/xml', LSCPOSTerminalLoc."P2M SoapAction URL");
    //     message(P2M_Response);
    //     IF P2M_Response <> '' then begin
    //         P2M_ResReturnCode := GetResponseXMLByPath(P2M_Response, 'ReturnCode');
    //         ErrorMsgResponse := GetResponseXMLByPath(P2M_Response, 'ErrorMsg');
    //         IF P2M_ResReturnCode = '0' then begin
    //             P2M_ResMerchToken := GetResponseXMLByPath(P2M_Response, 'merc_token');
    //             if pCommand then
    //                 AVGPOSSession.AVGPOSErrorMessages(ErrorMsgResponse)
    //         end else
    //             if pCommand then
    //                 AVGPOSSession.AVGPOSErrorMessages(ErrorMsgResponse);
    //         if not pCommand then
    //             exit(ErrorMsgResponse);
    //     end;
    // end;

    // local procedure P2MAccountSOA(pCommand: Boolean): Text
    // var
    //     StrBuilder: DotNet StringBuilder;
    //     P2M_Id, P2M_SecretKey, P2M_Tdt, P2M_Token, P2M_BodyRawRequest, P2M_Response : Text;
    //     CryptoMgt: Codeunit "Cryptography Management";
    //     CrpytoAlgo: Option MD5,SHA1,SHA256,SHA384,SHA512;
    //     ErrorMsgResponse: Text;
    //     LSCPOSTerminalLoc: Record "LSC POS Terminal";
    // begin
    //     if not LSCPOSTerminalLoc.Get(LSCPOSSession.TerminalNo()) then
    //         exit;
    //     clear(ErrorMsgResponse);
    //     clear(P2M_Tdt);
    //     P2M_Tdt := P2MGetDto();
    //     clear(P2M_Token);
    //     clear(P2M_BodyRawRequest);
    //     P2M_Id := LSCPOSTerminalLoc."P2M Access ID";
    //     P2M_SecretKey := LSCPOSTerminalLoc."P2M Secret Key";
    //     P2M_Token := CryptoMgt.GenerateHash(P2M_Id + P2M_SecretKey + P2M_Tdt, CrpytoAlgo::SHA1);
    //     StrBuilder := StrBuilder.StringBuilder();
    //     StrBuilder.Append('<Account.Info');
    //     StrBuilder.Append(StrSubstNo(' id="%1"', P2M_Id));
    //     StrBuilder.Append(StrSubstNo(' tdt="%1"', P2M_Tdt));
    //     StrBuilder.Append(StrSubstNo(' token="%1"', P2M_Token));
    //     StrBuilder.Append(StrSubstNo(' cmd="%1"', 'ACCOUNT-SOA'));
    //     StrBuilder.Append(StrSubstNo(' acctno="%1"', '003-24-00028-8'));
    //     StrBuilder.Append(StrSubstNo(' ds="%1"', '02/01/2024')); // Date Start
    //     StrBuilder.Append(StrSubstNo(' de="%1"', '03/01/2024')); // Date End
    //     StrBuilder.Append(StrSubstNo(' trans_idcode="%1"', '0'));
    //     StrBuilder.Append(' />');
    //     P2M_BodyRawRequest := StrBuilder.ToString();
    //     message(P2M_BodyRawRequest);
    //     clear(P2M_Response);
    //     P2M_Response := PostP2MHttpRequest(LSCPOSTerminalLoc."P2M URL", P2M_BodyRawRequest, 'text/xml', LSCPOSTerminalLoc."P2M SoapAction URL");
    //     message(P2M_Response);
    //     IF P2M_Response <> '' then begin
    //         P2M_ResReturnCode := GetResponseXMLByPath(P2M_Response, 'ReturnCode');
    //         ErrorMsgResponse := GetResponseXMLByPath(P2M_Response, 'ErrorMsg');
    //         IF P2M_ResReturnCode = '0' then begin
    //             P2M_ResMerchToken := GetResponseXMLByPath(P2M_Response, 'merc_token');
    //             if pCommand then
    //                 AVGPOSSession.AVGPOSErrorMessages(ErrorMsgResponse)
    //         end else
    //             if pCommand then
    //                 AVGPOSSession.AVGPOSErrorMessages(ErrorMsgResponse);
    //         if not pCommand then
    //             exit(ErrorMsgResponse);
    //     end;
    // end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnBeforeVoidTransaction, '', false, false)]
    local procedure OnBeforeVoidTransaction(var POSTransaction: Record "LSC POS Transaction"; var IsHandled: Boolean);
    var
        P2MTransLine: Record "LSC POS Trans. Line";
    begin
        P2MTransLine.Reset();
        P2MTransLine.setrange("Store No.", POSTransaction."Store No.");
        P2MTransLine.setrange("POS Terminal No.", POSTransaction."POS Terminal No.");
        P2MTransLine.setrange("Receipt No.", POSTransaction."Receipt No.");
        P2MTransLine.SetRange("Entry Type", P2MTransLine."Entry Type"::Payment);
        P2MTransLine.SetRange("Entry Status", P2MTransLine."Entry Status"::" ");
        IF P2MTransLine.FindSet() then
            repeat
                if P2MTransLine."P2M Merch Token" <> '' then
                    if StrPos(P2MPaymentCheck(false, P2MTransLine."P2M Merch Token"), 'received') <> 0 then begin
                        AVGPOSSession.AVGPOSErrorMessages('Unable to Void Transaction.\Customer is already Paid.\Kindly Settle this Transaction.');
                        IsHandled := true;
                        exit;
                    end;
            until P2MTransLine.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnBeforeVoidLine, '', false, false)]
    local procedure OnBeforeVoidLine(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var Handled: Boolean; var HandledErrorText: Text; var ReturnValue: Boolean);
    begin
        if POSTransLine."P2M Merch Token" <> '' then
            if StrPos(P2MPaymentCheck(false, POSTransLine."P2M Merch Token"), 'received') <> 0 then begin
                AVGPOSSession.AVGPOSErrorMessages('Unable to Void Transaction.\Customer is already Paid.\Kindly Settle this Transaction.');
                Handled := true;
                ReturnValue := false;
                exit;
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnBeforevoidLinePressed, '', false, false)]
    local procedure OnBeforevoidLinePressed(var POSTransaction: Record "LSC POS Transaction"; var IsHandled: Boolean);
    var
        P2MTransLine: Record "LSC POS Trans. Line";
    begin
        P2MTransLine.Reset();
        P2MTransLine.setrange("Store No.", POSTransaction."Store No.");
        P2MTransLine.setrange("POS Terminal No.", POSTransaction."POS Terminal No.");
        P2MTransLine.setrange("Receipt No.", POSTransaction."Receipt No.");
        P2MTransLine.SetRange("Entry Type", P2MTransLine."Entry Type"::Payment);
        P2MTransLine.SetRange("Entry Status", P2MTransLine."Entry Status"::" ");
        IF P2MTransLine.FindSet() then
            repeat
                if P2MTransLine."P2M Merch Token" <> '' then
                    if StrPos(P2MPaymentCheck(false, P2MTransLine."P2M Merch Token"), 'received') <> 0 then begin
                        AVGPOSSession.AVGPOSErrorMessages('Unable to Void Transaction.\Customer is already Paid.\Kindly Settle this Transaction.');
                        IsHandled := true;
                        exit;
                    end;
            until P2MTransLine.Next() = 0;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Post Utility", OnBeforeInsertPaymentEntryV2, '', false, false)]
    local procedure OnBeforeInsertPaymentEntryV2(var POSTransaction: Record "LSC POS Transaction"; var POSTransLineTemp: Record "LSC POS Trans. Line" temporary; var TransPaymentEntry: Record "LSC Trans. Payment Entry");
    begin
        if POSTransLineTemp."P2M Merch Token" = '' then
            exit;
        TransPaymentEntry."P2M Merch Token" := POSTransLineTemp."P2M Merch Token";
        TransPaymentEntry."P2M Amount" := POSTransLineTemp."P2M Amount";
        TransPaymentEntry."P2M Bank Refrence" := POSTransLineTemp."P2M Bank Refrence";
        TransPaymentEntry."P2M Payment Reference" := POSTransLineTemp."P2M Payment Reference";
        TransPaymentEntry."P2M Payment Channel" := POSTransLineTemp."P2M Payment Channel";
        TransPaymentEntry."P2M Payment Date & Time" := POSTransLineTemp."P2M Payment Date & Time";
        TransPaymentEntry."P2M Status" := POSTransLineTemp."P2M Status";
        TransPaymentEntry."P2M Message" := POSTransLineTemp."P2M Message";
    end;

    procedure ClearP2MValues()
    begin
        LSCPOSSession.DeleteValue('P2MMERCTOKEN');
        LSCPOSSession.DeleteValue('P2MAMOUNT');
        LSCPOSSession.DeleteValue('P2MBANKREF');
        LSCPOSSession.DeleteValue('P2MPAYMENTREF');
        LSCPOSSession.DeleteValue('P2MPAYMENTCHANNEL');
        LSCPOSSession.DeleteValue('P2MPAYMENTDATETIME');
        LSCPOSSession.DeleteValue('P2MSTATUS');
        LSCPOSSession.DeleteValue('P2MMESSAGE');
    end;
}

