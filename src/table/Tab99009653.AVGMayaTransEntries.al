table 99009653 "AVG Maya Trans. Entries"
{
    Caption = 'AVG Maya Trans. Entries';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Store No."; Code[20])
        {
            Caption = 'Store No.';
            TableRelation = "LSC Store";
        }
        field(2; "POS Terminal No."; Code[20])
        {
            Caption = 'POS Terminal No.';
            TableRelation = "LSC POS Terminal";
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
        field(6; "Parent Line No."; Integer)
        {
            Caption = 'Parent Line No.';
        }
        field(7; "Maya Aid"; Text[60])
        {
            Caption = 'Maya Aid';
        }
        field(8; "Maya App"; Text[60])
        {
            Caption = 'Maya App';
        }
        field(9; "Maya Atc"; Text[60])
        {
            Caption = 'Maya Atc';
        }
        field(10; "Maya Auth Code"; Text[60])
        {
            Caption = 'Maya Auth Code';
        }
        field(11; "Maya Batch No."; Text[60])
        {
            Caption = 'Maya Batch No.';
        }
        field(12; "Maya Card Bin"; Text[60])
        {
            Caption = 'Maya Card Bin';
        }
        field(13; "Maya Card Type"; Text[60])
        {
            Caption = 'Maya Card Type';
        }
        field(14; "Maya Enter Mode"; Text[60])
        {
            Caption = 'Maya Enter Mode';
        }
        field(15; "Maya Enter Mode Code"; Text[60])
        {
            Caption = 'Maya Enter Mode Code';
        }
        field(16; "Maya Merchant ID"; Text[60])
        {
            Caption = 'Maya Merchant ID';
        }
        field(17; "Maya Merchant Ref. No."; Text[60])
        {
            Caption = 'Maya Merchant Ref. No.';
        }
        field(18; "Maya Pan"; Text[60])
        {
            Caption = 'Maya Pan';
        }
        field(19; "Maya Reference No."; Text[60])
        {
            Caption = 'Maya Reference No.';
        }
        field(20; "Maya Response Code"; Text[60])
        {
            Caption = 'Maya Response Code';
        }
        field(21; "Maya Response Text"; Text[60])
        {
            Caption = 'Maya Response Text';
        }
        field(22; "Maya Status"; Text[60])
        {
            Caption = 'Maya Status';
        }
        field(23; "Maya Tender Type"; Text[60])
        {
            Caption = 'Maya Tender Type';
        }
        field(24; "Maya Terminal ID"; Text[60])
        {
            Caption = 'Maya Terminal ID';
        }
        field(25; "Maya TSI"; Text[60])
        {
            Caption = 'Maya TSI';
        }
        field(26; "Maya TVR"; Text[60])
        {
            Caption = 'Maya TVR';
        }
        field(27; "Maya Txn Date"; Text[60])
        {
            Caption = 'Maya Txn Date';
        }
        field(28; "Maya Txn ID"; Text[60])
        {
            Caption = 'Maya Txn ID';
        }
        field(29; "Maya Txn Time"; Text[60])
        {
            Caption = 'Maya Txn Time';
        }
        field(30; "Maya Txn Type"; Text[60])
        {
            Caption = 'Maya Txn Type';
        }
        field(31; "Maya Amount"; Text[60])
        {
            Caption = 'Maya Amount';
        }
        field(32; "Actual Amount"; Decimal)
        {
            Caption = 'Actual Amount';
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
