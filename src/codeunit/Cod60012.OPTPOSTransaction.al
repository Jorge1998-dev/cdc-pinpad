codeunit 60012 "OPT POS Transaction"
{
    // SingleInstance = true;
    TableNo = "LSC POS Menu Line";

    var
        POSTRANS: Codeunit "OPT POS Transaction Impl";
        // POSTransDiscounts: Codeunit "LSC POS Trans. Discounts";
        POSTransactionFunctions: Codeunit "OPT POS Transaction Functions";
    //POSTransPrint: Codeunit "LSC POS Transaction Print";

    trigger OnRun()
    begin
        POSTRANS.Run(Rec);
    end;

    procedure ValidateRecordIDInput(pRecordID: RecordID; pConfirmSelection: Boolean): Boolean
    begin
        exit(POSTRANS.ValidateRecordIDInput(pRecordID, pConfirmSelection));
    end;

    procedure RunCommand(var MenuLine: Record "LSC POS Menu Line"): Boolean
    begin
        exit(POSTRANS.RunCommand(MenuLine));
    end;

    procedure SetFunctionMode(FunctionCode: Code[20])
    begin
        POSTRANS.SetFunctionMode(FunctionCode);
    end;

    procedure InsertPaymentLine()
    begin
        POSTRANS.InsertPaymentLine();
    end;

    procedure TransactionTendered()
    begin
        POSTRANS.TransactionTendered();
    end;

    procedure TenderKeyPressed(TenderTypeCode: Code[10])
    begin
        POSTRANS.TenderKeyPressed(TenderTypeCode);
    end;

    procedure TenderKeyPressedEx(TenderTypeCode: Code[10]; TenderAmountText: Text)
    begin
        POSTRANS.TenderKeyPressedEx(TenderTypeCode, TenderAmountText);
    end;

    procedure AskForCard()
    begin
        POSTRANS.AskForCard();
    end;

    procedure InsertCardPaymentLine(pCardEntryNo: Integer)
    begin
        POSTRANS.InsertCardPaymentLine(pCardEntryNo);
    end;

    procedure SetCustomer(pCustomerNo: Code[20])
    begin
        POSTRANS.SetCustomer(pCustomerNo);
    end;

    procedure DiscAmPressedEx(DecPr: Decimal)
    begin
        POSTRANS.DiscAmPressedEx(DecPr);
    end;

    procedure ChangePricePressed(Value: Text[30])
    begin
        POSTRANS.ChangePricePressed(Value);
    end;

    procedure CalcTotals()
    begin
        POSTRANS.CalcTotals();
    end;

    procedure TotalPressed(pSkipTenderDiscAtTotal: Boolean): Boolean
    begin
        exit(POSTRANS.TotalPressed(pSkipTenderDiscAtTotal));
    end;

    procedure PostPressed()
    begin
        POSTRANS.PostPressed();
    end;

    procedure SalePressed(Keyed: Boolean)
    begin
        POSTRANS.SalePressed(Keyed);
    end;

    procedure SalePressed(Keyed: Boolean; FromInit: Boolean)
    begin
        POSTRANS.SalePressed(Keyed, FromInit);
    end;

    procedure RefundPressed(Keyed: Boolean)
    begin
        POSTRANS.RefundPressed(Keyed);
    end;

    procedure PostTransaction(PrintTransaction: Boolean)
    begin
        POSTRANS.PostTransaction(PrintTransaction);
    end;

    procedure GetLastCardEntryReceiptNo(): Code[20]
    begin
        exit(POSTRANS.GetLastCardEntryReceiptNo());
    end;

    procedure PrintZReport(DoChecks: Boolean; AskUser: Boolean)
    begin
        POSTRANS.PrintZReport(DoChecks, AskUser);
    end;

    procedure VoidLinePressed()
    begin
        POSTRANS.VoidLinePressed();
    end;

    procedure LogoffPressed(closePos: Boolean)
    begin
        POSTRANS.LogoffPressed(closePos);
    end;

    procedure CancelPressed(Hard: Boolean; Requested: Integer)
    begin
        POSTRANS.CancelPressed(Hard, Requested);
    end;

    procedure IncExpPressed(AccNo: Code[20])
    begin
        POSTRANS.IncExpPressed(AccNo);
    end;

    procedure FormatAmount(Amount: Decimal): Text[30]
    begin
        exit(POSTRANS.FormatAmount(Amount));
    end;

    procedure StartNewTransaction()
    begin
        POSTRANS.StartNewTransaction();
    end;

    procedure SetTransactionIsCancelCO()
    begin
        POSTRANS.SetTransactionIsCancelCO();
    end;

    procedure ClearGlobs()
    begin
        POSTRANS.ClearGlobs();
    end;

    procedure InsertLogonLogoffTrans(LogAction: Option Logoff,Logon)
    begin
        POSTRANS.InsertLogonLogoffTrans(LogAction);
    end;

    procedure TestNewTransaction(): Boolean
    begin
        exit(POSTRANS.TestNewTransaction());
    end;

    procedure VoidPostedTransaction(): Boolean
    begin
        exit(POSTRANS.VoidPostedTransaction());
    end;

    procedure TSCheckError(): Boolean
    begin
        exit(POSTRANS.TSCheckError());
    end;

    procedure ProcessReceiptBarcode() Success: Boolean
    begin
        exit(POSTRANS.ProcessReceiptBarcode());
    end;

    procedure OpenNumericKeyboard(Caption: Text; DefaultValue: Text; TriggerNo: Integer)
    begin
        POSTRANS.Gui.OpenNumericKeyboard(Caption, DefaultValue, TriggerNo);
    end;

    [Obsolete('This function has been obsoleted as param KeybType was not used within function, use function with same name and 3 parameters instead', '24.0')]
    procedure OpenNumericKeyboard(Caption: Text; KeybType: Integer; DefaultValue: Text; TriggerNo: Integer)
    begin
        POSTRANS.Gui.OpenNumericKeyboard(Caption, DefaultValue, TriggerNo);
    end;

    procedure OpenNumericKeyboard(Caption: Text; KeybType: Integer; DefaultValue: Text; Payload: Text)
    begin
        POSTRANS.Gui.OpenNumericKeyboard(Caption, DefaultValue, Payload);
    end;

    procedure MarkPressed()
    begin
        POSTRANS.MarkPressed();
    end;

    procedure CommitPaymentLineEx()
    begin
        POSTRANS.CommitPaymentLineEx();
    end;

    procedure SetPOSState(pSTATE: Code[10])
    begin
        POSTRANS.SetPOSState(pSTATE);
    end;

    procedure ScreenDisplay(pText: Text[250])
    begin
        POSTRANS.ScreenDisplay(pText);
    end;

    procedure GetLastTransNo(): Integer
    begin
        exit(POSTRANS.GetLastTransNo());
    end;

    procedure PosConfirm(Txt: Text; YesDefault: Boolean): Boolean
    begin
        exit(POSTRANS.Gui.PosConfirm(Txt, YesDefault));
    end;

    procedure PosErrorBanner(ErrorTxt: Text)
    begin
        POSTRANS.Gui.PosErrorBanner(ErrorTxt);
    end;

    procedure PosErrorBanner(ErrorTxt: Text; TimeoutSeconds: Integer)
    begin
        POSTRANS.Gui.PosErrorBanner(ErrorTxt, TimeoutSeconds);
    end;

    procedure PosMessageBanner(MessageTxt: Text)
    begin
        POSTRANS.Gui.PosMessageBanner(MessageTxt);
    end;

    procedure PosMessage(Txt: Text): Boolean
    begin
        exit(POSTRANS.Gui.PosMessage(Txt));
    end;

    procedure ErrorBeep(Txt: Text)
    begin
        POSTRANS.Gui.ErrorBeep(Txt);
    end;

    procedure MessageBeep(Txt: Text)
    begin
        POSTRANS.Gui.MessageBeep(Txt);
    end;

    procedure SelectDefaultMenu()
    begin
        POSTRANS.SelectDefaultMenu();
    end;

    procedure LookUpEx(ExecuteCommand: Boolean; FormID: Code[20]; "Filter": Code[29]; var LookupRecRef: RecordRef): Code[30]
    begin
        exit(POSTRANS.LookUpEx(ExecuteCommand, FormID, "Filter", LookupRecRef));
    end;

    procedure IsNewTransaction(): Boolean
    begin
        exit(POSTRANS.IsNewTransaction());
    end;

    procedure SaleIsReturnSale(): Boolean
    begin
        exit(POSTRANS.SaleIsReturnSale());
    end;

    procedure GetStoreNo(): Code[10]
    begin
        exit(POSTRANS.GetStoreNo());
    end;

    procedure GetPOSTerminalNo(): Code[10]
    begin
        exit(POSTRANS.GetPOSTerminalNo());
    end;

    procedure GetReceiptNo(): Code[20]
    begin
        exit(POSTRANS.GetReceiptNo());
    end;

    procedure GetOutstandingBalance(): Decimal
    begin
        exit(POSTRANS.GetOutstandingBalance());
    end;

    procedure GetStaffID(): Code[20]
    begin
        exit(POSTRANS.GetStaffID());
    end;

    procedure GetPosInfoText1(): Text
    begin
        exit(POSTRANS.GetPosInfoText1());
    end;

    procedure AvailabilityModeOn(): Boolean
    begin
        exit(POSTRANS.AvailabilityModeOn());
    end;

    procedure SetPosInfoText1(pText: Text)
    begin
        POSTRANS.SetPosInfoText1(pText);
    end;

    procedure GetPosInfoText2(): Text
    begin
        exit(POSTRANS.GetPosInfoText2());
    end;

    procedure SetPosInfoText2(pText: Text)
    begin
        POSTRANS.SetPosInfoText2(pText);
    end;

    procedure GetFunctionMode(): Code[20]
    begin
        exit(POSTRANS.GetFunctionMode());
    end;

    procedure SetCurrInput(var pCurrInput: Text)
    begin
        POSTRANS.SetCurrInput(pCurrInput);
    end;

    procedure SetTransNo(var TransNoIn: Integer)
    begin
        POSTRANS.SetTransNo(TransNoIn);
    end;

    procedure GetStateTxt(): Code[30]
    begin
        exit(POSTRANS.GetStateTxt());
    end;

    procedure InputMemberCard(CardNo: Text)
    begin
        POSTRANS.InputMemberCard(CardNo);
    end;

    procedure UpdatedCOWithDeliveryDate(RequestedDeliveryDate: Date)
    begin
        POSTRANS.UpdatedCOWithDeliveryDate(RequestedDeliveryDate);
    end;

    procedure CheckMemberCard(): Boolean
    begin
        exit(POSTRANS.CheckMemberCard());
    end;

    procedure UpdateContext()
    begin
        POSTRANS.UpdateContext();
    end;

    procedure EditMemberContact()
    begin
        POSTRANS.EditMemberContact();
    end;

    procedure GetStoreSetup()
    begin
        POSTRANS.GetStoreSetup();
    end;

    procedure LoadPosTrans(pReceiptNo: Code[20])
    begin
        POSTRANS.LoadPosTrans(pReceiptNo);
    end;

    procedure LoadPosTrans(pReceiptNo: Code[20]; suppressError: Boolean)
    begin
        POSTRANS.LoadPosTrans(pReceiptNo, suppressError);
    end;

    procedure GetGlobalMenuLine(var GlobalMenuLineOut: Record "LSC POS Menu Line")
    begin
        POSTRANS.GetGlobalMenuLine(GlobalMenuLineOut);
    end;

    procedure LoginEx()
    begin
        POSTRANS.LoginEx();
    end;

    procedure ChangeQtyPressedEx()
    begin
        POSTRANS.ChangeQtyPressedEx();
    end;

    procedure ClearInfoAndInfoUtil()
    begin
        POSTRANS.ClearInfoAndInfoUtil();
    end;

    procedure SetPOSTransaction(PosTransIn: Record "LSC POS Transaction")
    begin
        POSTRANS.SetPOSTransaction(PosTransIn);
    end;

    procedure GetPOSTransaction(var PosTransOut: Record "LSC POS Transaction")
    begin
        POSTRANS.GetPOSTransaction(PosTransOut);
    end;

    procedure SetNewLine(NewLineIn: Record "LSC POS Trans. Line")
    begin
        POSTRANS.SetNewLine(NewLineIn);
    end;

    procedure SetAmtAndBalance(AmountInCurrencyIn: Decimal; PaymentAmountIn: Decimal; BalanceIn: Decimal);
    begin
        POSTRANS.SetAmtAndBalance(AmountInCurrencyIn, PaymentAmountIn, BalanceIn);
    end;

    procedure GetAmtAndBalance(var AmountInCurrencyOut: Decimal; var PaymentAmountOut: Decimal; var BalanceOut: Decimal);
    begin
        POSTRANS.GetAmtAndBalance(AmountInCurrencyOut, PaymentAmountOut, BalanceOut);
    end;

    procedure SetInfoTextDescription(InfoTextDescIn: text; InfoTextDesc2In: text)
    begin
        POSTRANS.SetInfoTextDescription(InfoTextDescIn, InfoTextDesc2In);
    end;

    procedure GetInfoTextDescription(var InfoTextDescOut: text; var InfoTextDesc2Out: text)
    begin
        POSTRANS.GetInfoTextDescription(InfoTextDescOut, InfoTextDesc2Out);
    end;

    procedure SetSkipActionsInTotDiscAmPressed(SkipActionsInTotDiscAmPressedIn: Boolean)
    begin
        POSTRANS.SetSkipActionsInTotDiscAmPressed(SkipActionsInTotDiscAmPressedIn);
    end;

    procedure GetSkipActionsInTotDiscAmPressed(var SkipActionsInTotDiscAmPressedOut: Boolean)
    begin
        POSTRANS.GetSkipActionsInTotDiscAmPressed(SkipActionsInTotDiscAmPressedOut);
    end;

    procedure IsPosActionTriggerActive(ActionTriggerNo: Integer): Boolean
    begin
        exit(POSTRANS.IsPosActionTriggerActive(ActionTriggerNo));
    end;

    procedure OverridePLBItem()
    begin
        POSTRANS.OverridePLBItem();
    end;

    procedure UpdateRestrictedFlag()
    begin
        POSTRANS.UpdateRestrictedFlag();
    end;

    procedure GetPLBFlag(PaymentAmount: Decimal): Boolean
    begin
        exit(POSTRANS.GetPLBFlag(PaymentAmount));
    end;

    [Obsolete('Not used anymore. Use function CDCCardPayment(CardEntry) instead', '24.0')]
    procedure CDCCardPayment(): Boolean
    var
        emptyCardEntry: Record "LSC POS Card Entry";
    begin
        exit(CDCCardPayment(emptyCardEntry));
    end;

    procedure CDCCardPayment(var CardEntry: Record "LSC POS Card Entry"): Boolean
    begin
        exit(POSTRANS.CDCCardPayment(CardEntry));
    end;

    procedure GetMerchantoverrideFlag(): Boolean
    begin
        exit(POSTRANS.GetMerchantoverrideFlag());
    end;

    procedure GetChangeTender(): Boolean
    begin
        exit(POSTRANS.GetChangeTender());
    end;

    procedure SetLineRec(NewLineRec: Record "LSC POS Trans. Line")
    begin
        POSTRANS.SetLineRec(NewLineRec);
    end;

    procedure ClearOverridePLBItem()
    begin
        POSTRANS.ClearOverridePLBItem();
    end;

    procedure GetTenderType(): Text[20]
    begin
        exit(POSTRANS.GetTenderType());
    end;

    procedure SetEBTTenderType(TenderType: Code[10])
    begin
        POSTRANS.SetEBTTenderType(TenderType);
    end;

    procedure SetCOWasCreated(COCreated: Boolean)
    begin
        POSTRANS.SetCOWasCreated(COCreated);
    end;

    procedure SetVendorSourcing(VendorSourcing_p: Boolean)
    begin
        POSTRANS.SetVendorSourcing(VendorSourcing_p);
    end;

    procedure CustomerOrderPostShipOrder(DocId: Code[20]; var CustomerOrderLines_Temp: Record "LSC Customer Order Line" temporary)
    begin
        POSTRANS.CustomerOrderPostShipOrder(DocId, CustomerOrderLines_Temp);
    end;

    procedure InsertTmpTransaction(NewLogin: Boolean)
    begin
        POSTRANS.InsertTmpTransaction(NewLogin);
    end;

    procedure CheckForCODepositRemainingAmount(): Decimal
    begin
        exit(POSTRANS.CheckForCODepositRemainingAmount());
    end;

    procedure ChangeSalesType(SalesTypeIn: Code[20]; Command: Code[20])
    begin
        POSTRANS.ChangeSalesType(SalesTypeIn, Command);
    end;

    procedure ChangeBackAmount(): Decimal
    begin
        exit(POSTRANS.ChangeBackAmount());
    end;

    procedure GetPosState(): Code[10]
    begin
        exit(POSTRANS.GetPosState());
    end;

    procedure ClearPOSTransaction()
    begin
        POSTRANS.ClearPOSTransaction();
    end;

    procedure ValidatePriceCheckPhase2(var Price: Decimal)
    begin
        POSTRANS.ValidatePriceCheckPhase2(Price);
    end;

    procedure InfoKeyPressed(var MenuLine: Record "LSC POS Menu Line")
    begin
        POSTRANS.InfoKeyPressed(MenuLine);
    end;

    procedure IsInfocodeAllowMSR(): Boolean
    begin
        exit(POSTRANS.IsInfocodeAllowMSR());
    end;

    procedure NegAdjPressed()
    begin
        POSTRANS.NegAdjPressed();
    end;

    procedure PaymentIntoAccountPressed(Tender: Code[10])
    begin
        POSTRANS.PaymentIntoAccountPressed(Tender);
    end;

    procedure ProcessCustomer(pChangeState: Boolean)
    begin
        POSTRANS.ProcessCustomer(pChangeState);
    end;

    procedure SuspendPressed(SaleType: Code[20])
    begin
        POSTRANS.SuspendPressed(SaleType);
    end;

    // procedure PrintLastSlipCopy()
    // begin
    //     POSTransPrint.PrintSlipCopy(true);
    // end;

    // procedure FlushData(pSkipUpdate: Boolean)
    // begin
    //     POSTransDiscounts.FlushData(pSkipUpdate);
    // end;

    procedure ItemNoPressed()
    begin
        POSTRANS.ItemNoPressed();
    end;

    procedure InitNewLine()
    begin
        POSTRANS.InitNewLine();
    end;

    procedure ProcessSalesPerson()
    begin
        POSTRANS.ProcessSalesPerson();
    end;

    procedure VoidSuspendedTrans(pReceiptNo: Code[20])
    begin
        POSTRANS.VoidSuspendedTrans(pReceiptNo);
    end;

    procedure CheckInfoCode(Module: Code[10]): Boolean
    begin
        exit(POSTRANS.CheckInfoCode(Module));
    end;

    procedure ProcessExternalCommand(POSMenuLineIn: Record "LSC POS Menu Line")
    begin
        POSTRANS.ProcessExternalCommand(POSMenuLineIn);
    end;

    procedure ConfirmOrderPressed(StartFromBeginning: Boolean)
    begin
        POSTRANS.ConfirmOrderPressed(StartFromBeginning);
    end;

    procedure UseTransaction(NewTrans: Code[20]; UpdDisp: Boolean)
    begin
        POSTRANS.UseTransaction(NewTrans, UpdDisp);
    end;

    procedure GetSelectLineNoBeforePLUKEYPressed(): Integer
    begin
        exit(POSTRANS.GetSelectLineNoBeforePLUKEYPressed());
    end;

    procedure PickUpWarning(TransactionHeader: Record "LSC Transaction Header")
    begin
        POSTRANS.PickUpWarning(TransactionHeader);
    end;

    procedure ClearPluCheckPriceAndVariant()
    begin
        POSTRANS.ClearPluCheckPriceAndVariant();
    end;

    procedure TSSendUnsentTransactions()
    begin
        POSTRANS.TSSendUnsentTransactions();
    end;

    procedure ClearInput()
    begin
        POSTRANS.ClearInput();
    end;

    procedure DiscPrPressedEx(Dec: Decimal)
    begin
        POSTRANS.DiscPrPressedEx(Dec);
    end;

    procedure InsertCouponLine(CouponBarcode: Code[22]; CouponHeader: Record "LSC Coupon Header"; IssueOrUse: Integer; AutomaticallyCreated: Boolean; DiscountType: Integer; DiscountValue: Decimal)
    begin
        POSTRANS.InsertCouponLine(CouponBarcode, CouponHeader, IssueOrUse, AutomaticallyCreated, DiscountType, DiscountValue)
    end;

    // procedure PrintSlipCopy()
    // begin
    //     POSTransPrint.PrintSlipCopy(false);
    // end;

    Procedure VoidPressed()
    begin
        POSTRANS.VoidPressed();
    end;

    procedure UpdateLineInfo()
    begin
        POSTRANS.UpdateLineInfo();
    end;

    procedure CommitPaymentLine(var pCardEntry: Record "LSC POS Card Entry")
    begin
        POSTRANS.CommitPaymentLine(pCardEntry);
    end;

    procedure IsCustomerOrderPrepaid(): Boolean
    begin
        exit(POSTRANS.IsCustomerOrderPrepaid());
    end;

    procedure ProcessAddBenefitsEx(var TransBenefitCollectBuffer: Record "LSC Trans. Disc. Benefit Entry" temporary)
    begin
        POSTRANS.ProcessAddBenefitsEx(TransBenefitCollectBuffer);
    end;

    procedure TenderOp(Type: Integer): Boolean
    begin
        exit(POSTRANS.TenderOp(Type));
    end;

    procedure ProcessInfoCode(SubCode: Code[20]; CodeIsSet: Boolean; Requested: Option AutoOnly,All,RequestOnly; InfocodeOnHeader: Boolean)
    begin
        POSTRANS.ProcessInfoCode(SubCode, CodeIsSet, Requested, InfocodeOnHeader);
    end;

    procedure SetLastItemNo(pItemNo: Code[20])
    begin
        POSTRANS.SetLastItemNo(pItemNo);
    end;

    procedure SetInfoFunction(NewInfoFunction: Code[10])
    begin
        POSTRANS.SetInfoFunction(NewInfoFunction);
    end;

    procedure SetStartFunction(NewStartFunction: code[20])
    begin
        POSTRANS.SetStartFunction(NewStartFunction);
    end;

    procedure AskForDataEntryNo()
    begin
        POSTRANS.AskForDataEntryNo();
    end;

    procedure ProcessAddBenefits(lFunctionMode: Enum "LSC POS Command")
    begin
        POSTRANS.ProcessAddBenefits(lFunctionMode);
    end;

    procedure GetNewLine(var NewLineOut: Record "LSC POS Trans. Line")
    begin
        POSTRANS.GetNewLine(NewLineOut);
    end;

    procedure RefundLookUp(RefundLookUp: Record "LSC Transaction Header"; pNewReceiptNo: Code[20])
    begin
        POSTRANS.RefundLookUp(RefundLookUp, pNewReceiptNo);
    end;

    procedure UOMPopUp(POSTransLine: Record "LSC POS Trans. Line"): Code[10]
    begin
        exit(POSTRANS.UOMPopUp(POSTransLine));
    end;

    procedure ChangeUnitOfMeasurePressedEx(UOMCode: Code[10])
    begin
        POSTRANS.ChangeUnitOfMeasurePressedEx(UOMCode);
    end;

    procedure DisplayTotals()
    begin
        POSTRANS.DisplayTotals();
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeTrainingPressed()
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterTrainingPressed()
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterTDPressedPOSTEDState(var TransactionHeader: Record "LSC Transaction Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeInsertPaymentLine(var Rec: Record "LSC POS Transaction"; var PaymentAmount: Decimal; CouponBarcode: Code[22])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeValidateQuantity(var NewQuantity: Decimal; var Line: Record "LSC POS Trans. Line"; var Proceed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure UpdateCOStatusWhenVoidingCollect(CustomerOrderID: Code[20]; TerminalNo: Code[10]; CoLinesToBeVoided: List of [integer]; LineRec: Record "LSC POS Trans. Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnItemNoPressed(REC: Record "LSC POS Transaction"; CurrInput: Text; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnProcessRefundSelection(OriginalTransaction: Record "LSC Transaction Header"; var POSTransaction: Record "LSC POS Transaction"; isPostVoid: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeProcessKeyBoardResult(Payload: Text; InputValue: Text; ResultOK: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeInfocodeRequestOnLine(InfoUtil: Codeunit "LSC POS Infocode Utility"; Requested: Option AutoOnly,All,RequestOnly; var PosTransLine: Record "LSC POS Trans. Line"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterKeyboardTriggerToProcess(InputValue: Text; KeyboardTriggerToProcess: Integer; var Rec: Record "LSC POS Transaction"; var IsHandled: Boolean; ResultOk: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforePostTransaction(var Rec: Record "LSC POS Transaction"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeCheckVATSetups(POSTransaction: Record "LSC POS Transaction"; Item: Record Item; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnProcessBlankInfoDisplayOption(Info: Record "LSC Infocode"; POSTerminal: Record "LSC POS Terminal"; CurrInput: Text; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnTenderKeyPressedExStoreMismatch(ErrorMessage: Text; CurrentStore: Code[10]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnInitStoreMismatch(ErrorMessage: Text; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeInsertPayment_TenderKeyPressedEx(var POSTransaction: Record "LSC POS Transaction"; var CustomerOrderHeader_Temp: Record "LSC Customer Order Header" temporary;
                                                        var CustomerOrderLine_Temp: Record "LSC Customer Order Line" temporary; var CustomerOrderDiscountLine_Temp: Record "LSC CO Discount Line" temporary;
                                                        var PrepayCustomerOrder: Boolean; var COWasCreated: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeRefundLookup(var RefundTransaction: Record "LSC Transaction Header"; TransactionHeader: Record "LSC Transaction Header"; var IsHandled: Boolean; var LookupID: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeInsertTransDiscPercent(var LineRec: Record "LSC POS Trans. Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeSetState(var Rec: Record "LSC POS Transaction")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterAdjustAmount(var LineRec: Record "LSC POS Trans. Line"; var AmDec: Decimal; var PayAmount: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeAdjustAmountToShowOnTenderKey(var REC: Record "LSC POS Transaction"; TenderTypeCode: Code[10]; var PaymentAmount: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeOpenNumericKeyboardOnTenderKey(var REC: Record "LSC POS Transaction"; TenderTypeCode: Code[10]; var PaymentAmount: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeValidateDiscIncomeExpence(var LineRec: Record "LSC POS Trans. Line"; POSMenuLine: Record "LSC POS Menu Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeProcessAddBenefitsEx(var TransBenefitCollectBuffer: Record "LSC Trans. Disc. Benefit Entry" temporary; var CurrFuncMode_g: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterProcessAddBenefitsEx(var TransBenefitCollectBuffer: Record "LSC Trans. Disc. Benefit Entry" temporary; var POSTransLine: Record "LSC POS Trans. Line"; var CurrFuncMode_g: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnDifferentDiscGroup(var PosTransaction: Record "LSC POS Transaction")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterClearGlobs()
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterRetrieveSusp(Var PosTransaction: Record "LSC POS Transaction")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeFindPOSTrLineCHSALESTYPELINES()
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeFindPOSTrLineCHSALESTYPETRANS()
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeAddOffers()
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeInputValidateCusInvNoInp_InvPmtAmt(var ValidateCusInvNoInp_InvPmtAmt: Text; var IsHandled: Boolean; var ReturnValue: Boolean; var CurrInput: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeLookup(var FormID: Code[20])
    begin
    end;

    [IntegrationEvent(true, false)]
    internal procedure OnAfterItemLine2(var LineRec: Record "LSC POS Trans. Line"; var NewLine: Record "LSC POS Trans. Line")
    begin
    end;

    [IntegrationEvent(true, false)]
    internal procedure OnDiscAmtPressed(var LineRec: Record "LSC POS Trans. Line"; var IsHandled: Boolean; DecPr: Decimal; var PayAmount: Boolean; var CurrInput: Text)
    begin
    end;

    [IntegrationEvent(true, false)]
    internal procedure OnBeforeDiscPrPressed(var LineRec: Record "LSC POS Trans. Line"; var IsHandled: Boolean; Dec: Decimal)
    begin
    end;

    [IntegrationEvent(true, false)]
    internal procedure OnAfterDiscPrPressed(var LineRec: Record "LSC POS Trans. Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    internal procedure OnAfterInitNewLine(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    begin
    end;

    [IntegrationEvent(true, false)]
    internal procedure OnBeforeProcessScannerInput(var pScanInput: Text; StoreSetup: Record "LSC Store")
    begin
    end;

    [IntegrationEvent(true, false)]
    internal procedure OnBeforeValidateChangeQty(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var Proceed: Boolean; var ErrorText: Text[250])
    begin
    end;

    [IntegrationEvent(true, false)]
    internal procedure OnBeforeItemNoPressedInProcessBarCode(BarcodeMask: Record "LSC Barcode Mask"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    internal procedure OnBeforeValidateInputEx(BarcodeMask: Record "LSC Barcode Mask"; FunctionSetup: Record "LSC POS Command"; OkNewInput: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    internal procedure OnBeforeCouponPressed(POSTransaction: Record "LSC POS Transaction"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    internal procedure OnBeforeCreatingItemLineProcessAddBenefitsEx(POSTransaction: Record "LSC POS Transaction"; var TransBenefitCollectBuffer: Record "LSC Trans. Disc. Benefit Entry"; CurrValCode: Code[10]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    internal procedure OnBeforeApplyCouponsToTransactionOnTotalPressed(POSTransaction: Record "LSC POS Transaction"; CollectingOrder: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    internal procedure OnBeforePeriodicDiscAndAdditionalBenefitCalcOnTotalPressed(POSTransaction: Record "LSC POS Transaction"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    internal procedure OnBeforeAssigningSalesStaff(POSTransaction: Record "LSC POS Transaction"; PosFuncProfile: Record "LSC POS Func. Profile"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    internal procedure OnBeforeCheckIfZReportPrinted(var StoreSetup: Record "LSC Store"; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeVoucherOpenNumericKeyboard(var REC: Record "LSC POS Transaction"; TenderTypeCode: Code[10]; var PaymentAmount: Decimal; var IsHandled: Boolean)
    begin
    end;

    procedure PostInvoicePressed()
    begin
        POSTRANS.PostInvoicePressed();
    end;

    procedure ValidateCustomer()
    begin
        POSTRANS.ValidateCustomer();
    end;

    procedure AskForCustomer()
    begin
        POSTRANS.AskForCustomer();
    end;

    [Obsolete('Pending removal. Replaced by ProcessCoupon. Fixing spelling typo.', '22.3')]
    procedure PrecessCoupon(var ErrorMsg: Text[250]; ScannedCouponCode: Code[22]; pLineRec: Record "LSC POS Trans. Line"): Boolean
    begin
        exit(POSTRANS.ProcessCoupon(ErrorMsg, ScannedCouponCode, pLineRec));
    end;

    procedure ProcessCoupon(var ErrorMsg: Text[250]; ScannedCouponCode: Code[22]; pLineRec: Record "LSC POS Trans. Line"): Boolean
    begin
        exit(POSTRANS.ProcessCoupon(ErrorMsg, ScannedCouponCode, pLineRec));
    end;

    procedure CouponResetReservation(POSTransLine: Record "LSC POS Trans. Line")
    begin
        POSTRANS.CouponResetReservation(POSTransLine);
    end;

    procedure MultiplyMinusPressed()
    begin
        POSTRANS.MultiplyMinusPressed();
    end;

    procedure TextPressed(Text: Text)
    begin
        POSTRANS.TextPressed(Text);
    end;

    procedure PluKeyPressed(PluNo: Text)
    begin
        POSTRANS.PluKeyPressed(PluNo);
    end;

    procedure CopyTransaction(var Transaction: Record "LSC Transaction Header")
    begin
        POSTRANS.CopyTransaction(Transaction);
    end;

    procedure TotDiscAmPressed(Value: Text[30]; TotAmount: Boolean; InfocodeCheck: Boolean)
    begin
        POSTRANS.TotDiscAmPressed(Value, TotAmount, InfocodeCheck);
    end;

    procedure TotDiscPrPressed(Value: Text[30]; InfocodeCheck: Boolean)
    begin
        POSTRANS.TotDiscPrPressed(Value, InfocodeCheck);
    end;

    procedure WriteMgrStatus()
    begin
        POSTRANS.WriteMgrStatus();
    end;

    procedure OpenDrawerEx(RoleID: Code[10]; SuppressAlerts: Boolean)
    begin
        POSTRANS.OpenDrawerEx(RoleID, SuppressAlerts);
    end;

    procedure SelectCustPressed(pCustomerNo: Code[20])
    begin
        POSTRANS.SelectCustPressed(pCustomerNo);
    end;

    procedure ValidateDisc(): Boolean
    begin
        exit(POSTRANS.ValidateDisc());
    end;

    procedure TextLinkedPressed(Text: Text[100])
    begin
        POSTRANS.TextLinkedPressed(Text);
    end;

    procedure ProcessKDSCheckInputOnPosting(ReceiptNo: Code[20])
    begin
        POSTransactionFunctions.ProcessKDSCheckInputOnPosting(ReceiptNo);
    end;

    procedure RetSuspendedPressedEx(ReceiptNo: Text)
    begin
        POSTRANS.RetSuspendedPressedEx(ReceiptNo);
    end;

    procedure InsertItemLine()
    begin
        POSTRANS.InsertItemLine();
    end;

    procedure CouponPressed()
    begin
        POSTRANS.CouponPressed();
    end;

    procedure NextItemPhase()
    begin
        POSTRANS.NextItemPhase();
    end;

    procedure ZReportSuspendProcess(var NoSuspPOSTransactionsVoided: Integer): Boolean
    begin
        POSTRANS.ZReportSuspendProcess(NoSuspPOSTransactionsVoided);
    end;

    procedure RetSuspendedPressed(pReceiptNo: Text)
    begin
        POSTRANS.RetSuspendedPressed(pReceiptNo);
    end;

    procedure SetErrorCheck()
    begin
        POSTRANS.SetErrorCheck();
    end;

    procedure SetStaffID(pStaffID: Code[20])
    begin
        POSTRANS.SetStaffID(pStaffID);
    end;

    procedure PrintCardSlips(cardSlipNo: Text)
    begin
        POSTRANS.PrintCardSlips(cardSlipNo);
    end;

    procedure SetInfoPhase(NewInfoPhase: Integer)
    begin
        POSTRANS.SetInfoPhase(NewInfoPhase);
    end;

    procedure NextInfoPhase()
    begin
        POSTRANS.NextInfoPhase();
    end;

    procedure ValidateInfo(): Boolean
    begin
        exit(POSTRANS.ValidateInfo());
    end;

}