codeunit 50006 "AVG POS Functions"
{
    var
        AVGPOSSession: Codeunit "AVG POS Session";
        TypeHelper: Codeunit "Type Helper";

    procedure AVGPOSMessage(pTxtMessage: Text)
    begin
        AVGPOSSession.AVGPOSMessages(pTxtMessage);
    end;

    procedure AVGPOSErrorMessage(pTxtMessage: Text)
    begin
        AVGPOSSession.AVGPOSErrorMessages(pTxtMessage);
    end;

    procedure AVGCreateStandardGuidFormat(pRecPOSTerminal: Record "LSC POS Terminal"; pTxtMode: Text): Text;
    begin
        EXIT(COPYSTR(DELCHR(pTxtMode + pRecPOSTerminal."Store No." + pRecPOSTerminal."No." + CreateGuid() + TypeHelper.GetCurrUTCDateTimeISO8601(), '=', ':{}-'), 1, 64));
    end;
}
