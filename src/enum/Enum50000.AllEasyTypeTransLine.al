enum 50000 "AllEasy Type Trans. Line"
{

    value(0; "") { }
    value(1; "Cash In Inquire") { }
    value(2; "Cash In Credit") { }
    value(3; "Cash Out Inquire") { }
    value(4; "Cash Out Process") { }
    value(5; "Pay QR Inquire") { }
    value(6; "Pay QR Process") { }
    value(7; "HeartBeat Check")
    {
        Caption = 'gcash.common.heart.beat';
    }
    value(8; "Retail Pay")
    {
        Caption = 'gcash.acquiring.retail.pay';
    }
    value(9; "Query Transaction")
    {
        Caption = 'gcash.acquiring.order.query';
    }
    value(10; "Cancel Transaction")
    {
        Caption = 'gcash.acquiring.order.cancel';
    }
    value(11; "Refund Transaction")
    {
        Caption = 'gcash.acquiring.order.refund';
    }
}
