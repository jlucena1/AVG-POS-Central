codeunit 50008 "PH QR Code Helper"
{

    procedure GenerateQRCodeImage(SourceText: Text; QRCodeImageTempBlob: Codeunit "Temp Blob"): Boolean
    var
        PHCrossTempBlob: Codeunit "Temp Blob";
    begin
        if SourceText = '' then
            exit(false);

        LoadPHCrossImage(PHCrossTempBlob);
        if GenerateQRCodeImageImpl(SourceText, QRCodeImageTempBlob) then
            exit(OverlayPHCross(QRCodeImageTempBlob, PHCrossTempBlob));

        exit(false);
    end;

    [TryFunction]
    local procedure GenerateQRCodeImageImpl(SourceText: Text; TempBlob: Codeunit "Temp Blob")
    var
        IBarcodeProvider: DotNet "IBarcode Provider";
        QRCodeProvider: DotNet "QRCode Provider";
        ErrorCorrectionLevel: DotNet "QRCode Error Correction Level";
        OutStream: OutStream;
    begin
        TempBlob.CreateOutStream(OutStream);
        IBarcodeProvider := QRCodeProvider.QRCodeProvider();
        // encoding 65001 = UTF-8, ECI mode off.
        IBarcodeProvider.GetBarcodeStream(SourceText, OutStream, ErrorCorrectionLevel::Medium, 5, 0, 65001, false, false);
    end;

    local procedure OverlayPHCross(QRImageTempBlob: Codeunit "Temp Blob"; PHCrossTempBlob: Codeunit "Temp Blob"): Boolean
    var
        ratio: Decimal;
    begin
        ratio := 0.24;
        exit(OverlayBitmapScaledCenter(QRImageTempBlob, PHCrossTempBlob, ratio, ratio));
    end;

    [TryFunction]
    local procedure OverlayBitmapScaledCenter(QRImageTempBlob: Codeunit "Temp Blob"; PHCrossTempBlob: Codeunit "Temp Blob"; ratioX: Decimal; ratioY: Decimal)
    var
        QRImageBitmap: DotNet Bitmap;
        PHCrossBitmap: DotNet Bitmap;
        Graphics: DotNet Graphics;
        ImageFormat: DotNet ImageFormat;
        Rect: DotNet Rectangle;
        InStream: InStream;
        OutStream: OutStream;
        SizeX: Integer;
        SizeY: Integer;
        OffsetX: Integer;
        OffsetY: Integer;
    begin
        QRImageTempBlob.CreateInStream(InStream);
        QRImageTempBlob.CreateOutStream(OutStream);
        // QRImageBitmap := QRImageBitmap.Bitmap(300 * ratioX, 300 * ratioY);
        QRImageBitmap := QRImageBitmap.FromStream(InStream);
        Graphics := Graphics.FromImage(QRImageBitmap);
        PHCrossTempBlob.CreateInStream(InStream);
        PHCrossBitmap := PHCrossBitmap.FromStream(InStream);
        SizeX := Round(QRImageBitmap.Width() * RatioX, 1);
        SizeY := Round(QRImageBitmap.Height() * RatioY, 1);
        OffsetX := Round((QRImageBitmap.Width() - SizeX) / 2, 1);
        OffsetY := Round((QRImageBitmap.Height() - SizeY) / 2, 1);

        Graphics.DrawImage(PHCrossBitmap, Rect.Rectangle(OffsetX, OffsetY, SizeX, SizeY));
        QRImageBitmap.Save(OutStream, ImageFormat.Bmp());

        Graphics.Dispose();
        QRImageBitmap.Dispose();
        PHCrossBitmap.Dispose();
    end;

    local procedure LoadPHCrossImage(TempBlob: Codeunit "Temp Blob")
    var
        Base64Convert: Codeunit "Base64 Convert";
        OutStream: OutStream;
    begin
        TempBlob.CreateOutStream(OutStream);
        Base64Convert.FromBase64(GetPHCrossImageBase64(), OutStream);
    end;

    local procedure GetPHCrossImageBase64(): Text
    var
        QRPHText: Label '/9j/4QAYRXhpZgAASUkqAAgAAAAAAAAAAAAAAP/sABFEdWNreQABAAQAAAA+AAD/4QMwaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wLwA8P3hwYWNrZXQgYmVnaW49Iu+7vyIgaWQ9Ilc1TTBNcENlaGlIenJlU3pOVGN6a2M5ZCI/PiA8eDp4bXBtZXRhIHhtbG5zOng9ImFkb2JlOm5zOm1ldGEvIiB4OnhtcHRrPSJBZG9iZSBYTVAgQ29yZSA5LjAtYzAwMSA3OS4xNGVjYjQyZjJjLCAyMDIzLzAxLzEzLTEyOjI1OjQ0ICAgICAgICAiPiA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPiA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtbG5zOnhtcE1NPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvbW0vIiB4bWxuczpzdFJlZj0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3NUeXBlL1Jlc291cmNlUmVmIyIgeG1wOkNyZWF0b3JUb29sPSJBZG9iZSBQaG90b3Nob3AgMjQuMiAoV2luZG93cykiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6RkQxRTA3NTRDRUVFMTFFRUExM0I5MDdBOTg4QzUyQzQiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6RkQxRTA3NTVDRUVFMTFFRUExM0I5MDdBOTg4QzUyQzQiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDpGRDFFMDc1MkNFRUUxMUVFQTEzQjkwN0E5ODhDNTJDNCIgc3RSZWY6ZG9jdW1lbnRJRD0ieG1wLmRpZDpGRDFFMDc1M0NFRUUxMUVFQTEzQjkwN0E5ODhDNTJDNCIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/Pv/uAA5BZG9iZQBkwAAAAAH/2wCEAAYEBAQEBAYEBAYJBgUG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';
    begin
        exit(QRPHText);
    end;
}
