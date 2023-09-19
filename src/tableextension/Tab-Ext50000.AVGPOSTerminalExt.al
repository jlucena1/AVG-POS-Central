tableextension 50000 "AVG POS Terminal Ext." extends "LSC POS Terminal"
{
    fields
    {
        field(50100; "AE Enable Cash In"; Boolean)
        {
            Caption = 'Enable Cash In';
            DataClassification = CustomerContent;
        }
        field(50101; "AE Cash In URL"; Text[65])
        {
            Caption = 'Cash In URL';
            DataClassification = CustomerContent;
        }
        field(50102; "AE Cash In Client ID"; Text[65])
        {
            Caption = 'Cash In Client ID';
            DataClassification = CustomerContent;
        }
        field(50103; "AE Cash In Client Secret"; Text[65])
        {
            Caption = 'Cash In Client Secret';
            DataClassification = CustomerContent;
        }
        field(50104; "AE Cash In Inc. Acc."; Code[20])
        {
            Caption = 'Cash In Inc. Acc.';
            DataClassification = CustomerContent;
            TableRelation = "LSC Income/Expense Account"."No." WHERE("Store No." = FIELD("Store No."), "Account Type" = FILTER(Income));
            trigger OnValidate()
            begin
                IncExpAcc.GET("Store No.", "AE Cash In Inc. Acc.");
                "AE Cash In Inc. Acc. Desc." := IncExpAcc.Description;
            end;
        }
        field(50105; "AE Cash In Inc. Acc. Desc."; Text[30])
        {
            Caption = 'Cash In Inc. Acc. Desc.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50106; "AE Enable Cash Out"; Boolean)
        {
            Caption = 'Enable Cash Out';
            DataClassification = ToBeClassified;
        }
        field(50107; "AE Cash Out URL"; Text[65])
        {
            Caption = 'Cash Out URL';
            DataClassification = CustomerContent;
        }
        field(50108; "AE Cash Out Client ID"; Text[65])
        {
            Caption = 'Cash Out Client ID';
            DataClassification = CustomerContent;
        }
        field(50109; "AE Cash Out Client Secret"; Text[65])
        {
            Caption = 'Cash Out Client Secret';
            DataClassification = CustomerContent;
        }
        field(50110; "AE Cash Out Exp. Acc."; Code[20])
        {
            Caption = 'Cash Out Exp. Acc.';
            DataClassification = CustomerContent;
            TableRelation = "LSC Income/Expense Account"."No." WHERE("Store No." = FIELD("Store No."), "Account Type" = FILTER(Expense));
            trigger OnValidate()
            begin
                IncExpAcc.GET("Store No.", "AE Cash Out Exp. Acc.");
                "AE Cash Out Exp. Acc. Desc." := IncExpAcc.Description;
            end;
        }
        field(50111; "AE Cash Out Exp. Acc. Desc."; Text[30])
        {
            Caption = 'Cash Out Exp. Acc. Desc.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50112; "AE Enable Pay QR"; Boolean)
        {
            Caption = 'Enable Pay QR';
            DataClassification = CustomerContent;
        }
        field(50113; "AE Pay QR URL"; Text[65])
        {
            Caption = 'Pay QR URL';
            DataClassification = CustomerContent;
        }
        field(50114; "AE Pay QR Client ID"; Text[65])
        {
            Caption = 'Pay QR Client ID';
            DataClassification = CustomerContent;
        }
        field(50115; "AE Pay QR Client Secret"; Text[65])
        {
            Caption = 'Pay QR Client Secret';
            DataClassification = CustomerContent;
        }
        field(50116; "AE Pay QR Tender Type"; Code[20])
        {
            Caption = 'Pay QR Tender Type';
            DataClassification = CustomerContent;
            TableRelation = "LSC Tender Type".Code WHERE("Store No." = FIELD("Store No."));
            trigger OnValidate()
            begin
                TenderType.GET("Store No.", "AE Pay QR Tender Type");
                "AE Pay QR Tender Type Desc." := TenderType.Description;
            end;
        }
        field(50117; "AE Pay QR Tender Type Desc."; Text[30])
        {
            Caption = 'Pay QR Tender Type Desc.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50118; "AE Cash In Endpoint Inquire"; Text[30])
        {
            Caption = 'Cash In Endpoint Inquire';
            DataClassification = CustomerContent;
        }
        field(50119; "AE Cash Out Endpoint Inquire"; Text[30])
        {
            Caption = 'Cash Out Endpoint Inquire';
            DataClassification = CustomerContent;
        }
        field(50120; "AE Pay QR Endpoint Inquire"; Text[60])
        {
            Caption = 'Pay QR Endpoint Inquire';
            DataClassification = CustomerContent;
        }
        field(50121; "AE Cash In Auth. Endpoint"; Text[30])
        {
            Caption = 'Cash In Auth. Endpoint';
            DataClassification = CustomerContent;
        }
        field(50122; "AE Cash Out Auth. Endpoint"; Text[30])
        {
            Caption = 'Cash Out Auth. Endpoint';
            DataClassification = CustomerContent;
        }
        field(50123; "AE Pay QR Auth. Endpoint"; Text[30])
        {
            Caption = 'Pay QR Auth. Endpoint';
            DataClassification = CustomerContent;
        }
        field(50124; "AE Cash In Endpoint Credit"; Text[30])
        {
            Caption = 'Cash In Endpoint Credit';
            DataClassification = CustomerContent;
        }
        field(50125; "AE Cash Out Endpoint Process"; Text[30])
        {
            Caption = 'Cash Out Endpoint Process';
            DataClassification = CustomerContent;
        }
        field(50126; "AE Pay QR Endpoint Process"; Text[60])
        {
            Caption = 'Pay QR Endpoint Process';
            DataClassification = CustomerContent;
        }
        field(50127; "AE Pay QR Header1"; Text[60])
        {
            Caption = 'Pay QR Header1 ';
            DataClassification = CustomerContent;
        }
        field(50128; "AE Pay QR Header2"; Text[60])
        {
            Caption = 'Pay QR Header2';
            DataClassification = CustomerContent;
        }
        field(50129; "GCash URL"; Text[80])
        {
            Caption = 'GCash URL';
            DataClassification = CustomerContent;
        }
        field(50130; "GCash Client ID"; Text[80])
        {
            Caption = 'GCash Client ID';
            DataClassification = CustomerContent;
        }
        field(50131; "GCash Client Secret"; Text[80])
        {
            Caption = 'GCash Client Secret';
            DataClassification = CustomerContent;
        }
        field(50132; "GCash Merchant ID"; Text[60])
        {
            Caption = 'GCash Merchant ID';
            DataClassification = CustomerContent;
        }
        field(50133; "GCash Merchant Terminal ID"; Text[32])
        {
            Caption = 'GCash Merchant Terminal ID';
            DataClassification = CustomerContent;
        }
        field(50134; "GCash Product Code"; Text[32])
        {
            Caption = 'GCash Product Code';
            DataClassification = CustomerContent;
        }
        field(50135; "GCash AuthCode Type"; Text[32])
        {
            Caption = 'GCash AuthCode Type';
            DataClassification = CustomerContent;
        }
        field(50136; "GCash Order Terminal Type"; Text[32])
        {
            Caption = 'GCash Order Terminal Type';
            DataClassification = CustomerContent;
        }
        field(50137; "GCash Terminal Type"; Text[32])
        {
            Caption = 'GCash Terminal Type';
            DataClassification = CustomerContent;
        }
        field(50138; "GCash Scanner Device ID"; Text[32])
        {
            Caption = 'GCash Scanner Device ID';
            DataClassification = CustomerContent;
        }
        field(50139; "GCash Scanner Device IP"; Text[32])
        {
            Caption = 'GCash Scanner Device IP';
            DataClassification = CustomerContent;
        }
        field(50140; "GCash Client IP"; Text[32])
        {
            Caption = 'GCash Client IP';
            DataClassification = CustomerContent;
        }
        field(50141; "GCash Merchant IP"; Text[32])
        {
            Caption = 'GCash Merchant IP';
            DataClassification = CustomerContent;
        }
        field(50142; "GCash Order Title"; Text[32])
        {
            Caption = 'GCash Order Title';
            DataClassification = CustomerContent;
        }
        // field 50143 Vacant and need use
        field(50144; "GCash Tender Type"; Code[10])
        {
            Caption = 'GCash Tender Type';
            DataClassification = CustomerContent;
            TableRelation = "LSC Tender Type".Code WHERE("Store No." = FIELD("Store No."));
            trigger OnValidate()
            begin
                TenderType.GET("Store No.", "GCash Tender Type");
                "GCash Tender Type Desc." := TenderType.Description;
            end;
        }
        field(50145; "Enable GCash Pay"; Boolean)
        {
            Caption = 'Enable GCash Pay';
            DataClassification = CustomerContent;
        }
        field(50146; "Shop ID"; Code[30])
        {
            Caption = 'Shop ID';
            DataClassification = CustomerContent;
        }
        field(50147; "Shop Name"; Text[50])
        {
            Caption = 'Shop Name';
            DataClassification = CustomerContent;
        }
        field(50149; "HeartBeat Check Endpoint"; Text[50])
        {
            Caption = 'HeartBeat Check Endpoint';
            DataClassification = CustomerContent;
        }
        field(50150; "Retail Pay Endpoint"; Text[50])
        {
            Caption = 'Retail Pay Endpoint';
            DataClassification = CustomerContent;
        }
        field(50151; "Query Transaction Endpoint"; Text[50])
        {
            Caption = 'Query Transaction Endpoint';
            DataClassification = CustomerContent;
        }
        field(50152; "Cancel Transaction Endpoint"; Text[50])
        {
            Caption = 'Cancel Transaction Endpoint';
            DataClassification = CustomerContent;
        }
        field(50153; "Refund Transaction Endpoint"; Text[50])
        {
            Caption = 'Refund Transaction Endpoint';
            DataClassification = CustomerContent;
        }
        field(50154; "GCash Version"; Text[10])
        {
            Caption = 'GCash Version';
            DataClassification = CustomerContent;
        }
        field(50155; "GCash Private Key"; Blob)
        {
            Caption = 'GCash Private Key';
            DataClassification = CustomerContent;
        }
        field(50156; "GCash Public Key"; Blob)
        {
            Caption = 'GCash Public Key';
            DataClassification = CustomerContent;
        }
        field(50157; "GCash Reason Code"; Code[20])
        {
            Caption = 'GCash Reason Code';
            DataClassification = CustomerContent;
            TableRelation = "LSC Infocode".Code;
        }
        field(50158; "GCash Tender Type Desc."; Code[20])
        {
            Caption = 'GCash Tender Type Desc.';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
    var
        IncExpAcc: Record "LSC Income/Expense Account";
        TenderType: Record "LSC Tender Type";
}
