tableextension 50002 "AVG Tender Type Ext." extends "LSC Tender Type"
{
    fields
    {
        field(50000; "No. of Copies"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(50001; "Loyalty Redemption"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(50002; "Exclude Refund Autopost"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(50004; "AVG Maya Tender Type"; Enum "AVG Maya Tender Type")
        {
            Caption = 'Maya Tender Type';
            DataClassification = CustomerContent;
        }
        field(50005; "AVG Maya Tender Type Args."; Enum "AVG Maya Tender Type Args.")
        {
            Caption = 'Maya Tender Type Args.';
            DataClassification = CustomerContent;
        }
        // AVG - Reserve for Future Use - Begin
        // field(50003; "QR Code Image"; MediaSet)
        // {
        //     DataClassification = CustomerContent;
        // }
        // AVG - Reserve for Future Use - End
    }
}
