codeunit 60006 "OPT POS Transaction Events"
{
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeTenderOp(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterRefundPressed(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeTotDiscPr(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterTotDiscPr(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeTotDiscAm(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterTotDiscAm(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeChangePrice(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterChangePrice(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeTotalExecuted(var POSTransaction: Record "LSC POS Transaction"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterTotalExecuted(var POSTransaction: Record "LSC POS Transaction")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeChangeQty(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterChangeQty(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterDiscAmDiscountLine(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterDiscAmNegativeDiscountLine(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterDiscPrDiscountLine(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterDiscPrNegativeDiscountLine(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforePostPOSTransaction(var POSTransaction: Record "LSC POS Transaction")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterPostPOSTransaction(var POSTransaction: Record "LSC POS Transaction")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterVoidPressed(var POSTransaction: Record "LSC POS Transaction")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterVoidPressedExecuted(var POSTransaction: Record "LSC POS Transaction")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeVoidLine(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var Handled: Boolean; var HandledErrorText: Text; var ReturnValue: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterVoidLine(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeMessageBeep(var POSTransaction: Record "LSC POS Transaction"; Message: Text; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeErrorBeep(var POSTransaction: Record "LSC POS Transaction"; Message: Text; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforePosMessage(var POSTransaction: Record "LSC POS Transaction"; Message: Text; var IsHandled: Boolean; var ReturnValue: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforePosConfirm(var POSTransaction: Record "LSC POS Transaction"; Message: Text; var IsHandled: Boolean; var ReturnValue: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeVoidPrepaymentLine(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterVoidPrepaymentLine(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeVoidPrepayment(var POSTransaction: Record "LSC POS Transaction")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterVoidPrepayment(var POSTransaction: Record "LSC POS Transaction")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterCommitPaymentLine(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; TenderType: Code[10])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterCustomerPressed(var POSTransaction: Record "LSC POS Transaction")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeSetCustomer(var POSTransaction: Record "LSC POS Transaction"; var pCustomerNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterValidateCustomerTender(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var CustomerOrCardNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterValidateCustomerLine(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var CustomerOrCardNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeItemLine(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; Balance: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeInsertItemLine(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var CompressEntry: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterInsertItemLine(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeInsertPaymentLine(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var TenderTypeCode: Code[10]; Balance: decimal; PaymentAmount: Decimal; STATE: Code[10]; var isHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeRunCommand(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var POSMenuLine: Record "LSC POS Menu Line"; var isHandled: Boolean; TenderType: Record "LSC Tender Type"; var CusomterOrCardNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterRunCommand(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var Command: Code[20]; var POSMenuLine: Record "LSC POS Menu Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeOpenDrawer(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterWaitDrawerClosed(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeSuspend(var POSTransaction: Record "LSC POS Transaction")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterSuspend(var POSTransaction: Record "LSC POS Transaction")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterSuspendInsertNewTransaction(var NewPOSTransaction: Record "LSC POS Transaction")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeRetSuspended(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterRetSuspended(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeRemoveTender(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeTenderDecl(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeValidatePriceCheck(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterValidatePriceCheckPhase2(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var Price: Decimal; var ItemNo: Code[20]; var Ishandled: Boolean; var LinkedItemsActive: Boolean; var UOMSet: Code[10]; var PriceCheckUnitOfMeasure: Code[10])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeReturnPriceCheckInfoTxt(var Info: Text; Item: Record Item; Price: Decimal; UOM: Code[10])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeNegAdj(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterSelectCustomer(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterProcessRefundSelection(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeInsertNewTransaction(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterInsertNewTransaction(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnCalcPeriodicBeforeRecalc(POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterItemLine(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeInit(var POSTransaction: Record "LSC POS Transaction")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterInit(var POSTransaction: Record "LSC POS Transaction")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeCheckInfoCodeV2(var POSTransaction: Record "LSC POS Transaction"; var Infocode: Record "LSC Infocode"; Module: Code[10]; var IsHandled: Boolean; var ReturnValue: Boolean; var InfoUtil: Codeunit "LSC POS Infocode Utility")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterCheckInfoCode(var POSTransaction: Record "LSC POS Transaction"; var Infocode: Record "LSC Infocode"; var POSTransLine: Record "LSC POS Trans. Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeProcessInfoCode(var POSTransaction: Record "LSC POS Transaction"; var Infocode: Record "LSC Infocode")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterProcessInfoCode(var POSTransaction: Record "LSC POS Transaction"; var Infocode: Record "LSC Infocode")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeCardSlipsPrintingConfirmed(var POSTransaction: Record "LSC POS Transaction"; PrintReceiptWasConfirmed: Boolean; var ContinueWithCardSlipPrinting: Boolean; var IsHandled: Boolean)
    begin
    end;

    #region X/Z report integration events

    [Obsolete('Replaced with OnBeforeEFTGetXReportPOSConfirm. Note: Use new setup POS Terminal."Include EFT ZReport" to determine if user should be asked if the EFT information should be included. AskUser variable will be obsoleted.', '22.2')]
    [IntegrationEvent(false, false)]
    internal procedure OnEFTGetXReportBeforePOSConfirm(var AskUser: Boolean; var IsHandled: Boolean);
    begin
    end;

    [Obsolete('Replaced with OnBeforeEFTGetZReportPOSConfirm. Note: Use new setup POS Terminal."Include EFT ZReport" to determine if user should be asked if the EFT information should be included. AskUser variable will be obsoleted.', '22.2')]
    [IntegrationEvent(false, false)]
    internal procedure OnEFTGetZReportBeforePOSConfirm(var AskUser: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeEFTGetXReportPOSConfirm(var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeEFTGetZReportPOSConfirm(var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforePrintXReport(var POSTransaction: Record "LSC POS Transaction"; var DoCheck: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterPrintXReport(var POSTransaction: Record "LSC POS Transaction"; DoCheck: Boolean; AskUser: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforePrintZReport(var POSTransaction: Record "LSC POS Transaction"; var DoCheck: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterPrintZReport(var POSTransaction: Record "LSC POS Transaction"; DoCheck: Boolean; AskUser: Boolean)
    begin
    end;

    #endregion

    [IntegrationEvent(false, false)]
    internal procedure OnAfterValidateItemLine(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var Proceed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeIncExpLine(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterIncExpLine(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeAskForQuantity(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeAskForWeight(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeAskForCard(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var PaymentAmount: Decimal; var Proceed: Boolean; var TenderTypeCode: Code[10])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterInsertPaymentLine(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var TenderTypeCode: Code[10]; var SkipCommit: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterTenderKeyPressed(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var TenderTypeCode: Code[10])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterTenderKeyExecuted(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var TenderTypeCode: Code[10])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterTenderKeyPressedEx(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var TenderTypeCode: Code[10]; var TenderAmountText: Text; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeInsertPayment_TenderKeyExecutedEx(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var TenderTypeCode: Code[10]; var TenderAmountText: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterTenderKeyExecutedEx(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var TenderTypeCode: Code[10]; var TenderAmountText: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeValidateCard(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var TenderTypeCode: Code[10])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterValidateCard(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var TenderTypeCode: Code[10])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeValidateCustomer(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var CustomerOrCardNo: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeVoidTransaction(var POSTransaction: Record "LSC POS Transaction"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterVoidTransaction(var POSTransaction: Record "LSC POS Transaction")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeLogoff(var POSTransaction: Record "LSC POS Transaction"; var SalesType: Record "LSC Sales Type"; var closePos: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterLogoff(var POSTransaction: Record "LSC POS Transaction"; var SalesType: Record "LSC Sales Type"; var closePos: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeCancel(var POSTransaction: Record "LSC POS Transaction"; var CurrInput: Text; var Hard: boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforePurge(var POSTransaction: Record "LSC POS Transaction")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeProcessBarcode(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnProcessBarcode(var POSTransaction: Record "LSC POS Transaction"; var BarcodeMask: Record "LSC Barcode Mask"; var CurrInput: Text; var Proceed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterProcessBarcode(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeChangeUnitOfMeasure(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterChangeUnitOfMeasure(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeCloseForm(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeGetContext(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterGetContext(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeLogin(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterLogin(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeKeyLockChanged(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterKeyLockChanged(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeOnTimer(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeStaffLogon(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var Staff: Record "LSC Staff")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterStaffLogon(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var Staff: Record "LSC Staff")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterValidateCustomer(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var CustomerOrCardNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterValidateIncExpLine(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var Proceed: Boolean; var IncExpAccount: Record "LSC Income/Expense Account")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterValidateChangeQty(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var Proceed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeValidateChangePrice(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var Proceed: Boolean; var ErrorText: Text[250])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterValidateChangePrice(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var Proceed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterOpenDrawerPressed(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var RoleID: Code[10])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure ItemLineOnAfterItemGet(var POSTransLine: Record "LSC POS Trans. Line"; var Proceed: Boolean; Item: Record Item; var LastItemNo: Code[20]; var CurrQty: Decimal; var MultiplyWith: Decimal; var WeightInKgsFromScannedDatabar: Decimal; REC: Record "LSC POS Transaction"; var ErrorText: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeCheckMemberCard(var PosTransaction: Record "LSC POS Transaction"; var MemberAccountTemp: Record "LSC Member Account" temporary; var MemberContactTemp: Record "LSC Member Contact" temporary; var MembershipCardTemp: Record "LSC Membership Card" temporary; var Handled: boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterCheckMemberCardV2(var PosTransaction: Record "LSC POS Transaction"; var MemberAccountTemp: Record "LSC Member Account" temporary; var MemberContactTemp: Record "LSC Member Contact" temporary; var MembershipCardTemp: Record "LSC Membership Card" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnInsertCouponLineBeforeInsertLine(var PosTransaction: Record "LSC POS Transaction"; var NewLine: Record "LSC Pos Trans. line"; CouponHeader: Record "LSC Coupon Header"; DiscountValue: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterEFTResponseDataSet(var TempPostingExchField: Record "Data Exch. Field" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeVoidCard(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; VoidCardEntry: Record "LSC POS Card Entry"; var CardEntryNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeProcessTransForPostingByState(var POSTrans: Record "LSC POS Transaction")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterProcessTransForPostingByState(var POSTrans: Record "LSC POS Transaction")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnVoidTransaction(var POSTrans: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeVoidLinePressedEx(var POSTrans: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeSelectCustPressedEx(var pCustNo: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeVoidAndCopyTransaction(var Transaction: Record "LSC Transaction Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterValidateQuantity(var NewQuantity: Decimal; var Line: Record "LSC POS Trans. Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterCalcTotals(var Rec: Record "LSC POS Transaction"; var Balance: Decimal; var RealBalance: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterVoidPostedTransaction(var Rec: Record "LSC POS Transaction")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeOpenVariantLookup(var tmpValue: Decimal; var PosVariant: Record "Item Variant"; var ItemNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterPreAuthPressed(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var TenderTypeCode: Code[10])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterPreAuthExecuted(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var TenderTypeCode: Code[10])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeIsBlockSaleOnPOS(IsReturnSale: Boolean; Item: Record Item; var MultiplyWith: Decimal; var FixedQty: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeSelectCustPressed(var CustomerMandatory: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeInsertCopiedTransLine(var newLine: Record "LSC POS Trans. Line"; var pPosTransLineBuffer: Record "LSC POS Trans. Line" temporary; var pSelectionBuffer: Record "LSC POS Trans. Line" temporary; var pTrans: Record "LSC Transaction Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeInsertPosTransLineBuffer(var pPosTransLineBuffer: Record "LSC POS Trans. Line" temporary; var TransSalesEntry: Record "LSC Trans. Sales Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterInsertCopiedTransLine(var newLine: Record "LSC POS Trans. Line"; var pPosTransLineBuffer: Record "LSC POS Trans. Line" temporary; var pSelectionBuffer: Record "LSC POS Trans. Line" temporary; var pTrans: Record "LSC Transaction Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnStateChanged(var POSTransaction: Record "LSC POS Transaction"; fromState: Text; toState: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterFinalizePosting(var LastTransaction: Record "LSC Transaction Header"; POSTransPostingStateTmp: Record "LSC POS Trans. Posting State" temporary; StayInPOSOnPost: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure ItemLineOnCheckRetrievedFromReceipt(POSTransaction: Record "LSC POS Transaction"; var newLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var IsHandled: Boolean; MultiplyWit: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure onAskForDataEntryNo()
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeTransactionTendered(var POSTransaction: Record "LSC POS Transaction"; var TenderType: Record "LSC Tender Type"; var VoidInProcess: Boolean; var Balance: Decimal; var TmpAmount: Decimal; var RoundedValue: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnValidateDataEntryInputExpirationDate(var DataEntryBalance: Decimal; var ExpirationDate: Date; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeCopyTransaction(var Transaction: Record "LSC Transaction Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeSetFunctionModeSalesPressed(POSFuncProfile: Record "LSC POS Func. Profile"; POSTransaction: Record "LSC POS Transaction"; Keyed: Boolean; var CurrInput: Text; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeClearDiscOfferVoidLinePressed(PosFunc: Codeunit "LSC POS Functions"; var POSTransLine: Record "LSC POS Trans. Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeProcessItemPointOfferOnClosePanel(var TmpSelectedItemPointLine: Record "LSC Periodic Discount Line" temporary; var pCurrLine: Record "LSC POS Trans. Line"; var NewLine: Record "LSC POS Trans. Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeAskForPrice(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterAskForPrice(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var NewPOSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforePrintSlipCopy(var TransactionHeader: Record "LSC Transaction Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterPrintSlipCopy(var TransactionHeader: Record "LSC Transaction Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeProcessCustomer(var POSTransaction: Record "LSC POS Transaction")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeOpenNumericKeyboard(var Caption: Text; var KeybType: Integer; var DefaultValue: Text; var TriggerNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeEnterTenderTypeAmount(var PaymentAmount: Decimal; StoreNo: Code[10]; TenderTypeCode: Code[10]; Balance: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeShowDrawerOpenWarning(var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnInfocodeDisplayNumpad(var Infocode: Record "LSC Infocode"; var Input: Text; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterValidatePriceCheck(var Description: Text; ItemDescription: Text; PriceCheckUnitOfMeasure: Code[10]; Qty: Decimal; PriceCheckPrice: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnValidatePriceCheckBeforeTransPerDiscDelete(TmpLine: Record "LSC POS Trans. Line"; TransPerDisc: Record "LSC POS Trans. Per. Disc. Type"; var InfoTextDescription1: Text; var InfoTextDescription2: Text)
    begin
    end;

    [Obsolete('Breaks Scale certification.', '22.4')]
    [IntegrationEvent(false, false)]
    internal procedure OnAfterAskForWeight2(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var Item: Record Item; var IsHandled: Boolean; var CurrQty: Decimal; var MultiplyWith: Decimal; var ScalePrice: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeValidateTenderInTenderKeyPressed(var ErrorTextIfNotProceed: Text; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnVoidLine(var POSTransLine: Record "LSC POS Trans. Line"; var IsHandled: Boolean; var TenderType: Record "LSC Tender Type"; StoreSetup: Record "LSC Store"; var REC: Record "LSC POS Transaction"; var CardEntry: Record "LSC POS Card Entry"; var CustomerOrCardNo: Code[20]; var ReadFromMSR: Boolean; var ChangeTender: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterVoidMemberLineProcessed(var POSTransLine: Record "LSC POS Trans. Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnTenderKeyPressedEx_OnBeforeCheckPrinterActive(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var TenderTypeCode: Code[10]; var TenderAmountText: Text; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnInit_OnAfterGetPOSTransaction(var POSTransaction: Record "LSC POS Transaction"; CurrTableNo: Integer; CurrTableDescr: text; CurrDinResNo: code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnValidatePricePermissionItem(var POSTransLine: Record "LSC POS Trans. Line"; var Store: Record "LSC Store"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnOkNewInput(FunctionSetup: Record "LSC POS Command"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnGetOrderPressedAfterInfoTextDescription(var CurrInput: Text; var POSTransaction: Record "LSC POS Transaction"; var DocType: Enum "Sales Document Type"; var OrderNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeNewLineInsertTextLinkPressed(var POSTransLine: Record "LSC POS Trans. Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnInfocodeDisplayAlphabeticPad(var Info: Record "LSC Infocode"; var CurrInput: Text; var DefaultValue: Text; var LineRec: Record "LSC POS Trans. Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnPanelOKEditMemberContactOK(var POSTransaction: Record "LSC POS Transaction"; var MemberCardNo: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeExitWhenResultNotOk(var Payload: Text; var InputValue: Text; var ResultOK: Boolean; var KeyboardTriggerToProcess: Integer; var IsHandled: Boolean; var Rec: Record "LSC POS Transaction")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterOpenDrawerPressedEx(RoleId: Code[10]; TrainingActive: Boolean; var TransactionHdr: Record "LSC Transaction Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeSetFunctionModeGetNextInQueuePressed(POSFuncProfile: Record "LSC POS Func. Profile"; POSTransaction: Record "LSC POS Transaction"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeSetFunctionModeRefundPressed(POSFuncProfile: Record "LSC POS Func. Profile"; POSTransaction: Record "LSC POS Transaction"; Keyed: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeSetFunctionModeUseTransaction(POSFuncProfile: Record "LSC POS Func. Profile"; POSTransaction: Record "LSC POS Transaction"; NewTrans: Code[20]; UpdDisp: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeValidateSalesPerson(POSFuncProfile: Record "LSC POS Func. Profile"; POSTransaction: Record "LSC POS Transaction"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterValidateSalesPersonStaffStore(Staff: Record "LSC Staff")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeProcessPostingByState2(var POSTransaction: Record "LSC POS Transaction"; var POSTransPostingStateTemp: Record "LSC POS Trans. Posting State" temporary; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeSetFunctionModeInit(var PosFuncProfile: Record "LSC POS Func. Profile"; var POSTransaction: Record "LSC POS Transaction"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterProcessSalesPerson(POSFuncProfile: Record "LSC POS Func. Profile"; POSTransaction: Record "LSC POS Transaction"; var CurrInput: Text)
    begin
    end;

    [IntegrationEvent(true, false)]
    internal procedure OnBeforeSetTracking(var POSTrans: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var ItemPhase: Integer; var SerialTracking: Boolean; var LotTracking: Boolean; var SerialNo: Code[50]; var LotNo: Code[50]; var PreSetSerialLotNo: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure SuspendTransWithSalesTypeOnBeforeDeleteRecord(var POSTrans: Record "LSC POS Transaction"; SalesType: Record "LSC Sales Type"; var SendPOSTransSuccess: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeEFTCheckLastTrans(var pForce: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnMakeRepayTransBeforePosConfirm(SalesType: Record "LSC Sales Type"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeProcessCoupon(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var ScannedDatabar: Text[100]; var CouponCodeNextItem: Code[22]; var IsHandled: boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterDescriptionValidateVariant(PosFuncProfile: Record "LSC POS Func. Profile"; var POSTransLine: Record "LSC POS Trans. Line"; PosVariant: Record "Item Variant")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterValidateVariant(PosFuncProfile: Record "LSC POS Func. Profile"; POSTransaction: Record "LSC POS Transaction")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeValidateLotNo(NewLine: Record "LSC POS Trans. Line"; var IsHandled: Boolean; var ReturnValue: Boolean; SerialNo: Code[50]; LotNo: Code[50])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeTDCommandPressed(var POSTransaction: Record "LSC POS Transaction"; EndOfDay: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeMarkPressed(POSTransaction: Record "LSC POS Transaction"; POSTransLine: Record "LSC POS Trans. Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterProcessItemPhaseZero(Item: Record Item; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeAskForSuggestedQtyItemPhase2v2(var SuggestedQty: Decimal; var PosTransLine: Record "LSC POS Trans. Line"; var MultiplyWith: Decimal; Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnInitInsertItemLine(PosTrans: Record "LSC POS Transaction"; PosTransLine: Record "LSC POS Trans. Line"; Customer: Record Customer; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforePrintLastSlipCopy(TransHeader: Record "LSC Transaction Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeSuspendHospSalesTypeCheckReturnsError(POSTransaction: Record "LSC POS Transaction"; var IsHandled: Boolean; var ReturnValue: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeSelectCustPressedViewCustomerEx(var CustomerMandatory: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterFloat(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterUpdateMemberContext(var POSTransaction: Record "LSC POS Transaction"; POSFunction: Codeunit "LSC POS Functions")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnValidatePriceCheckOnBeforePerDiscLineFilterByType(var PeriodicDiscountLineRec: Record "LSC Periodic Discount Line"; var Step: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnValidatePriceCheckOnBeforePerDiscLineFilterByNo(var PeriodicDiscountLineRec: Record "LSC Periodic Discount Line"; Item: Record Item; var Step: Integer; var LineFound: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnFindActiveOfferInStoreOnBeforeAddQtyDiscV2(var PeriodicDiscountLines: Record "LSC Periodic Discount Line"; var PeriodicDiscount: Record "LSC Periodic Discount"; var TmpLine: Record "LSC POS Trans. Line"; var rboPriceUtil: Codeunit "LSC Retail Price Utils"; var found: Boolean; Store: Record "LSC Store"; Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeUnmarkSelectedLines(var POSTransaction: Record "LSC POS Transaction"; var SelectedPOSTransLine: Record "LSC POS Trans. Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeProcessSelectedLines(var POSTransaction: Record "LSC POS Transaction"; var SelectedPOSTransLine: Record "LSC POS Trans. Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforevoidLinePressed(var POSTransaction: Record "LSC POS Transaction"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeGetOrder(var LSCPosTransaction: Record "LSC POS Transaction"; DocType: Enum "Sales Document Type"; DocNumber: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterGetRecord(var LSCPosTransaction: Record "LSC POS Transaction")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeAskForCustomer(var CardEntry: Record "LSC POS Card Entry"; var LSCPosTransaction: Record "LSC POS Transaction"; var PosTerminal: Record "LSC POS Terminal")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeCheckScaleDevice(var LSCPosTransaction: Record "LSC POS Transaction"; var Item: Record Item; var LinePriceGroup: Code[10]; var LineSalesType: Code[20]; var IsHandled: boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterIsCouponValid(PosTransaction: Record "LSC POS Transaction"; POSTransLine: Record "LSC POS Trans. Line"; CouponHeader: Record "LSC Coupon Header"; var ErrorMsg: Text[250]; var IsHandled: Boolean; var ReturnValue: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeUpdateGlobalMemberInformation(var PosTransaction: Record "LSC POS Transaction"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeUpdatePosInfoTextsAndAfterPOSTransCommit(PosTransaction: Record "LSC POS Transaction"; var ContinueProcessing: Boolean; POSTransPostingStateTmp: Record "LSC POS Trans. Posting State" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforePrintSuspendSlip(var PosTransaction: Record "LSC POS Transaction"; var GrossAmount: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeAssigningSalesStaff(POSTransaction: Record "LSC POS Transaction"; PosFuncProfile: Record "LSC POS Func. Profile"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure ClearPOSTransactionOnBeforeModify(var POSTransaction: Record "LSC POS Transaction")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeSuspendPrinting(SalesType: Record "LSC Sales Type"; var POSTransaction: Record "LSC POS Transaction"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnSuspendNotConfirmedBeforeConfirm(var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeExitProcessLookupResultKeyValueEmpty(LookupID: Text; var MenuLine: Record "LSC POS Menu Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterValidateItemNoInPhaseZero(POSTransaction: Record "LSC POS Transaction"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeValidateTrackingOnTotal(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterViewCustomerEx(CustomerOk: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeEmailOrPrintV2(POSHardwareProfile: Record "LSC POS Hardware Profile"; POSTerminal: Record "LSC POS Terminal"; LastTransaction: Record "LSC Transaction Header"; var POSTransPostingStateTmp: Record "LSC POS Trans. Posting State" temporary; var IsHandled: Boolean; var ReturnValue: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeCustomerOrderPayment(var POSTransaction: Record "LSC POS Transaction"; POSTransLine: Record "LSC POS Trans. Line"; var CustomerOrderLine_Temp: Record "LSC Customer Order Line" temporary; var AddExtraPaymentToCO: Option; var CollectingOrder: Boolean; var VendorSourcing: Boolean; var PrepayCustomerOrder: Boolean; var InfoTextDescription: Text; var InfoTextDescription2: Text; var CORemainingAmount: Decimal; var ReturnValue: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterClearPOSTransaction(POSTransaction: Record "LSC POS Transaction")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeCheckTracking(var SerialTracking: Boolean; var LotTracking: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeSetCOPaymentAmtOnTenderKeyPressedEx(var POSTransaction: Record "LSC POS Transaction"; var CustomerOrderHeader_Temp: Record "LSC Customer Order Header" temporary; var CustomerOrderLine_Temp: Record "LSC Customer Order Line" temporary; var PaymentAmount: Decimal; var PrepayCustomerOrder: Boolean; var COWasCreated: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure COScanned(CurrInput: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnValidatePriceCheckOnAfterSetMaxNoOfSteps(var MaxNoOfSteps: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnValidatePriceCheckOnAfterCalcDiscPrice(TmpLine: Record "LSC POS Trans. Line"; PosFuncProfile: Record "LSC POS Func. Profile"; DiscPct: Decimal; var TmpDiscPrice: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeSelectDefaultMenuInCancelPressed(var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeExchangeLookup(var ExchangeTransaction: Record "LSC Transaction Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeExchangeProcessLookupResult(var REC: Record "LSC POS Transaction"; var POSRefundMgt: Codeunit "LSC POS Refund Mgt."; var stateTxt: Code[30]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeTotDiscPrPressed(var POSTransaction: Record "LSC POS Transaction"; var Value: Text[30]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeTotalPressed(var POSTransaction: Record "LSC POS Transaction"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeInsertTotalBenefitsLine(var POSTransaction: Record "LSC POS Transaction"; var TransBenefitCollectBuffer: Record "LSC Trans. Disc. Benefit Entry" temporary; var MultiplyWith: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeTotalCheckExchangeTransaction(var POSTransaction: Record "LSC POS Transaction"; var IsHandled: Boolean; var ReturnValue: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeValidateCRLines(pPosTransLineBuffer: Record "LSC POS Trans. Line" temporary; var SkipThis: Boolean; var pErrorText: Text[250])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure PosTransactionOnAfterVoidTransaction(var Line: Record "LSC POS Trans. Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnProcessSuspensionByState_SecErrorChecking(PosTransaction: Record "LSC POS Transaction"; var Cancel: Boolean; ErrorText: Text[250])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeProcessScannerFunctionCode(FunctionSetup: Record "LSC POS Command"; var IsHandled: Boolean; var Found: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterValidateDisc(var LineRec: Record "LSC POS Trans. Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeLookupCall(var LookupSetup: Record "LSC POS Lookup"; var PosTransLine: Record "LSC POS Trans. Line"; MgrKey: Boolean; CustomerNo: Code[20]; ExecuteCommand: Boolean; FormID: Code[20]; "Filter": Code[29]; var LookupRecRef: RecordRef; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeGetLookupResult(LookupID: Text; var Command: Code[20]; var KeyValue: Code[30]; var Execute: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnLookupResultVoidTR(var Command: Code[20]; var keyValue: Code[30]; var LookupRecID: RecordID; var IsHandled: Boolean; var IsExit: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnLookupResultOtherCommand(var Command: Code[20]; var keyValue: Code[30]; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeFindTenderTypeTable(POSTransaction: Record "LSC POS Transaction"; var TenderTypeTable: Record "LSC Tender Type Setup");
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAccNoCheckOnIncExpPressed(var AccNo: Code[20]; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeMakeRepayTransModifyRec(var Rec: Record "LSC POS Transaction");
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeNegAdjPressedStartNewTrans(var Rec: Record "LSC POS Transaction");
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterRecFound(var Rec: Record "LSC POS Transaction");
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeMemberTender(var MemberContactTEMP: Record "LSC Member Contact" temporary; var TenderType: Record "LSC Tender Type"; var Rec: Record "LSC POS Transaction");
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeRefundPressedStartNewTrans(var Rec: Record "LSC POS Transaction");
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeSalePressedStartNewTrans(var Rec: Record "LSC POS Transaction");
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterSalePressedStartNewTrans(POSFuncProfile: Record "LSC POS Func. Profile"; var POSTransaction: Record "LSC POS Transaction"; Keyed: Boolean; var CurrInput: Text; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeTotDiscAmPressed(var Value: Text[30]; var TotAmount: Boolean; var InfocodeCheck: Boolean; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeProcess_CHSALESTYPE_TRANS(POSTransaction: Record "LSC POS Transaction"; var SalesTypeIn: Code[20]; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnTotDiscPrPressed_OnAfterEvaluateInput(var LineRec: Record "LSC POS Trans. Line"; Dec: Decimal; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeCheckPointBalance(var Rec: Record "LSC POS Transaction"; var LineRec: Record "LSC POS Trans. Line"; var CurrInput: Text; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeAskConfirmationOnValidateCustomer(CustomerNo: code[20]; var CustConfirmOk: Boolean; var AskConfirmation: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeFilterRecOnInit(var FilterFrom: Code[20]; var FilterTo: Code[20]);
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeKeyboardTriggerProcess(KeyboardTriggerToProcess: Integer; InputValue: Text; var NumPadTrigger: Enum "LSC POS Trans. Numpad Trigger");
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterSetQuantityAndPrice(var ItemQty: Decimal; var OrgPrice: Decimal);
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterAdjustAmount(TenderType: Record "LSC Tender Type"; PosTransaction: Record "LSC POS Transaction"; var PaymentAmount: Decimal);
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnProcessLookupResult_KeyValueEmpty(var NewLine: Record "LSC POS Trans. Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnInit_OnBeforeTransDiscLoad(REC: Record "LSC POS Transaction"; STATE: Code[10])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterUpdateInputDevicesState(pFunctionSetup: Record "LSC POS Command"; pUsePostActions: Boolean; REC: Record "LSC POS Transaction"; STATE: Code[10])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnProcessFuelMessage(var PosTransLine: Record "LSC POS Trans. Line"; var PosTransaction: Record "LSC POS Transaction"; var retval: Integer; var CurrInput: Text; var CommandRetVal: Boolean; var KeyboardPrice: Decimal; var OverridePrice: Decimal; var MultiplyWith: Decimal);
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnProcessOtherInfoTrigger(SubInfo: record "LSC Information Subcode"; Info: Record "LSC Infocode"; var POSTr: record "LSC POS Transaction"; POSTerminal: Record "LSC POS Terminal"; CurrInput: Text; var isHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeIsProcessReceiptBarcode(var Handled: Boolean; CurrInput: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeEmailingInputOrPrint(var POSPrintUtility: Codeunit "LSC POS Print Utility"; LastTransaction: Record "LSC Transaction Header"; var Phase: Integer; var POSTransPostingStateTmp: Record "LSC POS Trans. Posting State"; POSHardwareProfile: Record "LSC POS Hardware Profile"; POSTerminal: Record "LSC POS Terminal"; var IsHandled: Boolean; var ReturnValue: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnTotalPressed_OnBeforeCheckEmptyLine(var REC: Record "LSC POS Transaction"; var IsHandled: Boolean; var ReturnValue: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnInit_OnAfterTenderDeclOpenOnADiffPOS(var IsHandled: Boolean; var ReturnValue: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterSetFunctionMode(var FunctionSetup: Record "LSC POS Command")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeInsertLineInsertPaymentLine(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var TenderTypeCode: Code[10]; Balance: decimal; PaymentAmount: Decimal; STATE: Code[10]; var isHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeUpdate_POSTrLine_CHSALESTYPE_TRANS(POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var SalesTypeIn: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeUpdate_DealHeaderPOSTrLine_CHSALESTYPE_TRANS(POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var SalesTypeIn: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeOpenCreatePanel(CustomerOrderLine_Temp: Record "LSC Customer Order Line" temporary; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeChangeSalesType(var SalesTypeIn: Code[20]; var Command: Enum "LSC POS Command")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterPOSInit(POSTerminal: Record "LSC POS Terminal")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnTenderKeyPressedEx_OnBeforeCheckRecStoreNo(var TenderType: Record "LSC Tender Type")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnSelectTenderType(var TenderType: Record "LSC Tender Type"; var PaymentAmt: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnProcessCustomKeyboardTrigger(KeyboardTrigger: Integer; InputValue: Text; var CurrInput: Text; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforePOSCommandCaseProcessed(POSTrans: Record "LSC POS Transaction"; POSTransLine: Record "LSC POS Trans. Line"; CurrInput: Text; POSSESSION: Codeunit "LSC POS Session"; STATE: Enum "LSC POS Transaction State"; Command: Code[20]; var Processed: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    internal procedure OnBeforeAssignPaymentLine(TenderType: Record "LSC Tender Type"; var NewLine: Record "LSC POS Trans. Line"; REC: Record "LSC POS Transaction"; StoreSetup: Record "LSC Store"; MultiplyWith: Decimal; var LineRec: Record "LSC POS Trans. Line"; var InfoTextDescription: Text; var InfoTextDescription2: Text)
    begin
    end;

    [IntegrationEvent(true, false)]
    internal procedure OnAfterPOSCommandCaseProcessed(PosCommand: Enum "LSC POS Command"; MenuLine: Record "LSC POS Menu Line"; var TenderType: Record "LSC Tender Type"; StoreSetup: Record "LSC Store"; var Balance: Decimal; var REC: Record "LSC POS Transaction"; var Currency: Record Currency; var CardEntry: Record "LSC POS Card Entry"; var CustomerOrCardNo: Code[20]; var ReadFromMSR: Boolean; var ChangeTender: Boolean; var TrainingActive: Boolean; STATE: Enum "LSC POS Transaction State"; var PaymentAmount: Decimal; var PosFunc: Codeunit "LSC POS Functions"; var CurrInput: Text; var gInsertTmpPayment: Boolean; var Processed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeAssignTenderCardTypeDescription(var NewLine: Record "LSC POS Trans. Line"; CardEntry: Record "LSC POS Card Entry"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterPurge()
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterPurgeOldTransactions()
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeCheckTransactionLines(ReceiptNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeCheckInfoCodeInputRequired(Info: Record "LSC Infocode"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeProcessRefundSelection(REC: Record "LSC POS Transaction"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeTestVoidCardEntryProcessRefundSelection(var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure GXLOnZReportSuspendProcessOnAfterVoidSuspendedTrans(POSTransaction: Record "LSC POS Transaction"; TerminalNo: Code[10])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeSetWebPrintingOfEmailReceiptFromTransOnClose(var TmpTrans: Record "LSC Transaction Header" temporary; var PrintUtil: Codeunit "LSC POS Print Utility")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnProcInfocodeBeforeDisplayCase(Info: Record "LSC Infocode"; Requested: Option AutoOnly,All,RequestOnly; InfocodeOnHeader: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeProcessInfoCodeInValidateInfocode(Infocode: Record "LSC Infocode"; Requested: Option AutoOnly,All,RequestOnly; InfocodeOnHeader: Boolean; OneSubcode: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeHandleSalesPersonMode(var REC: Record "LSC POS Transaction"; PosFuncProfile: Record "LSC POS Func. Profile"; PosCommand: Enum "LSC POS Command"; var IsHandled: boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterTransactionTendered(var RealBalance: Decimal; var InfoTextDescription2: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterTransactionTendered2(var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeCheckPermissionItemOnDiscAmPressed(LineRec: Record "LSC POS Trans. Line"; OldAmount: Decimal; AmDec: Decimal; var InfoTextDescription: Text; AmountToDisc: Decimal; var IsHandled: Boolean; var ExitProcedure: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    internal procedure OnBeforeCheckQuantityNegativeOnChangeQtyPressed(var Item: Record Item; LineRec: Record "LSC POS Trans. Line"; Dec: Decimal; var BOUtils: Codeunit "LSC BO Utils"; REC: Record "LSC POS Transaction"; StoreSetup: Record "LSC Store"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    internal procedure OnBeforeValidateInfocodeOnProcessInfoCodeInput(Requested: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforePostTransactionOnVoidTransaction(var PrintTransaction: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeVoidingPaymentOnVoidSingleLine(var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterSerialNoIsValidCheck(var IsHandled: Boolean; var ErrorText: Text[250])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeSettingPreAuthorizationAmount(POSCommand: Enum "LSC POS Command"; TransactionLine: Record "LSC POS Trans. Line"; CardEntry: Record "LSC POS Card Entry"; Balance: Decimal;
                                                      REC: Record "LSC POS Transaction"; var PreAuthAmount: Decimal; var DisplayNumPadForAmount: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeSettingPreAuthFinalizationAmount(POSCommand: Enum "LSC POS Command"; CardEntry: Record "LSC POS Card Entry"; Balance: Decimal;
                                                      REC: Record "LSC POS Transaction"; var PreAuthAmount: Decimal; var DisplayConfirmation: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeStoreOrderLimitOnPostingOrOnSuspending(ReceiptNo: Code[20]; var OrderLimit: Decimal; OnPosting: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeDealPressed(DealCode: Code[20]; var POSTransaction: Record "LSC POS Transaction"; var DealPOSTransLine: Record "LSC POS trans. Line"; var Deal: Record "LSC Offer"; var DealLinesTmp: Record "LSC Offer Line" temporary; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterInputMemberCard(var CardNo: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterAskForLotNo(var Rec: Record "LSC POS Transaction")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeProcessExternalCommand(var POSMenuLineIn: Record "LSC POS Menu Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeCalculateItemInventory(var ItemInventory: Decimal; var ItemRec: Record Item; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeOpenNumericKeyboardShippingCharge(var CustomerOrderHeader_Temp: Record "LSC Customer Order Header" temporary; var CustomerOrderLine_Temp: Record "LSC Customer Order Line" temporary; var CustomerOrderDiscountLine_Temp: Record "LSC CO Discount Line" temporary; var IsHandled: Boolean)
    begin
    end;

    #region Token Storage Events

    /// <summary>
    /// Note: If IsHandled is returned as false, the token that is created by the POS will be of type = Purchase, Initiator = CardHolder
    /// </summary>
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeGetTokenValuesForCreateToken(var Token: Record "LSC Token"; var REC: Record "LSC POS Transaction"; var IsHandled: Boolean)
    begin
    end;

    /// <summary>
    /// Note: PosCommand is always set to CardOnFile for any type of "purchase" operation i.e. void, return, sale, etc. Look at the PosTransaction values if you need to know what type ofsale is being performed.
    /// </summary>
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeCheckingMemberCardNoInValidateCardOnFile(PosCommand: Enum "LSC POS Command"; PosTransaction: Record "LSC POS Transaction"; var IsHandled: Boolean; var ValidationResult: Boolean; var ErrorReason: Text)
    begin
    end;

    /// <summary>
    /// Note: PosCommand is always set to CardOnFile for any type of "purchase" operation i.e. void, return, sale, etc. Look at the PosTransaction values if you need to know what type ofsale is being performed.
    /// </summary>
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeValidateCardOnFile(PosCommand: Enum "LSC POS Command"; PosTransaction: Record "LSC POS Transaction"; var IsHandled: Boolean; var ValidationResult: Boolean; var ErrorReason: Text)
    begin
    end;

    /// <summary>
    /// Note: This is only called if there is a token attached to the card entry
    /// </summary>
    [Obsolete('Renamed to OnBeforeCreatingTokenInSendPaymentTokenToStorageV2.', '24.0')]
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeCreatingTokenInSendPaymentTokenToStorage(var IsHandled: Boolean; CardEntry: Record "LSC POS Card Entry"; TokenType: Enum "LSC Token Type"; PosTransaction: Record "LSC POS Transaction");
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeCreatingTokenInSendPaymentTokenToStorageV2(PosTransaction: Record "LSC POS Transaction"; var Token: Record "LSC Token"; var IsHandled: Boolean);
    begin
    end;

    /// <summary>
    /// If the information about the token connection (TokenContractId and the TokenContractType) should be changed before sending the token to the storage it needs to be done here.
    /// Note: that the "LSC POS Transaction" record id cannot be used as the transaction will be moved to "LSC Transaction Header" once posted and the "LSC POS Transaction" RecordId value will be unusable
    /// </summary>
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeSendingPaymentTokenToStorage(var IsHandled: Boolean; CardEntry: Record "LSC POS Card Entry";
                        var TempToken: Record "LSC Token" temporary; var TokenContractId: RecordId; var TokenContractType: Enum "LSC Token Contract Type";
                        PosTransaction: Record "LSC POS Transaction");
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterSendingPaymentTokenToStorage(CardEntry: Record "LSC POS Card Entry"; var TempToken: Record "LSC Token" temporary;
                                       PosTransaction: Record "LSC POS Transaction";
                                       Result: Boolean; ResponseCode: Code[30]; ErrorText: Text);
    begin
    end;

    /// <summary>    
    /// If the information about the token connection (TokenContractId and the TokenContractType) should be changed before retrieving the token from the storage it needs to be done here.
    /// </summary>
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeGetPaymentTokenFromStorage(var IsHandled: Boolean; TokenType: Enum "LSC Token Type"; var TokenContractId: RecordId; var TokenContractType: Enum "LSC Token Contract Type";
                        PosTransaction: Record "LSC POS Transaction");
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterGetPaymentTokenFromStorage(var TempToken: Record "LSC Token" temporary; var Result: Boolean; var ResponseCode: Code[30]; var ErrorText: Text; TokenType: Enum "LSC Token Type"; PosTransaction: Record "LSC POS Transaction")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeSelectTokenToUseForPayment(var IsHandled: Boolean; var TempToken: Record "LSC Token" temporary; TokenType: Enum "LSC Token Type"; MemberCard: Record "LSC Membership Card"; PosTransaction: Record "LSC POS Transaction")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterSelectTokenToUseForPayment(var TempToken: Record "LSC Token" temporary; TokenType: Enum "LSC Token Type"; MemberCard: Record "LSC Membership Card"; PosTransaction: Record "LSC POS Transaction")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterAddCardToFileExecuted(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterAddCardPressed(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterCardOnFilePressed(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var TenderTypeCode: Code[10])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterCardOnFileExecuted(POSTransaction: Record "LSC POS Transaction"; POSTransLine: Record "LSC POS Trans. Line"; CurrInput: Text; TenderTypeCode: Code[10])
    begin
    end;
    #endregion

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeBalanceCheckingReturnsError(POSTransaction: Record "LSC POS Transaction"; SalesTypeCode: Code[20]; Balance: Decimal; GrossAmt: Decimal; LineDiscAmt: Decimal; PaymentAmt: Decimal; InputOrderLimit: Decimal; OnPosting: Boolean; var IsHandled: boolean; var ReturnValue: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterStartNewTransactionSalePressed(Keyed: Boolean; var REC: Record "LSC POS Transaction")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnMultiplyQtyAfterMultiplyWithCalc(var POSTransaction: Record "LSC POS Transaction"; var MultiplyWith: Decimal; var MutiplyValue: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeTotalGetRecommendation(REC: Record "LSC POS Transaction"; POSMenuLine: Record "LSC POS Menu Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnGetOutstandingBalance(REC: Record "LSC POS Transaction"; var ReturnValue: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeZReportSuspendProcess(Store: Record "LSC Store"; var NoSuspPOSTransactionsVoided: Integer; var IsHandled: Boolean; var ReturnValue: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeCheckMemberCard_POSTransaction(var CurrInput: Text; IsHandled: Boolean; var ReturnValue: Boolean)
    begin
    end;


    [IntegrationEvent(false, false)]
    internal procedure OnGetMemberInfoForPOSFailed(var CurrInput: Text; ResponseCode: Code[30]; var IsHandled: Boolean)
    begin
    end;

    [Obsolete('Replaced with OnBeforeGetDataEntryProcessInfoCodeV2', '23.0')]
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeGetDataEntryProcessInfoCode(Info: Record "LSC Infocode"; var SkipInput: Boolean; var MoreInfo: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterGetVoucherNoValidateDataEntryInput(var POSDataEntryTypeCode: Code[20]; var PosDataEntryBalanceOnly: Boolean; VoucherNo: Code[20]; var ErrorOccured: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeExtraPrintRequired(var ReturnValue: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterGetMemberDescription(var POSTransLine: Record "LSC POS Trans. Line"; MemberName: Text; MemberCardNo: Text[100])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterValidateRecordIDInputBarcodes(inRecRef: RecordRef; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeGetDataEntryProcessInfoCodeV2(var Infocode: Record "LSC Infocode"; var SkipInput: Boolean; var MoreInfo: Boolean; var IsHandled: Boolean; var IsExit: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeCustomerOrderCreated(var REC: Record "LSC POS Transaction"; var DataBuffer: Record "LSC Customer Order Header" temporary; var DataLinesBuffer: Record "LSC Customer Order Line" temporary; var DataDiscountLineBuffer: Record "LSC CO Discount Line" temporary; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterMarkPressed(POSTransaction: Record "LSC POS Transaction"; POSTransLine: Record "LSC POS Trans. Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeInsertMemberLine(var Rec: Record "LSC POS Transaction"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeTD_TenderDeclEndOfDayPressed(Rec: Record "LSC POS Transaction"; var GlobalMenuLine: Record "LSC POS Menu Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeTendDeclareLogOff(EndOfDay: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterTendDeclareLogOff(EndOfDay: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterItemLineGetValuesFromDatabar(Databar: Text; var NewLine: record "LSC POS Trans. Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeCurrencyKeyPressed(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var CurrCode: Code[10]; var CurrStatus: Integer; var IsHandled: Boolean)
    begin
    end;

    [Obsolete('Parameters now part of POS Functionality Profile', '24.0')]
    [IntegrationEvent(false, false)]
    internal procedure OnBeforePostingGetRetriesParameters(var AllowPostingRetries: Boolean; var MaximumPostingTries: Integer)
    begin
    end;

    [IntegrationEvent(true, false)]
    internal procedure TenderKeyPressedEx_OnBeforeRecModify(var POSTransaction: Record "LSC POS Transaction"; var PaymentAmount: Decimal; TenderType: Record "LSC Tender Type"; var CurrInput: Text; var Balance: Decimal; var ErrorTextIfNotProceed: Text; var Handled: Boolean);
    begin
    end;

    [IntegrationEvent(true, false)]
    internal procedure TenderKeyPressedEx_OnAfterTenderChargeSelect(var POSTransaction: Record "LSC POS Transaction"; var PaymentAmount: Decimal; TenderType: Record "LSC Tender Type"; var CurrInput: Text; CardType: Code[10]; var Balance: Decimal; TenderChargeSelect: Integer; OldCurrInput: Decimal; var Tmp: Record "LSC Report Temp Table" temporary; var ErrorTextIfNotProceed: Text; var Handled: Boolean);
    begin
    end;

    [IntegrationEvent(true, false)]
    internal procedure TenderKeyPressedEx_OnBeforeValidateCurrInput(var POSTransaction: Record "LSC POS Transaction"; var PaymentAmount: Decimal; TenderType: Record "LSC Tender Type"; var CurrInput: Text; var Balance: Decimal; var ErrorTextIfNotProceed: Text; var Handled: Boolean);
    begin
    end;

    [IntegrationEvent(true, false)]
    internal procedure TenderKeyPressedEx_OnCancelPaymentOnBeforeExit(var POSTransaction: Record "LSC POS Transaction"; PaymentAmount: Decimal; TenderType: Record "LSC Tender Type"; CurrInput: Text; Balance: Decimal; KeyboardAmount: Boolean);
    begin
    end;

    [IntegrationEvent(true, false)]
    internal procedure TenderKeyPressedEx_OnValidateTenderOnBeforeErrorBeep(var POSTransaction: Record "LSC POS Transaction"; PaymentAmount: Decimal; TenderType: Record "LSC Tender Type"; CurrInput: Text; Balance: Decimal; KeyboardAmount: Boolean; var InfoTextDescription: Text);
    begin
    end;

    [IntegrationEvent(true, false)]
    internal procedure TenderKeyPressedEx_OnBeforeTenderCheckLoyalty(var POSTransaction: Record "LSC POS Transaction"; PaymentAmount: Decimal; TenderType: Record "LSC Tender Type"; CurrInput: Text; Balance: Decimal; KeyboardAmount: Boolean; var InfoTextDescription: Text; var IsHandled: boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeCheckShowNumericKeyboard_TenderKeyPressedEx(POSTransaction: Record "LSC POS Transaction"; TenderType: Record "LSC Tender Type"; var ShowNumKeypadCheck: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeAskForQRCode(var CurrInput: Text; var IsHandled: Boolean)
    begin
    end;

    #region NA Localization
    [IntegrationEvent(false, false)]
    internal procedure OnFindPosCommandBeforeValidateInput(PosCommand: Enum "LSC POS Command"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure ItemLineOnAfterCheckVATSetups(var POSTransaction: Record "LSC POS Transaction"; var Item: Record Item; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure ItemLineOnAfterEvaluateSalesIsReturnSales(var POSTransaction: Record "LSC POS Transaction"; var Item: Record Item; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeEvaluateSaleIsReturnItemPhase1()
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure InsertPaymentLineOnBeforeSetAmountsMultiplyInTenderOperations(TenderType: Record "LSC Tender Type"; var NewLine: Record "LSC POS Trans. Line"; PosFuncProfile: Record "LSC POS Func. Profile"; PaymentAmount: Decimal; var isHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnTransactionTenderedAfterInitAmounts(var REC: Record "LSC POS Transaction"; var TenderType: Record "LSC Tender Type"; var PaymentAmount: Decimal; var ChangeTender: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeCheckStoreVATGroupCodeIsEmpty(Store: Record "LSC Store"; var SkipVatProdPostGrpLimitationCheck: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnTenderKeyPressedExAfterInitNewLine(var REC: Record "LSC POS Transaction"; var TenderType: Record "LSC Tender Type"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeRoundPaymentAmount_TenderKeyPressedEx(var REC: Record "LSC POS Transaction"; TenderType: Record "LSC Tender Type"; PosFuncProfile: Record "LSC POS Func. Profile"; var Balance: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeClearPrepaymentFromCustomer(Rec: Record "LSC POS Transaction"; var Customer: Record Customer; StoreSetup: Record "LSC Store")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforePosFuncChangeVATBusOnLine(var POSTransaction: Record "LSC POS Transaction"; var Customer: Record Customer; var POSFunctions: Codeunit "LSC POS Functions"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeInsertIncExpLineValidateAmount(var NewLine: Record "LSC POS Trans. Line"; var PaymentAmount: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterOfferPosCalcDeletAllProcessCustomer(var POSTransLine2: Record "LSC POS Trans. Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterCalculateAmountToDiscDiscAmountGetAmountToDiscount(var POSTransLine: Record "LSC POS Trans. Line"; var AmountToDisc: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeGetBalanceCalcTotals(var POSTransaction: Record "LSC POS Transaction"; var PosFuncProfile: Record "LSC POS Func. Profile"; var Balance: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnTotalPressedBeforeDisplayTotal(PosFuncProfile: Record "LSC POS Func. Profile"; Balance: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnTotalPressedAfterSetInfoTextDescriptions(var CustomerOrderLine_Temp: Record "LSC Customer Order Line" temporary; PosFuncProfile: Record "LSC POS Func. Profile"; var InfoTextDescription: Text; var InfoTextDescription2: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnTotDiscAmPressedAfterCalcNewBalance(Rec: Record "LSC POS Transaction"; PosFunc: Codeunit "LSC POS Functions"; NewBalance: Decimal; var Tax: Decimal; var AmDec: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnValidatePriceCheckAfterInitTmpLine(var TmpLine: Record "LSC POS Trans. Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnMakeRepayTransBeforeInsertLineRec(var POSTransLine: Record "LSC POS Trans. Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeGetNewBalance(PosTrLine: Record "LSC POS Trans. Line"; var NewBalance: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnStartNewTransactionBeforeInsertLoadCardNoInNewTrans(var POSTransaction: Record "LSC POS Transaction"; Store: Record "LSC Store")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeInsertIncExpLine(var NewLine: Record "LSC POS Trans. Line"; POSTransaction: Record "LSC POS Transaction"; TransIncomeExpenseEntry_L: Record "LSC Trans. Inc./Exp. Entry")
    begin
    end;
    #endregion NA Localization

    [IntegrationEvent(false, false)]
    internal procedure OnCustomerOrderBeforeEnterShippingCost(var POSTransaction: Record "LSC POS Transaction"; var CustOrderHeaderTemp: Record "LSC Customer Order Header" temporary; var CustOrderLineTemp: Record "LSC Customer Order Line" temporary; var CustOrderDicLineTemp: Record "LSC CO Discount Line" temporary; var IsHandled: Boolean)
    begin
    end;

    [integrationEvent(false, false)]
    internal procedure OnBeforeCreateOrderOnPOS(PosTransaction: Record "LSC POS Transaction")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeNegQtyChangeError(var REC: Record "LSC POS Transaction"; var LineRec: Record "LSC POS Trans. Line"; var CurrInput: Text; var Dec: Decimal; var ErrorText: Text[250]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnProcessCouponBeforeInsertCouponLine(var CouponEntry: Record "LSC Coupon Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterLineSalesTypeChange(var POSTransaction: Record "LSC POS Transaction"; var NewLine: Record "LSC POS Trans. Line"; var LineSalesType: Code[20]; var LinePriceGroup: Code[10]; var CalcPriceNeeded: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    internal procedure OnBeforeSeekAuthorisation(var REC: Record "LSC POS Transaction"; var CardEntryNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    internal procedure ValidateCard_OnBeforeCheckOverTender(var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure TenderKeyPressedEx_OnAfterCalculatePaymentAmount(TenderType: Record "LSC Tender Type"; PaymentAmount: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeRunProcessExternalCommand(POSMenuLine: Record "LSC POS Menu Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeExchangePressed(ExchangeParameter: Text; var REC: Record "LSC POS Transaction"; var ExchangeTransaction: Record "LSC Transaction Header"; var POSRefundMgt: Codeunit "LSC POS Refund Mgt."; var stateTxt: Code[30]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterInfoSubCodeSetFilter(Info: Record "LSC Infocode"; var SubInfo: record "LSC Information Subcode")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeConfirmCOFullPayment(DataLinesBuffer: Record "LSC Customer Order Line" temporary; CustomerOrderLine_Temp: Record "LSC Customer Order Line" temporary; var PrepayCustomerOrder: Boolean; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterNewLineInsertTextLinkPressed(var POSTransLine: Record "LSC POS Trans. Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforePostAndDeleteTransaction(var POSTransaction: Record "LSC POS Transaction"; var POSTransPostingStateTemp: Record "LSC POS Trans. Posting State" temporary; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterCheckCustomerOrderInEditMemberContact(var POSTransaction: Record "LSC POS Transaction"; var gOldMemberCardNo: Text; var IsHandled: Boolean)
    begin
    end;

    // [IntegrationEvent(false, false)]
    // internal procedure OnAfterCheckCustomerOrderInInputMemberContact(var POSTransaction: Record "LSC POS Transaction"; var CardNo: Text; var IsHandled: Boolean)
    // begin
    // end;

    // [IntegrationEvent(false, false)]
    // internal procedure OnAfterDiscResetPressed(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line")
    // begin
    // end;
}