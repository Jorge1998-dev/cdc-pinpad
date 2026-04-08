tableextension 60001 "MCB LSC POS Card entry" extends "LSC POS Card Entry"
{
    fields
    {
        // Add changes to table fields here
        field(50000; "Voucher Number"; Text[100]) { }
    }

    var
        myInt: Integer;
}