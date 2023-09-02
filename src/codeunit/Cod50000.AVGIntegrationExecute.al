codeunit 50000 "AVG Integration Execute"
{
    SingleInstance = true;
    TableNo = "LSC POS Menu Line";

    var
        GlobalRec: Record "LSC POS Menu Line";
        Store: Record "LSC Store";
        POSTerminal: Record "LSC POS Terminal";
        FunctionalityProfile: Record "LSC POS Func. Profile";
        POSTransactionCU: Codeunit "LSC POS Transaction";
        POSGui: Codeunit "LSC POS GUI";
        POSSession: Codeunit "LSC POS Session";
        AVGFunctions: Codeunit "AVG Functions";
        CashInAmountMsg: Label 'Cash In Amount';
        CashOutRefNoMsg: Label 'Cash Out Reference No.';
        PayQRCodeAmountMsg: Label 'Pay QR Amount';

    trigger OnRun()
    begin
        GlobalRec := Rec;
        POSTerminal.GET(POSSession.TerminalNo());
        Store.GET(POSTerminal."Store No.");
        FunctionalityProfile.GET(POSSession.FunctionalityProfileID());
        CASE Rec.Command of
            'ALLEASYCASHIN':
                AllEasyCashInEx;
            'ALLEASYCASHOUT':
                AllEasyCashOutEx;
            'ALLEASYPAYQR':
                AllEasyPayQREx;
        // 'GCASHPAY':
        // 'GCASHCANCEL':
        // 'GCASHREFUND':
        END;
        Rec := GlobalRec;
    end;

    local procedure AllEasyCashInEx()
    begin
        IF not AVGFunctions.InitializeAllEasy(1, POSTerminal) then
            EXIT;

        POSTransactionCU.OpenNumericKeyboard(CashInAmountMsg, 0, '', 50100);
        EXIT;
    end;

    local procedure AllEasyCashOutEx()
    begin
        IF not AVGFunctions.InitializeAllEasy(3, POSTerminal) then
            EXIT;

        POSGui.OpenAlphabeticKeyboard(CashOutRefNoMsg, '', FALSE, '#CASHOUTREFNO', 50);
        EXIT;
    end;

    local procedure AllEasyPayQREx()
    begin
        IF not AVGFunctions.InitializeAllEasy(5, POSTerminal) then
            EXIT;

        POSTransactionCU.OpenNumericKeyboard(PayQRCodeAmountMsg, 0, '', 50102);
        EXIT;
    end;
}
