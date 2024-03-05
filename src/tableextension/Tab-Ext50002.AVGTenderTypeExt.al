tableextension 50002 "AVG Tender Type Ext." extends "LSC Tender Type"
{
    fields
    {
        field(50100; "No. of Copies"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(50101; "Loyalty Redemption"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(50102; "Exclude Refund Autopost"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        // AVG - Reserve for Future Use - Begin
        // field(50103; "QR Code Image"; MediaSet)
        // {
        //     DataClassification = CustomerContent;
        // }
        // AVG - Reserve for Future Use - End
    }
}
