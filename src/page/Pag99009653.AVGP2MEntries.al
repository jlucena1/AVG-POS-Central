page 99009653 "AVG P2M Entries"
{
    ApplicationArea = All;
    Caption = 'AVG P2M Entries';
    SourceTable = "LSC Trans. Payment Entry";
    SourceTableView = where("P2M Merch Token" = filter(<> ''));
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
                field("P2M Merch Token"; Rec."P2M Merch Token")
                {
                    ToolTip = 'Specifies the value of the P2M Merch Token field.';
                }
                field("P2M Bank Refrence"; Rec."P2M Bank Refrence")
                {
                    ToolTip = 'Specifies the value of the P2M Bank Refrence field.';
                }
                field("P2M Amount"; Rec."P2M Amount")
                {
                    ToolTip = 'Specifies the value of the P2M Amount field.';
                }
                field("P2M Payment Channel"; Rec."P2M Payment Channel")
                {
                    ToolTip = 'Specifies the value of the P2M Payment Channel field.';
                }
                field("P2M Payment Date & Time"; Rec."P2M Payment Date & Time")
                {
                    ToolTip = 'Specifies the value of the P2M Payment Date & Time field.';
                }
                field("P2M Payment Reference"; Rec."P2M Payment Reference")
                {
                    ToolTip = 'Specifies the value of the P2M Payment Reference field.';
                }
                field("P2M Message"; Rec."P2M Message")
                {
                    ToolTip = 'Specifies the value of the P2M Message field.';
                }
                field("P2M Status"; Rec."P2M Status")
                {
                    ToolTip = 'Specifies the value of the P2M Status field.';
                }
            }
        }
    }
}
