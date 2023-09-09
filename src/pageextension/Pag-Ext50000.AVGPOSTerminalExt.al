pageextension 50000 "AVG POS Terminal Ext." extends "LSC POS Terminal Card"
{
    layout
    {
        addafter(Omni)
        {
            group("AVG Customizations")
            {
                Caption = 'AVG Customizations';

                group("AllEasy Integration")
                {
                    Caption = 'AllEasy Integration';
                    group("AllEasy Cash In")
                    {
                        field("AE Enable Cash In"; Rec."AE Enable Cash In")
                        {
                            ApplicationArea = All;
                        }
                        field("AE Cash In URL"; Rec."AE Cash In URL")
                        {
                            ApplicationArea = All;
                        }
                        field("AE Cash In Endpoint Inquire"; Rec."AE Cash In Endpoint Inquire")
                        {
                            ApplicationArea = All;
                        }
                        field("AE Cash In Endpoint Credit"; Rec."AE Cash In Endpoint Credit")
                        {
                            ApplicationArea = All;
                        }
                        field("AE Cash In Auth. Endpoint"; Rec."AE Cash In Auth. Endpoint")
                        {
                            ApplicationArea = All;
                        }
                        field("AE Cash In Client ID"; Rec."AE Cash In Client ID")
                        {
                            ApplicationArea = All;
                        }
                        field("AE Cash In Client Secret"; Rec."AE Cash In Client Secret")
                        {
                            ApplicationArea = All;
                        }
                        field("AE Cash In Inc. Acc."; Rec."AE Cash In Inc. Acc.")
                        {
                            ApplicationArea = All;
                        }
                        field("AE Cash In Inc. Acc. Desc."; Rec."AE Cash In Inc. Acc. Desc.")
                        {
                            ApplicationArea = All;
                        }
                    }
                    group("AllEasy Cash Out")
                    {
                        field("AE Enable Cash Out"; Rec."AE Enable Cash Out")
                        {
                            ApplicationArea = All;
                        }
                        field("AE Cash Out URL"; Rec."AE Cash Out URL")
                        {
                            ApplicationArea = All;
                        }
                        field("AE Cash Out Endpoint Inquire"; Rec."AE Cash Out Endpoint Inquire")
                        {
                            ApplicationArea = All;
                        }
                        field("AE Cash Out Endpoint Process"; Rec."AE Cash Out Endpoint Process")
                        {
                            ApplicationArea = All;
                        }
                        field("AE Cash Out Auth. Endpoint"; Rec."AE Cash Out Auth. Endpoint")
                        {
                            ApplicationArea = All;
                        }
                        field("AE Cash Out Client ID"; Rec."AE Cash Out Client ID")
                        {
                            ApplicationArea = All;
                        }
                        field("AE Cash Out Client Secret"; Rec."AE Cash Out Client Secret")
                        {
                            ApplicationArea = All;
                        }
                        field("AE Cash Out Exp. Acc."; Rec."AE Cash Out Exp. Acc.")
                        {
                            ApplicationArea = All;
                        }
                        field("AE Cash Out Exp. Acc. Desc."; Rec."AE Cash Out Exp. Acc. Desc.")
                        {
                            ApplicationArea = All;
                        }
                    }

                    group("AllEasy Pay QR")
                    {
                        field("AE Enable Pay QR"; Rec."AE Enable Pay QR")
                        {
                            ApplicationArea = All;
                        }
                        field("AE Pay QR URL"; Rec."AE Pay QR URL")
                        {
                            ApplicationArea = All;
                        }
                        field("AE Pay QR Endpoint"; Rec."AE Pay QR Endpoint Inquire")
                        {
                            ApplicationArea = All;
                        }
                        field("AE Pay QR Process"; Rec."AE Pay QR Endpoint Process")
                        {
                            ApplicationArea = All;
                        }
                        field("AE Pay QR Auth. Endpoint"; Rec."AE Pay QR Auth. Endpoint")
                        {
                            ApplicationArea = All;
                        }
                        field("AE Pay QR Client ID"; Rec."AE Pay QR Client ID")
                        {
                            ApplicationArea = All;
                        }
                        field("AE Pay QR Client Secret"; Rec."AE Pay QR Client Secret")
                        {
                            ApplicationArea = All;
                        }
                        field("AE Pay QR Header1"; Rec."AE Pay QR Header1")
                        {
                            ApplicationArea = All;
                        }
                        field("AE Pay QR Header2"; Rec."AE Pay QR Header2")
                        {
                            ApplicationArea = All;
                        }
                        field("AE Pay QR Exp. Acc."; Rec."AE Pay QR Tender Type")
                        {
                            ApplicationArea = All;
                        }
                        field("AE Pay QR Tender Type Desc."; Rec."AE Pay QR Tender Type Desc.")
                        {
                            ApplicationArea = All;
                        }

                    }
                }
                group("GCash Integration")
                {
                    Caption = 'GCash Integration';


                    field("Enable GCash Pay"; Rec."Enable GCash Pay")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Enable GCash Pay field.';
                    }
                    field("Shop ID"; Rec."Shop ID")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Shop ID field.';
                    }
                    field("Shop Name"; Rec."Shop Name")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Shop Name field.';
                    }
                    field("GCash Tender Type"; Rec."GCash Tender Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the GCash Tender Type field.';
                    }
                    field("GCash Tender Type Desc."; Rec."GCash Tender Type Desc.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the GCash Tender Type Desc. field.';
                    }
                    group("Private Key")
                    {
                        field("GCash Private Key"; GCashPrivateKey)
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the GCash Private Key Path field.';
                            MultiLine = true;
                            RowSpan = 30;
                            Editable = false;
                            ShowCaption = false;
                            ShowMandatory = true;
                            trigger OnAssistEdit()
                            begin
                                GCashPrivateKey := UploadKey('Select GCash Private Key', 1);
                            end;
                        }
                    }
                    group("Public Key")
                    {
                        field("GCash Public Key"; GCashPublicKey)
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the GCash Public Key Path field.';
                            MultiLine = true;
                            RowSpan = 30;
                            Editable = false;
                            ShowCaption = false;
                            ShowMandatory = true;
                            trigger OnAssistEdit()
                            begin
                                GCashPublicKey := UploadKey('Select GCash Public Key', 2);
                            end;
                        }
                    }

                    field("GCash URL"; Rec."GCash URL")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the GCash URL field.';
                    }
                    field("GCash Client ID"; Rec."GCash Client ID")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the GCash Client ID field.';
                    }
                    field("GCash Client Secret"; Rec."GCash Client Secret")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the GCash Client Secret field.';
                    }
                    field("GCash Merchant ID"; Rec."GCash Merchant ID")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the GCash Merchant ID field.';
                    }
                    field("GCash Product Code"; Rec."GCash Product Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the GCash Product Code field.';
                    }
                    field("GCash Merchant Terminal ID"; Rec."GCash Merchant Terminal ID")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the GCash Merchant Terminal ID field.';
                    }
                    field("GCash Version"; Rec."GCash Version")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the GCash Version field.';
                    }
                    field("HeartBeat Check Endpoint"; Rec."HeartBeat Check Endpoint")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the HeartBeat Check Endpoint" field.';
                    }
                    field("Retail Pay Endpoint"; Rec."Retail Pay Endpoint")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Retail Pay Endpoint field.';
                    }
                    field("Query Transaction Endpoint"; Rec."Query Transaction Endpoint")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Query Transaction Endpoint field.';
                    }
                    field("Cancel Transaction Endpoint"; Rec."Cancel Transaction Endpoint")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Cancel Transaction Endpoint field.';
                    }
                    field("Refund Transaction Endpoint"; Rec."Refund Transaction Endpoint")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Refund Transaction Endpoint field.';
                    }
                    field("GCash AuthCode Type"; Rec."GCash AuthCode Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the GCash AuthCode Type field.';
                    }
                    field("GCash Terminal Type"; Rec."GCash Terminal Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the GCash Terminal Type field.';
                    }
                    field("GCash Order Terminal Type"; Rec."GCash Order Terminal Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the GCash Order Terminal Type field.';
                    }
                    field("GCash Scanner Device ID"; Rec."GCash Scanner Device ID")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the GCash Scanner Device ID field.';
                    }
                    field("GCash Scanner Device IP"; Rec."GCash Scanner Device IP")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the GCash Scanner Device IP field.';
                    }
                    field("GCash Merchant IP"; Rec."GCash Merchant IP")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the GCash Merchant IP field.';
                    }
                    field("GCash Client IP"; Rec."GCash Client IP")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the GCash Client IP field.';
                    }
                    field("GCash Order Title"; Rec."GCash Order Title")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the GCash Order Title field.';
                    }
                    field("GCash Exec. Payment Per Amt."; Rec."GCash Exec. Payment Per Amt.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the GCash Exec. Payment Per Amt. field.';
                    }
                    field("GCash Reason Code"; Rec."GCash Reason Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the GCash Reason Code field.';
                    }
                    field("Wait Reponse (Minutes)"; Rec."Wait Reponse (Minutes)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Wait Reponse (Minutes) field.';
                    }
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        CLEAR(GCashPrivateKey);
        CLEAR(GCashPublicKey);
    end;

    trigger OnAfterGetRecord()
    var
        InStrPrivateKey: InStream;
        InStrPublicKey: InStream;
    begin
        CLEAR(GCashPrivateKey);
        CLEAR(GCashPublicKey);
        Rec.CalcFields("GCash Private Key", "GCash Public Key");
        Rec."GCash Private Key".CreateInStream(InStrPrivateKey);
        IF Rec."GCash Private Key".HasValue THEN
            InStrPrivateKey.Read(GCashPrivateKey);
        Rec."GCash Public Key".CreateInStream(InStrPublicKey);
        IF Rec."GCash Public Key".HasValue THEN
            InStrPublicKey.Read(GCashPublicKey);
    end;

    local procedure UploadKey(DialogTitle: Text; Mode: Integer): Text;
    var
        ReadTextValue: Text;
        ReadText1: Text;
        Name: Text;
    begin
        Clear(ReadTextValue);
        Clear(ReadText1);
        Clear(InStr);
        Clear(OutStr);
        if UploadIntoStream(DialogTitle, '', '', Name, InStr) THEN BEGIN
            while not InStr.EOS DO begin
                InStr.Read(ReadText1);
                ReadTextValue += ReadText1;
            end;
        END;
        IF ReadTextValue <> '' THEN BEGIN
            case Mode of
                1:
                    begin
                        Rec."GCash Private Key".CreateOutStream(OutStr);
                        OutStr.Write(ReadTextValue);
                        Rec.Modify();
                    end;
                2:
                    begin
                        Rec."GCash Public Key".CreateOutStream(OutStr);
                        OutStr.Write(ReadTextValue);
                        Rec.Modify();
                    end;
            end;
            EXIT(ReadTextValue);
        END;
    end;

    var
        InStr: InStream;
        OutStr: OutStream;
        GCashPrivateKey: Text;
        GCashPublicKey: Text;
}