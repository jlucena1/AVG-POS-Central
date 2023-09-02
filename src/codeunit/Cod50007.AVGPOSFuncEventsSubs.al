codeunit 50007 "AVG POS Func. Events Subs."
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnAfterInit, '', false, false)]
    local procedure OnAfterInit(var POSTransaction: Record "LSC POS Transaction");
    var
        AVGPOSSession: Codeunit "AVG POS Session";
    begin
        AVGPOSSession.InitAVGSetup();
    end;
}
