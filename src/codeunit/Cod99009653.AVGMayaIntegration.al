codeunit 99009653 "AVG Maya Integration"
{
    TableNo = "LSC POS Menu Line";

    var
        LSCGlobalRec: Record "LSC POS Menu Line";
        LSCStore: Record "LSC Store";
        LSCPOSTerminal: Record "LSC POS Terminal";
        LSCFunctionalityProfile: Record "LSC POS Func. Profile";
        LSCPOSTransLineRec: Record "LSC POS Trans. Line";
        LSCPOSTransactionCU: Codeunit "LSC POS Transaction";
        LSCPOSFunctionsCU: Codeunit "LSC POS Functions";
        LSCPOSCtrlInterfaceCU: Codeunit "LSC POS Control Interface";
        LSCPOSSession: Codeunit "LSC POS Session";
        LSCPOSGui: Codeunit "LSC POS GUI";
        AVGPOSSession: Codeunit "AVG POS Session";
        AVGPOSFunctions: Codeunit "AVG POS Functions";
        TypeHelper: Codeunit "Type Helper";
        AVGFunctions: Codeunit "AVG Functions";
        JObjectMaya: JsonObject;
        JTokenMaya: JsonToken;


    trigger OnRun()
    begin
        LSCGlobalRec := Rec;
        LSCPOSTerminal.GET(LSCPOSSession.TerminalNo());
        LSCStore.GET(LSCPOSTerminal."Store No.");
        LSCFunctionalityProfile.GET(LSCPOSSession.FunctionalityProfileID());
        IF LSCPOSTransLineRec.GET(LSCGlobalRec."Current-RECEIPT", LSCGlobalRec."Current-LINE") THEN;
        AVGFunctions.SetGlobalLSCPOSMenuLine(LSCGlobalRec);
        CASE Rec.Command of
            'MAYACHECK':
                MayaCheckEx(Rec.Parameter);
            'MAYAPAY':
                MayaPayEx(Rec.Parameter);
            'MAYAVOID':
                MayaVoidEx();
        END;
        Rec := LSCGlobalRec;
    end;

    procedure InitializeMaya(): Boolean
    begin

        IF NOT LSCPOSTerminal."Enable Maya Integration" THEN
            EXIT(FALSE);

        IF LSCPOSTerminal."Maya Py Script Path" = '' then
            EXIT(FALSE);

        IF LSCPOSTerminal."Maya COM Port" = '' then
            EXIT(FALSE);

        IF LSCPOSTerminal."Maya Python Exe Path" = '' then
            exit(false);


        EXIT(TRUE);
    end;

    local procedure MayaCheckEx(Parameter: Text)
    begin
        IF NOT InitializeMaya() then
            EXIT;

        ProcessMaya('', 1, '', '');
    end;

    local procedure MayaPayEx(Parameter: Text)
    var
        LSCTenderType: Record "LSC Tender Type";
    begin
        AVGPOSSession.ClearCurrMayaTenderType();
        AVGPOSSession.SetCurrMayaTenderType(Parameter);

        IF Parameter = '' then
            exit;

        IF NOT LSCTenderType.Get(LSCPOSTerminal."Store No.", Parameter) then
            exit;

        IF LSCTenderType."AVG Maya Tender Type" = LSCTenderType."AVG Maya Tender Type"::" " THEN
            exit;
        IF NOT InitializeMaya() then
            EXIT;
        LSCPOSTransactionCU.OpenNumericKeyboard('Maya Amount', 0, LSCPOSFunctionsCU.FormatAmount(LSCPOSTransactionCU.GetOutstandingBalance()), 99009653);
        EXIT;
    end;

    local procedure MayaVoidEx()
    begin
        IF NOT InitializeMaya() then
            EXIT;
        LSCPOSGui.OpenAlphabeticKeyboard('Enter Receipt Trace No.', '', AVGPOSSession.GetHideKeybValues, '#MAYATRACENO', 6);
        exit;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction", OnBeforeProcessKeyBoardResult, '', false, false)]
    local procedure "LSC POS Transaction_OnBeforeProcessKeyBoardResult"(Payload: Text; InputValue: Text; ResultOK: Boolean; var IsHandled: Boolean)
    begin
        case Payload of
            '#MAYATRACENO':
                begin
                    if ResultOK then begin
                        if InputValue <> '' then begin
                            message('Input Value 1: %1', InputValue);
                            LSCPOSSession.SetValue('MAYATRACENO', InputValue);
                            LSCPOSGui.OpenAlphabeticKeyboard('Enter Terminal Password', '', AVGPOSSession.GetHideKeybValues, '#MAYAPWD', 6);
                        end;
                    end;
                    IsHandled := true;
                    exit;
                end;
            '#MAYAPWD':
                begin
                    if ResultOK then begin
                        IsHandled := true;
                        if InputValue <> '' then begin
                            message('Input Value 2: %1', InputValue);
                            LSCPOSSession.SetValue('MAYAPWD', InputValue);
                            if (LSCPOSSession.GetValue('MAYATRACENO') = '') AND (LSCPOSSession.GetValue('MAYAPWD') = '') then
                                AVGPOSFunctions.AVGPOSErrorMessage('Invalid Trace No. or Terminal Password.')
                            else
                                ProcessMaya('', 3, LSCPOSSession.GetValue('MAYATRACENO'), LSCPOSSession.GetValue('MAYAPWD'));
                            Message(LSCPOSSession.GetValue('MAYATRACENO'));
                            Message(LSCPOSSession.GetValue('MAYAPWD'));
                        end;
                    end;
                    IsHandled := true;
                    exit;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction", OnAfterKeyboardTriggerToProcess, '', false, false)]
    local procedure OnAfterKeyboardTriggerToProcess(InputValue: Text; KeyboardTriggerToProcess: Integer; var Rec: Record "LSC POS Transaction"; var IsHandled: Boolean);
    var
        AmountToPay: Decimal;
        InvalidAmtMsg: Label 'Invalid Amount.', Locked = true;
        ExceededAmtMsg: Label 'Exceeded Amount.', Locked = true;
        decLAmount: Decimal;
        txtLAmount: Text;
        MayaAmountText: Text;
    begin
        case KeyboardTriggerToProcess of
            99009653:
                begin
                    // InputValue := LSCPOSCtrlInterfaceCU.GetInputText(LSCPOSSession.POSNumpadInputID());
                    // IF InputValue = '' then
                    //     EXIT;

                    decLAmount := 0;
                    IF NOT EVALUATE(decLAmount, InputValue) then
                        exit;

                    CLEAR(txtLAmount);
                    txtLAmount := InputValue;
                    IF decLAmount = 0 then
                        EXIT;
                    AVGPOSSession.ClearCurrMayaAmount();
                    AVGPOSSession.SetCurrMayaAmount(txtLAmount);
                    decLAmount := decLAmount * 100;
                    CLEAR(MayaAmountText);
                    MayaAmountText := DelChr(Format(decLAmount), '=', ',.');
                    ProcessMaya(MayaAmountText, 2, '', '');
                    IsHandled := true;
                end;
        end;
    end;



    procedure ProcessMaya(pTxtAmount: Text; pIntTrigger: Integer; pTxtMayaTraceNo: Text; pTxtMayaPassword: Text): Boolean
    var

        StringArgs, StringOutput : Text;
        LSCPOSTerminalLoc: Record "LSC POS Terminal";
        LSCTenderTypeLoc: Record "LSC Tender Type";
        AVGMayaCommands: Enum "AVG Maya Commands";
        AmountText: Text;
    begin
        IF NOT LSCPOSTerminalLoc.GET(LSCPOSSession.TerminalNo()) THEN
            exit(false);

        if not LSCTenderTypeLoc.Get(LSCPOSTerminalLoc."Store No.", AVGPOSSession.GetCurrMayaTenderType()) then
            exit(false);

        CLEAR(StringArgs);
        AVGMayaCommands := "AVG Maya Commands".FromInteger(pIntTrigger);
        case AVGMayaCommands of
            AVGMayaCommands::"Maya Check":
                begin
                    StringArgs := StrSubstNo('%1', LSCPOSTerminalLoc."Maya Py Script Path" +
                                    ' -t ' + LSCPOSTerminalLoc."Maya COM Port" +
                                    ' -c CHECK');
                    clear(StringOutput);
                    StringOutput := ProcessMayaECR(LSCPOSTerminalLoc, StringArgs);
                    ProcessMayaJson(StringOutput, 2);

                    if GetMayaValue('dataType') = 'ack' then begin
                        AVGPOSFunctions.AVGPOSMessage('Maya Terminal is Online.');
                        exit(true);
                    end else begin
                        AVGPOSFunctions.AVGPOSErrorMessage('Maya Terminal is Offline.');
                        exit(false);
                    end;

                end;
            AVGMayaCommands::"Maya Sale":
                begin
                    StringArgs := StrSubstNo('%1', LSCPOSTerminalLoc."Maya Py Script Path" +
                                    ' -t ' + LSCPOSTerminalLoc."Maya COM Port" +
                                    ' -c SALE --amount ' + pTxtAmount + ' --tender ' + FORMAT(LSCTenderTypeLoc."AVG Maya Tender Type"));
                    clear(StringOutput);

                    StringOutput := ProcessMayaECR(LSCPOSTerminalLoc, StringArgs);
                    if StringOutput = '' then
                        exit(false);
                    ProcessMayaJson(StringOutput, 3);
                    ProcessMayaResponse();
                    if GetMayaValue('data.responseText') = 'Txn Accepted' then begin
                        clear(AmountText);
                        AmountText := AVGPOSSession.GetCurrMayaAmount();
                        LSCPOSTransactionCU.SetCurrInput(AmountText);
                        LSCPOSTransactionCU.TenderKeyPressed(LSCTenderTypeLoc.Code);
                    end;
                end;
            AVGMayaCommands::"Maya Void":
                begin
                    StringArgs := StrSubstNo('%1', LSCPOSTerminalLoc."Maya Py Script Path" +
                                    ' -t ' + LSCPOSTerminalLoc."Maya COM Port" +
                                    ' -c VOID --txnId ' + pTxtMayaTraceNo + ' --pwd ' + pTxtMayaPassword);
                    StringOutput := ProcessMayaECR(LSCPOSTerminalLoc, StringArgs);
                    if StringOutput = '' then
                        exit(false);
                    ProcessMayaJson(StringOutput, 3);
                    ProcessMayaResponse();
                end;
        end;
    end;

    local procedure ProcessMayaECR(pLSCPOSTerminalRec: Record "LSC POS Terminal"; pStringArgs: Text): Text
    var
        ECR: DotNet StartInfo;
        ECRTimeout: Integer;
        StringOutput: Text;
    begin
        ECRTimeout := 5000; // DEFAULT

        IF pLSCPOSTerminalRec."Maya Terminal Timeout (ms)" <> 0 then
            ECRTimeout := pLSCPOSTerminalRec."Maya Terminal Timeout (ms)";
        ECR := ECR.Process();
        ECR.StartInfo.UseShellExecute(false);
        ECR.StartInfo.FileName(pLSCPOSTerminalRec."Maya Python Exe Path");
        ECR.StartInfo.Arguments(pStringArgs);
        ECR.StartInfo.UseShellExecute(FALSE);
        ECR.StartInfo.CreateNoWindow(TRUE);
        ECR.StartInfo.RedirectStandardOutput(TRUE);
        ECR.StartInfo.RedirectStandardError(TRUE);
        ECR.Start();
        StringOutput := ECR.StandardOutput.ReadToEnd();
        IF ECR.WaitForExit(ECRTimeout) then;
        exit(StringOutput);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnAfterInsertPaymentLine, '', false, false)]
    local procedure OnAfterInsertPaymentLine(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var TenderTypeCode: Code[10]; var SkipCommit: Boolean);
    begin
        IF LSCPOSSession.Getvalue('MAYASTATUS') = 'A' then
            ProcessMayaResponseToLines(POSTransaction, POSTransLine);
        LSCPOSSession.DeleteValue('MAYAAID');
        LSCPOSSession.DeleteValue('MAYAAPP');
        LSCPOSSession.DeleteValue('MAYAATC');
        LSCPOSSession.DeleteValue('MAYAAUTHCODE');
        LSCPOSSession.DeleteValue('MAYABATCHNO');
        LSCPOSSession.DeleteValue('MAYACARDBIN');
        LSCPOSSession.DeleteValue('MAYACARDTYPE');
        LSCPOSSession.DeleteValue('MAYAENTERMODE');
        LSCPOSSession.DeleteValue('MAYAENTERMODECODE');
        LSCPOSSession.DeleteValue('MAYAMERCHANTID');
        LSCPOSSession.DeleteValue('MAYAMERCHANTREFNO');
        LSCPOSSession.DeleteValue('MAYAPAN');
        LSCPOSSession.DeleteValue('MAYAREFERENCENO');
        LSCPOSSession.DeleteValue('MAYARESPONSECODE');
        LSCPOSSession.DeleteValue('MAYARESPONSETEXT');
        LSCPOSSession.DeleteValue('MAYASTATUS');
        LSCPOSSession.DeleteValue('MAYATENDERTYPE');
        LSCPOSSession.DeleteValue('MAYATERMINALID');
        LSCPOSSession.DeleteValue('MAYATSI');
        LSCPOSSession.DeleteValue('MAYATVR');
        LSCPOSSession.DeleteValue('MAYATXNDATE');
        LSCPOSSession.DeleteValue('MAYATXNID');
        LSCPOSSession.DeleteValue('MAYATXNTIME');
        LSCPOSSession.DeleteValue('MAYATXNTYPE');
        LSCPOSSession.DeleteValue('MAYAAMT');
    end;

    local procedure ProcessMayaResponse()
    begin
        LSCPOSSession.SetValue('MAYAAID', GetMayaValue('data.aid'));
        LSCPOSSession.SetValue('MAYAAPP', GetMayaValue('data.app'));
        LSCPOSSession.SetValue('MAYAATC', GetMayaValue('data.atc'));
        LSCPOSSession.SetValue('MAYAAUTHCODE', GetMayaValue('data.authCode'));
        LSCPOSSession.SetValue('MAYABATCHNO', GetMayaValue('data.batchNo'));
        LSCPOSSession.SetValue('MAYACARDBIN', GetMayaValue('data.cardBin'));
        LSCPOSSession.SetValue('MAYACARDTYPE', GetMayaValue('data.cardType'));
        LSCPOSSession.SetValue('MAYAENTERMODE', GetMayaValue('data.enterMode'));
        LSCPOSSession.SetValue('MAYAENTERMODECODE', GetMayaValue('data.enterModeCode'));
        LSCPOSSession.SetValue('MAYAMERCHANTID', GetMayaValue('data.merchantId'));
        LSCPOSSession.SetValue('MAYAMERCHANTREFNO', GetMayaValue('data.merchantRefNo'));
        LSCPOSSession.SetValue('MAYAPAN', GetMayaValue('data.pan'));
        LSCPOSSession.SetValue('MAYAREFERENCENO', GetMayaValue('data.referenceNo'));
        LSCPOSSession.SetValue('MAYARESPONSECODE', GetMayaValue('data.responseCode'));
        LSCPOSSession.SetValue('MAYARESPONSETEXT', GetMayaValue('data.responseText'));
        LSCPOSSession.SetValue('MAYASTATUS', GetMayaValue('data.status'));
        LSCPOSSession.SetValue('MAYATENDERTYPE', GetMayaValue('data.tenderType'));
        LSCPOSSession.SetValue('MAYATERMINALID', GetMayaValue('data.terminalId'));
        LSCPOSSession.SetValue('MAYATSI', GetMayaValue('data.tsi'));
        LSCPOSSession.SetValue('MAYATVR', GetMayaValue('data.tvr'));
        LSCPOSSession.SetValue('MAYATXNDATE', GetMayaValue('data.txnDate'));
        LSCPOSSession.SetValue('MAYATXNID', GetMayaValue('data.txnId'));
        LSCPOSSession.SetValue('MAYATXNTIME', GetMayaValue('data.txnTime'));
        LSCPOSSession.SetValue('MAYATXNTYPE', GetMayaValue('data.txnType'));
        LSCPOSSession.SetValue('MAYAAMT', GetMayaValue('data.amt'));
    end;

    local procedure ProcessMayaResponseToLines(pPOSTransaction: Record "LSC POS Transaction"; pPOSTransLine: Record "LSC POS Trans. Line")
    var
        AVGMayaTransLine, AVGMayaTransLine2 : Record "AVG Maya Trans. Line";
        MayaLineNo: Integer;
    begin
        clear(MayaLineNo);
        AVGMayaTransLine2.Reset();
        AVGMayaTransLine2.SetRange("Receipt No.", pPOSTransaction."Receipt No.");
        AVGMayaTransLine2.SetRange("Store No.", pPOSTransaction."Store No.");
        AVGMayaTransLine2.SetRange("POS Terminal No.", pPOSTransaction."POS Terminal No.");
        if AVGMayaTransLine2.FindLast() then
            MayaLineNo := AVGMayaTransLine2."Line No." + 10000
        else
            MayaLineNo := 10000;
        AVGMayaTransLine.Init();
        AVGMayaTransLine."Store No." := pPOSTransaction."Store No.";
        AVGMayaTransLine."POS Terminal No." := pPOSTransaction."POS Terminal No.";
        AVGMayaTransLine."Receipt No." := pPOSTransaction."Receipt No.";
        AVGMayaTransLine."Line No." := MayaLineNo;
        AVGMayaTransLine."Parent Line No." := pPOSTransLine."Line No.";
        AVGMayaTransLine."Maya Aid" := LSCPOSSession.GetValue('MAYAAID');
        AVGMayaTransLine."Maya App" := LSCPOSSession.GetValue('MAYAAPP');
        AVGMayaTransLine."Maya Atc" := LSCPOSSession.GetValue('MAYAATC');
        AVGMayaTransLine."Maya Auth Code" := LSCPOSSession.GetValue('MAYAAUTHCODE');
        AVGMayaTransLine."Maya Batch No." := LSCPOSSession.GetValue('MAYABATCHNO');
        AVGMayaTransLine."Maya Card Bin" := LSCPOSSession.GetValue('MAYACARDBIN');
        AVGMayaTransLine."Maya Card Type" := LSCPOSSession.GetValue('MAYACARDTYPE');
        AVGMayaTransLine."Maya Enter Mode" := LSCPOSSession.GetValue('MAYAENTERMODE');
        AVGMayaTransLine."Maya Enter Mode Code" := LSCPOSSession.GetValue('MAYAENTERMODECODE');
        AVGMayaTransLine."Maya Merchant ID" := LSCPOSSession.GetValue('MAYAMERCHANTID');
        AVGMayaTransLine."Maya Merchant Ref. No." := LSCPOSSession.GetValue('MAYAMERCHANTREFNO');
        AVGMayaTransLine."Maya Pan" := LSCPOSSession.GetValue('MAYAPAN');
        AVGMayaTransLine."Maya Reference No." := LSCPOSSession.GetValue('MAYAREFERENCENO');
        AVGMayaTransLine."Maya Response Code" := LSCPOSSession.GetValue('MAYARESPONSECODE');
        AVGMayaTransLine."Maya Response Text" := LSCPOSSession.GetValue('MAYARESPONSETEXT');
        AVGMayaTransLine."Maya Status" := LSCPOSSession.GetValue('MAYASTATUS');
        AVGMayaTransLine."Maya Tender Type" := LSCPOSSession.GetValue('MAYATENDERTYPE');
        AVGMayaTransLine."Maya Terminal ID" := LSCPOSSession.GetValue('MAYATERMINALID');
        AVGMayaTransLine."Maya TSI" := LSCPOSSession.GetValue('MAYATSI');
        AVGMayaTransLine."Maya TVR" := LSCPOSSession.GetValue('MAYATVR');
        AVGMayaTransLine."Maya Txn Date" := LSCPOSSession.GetValue('MAYATXNDATE');
        AVGMayaTransLine."Maya Txn ID" := LSCPOSSession.GetValue('MAYATXNID');
        AVGMayaTransLine."Maya Txn Time" := LSCPOSSession.GetValue('MAYATXNTIME');
        AVGMayaTransLine."Maya Txn Type" := LSCPOSSession.GetValue('MAYATXNTYPE');
        AVGMayaTransLine."Maya Amount" := LSCPOSSession.GetValue('MAYAAMT');
        AVGMayaTransLine."Actual Amount" := pPOSTransLine.Amount;
        AVGMayaTransLine.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Post Utility", OnAfterPostTransaction, '', false, false)]
    local procedure "LSC POS Post Utility_OnAfterPostTransaction"(var TransactionHeader_p: Record "LSC Transaction Header")
    var
        AVGMayaTransLine: Record "AVG Maya Trans. Line";
        AVGMayaTransEntry: Record "AVG Maya Trans. Entries";
    begin
        AVGMayaTransLine.Reset();
        AVGMayaTransLine.SetCurrentKey("Receipt No.", "Line No.", "Store No.", "POS Terminal No.");
        AVGMayaTransLine.SetRange("Receipt No.", TransactionHeader_p."Receipt No.");
        AVGMayaTransLine.SetRange("Store No.", TransactionHeader_p."Store No.");
        AVGMayaTransLine.SetRange("POS Terminal No.", TransactionHeader_p."POS Terminal No.");
        if AVGMayaTransLine.FindSet() then
            repeat
                AVGMayaTransEntry.Init();
                AVGMayaTransEntry."Store No." := TransactionHeader_p."Store No.";
                AVGMayaTransEntry."POS Terminal No." := TransactionHeader_p."POS Terminal No.";
                AVGMayaTransEntry."Receipt No." := TransactionHeader_p."Receipt No.";
                AVGMayaTransEntry."Transaction No." := TransactionHeader_p."Transaction No.";
                AVGMayaTransEntry."Line No." := AVGMayaTransLine."Line No.";
                AVGMayaTransEntry."Parent Line No." := AVGMayaTransLine."Parent Line No.";
                AVGMayaTransEntry."Maya Aid" := AVGMayaTransLine."Maya Aid";
                AVGMayaTransEntry."Maya App" := AVGMayaTransLine."Maya App";
                AVGMayaTransEntry."Maya Atc" := AVGMayaTransLine."Maya Atc";
                AVGMayaTransEntry."Maya Auth Code" := AVGMayaTransLine."Maya Auth Code";
                AVGMayaTransEntry."Maya Batch No." := AVGMayaTransLine."Maya Batch No.";
                AVGMayaTransEntry."Maya Card Bin" := AVGMayaTransLine."Maya Card Bin";
                AVGMayaTransEntry."Maya Card Type" := AVGMayaTransLine."Maya Card Type";
                AVGMayaTransEntry."Maya Enter Mode" := AVGMayaTransLine."Maya Enter Mode";
                AVGMayaTransEntry."Maya Enter Mode Code" := AVGMayaTransLine."Maya Enter Mode Code";
                AVGMayaTransEntry."Maya Merchant ID" := AVGMayaTransLine."Maya Merchant ID";
                AVGMayaTransEntry."Maya Merchant Ref. No." := AVGMayaTransLine."Maya Merchant Ref. No.";
                AVGMayaTransEntry."Maya Pan" := AVGMayaTransLine."Maya Pan";
                AVGMayaTransEntry."Maya Reference No." := AVGMayaTransLine."Maya Reference No.";
                AVGMayaTransEntry."Maya Response Code" := AVGMayaTransLine."Maya Response Code";
                AVGMayaTransEntry."Maya Response Text" := AVGMayaTransLine."Maya Response Text";
                AVGMayaTransEntry."Maya Status" := AVGMayaTransLine."Maya Status";
                AVGMayaTransEntry."Maya Tender Type" := AVGMayaTransLine."Maya Tender Type";
                AVGMayaTransEntry."Maya Terminal ID" := AVGMayaTransLine."Maya Terminal ID";
                AVGMayaTransEntry."Maya TSI" := AVGMayaTransLine."Maya TSI";
                AVGMayaTransEntry."Maya TVR" := AVGMayaTransLine."Maya TVR";
                AVGMayaTransEntry."Maya Txn Date" := AVGMayaTransLine."Maya Txn Date";
                AVGMayaTransEntry."Maya Txn ID" := AVGMayaTransLine."Maya Txn ID";
                AVGMayaTransEntry."Maya Txn Time" := AVGMayaTransLine."Maya Txn Time";
                AVGMayaTransEntry."Maya Txn Type" := AVGMayaTransLine."Maya Txn Type";
                AVGMayaTransEntry."Maya Amount" := AVGMayaTransLine."Maya Amount";
                AVGMayaTransEntry."Actual Amount" := AVGMayaTransLine."Actual Amount";
                IF AVGMayaTransEntry.Insert() then
                    AVGMayaTransLine.Delete();
            Until AVGMayaTransLine.next = 0;
    end;

    local procedure GetMayaValue(Path: Text): Text;
    begin
        if JObjectMaya.SelectToken(Path, JTokenMaya) then
            if JTokenMaya.IsValue then
                exit(JTokenMaya.AsValue().AsText());
    end;

    local procedure ProcessMayaJson(pStringText: Text; Mode: Integer): Text
    var
        i: Integer;
        BuilderReq1, BuilderRes1, BuilderReq2, BuilderRes2 : TextBuilder;
        OutputString: List of [Text];
        Str: Text;
        CR, LF : Char;
        CRLF: Text[2];
    begin
        CLEAR(CRLF);
        CR := 13;
        LF := 10;
        CLEAR(Str);
        CLEAR(OutputString);
        CLEAR(JObjectMaya);
        CRLF := format(CR) + format(LF);
        OutputString := pStringText.Split(CRLF);
        case Mode of
            1:
                begin
                    i := 0;
                    BuilderReq1.Clear();
                    while i < OutputString.Count do begin
                        i += 1;
                        Str := OutputString.Get(i);
                        if Str.Contains('REQUEST: {') then
                            BuilderReq1.AppendLine('{')
                        else
                            if BuilderReq1.Length > 0 then
                                IF Str.Contains('RESPONSE: {') then
                                    break
                                else
                                    BuilderReq1.AppendLine(Str)
                    end;
                    if JObjectMaya.ReadFrom(BuilderReq1.ToText()) then
                        exit(BuilderReq1.ToText());
                end;
            2:
                begin
                    i := 0;
                    BuilderRes1.Clear();
                    while i < OutputString.Count do begin
                        i += 1;
                        Str := OutputString.Get(i);
                        if Str.Contains('RESPONSE: {') then
                            BuilderRes1.AppendLine('{')
                        else
                            if BuilderRes1.Length > 0 then
                                IF Str.Contains('REQUEST {') then
                                    break
                                else
                                    BuilderRes1.AppendLine(Str)
                    end;
                    if JObjectMaya.ReadFrom(BuilderRes1.ToText()) then
                        exit(BuilderRes1.ToText());
                end;
            3:
                begin
                    i := 0;
                    BuilderReq2.Clear();
                    while i < OutputString.Count do begin
                        i += 1;
                        Str := OutputString.Get(i);
                        if Str.Contains('REQUEST {') then
                            BuilderReq2.AppendLine('{')
                        else
                            if BuilderReq2.Length > 0 THEN
                                IF Str.Contains('RESPONSE {') then
                                    break
                                else
                                    BuilderReq2.AppendLine(Str)
                    end;
                    if JObjectMaya.ReadFrom(BuilderReq2.ToText()) then
                        exit(BuilderReq2.ToText());
                end;
            4:
                begin
                    i := 0;
                    BuilderRes2.Clear();
                    while i < OutputString.Count do begin
                        i += 1;
                        Str := OutputString.Get(i);
                        if Str.Contains('RESPONSE {') then
                            BuilderRes2.AppendLine('{')
                        else
                            if BuilderRes2.Length > 0 THEN
                                BuilderRes2.AppendLine(Str)
                    end;
                    if JObjectMaya.ReadFrom(BuilderRes2.ToText()) then
                        exit(BuilderRes2.ToText());
                end;
        end;
    end;
}
