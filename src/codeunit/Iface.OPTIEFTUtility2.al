interface "OPT IEFTUtility2"
{
    procedure DisableVoidCardPrompt(): Boolean;
    procedure VoidCardEntry2(OrgCardEntry: Record "LSC POS Card Entry"; receiptNo: Code[20]; printSlips: Boolean; var VoidCardEntryNo: Integer; var ErrorReason: Text): Boolean;
}