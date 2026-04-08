tableextension 60000 "MCB LSC Tender Type" extends "LSC Tender Type"
{
    fields
    {
        // Add changes to table fields here
        field(60000; "Pinpad Integration"; Boolean) { }
        field(60001; "CurrencyId"; Text[20]) { }
        // field(60002; MerchantID; Text[20]) { }
        // field(60003; TerminalID; Text[20]) { }
        field(60004; IDs; Text[20]) { }
    }
}