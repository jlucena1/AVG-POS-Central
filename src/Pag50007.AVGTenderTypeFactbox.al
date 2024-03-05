// AVG - Reserve for Future Use - Begin
// page 50007 "AVG Tender Type Factbox"
// {
//     ApplicationArea = All;
//     Caption = 'Retail Image';
//     DeleteAllowed = false;
//     Editable = false;
//     InsertAllowed = false;
//     ModifyAllowed = false;
//     PageType = ListPart;
//     ShowFilter = false;
//     SourceTable = "LSC Retail Image";
//     SourceTableTemporary = true;
//     SourceTableView = SORTING(Code);

//     layout
//     {
//         area(content)
//         {
//             field("TenantMedia.Content"; TenantMedia.Content)
//             {
//                 ApplicationArea = All;
//                 ShowCaption = false;
//             }
//         }
//     }

//     actions
//     {
//     }

//     var
//         TenantMedia: Record "Tenant Media";

//     procedure SetActiveImage(TableRecordID: RecordId)
//     var
//         RetailImage: Record "LSC Retail Image";
//         RetailImageUtils: Codeunit "LSC Retail Image Utils";
//         DisplayOrder: Integer;
//     begin
//         Clear(TenantMedia);
//         case CurrPage.Caption of
//             'Store Logo', 'Retail Default Logo':
//                 RetailImageUtils.ReturnTenantMediaForRecordId(TableRecordID, Enum::"LSC Retail Image Link Type"::Logo, 0, TenantMedia);
//             'QR Code for Direction', 'QR Code for Dining Table':
//                 RetailImageUtils.ReturnTenantMediaForRecordId(TableRecordID, Enum::"LSC Retail Image Link Type"::"QR Code", 0, TenantMedia);
//             else
//                 RetailImageUtils.ReturnTenantMediaForRecordId(TableRecordID, Enum::"LSC Retail Image Link Type"::Image, 0, TenantMedia);
//         end;
//         if not TenantMedia.Content.HasValue then
//             RetailImage.Init();

//         Rec.DeleteAll;
//         Rec.Init;
//         Rec.Insert;
//         CurrPage.Update(false);
//     end;
// }
// AVG - Reserve for Future Use - End
