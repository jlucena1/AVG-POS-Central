codeunit 50005 "AVG POS Session"
{
    SingleInstance = true;

    var
        AVGSetup: Record "AVG Setup";
        LSCPOSTransaction: Codeunit "LSC POS Transaction";
        LSCPOSSession: Codeunit "LSC POS Session";
        CurrPayQR: Text;
        CurrPayQRAmountText: Text;
        CurrPartnerRefNo: Text;
        CurrCashInAmount: Text;
        CurrCashInMobileNo: Text;
        CurrAuthToken: Text;

    procedure InitAVGSetup()
    begin
        AVGSetup.GET;
    end;

    procedure AVGPOSMessages(pTxt: Text)
    begin
        case AVGSetup."Prompt Messages Format" OF
            AVGSetup."Prompt Messages Format"::" ":
                Message(pTxt);
            AVGSetup."Prompt Messages Format"::"Standard Prompt Message":
                LSCPOSTransaction.PosMessage(pTxt);
            AVGSetup."Prompt Messages Format"::"Banner Prompt Message":
                LSCPOSTransaction.PosMessageBanner(pTxt);
        end;
    end;

    procedure AVGPOSErrorMessages(pTxt: Text)
    begin
        case AVGSetup."Error Prompt Messages Format" OF
            AVGSetup."Error Prompt Messages Format"::" ":
                Error(pTxt);
            AVGSetup."Error Prompt Messages Format"::"Standard Error Prompt Message":
                LSCPOSTransaction.PosMessage(pTxt);
            AVGSetup."Error Prompt Messages Format"::"Banner Error Prompt Message":
                LSCPOSTransaction.PosErrorBanner(pTxt);
        end;
    end;

    procedure ClearCurrPayQRCode()
    begin
        CurrPayQR := '';
    end;

    procedure SetCurrPayQRCode(var pTxtPayQRCode: Text)
    begin
        CurrPayQR := pTxtPayQRCode;
    end;

    procedure GetCurrPayQRCode(): Text;
    begin
        EXIT(CurrPayQR);
    end;

    procedure ClearCurrPayQRAmount()
    begin
        CurrPayQRAmountText := '';
    end;

    procedure SetCurrPayQRAmount(var pTxtPayQRAmount: Text)
    begin
        CurrPayQRAmountText := pTxtPayQRAmount;
    end;

    procedure GetCurrPayQRAmount(): Text;
    begin
        EXIT(CurrPayQRAmountText);
    end;

    procedure ClearCurrPartnerRefNo()
    begin
        CurrPartnerRefNo := '';
    end;

    procedure SetCurrPartnerRefNo(var pTxtPartnerRefNo: Text)
    begin
        CurrPartnerRefNo := pTxtPartnerRefNo;
    end;

    procedure GetCurrPartnerRefNo(): Text;
    begin
        EXIT(CurrPartnerRefNo);
    end;

    procedure ClearCurrCashInAmount()
    begin
        CurrCashInAmount := '';
    end;

    procedure SetCurrCashInAmount(var pTxtCashInAmount: Text)
    begin
        CurrCashInAmount := pTxtCashInAmount;
    end;

    procedure GetCurrCashInAmount(): Text;
    begin
        EXIT(CurrCashInAmount);
    end;

    procedure ClearCurrCashInMobileNo()
    begin
        CurrCashInMobileNo := '';
    end;

    procedure SetCurrCashInMobileNo(var pTxtCashInMobileNo: Text)
    begin
        CurrCashInMobileNo := pTxtCashInMobileNo;
    end;

    procedure GetCurrCashInMobileNo(): Text;
    begin
        EXIT(CurrCashInMobileNo);
    end;

    procedure ClearCurrAuthToken()
    begin
        CurrAuthToken := '';
    end;

    procedure SetCurrAuthToken(var pTxtAuthToken: Text)
    begin
        CurrAuthToken := pTxtAuthToken;
    end;

    procedure GetCurrAuthToken(): Text;
    begin
        EXIT(CurrAuthToken);
    end;
}
