pageextension 50001 "AVG AE Integ. IncExp. Ext" extends "LSC Income/Expense Acc. Card"
{
    layout
    {
        addafter("Allow on Customer Order")
        {
            group("AllEasy Integration")

            {
                Caption = 'AVG AllEasy Integration';
                field("AE Min. Amt. to Accept"; Rec."AE Minimum Amount to Accept")
                {
                    ApplicationArea = All;
                }
                field("AE Max. Amt. to Accept"; Rec."AE Maximum Amount to Accept")
                {
                    ApplicationArea = All;
                }
                field("AE Allowed Tender Type"; Rec."AE Allowed Tender Type")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
