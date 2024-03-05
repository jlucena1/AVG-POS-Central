codeunit 99009651 "AVG POS Transaction"
{
    TableNo = "LSC POS Menu Line";

    var
        LSCGlobalRec: Record "LSC POS Menu Line";
        LSCPOSSessionCU: Codeunit "LSC POS Session";
        LSCPOSTransactionCU: Codeunit "LSC POS Transaction";
        LSCPOSCtrlInterfaceCU: Codeunit "LSC POS Control Interface";
        LSCStore: Record "LSC Store";
        LSCPOSTerminal: Record "LSC POS Terminal";
        AVGPOSSessionCU: Codeunit "AVG POS Session";
        LSCFunctionalityProfile: Record "LSC POS Func. Profile";
        LSCPOSTransLineRec: Record "LSC POS Trans. Line";
        LSCPOSTransactionRec: Record "LSC POS Transaction";
        AVGPOSPrintUtils: Codeunit "AVG POS Print Utility";

    trigger OnRun()
    begin
        LSCGlobalRec := Rec;
        LSCPOSTerminal.GET(LSCPOSSessionCU.TerminalNo());
        LSCStore.GET(LSCPOSTerminal."Store No.");
        LSCFunctionalityProfile.GET(LSCPOSSessionCU.FunctionalityProfileID());
        if LSCPOSTransactionRec.Get(LSCGlobalRec."Current-RECEIPT") then
            IF LSCPOSTransLineRec.GET(LSCPOSTransactionRec."Receipt No.", LSCGlobalRec."Current-LINE") THEN;

        CASE Rec.Command of
            'PRINTWIFIPIN':
                PrintWifiPins(LSCPOSTransactionRec);
        END;
        Rec := LSCGlobalRec;
    end;

    local procedure PrintWifiPins(pLSCPOSTransLineRec: Record "LSC POS Transaction")
    var
        AVGPOSPrintUtils: Codeunit "AVG POS Print Utility";
    begin
        AVGPOSPrintUtils.PrintWifiPins(pLSCPOSTransLineRec);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction", OnProcessRefundSelection, '', false, false)]
    local procedure OnProcessRefundSelection(OriginalTransaction: Record "LSC Transaction Header"; var POSTransaction: Record "LSC POS Transaction"; isPostVoid: Boolean);
    var
        LSCPOSTransLine: Record "LSC POS Trans. Line";
        LSCTenderTypeLoc: Record "LSC Tender Type";
        LSCTransPaymentEntryLoc: Record "LSC Trans. Payment Entry";
        LSCTransInfoEntryLoc: Record "LSC Trans. Infocode Entry";
        LSCPOSTransInfoEntryLoc: Record "LSC POS Trans. Infocode Entry";
        PaymentAmount, BalanceAmount, AmountCurrency : Decimal;
    begin
        if LSCPOSSessionCU.GetValue('REFAUTOPOST') = '1' then begin
            LSCTransPaymentEntryLoc.Reset();
            LSCTransPaymentEntryLoc.setrange("Store No.", POSTransaction."Retrieved from Store No.");
            LSCTransPaymentEntryLoc.setrange("POS Terminal No.", POSTransaction."Retrieved from POS Term. No.");
            LSCTransPaymentEntryLoc.setrange("Transaction No.", POSTransaction."Retrieved from Trans. No.");
            if LSCTransPaymentEntryLoc.FindSet() then
                repeat
                    if LSCTenderTypeLoc.Get(POSTransaction."Store No.", LSCTransPaymentEntryLoc."Tender Type") then
                        if not LSCTenderTypeLoc."Exclude Refund Autopost" then begin
                            clear(LSCPOSTransLine);
                            LSCPOSTransLine.Init();
                            LSCPOSTransLine."Store No." := POSTransaction."Store No.";
                            LSCPOSTransLine."POS Terminal No." := POSTransaction."POS Terminal No.";
                            LSCPOSTransLine."Receipt No." := POSTransaction."Receipt No.";
                            LSCPOSTransLine."Entry Type" := LSCPOSTransLine."Entry Type"::Payment;
                            LSCPOSTransLine.Quantity := 1;
                            LSCPOSTransLine."Card/Customer/Coup.Item No" := LSCTransPaymentEntryLoc."Card or Account";
                            LSCPOSTransLine.validate(Number, LSCTransPaymentEntryLoc."Tender Type");
                            LSCPOSTransLine.validate(Amount, LSCTransPaymentEntryLoc."Amount Tendered");
                            if LSCTransPaymentEntryLoc."Currency Code" <> '' then begin
                                LSCPOSTransLine."Currency Code" := LSCTransPaymentEntryLoc."Currency Code";
                                LSCPOSTransLine."Amount In Currency" := LSCTransPaymentEntryLoc."Amount in Currency";
                            end;
                            LSCPOSTransLine.InsertLine();
                            LSCPOSTransactionCU.SetLineRec(LSCPOSTransLine);

                            LSCTransInfoEntryLoc.Reset();
                            LSCTransInfoEntryLoc.setrange("Store No.", LSCTransPaymentEntryLoc."Store No.");
                            LSCTransInfoEntryLoc.SetRange("POS Terminal No.", LSCTransPaymentEntryLoc."POS Terminal No.");
                            LSCTransInfoEntryLoc.setrange("Transaction No.", LSCTransPaymentEntryLoc."Transaction No.");
                            LSCTransInfoEntryLoc.SetRange("Line No.", LSCTransPaymentEntryLoc."Line No.");
                            if LSCTransInfoEntryLoc.FindSet() then
                                repeat
                                    LSCPOSTransInfoEntryLoc.Init;
                                    LSCPOSTransInfoEntryLoc."Receipt No." := POSTransaction."Receipt No.";
                                    LSCPOSTransInfoEntryLoc."Transaction Type" := LSCPOSTransInfoEntryLoc."Transaction Type"::"Payment Entry";
                                    LSCPOSTransInfoEntryLoc."Line No." := LSCTransInfoEntryLoc."Line No.";
                                    LSCPOSTransInfoEntryLoc.Infocode := LSCTransInfoEntryLoc.Infocode;
                                    LSCPOSTransInfoEntryLoc."Entry Line No." := LSCTransInfoEntryLoc."Entry Line No.";
                                    LSCPOSTransInfoEntryLoc."Store No." := LSCPOSSessionCU.StoreNo();
                                    LSCPOSTransInfoEntryLoc.Information := LSCTransInfoEntryLoc.Information;
                                    LSCPOSTransInfoEntryLoc."Info. Amt." := LSCTransInfoEntryLoc."Info. Amt.";
                                    LSCPOSTransInfoEntryLoc."POS Terminal No." := LSCPOSSessionCU.TerminalNo();
                                    LSCPOSTransInfoEntryLoc."No." := LSCTransInfoEntryLoc."No.";
                                    LSCPOSTransInfoEntryLoc."Variant Code" := LSCTransInfoEntryLoc."Variant Code";
                                    LSCPOSTransInfoEntryLoc.Amount := -LSCTransInfoEntryLoc.Amount;
                                    LSCPOSTransInfoEntryLoc."Type of Input" := LSCPOSTransInfoEntryLoc."Type of Input";
                                    LSCPOSTransInfoEntryLoc.Subcode := LSCTransInfoEntryLoc.Subcode;
                                    LSCPOSTransInfoEntryLoc."Entry Variant Code" := LSCTransInfoEntryLoc."Entry Variant Code";
                                    LSCPOSTransInfoEntryLoc."Entry Trigger Function" := LSCTransInfoEntryLoc."Entry Trigger Function";
                                    LSCPOSTransInfoEntryLoc."Entry Trigger Code" := LSCTransInfoEntryLoc."Entry Trigger Code";
                                    LSCPOSTransInfoEntryLoc."Source Code" := LSCTransInfoEntryLoc."Source Code";
                                    LSCPOSTransInfoEntryLoc."Selected Quantity" := -LSCTransInfoEntryLoc.Quantity;
                                    LSCPOSTransInfoEntryLoc."Serial No." := LSCTransInfoEntryLoc."Serial No.";
                                    LSCPOSTransInfoEntryLoc.Counter := 1;
                                    LSCPOSTransInfoEntryLoc.Status := LSCPOSTransInfoEntryLoc.Status::Processed;
                                    LSCPOSTransInfoEntryLoc."Set Price" := false;
                                    LSCPOSTransInfoEntryLoc."New Price" := 0;
                                    LSCPOSTransInfoEntryLoc."Skip Posting to Info. Entry" := false;
                                    LSCPOSTransInfoEntryLoc."Line Inserted and Linked" := true;
                                    LSCPOSTransInfoEntryLoc."Sel. Qty. (Set Price)" := 0;
                                    LSCPOSTransInfoEntryLoc."New Entry Line No." := 0;
                                    LSCPOSTransInfoEntryLoc."Staff ID" := LSCPOSSessionCU.StaffID;
                                    LSCPOSTransInfoEntryLoc.Date := TODAY;
                                    LSCPOSTransInfoEntryLoc.Time := TIME;
                                    if LSCPOSTransInfoEntryLoc.Insert then;
                                until LSCTransInfoEntryLoc.Next() = 0;
                        end;
                until LSCTransPaymentEntryLoc.next = 0;
            AmountCurrency := 0;
            PaymentAmount := 0;
            BalanceAmount := 0;
            LSCPOSTransactionCU.GetAmtAndBalance(AmountCurrency, PaymentAmount, BalanceAmount);
            IF BalanceAmount = 0 then begin
                if LSCPOSTransactionCU.GetPosState() <> 'PAYMENT' then
                    LSCPOSCtrlInterfaceCU.PostEvent('RUNCOMMAND', 'TOTAL', '', '');
                LSCPOSCtrlInterfaceCU.PostEvent('RUNCOMMAND', 'POST', '', '');
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Refund Mgt.", OnBeforeRetrieveTransactionToRefundByReceipt, '', false, false)]
    local procedure OnBeforeRetrieveTransactionToRefundByReceipt(var TransactionHeader: Record "LSC Transaction Header"; ReceiptString: Code[20]; var ErrorCode: Code[10]; var ErrorText: Text; var IsHandled: Boolean; var IsFound: Boolean);
    var
        AVGSetup: Record "AVG Setup";
    begin
        AVGPOSSessionCU.GetCurrAVGSetup(AVGSetup);
        if not AVGSetup."Auto Retrieve Tender on Refund" then
            exit;

        if not LSCPOSTransactionCU.PosConfirm('Do you want to Proceed AutoPost Refund?', false) then begin
            AVGPOSSessionCU.AVGPOSErrorMessages('Refund Autopost has been Cancelled.');
            IsFound := false;
            IsHandled := true;
        end else begin
            LSCPOSSessionCU.SetValue('REFAUTOPOST', '1');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Post Utility", OnAfterPostTransaction, '', false, false)]
    local procedure OnAfterPostTransaction(var TransactionHeader_p: Record "LSC Transaction Header");
    var
        WifiPinsEntry: Record "AVG Wifi Pins Entry";
        PrintedWifiPinsEntry: Record "AVG Printed Wifi Pins Entry";
        AVGSetup: Record "AVG Setup";
    begin
        if TransactionHeader_p."Sale Is Exchange Sale" then
            exit;

        if TransactionHeader_p."Entry Status" = TransactionHeader_p."Entry Status"::Voided then
            exit;

        AVGPOSSessionCU.GetCurrAVGSetup(AVGSetup);
        if not AVGSetup."Wifi Pins" then
            exit;

        WifiPinsEntry.RESET;
        WifiPinsEntry.SETCURRENTKEY("Entry No.");
        WifiPinsEntry.SETRANGE(Used, FALSE);
        IF WifiPinsEntry.FINDFIRST THEN BEGIN
            PrintedWifiPinsEntry.Init();
            PrintedWifiPinsEntry."Store No." := TransactionHeader_p."Store No.";
            PrintedWifiPinsEntry."POS Terminal No." := TransactionHeader_p."POS Terminal No.";
            PrintedWifiPinsEntry."Transaction No." := TransactionHeader_p."Transaction No.";
            PrintedWifiPinsEntry."Receipt No." := TransactionHeader_p."Receipt No.";
            PrintedWifiPinsEntry."Printed Date" := TransactionHeader_p.Date;
            PrintedWifiPinsEntry."Printed Time" := TransactionHeader_p.Time;
            PrintedWifiPinsEntry."Staff ID" := TransactionHeader_p."Staff ID";
            PrintedWifiPinsEntry."Account PIN" := WifiPinsEntry."Account PIN";
            if PrintedWifiPinsEntry.Insert() then
                WifiPinsEntry.Delete();
        END;
    end;

    local procedure PrintWifiPinsDetails(var Sender: Codeunit POSPrintUtilityExtnd; var MainSender: Codeunit "LSC POS Print Utility"; var Transaction: Record "LSC Transaction Header"; var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer; DSTR1: Text[100]; var IsHandled: Boolean)
    var
        txtLValue: array[10] of Text;
        txtLNodeName: array[32] of Text[50];
        PrintedWifiPinsEntry: Record "AVG Printed Wifi Pins Entry";
        AVGSetup: Record "AVG Setup";
        recLTransactionHeader: Record "LSC Transaction Header";
        codStoreNo: Code[20];
        codPOSTerminal: Code[20];
        intTransactionNo: Integer;
    begin
        AVGPOSSessionCU.GetCurrAVGSetup(AVGSetup);
        if not AVGSetup."Wifi Pins" then
            exit;

        if Transaction."Transaction No." = 0 then
            exit;

        clear(codStoreNo);
        clear(codPOSTerminal);
        clear(intTransactionNo);
        if Transaction."Sale Is Return Sale" then begin
            recLTransactionHeader.Reset();
            recLTransactionHeader.setrange("Store No.", Transaction."Store No.");
            recLTransactionHeader.setrange("Receipt No.", Transaction."Retrieved from Receipt No.");
            IF recLTransactionHeader.FindFirst() then begin
                codStoreNo := recLTransactionHeader."Store No.";
                codPOSTerminal := recLTransactionHeader."POS Terminal No.";
                intTransactionNo := recLTransactionHeader."Transaction No.";
            end;
        end else begin
            codStoreNo := Transaction."Store No.";
            codPOSTerminal := Transaction."POS Terminal No.";
            intTransactionNo := Transaction."Transaction No.";
        end;

        CLEAR(PrintedWifiPinsEntry);
        PrintedWifiPinsEntry.SETCURRENTKEY("Store No.", "POS Terminal No.", "Transaction No.");
        PrintedWifiPinsEntry.SETRANGE("Store No.", codStoreNo);
        PrintedWifiPinsEntry.SETRANGE("POS Terminal No.", codPOSTerminal);
        PrintedWifiPinsEntry.SETRANGE("Transaction No.", intTransactionNo);
        IF PrintedWifiPinsEntry.FINDFIRST THEN BEGIN
            CLEAR(txtLValue);
            DSTR1 := '#C######################################';
            txtLValue[1] := 'WIFI PASSWORD';
            txtLNodeName[1] := 'WIFIPASS';
            MainSender.PrintLine(2, MainSender.FormatLine(MainSender.FormatStr(txtLValue, DSTR1, false), false, true, false, false));
            MainSender.AddPrintLine(200, 1, txtLNodeName, txtLValue, DSTR1, false, true, false, false, 2);

            txtLValue[1] := PrintedWifiPinsEntry."Account PIN";
            txtLNodeName[1] := 'WIFIPASS1';
            MainSender.PrintLine(2, MainSender.FormatLine(MainSender.FormatStr(txtLValue, DSTR1, false), false, true, false, false));
            MainSender.AddPrintLine(200, 1, txtLNodeName, txtLValue, DSTR1, false, true, false, false, 2);

            txtLValue[1] := 'ENJOY YOUR STAY!!!';
            txtLNodeName[1] := 'WIFIPASS2';
            MainSender.PrintLine(2, MainSender.FormatLine(MainSender.FormatStr(txtLValue, DSTR1, false), false, true, false, false));
            MainSender.AddPrintLine(200, 1, txtLNodeName, txtLValue, DSTR1, false, true, false, false, 2);
            MainSender.PrintSeperator(2);

        END;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::POSPrintUtilityExtnd, PHPOS_OnBeforePrintFooter, '', false, false)]
    local procedure PHPOS_OnBeforePrintFooter(var Sender: Codeunit POSPrintUtilityExtnd; var MainSender: Codeunit "LSC POS Print Utility"; var Transaction: Record "LSC Transaction Header"; var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer; var DSTR1: Text[100]; var IsHandled: Boolean);
    begin
        PrintWifiPinsDetails(Sender, MainSender, Transaction, PrintBuffer, PrintBufferIndex, LinesPrinted, DSTR1, IsHandled);
    end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnBeforeStaffLogon, '', false, false)]
    // local procedure OnBeforeStaffLogon(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var Staff: Record "LSC Staff");
    // var
    //     LoginErrorMsg: Label 'Unable to Login Staff: %1 - %2. Previous Staff: %3 - %4 must need to process X-Report to close the current shift transactions.', Locked = true;
    //     LSCStoreLoc: Record "LSC Store";
    //     LSCStaff, LSCStaffPrevious : Record "LSC Staff";
    // begin
    //     if not LSCStoreLoc.Get(LSCPOSSessionCU.StoreNo()) then
    //         exit;

    //     if not LSCStoreLoc."AVG Enable Staff Login Control" then
    //         exit;

    //     if not LSCStaff.Get(CurrInput) then
    //         exit;

    //     if LSCStaff."Manager Privileges" = LSCStaff."Manager Privileges"::Yes then
    //         exit;

    //     if LSCStaff."Employment Type" = LSCStaff."Employment Type"::"Sales Person" then
    //         exit;

    //     if (POSTransaction."Last Staff ID Logon" <> '') AND
    //         (POSTransaction."Last Staff ID Logon" <> LSCPOSSessionCU.StaffID())
    //     then begin
    //         if LSCStaffPrevious.Get(POSTransaction."Last Staff ID Logon") then begin
    //             AVGPOSSessionCU.AVGPOSErrorMessages(StrSubstNo(LoginErrorMsg, LSCStaff.ID, LSCStaff."Name on Receipt", LSCStaffPrevious.ID, LSCStaffPrevious."Name on Receipt"));
    //             clear(Staff);
    //             exit;
    //         end;
    //     end else
    //         IF not CheckStaffTransactionPerDay(CurrInput) then
    //             POSTransaction."Last Staff ID Logon" := CurrInput;
    // end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnBeforeLogoff, '', false, false)]
    // local procedure OnBeforeLogoff(var POSTransaction: Record "LSC POS Transaction"; var SalesType: Record "LSC Sales Type"; var closePos: Boolean);
    // begin
    //     Message('x');
    //     POSTransaction."Last Staff ID Logon" := LSCPOSSessionCU.StaffID();
    // end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnAfterLogoff, '', false, false)]
    // local procedure OnAfterLogoff(var POSTransaction: Record "LSC POS Transaction"; var SalesType: Record "LSC Sales Type"; var closePos: Boolean);
    // begin
    //     Message('Before: %1', POSTransaction."Last Staff ID Logon");
    //     POSTransaction."Last Staff ID Logon" := LSCPOSSessionCU.StaffID();
    //     POSTransaction.Modify();
    //     Commit();
    //     Message('After: %1', POSTransaction."Last Staff ID Logon");
    // end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Controller", OnBeforeClosePOSPanelInLogoffPressed, '', false, false)]
    // local procedure OnBeforeClosePOSPanelInLogoffPressed(ActivePanelID: Text; StartupControllerCodeunit: Integer; var CancelClosing: Boolean);
    // begin
    // end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Controller", OnBeforeClosePos, '', false, false)]
    // local procedure OnBeforeClosePos(var shouldSkipClosing: Boolean; var shouldSkipConfirm: Boolean);
    // var
    //     LSCPOSTransactionRec: Record "LSC POS Transaction";
    //     LSCStore: Record "LSC Store";
    // begin
    //     if not LSCStore.Get(LSCPOSSessionCU.StoreNo()) then
    //         exit;

    //     if not LSCStore."AVG Enable Staff Login Control" then
    //         exit;
    //     if LSCPOSTransactionRec.Get(LSCPOSSessionCU.GetValue('LASTPOSTRANS')) then begin
    //         LSCPOSTransactionRec."Last Staff ID Logon" := LSCPOSSessionCU.StaffID();
    //         LSCPOSTransactionRec.Modify();
    //         shouldSkipClosing := true;
    //         shouldSkipConfirm := true;
    //     end;
    // end;
    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnBeforeCloseForm, '', false, false)]
    // local procedure OnBeforeCloseForm(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text);
    // begin
    // end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnAfterPrintZReport, '', false, false)]
    // local procedure OnAfterPrintZReport(var POSTransaction: Record "LSC POS Transaction"; DoCheck: Boolean; AskUser: Boolean);
    // var
    //     LSCStaffLoc: Record "LSC Staff";
    //     LSCStoreLoc: Record "LSC Store";
    // begin
    //     if not LSCStoreLoc.Get(LSCPOSSessionCU.StoreNo()) then
    //         exit;

    //     if not LSCStoreLoc."AVG Enable Staff Login Control" then
    //         exit;

    //     if not LSCStaffLoc.Get(LSCPOSSessionCU.StaffID()) then
    //         exit;

    //     if LSCStaffLoc."Manager Privileges" = LSCStaffLoc."Manager Privileges"::Yes then
    //         exit;

    //     if LSCStaffLoc."Employment Type" = LSCStaffLoc."Employment Type"::"Sales Person" then
    //         exit;

    //     if POSTransaction."Staff ID" = LSCPOSSessionCU.StaffID() then begin
    //         POSTransaction."Last Staff ID Logon" := '';
    //         POSTransaction.Modify(true);
    //     end;
    // end;

    // local procedure CheckStaffTransactionPerDay(pStaffID: Code[20]): Boolean
    // var
    //     LSCTransactionHeader: Record "LSC Transaction Header";
    // begin
    //     IF pStaffID <> '' then
    //         exit(false);

    //     LSCTransactionHeader.Reset();
    //     LSCTransactionHeader.setrange("Store No.", LSCPOSSessionCU.StoreNo());
    //     LSCTransactionHeader.SetRange(Date, Today);
    //     LSCTransactionHeader.SetRange("Transaction Type", LSCTransactionHeader."Transaction Type"::Sales);
    //     LSCTransactionHeader.SetRange("Staff ID", pStaffID);
    //     if LSCTransactionHeader.FindFirst() then
    //         exit(true);
    // end;

}
