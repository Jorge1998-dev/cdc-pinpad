interface "Opt LSC IEFTPrinter"
{
    procedure PrintBuffer(pPrinterID: Text; var pPrintBufferRecRef: RecordRef; var pErrorText: Text): Boolean
}
