table 50000 "AllEasy Trans. Line"
{
    Caption = 'AllEasy Trans. Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Receipt No."; Code[20])
        {

        }
        field(2; "Line No."; Integer)
        {

        }
        field(3; "Store No."; Code[20])
        {

        }
        field(4; "POS Terminal No."; Code[20])
        {

        }
        field(5; "Trans. Date"; Date)
        {

        }
        field(6; "Trans. Time"; Time)
        {

        }
        field(7; "AllEasy Process Type"; Enum "AllEasy Type Trans. Line")
        {

        }
        field(8; "Res. Cash In/Out ID"; Code[20])
        {

        }
        field(9; "Res. Cash In/Out Code"; Code[20])
        {

        }
        field(10; "Res. Cash In/Out Message"; Text[100])
        {

        }
        field(11; "Res. Cash In/Out Mobile No."; Text[50])
        {

        }
        field(12; "Res. Cash In/Out Date"; Text[50])
        {

        }
        field(13; "Res. Cash In/Out Status"; Text[50])
        {

        }
        field(14; "Res. Cash In Ref. No."; Text[50])
        {

        }
        field(15; "Res. Cash Out Subscriber Name"; Text[180])
        {

        }
        field(16; "Res. Cash Out Ref. No."; Text[60])
        {

        }
        field(17; "Res. Cash Out  Amount"; Decimal)
        {

        }
        field(18; "Res. Cash In/Out Birthdate"; Text[50])
        {

        }
        field(19; "Res. Cash In/Out Address"; Text[100])
        {

        }
        field(20; "Res. Cash In is Valid"; Boolean)
        {

        }
        field(21; "Res. Cash In Remarks"; Text[100])
        {

        }
        field(22; "Amount"; Decimal)
        {

        }
        field(23; "Trans. Ref. No."; Text[100])
        {

        }
        field(24; "Res. Cash Out Branch"; Text[100])
        {

        }
        field(25; "Res. Cash Out Created At"; Text[50])
        {

        }
        field(26; "Res. Cash Out Validated By"; Text[60])
        {

        }
        field(27; "Res. Cash Out Validated At"; Text[50])
        {

        }
        field(28; "Trans. Line No."; Integer)
        {

        }

        field(29; "Res. PayQR Status Code"; Code[20])
        {

        }
        field(30; "Res. PayQR Message"; Text[50])
        {

        }
        field(31; "Res. PayQR ID"; Code[20])
        {

        }
        field(32; "Res. PayQR Code"; Code[20])
        {

        }
        field(33; "Res. PayQR Type"; Code[50])
        {

        }
        field(34; "Res. PayQR Ref. No."; Code[30])
        {

        }
        field(35; "Res. PayQR Remaining Balance"; Decimal)
        {

        }
        field(36; "Res. PayQR Profile ID"; Code[20])
        {

        }
        field(37; "Res. PayQR First Name"; Text[60])
        {

        }
        field(38; "Res. PayQR Last Name"; Text[60])
        {

        }
        field(39; "Res. PayQR Mobile No."; Text[50])
        {

        }
        field(40; "Res. PayQR Status"; Code[50])
        {

        }
        field(41; "Res. PayQR is Expired"; Boolean)
        {

        }
        field(42; "Res. PayQR Expiration"; Text[60])
        {

        }
        field(43; "Res. PayQR Created At"; Text[60])
        {

        }
        field(44; "Res. Cash In First Name"; Text[60])
        {

        }
        field(45; "Res. Cash In Middle Name"; Text[60])
        {

        }
        field(46; "Res. Cash In Last Name"; Text[60])
        {

        }
        field(47; "Res. Cash In/Out Amount"; Decimal)
        {

        }
        field(48; "Res. PayQR Amount"; Decimal)
        {

        }
        field(49; "Res. PayQR Merchant Name"; text[60])
        {

        }
        field(50; "Res. PayQR DateTime"; Text[50])
        {

        }
    }
    keys
    {
        key(PK; "Receipt No.", "Line No.")
        {
            Clustered = true;
        }
    }
}
