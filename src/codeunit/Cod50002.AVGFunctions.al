codeunit 50002 "AVG Functions"
{
    SingleInstance = true;

    var
        IncExp: Record "LSC Income/Expense Account";
        TenderType: Record "LSC Tender Type";
        POSSession: Codeunit "LSC POS Session";
        POSTransactionCU: Codeunit "LSC POS Transaction";
        POSTransLineCU: Codeunit "LSC POS Trans. Lines";
        AVGPOSSession: Codeunit "AVG POS Session";
        AVGPOSFunctions: Codeunit "AVG POS Functions";
        AVGHttpFunctions: Codeunit "AVG Http Functions";
        ConnectingToServerMsg: Label 'Connecting to AllEasy Server...';

    procedure InitializeAllEasy(pIntAllEasyAPITrigger: Integer; pRecPOSTerminal: Record "LSC POS Terminal"): Boolean;
    var
        bolOK: Boolean;
        txtLURL: Text;
        txtLEndpoint: Text;
        txtLClientID: Text;
        txtLClientSecret: Text;
        txtLHeader1: Text;
        txtLHeader2: text;
        bolPayQR: Boolean;
        txtLAuthorizeToken: Text;
        AllEasyTransType: Enum "AVG Type Trans. Line";
    begin
        bolOK := FALSE;
        AllEasyTransType := "AVG Type Trans. Line".FromInteger(pIntAllEasyAPITrigger);
        CASE AllEasyTransType of
            AllEasyTransType::"Cash In Inquire",
            AllEasyTransType::"Cash In Credit":
                begin
                    bolOK :=
                        (pRecPOSTerminal."AE Enable Cash In") AND
                        (pRecPOSTerminal."AE Cash In URL" <> '') AND
                        (pRecPOSTerminal."AE Cash In Client ID" <> '') AND
                        (pRecPOSTerminal."AE Cash In Client Secret" <> '') AND
                        (pRecPOSTerminal."AE Cash In Inc. Acc." <> '') AND
                        (pRecPOSTerminal."AE Cash In Auth. Endpoint" <> '') AND
                        (pRecPOSTerminal."AE Cash In Endpoint Credit" <> '') AND
                        (pRecPOSTerminal."AE Cash In Endpoint Inquire" <> '') AND
                        (IncExp.GET(pRecPOSTerminal."Store No.", pRecPOSTerminal."AE Cash In Inc. Acc."));
                    IF bolOK then BEGIN
                        txtLURL := pRecPOSTerminal."AE Cash In URL";
                        txtLEndpoint := pRecPOSTerminal."AE Cash In Auth. Endpoint";
                        txtLClientID := pRecPOSTerminal."AE Cash In Client ID";
                        txtLClientSecret := pRecPOSTerminal."AE Cash In Client Secret";
                        bolPayQR := FALSE;
                        txtLHeader1 := '';
                        txtLHeader2 := '';
                    END;
                end;
            AllEasyTransType::"Cash Out Inquire",
            AllEasyTransType::"Cash Out Process":
                begin
                    bolOK :=
                        (pRecPOSTerminal."AE Enable Cash Out") AND
                        (pRecPOSTerminal."AE Cash Out URL" <> '') AND
                        (pRecPOSTerminal."AE Cash Out Client ID" <> '') AND
                        (pRecPOSTerminal."AE Cash Out Client Secret" <> '') AND
                        (pRecPOSTerminal."AE Cash Out Exp. Acc." <> '') AND
                        (pRecPOSTerminal."AE Cash Out Auth. Endpoint" <> '') AND
                        (pRecPOSTerminal."AE Cash Out Endpoint Process" <> '') AND
                        (pRecPOSTerminal."AE Cash Out Endpoint Inquire" <> '') AND
                        (IncExp.GET(pRecPOSTerminal."Store No.", pRecPOSTerminal."AE Cash Out Exp. Acc."));
                    IF bolOK then BEGIN
                        txtLURL := pRecPOSTerminal."AE Cash Out URL";
                        txtLEndpoint := pRecPOSTerminal."AE Cash Out Auth. Endpoint";
                        txtLClientID := pRecPOSTerminal."AE Cash Out Client ID";
                        txtLClientSecret := pRecPOSTerminal."AE Cash Out Client Secret";
                        bolPayQR := FALSE;
                        txtLHeader1 := '';
                        txtLHeader2 := '';
                    END;
                end;
            AllEasyTransType::"Pay QR Inquire",
            AllEasyTransType::"Pay QR Process":
                begin
                    bolOK :=
                        (pRecPOSTerminal."AE Enable Pay QR") AND
                        (pRecPOSTerminal."AE Pay QR URL" <> '') AND
                        (pRecPOSTerminal."AE Pay QR Client ID" <> '') AND
                        (pRecPOSTerminal."AE Pay QR Client Secret" <> '') AND
                        (pRecPOSTerminal."AE Pay QR Tender Type" <> '') AND
                        (pRecPOSTerminal."AE Pay QR Auth. Endpoint" <> '') AND
                        (pRecPOSTerminal."AE Pay QR Endpoint Process" <> '') AND
                        (pRecPOSTerminal."AE Pay QR Endpoint Inquire" <> '') AND
                        (pRecPOSTerminal."AE Pay QR Header1" <> '') AND
                        (pRecPOSTerminal."AE Pay QR Header2" <> '') AND
                        (TenderType.GET(pRecPOSTerminal."Store No.", pRecPOSTerminal."AE Pay QR Tender Type"));
                    IF bolOK then BEGIN
                        txtLURL := pRecPOSTerminal."AE Pay QR URL";
                        txtLEndpoint := pRecPOSTerminal."AE Pay QR Auth. Endpoint";
                        txtLClientID := pRecPOSTerminal."AE Pay QR Client ID";
                        txtLClientSecret := pRecPOSTerminal."AE Pay QR Client Secret";
                        bolPayQR := TRUE;
                        txtLHeader1 := pRecPOSTerminal."AE Pay QR Header1";
                        txtLHeader2 := pRecPOSTerminal."AE Pay QR Header2";
                    END;
                end;
        END;

        if bolOK then BEGIN
            CLEAR(txtLAuthorizeToken);
            POSTransactionCU.ScreenDisplay(ConnectingToServerMsg);
            txtLAuthorizeToken := AVGHttpFunctions.ProcessAuthToken(txtLURL, txtLEndpoint, txtLClientID, txtLClientSecret, bolPayQR, txtLHeader1, txtLHeader2);
            AVGPOSSession.ClearCurrAuthToken();
            AVGPOSSession.SetCurrAuthToken(txtLAuthorizeToken);
            bolOK := txtLAuthorizeToken <> '';
            POSTransactionCU.ScreenDisplay('');
        END;
        EXIT(bolOK);
    END;

    procedure ValidateAllEasy(pIntAllEasyAPITrigger: Integer; pDecAmount: Decimal; pTxtAmount: Text; pTxtCORefNo: Text; pTxtMobileNo: text): Boolean;
    var
        txtLRefNo: Text;
        LSCIncExpLocal: Record "LSC Income/Expense Account";
        LSCTenderTypeLocal: Record "LSC Tender Type";
        POSTermLocal: Record "LSC POS Terminal";
        AllEasyAPITrigger: Enum "AVG Type Trans. Line";
        recLAllEasyTransLine: Record "AVG Trans. Line";
        decLAmount: Decimal;
        QRCodeAlreadyExistErrMsg: Label 'QR Code already Exists in POS: %1.\\Transaction will not Proceed.';
        IncExpAccountErrMsg: Label '%1 must not be Zero.\\Contact your System Administrator.';
        AllowedTenderTypeErrMsg: Label '%1 must no be Blank.\\Contact your System Administrator.';
        AmountToAcceptErrMsg: Label '%1 is: %2.\\Transaction will not Proceed.';
        PayQRInvalidAmountErrMsg: Label 'Invalid Amount.\Input must be Numbers.\\Please Try Again.';
        PayQRAmountErrMsg: Label 'Exceeded Amount not Allowed.\\Transaction will not Proceed.';
    begin
        POSTermLocal.GET(POSSession.TerminalNo());
        AllEasyAPITrigger := "AVG Type Trans. Line".FromInteger(pIntAllEasyAPITrigger);
        CASE AllEasyAPITrigger OF
            AllEasyAPITrigger::"Cash In Inquire":
                begin
                    POSTermLocal.GET(POSSession.TerminalNo());
                    LSCIncExpLocal.GET(POSTermLocal."Store No.", POSTermLocal."AE Cash In Inc. Acc.");
                    IF LSCIncExpLocal."AE Minimum Amount to Accept" = 0 THEN BEGIN
                        AVGPOSFunctions.AVGPOSErrorMessage(STRSUBSTNO(IncExpAccountErrMsg, LSCIncExpLocal.FIELDCAPTION("AE Minimum Amount to Accept")));
                        EXIT(FALSE);
                    END;

                    IF LSCIncExpLocal."AE Maximum Amount to Accept" = 0 THEN BEGIN
                        AVGPOSFunctions.AVGPOSErrorMessage(STRSUBSTNO(IncExpAccountErrMsg, LSCIncExpLocal.FIELDCAPTION("AE Maximum Amount to Accept")));
                        EXIT(FALSE);
                    END;

                    IF LSCIncExpLocal."AE Allowed Tender Type" = '' THEN BEGIN
                        AVGPOSFunctions.AVGPOSErrorMessage(STRSUBSTNO(AllowedTenderTypeErrMsg, LSCIncExpLocal.FIELDCAPTION("AE Allowed Tender Type")));
                        EXIT(FALSE);
                    END;

                    IF (pDecAmount < LSCIncExpLocal."AE Minimum Amount to Accept") THEN begin
                        AVGPOSFunctions.AVGPOSErrorMessage(StrSubstNo(AmountToAcceptErrMsg, LSCIncExpLocal.FIELDCAPTION("AE Minimum Amount To Accept"), FORMAT(LSCIncExpLocal."AE Minimum Amount To Accept")));
                        EXIT(FALSE);
                    end;
                    IF (pDecAmount > LSCIncExpLocal."AE Maximum Amount to Accept") THEN BEGIN
                        AVGPOSFunctions.AVGPOSErrorMessage(StrSubstNo(AmountToAcceptErrMsg, LSCIncExpLocal.FIELDCAPTION("AE Maximum Amount To Accept"), FORMAT(LSCIncExpLocal."AE Maximum Amount To Accept")));
                        EXIT(FALSE);
                    end;
                end;
            AllEasyAPITrigger::"Cash Out Inquire":
                begin
                    LSCIncExpLocal.GET(POSTermLocal."Store No.", POSTermLocal."AE Cash Out Exp. Acc.");
                    IF LSCIncExpLocal."AE Minimum Amount to Accept" = 0 THEN BEGIN
                        AVGPOSFunctions.AVGPOSErrorMessage(STRSUBSTNO(IncExpAccountErrMsg, LSCIncExpLocal.FIELDCAPTION("AE Minimum Amount to Accept")));
                        EXIT(FALSE);
                    END;

                    IF LSCIncExpLocal."AE Maximum Amount to Accept" = 0 THEN BEGIN
                        AVGPOSFunctions.AVGPOSErrorMessage(STRSUBSTNO(IncExpAccountErrMsg, LSCIncExpLocal.FIELDCAPTION("AE Maximum Amount to Accept")));
                        EXIT(FALSE);
                    END;
                end;
            AllEasyAPITrigger::"Pay QR Inquire":
                begin
                    LSCTenderTypeLocal.Get(POSTermLocal."Store No.", POSTermLocal."AE Pay QR Tender Type");
                    IF NOT Evaluate(decLAmount, AVGPOSSession.GetCurrPayQRAmount()) THEN begin
                        AVGPOSFunctions.AVGPOSErrorMessage(PayQRInvalidAmountErrMsg);
                        EXIT(FALSE);
                    end;

                    recLAllEasyTransLine.RESET;
                    recLAllEasyTransLine.SETRANGE("Store No.", POSSession.StoreNo());
                    recLAllEasyTransLine.SETRANGE("Process Type", recLAllEasyTransLine."Process Type"::"Pay QR Inquire");
                    recLAllEasyTransLine.SETRANGE("Res. PayQR Code", AVGPOSSession.GetCurrPayQRCode());
                    IF recLAllEasyTransLine.FINDFIRST then begin
                        AVGPOSFunctions.AVGPOSErrorMessage(StrSubstNo(QRCodeAlreadyExistErrMsg, POSTermLocal."No."));
                        EXIT(FALSE);
                    end;

                    IF decLAmount > POSTransactionCU.GetOutstandingBalance() THEN begin
                        AVGPOSFunctions.AVGPOSErrorMessage(PayQRAmountErrMsg);
                        EXIT(FALSE);
                    end;
                end;
        END;
        EXIT(ValidateAllEasyApi(AllEasyAPITrigger.AsInteger(), pDecAmount, pTxtAmount, pTxtMobileNo, pTxtCORefNo, POSTermLocal));
    end;

    procedure ValidateAllEasyApi(pIntAllEasyAPITrigger: Integer; pDecAmount: Decimal; pTxtAmount: Text; pTxtMobileNo: Text; pTxtCORefNo: Text; pRecPOSTerminal: Record "LSC POS Terminal"): Boolean;
    var
        txtLURL: Text;
        txtLEndpoint: Text;
        txtLRequestData: Text;
        AllEasyAPITrigger: Enum "AVG Type Trans. Line";
        txtLResponseData: Text;
        txtLScreenDisplayValue: Text;
        TextValidCI: Label 'Validating AllEasy Cash In...';
        TextSaveCI: Label 'Saving AllEasy Cash In Response...';
        TextPostCI: Label 'Posting AllEasy Cash In...';
        TextValidCO: Label 'Validating AllEasy Cash Out...';
        TextSaveCO: Label 'Saving AllEasy Cash Out Response...';
        TextPostCO: Label 'Posting AllEasy Cash Out...';
        TextSavePAYQR: Label 'Saving AllEasy Pay QR Response...';
        TextValidPAYQR: Label 'Validating AllEasy Pay QR...';
        TextPostPAYQR: Label 'Posting AllEasy Pay QR...';
        txtLValidationMessage: Text;
        txtLRefNo: Text;
        txtLAmount: Text;
        decLAmount: Decimal;
        IncExpLocal: Record "LSC Income/Expense Account";
        AVGPOSFunctions: Codeunit "AVG POS Functions";
    begin

        CLEAR(txtLRefNo);
        txtLRefNo := pRecPOSTerminal."Store No." + CreateGuid();
        txtLRefNo := DelChr(txtLRefNo, '=', '{}-');
        AVGPOSSession.ClearCurrPartnerRefNo();
        AVGPOSSession.SetCurrPartnerRefNo(txtLRefNo);
        AllEasyAPITrigger := "AVG Type Trans. Line".FromInteger(pIntAllEasyAPITrigger);
        CLEAR(txtLScreenDisplayValue);
        CLEAR(txtLValidationMessage);
        CLEAR(txtLAmount);
        CLEAR(txtLRequestData);
        CASE AllEasyAPITrigger of
            AllEasyAPITrigger::"Cash In Inquire":
                begin
                    POSTransactionCU.ScreenDisplay(TextValidCI);
                    IF AVGHttpFunctions.ProcessCashInInquire(
                        pRecPOSTerminal."AE Cash In URL",
                        pRecPOSTerminal."AE Cash In Endpoint Inquire",
                        pTxtMobileNo,
                        pDecAmount,
                        txtLRefNo,
                        pRecPOSTerminal."No.",
                        POSSession.StaffID())
                     then begin
                        POSTransactionCU.SetCurrInput(pTxtAmount);
                        POSTransactionCU.IncExpPressed(pRecPOSTerminal."AE Cash In Inc. Acc.");
                        txtLScreenDisplayValue := TextSaveCI;
                        InsertIntoAllEasyTransLine(AllEasyAPITrigger, pDecAmount);
                        EXIT(TRUE);
                    end else
                        EXIT(false);
                end;
            AllEasyAPITrigger::"Cash In Credit":
                begin
                    POSTransactionCU.ScreenDisplay(TextPostCI);
                    IF AVGHttpFunctions.ProcessCashInCredit(
                        pRecPOSTerminal."AE Cash In URL",
                        pRecPOSTerminal."AE Cash In Endpoint Credit",
                        pTxtMobileNo,
                        pDecAmount,
                        txtLRefNo,
                        pRecPOSTerminal."No.",
                        POSSession.StaffID())
                    then begin
                        InsertIntoAllEasyTransLine(AllEasyAPITrigger, pDecAmount);
                        txtLScreenDisplayValue := TextSaveCI;
                        EXIT(TRUE);
                    end else
                        EXIT(false);
                end;
            AllEasyAPITrigger::"Cash Out Inquire":
                begin
                    POSTransactionCU.ScreenDisplay(TextValidCO);
                    IF AVGHttpFunctions.ProcessCashOutInquire(
                        pRecPOSTerminal."AE Cash Out URL",
                        pRecPOSTerminal."AE Cash Out Endpoint Inquire",
                        pTxtCORefNo,
                        txtLRefNo,
                        pRecPOSTerminal."No.",
                        POSSession.StaffID(), pTxtAmount, pRecPOSTerminal)
                    then begin
                        POSTransactionCU.SetCurrInput(pTxtAmount);
                        POSTransactionCU.IncExpPressed(pRecPOSTerminal."AE Cash Out Exp. Acc.");
                        txtLScreenDisplayValue := TextSaveCO;
                        InsertIntoAllEasyTransLine(AllEasyAPITrigger, pDecAmount);
                        EXIT(TRUE);
                    end else
                        EXIT(false);
                end;
            AllEasyAPITrigger::"Cash Out Process":
                begin
                    POSTransactionCU.ScreenDisplay(TextPostCO);
                    if AVGHttpFunctions.ProcessCashOutProcess(
                        pRecPOSTerminal."AE Cash Out URL",
                        pRecPOSTerminal."AE Cash Out Endpoint Process",
                        pTxtCORefNo,
                        txtLRefNo,
                        pRecPOSTerminal."No.",
                        POSSession.StaffID())
                    THEN begin
                        InsertIntoAllEasyTransLine(AllEasyAPITrigger, pDecAmount);
                        txtLScreenDisplayValue := TextSaveCO;
                        EXIT(TRUE);
                    end else
                        EXIT(false);

                end;
            AllEasyAPITrigger::"Pay QR Inquire":
                begin
                    POSTransactionCU.ScreenDisplay(TextValidPAYQR);
                    txtLRequestData :=
                        pRecPOSTerminal."AE Pay QR URL" +
                        pRecPOSTerminal."AE Pay QR Endpoint Inquire" + '/' +
                        AVGPOSSession.GetCurrPayQRCode();
                    IF AVGHttpFunctions.ProcessPayQRInquire(txtLRequestData) THEN begin
                        InsertIntoAllEasyTransLine(AllEasyAPITrigger, pDecAmount);
                        pTxtAmount := AVGPOSSession.GetCurrPayQRAmount();
                        POSTransactionCU.SetCurrInput(pTxtAmount);
                        POSTransactionCU.TenderKeyPressed(pRecPOSTerminal."AE Pay QR Tender Type");
                        txtLScreenDisplayValue := TextSavePAYQR;
                        EXIT(TRUE);
                    end else
                        EXIT(false);
                end;
            AllEasyAPITrigger::"Pay QR Process":
                begin
                    POSTransactionCU.ScreenDisplay(TextPostPAYQR);
                    txtLRequestData :=
                        pRecPOSTerminal."AE Pay QR URL" +
                        pRecPOSTerminal."AE Pay QR Endpoint Process" + '?code=' +
                        AVGPOSSession.GetCurrPayQRCode() + '&amount=' + AVGPOSSession.GetCurrPayQRAmount;
                    IF AVGHttpFunctions.ProcessPayQRProcess(txtLRequestData) THEN begin
                        InsertIntoAllEasyTransLine(AllEasyAPITrigger, pDecAmount);
                        txtLScreenDisplayValue := TextSavePAYQR;
                        EXIT(TRUE);
                    end else
                        EXIT(false);
                end;
        end;
    END;

    local procedure InsertIntoAllEasyTransLine(pAllEasyProcessType: Enum "AVG Type Trans. Line"; pDecAmount: Decimal)
    var
        AllEasyTransLine: Record "AVG Trans. Line";
        AllEasyTransLine2: Record "AVG Trans. Line";
        intLLineNo: Integer;
    begin
        intLLineNo := 0;
        IF NOT AllEasyTransLine2.RecordLevelLocking then
            AllEasyTransLine2.LockTable(TRUE, TRUE);

        AllEasyTransLine2.RESET;
        AllEasyTransLine2.SetCurrentKey("Receipt No.", "Line No.");
        AllEasyTransLine2.SETRANGE("Store No.", POSSession.StoreNo());
        AllEasyTransLine2.SETRANGE("POS Terminal No.", POSSession.TerminalNo());
        AllEasyTransLine2.SETRANGE("Receipt No.", POSTransactionCU.GetReceiptNo());
        IF AllEasyTransLine2.FindLast() THEN
            intLLineNo := AllEasyTransLine2."Line No." + 10000
        else
            intLLineNo := 10000;

        AllEasyTransLine.INIT;
        AllEasyTransLine."Receipt No." := POSTransactionCU.GetReceiptNo();
        AllEasyTransLine."Line No." := intLLineNo;
        AllEasyTransLine."Store No." := POSTransactionCU.GetStoreNo();
        AllEasyTransLine."POS Terminal No." := POSTransactionCU.GetPOSTerminalNo();
        AllEasyTransLine."Trans. Date" := WorkDate();
        AllEasyTransLine."Trans. Time" := Time;
        AllEasyTransLine."Process Type" := pAllEasyProcessType;
        AllEasyTransLine.Amount := pDecAmount;
        AllEasyTransLine."Trans. Ref. No." := AVGPOSSession.GetCurrPartnerRefNo();
        AllEasyTransLine."Trans. Line No." := POSTransLineCU.GetCurrentLineNo();
        case pAllEasyProcessType of
            pAllEasyProcessType::"Cash In Inquire":
                begin
                    AllEasyTransLine."Res. Cash In/Out ID" := AVGHttpFunctions.GetResponseJsonByPathText('res_id');
                    AllEasyTransLine."Res. Cash In/Out Code" := AVGHttpFunctions.GetResponseJsonByPathText('res_code');
                    AllEasyTransLine."Res. Cash In/Out Message" := AVGHttpFunctions.GetResponseJsonByPathText('res_message');
                    AllEasyTransLine."Res. Cash In/Out Status" := AVGHttpFunctions.GetResponseJsonByPathText('res_status');
                    AllEasyTransLine."Res. Cash In/Out Date" := AVGHttpFunctions.GetResponseJsonByPathText('res_date');
                    AllEasyTransLine."Res. Cash In/Out Mobile No." := AVGHttpFunctions.GetResponseJsonByPathText('res_data.mobile_number');
                    AllEasyTransLine."Res. Cash In First Name" := AVGHttpFunctions.GetResponseJsonByPathText('res_data.first_name');
                    AllEasyTransLine."Res. Cash In Middle Name" := AVGHttpFunctions.GetResponseJsonByPathText('res_data.middle_name');
                    AllEasyTransLine."Res. Cash In Last Name" := AVGHttpFunctions.GetResponseJsonByPathText('res_data.last_name');
                    AllEasyTransLine."Res. Cash In/Out Birthdate" := AVGHttpFunctions.GetResponseJsonByPathText('res_data.birth_date');
                    AllEasyTransLine."Res. Cash In/Out Address" := AVGHttpFunctions.GetResponseJsonByPathText('res_data.address');
                    IF EVALUATE(AllEasyTransLine."Res. Cash In is Valid", AVGHttpFunctions.GetResponseJsonByPathText('res_data.is_valid')) THEN;
                    AllEasyTransLine."Res. Cash In Remarks" := AVGHttpFunctions.GetResponseJsonByPathText('res_data.remarks');
                end;
            pAllEasyProcessType::"Cash In Credit":
                begin
                    AllEasyTransLine."Res. Cash In/Out ID" := AVGHttpFunctions.GetResponseJsonByPathText('res_id');
                    AllEasyTransLine."Res. Cash In/Out Code" := AVGHttpFunctions.GetResponseJsonByPathText('res_code');
                    AllEasyTransLine."Res. Cash In/Out Message" := AVGHttpFunctions.GetResponseJsonByPathText('res_message');
                    AllEasyTransLine."Res. Cash In Ref. No." := AVGHttpFunctions.GetResponseJsonByPathText('res_cashin_ref');
                    AllEasyTransLine."Res. Cash In/Out Mobile No." := AVGHttpFunctions.GetResponseJsonByPathText('res_mobileno');
                    IF EVALUATE(AllEasyTransLine."Res. Cash In/Out Amount", AVGHttpFunctions.GetResponseJsonByPathText('res_amount')) THEN;
                    AllEasyTransLine."Res. Cash In/Out Status" := AVGHttpFunctions.GetResponseJsonByPathText('res_status');
                    AllEasyTransLine."Res. Cash In/Out Date" := AVGHttpFunctions.GetResponseJsonByPathText('res_date');
                end;
            pAllEasyProcessType::"Cash Out Inquire",
            pAllEasyProcessType::"Cash Out Process":
                begin
                    AllEasyTransLine."Res. Cash In/Out ID" := AVGHttpFunctions.GetResponseJsonByPathText('res_id');
                    AllEasyTransLine."Res. Cash In/Out Code" := AVGHttpFunctions.GetResponseJsonByPathText('res_code');
                    AllEasyTransLine."Res. Cash In/Out Message" := AVGHttpFunctions.GetResponseJsonByPathText('res_message');
                    AllEasyTransLine."Res. Cash Out Ref. No." := AVGHttpFunctions.GetResponseJsonByPathText('res_refno');
                    IF EVALUATE(AllEasyTransLine."Res. Cash In/Out Amount", AVGHttpFunctions.GetResponseJsonByPathText('res_amount')) THEN;
                    AllEasyTransLine."Res. Cash In/Out Status" := AVGHttpFunctions.GetResponseJsonByPathText('res_status');
                    AllEasyTransLine."Res. Cash In/Out Date" := AVGHttpFunctions.GetResponseJsonByPathText('res_date');
                    AllEasyTransLine."Res. Cash Out Subscriber Name" := AVGHttpFunctions.GetResponseJsonByPathText('res_data.subscriber_name');
                    AllEasyTransLine."Res. Cash In/Out Birthdate" := AVGHttpFunctions.GetResponseJsonByPathText('res_data.birth_date');
                    AllEasyTransLine."Res. Cash In/Out Address" := AVGHttpFunctions.GetResponseJsonByPathText('res_data.address');
                    AllEasyTransLine."Res. Cash In/Out Mobile No." := AVGHttpFunctions.GetResponseJsonByPathText('res_data.mobile');
                    AllEasyTransLine."Res. Cash Out Ref. No." := AVGHttpFunctions.GetResponseJsonByPathText('res_data.refno');
                    IF EVALUATE(AllEasyTransLine."Res. Cash Out  Amount", AVGHttpFunctions.GetResponseJsonByPathText('res_data.amount')) THEN;
                    AllEasyTransLine."Res. Cash In/Out Status" := AVGHttpFunctions.GetResponseJsonByPathText('res_data.status');
                    AllEasyTransLine."Res. Cash Out Branch" := AVGHttpFunctions.GetResponseJsonByPathText('res_data.branch');
                    AllEasyTransLine."Res. Cash Out Created At" := AVGHttpFunctions.GetResponseJsonByPathText('res_data.created_at');
                    AllEasyTransLine."Res. Cash Out Validated By" := AVGHttpFunctions.GetResponseJsonByPathText('res_data.validated_by');
                    AllEasyTransLine."Res. Cash Out Validated At" := AVGHttpFunctions.GetResponseJsonByPathText('res_data.validated_at');
                end;
            pAllEasyProcessType::"Pay QR Inquire":
                begin
                    AllEasyTransLine."Res. PayQR Status Code" := AVGHttpFunctions.GetResponseJsonByPathText('status');
                    AllEasyTransLine."Res. PayQR Message" := AVGHttpFunctions.GetResponseJsonByPathText('message');
                    AllEasyTransLine."Res. PayQR ID" := AVGHttpFunctions.GetResponseJsonByPathText('data.response.id');
                    AllEasyTransLine."Res. PayQR Code" := AVGHttpFunctions.GetResponseJsonByPathText('data.response.code');
                    AllEasyTransLine."Res. PayQR Type" := AVGHttpFunctions.GetResponseJsonByPathText('data.response.type');
                    AllEasyTransLine."Res. PayQR Ref. No." := AVGHttpFunctions.GetResponseJsonByPathText('data.response.refno');
                    IF EVALUATE(AllEasyTransLine."Res. PayQR Remaining Balance", AVGHttpFunctions.GetResponseJsonByPathText('data.response.remaining_balance')) then;
                    AllEasyTransLine."Res. PayQR Profile ID" := AVGHttpFunctions.GetResponseJsonByPathText('data.response.merchant.profile_id');
                    AllEasyTransLine."Res. PayQR First Name" := AVGHttpFunctions.GetResponseJsonByPathText('data.response.merchant.first_name');
                    AllEasyTransLine."Res. PayQR Last Name" := AVGHttpFunctions.GetResponseJsonByPathText('data.response.merchant.last_name');
                    AllEasyTransLine."Res. PayQR Mobile No." := AVGHttpFunctions.GetResponseJsonByPathText('data.response.merchant.mobile');
                    AllEasyTransLine."Res. PayQR Status" := AVGHttpFunctions.GetResponseJsonByPathText('data.response.status');
                    IF EVALUATE(AllEasyTransLine."Res. PayQR is Expired", AVGHttpFunctions.GetResponseJsonByPathText('data.response.is_expired')) THEN;
                    AllEasyTransLine."Res. PayQR Created At" := AVGHttpFunctions.GetResponseJsonByPathText('data.response.expiration');
                    AllEasyTransLine."Res. PayQR Expiration" := AVGHttpFunctions.GetResponseJsonByPathText('data.response.created_at');
                end;
            pAllEasyProcessType::"Pay QR Process":
                begin
                    AllEasyTransLine."Res. PayQR Status Code" := AVGHttpFunctions.GetResponseJsonByPathText('status');
                    AllEasyTransLine."Res. PayQR Message" := AVGHttpFunctions.GetResponseJsonByPathText('message');
                    AllEasyTransLine."Res. PayQR Ref. No." := AVGHttpFunctions.GetResponseJsonByPathText('data.refno');
                    IF EVALUATE(AllEasyTransLine."Res. PayQR Amount", AVGHttpFunctions.GetResponseJsonByPathText('data.amount')) then;
                    AllEasyTransLine."Res. PayQR Mobile No." := AVGHttpFunctions.GetResponseJsonByPathText('data.senderMobile');
                    AllEasyTransLine."Res. PayQR First Name" := AVGHttpFunctions.GetResponseJsonByPathText('data.senderFirstName');
                    AllEasyTransLine."Res. PayQR Merchant Name" := AVGHttpFunctions.GetResponseJsonByPathText('data.merchantName');
                    AllEasyTransLine."Res. PayQR DateTime" := AVGHttpFunctions.GetResponseJsonByPathText('data.datetime');
                end;
        end;
        AllEasyTransLine.Insert();
    end;

    procedure InitializeGCash(pIntGCashAPITrigger: Integer; pRecPOSTerminal: Record "LSC POS Terminal"; pLSCGlobalRec: Record "LSC POS Menu Line"): Boolean
    var
        bolOK: Boolean;
        GCashTransType: Enum "AVG Type Trans. Line";
        LSCPOSTransactionRec: Record "LSC POS Transaction";
        GCashErrMsg: Label 'GCash Pay is not Allowed for Return.\Please Try Again.';

    begin
        LSCPOSTransactionRec.Get(pLSCGlobalRec."Current-RECEIPT");
        IF LSCPOSTransactionRec."Sale Is Return Sale" THEN BEGIN
            AVGPOSFunctions.AVGPOSErrorMessage(GCashErrMsg);
            EXIT(FALSE);
        END;

        CLEAR(bolOK);
        bolOK := FALSE;
        pRecPOSTerminal.CalcFields("GCash Private Key", "GCash Public Key");
        bolOK := (pRecPOSTerminal."Enable GCash Pay") AND
                (pRecPOSTerminal."Shop ID" <> '') AND
                (pRecPOSTerminal."Shop Name" <> '') AND
                (pRecPOSTerminal."GCash Tender Type" <> '') AND
                (TenderType.Get(pRecPOSTerminal."Store No.", pRecPOSTerminal."GCash Tender Type")) AND
                (pRecPOSTerminal."GCash Private Key".HasValue) AND
                (pRecPOSTerminal."GCash Public Key".HasValue) AND
                (pRecPOSTerminal."GCash URL" <> '') AND
                (pRecPOSTerminal."GCash Client ID" <> '') AND
                (pRecPOSTerminal."GCash Client Secret" <> '') AND
                (pRecPOSTerminal."GCash Merchant ID" <> '') AND
                (pRecPOSTerminal."GCash Product Code" <> '') AND
                (pRecPOSTerminal."GCash Merchant Terminal ID" <> '') AND
                (pRecPOSTerminal."GCash Version" <> '') AND
                (pRecPOSTerminal."GCash AuthCode Type" <> '') AND
                (pRecPOSTerminal."GCash Terminal Type" <> '') AND
                (pRecPOSTerminal."GCash Order Terminal Type" <> '') AND
                (pRecPOSTerminal."GCash Scanner Device ID" <> '') AND
                (pRecPOSTerminal."GCash Scanner Device IP" <> '') AND
                (pRecPOSTerminal."GCash Merchant IP" <> '') AND
                (pRecPOSTerminal."GCash Client IP" <> '') AND
                (pRecPOSTerminal."GCash Order Title" <> '') AND
                (pRecPOSTerminal."GCash Reason Code" <> '');
        IF bolOK THEN begin
            GCashTransType := "AVG Type Trans. Line".FromInteger(pIntGCashAPITrigger);
            case GCashTransType of
                GCashTransType::"HeartBeat Check":
                    bolOK := pRecPOSTerminal."HeartBeat Check Endpoint" <> '';
                GCashTransType::"Retail Pay":
                    bolOK := pRecPOSTerminal."Retail Pay Endpoint" <> '';
                GCashTransType::"Query Transaction":
                    bolOK := pRecPOSTerminal."Query Transaction Endpoint" <> '';
                GCashTransType::"Cancel Transaction":
                    bolOK := pRecPOSTerminal."Cancel Transaction Endpoint" <> '';
                GCashTransType::"Refund Transaction":
                    bolOK := pRecPOSTerminal."Refund Transaction Endpoint" <> '';
            end;
        end;
        EXIT(bolOK);
    end;


    procedure ValidateGCashApi(pIntGCashAPITrigger: Integer): Boolean
    var
        POSTermLocal: Record "LSC POS Terminal";
        GCashTransType: Enum "AVG Type Trans. Line";
        AmountText: Text;
    begin
        GCashTransType := "AVG Type Trans. Line".FromInteger(pIntGCashAPITrigger);
        POSTermLocal.Get(POSSession.TerminalNo());
        CASE GCashTransType of
            GCashTransType::"Retail Pay":
                begin
                    CLEAR(AmountText);
                    AmountText := AVGPOSSession.GetGCashCurrPayQRAmount();
                    POSTransactionCU.SetCurrInput(AmountText);
                    POSTransactionCU.TenderKeyPressed(POSTermLocal."GCash Tender Type");
                    EXIT(AVGHttpFunctions.GCashRetailPay(POSTermLocal, AVGPOSSession.GetGCashCurrPayQRAmount(), AVGPOSSession.GetCurrGCashPayQRCode()));
                end;
            GCashTransType::"Cancel Transaction":
                EXIT(AVGHttpFunctions.GCashCancel(POSTermLocal, AVGPOSSession.GetCurrGCashCancelAcqID()));
            GCashTransType::"Refund Transaction":
                exit(AVGHttpFunctions.GCashRefund(POSTermLocal, AVGPOSSession.GetCurrGCashRefundAmount, AVGPOSSession.GetCurrGCashRefundAcqID()));

        END;
    end;

    procedure GCashHeartBeatCheck(pRecPOSTerminal: Record "LSC POS Terminal")
    begin
        AVGHttpFunctions.GCashHeartBeatCheck(pRecPOSTerminal, TRUE);
    end;

    // procedure GCashRetailPay(pRecPOSTerminal: Record "LSC POS Terminal")
    // begin
    //     AVGHttpFunctions.GCashRetailPay(pRecPOSTerminal, TRUE);
    // end;

    // procedure GCashHeartBeatCheck(pRecPOSTerminal: Record "LSC POS Terminal")
    // begin
    //     AVGHttpFunctions.GCashHeartBeatCheck(pRecPOSTerminal, TRUE);
    // end;

    // procedure GCashHeartBeatCheck(pRecPOSTerminal: Record "LSC POS Terminal")
    // begin
    //     AVGHttpFunctions.GCashHeartBeatCheck(pRecPOSTerminal, TRUE);
    // end;

    // procedure GCashHeartBeatCheck(pRecPOSTerminal: Record "LSC POS Terminal")
    // begin
    //     AVGHttpFunctions.GCashHeartBeatCheck(pRecPOSTerminal, TRUE);
    // end;
}
