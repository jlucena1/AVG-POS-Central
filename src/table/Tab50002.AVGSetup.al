table 50002 "AVG Setup"
{
    Caption = 'AVG Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Key"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(2; "Prompt Messages Format"; Enum "AVG Prompt Messages")
        {
            DataClassification = CustomerContent;
        }
        field(3; "Last Date Modified"; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(4; "Last Modified By"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(5; "Date Initialized"; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(6; "Initialized By"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(7; "Error Prompt Messages Format"; Enum "AVG Error Prompt Messages")
        {
            DataClassification = CustomerContent;
        }
        field(9; "Hide Values on Keyboard"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(10; "AVG Company Code"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(11; "Auto Retrieve Tender on Refund"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(12; "Wifi Pins"; Boolean)
        {
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Key")
        {
            Clustered = true;
        }
    }
    trigger OnModify()

    begin
        "Last Date Modified" := CurrentDateTime;
        "Last Modified By" := UserId;
    end;
}
