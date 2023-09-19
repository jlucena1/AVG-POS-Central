pageextension 50002 "AVG Trans. Entries Factbox" extends "LSC Transaction Factbox"
{
    layout
    {
        addafter(General)
        {
            group("AVG POS Transaction Entries")
            {

                group(AllEasy)
                {
                    field(AllEasyCashIn; AllEasyCashInEntries)
                    {
                        Caption = 'AllEasy Cash In';
                        ApplicationArea = All;
                        trigger OnDrillDown()
                        var
                            AllEasyCashInEntriesRec: Record "AVG Trans. Line Entry";
                            AllEasyCashInEntriesPag: Page "AllEasy Trans. Line Entries";
                        begin
                            FilterAllEasyCashInEntries(AllEasyCashInEntriesRec);
                            AllEasyCashInEntriesPag.SETTABLEVIEW(AllEasyCashInEntriesRec);
                            AllEasyCashInEntriesPag.EDITABLE(FALSE);
                            AllEasyCashInEntriesPag.LOOKUPMODE(TRUE);
                            AllEasyCashInEntriesPag.RUNMODAL;
                        end;
                    }
                    field(AllEasyCashOut; AllEasyCashOutEntries)
                    {
                        Caption = 'AllEasy Cash Out';
                        ApplicationArea = All;
                        trigger OnDrillDown()
                        var
                            AllEasyCashOutEntriesRec: Record "AVG Trans. Line Entry";
                            AllEasyCashOutEntriesPag: Page "AllEasy Trans. Line Entries";
                        begin
                            FilterAllEasyCashOutEntries(AllEasyCashOutEntriesRec);
                            AllEasyCashOutEntriesPag.SETTABLEVIEW(AllEasyCashOutEntriesRec);
                            AllEasyCashOutEntriesPag.EDITABLE(FALSE);
                            AllEasyCashOutEntriesPag.LOOKUPMODE(TRUE);
                            AllEasyCashOutEntriesPag.RUNMODAL;
                        end;

                    }
                    field(AllEasyPayQR; AllEasyPayEntries)
                    {
                        Caption = 'AllEasy Pay';
                        ApplicationArea = All;
                        trigger OnDrillDown()
                        var
                            AllEasyPayEntriesRec: Record "AVG Trans. Line Entry";
                            AllEasyPayEntriesPag: Page "AllEasy Trans. Line Entries";
                        begin
                            FilterAllEasyPayEntries(AllEasyPayEntriesRec);
                            AllEasyPayEntriesPag.SETTABLEVIEW(AllEasyPayEntriesRec);
                            AllEasyPayEntriesPag.EDITABLE(FALSE);
                            AllEasyPayEntriesPag.LOOKUPMODE(TRUE);
                            AllEasyPayEntriesPag.RUNMODAL;
                        end;
                    }
                }
                group(GCash)
                {
                    field(GCashPay; GCashPayEntries)
                    {
                        Caption = 'GCash Pay';
                        ApplicationArea = All;
                        trigger OnDrillDown()
                        var
                            GCashPayEntriesRec: Record "AVG Trans. Line Entry";
                            GCashPayEntriesPag: Page "GCash Trans. Line Entries";
                        begin
                            FilterGCashPayEntries(GCashPayEntriesRec);
                            GCashPayEntriesPag.SETTABLEVIEW(GCashPayEntriesRec);
                            GCashPayEntriesPag.EDITABLE(FALSE);
                            GCashPayEntriesPag.LOOKUPMODE(TRUE);
                            GCashPayEntriesPag.RUNMODAL;
                        end;
                    }
                }
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        AllEasyCashInEntries := GetAllEasyCashInEntries();
        AllEasyCashOutEntries := GetAllEasyCashOutEntries();
        AllEasyPayEntries := GetAllEasyPayEntries();
        GCashPayEntries := GetGCashPayEntries();
    end;

    var
        AllEasyCashInEntries: Integer;
        AllEasyCashOutEntries: Integer;
        AllEasyPayEntries: Integer;
        GCashPayEntries: Integer;

    local procedure FilterAllEasyCashInEntries(var AllEasyCashInEntries: Record "AVG Trans. Line Entry")
    begin
        AllEasyCashInEntries.FilterGroup(2);
        AllEasyCashInEntries.SetRange("Store No.", Rec."Store No.");
        AllEasyCashInEntries.SetRange("POS Terminal No.", Rec."POS Terminal No.");
        AllEasyCashInEntries.setrange("Transaction No.", Rec."Transaction No.");
        AllEasyCashInEntries.SetFilter("Process Type", '%1|%2', AllEasyCashInEntries."Process Type"::"Cash In Inquire", AllEasyCashInEntries."Process Type"::"Cash In Credit");
        AllEasyCashInEntries.FilterGroup(0);
    end;

    local procedure FilterAllEasyCashOutEntries(var AllEasyCashOutEntries: Record "AVG Trans. Line Entry")
    begin
        AllEasyCashOutEntries.FilterGroup(2);
        AllEasyCashOutEntries.SetRange("Store No.", Rec."Store No.");
        AllEasyCashOutEntries.SetRange("POS Terminal No.", Rec."POS Terminal No.");
        AllEasyCashOutEntries.setrange("Transaction No.", Rec."Transaction No.");
        AllEasyCashOutEntries.SetFilter("Process Type", '%1|%2', AllEasyCashOutEntries."Process Type"::"Cash Out Inquire", AllEasyCashOutEntries."Process Type"::"Cash Out Process");
        AllEasyCashOutEntries.FilterGroup(0);
    end;

    local procedure FilterAllEasyPayEntries(var AllEasyPayEntries: Record "AVG Trans. Line Entry")
    begin
        AllEasyPayEntries.FilterGroup(2);
        AllEasyPayEntries.SetRange("Store No.", Rec."Store No.");
        AllEasyPayEntries.SetRange("POS Terminal No.", Rec."POS Terminal No.");
        AllEasyPayEntries.setrange("Transaction No.", Rec."Transaction No.");
        AllEasyPayEntries.SetFilter("Process Type", '%1|%2', AllEasyPayEntries."Process Type"::"Pay QR Inquire", AllEasyPayEntries."Process Type"::"Pay QR Process");
        AllEasyPayEntries.FilterGroup(0);
    end;

    local procedure FilterGCashPayEntries(var GCashPayEntries: Record "AVG Trans. Line Entry")
    begin
        GCashPayEntries.FilterGroup(2);
        GCashPayEntries.SetRange("Store No.", Rec."Store No.");
        GCashPayEntries.SetRange("POS Terminal No.", Rec."POS Terminal No.");
        GCashPayEntries.setrange("Transaction No.", Rec."Transaction No.");
        GCashPayEntries.SetFilter("Process Type", '%1|%2|%3|%4',
            GCashPayEntries."Process Type"::"Retail Pay",
            GCashPayEntries."Process Type"::"Cancel Transaction",
            GCashPayEntries."Process Type"::"Query Transaction",
            GCashPayEntries."Process Type"::"Refund Transaction");
        GCashPayEntries.FilterGroup(0);
    end;

    local procedure GetAllEasyCashInEntries(): Decimal
    var
        AllEasyCashInRec: Record "AVG Trans. Line Entry";
    begin
        FilterAllEasyCashInEntries(AllEasyCashInRec);
        EXIT(AllEasyCashInRec.Count);
    end;

    local procedure GetAllEasyCashOutEntries(): Decimal
    var
        AllEasyCashOutEntriesRec: Record "AVG Trans. Line Entry";
    begin
        FilterAllEasyCashOutEntries(AllEasyCashOutEntriesRec);
        EXIT(AllEasyCashOutEntriesRec.Count);
    end;

    local procedure GetAllEasyPayEntries(): Decimal
    var
        AllEasyPayEntriesRec: Record "AVG Trans. Line Entry";
    begin
        FilterAllEasyPayEntries(AllEasyPayEntriesRec);
        EXIT(AllEasyPayEntriesRec.Count);
    end;

    local procedure GetGCashPayEntries(): Decimal
    var
        GCashPayEntriesRec: Record "AVG Trans. Line Entry";
    begin
        FilterGCashPayEntries(GCashPayEntriesRec);
        EXIT(GCashPayEntriesRec.Count);
    end;
}