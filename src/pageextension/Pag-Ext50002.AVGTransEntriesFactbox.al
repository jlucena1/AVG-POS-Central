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
                        Caption = 'AllEasy Cash In Entries';
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
                        Caption = 'AllEasy Cash Out Entries';
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
                        Caption = 'AllEasy Pay Entries';
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
                        Caption = 'GCash Pay Entries';
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
                group(Loyalty)
                {
                    field(LoyPoints; LoyaltyEntries)
                    {
                        Caption = 'Loyalty Entries';
                        ApplicationArea = All;
                        trigger OnDrillDown()
                        var
                            LoyaltyEntriesRec: Record "AVG Trans. Line Entry";
                            LoyaltyEntriesPag: Page "Loyalty Trans. Line Entries";
                        begin
                            FilterLoyaltyEntries(LoyaltyEntriesRec);
                            LoyaltyEntriesPag.SETTABLEVIEW(LoyaltyEntriesRec);
                            LoyaltyEntriesPag.EDITABLE(FALSE);
                            LoyaltyEntriesPag.LOOKUPMODE(TRUE);
                            LoyaltyEntriesPag.RUNMODAL;
                        end;
                    }

                }
                group("Loyalty V2")
                {
                    field(LoyaltyEntriesV2; LoyaltyEntriesV2)
                    {
                        Caption = 'Loyalty V2 Entries';
                        ApplicationArea = All;
                        trigger OnDrillDown()
                        var
                            LoyaltyV2EntriesRec: Record "AVG Loyalty V2 Entry";
                            LoyaltyV2EntriesPag: Page "AVG Loyalty V2 Entries";
                        begin
                            FilterLoyaltyV2Entries(LoyaltyV2EntriesRec);
                            LoyaltyV2EntriesPag.SETTABLEVIEW(LoyaltyV2EntriesRec);
                            LoyaltyV2EntriesPag.EDITABLE(FALSE);
                            LoyaltyV2EntriesPag.LOOKUPMODE(TRUE);
                            LoyaltyV2EntriesPag.RUNMODAL;
                        end;
                    }
                }
                group(P2M)
                {
                    field(P2MEntries; P2MEntries)
                    {
                        Caption = 'P2M Entries';
                        ApplicationArea = All;
                        trigger OnDrillDown()
                        var
                            P2MEntriesRec: Record "LSC Trans. Payment Entry";
                            P2MEntriesPag: Page "AVG P2M Entries";
                        begin
                            FilterP2MEntries(P2MEntriesRec);
                            P2MEntriesPag.SETTABLEVIEW(P2MEntriesRec);
                            P2MEntriesPag.EDITABLE(FALSE);
                            P2MEntriesPag.LOOKUPMODE(TRUE);
                            P2MEntriesPag.RUNMODAL;
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
        LoyaltyEntries := GetLoyaltyEntries();
        LoyaltyEntriesV2 := GetLoyaltyV2Entries();
        P2MEntries := GetP2MEntries();
    end;

    var
        AllEasyCashInEntries: Integer;
        AllEasyCashOutEntries: Integer;
        AllEasyPayEntries: Integer;
        GCashPayEntries: Integer;
        LoyaltyEntries: Integer;
        LoyaltyEntriesV2: Integer;
        P2MEntries: Integer;

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

    local procedure FilterLoyaltyEntries(var LoyaltyEntries: Record "AVG Trans. Line Entry")
    begin
        LoyaltyEntries.FilterGroup(2);
        LoyaltyEntries.SetRange("Store No.", Rec."Store No.");
        LoyaltyEntries.SetRange("POS Terminal No.", Rec."POS Terminal No.");
        LoyaltyEntries.setrange("Transaction No.", Rec."Transaction No.");
        LoyaltyEntries.SetFilter("Process Type", '%1|%2|%3',
            LoyaltyEntries."Process Type"::"Loyalty Add Member",
            LoyaltyEntries."Process Type"::"Loyalty Earn Points",
            LoyaltyEntries."Process Type"::"Loyalty Redeem Points");
        LoyaltyEntries.FilterGroup(0);
    end;

    local procedure FilterLoyaltyV2Entries(var LoyaltyV2Entries: Record "AVG Loyalty V2 Entry")
    begin
        LoyaltyV2Entries.FilterGroup(2);
        LoyaltyV2Entries.SetRange("Store No.", Rec."Store No.");
        LoyaltyV2Entries.SetRange("POS Terminal No.", Rec."POS Terminal No.");
        LoyaltyV2Entries.setrange("Transaction No.", Rec."Transaction No.");
        LoyaltyV2Entries.FilterGroup(0);
    end;

    local procedure FilterP2MEntries(var P2MEntries: Record "LSC Trans. Payment Entry")
    begin
        P2MEntries.FilterGroup(2);
        P2MEntries.SetRange("Store No.", Rec."Store No.");
        P2MEntries.SetRange("POS Terminal No.", Rec."POS Terminal No.");
        P2MEntries.setrange("Transaction No.", Rec."Transaction No.");
        P2MEntries.SetFilter("P2M Merch Token", '<>%1', '');
        P2MEntries.FilterGroup(0);
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

    local procedure GetLoyaltyEntries(): Decimal
    var
        LoyaltyEntriesRec: Record "AVG Trans. Line Entry";
    begin
        FilterLoyaltyEntries(LoyaltyEntriesRec);
        EXIT(LoyaltyEntriesRec.Count);
    end;

    local procedure GetLoyaltyV2Entries(): Decimal
    var
        LoyaltyV2EntriesRec: Record "AVG Loyalty V2 Entry";
    begin
        FilterLoyaltyV2Entries(LoyaltyV2EntriesRec);
        EXIT(LoyaltyV2EntriesRec.Count);
    end;

    local procedure GetP2MEntries(): Decimal
    var
        P2MEntriesRec: Record "LSC Trans. Payment Entry";
    begin
        FilterP2MEntries(P2MEntriesRec);
        EXIT(P2MEntriesRec.Count);
    end;
}