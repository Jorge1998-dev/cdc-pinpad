permissionset 60000 Lafise
{
    Assignable = true;
    Permissions = tabledata "OPT Serial Port Setup"=RIMD,
        tabledata "Trans. LAF"=RIMD,
        table "OPT Serial Port Setup"=X,
        table "Trans. LAF"=X,
        codeunit "Button Settle"=X,
        codeunit ConectApi=X,
        codeunit ConnectCom=X,
        codeunit "LAF Printing Utility"=X,
        codeunit "OPT Events Pinpad"=X,
        codeunit "OPT POS EFT Utility"=X,
        codeunit "OPT POS Transaction"=X,
        codeunit "OPT POS Transaction EFT"=X,
        codeunit "OPT POS Transaction Events"=X,
        codeunit "OPT POS Transaction Functions"=X,
        codeunit "OPT POS Transaction Impl"=X,
        codeunit "OPT POS Void Card Functions"=X,
        codeunit "OPTs POS Transaction GUI"=X,
        page "Lafise Log"=X,
        page "Serial Ports Setup"=X;
}