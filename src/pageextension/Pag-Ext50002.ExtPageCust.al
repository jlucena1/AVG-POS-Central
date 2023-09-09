pageextension 50002 ExtPageCust extends "Customer List"
{
    var
        txtResponse: Text;
        JToken: JsonToken;
        AVGPOSFunctions: Codeunit "AVG POS Functions";
        AVGPOSSession: Codeunit "AVG POS Session";
        LSCHttpWrapper: Codeunit "LSC Http Wrapper";
        LSCPOSTransactionCU: Codeunit "LSC POS Transaction";
        LSCAuthType: Enum "LSC Http AuthType";
        LSCContentType: Enum "LSC Http ContentType";
        RRef: RecordRef;
        FRef: FieldRef;
        avghttpfunc: Codeunit "AVG Http Functions";

    trigger OnOpenPage()
    var
        myInt: Integer;
        D: Date;
        T: Time;
        txtD: Text;
        txtT: Text;
        typehelper: Codeunit "Type Helper";
    begin
        // D := Today;
        // T := TIME;
        // MESSAGE('%1', typehelper.GetCurrUTCDateTimeISO8601());
        // 'THH:mm:sszzz'
        // txtD := FORMAT(D, 0, '<Year4>-<Month,2>-<Day,2>');
        // txtT := FORMAT(T, 0, 'T<Hours24,2><Filler Character,0>:<Minutes,2>:<Seconds,2>');
        // txtD := FORMAT(c)
        //MESSAGE('%1', FORMAT(TODAY));
        // avghttpfunc.GetGCashFunction(7);
        // avghttpfunc.GetGCashFunction(8);
        // avghttpfunc.GetGCashFunction(9);
        // avghttpfunc.GetGCashFunction(10);
        // avghttpfunc.GetGCashFunction(11);
        // RRef.Open(Database::"LSC POS Terminal");
        // MESSAGE('%1', RRef.FieldCount);
        //ProcessAuthToken('https://stg-fccpartner.alleasy.com.ph', '/authorize', '614c1dcef18d7', 'Bekzlq4I2zQ385YOxfI4qSMgc8MUaVKW5YsE', false, '', '');
    end;

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
        LSCHttpWrapper.Send();
        MESSAGE(LSCHttpWrapper.ResponseText())
        // IF LSCHttpWrapper.Send() THEN BEGIN
        //     txtResponse := GetResponseJsonByPathText('token');
        //     EXIT(txtResponse);
        // END ELSE begin
        //     RStatus := GetResponseJsonByPathText('error');
        //     RMessage := GetResponseJsonByPathText('error_description');
        //     AVGPOSFunctions.AVGPOSErrorMessage(StrSubstNo(AVGErrorProcessAuthToken, RStatus, RMessage));
        //     exit('');
        // end;
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
                ResponseText := ResponseText.Replace('"', ' ');
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
