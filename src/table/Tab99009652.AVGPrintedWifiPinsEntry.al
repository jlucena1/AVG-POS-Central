table 99009652 "AVG Printed Wifi Pins Entry"
{
    Caption = 'AVG Printed Wifi Pins Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Store No."; Code[20])
        {
        }
        field(2; "POS Terminal No."; Code[20])
        {
        }
        field(3; "Transaction No."; Integer)
        {
        }
        field(4; "Receipt No."; Code[20])
        {
        }
        field(5; "Printed Date"; Date)
        {
        }
        field(6; "Printed Time"; Time)
        {
        }
        field(7; "Staff ID"; Code[20])
        {
        }
        field(8; "Account PIN"; Text[100])
        {
        }
    }

    keys
    {
        key(PK; "Store No.", "POS Terminal No.", "Transaction No.")
        {
            Clustered = true;
        }
    }
}


