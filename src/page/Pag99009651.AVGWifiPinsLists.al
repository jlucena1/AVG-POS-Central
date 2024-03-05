page 99009651 "AVG Wifi Pins Lists"
{
    ApplicationArea = All;
    Caption = 'AVG Wifi Pins';
    PageType = List;
    SourceTable = "AVG Wifi Pins Entry";
    UsageCategory = Lists;
    ModifyAllowed = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field.';
                }
                field("File Entry No."; Rec."File Entry No.")
                {
                    ToolTip = 'Specifies the value of the File Entry No. field.';
                }
                field("Account PIN"; Rec."Account PIN")
                {
                    ToolTip = 'Specifies the value of the Account PIN field.';
                }
                field(Used; Rec.Used)
                {
                    ToolTip = 'Specifies the value of the Used field.';
                }
                field("Uploaded By"; Rec."Uploaded By")
                {
                    ToolTip = 'Specifies the value of the Uploaded By field.';
                }
                field("Uploaded DateTime"; Rec."Uploaded DateTime")
                {
                    ToolTip = 'Specifies the value of the Uploaded DateTime field.';
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            action(UploadWifiPins)
            {
                ApplicationArea = All;
                Caption = 'Upload Wifi PINS';
                Image = ImportExcel;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                trigger OnAction()
                var
                    txtFile: Text;
                    InStr: InStream;
                begin
                    CSVBuffer.Reset();
                    CSVBuffer.DeleteAll();
                    if Upload('Import CSV File', '', '*.CSV|*.csv', '', txtFile) then begin
                        CSVBuffer.LoadData(txtFile, ',');
                        InsertIntoWifiPinsENtry();
                    end;
                end;
            }
            action(DeleteAllPins)
            {
                ApplicationArea = All;
                Image = Delete;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Caption = 'Delete all Pins';
                trigger OnAction()
                var
                    WifiPINSEntry: Record "AVG Wifi Pins Entry";
                    RecorCount: Integer;
                begin
                    RecorCount := 0;
                    IF NOT CONFIRM('Are you sure do you want to Delete All Wifi Pins Entry?', FALSE) THEN
                        EXIT;

                    WifiPINSEntry := Rec;
                    CLEAR(WifiPINSEntry);
                    RecorCount := WifiPINSEntry.COUNT;
                    IF NOT WifiPINSEntry.ISEMPTY THEN BEGIN
                        WifiPINSEntry.DELETEALL;
                        IF RecorCount <> 0 THEN
                            MESSAGE('%1 Wifi Pins Deleted.', RecorCount);
                        Rec := WifiPINSEntry;
                    END;
                end;
            }
        }
    }
    local procedure InsertIntoWifiPinsENtry()
    var
        AccountPIN, TempAccountPIN, StoreCode : Text;
        WifiPinsEntry, WifiPinsEntry2 : Record "AVG Wifi Pins Entry";
        Ctr, Currline, Position, RecCount : Integer;
    begin
        Commit();
        CSVBuffer.SETFILTER("Line No.", '>%1', 1);
        IF CSVBuffer.FINDSET THEN
            REPEAT
                CLEAR(WifiPinsEntry2);
                WifiPinsEntry2.SETCURRENTKEY("Entry No.");
                IF WifiPinsEntry2.FINDLAST THEN
                    Ctr := WifiPinsEntry2."Entry No." + 1
                ELSE
                    Ctr := 1;

                IF CSVBuffer."Line No." <> Currline THEN BEGIN
                    CLEAR(TempAccountPIN);
                    TempAccountPIN := CSVBuffer.GetValue(CSVBuffer."Line No.", 2);
                    CLEAR(Position);
                    Position := STRPOS(TempAccountPIN, '_');
                    IF Position <> 0 THEN BEGIN
                        //txtAccountPIN := COPYSTR(TempAccountPIN,Position + 1,STRLEN(TempAccountPIN));
                        AccountPIN := TempAccountPIN;
                        StoreCode := COPYSTR(TempAccountPIN, 1, Position - 1);
                    END ELSE
                        AccountPIN := TempAccountPIN;
                    IF (CSVBuffer.GetValue(CSVBuffer."Line No.", 1) <> '') AND
                       (AccountPIN <> '') AND
                       (CSVBuffer.GetValue(CSVBuffer."Line No.", 3) <> '')
                    THEN begin
                        WifiPinsEntry.LOCKTABLE;
                        WifiPinsEntry.INIT;
                        WifiPinsEntry."Entry No." := Ctr;
                        EVALUATE(WifiPinsEntry."File Entry No.", CSVBuffer.GetValue(CSVBuffer."Line No.", 1));
                        EVALUATE(WifiPinsEntry."Account PIN", AccountPIN);
                        EVALUATE(WifiPinsEntry.Used, CSVBuffer.GetValue(CSVBuffer."Line No.", 3));
                        WifiPinsEntry."Uploaded By" := UserId;
                        WifiPinsEntry."Uploaded DateTime" := CurrentDateTime;
                        IF NOT WifiPinsEntry.Used THEN BEGIN
                            IF NOT WifiPinsEntry.INSERT THEN
                                WifiPinsEntry.MODIFY;
                            RecCount += 1;
                        END;
                    end;
                END;
                Currline := CSVBuffer."Line No.";
            UNTIL CSVBuffer.NEXT = 0;
        IF RecCount <> 0 THEN BEGIN
            IF GUIALLOWED THEN
                MESSAGE('%1 Data Uploaded.', RecCount);
            // DeleteFile;
        END;
    end;

    var
        CSVBuffer: Record "CSV Buffer" temporary;
}
