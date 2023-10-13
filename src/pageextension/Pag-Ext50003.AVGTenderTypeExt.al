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
            }
        }
    }
}
