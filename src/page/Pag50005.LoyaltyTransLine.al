page 50005 "Loyalty Trans. Line"
{
    ApplicationArea = All;
    Caption = 'Loyalty Trans. Line';
    PageType = List;
    SourceTable = "AVG Trans. Line";
    UsageCategory = Lists;
    ShowFilter = false;
    SourceTableView = sorting("Receipt No.", "Line No.") order(ascending) where("Process Type" = filter("Loyalty Add Member" | "Loyalty Earn Points" | "Loyalty Redeem Points"));
    layout
    {
        area(content)
        {
            repeater(General)
            {

                field("Receipt No."; Rec."Receipt No.")
                {
                    ToolTip = 'Specifies the value of the Receipt No. field.';
                }
                field("Line No."; Rec."Line No.")
                {
                    ToolTip = 'Specifies the value of the Line No. field.';
                }
                field("Store No."; Rec."Store No.")
                {
                    ToolTip = 'Specifies the value of the Store No. field.';
                }
                field("POS Terminal No."; Rec."POS Terminal No.")
                {
                    ToolTip = 'Specifies the value of the POS Terminal No. field.';
                }
                field("Trans. Date"; Rec."Trans. Date")
                {
                    ToolTip = 'Specifies the value of the Trans. Date field.';
                }
                field("Trans. Time"; Rec."Trans. Time")
                {
                    ToolTip = 'Specifies the value of the Trans. Time field.';
                }
                field("Process Type"; Rec."Process Type")
                {
                    ToolTip = 'Specifies the value of the AllEasy Process Type field.';
                }
                field("Trans. Line No."; Rec."Trans. Line No.")
                {
                    ToolTip = 'Specifies the value of the Trans. Line No. field.';
                }

                field("Loyalty Member Last Visited"; Rec."Loyalty Member Last Visited")
                {
                    ToolTip = 'Specifies the value of the Loyalty Member Last Visited field.';
                }
                field("Loyalty Member Full Name"; Rec."Loyalty Member Full Name")
                {
                    ToolTip = 'Specifies the value of the Loyalty Member Full Name field.';
                }
                field("Loyalty Member Balance"; Rec."Loyalty Member Balance")
                {
                    ToolTip = 'Specifies the value of the Loyalty Member Balance field.';
                }
                field("Loyalty Points Earned"; Rec."Loyalty Points Earned")
                {
                    ToolTip = 'Specifies the value of the Loyalty Points Earned field.';
                }
                field("Loyalty Points Redeemed"; Rec."Loyalty Points Redeemed")
                {
                    ToolTip = 'Specifies the value of the Loyalty Points Redeemed field.';
                }
                field("Loyalty Card Number Last 4"; Rec."Loyalty Card Number Last 4")
                {
                    ToolTip = 'Specifies the value of the Loyalty Card Number Last 4 field.';

                }
                field("Loyalty Request"; Rec."Loyalty Request")
                {
                    ToolTip = 'Specifies the value of the Loyalty Request field.';
                }
                field("Loyalty Response"; Rec."Loyalty Response")
                {
                    ToolTip = 'Specifies the value of the Loyalty Response field.';
                }
            }
        }
    }
}
