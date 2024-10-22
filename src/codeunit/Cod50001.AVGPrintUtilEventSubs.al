codeunit 50001 "AVG Print Util Event Subs."
{
    var
        GiftCardCurrencyCode: Code[10];
        LineLen: Integer;
        NodeName: array[32] of Text[50];
        FieldValue: array[10] of Text[100];

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", OnAfterPrintTenderTypeDescription, '', false, false)]
    local procedure OnAfterPrintTenderTypeDescription(var Sender: Codeunit "LSC POS Print Utility"; TransPaymentEntry: Record "LSC Trans. Payment Entry"; TenderType: Record "LSC Tender Type"; Tray: Integer);
    var
        AllEasyTransLineEntry: Record "AVG Trans. Line Entry";
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
        AllEasyTransLineEntry.SETRANGE("Process Type", AllEasyTransLineEntry."Process Type"::"Pay QR Process");
        IF NOT AllEasyTransLineEntry.FindFirst() then
            EXIT;

        IF AllEasyTransLineEntry."Res. PayQR Ref. No." <> '' THEN begin
            CLEAR(txtLValue);
            txtLDesign := ' #L#########################';
            txtLValue[1] := StrSubstNo(RefNoMsg, AllEasyTransLineEntry."Res. PayQR Ref. No.");
            Sender.PrintLine(Sender.FormatLine(Sender.FormatStr(txtLValue, txtLDesign), false, TRUE, FALSE, false));
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", OnBeforeIncExpAccDescription, '', false, false)]
    local procedure OnBeforeIncExpAccDescription(var IncomeExpenseAccount: Record "LSC Income/Expense Account"; var TransIncomeExpenseEntry: Record "LSC Trans. Inc./Exp. Entry");
    var
        AllEasyTransLineEntry: Record "AVG Trans. Line Entry";
        AllEasyTypeTransLine: Enum "AVG Type Trans. Line";
        txtLRefNo: Text;
        RefNoMsg: Label ' Ref. No.: %1';
    begin
        CLEAR(txtLRefNo);
        AllEasyTransLineEntry.RESET;
        AllEasyTransLineEntry.SETRANGE("Store No.", TransIncomeExpenseEntry."Store No.");
        AllEasyTransLineEntry.SETRANGE("POS Terminal No.", TransIncomeExpenseEntry."POS Terminal No.");
        AllEasyTransLineEntry.SETRANGE("Transaction No.", TransIncomeExpenseEntry."Transaction No.");
        AllEasyTransLineEntry.SETFILTER("Process Type", '%1|%2', AllEasyTransLineEntry."Process Type"::"Cash In Credit", AllEasyTransLineEntry."Process Type"::"Cash Out Process");
        IF NOT AllEasyTransLineEntry.FindFirst() then
            EXIT;
        AllEasyTypeTransLine := "AVG Type Trans. Line".FromInteger(AllEasyTransLineEntry."Process Type".AsInteger());
        case AllEasyTypeTransLine of
            AllEasyTypeTransLine::"Cash In Credit":
                txtLRefNo := AllEasyTransLineEntry."Res. Cash In Ref. No.";
            AllEasyTypeTransLine::"Cash Out Process":
                txtLRefNo := AllEasyTransLineEntry."Res. Cash Out Ref. No.";
        END;
        IF txtLRefNo <> '' THEN
            IncomeExpenseAccount."Slip Text 1" := StrSubstNo(RefNoMsg, txtLRefNo);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", OnBeforePrintSubHeader, '', false, false)]
    local procedure OnBeforePrintSubHeader(var Sender: Codeunit "LSC POS Print Utility"; var TransactionHeader: Record "LSC Transaction Header"; Tray: Integer; var POSPrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer; var IsHandled: Boolean);
    var
        txtLValue: array[10] of Text;
        txtLDesign: Text;
        AllEasyTransLineEntry: Record "AVG Trans. Line Entry";
        AllEasyTypeTransLine: Enum "AVG Type Trans. Line";
        CashOutReceiptMsg: Label 'CASH OUT RECEIPT';
        AcknowledgementReceiptMsg: Label 'ACKNOWLEDGEMENT RECEIPT';
    begin
        AllEasyTransLineEntry.RESET;
        AllEasyTransLineEntry.SETRANGE("Store No.", TransactionHeader."Store No.");
        AllEasyTransLineEntry.SETRANGE("POS Terminal No.", TransactionHeader."POS Terminal No.");
        AllEasyTransLineEntry.SETRANGE("Transaction No.", TransactionHeader."Transaction No.");
        AllEasyTransLineEntry.SETFILTER("Process Type", '%1|%2', AllEasyTransLineEntry."Process Type"::"Cash In Credit", AllEasyTransLineEntry."Process Type"::"Cash Out Process");
        IF NOT AllEasyTransLineEntry.FindFirst() then
            EXIT;

        CLEAR(txtLValue);
        txtLDesign := '#C######################################';
        AllEasyTypeTransLine := "AVg Type Trans. Line".FromInteger(AllEasyTransLineEntry."Process Type".AsInteger());
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


    local procedure PrintPaymInfo(var Sender: Codeunit "LSC POS Print Utility"; Transaction: Record "LSC Transaction Header"; Tray: Integer)
    var
        PaymEntry: Record "LSC Trans. Payment Entry";
        Tendertype: Record "LSC Tender Type";
        Tendercard: Record "LSC Tender Type Card Setup";
        Currency: Record Currency;
        TransInfoCode: Record "LSC Trans. Infocode Entry";
        DSTR1: Text[100];
        DSTR2: Text[100];
        Payment: Text[30];
        tmpStr: Text[50];
        RemainingAmount: Text;
        i: Integer;
        RemAmountText: Label 'Remaining Amount ';
        FieldValue: array[10] of Text[100];
        NodeName: array[32] of Text[50];
        POSFunctions: Codeunit "LSC POS Functions";
        AVGTransLineEntry: Record "AVG Trans. Line Entry";
        txtLValue2: array[10] of Text;
        txtLDesign: Text;
        RefNo: Text;
    begin
        Clear(PaymEntry);
        PaymEntry.SetRange("Store No.", Transaction."Store No.");
        PaymEntry.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
        PaymEntry.SetRange("Transaction No.", Transaction."Transaction No.");
        if PaymEntry.FindSet() then begin
            repeat

                DSTR1 := '#L################## #R## #R#########   ';
                Clear(FieldValue);
                Payment := PaymEntry."Tender Type";
                if Tendertype.Get(PaymEntry."Store No.", PaymEntry."Tender Type") then begin
                    if PaymEntry."Change Line" and (Tendertype."Change Line on Receipt" <> '') then
                        Payment := Tendertype."Change Line on Receipt"
                    else
                        Payment := Tendertype.Description;
                end
                else
                    Clear(Tendertype);

                if not Tendertype."Auto Account Payment Tender" then begin
                    FieldValue[1] := Payment;
                    NodeName[1] := 'Tender Description';
                    if (Tendertype."Function" = Tendertype."Function"::Coupons) and (PaymEntry.Quantity > 1) then
                        FieldValue[2] := Format(PaymEntry.Quantity);
                    NodeName[2] := 'Quantity';
                    FieldValue[3] := POSFunctions.FormatAmount(PaymEntry."Amount Tendered");
                    NodeName[3] := 'Amount In Tender';
                    FieldValue[4] := PaymEntry."Tender Type";
                    NodeName[4] := 'Tender Type';
                    FieldValue[5] := Format(PaymEntry."Line No.");
                    NodeName[5] := 'Line No.';
                    Sender.PrintLine(Tray, Sender.FormatLine(Sender.FormatStr(FieldValue, DSTR1), false, true, false, false));
                    Sender.AddPrintLine(700, 5, NodeName, FieldValue, DSTR1, false, true, false, false, Tray);

                    if (Tendertype."Function" = Tendertype."Function"::Card) then begin
                        DSTR2 := '  #L##################################  ';
                        if Tendercard.Get(PaymEntry."Store No.", PaymEntry."Tender Type", PaymEntry."Card No.") then begin
                            if Tendercard.Description <> '' then begin
                                FieldValue[1] := Tendercard.Description;
                                NodeName[1] := 'Card Name';
                                FieldValue[2] := Format(PaymEntry."Line No.");
                                NodeName[2] := 'Line No.';
                                Sender.PrintLine(Tray, Sender.FormatLine(Sender.FormatStr(FieldValue, DSTR2), false, true, false, false));
                                Sender.AddPrintLine(700, 2, NodeName, FieldValue, DSTR2, false, true, false, false, Tray);
                            end;
                        end;
                        if PaymEntry."Card or Account" <> '' then begin
                            tmpStr := PaymEntry."Card or Account";
                            for i := 1 to StrLen(tmpStr) - 6 do
                                tmpStr[i] := '*';
                            FieldValue[1] :=
                              CopyStr(tmpStr, 1, 4) + ' ' +
                              CopyStr(tmpStr, 5, 4) + ' ' +
                              CopyStr(tmpStr, 9, 4) + ' ' +
                              CopyStr(tmpStr, 13, 4) + ' ' +
                              CopyStr(tmpStr, 17, 4);
                            NodeName[1] := 'Detail Text';
                            FieldValue[2] := Format(PaymEntry."Line No.");
                            NodeName[2] := 'Line No.';
                            Sender.PrintLine(Tray, Sender.FormatLine(Sender.FormatStr(FieldValue, DSTR2), false, true, false, false));
                            Sender.AddPrintLine(700, 2, NodeName, FieldValue, DSTR2, false, true, false, false, Tray);
                        end;
                    end
                    else
                        if Tendertype."Card/Account No." then begin
                            DSTR2 := '  #L##################################  ';
                            FieldValue[1] := Tendertype."Ask for Card/Account" + ' ' + PaymEntry."Card or Account";
                            NodeName[1] := 'Detail Text';
                            FieldValue[2] := Format(PaymEntry."Line No.");
                            NodeName[2] := 'Line No.';
                            Sender.PrintLine(Tray, Sender.FormatLine(Sender.FormatStr(FieldValue, DSTR2), false, true, false, false));
                            Sender.AddPrintLine(700, 2, NodeName, FieldValue, DSTR2, false, true, false, false, Tray);
                        end;
                    if Tendertype."Foreign Currency" then begin
                        if PaymEntry."Amount in Currency" = 0 then
                            PaymEntry."Amount in Currency" := 1;
                        Currency.Get(PaymEntry."Currency Code");
                        DSTR2 := '  #L###### #L####################       ';
                        FieldValue[1] := Currency.Code;
                        NodeName[1] := 'Currency Code';
                        FieldValue[2] := POSFunctions.FormatCurrency(-PaymEntry."Amount in Currency", PaymEntry."Currency Code") +
                        ' @ ' + Format(Round(PaymEntry."Exchange Rate", 0.001, '='));
                        NodeName[2] := 'x';
                        FieldValue[3] := Format(PaymEntry."Line No.");
                        NodeName[3] := 'Line No.';
                        FieldValue[4] := POSFunctions.FormatCurrency(-PaymEntry."Amount in Currency", PaymEntry."Currency Code");
                        NodeName[4] := 'Amount In Currency';
                        FieldValue[5] := Format(PaymEntry."Exchange Rate");
                        NodeName[5] := 'Exchange Rate';
                        Sender.PrintLine(Tray, Sender.FormatLine(Sender.FormatStr(FieldValue, DSTR2), false, true, false, false));
                        Sender.AddPrintLine(700, 5, NodeName, FieldValue, DSTR2, false, true, false, false, Tray);
                    end;

                    TransInfoCode.SetRange("Store No.", Transaction."Store No.");
                    TransInfoCode.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
                    TransInfoCode.SetRange("Transaction No.", Transaction."Transaction No.");
                    TransInfoCode.SetRange("Transaction Type", TransInfoCode."Transaction Type"::"Payment Entry");
                    TransInfoCode.SetRange("Line No.", PaymEntry."Line No.");
                    PrintTransInfoCode(Sender, TransInfoCode, Tray, false);
                    RemainingAmount := '';
                    if TransInfoCode.FindFirst() then
                        if TransInfoCode."Type of Input" = TransInfoCode."Type of Input"::"Apply To Entry" then
                            RemainingAmount := Format(CalcDataEntryRemainingAmount(TransInfoCode)) + ' ' + GiftCardCurrencyCode;
                    if RemainingAmount <> '' then begin
                        DSTR1 := '  #L##################################  ';
                        NodeName[1] := RemAmountText;
                        FieldValue[1] := RemAmountText;
                        FieldValue[1] += RemainingAmount;
                        Sender.PrintLine(2, Sender.FormatLine(Sender.FormatStr(FieldValue, DSTR1), false, false, false, false));
                        Sender.AddPrintLine(100, 1, NodeName, FieldValue, DSTR1, false, false, false, false, 2);
                    end;
                    CLEAR(RefNo);
                    AVGTransLineEntry.RESET;
                    AVGTransLineEntry.SETRANGE("Store No.", PaymEntry."Store No.");
                    AVGTransLineEntry.SETRANGE("POS Terminal No.", PaymEntry."POS Terminal No.");
                    AVGTransLineEntry.SETRANGE("Transaction No.", PaymEntry."Transaction No.");
                    AVGTransLineEntry.SetRange("Trans. Line No.", PaymEntry."Line No.");
                    IF AVGTransLineEntry.FindFirst() then begin
                        case AVGTransLineEntry."Process Type" of
                            AVGTransLineEntry."Process Type"::"Pay QR Process":
                                RefNo := AVGTransLineEntry."Res. PayQR Ref. No.";
                            AVGTransLineEntry."Process Type"::"Retail Pay":
                                RefNo := AVGTransLineEntry."GCash Transaction ID";
                            AVGTransLineEntry."Process Type"::"Refund Transaction":
                                RefNo := AVGTransLineEntry."GCash Short Refund ID";
                        end;
                        IF RefNo <> '' THEN begin
                            CLEAR(txtLValue2);
                            txtLDesign := ' #L#########################';
                            txtLValue2[1] := StrSubstNo('Ref. No.: %1', RefNo);
                            Sender.PrintLine(Sender.FormatLine(Sender.FormatStr(txtLValue2, txtLDesign), false, FALSE, FALSE, false));
                        end;
                    end;
                end;
            until PaymEntry.Next = 0;
        end;
        Sender.PrintSeperator(Tray);
    end;

    procedure PrintTransInfoCode(var Sender: Codeunit "LSC POS Print Utility"; var TransInfoEntry: Record "LSC Trans. Infocode Entry"; Tray: Integer; PrintSep: Boolean)
    begin
        if TransInfoEntry.FindSet() then
            repeat
                PrintInfoCodeLine(Sender, Tray, false, TransInfoEntry.Infocode, TransInfoEntry.Subcode, TransInfoEntry.Information, TransInfoEntry."Line No.");
            until TransInfoEntry.Next = 0;
        if PrintSep then
            Sender.PrintLine(Tray, '');
    end;

    procedure PrintInfoCodeLine(var Sender: Codeunit "LSC POS Print Utility"; Tray: Integer; PrintSep: Boolean; ICode: Code[20]; ISubCode: Code[20]; Information: Text[100]; LineNo: Integer)
    var
        InfoCode: Record "LSC Infocode";
        InfoSub: Record "LSC Information Subcode";
        DSTR: Text[100];
        InfoText: Text[250];
    begin
        DSTR := '  #T####################################';
        IF LineLen = 0 THEN
            LineLen := Sender.GetLineLen();
        if InfoCode.Get(ICode) then begin
            InfoText := '';
            if InfoCode."Print Prompt on Receipt" then
                InfoText := InfoText + InfoCode.Prompt + ' ';
            if InfoCode."Print Input on Receipt" then
                InfoText := InfoText + Information + ' ';
            if InfoCode."Print Inp. Name on Rcpt." then
                if InfoSub.Get(InfoCode.Code, ISubCode) then
                    InfoText := InfoText + InfoSub.Description + ' ';
            if InfoText <> '' then begin
                while InfoText <> '' do begin
                    FieldValue[1] := CopyStr(InfoText, 1, LineLen - 2);
                    if StrLen(InfoText) > (LineLen - 2) then
                        InfoText := CopyStr(InfoText, LineLen - 1, StrLen(InfoText) - (LineLen - 2))
                    else
                        InfoText := '';
                    NodeName[1] := 'Extra Info Line';
                    FieldValue[2] := Format(LineNo);
                    NodeName[2] := 'Line No.';
                    IF InfoCode.RAL_MaskedDataOnReceiptPrint THEN
                        FieldValue[1] := PADSTR('', InfoCode.RAL_NoOfPaddedChar, InfoCode.RAL_PadCharacter) + FieldValue[1];
                    Sender.PrintLine(Tray, Sender.FormatLine(Sender.FormatStr(FieldValue, DSTR), false, false, false, false));
                    Sender.AddPrintLine(350, 2, NodeName, FieldValue, DSTR, false, false, false, false, Tray);
                end;
                if PrintSep then
                    Sender.PrintLine(Tray, '');
            end;
        end;

    end;

    local procedure CalcDataEntryRemainingAmount(TransInfoCodeEntry_p: Record "LSC Trans. Infocode Entry"): Decimal
    var
        DataEntry: Record "LSC POS Data Entry";
        DataEntryType_l: Record "LSC POS Data Entry Type";
        Infocode_l: Record "LSC Infocode";
        POSInfocodeUtility: Codeunit "LSC POS Infocode Utility";
        Balance: Decimal;
        HasExpired: Boolean;

    begin
        Balance := 0;
        GiftCardCurrencyCode := '';
        if Infocode_l.Get(TransInfoCodeEntry_p.Infocode) then
            if DataEntryType_l.Get(Infocode_l."Data Entry Type") then
                if DataEntryType_l."Print Remaining Balance" then begin
                    DataEntry.SetRange("Entry Type", DataEntryType_l.Code);
                    DataEntry.SetRange("Entry Code", TransInfoCodeEntry_p.Information);
                    if DataEntry.FindSet then begin
                        repeat
                            HasExpired := false;
                            if (DataEntry."Expiring Date" <> 0D) and (DataEntry."Expiring Date" < Today) then
                                HasExpired := true;
                            if (not DataEntry.Applied) and (not HasExpired) then
                                Balance += DataEntry.Amount - DataEntry."Applied Amount";
                            if DataEntry."Currency Code" <> '' then
                                GiftCardCurrencyCode := DataEntry."Currency Code"
                            else
                                GiftCardCurrencyCode := POSInfocodeUtility.GetCurrencyDataEntry(DataEntry."Created in Store No.");
                        until DataEntry.Next = 0;
                    end;
                end;

        exit(Balance);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", OnAfterPrintSlips, '', false, false)]
    local procedure OnAfterPrintSlips(var Sender: Codeunit "LSC POS Print Utility"; var Transaction: Record "LSC Transaction Header"; var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer; var MsgTxt: Text[50]; PrintSlip: Boolean);
    var
        txtLValue: array[10] of Text;
        txtLValue2: array[10] of Text;
        DSTR1: Text;
        LSCPOSFunctionsCU: Codeunit "LSC POS Functions";
    begin

        CLEAR(DSTR1);
        CLEAR(txtLValue);
        clear(txtLValue2);

        IF Transaction."Transaction No." = 0 THEN
            EXIT;

        IF Transaction."Official Receipt No." = '' THEN
            EXIT;

        IF NOT Sender.OpenReceiptPrinter(2, 'NORMAL', 'TENDERSLIP', Transaction."Transaction No.", Transaction."Receipt No.") THEN
            EXIT;

        Sender.PrintLogo(2);
        Sender.PrintHeader(Transaction, FALSE, 2);
        Sender.PrintSubHeader(Transaction, 2, Transaction.Date, Transaction.Time);
        DSTR1 := '#C##################';
        txtLValue[1] := 'STORE COPY';
        Sender.PrintLine(2, Sender.FormatLine(Sender.FormatStr(txtLValue, DSTR1), TRUE, FALSE, TRUE, FALSE));
        Sender.PrintSeperator(2);
        IF Transaction."Transaction Type" = Transaction."Transaction Type"::Sales THEN BEGIN
            IF NOT Transaction."Sale Is Return Sale" THEN BEGIN
                IF Transaction."Sales Type" <> '' THEN BEGIN
                    CLEAR(txtLValue);
                    DSTR1 := '       #C#########################';
                    txtLValue[1] := Transaction."Sales Type";
                    Sender.PrintLine(2, Sender.FormatLine(Sender.FormatStr(txtLValue, DSTR1), FALSE, FALSE, FALSE, FALSE));
                END;
                Sender.PrintSeperator(2);
            END;
        END;
        DSTR1 := '       #C#########################';
        txtLValue[1] := 'TENDER SLIP';
        Sender.PrintLine(2, Sender.FormatLine(Sender.FormatStr(txtLValue, DSTR1), FALSE, FALSE, FALSE, FALSE));
        Sender.PrintSeperator(2);
        DSTR1 := '#L################## #R## #R#########   ';
        txtLValue[1] := 'Total Sales Amount';
        txtLValue[2] := '';
        txtLValue[3] := LSCPOSFunctionsCU.FormatAmount(-Transaction."Gross Amount");
        Sender.PrintLine(2, Sender.FormatLine(Sender.FormatStr(txtLValue, DSTR1), FALSE, FALSE, FALSE, FALSE));
        PrintPaymInfo(Sender, Transaction, 2);

        Sender.PrintBlankLine(2);
        DSTR1 := '       #C#########################';
        txtLValue[1] := 'Merchant Signature';
        Sender.PrintLine(2, Sender.FormatLine(Sender.FormatStr(txtLValue, DSTR1), FALSE, FALSE, FALSE, FALSE));

        txtLValue[1] := '_________________';
        Sender.PrintLine(2, Sender.FormatLine(Sender.FormatStr(txtLValue, DSTR1), FALSE, FALSE, FALSE, FALSE));
        Sender.PrintSeperator(2);

        txtLValue[1] := 'Customer Signature';
        Sender.PrintLine(2, Sender.FormatLine(Sender.FormatStr(txtLValue, DSTR1), FALSE, FALSE, FALSE, FALSE));

        txtLValue[1] := '_________________';
        Sender.PrintLine(2, Sender.FormatLine(Sender.FormatStr(txtLValue, DSTR1), FALSE, FALSE, FALSE, FALSE));
        Sender.PrintSeperator(2);

        IF not Sender.ClosePrinter(2) then
            exit;
    end;
}
