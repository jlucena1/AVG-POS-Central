page 50002 "AVG Setup"
{
    ApplicationArea = All;
    Caption = 'AVG General Setup';
    PageType = Card;
    InsertAllowed = false;
    DeleteAllowed = false;
    SourceTable = "AVG Setup";
    UsageCategory = Administration;
    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field("Prompt Messages"; Rec."Prompt Messages Format")
                {

                }

                field("Error Prompt Messages Format"; Rec."Error Prompt Messages Format")
                {

                }
                field("Last Date Modified"; Rec."Last Date Modified")
                {
                    Editable = false;
                }
                field("Last Modified By"; Rec."Last Modified By")
                {
                    Editable = false;
                }
                field("Date Initialized"; Rec."Date Initialized")
                {
                    Editable = false;
                }
                field("Initialized By"; Rec."Initialized By")
                {
                    Editable = false;
                }
                field("Hide Values on Keyboard"; Rec."Hide Values on Keyboard")
                {

                }
                field("AVG Company Code"; Rec."AVG Company Code")
                {

                }
                field("Auto Retrieve on Refund"; Rec."Auto Retrieve Tender on Refund")
                {

                }
                field("Wifi Pins"; Rec."Wifi Pins")
                {

                }
                // group(Payments)
                // {
                // }
            }
        }
    }
    trigger OnOpenPage()

    begin
        if not rec.Get() then begin
            rec.Init();
            rec."Date Initialized" := CurrentDateTime;
            rec."Initialized By" := UserId;
            Rec.Insert();
        end;
    end;
}
