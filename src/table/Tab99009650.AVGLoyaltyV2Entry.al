table 99009650 "AVG Loyalty V2 Entry"
{
    Caption = 'AVG Loyalty V2 Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Store No."; Code[10])
        {
            Caption = 'Store No.';
            TableRelation = "LSC Store"."No.";
        }
        field(2; "POS Terminal No."; Code[10])
        {
            Caption = 'POS Terminal No.';
            TableRelation = "LSC POS Terminal"."No.";
        }
        field(3; "Transaction No."; Integer)
        {
            Caption = 'Transaction No.';
        }
        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(5; "Receipt No."; Code[20])
        {
            Caption = 'Receipt No.';
        }
        field(6; "Member Full Name"; Text[250])
        {
            Caption = 'Member Full Name';
        }
        field(7; "Member Current Points"; Decimal)
        {
            Caption = 'Member Current Points';
        }
        field(8; "Member Email"; Text[150])
        {
            Caption = 'Member Email';
        }
        field(9; "Member Mobile No."; Text[30])
        {
            Caption = 'Member Mobile No.';
        }
        field(10; "Member Birthday"; Date)
        {
            Caption = 'Member Birthday';
        }
        field(11; "Member Tier"; Text[30])
        {
            Caption = 'Member Tier';
        }
        field(12; "Card Number"; Code[20])
        {
            Caption = 'Card Number';
        }
        field(13; "Card Number Last 4"; Code[20])
        {
            Caption = 'Card Number Last 4';
        }
        field(14; "Res. Transaction Count"; Integer)
        {
            Caption = 'Res. Transaction Count';
        }
        field(15; "Res. ID"; Integer)
        {
            Caption = 'Res. ID';
        }
        field(16; "Res. Trans. ID"; Text[100])
        {
            Caption = 'Res. Trans. ID';
        }
        field(17; "Res. Member ID"; Text[30])
        {
            Caption = 'Res. Member ID';
        }
        field(18; "Res. Action"; Text[30])
        {
            Caption = 'Res. Action';
        }
        field(19; "Res. Points"; Decimal)
        {
            Caption = 'Res. Points';
        }
        field(20; "Res. Unit ID"; Text[30])
        {
            Caption = 'Res. Unit ID';
        }
        field(21; "Res. Tier ID"; Text[30])
        {
            Caption = 'Res. Tier ID';
        }
        field(22; "Res. Promo Code"; Code[50])
        {
            Caption = 'Res. Promo Code';
        }
        field(23; "Res. Status"; Text[30])
        {
            Caption = 'Res. Status';
        }
        field(24; "Res. Time Stamp"; Text[30])
        {
            Caption = 'Res. Time Stamp';
        }
        field(25; "Res. New Tier"; Boolean)
        {
            Caption = 'Res. New Tier';
        }
        field(26; "Res. Valid Email"; Boolean)
        {
            Caption = 'Res. Valid Email';
        }
        field(27; "Res. Cancel Trans. ID"; Text[100])
        {
            Caption = 'Res. Cancel Trans. ID';
        }
        field(28; "Orig. Store No."; Code[10])
        {
            Caption = 'Orig. Store No.';
        }
        field(29; "Orig. POS Terminal No."; Code[10])
        {
            Caption = 'Orig. POS Terminal No.';
        }
        field(30; "Orig. Transaction No."; Integer)
        {
            Caption = 'Orig. Transaction No.';
        }
        field(31; "Orig. Receipt No."; Code[20])
        {
            Caption = 'Orig. Receipt No.';
        }
        field(32; "Res. Message"; Text[100])
        {
            Caption = 'Res. Message';
        }
        field(33; "Orig. Res. Trans. ID"; Text[100])
        {
            Caption = 'Orig. Res. Trans. ID';
        }
        field(34; Processed; Boolean)
        {
            Caption = 'Processed';
        }
        field(35; "Trans. Date"; Date)
        {
            Caption = 'Trans. Date';
        }
        field(36; "Trans. Time"; Time)
        {
            Caption = 'Trans. Time';
        }
    }
    keys
    {
        key(PK; "Store No.", "POS Terminal No.", "Transaction No.", "Line No.")
        {
            Clustered = true;
        }
    }
}
