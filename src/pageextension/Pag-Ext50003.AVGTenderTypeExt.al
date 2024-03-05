pageextension 50003 "AVG Tender Type Ext." extends "LSC Tender Type Card"
{
    layout
    {
        // AVG - Reserve for Future Use - Begin
        // addfirst(FactBoxes)
        // {
        //     part(AVGTenderType; "AVG Tender Type Factbox")
        //     {
        //         Enabled = false;
        //         ShowFilter = false;
        //         Caption = 'Picture';
        //         ApplicationArea = All;
        //     }
        // }
        // AVG - Reserve for Future Use - End
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

    // AVG - Reserve for Future Use - Begin
    // actions
    // {
    //     addlast(navigation)
    //     {
    //         action(Image)
    //         {
    //             ApplicationArea = All;
    //             Caption = '&Images';
    //             Image = Picture;
    //             RunPageMode = View;
    //             trigger OnAction()
    //             var
    //                 RetailImageUtilsL: Codeunit "LSC Retail Image Utils";
    //                 RecRefL: RecordRef;
    //                 PosSessionL: Codeunit "LSC POS Session";
    //             begin
    //                 RecRefL.GetTable(Rec);
    //                 RetailImageUtilsL.RetailImageLinksEdit(RecRefL);
    //                 SetTenderPictureFromRetaiImagelLinks(Rec);
    //             end;
    //         }
    //     }

    // }

    // trigger OnAfterGetCurrRecord()
    // begin
    //     CurrPage.AVGTenderType.Page.SetActiveImage(Rec.RecordId);
    // end;

    // procedure ReturnTenantMediaForRecordId(RecId: RecordId; LinkType: enum "LSC Retail Image Link Type"; DisplayOrder: integer; var TenantMediaOut: Record "Tenant Media"): Boolean
    // var
    //     RetailImageLinkL: Record "LSC Retail Image Link";
    //     RetailImageL: Record "LSC Retail Image";
    //     TenantMediaSetL: Record "Tenant Media Set";
    // begin
    //     Clear(TenantMediaOut);
    //     RetailImageLinkL.SetCurrentKey(TableName, KeyValue, "Display Order");
    //     RetailImageLinkL.SetRange("Record Id", Format(RecId));
    //     if LinkType <> LinkType::Image then
    //         RetailImageLinkL.SetRange("Link Type", LinkType);
    //     if DisplayOrder <> 0 then
    //         RetailImageLinkL.SetRange("Display Order", DisplayOrder);
    //     if RetailImageLinkL.FindFirst() then
    //         if RetailImageL.Get(RetailImageLinkL."Image Id") then begin
    //             TenantMediaSetL.SetRange(ID, format(RetailImageL."Image Mediaset"));
    //             if TenantMediaSetL.FindFirst() then
    //                 if TenantMediaGet(TenantMediaOut, Format(TenantMediaSetL."Media ID")) then
    //                     TenantMediaOut.CalcFields(Content);
    //         end;
    //     exit(TenantMediaOut.Content.HasValue);
    // end;

    // procedure SetTenderPictureFromRetaiImagelLinks(var TenderType: Record "LSC Tender Type")
    // var
    //     TenantMediaL: Record "Tenant Media";
    // begin
    //     Clear(TenderType."QR Code Image");
    //     if ReturnTenantMediaForRecordId(TenderType.RecordId, enum::"LSC Retail Image Link Type"::Image, 0, TenantMediaL) then
    //         TenderType."QR Code Image".Insert(TenantMediaL.ID);
    //     TenderType.Modify();
    // end;

    // internal procedure TenantMediaGet(var TenantMedia: Record "Tenant Media"; ID: Text): Boolean
    // begin
    //     if TenantMedia.Get(ID) then
    //         exit(true);
    //     exit(false);
    // end;

    // internal procedure TenantMediaGet(var TenantMedia: Record "Tenant Media"; ID: Guid): Boolean
    // begin
    //     if TenantMedia.Get(ID) then
    //         exit(true);
    //     exit(false);
    // end;

    // internal procedure TenantMediaInsert(var TenantMedia: Record "Tenant Media"): Boolean
    // begin
    //     if TenantMedia.Insert() then
    //         exit(true);
    //     exit(false);
    // end;
    // AVG - Reserve for Future Use - End
}
