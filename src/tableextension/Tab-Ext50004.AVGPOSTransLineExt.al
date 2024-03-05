tableextension 50004 "AVG POS Trans. Line Ext." extends "LSC POS Trans. Line"
{
    fields
    {
        field(50000; "P2M Merch Token"; Text[20])
        {
            Caption = 'P2M Merch Token';
            DataClassification = CustomerContent;
        }
        field(50001; "P2M Amount"; Decimal)
        {
            Caption = 'P2M Amount';
            DataClassification = CustomerContent;
        }
        field(50002; "P2M Bank Refrence"; Integer)
        {
            Caption = 'P2M Bank Refrence';
            DataClassification = CustomerContent;
        }
        field(50003; "P2M Payment Reference"; Text[100])
        {
            Caption = 'P2M Payment Reference';
            DataClassification = CustomerContent;
        }
        field(50004; "P2M Payment Channel"; Text[100])
        {
            Caption = 'P2M Payment Channel';
            DataClassification = CustomerContent;
        }
        field(50005; "P2M Payment Date & Time"; Text[50])
        {
            Caption = 'P2M Payment Date & Time';
            DataClassification = CustomerContent;
        }
        field(50006; "P2M Status"; Text[50])
        {
            Caption = 'P2M Status';
            DataClassification = CustomerContent;
        }
        field(50007; "P2M Message"; Text[100])
        {
            Caption = 'P2M Message';
            DataClassification = CustomerContent;
        }
    }
}
