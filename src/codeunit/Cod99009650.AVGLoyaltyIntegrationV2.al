codeunit 99009650 "AVG Loyalty Integration V2"
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
        LSCPOSTransLineCU: Codeunit "LSC POS Trans. Lines";
        LSCPOSCtrlInterfaceCU: Codeunit "LSC POS Control Interface";
        LSCPOSGui: Codeunit "LSC POS GUI";
        LSCPOSSession: Codeunit "LSC POS Session";
        LSCAuthType: Enum "LSC Http AuthType";
        AVGPOSSession: Codeunit "AVG POS Session";
        AVGFunctions: Codeunit "AVG Functions";
        LOYV2BalanceInqText: Label 'Scan/Enter QR Code', Locked = true;


    trigger OnRun()
    begin

        LSCGlobalRec := Rec;
        LSCPOSTerminal.GET(LSCPOSSession.TerminalNo());
        LSCStore.GET(LSCPOSTerminal."Store No.");
        LSCFunctionalityProfile.GET(LSCPOSSession.FunctionalityProfileID());
        IF LSCPOSTransLineRec.GET(LSCGlobalRec."Current-RECEIPT", LSCGlobalRec."Current-LINE") THEN;
        AVGFunctions.SetGlobalLSCPOSMenuLine(LSCGlobalRec);
        CASE Rec.Command of
            'LOYV2BALANCE':
                LoyV2BalanceEx();
            'LOYV2ADDMEBER':
                LoyV2AddMemberEx();
            'LOYV2POINTS':
                LoyV2PointsEx(Rec.Parameter);
            'LOYV2CLEARMEMBERINFO':
                ClearMemberInfo(true);
            'LOYV2SHOWMEMBERINFO':
                ShowCurrentMemberDetails();
        END;
        Rec := LSCGlobalRec;
    end;

    local procedure LoyV2BalanceEx()
    begin
        if not InitializedLOYV2 then
            exit;
        LSCPOSGui.OpenAlphabeticKeyboard(LOYV2BalanceInqText, '', AVGPOSSession.GetHideKeybValues, '#LOYV2BALANCE', 2048);
        EXIT;
    end;

    local procedure LoyV2AddMemberEx()
    begin

    end;

    local procedure LoyV2PointsEx(TenderType: Code[20])
    var
        LSCTenderTypeLoc: Record "LSC Tender Type";
        TenderTypeErrMsg: Label 'Tender Type: %1 is not yet Activated.\Contact your System Administrator.', Locked = true;
        MemberCardErrMsg: Label 'Member must be Added.', Locked = true;
    begin

        if not LSCTenderTypeLoc.Get(LSCPOSTerminal."Store No.", TenderType) then
            exit;

        if not LSCTenderTypeLoc."Loyalty Redemption" then begin
            AVGPOSSession.AVGPOSErrorMessages(StrSubstNo(TenderTypeErrMsg, LSCTenderTypeLoc.Description));
            exit;
        end;

        if LSCPOSSession.GetValue('LOYV2CARDORIG') = '' then begin
            AVGPOSSession.AVGPOSErrorMessages(MemberCardErrMsg);
            exit;
        end;
        LSCPOSSession.SetValue('LOYV2TENDER', TenderType);
        LSCPOSTransactionCU.OpenNumericKeyboard('Amount to Redeem', 0, format(LSCPOSTransactionCU.GetOutstandingBalance()), 99009650);
        exit;
    end;

    local procedure InitializedLOYV2(): Boolean
    begin
        if not LSCPOSTerminal."Enable Loyalty V2" then
            exit(false);

        if LSCPOSTerminal."Loyalty V2 Url" = '' then
            exit(false);

        if LSCPOSTerminal."Loyalty V2 Setup Endpoint" = '' then
            exit(false);

        if LSCPOSTerminal."Loyalty V2 POS Setup Endpoint" = '' then
            exit(false);

        if LSCPOSTerminal."Loyalty V2 Member Data Endpt" = '' then
            exit(false);

        if LSCPOSTerminal."Loyalty V2 Cancel Trans. Endpt" = '' then
            exit(false);

        if not InitializedLOYV2Setup then
            exit(false);

        if not InitializedLOYV2POSSetup() then
            exit(false);
        exit(true);
    end;

    local procedure InitializedLOYV2Setup(): Boolean
    var
        LSCHttpWrapperSetup: Codeunit "LSC Http Wrapper";
        Result: Boolean;
        SuccessApi: Boolean;
    begin
        ClearHttpVars(LSCHttpWrapperSetup);
        LSCHttpWrapperSetup.AcceptType('application/json');
        LSCHttpWrapperSetup.ContentType('application/json');
        LSCHttpWrapperSetup.KeepAlive(true);
        LSCHttpWrapperSetup.Method('GET');
        LSCHttpWrapperSetup.Url(LSCPOSTerminal."Loyalty V2 Url" + LSCPOSTerminal."Loyalty V2 Setup Endpoint");
        Result := LSCHttpWrapperSetup.Send();
        if Result then begin
            if not evaluate(SuccessApi, GetResponseJsonByPathText('success', LSCHttpWrapperSetup)) then
                Result := false;
        end else
            Result := false;
        exit((Result and SuccessApi));
    end;

    local procedure InitializedLOYV2POSSetup(): Boolean
    var
        LSCHttpWrapperPOSSetupGet: Codeunit "LSC Http Wrapper";
        LSCHttpWrapperPOSSetupPost: Codeunit "LSC Http Wrapper";
        POSRegistered: Boolean;
        Result: Boolean;
    begin
        ClearHttpVars(LSCHttpWrapperPOSSetupGet);
        LSCHttpWrapperPOSSetupGet.AcceptType('application/json');
        LSCHttpWrapperPOSSetupGet.ContentType('application/json');
        LSCHttpWrapperPOSSetupGet.KeepAlive(true);
        LSCHttpWrapperPOSSetupGet.Method('GET');
        LSCHttpWrapperPOSSetupGet.Url(LSCPOSTerminal."Loyalty V2 Url" + LSCPOSTerminal."Loyalty V2 POS Setup Endpoint" + LSCPOSTerminal."Store No." + LSCPOSTerminal."No.");
        Result := LSCHttpWrapperPOSSetupGet.Send();
        if Result then begin
            if not evaluate(POSRegistered, GetResponseJsonByPathText('registered', LSCHttpWrapperPOSSetupGet)) then
                Result := false;

            if not POSRegistered then
                RegisterLOYV2(LSCHttpWrapperPOSSetupPost)
            else
                POSRegistered := true;
        end else
            Result := false;
        exit((Result and POSRegistered));
    end;

    local procedure RegisterLOYV2(LSCHttpWrapperPOSSetupPost: Codeunit "LSC Http Wrapper"): Boolean;
    var
        JObject: JsonObject;
        LSCRetailSetup: Record "LSC Retail Setup";
        Result: Boolean;
        SuccessApi: Boolean;
    begin
        ClearHttpVars(LSCHttpWrapperPOSSetupPost);
        if not LSCRetailSetup.Get() then
            exit;

        if AVGPOSSession.AVGCompanyCode() = '' then
            exit;

        JObject.Add('pos_code', LSCPOSTerminal."Store No." + LSCPOSTerminal."No.");
        JObject.Add('branch_code', LSCPOSTerminal."Store No.");
        JObject.Add('company_code', AVGPOSSession.AVGCompanyCode());
        JObject.Add('pos_name', LSCPOSTerminal."No.");
        JObject.Add('is_active', true);

        LSCHttpWrapperPOSSetupPost.AcceptType('application/json');
        LSCHttpWrapperPOSSetupPost.ContentType('application/json');
        LSCHttpWrapperPOSSetupPost.SetHeader('User-Agent', 'AVGLOYV2');
        LSCHttpWrapperPOSSetupPost.KeepAlive(true);
        LSCHttpWrapperPOSSetupPost.Method('POST');
        LSCHttpWrapperPOSSetupPost.Url(LSCPOSTerminal."Loyalty V2 Url" + LSCPOSTerminal."Loyalty V2 POS Setup Endpoint");
        LSCHttpWrapperPOSSetupPost.RequestJson(JObject);
        Result := LSCHttpWrapperPOSSetupPost.Send();
        if Result then begin
            if not evaluate(SuccessApi, GetResponseJsonByPathText('success', LSCHttpWrapperPOSSetupPost)) then
                Result := false;
        end else
            Result := false;
        exit((Result and SuccessApi))
    end;

    local procedure ClearHttpVars(var pLSCHttpWrapper: Codeunit "LSC Http Wrapper")
    begin
        pLSCHttpWrapper.ClearClient();
        pLSCHttpWrapper.ClearErrors();
        pLSCHttpWrapper.ClearFlags();
        pLSCHttpWrapper.ClearHeaders();
        pLSCHttpWrapper.ClearVars();
    end;

    local procedure GetResponseJsonByPathText(pPath: Text; pLSCHttpWrapper: Codeunit "LSC Http Wrapper"): Text;
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

    local procedure RemoveSpecialChars(var pText: Text)
    begin
        if pText.Contains('%?') then
            pText := pText.Replace('%?', '')
        else
            exit;
    end;

    local procedure LOYV2BalanceApi(pMemberDataCode: Text; pReturn: Boolean): Boolean;
    var
        LSCPOSTerminalRecLoc: Record "LSC POS Terminal";
        LSCHttpWrapperMemberDataGet: Codeunit "LSC Http Wrapper";
        Result: Boolean;
        SuccessApi: Boolean;
        MemberCardNoLast4: Text;
        MemberFullName: Text;
        MemberEmail: Text;
        MemberContact: Code[20];
        MemberBirthday: Date;
        MemberTier: Code[50];
        MemberPoints: Decimal;
        MemberValidEmail: Boolean;
        MemberTransCount: Integer;
        MemberAccessToken: Text;
        QRCodeValues: Array[10] of Text;
        QRCardNo: Text;
        QRFirstName: Text;
        QRLastName: Text;
        QRBirthday: Text;
        QREmail: Text;
        QRMobile: Text;
        Text001: Label 'Card No.: %1\Full Name: %2\Member Tier: %3\Balance: %4', Locked = true;
        Text002: Label 'Card No.: %1\Full Name: %2\Member Tier: %3\Balance: %4\Birthday: %5\Mobile No.: %6\Email: %7', Locked = true;
        InvalidEmailMsg: Label 'To enjoy the benefits of AllRewards, please update your customer details as soon as possible. This way, you will receive the latest news and offers from AllRewards.', Locked = true;
        TransCountMsg: Label 'You are required to update information to accumulate points for this transaction.', Locked = true;
        MemberAcceptConfirm: Label 'Do you want to Procceed by Adding this Member?', Locked = true;
        MemberAcceptedMsg: Label 'Member %1 has been Accepted.', Locked = true;
    begin
        IF not LSCPOSTerminalRecLoc.Get(LSCPOSSession.TerminalNo()) then
            exit(false);

        if pMemberDataCode = '' then
            exit(false);



        CLEAR(QRCodeValues);
        QRCodeSeparator(pMemberDataCode, '&', QRCodeValues);

        IF QRCodeValues[1] = '' THEN
            EXIT;

        CLEAR(QRCardNo);
        CLEAR(QRFirstName);
        CLEAR(QRLastName);
        CLEAR(QRBirthday);
        CLEAR(QREmail);
        CLEAR(QRMobile);

        QRCardNo := QRCodeValues[1];
        QRFirstName := QRCodeValues[2];
        QRLastName := QRCodeValues[3];
        QRBirthday := QRCodeValues[4];
        QREmail := QRCodeValues[5];
        QRMobile := QRCodeValues[6];

        CLEAR(MemberCardNoLast4);
        MemberCardNoLast4 := QRCardNo;
        GetLast4DigitsCardNo(MemberCardNoLast4);

        ClearHttpVars(LSCHttpWrapperMemberDataGet);
        LSCHttpWrapperMemberDataGet.AcceptType('application/json');
        LSCHttpWrapperMemberDataGet.ContentType('application/json');
        LSCHttpWrapperMemberDataGet.KeepAlive(true);
        LSCHttpWrapperMemberDataGet.Method('GET');
        LSCHttpWrapperMemberDataGet.Url(LSCPOSTerminalRecLoc."Loyalty V2 Url" + LSCPOSTerminalRecLoc."Loyalty V2 Member Data Endpt" + QRCardNo);
        Result := LSCHttpWrapperMemberDataGet.Send();
        if Result then begin
            if not Evaluate(SuccessApi, GetResponseJsonByPathText('success', LSCHttpWrapperMemberDataGet)) then
                Result := false;

            if SuccessApi then begin
                if GetResponseJsonByPathText('data.member', LSCHttpWrapperMemberDataGet) <> '' then begin
                    MemberFullName := GetResponseJsonByPathText('data.member.firstName', LSCHttpWrapperMemberDataGet) + ' ' + GetResponseJsonByPathText('data.member.lastName', LSCHttpWrapperMemberDataGet);
                    MemberEmail := GetResponseJsonByPathText('data.member.email', LSCHttpWrapperMemberDataGet);
                    MemberContact := GetResponseJsonByPathText('data.member.contactNumber', LSCHttpWrapperMemberDataGet);
                    if evaluate(MemberBirthday, GetResponseJsonByPathText('data.member.birthday', LSCHttpWrapperMemberDataGet)) then;
                    MemberTier := GetResponseJsonByPathText('data.member.tier', LSCHttpWrapperMemberDataGet);
                    if evaluate(MemberPoints, GetResponseJsonByPathText('data.member.currentPoints', LSCHttpWrapperMemberDataGet)) then;
                    if evaluate(MemberValidEmail, GetResponseJsonByPathText('data.member.validEmail', LSCHttpWrapperMemberDataGet)) then;
                    if evaluate(MemberTransCount, GetResponseJsonByPathText('data.member.transactionCount', LSCHttpWrapperMemberDataGet)) then;
                    MemberAccessToken := GetResponseJsonByPathText('data.accessToken', LSCHttpWrapperMemberDataGet);
                    if not pReturn then begin
                        IF NOT MemberValidEmail THEN BEGIN
                            AVGPOSSession.AVGPOSMessages(STRSUBSTNO(Text002, MemberCardNoLast4, MemberFullName, MemberTier, MemberPoints, MemberBirthday, MemberContact, MemberEmail));
                            AVGPOSSession.AVGPOSMessages(InvalidEmailMsg);
                            IF MemberTransCount >= 3 THEN
                                AVGPOSSession.AVGPOSMessages(TransCountMsg);
                        END ELSE
                            AVGPOSSession.AVGPOSMessages(STRSUBSTNO(Text001, MemberCardNoLast4, MemberFullName, MemberTier, LSCPOSFunctionsCU.FormatAmount(MemberPoints)));
                        if not LSCPOSTransactionCU.PosConfirm(MemberAcceptConfirm, false) then
                            exit(false);
                        AVGPOSSession.AVGPOSMessages(StrSubstNo(MemberAcceptedMsg, MemberFullName));
                        LSCPOSTransactionCU.SetFunctionMode('ITEM');
                    end;

                    LSCPOSSession.SetValue('LOYV2CARDORIG', QRCardNo);
                    LSCPOSSession.SetValue('LOYV2CARDLAST4', MemberCardNoLast4);
                    LSCPOSSession.SetValue('LOYV2FULLNAME', MemberFullName);
                    LSCPOSSession.SetValue('LOYV2EMAIL', MemberEmail);
                    LSCPOSSession.SetValue('LOYV2CONTACTNUMBER', MemberContact);
                    LSCPOSSession.SetValue('LOYV2BIRTHDAY', format(MemberBirthday, 0, '<Month,2>/<Day,2>/<Year4>'));
                    LSCPOSSession.SetValue('LOYV2TIER', MemberTier);
                    LSCPOSSession.SetValue('LOYV2CURRENTPOINTS', format(MemberPoints));
                    LSCPOSSession.SetValue('LOYV2VALIDEMAIL', format(MemberValidEmail));
                    LSCPOSSession.SetValue('LOYV2TRANSACTIONCOUNT', format(MemberTransCount));
                    LSCPOSSession.SetValue('LOYV2ACCESSTOKEN', MemberAccessToken);
                    exit(true);
                end else begin
                    if GetResponseJsonByPathText('message', LSCHttpWrapperMemberDataGet) <> '' then
                        AVGPOSSession.AVGPOSErrorMessages(GetResponseJsonByPathText('message', LSCHttpWrapperMemberDataGet));
                    exit(false);
                end;
            end else begin
                if GetResponseJsonByPathText('message', LSCHttpWrapperMemberDataGet) <> '' then
                    AVGPOSSession.AVGPOSErrorMessages(GetResponseJsonByPathText('message', LSCHttpWrapperMemberDataGet));
                exit(false);
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction", OnBeforeProcessKeyBoardResult, '', false, false)]
    local procedure OnBeforeProcessKeyBoardResult(Payload: Text; InputValue: Text; ResultOK: Boolean; var IsHandled: Boolean);
    begin
        CASE Payload of
            '#LOYV2BALANCE':
                begin
                    if ResultOK then begin
                        RemoveSpecialChars(InputValue);
                        LOYV2BalanceApi(InputValue, false);
                        IsHandled := true;
                    end;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction", OnAfterKeyboardTriggerToProcess, '', false, false)]
    local procedure OnAfterKeyboardTriggerToProcess(InputValue: Text; KeyboardTriggerToProcess: Integer; var Rec: Record "LSC POS Transaction"; var IsHandled: Boolean);
    var
        RedeemAmount: Decimal;
        CurrentPoints: Decimal;
        InvalidAmtMsg: Label 'Invalid Amount.', Locked = true;
        ExceededAmtMsg: Label 'Exceeded Amount.', Locked = true;
        InsufficientPtsMsg: Label 'Insufficient Points.', Locked = true;
    begin
        CASE KeyboardTriggerToProcess of
            99009650: // LoyV2 Points Redemption
                begin
                    if not Evaluate(RedeemAmount, InputValue) then begin
                        AVGPOSSession.AVGPOSErrorMessages(InvalidAmtMsg);
                        IsHandled := true;
                        exit;
                    end;

                    if not evaluate(CurrentPoints, LSCPOSSession.GetValue('LOYV2CURRENTPOINTS')) then begin
                        IsHandled := true;
                        exit;
                    end;

                    if RedeemAmount = 0 then begin
                        IsHandled := true;
                        exit;
                    end;

                    if RedeemAmount > LSCPOSTransactionCU.GetOutstandingBalance() then begin
                        AVGPOSSession.AVGPOSErrorMessages(ExceededAmtMsg);
                        IsHandled := true;
                        exit;
                    end;

                    IF (CurrentPoints < RedeemAmount) THEN BEGIN
                        AVGPOSSession.AVGPOSErrorMessages(InsufficientPtsMsg);
                        IsHandled := true;
                        exit;
                    END;
                    LSCPOSTransactionCU.SetCurrInput(InputValue);
                    LSCPOSSession.SetValue('LOYV2ISREDEEM', '1');
                    LSCPOSTransactionCU.TenderKeyPressed(LSCPOSSession.GetValue('LOYV2TENDER'));
                    IsHandled := true;
                end;
        END;
    end;

    local procedure GetLast4DigitsCardNo(var pCardNo: Text): Boolean
    var
        CardNo: Text;
        CardNoLength: Integer;
    begin

        CLEAR(CardNo);
        CLEAR(CardNoLength);
        CardNo := pCardNo;
        CardNoLength := STRLEN(CardNo);
        IF CardNoLength < 16 THEN
            exit(false);

        pCardNo := PADSTR('', CardNoLength - 4, 'X') + COPYSTR(CardNo, CardNoLength - 3, CardNoLength);
        exit(true);
    end;

    local procedure ShowCurrentMemberDetails()
    var
        MemberInfoHeaderMsg: Label '***MEMBER INFORMATION***', Locked = true;

    begin
        AVGPOSSession.AVGPOSMessages(MemberInfoHeaderMsg + '\\' +
            'Member Card No: ' + LSCPOSSession.GetValue('LOYV2CARDLAST4') + '\' +
            'Member Full Name: ' + LSCPOSSession.GetValue('LOYV2FULLNAME') + '\' +
            'Member Email Address: ' + LSCPOSSession.GetValue('LOYV2EMAIL') + '\' +
            'Member Contact Number: ' + LSCPOSSession.GetValue('LOYV2CONTACTNUMBER') + '\' +
            'Member Birthday: ' + LSCPOSSession.GetValue('LOYV2BIRTHDAY') + '\' +
            'Member Tier: ' + LSCPOSSession.GetValue('LOYV2TIER') + '\' +
            'Member Current Points: ' + LSCPOSSession.GetValue('LOYV2CURRENTPOINTS') + '\' +
            'Member Valid Email: ' + LSCPOSSession.GetValue('LOYV2VALIDEMAIL') + '\' +
            'Member Transaction Count: ' + LSCPOSSession.GetValue('LOYV2TRANSACTIONCOUNT')
        );
    end;

    local procedure ProcessLoyaltyV2Transaction(pLSCTransactionHeader: Record "LSC Transaction Header"; pLOYV2Entries: Record "AVG Loyalty V2 Entry"; pRedeem: Boolean): Boolean
    var
        TransID: Text;
        TransIdentifier: Text;
        TotalAmount: Decimal;
        EarnAmount: Decimal;
        RedeemAmount: Decimal;
        TransDate: Date;
        TransTime: Time;
        Result: Boolean;
        SuccessApi: Boolean;
        LSCHttpWrapperMemberDataPostTrans: Codeunit "LSC Http Wrapper";
        LSCHttpWrapperCancelPutTrans: Codeunit "LSC Http Wrapper";
        LSCPOSTerminalLocRec: Record "LSC POS Terminal";
        LSCTransSalesEntry: Record "LSC Trans. Sales Entry";
        LSCTransPaymentEntry: Record "LSC Trans. Payment Entry";
        LSCTenderType: Record "LSC Tender Type";
        LOYV2EntriesLoc: Record "AVG Loyalty V2 Entry";
        Item: Record Item;
        JObject: JsonObject;
        JObjectItemDetails: JsonObject;
    begin
        if not LSCPOSTerminalLocRec.get(LSCPOSSession.TerminalNo()) then
            exit(false);

        IF pLSCTransactionHeader.Date <> 0D then
            TransDate := pLSCTransactionHeader.Date
        ELSE
            TransDate := TODAY;
        IF pLSCTransactionHeader.Time <> 0T then
            TransTime := pLSCTransactionHeader.Time
        ELSE
            TransTime := Time;
        if not pLSCTransactionHeader."Sale Is Return Sale" then begin
            clear(TransID);
            clear(TotalAmount);
            clear(LSCTransSalesEntry);
            clear(JObjectItemDetails);
            LSCTransSalesEntry.SetRange("Store No.", pLSCTransactionHeader."Store No.");
            LSCTransSalesEntry.SetRange("POS Terminal No.", pLSCTransactionHeader."POS Terminal No.");
            LSCTransSalesEntry.SetRange("Transaction No.", pLSCTransactionHeader."Transaction No.");
            if LSCTransSalesEntry.FindSet() then
                repeat
                    if Item.GET(LSCTransSalesEntry."Item No.") then
                        JObjectItemDetails.Add(FORMAT(LSCTransSalesEntry."Line No.") + '_' + Item."No." + '_' + Item.Description, -LSCTransSalesEntry."Net Amount" + -LSCTransSalesEntry."VAT Amount");
                until LSCTransSalesEntry.NEXT = 0;

            clear(RedeemAmount);
            clear(EarnAmount);
            LSCTransPaymentEntry.SetRange("Store No.", pLSCTransactionHeader."Store No.");
            LSCTransPaymentEntry.SetRange("POS Terminal No.", pLSCTransactionHeader."POS Terminal No.");
            LSCTransPaymentEntry.SetRange("Transaction No.", pLSCTransactionHeader."Transaction No.");
            if LSCTransPaymentEntry.FindSet() then
                repeat
                    if LSCTenderType.GET(LSCTransPaymentEntry."Store No.", LSCTransPaymentEntry."Tender Type") then begin
                        if LSCTenderType."Loyalty Redemption" then
                            RedeemAmount += LSCTransPaymentEntry."Amount Tendered"
                        else
                            EarnAmount += LSCTransPaymentEntry."Amount Tendered";
                    END;
                until LSCTransPaymentEntry.NEXT = 0;

            CLEAR(TransIdentifier);
            CLEAR(JObject);

            if pRedeem then begin
                TotalAmount := RedeemAmount;
                TransIdentifier := 'R';
            end else begin
                TotalAmount := EarnAmount;
                TransIdentifier := 'E';
            end;

            if TotalAmount = 0 then
                exit;

            TransID := pLSCTransactionHeader."Store No." + '_' +
                pLSCTransactionHeader."POS Terminal No." + '_' +
                format(pLSCTransactionHeader."Transaction No.") + '_' +
                pLSCTransactionHeader."Official Receipt No." + '_' +
                TransIdentifier;

            JObject.Add('transaction_id', TransID);
            JObject.Add('pos_code', pLSCTransactionHeader."Store No." + pLSCTransactionHeader."POS Terminal No.");
            JObject.Add('details', JObjectItemDetails);
            JObject.Add('total_amount', TotalAmount);
            JObject.Add('transaction_date', FORMAT(TransDate, 0, '<Month,2>/<Day,2>/<Year4>'));
            JObject.Add('transaction_time', FORMAT(TransTime, 0, '<Hours24,2><Filler Character,0>:<Minutes,2>'));
            IF pRedeem THEN BEGIN
                JObject.Add('is_redeem', pRedeem);
                JObject.Add('redeem_amount', RedeemAmount);
            END;

            LSCHttpWrapperMemberDataPostTrans.AcceptType('application/json');
            LSCHttpWrapperMemberDataPostTrans.ContentType('application/json');
            LSCHttpWrapperMemberDataPostTrans.SetHeader('Authorization', StrSubstNo('Bearer %1', LSCPOSSession.GetValue('LOYV2ACCESSTOKEN')));
            LSCHttpWrapperMemberDataPostTrans.KeepAlive(true);
            LSCHttpWrapperMemberDataPostTrans.Method('POST');
            LSCHttpWrapperMemberDataPostTrans.Url(LSCPOSTerminalLocRec."Loyalty V2 Url");
            LSCHttpWrapperMemberDataPostTrans.RequestJson(JObject);
            Result := LSCHttpWrapperMemberDataPostTrans.Send();
            if Result then begin
                if not evaluate(SuccessApi, GetResponseJsonByPathText('success', LSCHttpWrapperMemberDataPostTrans)) then
                    Result := false;
                InsertIntoLoyaltyEntries(pLSCTransactionHeader, LOYV2EntriesLoc, LSCHttpWrapperMemberDataPostTrans, TransDate, TransTime, SuccessApi);
            end else
                Result := false;
        end else begin
            LSCHttpWrapperCancelPutTrans.AcceptType('application/json');
            LSCHttpWrapperCancelPutTrans.ContentType('application/json');
            LSCHttpWrapperCancelPutTrans.SetHeader('Authorization', StrSubstNo('Bearer %1', LSCPOSSession.GetValue('LOYV2REFUNDACCTOKEN')));
            LSCHttpWrapperCancelPutTrans.KeepAlive(true);
            LSCHttpWrapperCancelPutTrans.Method('PUT');
            LSCHttpWrapperCancelPutTrans.Url(LSCPOSTerminalLocRec."Loyalty V2 Url" + LSCPOSTerminalLocRec."Loyalty V2 Cancel Trans. Endpt" + pLOYV2Entries."Res. Trans. ID");
            Result := LSCHttpWrapperCancelPutTrans.Send();
            if Result then begin
                if not evaluate(SuccessApi, GetResponseJsonByPathText('success', LSCHttpWrapperCancelPutTrans)) then
                    Result := false;
                InsertIntoLoyaltyEntries(pLSCTransactionHeader, pLOYV2Entries, LSCHttpWrapperCancelPutTrans, TransDate, TransTime, SuccessApi);
            end else
                Result := false;
        end;
        exit((Result and SuccessApi));
    end;

    local procedure InsertIntoLoyaltyEntries(pTransactionHeader: Record "LSC Transaction Header"; pLOYV2Entries: Record "AVG Loyalty V2 Entry"; pLSCHttpWrapperMemberDataPostTrans: Codeunit "LSC Http Wrapper"; pTransDate: Date; pTransTime: Time; pProcessed: Boolean)
    var
        LOYV2Entries, LOYV2Entries2 : Record "AVG Loyalty V2 Entry";
        LineNo: Integer;
    begin

        LineNo := 0;
        LOYV2Entries2.Reset();
        LOYV2Entries2.SetCurrentKey("Store No.", "POS Terminal No.", "Transaction No.", "Line No.");
        LOYV2Entries2.SetRange("Store No.", pTransactionHeader."Store No.");
        LOYV2Entries2.SetRange("POS Terminal No.", pTransactionHeader."POS Terminal No.");
        LOYV2Entries2.SetRange("Transaction No.", pTransactionHeader."Transaction No.");
        if LOYV2Entries2.FindLast() then
            LineNo := LOYV2Entries2."Line No." + 10000
        else
            LineNo := 10000;

        LOYV2Entries.INIT;
        LOYV2Entries."Store No." := pTransactionHeader."Store No.";
        LOYV2Entries."POS Terminal No." := pTransactionHeader."POS Terminal No.";
        LOYV2Entries."Transaction No." := pTransactionHeader."Transaction No.";
        LOYV2Entries."Line No." := LineNo;
        LOYV2Entries."Receipt No." := pTransactionHeader."Receipt No.";
        LOYV2Entries.Processed := pProcessed;
        IF NOT pTransactionHeader."Sale Is Return Sale" THEN BEGIN
            LOYV2Entries."Member Full Name" := LSCPOSSession.GetValue('LOYV2FULLNAME');
            IF EVALUATE(LOYV2Entries."Member Current Points", LSCPOSSession.GetValue('LOYV2CURRENTPOINTS')) THEN;
            LOYV2Entries."Member Email" := LSCPOSSession.GetValue('LOYV2EMAIL');
            IF EVALUATE(LOYV2Entries."Res. Valid Email", LSCPOSSession.GetValue('LOYV2VALIDEMAIL')) THEN;
            LOYV2Entries."Member Mobile No." := LSCPOSSession.GetValue('LOYV2CONTACTNUMBER');
            IF EVALUATE(LOYV2Entries."Member Birthday", LSCPOSSession.GetValue('LOYV2BIRTHDAY')) THEN;
            LOYV2Entries."Member Tier" := LSCPOSSession.GetValue('LOYV2TIER');
            LOYV2Entries."Card Number" := LSCPOSSession.GetValue('LOYV2CARDORIG');
            LOYV2Entries."Card Number Last 4" := LSCPOSSession.GetValue('LOYV2CARDLAST4');
            IF EVALUATE(LOYV2Entries."Res. Transaction Count", LSCPOSSession.GetValue('LOYV2TRANSACTIONCOUNT')) THEN;
            IF EVALUATE(LOYV2Entries."Res. ID", GetResponseJsonByPathText('data.pointsTransaction.id', pLSCHttpWrapperMemberDataPostTrans)) THEN;
            LOYV2Entries."Res. Trans. ID" := COPYSTR(GetResponseJsonByPathText('data.pointsTransaction.transaction_id', pLSCHttpWrapperMemberDataPostTrans), 1, 100);
            LOYV2Entries."Res. Member ID" := GetResponseJsonByPathText('data.pointsTransaction.member_id', pLSCHttpWrapperMemberDataPostTrans);
            LOYV2Entries."Res. Action" := GetResponseJsonByPathText('data.pointsTransaction.action', pLSCHttpWrapperMemberDataPostTrans);
            IF EVALUATE(LOYV2Entries."Res. Points", GetResponseJsonByPathText('data.pointsTransaction.points', pLSCHttpWrapperMemberDataPostTrans)) THEN;
            LOYV2Entries."Res. Unit ID" := GetResponseJsonByPathText('data.pointsTransaction.unit_id', pLSCHttpWrapperMemberDataPostTrans);
            LOYV2Entries."Res. Tier ID" := GetResponseJsonByPathText('data.pointsTransaction.tier_id', pLSCHttpWrapperMemberDataPostTrans);
            LOYV2Entries."Res. Promo Code" := GetResponseJsonByPathText('data.pointsTransaction.promo_code', pLSCHttpWrapperMemberDataPostTrans);
            LOYV2Entries."Res. Status" := GetResponseJsonByPathText('data.pointsTransaction.status', pLSCHttpWrapperMemberDataPostTrans);
            LOYV2Entries."Res. Time Stamp" := GetResponseJsonByPathText('data.pointsTransaction.timestamp', pLSCHttpWrapperMemberDataPostTrans);
            IF EVALUATE(LOYV2Entries."Res. New Tier", GetResponseJsonByPathText('data.newTier', pLSCHttpWrapperMemberDataPostTrans)) THEN;
            LOYV2Entries."Trans. Date" := pTransDate;
            LOYV2Entries."Trans. Time" := pTransTime;
        END ELSE BEGIN
            LOYV2Entries."Member Full Name" := pLOYV2Entries."Member Full Name";
            LOYV2Entries."Member Current Points" := pLOYV2Entries."Member Current Points";
            LOYV2Entries."Member Email" := pLOYV2Entries."Member Email";
            LOYV2Entries."Res. Valid Email" := pLOYV2Entries."Res. Valid Email";
            LOYV2Entries."Member Mobile No." := pLOYV2Entries."Member Mobile No.";
            LOYV2Entries."Member Birthday" := pLOYV2Entries."Member Birthday";
            LOYV2Entries."Member Tier" := pLOYV2Entries."Member Tier";
            LOYV2Entries."Card Number" := pLOYV2Entries."Card Number";
            LOYV2Entries."Card Number Last 4" := pLOYV2Entries."Card Number Last 4";
            LOYV2Entries."Orig. Store No." := pLOYV2Entries."Store No.";
            LOYV2Entries."Orig. POS Terminal No." := pLOYV2Entries."POS Terminal No.";
            LOYV2Entries."Orig. Transaction No." := pLOYV2Entries."Transaction No.";
            LOYV2Entries."Orig. Receipt No." := pLOYV2Entries."Receipt No.";
            LOYV2Entries."Orig. Res. Trans. ID" := COPYSTR(GetResponseJsonByPathText('data.origTransID', pLSCHttpWrapperMemberDataPostTrans), 1, 100);
            LOYV2Entries."Res. Cancel Trans. ID" := GetResponseJsonByPathText('data.referenceId', pLSCHttpWrapperMemberDataPostTrans);
            LOYV2Entries."Res. Message" := GetResponseJsonByPathText('message', pLSCHttpWrapperMemberDataPostTrans);
            LOYV2Entries."Trans. Date" := pTransDate;
            LOYV2Entries."Trans. Time" := pTransTime;
        END;
        IF LOYV2Entries.INSERT THEN;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Post Utility", OnAfterPostTransaction, '', false, false)]
    local procedure OnAfterPostTransaction(var TransactionHeader_p: Record "LSC Transaction Header");
    var
        IsRedeem: Boolean;
        LSCTransactionHeaderLoc: Record "LSC Transaction Header";
        LOYV2Entries: Record "AVG Loyalty V2 Entry";
    begin
        if not TransactionHeader_p."Sale Is Return Sale" then begin
            ProcessLoyaltyV2Transaction(TransactionHeader_p, LOYV2Entries, false);
            IsRedeem := LSCPOSSession.GetValue('LOYV2ISREDEEM') = '1';
            if IsRedeem then
                ProcessLoyaltyV2Transaction(TransactionHeader_p, LOYV2Entries, IsRedeem);
        end else begin
            LSCTransactionHeaderLoc.Reset();
            LSCTransactionHeaderLoc.setrange("Receipt No.", TransactionHeader_p."Retrieved from Receipt No.");
            if LSCTransactionHeaderLoc.FindFirst() then begin
                LOYV2Entries.Reset();
                LOYV2Entries.setrange("Store No.", LSCTransactionHeaderLoc."Store No.");
                LOYV2Entries.setrange("POS Terminal No.", LSCTransactionHeaderLoc."POS Terminal No.");
                LOYV2Entries.setrange("Transaction No.", LSCTransactionHeaderLoc."Transaction No.");
                if not LOYV2Entries.FindFirst() then
                    exit;

                repeat
                    LSCPOSSession.DeleteValue('LOYV2REFUNDACCTOKEN');
                    LOYV2BalanceApi(LOYV2Entries."Card Number", true);
                    LSCPOSSession.SetValue('LOYV2REFUNDACCTOKEN', LSCPOSSession.GetValue('LOYV2ACCESSTOKEN'));
                    if LSCPOSSession.GetValue('LOYV2REFUNDACCTOKEN') <> '' then
                        ProcessLoyaltyV2Transaction(TransactionHeader_p, LOYV2Entries, false);
                until LOYV2Entries.Next() = 0;
            end;
        end;
        ClearMemberInfo(false);

    end;

    local procedure ClearMemberInfo(Confirm: Boolean)
    var
        MemberRemovedMsg: Label 'Member Information for %1 has been Removed.', Locked = true;
        MemberRemoveConfirm: Label 'Are you sure you want to remove Member Informations?', Locked = true;
    begin
        IF Confirm then begin
            if not LSCPOSTransactionCU.PosConfirm(MemberRemoveConfirm, false) then
                exit;
            AVGPOSSession.AVGPOSMessages(StrSubstNo(MemberRemovedMsg, LSCPOSSession.GetValue('LOYV2FULLNAME')));
        end;
        LSCPOSSession.DeleteValue('LOYV2CARDORIG');
        LSCPOSSession.DeleteValue('LOYV2CARDLAST4');
        LSCPOSSession.DeleteValue('LOYV2FULLNAME');
        LSCPOSSession.DeleteValue('LOYV2EMAIL');
        LSCPOSSession.DeleteValue('LOYV2CONTACTNUMBER');
        LSCPOSSession.DeleteValue('LOYV2BIRTHDAY');
        LSCPOSSession.DeleteValue('LOYV2TIER');
        LSCPOSSession.DeleteValue('LOYV2CURRENTPOINTS');
        LSCPOSSession.DeleteValue('LOYV2VALIDEMAIL');
        LSCPOSSession.DeleteValue('LOYV2TRANSACTIONCOUNT');
        LSCPOSSession.DeleteValue('LOYV2ACCESSTOKEN');
        LSCPOSSession.DeleteValue('LOYV2ISREDEEM');
        LSCPOSSession.DeleteValue('LOYV2REFUNDACCTOKEN');
        LSCPOSSession.DeleteValue('REFAUTOPOST')
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::POSPrintUtilityExtnd, PHPOS_OnBeforePrintFooter, '', false, false)]
    local procedure PHPOS_OnBeforePrintFooter(var Sender: Codeunit POSPrintUtilityExtnd; var MainSender: Codeunit "LSC POS Print Utility"; var Transaction: Record "LSC Transaction Header"; var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer; var DSTR1: Text[100]; var IsHandled: Boolean);
    begin
        PrintLOYV2Details(Sender, MainSender, Transaction, PrintBuffer, PrintBufferIndex, LinesPrinted, DSTR1, IsHandled);
    end;

    local procedure PrintLOYV2Details(var Sender: Codeunit POSPrintUtilityExtnd; var MainSender: Codeunit "LSC POS Print Utility"; var Transaction: Record "LSC Transaction Header"; var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer; DSTR1: Text[100]; var IsHandled: Boolean)
    var
        txtLValue: array[10] of Text;
        EarnedPoints, RedeemPoints, TotalPointsBalance : Decimal;
        LOYV2Entries: Record "AVG Loyalty V2 Entry";
    begin
        LOYV2Entries.Reset();
        LOYV2Entries.SETCURRENTKEY("Store No.", "POS Terminal No.", "Transaction No.");
        LOYV2Entries.SETRANGE("Store No.", Transaction."Store No.");
        LOYV2Entries.SETRANGE("POS Terminal No.", Transaction."POS Terminal No.");
        LOYV2Entries.SETRANGE("Transaction No.", Transaction."Transaction No.");
        IF NOT LOYV2Entries.FINDFIRST THEN
            EXIT;

        CLEAR(EarnedPoints);
        CLEAR(RedeemPoints);
        CLEAR(TotalPointsBalance);
        REPEAT
            CASE LOYV2Entries."Res. Action" OF
                'EARN':
                    EarnedPoints += LOYV2Entries."Res. Points";
                'REDEEM':
                    RedeemPoints += LOYV2Entries."Res. Points";
            END;
        UNTIL LOYV2Entries.NEXT = 0;
        TotalPointsBalance := (LOYV2Entries."Member Current Points" + EarnedPoints) - RedeemPoints;
        DSTR1 := '#L##############   #R##################';
        txtLValue[1] := 'Membership Card:';
        txtLValue[2] := LOYV2Entries."Card Number Last 4";
        MainSender.PrintLine(2, MainSender.FormatLine(MainSender.FormatStr(txtLValue, DSTR1), FALSE, FALSE, FALSE, FALSE));

        txtLValue[1] := 'Member Name:';
        txtLValue[2] := LOYV2Entries."Member Full Name";
        MainSender.PrintLine(2, MainSender.FormatLine(MainSender.FormatStr(txtLValue, DSTR1), FALSE, FALSE, FALSE, FALSE));

        txtLValue[1] := 'Points Earned:';
        txtLValue[2] := LSCPOSFunctionsCU.FormatAmount(EarnedPoints);
        MainSender.PrintLine(2, MainSender.FormatLine(MainSender.FormatStr(txtLValue, DSTR1), FALSE, FALSE, FALSE, FALSE));

        txtLValue[1] := 'Points Redeemed:';
        txtLValue[2] := LSCPOSFunctionsCU.FormatAmount(RedeemPoints);
        MainSender.PrintLine(2, MainSender.FormatLine(MainSender.FormatStr(txtLValue, DSTR1), FALSE, FALSE, FALSE, FALSE));

        txtLValue[1] := 'Points Balance:';
        txtLValue[2] := LSCPOSFunctionsCU.FormatAmount(TotalPointsBalance);
        MainSender.PrintLine(2, MainSender.FormatLine(MainSender.FormatStr(txtLValue, DSTR1), FALSE, FALSE, FALSE, FALSE));
        MainSender.PrintSeperator(2);
    end;

    local procedure QRCodeSeparator(pString: Text; pSeparator: Text; var pQRCodeValue: Array[10] of Text)
    var
        Parameter, ParamStr : Text;
        SepPosition, Ctr : Integer;
    begin

        Ctr := 0;
        ParamStr := pString;
        REPEAT
            Ctr += 1;
            SepPosition := STRPOS(ParamStr, pSeparator);
            IF SepPosition > 0 THEN
                Parameter := COPYSTR(ParamStr, 1, SepPosition - 1)
            ELSE
                Parameter := ParamStr;
            ParamStr := COPYSTR(ParamStr, SepPosition + 1);
            pQRCodeValue[Ctr] := Parameter;
        UNTIL SepPosition = 0;
    end;


}
