page 50001 "AllEasy Trans. Line Entries"
{
    ApplicationArea = All;
    Caption = 'AllEasy Trans. Line Entries';
    PageType = List;
    SourceTable = "AVG Trans. Line Entry";
    UsageCategory = History;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    SourceTableView = sorting("Store No.", "POS Terminal No.", "Transaction No.", "Line No.") order(ascending) where("Process Type" = filter("Cash In Inquire" | "Cash In Credit" | "Cash Out Inquire" | "Cash Out Process" | "Pay QR Inquire" | "Pay QR Process"));
    layout
    {
        area(content)
        {
            repeater(General)
            {

                field("Transaction No."; Rec."Transaction No.")
                {

                }
                field("Line No."; Rec."Line No.")
                {
                    ToolTip = 'Specifies the value of the Line No. field.';
                }
                field("Receipt No."; Rec."Receipt No.")
                {
                    ToolTip = 'Specifies the value of the Receipt No. field.';
                }

                field("Trans. Line No."; Rec."Trans. Line No.")
                {
                    ToolTip = 'Specifies the value of the Trans. Line No. field.';
                }
                field("Process Type"; Rec."Process Type")
                {
                    ToolTip = 'Specifies the value of the AllEasy Process Type field.';
                }
                field("Trans. Date"; Rec."Trans. Date")
                {
                    ToolTip = 'Specifies the value of the Trans. Date field.';
                }
                field("Trans. Time"; Rec."Trans. Time")
                {
                    ToolTip = 'Specifies the value of the Trans. Time field.';
                }
                field("Trans. Ref. No."; Rec."Trans. Ref. No.")
                {
                    ToolTip = 'Specifies the value of the Trans. Ref. No. field.';
                }
                field(Amount; Rec.Amount)
                {
                    ToolTip = 'Specifies the value of the Amount field.';
                }
                field("Res. Cash In/Out Address"; Rec."Res. Cash In/Out Address")
                {
                    ToolTip = 'Specifies the value of the Res. Cash In/Out Address field.';
                }
                field("Res. Cash In/Out Amount"; Rec."Res. Cash In/Out Amount")
                {
                    ToolTip = 'Specifies the value of the Res. Cash In/Out Amount field.';
                }
                field("Res. Cash In/Out Birthdate"; Rec."Res. Cash In/Out Birthdate")
                {
                    ToolTip = 'Specifies the value of the Res. Cash In/Out Birthdate field.';
                }
                field("Res. Cash In/Out Code"; Rec."Res. Cash In/Out Code")
                {
                    ToolTip = 'Specifies the value of the Res. Cash In/Out Code field.';
                }
                field("Res. Cash In/Out Date"; Rec."Res. Cash In/Out Date")
                {
                    ToolTip = 'Specifies the value of the Res. Cash In/Out Date field.';
                }
                field("Res. Cash In First Name"; Rec."Res. Cash In First Name")
                {
                    ToolTip = 'Specifies the value of the Res. Cash In First Name field.';
                }
                field("Res. Cash In/Out ID"; Rec."Res. Cash In/Out ID")
                {
                    ToolTip = 'Specifies the value of the Res. Cash In/Out ID field.';
                }
                field("Res. Cash In Last Name"; Rec."Res. Cash In Last Name")
                {
                    ToolTip = 'Specifies the value of the Res. Cash In Last Name field.';
                }
                field("Res. Cash In/Out Message"; Rec."Res. Cash In/Out Message")
                {
                    ToolTip = 'Specifies the value of the Res. Cash In/Out Message field.';
                }
                field("Res. Cash In Middle Name"; Rec."Res. Cash In Middle Name")
                {
                    ToolTip = 'Specifies the value of the Res. Cash In Middle Name field.';
                }
                field("Res. Cash In/Out Mobile No."; Rec."Res. Cash In/Out Mobile No.")
                {
                    ToolTip = 'Specifies the value of the Res. Cash In/Out Mobile No. field.';
                }
                field("Res. Cash In Ref. No."; Rec."Res. Cash In Ref. No.")
                {
                    ToolTip = 'Specifies the value of the Res. Cash In Ref. No. field.';
                }
                field("Res. Cash In Remarks"; Rec."Res. Cash In Remarks")
                {
                    ToolTip = 'Specifies the value of the Res. Cash In Remarks field.';
                }
                field("Res. Cash In/Out Status"; Rec."Res. Cash In/Out Status")
                {
                    ToolTip = 'Specifies the value of the Res. Cash In/Out Status field.';
                }
                field("Res. Cash In is Valid"; Rec."Res. Cash In is Valid")
                {
                    ToolTip = 'Specifies the value of the Res. Cash In is Valid field.';
                }
                field("Res. Cash Out  Amount"; Rec."Res. Cash Out  Amount")
                {
                    ToolTip = 'Specifies the value of the Res. Cash Out  Amount field.';
                }
                field("Res. Cash Out Branch"; Rec."Res. Cash Out Branch")
                {
                    ToolTip = 'Specifies the value of the Res. Cash Out Branch field.';
                }
                field("Res. Cash Out Created At"; Rec."Res. Cash Out Created At")
                {
                    ToolTip = 'Specifies the value of the Res. Cash Out Created At field.';
                }
                field("Res. Cash Out Ref. No."; Rec."Res. Cash Out Ref. No.")
                {
                    ToolTip = 'Specifies the value of the Res. Cash Out Ref. No. field.';
                }
                field("Res. Cash Out Subscriber Name"; Rec."Res. Cash Out Subscriber Name")
                {
                    ToolTip = 'Specifies the value of the Res. Cash Out Subscriber Name field.';
                }
                field("Res. Cash Out Validated At"; Rec."Res. Cash Out Validated At")
                {
                    ToolTip = 'Specifies the value of the Res. Cash Out Validated At field.';
                }
                field("Res. Cash Out Validated By"; Rec."Res. Cash Out Validated By")
                {
                    ToolTip = 'Specifies the value of the Res. Cash Out Validated By field.';
                }
                field("Res. PayQR Code"; Rec."Res. PayQR Code")
                {
                    ToolTip = 'Specifies the value of the Res. PayQR Code field.';
                }
                field("Res. PayQR Created At"; Rec."Res. PayQR Created At")
                {
                    ToolTip = 'Specifies the value of the Res. PayQR Created At field.';
                }
                field("Res. PayQR Expiration"; Rec."Res. PayQR Expiration")
                {
                    ToolTip = 'Specifies the value of the Res. PayQR Expiration field.';
                }
                field("Res. PayQR First Name"; Rec."Res. PayQR First Name")
                {
                    ToolTip = 'Specifies the value of the Res. PayQR First Name field.';
                }
                field("Res. PayQR ID"; Rec."Res. PayQR ID")
                {
                    ToolTip = 'Specifies the value of the Res. PayQR ID field.';
                }
                field("Res. PayQR Last Name"; Rec."Res. PayQR Last Name")
                {
                    ToolTip = 'Specifies the value of the Res. PayQR Last Name field.';
                }
                field("Res. PayQR Message"; Rec."Res. PayQR Message")
                {
                    ToolTip = 'Specifies the value of the Res. PayQR Message field.';
                }
                field("Res. PayQR Mobile No."; Rec."Res. PayQR Mobile No.")
                {
                    ToolTip = 'Specifies the value of the Res. PayQR Mobile No. field.';
                }
                field("Res. PayQR Profile ID"; Rec."Res. PayQR Profile ID")
                {
                    ToolTip = 'Specifies the value of the Res. PayQR Profile ID field.';
                }
                field("Res. PayQR Ref. No."; Rec."Res. PayQR Ref. No.")
                {
                    ToolTip = 'Specifies the value of the Res. PayQR Ref. No. field.';
                }
                field("Res. PayQR Remaining Balance"; Rec."Res. PayQR Remaining Balance")
                {
                    ToolTip = 'Specifies the value of the Res. PayQR Remaining Balance field.';
                }
                field("Res. PayQR Status"; Rec."Res. PayQR Status")
                {
                    ToolTip = 'Specifies the value of the Res. PayQR Status field.';
                }
                field("Res. PayQR Status Code"; Rec."Res. PayQR Status Code")
                {
                    ToolTip = 'Specifies the value of the Res. PayQR Status Code field.';
                }
                field("Res. PayQR Type"; Rec."Res. PayQR Type")
                {
                    ToolTip = 'Specifies the value of the Res. PayQR Type field.';
                }
                field("Res. PayQR is Expired"; Rec."Res. PayQR is Expired")
                {
                    ToolTip = 'Specifies the value of the Res. PayQR is Expired field.';
                }
            }
        }
    }
}
