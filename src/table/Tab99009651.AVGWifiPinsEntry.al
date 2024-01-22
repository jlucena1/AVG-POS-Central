table 99009651 "AVG Wifi Pins Entry"
{
    Caption = 'AVG Wifi Pins Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(2; "File Entry No."; Integer)
        {
            Caption = 'File Entry No.';
        }
        field(3; "Account PIN"; Text[100])
        {
            Caption = 'Account PIN';
        }
        field(4; Used; Boolean)
        {
            Caption = 'Used';
        }
        field(5; "Uploaded By"; Text[250])
        {
            Caption = 'Uploaded By';
        }
        field(6; "Uploaded DateTime"; DateTime)
        {
            Caption = 'Uploaded DateTime';
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}
