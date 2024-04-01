tableextension 50000 "AVG POS Terminal Ext." extends "LSC POS Terminal"
{
    fields
    {
        field(50000; "AE Enable Cash In"; Boolean)
        {
            Caption = 'Enable Cash In';
            DataClassification = CustomerContent;
        }
        field(50001; "AE Cash In URL"; Text[65])
        {
            Caption = 'Cash In URL';
            DataClassification = CustomerContent;
        }
        field(50002; "AE Cash In Client ID"; Text[65])
        {
            Caption = 'Cash In Client ID';
            DataClassification = CustomerContent;
        }
        field(50003; "AE Cash In Client Secret"; Text[65])
        {
            Caption = 'Cash In Client Secret';
            DataClassification = CustomerContent;
        }
        field(50004; "AE Cash In Inc. Acc."; Code[20])
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
        field(50005; "AE Cash In Inc. Acc. Desc."; Text[30])
        {
            Caption = 'Cash In Inc. Acc. Desc.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50006; "AE Enable Cash Out"; Boolean)
        {
            Caption = 'Enable Cash Out';
            DataClassification = ToBeClassified;
        }
        field(50007; "AE Cash Out URL"; Text[65])
        {
            Caption = 'Cash Out URL';
            DataClassification = CustomerContent;
        }
        field(50008; "AE Cash Out Client ID"; Text[65])
        {
            Caption = 'Cash Out Client ID';
            DataClassification = CustomerContent;
        }
        field(50009; "AE Cash Out Client Secret"; Text[65])
        {
            Caption = 'Cash Out Client Secret';
            DataClassification = CustomerContent;
        }
        field(50010; "AE Cash Out Exp. Acc."; Code[20])
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
        field(50011; "AE Cash Out Exp. Acc. Desc."; Text[30])
        {
            Caption = 'Cash Out Exp. Acc. Desc.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50012; "AE Enable Pay QR"; Boolean)
        {
            Caption = 'Enable Pay QR';
            DataClassification = CustomerContent;
        }
        field(50013; "AE Pay QR URL"; Text[65])
        {
            Caption = 'Pay QR URL';
            DataClassification = CustomerContent;
        }
        field(50014; "AE Pay QR Client ID"; Text[65])
        {
            Caption = 'Pay QR Client ID';
            DataClassification = CustomerContent;
        }
        field(50015; "AE Pay QR Client Secret"; Text[65])
        {
            Caption = 'Pay QR Client Secret';
            DataClassification = CustomerContent;
        }
        field(50016; "AE Pay QR Tender Type"; Code[20])
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
        field(50017; "AE Pay QR Tender Type Desc."; Text[30])
        {
            Caption = 'Pay QR Tender Type Desc.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50018; "AE Cash In Endpoint Inquire"; Text[30])
        {
            Caption = 'Cash In Endpoint Inquire';
            DataClassification = CustomerContent;
        }
        field(50019; "AE Cash Out Endpoint Inquire"; Text[30])
        {
            Caption = 'Cash Out Endpoint Inquire';
            DataClassification = CustomerContent;
        }
        field(50020; "AE Pay QR Endpoint Inquire"; Text[60])
        {
            Caption = 'Pay QR Endpoint Inquire';
            DataClassification = CustomerContent;
        }
        field(50021; "AE Cash In Auth. Endpoint"; Text[30])
        {
            Caption = 'Cash In Auth. Endpoint';
            DataClassification = CustomerContent;
        }
        field(50022; "AE Cash Out Auth. Endpoint"; Text[30])
        {
            Caption = 'Cash Out Auth. Endpoint';
            DataClassification = CustomerContent;
        }
        field(50023; "AE Pay QR Auth. Endpoint"; Text[30])
        {
            Caption = 'Pay QR Auth. Endpoint';
            DataClassification = CustomerContent;
        }
        field(50024; "AE Cash In Endpoint Credit"; Text[30])
        {
            Caption = 'Cash In Endpoint Credit';
            DataClassification = CustomerContent;
        }
        field(50025; "AE Cash Out Endpoint Process"; Text[30])
        {
            Caption = 'Cash Out Endpoint Process';
            DataClassification = CustomerContent;
        }
        field(50026; "AE Pay QR Endpoint Process"; Text[60])
        {
            Caption = 'Pay QR Endpoint Process';
            DataClassification = CustomerContent;
        }
        field(50027; "AE Pay QR Header1"; Text[60])
        {
            Caption = 'Pay QR Header1 ';
            DataClassification = CustomerContent;
        }
        field(50028; "AE Pay QR Header2"; Text[60])
        {
            Caption = 'Pay QR Header2';
            DataClassification = CustomerContent;
        }
        field(50029; "GCash URL"; Text[80])
        {
            Caption = 'GCash URL';
            DataClassification = CustomerContent;
        }
        field(50030; "GCash Client ID"; Text[80])
        {
            Caption = 'GCash Client ID';
            DataClassification = CustomerContent;
        }
        field(50031; "GCash Client Secret"; Text[80])
        {
            Caption = 'GCash Client Secret';
            DataClassification = CustomerContent;
        }
        field(50032; "GCash Merchant ID"; Text[60])
        {
            Caption = 'GCash Merchant ID';
            DataClassification = CustomerContent;
        }
        field(50033; "GCash Merchant Terminal ID"; Text[32])
        {
            Caption = 'GCash Merchant Terminal ID';
            DataClassification = CustomerContent;
        }
        field(50034; "GCash Product Code"; Text[32])
        {
            Caption = 'GCash Product Code';
            DataClassification = CustomerContent;
        }
        field(50035; "GCash AuthCode Type"; Text[32])
        {
            Caption = 'GCash AuthCode Type';
            DataClassification = CustomerContent;
        }
        field(50036; "GCash Order Terminal Type"; Text[32])
        {
            Caption = 'GCash Order Terminal Type';
            DataClassification = CustomerContent;
        }
        field(50037; "GCash Terminal Type"; Text[32])
        {
            Caption = 'GCash Terminal Type';
            DataClassification = CustomerContent;
        }
        field(50038; "GCash Scanner Device ID"; Text[32])
        {
            Caption = 'GCash Scanner Device ID';
            DataClassification = CustomerContent;
        }
        field(50039; "GCash Scanner Device IP"; Text[32])
        {
            Caption = 'GCash Scanner Device IP';
            DataClassification = CustomerContent;
        }
        field(50040; "GCash Client IP"; Text[32])
        {
            Caption = 'GCash Client IP';
            DataClassification = CustomerContent;
        }
        field(50041; "GCash Merchant IP"; Text[32])
        {
            Caption = 'GCash Merchant IP';
            DataClassification = CustomerContent;
        }
        field(50042; "GCash Order Title"; Text[32])
        {
            Caption = 'GCash Order Title';
            DataClassification = CustomerContent;
        }
        // field 50143 Vacant and need use
        field(50043; "GCash Tender Type"; Code[10])
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
        field(50044; "Enable GCash Pay"; Boolean)
        {
            Caption = 'Enable GCash Pay';
            DataClassification = CustomerContent;
        }
        field(50045; "Shop ID"; Code[30])
        {
            Caption = 'Shop ID';
            DataClassification = CustomerContent;
        }
        field(50046; "Shop Name"; Text[50])
        {
            Caption = 'Shop Name';
            DataClassification = CustomerContent;
        }
        field(50047; "HeartBeat Check Endpoint"; Text[50])
        {
            Caption = 'HeartBeat Check Endpoint';
            DataClassification = CustomerContent;
        }
        field(50048; "Retail Pay Endpoint"; Text[50])
        {
            Caption = 'Retail Pay Endpoint';
            DataClassification = CustomerContent;
        }
        field(50049; "Query Transaction Endpoint"; Text[50])
        {
            Caption = 'Query Transaction Endpoint';
            DataClassification = CustomerContent;
        }
        field(50050; "Cancel Transaction Endpoint"; Text[50])
        {
            Caption = 'Cancel Transaction Endpoint';
            DataClassification = CustomerContent;
        }
        field(50051; "Refund Transaction Endpoint"; Text[50])
        {
            Caption = 'Refund Transaction Endpoint';
            DataClassification = CustomerContent;
        }
        field(50052; "GCash Version"; Text[10])
        {
            Caption = 'GCash Version';
            DataClassification = CustomerContent;
        }
        field(50053; "GCash Private Key"; Blob)
        {
            Caption = 'GCash Private Key';
            DataClassification = CustomerContent;
        }
        field(50054; "GCash Public Key"; Blob)
        {
            Caption = 'GCash Public Key';
            DataClassification = CustomerContent;
        }
        field(50055; "GCash Reason Code"; Code[20])
        {
            Caption = 'GCash Reason Code';
            DataClassification = CustomerContent;
            TableRelation = "LSC Infocode".Code;
        }
        field(50056; "GCash Tender Type Desc."; Code[20])
        {
            Caption = 'GCash Tender Type Desc.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50057; "Enable Loyalty"; Boolean)
        {
            Caption = 'Enable Loyalty';
            DataClassification = CustomerContent;
        }
        field(50058; "Loyalty Url"; Text[60])
        {
            Caption = 'Loyalty Url';
            DataClassification = CustomerContent;
        }
        field(50059; "Loyalty POS No."; Text[10])
        {
            Caption = 'Loyalty POS No.';
            DataClassification = CustomerContent;
        }
        field(50060; "Enable Loyalty V2"; Boolean)
        {
            Caption = 'Enable Loyalty V2';
            DataClassification = CustomerContent;
        }
        field(50061; "Maya Py Script Path"; Text[60])
        {
            Caption = 'Maya Py Script Path';
            DataClassification = CustomerContent;
        }
        field(50062; "Loyalty V2 Url"; Text[60])
        {
            Caption = 'Loyalty V2 Url';
            DataClassification = CustomerContent;
        }
        field(50063; "Maya COM Port"; Code[10])
        {
            Caption = 'Maya COM Port';
            DataClassification = CustomerContent;
        }
        field(50064; "Loyalty V2 Setup Endpoint"; Text[30])
        {
            Caption = 'Loyalty V2 Setup Endpoint';
            DataClassification = CustomerContent;
        }
        field(50065; "Enable Maya Integration"; Boolean)
        {
            Caption = 'Enable Maya Integration';
            DataClassification = CustomerContent;
        }
        field(50066; "Loyalty V2 POS Setup Endpoint"; Text[30])
        {
            Caption = 'Loyalty V2 POS Setup Endpoint';
            DataClassification = CustomerContent;
        }
        field(50067; "Maya Python Exe Path"; Text[60])
        {
            Caption = 'Maya Python Exe Path';
            DataClassification = CustomerContent;
        }
        field(50068; "Loyalty V2 Member Data Endpt"; Text[30])
        {
            Caption = 'Loyalty V2 Member Data Endpoint';
            DataClassification = CustomerContent;
        }
        field(50069; "Maya Terminal Timeout (ms)"; Integer)
        {
            Caption = 'Maya Terminal Timeout (ms)';
            DataClassification = CustomerContent;
        }
        field(50070; "Loyalty V2 Cancel Trans. Endpt"; Text[30])
        {
            Caption = 'Loyalty V2 Cancel Transaction Endpoint';
            DataClassification = CustomerContent;
        }
        field(50071; "Enable P2M Pay"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Enable P2M Pay';
        }
        field(50072; "P2M URL"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'P2M URL';
        }
        field(50073; "P2M SoapAction URL"; Text[60])
        {
            DataClassification = CustomerContent;
            Caption = 'P2M SoapAction URL';
        }
        field(50074; "P2M Access ID"; Text[60])
        {
            DataClassification = CustomerContent;
            Caption = 'P2M Access ID';
        }
        field(50075; "P2M Secret Key"; Text[60])
        {
            DataClassification = CustomerContent;
            Caption = 'P2M Secret Key';
        }
        field(50076; "P2M Webhook Secret"; Text[80])
        {
            DataClassification = CustomerContent;
            Caption = 'P2M Webhook Secret';
        }
        field(50077; "P2M Username"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'P2M Username';
        }
        field(50078; "P2M Password"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'P2M Password';
        }
        field(50079; "P2M Internal Url"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'P2M Internal Url';
        }
        field(50080; "P2M Internal Endpt. P2M"; Text[10])
        {
            DataClassification = CustomerContent;
            Caption = 'P2M Internal Endpoint P2M';
        }
        field(50081; "P2M Internal Endpt. Instapay"; Text[10])
        {
            DataClassification = CustomerContent;
            Caption = 'P2M Internal Endpoint Instapay';
        }
        field(50082; "P2M Internal Endpt. Pesonet"; Text[10])
        {
            DataClassification = CustomerContent;
            Caption = 'P2M Internal Endpoint Pesonet';
        }
        field(50083; "P2M Wait Response Min."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'P2M Response Wait Time Min.';
            MinValue = 1;
            MaxValue = 60;
        }
        field(50084; "P2M No. Series Ref. No."; Code[20])
        {
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(50085; "P2M Prompt API Messages"; Boolean)
        {
            Caption = 'P2M Prompt API Messages';
            DataClassification = CustomerContent;
        }
    }
    var
        IncExpAcc: Record "LSC Income/Expense Account";
        TenderType: Record "LSC Tender Type";
}
