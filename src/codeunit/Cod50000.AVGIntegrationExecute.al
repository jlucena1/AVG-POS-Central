codeunit 50000 "AVG Integration Execute"
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
        AVGFunctions: Codeunit "AVG Functions";
        CashInAmountMsg: Label 'Cash In Amount';
        CashOutRefNoMsg: Label 'Cash Out Reference No.';
        PayQRCodeAmountMsg: Label 'Pay QR Amount';
        GCashAmountMsg: Label 'GCash Amount';
        GCashCancelAcqID: Label 'GCash Cancel Aqcuirement ID';

    trigger OnRun()
    begin

        LSCGlobalRec := Rec;
        LSCPOSTerminal.GET(LSCPOSSession.TerminalNo());
        LSCStore.GET(LSCPOSTerminal."Store No.");
        LSCFunctionalityProfile.GET(LSCPOSSession.FunctionalityProfileID());
        IF LSCPOSTransLineRec.GET(LSCGlobalRec."Current-RECEIPT", LSCGlobalRec."Current-LINE") THEN;
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

        LSCPOSGui.OpenAlphabeticKeyboard(CashOutRefNoMsg, '', FALSE, '#CASHOUTREFNO', 50);
        EXIT;
    end;

    local procedure AllEasyPayQREx()
    begin
        IF not AVGFunctions.InitializeAllEasy(5, LSCPOSTerminal) then
            EXIT;

        POSTransactionCU.OpenNumericKeyboard(PayQRCodeAmountMsg, 0, '', 50102);
        EXIT;
    end;

    local procedure GCashHeartBeatCheckEx()
    begin
        IF NOT AVGFunctions.InitializeGCash(7, LSCPOSTerminal, LSCGlobalRec) then
            EXIT;

        AVGFunctions.GCashHeartBeatCheck(LSCPOSTerminal);
    end;

    local procedure GCashPayEx()
    begin
        IF NOT AVGFunctions.InitializeGCash(8, LSCPOSTerminal, LSCGlobalRec) then
            EXIT;

        POSTransactionCU.OpenNumericKeyboard(GCashAmountMsg, 0, '', 50103);
        EXIT;

    end;

    local procedure GCashQueryEx()
    begin
        IF NOT AVGFunctions.InitializeGCash(9, LSCPOSTerminal, LSCGlobalRec) then
            EXIT;
        // AVGFunctions.GCashHeartBeatCheck(POSTerminal);
    end;

    local procedure GCashCancelEx()
    begin
        IF NOT AVGFunctions.InitializeGCash(10, LSCPOSTerminal, LSCGlobalRec) then
            EXIT;

        LSCPOSGui.OpenAlphabeticKeyboard(GCashCancelAcqID, '', FALSE, '#GCASHCANCEL', 64);
        EXIT;
    end;

    local procedure GCashRefundEx()
    begin
        IF NOT AVGFunctions.InitializeGCash(11, LSCPOSTerminal, LSCGlobalRec) then
            EXIT;
        // AVGFunctions.GCashHeartBeatCheck(POSTerminal);
    end;

}
