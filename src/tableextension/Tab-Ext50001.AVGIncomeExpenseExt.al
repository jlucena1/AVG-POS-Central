tableextension 50001 "AVG Income/Expense Ext." extends "LSC Income/Expense Account"
{
    fields
    {
        field(50000; "AE Minimum Amount to Accept"; Decimal)
        {
            Caption = 'Min. Amt. to Accept';
            DataClassification = CustomerContent;
        }
        field(50001; "AE Maximum Amount to Accept"; Decimal)
        {
            Caption = 'Max. Amt. to Accept';
            DataClassification = CustomerContent;
        }
        field(50002; "AE Allowed Tender Type"; Code[20])
        {
            Caption = 'Allowed Tender Type';
            DataClassification = CustomerContent;
            TableRelation = "LSC Tender Type".Code WHERE("Store No." = FIELD("Store No."));
        }
    }
}
