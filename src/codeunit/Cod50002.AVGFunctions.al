codeunit 50002 "AVG Functions"
{
    SingleInstance = true;

    var
        GlobalPOSMenuLineTemp: Record "LSC POS Menu Line" temporary;
        IncExp: Record "LSC Income/Expense Account";
        TenderType: Record "LSC Tender Type";
        LSCPOSSession: Codeunit "LSC POS Session";
        LSCPOSTransactionCU: Codeunit "LSC POS Transaction";
        POSTransLineCU: Codeunit "LSC POS Trans. Lines";
        AVGPOSSession: Codeunit "AVG POS Session";
        AVGPOSFunctions: Codeunit "AVG POS Functions";
        AVGHttpFunctions: Codeunit "AVG Http Functions";
        ConnectingToServerMsg: Label 'Connecting to AllEasy Server...';

    procedure GCashHeartBeatCheck(pRecPOSTerminal: Record "LSC POS Terminal")
    begin
        AVGHttpFunctions.GCashHeartBeatCheck(pRecPOSTerminal, TRUE);
    end;

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
            LSCPOSTransactionCU.ScreenDisplay(ConnectingToServerMsg);
            txtLAuthorizeToken := AVGHttpFunctions.ProcessAuthToken(txtLURL, txtLEndpoint, txtLClientID, txtLClientSecret, bolPayQR, txtLHeader1, txtLHeader2);
            AVGPOSSession.ClearCurrAuthToken();
            AVGPOSSession.SetCurrAuthToken(txtLAuthorizeToken);
            bolOK := txtLAuthorizeToken <> '';
            LSCPOSTransactionCU.ScreenDisplay('');
        END;
        EXIT(bolOK);
    END;

    procedure InitializeGCash(pIntGCashAPITrigger: Integer; pRecPOSTerminal: Record "LSC POS Terminal"): Boolean
    var
        bolOK: Boolean;
        GCashTransType: Enum "AVG Type Trans. Line";
    begin
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

    Procedure SetGlobalLSCPOSMenuLine(pLSCPOSMenuLine: Record "LSC POS Menu Line")
    begin
        GlobalPOSMenuLineTemp.RESET;
        GlobalPOSMenuLineTemp.DELETEALL;
        GlobalPOSMenuLineTemp := pLSCPOSMenuLine;
    end;

    procedure ValidateAllEasy(pIntAllEasyAPITrigger: Integer; pDecAmount: Decimal; pTxtAmount: Text; pTxtCORefNo: Text; pTxtMobileNo: text): Boolean;
    var
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
        POSTermLocal.GET(LSCPOSSession.TerminalNo());
        AllEasyAPITrigger := "AVG Type Trans. Line".FromInteger(pIntAllEasyAPITrigger);
        CASE AllEasyAPITrigger OF
            AllEasyAPITrigger::"Cash In Inquire":
                begin
                    POSTermLocal.GET(LSCPOSSession.TerminalNo());
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
                    recLAllEasyTransLine.SETRANGE("Store No.", LSCPOSSession.StoreNo());
                    recLAllEasyTransLine.SETRANGE("Process Type", recLAllEasyTransLine."Process Type"::"Pay QR Inquire");
                    recLAllEasyTransLine.SETRANGE("Res. PayQR Code", AVGPOSSession.GetCurrPayQRCode());
                    IF recLAllEasyTransLine.FINDFIRST then begin
                        AVGPOSFunctions.AVGPOSErrorMessage(StrSubstNo(QRCodeAlreadyExistErrMsg, POSTermLocal."No."));
                        EXIT(FALSE);
                    end;

                    IF decLAmount > LSCPOSTransactionCU.GetOutstandingBalance() THEN begin
                        AVGPOSFunctions.AVGPOSErrorMessage(PayQRAmountErrMsg);
                        EXIT(FALSE);
                    end;
                end;
        END;
        EXIT(ValidateAllEasyApi(AllEasyAPITrigger.AsInteger(), pDecAmount, pTxtAmount, pTxtMobileNo, pTxtCORefNo, POSTermLocal));
    end;

    procedure ValidateAllEasyApi(pIntAllEasyAPITrigger: Integer; pDecAmount: Decimal; pTxtAmount: Text; pTxtMobileNo: Text; pTxtCORefNo: Text; pRecPOSTerminal: Record "LSC POS Terminal"): Boolean;
    var
        txtLRequestData: Text;
        AllEasyAPITrigger: Enum "AVG Type Trans. Line";
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
                    LSCPOSTransactionCU.ScreenDisplay(TextValidCI);
                    IF AVGHttpFunctions.ProcessCashInInquire(
                        pRecPOSTerminal."AE Cash In URL",
                        pRecPOSTerminal."AE Cash In Endpoint Inquire",
                        pTxtMobileNo,
                        pDecAmount,
                        txtLRefNo,
                        pRecPOSTerminal."No.",
                        LSCPOSSession.StaffID())
                     then begin
                        LSCPOSTransactionCU.SetCurrInput(pTxtAmount);
                        LSCPOSTransactionCU.IncExpPressed(pRecPOSTerminal."AE Cash In Inc. Acc.");
                        txtLScreenDisplayValue := TextSaveCI;
                        InsertIntoAllEasyTransLine(AllEasyAPITrigger, pDecAmount);
                        EXIT(TRUE);
                    end else
                        EXIT(false);
                end;
            AllEasyAPITrigger::"Cash In Credit":
                begin
                    LSCPOSTransactionCU.ScreenDisplay(TextPostCI);
                    IF AVGHttpFunctions.ProcessCashInCredit(
                        pRecPOSTerminal."AE Cash In URL",
                        pRecPOSTerminal."AE Cash In Endpoint Credit",
                        pTxtMobileNo,
                        pDecAmount,
                        txtLRefNo,
                        pRecPOSTerminal."No.",
                        LSCPOSSession.StaffID())
                    then begin
                        InsertIntoAllEasyTransLine(AllEasyAPITrigger, pDecAmount);
                        txtLScreenDisplayValue := TextSaveCI;
                        EXIT(TRUE);
                    end else
                        EXIT(false);
                end;
            AllEasyAPITrigger::"Cash Out Inquire":
                begin
                    LSCPOSTransactionCU.ScreenDisplay(TextValidCO);
                    IF AVGHttpFunctions.ProcessCashOutInquire(
                        pRecPOSTerminal."AE Cash Out URL",
                        pRecPOSTerminal."AE Cash Out Endpoint Inquire",
                        pTxtCORefNo,
                        txtLRefNo,
                        pRecPOSTerminal."No.",
                        LSCPOSSession.StaffID(), pTxtAmount, pRecPOSTerminal)
                    then begin
                        LSCPOSTransactionCU.SetCurrInput(pTxtAmount);
                        LSCPOSTransactionCU.IncExpPressed(pRecPOSTerminal."AE Cash Out Exp. Acc.");
                        txtLScreenDisplayValue := TextSaveCO;
                        InsertIntoAllEasyTransLine(AllEasyAPITrigger, pDecAmount);
                        EXIT(TRUE);
                    end else
                        EXIT(false);
                end;
            AllEasyAPITrigger::"Cash Out Process":
                begin
                    LSCPOSTransactionCU.ScreenDisplay(TextPostCO);
                    if AVGHttpFunctions.ProcessCashOutProcess(
                        pRecPOSTerminal."AE Cash Out URL",
                        pRecPOSTerminal."AE Cash Out Endpoint Process",
                        pTxtCORefNo,
                        txtLRefNo,
                        pRecPOSTerminal."No.",
                        LSCPOSSession.StaffID())
                    THEN begin
                        InsertIntoAllEasyTransLine(AllEasyAPITrigger, pDecAmount);
                        txtLScreenDisplayValue := TextSaveCO;
                        EXIT(TRUE);
                    end else
                        EXIT(false);

                end;
            AllEasyAPITrigger::"Pay QR Inquire":
                begin
                    LSCPOSTransactionCU.ScreenDisplay(TextValidPAYQR);
                    txtLRequestData :=
                        pRecPOSTerminal."AE Pay QR URL" +
                        pRecPOSTerminal."AE Pay QR Endpoint Inquire" + '/' +
                        AVGPOSSession.GetCurrPayQRCode();
                    IF AVGHttpFunctions.ProcessPayQRInquire(txtLRequestData) THEN begin
                        InsertIntoAllEasyTransLine(AllEasyAPITrigger, pDecAmount);
                        pTxtAmount := AVGPOSSession.GetCurrPayQRAmount();
                        LSCPOSTransactionCU.SetCurrInput(pTxtAmount);
                        LSCPOSTransactionCU.TenderKeyPressed(pRecPOSTerminal."AE Pay QR Tender Type");
                        txtLScreenDisplayValue := TextSavePAYQR;
                        EXIT(TRUE);
                    end else
                        EXIT(false);
                end;
            AllEasyAPITrigger::"Pay QR Process":
                begin
                    LSCPOSTransactionCU.ScreenDisplay(TextPostPAYQR);
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

    procedure ValidateGCashApi(pIntGCashAPITrigger: Integer): Boolean
    var
        POSTermLocal: Record "LSC POS Terminal";
        GCashTransType: Enum "AVG Type Trans. Line";
        AmountText: Text;
        bolResult: Boolean;
    begin
        IF NOT ValidatedGCash(pIntGCashAPITrigger) then
            EXIT(false);

        CLEAR(bolResult);
        GCashTransType := "AVG Type Trans. Line".FromInteger(pIntGCashAPITrigger);
        POSTermLocal.Get(LSCPOSSession.TerminalNo());
        CASE GCashTransType of
            GCashTransType::"Retail Pay":
                begin
                    CLEAR(AmountText);
                    AmountText := AVGPOSSession.GetGCashCurrPayQRAmount();
                    bolResult := AVGHttpFunctions.GCashRetailPay(POSTermLocal, AmountText, AVGPOSSession.GetCurrGCashPayQRCode());
                    IF bolResult THEN BEGIN
                        LSCPOSTransactionCU.SetCurrInput(AmountText);
                        LSCPOSTransactionCU.TenderKeyPressed(POSTermLocal."GCash Tender Type");
                    END;
                end;
            GCashTransType::"Cancel Transaction":
                bolResult := AVGHttpFunctions.GCashCancel(POSTermLocal, AVGPOSSession.GetCurrGCashCancelAcqID());
            GCashTransType::"Refund Transaction":
                begin
                    CLEAR(AmountText);
                    AmountText := AVGPOSSession.GetCurrGCashRefundAmount();
                    bolResult := AVGHttpFunctions.GCashRefund(POSTermLocal, AVGPOSSession.GetCurrGCashRefundAmount, AVGPOSSession.GetCurrGCashRefundAcqID());
                    IF bolResult THEN BEGIN
                        LSCPOSTransactionCU.SetCurrInput(AmountText);
                        LSCPOSTransactionCU.TenderKeyPressed(POSTermLocal."GCash Tender Type");
                    end;
                END;
        end;
        EXIT(bolResult);
    end;

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
        AllEasyTransLine2.SETRANGE("Store No.", LSCPOSSession.StoreNo());
        AllEasyTransLine2.SETRANGE("POS Terminal No.", LSCPOSSession.TerminalNo());
        AllEasyTransLine2.SETRANGE("Receipt No.", LSCPOSTransactionCU.GetReceiptNo());
        IF AllEasyTransLine2.FindLast() THEN
            intLLineNo := AllEasyTransLine2."Line No." + 10000
        else
            intLLineNo := 10000;

        AllEasyTransLine.INIT;
        AllEasyTransLine."Receipt No." := LSCPOSTransactionCU.GetReceiptNo();
        AllEasyTransLine."Line No." := intLLineNo;
        AllEasyTransLine."Store No." := LSCPOSTransactionCU.GetStoreNo();
        AllEasyTransLine."POS Terminal No." := LSCPOSTransactionCU.GetPOSTerminalNo();
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

    local procedure ValidatedGCash(pIntGCashAPITrigger: Integer): Boolean;
    var
        LSCPOSTransactionRec: Record "LSC POS Transaction";
        LSCInfocodeRec: Record "LSC Infocode";
        GCashTransLineEntryRec: Record "AVG Trans. Line Entry";
        LSCPOSTerminalRec: Record "LSC POS Terminal";
        RefundAmount: Text;
        GCashTransType: Enum "AVG Type Trans. Line";
        GCashRetailPayErrMsg: Label 'GCash Pay is not Allowed for Return Transaction.\Please Try Again.';
        GCashRefundErrMsg: Label 'GCash Refund is not Allowed for Sales Transaction.\Please Try Again.';
    begin
        IF NOT LSCPOSTransactionRec.Get(LSCPOSTransactionCU.GetReceiptNo()) then
            EXIT;

        IF NOT LSCPOSTerminalRec.Get(LSCPOSTransactionRec."POS Terminal No.") THEN
            EXIT;

        IF NOT InitializeGCash(pIntGCashAPITrigger, LSCPOSTerminalRec) then
            EXIT;

        GCashTransType := "AVG Type Trans. Line".FromInteger(pIntGCashAPITrigger);
        CASE GCashTransType of
            GCashTransType::"Retail Pay":
                begin
                    IF LSCPOSTransactionRec."Sale Is Return Sale" THEN BEGIN
                        AVGPOSFunctions.AVGPOSErrorMessage(GCashRetailPayErrMsg);
                        exit(false);
                    END ELSE
                        exit(true);
                end;
            GCashTransType::"Cancel Transaction":
                begin
                    exit(true);
                end;
            GCashTransType::"Refund Transaction":
                begin
                    IF NOT LSCPOSTransactionRec."Sale Is Return Sale" THEN BEGIN
                        AVGPOSFunctions.AVGPOSErrorMessage(GCashRefundErrMsg);
                        exit(false);
                    end else begin
                        IF LSCPOSTerminalRec."GCash Reason Code" = '' then
                            exit(false);

                        IF not LSCInfocodeRec.Get(LSCPOSTerminalRec."GCash Reason Code") then
                            exit(false);

                        GCashTransLineEntryRec.RESET;
                        GCashTransLineEntryRec.SETRANGE("Store No.", LSCPOSTransactionRec."Retrieved from Store No.");
                        GCashTransLineEntryRec.SETRANGE("POS Terminal No.", LSCPOSTransactionRec."Retrieved from POS Term. No.");
                        GCashTransLineEntryRec.SETRANGE("Transaction No.", LSCPOSTransactionRec."Retrieved from Trans. No.");
                        GCashTransLineEntryRec.SETRANGE("Process Type", GCashTransLineEntryRec."Process Type"::"Retail Pay");
                        IF NOT GCashTransLineEntryRec.FINDFIRST then
                            exit(false);

                        CLEAR(RefundAmount);
                        RefundAmount := FORMAT(GCashTransLineEntryRec.Amount);
                        AVGPOSSession.ClearCurrGCashRefundAmount();
                        AVGPOSSession.SetCurrGCashRefundAmount(RefundAmount);
                        AVGPOSSession.ClearCurrGCashRefundAcqID();
                        AVGPOSSession.SetCurrGCashRefundAcqID(GCashTransLineEntryRec."GCash Acquirement ID");
                        exit(true);
                    end;
                end;
        end;
    end;

    procedure ValidateLoyalty(pIntLoyaltyAPITrigger: Integer; CardNo: Text; Amount: Text): Boolean;
    var
        LoyaltyTransType: Enum "AVG Type Trans. Line";
        LSCPOSTerminalRec: Record "LSC POS Terminal";
        LoyaltyErrMsg: Label 'Invalid Loyalty Member Card Number.\Please Try Again.';
        LoyReq: Text;
        LoyRes: Text;
    begin
        CLEAR(LoyReq);
        CLEAR(LoyRes);
        IF NOT LSCPOSTerminalRec.Get(LSCPOSSession.TerminalNo()) THEN
            EXIT(FALSE);

        IF NOT LSCPOSTerminalRec."Enable Loyalty" then
            EXIT(FALSE);

        IF LSCPOSTerminalRec."Loyalty Url" = '' then
            EXIT(FALSE);

        IF NOT IsValidInput(CardNo, '^[a-zA-z0-9 ]*$') then begin
            AVGPOSFunctions.AVGPOSErrorMessage(LoyaltyErrMsg);
            EXIT(false);
        end;
        LoyaltyTransType := "AVG Type Trans. Line".FromInteger(pIntLoyaltyAPITrigger);
        case LoyaltyTransType of
            LoyaltyTransType::"Loyalty Balance Inquiry":
                AVGHttpFunctions.ProcessLoyaltyAPI(pIntLoyaltyAPITrigger, LSCPOSTerminalRec."Loyalty Url", CardNo, LoyReq, LoyRes);
            LoyaltyTransType::"Loyalty Add Member":
                begin
                    IF AVGHttpFunctions.ProcessLoyaltyAPI(pIntLoyaltyAPITrigger, LSCPOSTerminalRec."Loyalty Url", CardNo, LoyReq, LoyRes) then begin
                        InsertIntoLoyaltyTransLine(pIntLoyaltyAPITrigger, CardNo, LoyReq, LoyRes);
                        IF LoyaltyTransType = LoyaltyTransType::"Loyalty Add Member" THEN
                            LSCPOSTransactionCU.SetFunctionMode('ITEM');
                    end;
                end;
            LoyaltyTransType::"Loyalty Redeem Points":
                begin
                    if LSCPOSSession.GetValue('LOYMEMBERCARD') = '' then begin
                        AVGPOSFunctions.AVGPOSErrorMessage('Loyalty Member must be Added.');
                        EXIT(FALSE);
                    end;
                    LSCPOSTransactionCU.SetCurrInput(Amount);
                    LSCPOSTransactionCU.TenderKeyPressed(AVGPOSSession.GetCurrLoyaltyCurrTenderType());
                end;
        end;
    end;

    local procedure IsValidInput(StringText: Text; PatternText: Text): Boolean;
    var
        CustRegex: DotNet Regex;
        Match: Boolean;
    begin
        CLEAR(CustRegex);
        CustRegex := CustRegex.Regex(StrSubstNo('%1', PatternText));
        Match := CustRegex.IsMatch(StringText);
        EXIT(Match);
    end;

    procedure InsertIntoLoyaltyTransLine(pIntLoyaltyAPITrigger: Integer; CardNo: Text; pLoyReq: Text; pLoyRes: Text)
    var
        LoyaltyTransType: Enum "AVG Type Trans. Line";
        LoyaltyTransLine: Record "AVG Trans. Line";
        LoyaltyTransLine2: Record "AVG Trans. Line";
        intLLineNo: Integer;
        CardNumberLast4: Text;
        FullName: Text;
        Balance: Decimal;
        LastVisited: Text;
    begin
        intLLineNo := 0;
        IF NOT LoyaltyTransLine2.RecordLevelLocking then
            LoyaltyTransLine2.LockTable(TRUE, TRUE);

        LoyaltyTransLine2.RESET;
        LoyaltyTransLine2.SetCurrentKey("Receipt No.", "Line No.");
        LoyaltyTransLine2.SETRANGE("Store No.", LSCPOSSession.StoreNo());
        LoyaltyTransLine2.SETRANGE("POS Terminal No.", LSCPOSSession.TerminalNo());
        LoyaltyTransLine2.SETRANGE("Receipt No.", LSCPOSTransactionCU.GetReceiptNo());
        IF LoyaltyTransLine2.FindLast() THEN
            intLLineNo := LoyaltyTransLine2."Line No." + 10000
        else
            intLLineNo := 10000;
        LoyaltyTransLine.INIT;
        LoyaltyTransLine."Receipt No." := LSCPOSTransactionCU.GetReceiptNo();
        LoyaltyTransLine."Line No." := intLLineNo;
        LoyaltyTransLine."Store No." := LSCPOSTransactionCU.GetStoreNo();
        LoyaltyTransLine."POS Terminal No." := LSCPOSTransactionCU.GetPOSTerminalNo();
        LoyaltyTransLine."Trans. Date" := WorkDate();
        LoyaltyTransLine."Trans. Time" := Time;
        LoyaltyTransLine."Loyalty Request" := pLoyReq;
        LoyaltyTransLine."Loyalty Response" := pLoyRes;
        LoyaltyTransType := "AVG Type Trans. Line".FromInteger(pIntLoyaltyAPITrigger);
        CLEAR(CardNumberLast4);
        CardNumberLast4 := CardNo;
        AVGHttpFunctions.GetLast4DigitsLoyCardNo(CardNumberLast4);
        CLEAR(FullName);
        CLEAR(Balance);
        CLEAR(LastVisited);
        FullName := AVGHttpFunctions.GetResponseJsonByPathText('loyalty.data[0].first_name');
        FullName += ' ' + AVGHttpFunctions.GetResponseJsonByPathText('loyalty.data[0].middle_name');
        FullName += ' ' + AVGHttpFunctions.GetResponseJsonByPathText('loyalty.data[0].last_name');
        IF EVALUATE(Balance, AVGHttpFunctions.GetResponseJsonByPathText('loyalty.data[0].balance')) THEN;
        LastVisited := AVGHttpFunctions.GetResponseJsonByPathText('loyalty.data[0].last_visit');
        LoyaltyTransLine."Loyalty Member Full Name" := FullName;
        LoyaltyTransLine."Loyalty Member Balance" := Balance;
        LoyaltyTransLine."Loyalty Card Number" := CardNo;
        LoyaltyTransLine."Loyalty Card Number Last 4" := CardNumberLast4;
        LoyaltyTransLine."Loyalty Member Last Visited" := LastVisited;
        case LoyaltyTransType of
            LoyaltyTransType::"Loyalty Add Member":
                LoyaltyTransLine."Process Type" := LoyaltyTransType::"Loyalty Add Member";
            LoyaltyTransType::"Loyalty Earn Points":
                begin
                    LoyaltyTransLine."Process Type" := LoyaltyTransType::"Loyalty Earn Points";
                    IF EVALUATE(LoyaltyTransLine."Loyalty Points Earned", AVGHttpFunctions.GetResponseJsonByPathText('loyalty.data[0].points_earned')) THEN;
                end;
            LoyaltyTransType::"Loyalty Redeem Points":
                begin
                    LoyaltyTransLine."Process Type" := LoyaltyTransType::"Loyalty Redeem Points";
                    IF EVALUATE(LoyaltyTransLine."Loyalty Points Earned", AVGHttpFunctions.GetResponseJsonByPathText('loyalty.data[0].points_redeemed')) THEN;
                end;
        end;
        LoyaltyTransLine.Insert;
    end;

    procedure InsertIntoLoyaltyTransLineEntry(TransactionHeader: Record "LSC Transaction Header"; pIntLoyaltyAPITrigger: Integer; CardNo: Text; pLoyReq: Text; pLoyRes: Text)
    var
        LoyaltyTransType: Enum "AVG Type Trans. Line";
        LoyaltyTransLineEntry: Record "AVG Trans. Line Entry";
        LoyaltyTransLineEntry2: Record "AVG Trans. Line Entry";
        intLLineNo: Integer;
        CardNumberLast4: Text;
        FullName: Text;
        Balance: Decimal;
        LastVisited: Text;
    begin
        intLLineNo := 0;
        IF NOT LoyaltyTransLineEntry2.RecordLevelLocking then
            LoyaltyTransLineEntry2.LockTable(TRUE, TRUE);

        LoyaltyTransLineEntry2.RESET;
        LoyaltyTransLineEntry2.SetCurrentKey("Store No.", "POS Terminal No.", "Transaction No.", "Line No.");
        LoyaltyTransLineEntry2.SETRANGE("Store No.", TransactionHeader."Store No.");
        LoyaltyTransLineEntry2.SETRANGE("POS Terminal No.", TransactionHeader."POS Terminal No.");
        LoyaltyTransLineEntry2.SETRANGE("Transaction No.", TransactionHeader."Transaction No.");
        IF LoyaltyTransLineEntry2.FindLast() THEN
            intLLineNo := LoyaltyTransLineEntry2."Line No." + 10000
        else
            intLLineNo := 10000;
        LoyaltyTransLineEntry.INIT;
        LoyaltyTransLineEntry."Receipt No." := TransactionHeader."Receipt No.";
        LoyaltyTransLineEntry."Line No." := intLLineNo;
        LoyaltyTransLineEntry."Store No." := TransactionHeader."Store No.";
        LoyaltyTransLineEntry."POS Terminal No." := TransactionHeader."POS Terminal No.";
        LoyaltyTransLineEntry."Transaction No." := TransactionHeader."Transaction No.";
        LoyaltyTransLineEntry."Trans. Date" := TransactionHeader.Date;
        LoyaltyTransLineEntry."Trans. Time" := TransactionHeader.Time;
        // LoyaltyTransLineEntry."Loyalty Request" := pLoyReq;
        // LoyaltyTransLineEntry."Loyalty Response" := pLoyRes;
        LoyaltyTransType := "AVG Type Trans. Line".FromInteger(pIntLoyaltyAPITrigger);
        CLEAR(CardNumberLast4);
        CardNumberLast4 := CardNo;
        AVGHttpFunctions.GetLast4DigitsLoyCardNo(CardNumberLast4);
        CLEAR(FullName);
        CLEAR(Balance);
        CLEAR(LastVisited);
        FullName := AVGHttpFunctions.GetResponseJsonByPathText('loyalty.data[0].first_name');
        FullName += ' ' + AVGHttpFunctions.GetResponseJsonByPathText('loyalty.data[0].middle_name');
        FullName += ' ' + AVGHttpFunctions.GetResponseJsonByPathText('loyalty.data[0].last_name');
        IF EVALUATE(Balance, AVGHttpFunctions.GetResponseJsonByPathText('loyalty.data[0].balance')) THEN;
        LastVisited := AVGHttpFunctions.GetResponseJsonByPathText('loyalty.data[0].last_visit');
        LoyaltyTransLineEntry."Loyalty Member Full Name" := FullName;
        LoyaltyTransLineEntry."Loyalty Member Balance" := Balance;
        LoyaltyTransLineEntry."Loyalty Card Number" := CardNo;
        LoyaltyTransLineEntry."Loyalty Card Number Last 4" := CardNumberLast4;
        LoyaltyTransLineEntry."Loyalty Member Last Visited" := LastVisited;
        case LoyaltyTransType of
            LoyaltyTransType::"Loyalty Earn Points":
                begin
                    LoyaltyTransLineEntry."Process Type" := LoyaltyTransType::"Loyalty Earn Points";
                    IF EVALUATE(LoyaltyTransLineEntry."Loyalty Points Earned", AVGHttpFunctions.GetResponseJsonByPathText('loyalty.data[0].points_earned')) THEN;
                end;
            LoyaltyTransType::"Loyalty Redeem Points":
                begin
                    LoyaltyTransLineEntry."Process Type" := LoyaltyTransType::"Loyalty Redeem Points";
                    IF EVALUATE(LoyaltyTransLineEntry."Loyalty Points Redeemed", AVGHttpFunctions.GetResponseJsonByPathText('loyalty.data[0].points_redeemed')) THEN;
                end;
        end;
        LoyaltyTransLineEntry.Insert;
    end;

    procedure CheckLoyalty(TransactionHeader: Record "LSC Transaction Header"; var pCardNo: Text; var pCardLast4: Text): Boolean;
    var
        LoyaltyTransLineEntry: Record "AVG Trans. Line Entry";
    begin
        LoyaltyTransLineEntry.RESET;
        LoyaltyTransLineEntry.SetCurrentKey("Store No.", "POS Terminal No.", "Transaction No.", "Line No.");
        LoyaltyTransLineEntry.SETRANGE("Store No.", TransactionHeader."Store No.");
        LoyaltyTransLineEntry.SETRANGE("POS Terminal No.", TransactionHeader."POS Terminal No.");
        LoyaltyTransLineEntry.SETRANGE("Transaction No.", TransactionHeader."Transaction No.");
        LoyaltyTransLineEntry.SETFILTER("Loyalty Card Number", '<>%1', '');
        IF LoyaltyTransLineEntry.FindFirst() then begin
            pCardNo := LoyaltyTransLineEntry."Loyalty Card Number";
            pCardLast4 := LoyaltyTransLineEntry."Loyalty Card Number Last 4";
            exit(true);
        end else
            exit(false);
    end;

    procedure LoyaltySendTransaction(var TransactionHeader: Record "LSC Transaction Header"): Boolean;
    var
        LSCPOSTerminal: Record "LSC POS Terminal";
        LoyaltyTransLineEntry: Record "AVG Trans. Line Entry";
        LSCTransSalesEntry: Record "LSC Trans. Sales Entry";
        LSCTransPaymentEntry: Record "LSC Trans. Payment Entry";
        LSCBarcode: Record "LSC Barcodes";
        LSCTenderType: Record "LSC Tender Type";
        Item: Record Item;
        Voided: Integer;
        Refund: Integer;
        ItemCount: Integer;
        TenderCount: Integer;
        Counter: Integer;
        PromoCount: Integer;
        Data: Text;
        POSKey: Text;
    begin
        IF NOT LSCPOSTerminal.GET(TransactionHeader."POS Terminal No.") then
            EXIT;

        IF NOT LSCPOSTerminal."Enable Loyalty" then
            EXIT;

        IF LSCPOSTerminal."Loyalty Url" = '' then
            EXIT;

        IF LSCPOSTerminal."Loyalty POS No." = '' then
            EXIT;

        LoyaltyTransLineEntry.RESET;
        LoyaltyTransLineEntry.setrange("Store No.", TransactionHeader."Store No.");
        LoyaltyTransLineEntry.setrange("POS Terminal No.", TransactionHeader."POS Terminal No.");
        LoyaltyTransLineEntry.setrange("Transaction No.", TransactionHeader."Transaction No.");
        LoyaltyTransLineEntry.setfilter("Loyalty Card Number", '<>%1', '');
        if NOT LoyaltyTransLineEntry.FindFirst() then
            exit;

        Voided := 0;
        IF TransactionHeader."Entry Status" = TransactionHeader."Entry Status"::Voided then
            Voided := 1;

        Refund := 0;
        IF TransactionHeader."Sale Is Return Sale" then
            Refund := 1;

        CLEAR(POSKey);
        POSKey := '10yalty' +
                LoyaltyTransLineEntry."Loyalty Card Number" +
                TransactionHeader."Store No." +
                FORMAT(TransactionHeader.Date, 0, '<Closing><Year4><Month,2><Day,2>') +
                LSCPOSTerminal."Loyalty POS No." +
                TransactionHeader."Official Receipt No.";

        CLEAR(Data);
        Data := STRSUBSTNO('state=trans&') +
                    STRSUBSTNO('store=%1&', TransactionHeader."Store No.") +
                    STRSUBSTNO('card_number=%1&', LoyaltyTransLineEntry."Loyalty Card Number") +
                    STRSUBSTNO('pos=%1&', LSCPOSTerminal."Loyalty POS No.") +
                    STRSUBSTNO('posdate=%1&', FORMAT(TransactionHeader.Date, 0, '<Closing><Year4><Month,2><Day,2>')) +
                    STRSUBSTNO('or_num=%1&', TransactionHeader."Official Receipt No.") +
                    STRSUBSTNO('cashier=%1&', TransactionHeader."Staff ID") +
                    STRSUBSTNO('is_void=%1&', Voided) +
                    STRSUBSTNO('is_refund=%1&', Refund) +
                    STRSUBSTNO('pos_key=%1&', CreateMD5(POSKey));

        CLEAR(ItemCount);
        CLEAR(LSCTransSalesEntry);
        LSCTransSalesEntry.SETCURRENTKEY("Store No.", "POS Terminal No.", "Transaction No.", "Line No.");
        LSCTransSalesEntry.SETRANGE("Store No.", TransactionHeader."Store No.");
        LSCTransSalesEntry.SETRANGE("POS Terminal No.", TransactionHeader."POS Terminal No.");
        LSCTransSalesEntry.SETRANGE("Transaction No.", TransactionHeader."Transaction No.");
        IF LSCTransSalesEntry.FINDSET THEN BEGIN
            ItemCount := LSCTransSalesEntry.COUNT;
            Data += STRSUBSTNO('item_count=%1&', ItemCount);
        END;

        CLEAR(TenderCount);
        CLEAR(LSCTransPaymentEntry);
        LSCTransPaymentEntry.SETCURRENTKEY("Store No.", "POS Terminal No.", "Transaction No.", "Line No.");
        LSCTransPaymentEntry.SETRANGE("Store No.", TransactionHeader."Store No.");
        LSCTransPaymentEntry.SETRANGE("POS Terminal No.", TransactionHeader."POS Terminal No.");
        LSCTransPaymentEntry.SETRANGE("Transaction No.", TransactionHeader."Transaction No.");
        IF LSCTransPaymentEntry.FINDSET THEN BEGIN
            TenderCount := LSCTransPaymentEntry.COUNT;
            Data += STRSUBSTNO('tender_count=%1&', TenderCount);
        END ELSE
            EXIT;

        Counter := 1;
        CLEAR(PromoCount);
        REPEAT
            IF Item.GET(LSCTransSalesEntry."Item No.") THEN BEGIN
                Data += STRSUBSTNO('&item_code_%1=%2&', Counter, Item."No.") +
                        STRSUBSTNO('item_desc_%1=%2&', Counter, Item.Description) +
                        STRSUBSTNO('retail_price_%1=%2&', Counter, FORMAT(LSCTransSalesEntry.Price, 0, 1)) +
                        STRSUBSTNO('quantity_%1=%2&', Counter, -LSCTransSalesEntry.Quantity) +
                        STRSUBSTNO('category_cd_%1=%2&', Counter, Item."LSC Division Code") +
                        STRSUBSTNO('subcat_cd_%1=%2&', Counter, Item."Item Category Code") +
                        STRSUBSTNO('class_cd_%1=%2&', Counter, Item."LSC Retail Product Code" +
                        STRSUBSTNO('subclass_cd_%1=%2', Counter, Item."LSC Item Family Code"));
                IF STRPOS(Item.Description, 'PROMOLOY') > 0 THEN BEGIN
                    CLEAR(LSCBarcode);
                    LSCBarcode.SETRANGE("Item No.", Item."No.");
                    LSCBarcode.SETRANGE("Barcode No.", LSCTransSalesEntry."Barcode No.");
                    LSCBarcode.SETRANGE("Unit of Measure Code", LSCTransSalesEntry."Unit of Measure");
                    IF LSCBarcode.FINDFIRST THEN BEGIN
                        PromoCount += 1;
                        Data += STRSUBSTNO('&promo_code_%1=%2&', Counter, LSCBarcode."Barcode No.") +
                                STRSUBSTNO('promo_count_%1=%2', Counter, PromoCount);
                    END;
                END;

                Counter += 1;
            END;
        UNTIL LSCTransSalesEntry.NEXT = 0;

        Counter := 1;
        REPEAT
            IF LSCTenderType.GET(LSCTransPaymentEntry."Store No.", LSCTransPaymentEntry."Tender Type") THEN BEGIN
                Data += STRSUBSTNO('&tender_code_%1=%2&', Counter, LSCTenderType.Code) +
                        STRSUBSTNO('tender_desc_%1=%2&', Counter, LSCTenderType.Description) +
                        STRSUBSTNO('tender_amount_%1=%2', Counter, FORMAT(LSCTransPaymentEntry."Amount Tendered", 0, 1));
                Counter += 1;
            END;
        UNTIL LSCTransPaymentEntry.NEXT = 0;
        Data := Data.Replace(' ', '%20');
        IF AVGHttpFunctions.ProcessLoyaltyHttpWebRequest(LSCPOSTerminal."Loyalty Url", Data) THEN begin
            InsertIntoLoyaltyTransLine(13, LoyaltyTransLineEntry."Loyalty Card Number", '', '');
            exit(True);
        end;
        EXIT(false);
    end;

    local procedure CreateMD5(pString: Text): Text
    var
        MD5: DotNet MD5;
        Encoding: DotNet Encoding;
        HashBytes: DotNet Array;
        StringBuilder: DotNet StringBuilder;
        Counter: Integer;
        NumArray: DotNet Byte;
    begin
        SelectLatestVersion();
        Clear(MD5);
        Clear(Encoding);
        Clear(HashBytes);
        Clear(StringBuilder);
        Clear(Counter);
        Clear(NumArray);
        MD5 := MD5.Create;
        HashBytes := MD5.ComputeHash(Encoding.UTF8.GetBytes(pString));
        StringBuilder := StringBuilder.StringBuilder;
        FOR Counter := 0 TO HashBytes.Length - 1 DO BEGIN
            NumArray := HashBytes.GetValue(Counter);
            StringBuilder.Append(NumArray.ToString('x2'));
        END;
        EXIT(StringBuilder.ToString);
    end;
}
