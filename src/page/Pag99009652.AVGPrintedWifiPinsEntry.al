page 99009652 "AVG Printed Wifi Pins Entry"
{
    ApplicationArea = All;
    Caption = 'Printed Wifi Pins Entry';
    PageType = List;
    SourceTable = "AVG Printed Wifi Pins Entry";
    UsageCategory = History;

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
                field("Receipt No."; Rec."Receipt No.")
                {
                    ToolTip = 'Specifies the value of the Receipt No. field.';
                }
                field("Printed Date"; Rec."Printed Date")
                {
                    ToolTip = 'Specifies the value of the Printed Date field.';
                }
                field("Printed Time"; Rec."Printed Time")
                {
                    ToolTip = 'Specifies the value of the Printed Time field.';
                }
                field("Staff ID"; Rec."Staff ID")
                {
                    ToolTip = 'Specifies the value of the Staff ID field.';
                }
            }
        }
    }
}
