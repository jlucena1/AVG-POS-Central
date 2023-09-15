codeunit 50003 "AVG Event Subs. Trans."
{
    var
        POSControlInteface: Codeunit "LSC POS Control Interface";
        POSSession: Codeunit "LSC POS Session";
        POSGUI: Codeunit "LSC POS GUI";
        POSTransactionCU: Codeunit "LSC POS Transaction";
        AVGPOSSession: Codeunit "AVG POS Session";
        AVGFunctions: Codeunit "AVG Functions";
        AVGHttpFunctions: Codeunit "AVG Http Functions";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction", OnAfterKeyboardTriggerToProcess, '', false, false)]
    local procedure OnAfterKeyboardTriggerToProcess(InputValue: Text; KeyboardTriggerToProcess: Integer; var Rec: Record "LSC POS Transaction"; var IsHandled: Boolean);
    var
        NumpadProcess: Integer;
        decLAmount: Decimal;
        txtLAmount: Text;
        txtLMobile: Text;
        MobileNoCaption: Label 'Enter Mobile No.';
        InvalidMobileNoCaption: Label 'Invalid Mobile No.';
        AllEasyScanQRCodeCaption: Label 'AllEasy Pay QR Code:';
        GCashScanQRCodeCaption: Label 'GCash Pay QR Code:';
    begin
        NumpadProcess := 0;
        InputValue := '';
        IsHandled := FALSE;
        NumpadProcess := KeyboardTriggerToProcess;
        CASE NumpadProcess of
            50100:
                begin
                    InputValue := POSControlInteface.GetInputText(POSSession.POSNumpadInputID());
                    IF InputValue = '' then
                        EXIT;
                    decLAmount := 0;
                    IF NOT EVALUATE(decLAmount, InputValue) then
                        exit;
                    CLEAR(txtLAmount);
                    txtLAmount := InputValue;
                    IF decLAmount = 0 then
                        EXIT;
                    AVGPOSSession.ClearCurrCashInMobileNo();
                    AVGPOSSession.SetCurrCashInAmount(txtLAmount);
                    POSTransactionCU.OpenNumericKeyboard(MobileNoCaption, 0, '', 50101);
                end;
            50101:
                begin
                    decLAmount := 0;
                    CLEAR(txtLAmount);
                    CLEAR(txtLMobile);
                    InputValue := POSControlInteface.GetInputText(POSSession.POSNumpadInputID());
                    IF InputValue = '' then
                        EXIT;

                    txtLMobile := InputValue;
                    IF STRLEN(txtLMobile) > 50 then BEGIN
                        POSTransactionCU.PosMessage(InvalidMobileNoCaption);
                        EXIT;
                    END;

                    AVGPOSSession.ClearCurrCashInMobileNo();
                    AVGPOSSession.SetCurrCashInMobileNo(txtLMobile);
                    txtLAmount := AVGPOSSession.GetCurrCashInAmount();
                    IF NOT EVALUATE(decLAmount, txtLAmount) then
                        EXIT;

                    AVGFunctions.ValidateAllEasy(1, decLAmount, txtLAmount, '', txtLMobile);
                end;
            50102:
                begin
                    InputValue := POSControlInteface.GetInputText(POSSession.POSNumpadInputID());
                    IF InputValue = '' then
                        EXIT;
                    decLAmount := 0;
                    IF NOT EVALUATE(decLAmount, InputValue) then
                        exit;
                    CLEAR(txtLAmount);
                    txtLAmount := InputValue;
                    IF decLAmount = 0 then
                        EXIT;
                    AVGPOSSession.ClearCurrPayQRAmount();
                    AVGPOSSession.SetCurrPayQRAmount(txtLAmount);
                    POSGui.OpenAlphabeticKeyboard(AllEasyScanQRCodeCaption, '', FALSE, '#PAYQR', 20);
                end;
            50103:
                begin
                    InputValue := POSControlInteface.GetInputText(POSSession.POSNumpadInputID());
                    IF InputValue = '' then
                        EXIT;
                    decLAmount := 0;
                    IF NOT EVALUATE(decLAmount, InputValue) then
                        exit;
                    CLEAR(txtLAmount);
                    txtLAmount := InputValue;
                    IF decLAmount = 0 then
                        EXIT;
                    AVGPOSSession.ClearCurrGCashPayQRAmount();
                    AVGPOSSession.SetGCashCurrPayQRAmount(txtLAmount);
                    POSGui.OpenAlphabeticKeyboard(GCashScanQRCodeCaption, '', FALSE, '#GCASHPAYQR', 64);
                end;
        END;
        IsHandled := True;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction", OnBeforeProcessKeyBoardResult, '', false, false)]
    local procedure OnBeforeProcessKeyBoardResult(Payload: Text; InputValue: Text; ResultOK: Boolean; var IsHandled: Boolean);
    var
        InvalidCashOutRefCaption: Label 'Invalid Reference No.\Please Try Again.';
        InvalidQRcodeCaption: Label 'Invalid QR Code.\Please Try Again.';
    begin
        CASE Payload of
            '#CASHOUTREFNO':
                begin
                    IF ResultOK THEN BEGIN
                        InputValue := POSControlInteface.GetInputText(POSSession.POSKeyboardInputID());
                        AVGFunctions.ValidateAllEasy(3, 0, '', InputValue, '');
                    END ELSE
                        POSTransactionCU.PosMessage(InvalidCashOutRefCaption);
                end;
            '#PAYQR':
                begin
                    if ResultOK THEN BEGIN
                        InputValue := POSControlInteface.GetInputText(POSSession.POSKeyboardInputID());
                        AVGPOSSession.ClearCurrPayQRCode();
                        AVGPOSSession.SetCurrPayQRCode(InputValue);
                        AVGFunctions.ValidateAllEasy(5, 0, '', '', '');
                    END ELSE
                        POSTransactionCU.PosMessage(InvalidQRcodeCaption);
                end;
            '#GCASHPAYQR':
                begin
                    if ResultOK THEN BEGIN
                        InputValue := POSControlInteface.GetInputText(POSSession.POSKeyboardInputID());
                        AVGPOSSession.ClearCurrGCashPayQRCode();
                        AVGPOSSession.SetCurrGCashPayQRCode(InputValue);
                        AVGFunctions.ValidateGCashApi(8);
                    END ELSE
                        POSTransactionCU.PosMessage(InvalidQRcodeCaption);
                end;
            '#GCASHCANCEL':
                begin
                    if ResultOK THEN BEGIN
                        InputValue := POSControlInteface.GetInputText(POSSession.POSKeyboardInputID());
                        AVGPOSSession.ClearCurrGCashCancelAcqID();
                        AVGPOSSession.SetCurrGCashCancelAcqID(InputValue);
                        AVGFunctions.ValidateGCashApi(10);
                    END ELSE
                        POSTransactionCU.PosMessage(InvalidQRcodeCaption);
                end;
        END;
        IsHandled := True;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction", OnBeforePostTransaction, '', false, false)]
    local procedure OnBeforePostTransaction(var Rec: Record "LSC POS Transaction"; var IsHandled: Boolean);
    var
        AllEasyTransLine: Record "AVG Trans. Line";
        POSTerminalLoc: Record "LSC POS Terminal";
        intLTriggerID: Integer;
    begin

        IF Rec."Entry Status" = Rec."Entry Status"::Voided then
            EXIT;

        IF NOT POSTerminalLoc.GET(Rec."POS Terminal No.") THEN
            EXIT;

        AllEasyTransLine.RESET;
        AllEasyTransLine.SetCurrentKey("Receipt No.", "Line No.");
        AllEasyTransLine.SETRANGE("Store No.", Rec."Store No.");
        AllEasyTransLine.SETRANGE("POS Terminal No.", Rec."POS Terminal No.");
        AllEasyTransLine.SETRANGE("Receipt No.", Rec."Receipt No.");
        IF AllEasyTransLine.FindFirst() THEN BEGIN
            intLTriggerID := 0;
            case AllEasyTransLine."Process Type" of
                AllEasyTransLine."Process Type"::"Cash In Inquire":
                    intLTriggerID := AllEasyTransLine."Process Type"::"Cash In Credit".AsInteger();
                AllEasyTransLine."Process Type"::"Cash Out Inquire":
                    intLTriggerID := AllEasyTransLine."Process Type"::"Cash Out Process".AsInteger();
                AllEasyTransLine."Process Type"::"Pay QR Inquire":
                    intLTriggerID := AllEasyTransLine."Process Type"::"Pay QR Process".AsInteger();
            end;
            IF intLTriggerID <> 0 THEN
                IF NOT AVGFunctions.ValidateAllEasyApi(
                    intLTriggerID,
                    AllEasyTransLine.Amount,
                    FORMAT(AllEasyTransLine.Amount),
                    AllEasyTransLine."Res. Cash In/Out Mobile No.",
                    AllEasyTransLine."Res. Cash Out Ref. No.",
                    POSTerminalLoc)
                then
                    IsHandled := TRUE;
        END;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnAfterPostPOSTransaction, '', false, false)]
    local procedure OnAfterPostPOSTransaction(var POSTransaction: Record "LSC POS Transaction");
    begin
        AVGPOSSession.ClearCurrAuthToken();
        AVGPOSSession.ClearCurrCashInAmount();
        AVGPOSSession.ClearCurrCashInMobileNo();
        AVGPOSSession.ClearCurrPartnerRefNo();
        AVGPOSSession.ClearCurrPayQRAmount();
        AVGPOSSession.ClearCurrPayQRCode();
        AVGHttpFunctions.ClearHttpVars();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Post Utility", OnWriteTransactionToDatabase, '', false, false)]
    local procedure OnWriteTransactionToDatabase(var TransactionHeader: Record "LSC Transaction Header");
    var
        AVGTransLine: Record "AVG Trans. Line";
        AVGTransLineEntry: Record "AVG Trans. Line Entry";
    begin
        AVGTransLine.RESET;
        AVGTransLine.SetCurrentKey("Receipt No.", "Line No.");
        AVGTransLine.SETRANGE("Store No.", TransactionHeader."Store No.");
        AVGTransLine.SETRANGE("POS Terminal No.", TransactionHeader."POS Terminal No.");
        AVGTransLine.SETRANGE("Receipt No.", TransactionHeader."Receipt No.");
        IF AVGTransLine.FindSet() THEN
            repeat
                AVGTransLineEntry.INIT;
                AVGTransLineEntry.TransferFields(AVGTransLine);
                AVGTransLineEntry."Transaction No." := TransactionHeader."Transaction No.";
                IF AVGTransLineEntry.INSERT then
                    AVGTransLine.Delete();
            UNTIL AVGTransLine.Next() = 0;
    END;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnVoidTransaction, '', false, false)]
    local procedure OnVoidTransactionAllEasy(var POSTrans: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line");
    var
        AllEasyTransLine: Record "AVG Trans. Line";
    begin
        AllEasyTransLine.Reset();
        AllEasyTransLine.SetRange("Receipt No.", POSTrans."Receipt No.");
        IF AllEasyTransLine.FindFirst() then
            IF AllEasyTransLine."Process Type" IN [
                AllEasyTransLine."Process Type"::"Cash In Inquire",
                AllEasyTransLine."Process Type"::"Cash In Credit",
                AllEasyTransLine."Process Type"::"Cash Out Process",
                AllEasyTransLine."Process Type"::"Cash Out Inquire",
                AllEasyTransLine."Process Type"::"Pay QR Inquire",
                AllEasyTransLine."Process Type"::"Pay QR Process"]
            THEN
                AllEasyTransLine.DeleteAll();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnVoidLine, '', false, false)]
    local procedure OnVoidLineAllEasy(var POSTransLine: Record "LSC POS Trans. Line"; var IsHandled: Boolean);
    var
        AllEasyTransLine: Record "AVG Trans. Line";

    begin
        AllEasyTransLine.Reset();
        AllEasyTransLine.SetRange("Receipt No.", POSTransLine."Receipt No.");
        AllEasyTransLine.SetRange("Trans. Line No.", POSTransLine."Line No.");
        IF AllEasyTransLine.FindFirst() then
            IF AllEasyTransLine."Process Type" IN [
                    AllEasyTransLine."Process Type"::"Cash In Inquire",
                    AllEasyTransLine."Process Type"::"Cash Out Inquire",
                    AllEasyTransLine."Process Type"::"Pay QR Inquire"]
            THEN
                AllEasyTransLine.Delete();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnVoidTransaction, '', false, false)]
    local procedure OnVoidTransactionGCash(var POSTrans: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line");
    var
        GCashTransLine: Record "AVG Trans. Line";
    begin
        GCashTransLine.Reset();
        GCashTransLine.SetRange("Receipt No.", POSTrans."Receipt No.");
        GCashTransLine.Setrange("Process Type", GCashTransLine."Process Type"::"Retail Pay");
        IF GCashTransLine.FindFirst() then
            repeat
                AVGPOSSession.ClearCurrGCashCancelAcqID();
                AVGPOSSession.SetCurrGCashCancelAcqID(GCashTransLine."GCash Acquirement ID");
                AVGFunctions.ValidateGCashApi(10);
            UNTIL GCashTransLine.next = 0;

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnVoidLine, '', false, false)]
    local procedure OnVoidLineGCash(var POSTransLine: Record "LSC POS Trans. Line"; var IsHandled: Boolean);
    var
        GCashTransLine: Record "AVG Trans. Line";
    begin
        GCashTransLine.Reset();
        GCashTransLine.SetRange("Receipt No.", POSTransLine."Receipt No.");
        GCashTransLine.SetRange("Trans. Line No.", POSTransLine."Line No.");
        GCashTransLine.Setrange("Process Type", GCashTransLine."Process Type"::"Retail Pay");
        IF GCashTransLine.FindFirst() then begin
            AVGPOSSession.ClearCurrGCashCancelAcqID();
            AVGPOSSession.SetCurrGCashCancelAcqID(GCashTransLine."GCash Acquirement ID");
            AVGFunctions.ValidateGCashApi(10);
        end;
    end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnAfterVoidPostedTransaction, '', false, false)]
    // local procedure OnAfterVoidPostedTransaction(var Rec: Record "LSC POS Transaction");
    // var
    //     GCashTransLineEntry: Record "AVG Trans. Line Entry"
    //     TxtAmount: Text;
    // begin
    //     LSCPOSTransLineLoc.RESET;
    //     LSCPOSTransLineLoc.SETRANGE("Receipt No.", Rec."Receipt No.");
    //     LSCPOSTransLineLoc.SETRANGE("Entry Type", LSCPOSTransLineLoc."Entry Type"::Payment);
    //     IF NOT LSCPOSTransLineLoc.FINDFIRST then
    //         EXIT;
    //     CLEAR(TxtAmount);
    //     TxtAmount := FORMAT(LSCPOSTransLineLoc.Amount);
    //     AVGPOSSession.ClearCurrGCashRefundAmount();
    //     AVGPOSSession.SetCurrGCashRefundAmount(TxtAmount);
    //     AVGFunctions.ValidateGCashApi(11);
    // end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Refund Mgt.", OnAfterInfocodePosTransLineBufferInsert, '', false, false)]
    local procedure OnAfterInfocodePosTransLineBufferInsert(var POSTransLineBuffer: Record "LSC POS Trans. Line");
    var
        GCashTransLineEntry: Record "AVG Trans. Line Entry";
        TxtAmount: Text;
    begin
        GCashTransLineEntry.RESET;
        GCashTransLineEntry.SETRANGE("Store No.", POSTransLineBuffer."Orig. Trans. Store");
        GCashTransLineEntry.SETRANGE("POS Terminal No.", POSTransLineBuffer."Orig. Trans. Pos");
        GCashTransLineEntry.SETRANGE("Transaction No.", POSTransLineBuffer."Orig. Trans. No.");
        GCashTransLineEntry.SETRANGE("Process Type", GCashTransLineEntry."Process Type"::"Retail Pay");
        IF NOT GCashTransLineEntry.FINDFIRST then
            EXIT;

        CLEAR(TxtAmount);
        TxtAmount := FORMAT(GCashTransLineEntry."GCash Amount");
        AVGPOSSession.ClearCurrGCashRefundAmount();
        AVGPOSSession.SetCurrGCashRefundAmount(TxtAmount);
        AVGPOSSession.ClearCurrGCashRefundAcqID();
        AVGPOSSession.SetCurrGCashCancelAcqID(GCashTransLineEntry."GCash Acquirement ID");
        AVGFunctions.ValidateGCashApi(11);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Infocode Utility", OnAfterTypeSelection, '', false, false)]
    local procedure OnAfterTypeSelection(Input: Text; var SubCodeRec: Record "LSC Information Subcode"; var InfoCodeRec: Record "LSC Infocode"; var ErrorTxt: Text);
    begin
        AVGPOSSession.ClearCurrGCashSelectedInfocode();
        AVGPOSSession.SetCurrGCashSelectedInfocode(SubCodeRec.Description);
    end;

}
