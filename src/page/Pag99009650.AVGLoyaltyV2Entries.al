page 99009650 "AVG Loyalty V2 Entries"
{
    ApplicationArea = All;
    Caption = 'AVG Loyalty V2 Entries';
    PageType = List;
    SourceTable = "AVG Loyalty V2 Entry";
    UsageCategory = History;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Editable = false;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Store No."; Rec."Store No.")
                {
                    ToolTip = 'Specifies the value of the Store No. field.';
                }
                field("POS Terminal No."; Rec."POS Terminal No.")
                {
                    ToolTip = 'Specifies the value of the POS Terminal No. field.';
                }
                field("Transaction No."; Rec."Transaction No.")
                {
                    ToolTip = 'Specifies the value of the Transaction No. field.';
                }
                field("Line No."; Rec."Line No.")
                {
                    ToolTip = 'Specifies the value of the Line No. field.';
                }
                field("Receipt No."; Rec."Receipt No.")
                {
                    ToolTip = 'Specifies the value of the Receipt No. field.';
                }
                field("Card Number Last 4"; Rec."Card Number Last 4")
                {
                    ToolTip = 'Specifies the value of the Card Number Last 4 field.';
                }
                field("Member Full Name"; Rec."Member Full Name")
                {
                    ToolTip = 'Specifies the value of the Member Full Name field.';
                }
                field("Member Birthday"; Rec."Member Birthday")
                {
                    ToolTip = 'Specifies the value of the Member Birthday field.';
                    ExtendedDatatype = Masked;
                }
                field("Member Current Points"; Rec."Member Current Points")
                {
                    ToolTip = 'Specifies the value of the Member Current Points field.';
                }
                field("Member Mobile No."; Rec."Member Mobile No.")
                {
                    ToolTip = 'Specifies the value of the Member Mobile No. field.';
                    ExtendedDatatype = Masked;
                }
                field("Member Email"; Rec."Member Email")
                {
                    ToolTip = 'Specifies the value of the Member Email field.';
                    ExtendedDatatype = Masked;
                }
                field("Member Tier"; Rec."Member Tier")
                {
                    ToolTip = 'Specifies the value of the Member Tier field.';
                }
                field("Orig. Store No."; Rec."Orig. Store No.")
                {
                    ToolTip = 'Specifies the value of the Orig. Store No. field.';
                }
                field("Orig. POS Terminal No."; Rec."Orig. POS Terminal No.")
                {
                    ToolTip = 'Specifies the value of the Orig. POS Terminal No. field.';
                }
                field("Orig. Transaction No."; Rec."Orig. Transaction No.")
                {
                    ToolTip = 'Specifies the value of the Orig. Transaction No. field.';
                }
                field("Orig. Receipt No."; Rec."Orig. Receipt No.")
                {
                    ToolTip = 'Specifies the value of the Orig. Receipt No. field.';
                }
                field("Orig. Res. Trans. ID"; Rec."Orig. Res. Trans. ID")
                {
                    ToolTip = 'Specifies the value of the Orig. Res. Trans. ID field.';
                }
                field("Res. ID"; Rec."Res. ID")
                {
                    ToolTip = 'Specifies the value of the Res. ID field.';
                }
                field("Res. Action"; Rec."Res. Action")
                {
                    ToolTip = 'Specifies the value of the Res. Action field.';
                }
                field("Res. Member ID"; Rec."Res. Member ID")
                {
                    ToolTip = 'Specifies the value of the Res. Member ID field.';
                }
                field("Res. Cancel Trans. ID"; Rec."Res. Cancel Trans. ID")
                {
                    ToolTip = 'Specifies the value of the Res. Cancel Trans. ID field.';
                }
                field("Res. Message"; Rec."Res. Message")
                {
                    ToolTip = 'Specifies the value of the Res. Message field.';
                }
                field("Res. New Tier"; Rec."Res. New Tier")
                {
                    ToolTip = 'Specifies the value of the Res. New Tier field.';
                }
                field("Res. Points"; Rec."Res. Points")
                {
                    ToolTip = 'Specifies the value of the Res. Points field.';
                }
                field("Res. Promo Code"; Rec."Res. Promo Code")
                {
                    ToolTip = 'Specifies the value of the Res. Promo Code field.';
                }
                field("Res. Status"; Rec."Res. Status")
                {
                    ToolTip = 'Specifies the value of the Res. Status field.';
                }
                field("Res. Tier ID"; Rec."Res. Tier ID")
                {
                    ToolTip = 'Specifies the value of the Res. Tier ID field.';
                }
                field("Res. Time Stamp"; Rec."Res. Time Stamp")
                {
                    ToolTip = 'Specifies the value of the Res. Time Stamp field.';
                }
                field("Res. Trans. ID"; Rec."Res. Trans. ID")
                {
                    ToolTip = 'Specifies the value of the Res. Trans. ID field.';
                }
                field("Res. Unit ID"; Rec."Res. Unit ID")
                {
                    ToolTip = 'Specifies the value of the Res. Unit ID field.';
                }
                field("Res. Valid Email"; Rec."Res. Valid Email")
                {
                    ToolTip = 'Specifies the value of the Res. Valid Email field.';
                }
                field("Res. Transaction Count"; Rec."Res. Transaction Count")
                {
                    ToolTip = 'Specifies the value of the Res. Transaction Count field.';
                }
                field(Processed; Rec.Processed)
                {
                    ToolTip = 'Specifies the value of the Processed field.';
                }
                field("Trans. Date"; Rec."Trans. Date")
                {
                    ToolTip = 'Specifies the value of the Trans. Date field.';
                }
                field("Trans. Time"; Rec."Trans. Time")
                {
                    ToolTip = 'Specifies the value of the Trans. Time field.';
                }
            }
        }
    }
}
