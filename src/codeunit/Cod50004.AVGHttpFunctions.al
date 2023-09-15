
codeunit 50004 "AVG Http Functions"
{
    SingleInstance = true;

    var
        txtResponse: Text;
        JToken: JsonToken;
        AVGPOSFunctions: Codeunit "AVG POS Functions";
        AVGPOSSession: Codeunit "AVG POS Session";
        LSCHttpWrapper: Codeunit "LSC Http Wrapper";
        LSCHttpWrapperGCashQuery: Codeunit "LSC Http Wrapper";
        LSCPOSTransactionCU: Codeunit "LSC POS Transaction";
        LSCLSCPOSSession: Codeunit "LSC POS Session";
        LSCPOSTransLineCU: Codeunit "LSC POS Trans. Lines";
        LSCAuthType: Enum "LSC Http AuthType";
        LSCContentType: Enum "LSC Http ContentType";
        TypeHelper: Codeunit "Type Helper";

    procedure ProcessAuthToken(pTxtUrl: Text; pTxtEndpoint: Text; pTxtClientID: Text; pTxtClientSecret: Text; pBolPayQR: Boolean; pTxtHeader1: Text; pTxtHeader2: Text): Text;
    var
        JObject: JsonObject;
        RStatus: Text;
        RMessage: Text;
        AVGErrorProcessAuthToken: Label 'Status: %1\Message: %2\\Contact your System Administrator.';
    begin
        ClearHttpVars;
        LSCHttpWrapper.KeepAlive(true);
        LSCHttpWrapper.ContentTypeFromEnum(LSCContentType::Json);
        LSCHttpWrapper.SetHeader('User-Agent', 'AVGAllEasy');
        IF pBolPayQR THEN
            LSCHttpWrapper.SetHeader(pTxtHeader1, pTxtHeader2);
        LSCHttpWrapper.Url(pTxtUrl + pTxtEndpoint);
        LSCHttpWrapper.Method('POST');
        CLEAR(JObject);
        JObject.Add('client_id', pTxtClientID);
        JObject.Add('client_secret', pTxtClientSecret);
        LSCHttpWrapper.RequestJson(JObject);
        IF LSCHttpWrapper.Send() THEN BEGIN
            txtResponse := GetResponseJsonByPathText('token');
            EXIT(txtResponse);
        END ELSE begin
            RStatus := GetResponseJsonByPathText('error');
            RMessage := GetResponseJsonByPathText('error_description');
            AVGPOSFunctions.AVGPOSErrorMessage(StrSubstNo(AVGErrorProcessAuthToken, RStatus, RMessage));
            exit('');
        end;
    end;

    procedure ProcessCashInInquire(pTxtUrl: Text; pTxtEndpoint: Text; pTxtMobileNo: Text; pDecAmount: Decimal; pTxtRefNo: Text; pCodTerminalID: Code[20]; pTxtStaffID: Text): Boolean;
    var
        JObject: JsonObject;
        RStatus: Text;
        RMessage: Text;
        bolOK: Boolean;
        CashInSuccessConfirmMsg: Label 'Status: %1\Message: %2\\Do you want to Procced?';
        CashInErrorMsg: Label 'Status: %1\Message: %2';
    begin
        ClearHttpVars;
        LSCHttpWrapper.KeepAlive(true);
        LSCHttpWrapper.SetCredentials('', AVGPOSSession.GetCurrAuthToken());
        LSCHttpWrapper.AuthType(LSCAuthType::Bearer);
        LSCHttpWrapper.ContentTypeFromEnum(LSCContentType::Json);
        LSCHttpWrapper.SetHeader('User-Agent', 'AVGAllEasy');
        LSCHttpWrapper.Url(pTxtUrl + pTxtEndpoint);
        LSCHttpWrapper.Method('POST');
        CLEAR(JObject);
        JObject.Add('cashin_mobileno', pTxtMobileNo);
        JObject.Add('cashin_amount', pDecAmount);
        JObject.Add('partner_refno', pTxtRefNo);
        JObject.Add('partner_terminalid', pCodTerminalID);
        JObject.Add('partner_user', pTxtStaffID);
        LSCHttpWrapper.RequestJson(JObject);
        IF LSCHttpWrapper.Send() THEN BEGIN
            RStatus := GetResponseJsonByPathText('res_status');
            RMessage := GetResponseJsonByPathText('res_message');
            bolOK := LSCPOSTransactionCU.PosConfirm(StrSubstNo(CashInSuccessConfirmMsg, RStatus, RMessage), false);
        END ELSE begin
            RStatus := GetResponseJsonByPathText('res_status');
            RMessage := GetResponseJsonByPathText('res_message');
            AVGPOSFunctions.AVGPOSErrorMessage(StrSubstNo(CashInErrorMsg, RStatus, RMessage));
            bolOK := false;
        end;
        EXIT(bolOK);
    end;

    procedure ProcessCashInCredit(pTxtUrl: Text; pTxtEndpoint: Text; pTxtMobileNo: Text; pDecAmount: Decimal; pTxtRefNo: Text; pCodTerminalID: Code[20]; pTxtStaffID: Text): Boolean;
    var
        JObject: JsonObject;
        RStatus: Text;
        RMessage: Text;
        bolOK: Boolean;
        CashInMsg: Label 'Status: %1\Message: %2';
    begin
        ClearHttpVars;
        LSCHttpWrapper.KeepAlive(true);
        LSCHttpWrapper.SetCredentials('', AVGPOSSession.GetCurrAuthToken());
        LSCHttpWrapper.AuthType(LSCAuthType::Bearer);
        LSCHttpWrapper.ContentTypeFromEnum(LSCContentType::Json);
        LSCHttpWrapper.SetHeader('User-Agent', 'AVGAllEasy');
        LSCHttpWrapper.Url(pTxtUrl + pTxtEndpoint);
        LSCHttpWrapper.Method('POST');
        CLEAR(JObject);
        JObject.Add('cashin_mobileno', pTxtMobileNo);
        JObject.Add('cashin_amount', pDecAmount);
        JObject.Add('partner_refno', pTxtRefNo);
        JObject.Add('partner_terminalid', pCodTerminalID);
        JObject.Add('partner_user', pTxtStaffID);
        LSCHttpWrapper.RequestJson(JObject);
        IF LSCHttpWrapper.Send() THEN BEGIN
            RStatus := GetResponseJsonByPathText('res_status');
            RMessage := GetResponseJsonByPathText('res_message');
            AVGPOSFunctions.AVGPOSMessage(StrSubstNo(CashInMsg, RStatus, RMessage));
            bolOK := true;
        END ELSE begin
            RStatus := GetResponseJsonByPathText('res_status');
            RMessage := GetResponseJsonByPathText('res_message');
            AVGPOSFunctions.AVGPOSErrorMessage(StrSubstNo(CashInMsg, RStatus, RMessage));
            bolOK := false;
        end;
        EXIT(bolOK);
    end;

    procedure ProcessCashOutInquire(pTxtUrl: Text; pTxtEndpoint: Text; pTxtCORefNo: Text; pTxtRefNo: Text; pCodTerminalID: Code[20]; pTxtStaffID: Text; var pTxtAmount: Text; pRecPOSTerminal: Record "LSC POS Terminal"): Boolean;
    var
        JObject: JsonObject;
        RStatus: Text;
        RMessage: Text;
        txtLValidationMessage: Text;
        txtLAmount: Text;
        decLAmount: Decimal;
        bolOK: Boolean;
        IncExpLocal: Record "LSC Income/Expense Account";
        CashOutSuccessConfirmMsg: Label 'Status: %1\Message: %2\\Do you want to Procced?';
        CashOutErrorMsg: Label 'Status: %1\Message: %2';
        AmountToAcceptErrMsg: Label '%1 is: %2.\\Transaction will not Proceed.';
        ValidationErrMsg: Label 'Message: %1\Status: %2\Branch: %3\Validated By: %4\Validated At: %5';
    begin
        ClearHttpVars;
        LSCHttpWrapper.KeepAlive(true);
        LSCHttpWrapper.SetCredentials('', AVGPOSSession.GetCurrAuthToken());
        LSCHttpWrapper.AuthType(LSCAuthType::Bearer);
        LSCHttpWrapper.ContentTypeFromEnum(LSCContentType::Json);
        LSCHttpWrapper.SetHeader('User-Agent', 'AVGAllEasy');
        LSCHttpWrapper.Url(pTxtUrl + pTxtEndpoint);
        LSCHttpWrapper.Method('POST');
        CLEAR(JObject);
        JObject.Add('cashout_refno', pTxtCORefNo);
        JObject.Add('partner_refno', pTxtRefNo);
        JObject.Add('partner_terminalid', pCodTerminalID);
        JObject.Add('partner_user', pTxtStaffID);
        LSCHttpWrapper.RequestJson(JObject);
        IF LSCHttpWrapper.Send() THEN BEGIN
            RStatus := GetResponseJsonByPathText('res_status');
            RMessage := GetResponseJsonByPathText('res_message');
            bolOK := LSCPOSTransactionCU.PosConfirm(StrSubstNo(CashOutSuccessConfirmMsg, RStatus, RMessage), false);
            IF bolOK THEN BEGIN
                txtLAmount := GetResponseJsonByPathText('res_data.amount');
                IF NOT Evaluate(decLAmount, txtLAmount) then
                    bolOK := false;
                pTxtAmount := txtLAmount;
                IncExpLocal.Get(pRecPOSTerminal."Store No.", pRecPOSTerminal."AE Cash Out Exp. Acc.");
                IF (decLAmount < IncExpLocal."AE Minimum Amount to Accept") THEN begin
                    AVGPOSFunctions.AVGPOSErrorMessage(StrSubstNo(AmountToAcceptErrMsg, IncExpLocal.FIELDCAPTION("AE Minimum Amount To Accept"), FORMAT(IncExpLocal."AE Minimum Amount To Accept")));
                    bolOK := false;
                end;
                IF (decLAmount > IncExpLocal."AE Maximum Amount to Accept") THEN BEGIN
                    AVGPOSFunctions.AVGPOSErrorMessage(StrSubstNo(AmountToAcceptErrMsg, IncExpLocal.FIELDCAPTION("AE Maximum Amount To Accept"), FORMAT(IncExpLocal."AE Maximum Amount To Accept")));
                    bolOK := false;
                end;
                IF GetResponseJsonByPathText('res_status') <> 'PENDING' then begin
                    txtLValidationMessage :=
                        StrSubstNo(ValidationErrMsg,
                            GetResponseJsonByPathText('res_message'),
                            GetResponseJsonByPathText('res_status'),
                            GetResponseJsonByPathText('res_data.branch'),
                            GetResponseJsonByPathText('res_data.validated_by'),
                            GetResponseJsonByPathText('res_data.validated_at'));
                    AVGPOSFunctions.AVGPOSErrorMessage(txtLValidationMessage);
                    bolOK := false;
                end;
            END;
        END ELSE begin
            RStatus := GetResponseJsonByPathText('res_status');
            RMessage := GetResponseJsonByPathText('res_message');
            AVGPOSFunctions.AVGPOSErrorMessage(StrSubstNo(CashOutErrorMsg, RStatus, RMessage));
            bolOK := false;
        end;
        EXIT(bolOK);
    end;

    procedure ProcessCashOutProcess(pTxtUrl: Text; pTxtEndpoint: Text; pTxtCORefNo: Text; pTxtRefNo: Text; pCodTerminalID: Code[20]; pTxtStaffID: Text): Boolean;
    var
        JObject: JsonObject;
        RStatus: Text;
        RMessage: Text;
        bolOK: Boolean;
        CashOutMsg: Label 'Status: %1\Message: %2';
    begin
        ClearHttpVars;
        LSCHttpWrapper.KeepAlive(true);
        LSCHttpWrapper.SetCredentials('', AVGPOSSession.GetCurrAuthToken());
        LSCHttpWrapper.AuthType(LSCAuthType::Bearer);
        LSCHttpWrapper.ContentTypeFromEnum(LSCContentType::Json);
        LSCHttpWrapper.SetHeader('User-Agent', 'AVGAllEasy');
        LSCHttpWrapper.Url(pTxtUrl + pTxtEndpoint);
        LSCHttpWrapper.Method('POST');
        CLEAR(JObject);
        JObject.Add('cashout_refno', pTxtCORefNo);
        JObject.Add('partner_refno', pTxtRefNo);
        JObject.Add('partner_terminalid', pCodTerminalID);
        JObject.Add('partner_user', pTxtStaffID);
        LSCHttpWrapper.RequestJson(JObject);
        IF LSCHttpWrapper.Send() THEN BEGIN
            RStatus := GetResponseJsonByPathText('res_status');
            RMessage := GetResponseJsonByPathText('res_message');
            AVGPOSFunctions.AVGPOSMessage(StrSubstNo(CashOutMsg, RStatus, RMessage));
            bolOK := true;
        END ELSE begin
            RStatus := GetResponseJsonByPathText('res_status');
            RMessage := GetResponseJsonByPathText('res_message');
            AVGPOSFunctions.AVGPOSErrorMessage(StrSubstNo(CashOutMsg, RStatus, RMessage));
            bolOK := false;
        end;
        EXIT(bolOK);
    end;

    procedure ProcessPayQRInquire(pTxtEndpoint: Text): Boolean;
    var
        RStatus: Text;
        RMessage: Text;
        RError: Text;
        bolOK: Boolean;
        PayQRSuccessMsg: Label 'Status: %1\Message: %2\\Do you want to Proceed?';
        PayQRErrorMsg: Label 'Status: %1\Message: %2\Reason: %3\\Transaction will not Proceed.';
        PayQRProcessedErrMsg: Label 'QR Code is already Proccessed.\\Transaction will not Proceed.';
    begin
        ClearHttpVars;
        LSCHttpWrapper.KeepAlive(true);
        LSCHttpWrapper.SetCredentials('', AVGPOSSession.GetCurrAuthToken());
        LSCHttpWrapper.AuthType(LSCAuthType::Bearer);
        LSCHttpWrapper.ContentTypeFromEnum(LSCContentType::Json);
        LSCHttpWrapper.SetHeader('User-Agent', 'AVGAllEasy');
        LSCHttpWrapper.Url(pTxtEndpoint);
        IF LSCHttpWrapper.Send() THEN BEGIN
            RStatus := GetResponseJsonByPathText('data.response.status');
            RMessage := GetResponseJsonByPathText('message');
            IF RMessage = 'ok' then
                RMessage := 'QR Code is Valid.';
            if Rstatus.Contains('SEND') then begin
                AVGPOSFunctions.AVGPOSErrorMessage(PayQRProcessedErrMsg);
                bolOK := false;
            end ELSE
                bolOK := LSCPOSTransactionCU.PosConfirm(StrSubstNo(PayQRSuccessMsg, RStatus, RMessage), false);
        END ELSE BEGIN
            IF EVALUATE(RStatus, FORMAT(GetResponseJsonByPathText('statusCode'))) THEN;
            RMessage := GetResponseJsonByPathText('message');
            RError := GetResponseJsonByPathText('error');
            AVGPOSFunctions.AVGPOSErrorMessage(StrSubstNo(PayQRErrorMsg, RStatus, RMessage, RError));
            bolOK := false;
        END;

        EXIT(bolOK);
    end;

    procedure ProcessPayQRProcess(pTxtEndpoint: Text): Boolean;
    var
        RStatus: Integer;
        RMessage: Text;
        RError: Text;
        bolOK: Boolean;
        PayQRSuccessMsg: Label 'Status Code: %1\Message: %2';
        PayQRErrorMsg: Label 'Status: %1\Message: %2\Reason: %3\\Transaction will not Proceed.';
    begin
        ClearHttpVars;
        LSCHttpWrapper.KeepAlive(true);
        LSCHttpWrapper.SetCredentials('', AVGPOSSession.GetCurrAuthToken());
        LSCHttpWrapper.AuthType(LSCAuthType::Bearer);
        LSCHttpWrapper.ContentTypeFromEnum(LSCContentType::Json);
        LSCHttpWrapper.SetHeader('User-Agent', 'AVGAllEasy');
        LSCHttpWrapper.Url(pTxtEndpoint);
        LSCHttpWrapper.Method('POST');
        IF LSCHttpWrapper.Send() THEN BEGIN
            IF EVALUATE(RStatus, FORMAT(GetResponseJsonByPathText('status'))) THEN;
            RMessage := GetResponseJsonByPathText('message');
            IF RMessage = 'OK' then
                RMessage := 'Payment using AllEasy QR Code has been Successfully Posted.';
            AVGPOSFunctions.AVGPOSMessage(Strsubstno(PayQRSuccessMsg, RStatus, RMessage));
            bolOK := TRUE;
        END ELSE BEGIN
            IF EVALUATE(RStatus, FORMAT(GetResponseJsonByPathText('statusCode'))) THEN;
            RMessage := GetResponseJsonByPathText('message');
            AVGPOSFunctions.AVGPOSErrorMessage(StrSubstNo(PayQRErrorMsg, RStatus, RMessage, 'Not Found.'));
            bolOK := false;
        END;

        EXIT(bolOK);
    end;

    procedure GCashHeartBeatCheck(pRecPOSTerminal: Record "LSC POS Terminal"; WithPromptMsg: Boolean): Boolean
    var
        JObjectReqMerged: JsonObject;
        JObjectReqHeaderDetails: JsonObject;
        JObjectReqBodyDetails: JsonObject;
        JObjectRequest: JsonObject;
        JsonRequestString: Text;
        SignatureString: Text;
        EndpointString: Text;
        VerifiedKeyPair: Boolean;
    begin
        CLEAR(SignatureString);
        JObjectReqHeaderDetails.Add('version', pRecPOSTerminal."GCash Version");
        JObjectReqHeaderDetails.Add('function', GetGCashFunction(7));
        JObjectReqHeaderDetails.Add('clientId', pRecPOSTerminal."GCash Client ID");
        JObjectReqHeaderDetails.Add('clientSecret', pRecPOSTerminal."GCash Client Secret");
        JObjectReqHeaderDetails.Add('reqTime', TypeHelper.GetCurrUTCDateTimeISO8601());
        JObjectReqHeaderDetails.Add('reqMsgId', AVGPOSFunctions.AVGCreateStandardGuidFormat(pRecPOSTerminal, 'H'));// H = HeartBeat;
        JObjectReqBodyDetails.Add('echo', 'test connection');
        JObjectReqMerged.Add('head', JObjectReqHeaderDetails);
        JObjectReqMerged.Add('body', JObjectReqBodyDetails);
        CLEAR(JsonRequestString);
        JObjectReqMerged.WriteTo(JsonRequestString);

        JObjectRequest.Add('request', JObjectReqMerged);
        CLEAR(SignatureString);
        VerifiedKeyPair := GCashGenerateSignature(JsonRequestString, pRecPOSTerminal, SignatureString);
        JObjectRequest.Add('signature', SignatureString);
        IF VerifiedKeyPair THEN begin
            CLEAR(EndpointString);
            EndpointString := pRecPOSTerminal."GCash URL" + pRecPOSTerminal."HeartBeat Check Endpoint";
            IF ProcessGCashHttpWebRequest(EndpointString, JObjectRequest) THEN BEGIN
                IF GetResponseJsonByPathText('response.body.resultInfo.resultStatus') = 'S' then
                    IF WithPromptMsg THEN
                        AVGPOSFunctions.AVGPOSMessage('GCash Heartbeat is Online.')
                    ELSE
                        EXIT(TRUE);
            end ELSE
                if WithPromptMsg then
                    AVGPOSFunctions.AVGPOSErrorMessage('GCash Heartbeat is Offline.')
                ELSE
                    exit(false);
        END;

    end;

    procedure GCashRetailPay(pRecPOSTerminal: Record "LSC POS Terminal"; pTxtAmount: Text; pQRCode: Code[80]): Boolean
    var
        JObjectOrder: JsonObject;
        JObjectShopInfo: JsonObject;
        JObjectScannerInfo: JsonObject;
        JObjectEnvInfo: JsonObject;
        JObjectMoney: JsonObject;
        JObjectReqMerged: JsonObject;
        JObjectReqHeaderDetails: JsonObject;
        JObjectReqBodyDetails: JsonObject;
        JObjectRequest: JsonObject;
        JsonRequestString: Text;
        SignatureString: Text;
        EndpointString: Text;
        MerchantTransId: Text;
        StatusString: Text;
        QueryStatusString: Text;
        VerifiedKeyPair: Boolean;
        LSCPOSTransLineRec: Record "LSC POS Trans. Line";
        Amount: Decimal;
        Counter: Integer;
    begin
        Clear(Amount);
        IF NOT Evaluate(Amount, pTxtAmount) then
            AVGPOSSession.AVGPOSErrorMessages('Invalid Amount.');

        IF Amount = 0 then
            EXIT;

        pTxtAmount := LSCPOSTransactionCU.FormatAmount(Amount);
        pTxtAmount := DELCHR(pTxtAmount, '=', ',|.');

        LSCPOSTransLineCU.GetCurrentLine(LSCPOSTransLineRec);
        CLEAR(MerchantTransId);
        MerchantTransId := DELCHR(AVGPOSFunctions.AVGCreateStandardGuidFormat(pRecPOSTerminal, 'P')); // P = Retail Pay
        IF MerchantTransId = '' then
            MerchantTransId := LSCPOSTransLineRec."Receipt No.";

        CLEAR(SignatureString);

        //Order
        JObjectMoney.Add('currency', LSCLSCPOSSession.ActiveCurrencyCode());
        JObjectMoney.Add('value', pTxtAmount);

        JObjectOrder.Add('orderAmount', JObjectMoney);
        JObjectOrder.Add('merchantTransId', LSCPOSTransLineRec."Receipt No.");
        JObjectOrder.Add('orderTitle', pRecPOSTerminal."GCash Order Title");

        JObjectShopInfo.Add('shopId', pRecPOSTerminal."Shop ID");
        JObjectShopInfo.Add('shopName', pRecPOSTerminal."Shop Name");

        JObjectScannerInfo.Add('deviceId', pRecPOSTerminal."GCash Scanner Device ID");
        JObjectScannerInfo.Add('deviceIp', pRecPOSTerminal."GCash Scanner Device IP");

        JObjectEnvInfo.Add('orderTerminalType', pRecPOSTerminal."GCash Order Terminal Type");
        JObjectEnvInfo.Add('terminalType', pRecPOSTerminal."GCash Terminal Type");
        JObjectEnvInfo.Add('merchantTerminalId', pRecPOSTerminal."GCash Merchant Terminal ID");

        //Header
        JObjectReqHeaderDetails.Add('version', pRecPOSTerminal."GCash Version");
        JObjectReqHeaderDetails.Add('function', GetGCashFunction(8));
        JObjectReqHeaderDetails.Add('clientId', pRecPOSTerminal."GCash Client ID");
        JObjectReqHeaderDetails.Add('clientSecret', pRecPOSTerminal."GCash Client Secret");
        JObjectReqHeaderDetails.Add('reqTime', TypeHelper.GetCurrUTCDateTimeISO8601());
        JObjectReqHeaderDetails.Add('reqMsgId', AVGPOSFunctions.AVGCreateStandardGuidFormat(pRecPOSTerminal, 'P')); // P = Retail Pay

        //Body
        JObjectReqBodyDetails.Add('order', JObjectOrder);
        JObjectReqBodyDetails.Add('merchantId', pRecPOSTerminal."GCash Merchant ID");
        JObjectReqBodyDetails.Add('shopInfo', JObjectShopInfo);
        JObjectReqBodyDetails.Add('scannerInfo', JObjectScannerInfo);
        JObjectReqBodyDetails.Add('productCode', pRecPOSTerminal."GCash Product Code");
        JObjectReqBodyDetails.Add('authCodeType', pRecPOSTerminal."GCash AuthCode Type");
        JObjectReqBodyDetails.Add('authCode', pQRCode);
        JObjectReqBodyDetails.Add('envInfo', JObjectEnvInfo);

        JObjectReqMerged.Add('head', JObjectReqHeaderDetails);
        JObjectReqMerged.Add('body', JObjectReqBodyDetails);
        CLEAR(JsonRequestString);
        JObjectReqMerged.WriteTo(JsonRequestString);

        JObjectRequest.Add('request', JObjectReqMerged);
        CLEAR(SignatureString);
        VerifiedKeyPair := GCashGenerateSignature(JsonRequestString, pRecPOSTerminal, SignatureString);
        JObjectRequest.Add('signature', SignatureString);
        IF VerifiedKeyPair THEN begin
            CLEAR(EndpointString);
            EndpointString := pRecPOSTerminal."GCash URL" + pRecPOSTerminal."Retail Pay Endpoint";
            IF ProcessGCashHttpWebRequest(EndpointString, JObjectRequest) THEN BEGIN
                StatusString := GetResponseJsonByPathText('response.body.resultInfo.resultStatus');
                case StatusString of
                    'S':
                        begin
                            InsertIntoGCashTransLine(8, AVGPOSSession.GetCurrGCashPayQRCode(), LSCHttpWrapper.GetRequestAsText(), LSCHttpWrapper.ResponseText());
                            exit(true);
                        end;
                    'F':
                        begin
                            InsertIntoGCashTransLine(8, AVGPOSSession.GetCurrGCashPayQRCode(), LSCHttpWrapper.GetRequestAsText(), LSCHttpWrapper.ResponseText());
                            exit(false);
                        end;
                    '', 'U':
                        begin
                            InsertIntoGCashTransLine(8, AVGPOSSession.GetCurrGCashPayQRCode(), LSCHttpWrapper.GetRequestAsText(), LSCHttpWrapper.ResponseText());
                            for counter := 0 to 3 DO begin
                                GCashQuery(pRecPOSTerminal, false, ProcessGCashTransIDHierarchy);
                                InsertIntoGCashTransLine(9, AVGPOSSession.GetCurrGCashPayQRCode(), LSCHttpWrapperGCashQuery.GetRequestAsText(), LSCHttpWrapperGCashQuery.ResponseText());
                                CLEAR(QueryStatusString);
                                QueryStatusString := GCashQueryGetResponseJsonByPathText('response.body.statusDetail.acquirementStatus');
                                IF QueryStatusString IN ['SUCCESS', 'CLOSED'] then
                                    break;
                                IF counter = 3 then begin
                                    GCashCancel(pRecPOSTerminal, ProcessGCashTransIDHierarchy);
                                    InsertIntoGCashTransLine(10, AVGPOSSession.GetCurrGCashPayQRCode(), LSCHttpWrapperGCashQuery.GetRequestAsText(), LSCHttpWrapperGCashQuery.ResponseText());
                                    exit(false);
                                end;
                            end;
                            case QueryStatusString of
                                'SUCCESS':
                                    begin
                                        InsertIntoGCashTransLine(8, AVGPOSSession.GetCurrGCashPayQRCode(), LSCHttpWrapperGCashQuery.GetRequestAsText(), LSCHttpWrapperGCashQuery.ResponseText());
                                        exit(true);
                                    end;
                                'CLOSED':
                                    begin
                                        InsertIntoGCashTransLine(9, AVGPOSSession.GetCurrGCashPayQRCode(), LSCHttpWrapperGCashQuery.GetRequestAsText(), LSCHttpWrapperGCashQuery.ResponseText());
                                        exit(false);
                                    end;
                            end;
                        end;
                    else begin
                        AVGPOSFunctions.AVGPOSErrorMessage('Invalid Request.');
                        EXIT(false);
                    end;
                end;
            END ELSE begin
                AVGPOSFunctions.AVGPOSErrorMessage('Response Failed.\' + GetResponseJsonByPathText('response.body.resultInfo.resultMsg'));
                EXIT(false);
            end;
        end ELSE
            exit(false);
    END;

    procedure GCashQuery(pRecPOSTerminal: Record "LSC POS Terminal"; WithPromptMsg: Boolean; pAcqID: Text): Boolean
    var
        JObjectOrder: JsonObject;
        JObjectShopInfo: JsonObject;
        JObjectScannerInfo: JsonObject;
        JObjectEnvInfo: JsonObject;
        JObjectMoney: JsonObject;
        JObjectReqMerged: JsonObject;
        JObjectReqHeaderDetails: JsonObject;
        JObjectReqBodyDetails: JsonObject;
        JObjectRequest: JsonObject;
        JsonRequestString: Text;
        SignatureString: Text;
        EndpointString: Text;
        VerifiedKeyPair: Boolean;
        LSCPOSTransLineRec: Record "LSC POS Trans. Line";
    begin

        CLEAR(SignatureString);

        //Header
        JObjectReqHeaderDetails.Add('version', pRecPOSTerminal."GCash Version");
        JObjectReqHeaderDetails.Add('function', GetGCashFunction(9));
        JObjectReqHeaderDetails.Add('clientId', pRecPOSTerminal."GCash Client ID");
        JObjectReqHeaderDetails.Add('clientSecret', pRecPOSTerminal."GCash Client Secret");
        JObjectReqHeaderDetails.Add('reqTime', TypeHelper.GetCurrUTCDateTimeISO8601());
        JObjectReqHeaderDetails.Add('reqMsgId', AVGPOSFunctions.AVGCreateStandardGuidFormat(pRecPOSTerminal, 'Q'));// Q = Query Trans

        //Body
        JObjectReqBodyDetails.Add('merchantId', pRecPOSTerminal."GCash Merchant ID");
        JObjectReqBodyDetails.Add('acquirementId', pAcqID);

        JObjectReqMerged.Add('head', JObjectReqHeaderDetails);
        JObjectReqMerged.Add('body', JObjectReqBodyDetails);
        CLEAR(JsonRequestString);
        JObjectReqMerged.WriteTo(JsonRequestString);

        JObjectRequest.Add('request', JObjectReqMerged);
        CLEAR(SignatureString);
        VerifiedKeyPair := GCashGenerateSignature(JsonRequestString, pRecPOSTerminal, SignatureString);
        JObjectRequest.Add('signature', SignatureString);
        IF VerifiedKeyPair THEN begin
            CLEAR(EndpointString);
            EndpointString := pRecPOSTerminal."GCash URL" + pRecPOSTerminal."Query Transaction Endpoint";
            IF ProcessGCashQueryHttpWebRequest(EndpointString, JObjectRequest) THEN BEGIN
                IF GCashQueryGetResponseJsonByPathText('response.body.resultInfo.resultStatus') = 'S' then
                    IF WithPromptMsg THEN
                        AVGPOSFunctions.AVGPOSMessage('GCash Heartbeat is Online.')
                    ELSE
                        EXIT(TRUE);
            end ELSE
                if WithPromptMsg then
                    AVGPOSFunctions.AVGPOSErrorMessage('GCash Heartbeat is Offline.')
                ELSE
                    exit(false);
        END;
    end;

    procedure GCashCancel(pRecPOSTerminal: Record "LSC POS Terminal"; pTxtAcqId: Text): Boolean
    var
        JObjectOrder: JsonObject;
        JObjectShopInfo: JsonObject;
        JObjectScannerInfo: JsonObject;
        JObjectEnvInfo: JsonObject;
        JObjectMoney: JsonObject;
        JObjectReqMerged: JsonObject;
        JObjectReqHeaderDetails: JsonObject;
        JObjectReqBodyDetails: JsonObject;
        JObjectRequest: JsonObject;
        JsonRequestString: Text;
        SignatureString: Text;
        EndpointString: Text;
        VerifiedKeyPair: Boolean;
        LSCPOSTransLineRec: Record "LSC POS Trans. Line";
        Amount: Decimal;
    begin

        //Header
        JObjectReqHeaderDetails.Add('version', pRecPOSTerminal."GCash Version");
        JObjectReqHeaderDetails.Add('function', GetGCashFunction(10));
        JObjectReqHeaderDetails.Add('clientId', pRecPOSTerminal."GCash Client ID");
        JObjectReqHeaderDetails.Add('clientSecret', pRecPOSTerminal."GCash Client Secret");
        JObjectReqHeaderDetails.Add('reqTime', TypeHelper.GetCurrUTCDateTimeISO8601());
        JObjectReqHeaderDetails.Add('reqMsgId', AVGPOSFunctions.AVGCreateStandardGuidFormat(pRecPOSTerminal, 'C'));// C = Cancel Trans.

        //Body
        JObjectReqBodyDetails.Add('acquirementId', pTxtAcqId);
        JObjectReqBodyDetails.Add('merchantId', pRecPOSTerminal."GCash Merchant ID");

        JObjectReqMerged.Add('head', JObjectReqHeaderDetails);
        JObjectReqMerged.Add('body', JObjectReqBodyDetails);

        CLEAR(JsonRequestString);
        JObjectReqMerged.WriteTo(JsonRequestString);

        JObjectRequest.Add('request', JObjectReqMerged);
        CLEAR(SignatureString);
        VerifiedKeyPair := GCashGenerateSignature(JsonRequestString, pRecPOSTerminal, SignatureString);
        JObjectRequest.Add('signature', SignatureString);
        IF VerifiedKeyPair THEN begin
            CLEAR(EndpointString);
            EndpointString := pRecPOSTerminal."GCash URL" + pRecPOSTerminal."Cancel Transaction Endpoint";
            IF ProcessGCashHttpWebRequest(EndpointString, JObjectRequest) THEN BEGIN
                IF GetResponseJsonByPathText('response.body.resultInfo.resultStatus') = 'S' then begin
                    InsertIntoGCashTransLine(10, '', LSCHttpWrapper.GetRequestAsText(), LSCHttpWrapper.ResponseText());
                    EXIT(TRUE);
                end else
                    exit(false);
            end ELSE
                exit(false);
        END;
    end;

    procedure GCashRefund(pRecPOSTerminal: Record "LSC POS Terminal"; pTxtAmount: Text; pAcqID: Code[80]): Boolean
    var
        JObjectRefundOrder: JsonObject;
        JObjectMoney: JsonObject;
        JObjectReqMerged: JsonObject;
        JObjectReqHeaderDetails: JsonObject;
        JObjectReqBodyDetails: JsonObject;
        JObjectRequest: JsonObject;
        JsonRequestString: Text;
        SignatureString: Text;
        EndpointString: Text;
        MerchantTransId: Text;
        VerifiedKeyPair: Boolean;
        LSCPOSTransLineRec: Record "LSC POS Trans. Line";
        Amount: Decimal;
        RefundReasonInfocode: Record "LSC Infocode";
        LSCTempPOSMenuLineRec: Record "LSC POS Menu Line" temporary;
    begin
        pRecPOSTerminal.TestField("GCash Reason Code");
        RefundReasonInfocode.GET(pRecPOSTerminal."GCash Reason Code");
        LSCTempPOSMenuLineRec.RESET;
        LSCTempPOSMenuLineRec.DeleteAll();
        // LSCLSCPOSSession.GetPosMenuRec()
        // LSCTempPOSMenuLineRec.

        // LSCPOSTransactionCU.InfoKeyPressed();
        CLEAR(MerchantTransId);
        MerchantTransId := DELCHR(AVGPOSFunctions.AVGCreateStandardGuidFormat(pRecPOSTerminal, 'R')); // R = Refund
        IF MerchantTransId = '' then
            MerchantTransId := LSCPOSTransLineRec."Receipt No.";

        Clear(Amount);
        IF NOT Evaluate(Amount, pTxtAmount) then
            AVGPOSSession.AVGPOSErrorMessages('Invalid Amount.');

        IF Amount = 0 then
            EXIT;

        pTxtAmount := LSCPOSTransactionCU.FormatAmount(Amount);
        pTxtAmount := DELCHR(pTxtAmount, '=', ',|.');

        CLEAR(SignatureString);
        //Order
        LSCPOSTransLineCU.GetCurrentLine(LSCPOSTransLineRec);
        JObjectMoney.Add('currency', LSCLSCPOSSession.ActiveCurrencyCode());
        JObjectMoney.Add('value', pTxtAmount);


        //Header
        JObjectReqHeaderDetails.Add('version', pRecPOSTerminal."GCash Version");
        JObjectReqHeaderDetails.Add('function', GetGCashFunction(11));
        JObjectReqHeaderDetails.Add('clientId', pRecPOSTerminal."GCash Client ID");
        JObjectReqHeaderDetails.Add('clientSecret', pRecPOSTerminal."GCash Client Secret");
        JObjectReqHeaderDetails.Add('reqTime', TypeHelper.GetCurrUTCDateTimeISO8601());
        JObjectReqHeaderDetails.Add('reqMsgId', AVGPOSFunctions.AVGCreateStandardGuidFormat(pRecPOSTerminal, 'R'));// R = Refund Trans.

        //Body
        JObjectReqBodyDetails.Add('merchantId', pRecPOSTerminal."GCash Merchant ID");
        JObjectReqBodyDetails.Add('acquirementId', pAcqID);
        JObjectReqBodyDetails.Add('merchantTransId', MerchantTransId);
        JObjectReqBodyDetails.Add('requestId', LSCPOSTransLineRec."Receipt No.");
        JObjectReqBodyDetails.Add('refundAmount', JObjectRefundOrder);

        JObjectReqBodyDetails.Add('refundAppliedTime', TypeHelper.GetCurrUTCDateTimeISO8601());
        JObjectReqBodyDetails.Add('refundReason', AVGPOSSession.GetCurrGCashSelectedInfocode());


        JObjectReqMerged.Add('head', JObjectReqHeaderDetails);
        JObjectReqMerged.Add('body', JObjectReqBodyDetails);
        CLEAR(JsonRequestString);
        JObjectReqMerged.WriteTo(JsonRequestString);

        JObjectRequest.Add('request', JObjectReqMerged);
        CLEAR(SignatureString);
        VerifiedKeyPair := GCashGenerateSignature(JsonRequestString, pRecPOSTerminal, SignatureString);
        JObjectRequest.Add('signature', SignatureString);
        IF VerifiedKeyPair THEN begin
            CLEAR(EndpointString);
            EndpointString := pRecPOSTerminal."GCash URL" + pRecPOSTerminal."Refund Transaction Endpoint";
            IF ProcessGCashHttpWebRequest(EndpointString, JObjectRequest) THEN BEGIN
                IF GetResponseJsonByPathText('response.body.resultInfo.resultStatus') = 'S' then begin
                    InsertIntoGCashTransLine(11, '', LSCHttpWrapper.GetRequestAsText(), LSCHttpWrapper.ResponseText());
                    EXIT(TRUE);
                end else
                    exit(false);
            end ELSE
                exit(false);
        END;
    end;

    local procedure ProcessGCashHttpWebRequest(EndpointText: Text; JObjectRequest: JsonObject): Boolean
    begin
        ClearHttpVars;
        LSCHttpWrapper.KeepAlive(true);
        LSCHttpWrapper.ContentTypeFromEnum(LSCContentType::Json);
        LSCHttpWrapper.SetHeader('User-Agent', 'AVGGCash');
        LSCHttpWrapper.Url(EndpointText);
        LSCHttpWrapper.Method('POST');
        LSCHttpWrapper.RequestJson(JObjectRequest);
        IF LSCHttpWrapper.Send() THEN
            EXIT(TRUE)
        ELSE
            EXIT(FALSE);
    end;

    local procedure ProcessGCashQueryHttpWebRequest(EndpointText: Text; JObjectRequest: JsonObject): Boolean
    begin
        ClearHttpVarsGCashQuery;
        LSCHttpWrapperGCashQuery.KeepAlive(true);
        LSCHttpWrapperGCashQuery.ContentTypeFromEnum(LSCContentType::Json);
        LSCHttpWrapperGCashQuery.SetHeader('User-Agent', 'AVGGCash');
        LSCHttpWrapperGCashQuery.Url(EndpointText);
        LSCHttpWrapperGCashQuery.Method('POST');
        LSCHttpWrapperGCashQuery.RequestJson(JObjectRequest);
        IF LSCHttpWrapperGCashQuery.Send() THEN
            EXIT(TRUE)
        ELSE
            EXIT(FALSE);
    end;

    local procedure GCashGenerateSignature(pJObjectRequest: Text; pRecPOSTerminal: Record "LSC POS Terminal"; var SignatureString: Text): Boolean;
    var
        txtReadPrivateKey: Text;
        txtReadPrivateKeyValue: Text;
        txtReadPublicKey: Text;
        txtReadPublicKeyValue: Text;
        SignatureBase64: Text;
        InStrPrivateKey: InStream;
        InStrPublicKey: InStream;
        PrivateKeyReader: DotNet PemReader;
        PubkeyReader: DotNet PemReader;
        PrivateKeyCert: DotNet RsaPrivateCrtKeyParameters;
        PublicKeyCert: DotNet RsaKeyParameters;
        StringReader: DotNet StringReader;
        CustTextReader: DotNet CustTextReader;
        Sha256Digest: DotNet Sha256Digest;
        RsaDigestSigner: DotNet RsaDigestSigner;
        dataBytes: DotNet Array;
        signatureBytes: DotNet Array;
        Encoder: DotNet Encoding;
        Convert64: DotNet Convert;
        Verified: Boolean;
    begin

        CLEAR(SignatureBase64);
        CLEAR(txtReadPrivateKey);
        CLEAR(txtReadPrivateKeyValue);
        pRecPOSTerminal.CalcFields("GCash Private Key", "GCash Public Key");
        IF pRecPOSTerminal."GCash Private Key".HasValue THEN begin
            pRecPOSTerminal."GCash Private Key".CreateInStream(InStrPrivateKey);
            while not InStrPrivateKey.EOS DO begin
                InStrPrivateKey.Read(txtReadPrivateKey);
                txtReadPrivateKeyValue += txtReadPrivateKey;
            end;
            pRecPOSTerminal."GCash Public Key".CreateInStream(InStrPublicKey);
            while not InStrPublicKey.EOS DO begin
                InStrPublicKey.Read(txtReadPublicKey);
                txtReadPublicKeyValue += txtReadPublicKey;
            end;
        end;

        // SignData
        StringReader := StringReader.StringReader(txtReadPrivateKeyValue);
        CustTextReader := StringReader;
        PrivateKeyReader := PrivateKeyReader.PemReader(CustTextReader);
        PrivateKeyCert := PrivateKeyReader.ReadObject;
        Sha256Digest := Sha256Digest.Sha256Digest;
        dataBytes := Encoder.UTF8.GetBytes(STRSUBSTNO('%1', pJObjectRequest));
        RsaDigestSigner := RsaDigestSigner.RsaDigestSigner(Sha256Digest);
        RsaDigestSigner.Init(TRUE, PrivateKeyCert);
        RsaDigestSigner.BlockUpdate(dataBytes, 0, dataBytes.Length);
        SignatureBase64 := Convert64.ToBase64String(RsaDigestSigner.GenerateSignature());
        SignatureString := SignatureBase64;

        //Verify
        StringReader := StringReader.StringReader(txtReadPublicKeyValue);
        CustTextReader := StringReader;
        PubkeyReader := PubkeyReader.PemReader(CustTextReader);
        PublicKeyCert := PubkeyReader.ReadObject();
        Sha256Digest := Sha256Digest.Sha256Digest();
        dataBytes := Encoder.UTF8.GetBytes(STRSUBSTNO('%1', pJObjectRequest));
        RsaDigestSigner := RsaDigestSigner.RsaDigestSigner(Sha256Digest);
        RsaDigestSigner.Init(FALSE, PublicKeyCert);
        RsaDigestSigner.BlockUpdate(dataBytes, 0, dataBytes.Length);
        Verified := RsaDigestSigner.VerifySignature(Convert64.FromBase64String(SignatureBase64));

        EXIT(Verified);
    end;

    local procedure ProcessGCashTransIDHierarchy(): Text
    var
        IDString: Text;
    begin
        CLEAR(IDString);
        IDString := GetResponseJsonByPathText('response.body.acquirementId');
        IF IDString = '' then
            IDString := GetResponseJsonByPathText('response.body.merchantTransId');
        IF IDString = '' then
            IDString := GetResponseJsonByPathText('response.body.transactionId');
        EXIT(IDString);
    end;

    local procedure InsertIntoGCashTransLine(pGCashProcessType: Integer; pAutCode: Text; pRequest: Text; pResponse: Text)
    var
        OutStrGCashReq: OutStream;
        OutStrGCashRes: OutStream;
        GCashTransLine: Record "AVG Trans. Line";
        GCashTransLine2: Record "AVG Trans. Line";
        intLLineNo: Integer;
        LSCPOSSession: Codeunit "LSC POS Session";
        POSTransactionCU: Codeunit "LSC POS Transaction";
        POSTransLineCU: Codeunit "LSC POS Trans. Lines";
        GCashProcessType: Enum "AVG Type Trans. Line";
    begin
        GCashProcessType := "AVG Type Trans. Line".FromInteger(pGCashProcessType);
        intLLineNo := 0;
        IF NOT GCashTransLine2.RecordLevelLocking then
            GCashTransLine2.LockTable(TRUE, TRUE);

        GCashTransLine2.RESET;
        GCashTransLine2.SetCurrentKey("Receipt No.", "Line No.");
        GCashTransLine2.SETRANGE("Store No.", LSCPOSSession.StoreNo());
        GCashTransLine2.SETRANGE("POS Terminal No.", LSCPOSSession.TerminalNo());
        GCashTransLine2.SETRANGE("Receipt No.", POSTransactionCU.GetReceiptNo());
        IF GCashTransLine2.FindLast() THEN
            intLLineNo := GCashTransLine2."Line No." + 10000
        else
            intLLineNo := 10000;

        GCashTransLine.INIT;
        GCashTransLine."Receipt No." := POSTransactionCU.GetReceiptNo();
        GCashTransLine."Line No." := intLLineNo;
        GCashTransLine."Store No." := POSTransactionCU.GetStoreNo();
        GCashTransLine."POS Terminal No." := POSTransactionCU.GetPOSTerminalNo();
        GCashTransLine."Trans. Date" := WorkDate();
        GCashTransLine."Trans. Time" := Time;
        GCashTransLine."Authorization Code" := pAutCode;
        GCashTransLine."Trans. Line No." := POSTransLineCU.GetCurrentLineNo();
        case GCashProcessType of
            GCashProcessType::"Retail Pay":
                begin
                    GCashTransLine."Process Type" := GCashTransLine."Process Type"::"Retail Pay";
                    GCashTransLine."GCash Create Time" := GetResponseJsonByPathText('response.body.createTime');
                    GCashTransLine."GCash Amount Currency" := GetResponseJsonByPathText('response.body.orderAmount.currency');
                    GCashTransLine."GCash Amount" := GetResponseJsonByPathText('response.body.orderAmount.value');
                    IF EVALUATE(GCashTransLine.Amount, GCashTransLine."GCash Amount") THEN;
                    GCashTransLine."GCash Paid Time" := GetResponseJsonByPathText('response.body.paidTime');
                    GCashTransLine."GCash Transaction ID" := GetResponseJsonByPathText('response.body.transactionId');
                end;
            // GCashProcessType::"Query Transaction":
            //     begin
            //         GCashTransLine."Res. Cash In/Out ID" := GetResponseJsonByPathText('res_id');
            //         GCashTransLine."Res. Cash In/Out Code" := GetResponseJsonByPathText('res_code');
            //         GCashTransLine."Res. Cash In/Out Message" := GetResponseJsonByPathText('res_message');
            //         GCashTransLine."Res. Cash In Ref. No." := GetResponseJsonByPathText('res_cashin_ref');
            //         GCashTransLine."Res. Cash In/Out Mobile No." := GetResponseJsonByPathText('res_mobileno');
            //         IF EVALUATE(GCashTransLine."Res. Cash In/Out Amount", GetResponseJsonByPathText('res_amount')) THEN;
            //         GCashTransLine."Res. Cash In/Out Status" := GetResponseJsonByPathText('res_status');
            //         GCashTransLine."Res. Cash In/Out Date" := GetResponseJsonByPathText('res_date');
            // GCashTransLine."GCash Transaction ID" := GetResponseJsonByPathText('response.body.transactionId');
            //     end;
            GCashProcessType::"Cancel Transaction":
                begin
                    GCashTransLine."Process Type" := GCashTransLine."Process Type"::"Cancel Transaction";
                    GCashTransLine."GCash Cancel Time" := GetResponseJsonByPathText('response.body.cancelTime');
                end;
            GCashProcessType::"Refund Transaction":
                begin
                    GCashTransLine."Process Type" := GCashTransLine."Process Type"::"Refund Transaction";
                    GCashTransLine."GCash Amount Currency" := GetResponseJsonByPathText('response.body.refundAmount.currency');
                    GCashTransLine."GCash Amount" := GetResponseJsonByPathText('response.body.refundAmount.value');
                    IF EVALUATE(GCashTransLine.Amount, GCashTransLine."GCash Amount") THEN;
                    GCashTransLine."GCash Refund ID" := GetResponseJsonByPathText('response.body.refundId');
                    GCashTransLine."GCash Refund Time" := GetResponseJsonByPathText('response.body.refundTime');
                    GCashTransLine."GCash Request ID" := GetResponseJsonByPathText('response.body.requestId');
                    GCashTransLine."GCash Short Refund ID" := GetResponseJsonByPathText('response.body.shortRefundId');
                end;
        end;
        GCashTransLine."GCash Result CodeId" := GetResponseJsonByPathText('response.body.resultInfo.resultCodeId');
        GCashTransLine."GCash Result Msg" := GetResponseJsonByPathText('response.body.resultInfo.resultMsg');
        GCashTransLine."GCash Result Status" := GetResponseJsonByPathText('response.body.resultInfo.resultStatus');
        GCashTransLine."GCash Result Code" := GetResponseJsonByPathText('response.body.resultInfo.resultCode');
        GCashTransLine."GCash Response Time" := GetResponseJsonByPathText('response.head.respTime');
        GCashTransLine."GCash Acquirement ID" := GetResponseJsonByPathText('response.body.acquirementId');
        GCashTransLine."GCash Merchant Trans. ID" := GetResponseJsonByPathText('response.body.merchantTransId');
        GCashTransLine."GCash Response Signature" := GetResponseJsonByPathText('signature');
        GCashTransLine."GCash Request".CreateOutStream(OutStrGCashReq);
        OutStrGCashReq.Write(pRequest);
        GCashTransLine."GCash Response".CreateOutStream(OutStrGCashRes);
        OutStrGCashRes.Write(pResponse);
        GCashTransLine.Insert();
    end;

    procedure GetResponseJsonByPathText(pPath: Text): Text;
    var
        JTokenLocal: JsonToken;
        ResponseText: Text;
    begin

        CLEAR(ResponseText);
        JTokenLocal := LSCHttpWrapper.GetResponseJsonByPath(pPath);
        IF JTokenLocal.WriteTo(ResponseText) then BEGIN
            IF ResponseText.Contains('null') THEN
                ResponseText := ResponseText.Replace('null', '');
            IF ResponseText.Contains('"') THEN
                ResponseText := ResponseText.Replace('"', '');
        END ELSE
            ResponseText := '';
        EXIT(ResponseText);
    end;

    procedure GetGCashFunction(GCashFunc: Integer): Text;
    var
        GCashFunctionTypes: Enum "AVG Type Trans. Line";
        txtFunctionName: Text;
    begin
        CLEAR(txtFunctionName);
        GCashFunctionTypes := "AVG Type Trans. Line".FromInteger(GCashFunc);
        case GCashFunctionTypes of
            GCashFunctionTypes::"HeartBeat Check":
                txtFunctionName := 'gcash.common.heart.beat';
            GCashFunctionTypes::"Retail Pay":
                txtFunctionName := 'gcash.acquiring.retail.pay';
            GCashFunctionTypes::"Query Transaction":
                txtFunctionName := 'gcash.acquiring.order.query';
            GCashFunctionTypes::"Cancel Transaction":
                txtFunctionName := 'gcash.acquiring.order.cancel';
            GCashFunctionTypes::"Refund Transaction":
                txtFunctionName := 'gcash.acquiring.order.refund';
        end;
        EXIT(txtFunctionName);
    end;

    procedure GCashQueryGetResponseJsonByPathText(pPath: Text): Text;
    var
        JTokenLocal: JsonToken;
        ResponseText: Text;
    begin
        CLEAR(ResponseText);
        JTokenLocal := LSCHttpWrapperGCashQuery.GetResponseJsonByPath(pPath);
        IF JTokenLocal.WriteTo(ResponseText) then BEGIN
            IF ResponseText.Contains('null') THEN
                ResponseText := ResponseText.Replace('null', '');
            IF ResponseText.Contains('"') THEN
                ResponseText := ResponseText.Replace('"', '');
        END ELSE
            ResponseText := '';
        EXIT(ResponseText);
    end;

    procedure ClearHttpVars()
    begin
        LSCHttpWrapper.ClearClient();
        LSCHttpWrapper.ClearErrors();
        LSCHttpWrapper.ClearFlags();
        LSCHttpWrapper.ClearHeaders();
        LSCHttpWrapper.ClearVars();
    end;

    procedure ClearHttpVarsGCashQuery()
    begin
        LSCHttpWrapperGCashQuery.ClearClient();
        LSCHttpWrapperGCashQuery.ClearErrors();
        LSCHttpWrapperGCashQuery.ClearFlags();
        LSCHttpWrapperGCashQuery.ClearHeaders();
        LSCHttpWrapperGCashQuery.ClearVars();
    end;

}
