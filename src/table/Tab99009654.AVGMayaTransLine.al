table 99009654 "AVG Maya Trans. Line"
{
    Caption = 'AVG Maya Trans. Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Store No."; Code[20])
        {
            Caption = 'Store No.';
            TableRelation = "LSC Store";
        }
        field(3; "POS Terminal No."; Code[20])
        {
            Caption = 'POS Terminal No.';
            TableRelation = "LSC POS Terminal";
        }
        field(2; "Receipt No."; Code[20])
        {
            Caption = 'Receipt No.';
        }
        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }

        field(5; "Parent Line No."; Integer)
        {
            Caption = 'Parent Line No.';
        }
        field(6; "Maya Aid"; Text[60])
        {
            Caption = 'Maya Aid';
        }
        field(7; "Maya App"; Text[60])
        {
            Caption = 'Maya App';
        }
        field(8; "Maya Atc"; Text[60])
        {
            Caption = 'Maya Atc';
        }
        field(9; "Maya Auth Code"; Text[60])
        {
            Caption = 'Maya Auth Code';
        }
        field(10; "Maya Batch No."; Text[60])
        {
            Caption = 'Maya Batch No.';
        }
        field(11; "Maya Card Bin"; Text[60])
        {
            Caption = 'Maya Card Bin';
        }
        field(12; "Maya Card Type"; Text[60])
        {
            Caption = 'Maya Card Type';
        }
        field(13; "Maya Enter Mode"; Text[60])
        {
            Caption = 'Maya Enter Mode';
        }
        field(14; "Maya Enter Mode Code"; Text[60])
        {
            Caption = 'Maya Enter Mode Code';
        }
        field(15; "Maya Merchant ID"; Text[60])
        {
            Caption = 'Maya Merchant ID';
        }
        field(16; "Maya Merchant Ref. No."; Text[60])
        {
            Caption = 'Maya Merchant Ref. No.';
        }
        field(17; "Maya Pan"; Text[60])
        {
            Caption = 'Maya Pan';
        }
        field(18; "Maya Reference No."; Text[60])
        {
            Caption = 'Maya Reference No.';
        }
        field(19; "Maya Response Code"; Text[60])
        {
            Caption = 'Maya Response Code';
        }
        field(20; "Maya Response Text"; Text[60])
        {
            Caption = 'Maya Response Text';
        }
        field(21; "Maya Status"; Text[60])
        {
            Caption = 'Maya Status';
        }
        field(22; "Maya Tender Type"; Text[60])
        {
            Caption = 'Maya Tender Type';
        }
        field(23; "Maya Terminal ID"; Text[60])
        {
            Caption = 'Maya Terminal ID';
        }
        field(24; "Maya TSI"; Text[60])
        {
            Caption = 'Maya TSI';
        }
        field(25; "Maya TVR"; Text[60])
        {
            Caption = 'Maya TVR';
        }
        field(26; "Maya Txn Date"; Text[60])
        {
            Caption = 'Maya Txn Date';
        }
        field(27; "Maya Txn ID"; Text[60])
        {
            Caption = 'Maya Txn ID';
        }
        field(28; "Maya Txn Time"; Text[60])
        {
            Caption = 'Maya Txn Time';
        }
        field(29; "Maya Txn Type"; Text[60])
        {
            Caption = 'Maya Txn Type';
        }
        field(30; "Maya Amount"; Text[60])
        {
            Caption = 'Maya Amount';
        }
        field(31; "Actual Amount"; Decimal)
        {
            Caption = 'Actual Amount';
        }
    }
    keys
    {
        key(PK; "Receipt No.", "Line No.", "Store No.", "POS Terminal No.")
        {
            Clustered = true;
        }
    }
}
