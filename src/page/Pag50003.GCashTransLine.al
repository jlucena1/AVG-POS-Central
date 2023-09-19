page 50003 "GCash Trans. Line"
{
    ApplicationArea = All;
    Caption = 'GCash Trans. Line';
    PageType = List;
    SourceTable = "AVG Trans. Line";
    UsageCategory = Lists;
    ShowFilter = false;
    SourceTableView = sorting("Receipt No.", "Line No.") order(ascending) where("Process Type" = filter("Retail Pay" | "Query Transaction" | "Cancel Transaction" | "Refund Transaction"));
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
                field("Receipt No."; Rec."Receipt No.")
                {
                    ToolTip = 'Specifies the value of the Receipt No. field.';
                }
                field("Line No."; Rec."Line No.")
                {
                    ToolTip = 'Specifies the value of the Line No. field.';
                }
                field("Trans. Line No."; Rec."Trans. Line No.")
                {
                    ToolTip = 'Specifies the value of the Trans. Line No. field.';
                }
                field("Process Type"; Rec."Process Type")
                {
                    ToolTip = 'Specifies the value of the AllEasy Process Type field.';
                }
                field("GCash Acquirement ID"; Rec."GCash Acquirement ID")
                {
                    ToolTip = 'Specifies the value of the GCash Acquirement ID field.';
                }
                field("GCash Merchant Trans, ID"; Rec."GCash Merchant Trans. ID")
                {
                    ToolTip = 'Specifies the value of the GCash Merchant Trans, ID field.';
                }
                field("GCash Transaction ID"; Rec."GCash Transaction ID")
                {
                    ToolTip = 'Specifies the value of the GCash Transaction ID field.';
                }
                field("GCash Result Code"; Rec."GCash Result Code")
                {
                    ToolTip = 'Specifies the value of the GCash Result Code field.';
                }
                field("GCash Result CodeId"; Rec."GCash Result CodeId")
                {
                    ToolTip = 'Specifies the value of the GCash Result CodeId field.';
                }
                field("GCash Result Status"; Rec."GCash Result Status")
                {
                    ToolTip = 'Specifies the value of the GCash Result Status field.';
                }
                field("GCash Result Msg"; Rec."GCash Result Msg")
                {
                    ToolTip = 'Specifies the value of the GCash Result Msg field.';
                }
                field("GCash Response Time"; Rec."GCash Response Time")
                {
                    ToolTip = 'Specifies the value of the GCash Response Time field.';
                }
                field(Amount; Rec.Amount)
                {
                    Caption = 'GCash Orig. Amount';
                }
                field("GCash Amount"; Rec."GCash Amount")
                {
                    ToolTip = 'Specifies the value of the GCash Amount field.';
                }
                field("GCash Amount Currency"; Rec."GCash Amount Currency")
                {
                    ToolTip = 'Specifies the value of the GCash Amount Currency field.';
                }
                field("GCash Create Time"; Rec."GCash Create Time")
                {
                    ToolTip = 'Specifies the value of the GCash Create Time field.';
                }
                field("GCash Paid Time"; Rec."GCash Paid Time")
                {
                    ToolTip = 'Specifies the value of the GCash Paid Time field.';
                }
                field("GCash Cancel Time"; Rec."GCash Cancel Time")
                {
                    ToolTip = 'Specifies the value of the GCash Cancel Time field.';
                }
                field("GCash Refund ID"; Rec."GCash Refund ID")
                {
                    ToolTip = 'Specifies the value of the GCash Refund ID field.';
                }
                field("GCash Refund Time"; Rec."GCash Refund Time")
                {
                    ToolTip = 'Specifies the value of the GCash Refund Time field.';
                }
                field("GCash Request"; Rec."GCash Request")
                {
                    ToolTip = 'Specifies the value of the GCash Request field.';

                }
                field("GCash Response"; Rec."GCash Response")
                {
                    ToolTip = 'Specifies the value of the GCash Response field.';
                }
                field("GCash Request ID"; Rec."GCash Request ID")
                {
                    ToolTip = 'Specifies the value of the GCash Request ID field.';
                }

                field("GCash Short Refund ID"; Rec."GCash Short Refund ID")
                {
                    ToolTip = 'Specifies the value of the GCash Short Refund ID field.';
                }
                field("GCash Response Signature"; Rec."GCash Response Signature")
                {
                    ToolTip = 'Specifies the value of the GCash Response Signature field.';
                }
                field("Trans. Date"; Rec."Trans. Date")
                {
                    ToolTip = 'Specifies the value of the Trans. Date field.';
                }
                field("Trans. Time"; Rec."Trans. Time")
                {
                    ToolTip = 'Specifies the value of the Trans. Time field.';
                }
                field("Authorization Code"; Rec."Authorization Code")
                {
                    ToolTip = 'Specifies the value of the Authorization Code field.';
                }
            }
        }
    }
}
