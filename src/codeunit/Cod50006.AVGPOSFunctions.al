codeunit 50006 "AVG POS Functions"
{
    var
        AVGPOSSession: Codeunit "AVG POS Session";

    procedure AVGPOSMessage(pTxtMessage: Text)
    begin
        AVGPOSSession.AVGPOSMessages(pTxtMessage);
    end;

    procedure AVGPOSErrorMessage(pTxtMessage: Text)
    begin
        AVGPOSSession.AVGPOSErrorMessages(pTxtMessage);
    end;
}
