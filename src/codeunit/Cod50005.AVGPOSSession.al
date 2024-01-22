codeunit 50005 "AVG POS Session"
{
    SingleInstance = true;

    var
        AVGSetup: Record "AVG Setup";
        LSCPOSTransaction: Codeunit "LSC POS Transaction";
        CurrPayQR: Text;
        CurrPayQRAmountText: Text;
        CurrPartnerRefNo: Text;
        CurrCashInAmount: Text;
        CurrCashInMobileNo: Text;
        CurrAuthToken: Text;
        CurrGCashPayQR: Text;
        CurrGCashPayQRAmountText: Text;
        CurrGCashCancelAcqID: Text;
        CurrGCashRefundAcqID: Text;
        CurrGCashSelectedInfocode: Text;
        CurrGCashRefundAmount: Text;
        CurrLoyaltyTenderType: Code[20];

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

    procedure AVGCompanyCode(): Code[20]
    begin
        exit(AVGSetup."AVG Company Code");
    end;

    procedure GetCurrAVGSetup(var pAVGSetup: Record "AVG Setup")
    begin
        pAVGSetup := AVGSetup;
    end;

    procedure ClearAllValues()
    begin
        ClearCurrAuthToken();
        ClearCurrCashInAmount();
        ClearCurrCashInMobileNo();
        ClearCurrGCashCancelAcqID();
        ClearCurrGCashPayQRAmount();
        ClearCurrGCashPayQRCode();
        ClearCurrGCashRefundAcqID();
        ClearCurrGCashRefundAmount();
        ClearCurrGCashSelectedInfocode();
        ClearCurrPartnerRefNo();
        ClearCurrPayQRAmount();
        ClearCurrPayQRCode();
        ClearLoyaltyCurrTenderType();
    end;

    procedure ClearCurrAuthToken()
    begin
        CurrAuthToken := '';
    end;

    procedure ClearCurrCashInAmount()
    begin
        CurrCashInAmount := '';
    end;

    procedure ClearCurrCashInMobileNo()
    begin
        CurrCashInMobileNo := '';
    end;

    procedure ClearCurrGCashCancelAcqID()
    begin
        CurrGCashCancelAcqID := '';
    end;

    procedure ClearCurrGCashPayQRAmount()
    begin
        CurrGCashPayQRAmountText := '';
    end;

    procedure ClearCurrGCashPayQRCode()
    begin
        CurrGCashPayQR := '';
    end;

    procedure ClearCurrGCashRefundAcqID()
    begin
        CurrGCashRefundAcqID := '';
    end;

    procedure ClearCurrGCashRefundAmount()
    begin
        CurrGCashRefundAmount := '';
    end;

    procedure ClearCurrGCashSelectedInfocode()
    begin
        CurrGCashSelectedInfocode := '';
    end;

    procedure ClearCurrPartnerRefNo()
    begin
        CurrPartnerRefNo := '';
    end;

    procedure ClearCurrPayQRAmount()
    begin
        CurrPayQRAmountText := '';
    end;

    procedure ClearCurrPayQRCode()
    begin
        CurrPayQR := '';
    end;

    procedure GetCurrAuthToken(): Text;
    begin
        EXIT(CurrAuthToken);
    end;

    procedure GetCurrCashInAmount(): Text;
    begin
        EXIT(CurrCashInAmount);
    end;

    procedure GetCurrCashInMobileNo(): Text;
    begin
        EXIT(CurrCashInMobileNo);
    end;

    procedure GetCurrGCashCancelAcqID(): Text;
    begin
        EXIT(CurrGCashCancelAcqID);
    end;

    procedure GetCurrGCashPayQRCode(): Text;
    begin
        EXIT(CurrGCashPayQR);
    end;

    procedure GetCurrGCashRefundAcqID(): Text;
    begin
        EXIT(CurrGCashRefundAcqID);
    end;

    procedure GetCurrGCashRefundAmount(): Text;
    begin
        EXIT(CurrGCashRefundAmount);
    end;

    procedure GetCurrGCashSelectedInfocode(): Text;
    begin
        EXIT(CurrGCashSelectedInfocode);
    end;

    procedure GetCurrPartnerRefNo(): Text;
    begin
        EXIT(CurrPartnerRefNo);
    end;

    procedure GetCurrPayQRAmount(): Text;
    begin
        EXIT(CurrPayQRAmountText);
    end;

    procedure GetCurrPayQRCode(): Text;
    begin
        EXIT(CurrPayQR);
    end;

    procedure GetGCashCurrPayQRAmount(): Text;
    begin
        EXIT(CurrGCashPayQRAmountText);
    end;

    procedure GetHideKeybValues(): Boolean
    begin
        Exit(AVGSetup."Hide Values on Keyboard");
    end;

    procedure InitAVGSetup()
    begin
        AVGSetup.GET;
    end;

    procedure SetCurrAuthToken(var pTxtAuthToken: Text)
    begin
        CurrAuthToken := pTxtAuthToken;
    end;

    procedure SetCurrCashInAmount(var pTxtCashInAmount: Text)
    begin
        CurrCashInAmount := pTxtCashInAmount;
    end;

    procedure SetCurrCashInMobileNo(var pTxtCashInMobileNo: Text)
    begin
        CurrCashInMobileNo := pTxtCashInMobileNo;
    end;

    procedure SetCurrGCashCancelAcqID(var pTxtGCashCancelAcID: Text)
    begin
        CurrGCashCancelAcqID := pTxtGCashCancelAcID;
    end;

    procedure SetCurrGCashPayQRCode(var pTxtGCashPayQRCode: Text)
    begin
        CurrGCashPayQR := pTxtGCashPayQRCode;
    end;

    procedure SetCurrGCashRefundAcqID(var pTxtGCashRefundAcqID: Text)
    begin
        CurrGCashRefundAcqID := pTxtGCashRefundAcqID;
    end;

    procedure SetCurrGCashRefundAmount(var pTxtGCashRefundAmount: Text)
    begin
        CurrGCashRefundAmount := pTxtGCashRefundAmount;
    end;

    procedure SetCurrGCashSelectedInfocode(var pTxtGCashSelectedInfocode: Text)
    begin
        CurrGCashSelectedInfocode := pTxtGCashSelectedInfocode;
    end;

    procedure SetCurrPartnerRefNo(var pTxtPartnerRefNo: Text)
    begin
        CurrPartnerRefNo := pTxtPartnerRefNo;
    end;

    procedure SetCurrPayQRAmount(var pTxtPayQRAmount: Text)
    begin
        CurrPayQRAmountText := pTxtPayQRAmount;
    end;

    procedure SetCurrPayQRCode(var pTxtPayQRCode: Text)
    begin
        CurrPayQR := pTxtPayQRCode;
    end;

    procedure SetGCashCurrPayQRAmount(var pTxtPayQRAmount: Text)
    begin
        CurrGCashPayQRAmountText := pTxtPayQRAmount;
    end;

    procedure ClearLoyaltyCurrTenderType()
    begin
        CurrLoyaltyTenderType := '';
    end;

    procedure SetCurrLoyaltyCurrTenderType(pTxtTenderType: Code[20])
    begin
        CurrLoyaltyTenderType := pTxtTenderType;
    end;

    procedure GetCurrLoyaltyCurrTenderType(): Code[20];
    begin
        EXIT(CurrLoyaltyTenderType);
    end;
}
