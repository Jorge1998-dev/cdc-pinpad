pageextension 60000 "MCB LSC Tender Type Card" extends "LSC Tender Type Card"
{
    layout
    {
        addafter(General)
        {
            group(Pinpad)
            {
                field("Pinpad Integration"; Rec."Pinpad Integration") { ApplicationArea = all; }
                // field(MerchantID; Rec.MerchantID) { ApplicationArea = all; }
                // field(TerminalID; Rec.TerminalID) { ApplicationArea = all; }
                field(CurrencyId; Rec.CurrencyId) { ApplicationArea = all; }
                field(IDs; Rec.IDs) { ApplicationArea = all; }
            }

        }
    }
}