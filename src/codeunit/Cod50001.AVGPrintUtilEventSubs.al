codeunit 50001 "AVG Print Util Event Subs."
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", OnBeforePrintSubHeader, '', false, false)]
    local procedure OnBeforePrintSubHeader(var Sender: Codeunit "LSC POS Print Utility"; var TransactionHeader: Record "LSC Transaction Header"; Tray: Integer; var POSPrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer; var IsHandled: Boolean);
    var
        txtLValue: array[10] of Text;
        txtLDesign: Text;
        AllEasyTransLineEntry: Record "AllEasy Trans. Line Entry";
        AllEasyTypeTransLine: Enum "AllEasy Type Trans. Line";
        CashOutReceiptMsg: Label 'CASH OUT RECEIPT';
        AcknowledgementReceiptMsg: Label 'ACKNOWLEDGEMENT RECEIPT';
    begin
        AllEasyTransLineEntry.RESET;
        AllEasyTransLineEntry.SETRANGE("Store No.", TransactionHeader."Store No.");
        AllEasyTransLineEntry.SETRANGE("POS Terminal No.", TransactionHeader."POS Terminal No.");
        AllEasyTransLineEntry.SETRANGE("Transaction No.", TransactionHeader."Transaction No.");
        AllEasyTransLineEntry.SETFILTER("AllEasy Process Type", '%1|%2', AllEasyTransLineEntry."AllEasy Process Type"::"Cash In Credit", AllEasyTransLineEntry."AllEasy Process Type"::"Cash Out Process");
        IF NOT AllEasyTransLineEntry.FindFirst() then
            EXIT;

        CLEAR(txtLValue);
        txtLDesign := '#C######################################';
        AllEasyTypeTransLine := "AllEasy Type Trans. Line".FromInteger(AllEasyTransLineEntry."AllEasy Process Type".AsInteger());
        case AllEasyTypeTransLine of
            AllEasyTypeTransLine::"Cash Out Process":
                txtLValue[1] := CashOutReceiptMsg;
            AllEasyTypeTransLine::"Cash In Credit":
                txtLValue[1] := AcknowledgementReceiptMsg;
        END;
        Sender.PrintSeperator();
        Sender.PrintLine(Sender.FormatLine(Sender.FormatStr(txtLValue, txtLDesign), false, TRUE, FALSE, false));
        Sender.PrintSeperator();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", OnBeforeIncExpAccDescription, '', false, false)]
    local procedure OnBeforeIncExpAccDescription(var IncomeExpenseAccount: Record "LSC Income/Expense Account"; var TransIncomeExpenseEntry: Record "LSC Trans. Inc./Exp. Entry");
    var
        AllEasyTransLineEntry: Record "AllEasy Trans. Line Entry";
        AllEasyTypeTransLine: Enum "AllEasy Type Trans. Line";
        txtLRefNo: Text;
        RefNoMsg: Label ' Ref. No.: %1';
    begin
        CLEAR(txtLRefNo);
        AllEasyTransLineEntry.RESET;
        AllEasyTransLineEntry.SETRANGE("Store No.", TransIncomeExpenseEntry."Store No.");
        AllEasyTransLineEntry.SETRANGE("POS Terminal No.", TransIncomeExpenseEntry."POS Terminal No.");
        AllEasyTransLineEntry.SETRANGE("Transaction No.", TransIncomeExpenseEntry."Transaction No.");
        AllEasyTransLineEntry.SETFILTER("AllEasy Process Type", '%1|%2', AllEasyTransLineEntry."AllEasy Process Type"::"Cash In Credit", AllEasyTransLineEntry."AllEasy Process Type"::"Cash Out Process");
        IF NOT AllEasyTransLineEntry.FindFirst() then
            EXIT;
        AllEasyTypeTransLine := "AllEasy Type Trans. Line".FromInteger(AllEasyTransLineEntry."AllEasy Process Type".AsInteger());
        case AllEasyTypeTransLine of
            AllEasyTypeTransLine::"Cash In Credit":
                txtLRefNo := AllEasyTransLineEntry."Res. Cash In Ref. No.";
            AllEasyTypeTransLine::"Cash Out Process":
                txtLRefNo := AllEasyTransLineEntry."Res. Cash Out Ref. No.";
        END;
        IF txtLRefNo <> '' THEN
            IncomeExpenseAccount."Slip Text 1" := StrSubstNo(RefNoMsg, txtLRefNo);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", OnAfterPrintTenderTypeDescription, '', false, false)]
    local procedure OnAfterPrintTenderTypeDescription(var Sender: Codeunit "LSC POS Print Utility"; TransPaymentEntry: Record "LSC Trans. Payment Entry"; TenderType: Record "LSC Tender Type"; Tray: Integer);
    var
        AllEasyTransLineEntry: Record "AllEasy Trans. Line Entry";
        AllEasyTypeTransLine: Enum "AllEasy Type Trans. Line";
        txtLRefNo: Text;
        txtLValue: array[10] of Text;
        txtLDesign: Text;
        RefNoMsg: Label ' Ref. No.: %1';
    begin
        CLEAR(txtLRefNo);
        AllEasyTransLineEntry.RESET;
        AllEasyTransLineEntry.SETRANGE("Store No.", TransPaymentEntry."Store No.");
        AllEasyTransLineEntry.SETRANGE("POS Terminal No.", TransPaymentEntry."POS Terminal No.");
        AllEasyTransLineEntry.SETRANGE("Transaction No.", TransPaymentEntry."Transaction No.");
        AllEasyTransLineEntry.SETRANGE("AllEasy Process Type", AllEasyTransLineEntry."AllEasy Process Type"::"Pay QR Process");
        IF NOT AllEasyTransLineEntry.FindFirst() then
            EXIT;

        IF AllEasyTransLineEntry."Res. PayQR Ref. No." <> '' THEN begin
            CLEAR(txtLValue);
            txtLDesign := ' #L#########################';
            txtLValue[1] := StrSubstNo(RefNoMsg, AllEasyTransLineEntry."Res. PayQR Ref. No.");
            Sender.PrintLine(Sender.FormatLine(Sender.FormatStr(txtLValue, txtLDesign), false, TRUE, FALSE, false));
        end;
    end;


}
