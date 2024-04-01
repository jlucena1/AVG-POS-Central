codeunit 50000 "AVG External Commands"
{
    SingleInstance = true;
    TableNo = "LSC POS Menu Line";

    var

        LSCGlobalRec: Record "LSC POS Menu Line";
        LSCStore: Record "LSC Store";
        LSCPOSTerminal: Record "LSC POS Terminal";
        LSCFunctionalityProfile: Record "LSC POS Func. Profile";
        LSCPOSTransLineRec: Record "LSC POS Trans. Line";
        POSTransactionCU: Codeunit "LSC POS Transaction";
        LSCPOSGui: Codeunit "LSC POS GUI";
        LSCPOSSession: Codeunit "LSC POS Session";
        AVGPOSSession: Codeunit "AVG POS Session";
        AVGFunctions: Codeunit "AVG Functions";
        CashInAmountMsg: Label 'Cash In Amount';
        CashOutRefNoMsg: Label 'Cash Out Reference No.';
        PayQRCodeAmountMsg: Label 'Pay QR Amount';
        GCashAmountMsg: Label 'GCash Amount';
        GCashCancelAcqID: Label 'GCash Cancel Aqcuirement ID';
        LoyaltyMemberCard: Label 'Loyalty Member Card Number';
        LoyaltyAmountToRedeem: Label 'Amount to Redeem';
    // MIGHT USE LATER - BEGIN
    // SecurityProtocolType: DotNet SecurityProtocolType;
    // ServicePointManagerY: DotNet ServicePointManager;
    // MIGHT USE LATER - END
    trigger OnRun()
    begin

        LSCGlobalRec := Rec;
        LSCPOSTerminal.GET(LSCPOSSession.TerminalNo());
        LSCStore.GET(LSCPOSTerminal."Store No.");
        LSCFunctionalityProfile.GET(LSCPOSSession.FunctionalityProfileID());
        IF LSCPOSTransLineRec.GET(LSCGlobalRec."Current-RECEIPT", LSCGlobalRec."Current-LINE") THEN;
        AVGFunctions.SetGlobalLSCPOSMenuLine(LSCGlobalRec);
        // MIGHT USE LATER - BEGIN
        // ServicePointManagerY.Expect100Continue(TRUE);
        // ServicePointManagerY.SecurityProtocol(SecurityProtocolType.Tls);
        // ServicePointManagerY.SecurityProtocol(SecurityProtocolType.Tls11);
        // ServicePointManagerY.SecurityProtocol(SecurityProtocolType.Tls12);
        // ServicePointManagerY.SecurityProtocol(SecurityProtocolType.Tls13);
        // MIGHT USE LATER - END
        CASE Rec.Command of
            'ALLEASYCASHIN':
                AllEasyCashInEx();
            'ALLEASYCASHOUT':
                AllEasyCashOutEx();
            'ALLEASYPAYQR':
                AllEasyPayQREx();
            'GCASHCHECK':
                GCashHeartBeatCheckEx();
            'GCASHPAY':
                GCashPayEx();
            'GCASHCANCEL':
                GCashCancelEx();
            'GCASHREFUND':
                GCashRefundEx();
            'LOYBALINQ':
                LoyaltyBalanceInquiryEx();
            'LOYADDMEMBER':
                LoyaltyMemberEx();
            'LOYPOINTS':
                LoyaltyPointsEx(Rec.Parameter);
        END;
        Rec := LSCGlobalRec;
    end;

    local procedure AllEasyCashInEx()
    begin
        IF not AVGFunctions.InitializeAllEasy(1, LSCPOSTerminal) then
            EXIT;

        POSTransactionCU.OpenNumericKeyboard(CashInAmountMsg, 0, '', 50100);
        EXIT;
    end;

    local procedure AllEasyCashOutEx()
    begin
        IF not AVGFunctions.InitializeAllEasy(3, LSCPOSTerminal) then
            EXIT;

        LSCPOSGui.OpenAlphabeticKeyboard(CashOutRefNoMsg, '', AVGPOSSession.GetHideKeybValues, '#CASHOUTREFNO', 50);
        EXIT;
    end;

    local procedure AllEasyPayQREx()
    begin
        IF not AVGFunctions.InitializeAllEasy(5, LSCPOSTerminal) then
            EXIT;

        POSTransactionCU.OpenNumericKeyboard(PayQRCodeAmountMsg, 0, '', 50102);
        EXIT;
    end;

    local procedure GCashCancelEx()
    begin
        IF NOT AVGFunctions.InitializeGCash(10, LSCPOSTerminal) then
            EXIT;

        LSCPOSGui.OpenAlphabeticKeyboard(GCashCancelAcqID, '', AVGPOSSession.GetHideKeybValues, '#GCASHCANCEL', 64);
        EXIT;
    end;

    local procedure GCashHeartBeatCheckEx()
    begin
        IF NOT AVGFunctions.InitializeGCash(7, LSCPOSTerminal) then
            EXIT;

        AVGFunctions.GCashHeartBeatCheck(LSCPOSTerminal);
    end;

    local procedure GCashPayEx()
    begin
        IF NOT AVGFunctions.InitializeGCash(8, LSCPOSTerminal) then
            EXIT;

        POSTransactionCU.OpenNumericKeyboard(GCashAmountMsg, 0, '', 50103);
        EXIT;
    end;

    local procedure GCashQueryEx()
    begin
        IF NOT AVGFunctions.InitializeGCash(9, LSCPOSTerminal) then
            EXIT;
    end;

    local procedure GCashRefundEx()
    begin
        IF NOT AVGFunctions.ValidateGCashApi(11) then
            EXIT;
    end;

    local procedure LoyaltyBalanceInquiryEx()
    begin
        // POSTransactionCU.OpenNumericKeyboard(LoyaltyAmountToRedeem, 0, '', 50105);
        // EXIT;
        LSCPOSGui.OpenAlphabeticKeyboard(LoyaltyMemberCard, '', AVGPOSSession.GetHideKeybValues, '#LOYCARDBAL', 16);
        EXIT;
    end;

    local procedure LoyaltyMemberEx()
    begin
        // POSTransactionCU.OpenNumericKeyboard(LoyaltyAmountToRedeem, 0, '', 50106);
        // EXIT;
        LSCPOSGui.OpenAlphabeticKeyboard(LoyaltyMemberCard, '', AVGPOSSession.GetHideKeybValues, '#LOYCARDMEMBER', 16);
        EXIT;
    end;

    local procedure LoyaltyPointsEx(Parameter: Text)
    begin
        AVGPOSSession.ClearLoyaltyCurrTenderType();
        AVGPOSSession.SetCurrLoyaltyCurrTenderType(Parameter);
        POSTransactionCU.OpenNumericKeyboard(LoyaltyAmountToRedeem, 0, '', 50104);
        EXIT;
    end;


}
