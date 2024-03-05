codeunit 50003 "AVG Event Subs. Trans."
{
    var
        LSCPOSControlInterface: Codeunit "LSC POS Control Interface";
        LSCPOSSession: Codeunit "LSC POS Session";
        LSCPOSGUI: Codeunit "LSC POS GUI";
        LSCPOSTransactionCU: Codeunit "LSC POS Transaction";
        AVGPOSSession: Codeunit "AVG POS Session";
        AVGFunctions: Codeunit "AVG Functions";
        AVGHttpFunctions: Codeunit "AVG Http Functions";
        AVGP2MIntegration: Codeunit "AVG P2M AllBank Integration";

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
                    InputValue := LSCPOSControlInterface.GetInputText(LSCPOSSession.POSNumpadInputID());
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
                    LSCPOSTransactionCU.OpenNumericKeyboard(MobileNoCaption, 0, '', 50101);
                    IsHandled := True;
                end;
            50101:
                begin
                    decLAmount := 0;
                    CLEAR(txtLAmount);
                    CLEAR(txtLMobile);
                    InputValue := LSCPOSControlInterface.GetInputText(LSCPOSSession.POSNumpadInputID());
                    IF InputValue = '' then
                        EXIT;

                    txtLMobile := InputValue;
                    IF STRLEN(txtLMobile) > 50 then BEGIN
                        LSCPOSTransactionCU.PosMessage(InvalidMobileNoCaption);
                        EXIT;
                    END;

                    AVGPOSSession.ClearCurrCashInMobileNo();
                    AVGPOSSession.SetCurrCashInMobileNo(txtLMobile);
                    txtLAmount := AVGPOSSession.GetCurrCashInAmount();
                    IF NOT EVALUATE(decLAmount, txtLAmount) then
                        EXIT;

                    AVGFunctions.ValidateAllEasy(1, decLAmount, txtLAmount, '', txtLMobile);
                    IsHandled := True;
                end;
            50102:
                begin
                    InputValue := LSCPOSControlInterface.GetInputText(LSCPOSSession.POSNumpadInputID());
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
                    LSCPOSGUI.OpenAlphabeticKeyboard(AllEasyScanQRCodeCaption, '', AVGPOSSession.GetHideKeybValues, '#PAYQR', 20);
                    IsHandled := True;
                end;
            50103:
                begin
                    InputValue := LSCPOSControlInterface.GetInputText(LSCPOSSession.POSNumpadInputID());
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
                    LSCPOSGUI.OpenAlphabeticKeyboard(GCashScanQRCodeCaption, '', AVGPOSSession.GetHideKeybValues, '#GCASHPAYQR', 64);
                    IsHandled := True;
                end;
            50104:
                begin
                    InputValue := LSCPOSControlInterface.GetInputText(LSCPOSSession.POSNumpadInputID());
                    IF InputValue = '' then
                        EXIT;
                    decLAmount := 0;
                    IF NOT EVALUATE(decLAmount, InputValue) then
                        exit;
                    CLEAR(txtLAmount);
                    txtLAmount := InputValue;
                    IF decLAmount = 0 then
                        EXIT;

                    AVGFunctions.ValidateLoyalty(14, '', txtLAmount);
                    IsHandled := True;
                end;
        // 50105:
        //     begin
        //         InputValue := LSCPOSControlInterface.GetInputText(LSCPOSSession.POSNumpadInputID());
        //         IF InputValue = '' then
        //             EXIT;

        //         AVGFunctions.ValidateLoyalty(15, InputValue, '');
        //         IsHandled := True;
        //     end;
        // 50106:
        //     begin
        //         InputValue := LSCPOSControlInterface.GetInputText(LSCPOSSession.POSNumpadInputID());
        //         IF InputValue = '' then
        //             EXIT;

        //         AVGFunctions.ValidateLoyalty(12, InputValue, '');
        //         IsHandled := True;
        //     end;
        END;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnAfterPostPOSTransaction, '', false, false)]
    local procedure OnAfterPostPOSTransaction(var POSTransaction: Record "LSC POS Transaction");
    begin
        AVGPOSSession.ClearAllValues();
        AVGHttpFunctions.ClearHttpVars();
        AVGHttpFunctions.ClearHttpVarsGCashQuery();
        LSCPOSSession.DeleteValue('LOYMEMBERCARD');
        LSCPOSSession.DeleteValue('LOYMEMBERNAME');
        AVGP2MIntegration.ClearP2MValues();
        AVGP2MIntegration.DeleteP2MRetailImage(POSTransaction."POS Terminal No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Post Utility", OnAfterPostTransaction, '', false, false)]
    local procedure OnAfterPostTransaction(var TransactionHeader_p: Record "LSC Transaction Header");
    var
        CardNo: Text;
        CardNoLast4: Text;
    begin
        CLEAR(CardNo);
        CLEAR(CardNoLast4);
        IF NOT AVGFunctions.CheckLoyalty(TransactionHeader_p, CardNo, CardNoLast4) then
            EXIT;
        IF AVGFunctions.LoyaltySendTransaction(TransactionHeader_p) THEN begin
            AVGFunctions.InsertIntoLoyaltyTransLineEntry(TransactionHeader_p, 13, CardNo, '', ''); // Earn
            IF AVGPOSSession.GetCurrLoyaltyCurrTenderType() <> '' THEN
                AVGFunctions.InsertIntoLoyaltyTransLineEntry(TransactionHeader_p, 14, CardNo, '', ''); // Redeem

        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Infocode Utility", OnAfterTypeSelection, '', false, false)]
    local procedure OnAfterTypeSelection(Input: Text; var SubCodeRec: Record "LSC Information Subcode"; var InfoCodeRec: Record "LSC Infocode"; var ErrorTxt: Text);
    var
        LSCPOSTerminaLocRec: Record "LSC POS Terminal";
    begin
        IF NOT LSCPOSTerminaLocRec.Get(LSCPOSSession.TerminalNo()) then
            EXIT;

        IF NOT LSCPOSTerminaLocRec."Enable GCash Pay" then
            EXIT;

        if LSCPOSTerminaLocRec."GCash Reason Code" = '' then
            EXIT;

        IF LSCPOSTerminaLocRec."GCash Reason Code" <> InfoCodeRec.Code then
            EXIT;

        AVGPOSSession.ClearCurrGCashSelectedInfocode();
        AVGPOSSession.SetCurrGCashSelectedInfocode(SubCodeRec.Description);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction", OnBeforePostTransaction, '', false, false)]
    local procedure OnBeforePostTransaction(var Rec: Record "LSC POS Transaction"; var IsHandled: Boolean);
    var
        AVGTransLine: Record "AVG Trans. Line";
        POSTerminalLoc: Record "LSC POS Terminal";
        AllEasyTriggerID: Integer;
    begin

        IF Rec."Entry Status" = Rec."Entry Status"::Voided then
            EXIT;

        IF NOT POSTerminalLoc.GET(Rec."POS Terminal No.") THEN
            EXIT;

        AVGTransLine.RESET;
        AVGTransLine.SetCurrentKey("Receipt No.", "Line No.");
        AVGTransLine.SETRANGE("Store No.", Rec."Store No.");
        AVGTransLine.SETRANGE("POS Terminal No.", Rec."POS Terminal No.");
        AVGTransLine.SETRANGE("Receipt No.", Rec."Receipt No.");
        IF AVGTransLine.FindFirst() THEN BEGIN
            AllEasyTriggerID := 0;
            case AVGTransLine."Process Type" of
                AVGTransLine."Process Type"::"Cash In Inquire":
                    AllEasyTriggerID := AVGTransLine."Process Type"::"Cash In Credit".AsInteger();
                AVGTransLine."Process Type"::"Cash Out Inquire":
                    AllEasyTriggerID := AVGTransLine."Process Type"::"Cash Out Process".AsInteger();
                AVGTransLine."Process Type"::"Pay QR Inquire":
                    AllEasyTriggerID := AVGTransLine."Process Type"::"Pay QR Process".AsInteger();
            end;
            IF AllEasyTriggerID <> 0 THEN
                IF NOT AVGFunctions.ValidateAllEasyApi(
                    AllEasyTriggerID,
                    AVGTransLine.Amount,
                    FORMAT(AVGTransLine.Amount),
                    AVGTransLine."Res. Cash In/Out Mobile No.",
                    AVGTransLine."Res. Cash Out Ref. No.",
                    POSTerminalLoc)
                then;
            // IsHandled := TRUE;
        END;
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
                        InputValue := LSCPOSControlInterface.GetInputText(LSCPOSSession.POSKeyboardInputID());
                        AVGFunctions.ValidateAllEasy(3, 0, '', InputValue, '');
                    END ELSE
                        LSCPOSTransactionCU.PosMessage(InvalidCashOutRefCaption);
                    IsHandled := True;
                end;
            '#PAYQR':
                begin
                    if ResultOK THEN BEGIN
                        InputValue := LSCPOSControlInterface.GetInputText(LSCPOSSession.POSKeyboardInputID());
                        AVGPOSSession.ClearCurrPayQRCode();
                        AVGPOSSession.SetCurrPayQRCode(InputValue);
                        AVGFunctions.ValidateAllEasy(5, 0, '', '', '');
                    END ELSE
                        LSCPOSTransactionCU.PosMessage(InvalidQRcodeCaption);
                    IsHandled := True;
                end;
            '#GCASHPAYQR':
                begin
                    if ResultOK THEN BEGIN
                        InputValue := LSCPOSControlInterface.GetInputText(LSCPOSSession.POSKeyboardInputID());
                        AVGPOSSession.ClearCurrGCashPayQRCode();
                        AVGPOSSession.SetCurrGCashPayQRCode(InputValue);
                        AVGFunctions.ValidateGCashApi(8);
                    END ELSE
                        LSCPOSTransactionCU.PosMessage(InvalidQRcodeCaption);
                    IsHandled := True;
                end;
            '#GCASHCANCEL':
                begin
                    if ResultOK THEN BEGIN
                        InputValue := LSCPOSControlInterface.GetInputText(LSCPOSSession.POSKeyboardInputID());
                        AVGPOSSession.ClearCurrGCashCancelAcqID();
                        AVGPOSSession.SetCurrGCashCancelAcqID(InputValue);
                        AVGFunctions.ValidateGCashApi(10);
                    END ELSE
                        LSCPOSTransactionCU.PosMessage(InvalidQRcodeCaption);
                    IsHandled := True;
                end;
            '#LOYCARDBAL':
                begin
                    if ResultOK then begin
                        InputValue := LSCPOSControlInterface.GetInputText(LSCPOSSession.POSKeyboardInputID());
                        AVGFunctions.ValidateLoyalty(15, InputValue, '');
                    end;
                    IsHandled := True;
                end;
            '#LOYCARDMEMBER':
                begin
                    if ResultOK then begin
                        InputValue := LSCPOSControlInterface.GetInputText(LSCPOSSession.POSKeyboardInputID());
                        AVGFunctions.ValidateLoyalty(12, InputValue, '');
                    end;
                    IsHandled := True;
                end;
        END;
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnVoidLine, '', false, false)]
    local procedure OnVoidLineGCash(var POSTransLine: Record "LSC POS Trans. Line"; var IsHandled: Boolean);
    var
        GCashTransLine: Record "AVG Trans. Line";
    begin
        GCashTransLine.Reset();
        GCashTransLine.SetRange("Receipt No.", POSTransLine."Receipt No.");
        GCashTransLine.Setrange("Process Type", GCashTransLine."Process Type"::"Retail Pay");
        IF GCashTransLine.FindFirst() then begin
            AVGPOSSession.ClearCurrGCashCancelAcqID();
            AVGPOSSession.SetCurrGCashCancelAcqID(GCashTransLine."GCash Acquirement ID");
            IF AVGFunctions.ValidateGCashApi(10) then
                AVGHttpFunctions.InsertIntoGCashTransLine(10, GCashTransLine."GCash Acquirement ID", 0, POSTransLine."Line No.");
        end;
    end;

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
                IF AVGFunctions.ValidateGCashApi(10) then
                    AVGHttpFunctions.InsertIntoGCashTransLine(10, GCashTransLine."GCash Acquirement ID", 0, POSTransLine."Line No.");
            UNTIL GCashTransLine.next = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnVoidTransaction, '', false, false)]
    local procedure OnVoidTransactionLoyalty(var POSTrans: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line");
    var
        LoyaltyTransLine: Record "AVG Trans. Line";
    begin
        LoyaltyTransLine.Reset();
        LoyaltyTransLine.SetRange("Receipt No.", POSTrans."Receipt No.");
        IF LoyaltyTransLine.FindFirst() then
            IF LoyaltyTransLine."Process Type" IN [
                LoyaltyTransLine."Process Type"::"Loyalty Add Member",
                LoyaltyTransLine."Process Type"::"Loyalty Earn Points",
                LoyaltyTransLine."Process Type"::"Loyalty Redeem Points"]
            THEN
                LoyaltyTransLine.DeleteAll();
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
        IF AVGTransLine.FindSet() THEN BEGIN
            repeat
                AVGTransLineEntry.INIT;
                AVGTransLineEntry.TransferFields(AVGTransLine);
                AVGTransLineEntry."Transaction No." := TransactionHeader."Transaction No.";
                IF AVGTransLineEntry.INSERT then
                    AVGTransLine.Delete();
            UNTIL AVGTransLine.Next() = 0;
        END;
    END;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnAfterInsertPaymentLine, '', false, false)]
    local procedure OnAfterInsertPaymentLine(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var TenderTypeCode: Code[10]; var SkipCommit: Boolean);
    var
        LSCPOSTerminalRec: Record "LSC POS Terminal";
    begin
        IF NOT LSCPOSTerminalRec.Get(POSTransaction."POS Terminal No.") then
            EXIT;

        IF NOT LSCPOSTerminalRec."Enable GCash Pay" then
            EXIT;

        if TenderTypeCode <> LSCPOSTerminalRec."GCash Tender Type" then
            EXIT;
        IF NOT POSTransaction."Sale Is Return Sale" THEN
            AVGHttpFunctions.InsertIntoGCashTransLine(8, AVGPOSSession.GetCurrGCashPayQRCode(), POSTransLine.Amount, POSTransLine."Line No.")
        ELSE
            AVGHttpFunctions.InsertIntoGCashTransLine(11, '', POSTransLine.Amount, POSTransLine."Line No.")
    end;

}
