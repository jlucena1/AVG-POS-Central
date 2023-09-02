codeunit 50004 "AVG Http Functions"
{
    SingleInstance = true;

    var
        txtResponse: Text;
        JToken: JsonToken;
        AVGPOSFunctions: Codeunit "AVG POS Functions";
        AVGPOSSession: Codeunit "AVG POS Session";
        LSCHttpWrapper: Codeunit "LSC Http Wrapper";
        LSCPOSTransactionCU: Codeunit "LSC POS Transaction";
        LSCAuthType: Enum "LSC Http AuthType";
        LSCContentType: Enum "LSC Http ContentType";


    procedure ProcessAuthToken(pTxtUrl: Text; pTxtEndpoint: Text; pTxtClientID: Text; pTxtClientSecret: Text; pBolPayQR: Boolean; pTxtHeader1: Text; pTxtHeader2: Text): Text;
    var
        JObject: JsonObject;
        RStatus: Text;
        RMessage: Text;
        AVGErrorProcessAuthToken: Label 'Status: %1\Message: %2\\Contact your System Administrator.';
    begin
        ClearHttpVars;
        LSCHttpWrapper.KeepAlive(true);
        LSCHttpWrapper.ContentTypeFromEnum(LSCContentType::Json);
        LSCHttpWrapper.SetHeader('User-Agent', 'AVGAllEasy');
        IF pBolPayQR THEN
            LSCHttpWrapper.SetHeader(pTxtHeader1, pTxtHeader2);
        LSCHttpWrapper.Url(pTxtUrl + pTxtEndpoint);
        LSCHttpWrapper.Method('POST');
        CLEAR(JObject);
        JObject.Add('client_id', pTxtClientID);
        JObject.Add('client_secret', pTxtClientSecret);
        LSCHttpWrapper.RequestJson(JObject);
        IF LSCHttpWrapper.Send() THEN BEGIN
            txtResponse := GetResponseJsonByPathText('token');
            EXIT(txtResponse);
        END ELSE begin
            RStatus := GetResponseJsonByPathText('error');
            RMessage := GetResponseJsonByPathText('error_description');
            AVGPOSFunctions.AVGPOSErrorMessage(StrSubstNo(AVGErrorProcessAuthToken, RStatus, RMessage));
            exit('');
        end;
    end;

    procedure ProcessCashInInquire(pTxtUrl: Text; pTxtEndpoint: Text; pTxtMobileNo: Text; pDecAmount: Decimal; pTxtRefNo: Text; pCodTerminalID: Code[20]; pTxtStaffID: Text): Boolean;
    var
        JObject: JsonObject;
        RStatus: Text;
        RMessage: Text;
        bolOK: Boolean;
        CashInSuccessConfirmMsg: Label 'Status: %1\Message: %2\\Do you want to Procced?';
        CashInErrorMsg: Label 'Status: %1\Message: %2';
    begin
        ClearHttpVars;
        LSCHttpWrapper.KeepAlive(true);
        LSCHttpWrapper.SetCredentials('', AVGPOSSession.GetCurrAuthToken());
        LSCHttpWrapper.AuthType(LSCAuthType::Bearer);
        LSCHttpWrapper.ContentTypeFromEnum(LSCContentType::Json);
        LSCHttpWrapper.SetHeader('User-Agent', 'AVGAllEasy');
        LSCHttpWrapper.Url(pTxtUrl + pTxtEndpoint);
        LSCHttpWrapper.Method('POST');
        CLEAR(JObject);
        JObject.Add('cashin_mobileno', pTxtMobileNo);
        JObject.Add('cashin_amount', pDecAmount);
        JObject.Add('partner_refno', pTxtRefNo);
        JObject.Add('partner_terminalid', pCodTerminalID);
        JObject.Add('partner_user', pTxtStaffID);
        LSCHttpWrapper.RequestJson(JObject);
        IF LSCHttpWrapper.Send() THEN BEGIN
            RStatus := GetResponseJsonByPathText('res_status');
            RMessage := GetResponseJsonByPathText('res_message');
            bolOK := LSCPOSTransactionCU.PosConfirm(StrSubstNo(CashInSuccessConfirmMsg, RStatus, RMessage), false);
        END ELSE begin
            RStatus := GetResponseJsonByPathText('res_status');
            RMessage := GetResponseJsonByPathText('res_message');
            AVGPOSFunctions.AVGPOSErrorMessage(StrSubstNo(CashInErrorMsg, RStatus, RMessage));
            bolOK := false;
        end;
        EXIT(bolOK);
    end;

    procedure ProcessCashInCredit(pTxtUrl: Text; pTxtEndpoint: Text; pTxtMobileNo: Text; pDecAmount: Decimal; pTxtRefNo: Text; pCodTerminalID: Code[20]; pTxtStaffID: Text): Boolean;
    var
        JObject: JsonObject;
        RStatus: Text;
        RMessage: Text;
        bolOK: Boolean;
        CashInMsg: Label 'Status: %1\Message: %2';
    begin
        ClearHttpVars;
        LSCHttpWrapper.KeepAlive(true);
        LSCHttpWrapper.SetCredentials('', AVGPOSSession.GetCurrAuthToken());
        LSCHttpWrapper.AuthType(LSCAuthType::Bearer);
        LSCHttpWrapper.ContentTypeFromEnum(LSCContentType::Json);
        LSCHttpWrapper.SetHeader('User-Agent', 'AVGAllEasy');
        LSCHttpWrapper.Url(pTxtUrl + pTxtEndpoint);
        LSCHttpWrapper.Method('POST');
        CLEAR(JObject);
        JObject.Add('cashin_mobileno', pTxtMobileNo);
        JObject.Add('cashin_amount', pDecAmount);
        JObject.Add('partner_refno', pTxtRefNo);
        JObject.Add('partner_terminalid', pCodTerminalID);
        JObject.Add('partner_user', pTxtStaffID);
        LSCHttpWrapper.RequestJson(JObject);
        IF LSCHttpWrapper.Send() THEN BEGIN
            RStatus := GetResponseJsonByPathText('res_status');
            RMessage := GetResponseJsonByPathText('res_message');
            AVGPOSFunctions.AVGPOSMessage(StrSubstNo(CashInMsg, RStatus, RMessage));
            bolOK := true;
        END ELSE begin
            RStatus := GetResponseJsonByPathText('res_status');
            RMessage := GetResponseJsonByPathText('res_message');
            AVGPOSFunctions.AVGPOSErrorMessage(StrSubstNo(CashInMsg, RStatus, RMessage));
            bolOK := false;
        end;
        EXIT(bolOK);
    end;

    procedure ProcessCashOutInquire(pTxtUrl: Text; pTxtEndpoint: Text; pTxtCORefNo: Text; pTxtRefNo: Text; pCodTerminalID: Code[20]; pTxtStaffID: Text; var pTxtAmount: Text; pRecPOSTerminal: Record "LSC POS Terminal"): Boolean;
    var
        JObject: JsonObject;
        RStatus: Text;
        RMessage: Text;
        txtLValidationMessage: Text;
        txtLAmount: Text;
        decLAmount: Decimal;
        bolOK: Boolean;
        IncExpLocal: Record "LSC Income/Expense Account";
        CashOutSuccessConfirmMsg: Label 'Status: %1\Message: %2\\Do you want to Procced?';
        CashOutErrorMsg: Label 'Status: %1\Message: %2';
        AmountToAcceptErrMsg: Label '%1 is: %2.\\Transaction will not Proceed.';
        ValidationErrMsg: Label 'Message: %1\Status: %2\Branch: %3\Validated By: %4\Validated At: %5';
    begin
        ClearHttpVars;
        LSCHttpWrapper.KeepAlive(true);
        LSCHttpWrapper.SetCredentials('', AVGPOSSession.GetCurrAuthToken());
        LSCHttpWrapper.AuthType(LSCAuthType::Bearer);
        LSCHttpWrapper.ContentTypeFromEnum(LSCContentType::Json);
        LSCHttpWrapper.SetHeader('User-Agent', 'AVGAllEasy');
        LSCHttpWrapper.Url(pTxtUrl + pTxtEndpoint);
        LSCHttpWrapper.Method('POST');
        CLEAR(JObject);
        JObject.Add('cashout_refno', pTxtCORefNo);
        JObject.Add('partner_refno', pTxtRefNo);
        JObject.Add('partner_terminalid', pCodTerminalID);
        JObject.Add('partner_user', pTxtStaffID);
        LSCHttpWrapper.RequestJson(JObject);
        IF LSCHttpWrapper.Send() THEN BEGIN
            RStatus := GetResponseJsonByPathText('res_status');
            RMessage := GetResponseJsonByPathText('res_message');
            bolOK := LSCPOSTransactionCU.PosConfirm(StrSubstNo(CashOutSuccessConfirmMsg, RStatus, RMessage), false);
            IF bolOK THEN BEGIN
                txtLAmount := GetResponseJsonByPathText('res_data.amount');
                IF NOT Evaluate(decLAmount, txtLAmount) then
                    bolOK := false;
                pTxtAmount := txtLAmount;
                IncExpLocal.Get(pRecPOSTerminal."Store No.", pRecPOSTerminal."AE Cash Out Exp. Acc.");
                IF (decLAmount < IncExpLocal."AE Minimum Amount to Accept") THEN begin
                    AVGPOSFunctions.AVGPOSErrorMessage(StrSubstNo(AmountToAcceptErrMsg, IncExpLocal.FIELDCAPTION("AE Minimum Amount To Accept"), FORMAT(IncExpLocal."AE Minimum Amount To Accept")));
                    bolOK := false;
                end;
                IF (decLAmount > IncExpLocal."AE Maximum Amount to Accept") THEN BEGIN
                    AVGPOSFunctions.AVGPOSErrorMessage(StrSubstNo(AmountToAcceptErrMsg, IncExpLocal.FIELDCAPTION("AE Maximum Amount To Accept"), FORMAT(IncExpLocal."AE Maximum Amount To Accept")));
                    bolOK := false;
                end;
                IF GetResponseJsonByPathText('res_status') <> 'PENDING' then begin
                    txtLValidationMessage :=
                        StrSubstNo(ValidationErrMsg,
                            GetResponseJsonByPathText('res_message'),
                            GetResponseJsonByPathText('res_status'),
                            GetResponseJsonByPathText('res_data.branch'),
                            GetResponseJsonByPathText('res_data.validated_by'),
                            GetResponseJsonByPathText('res_data.validated_at'));
                    AVGPOSFunctions.AVGPOSErrorMessage(txtLValidationMessage);
                    bolOK := false;
                end;
            END;
        END ELSE begin
            RStatus := GetResponseJsonByPathText('res_status');
            RMessage := GetResponseJsonByPathText('res_message');
            AVGPOSFunctions.AVGPOSErrorMessage(StrSubstNo(CashOutErrorMsg, RStatus, RMessage));
            bolOK := false;
        end;
        EXIT(bolOK);
    end;

    procedure ProcessCashOutProcess(pTxtUrl: Text; pTxtEndpoint: Text; pTxtCORefNo: Text; pTxtRefNo: Text; pCodTerminalID: Code[20]; pTxtStaffID: Text): Boolean;
    var
        JObject: JsonObject;
        RStatus: Text;
        RMessage: Text;
        bolOK: Boolean;
        CashOutMsg: Label 'Status: %1\Message: %2';
    begin
        ClearHttpVars;
        LSCHttpWrapper.KeepAlive(true);
        LSCHttpWrapper.SetCredentials('', AVGPOSSession.GetCurrAuthToken());
        LSCHttpWrapper.AuthType(LSCAuthType::Bearer);
        LSCHttpWrapper.ContentTypeFromEnum(LSCContentType::Json);
        LSCHttpWrapper.SetHeader('User-Agent', 'AVGAllEasy');
        LSCHttpWrapper.Url(pTxtUrl + pTxtEndpoint);
        LSCHttpWrapper.Method('POST');
        CLEAR(JObject);
        JObject.Add('cashout_refno', pTxtCORefNo);
        JObject.Add('partner_refno', pTxtRefNo);
        JObject.Add('partner_terminalid', pCodTerminalID);
        JObject.Add('partner_user', pTxtStaffID);
        LSCHttpWrapper.RequestJson(JObject);
        IF LSCHttpWrapper.Send() THEN BEGIN
            RStatus := GetResponseJsonByPathText('res_status');
            RMessage := GetResponseJsonByPathText('res_message');
            AVGPOSFunctions.AVGPOSMessage(StrSubstNo(CashOutMsg, RStatus, RMessage));
            bolOK := true;
        END ELSE begin
            RStatus := GetResponseJsonByPathText('res_status');
            RMessage := GetResponseJsonByPathText('res_message');
            AVGPOSFunctions.AVGPOSErrorMessage(StrSubstNo(CashOutMsg, RStatus, RMessage));
            bolOK := false;
        end;
        EXIT(bolOK);
    end;

    procedure ProcessPayQRInquire(pTxtEndpoint: Text): Boolean;
    var
        RStatus: Text;
        RMessage: Text;
        RError: Text;
        bolOK: Boolean;
        PayQRSuccessMsg: Label 'Status: %1\Message: %2\\Do you want to Proceed?';
        PayQRErrorMsg: Label 'Status: %1\Message: %2\Reason: %3\\Transaction will not Proceed.';
        PayQRProcessedErrMsg: Label 'QR Code is already Proccessed.\\Transaction will not Proceed.';
    begin
        ClearHttpVars;
        LSCHttpWrapper.KeepAlive(true);
        LSCHttpWrapper.SetCredentials('', AVGPOSSession.GetCurrAuthToken());
        LSCHttpWrapper.AuthType(LSCAuthType::Bearer);
        LSCHttpWrapper.ContentTypeFromEnum(LSCContentType::Json);
        LSCHttpWrapper.SetHeader('User-Agent', 'AVGAllEasy');
        LSCHttpWrapper.Url(pTxtEndpoint);
        IF LSCHttpWrapper.Send() THEN BEGIN
            RStatus := GetResponseJsonByPathText('data.response.status');
            RMessage := GetResponseJsonByPathText('message');
            IF RMessage = 'ok' then
                RMessage := 'QR Code is Valid.';
            if Rstatus.Contains('SEND') then begin
                AVGPOSFunctions.AVGPOSErrorMessage(PayQRProcessedErrMsg);
                bolOK := false;
            end ELSE
                bolOK := LSCPOSTransactionCU.PosConfirm(StrSubstNo(PayQRSuccessMsg, RStatus, RMessage), false);
        END ELSE BEGIN
            IF EVALUATE(RStatus, FORMAT(GetResponseJsonByPathText('statusCode'))) THEN;
            RMessage := GetResponseJsonByPathText('message');
            RError := GetResponseJsonByPathText('error');
            AVGPOSFunctions.AVGPOSErrorMessage(StrSubstNo(PayQRErrorMsg, RStatus, RMessage, RError));
            bolOK := false;
        END;

        EXIT(bolOK);
    end;

    procedure ProcessPayQRProcess(pTxtEndpoint: Text): Boolean;
    var
        RStatus: Integer;
        RMessage: Text;
        RError: Text;
        bolOK: Boolean;
        PayQRSuccessMsg: Label 'Status Code: %1\Message: %2';
        PayQRErrorMsg: Label 'Status: %1\Message: %2\Reason: %3\\Transaction will not Proceed.';
    begin
        ClearHttpVars;
        LSCHttpWrapper.KeepAlive(true);
        LSCHttpWrapper.SetCredentials('', AVGPOSSession.GetCurrAuthToken());
        LSCHttpWrapper.AuthType(LSCAuthType::Bearer);
        LSCHttpWrapper.ContentTypeFromEnum(LSCContentType::Json);
        LSCHttpWrapper.SetHeader('User-Agent', 'AVGAllEasy');
        LSCHttpWrapper.Url(pTxtEndpoint);
        LSCHttpWrapper.Method('POST');
        IF LSCHttpWrapper.Send() THEN BEGIN
            IF EVALUATE(RStatus, FORMAT(GetResponseJsonByPathText('status'))) THEN;
            RMessage := GetResponseJsonByPathText('message');
            IF RMessage = 'OK' then
                RMessage := 'Payment using AllEasy QR Code has been Successfully Posted.';
            AVGPOSFunctions.AVGPOSMessage(Strsubstno(PayQRSuccessMsg, RStatus, RMessage));
            bolOK := TRUE;
        END ELSE BEGIN
            IF EVALUATE(RStatus, FORMAT(GetResponseJsonByPathText('statusCode'))) THEN;
            RMessage := GetResponseJsonByPathText('message');
            AVGPOSFunctions.AVGPOSErrorMessage(StrSubstNo(PayQRErrorMsg, RStatus, RMessage, 'Not Found.'));
            bolOK := false;
        END;

        EXIT(bolOK);
    end;

    procedure GetResponseJsonByPathText(pPath: Text): Text;
    var
        JTokenLocal: JsonToken;
        ResponseText: Text;
    begin

        CLEAR(ResponseText);
        JTokenLocal := LSCHttpWrapper.GetResponseJsonByPath(pPath);
        IF JTokenLocal.WriteTo(ResponseText) then BEGIN
            IF ResponseText.Contains('null') THEN
                ResponseText := ResponseText.Replace('null', '');
            IF ResponseText.Contains('"') THEN
                ResponseText := ResponseText.Replace('"', '');
        END ELSE
            ResponseText := '';
        EXIT(ResponseText);
    end;

    procedure ClearHttpVars()
    begin
        LSCHttpWrapper.ClearClient();
        LSCHttpWrapper.ClearErrors();
        LSCHttpWrapper.ClearFlags();
        LSCHttpWrapper.ClearHeaders();
        LSCHttpWrapper.ClearVars();
    end;


}
