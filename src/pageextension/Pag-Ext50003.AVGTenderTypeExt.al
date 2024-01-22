pageextension 50003 "AVG Tender Type Ext." extends "LSC Tender Type Card"
{
    layout
    {
        addafter(Declaration)
        {
            group("AVG Customizations")
            {
                field("No. of Copies"; Rec."No. of Copies")
                {
                    ApplicationArea = All;
                }
                field("Loyalty Redemption"; Rec."Loyalty Redemption")
                {
                    ApplicationArea = All;
                }
                field("Exclude Refund Autopost"; Rec."Exclude Refund Autopost")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
