codeunit 60005 "OPT POS Transaction Impl"
{
    // Access = internal;
    //SingleInstance = true;
    TableNo = "LSC POS Menu Line";

    trigger OnRun()
    begin
        //CommandRetVal := RunCommand(Rec);
    end;

    var
        REC: Record "LSC POS Transaction";
        Item: Record Item;
        PosVariant: Record "Item Variant";
        TenderType: Record "LSC Tender Type";
        TenderTypeTable: Record "LSC Tender Type Setup";
        TenderCardType: Record "LSC Tender Type Card Setup";
        Customer: Record Customer;
        Currency: Record Currency;
        PosSetup: Record "LSC POS Hardware Profile";
        PosFuncProfile: Record "LSC POS Func. Profile";
        FunctionSetup: Record "LSC POS Command";
        DrawerDevice: Record "LSC POS Drawer";
        DisplayDevice: Record "LSC POS Display";
        Info: Record "LSC Infocode";
        StoreSetup: Record "LSC Store";
        PosTerminal: Record "LSC POS Terminal";
        CardEntry: Record "LSC POS Card Entry";
        IncExpAccount: Record "LSC Income/Expense Account";
        CompanyInfo: Record "Company Information";
        LineRec, NewLine : Record "LSC POS Trans. Line";
        LinkedItems: Record "LSC Linked Item";
        BarcodeMask: Record "LSC Barcode Mask";
        Barcode: Record "LSC Barcodes";
        PosGuiProfile: Record "LSC POS Interface Profile";
        DealPOSTransLine: Record "LSC POS Trans. Line";
        ItemTrackingCode: Record "Item Tracking Code";
        POSAction: Record "LSC POS Actions";
        GlobalMenuLine, GlobalMenuLineTag : Record "LSC POS Menu Line";
        SalesTypeRec: Record "LSC Sales Type";
        RefundTransaction: Record "LSC Transaction Header";
        PaymentIntoAccountMenuLine, CreateNewCustomerMenuLine, MenuLine2 : Record "LSC POS Menu Line";
        Deal: Record "LSC Offer";
        DefaultMenuType: Record "LSC Default Rest Menu Type";
        RetailSetup: Record "LSC Retail Setup";
        LinkedItemsNewLineTemp, tmpRepayPOSTransLines : Record "LSC POS Trans. Line" temporary;
        tmpRepayPOSTrans: Record "LSC POS Transaction" temporary;
        HospOrderTransStatus: Record "LSC Hosp. Order Trans. Status";
        //Member_: Codeunit "LSC POS Transaction Member";
        // EFT_: Codeunit "OPT POS Transaction EFT";
        EFT_: Codeunit "OPT POS Transaction EFT";
        Gui_: Codeunit "OPTs POS Transaction GUI";
        //POSTransPrint: Codeunit "LSC POS Transaction Print";
        //POSTransScale: Codeunit "LSC POS Transaction Scale";
        tmpDealLines: Record "LSC Offer Line" temporary;
        TmpSelQty: Record "LSC Selected Quantity" temporary;
        tmpPosActions: Record "Integer" temporary;
        CustomerOrderHeader_Temp: Record "LSC Customer Order Header" temporary;
        CustomerOrderLine_Temp, CustomerOrderLineCompare_Temp : Record "LSC Customer Order Line" temporary;
        CustomerOrderDiscountLine_Temp: Record "LSC CO Discount Line" temporary;
        CustomerOrderPayment_Temp: Record "LSC Customer Order Payment" temporary;
        GlobalRecordID: RecordID;
        PosFunc: Codeunit "LSC POS Functions";
        InfoUtil: Codeunit "LSC POS Infocode Utility";
        OposUtil: Codeunit "LSC POS OPOS Utility";
        TSUtil_: Codeunit "LSC POS Trans. Server Utility";
        POSCtrl: Codeunit "LSC POS Control Interface";
        //HospFunc: Codeunit "LSC Hospitality Functions";
        //RetailMessageManagement: Codeunit "LSC Retail Message Management";
        ClientSessionUtility: Codeunit "LSC Client Session Utility";
        POSTransactionEvents: Codeunit "OPT POS Transaction Events";
        POSTransactionEventsPub: Codeunit "LSC POS Transaction";
        POSLINES: Codeunit "LSC POS Trans. Lines";
        POSGUI: Codeunit "LSC POS GUI";
        POSSESSION: Codeunit "LSC POS Session";
        //POSSESSION2: Codeunit "MCB LSC POS Session";
        PosTransactionGui: Codeunit "OPTs POS Transaction GUI";
        //CashMgm: Codeunit "LSC Cash Management";
        PosOfferExt: Codeunit "LSC POS Offer Ext. Utility";
        PopupPOSComm: Codeunit "LSC Pop-up POS Commands";
        PopupFunc: Codeunit "LSC Pop-up Functions";
        RefundMgt: Codeunit "LSC POS Refund Mgt.";
        //SafeMgmtComm: Codeunit "LSC Safe Denom. Panel Commands";
        TypeHelper: Codeunit "Type Helper";
        //ItemFinder: Codeunit "LSC POS Item Finder";
        GS1DatabarBarcodeMgmt: Codeunit "LSC GS1Databar Barcode Mgmt.";
        ProductExt: Codeunit "LSC Product Ext.";
        LocalizationExt: Codeunit "LSC Retail Localization Ext.";
        PLBMgt: Codeunit "LSC PLB Item Mgt.";
        RetailExt: Codeunit "LSC Retail Localization Ext.";
        LimitationMgt: Codeunit "LSC Limitation Management";
        POSTransactionFunctions: Codeunit "OPT POS Transaction Functions";
        BOUtils: Codeunit "LSC BO Utils";
        // CustomerOrderSession: Codeunit "LSC Customer Order Session";
        CurrInput: Text;
        InfoTextDescription, InfoTextDescription2 : Text;
        StateTxt2: Text;
        CardExtraData: Text;
        CurrTableDescr: Text;
        TextFilter: Text;
        CurrentTableDescription: Text[30];
        ValidateCusInvNoInp_InvPmtAmt: Text;
        CustomerOrder_pParameter: Text;
        TotDiscPressedValue: Text;
        LookupCallFunc: Text;
        gOldMemberCardNo: Text;
        TmpText: Text;
        VoidLineLastVoidedLineDescr: Text;
        ScannedDatabar: Text[100];
        EBTTenderType: Text[20];
        Recipients: list of [Text];
        STATE, LAST_STATE : Enum "LSC POS Transaction State";
        LastSlipNo: Code[20];
        CustomerOrCardNo: Code[20];
        StartFunction: Code[20];
        InfoFunction: Code[10];
        StartItemNo: Code[20];
        IncExpAccNo: Code[20];
        CouponTenderType: Code[10];
        ItemOrBarcode: Code[20];
        LastCurrencyCode: Code[10];
        UOMSet: Code[10];
        LastItemNo: Code[20];
        StateTxt: Code[30];
        SerialNo: Code[50];
        GLobalSalesType: Code[20];
        LineSalesType: Code[20];
        LinePriceGroup: Code[10];
        DealNo: Code[20];
        DealVariant: Code[10];
        DealLineDescription: text[100];
        PriceCheckUnitOfMeasure: Code[10];
        OldFuncMode: Code[20];
        CouponCode: Code[22];
        LotNo: Code[50];
        InvoiceNo: Code[20];
        PaymentIntoAccTender: Code[10];
        MealPlanMenuFromButton: Code[10];
        PosDataEntryTypeCode: Code[20];
        CouponCodeNextItem: Code[22];
        pluCurrVariant: Code[10];
        CardType: Code[10];
        LocationPrintItemNo: Code[20];
        LocationPrintVariantNo: Code[10];
        CustomerBalanceCalculated: Code[20];
        CustomerLastSale: Code[20];
        OtherPOS: Code[10];
        CurrentTenderTypeCode: Code[10];
        CurrencyKeyPressed_CurrCode: Code[10];
        OpenDrawerPressedRoleID: Code[10];
        CurrFuncMode_g: Code[20];
        LastProfileID: Code[10];
        LastMenuID: Code[20];
        GTIN_EAN: Code[20];
        PriceGr: Code[10];
        CustomerLastSaleDate: Date;
        StartDate, EndDate : Date;
        TSErrorTime: Time;
        LimitationBalanceAmount, LimitationTotalAmount, LimitationPaidAmount : array[10] of Decimal;
        Remaining, RemainingFCY, CurrQty, PaymentAmount, AmountInCurrency, Balance, RealBalance, MultiplyWith, MultiplyWithTemp, KeyboardPrice, PriceInBarcode, QtyInBarcode, DealAddedPrice,
            TenderOfferNewBalanc, DiscPrAmtPressedDec, ChangePricePressedDec, LastDiscPrice, OverridePrice, WeightInKgsFromScannedDatabar, WeightInLbsFromScannedDatabar, COAmountToDeductFromTot, COTotalAmount,
             CORemainingAmount, AmtChargedOnPOSInt, AmtChargedPostedInt, BalanceLCYInt, TotalExchangeAmountToCO, TotalExchangeAmount, CurrentPaymentAmount, GrossAmountBeforeCreatingCO : Decimal;
        TransNo, ItemPhase, ParentLine, CurrTableNo, CurrGuest, FromLineNo, GlobalHospTypeSeq, CurrMenuType, gTransNo, DealModifierLineNo, DealLineNo, SequenceNo, MobileDealLineNo, MobileGroupLineNo,
            CurrentTableNo, TenderChargeSelect, PaymentCount, CurrMenuTypeDeal, InfoPhase, NumericKeyboardTrigger, ValidateInfocode_Requested, CurrencyKeyPressed_CurrStatus,
            VoidLineNoOfVoidedLines, SelectedLineNoBeforePLUKEYPressed : Integer;
        ItemStockAction: Option RefreshButtons,RefreshPOSButton,RefreshItemNo,EnableAll,ResetAll,SetPopUpInfo;
        AddExtraPaymentToCO: Option NotAsked,DoAdd,DoNotAdd;
        Requested_g: Option AutoOnly,All,RequestOnly;
        _Initialized, COWasCreated, CollectingOrder, PrepayCustomerOrder, CommandRetVal, KeyboardAmount, ChangeTender, Scanned, ReadFromMSR, ScaleDisplayed, VoidInProcess, LastCanceled, TrainingActive,
            LinkedItemsActive, StartingPaymentsIntoAccount, OnlySelectCustomer, SalesTypeFilter, gInsertTmpPayment, ClosePosFlag, ExternalZeroPrice, PreSetSerialLotNo,
            SelectDefaultMenuFlag, PosDataEntryBalanceOnly, gInfoCodeSelectionOk, pluCheckPriceMode, ProcessTenderOffers, WarmupDone, DoXYReportCheck, CompressDealVariants, BillIsPrinted, FromMobileQR,
            TenderDeclOpenOnADiffPOS, AskConfirmation, gCancelOffer, CopyTransSalesLinesWithoutPopUps, ValidateInfocode_InfocodeOnHdr, ValidateInfocode_OneSubcode,
            ValidateInfocode_WaitingForInput_Web, ValidateInfocode_InsertingItem, TotalDiscPressedPercentage, TotDiscAmPressedTotAmount, DiscPressedPercentage, DiscDealPressedPercentage, DiscDealPressedAmount,
            ProcessCustomerChangeState, TenderDeclEndOfDay, ChangeQtyInProgress, ItemStockRestrictionOn, IsDataBarWithLotNoAndExpDate, VendorSourcing, SkipActionsInTotDiscAmPressed,
            BomLineEntry, SPGOrder, NotIncludeWebPreAuth, COTotalHasBeenPressed, VoidLineShowOnDisplay, DoNotUseExchangeLineAsPayToCO, IsLimitation, TransactionIsCancelCO, MemberLinkedCustomerInfoCode, LineUpdateInProgress,
            UsePaymentToken, InfocodeOnHeader_g, OneSubcode_g, LAST_STATE_WAS_NOT_EMPTY, MultipleRecordsForReceipt, COEdit : Boolean;
        NewTransMsg: Label 'New transaction';
        InvalidErr: Label 'Invalid %1!';
        CommandNotAllowedInStateErr: Label 'Command not allowed in this state!';
        MgrKeyRequiredErr: Label 'Manager key is required for this function';
        ItemNotOnFileErr: Label 'Item %1 is not on file!';
        IsBlockedErr: Label '%1 %2 is blocked!';
        NoCorrectedHigherThanSoldErr: Label 'Number corrected higher than sold items';
        InvalidAmtValueErr: Label 'Invalid value in amount';
        LowestAcceptedDenomErr: Label 'Lowest accept. denominator is %1';
        AmtEntryRequiredErr: Label 'Amount entry is required!';
        DiscNotAllowedForItemErr: Label 'Discount is not allowed for this item';
        InvalidValInPercentErr: Label 'Invalid value in percent';
        DiscChangedMsg: Label 'Discount changed';
        DiscHigherThanAmtErr: Label 'Discount is higher than amount';
        InvalidValInQtyErr: Label 'Invalid value in quantity';
        EnterInfocodeMsg: Label 'Enter Infocode';
        StaffIdNotInStoreErr: Label 'The Staff ID does not belong to this store !';
        BalanceDueIsMsg: Label 'Balance due is %1';
        DiscExceedsBalanceErr: Label 'Discount exceeds Balance';
        TotalDiscNotAppliedToAnyItemErr: Label 'Total discount cannot be applied to any item.';
        PrintingMsg: Label 'Printing...';
        ZReportNotInTrainingErr: Label 'Z-Reports are not allowed in Training mode';
        InfocodeRequiredCancelQst: Label 'InfoCode Input is required\Do you want to cancel the line?';
        TransRetrievedMsg: Label 'Transaction retrieved';
        ItemLinesNotAllowedInStateErr: Label 'Item lines are not allowed in this state!';
        CouponsNotAllowedInStateErr: Label 'Coupons are not allowed in this state!';
        SetupCouponsDefinedErr: Label 'Setup error\No %1 for coupons defined';
        SetupCouponsDefinedInErr: Label 'Setup error\No %1 for coupons defined in this %2';
        InvalidOperationErr: Label 'Invalid operation';
        CurrTransMustBeFinishedErr: Label 'Current transaction must be finished!';
        InvalidBarcodeErr: Label 'Invalid Barcode';
        ReceiptNotFoundErr: Label 'Receipt number not found.';
        PrePaymDueMsg: Label 'Prepayment Balance due is %1';
        IsNotErr: Label '%1 %2 is not %3';
        IsNotOnFileErr: Label '%1 %2 is not on file!';
        TransNoConnectionPrintThisTermOnlyQst: Label 'Transaction server could not be contacted. Do you want to print for this terminal only?';
        LoginActionsInvalidInTransErr: Label 'Login actions can''t be done in transactions';
        PriceMsg: Label 'Price';
        QtyMsg: Label 'Quantity';
        AmountMsg: Label 'Amount';
        CartTypeMsg: Label 'Card type';
        CustomerMsg: Label 'Customer';
        QtyOnlyOneWhenSerialNoErr: Label 'Quantity can only be 1 when the item has a serial no.';
        CardNoMsg: Label 'Card No.';
        MemberCardRequiredBeforePaymErr: Label 'Member Card must be entered prior to this payment selection';
        DealInvalidErr: Label 'Deal %1 is invalid.';
        SelectOtherPaymOrCustMsg: Label 'Select other Payment or Customer';
        UnpostedTransContinueQst: Label 'There are %1 unposted sales transactions in the store. Do you still want to continue?';
        CompleteTransOrCancelMsg: Label '. Complete the %1 Transaction\first or press CANCEL';
        ScanItemToTriggerCouponMsg: Label 'Scan item now to trigger coupon';
        CustCannotModifiedWhenRefundErr: Label 'Customer cannot be modified when refunding previous sales';
        TakeOverTransQst: Label 'Do you want to take over this transaction?';
        PaymAmtMsg: Label 'Payment Amt.';
        TransBelongsToCustErr: Label 'The transaction belongs to Customer %1';
        SalesPersonRegisteredErr: Label 'Sales Person %1 registered.';
        LineNotPartOfDealErr: Label 'The line is not a part of a deal.';
        InvalidUOMErr: Label 'Invalid Unit of Measure';
        UOMNotAvailableForItemErr: Label 'UOM %1 is not available for Item %2';
        AddRemoveTenderTypeMissingErr: Label 'Add/Remove Tender Type missing in Store Setup.\Contact Store manager';
        EnterTextMsg: Label 'Enter text';
        TextEntryNotAllowedMsg: Label 'Text entry is not allowed in this state!';
        CannotChangeLineErr: Label 'You cannot change this line.';
        ReportOnlyPrintableFromPosErr: Label 'The report can only be printed from within the POS.';
        NoIsConfiguredInHwProfileMsg: Label 'No %1 is configured in Hardware profile %2.';
        DiningTableOrContactNameRequiredMsg: Label 'You cannot sell items. The sales type in use demands a dining table no. or marking with contact name.';
        FirstTransMsg: Label 'ATTENTION: This is the first Transaction for Terminal %1 in this database.';
        __StateREFUND: Label 'REFUND';
        __StateTRAINING: Label 'TRAINING';
        __TSError: Label 'Trans. or Web Server Connection failed';
        __QTY_TOO_HIGH: Label 'The Quantity Entered is too High.\The Maximum value is %1.';
        __PRICE_TOO_HIGH: Label 'The Price Entered is too High.\The Maximum value is %1.';
        TotalError1: Label 'There are no lines to total';
        __ChangeQtyLinkedErr: Label 'Quantity cannot be changed on linked items';
        NewCustPrices: Label 'New Customer Prices have been triggered.';
        PriceCheckForItem: Label 'Price check for item';
        CANCELED_TXT: Label 'Canceled.';
        FinalizePaymentNotAuthorized: Label 'Finalize payment from card not Authorized';
        RefundGiftCardSale: Label 'Selling Gift Cards or Vouchers is not allowed in a Return Sale';
        EmailNotValid: Label 'E-mail %1 is not valid.  Do you want to try again?';
        EmailForReceipt: Label 'E-mail for receipt';
        "E-Receipt": Label 'E-Receipt ';
        NoLinesWereEligibleForRef: Label 'No lines were eligible for refund from Receipt %1';
        CurrBalanceAndExpiration: Label 'Current Balance is %1.  Expiration Date %2';
        UOMCHNotAllowed: Label 'It is not allowed to change the %1 on %2';
        SetQuantityText: Label 'Set Quantity';
        ChangeOnSentLineError: Label 'You cannot change a line that has been sent to kitchen';
        NotSentToKitchenError: Label 'There are items that need to be sent to kitchen. You cannot split the bill.';
        OnStockRestrictionNo: Label '%1 is set to No in store/restaurant %2';
        ItemExpiredError: Label 'Item is expired!\Please find another item for the Customer.';
        GenericLotNoError: Label 'This Lot No. cannot be sold';
        ItemIsExpiredOrIsAboutToExp: Label 'Item is expired or is about to expire. Does the customer still want to buy it?';
        PressAnyKeyToContinue: Label 'Press any key to continue';
        DoYouStillWantToSell: Label 'Do you still want to sell the item?';
        SplitAllLinesError: Label 'Cannot mark all lines for splitting the bill';
        EndOfDayDeclNotAllowed: Label 'End-of-Day Tender Declaration is not allowed when the POS is in Training Mode and Safe Management is in use';
        NoTransactionToEmail: Label 'No transaction to Email';
        EFTRecoverTrans: Label 'A Failed Card Payment entry has been detected (%1).\Transaction Type: %2\Amount: %3\Error: %4\\Attempt to Recover on EFT Terminal?';
        EFTRecoverTransSuccess: Label 'Last EFT Card Payment was successfully recovered.';
        PayloadNotImplemented: Label 'Keyboard Result NOT IMPLEMENTED!';
        NumpadNotImplemented: Label 'KeyboardTriggerToProcess: %1 [ %2 ] Numpad Result NOT IMPLEMENTED!';
        EnterValue: Label 'Enter %1';
        DepositMoreThanRemaining: Label 'Deposit Amount %1 exceeds the Remaining Amount %2';
        QuantityToReorderText: Label 'Quantity to Reorder';
        RetryCardVoid: Label '%1\Retry Void?';
        ExchangeLbl: Label 'EXCHANGE', Locked = true;
        EBTText: Label 'EBT', Locked = true;
        EBTCashText: Label 'EBTCash', Locked = true;
        pPOSTransaction: Record "LSC POS Transaction";
        pPOSTransLine: Record "LSC POS Trans. Line";
        pVoidCardEntry: Record "LSC POS Card Entry";

    procedure Init(): Boolean
    var
        HospType: Record "LSC Hospitality Type";

        CurrentAvailabilityLock: Record "LSC Current Availability Lock";
        Staff: Record "LSC Staff";
        STAFFPERGroup: Record "LSC STAFF PER Group";
        BOUtils: Codeunit "LSC BO Utils";
        //POSTransactionWarmup: Codeunit "LSC POS Transaction Warmup";
        TmpTxt, ErrorText, CurrOrderSet : Text;
        FilterFrom, FilterTo : Code[20];
        CurrDinResNo: Code[20];
        PresetCoverNo, PresetSeatCap : Integer;
        MemberLoadError, MemberLoadSyncError : Boolean;
        NewSaleRequestedPickupOld, NewSaleRequested : Boolean;
        ExistingSaleRequested: Boolean;
        RecFound: Boolean;
        CheckStaffTakeoverProfile: Boolean;
        IsHandled, ReturnValue : Boolean;
        ShouldVoid: Boolean;
        Text000: Label 'POS Terminal %1 not found in Store %2';
        TblNewEntryMsg: Label 'Table %1 New Entry';
        TblAdditionalEntryMsg: Label 'Table %1 Additional Entry';
        PurgeOldQst: Label 'Do you want to purge old transactions?';
        TenderDeclFloatExistsMsg: Label 'Tender Declaration - Float Entry for Staff %1 exists on POS Terminal %2';
    begin
        ClearGlobs;
        ShouldVoid := POSSESSION.InTestMode() and (not _Initialized);
        _Initialized := true; // STATE_SALES <> ''
        CouponCode := '';
        RemainingFCY := 0;
        LastCurrencyCode := '';
        CouponCodeNextItem := '';
        AskConfirmation := true;

        // POSTransactionEvents.OnBeforeInit(REC);
        POSSESSION.SetValue("LSC POS Tag"::"NUMPAD-TEXT", '');
        POSSESSION.SetValue("LSC POS Tag"::"NUMPAD-VALUE", '');
        POSSESSION.SetValue("LSC POS Tag"::"NUMPAD-TYPE", '');
        // POSSESSION.SetValue("LSC POS Tag"::"Retail_Message", RetailMessageManagement.GetCurrentTagText);
        POSSESSION.SetValue("LSC POS Tag"::"LastSlipNo_", '');
        EFT.Init();
        ClearPluCheckPriceAndVariant;
        PosSetup.Get(POSSESSION.HardwareProfileID);
        GetStoreSetup;

        if not PosFuncProfile.Get(POSSESSION.GetValue("LSC POS Tag"::"LSFUNCPROFILE")) then
            PosFuncProfile.Get(StoreSetup."Functionality Profile");

        CheckIfZReportPrinted();
        PosTerminal.Get(POSSESSION.TerminalNo);
        PosGuiProfile.Get(POSSESSION.InterfaceProfileID);
        if PosTerminal."Store No." <> StoreSetup."No." then begin
            IsHandled := false;
            // POSTransactionEventsPub.OnInitStoreMismatch(StrSubstNo(Text000, PosTerminal."No.", StoreSetup."No."), IsHandled);
            If not IsHandled then
                Error(Text000, PosTerminal."No.", StoreSetup."No.");
        end;

        POSSESSION.SetValue("LSC POS Tag"::"TS_ERROR", '');
        SetGlobalSalesType;
        //HospFunc.SetCurrDiningTblAndDescr(CurrTableNo, CurrTableDescr, CurrDinResNo);
        InitPosActions();
        PosFunc.ReadLocalVar(LastSlipNo);
        PosFunc.InitPosFunctions;
        PosFunc.PosTransDiscLoad('');
        OposUtil.Display(PosTerminal."Customer Display Text 1", PosTerminal."Customer Display Text 2");

        //POSTransactionWarmup.CreateWarmupTransaction(StoreSetup, WarmupDone);

        REC.Reset;
        FilterFrom := PosFunc.ZeroPad(POSSESSION.TerminalNo, 10) +
                      PosFunc.ZeroPad('0', 9);
        FilterTo := PosFunc.ZeroPad(POSSESSION.TerminalNo, 10) +
                      PosFunc.NumberPad('9', 9);

        // POSTransactionEvents.OnBeforeFilterRecOnInit(FilterFrom, FilterTo);
        REC.SetRange("Receipt No.", FilterFrom, FilterTo);
        REC.SetFilter("Entry Status", '<>%1', REC."Entry Status"::Suspended);

        MultiplyWith := 1;
        EFT.InitEFTServer;

        // if PosFunc.IsPurgeOverDue then
        //     if PosTransactionGui.PosConfirm(PurgeOldQst, false) then begin
        //         PosFunc.Purge();
        //         POSTransactionEvents.OnAfterPurgeOldTransactions();
        //     end;

        GlobalHospTypeSeq := 0;
        SalesTypeFilter := false;
        clear(HospType);

        CheckStaffTakeoverProfile := true;
        if GLobalSalesType <> '' then begin
            if BOUtils.IsHospitalityPermitted then begin
                if Evaluate(GlobalHospTypeSeq, POSSESSION.GetValue("LSC POS Tag"::"HOSTYPSEQ")) then;
                if HospType.Get(POSSESSION.StoreNo, GlobalHospTypeSeq, GLobalSalesType) then begin
                    CheckStaffTakeoverProfile := false;
                    if HospType."Sharing Sales Type Filter" <> '' then begin
                        REC.SetFilter("Sales Type", HospType."Sharing Sales Type Filter");
                        SalesTypeFilter := true;
                    end;
                    if HospType."KDS Display/Printing" = HospType."KDS Display/Printing"::"On Item Added" then
                        POSSESSION.SetValue("LSC POS Tag"::"ON-ITEM-ADDED", 'YES')
                    else
                        POSSESSION.SetValue("LSC POS Tag"::"ON-ITEM-ADDED", 'NO');
                end;
            end;
            if not SalesTypeFilter then begin
                if StoreSetup."Store Sales Type Filter" <> '' then begin
                    if not BOUtils.IsCodeInFilter(StoreSetup."Store Sales Type Filter", GLobalSalesType) then
                        StoreSetup."Store Sales Type Filter" := StoreSetup."Store Sales Type Filter" + '|' + GLobalSalesType;
                    REC.SetFilter("Sales Type", StoreSetup."Store Sales Type Filter")
                end else
                    REC.SetRange("Sales Type", GLobalSalesType);
            end;
        end;

        //HospFunc.SetNewOrRequestedOrder(CurrOrderSet, NewSaleRequested, NewSaleRequestedPickupOld, ExistingSaleRequested, CurrTableNo);

        if ExistingSaleRequested or NewSaleRequested then begin
            REC.SetRange("Entry Status");
            REC.SetRange("Sales Type");
            REC.SetRange("Receipt No.", CurrOrderSet);
        end else begin
            if CurrTableNo = 0 then
                if PosFuncProfile."Staff Sales Filter" then
                    REC.SetRange("Staff ID", POSSESSION.StaffID);
        end;

        if (LastSlipNo <> '') and (POSSESSION.GetValue("LSC POS Tag"::"CURRORDER") = '') then
            REC.SetRange("Receipt No.", LastSlipNo);

        RecFound := true;
        if (not REC.FindLast) or (POSSESSION.GetValue("LSC POS Tag"::"SAF-CANCEL-SOD") = 'INIT') then begin
            if NewSaleRequestedPickupOld or NewSaleRequested or ExistingSaleRequested then begin
                RecFound := false;
                if LastSlipNo = '0' then //First Trans in database, Show Notification.
                    PosTransactionGui.PosMessage(StrSubstNo(FirstTransMsg, PosTerminal."No."));
                InsertTmpTransaction(true);
                if TD_DuFloatEntry then begin
                    TD_MakeFloatEntry;
                    if POSSESSION.GetValue("LSC POS Tag"::"SAF-CANCEL-SOD") = 'LOGOFF' then
                        exit(false);
                end;
            end
            else begin
                REC.SetRange("Receipt No.");
                REC.SetRange("Store No.", POSSESSION.StoreNo);
                REC.SetRange("POS Terminal No.", POSSESSION.TerminalNo);
                if POSSESSION.GetValue("LSC POS Tag"::"SAF-CANCEL-SOD") = 'INIT' then
                    REC.SetFilter("Transaction Type", '%1|%2|%3|%4',
                      REC."Transaction Type"::"Remove Tender", REC."Transaction Type"::"Float Entry",
                      REC."Transaction Type"::"Change Tender", REC."Transaction Type"::"Tender Decl.");
                if not REC.FindLast then begin
                    RecFound := false;
                    if LastSlipNo = '0' then //First Trans in database, Show Notification.
                        PosTransactionGui.PosMessage(StrSubstNo(FirstTransMsg, PosTerminal."No."));
                    InsertTmpTransaction(true);
                    if TD_DuFloatEntry then begin
                        TD_MakeFloatEntry;
                        if POSSESSION.GetValue("LSC POS Tag"::"SAF-CANCEL-SOD") = 'LOGOFF' then
                            exit(false);
                    end;
                end
                else
                    AfterGetRecord;
            end;
            REC.SetRange("Store No.");
            REC.SetRange("POS Terminal No.");
        end
        else
            AfterGetRecord;

        if RecFound then begin
            REC.SetRecFilter();
            // POSTransactionEvents.OnAfterRecFound(REC);
            if REC."New Transaction" then begin
                if TD_DuFloatEntry then begin
                    TD_MakeFloatEntry();
                    if POSSESSION.GetValue("LSC POS Tag"::"SAF-CANCEL-SOD") = 'LOGOFF' then
                        exit(false);
                end
                else begin
                    if TenderDeclOpenOnADiffPOS then begin
                        PosTransactionGui.ErrorBeep(StrSubstNo(TenderDeclFloatExistsMsg, POSSESSION.StaffID, OtherPOS));
                        //SetFunctionMode("LSC POS Command"::ERRCHK);
                        exit(false);
                    end;

                    IsHandled := false;
                    // POSTransactionEvents.OnInit_OnAfterTenderDeclOpenOnADiffPOS(IsHandled, ReturnValue);
                    // if IsHandled then
                    //     exit(ReturnValue);

                    InfoTextDescription := NewTransMsg;
                    SetPOSState("LSC POS Transaction State"::SALES);
                    //SetFunctionMode("LSC POS Command"::ITEM);
                end;
            end
            else begin
                StateTxt := Format(REC."Transaction Type");
                case REC."Transaction Type" of
                    REC."Transaction Type"::Sales:
                        begin
                            if REC."sale is Exchange Sale" then
                                StateTxt := ExchangeLbl
                            ELSE
                                if REC."Sale Is Return Sale" then
                                    StateTxt := __StateREFUND;
                            SetPOSState("LSC POS Transaction State"::SALES);

                            IsHandled := false;
                            // POSTransactionEvents.OnBeforeSetFunctionModeInit(PosFuncProfile, REC, IsHandled);
                            // if not IsHandled then
                            //     POSTransactionFunctions.HandleSalesPersonMode(REC, PosFuncProfile, "LSC POS Command"::ITEM);

                            // if (CurrTableNo <> 0) and (REC."No. of Covers" > 0) then
                            //     HospFunc.UpdateOccupiedSeats(CurrTableNo, PosFuncProfile."Print Copy No. on Pre-Receipt", REC."Receipt No.");
                        end;
                    REC."Transaction Type"::Payment:
                        begin
                            SetPOSState("LSC POS Transaction State"::PAYMENT);
                            // SetFunctionMode("LSC POS Command"::PAYMENT);
                        end;
                    REC."Transaction Type"::"Tender Decl.",
                    REC."Transaction Type"::"Float Entry",
                    REC."Transaction Type"::"Remove Tender":
                        begin
                            SetPOSState("LSC POS Transaction State"::TENDOP);
                            //SetFunctionMode("LSC POS Command"::TENDOP);

                            if (REC."Transaction Type" = REC."Transaction Type"::"Float Entry") then begin
                                if TD_DuFloatEntry then begin
                                    TD_MakeFloatEntry();
                                    if POSSESSION.GetValue("LSC POS Tag"::"SAF-CANCEL-SOD") = 'LOGOFF' then
                                        exit(false);
                                end;
                            end;
                        end;
                    REC."Transaction Type"::NegAdj:
                        begin
                            SetPOSState("LSC POS Transaction State"::NEG_ADJ);
                            //SetFunctionMode("LSC POS Command"::ITEM);
                        end;
                    REC."Transaction Type"::PhysInv:
                        begin
                            SetPOSState("LSC POS Transaction State"::PHYS_INV);
                            // SetFunctionMode("LSC POS Command"::ITEM);
                        end;
                    REC."Transaction Type"::"Open Drawer",
                    REC."Transaction Type"::Logon,
                    REC."Transaction Type"::Logoff,
                    REC."Transaction Type"::"Change Tender",
                    REC."Transaction Type"::Voided:
                        begin
                            REC."New Transaction" := true;
                            InfoTextDescription := NewTransMsg;
                            SetPOSState("LSC POS Transaction State"::SALES);
                            // SetFunctionMode("LSC POS Command"::ITEM);
                        end;
                end;
            end;
        end;

        if (REC."Staff ID" <> POSSESSION.StaffID) and (REC."Staff ID" <> '') then begin
            if not CheckStaffTakeoverProfile then begin
                if POSSESSION.StaffHasMgrPriv then begin
                    // if HospType."Manager Takeover in Trans." = HospType."Manager Takeover in Trans."::Always then begin
                    //     REC."Staff ID" := POSSESSION.StaffID;
                    //     PosFunc.ChangeStaff(REC);
                    // end;
                    // if HospType."Manager Takeover in Trans." = HospType."Manager Takeover in Trans."::"With Confirmation" then
                    //     if PosTransactionGui.PosConfirm(TakeOverTransQst, false) then begin
                    //         REC."Staff ID" := POSSESSION.StaffID;
                    //         PosFunc.ChangeStaff(REC);
                    //     end;
                end
                else begin
                    // if HospType."Staff Takeover in Trans." = HospType."Staff Takeover in Trans."::Always then begin
                    //     REC."Staff ID" := POSSESSION.StaffID;
                    //     PosFunc.ChangeStaff(REC);
                    // end;
                    // if HospType."Staff Takeover in Trans." = HospType."Staff Takeover in Trans."::"With Confirmation" then
                    //     if PosTransactionGui.PosConfirm(TakeOverTransQst, false) then begin
                    //         REC."Staff ID" := POSSESSION.StaffID;
                    //         PosFunc.ChangeStaff(REC);
                    //     end;
                end;
            end
            else begin
                if POSSESSION.StaffHasMgrPriv then begin
                    if PosFuncProfile."Manager Takeover in Trans." = PosFuncProfile."Manager Takeover in Trans."::Always then
                        REC."Staff ID" := POSSESSION.StaffID;
                    if PosFuncProfile."Manager Takeover in Trans." = PosFuncProfile."Manager Takeover in Trans."::"With Confirmation" then
                        if PosTransactionGui.PosConfirm(TakeOverTransQst, false) then
                            REC."Staff ID" := POSSESSION.StaffID;
                end
                else begin
                    if PosFuncProfile."Staff Takeover in Trans." = PosFuncProfile."Staff Takeover in Trans."::Always then
                        REC."Staff ID" := POSSESSION.StaffID;
                    if PosFuncProfile."Staff Takeover in Trans." = PosFuncProfile."Staff Takeover in Trans."::"With Confirmation" then
                        if PosTransactionGui.PosConfirm(TakeOverTransQst, false) then
                            REC."Staff ID" := POSSESSION.StaffID;
                end;
            end;
        end;

        if Staff.Get(REC."Staff ID") then
            case Staff."Return in Transaction" of
                Staff."Return in Transaction"::" ":
                    begin
                        if STAFFPERGroup.Get(Staff."Permission Group") then
                            if STAFFPERGroup."Return in Transaction" = STAFFPERGroup."Return in Transaction"::No then begin
                                REC."Sale Is Return Sale" := false;
                                StateTxt := '';
                            end;
                    end;
                Staff."Return in Transaction"::No:
                    begin
                        REC."Sale Is Return Sale" := false;
                        StateTxt := '';
                    end;
            end;

        LinePriceGroup := REC."Price Group Code";
        if SalesTypeFilter then begin
            LineSalesType := GLobalSalesType;
            if SalesTypeRec.Get(GLobalSalesType) then
                LinePriceGroup := SalesTypeRec."Price Group";
        end
        else begin
            if REC."Original Sales Type" <> '' then
                LineSalesType := REC."Original Sales Type"   // price group same as header, trans. is pre-order
            else
                LineSalesType := REC."Sales Type";
        end;

        if CurrTableNo <> 0 then begin
            if REC."New Transaction" then
                InfoTextDescription := StrSubstNo(TblNewEntryMsg, Format(CurrTableDescr))
            else
                InfoTextDescription := StrSubstNo(TblAdditionalEntryMsg, Format(CurrTableDescr));
        end;

        PresetCoverNo := 0;
        if POSSESSION.GetValue("LSC POS Tag"::"PRESET_COVER") <> '' then begin
            if Evaluate(PresetCoverNo, POSSESSION.GetValue("LSC POS Tag"::"PRESET_COVER")) then
                REC."No. of Covers" += PresetCoverNo;
            POSSESSION.DeleteValue("LSC POS Tag"::"PRESET_COVER");
        end;
        if POSSESSION.GetValue("LSC POS Tag"::"SEAT_CAP") <> '' then begin
            if Evaluate(PresetSeatCap, POSSESSION.GetValue("LSC POS Tag"::"SEAT_CAP")) then begin
                REC."Max. Seating Capacity" := PresetSeatCap;
                if REC."No. of Covers" > PresetSeatCap then
                    REC."Max. Seating Capacity" := REC."No. of Covers";
            end;
        end;

        // HospFunc.SetBillPrinted(REC, BillIsPrinted, HospOrderTransStatus);

        if InfoTextDescription = '' then
            InfoTextDescription := REC.Comment;

        // if POSSESSION.GetValue("LSC POS Tag"::"REC_TGL") = '' then
        //     POSTransPrint.SetRecPrintDisabled(PosTerminal."Rec. Printing Off by Default")
        // else
        //     POSTransPrint.TestAndSetRecPrintDisabled(POSSESSION.GetValue("LSC POS Tag"::"REC_TGL"));

        if REC."Entry Status" = REC."Entry Status"::Training then
            TrainingActive := true;
        RefreshTrainingStatus;

        // if PosFunc.UseBackgroundSession then
        //     TSSendUnsentTransactions
        // else
        //     TSCheckError;

        if REC."Entry Status" <> REC."Entry Status"::Training then
            if PosTerminal."Open Drawer at LI/LO" then begin
                OpenDrawer('');
                WaitDrawerClosed('');
            end;

        REC.SetRange("Sales Type");
        REC.SetRange("Staff ID");

        CheckOpenDeals();

        //POSTransactionEvents.OnInit_OnAfterGetPOSTransaction(REC, CurrTableNo, CurrTableDescr, CurrDinResNo);

        if REC."New Transaction" then
            if (POSSESSION.GetStartMenu = POSSESSION.GetSalesMenu) or (POSSESSION.GetStartMenu = '') or
               (POSSESSION.GetValue("LSC POS Tag"::"SHOWSALESMENU") <> '')
            then begin
                TmpTxt := InfoTextDescription;
                SalePressed(true, true);
                SelectDefaultMenuFlag := false;
                InfoTextDescription := TmpTxt;
            end;

        gTransNo := 0;

        //POSTransactionEvents.OnInit_OnBeforeTransDiscLoad(REC, Format(STATE));

        PosFunc.PosTransDiscLoad(REC."Receipt No.");
        //PosFunc.InitTrackingInstanceID(REC);
        PosFunc.LoadOfferTables(true);

        IsHandled := false;
        // POSTransactionEvents.OnBeforeUpdateGlobalMemberInformation(REC, IsHandled);
        // if not IsHandled then begin
        //     MemberLoadError := not Member.LoadMemberInfo(REC."Member Card No.", ErrorText, true, MemberLoadSyncError);
        //     if MemberLoadError and MemberLoadSyncError then
        //         MemberLoadError := not Member.LoadMemberInfo(REC."Member Card No.", ErrorText, true, MemberLoadSyncError);
        //     if MemberLoadError then begin
        //         Member.Init();
        //         REC."Member Card No." := '';
        //         REC.Modify;
        //         PosTransactionGui.MessageBeep(ErrorText);
        //     end;
        // end;
        // CurrentAvailabilityLock.ClearRecord(POSSESSION.TerminalNo);
        // POSTransactionEvents.OnAfterInit(REC);
        DoXYReportCheck := true;
        if REC."Customer No." <> '' then
            if POSSESSION.GetValue("LSC POS Tag"::"RUNPOS") <> '' then
                IF Customer.GET(REC."Customer No.") then begin
                    KeyboardAmount := true;
                    OnlySelectCustomer := true;
                    ProcessCustomer(false);
                end;
        if not IsNewTransaction then
            POSGUI.PostCommand("LSC POS Command"::EFT_RECOVER, '');

        POSCtrl.RegisterPanelClosedEvent('#COPICKLINES');
        POSTransactionEvents.OnAfterPOSInit(PosTerminal);

        if ShouldVoid then begin
            POSSession.SetValue("LSC POS Tag"::SKIPVOIDCONFIRM, 'TRUE');
            VoidPressed();
        end;

        exit(true);
    end;

    procedure IsInitialized(): Boolean
    begin
        exit(_Initialized); // STATE <> ''
    end;

    procedure SetOfflineTenderDeclState(pCommand: Text)
    begin
        case pCommand of
            'TD_ENDDAY':
                begin
                    DoXYReportCheck := true;
                    REC."Transaction Type" := REC."Transaction Type"::"Tender Decl.";
                end;
            'REM_TENDER':
                begin
                    DoXYReportCheck := true;
                    REC."Transaction Type" := REC."Transaction Type"::"Remove Tender";
                end;
            'FLOAT_ENT':
                begin
                    DoXYReportCheck := true;
                    REC."Transaction Type" := REC."Transaction Type"::"Float Entry";
                end;
            else begin
                DoXYReportCheck := false;
            end;
        end;
    end;

    procedure Close(FromStart: Boolean): Boolean
    var
        CurrentAvailabilityFunctions: Codeunit "LSC Current Availab. Functions";
        KDSFunctions: Codeunit "LSC KDS Functions";
    begin
        if FromStart then begin
            //POSTransactionEvents.OnBeforeClose(REC);

            EFT.CloseEFTServer;

            POSSESSION.SetValue("LSC POS Tag"::"CURRORDER", '');

            if PosTerminal."Display Terminal Closed" then begin
                // InitDisplay();
                // if (DisplayDevice.IsActive()) then begin
                //     if PosTerminal."Customer Display Text 1" = '' then
                //         OposUtil.Display(DisplayDevice."Display Closed Line1", DisplayDevice."Display Closed Line2")
                //     else
                //         OposUtil.Display(PosTerminal."Customer Display Text 1", PosTerminal."Customer Display Text 2");
                // end;
            end;

            // if not (TSUtil.UpdateStaffStatus(POSSESSION.StaffID, POSSESSION.TerminalNo, false)) then;
            // if not PosFunc.UseBackgroundSession then
            //     TSUtil.SendUnsentTablesDD3(0, true);
            // if PosCtrl.GetInitialized() then
            //     if KDSFunctions.HospCheckKDSConfirmNeeded(1, 'ON-CLOSE', Format(STATE), StoreSetup."No.", REC) then
            //         exit(false);
        end;
        //PosFunc.InsertTransInUseOnPos(REC."Receipt No.", POSSESSION.TerminalNo, true, false);

        SetPOSState('');

        // if (PosTerminal."Online Trans. Backup") or (PosFuncProfile."TS Online Trans. Backup") then begin
        //     if (REC."Transaction Type" <> REC."Transaction Type"::Logoff) then
        //         TSUtil.SendTableTransaction(REC, 0);
        // end;
        // if CurrentAvailabilityFunctions.SetCurrentAvailabilityLock(false) then;

        Commit;
        //POSTransactionEvents.OnAfterClose(REC);
        exit(true);
    end;

    procedure GetCommandRetVal(): Boolean
    begin
        exit(CommandRetVal);
    end;

    procedure ValidateInput()
    var
        PosCommandRec: Record "LSC POS Command";
        PosCommand: Enum "LSC POS Command";
        IsHandled: Boolean;
    begin
        // if not PosCommandRec.CommandExists(FunctionSetup."Function Code", PosCommand) then begin
        //     PosTransactionGui.MessageBeep('');
        //     BackDateTransCheck;
        //     exit;
        // end;

        //  POSTransactionEvents.OnFindPosCommandBeforeValidateInput(PosCommand, IsHandled);
        if not IsHandled then
            case PosCommand of
                PosCommand::CARD:
                    ValidateCard;
                PosCommand::CARDEXTRA:
                    ValidateCardExtra;
                PosCommand::CARDTYPE:
                    ValidateCardType;
                PosCommand::CHECK:
                    ValidatePriceCheck;
                PosCommand::CONTROL:
                    ValidateControl;
                PosCommand::CUSTOMER:
                    ValidateCustomer;
                PosCommand::CONTACT:
                    ValidateContact;
                PosCommand::ERRCHK:
                    ErrorCheck;
                PosCommand::EXDATE:
                    ValidateDate;
                PosCommand::INFOCODE:
                    ValidateInfocode(0, false, false);
                PosCommand::PASSWORD:
                    ValidatePassword;
                PosCommand::PRICE:
                    if ValidatePrice(KeyboardPrice, KeyboardPrice, Item."No.") then
                        NextItemPhase;
                PosCommand::SALESP:
                    ProcessSalesPerson;
                PosCommand::VARIANT:
                    begin
                        if pluCheckPriceMode then begin
                            pluCurrVariant := CopyStr(CurrInput, 1, 10);
                            CurrInput := NewLine.Number;
                            ValidatePriceCheck;
                            ClearPluCheckPriceAndVariant;
                        end else
                            ValidateVariant;
                    end;
                PosCommand::QUANTITY:
                    ValidateQtyInput;
                // PosCommand::WEIGHT:
                //     POSTransScale.ValidateWeight(false);
                PosCommand::SERIALNO:
                    ValidateSerialLotInput;
                PosCommand::LOTNO:
                    ValidateSerialLotInput;
                PosCommand::INVOICENO:
                    ValidateCustomerInvoiceNoInput;
                PosCommand::DAENTRCODE:
                    ValidateDataEntryInput;
                PosCommand::ADDSALESP:
                    AddSalesPerson(true);
                PosCommand::ADDSALESP_L:
                    AddSalesPerson(false);
                else
                    PosTransactionGui.MessageBeep('');
            end;

        BackDateTransCheck;
    end;

    procedure Gui(): Codeunit "OPTs POS Transaction GUI"
    begin
        exit(GUI_)
    end;

    procedure Member()
    begin
        // exit(Member_);
    end;

    procedure EFT(): Codeunit "OPT POS Transaction EFT"
    begin
        exit(EFT_);
    end;

    procedure TSUtil(): Codeunit "LSC POS Trans. Server Utility"
    begin
        exit(TSUtil_);
    end;

    // procedure SetMemberCodeunit(MemberCodeunit: Codeunit "LSC POS Transaction Member")
    // begin
    //     //  Member_ := MemberCodeunit;
    // end;

    procedure ActiveMemberCardNo(): Text
    begin
        exit(REC."Member Card No.");
    end;

    procedure ValidateRecordIDInput(pRecordID: RecordID; pConfirmSelection: Boolean): Boolean
    var
        TransactionHeaderMulti: Record "LSC Transaction Header";
        inRecRef: RecordRef;
        lMembershipCard: Record "LSC Membership Card";
        inFldRef: FieldRef;
        TextValue: Text;
        TextValue2: Text;
        ConfirmResult, IsHandled : Boolean;
        Confirm001: Label '\\Confirm %1?';
        NoActiveMembershipCardFoundErr: Label 'No active Membership Card found';
        InvalidRecIDInputMsg: Label 'Invalid Record ID input [%1]';
    begin
        if not inRecRef.Get(pRecordID) then begin
            PosTransactionGui.MessageBeep(StrSubstNo(InvalidRecIDInputMsg, Format(pRecordID)));
            exit(false);
        end;

        AskConfirmation := pConfirmSelection;
        ConfirmResult := true;

        case inRecRef.Number of
            Database::Item:
                begin
                    inFldRef := inRecRef.Field(3);
                    TextValue := inFldRef.Value;
                    if pConfirmSelection then
                        ConfirmResult := PosTransactionGui.PosConfirm(TextValue + StrSubstNo(Confirm001, inRecRef.Name), true);
                    if ConfirmResult then begin
                        inFldRef := inRecRef.Field(1);
                        CurrInput := Format(inFldRef.Value);
                        ItemNoPressed();
                    end;
                end;
            Database::Customer:
                begin
                    inFldRef := inRecRef.Field(1);
                    TextValue := inFldRef.Value;
                    inFldRef := inRecRef.Field(2);
                    TextValue2 := inFldRef.Value;
                    TextValue := TextValue + ', ' + TextValue2;
                    inFldRef := inRecRef.Field(1);
                    CurrInput := Format(inFldRef.Value);
                    CustomerPressed();
                end;
            Database::"LSC Transaction Header":
                begin
                    MultipleRecordsForReceipt := false;
                    inFldRef := inRecRef.Field(15);
                    TransactionHeaderMulti.SetCurrentKey("Receipt No.");
                    TransactionHeaderMulti.SetRange("Receipt No.", Format(inFldRef.Value));
                    if TransactionHeaderMulti.count > 1 then begin
                        MultipleRecordsForReceipt := true;
                        CurrInput := Format(inRecRef.RecordId);
                    end else
                        CurrInput := Format(inFldRef.Value);
                    VoidPostedTransaction();
                end;
            Database::Contact:
                begin
                    ContactPressed();
                    inFldRef := inRecRef.Field(1);
                    CurrInput := Format(inFldRef.Value);
                    ValidateInput;
                end;
            Database::"LSC Member Contact":
                begin
                    inFldRef := inRecRef.Field(1);
                    lMembershipCard.SetCurrentKey("Account No.", "Contact No.", Status);
                    lMembershipCard.SetRange("Account No.", Format(inFldRef.Value));
                    inFldRef := inRecRef.Field(5);
                    lMembershipCard.SetRange("Contact No.", Format(inFldRef.Value));
                    lMembershipCard.SetRange(Status, lMembershipCard.Status::Active);
                    if lMembershipCard.FindFirst then begin
                        if pConfirmSelection then begin
                            inFldRef := inRecRef.Field(10); //Name
                            TextValue := inFldRef.Value;
                            ConfirmResult := PosTransactionGui.PosConfirm(TextValue + StrSubstNo(Confirm001, inRecRef.Name), true);
                        end;

                        if ConfirmResult then
                            InputMemberCard(lMembershipCard."Card No.")
                    end
                    else
                        PosTransactionGui.MessageBeep(NoActiveMembershipCardFoundErr);
                end;
            Database::"Item Variant":
                begin
                    if pConfirmSelection then begin
                        inFldRef := inRecRef.Field(3); //Description
                        TextValue := inFldRef.Value;
                        inFldRef := inRecRef.Field(4); //Description2
                        TextValue2 := inFldRef.Value;
                        ConfirmResult := PosTransactionGui.PosConfirm(TextValue + ' ' + TextValue2 + StrSubstNo(Confirm001, inRecRef.Name), true);
                    end;
                    if ConfirmResult then begin
                        inFldRef := inRecRef.Field(2); //Item No.
                        CurrInput := Format(inFldRef.Value);
                        inFldRef := inRecRef.Field(1); //Variant Code
                        ItemLine(true, false, 0, 0, Format(inFldRef.Value), '', '', '', 0, 0);
                    end;
                end;
            Database::"LSC Barcodes":
                begin
                    if pConfirmSelection then begin
                        inFldRef := inRecRef.Field(25); //Description
                        TextValue := inFldRef.Value;
                        inFldRef := inRecRef.Field(200); //Unit of measure
                        TextValue2 := inFldRef.Value;
                        ConfirmResult := PosTransactionGui.PosConfirm(TextValue + ' ' + TextValue2 + StrSubstNo(Confirm001, inRecRef.Name), true);
                    end;
                    if ConfirmResult then begin
                        inFldRef := inRecRef.Field(10); //Barcode No.
                        CurrInput := Format(inFldRef.Value);
                        ItemLine(true, false, 0, 0, '', '', '', '', 0, 0);
                    end;
                end;
            else
                //POSTransactionEvents.OnAfterValidateRecordIDInputBarcodes(inRecRef, IsHandled);
                if not IsHandled then
                    PosTransactionGui.MessageBeep(StrSubstNo(InvalidRecIDInputMsg, Format(pRecordID)));
        end;
        AskConfirmation := true;
    end;

    procedure RunCommand(var MenuLine: Record "LSC POS Menu Line"): Boolean
    var
        CurrFunction: Record "LSC POS Command";
        FunctionSetup2: Record "LSC POS Command";
        Currline: Record "LSC POS Trans. Line";
        POSTransPostingState: Record "LSC POS Trans. Posting State";
        POSDataTableColumns: Record "LSC POS Data Table Columns";
        PosCommandRec: Record "LSC POS Command";
        CurrentAvailabilityFunctions: Codeunit "LSC Current Availab. Functions";
        PosCommand: Enum "LSC POS Command";
        Processed, CommandExists : Boolean;
        ErrorState: Boolean;
        ErrorText: Text;
        iPos: Integer;
        CommandType: Integer;
        IsHandled: Boolean;
        IsMissingFromErr: Label '%1 is missing from %2';
        EmptyCardEntry: Record "LSC POS Card Entry";
    begin
        GlobalMenuLine := MenuLine;
        CommandType := 0;
        gCancelOffer := false;
        if FunctionSetup2.Get(MenuLine.Command) then begin
            CommandType := FunctionSetup2."Function Type";
            if FunctionSetup2."Set POS State" <> '' then begin
                SetPOSState(FunctionSetup2."Set POS State");
                SetFunctionMode(FunctionSetup2."Set POS State");
            end else
                UpdateInputDevicesState(FunctionSetup2, false);
        end;

        if _Initialized then
            if MenuLine."Current-LINE" = 0 then begin
                POSLINES.GetCurrentLine(Currline);
                MenuLine."Current-LINE" := Currline."Line No.";
            end;

        // POSTransactionEvents.OnBeforeRunCommand(REC, Currline, CurrInput, MenuLine, IsHandled, TenderType, CustomerOrCardNo);
        if IsHandled then
            exit(true);

        if CommandType = 1 then begin        //External commands
            if FunctionSetup2."Run Codeunit" = 0 then begin
                PosTransactionGui.MessageBeep('');
                exit(false);
            end;

            Commit;

            PopulatePOSMenuLineForCodeunitRun(MenuLine.Command, MenuLine.Parameter, MenuLine, Currline, false, false);

            CODEUNIT.Run(FunctionSetup2."Run Codeunit", MenuLine);

            // POSTransactionEvents.OnBeforeRunProcessExternalCommand(MenuLine, IsHandled);
            if not IsHandled then
                if MenuLine."Input Process" = MenuLine."Input Process"::" " then
                    ProcessExternalCommand(MenuLine);
            exit(true);
        end;

        if (FunctionSetup2."Function Type" = FunctionSetup2."Function Type"::"POS Internal") then begin
            case FunctionSetup2."Run Codeunit" of
                Codeunit::"LSC Pop-up POS Commands":
                    begin
                        PopulatePOSMenuLineForCodeunitRun(MenuLine.Command, MenuLine.Parameter, MenuLine, Currline, false, false);
                        PopupPOSComm.Run(MenuLine);
                        if MenuLine."Input Process" = MenuLine."Input Process"::" " then
                            ProcessPopupCommand(MenuLine);
                        exit(true);
                    end;
            end;
        end;

        //CommandExists := PosCommandRec.CommandExists(MenuLine.Command, PosCommand);

        //POSTransactionEvents.OnBeforePOSCommandCaseProcessed(Rec, CurrLine, CurrInput, POSSESSION, STATE, MenuLine.Command, Processed);

        if not Processed then
            if EFT.RunCommand(PosCommand, MenuLine, REC, LineRec, CurrInput, TrainingActive, POSSESSION.PrinterActive, ErrorState, ErrorText) then begin
                Processed := true;
                if ErrorState then
                    PosTransactionGui.ErrorBeep(ErrorText);
            end;

        if CommandExists and (not Processed) then begin
            Processed := true;
            case PosCommand of
                PosCommand::"VARIANT":
                    VariantPressed(MenuLine.Parameter);
                PosCommand::NEWSALE:
                    NewSalePressed();
                PosCommand::CONTACT:
                    ContactPressed;
                PosCommand::VIEW_CUSTOMER:
                    ViewCustomer(MenuLine);
                PosCommand::MSRCARD:
                    InputMSRCards();
                PosCommand::MEMBERCARD:
                    InputMemberCard(MenuLine.Parameter);
                // PosCommand::LOCATIONPROF_PRINT:
                //     POSTransPrint.LocationProfilePrint(StoreSetup."Location Profile");
                PosCommand::LOCATIONPROF_EMAIL:
                    LocationProfileEmail;
                PosCommand::LOCATIONPROF_SMS:
                    LocationProfileSMS;
                PosCommand::CANCEL:
                    CancelPressed(false, 0);
                PosCommand::CANCEL2:
                    CancelPressed(true, 0);
                PosCommand::BACKSPACE:
                    BackSpace;
                PosCommand::"LOOKUP":
                    LookUp(true, MenuLine.Parameter, '');
                PosCommand::INV_LOOKUP:
                    InventoryLookupPressed;
                PosCommand::REFUND_MARK_LINE,
                PosCommand::REFUND_ITEM,
                PosCommand::REFUND_MARK_ALL:
                    RefundMgt.Run(MenuLine);
                PosCommand::EFT_RECOVER:
                    begin
                        if POSSESSION.EFTActive() then begin
                            PrintCardSlips(GetLastCardEntryReceiptNo()); //Trigger EFT Printing if something outstanding
                            EFTCheckLastTrans(false);
                        end;
                    end;
                PosCommand::CHECK_INFOCODE:
                    CheckInfoCode(MenuLine.Parameter);
                PosCommand::ERRORBEEP:
                    PosTransactionGui.ErrorBeep(MenuLine.Parameter);
                PosCommand::MESSAGEBEEP:
                    PosTransactionGui.MessageBeep(MenuLine.Parameter);
                PosCommand::" ":
                    begin
                        PosTransactionGui.MessageBeep('');
                        exit(false);
                    end;
                else
                    Processed := false;
            end;
        end;

        if CommandExists and (not Processed) then begin
            Processed := true;
            if (not OkNewInput) and (FunctionSetup."Function Code" <> Format("LSC POS Command"::CHECK)) then begin
                PosTransactionGui.MessageBeep('');
                exit(false);
            end;
            CurrFunction.Get(MenuLine.Command);
            if CurrFunction."Manager Key" then
                if not POSSESSION.MgrKey then begin
                    PosTransactionGui.ErrorBeep(MgrKeyRequiredErr);
                    exit(false);
                end;

            case PosCommand of
                PosCommand::AMOUNT_K:
                    AmountKeyPressed(MenuLine.Parameter);
                PosCommand::CHECK_NEW_MSG:
                    OnIdle_RefreshRetailMessageTagText();
                PosCommand::CURR_K:
                    CurrencyKeyPressed(MenuLine.Parameter, 0);
                PosCommand::CARDT_K:
                    CardTypeKeyPressed(MenuLine.Parameter);
                PosCommand::SETSALESTYPE_LINES:
                    ChangeSalesType(MenuLine.Parameter, MenuLine.Command);
                PosCommand::CHSALESTYPE_LINES:
                    ChangeSalesType(MenuLine.Parameter, MenuLine.Command);
                PosCommand::SETSALESTYPE_TRANS:
                    ChangeSalesType(MenuLine.Parameter, MenuLine.Command);
                PosCommand::CHSALESTYPE_TRANS:
                    ChangeSalesType(MenuLine.Parameter, MenuLine.Command);
                PosCommand::COUPON:
                    begin
                        if CurrInput = '' then
                            CurrInput := MenuLine.Parameter;
                        CouponPressed;
                    end;
                PosCommand::ISSUECOUPON:
                    IssueCouponPressed(MenuLine.Parameter);
                PosCommand::DEAL:
                    begin
                        // GlobalMenuLineTag := MenuLine;
                        // if ItemStockRestrictionOn then
                        //     CurrentAvailabilityFunctions.CurrentAvailabilityPressed(MenuLine, CurrInput)
                        // else
                        //     DealPressed(MenuLine.Parameter);
                    end;
                PosCommand::DEALMODCHANGE:
                    DealSwap(false);
                PosCommand::DEALMODSWITCHMOD:
                    DealSwitchGroup(MenuLine.Parameter, false);
                PosCommand::DEALMODADDEXTRA:
                    DealAddExtra;
                PosCommand::DEALMODCHANGELINE:
                    DealSwap(true);
                PosCommand::DEALMODSWITCHLINE:
                    DealSwitchGroup(MenuLine.Parameter, true);
                PosCommand::DISCAM:
                    DiscAmPressed(MenuLine.Parameter, false);
                PosCommand::DISCPAYM:
                    DiscAmPressed(MenuLine.Parameter, true);
                PosCommand::DISCPR:
                    DiscPrPressed(MenuLine.Parameter);
                PosCommand::DISRESET:
                    DiscResetPressed;
                // PosCommand::EXCHANGE:
                //     POSTransactionFunctions.ExchangePressed(MenuLine.Parameter, REC, RefundTransaction, RefundMgt, stateTxt);
                // PosCommand::FLOAT_ENT:
                //     FloatPressed;
                PosCommand::GETORDER:
                    GetOrderPressed(MenuLine.Parameter);
                PosCommand::CREATEORD:
                    CreateOrderPressed;
                PosCommand::POSTINVOICE:
                    PostInvoicePressed;
                PosCommand::SELECTCUST:
                    SelectCustPressed(MenuLine.Parameter);
                PosCommand::TOACCOUNT:
                    ToAccountPressed;
                PosCommand::INCEXP:
                    IncExpPressed(MenuLine.Parameter);
                PosCommand::INFO_K:
                    InfoKeyPressed(MenuLine);
                PosCommand::INFO_REQLI_ALL:
                    InfocodeRequestOnLine(1);
                PosCommand::INFO_REQLI_REQ:
                    InfocodeRequestOnLine(2);
                PosCommand::ITEMNO:
                    ItemNoPressed;
                PosCommand::MEALMENU_INSERT:
                    MealMenuInsertPressed(MenuLine.Parameter);
                PosCommand::NEG_QTY:
                    MultiplyMinusPressed;
                PosCommand::NEG_ADJ:
                    NegAdjPressed;
                PosCommand::PHYS_INV:
                    PhysInvPressed;
                PosCommand::PAYM_ACC:
                    PaymentIntoAccountPressed(MenuLine.Parameter);
                PosCommand::QTY:
                    MultiplyPressed(MenuLine.Parameter);
                PosCommand::OPEN_DR:
                    OpenDrawerPressed(MenuLine.Parameter);
                PosCommand::PLU_K:
                    begin
                        // LastProfileID := MenuLine."Profile ID";
                        // LastMenuID := MenuLine."Menu ID";
                        // GlobalMenuLineTag := MenuLine;
                        // if ItemStockRestrictionOn then
                        //     CurrentAvailabilityFunctions.CurrentAvailabilityPressed(MenuLine, CurrInput)
                        // else
                        //     PluKeyPressed(MenuLine.Parameter);
                    end;
                PosCommand::AVAILABILITY_MODE:
                    begin
                        if StoreSetup."Show Availab. on POS Button" = StoreSetup."Show Availab. on POS Button"::No then
                            PosTransactionGui.PosMessage(StrSubstNo(OnStockRestrictionNo, StoreSetup.FieldCaption("Show Availab. on POS Button"), StoreSetup."No."))
                        else begin
                            // CurrentAvailabilityFunctions.SetCurrentAvailability(ItemStockRestrictionOn);
                            // if not ItemStockRestrictionOn then begin
                            //     STATE := "LSC POS Transaction State"::SALES;
                            //     SetPOSState(LAST_STATE);
                            //     CurrentAvailabilityFunctions.CheckPOSMenuLine(MenuLine, ItemStockAction::ResetAll);
                            // end else begin
                            //     SetPOSState("LSC POS Transaction State"::STOCK);
                            //     CurrentAvailabilityFunctions.CheckPOSMenuLine(MenuLine, ItemStockAction::EnableAll);
                            //     if MenuLine.Parameter <> '' then
                            //         CurrInput := CopyStr(MenuLine.Parameter, 1, 20);
                            // end;
                        end;
                    end;
                PosCommand::PLU_ZERO:
                    PluKeyPressed(MenuLine.Parameter);
                PosCommand::POST:
                    begin
                        POSSESSION.SetTransPostingSource(POSTransPostingState."Posting Source"::"Post Pressed");
                        PostPressed;
                    end;
                PosCommand::PRICECH:
                    ChangePricePressed(MenuLine.Parameter);
                PosCommand::PRICECHK:
                    PriceCheckPressed(MenuLine.Parameter);
                // PosCommand::PRINT_C:
                //     POSTransPrint.PrintSlipCopy(false);
                // PosCommand::PRINT_LAST_C:
                //     POSTransPrint.PrintSlipCopy(true);
                // PosCommand::PRINT_IC:
                //     POSTransPrint.PrintInvoiceCopy();
                // PosCommand::PRINT_LAST_IC:
                //     POSTransPrint.PrintLastInvoiceCopy();
                PosCommand::EMAIL_C:
                    EmailSlipCopy;
                PosCommand::EMAIL_LAST_C:
                    EmailLastSlipCopy;
                PosCommand::EMAIL_IC:
                    EmailInvoiceCopy;
                PosCommand::EMAIL_LAST_IC:
                    EmailLastInvoiceCopy;
                // PosCommand::PRINT_TIPS:
                //     POSTransPrint.PrintTipsReport();
                PosCommand::PRINT_X:
                    begin
                        if DoXYReportCheck then
                            PrintXReport(true)
                        else begin
                            PrintXReport(false);
                        end;
                    end;
                PosCommand::PRINT_Z:
                    PrintZReport(true, true);
                PosCommand::PRINT_Y:
                    begin
                        if DoXYReportCheck then
                            PrintYReport(true)
                        else begin
                            PrintYReport(false);
                        end;
                    end;
                // PosCommand::PRINT_CID:
                //     POSTransPrint.PrintCIDReport();
                PosCommand::PURGE:
                    PurgePressed;
                PosCommand::RUNOBJ:
                    RunObjPressed(MenuLine.Parameter, 'MENU');
                PosCommand::QTYCH:
                    ChangeQtyPressed(MenuLine.Parameter);
                PosCommand::REQ_DESCR_TRANSSTART:
                    begin
                        // POSTransactionFunctions.RequestDescriptionForSalesTypeOnTransStart(REC, (POSSESSION.GetValue("LSC POS Tag"::"PREVENT_NORMSALE") <> ''));
                        // exit;
                    end;
                // PosCommand::REC_TGL:
                //     POSTransPrint.RecPrintTogglePressed();
                PosCommand::REFUND:
                    RefundPressed(true);
                PosCommand::REFUNDLINE:
                    RefundLinePressed;
                PosCommand::REM_TENDER:
                    RemoveTenderPressed;
                PosCommand::SALESP:
                    ProcessSalesPerson;
                PosCommand::STAFFLOGCO:
                    CorrectStaffLogin;
                PosCommand::STAFFLOGIN:
                    LogInOutStaff(0);
                PosCommand::STAFFLOGOU:
                    LogInOutStaff(1);
                PosCommand::START:
                    begin
                        if not PreventNormalSaleCheck then
                            exit;

                        if REC."New Transaction" then //IGNORE COMMAND IF NOT VALID STATE
                            SalePressed(true);
                    end;
                PosCommand::SUSPEND:
                    SuspendPressed(MenuLine.Parameter);
                // PosCommand::TARE:
                //     if LocalizationExt.IsNALocalizationEnabled then
                //         POSTransScale.TarePressed();
                PosCommand::CARDONFILE:
                    CardOnFilePressed(MenuLine.Parameter);
                PosCommand::TENDER_K:
                    TenderKeyPressed(MenuLine.Parameter);
                PosCommand::TENDER_K_AM:
                    begin
                        iPos := StrPos(MenuLine.Parameter, ',');
                        if iPos > 0 then
                            TenderKeyPressedEx(CopyStr(MenuLine.Parameter, 1, iPos - 1), CopyStr(MenuLine.Parameter, iPos + 1))
                        else
                            TenderKeyPressed(MenuLine.Parameter);
                    end;
                PosCommand::TENDER_D:
                    TenderDeclPressed;
                PosCommand::TENDNO:
                    TenderNoPressed;
                PosCommand::TOTAL:
                    begin
                        //POSTransactionEvents.OnBeforeTotalGetRecommendation(REC, MenuLine, IsHandled);
                        if IsHandled then
                            exit(true);
                        GetRecommendation(MenuLine, true);
                        TotalPressed(false);
                    end;
                PosCommand::TOTDISCAM:
                    TotDiscAmPressed(MenuLine.Parameter, false, true);
                PosCommand::TOTDISCPR:
                    TotDiscPrPressed(MenuLine.Parameter, true);
                PosCommand::TOTPAYAM:
                    TotDiscAmPressed(MenuLine.Parameter, true, true);
                PosCommand::TRAINING:
                    TrainingPressed;
                PosCommand::UOM:
                    UnitOfMeasurePressed(MenuLine.Parameter);
                PosCommand::VOID:
                    VoidPressed;
                PosCommand::VOID_L:
                    VoidLinePressed;
                PosCommand::VOID_TR:
                    if REC."Entry Status" = REC."Entry Status"::Training then begin
                        POSDataTableColumns.SetRange("Data Table ID", 'REGISTER');
                        POSDataTableColumns.SetRange("Field No.", 120); //Entry Status
                        if POSDataTableColumns.FindFirst() then begin
                            POSDataTableColumns."Fixed Filter" := '[%=TRAININGMODE]';
                            POSDataTableColumns.Modify();
                            POSSESSION.SetValue("LSC POS Tag"::"TRAININGMODE", Format(REC."Entry Status"::Training));
                            LookUp(true, 'REGISTER', '');

                            //Clean up
                            POSSESSION.SetValue("LSC POS Tag"::"TRAININGMODE", '');
                            POSDataTableColumns."Fixed Filter" := '';
                            POSDataTableColumns.Modify();
                        end else
                            Error(StrSubstNo(IsMissingFromErr, REC.FieldCaption("Entry Status"), POSDataTableColumns.TableCaption));
                    end else
                        LookUp(true, 'REGISTER', '');
                // PosCommand::PRINT_SL:
                //     POSTransPrint.PrintPOSSlip();
                PosCommand::MARK:
                    MarkPressed();
                PosCommand::TEXT:
                    TextPressed(MenuLine.Parameter);
                PosCommand::TEXT_LINKED:
                    TextLinkedPressed(MenuLine.Parameter);
                PosCommand::GUEST_TGL:
                    ToggleGuestPressed;
                PosCommand::SPLIT_BILL:
                    SplitBillPressed;
                PosCommand::CONFIRMORDER:
                    ConfirmOrderPressed(true);
                PosCommand::GETNEXT:
                    GetNextInQueuePressed;
                PosCommand::TD_ENDDAY:
                    TD_TenderDeclEndOfDayPressed;
                PosCommand::TD_OPEN_DR:
                    TD_OpenDrawerPressed;
                PosCommand::TD_CANCEL:
                    TD_CancelPressed;
                PosCommand::UOMCH:
                    ChangeUnitOfMeasurePressed(MenuLine);
                PosCommand::PAYM_ACC_INV:
                    PaymentIntoAccWithInvPressed(MenuLine.Parameter);
                PosCommand::POSZOOM:
                    POSZoom(MenuLine);
                PosCommand::POSINFO:
                    POSInfo(MenuLine);
                PosCommand::VOIDPP:
                    VoidPrepaymentPressed();
                PosCommand::VOIDPP_L:
                    VoidPrepaymentLinePressed();
                PosCommand::CHGPP_L:
                    ChangePrepaymentLinePressed();
                PosCommand::ADDPP_L:
                    AddPrepaymentLinePressed();
                PosCommand::ITEMFINDER:
                    ItemFinderPressed(MenuLine.Parameter);
                PosCommand::VIEW_DATAENTRY_BAL:
                    ViewDataEntryBalance(MenuLine.Parameter);
                PosCommand::VIEW_VOUCHER_ENTRIES:
                    ViewVoucherEntries(MenuLine.Parameter);
                PosCommand::ADDSALESP:
                    AddSalesPerson(true);
                PosCommand::ADDSALESP_L:
                    AddSalesPerson(false);
                PosCommand::LINE_DISC_OFFER:
                    LineDiscOffer(MenuLine.Parameter);
                PosCommand::TENDER_DISC_AT_TOTAL:
                    ProcessTenderOfferAtTotal('');
                PosCommand::SHOWDISCINFO:
                    ShowDiscInfo();
                PosCommand::ITEM_POINT_OFFER:
                    ProcessItemPointOffer(true);
                PosCommand::MEMBERCONTACT:
                    EditMemberContact;
                PosCommand::MEMBER_EMAIL:
                    AddMemberEmail;
                PosCommand::CHECK_TS_STATUS:
                    CheckTSStatus;
                PosCommand::REORDERMENUTYPE:
                    ReOrderMenuType(MenuLine.Parameter);
                PosCommand::REORDERQTY:
                    ReOrderQty(MenuLine.Parameter);
                PosCommand::CUSTOMER_ORDER_LIST:
                    CustomerOrderList;
                PosCommand::CUSTOMER_ORDER:
                    CustomerOrder(MenuLine.Parameter);
                PosCommand::CO_PREPAYMENT:
                    TogglePrepayCustomerOrder();
                PosCommand::WEB_REPL:
                    WebReplication(MenuLine.Parameter);
                PosCommand::FBP_STATUS:
                    FBPStatus(MenuLine);
                PosCommand::COUPON_LIST:
                    ShowMemberCouponList(MenuLine);
                PosCommand::COPY_TR:
                    CopyPostedTransaction();
                PosCommand::VOID_AND_COPY_TR:
                    VoidAndCopyTransaction();
                PosCommand::RECOMMEND:
                    begin
                        GetRecommendation(MenuLine, false);
                        REC.Get(REC."Receipt No.");
                    end;
                PosCommand::PREAUTH,
                PosCommand::"PREAUTH-UPDATE",
                PosCommand::"PREAUTH-FINALIZE",
                PosCommand::ADDCARDTOFILE:
                    PreauthPressed(MenuLine.Command, MenuLine.Parameter);
                PosCommand::COLLECTSCANPAYGO:
                    CollectSPGOrderPressed(MenuLine);
                // PosCommand::SCANNER_BEHAVIOUR:
                //     //POSTransactionFunctions.Process_T_Transaction(CurrInput, NewLine, PosFuncProfile, MenuLine.Parameter);
                //     PosCommand::SEARCHCONTACT:
                //     //POSTransactionFunctions.SearchMemberContact();
                else begin
                    Processed := false;
                    //  POSTransactionEvents.OnAfterPOSCommandCaseProcessed(PosCommand, MenuLine, TenderType, StoreSetup, Balance, REC, Currency, EmptyCardEntry, CustomerOrCardNo, ReadFromMSR, ChangeTender, TrainingActive, STATE, PaymentAmount, PosFunc, CurrInput, gInsertTmpPayment, Processed);
                end;
            end;
        end;

        if not Processed then begin
            if CommandType = 0 then begin
                PosTransactionGui.MessageBeep('');
                exit(false);
            end;
        end;

        UpdateInputDevicesState(FunctionSetup2, true);

        //POSTransactionEvents.OnAfterRunCommand(REC, Currline, CurrInput, MenuLine.Command, MenuLine);
        CalcTotals();

        TSCheckError;

        exit(true);
    end;

    local procedure PopulatePOSMenuLineForCodeunitRun(Command: Code[20]; Parameter: Text; var POSMenuLineIn: Record "LSC POS Menu Line"; POSTransLine: Record "LSC POS Trans. Line"; UseLineRec: Boolean; UseDefaultMenus: Boolean)
    begin
        if UseDefaultMenus then begin
            POSMenuLineIn."Profile ID" := POSSESSION.MenuProfileID;
            POSMenuLineIn."Menu ID" := POSGUI.GetCurrMenu(0);
        end;
        POSMenuLineIn.Command := Command;
        POSMenuLineIn.Parameter := Parameter;
        POSMenuLineIn."Current-MENU" := POSGUI.GetCurrMenu(0);
        POSMenuLineIn."Current-MENU1" := POSGUI.GetCurrMenu(1);
        POSMenuLineIn."Current-MENU2" := POSGUI.GetCurrMenu(2);
        POSMenuLineIn."Current-MENU3" := POSGUI.GetCurrMenu(3);
        POSMenuLineIn."Current-POSID" := POSSESSION.TerminalNo;
        POSMenuLineIn."Current-StaffID" := POSSESSION.StaffID;
        POSMenuLineIn."Current-SHIFT" := POSSESSION.GetValue("LSC POS Tag"::"SHIFT_NO");
        POSMenuLineIn."Current-SALESREP" := REC."Sales Staff";
        POSMenuLineIn."Current-RECEIPT" := REC."Receipt No.";
        POSMenuLineIn."Current-SALESORDER" := REC."Document No.";
        POSMenuLineIn."Current-SALESTYPE" := GLobalSalesType;
        POSMenuLineIn."Current-MANAGERSTATUS" := POSSESSION.MgrKey;
        POSMenuLineIn."Current-STATE" := Format(STATE);
        POSMenuLineIn."Current-INPUT" := CopyStr(CurrInput, 1, 100);
        POSMenuLineIn."Current-GUEST" := CurrGuest;
        POSMenuLineIn."Current-MenuType" := CurrMenuType;
        POSMenuLineIn."Set Current-Input" := '';
        POSMenuLineIn."Current-UOM" := UOMSet;
        POSMenuLineIn."Current-Description" := CopyStr(InfoTextDescription, 1, MaxStrLen(POSMenuLineIn."Current-Description"));
        POSMenuLineIn."Current-Description2" := CopyStr(InfoTextDescription2, 1, MaxStrLen(POSMenuLineIn."Current-Description2"));
        POSMenuLineIn."Input Process" := POSMenuLineIn."Input Process"::" ";

        if UseLineRec then begin
            POSMenuLineIn."Current-LINE" := POSTransLine."Line No.";
            if POSTransLine."Sales Type" <> '' then
                POSMenuLineIn."Current-SALESTYPE" := POSTransLine."Sales Type"
            else
                POSMenuLineIn."Current-SALESTYPE" := GLobalSalesType;
            POSMenuLineIn."Current-Description" := POSTransLine.Description;
            POSMenuLineIn."Current-INPUT" := POSTransLine.Number;
        end;
    end;

    procedure ProcessExternalCommand(POSMenuLineIn: Record "LSC POS Menu Line")
    var
        POSTransLine: Record "LSC POS Trans. Line";
        POSCommand: Record "LSC POS Command";
    begin
        //POSTransactionEvents.OnBeforeProcessExternalCommand(PosMenuLineIn);
        //HospFunc.SetBillPrinted(REC, BillIsPrinted, HospOrderTransStatus);
        CurrInput := POSMenuLineIn."Set Current-Input";
        CurrGuest := POSMenuLineIn."Current-GUEST";

        CurrMenuType := POSMenuLineIn."Current-MenuType";

        InfoTextDescription := POSMenuLineIn."Current-Description";
        InfoTextDescription2 := POSMenuLineIn."Current-Description2";
        if POSMenuLineIn."Current-RECEIPT" <> '' then begin
            if POSMenuLineIn."Current-RECEIPT" <> REC."Receipt No." then
                UseTransaction(POSMenuLineIn."Current-RECEIPT", true)
            else
                if REC.Get(REC."Receipt No.") then;
        end;

        POSLINES.GetCurrentLine(POSTransLine);

        if POSMenuLineIn."Current-LINE" <> 0 then begin
            if POSMenuLineIn."Current-LINE" <> POSTransLine."Line No." then begin
                if POSTransLine.Get(REC."Receipt No.", POSMenuLineIn."Current-LINE") then
                    POSLINES.SetCurrentLine(POSTransLine);
            end;
        end;
        POSCommand.Get(POSMenuLineIn.Command);
        UpdateInputDevicesState(POSCommand, true);

        //POSTransactionEvents.OnAfterRunCommand(REC, POSTransLine, CurrInput, POSMenuLineIn.Command, POSMenuLineIn);

        CalcTotals;
        TSCheckError;
    end;

    procedure ProcessPopupCommand(POSMenuLineIn: Record "LSC POS Menu Line")
    var
        POSTransLine: Record "LSC POS Trans. Line";
        POSCommand: Record "LSC POS Command";
    begin
        CurrInput := POSMenuLineIn."Set Current-Input";
        CurrGuest := POSMenuLineIn."Current-GUEST";
        CurrMenuType := POSMenuLineIn."Current-MenuType";
        InfoTextDescription := POSMenuLineIn."Current-Description";
        InfoTextDescription2 := POSMenuLineIn."Current-Description2";

        POSLINES.GetCurrentLine(POSTransLine);

        POSCommand.Get(POSMenuLineIn.Command);
        UpdateInputDevicesState(POSCommand, true);

        // POSTransactionEvents.OnAfterRunCommand(REC, POSTransLine, CurrInput, POSMenuLineIn.Command, POSMenuLineIn);

        CalcTotals;
        TSCheckError;
    end;

    procedure GetFunctionMode(): Code[20]
    begin
        exit(FunctionSetup."Function Code");
    end;

    // procedure GetFunctionModeEnum() FunctionModeEnum: Enum "LSC POS Command";
    // begin
    //     exit(FunctionSetup.CommandToEnum(GetFunctionMode));
    // end;

    procedure SetFunctionMode(PosCommand: Enum "LSC POS Command")
    begin
        // SetFunctionMode(FunctionSetup.CommandFromEnum(PosCommand));
    end;

    procedure SetFunctionMode(FunctionCode: Code[20])
    begin
        if FunctionCode = '' then
            exit;

        FunctionSetup.Get(FunctionCode);
        UpdateInputDevicesState(FunctionSetup, false);
        SetInputPrompt(FunctionSetup.Prompt);
        //POSTransactionEvents.OnAfterSetFunctionMode(FunctionSetup);
    end;

    procedure ItemLine(ToSalesMenu: Boolean; ExtPrice: Boolean; FixedQty: Decimal; ParentLineIn: Integer; VarCodeIn: Code[10]; FixMixMatch: Code[20]; FromInfocode: Code[20]; FromSubcode: Code[20]; FromEntryNo: Integer; FromSelQty: Decimal)
    var
        ItemUOM: Record "Item Unit of Measure";
        ReturnPolicy: Record "LSC Return Policy";
        ItemStatusLink: Record "LSC Item Status Link";
        // BOUtils: Codeunit "LSC BO Utils";
        NewLineDescription: Text[100];
        MessageText: Text[250];
        ErrorText: Text[250];
        CurrVariantCode: Code[10];
        GS1BestBeforeDate: Date;
        tmpValue: Decimal;
        RetPolicyAction: Integer;
        ItemLoaded: Boolean;
        AllExcluded: Boolean;
        Proceed: Boolean;
        IsHandled: Boolean;
        COFinishCurrentTransaction: Label 'It is not possible to add a new line to the transaction.\Please finish the current one and start a new one.';
        NewItemsCannotRefundPreviousErr: Label 'New items cannot be added to refund of previous sales';
    begin
        //POSTransactionEvents.OnBeforeItemLine(REC, LineRec, CurrInput, Balance, IsHandled);
        if IsHandled then
            exit;

        if CurrInput = '' then
            if FunctionSetup."Function Code" = Format("LSC POS Command"::ITEM) then begin
                // if PosFunc.ShouldAddItemOnEnter(GlobalMenuLine, LastItemNo, LineRec) then
                //     CurrInput := GlobalMenuLine.Parameter
                // else
                //     exit;
            end else
                exit;

        if not BackDateTransCheck then
            exit;

        if not CheckBillPrinted then begin
            CurrInput := '';
            exit;
        end;

        if not PreventNormalSaleCheck then
            exit;

        if MultiplyWith = 0 then
            exit;

        if (STATE = "LSC POS Transaction State"::PAYMENT) and CustomerOrderHeader_Temp.CancelledOrder then begin
            Clear(CurrInput);
            PosTransactionGui.ErrorBeep(COFinishCurrentTransaction);
            exit;
        end;

        pluCheckPriceMode := false;
        if FunctionSetup."Function Code" = Format("LSC POS Command"::CHECK) then
            pluCheckPriceMode := true;

        CurrVariantCode := VarCodeIn;
        NewLineDescription := '';

        if (DealNo <> '') and (not LinkedItemsActive) then begin
            CurrVariantCode := DealVariant;
            DealVariant := '';
            NewLineDescription := DealLineDescription;
        end;

        if GS1DatabarBarcodeMgmt.IsComplexBarcode(CurrInput) then begin
            ScannedDatabar := CurrInput;
            CurrInput := GS1DatabarBarcodeMgmt.GetGTINFromDatabar(ScannedDatabar)
        end else begin
            ScannedDatabar := '';
            if StrLen(CurrInput) > 20 then
                CurrInput := CopyStr(CurrInput, 1, 20);
        end;

        if CurrInput <> '' then begin
            if not Item.Get(CurrInput) then
                if CouponCodeNextItem = '' then begin
                    if ProcessCoupon(ErrorText, CopyStr(CurrInput, 1, 22), LineRec) then begin
                        if ErrorText <> '' then
                            PosTransactionGui.ErrorBeep(ErrorText);
                        CurrInput := '';
                        exit;
                    end;
                end;
        end;

        if StrLen(CurrInput) > 20 then begin
            PosTransactionGui.ErrorBeep(InvalidBarcodeErr);
            exit;
        end;

        if IsProcessReceiptBarcode(true) then
            exit;
        Proceed := true;
        //POSTransactionEvents.OnAfterValidateItemLine(REC, LineRec, CurrInput, Proceed);
        if not Proceed then
            exit;

        if not pluCheckPriceMode then begin
            if REC."New Transaction" then begin
                SalePressed(false);
                StartItemNo := CurrInput;
                if CheckInfoCode('START') then
                    exit;
            end;

            IsHandled := false;
            //POSTransactionEventsPub.OnBeforeAssigningSalesStaff(REC, PosFuncProfile, IsHandled);
            if not IsHandled then
                if (not REC."New Transaction") and (REC."Sales Staff" = '') then
                    if (PosFuncProfile."Sales Person Mode" = PosFuncProfile."Sales Person Mode"::Automatic) then
                        if POSSESSION.StaffEmploymentType = 2 then  //BOTH
                            REC."Sales Staff" := POSSESSION.StaffID;

            if FunctionSetup."Function Code" = Format("LSC POS Command"::SALESP) then begin
                StartItemNo := CurrInput;
                CurrInput := '';
                exit;
            end;
        end;
        if ToSalesMenu then begin
            // case REC."Transaction Type" of
            //     REC."Transaction Type"::NegAdj:
            //         begin
            //             SetPOSState("LSC POS Transaction State"::NEG_ADJ);
            //             SetFunctionMode("LSC POS Command"::ITEM);
            //             SelectDefaultMenu;
            //         end;
            //     REC."Transaction Type"::PhysInv:
            //         begin
            //             SetPOSState("LSC POS Transaction State"::PHYS_INV);
            //             SetFunctionMode("LSC POS Command"::ITEM);
            //             SelectDefaultMenu;
            //         end;
            //     else
            //         if (STATE <> "LSC POS Transaction State"::SALES) or (POSGUI.GetCurrMenu(0) <> POSSESSION.GetSalesMenu) then begin
            //             SetPOSState("LSC POS Transaction State"::SALES);
            //             SetFunctionMode("LSC POS Command"::ITEM);
            //             SelectDefaultMenu;
            //         end;
            // end;
        end;

        if not ExtPrice then begin
            PriceInBarcode := 0;
            KeyboardPrice := 0;
        end;

        //POSTransScale.SetScalePrice(0);
        ScaleDisplayed := false;

        if FixedQty = 0 then
            CurrQty := 1
        else
            CurrQty := FixedQty;

        if CoLinesMarkHasChanged() then begin
            COTotalHasBeenPressed := false;
            COWasCreated := false;
        end;

        InitNewLine;
        NewLine."Entry Type" := NewLine."Entry Type"::Item;
        NewLine.Number := CurrInput;
        NewLine."Parent Line" := ParentLineIn;
        NewLine."Variant Code" := CurrVariantCode;
        if NewLineDescription <> '' then
            NewLine.Description := NewLineDescription;

        if (FixMixMatch <> '') then begin
            if FixMixMatch = 'SYSTEMEXCL' then
                NewLine."System-Exclude from Offers" := true
            else begin
                NewLine."System-Unchangable Offer" := true;
                NewLine."Orig Per. Disc. Group" := FixMixMatch;
            end;
        end;

        if REC."Customer Order" and (NewLine.Number = Storesetup."Web Store Shipping Cost Item") then begin
            NewLine."Customer Order Line" := true;
            NewLine.Marked := true;
        end;

        LotNo := '';
        NewLine."Lot No." := '';
        ItemLoaded := PosFunc.LoadItem(NewLine);

        IsDataBarWithLotNoAndExpDate := false;
        WeightInKgsFromScannedDatabar := 0;
        WeightInLbsFromScannedDatabar := 0;

        if ScannedDatabar <> '' then begin
            // GS1DatabarBarcodeMgmt.GetValuesFromDatabar(ScannedDatabar, GTIN_EAN, NewLine."Expiration Date", WeightInKgsFromScannedDatabar,
            //   WeightInLbsFromScannedDatabar, NewLine."Lot No.", NewLine."Serial No.", GS1BestBeforeDate);
            ///POSTransactionEvents.OnAfterItemLineGetValuesFromDatabar(ScannedDatabar, NewLine);

            //We use both the Expiration Date(17) and the BestBeforeDate(15) as the Expiration Date in the POS Trans. Line
            if NewLine."Expiration Date" = 0D then
                NewLine."Expiration Date" := GS1BestBeforeDate;

            if NewLine.Quantity <> 0 then
                NewLine."Quantity in Barcode" := true;

            ScannedDatabar := '';

            if not CheckGS1DataBarItemAction(NewLine.Number, NewLine."Lot No.", NewLine."Expiration Date") then begin
                CurrInput := '';
                exit;
            end;

            if (NewLine."Expiration Date" <> 0D) and (NewLine."Lot No." <> '') then
                IsDataBarWithLotNoAndExpDate := true;
        end;

        if not Item.Get(NewLine.Number) then begin
            OposUtil.Beeper;
            OposUtil.Beeper;
            PosTransactionGui.PosMessage(StrSubstNo(ItemNotOnFileErr, CurrInput));
            CurrInput := '';
            exit;
        end;

        Proceed := true;
        //POSTransactionEvents.ItemLineOnAfterItemGet(NewLine, Proceed, Item, LastItemNo, CurrQty, MultiplyWith, WeightInKgsFromScannedDatabar, REC, ErrorText);
        // if not Proceed then begin
        //     PosTransactionGui.ErrorBeep(ErrorText);
        exit;
        //end;

        if not REC."Sale Is Exchange Sale" and not REC."Sale Is Copied Transaction" then
            if REC."Retrieved from Receipt No." <> '' then begin
                IsHandled := false;
                //POSTransactionEvents.ItemLineOnCheckRetrievedFromReceipt(REC, NewLine, CurrInput, IsHandled, MultiplyWith);
                if IsHandled then
                    exit;
                LastItemNo := '';
                PosTransactionGui.ErrorBeep(NewItemsCannotRefundPreviousErr);
                exit;
            end;

        CheckVATSetups(REC, Item);

        IsHandled := false;
        // POSTransactionEvents.ItemLineOnAfterCheckVATSetups(Rec, Item, IsHandled);
        if IsHandled then
            exit;

        if FromInfocode <> '' then begin
            NewLine."Orig. from Infocode" := FromInfocode;
            NewLine."Orig. from Subcode" := FromSubcode;
            NewLine."Infocode Entry Line No." := FromEntryNo;
            NewLine."Infocode Selected Qty." := FromSelQty;
        end;

        IsHandled := false;
        //POSTransactionEvents.OnBeforeIsBlockSaleOnPOS(REC."Sale Is Return Sale", Item, MultiplyWith, FixedQty, IsHandled);
        if not IsHandled then begin
            // if BOUtils.IsBlockSaleOnPOS(Item."No.", '', NewLine."Variant Code", REC."Store No.", StoreSetup."Location Code", Today,
            //   ItemStatusLink) then begin
            //     LastItemNo := '';
            //     PosTransactionGui.ErrorBeep(StrSubstNo(IsBlockedErr, Item.TableCaption, Item.Description));
            //     exit;
            // end;
        end;
        if REC."Sale Is Return Sale" then begin
            // RetPolicyAction := PosFunc.FindReturnPolicy(NewLine, POSSESSION.MgrKey, Today, ReturnPolicy, MessageText, ErrorText);
            // if (RetPolicyAction > 0) then begin
            //     if (ErrorText <> '') then begin
            //         PosTransactionGui.ErrorBeep(ErrorText);
            //         exit;
            //     end;
            //     if (MessageText <> '') then begin
            //         if (RetPolicyAction = 2) then begin
            //             if not PosTransactionGui.PosConfirm(MessageText, true) then
            //                 exit;
            //         end
            //         else begin
            //             PosTransactionGui.PosMessage(MessageText);
            //         end;
            //     end;
            // end;
        end;

        IsHandled := false;
        // POSTransactionEvents.ItemLineOnAfterEvaluateSalesIsReturnSales(REC, Item, IsHandled);
        if IsHandled then
            exit;

        if NewLine."Quantity in Barcode" then
            QtyInBarcode := NewLine.Quantity;
        if NewLine."Price in Barcode" then
            PriceInBarcode := NewLine.Amount;

        ItemOrBarcode := CopyStr(CurrInput, 1, 20);
        if not Rec."Sale Is Exchange Sale" then
            if Item."LSC Keying in Quantity" = Item."LSC Keying in Quantity"::"Must not Key in Quantity" then begin
                if MultiplyWith <> 0 then
                    if not POSSESSION.PermissionItem('QTY', Item."No.", MultiplyWith, 0, InfoTextDescription, '', false) then begin
                        PosTransactionGui.ErrorBeep(InfoTextDescription);
                        exit;
                    end;

                if FixedQty <> 0 then
                    if not POSSESSION.PermissionItem('QTY', Item."No.", FixedQty, 0, InfoTextDescription, '', false) then begin
                        PosTransactionGui.ErrorBeep(InfoTextDescription);
                        exit;
                    end;
            end;

        ItemPhase := 0;

        if (NewLine."Variant Code" = '') then begin
            //tmpValue := PosFunc.FindVariant(PosVariant, Item."No.");
            //POSTransactionEvents.OnBeforeOpenVariantLookup(tmpValue, PosVariant, Item."No.");
            //if tmpValue > 0 then
            // if tmpValue = 1 then begin
            //     NewLine."Variant Code" := PosVariant.Code;
            //     if PosVariant.Description <> '' then
            //         NewLine.Description := CopyStr(PosVariant.Description + ' ' +
            //                                       PosVariant."Description 2", 1, MaxStrLen(NewLine.Description));

            //     Scanned := false;
            // end
            // else begin
            //     SetFunctionMode("LSC POS Command"::"VARIANT");
            //     PosTransactionGui.MessageBeep(StrSubstNo('%1: %2', FunctionSetup.Description, Item.Description));
            //     SetPosInfoText1(StrSubstNo('%1 %2', Item."No.", Item.Description));
            //     if PosFuncProfile."Automatic Variant Lookup" then begin
            //         LookUp(true, 'VARIANT', '');
            //         if CurrentClientType = CLIENTTYPE::Web then begin
            //             SetFunctionMode("LSC POS Command"::ITEM);
            //             exit;
            //         end;
            //     end;
            //     ClearPluCheckPriceAndVariant;
            //     exit;
            // end;
        end else begin
            if PosVariant.Get(Item."No.", NewLine."Variant Code") then
                NewLine.Description :=
                  CopyStr(
                    PosVariant.Description + ' ' + PosVariant."Description 2", 1, MaxStrLen(NewLine.Description));
        end;

        NewLine."Created by Staff ID" := POSSESSION.StaffID;

        if pluCheckPriceMode then begin
            ValidateInput;
            ClearPluCheckPriceAndVariant;
            exit;
        end;

        if (DealNo = '') and (ParentLineIn = 0) and (UOMSet = '') then begin
            if IsUOMPopUp(Item, AllExcluded) then begin
                UOMPopUp(NewLine);
                exit;
            end;
        end;
        if UOMSet <> '' then begin
            if not ItemUOM.Get(NewLine.Number, UOMSet) then begin
                LastItemNo := '';
                PosTransactionGui.ErrorBeep(StrSubstNo(UOMNotAvailableForItemErr, UOMSet, CurrInput));
                exit;
            end;
            NewLine."Unit of Measure" := UOMSet;
        end else begin
            if (Item."Sales Unit of Measure" <> '') and not ItemUOM.Get(Item."No.", Item."Sales Unit of Measure") then begin
                PosTransactionGui.ErrorBeep(StrSubstNo(UOMNotAvailableForItemErr, Item."Sales Unit of Measure", Item."No."));
                exit;
            end;
            if (NewLine."Unit of Measure" = Item."Sales Unit of Measure") and (Item."Sales Unit of Measure" = Item."Base Unit of Measure") then
                NewLine."Unit of Measure" := '';

            if REC."Customer Order" then
                if NewLine."Unit of Measure" = '' then
                    NewLine."Unit of Measure" := Item."Sales Unit of Measure";

            NewLine."Show Unit on POS" := Item."LSC Show Unit on POS";
        end;
        //POSTransactionEvents.OnAfterItemLine(REC, NewLine, CurrInput);
        //POSTransactionEventsPub.OnAfterItemLine2(LineRec, NewLine);

        //HospFunc.ChangedAfterBillPrinted(REC, BillIsPrinted, HospOrderTransStatus);

        NextItemPhase;

        if OverridePrice <> 0 then begin
            NewLine.Price := OverridePrice;
            NewLine."Price Change" := true;
            NewLine."Net Price" := Round(NewLine.Price / (1 + NewLine."VAT %" / 100), PosFuncProfile."Price Rounding to");
            KeyboardPrice := 0;
        end;
    end;

    procedure NextItemPhase()
    var
        ErrorText: Text[250];
        SuggestedQty: Decimal;
        SerialTracking: Boolean;
        LotTracking: Boolean;
        IsHandled: Boolean;
    begin
        if ItemPhase = -1 then begin
            InfoTextDescription := StrSubstNo('%1 - %2 %3 %4 - %5 %6 %7', Item."No.", Format(CurrQty), Item."Sales Unit of Measure", PosFuncProfile."Multiple Items Symbol",
              FormatAmount(KeyboardPrice), Item.Description, Currency.Code);
            InfoTextDescription2 := StrSubstNo('%1 %2 %3', AmountMsg, Format(KeyboardPrice * CurrQty), PosFuncProfile."POS Currency Symbol");
            //OposUtil.DisplayScaleLine('', Item.Description, CurrQty, KeyboardPrice, CurrQty * KeyboardPrice, Item."Sales Unit of Measure");
            ValidatePriceCheckPhase2(KeyboardPrice);
            exit;
        end;

        if (DealNo <> '') and (not LinkedItemsActive) then
            NewLine."Deal Line" := true;

        if ItemPhase = 0 then begin
            NewLine.Validate(Number, Item."No.");
            // POSTransactionEvents.OnAfterValidateItemNoInPhaseZero(REC, IsHandled);
            if IsHandled then
                exit;

            Item.CalcFields("LSC Options Exist");
            if Item."LSC Options Exist" then
                PreSetSerialLotNo := true;
            ItemPhase := ItemPhase + 1;
            if (Item."LSC Keying in Price" <> Item."LSC Keying in Price"::"Not Mandatory") and
               (Item."LSC Keying in Price" <> Item."LSC Keying in Price"::"Must not Key in Price") or
               ((NewLine.Price = 0) and PosFuncProfile."Must Key in Price if Zero" and not Item."LSC Zero Price Valid") then begin
                if not NewLine."Price in Barcode" then begin
                    AskForPrice;
                    exit;
                end;
            end;

            IsHandled := false;
            //POSTransactionEvents.OnAfterProcessItemPhaseZero(Item, IsHandled);
            if IsHandled then
                exit;
        end;

        if ItemPhase = 1 then begin
            ItemPhase := ItemPhase + 1;
            LineRec."Weight manually Entered" := false;

            if WeightInKgsFromScannedDatabar > 0 then begin
                NewLine."Unit of Measure" := FindItemUOMForKgOrLbs(Item."No.", Item.Description, 0, ErrorText);
                if ErrorText <> '' then begin
                    OposUtil.Beeper;
                    OposUtil.Beeper;
                    PosTransactionGui.PosConfirm(ErrorText, false);
                    CurrInput := '';
                    exit;
                end;
                NewLine.Validate("Unit of Measure", NewLine."Unit of Measure");
                NewLine.Quantity := WeightInKgsFromScannedDatabar;
                QtyInBarcode := WeightInKgsFromScannedDatabar;
                NewLine."Quantity in Barcode" := true;
                CurrQty := WeightInKgsFromScannedDatabar;
                NewLine.Validate(Number);
            end;
            if WeightInLbsFromScannedDatabar > 0 then begin
                NewLine."Unit of Measure" := FindItemUOMForKgOrLbs(Item."No.", Item.Description, 1, ErrorText);
                if ErrorText <> '' then begin
                    OposUtil.Beeper;
                    OposUtil.Beeper;
                    PosTransactionGui.PosConfirm(ErrorText, false);
                    CurrInput := '';
                    exit;
                end;
                NewLine.Validate("Unit of Measure", NewLine."Unit of Measure");
                NewLine.Quantity := WeightInLbsFromScannedDatabar;
                QtyInBarcode := WeightInLbsFromScannedDatabar;
                NewLine."Quantity in Barcode" := true;
                CurrQty := WeightInLbsFromScannedDatabar;
                NewLine.Validate(Number);
            end;

            if (Item."LSC Scale Item") and (WeightInKgsFromScannedDatabar = 0) and (WeightInLbsFromScannedDatabar = 0) then begin
                ItemPhase := ItemPhase + 1;
                // if LocalizationExt.IsNALocalizationEnabled then
                //     POSTransScale.SetReScaling(false);
                //POSTransactionEvents.OnBeforeEvaluateSaleIsReturnItemPhase1();

                if REC."Sale Is Return Sale" then begin
                    AskForQuantity;
                    LineRec."Weight manually Entered" := true;
                    LineRec."Unit of Measure" := Item."Sales Unit of Measure";
                end;// else
                    //POSTransScale.AskForWeight(Item);
                exit;
            end;
        end;

        if ItemPhase = 2 then begin
            ItemPhase := ItemPhase + 1;
            if not Rec."Sale Is Exchange Sale" then
                if (Item."LSC Keying in Quantity" = Item."LSC Keying in Quantity"::"Must Key in Quantity") and
                   (Abs(MultiplyWith) = 1) then begin
                    AskForQuantity;
                    exit;
                end;
            if Item."Item Tracking Code" = '' then begin
                // SuggestedQty := PosFunc.GetSuggestedQty(Item);
                //POSTransactionEvents.OnBeforeAskForSuggestedQtyItemPhase2v2(SuggestedQty, NewLine, MultiplyWith, Item);
                if SuggestedQty <> 0 then begin
                    AskForSuggestedQty(SuggestedQty);
                    exit;
                end;
            end;
        end;

        if ItemPhase = 3 then begin
            ItemPhase := ItemPhase + 1;
            SerialTracking := false;
            LotTracking := false;
            if (Item."Item Tracking Code" <> '') and ItemTrackingCode.Get(Item."Item Tracking Code") then begin
                if ItemTrackingCode."SN Specific Tracking" or ItemTrackingCode."SN Sales Outbound Tracking" then
                    SerialTracking := true;
                if ItemTrackingCode."Lot Specific Tracking" or ItemTrackingCode."Lot Sales Outbound Tracking" then
                    LotTracking := true;
            end;

            // POSTransactionEvents.OnBeforeSetTracking(REC, NewLine, ItemPhase, SerialTracking, LotTracking, SerialNo, LotNo, PreSetSerialLotNo);
            if (SerialTracking) and (SerialNo = '') and (not PreSetSerialLotNo) then begin
                if MultiplyWith > 1 then begin
                    PosTransactionGui.ErrorBeep(QtyOnlyOneWhenSerialNoErr);
                    exit;
                end;
                if NewLine."Serial No." <> '' then begin
                    // if not PosFunc.UpdateSerialLotInvLookup(NewLine, Item."Item Tracking Code", ErrorText) then
                    //     if not POSSESSION.MgrKey then begin
                    //         PosTransactionGui.ErrorBeep(ErrorText);
                    //         exit;
                    //     end;
                    // SerialNo := NewLine."Serial No.";
                    // InfoTextDescription := CopyStr(StrSubstNo('%1 %2', Item."No.", Item.Description), 1, MaxStrLen(InfoTextDescription));
                    // if not ValidateSerialNo(ErrorText) then begin
                    //     PosTransactionGui.ErrorBeep(ErrorText);
                    //     exit;
                    // end;
                end
                else begin
                    AskForSerialNo;
                    exit;
                end;
            end;
            if (LotTracking) and (LotNo = '') and (not PreSetSerialLotNo) then begin
                if NewLine."Lot No." <> '' then begin
                    // if not PosFunc.UpdateSerialLotInvLookup(NewLine, Item."Item Tracking Code", ErrorText) then
                    //     if not POSSESSION.MgrKey then begin
                    //         PosTransactionGui.ErrorBeep(ErrorText);
                    //         exit;
                    //     end;
                    // LotNo := NewLine."Lot No.";
                    // InfoTextDescription := CopyStr(StrSubstNo('%1 %2', Item."No.", Item.Description), 1, MaxStrLen(InfoTextDescription));
                    // if not ValidateLotNo(ErrorText) then begin
                    //     PosTransactionGui.ErrorBeep(ErrorText);
                    //     exit;
                    // end;
                end
                else begin
                    AskForLotNo;
                    exit;
                end;
            end;
            PreSetSerialLotNo := false;
        end;

        InsertItemLine;
    end;

    procedure InsertItemLine()
    var
        BomLines: Record "BOM Component";
        DealHeader: Record "LSC Offer";
        MealPlanMenu: Record "LSC Meal Plan Menu";
        POSTransPeriodicDisc: Record "LSC POS Trans. Per. Disc. Type";
        //  BOUtils: Codeunit "LSC BO Utils";
        PosPriceUtility: Codeunit "LSC POS Price Utility";
        UOMMgmt: Codeunit "Unit of Measure Management";
        TmpItemNo: Code[20];
        TmpLastItemNo: Code[20];
        TmpMultiplyWith: Decimal;
        ParentQty: Decimal;
        ScalePrice: Decimal;
        TmpNewLineNo: Integer;
        DisplayMultiply: Integer;
        LinkedItemLineNo: Integer;
        LinesFound: Boolean;
        IsScaleDisplayed: Boolean;
        CalcPriceNeeded: Boolean;
        CompressEntry: Boolean;
        IsHandled: Boolean;
        InvalidQtyErr: Label 'Quantity is not valid for this item';
    begin
        ///POSTransactionEvents.OnInitInsertItemLine(REC, NewLine, Customer, IsHandled);
        if IsHandled then
            exit;

        // if OposUtil.IsAnyDrawerOpen(TmpText) and ClientSessionUtility.OpenDrawerBlocksSale then begin
        //     ShowDrawerOpenWarning(TmpText);
        //     Sleep(1000);
        //     ScreenDisplay('');
        //     CurrInput := '';
        //     exit;
        // end;
        CalcPriceNeeded := false;
        // if BOUtils.IsHospitalityPermitted then begin
        //     if LineSalesType <> REC."Sales Type" then begin
        //         NewLine.Validate("Sales Type", LineSalesType);
        //         NewLine."Price Group Code" := LinePriceGroup;
        //         CalcPriceNeeded := true;
        //     end;

        //     if MealPlanMenu.Get(POSGUI.GetCurrMenu(0)) then begin
        //         if MealPlanMenu."Price Group Code" <> '' then
        //             if NewLine."Price Group Code" <> MealPlanMenu."Price Group Code" then begin
        //                 NewLine."Price Group Code" := MealPlanMenu."Price Group Code";
        //                 CalcPriceNeeded := true;
        //             end;
        //     end;
        //     if MealPlanMenuFromButton <> '' then begin
        //         if MealPlanMenu.Get(MealPlanMenuFromButton) then
        //             if NewLine."Price Group Code" <> MealPlanMenu."Price Group Code" then begin
        //                 NewLine."Price Group Code" := MealPlanMenu."Price Group Code";
        //                 CalcPriceNeeded := true;
        //             end;
        //     end;
        //    // POSTransactionEvents.OnAfterLineSalesTypeChange(REC, NewLine, LineSalesType, LinePriceGroup, CalcPriceNeeded);
        // end;

        if (NewLine."Unit of Measure" <> LineRec."Unit of Measure") and
          (NewLine."Scale Item") then begin
            NewLine."Unit of Measure" := LineRec."Unit of Measure";
            CalcPriceNeeded := true;
        end;

        // if CalcPriceNeeded then
        //     PosPriceUtility.CalcPrice(NewLine, true);

        MealPlanMenuFromButton := '';

        if (DealNo <> '') and (not LinkedItemsActive) then begin
            NewLine."Promotion No." := DealNo;
            NewLine."Disc. Info Line No." := FromLineNo;
            NewLine."Parent Line" := FromLineNo;
            NewLine."Deal Line" := true;
            NewLine."Deal Modifier Line No." := DealModifierLineNo;
            NewLine."Deal Line No." := DealLineNo;
            NewLine."Deal Added Amount" := DealAddedPrice;
            DealHeader.Get(DealNo);
            NewLine."View Line in Journal" := DealHeader."Show Deal Lines";
        end;

        StartItemNo := '';
        if NewLine."Quantity in Barcode" then
            CurrQty := QtyInBarcode * (MultiplyWith / ABS(MultiplyWith))
        else
            CurrQty := CurrQty * MultiplyWith;

        if not ValidateQuantity(CurrQty, NewLine) then begin
            PosTransactionGui.ErrorBeep(InvalidQtyErr);
            exit;
        end;
        MultiplyWith := CurrQty;

        if Item."LSC Qty. Becomes Negative" then begin
            NewLine."Item/Dept. Negative" := true;
            NewLine.Validate(Quantity, -CurrQty)
        end
        else
            NewLine.Validate(Quantity, CurrQty);

        NewLine.Validate(NewLine."Item Number Scanned", Scanned);
        if (KeyboardPrice <> 0) or ExternalZeroPrice then begin
            NewLine.Validate(NewLine.Price, KeyboardPrice);
            ExternalZeroPrice := false;
        end;

        if NewLine."Price in Barcode" then begin
            if Abs(MultiplyWith) = 1 then
                NewLine.Validate(NewLine.Amount, PriceInBarcode * MultiplyWith)
            else
                NewLine.Validate(NewLine.Amount, PriceInBarcode);
        end;
        //ScalePrice := POSTransScale.GetScalePrice();
        // if ScalePrice <> 0 then
        //     NewLine.SetAmountWithoutQuantityRecalc(ScalePrice);
        IsScaleDisplayed := ScaleDisplayed;
        NewLine."Weight manually Entered" := LineRec."Weight manually Entered";
        NewLine."Linked No. not Orig." := LinkedItemsActive;

        if PosFuncProfile."Sales Person Mode" <> PosFuncProfile."Sales Person Mode"::" " then
            NewLine."Sales Staff" := REC."Sales Staff";

        // if MultiplyWith < 0 then begin
        //     if ReturnRestrictions(MultiplyWith, NewLine, false, LinesFound) then begin
        //         if MultiplyWith < 0 then begin
        //             PosTransactionGui.ErrorBeep(NoCorrectedHigherThanSoldErr);
        //             SetFunctionMode("LSC POS Command"::ITEM);
        //             exit;
        //         end;
        //     end;
        // end;

        NewLine."Serial No." := SerialNo;
        NewLine."Lot No." := LotNo;
        // if (NewLine."Serial No." <> '') or (NewLine."Lot No." <> '') then
        //     if not IsDataBarWithLotNoAndExpDate then
        //         NewLine."Expiration Date" := PosFunc.GetSerialLotExpDate(NewLine, NewLine."Serial No.", NewLine."Lot No.");
        SerialNo := '';
        LotNo := '';

        NewLine."Orig. of a Linked Item List" := ProductExt.HasLinkedItems(Item, NewLine."Unit of Measure", GLobalSalesType);

        if LinkedItemsActive then
            NewLine."Parent Line" := ParentLine;

        CompressEntry := PosFuncProfile."Compress When Scanned";
        if Item."LSC Skip Compr. When Scanned" then begin
            NewLine."Journal Compression" := NewLine."Journal Compression"::"Not Allowed";
            if CompressEntry then
                CompressEntry := false;
        end;

        if RetailExt.IsAULocalizationEnabled() then
            PLBMgt.UpdatePLBItemInPOSLine(NewLine);

        // POSTransactionEvents.OnBeforeInsertItemLine(REC, NewLine, CurrInput, CompressEntry);

        NewLine.InsertLine;

        //HospFunc.CreateTransStatusAndKitchenStatusAfterItemInsert(REC, StoreSetup);

        // if (NewLine."System-Unchangable Offer") and (NewLine."Orig Per. Disc. Group" <> '') then begin
        //     PosPriceUtility.InsertTransDiscPerType(
        //       NewLine, true, POSTransPeriodicDisc."Periodic Disc. Type"::"Mix&Match",
        //       true, NewLine."Orig Per. Disc. Group");
        //     NewLine."Orig Per. Disc. Group" := '';
        // end;

        // if (NewLine."Guest/Seat No." <> 0) then
        //     if (NewLine."Line No." = NewLine."Parent Line") or (NewLine."Parent Line" = 0) then
        //         HospFunc.InsertOccupiedSeat(CurrTableNo, PosFuncProfile."Print Copy No. on Pre-Receipt", REC."Receipt No.", NewLine."Guest/Seat No.");

        // if HospFunc.InsertQueueCounterAfterTransLine(StoreSetup, REC, NewLine) then
        //     REC.Modify;

        if NewLine."Barcode No." <> '' then begin
            if Barcode.Get(NewLine."Barcode No.") then
                if Barcode."Discount %" <> 0 then begin
                    // PosPriceUtility.InsertTransDiscPercent(NewLine, Barcode."Discount %", POSTransPeriodicDisc.DiscType::Line, '');
                    NewLine.CalcPrices;
                end;
        end;

        if NewLine."Item Disc. Group" <> '' then
            NewLine.Validate(NewLine."Item Disc. Group");

        if OverridePrice <> 0 then begin
            NewLine.Price := OverridePrice;
            NewLine."Price Change" := true;
            NewLine."Net Price" := Round(NewLine.Price / (1 + NewLine."VAT %" / 100), PosFuncProfile."Price Rounding to");
            KeyboardPrice := 0;
        end;

        if CompressEntry or LinkedItemsActive then
            POSLINES.SetCurrentLine(NewLine)
        else begin
            LineRec.SetRange("Receipt No.", REC."Receipt No.");
            LineRec.FindLast;
            POSLINES.SetCurrentLine(LineRec);
        end;

        LineRec := NewLine;
        WriteMgrStatus;

        if PriceInBarcode <> 0 then
            LastItemNo := ''
        else
            LastItemNo := ItemOrBarcode;

        if LineRec."Scale Item" and LineRec."Weight manually Entered" then begin
            LineRec.Description := 'MAN ' + LineRec.Description;
        end;

        DisplayMultiply := 1;
        if REC."Sale Is Return Sale" then
            DisplayMultiply := -1;

        InfoTextDescription := '';
        if not LinkedItemsActive or PosTerminal."Display Linked Item" then begin
            // if LinkedItemsActive then begin
            //     InitDisplay();
            //     if ((Displaydevice.IsActive()) and (DisplayDevice."Delay for Linked items" > 0)) then begin
            //         Sleep(DisplayDevice."Delay for Linked items" * 1000);
            //     end;
            // end;
            // if LineRec."Scale Item" or LineRec."Price in Barcode" then begin
            //     if LineRec."Price in Barcode" or LineRec."Weight manually Entered" then begin
            //         LineRec."Unit of Measure" := Item."Sales Unit of Measure";
            //         OposUtil.DisplayScaleLine('', LineRec.Description, DisplayMultiply * LineRec.Quantity, LineRec.Price,
            //                                   DisplayMultiply * LineRec.Amount, LineRec."Unit of Measure");
            //     end;
            //     InfoTextDescription := PosFunc.FormatWeight(DisplayMultiply * LineRec.Quantity, LineRec."Unit of Measure") + ' x ';
            // end
            // else begin
            //     if not LineRec."Deal Line" then
            //         OposUtil.DisplaySalesLine(
            //           LineRec.Number, LineRec.Description, DisplayMultiply * LineRec.Quantity,
            //           LineRec.Price, DisplayMultiply * LineRec.Amount, Item."Sales Unit of Measure", CompressEntry);
            //     if (LineRec.Quantity <> 1) and (LineRec.Quantity <> 0) then
            //         InfoTextDescription := PosFunc.FormatQty(LineRec.Quantity) + ' x ';
            // end;
        end;

        InfoTextDescription := InfoTextDescription + LineRec.Number + ' ' + NewLine.Description;
        InfoTextDescription2 := '';

        if (LineRec.Number <> '') and (LineRec."Variant Code" <> '') then
            if PosVariant.Get(LineRec.Number, LineRec."Variant Code") then
                InfoTextDescription2 := PosVariant."Description 2";

        POSSESSION.UpdatePosPicture(LineRec);
        OverridePrice := 0;
        KeyboardPrice := 0;
        PriceInBarcode := 0;
        // POSTransScale.SetScalePrice(0);
        ScaleDisplayed := false;
        UOMSet := '';
        //POSTransactionEvents.OnAfterInsertItemLine(REC, LineRec, CurrInput);

        if ProductExt.HasLinkedItems(Item, LineRec."Unit of Measure", GLobalSalesType) then begin
            LinkedItemsActive := true;
            ParentLine := NewLine."Line No.";
            TmpLastItemNo := LastItemNo;
            TmpItemNo := Item."No.";
            TmpNewLineNo := NewLine."Line No.";
            TmpMultiplyWith := MultiplyWith;
            ParentQty := CurrQty;
            LinkedItemLineNo := 0;
            if not LinkedItemsNewLineTemp.IsEmpty() then begin
                LinkedItemsNewLineTemp.FindLast();
                LinkedItemLineNo := LinkedItemsNewLineTemp."Line No." + 1;
            end else
                LinkedItemLineNo := 1000000;
#pragma warning disable AL0432
            //POSCtrl.SetStackedLookup(true);
#pragma warning restore AL0432

            LinkedItems.SetCurrentKey("Item No.");
            LinkedItems.SetRange("Item No.", Item."No.");
            if (LineRec."Unit of Measure" = '') or
               ((LineRec."Unit of Measure" = Item."Sales Unit of Measure") and
                (Item."Sales Unit of Measure" = Item."Base Unit of Measure"))
            then
                LinkedItems.SetFilter("Unit of Measure", '%1|%2', '', Item."Sales Unit of Measure")
            else
                LinkedItems.SetRange("Unit of Measure", LineRec."Unit of Measure");
            LinkedItems.SetFilter("Sales Type", '%1|%2', '', GLobalSalesType);
            if LinkedItems.FindSet then
                repeat
                    CurrInput := LinkedItems."Linked Item No.";
                    MultiplyWith := LinkedItems."No. of Items" * ParentQty;
                    ItemLine(false, false, 0, 0, '', '', '', '', 0, 0);
                    if LinkedItemLineNo > 0 then begin
                        LinkedItemsNewLineTemp := NewLine;
                        LinkedItemsNewLineTemp."Line No." := LinkedItemLineNo;
                        LinkedItemsNewLineTemp.Insert();
                        LinkedItemLineNo += 1;
                    end;
                until LinkedItems.Next = 0;

            LastItemNo := TmpLastItemNo;
            Item.Get(TmpItemNo);
            NewLine.Get(NewLine."Receipt No.", TmpNewLineNo);
            LineRec.Get(LineRec."Receipt No.", TmpNewLineNo);
            LinkedItemsActive := false;
            MultiplyWith := TmpMultiplyWith;
        end;

        if (Item."LSC BOM Method" = Item."LSC BOM Method"::"Explode at Entry") and
           (Item."LSC BOM Type" <> Item."LSC BOM Type"::Prepack)
        then begin
            LinkedItemsActive := true;
            ParentLine := NewLine."Line No.";
            TmpLastItemNo := LastItemNo;
            TmpItemNo := Item."No.";
            TmpNewLineNo := NewLine."Line No.";
            TmpMultiplyWith := MultiplyWith;
            ParentQty := CurrQty * UOMMgmt.GetQtyPerUnitOfMeasure(Item, NewLine."Unit of Measure");
            BomLines.SetRange(BomLines."Parent Item No.", NewLine.Number);
            BomLines.SetRange(BomLines.Type, BomLines.Type::Item);
            if BomLines.FindSet then
                repeat
                    CurrInput := BomLines."No.";
                    MultiplyWith := BomLines."Quantity per" * ParentQty;
                    UOMSet := BomLines."Unit of Measure Code";
                    BomLineEntry := true;
                    ItemLine(false, false, 0, 0, BomLines."Variant Code", '', '', '', 0, 0);
                    NewLine.Get(NewLine."Receipt No.", NewLine."Line No.");
                    NewLine.Validate(Price, 0);
                    NewLine.Modify(true);
                until BomLines.Next() = 0;
            UOMSet := '';
            LastItemNo := TmpLastItemNo;
            LinkedItemsActive := false;
            BomLineEntry := false;
            MultiplyWith := TmpMultiplyWith;
            Item.Get(TmpItemNo);
            NewLine.Get(NewLine."Receipt No.", TmpNewLineNo);
            LineRec.Get(LineRec."Receipt No.", TmpNewLineNo);
        end;

        CalcTotals;
        // SetFunctionMode("LSC POS Command"::ITEM);
        CurrInput := '';
        MultiplyWith := 1;

        ValidateInfocode_WaitingForInput_Web := false;
        ValidateInfocode_InsertingItem := true;
        if not FromMobileQR then begin
            if not CheckInfoCode('ITEM') then
                if not REC."Sale Is Return Sale" and (NewLine.Quantity < 0) and (not Item."LSC Qty. Becomes Negative") then
                    CheckInfoCode('NEGSALE')
                else
                    if REC."Sale Is Return Sale" then
                        CheckInfoCode('NEGSALE');
        end;

        if ValidateInfocode_WaitingForInput_Web then
            exit
        else begin
            ValidateInfocode_InsertingItem := false;
            InsertItemLine2;
        end;
    end;

    local procedure InsertItemLine2()
    var
        //  KDSFunctions: Codeunit "LSC KDS Functions";
        ErrorText: Text[250];
        TmpText_l: Text;
    begin
        if CouponCode <> '' then
            CouponPressed;

        if CouponCodeNextItem <> '' then
            if ProcessCoupon(ErrorText, CouponCodeNextItem, LineRec) then begin
                if ErrorText <> '' then
                    PosTransactionGui.ErrorBeep(ErrorText);
            end;

        if (DealNo <> '') and (not LinkedItemsActive) then begin
            if FromMobileQR then begin
                if MobileDealLineNo <> 0 then
                    ProcessHospDataRecipe(NewLine.Number, NewLine, MobileGroupLineNo, MobileDealLineNo);
            end;

            InsertDealLines();
        end;

        InitDrawer();
        // if (DrawerDevice.IsActive() and DrawerDevice."Drawer Alert if Open") then
        //     if OposUtil.IsAnyDrawerOpen(TmpText_l) then begin
        //         ShowDrawerOpenWarning(TmpText_l);
        //         Sleep(1000);
        //         ScreenDisplay('');
        //     end;
        if not ((FunctionSetup."Function Code" = Format("LSC POS Command"::INFOCODE)) and (Info.Type = Info.Type::"Text Input") and (Info."Display Option" = Info."Display Option"::" ")) then begin
            if (not CheckDiscountOffers(NewLine) and not BomLineEntry) then
                CheckNextItemInQueue;
        end;

        // KDSFunctions.SendToKDSifOnItemAddedSet(NewLine, REC."Receipt No.", true);
    end;

    procedure ValidateVariant()
    var
        ItemStatusLink: Record "LSC Item Status Link";
        //BOUtils: Codeunit "LSC BO Utils";
        VariantDoesNotExistErr: Label 'Variant %1 does not exist for item %2';
        InvalidVariantErr: Label 'Invalid Variant';
    begin
        if StrLen(CurrInput) > 10 then begin
            PosTransactionGui.ErrorBeep(InvalidVariantErr);
            exit;
        end;

        if not LinkedItemsNewLineTemp.IsEmpty() then begin
            LinkedItemsNewLineTemp.FindLast();
            Item.Get(LinkedItemsNewLineTemp.Number);
            LinkedItemsNewLineTemp."Linked No. not Orig." := true;
            LinkedItemsNewLineTemp."Parent Line" := ParentLine;
            NewLine := LinkedItemsNewLineTemp;
            ItemPhase := 0;
            LinkedItemsNewLineTemp.Delete();
#pragma warning disable AL0432
            // POSCtrl.DecreaseStackedLookupIndex();
#pragma warning restore AL0432
        end;

        if not PosVariant.Get(Item."No.", CurrInput) then begin
            PosTransactionGui.ErrorBeep(StrSubstNo(VariantDoesNotExistErr, CurrInput, Item."No."));
            exit;
        end;

        // if BOUtils.IsBlockSaleOnPOS(Item."No.", '', PosVariant.Code, NewLine."Store No.", StoreSetup."Location Code", Today,
        //     ItemStatusLink) then begin
        //     PosTransactionGui.ErrorBeep(StrSubstNo(IsBlockedErr, Item.TableCaption, Item."No." + '/' + PosVariant.Code));
        //     exit;
        // end;

        NewLine."Variant Code" := PosVariant.Code;
        if PosVariant.Description <> '' then
            NewLine.Description := CopyStr(PosVariant.Description + ' ' +
                                           PosVariant."Description 2", 1, MaxStrLen(NewLine.Description));

        InfoTextDescription2 := PosVariant."Description 2";

        // POSTransactionEvents.OnAfterDescriptionValidateVariant(PosFuncProfile, NewLine, PosVariant);

        Scanned := false;
        NextItemPhase;

        //POSTransactionEvents.OnAfterValidateVariant(PosFuncProfile, Rec);
    end;

    procedure InsertPaymentLine()
    var
        EmptyCardEntry: Record "LSC POS Card Entry";
    begin
        InsertPaymentLine(-1, EmptyCardEntry);
    end;

    procedure InsertPaymentLine(UseLineNo: Integer; var CardEntry: Record "LSC POS Card Entry")
    var
        TenderTypeSetup: Record "LSC Tender Type Setup";
        EBTType: Text[20];
        lSkipCommit: Boolean;
        isHandled: Boolean;
    begin
        if gInsertTmpPayment then begin
            gInsertTmpPayment := false;
            lSkipCommit := true;
        end;

        //POSTransactionEvents.OnBeforeInsertPaymentLine(REC, NewLine, CurrInput, TenderType.Code, Balance, PaymentAmount, Format(STATE), isHandled);
        if isHandled then
            exit;

        if REC."New Transaction" then
            SalePressed(false);

        if (BarcodeMask.Type = BarcodeMask.Type::Customer) or (BarcodeMask.Type = BarcodeMask.Type::"Member Card") then
            if (PaymentAmount = 0) and (CustomerOrCardNo = CurrInput) then
                exit;

        //POSTransactionEvents.OnBeforeAssignPaymentLine(TenderType, NewLine, REC, StoreSetup, MultiplyWith, LineRec, InfoTextDescription, InfoTextDescription2);

        TenderTypeSetup.Get(TenderType.Code);
        NewLine."Entry Type" := NewLine."Entry Type"::Payment;
        NewLine."Bank Transfer" := TenderTypeSetup."Bank Transfer";
        NewLine.Quantity := MultiplyWith;
        if NewLine.Quantity = 0 then
            NewLine.Quantity := 1;
        NewLine.Validate(Number, TenderType.Code);

        ishandled := false;
        // POSTransactionEvents.InsertPaymentLineOnBeforeSetAmountsMultiplyInTenderOperations(TenderType, NewLine, PosFuncProfile, PaymentAmount, isHandled);
        if not isHandled then begin
            if TenderType."Multiply in Tender Operations" then begin
                NewLine.Validate(Price, PaymentAmount);
                NewLine.Validate(Quantity);
                NewLine.CalcPrices
            end else
                NewLine.Validate(Amount, PaymentAmount);
        end;

        if TenderType."Foreign Currency" and (Currency.Code <> '') then begin
            NewLine."Currency Code" := Currency.Code;
            NewLine."Amount In Currency" := AmountInCurrency;
            NewLine.Description := Currency.Code + ' '
             + PosFunc.FormatCurrency(NewLine."Amount In Currency", Currency.Code);
        end;

        if STATE <> "LSC POS Transaction State"::TENDOP then begin
            NewLine."Card/Customer/Coup.Item No" := CustomerOrCardNo;
            if TenderType."Card/Account No." then
                if TenderType."Function" = TenderType."Function"::Customer then
                    NewLine."Card/Customer/Coup.Item No" := REC."Customer No."
                else
                    if (TenderType."Function" = TenderType."Function"::Card) and (CardEntry."Entry No." <> 0) then begin
                        isHandled := false;
                        POSTransactionEvents.OnBeforeAssignTenderCardTypeDescription(NewLine, CardEntry, isHandled);
                        if not isHandled then
                            if TenderCardType.Get(NewLine."Store No.", NewLine.Number, NewLine."Card Type") then
                                NewLine.Description := TenderCardType.Description;
                    end;
        end;

        NewLine."Created by Staff ID" := POSSESSION.StaffID;

        if LocalizationExt.IsAULocalizationEnabled() then
            if CDCCardPayment(CardEntry) then
                NewLine.CDCPayment := true;

        isHandled := false;
        // POSTransactionEvents.OnBeforeInsertLineInsertPaymentLine(REC, NewLine, CurrInput, TenderType.Code, Balance, PaymentAmount, Format(STATE), IsHandled);
        if isHandled then
            exit;

        NewLine.InsertLine(UseLineNo);

        if IsLimitation then begin
            EBTType := GetTenderType();
            if EBTType = EBTText then
                NewLine.Limitation := true;
            if EBTType = EBTCashText then
                NewLine.EBTCash := true;
            NewLine.Modify();
            LimitationMgt.LimitationProcess(REC."Receipt No.", CurrentPaymentAmount, NewLine);
            CalcTotals();
        end;

        // POSTransactionEvents.OnAfterInsertPaymentLine(REC, NewLine, CurrInput, TenderType.Code, lSkipCommit);

        if not lSkipCommit then
            CommitPaymentLine;
    end;

    procedure InsertPreauthInfoLine(var pCardEntry: Record "LSC POS Card Entry")
    var
        ParentCardEntry: Record "LSC POS Card Entry";
    begin
        if REC."New Transaction" then
            SalePressed(false);

        if ParentCardEntry.Get(pCardEntry."PreAuth Entry Store", pCardEntry."PreAuth Entry Terminal", pCardEntry."PreAuth Entry No.") then;

        if pCardEntry."Transaction Type" in [pCardEntry."Transaction Type"::PreAuth, pCardEntry."Transaction Type"::AddCardToFile] then begin
            InitNewLine;
            NewLine."Entry Type" := NewLine."Entry Type"::FreeText;
            if pCardEntry."Transaction Type" = pCardEntry."Transaction Type"::PreAuth then
                NewLine."Text Type" := NewLine."Text Type"::"Pre-Auth Text"
            else
                NewLine."Text Type" := NewLine."Text Type"::"Card On File Text";
            NewLine.Quantity := 1;
        end
        else
            NewLine.Get(REC."Receipt No.", ParentCardEntry."Line No.");

        NewLine.Number := FORMAT(pCardEntry."Transaction Type");
        NewLine.Validate(Amount, PaymentAmount);
        NewLine."Created by Staff ID" := POSSESSION.StaffID;

        if pCardEntry."Transaction Type" in [pCardEntry."Transaction Type"::PreAuth, pCardEntry."Transaction Type"::AddCardToFile] then
            NewLine.InsertLine()
        else
            NewLine.Modify();
    end;

    procedure TransactionTendered()
    var
        SalesTypes: Record "LSC Sales Type";
        POSTransLine: Record "LSC POS Trans. Line";
        COLineTemp: Record "LSC Customer Order Line" temporary;
        //COPOSFunctions: Codeunit "LSC CO POS Functions";
        // COUpdatePaymentUtils: Codeunit LSCCOUpdatePaymentUtils;
        // POSExchangerateconversion: Codeunit "LSC POS Exch. rate conversion";
        // COUtility: Codeunit "LSC CO Utility";
        POSPrintUtility: Codeunit "LSC POS Print Utility";
        //COSession: Codeunit "LSC Customer Order Session";
        ErrorText: Text;
        ResponseCode: Code[30];
        ReceiptNo: Code[20];
        CustomerOrderID: Code[20];
        TmpAmount: Decimal;
        ChangeAmount: Decimal;
        WebPreAuthNotAuthorized: Boolean;
        RoundedValue: Boolean;
        NoExchangeAddedToCO: Boolean;
        PrintCoSlip: Boolean;
        TenderChangeMsg: Label 'Tender change !';
        IsHandled: Boolean;
    begin
        //         CalcTotals;
        //         COAmountToDeductFromTot := 0;
        //         if (Rec."Gross Amount" <> GrossAmountBeforeCreatingCO) or CustomerOrderSession.IsCustomerOrderEdit() then
        //             if (not CollectingOrder) and (REC."Customer Order") then
        //                 COUtility.RecalculateOrderLines(REC, CustomerOrderLine_Temp, CustomerOrderDiscountLine_Temp, CustomerOrderHeader_Temp);

        //         if (REC."Rounding Amount" <> 0) and REC."Customer Order" then
        //             RoundedValue := (REC."Gross Amount" + REC."Rounding Amount" = REC.Payment) or (REC."Gross Amount" + REC."Rounding Amount" = abs(REC."Income/Exp. Amount"));

        //         POSTransactionEvents.OnBeforeTransactionTendered(REC, TenderType, VoidInProcess, Balance, TmpAmount, RoundedValue);

        //         if not VoidInProcess then begin
        //             Commit;
        //             CustomerOrderLine_Temp.SetRange("Line No.");
        //             if REC."Customer Order" and PrepayCustomerOrder then begin
        //                 CustomerOrderLine_Temp.CalcSums(Amount, "Prepayment Amount");
        //                 CustomerOrderPayment_Temp.CalcSums("Finalized Amount LCY", "Pre Approved Amount LCY");
        //                 COAmountToDeductFromTot := CustomerOrderLine_Temp.Amount - PaymentAmount - CustomerOrderPayment_Temp."Finalized Amount LCY" - CustomerOrderPayment_Temp."Pre Approved Amount LCY";
        //             end;

        //             POSTransactionEvents.OnTransactionTenderedAfterInitAmounts(REC, TenderType, PaymentAmount, ChangeTender, IsHandled);
        //             if IsHandled then
        //                 exit;

        //             if (PaymentCount >= 1) then begin
        //                 PaymentCount := 0;
        //                 exit
        //             end else
        //                 if (Balance = 0) or CustomerOrderPayment(POSTransLine, NoExchangeAddedToCO) or (RoundedValue) then begin
        //                     if SalesTypes.Get(REC."Sales Type") then
        //                         if SalesTypes."Payment is Prepayment" then
        //                             exit;
        //                     Member.OnBeforeTender(REC, TenderType);
        //                     if CheckInfoCode('END') then
        //                         exit;
        //                     PaymentCount := PaymentCount + 1;
        //                     if VendorSourcing then
        //                         if not COSession.IsCOLineCompressed() then
        //                             if CustomerOrderLine_Temp.FindSet then
        //                                 repeat
        //                                     CustomerOrderLine_Temp."Vendor Sourcing" := true;
        // #pragma warning disable AL0432
        //                                     CustomerOrderLine_Temp.Status := CustomerOrderLine_Temp.Status::"To Pick";
        // #pragma warning restore AL0432
        //                                     CustomerOrderLine_Temp.Modify;
        //                                 until CustomerOrderLine_Temp.Next = 0;

        //                     if not CollectingOrder then begin
        //                         if PaymentAmount <> 0 then begin
        //                             ChangeAmount := COPOSFunctions.AddPaymentToCustomerOrder(CustomerOrderHeader_Temp, CustomerOrderLine_Temp, CustomerOrderPayment_Temp, REC, CustomerOrderHeader_Temp."Document ID", COTotalAmount, PrepayCustomerOrder, CORemainingAmount, AddExtraPaymentToCO, false, false, NoExchangeAddedToCO);
        //                             if not CustomerOrderSession.IsCustomerOrderEdit() then
        //                                 if (ChangeAmount <> 0) and not NoExchangeAddedToCO then begin
        //                                     if (TenderType."Change Tend. Code" <> '') and ((-ChangeAmount <= TenderType."Min. Change") or (TenderType."Min. Change" = 0)) then begin
        //                                         if TenderType.Code <> TenderType."Change Tend. Code" then
        //                                             TenderType.Get(StoreSetup."No.", TenderType."Change Tend. Code");
        //                                     end else
        //                                         if ((TenderType."Above Min. Change Tender Type" <> '') and (-ChangeAmount > TenderType."Min. Change")) then
        //                                             if TenderType.Code <> TenderType."Above Min. Change Tender Type" then
        //                                                 TenderType.Get(StoreSetup."No.", TenderType."Above Min. Change Tender Type");

        //                                     PaymentAmount := ChangeAmount;
        //                                     ChangeTender := true;
        //                                     InitNewLine;
        //                                     InsertPaymentLine;
        //                                 end;
        //                         end;
        //                         PrintCoSlip := COPOSFunctions.FinalizePaymentForCustomerOrder(CustomerOrderHeader_Temp, CustomerOrderLine_Temp, CustomerOrderPayment_Temp, REC, CustomerOrderDiscountLine_Temp);
        //                         if AddExtraPaymentToCO = AddExtraPaymentToCO::DoAdd then begin
        //                             COUpdatePaymentUtils.SetPosFunctionalityProfile(PosFuncProfile."Profile ID");
        //                             COUpdatePaymentUtils.SendRequest(CustomerOrderPayment_Temp, COLineTemp, WebPreAuthNotAuthorized, ResponseCode, ErrorText);
        //                             COUpdatePaymentUtils.SetCommunicationError(ResponseCode, ErrorText);
        //                             if ErrorText <> '' then
        //                                 Error(ErrorText);
        //                         end;
        //                     end else begin
        //                         if REC."Customer Order" then begin
        //                             ChangeAmount := COPOSFunctions.AddPaymentToCustomerOrder(CustomerOrderHeader_Temp, CustomerOrderLine_Temp, CustomerOrderPayment_Temp, REC, CustomerOrderHeader_Temp."Document ID", COTotalAmount, PrepayCustomerOrder, 0, AddExtraPaymentToCO::DoNotAdd, true, NotIncludeWebPreAuth, NoExchangeAddedToCO);
        //                             COUpdatePaymentUtils.SetPosFunctionalityProfile(PosFuncProfile."Profile ID");
        //                             COUpdatePaymentUtils.SendRequest(CustomerOrderPayment_Temp, CustomerOrderLine_Temp, WebPreAuthNotAuthorized, ResponseCode, ErrorText);
        //                             COUpdatePaymentUtils.SetCommunicationError(ResponseCode, ErrorText);
        //                             if ErrorText <> '' then
        //                                 Error(ErrorText);
        //                             if CustomerOrderHeader_Temp.CancelledOrder then
        //                                 if not COUtility.CancelExcistingCustomerOrder(CustomerOrderHeader_TEMP, CustomerOrderLine_TEMP, CustomerOrderPayment_TEMP, CustomerOrderDiscountLine_Temp, ErrorText) then
        //                                     Error(ErrorText)
        //                                 else begin
        //                                     Clear(CustomerOrderHeader_Temp);
        //                                     CustomerOrderHeader_Temp.DeleteAll();
        //                                 end;
        //                         end;
        //                     end;

        //                     if not WebPreAuthNotAuthorized then begin
        //                         POSTransLine.Reset;
        //                         POSTransLine.SetRange("Receipt No.", REC."Receipt No.");
        //                         POSTransLine.SetRange("Entry Type", POSTransLine."Entry Type"::Payment);
        //                         POSTransLine.SetFilter(Amount, '<=0');
        //                         POSTransLine.SetRange("CO Exchange Line", false);
        //                         if POSTransLine.FindLast then
        //                             if REC."Transaction Type" <> REC."Transaction Type"::Payment then
        //                                 Remaining := POSTransLine.Amount;
        //                         if (not PrepayCustomerOrder and REC."Customer Order") then
        //                             Remaining := ChangeAmount;

        //                         CustomerOrderLine_Temp.CalcSums("Prepayment Amount");
        //                         CollectingOrder := false;
        //                         VendorSourcing := false;
        //                         ReceiptNo := REC."Receipt No.";
        //                         CustomerOrderID := REC."Customer Order ID";
        //                         COEdit := CustomerOrderSession.IsCustomerOrderEdit();
        //                         PostTransaction(true);
        //                         CustomerOrderPayment_Temp.DeleteAll;
        //                         PaymentCount := 0;
        //                         NotIncludeWebPreAuth := false;
        //                         if PrintCoSlip then begin
        //                             REC.CalcFields("Gross Amount", "Income/Exp. Amount", Payment);
        //                             POSPrintUtility.Init();
        //                             POSPrintUtility.PrintCOSlip(CustomerOrderID, ReceiptNo);
        //                         end;
        //                         PrintCoSlip := false;
        //                         exit
        //                     end else begin
        //                         WebPreAuthNotAuthorizedFunc(false);
        //                         if PrintCoSlip then begin
        //                             ReceiptNo := REC."Receipt No.";
        //                             CustomerOrderID := REC."Customer Order ID";
        //                             REC.CalcFields("Gross Amount", "Income/Exp. Amount", Payment);
        //                             POSPrintUtility.Init();
        //                             POSPrintUtility.PrintCOSlip(CustomerOrderID, ReceiptNo);
        //                         end;
        //                         PrintCoSlip := false;
        //                         exit;
        //                     end;
        //                 end;

        //             if LastCurrencyCode <> '' then
        //                 Currency.Get(LastCurrencyCode);
        //             PaymentAmount := PosFunc.RoundTender(TenderType, Balance);
        //             if (PaymentAmount = 0) then begin
        //                 RemainingFCY := 0;
        //                 if CheckInfoCode('END') then
        //                     exit;
        //                 PostTransaction(true);
        //                 PaymentCount := 0;
        //                 exit;
        //             end;
        //             if (TenderType."Change Tend. Code" <> '') and (RealBalance < 0) then begin
        //                 if (LastCurrencyCode <> '') and
        //                     ((TenderType."Above Min. Change Tender Type" = TenderType.Code) or
        //                     (TenderType."Change Tend. Code" = TenderType.Code))
        //                 then begin
        //                     if Currency."LSC Lowest Accept. Denom. Amt." = 0 then
        //                         Currency."LSC Lowest Accept. Denom. Amt." := 0.01;
        //                     TmpAmount := POSExchangerateconversion.POSExchangeLCYToFCY(REC."Trans. Date", Currency.Code, Balance) / REC."Currency Factor";
        //                     if Currency."Amount Rounding Precision" <> 0 then
        //                         TmpAmount := Round(TmpAmount, Currency."Amount Rounding Precision");
        //                     if (Currency."LSC Lowest Accept. Denom. Amt." < -TmpAmount) or
        //                         (TenderType."Change Tend. Code" = TenderType.Code) then begin
        //                         AmountInCurrency := Round(TmpAmount, Currency."LSC Lowest Accept. Denom. Amt.");
        //                         PaymentAmount := Round(POSExchangerateconversion.POSExchangeFCYToLCY(REC."Trans. Date", Currency.Code, AmountInCurrency)
        //                                                   * REC."Currency Factor", Currency."Amount Rounding Precision");
        //                         RemainingFCY := AmountInCurrency;
        //                     end
        //                     else begin
        //                         Clear(Currency);
        //                         TenderType.Get(StoreSetup."No.", TenderType."Change Tend. Code");
        //                         AmountInCurrency := 0;
        //                         PaymentAmount := PosFunc.RoundTender(TenderType, Balance);
        //                         Remaining := PaymentAmount;
        //                     end;
        //                 end
        //                 else begin
        //                     if not (REC."Sale Is Return Sale") or (REC."Sale Is Return Sale" and (TmpAmount < 0)) then begin
        //                         if (TenderType."Change Tend. Code" <> '') and
        //                             ((-RealBalance <= TenderType."Min. Change") or (TenderType."Min. Change" = 0))
        //                         then
        //                             TenderType.Get(StoreSetup."No.", TenderType."Change Tend. Code")
        //                         else
        //                             if TenderType."Above Min. Change Tender Type" <> '' then
        //                                 TenderType.Get(StoreSetup."No.", TenderType."Above Min. Change Tender Type")
        //                             else
        //                                 Clear(TenderType);

        //                         if TenderType.Code <> '' then begin
        //                             KeyboardAmount := false;
        //                             PaymentAmount := PosFunc.RoundTender(TenderType, Balance);
        //                             if TenderType."Rounding To" <> 0 then begin
        //                                 TmpAmount :=
        //                                   PosFunc.RoundTender(TenderType, REC."Gross Amount" + REC."Income/Exp. Amount" + REC."Service Charge") - REC.Payment;
        //                             end;
        //                             Remaining := PaymentAmount;
        //                         end;
        //                     end else
        //                         Clear(TenderType);
        //                 end;

        //                 if TenderType.Code <> '' then begin
        //                     if (PaymentAmount = 0) then begin
        //                         if CheckInfoCode('END') then
        //                             exit;
        //                         PostTransaction(true);
        //                         exit;
        //                     end;

        //                     ChangeTender := true;
        //                     InitNewLine;
        //                     InsertPaymentLine;
        //                     PaymentCount := 0;
        //                     exit;
        //                 end;
        //             end else
        //                 if (TenderType.Code <> '') and (RealBalance >= 0) and ((RealBalance < TenderType."Rounding To") or (RealBalance < Currency."LSC Lowest Accept. Denom. Amt.")) then begin
        //                     PaymentAmount := 0;
        //                     RemainingFCY := 0;
        //                     if CheckInfoCode('END') then
        //                         exit;
        //                     PostTransaction(true);
        //                     PaymentCount := 0;
        //                     exit;
        //                 end;
        //         end;

        //         SetFunctionMode("LSC POS Command"::PAYMENT);
        //         if RealBalance < 0 then begin
        //             if InfoTextDescription <> '' then
        //                 InfoTextDescription2 := TenderChangeMsg
        //             else
        //                 InfoTextDescription := TenderChangeMsg;
        //             PosTransactionGui.MessageBeep('');
        //         end;
        //         PaymentCount := 0;
        //         //POSTransactionEvents.OnAfterTransactionTendered(RealBalance, InfoTextDescription2);
    end;

    local procedure CustomerOrderPayment(POSTransLine: Record "LSC POS Trans. Line"; var NoExchangeAddedToCO: Boolean): Boolean
    var
        NonCustomerOrderAmount, AllreadyPaid : Decimal;
        IsHandled, ReturnValue : Boolean;
    begin
        // POSTransactionEvents.OnBeforeCustomerOrderPayment(REC, POSTransLine, CustomerOrderLine_Temp, AddExtraPaymentToCO, CollectingOrder, VendorSourcing, PrepayCustomerOrder, InfoTextDescription, InfoTextDescription2, CORemainingAmount, ReturnValue, IsHandled);
        if IsHandled then
            exit(ReturnValue);

        if not REC."Customer Order" then
            exit(false);

        AllreadyPaid := 0;
        NonCustomerOrderAmount := 0;

        POSTransLine.Reset;
        POSTransLine.SetRange("Receipt No.", REC."Receipt No.");
        POSTransLine.SetRange("Entry Type", POSTransLine."Entry Type"::Payment);
        POSTransLine.SetFilter(POSTransLine."Entry Status", '<>%1', POSTransLine."Entry Status"::Voided);
        if POSTransLine.FindSet then
            repeat
                AllreadyPaid := AllreadyPaid + POSTransLine.Amount;
            until POSTransLine.Next = 0;

        // Due to Customer Order EDIT: calculate prepaid amount in earlier transaction.
        // if CustomerOrderSession.IsCustomerOrderEdit() then begin
        //     POSTransLine.Reset();
        //     POSTransLine.SetRange("Receipt No.", REC."Receipt No.");
        //     POSTransLine.SetRange("Entry Type", POSTransLine."Entry Type"::IncomeExpense);
        //     POSTransLine.SetFilter(POSTransLine."Entry Status", '<>%1', POSTransLine."Entry Status"::Voided);
        //     POSTransLine.SetRange("Customer Order Line", true);
        //     POSTransLine.SetRange("CO Prepayment Line", true);
        //     POSTransLine.CalcSums(Amount);
        //     AllreadyPaid += -POSTransLine.Amount;
        // end;

        POSTransLine.Reset;
        POSTransLine.SetRange("Receipt No.", REC."Receipt No.");
        POSTransLine.SetFilter("Entry Type", '%1|%2', POSTransLine."Entry Type"::Item, POSTransLine."Entry Type"::IncomeExpense);
        POSTransLine.SetFilter("Entry Status", '<>%1', POSTransLine."Entry Status"::Voided);
        POSTransLine.SetFilter(Quantity, '>%1', 0);
        if CollectingOrder then
            POSTransLine.setrange("Customer order line", false)
        else
            POSTransLine.SetRange(Marked, false);
        if POSTransLine.FindSet then
            repeat
                NonCustomerOrderAmount := NonCustomerOrderAmount + POSTransLine.Amount;
            until POSTransLine.Next = 0;

        if NonCustomerOrderAmount < 0 then
            NonCustomerOrderAmount := 0;

        //If user has chosen not to pay customer order. Check for exchange line in customer order.
        if TotalExchangeAmountToCO > 0 then begin //Only payment to customer order is of type Exchange line and is agreed by user 
            PaymentAmount := TotalExchangeAmountToCO;
            TotalExchangeAmount := 0;
            TotalExchangeAmountToCO := 0;
            exit(true);
        end else
            if TotalExchangeAmount > 0 then begin //No payment added to customer order and no Exchange amount added either. Add change back
                NoExchangeAddedToCO := true;
                TotalExchangeAmount := 0;
                exit(true);
            end;

        //Check to see if Non Customer Amount and Prepayment Amount has been paid and asks if you want to get changeback or add extra amount to the Customer Order as prepayment
        CustomerOrderLine_Temp.Reset();
        CustomerOrderLine_Temp.Calcsums("Prepayment Amount");
        AddExtraPaymentToCO := AddExtraPaymentToCO::NotAsked; //Will change depending on if user is asked and confirms No/Yes
        if ((CustomerOrderLine_Temp."Prepayment Amount" + NonCustomerOrderAmount) <= AllreadyPaid) and VendorSourcing then begin
            //checks if payment is over not equal to and if a item that needs to be prepaid a 100% and skips the PosConfirm
            if (((CustomerOrderLine_Temp."Prepayment Amount" + NonCustomerOrderAmount) < AllreadyPaid) and not (CustomerOrderLine_Temp."Prepayment Amount" + NonCustomerOrderAmount = REC."Gross Amount")) then
                CheckIfUserWantsToAddExtraPaymentToCO(NonCustomerOrderAmount, AllreadyPaid);
            exit(true);
        end;

        if (CustomerOrderLine_Temp."Prepayment Amount" > 0) and PrepayCustomerOrder then begin
            InfoTextDescription := StrSubstNo(PrePaymDueMsg, CustomerOrderLine_Temp."Prepayment Amount" + NonCustomerOrderAmount - AllreadyPaid);
            InfoTextDescription2 := '';
        end;

        if (not PrepayCustomerOrder and (NonCustomerOrderAmount <= AllreadyPaid) and (not CollectingOrder)) then begin
            if ((NonCustomerOrderAmount < AllreadyPaid) and (NonCustomerOrderAmount <> 0)) then
                CheckIfUserWantsToAddExtraPaymentToCO(NonCustomerOrderAmount, AllreadyPaid);
            exit(true);
        end;

        if prepaycustomerorder and (REC."Gross Amount" < AllreadyPaid) then
            exit(true);

        exit(false);
    end;

    procedure CheckIfUserWantsToAddExtraPaymentToCO(NonCustomerOrderAmount: Decimal; AllreadyPaid: Decimal)
    var
        POSTransLine: Record "LSC POS Trans. Line";
        CurrentIncExpAmount: Decimal;
        RemainingAmount: Decimal;
        RemainingAmountPlusNonCOAmount: Decimal;
        CustomerOrderDepositAmount: Decimal;
        AddToCustomerOrder: Label 'The payment amount is %1 more than the required deposit amount, do you want to add the Amount of %1 to the Customer Order?';
    begin
        if REC."Customer Order ID" <> '' then
            RemainingAmount := CheckForCODepositRemainingAmount()
        else begin
            //Customer Order has not been created. No payment has been added
            RemainingAmount := 0;
            CORemainingAmount := REC."Gross Amount" - NonCustomerOrderAmount;
        end;

        POSTransLine.SetRange("Receipt No.", REC."Receipt No.");
        POSTransLine.SetRange("Entry Type", POSTransLine."Entry Type"::IncomeExpense);
        POSTransLine.SetFilter("Entry Status", '<>%1', POSTransLine."Entry Status"::Voided);
        POSTransLine.SetRange("CO Prepayment Line", false);
        if not POSTransLine.IsEmpty() then begin
            POSTransLine.CalcSums(Amount);
            CurrentIncExpAmount := POSTransLine.Amount;
            CORemainingAmount := CORemainingAmount + CurrentIncExpAmount;
        end;

        RemainingAmountPlusNonCOAmount := RemainingAmount + REC."Gross Amount" + CurrentIncExpAmount;
        CustomerOrderDepositAmount := NonCustomerOrderAmount - REC."Gross Amount" - CurrentIncExpAmount;
        if RemainingAmount > CustomerOrderDepositAmount then begin
            if (AllreadyPaid > RemainingAmountPlusNonCOAmount) then
                PrepayCustomerOrder := PosTransactionGui.PosConfirm(StrSubstNo(AddToCustomerOrder, (RemainingAmountPlusNonCOAmount - (NonCustomerOrderAmount + CustomerOrderLine_Temp."Prepayment Amount"))), false)
            else
                PrepayCustomerOrder := PosTransactionGui.PosConfirm(StrSubstNo(AddToCustomerOrder, (AllreadyPaid - (NonCustomerOrderAmount + CustomerOrderLine_Temp."Prepayment Amount"))), false);

            if PrepayCustomerOrder then
                AddExtraPaymentToCO := AddExtraPaymentToCO::DoAdd
            else
                AddExtraPaymentToCO := AddExtraPaymentToCO::DoNotAdd;
        end;
    end;

    procedure CheckForCODepositRemainingAmount(): Decimal
    var
        CustomerOrderHeaderTemp: Record "LSC Customer Order Header" temporary;
        CustomerOrderLineTemp: Record "LSC Customer Order Line" temporary;
        CustomerOrderDiscountLineTemp: Record "LSC CO Discount Line" temporary;
        CustomerOrderPaymentTemp: Record "LSC Customer Order Payment" temporary;
        ErrorText: Text;
    begin
        PosFunc.GetCustomerOrder('LOOKUP', REC."Customer Order ID", CustomerOrderHeaderTemp, CustomerOrderLineTemp, CustomerOrderDiscountLineTemp, CustomerOrderPaymentTemp, ErrorText);
        if ErrorText <> '' then
            PosTransactionGui.ErrorBeep(ErrorText)
        else begin
            CustomerOrderLineTemp.Reset;
            CustomerOrderLineTemp.FindSet;
            CORemainingAmount := 0;
            CustomerOrderLineTemp.CalcSums(Amount);
            CORemainingAmount := CustomerOrderLineTemp.Amount;
            CustomerOrderPaymentTemp.SetRange(Type, CustomerOrderPaymentTemp.Type::Payment);
            if CustomerOrderPaymentTemp.FindSet then
                repeat
                    CORemainingAmount := CORemainingAmount - CustomerOrderPaymentTemp."Pre Approved Amount LCY";
                until CustomerOrderPaymentTemp.Next = 0;
        end;
        exit(CORemainingAmount);
    end;

    procedure CardOnFilePressed(TenderTypeCode: Code[10])
    begin
        POSTransactionEvents.OnAfterCardOnFilePressed(REC, LineRec, CurrInput, TenderTypeCode);
        UsePaymentToken := true;
        TenderKeyPressed(TenderTypeCode);
        UsePaymentToken := false;
        POSTransactionEvents.OnAfterCardOnFileExecuted(Rec, LineRec, CurrInput, TenderTypeCode);
    end;

    procedure TenderKeyPressed(TenderTypeCode: Code[10])
    begin
        // POSTransactionEvents.OnAfterTenderKeyPressed(REC, LineRec, CurrInput, TenderTypeCode);
        TenderKeyPressedEx(TenderTypeCode, '');
        //POSTransactionEvents.OnAfterTenderKeyExecuted(REC, LineRec, CurrInput, TenderTypeCode);
    end;

    procedure TenderKeyPressedEx(TenderTypeCode: Code[10]; TenderAmountText: Text)
    var
        lTmp: Record "LSC Report Temp Table" temporary;
        PosTrLine, POSTransLine : Record "LSC POS Trans. Line";
        ShippingCostItem: Record Item;
        Store: Record "LSC Store";
        EmptyCardEntry: Record "LSC POS Card Entry";
        TenderTypeSetup: Record "LSC Tender Type Setup";
        //FisPOSCommand: Codeunit "LSC Fiscal POS Commands";
        COEditOrder: Codeunit "LSC CO Edit Order";
        ResponseCode: Code[30];
        ErrorTextIfNotProceed: Text;
        ErrorText: Text;
        lOldCurrInput: Decimal;
        PaymentAbsValue: Decimal;
        EBTBalance: Decimal;
        AmountToShow: Decimal;
        IsHandled: Boolean;
        Handled: Boolean;
        CanNotMixTenderTypes: Label '%1 cannot be used with other Tender Types';
        Text296: Label 'The transaction must be finalized in %1 %2.';
        LimitationExcessErr: Label '%1 Balance is %2.';
        TaxCodeCodeErr: Label '%1 field cannot be blank in %2 table.';
        OnlyRefundTotalAmount: Label 'It is only supported to refund the whole amount.\ Do you want to refund the Total Amount: %1?';
        TenderTypeNotUsedErr: Label 'This Tender Type may not be used';
        TenderTypeNotUsedInTrainingErr: Label 'This Tender Type may not be used\in training mode';
        TenderTypeNotAllowedInFloatEntryErr: Label 'This Tender Type is not allowed in Float Entry!';
        TenderTypeRequiresCountingErr: Label 'This Tender Type does not require counting!';
        PaymNotAllowedErr: Label 'Payment not allowed in this state!';
        CustAccNotAllowedForPaymErr: Label 'Customer accounts are not allowed\for Payments into account';
        TenderedAmtIsLessThanPrePaymAmtErr: Label 'Tendered amount %1 is less than required prepayment amount of %2';
        UnexpectedReturnCodeTenderChargeErr: Label 'Unexpected Return Code from TenderCharge function.';
        BankTransferAmountToHigh: Label '%1 Payment amount can not be higher than the Customer Order Amount';
        SkipVatProdPostGrpLimitationCheck: Boolean;
        ShowNumericKeyboardCheck: Boolean;
    begin
        //POSTransactionEvents.OnAfterTenderKeyPressedEx(REC, LineRec, CurrInput, TenderTypeCode, TenderAmountText, IsHandled);
        if IsHandled then
            exit;

        if TransactionIsCancelCO and (Balance < 0) then begin
            if TenderAmountText <> '0' then
                if ((CurrInput <> Format(-Balance)) and (CurrInput <> '')) or (TenderAmountText <> '') then
                    if not PosTransactionGui.PosConfirm(StrSubstNo(OnlyRefundTotalAmount, Format(-Balance)), true) then
                        exit
                    else begin
                        TenderAmountText := '';
                        CurrInput := Format(-Balance);
                    end;
        end;

        IsLimitation := false;
        EBTTenderType := '';
        RetailSetup.Get();
        if RetailSetup."Enable Limitation" then
            if LimitationMgt.LimitationInTenderType(REC."Store No.", TenderTypeCode) then begin
                IsLimitation := true;
                SetEBTTenderType(TenderTypeCode);
                LimitationMgt.CalcBalanceAmount(REC."Receipt No.", LimitationBalanceAmount);

                if EBTTenderType = EBTText then
                    EBTBalance := LimitationBalanceAmount[1]
                else
                    if EBTTenderType = EBTCashText then
                        EBTBalance := LimitationBalanceAmount[2];

                if CurrInput <> '' then
                    Evaluate(CurrentPaymentAmount, CurrInput)
                else
                    if TenderAmountText <> '' then
                        Evaluate(CurrentPaymentAmount, TenderAmountText)
                    else
                        CurrentPaymentAmount := EBTBalance;

                if CurrentPaymentAmount > EBTBalance then begin
                    PosTransactionGui.ErrorBeep(StrSubstNo(LimitationExcessErr, EBTTenderType, EBTBalance));
                    exit;
                end;

                Store.Get(REC."Store No.");
                IsHandled := false;
                // POSTransactionEvents.OnBeforeCheckStoreVATGroupCodeIsEmpty(Store, SkipVatProdPostGrpLimitationCheck, IsHandled);
                if IsHandled then
                    exit;

                if not SkipVatProdPostGrpLimitationCheck then
                    if Store."VAT Prod Post Grp (Limitation)" = '' then begin
                        PosTransactionGui.ErrorBeep(StrSubstNo(TaxCodeCodeErr, Store.FieldCaption("VAT Prod Post Grp (Limitation)"), Store.TableCaption));
                        exit;
                    end;
            end;

        CheckCreditCardHold;
        TenderType.Get(StoreSetup."No.", TenderTypeCode);

        if (TenderType."Function" = TenderType."Function"::Member) then begin
            PosFunc.GetMemberInfoForPosMemberTender(REC."Member Card No.", ResponseCode, ErrorText, true);
        end;

        // if not Member.CheckPointBalance(Rec, LineRec, CurrInput) then
        //     exit;

        if TenderType."Function" = TenderType."Function"::Card then begin
            IsHandled := false;
            // POSTransactionEvents.OnTenderKeyPressedEx_OnBeforeCheckPrinterActive(REC, LineRec, CurrInput, TenderTypeCode, TenderAmountText, IsHandled);
            // if not IsHandled then
            //     if not POSTransPrint.IsPrinterActive() then
            //         exit;

            if TenderAmountText = '' then
                if POSSESSION.EFTActive() then
                    if EFTCheckLastTrans(false) then
                        exit;
        end;

        // POSTransactionEvents.OnTenderKeyPressedEx_OnBeforeCheckRecStoreNo(TenderType);

        if StoreSetup."No." <> REC."Store No." then begin
            IsHandled := false;
            //  POSTransactionEventsPub.OnTenderKeyPressedExStoreMismatch(StrSubstNo(Text296, REC.FieldCaption(REC."Store No."), REC."Store No."), StoreSetup."No.", IsHandled);
            if not IsHandled then
                Error(Text296, REC.FieldCaption(REC."Store No."), REC."Store No.");
        end;

        if (TenderType."Function" = TenderType."Function"::Member) and (REC."Member Card No." = '') then begin
            PosTransactionGui.PosMessage(MemberCardRequiredBeforePaymErr);
            exit;
        end;

        if not TenderType."May Be Used" then begin
            PosTransactionGui.ErrorBeep(TenderTypeNotUsedErr);
            exit;
        end;

        TenderTypeSetup.Get(TenderTypeCode);
        if TenderTypeSetup."Bank Transfer" then begin
            if not REC."Customer Order" then begin
                PosTransactionGui.ErrorBeep(TenderTypeNotUsedErr);
                exit;
            end;

            CurrentPaymentAmount := 0;
            REC.CalcFields("Customer Order Amount", "Bank Transfer Payment Amount");
            if CurrInput <> '' then
                Evaluate(CurrentPaymentAmount, CurrInput)
            else
                if TenderAmountText <> '' then
                    Evaluate(CurrentPaymentAmount, TenderAmountText);
            if REC."Customer Order Amount" < CurrentPaymentAmount + REC."Bank Transfer Payment Amount" then begin
                PosTransactionGui.ErrorBeep(StrSubstNo(BankTransferAmountToHigh, TenderType.Description));
                exit;
            end;
        end;


        if TrainingActive and (TenderType."Function" = TenderType."Function"::Card) then begin
            PosTransactionGui.ErrorBeep(TenderTypeNotUsedInTrainingErr);
            exit;
        end;

        CalcTotals;
        Clear(Currency);
        InitNewLine;
        CustomerOrCardNo := '';
        ReadFromMSR := false;
        ChangeTender := false;
        Clear(LastCurrencyCode);

        Ishandled := false;
        // POSTransactionEvents.OnTenderKeyPressedExAfterInitNewLine(REC, TenderType, IsHandled);
        if IsHandled then
            exit;

        // if FisPOSCommand.IsNOLocalizationEnabled then begin
        //     if TenderType."Function" = TenderType."Function"::Customer then begin
        //         PosTrLine.reset;
        //         PosTrLine.SetRange("Receipt No.", REC."Receipt No.");
        //         PosTrLine.SetRange("Entry Type", PosTrLine."Entry Type"::Payment);
        //         PosTrLine.SetFilter("Entry Status", '<>%1', PosTrLine."Entry status"::Voided);
        //         if not PosTrLine.IsEmpty then begin
        //             PosTransactionGui.ErrorBeep(StrSubstNo(CanNotMixTenderTypes, TenderType.Description));
        //             exit;
        //         end;
        //     end;
        // end;

        POSTransLine.SetRange("Receipt No.", REC."Receipt No.");
        POSTransLine.SetRange(Number, StoreSetup."Web Store Shipping Cost Item");
        POSTransLine.SetRange(Price, 0);
        if POSTransLine.FindFirst() then
            if ShippingCostItem.Get(POSTransLine.Number) then
                //   if not POSTransactionFunctions.CheckPriceZeroIsValid(POSTransLine.Price, ShippingCostItem) then
                //    exit;

                if STATE <> "LSC POS Transaction State"::TENDOP then begin
                    if TenderType."Card/Account No." and (TenderType."Function" = TenderType."Function"::Customer) and REC."New Transaction" then begin
                        InfoTextDescription := TenderType.Description;
                        AskForCustomer;
                        exit;
                    end;
                    if STATE <> "LSC POS Transaction State"::PAYMENT then begin
                        PosTransactionGui.ErrorBeep(PaymNotAllowedErr);
                        exit;
                    end;
                    if ProcessTenderOffers then begin
                        Balance := TenderOfferNewBalanc;
                    end else begin
                        if ProcessTenderOfferAtTotal(TenderTypeCode) then
                            exit;
                    end;
                    if (TenderType."Function" = TenderType."Function"::Customer) and
                       (REC."Transaction Type" = REC."Transaction Type"::Payment) and not REC."New Transaction" then begin
                        PosTransactionGui.ErrorBeep(CustAccNotAllowedForPaymErr);
                        exit;
                    end;
                    // if not PosFunc.PermissionTender(TenderType, POSSESSION.MgrKey, InfoTextDescription) then begin
                    //     PosTransactionGui.ErrorBeep(InfoTextDescription);
                    //     exit;
                    // end;
                    if TenderType."Card/Account No." and (TenderType."Function" = TenderType."Function"::Customer) then begin
                        if not PrepaymentAmountTendered then begin
                            if REC.Payment < 0 then
                                PosTransactionGui.ErrorBeep(StrSubstNo(TenderedAmtIsLessThanPrePaymAmtErr, REC.Payment, REC.Prepayment - REC.Payment))
                            else
                                PosTransactionGui.ErrorBeep(StrSubstNo(TenderedAmtIsLessThanPrePaymAmtErr, REC.Payment, REC.Prepayment));
                            exit;
                        end;
                    end;
                end
                else begin
                    if (REC."Transaction Type" = REC."Transaction Type"::"Float Entry") and not TenderType."Float Allowed" then begin
                        PosTransactionGui.ErrorBeep(TenderTypeNotAllowedInFloatEntryErr);
                        exit;
                    end;
                    if not TenderType."Counting Required" then begin
                        PosTransactionGui.ErrorBeep(TenderTypeRequiresCountingErr);
                        exit;
                    end;
                    if TenderType."Remove/Float Type" = '' then begin
                        PosTransactionGui.ErrorBeep(AddRemoveTenderTypeMissingErr);
                        exit;
                    end;
                end;
        // if TenderType."Foreign Currency" then begin
        //     SetFunctionMode("LSC POS Command"::CURRENCY);
        //     exit;
        // end;

        if TenderAmountText <> '' then begin
            if (StrLen(TenderAmountText) > 0) and (CopyStr(TenderAmountText, 1, 1) = '<') then
                CurrInput := POSSESSION.GetValue(TenderAmountText)
            else
                CurrInput := TenderAmountText;
        end;

        //POSTransactionEventsPub.OnBeforeInsertPayment_TenderKeyPressedEx(REC, CustomerOrderHeader_Temp, CustomerOrderLine_Temp, CustomerOrderDiscountLine_Temp, PrepayCustomerOrder, COWasCreated);

        if CurrInput = '' then begin
            ShowNumericKeyboardCheck := ((TenderType."Function" <> TenderType."Function"::Card) or EFT.UseNumpad) and
                (TenderType."Function" <> TenderType."Function"::Voucher) and
                PosFuncProfile."Numeric Keypad on Tender";
            POSTransactionEvents.OnBeforeCheckShowNumericKeyboard_TenderKeyPressedEx(REC, TenderType, ShowNumericKeyboardCheck);
            if ShowNumericKeyboardCheck then begin
                if TenderType."Function" = TenderType."Function"::Card then
                    EFT.AdjustCardAmountForTips(REC, PaymentAmount, Balance);

                POSTransactionEvents.OnBeforeRoundPaymentAmount_TenderKeyPressedEx(REC, TenderType, PosFuncProfile, Balance);

                if IsLimitation then begin
                    PaymentAmount := PosFunc.RoundTender(TenderType, EBTBalance);
                    REC."Rounding Amount" := PaymentAmount - EBTBalance;
                end else begin
                    PaymentAmount := PosFunc.RoundTender(TenderType, Balance);
                    REC."Rounding Amount" := PaymentAmount - Balance;
                end;
                PosTransactionEvents.OnSelectTenderType(TenderType, PaymentAmount, IsHandled);
                if IsHandled then
                    exit;
                //PosFunc.AdjustAmountToShow(PaymentAmount);

                if STATE <> "LSC POS Transaction State"::TENDOP then begin
                    if Balance < 0 then
                        PaymentAmount := -PaymentAmount;
                end;
                Commit;

                POSTransactionEvents.OnBeforeEnterTenderTypeAmount(PaymentAmount, POSSESSION.StoreNo, TenderTypeCode, Balance);

                CurrentTenderTypeCode := TenderTypeCode;
                CustomerOrderHeader_Temp.CalcFields("Pre Approved Amount");
                IsHandled := false;
                POSTransactionEvents.OnBeforeSetCOPaymentAmtOnTenderKeyPressedEx(REC, CustomerOrderHeader_Temp, CustomerOrderLine_Temp, PaymentAmount, PrepayCustomerOrder, COWasCreated, IsHandled);
                if not IsHandled then
                    if REC."Customer Order" then
                        if PrepayCustomerOrder then begin
                            if (CustomerOrderHeader_Temp."Pre Approved Amount" > 0) then
                                PaymentAmount := CustomerOrderHeader_Temp."Pre Approved Amount";
                        end else
                            if COWasCreated then
                                PaymentAmount := PaymentAmount - PosFunc.GetCustomerOrderAmountFromPOSTransaction(REC);

                if REC."Rounding Amount" = PaymentAmount then
                    PaymentAmount := PaymentAmount - REC."Rounding Amount";

                // if REC."Customer Order" and not PrepayCustomerOrder then begin
                //     if CustomerOrderSession.IsCustomerOrderEdit() then
                //         // earlier payments needs to be subtracted from current total to show actual balance.
                //         COEditOrder.ReturnActualAmountForPos(REC, PaymentAmount);
                //     //Customer does not want to add payment to CO. If Exhange line in Trans, check if customer wants to add Exchange amount to CO
                //     TotalExchangeAmountToCO := CheckForExchangeLineInTrans(REC."Receipt No.", PaymentAmount, DoNotUseExchangeLineAsPayToCO);
                //     if TotalExchangeAmountToCO > 0 then
                //         PaymentAmount += TotalExchangeAmountToCO
                //     else
                //         if DoNotUseExchangeLineAsPayToCO then begin
                //             PaymentAbsValue := Abs(PaymentAmount);
                //             //POSTransactionEventsPub.OnBeforeOpenNumericKeyboardOnTenderKey(REC, TenderTypeCode, PaymentAbsValue);
                //             PosTransactionGui.OpenNumericKeyboard(AmountMsg, PosFunc.FormatAmountToShow(PaymentAbsValue), Enum::"LSC POS Trans. Numpad Trigger"::TenderKeyPressedEx);
                //             exit;
                //         end;
                // end;

                if REC."Customer Order" then
                    if TenderTypeSetup."Bank Transfer" and (REC."Customer Order Amount" < PaymentAmount) then
                        PaymentAmount := REC."Customer Order Amount";

                //  POSTransactionEventsPub.OnBeforeOpenNumericKeyboardOnTenderKey(REC, TenderTypeCode, PaymentAmount);
                PosTransactionGui.OpenNumericKeyboard(AmountMsg, PosFunc.FormatAmountToShow(PaymentAmount), Enum::"LSC POS Trans. Numpad Trigger"::TenderKeyPressedEx);
                exit;
            end;
        end;

        if IsLimitation then begin
            PaymentAmount := PosFunc.RoundTender(TenderType, EBTBalance);
            REC."Rounding Amount" := PaymentAmount - EBTBalance;
        end else begin
            PaymentAmount := PosFunc.RoundTender(TenderType, Balance);
            REC."Rounding Amount" := PaymentAmount - Balance;
        end;

        POSTransactionEvents.TenderKeyPressedEx_OnBeforeRecModify(REC, PaymentAmount, TenderType, CurrInput, Balance, ErrorTextIfNotProceed, Handled);
        if Handled then begin
            if ErrorTextIfNotProceed <> '' then
                PosTransactionGui.ErrorBeep(ErrorTextIfNotProceed);
            exit;
        end;

        REC.Modify;

        TenderChargeSelect := TenderCharge(REC."Store No.", TenderType, CurrInput, lTmp, CardType);

        POSTransactionEvents.TenderKeyPressedEx_OnAfterTenderChargeSelect(REC, PaymentAmount, TenderType, CurrInput, CardType, Balance, TenderChargeSelect, lOldCurrInput, lTmp, ErrorTextIfNotProceed, Handled);
        if Handled then begin
            if ErrorTextIfNotProceed <> '' then
                PosTransactionGui.ErrorBeep(ErrorTextIfNotProceed);
            exit;
        end;

        if TenderChargeSelect = -1 then
            exit;

        case TenderChargeSelect of
            0: //CHARGE_ZERO
                ;
            1: //CHARGE_ACCEPTED
                begin
                    if CurrInput <> '' then begin
                        if not Evaluate(lOldCurrInput, CurrInput) then begin
                            PosTransactionGui.ErrorBeep(InvalidAmtValueErr);
                            exit;
                        end;
                    end else
                        lOldCurrInput := 0;

                    CurrInput := Format(lTmp.Amount3); //Charge
                    if lTmp.Amount3 <> 0 then
                        IncExpPressed(lTmp."Sort Code");   //Charge Account

                    if lOldCurrInput > lTmp."Sales Amount" then
                        CurrInput := Format(lOldCurrInput)
                    else
                        CurrInput := Format(lTmp."Sales Amount");
                    PaymentAmount := lTmp."Sales Amount";
                end;
            2: //CHARGE_CANCEL
                exit;
            else begin
                PosTransactionGui.ErrorBeep(UnexpectedReturnCodeTenderChargeErr);
                exit;
            end;
        end;

        // POSTransactionEvents.TenderKeyPressedEx_OnBeforeValidateCurrInput(REC, PaymentAmount, TenderType, CurrInput, Balance, ErrorTextIfNotProceed, Handled);
        if Handled then begin
            if ErrorTextIfNotProceed <> '' then
                PosTransactionGui.ErrorBeep(ErrorTextIfNotProceed);
            exit;
        end;

        case CurrInput of
            '':
                begin
                    KeyboardAmount := false;
                    PaymentAmount := PosFunc.RoundTender(TenderType, Balance);
                    POSTransactionEvents.TenderKeyPressedEx_OnAfterCalculatePaymentAmount(TenderType, PaymentAmount, IsHandled);
                    if IsHandled then
                        exit;
                end;
            '0':
                begin
                    KeyboardAmount := true;
                    PaymentAmount := 0;
                    POSTransactionEvents.TenderKeyPressedEx_OnAfterCalculatePaymentAmount(TenderType, PaymentAmount, IsHandled);
                    if IsHandled then
                        exit;
                end;
            else begin
                if not Evaluate(PaymentAmount, CurrInput) then begin
                    PosTransactionGui.ErrorBeep(InvalidAmtValueErr);
                    exit;
                end;
                // PosFunc.AdjustAmount(PaymentAmount);
                if TenderType."Rounding To" <> 0 then
                    if PaymentAmount mod TenderType."Rounding To" <> 0 then begin
                        PosTransactionGui.ErrorBeep(StrSubstNo(LowestAcceptedDenomErr, FormatAmount(TenderType."Rounding To")));
                        exit;
                    end;
                if STATE <> "LSC POS Transaction State"::TENDOP then begin
                    if Balance < 0 then
                        PaymentAmount := -PaymentAmount;
                end;
                KeyboardAmount := true;
            end;
        end;

        if (CurrInput = '') and (TenderType."Function" = TenderType."Function"::Voucher) then begin
            CurrentTenderTypeCode := TenderTypeCode;
            //POSTransactionEventsPub.OnBeforeOpenNumericKeyboardOnTenderKey(REC, TenderTypeCode, PaymentAmount);

            IsHandled := false;
            // POSTransactionEventsPub.OnBeforeVoucherOpenNumericKeyboard(REC, TenderTypeCode, PaymentAmount, IsHandled);
            if not IsHandled then begin
                // if CustomerOrderSession.isCustomerOrderEdit() then
                //     AmountToShow := -PaymentAmount
                // else
                AmountToShow := PaymentAmount;
                PosTransactionGui.OpenNumericKeyboard(AmountMsg, PosFunc.FormatAmountToShow(AmountToShow), Enum::"LSC POS Trans. Numpad Trigger"::TenderKeyPressedEx);
                exit;
            end;
        end;

        if REC."Customer Order" and not PrepayCustomerOrder and COWasCreated and (CurrInput = '') then
            PaymentAmount := PaymentAmount - PosFunc.GetCustomerOrderAmountFromPOSTransaction(REC);

        if DoNotUseExchangeLineAsPayToCO then begin
            DoNotUseExchangeLineAsPayToCO := false;
            if (Balance - TotalExchangeAmount > 0) and (PaymentAmount <> 0) then
                PaymentAmount := -PaymentAmount;
        end;

        if ProcessTenderOffers then begin
            if TenderOfferNewBalanc > PaymentAmount then
                ProcessTenderOffers := false;
        end;

        if (STATE = "LSC POS Transaction State"::TENDOP) and not KeyboardAmount then begin
            PosTransactionGui.ErrorBeep(AmtEntryRequiredErr);
            POSTransactionEvents.TenderKeyPressedEx_OnCancelPaymentOnBeforeExit(REC, PaymentAmount, TenderType, CurrInput, Balance, KeyboardAmount);
            exit;
        end;

        CurrInput := '';

        POSTransactionEvents.OnBeforeValidateTenderInTenderKeyPressed(ErrorTextIfNotProceed, Handled);
        if Handled then begin
            PosTransactionGui.ErrorBeep(ErrorTextIfNotProceed);
            exit;
        end;

        if (RetailSetup."Enable Limitation") and (IsLimitation) and (TenderType."Function" = TenderType."Function"::Card) then begin
            if CurrentPaymentAmount <> 0 then
                PaymentAmount := CurrentPaymentAmount
            else
                if EBTBalance <= Balance then begin
                    PaymentAmount := EBTBalance;
                    CurrentPaymentAmount := EBTBalance;
                end else begin
                    PaymentAmount := Balance;
                    CurrentPaymentAmount := Balance;
                end;
        end;

        if STATE <> "LSC POS Transaction State"::TENDOP then begin
            // if not PosFunc.ValidateTender(TenderType, REC."Gross Amount", Balance, PaymentAmount, REC."Sale Is Return Sale", KeyboardAmount, InfoTextDescription) then begin
            //     POSTransactionEvents.TenderKeyPressedEx_OnValidateTenderOnBeforeErrorBeep(REC, PaymentAmount, TenderType, CurrInput, Balance, KeyboardAmount, InfoTextDescription);
            //     PosTransactionGui.ErrorBeep(InfoTextDescription);
            //     exit;
            // end;

            if PaymentAmount >= Balance then
                if not EFT.UnprocessedPreAuthCheck(REC, 0) then begin
                    POSTransactionEvents.TenderKeyPressedEx_OnCancelPaymentOnBeforeExit(REC, PaymentAmount, TenderType, CurrInput, Balance, KeyboardAmount);
                    exit;
                end;

            InfoTextDescription := StrSubstNo('%1 %2', TenderType.Description, FormatAmount(PaymentAmount));
            if TenderType."Card/Account No." then begin
                if TenderType."Function" = TenderType."Function"::Customer then begin
                    if REC."Customer No." = '' then begin
                        AskForCustomer;
                        POSTransactionEvents.TenderKeyPressedEx_OnValidateTenderOnBeforeErrorBeep(REC, PaymentAmount, TenderType, CurrInput, Balance, KeyboardAmount, InfoTextDescription);
                        exit;
                    end;
                    if not TestCustomer(REC."Customer No.", KeyboardAmount, true) then begin
                        POSTransactionEvents.TenderKeyPressedEx_OnValidateTenderOnBeforeErrorBeep(REC, PaymentAmount, TenderType, CurrInput, Balance, KeyboardAmount, InfoTextDescription);
                        exit;
                    end;

                    // if not PosFunc.ValidateCustomer(Customer, POSSESSION.MgrKey, REC."Sale Is Return Sale", PaymentAmount, InfoTextDescription) then begin
                    //     PosTransactionGui.ErrorBeep(InfoTextDescription);
                    //     SetFunctionMode("LSC POS Command"::PAYMENT);
                    //     InfoTextDescription2 := SelectOtherPaymOrCustMsg;
                    //     CurrInput := '';
                    //     REC.Modify;
                    //     POSTransactionEvents.TenderKeyPressedEx_OnValidateTenderOnBeforeErrorBeep(REC, PaymentAmount, TenderType, CurrInput, Balance, KeyboardAmount, InfoTextDescription);
                    //     exit;
                    // end;
                end else
                    if (TenderType."Function" = TenderType."Function"::Card) then begin
                        AskForCard;
                        POSTransactionEvents.TenderKeyPressedEx_OnValidateTenderOnBeforeErrorBeep(REC, PaymentAmount, TenderType, CurrInput, Balance, KeyboardAmount, InfoTextDescription);
                        exit;
                    end else begin
                        POSTransactionEvents.OnBeforeAskForCustomer(EmptyCardEntry, Rec, PosTerminal);
                        AskForCustomer;
                        POSTransactionEvents.TenderKeyPressedEx_OnValidateTenderOnBeforeErrorBeep(REC, PaymentAmount, TenderType, CurrInput, Balance, KeyboardAmount, InfoTextDescription);
                        exit;
                    end;
            end;
        end;

        POSTransactionEvents.TenderKeyPressedEx_OnBeforeTenderCheckLoyalty(REC, PaymentAmount, TenderType, CurrInput, Balance, KeyboardAmount, InfoTextDescription, Handled);
        if Handled then begin
            if InfoTextDescription <> '' then
                PosTransactionGui.ErrorBeep(InfoTextDescription);
            exit;
        end;

        if not TenderCheckloyalty() then
            exit;

        POSTransactionEvents.OnBeforeInsertPayment_TenderKeyExecutedEx(REC, LineRec, CurrInput, TenderTypeCode, TenderAmountText);

        InsertPaymentLine;

        POSTransactionEvents.OnAfterTenderKeyExecutedEx(REC, LineRec, CurrInput, TenderTypeCode, TenderAmountText);
    end;

    local procedure AskForQRCode()
    var
        POSScannerDialog: Page "LSC POS Scanner Dialog";
        ScannerId: Code[20];
        IsHandled: Boolean;
    begin
        // POSTransactionEvents.OnBeforeAskForQRCode(CurrInput, IsHandled);
        // if IsHandled then
        //     exit;

        // ScannerId := POSSession.GetHardwareProfileDevice("LSC Hardware Profile Devices"::Scanner);
        // POSScannerDialog.SetScannerID(ScannerId, "LSC Barcode Scan Types"::BarcodeScan);
        // Commit;
        // POSScannerDialog.RunModal();
        // if POSScannerDialog.GetScannerResult() then
        //     CurrInput := POSScannerDialog.GetScanDataLabel();
    end;

    procedure TenderNoPressed()
    var
        TenderNotOnFileErr: Label 'Tender %1 is not on file !';
    begin
        if not TenderType.Get(StoreSetup."No.", CurrInput) then begin
            PosTransactionGui.ErrorBeep(StrSubstNo(TenderNotOnFileErr, CurrInput));
            exit;
        end;
        CurrInput := '';
        TenderKeyPressed(TenderType.Code);
    end;

    procedure CustomerPressed()
    var
        lStartFunction: Code[10];
    begin
        // if FunctionSetup."Function Code" <> Format("LSC POS Command"::CUSTOMER) then begin
        //     lStartFunction := FunctionSetup."Function Code";
        //     SetFunctionMode("LSC POS Command"::CUSTOMER);
        //     OnlySelectCustomer := true;
        //     TenderType."Function" := TenderType."Function"::Customer;
        // end;

        // if not ValidateCustomer() then begin
        //     OnlySelectCustomer := false;
        //     exit;
        // end;

        // OnlySelectCustomer := false;

        // POSTransactionEvents.OnAfterCustomerPressed(REC);

        // if lStartFunction = 'CUSTOMER' then begin
        //     SetPOSState("LSC POS Transaction State"::SALES);
        //     SetFunctionMode("LSC POS Command"::ITEM);
        //     SelectDefaultMenu;
        // end
        // else
        //     if lStartFunction <> '' then begin
        //         SetFunctionMode(lStartFunction);
        //     end;
    end;

    procedure ChangeStaff(KeyValue: Text[30])
    var
        ConfirmationQst: Label 'Are you sure you want to change the staff ID of this transaction from %1 to %2?';
    begin
        if (KeyValue <> '') and (REC."Staff ID" <> KeyValue) then begin
            if not PosTransactionGui.PosConfirm(StrSubstNo(ConfirmationQst, REC."Staff ID", KeyValue), true) then
                exit;

            REC."Staff ID" := KeyValue;
            //PosFunc.ChangeStaff(REC);
        end;
    end;

    procedure AskForCard()
    var
        Proceed: Boolean;
    begin
        Proceed := true;
        POSTransactionEvents.OnBeforeAskForCard(REC, LineRec, CurrInput, PaymentAmount, Proceed, TenderType.Code);

        if not Proceed then
            exit;

        if not KeyboardAmount then
            EFT.AdjustCardAmountForTips(REC, PaymentAmount, Balance);

        if TenderType."Scan QR Code" then
            AskForQRCode()
        else
            CurrInput := '-(PINPAD)-';

        EFT.SetCardOffline(false);
        ValidateCard;
    end;

    procedure EFTActive(ShowError: Boolean): Boolean
    begin
        if not POSSESSION.EFTActive() then begin
            if ShowError then
                PosTransactionGui.ErrorBeep(StrSubstNo(NoIsConfiguredInHwProfileMsg, "LSC Hardware Profile Devices"::EFT, PosSetup."Profile ID"));
            exit(false);
        end;

        exit(true);
    end;

    procedure PreauthPressed(pCommand: Text; pParameter: Text)
    var
        ErrorReason: Text;
    begin
        if EFTCheckLastTrans(false) then
            exit;
        CalcTotals;
        if not EFT.PreAuthPressed(pCommand, pParameter, REC, LineRec, CurrInput, Balance, PaymentAmount, ErrorReason, UsePaymentToken) then begin
            if ErrorReason <> '' then
                PosTransactionGui.ErrorBeep(ErrorReason);
            exit;
        end;
        NextCardPhase;
    end;

    procedure CollectSPGOrderPressed(pMenuLine: Record "LSC POS Menu Line")
    var
        COPosFunctions: Codeunit "LSC CO POS Functions";
    begin
        if REC."New Transaction" then
            SalePressed(true)
        else
            if not SPGOrder then begin
                PosTransactionGui.ErrorBeep(CurrTransMustBeFinishedErr);
                exit;
            end;

        CurrInput := pMenuLine.Parameter;
        TmpText := COPosFunctions.POSCollectScanPayGoOrder(CurrInput);
        CustomerOrderHeader_Temp."Document ID" := CurrInput;
        if TmpText <> '' then begin
            PosTransactionGui.MessageBeep(TmpText);
        end else
            CurrInput := '';
        CollectingOrder := true;
        SPGOrder := true;
    end;

    procedure ValidateCard(TokenSelectionValue: Text)
    begin
        EFT.SetTokenSelectionValue(TokenSelectionValue);
        CurrInput := '-(PINPAD)-';
        ValidateCard();
    end;

    procedure ValidateCard()
    var
        emptyCardEntry: Record "LSC POS Card Entry";
    begin
        ValidateCard(emptyCardEntry);
    end;

    procedure ValidateCard(var pCardEntry: Record "LSC POS Card Entry")
    begin
        ValidateCard(pCardEntry, 0);
    end;

    procedure ValidateCard(var pCardEntry: Record "LSC POS Card Entry"; pTransType: Option Sale,Preauth,"Update-Preauth","Finalize-Preauth")
    var
        ErrorReason: Text;
        CarNoMsg: Label 'Card no.';
        OvertenderNotAllowed: Label 'Overtender not allowed for this cardtype';
        MessageText: Text;
        IsHandled: Boolean;
    begin
        if CurrInput = '' then begin
            PosTransactionGui.OpenNumericKeyboard(CarNoMsg, '', Enum::"LSC POS Trans. Numpad Trigger"::ValidateCard);
            exit;
        end;

        if not EFT.ValidateCard(REC, LineRec, pCardEntry, pTransType, TenderType.Code, PaymentAmount, Balance, CurrInput, ReadFromMSR, MessageText, ErrorReason, UsePaymentToken, TenderType."Scan QR Code") then begin
            PosTransactionGui.ErrorBeep(ErrorReason);
            exit;
        end
        else
            if MessageText <> '' then
                PosTransactionGui.PosMessage(MessageText);

        POSTransactionEvents.ValidateCard_OnBeforeCheckOverTender(IsHandled);
        if not IsHandled then
            if TenderCardType.Get(TenderType."Store No.", TenderType.Code, EFT.GetCardType) then begin
                if not TenderCardType."Change Allowed" then
                    if Balance < PaymentAmount then begin
                        PosTransactionGui.ErrorBeep(OvertenderNotAllowed);
                        //SetFunctionMode("LSC POS Command"::PAYMENT);
                        exit;
                    end;
            end;

        if EFT.GetCardTypeName <> '' then
            InfoTextDescription := StrSubstNo('%1 (%2) %3', TenderType.Description, EFT.GetCardTypeName, FormatAmount(PaymentAmount))
        else
            InfoTextDescription := StrSubstNo('%1 %2', TenderType.Description, FormatAmount(PaymentAmount));


        EFT.SetCardPhase(0);
        if EFT.IsExpiryDateRequired then begin
            //SetFunctionMode("LSC POS Command"::EXDATE);
            PosTransactionGui.MessageBeep('');
            exit;
        end;
        POSTransactionEvents.OnAfterValidateCard(REC, LineRec, CurrInput, TenderType.Code);
        NextCardPhase;
    end;

    procedure NextCardPhase()
    var
        FuncMode: Enum "LSC POS Command";
    begin
        FuncMode := EFT.NextCardPhase();
        if FuncMode <> Enum::"LSC POS Command"::" " then begin
            //SetFunctionMode(FuncMode);
            PosTransactionGui.MessageBeep('');
            exit;
        end;
        SeekAuthorisation;
    end;

    procedure ValidateCardType()
    var
        CreditCard: Boolean;
        CardTypeOptsMsg: Label 'The options are 0: Debitcard 1: Creditcard';
    begin
        if CurrInput = '' then begin
            PosTransactionGui.OpenNumericKeyboard(CartTypeMsg, '', Enum::"LSC POS Trans. Numpad Trigger"::ValidateCardType);
            exit;
        end;

        case CurrInput of
            '0':
                CreditCard := false;
            '1':
                CreditCard := true;
            else begin
                InfoTextDescription := CardTypeOptsMsg;
                PosTransactionGui.MessageBeep('');
                exit;
            end;
        end;
        EFT.SetComboCard(CreditCard);
        NextCardPhase;
    end;

    procedure ValidateCardExtra()
    begin
        if CurrInput = '' then begin
            PosTransactionGui.OpenNumericKeyboard(CartTypeMsg, '', Enum::"LSC POS Trans. Numpad Trigger"::ValidateCardExtra);
            exit;
        end;

        if CurrInput = '0' then
            CurrInput := '';
        CardExtraData := CurrInput;
        NextCardPhase;
    end;

    procedure SeekAuthorisation()
    var
        CardEntryNo: Integer;
    begin
        OposUtil.DisableScanner();
        CurrInput := '';
        SetInfoTextDescription('', '');
        CardEntryNo := EFT.SeekAuthorisation(REC, InfoTextDescription);
        InsertCardPaymentLine(CardEntryNo);
    end;

    procedure InsertCardPaymentLine(pCardEntryNo: Integer)
    var
        parentEntry: Record "LSC POS Card Entry";
        cardSlipNo: Text;
        isPreAuth: Boolean;
        PreAuthDescription: Label 'Pre-Auth(%1) [%2] on %3';
        CardToFileDescription: Label 'Card to file [%1] on %2';
        CardEntry: Record "LSC POS Card Entry";
    begin
        CardEntry.Get(PosTerminal."Store No.", PosTerminal."No.", pCardEntryNo);
        isPreAuth := CardEntry."Transaction Type" in [CardEntry."Transaction Type"::PreAuth, CardEntry."Transaction Type"::UpdatePreAuth, CardEntry."Transaction Type"::AddCardToFile];

        if EFT.GetResult = 1 then begin
            if REC."Sale Is Return Sale" then begin
                if -PaymentAmount >= 0 then
                    PaymentAmount := -EFT.GetAmount;
            end
            else
                if PaymentAmount >= 0 then
                    PaymentAmount := EFT.GetAmount;

            EFT.ProcessTipAndServiceCharge(REC);

            if isPreAuth then begin
                InsertPreauthInfoLine(CardEntry);
            end
            else begin
                gInsertTmpPayment := true;
                if ((CardEntry."Transaction Type" = CardEntry."Transaction Type"::"Void Sale") and (CardEntry."Line No." = 0)) then begin
                    if NewLine."Entry Type" <> NewLine."Entry Type"::Payment then begin
                        InsertVoidPaymentLine(CardEntry, CardEntry."Entry No.");
                    end
                end
                else
                    if CardEntry."Transaction Type" = CardEntry."Transaction Type"::FinalizePreAuth then begin
                        if parentEntry.Get(CardEntry."PreAuth Entry Store", CardEntry."PreAuth Entry Terminal", CardEntry."PreAuth Entry No.") then begin
                            NewLine.Description := '';
                            NewLine."Text Type" := NewLine."Text Type"::" ";
                            InsertPaymentLine(parentEntry."Line No.", CardEntry)
                        end;
                    end
                    else
                        InsertPaymentLine(-1, CardEntry);
            end;
        end;

        CardEntry."Line No." := NewLine."Line No.";
        cardSlipNo := REC."Receipt No.";
        case EFT.GetResult of
            1:
                CardEntry."Authorisation Ok" := true;
            2:
                begin
                    // SetFunctionMode("LSC POS Command"::CONTROL);
                    //PrintCardSlips(cardSlipNo);
                    exit;
                end;
            else begin
                POSGUI.PostCommand("LSC POS Command"::ERRORBEEP, CopyStr(InfoTextDescription, 1, 100)); //Delay error message (to close eft dialog)
                                                                                                        // SetFunctionMode("LSC POS Command"::PAYMENT);
                                                                                                        //PrintCardSlips(cardSlipNo);
                exit;
            end;
        end;
        CardEntry."Extra Data" := CardExtraData;
        CardEntry.Modify(true);

        if isPreAuth then begin
            if CardEntry."Authorisation Ok" then begin
                //NewLine."Card/Customer/Coup.Item No" := PosFunc.PadCardNo(CardEntry.GetCardNo);
                NewLine."Card Entry No." := CardEntry."Entry No.";
                NewLine."Card Type" := CardEntry."Card Type";
                if CardEntry."Transaction Type" = CardEntry."Transaction Type"::AddCardToFile then
                    NewLine.Description := StrSubstNo(CardToFileDescription, CardEntry."Card Number", CardEntry.Date)
                else
                    NewLine.Description := StrSubstNo(PreAuthDescription, EFT.PreAuthUpdateCount(CardEntry), CardEntry."Card Number", CardEntry.Date);
            end;

            NewLine.Modify(true);
            Commit;
            LineRec := NewLine;
            POSLINES.SetCurrentLine(LineRec);
        end
        else
            CommitPaymentLine(CardEntry);

        PrintCardSlips(cardSlipNo);
    end;

    procedure PrintCardSlips(cardSlipNo: Text)
    begin
        if not EFTActive(false) then
            exit;

        // if not POSTransPrint.IsPrinterActive() then
        //     exit;

        EFT.PrintCardSlips(REC, cardSlipNo);
    end;

    procedure AskForCustomer()
    begin
        //SetFunctionMode("LSC POS Command"::CUSTOMER);
        //SetInputPrompt(TenderType."Ask for Card/Account");
        PosTransactionGui.MessageBeep('');
    end;

    procedure SetCustomer(pCustomerNo: Code[20])
    var
        Text249: Label 'Customer %1 %2 selected.';
    begin
        if REC."Sale Is Return Sale" and (REC."Customer No." <> '') and (REC."Retrieved from Receipt No." <> '') then begin
            if (REC."Customer No." <> pCustomerNo) then begin
                PosTransactionGui.ErrorBeep(StrSubstNo(TransBelongsToCustErr, REC."Customer No."));
                exit;
            end;
        end;
        // POSTransactionEvents.OnBeforeSetCustomer(REC, pCustomerNo);
        REC."Customer No." := pCustomerNo;
        Customer.Get(REC."Customer No.");
        REC.Modify;
        InfoTextDescription2 := CopyStr(StrSubstNo(Text249, pCustomerNo, Customer.Name), 1, MaxStrLen(InfoTextDescription2));
    end;

    procedure ValidateCustomer(): Boolean
    var
        COUtility: Codeunit "LSC CO Utility";
        CustConfirmOk: Boolean;
        IsHandled: Boolean;
        ConfirmCustQst: Label '\\Confirm customer?';
        UnknownCustErr: Label 'Unknown customer %1';
        CustInvalidAsPaymErr: Label 'Customer %1 is invalid as payment.';
    begin
        // POSTransactionEvents.OnBeforeValidateCustomer(REC, LineRec, CurrInput, CustomerOrCardNo, IsHandled);
        if IsHandled then
            exit(false);
        if CurrInput = '' then begin
            PosTransactionGui.OpenNumericKeyboard(CustomerMsg, '', Enum::"LSC POS Trans. Numpad Trigger"::ValidateCustomer);
            exit(true);
        end;

        if REC."Sale Is Return Sale" and (REC."Customer No." <> '') and (REC."Retrieved from Receipt No." <> '') then begin
            if (REC."Customer No." <> CurrInput) then begin
                PosTransactionGui.ErrorBeep(StrSubstNo(TransBelongsToCustErr, REC."Customer No."));
                exit(false);
            end;
        end;

        if FunctionSetup."Function Code" = Format("LSC POS Command"::CUSTOMER) then begin
            if TenderType."Function" <> TenderType."Function"::Check then begin
                if not Customer.Get(CurrInput) then begin
                    PosTransactionGui.ErrorBeep(StrSubstNo(UnknownCustErr, CurrInput));
                    // if not REC."New Transaction" then
                    //     SetFunctionMode("LSC POS Command"::PAYMENT);
                    exit(false);
                end;
                CustomerOrCardNo := Customer."No.";
                //POSTransactionEvents.OnAfterValidateCustomerTender(REC, LineRec, CurrInput, CustomerOrCardNo);
            end else begin
                CustomerOrCardNo := CurrInput;
                InsertPaymentLine;
                exit(true);
            end
        end
        else begin
            CustomerOrCardNo := CurrInput;
            InsertPaymentLine;
            exit(true);
        end;
        CurrInput := '';

        if (Customer."No." = REC."Customer No.") and (not OnlySelectCustomer) then
            CustConfirmOk := true
        else
            CustConfirmOk := not AskConfirmation;

        //POSTransactionEvents.OnBeforeAskConfirmationOnValidateCustomer(Customer."No.", CustConfirmOk, AskConfirmation);
        if AskConfirmation then
            if PosTransactionGui.PosConfirm(Customer."No." + ' ' + Customer.Name + ConfirmCustQst, true) then
                CustConfirmOk := true;

        if CustConfirmOk then begin
            if OnlySelectCustomer then begin
                // if not PosFunc.ValidateCustomer(Customer, POSSESSION.MgrKey, REC."Sale Is Return Sale", 0, InfoTextDescription) then begin
                //     PosTransactionGui.ErrorBeep(InfoTextDescription);
                //     SetFunctionMode("LSC POS Command"::PAYMENT);
                //     CurrInput := '';
                //     REC."Customer No." := '';
                //     InfoTextDescription2 := SelectOtherPaymOrCustMsg;
                //     REC.Modify;
                //     CleanupCustomer;
                //     exit(false);
                // end;
            end
            else begin
                if not TestCustomer(Customer."No.", Balance <> 0, false) then begin
                    if REC."Customer No." = '' then begin
                        InfoTextDescription := StrSubstNo(CustInvalidAsPaymErr, Customer."No.");
                        InfoTextDescription2 := SelectOtherPaymOrCustMsg;
                    end;
                    exit(false);
                end;
                // if not PosFunc.ValidateCustomer(Customer, POSSESSION.MgrKey, REC."Sale Is Return Sale", Balance, InfoTextDescription) then begin
                //     PosTransactionGui.ErrorBeep(InfoTextDescription);
                //     SetFunctionMode("LSC POS Command"::PAYMENT);
                //     CurrInput := '';
                //     REC."Customer No." := '';
                //     InfoTextDescription2 := SelectOtherPaymOrCustMsg;
                //     REC.Modify;
                //     CleanupCustomer;
                //     exit(false);
                // end;
            end;

            //POSTransactionEvents.OnAfterValidateCustomerLine(REC, LineRec, CurrInput, CustomerOrCardNo);
            ProcessCustomerChangeState := not OnlySelectCustomer;

            AmtChargedOnPOSInt := Customer."LSC AmtChargedOnPOSInt";
            AmtChargedPostedInt := Customer."LSC AmtChargedPostedInt";
            BalanceLCYInt := Customer."LSC BalanceLCYInt";

            if CheckInfoCode('CUSTOMER') then
                exit;
            if OnlySelectCustomer then
                ProcessCustomer(false)
            else
                ProcessCustomer(true);
            //    // POSTransactionEvents.OnAfterValidateCustomer(REC, LineRec, CurrInput, CustomerOrCardNo);
            //     if REC."Customer Order" then
            //         if not CustomerOrderHeader_Temp.IsEmpty() then
            //             COUtility.CustomerOrderUpdateCustomer(REC, CustomerOrderHeader_Temp, CustomerOrderLine_Temp, CustomerOrderDiscountLine_Temp);

            exit(true);
        end else begin
            SetPOSState("LSC POS Transaction State"::SALES);
            // SetFunctionMode("LSC POS Command"::ITEM);
            //InfoTextDescription := '';
            InfoTextDescription2 := '';
            CurrInput := '';
            CustomerOrCardNo := '';
            REC."Customer No." := '';
            REC.Modify;
            CleanupCustomer;
            exit(false);
        end;
    end;

    procedure ProcessCustomer(pChangeState: Boolean)
    var
        POSTransLine2: Record "LSC POS Trans. Line";
        POSTransPerDisc: Record "LSC POS Trans. Per. Disc. Type";
        DT: Record "LSC POS Trans. Per. Disc. Type";
        OfferPosCalc: Record "LSC Offer Pos Calculation";
        PosPriceUtil: Codeunit "LSC POS Price Utility";
        // POSPrepaymentUtil: Codeunit "LSC POS Prepayment Mgt.";
        DealPricingFunctions: Codeunit "LSC Deal Pricing Functions";
        xCustomerDiscGroup: Code[20];
        OldBalance: Decimal;
        lPrice: Decimal;
        lQty: Decimal;
        OfferType: Enum "LSC POS Trans. Per. Disc. Type";
        LastLineNo: Integer;
        PromOnCustDiscGroup: Boolean;
        CustMsg: Label 'Cust: ';
        CustAccPostingNotAllowedErr: Label 'Customer Account posting is not allowed\Use different tender type.';
        IsHandled: Boolean;
    begin
        REC."Customer No." := Customer."No.";
        // POSTransactionEvents.OnBeforeProcessCustomer(REC);
        if not REC."VAT by InfoCode" then begin
            if Customer."VAT Bus. Posting Group" = '' then
                REC."VAT Bus.Posting Group" := StoreSetup."Store VAT Bus. Post. Gr."
            else
                REC."VAT Bus.Posting Group" := Customer."VAT Bus. Posting Group";
            if Customer."Gen. Bus. Posting Group" = '' then
                REC."Gen. Bus. Posting Group" := StoreSetup."Store Gen. Bus. Post. Gr."
            else
                REC."Gen. Bus. Posting Group" := Customer."Gen. Bus. Posting Group";
        end;

        xCustomerDiscGroup := REC."Customer Disc. Group";
        REC."Customer Disc. Group" := Customer."Customer Disc. Group";
        REC.Modify;
        if REC."Customer No." <> '' then
            InfoTextDescription := StrSubstNo('%1 %2', Customer."No.", Customer.Name);
        CalcTotals;
        OldBalance := Balance;

        if REC."Customer No." <> '' then begin
            POSTransLine2.Reset;
            POSTransLine2.SetRange("Receipt No.", REC."Receipt No.");
            POSTransLine2.SetRange("Entry Type", POSTransLine2."Entry Type"::FreeText);
            POSTransLine2.SetRange("Entry Status", 0);
            POSTransLine2.SetFilter("Card/Customer/Coup.Item No", '<>%1', '');
            POSTransLine2.SetRange("Text Type", POSTransLine2."Text Type"::"Cust. Text");
            if POSTransLine2.FindFirst then
                POSTransLine2.Delete(true);
            POSTransLine2.SetRange("Entry Type");
            POSTransLine2.SetRange("Card/Customer/Coup.Item No");
            POSTransLine2.SetRange("Entry Status");
            POSTransLine2.SetRange("Text Type");
            if POSTransLine2.FindLast then
                LastLineNo := POSTransLine2."Line No."
            else
                LastLineNo := 0;
            POSTransLine2.Init;
            POSTransLine2."Receipt No." := REC."Receipt No.";
            POSTransLine2."Store No." := REC."Store No.";
            POSTransLine2."POS Terminal No." := REC."POS Terminal No.";
            POSTransLine2."Line No." := LastLineNo + 10000;
            POSTransLine2.Description := CopyStr(CustMsg + Customer.Name, 1, MaxStrLen(POSTransLine2.Description));
            POSTransLine2."Entry Type" := POSTransLine2."Entry Type"::FreeText;
            POSTransLine2."Card/Customer/Coup.Item No" := Customer."No.";
            POSTransLine2."Text Type" := POSTransLine2."Text Type"::"Cust. Text";
            POSTransLine2.Insert(true);
            //Insert Prepayment info.
            if not PosFuncProfile."Disable POS Prepayment" then begin
                POSTransLine2.Reset;
                POSTransLine2.SetRange("Receipt No.", REC."Receipt No.");
                POSTransLine2.SetRange("Entry Type", POSTransLine2."Entry Type"::Item);
                if POSTransLine2.FindSet then begin
                    repeat
                    // POSPrepaymentUtil.SetPosTransLinePrepaymentPct(POSTransLine2);
                    // POSTransLine2.Modify(true);
                    until POSTransLine2.Next = 0;
                end;
            end;
        end
        else begin
            POSTransactionEvents.OnBeforeClearPrepaymentFromCustomer(Rec, Customer, StoreSetup);

            //Clear prepayment that originate from Customer
            if not PosFuncProfile."Disable POS Prepayment" then begin
                POSTransLine2.Reset;
                POSTransLine2.SetRange("Receipt No.", REC."Receipt No.");
                POSTransLine2.SetRange("Entry Type", POSTransLine2."Entry Type"::Item);
                if POSTransLine2.FindSet then begin
                    repeat
                        POSTransLine2."Prepayment %" := 0;
                        POSTransLine2."Prepmt. Line Amount" := 0;
                        POSTransLine2."Prepayment Line" := false;
                        POSTransLine2.Modify(true);
                    until POSTransLine2.Next = 0;
                end;
            end;
        end;

        POSTransPerDisc.Reset;
        POSTransPerDisc.SetCurrentKey(DiscType);
        POSTransPerDisc.SetRange(DiscType, POSTransPerDisc.DiscType::Customer);
        POSTransPerDisc.SetRange("Receipt No.", REC."Receipt No.");
        PosFunc.PosTransDiscSetTableFilter(1, POSTransPerDisc);
        if PosFunc.PosTransDiscFindRec(1, '-', POSTransPerDisc) then begin
            repeat
                POSTransLine2.Get(POSTransPerDisc."Receipt No.", POSTransPerDisc."Line No.");
                PosPriceUtil.InsertTransDiscPercent(POSTransLine2, 0, POSTransPerDisc.DiscType::Customer, '');
                POSTransLine2.CalcPrices;
            // if not PosFuncProfile."Disable POS Prepayment" then
            //     POSPrepaymentUtil.SetPosTransLinePrepaymentPct(POSTransLine2);
            // POSTransLine2.Modify(true);
            until PosFunc.PosTransDiscNextRec(1, 1, POSTransPerDisc) = 0;
        end;

        //    PosFunc.ChangeGenBusPostingGroup(REC);

        //  POSTransactionEvents.OnBeforePosFuncChangeVATBusOnLine(Rec, Customer, PosFunc, IsHandled);
        if not IsHandled then
            PosFunc.ChangeVATBusOnLine(REC);

        if REC."Customer Disc. Group" <> xCustomerDiscGroup then begin
            // POSTransactionEventsPub.OnDifferentDiscGroup(REC);
            PromOnCustDiscGroup := PosPriceUtil.IsPromotionForCustDiscGroup(REC."Customer Disc. Group", REC);
            POSTransLine2.Reset;
            POSTransLine2.SetRange("Receipt No.", REC."Receipt No.");
            POSTransLine2.SetRange("Entry Type", POSTransLine2."Entry Type"::Item);
            if POSTransLine2.FindSet then
                repeat
                    Clear(OfferPosCalc);
                    OfferPosCalc.SetRange("Receipt No.", POSTransLine2."Receipt No.");
                    OfferPosCalc.SetRange("Trans. Line No.", POSTransLine2."Line No.");
                    OfferPosCalc.DeleteAll;

                    // POSTransactionEvents.OnAfterOfferPosCalcDeletAllProcessCustomer(POSTransLine2);

                    PosPriceUtil.InsertTransDiscPercent(POSTransLine2, 0, POSTransPerDisc.DiscType::"Periodic Disc.", '');
                    if PromOnCustDiscGroup then begin
                        lPrice := POSTransLine2.Price;
                        lQty := POSTransLine2.Quantity;
                        PosPriceUtil.InsertTransDiscPercent(POSTransLine2, 0, DT.DiscType::"Periodic Disc.", '');
                        if not POSTransLine2."Deal Line" then
                            POSTransLine2."Promotion No." := '';
                        POSTransLine2."Mix & Match Line No." := 0;
                        PosPriceUtil.InsertTransDiscAmount(POSTransLine2, 0, DT.DiscType::"Periodic Disc.", '');
                        if not POSTransLine2."Price Change" then
                            PosPriceUtil.CalcPrice(POSTransLine2, false);
                        if (lPrice <> POSTransLine2.Price) then begin
                            POSTransLine2.Validate(Quantity, lQty);
                            POSTransLine2.Modify(true);
                        end;
                    end;
                    PosFunc.ClearPosTransLineOffers(POSTransLine2);
                    PosPriceUtil.InitGlobals(POSTransLine2, true);
                    PosPriceUtil.FindPeriodicOffers(POSTransLine2);
                    PosFunc.AddPosTransLineOffers(POSTransLine2);
                    POSTransLine2.Modify(true);
                until POSTransLine2.Next = 0;
            PosPriceUtil.CalcPeriodicOnTotalPressed(REC);
        end;

        //DealPricingFunctions.DealPricing_UpdatePricingForDealsInTransaction(REC);

        PosFunc.RecalcSlip(REC);
        if (not REC."New Transaction") and (STATE <> "LSC POS Transaction State"::SALES) then
            PosOfferExt.ReCalcOfferSeq(REC, OfferType::"Total Discount");

        REC."Post as Shipment" := Customer."LSC Post as Shipment";
        REC.Modify;
        Commit;

        // if (not REC."New Transaction") and (STATE <> "LSC POS Transaction State"::SALES) then
        //     ProcessAddBenefits(GetFunctionModeEnum);

        if REC."Customer No." = '' then
            exit;

        CalcTotals;
        if not REC."New Transaction" then begin
            if OldBalance <> Balance then begin
                DisplayTotals;
                PosTransactionGui.MessageBeep(NewCustPrices);
                // if pChangeState then begin
                //     SetPOSState("LSC POS Transaction State"::PAYMENT);
                //    // SetFunctionMode("LSC POS Command"::PAYMENT);
                // end else
                //     SetFunctionMode("LSC POS Command"::ITEM);

                SelectDefaultMenu;
                exit;
            end;
            if not KeyboardAmount then
                PaymentAmount := Balance;
            if not OnlySelectCustomer then
                if PaymentAmount <> 0 then
                    if not Customer."LSC Other Tender in Finalizing" then begin
                        InsertPaymentLine;
                        exit;
                    end else
                        PosTransactionGui.ErrorBeep(CustAccPostingNotAllowedErr);
            // if pChangeState then begin
            //     SetPOSState("LSC POS Transaction State"::PAYMENT);
            //     SetFunctionMode("LSC POS Command"::PAYMENT);
            // end else
            //     SetFunctionMode("LSC POS Command"::ITEM);
        end
        else
            if StartingPaymentsIntoAccount then begin
                REC."Transaction Type" := REC."Transaction Type"::Payment;
                StartNewTransaction;
                InitNewLine;
                // if pChangeState then begin
                //     SetPOSState("LSC POS Transaction State"::PAYMENT);
                //     SetFunctionMode("LSC POS Command"::PAYMENT);
                // end;
                InsertPaymentLine;
                SelectDefaultMenu;
            end else
                SalePressed(true);
        StartingPaymentsIntoAccount := false;
        OnlySelectCustomer := false;
    end;

    procedure TestCustomer(CustomerNo: Code[20]; KeyboardAmount: Boolean; Charge: Boolean): Boolean
    var
        Text118: Label 'Use other tender for account %1';
    begin
        if not Customer.Get(CustomerNo) then
            Clear(Customer);
        if Customer."LSC Other Tender in Finalizing" then begin
            if KeyboardAmount or Charge then begin
                PosTransactionGui.ErrorBeep(StrSubstNo(Text118, CustomerNo));
                //SetFunctionMode("LSC POS Command"::PAYMENT);
                exit(false);
            end;
            PaymentAmount := 0;
        end;
        exit(true);
    end;

    procedure PaymentIntoAccountPressed(Tender: Code[10])
    begin
        if not TestNewTransaction then
            exit;

        if CurrInput = '' then begin
            CurrentTenderTypeCode := Tender;
            OpenNumericKeyboard(AmountMsg, 0, '', Enum::"LSC POS Trans. Numpad Trigger"::PaymentIntoAccountPressed.AsInteger());
            exit;
        end;
        if not Evaluate(PaymentAmount, CurrInput) then begin
            PosTransactionGui.ErrorBeep(InvalidAmtValueErr);
            exit;
        end;

        if PaymentAmount <= 0 then begin
            PosTransactionGui.ErrorBeep(InvalidAmtValueErr);
            exit;
        end;
        if not TenderType.Get(StoreSetup."No.", Tender)
          or (TenderType."Function" <> TenderType."Function"::Customer) then begin
            PosTransactionGui.ErrorBeep(StrSubstNo(InvalidErr, TenderType.TableCaption));
            exit;
        end;
        //PosFunc.AdjustAmount(PaymentAmount);
        POSTransactionEvents.OnAfterAdjustAmount(TenderType, Rec, PaymentAmount);
        PaymentAmount := -PaymentAmount;
        StartingPaymentsIntoAccount := true;

        REC.Modify;
        Commit;
        if (REC."Customer No." = '') and (PaymentIntoAccountMenuLine.Command <> '') then
            RunCommand(PaymentIntoAccountMenuLine);
        AskForCustomer;
    end;

    procedure IncExpLine()
    var
        IncExpFixedAmount: Record "LSC Income/Expense Fixed Amt.";
        Proceed: Boolean;
        IncExpAccNoMissingErr: Label 'Income/Expence Account Number missing';
    begin
        if not IncExpAccount.Get(REC."Store No.", IncExpAccNo) then begin
            PosTransactionGui.ErrorBeep(IncExpAccNoMissingErr);
            exit;
        end;
        if SaleIsReturnSale and (IncExpAccount."Account Type" = IncExpAccount."Account Type"::Income) then begin
            PosTransactionGui.ErrorBeep(RefundGiftCardSale);
            exit;
        end;
        if IncExpAccount."Foreign Currency" then begin
            REC."Trans. Date" := Today;
            REC."Currency Factor" := 1;
            // SetFunctionMode("LSC POS Command"::CURRENCY);
            exit;
        end;
        Proceed := true;
        POSTransactionEvents.OnAfterValidateIncExpLine(REC, LineRec, CurrInput, Proceed, IncExpAccount);
        if not Proceed then
            exit;
        if CurrInput = '' then begin
            IncExpFixedAmount.Reset;
            IncExpFixedAmount.SetRange("Store No.", IncExpAccount."Store No.");
            IncExpFixedAmount.SetRange("No.", IncExpAccount."No.");
            if not IncExpFixedAmount.IsEmpty then begin
                FindIncExpFixedAmount(IncExpAccount."No.");
                exit;
            end else begin
                PosTransactionGui.OpenNumericKeyboard(AmountMsg, '', Enum::"LSC POS Trans. Numpad Trigger"::IncExpLine);
                exit;
            end;
        end else
            IncExpLineEx;
    end;

    procedure IncExpLineEx()
    var
        COPOSFunctions: Codeunit "LSC CO POS Functions";
    begin
        if CurrInput = '' then begin
            PosTransactionGui.ErrorBeep(AmtEntryRequiredErr);
            exit;
        end;

        if not Evaluate(PaymentAmount, CurrInput) then begin
            PosTransactionGui.ErrorBeep(InvalidAmtValueErr);
            exit;
        end;

        // PosFunc.AdjustAmount(PaymentAmount);
        if IncExpAccount."Account Type" = IncExpAccount."Account Type"::Expense then
            if not REC."New Transaction" then
                PaymentAmount := -PaymentAmount
            else
                if PosFuncProfile."Sales Person Mode" <> PosFuncProfile."Sales Person Mode"::Automatic then
                    PaymentAmount := -PaymentAmount;

        if REC."New Transaction" then begin
            SalePressed(false);
            if CheckInfoCode('START') then
                exit;
        end;
        if FunctionSetup."Function Code" = Format("LSC POS Command"::SALESP) then begin
            CurrInput := '';
            exit;
        end;
        InitNewLine;
        InsertIncExpLine;
        if (REC."Customer Order ID" <> '') and (CustomerOrderHeader_Temp."Member Card No." <> '') then
            InputMemberCard(CustomerOrderHeader_Temp."Member Card No.");
    end;

    procedure InsertIncExpLine()
    var
        IsHandled: Boolean;
    begin
        POSTransactionEvents.OnBeforeIncExpLine(REC, NewLine, CurrInput);

        NewLine."Entry Type" := NewLine."Entry Type"::IncomeExpense;
        NewLine.Validate(Number, IncExpAccount."No.");

        POSTransactionEvents.OnBeforeInsertIncExpLineValidateAmount(NewLine, PaymentAmount, IsHandled);
        if not IsHandled then
            NewLine.Validate(Amount, PaymentAmount);

        if IncExpAccount."Foreign Currency" and (Currency.Code <> '') then begin
            NewLine."Currency Code" := Currency.Code;
            NewLine."Amount In Currency" := AmountInCurrency;
            NewLine.Description :=
              NewLine.Description + ' ' + Currency.Code + ' '
              + PosFunc.FormatCurrency(NewLine."Amount In Currency", Currency.Code);
        end;

        NewLine.InsertLine;
        Commit;
        LineRec := NewLine;
        POSLINES.SetCurrentLine(LineRec);
        WriteMgrStatus;

        OposUtil.DisplaySalesLine(LineRec.Number, LineRec.Description, LineRec.Quantity,
          LineRec.Price, LineRec.Amount, LineRec."Unit of Measure", true);

        CalcTotals;
        IncExpAccNo := '';
        CurrInput := '';
        InfoTextDescription := StrSubstNo('%1 %2', LineRec.Description, FormatAmount(NewLine.Amount));
        InfoTextDescription2 := '';

        POSTransactionEvents.OnAfterIncExpLine(REC, LineRec, CurrInput);

        CheckInfoCode('INCEXP');
    end;

    procedure ValidateDate()
    var
        Int: Integer;
        DateRequiresFourDigitsErr: Label 'Date must be entered as 4 digits';
        DateDDMMMsg: Label 'Date DDMM';
    begin
        if CurrInput = '' then begin
            PosTransactionGui.OpenNumericKeyboard(DateDDMMMsg, '', Enum::"LSC POS Trans. Numpad Trigger"::ValidateDate);
            exit;
        end;

        if (StrLen(CurrInput) <> 4) or not Evaluate(Int, CurrInput) then begin
            PosTransactionGui.ErrorBeep(DateRequiresFourDigitsErr);
            exit;
        end;
        EFT.SetExpiryDate(CurrInput);
        NextCardPhase;
    end;

    procedure ValidateControl()
    var
        CtrlMsg: Label 'Control';
        ErrorTxt: Text;
    begin
        if CurrInput = '' then begin
            PosTransactionGui.OpenNumericKeyboard(CtrlMsg, '', Enum::"LSC POS Trans. Numpad Trigger"::ValidateControl);
            exit;
        end;
        if not EFT.ValidateControl(CurrInput, ErrorTxt) then begin
            PosTransactionGui.ErrorBeep(ErrorTxt);
            exit;
        end;
        NextCardPhase;
    end;

    procedure ValidatePassword()
    var
        PwdMsg: Label 'Password';
    begin
        if CurrInput = '' then begin
            PosTransactionGui.OpenNumericKeyboard(PwdMsg, '', Enum::"LSC POS Trans. Numpad Trigger"::ValidatePassword);
            exit;
        end;
        EFT.SetPassword(CurrInput);
        NextCardPhase;
    end;

    procedure ValidateDisc(): Boolean
    var
        IsHandled: Boolean;
        ErrorDiscountOnDealItemLine: Label 'You can give line discount on the deal itself, not individual deal items.';
    begin
        if (STATE = "LSC POS Transaction State"::TENDOP) or REC."New Transaction" then begin
            PosTransactionGui.MessageBeep('');
            exit(false);
        end;

        POSLINES.GetCurrentLine(LineRec);

        if (LineRec."Deal Line") and (LineRec."Entry Type" = LineRec."Entry Type"::Item) then begin
            PosTransactionGui.ErrorBeep(ErrorDiscountOnDealItemLine);
            exit(false);
        end;

        if (LineRec."Text Type" = LineRec."Text Type"::"Deal Header") then begin
            if LineRec."System-Block Manual Discount" then begin
                PosTransactionGui.ErrorBeep(DiscNotAllowedForItemErr);
                exit(false);
            end;
            exit(true);
        end;

        if (LineRec.Number = '') or (LineRec."Entry Status" = LineRec."Entry Status"::Voided) or LineRec."Deal Line" then begin
            PosTransactionGui.MessageBeep('');
            exit(false);
        end;
        if LineRec."System-Block Manual Discount" then begin
            PosTransactionGui.ErrorBeep(DiscNotAllowedForItemErr);
            exit(false);
        end;

        IsHandled := false;
        POSTransactionEvents.OnAfterValidateDisc(LineRec, IsHandled);
        if IsHandled then
            exit(false);

        exit(true);
    end;

    procedure DiscPrPressed(Value: Text[30])
    var
        Dec: Decimal;
        DiscPercentMsg: Label 'Disc. %';
        IsHandled: Boolean;
    begin
        if Value <> '' then
            CurrInput := Value;
        if not ValidateDisc then
            exit;

        if CurrInput = '' then begin
            PosTransactionGui.OpenNumericKeyboard(DiscPercentMsg, '', Enum::"LSC POS Trans. Numpad Trigger"::DiscPrPressed);
            exit;
        end;

        if not Evaluate(Dec, CurrInput) or (Abs(Dec) > 100) then begin
            PosTransactionGui.ErrorBeep(InvalidValInPercentErr);
            exit;
        end;

        IsHandled := false;
        //POSTransactionEventsPub.OnBeforeDiscPrPressed(LineRec, IsHandled, Dec);
        if IsHandled then
            exit;

        if LineRec."Text Type" = LineRec."Text Type"::"Deal Header" then begin
            DiscPrPressedOnDeal(Dec);
            exit;
        end;

        if LineRec."Entry Type" = LineRec."Entry Type"::Item then
            if not POSSESSION.PermissionItem('DISC', LineRec.Number, Dec, 0, InfoTextDescription, POSSESSION.ManagerID, false) then begin
                PosTransactionGui.ErrorBeep(InfoTextDescription);
                exit;
            end;

        IsHandled := false;
        // POSTransactionEventsPub.OnAfterDiscPrPressed(LineRec, IsHandled);
        if IsHandled then
            exit;

        DiscPressedPercentage := true;
        DiscPrAmtPressedDec := Dec;
        if Dec > 0 then begin
            if CheckInfoCode('MARKDN') then
                exit;
        end else begin
            if Dec < 0 then
                if CheckInfoCode('MARKUP') then
                    exit;
        end;
        if (LineRec."Entry Type" = LineRec."Entry Type"::IncomeExpense) and (not LineRec."CO Prepayment Line") then begin
            GlobalMenuLine."Current-INPUT" := CurrInput;
            CurrInput := '';
            // POSTransactionEventsPub.OnBeforeValidateDiscIncomeExpence(LineRec, GlobalMenuLine)
        end else
            DiscPrPressedEx(Dec);
    end;

    procedure DiscPrPressedEx(Dec: Decimal)
    var
        DT: Record "LSC POS Trans. Per. Disc. Type";
        PosPriceUtil: Codeunit "LSC POS Price Utility";
        OldAmount: Decimal;
        LineDiscBefore: Boolean;
        LineDiscAfter: Boolean;
        LineDiscChange: Boolean;
    begin
        POSLINES.GetCurrentLine(LineRec);

        LineDiscBefore := PosOfferExt.TransLineDiscOfferTypeExists(LineRec, DT.DiscType::Line);
        PosPriceUtil.InsertTransDiscPercent(LineRec, 0, DT.DiscType::Line, '');
        LineRec.Validate(LineRec."Line Disc. %", 0);
        OldAmount := LineRec.Amount;
        //POSTransactionEventsPub.OnBeforeInsertTransDiscPercent(LineRec);
        PosPriceUtil.InsertTransDiscPercent(LineRec, Dec, DT.DiscType::Line, '');
        LineRec.Validate("Line Disc. %", Dec);
        LineDiscAfter := PosOfferExt.TransLineDiscOfferTypeExists(LineRec, DT.DiscType::Line);
        if LineDiscAfter then
            PosOfferExt.ProcessLinePreTotal(REC, LineRec, '');
        LineDiscChange := LineDiscBefore or LineDiscAfter;
        WriteMgrStatus;
        CalcTotals;
        CurrInput := '';
        if LineDiscChange then
            InfoTextDescription := DiscChangedMsg;
        OposUtil.DisplaySalesLine('', LineRec.Description, LineRec.Quantity, LineRec.Price, LineRec.Amount, LineRec."Unit of Measure", true);

        if LineDiscChange then begin
            if Abs(OldAmount) >= Abs(LineRec.Amount) then
                POSTransactionEvents.OnAfterDiscPrDiscountLine(REC, LineRec, CurrInput)
            else
                if Abs(OldAmount) < Abs(LineRec.Amount) then
                    POSTransactionEvents.OnAfterDiscPrNegativeDiscountLine(REC, LineRec, CurrInput);
        end;

        if not LineDiscChange then begin
            InfoUtil.RemoveInfoCode(LineRec, 'MARKDN');
            InfoUtil.RemoveInfoCode(LineRec, 'MARKUP');
        end;
    end;

    procedure DiscPrPressedOnDeal(Dec: Decimal)
    begin
        if not POSSESSION.PermissionDeal('DISC', LineRec."Promotion No.", Dec, 0, InfoTextDescription, POSSESSION.ManagerID, false) then begin
            PosTransactionGui.ErrorBeep(InfoTextDescription);
            exit;
        end;
        DiscDealPressedPercentage := true;
        DiscDealPressedAmount := False;
        DiscPrAmtPressedDec := Dec;
        if Dec > 0 then begin
            if CheckInfoCode('MARKDN') then
                exit;
        end else begin
            if Dec < 0 then
                if CheckInfoCode('MARKUP') then
                    exit;
        end;
        DiscPrPressedOnDealEx(DiscPrAmtPressedDec);
    end;

    procedure DiscPrPressedOnDealEx(Dec: Decimal)
    var
        DealPOSTransLine: Record "LSC POS Trans. Line";
        PosPriceUtil: Codeunit "LSC POS Price Utility";
        DealParentLineNo: Integer;
    begin
        POSLINES.GetCurrentLine(LineRec);
        DealParentLineNo := Linerec."Line No.";
        DiscDealPressedPercentage := false;

        DealPOSTransLine.SetRange("Receipt No.", LineRec."Receipt No.");
        DealPOSTransLine.SetRange("Parent Line", LineRec."Line No.");
        DealPOSTransLine.setrange("Deal Line", true);
        DealPOSTransLine.SetRange("Entry Type", DealPOSTransLine."Entry Type"::item);
        DealPOSTransLine.SetRange("Entry Status", DealPOSTransLine."Entry Status"::" ");
        if DealPOSTransLine.findset then
            repeat
                POSLINES.SetCurrentLine(DealPOSTransLine);
                DiscPrPressedEx(Dec);
            until DealPOSTransLine.next = 0;

        DealPOSTransLine.get(REC."Receipt No.", DealParentLineNo);
        // PosPriceUtil.RegisterDeal(DealPOSTransLine);
    end;

    procedure DiscAmPressed(Value: Text[30]; PayAmount: Boolean)
    var
        DT: Record "LSC POS Trans. Per. Disc. Type";
        PosPriceUtil: Codeunit "LSC POS Price Utility";
        COUtility: Codeunit "LSC CO Utility";
        OldAmount: Decimal;
        OldLineDiscountAmt: Decimal;
        DecPr: Decimal;
        AmDec: Decimal;
        AmountToDisc: Decimal;
        IsHandled, ExitProcedure : Boolean;
        DiscAmtMsg: Label 'Disc. Amt.';
    begin
        if Value <> '' then
            CurrInput := Value;

        if not ValidateDisc then
            exit;

        if CurrInput = '' then begin
            if PayAmount then
                PosTransactionGui.OpenNumericKeyboard(PaymAmtMsg, '', Enum::"LSC POS Trans. Numpad Trigger"::"DiscAmPressed - Payment Discount")
            else
                PosTransactionGui.OpenNumericKeyboard(DiscAmtMsg, '', Enum::"LSC POS Trans. Numpad Trigger"::"DiscAmPressed - Item Discount");
            exit;
        end;

        if not Evaluate(AmDec, CurrInput) then begin
            PosTransactionGui.ErrorBeep(InvalidAmtValueErr);
            exit;
        end;

        // PosFunc.AdjustAmount(AmDec);
        // POSTransactionEventsPub.OnAfterAdjustAmount(LineRec, AmDec, PayAmount);

        IsHandled := false;
        //POSTransactionEventsPub.OnDiscAmtPressed(LineRec, IsHandled, DecPR, PayAmount, CurrInput);
        if IsHandled then
            exit;

        if LineRec."Text Type" = LineRec."Text Type"::"Deal Header" then begin
            DiscAmtPressedOnDeal(AmDec, PayAmount);
            exit;
        end;

        //OldLineDiscountAmt := PosPriceUtil.GetTransLineDiscAmountByType(LineRec, DT.DiscType::Line.AsInteger());
        OldAmount := LineRec.Amount + OldLineDiscountAmt;

        if PayAmount then begin
            AmDec := OldAmount - AmDec;
            if AmDec < 0 then begin
                PosTransactionGui.ErrorBeep(DiscHigherThanAmtErr);
                exit;
            end;
        end;

        if Abs(AmDec) > Abs(OldAmount) then begin
            PosTransactionGui.ErrorBeep(DiscHigherThanAmtErr);
            exit;
        end;

        if OldAmount <> 0 then begin
            if OldAmount < 0 then
                AmDec := -AmDec;
            AmountToDisc := DiscAmountGetAmountToDiscount(LineRec);
            DecPr := PosPriceUtil.DiscAmountGetPercentage(AmDec, AmountToDisc);
        end else
            DecPr := 0;
        if LineRec."Entry Type" = LineRec."Entry Type"::Item then begin
            IsHandled := false;
            POSTransactionEvents.OnBeforeCheckPermissionItemOnDiscAmPressed(LineRec, OldAmount, AmDec, InfoTextDescription, AmountToDisc, IsHandled, ExitProcedure);
            if not IsHandled then begin
                if not POSSESSION.PermissionItem('DISC', LineRec.Number, DecPr, 0, InfoTextDescription, POSSESSION.ManagerID, false) then begin
                    PosTransactionGui.ErrorBeep(InfoTextDescription);
                    exit;
                end;
            end else
                if ExitProcedure then begin
                    PosTransactionGui.ErrorBeep(InfoTextDescription);
                    exit;
                end;
        end;
        IsHandled := false;
        //POSTransactionEventsPub.OnDiscAmtPressed(LineRec, IsHandled, DecPR, PayAmount, CurrInput);
        if IsHandled then
            exit;

        DiscPressedPercentage := false;
        DiscPrAmtPressedDec := DecPr;

        if (DecPr > 0) then begin
            if CheckInfoCode('MARKDN') then
                exit;
        end else
            if (DecPr < 0) then
                if CheckInfoCode('MARKUP') then
                    exit;
        if LineRec."Entry Type" = LineRec."Entry Type"::IncomeExpense then begin
            GlobalMenuLine."Current-INPUT" := CurrInput;
            CurrInput := '';
            // POSTransactionEventsPub.OnBeforeValidateDiscIncomeExpence(LineRec, GlobalMenuLine)
        end else
            DiscAmPressedEx(DecPr);

        if REC."Customer Order" then
            COUtility.UpdateOrderLines(REC, CustomerOrderLine_Temp, CustomerOrderDiscountLine_Temp, CustomerOrderHeader_Temp);
    end;

    local procedure DiscAmountGetAmountToDiscount(POSTransLine: Record "LSC POS Trans. Line"): Decimal
    var
        PosPriceUtil: Codeunit "LSC POS Price Utility";
        AmountToDisc: Decimal;
        CustDiscAmount: Decimal;
    begin
        AmountToDisc := 0;

        PosPriceUtil.GetTransDisc(POSTransLine, true, "LSC POS Trans. Per. Disc. Type"::"Periodic Disc.");

        AmountToDisc := POSTransLine.Price * POSTransLine.Quantity;
        POSTransactionEvents.OnAfterCalculateAmountToDiscDiscAmountGetAmountToDiscount(POSTransLine, AmountToDisc);

        CustDiscAmount := Round((POSTransLine."Customer Disc. %" / 100) * AmountToDisc);
        AmountToDisc := AmountToDisc - POSTransLine."Periodic Discount Amount" - CustDiscAmount;

        exit(AmountToDisc);
    end;

    procedure DiscAmPressedEx(DecPr: Decimal)
    var
        DT: Record "LSC POS Trans. Per. Disc. Type";
        PosPriceUtil: Codeunit "LSC POS Price Utility";
        OldAmount: Decimal;
        OldLineDiscountAmt: Decimal;
        LineDiscBefore: Boolean;
        LineDiscAfter: Boolean;
        LineDiscChange: Boolean;
    begin
        POSLINES.GetCurrentLine(LineRec);

        //OldLineDiscountAmt := PosPriceUtil.GetTransLineDiscAmountByType(LineRec, DT.DiscType::Line.AsInteger());
        OldAmount := LineRec.Amount + OldLineDiscountAmt;
        LineDiscBefore := (OldLineDiscountAmt <> 0);

        PosPriceUtil.InsertTransDiscPercent(LineRec, DecPr, DT.DiscType::Line, '');
        LineRec.Validate(LineRec."Line Disc. %", DecPr);
        LineDiscAfter := PosOfferExt.TransLineDiscOfferTypeExists(LineRec, DT.DiscType::Line);
        if LineDiscAfter then
            PosOfferExt.ProcessLinePreTotal(REC, LineRec, '');
        LineDiscChange := LineDiscBefore or LineDiscAfter;
        PosPriceUtil.SetTransLineDiscAsAmountBased(LineRec, DT.DiscType::Line);
        WriteMgrStatus;
        CalcTotals;
        CurrInput := '';
        if LineDiscChange then
            InfoTextDescription := DiscChangedMsg;
        OposUtil.DisplaySalesLine('', LineRec.Description, LineRec.Quantity, LineRec.Price, LineRec.Amount, LineRec."Unit of Measure", false);

        if LineDiscChange then begin
            if Abs(OldAmount) >= Abs(LineRec.Amount) then
                POSTransactionEvents.OnAfterDiscAmDiscountLine(REC, LineRec, CurrInput)
            else
                if Abs(OldAmount) < Abs(LineRec.Amount) then
                    POSTransactionEvents.OnAfterDiscAmNegativeDiscountLine(REC, LineRec, CurrInput);
        end;

        if not LineDiscChange then begin //Clear Infocode MARKDN / MARKUP
            InfoUtil.RemoveInfoCode(LineRec, 'MARKDN');
            InfoUtil.RemoveInfoCode(LineRec, 'MARKUP');
        end;
    end;

    procedure DiscAmtPressedOnDeal(DiscAmt: Decimal; PayAmount: Boolean)
    var
        DT: Record "LSC POS Trans. Per. Disc. Type";
        DealPOSTransLine: Record "LSC POS Trans. Line";
        PosPriceUtil: Codeunit "LSC POS Price Utility";
        OldAmount: Decimal;
        OldLineDiscountAmt: Decimal;
        LinesOldAmount: Decimal;
        DiscPr: Decimal;
        AmountToDisc: Decimal;
        LinesAmountToDisc: Decimal;
    begin
        DealPOSTransLine.SetRange("Receipt No.", LineRec."Receipt No.");
        DealPOSTransLine.SetRange("Parent Line", LineRec."Line No.");
        DealPOSTransLine.setrange("Deal Line", true);
        DealPOSTransLine.SetRange("Entry Type", DealPOSTransLine."Entry Type"::item);
        DealPOSTransLine.SetRange("Entry Status", DealPOSTransLine."Entry Status"::" ");
        if DealPOSTransLine.findset then
            repeat
                //OldLineDiscountAmt := PosPriceUtil.GetTransLineDiscAmountByType(DealPOSTransLine, DT.DiscType::Line.AsInteger());
                OldAmount := DealPOSTransLine.Amount + OldLineDiscountAmt;
                LinesOldAmount += OldAmount;

                AmountToDisc := DiscAmountGetAmountToDiscount(DealPOSTransLine);
                LinesAmountToDisc += AmountToDisc;
            until DealPOSTransLine.next = 0;

        if PayAmount then begin
            DiscAmt := LinesOldAmount - DiscAmt;
            if DiscAmt < 0 then begin
                PosTransactionGui.ErrorBeep(DiscHigherThanAmtErr);
                exit;
            end;
        end;

        if Abs(DiscAmt) > Abs(LinesOldAmount) then begin
            PosTransactionGui.ErrorBeep(DiscHigherThanAmtErr);
            exit;
        end;

        if LinesOldAmount <> 0 then begin
            if LinesOldAmount < 0 then
                DiscAmt := -DiscAmt;
            DiscPr := PosPriceUtil.DiscAmountGetPercentage(DiscAmt, LinesAmountToDisc);
        end else
            DiscPr := 0;

        if not POSSESSION.PermissionDeal('DISC', LineRec."Promotion No.", DiscPr, 0, InfoTextDescription, POSSESSION.ManagerID, false) then begin
            PosTransactionGui.ErrorBeep(InfoTextDescription);
            exit;
        end;

        DiscDealPressedPercentage := false;
        DiscDealPressedAmount := true;
        DiscPrAmtPressedDec := DiscAmt;
        if DiscPr > 0 then begin
            if CheckInfoCode('MARKDN') then
                exit;
        end else begin
            if DiscPr < 0 then
                if CheckInfoCode('MARKUP') then
                    exit;
        end;

        DiscAmtPressedOnDealEx(DiscAmt);
    end;

    local procedure DiscAmtPressedOnDealEx(DiscAmt: Decimal)
    var
        DealPOSTransLine: Record "LSC POS Trans. Line";
        PosPriceUtil: Codeunit "LSC POS Price Utility";
        DealLineDiscPr: Decimal;
        DealLinePortionPr: Decimal;
        DealLineDiscAmt: Decimal;
        DealAmount: Decimal;
        DiscAmtProcessed: Decimal;
        DealLineAmountToDisc: Decimal;
        NoOfDealLines: Integer;
        DealLineCount: Integer;
        DealParentLineNo: Integer;
    begin
        DiscDealPressedPercentage := false;
        DiscDealPressedAmount := false;
        DealParentLineNo := LineRec."Line No.";
        DealAmount := LineRec.Amount + LineRec."Discount Amount";
        DealPOSTransLine.SetRange("Receipt No.", LineRec."Receipt No.");
        DealPOSTransLine.SetRange("Parent Line", LineRec."Line No.");
        DealPOSTransLine.setrange("Deal Line", true);
        DealPOSTransLine.SetRange("Entry Type", DealPOSTransLine."Entry Type"::item);
        DealPOSTransLine.SetRange("Entry Status", DealPOSTransLine."Entry Status"::" ");
        NoOfDealLines := DealPOSTransLine.count;
        if DealPOSTransLine.findset then
            repeat
                DealLineCount += 1;
                DealLineAmountToDisc := DiscAmountGetAmountToDiscount(DealPOSTransLine);

                if DealLineCount = NoOfDealLines then begin
                    DealLineDiscAmt := DiscAmt - DiscAmtProcessed;
                    DealLineDiscPr := PosPriceUtil.DiscAmountGetPercentage(DealLineDiscAmt, DealLineAmountToDisc);
                end else begin
                    DealLinePortionPr := PosPriceUtil.DiscAmountGetPercentage(DealLineAmountToDisc, DealAmount);

                    if DealLineAmountToDisc <> 0 then begin
                        DealLineDiscAmt := PosPriceUtil.DiscAmountGetAmount(DealLinePortionPr, DiscAmt);
                        if DiscAmtProcessed + DealLineDiscAmt > DiscAmt then
                            DealLineDiscAmt := DiscAmt - DiscAmtProcessed;
                        DiscAmtProcessed += DealLineDiscAmt;

                        DealLineDiscPr := PosPriceUtil.DiscAmountGetPercentage(DealLineDiscAmt, DealLineAmountToDisc);
                    end else
                        DealLineDiscPr := 0;
                end;

                POSLINES.SetCurrentLine(DealPOSTransLine);
                DiscAmPressedEx(DealLineDiscPr);
            until DealPOSTransLine.next = 0;

        DealPOSTransLine.get(REC."Receipt No.", DealParentLineNo);
        //PosPriceUtil.RegisterDeal(DealPOSTransLine);
    end;

    procedure DiscResetPressed()
    var
        COUtility: Codeunit "LSC CO Utility";
        ClearDiscQst: Label 'Do you want to clear discounts for the line?';
        ErrorDeal: Label 'You cannot reset discounts for a deal.';
    begin
        if not ValidateDisc then
            exit;

        if LineRec."Text Type" = LineRec."Text Type"::"Deal Header" then begin
            PosTransactionGui.ErrorBeep(ErrorDeal);
            exit;
        end;

        if LineRec."Discount %" = 0 then begin
            PosTransactionGui.MessageBeep('');
            exit;
        end;

        if not POSSESSION.PermissionItem('DISC', LineRec.Number, 0, 0, InfoTextDescription, POSSESSION.ManagerID, false) then begin
            PosTransactionGui.ErrorBeep(InfoTextDescription);
            exit;
        end;

        if not PosTransactionGui.PosConfirm(ClearDiscQst, false) then
            exit;

        PosFunc.DiscReset(LineRec);
        UpdateVoucherEntries(LineRec);
        //LineRec.UpdateDataEntry();
        WriteMgrStatus;
        CalcTotals;
        CurrInput := '';
        InfoTextDescription := DiscChangedMsg;
        OposUtil.DisplaySalesLine('', LineRec.Description, LineRec.Quantity, LineRec.Price, LineRec.Amount, LineRec."Unit of Measure", true);

        if REC."Customer Order" then
            COUtility.UpdateOrderLines(REC, CustomerOrderLine_Temp, CustomerOrderDiscountLine_Temp, CustomerOrderHeader_Temp);

        // POSTransactionEvents.OnAfterDiscResetPressed(REC, LineRec);
    end;

    procedure ChangeQtyPressed(Value: Text[30])
    var
        LinkedLine: Record "LSC POS Trans. Line";
        LinkedItem: Record "LSC Linked Item";
        KDSFunctions: Codeunit "LSC KDS Functions";
        ErrorText: Text[250];
        Dec: Decimal;
        Dec1: Decimal;
        Factor: Decimal;
        OldQty: Decimal;
        QtyNotPrinted: Decimal;
        QtyToReduce: Decimal;
        CurrInputDec: Decimal;
        PrintLineVoided, ManualQuantity, LinesFound, Proceed, IsHandled : Boolean;
        ErrorPrintMsg: Label 'Line is printed to kitchen. Manager key is required for reducing quantity.';
        QtyChangeIsNotAllowedOnScaleItems: Label 'Quantity change is not allowed on scale items.';
        QtyOnlyOnSalesLinesErr: Label 'Quantity can only be changed on sales line';
        SalesAndReturnsNotAllowedErr: Label 'Sales and returns are not allowed in the same transaction';
        NoChangeQtyErr: Label 'Cannot change quantity in this state';
        ChangeQtyMsg: Label 'Change qty';
        QtyCantChangeOnDealsErr: Label 'Quantity can''t be changed on Deals. Add new Deal(s) or void the line.';
        NoChangeQtyForLineErr: Label 'Quantity cannot be changed for this line';
        QtyNoChangeForLinkedItemsErr: Label 'Qty. cannot be changed for lines with linked items';
        QtyNoNegativeToKitchenErr: Label 'Quantity cannot be negative on a line that has been printed to kitchen.';
        OrderSentToResNoQtyChangeErr: Label 'The order has been sent to the restaurant. You cannot change quantity on the line.';
        QtyCannotBeChangedErr: Label 'Quantity cannot be changed on this line';
        NegQtyChangeOnReturnSale: Label 'Quantity cannot be negative when Sale is Return Sale.';
    begin
        if Value <> '' then
            CurrInput := Value;

        if (STATE = "LSC POS Transaction State"::TENDOP) or REC."New Transaction" then begin
            PosTransactionGui.ErrorBeep(NoChangeQtyErr);
            exit;
        end;
        ManualQuantity := false;
        Clear(LineRec);

        Proceed := true;
        //POSTransactionEventsPub.OnBeforeValidateChangeQty(REC, LineRec, CurrInput, Proceed, ErrorText);
        if not Proceed then begin
            PosTransactionGui.ErrorBeep(ErrorText);
            exit;
        end;

        POSLINES.GetCurrentLine(LineRec);

        if not CheckBillPrinted then
            exit;

        if LineRec."Deal Line" then begin
            PosTransactionGui.ErrorBeep(QtyCantChangeOnDealsErr);
            exit;
        end;

        if LineRec.Number = '' then begin
            PosTransactionGui.ErrorBeep(QtyCannotBeChangedErr);
            exit;
        end;

        if LineRec."Entry Status" = LineRec."Entry Status"::Voided then begin
            PosTransactionGui.ErrorBeep(QtyCannotBeChangedErr);
            exit;
        end;

        if LineRec."Entry Type" <> LineRec."Entry Type"::Item then begin
            PosTransactionGui.ErrorBeep(QtyOnlyOnSalesLinesErr);
            exit;
        end;

        if (LineRec."Parent Line" <> 0) and (LineRec."Parent Line" <> LineRec."Line No.") then begin
            PosTransactionGui.ErrorBeep(__ChangeQtyLinkedErr);
            exit;
        end;

        if LineRec."System-Unchangable Quantity" and (POSSESSion.GetValue("LSC POS Tag"::EXCHANGE_PRESSED_EX) = '') then begin
            PosTransactionGui.ErrorBeep(NoChangeQtyForLineErr);
            exit;
        end;

        if LineRec."Parent Line" = LineRec."Line No." then
            LineRec.CalcFields(LineRec."Linked lines are Modifiers");
        if LineRec."Linked lines are Modifiers" > 0 then begin
            PosTransactionGui.ErrorBeep(QtyNoChangeForLinkedItemsErr);
            exit;
        end;

        // if LineRec."Scale Item" and (LineRec."Weight manually Entered" = false) then begin
        //     POSTransScale.InitScale('', '', PosSetup);
        //     if POSTransScale.IsScaleActive() then begin
        //         PosTransactionGui.ErrorBeep(QtyChangeIsNotAllowedOnScaleItems);
        //         exit;
        //     end;
        // end;

        if CurrInput = '' then begin
            PosTransactionGui.OpenNumericKeyboard(ChangeQtyMsg, '', Enum::"LSC POS Trans. Numpad Trigger"::ChangeQtyPressed);
            ManualQuantity := true;
            exit;
        end;

        case CurrInput of
            '+':
                begin
                    CurrInput := Format(LineRec.Quantity + 1);
                    ManualQuantity := true;
                end;
            '-':
                begin
                    CurrInput := Format(LineRec.Quantity - 1);
                    ManualQuantity := true;
                end;
        end;

        if not Evaluate(Dec, CurrInput) then begin
            PosTransactionGui.ErrorBeep(InvalidValInQtyErr);
            exit;
        end;

        if REC."Sale Is Return Sale" then
            if Dec < 0 then begin
                IsHandled := false;
                POSTransactionEvents.OnBeforeNegQtyChangeError(REC, LineRec, CurrInput, Dec, ErrorText, IsHandled);
                if not IsHandled then begin
                    PosTransactionGui.ErrorBeep(NegQtyChangeOnReturnSale);
                    exit;
                end;
            end;

        if LineRec."Lot No." <> '' then begin
            // if not PosFunc.ValidateLotNoQty(LineRec, REC."Sale Is Return Sale", Dec, ErrorText) then begin
            //     PosTransactionGui.ErrorBeep(ErrorText);
            //     exit;
            // end;
        end;
        if (Abs(Dec) <> 1) and (LineRec."Serial No." <> '') then begin
            PosTransactionGui.ErrorBeep(QtyOnlyOneWhenSerialNoErr);
            exit;
        end;

        POSTransactionEvents.OnBeforeCheckQuantityNegativeOnChangeQtyPressed(Item, LineRec, Dec, BOUtils, REC, StoreSetup, IsHandled);
        if IsHandled then
            exit;

        if LineRec.Quantity < 0 then
            Dec := -Dec;

        if Dec < 0 then begin
            Dec1 := Dec;
            if ReturnRestrictions(Dec1, NewLine, true, LinesFound) then begin
                if LinesFound then begin
                    if Dec1 < 0 then begin
                        PosTransactionGui.ErrorBeep(NoCorrectedHigherThanSoldErr);
                        exit;
                    end;
                end else begin
                    PosTransactionGui.ErrorBeep(SalesAndReturnsNotAllowedErr);
                    exit;
                end;
            end;
        end;

        if LineRec."Retail Special Order" then begin
            if REC."Sale Is Return Sale" xor (Dec < 0) then begin
                PosTransactionGui.ErrorBeep(StrSubstNo(InvalidErr, Dec));
                exit;
            end;
        end;

        if POSSESSION.GetValue("LSC POS Tag"::"OFFL_CALLCENTER") = 'SENT' then begin
            if (Dec - LineRec.Quantity < 0) then begin
                PosTransactionGui.ErrorBeep(OrderSentToResNoQtyChangeErr);
                exit;
            end;
        end;

        if not ValidateQuantity(Dec, LineRec) then
            exit;

        if not POSSESSION.PermissionItem('QTY', LineRec.Number, Dec, 0, InfoTextDescription, '', ManualQuantity) then begin
            PosTransactionGui.ErrorBeep(InfoTextDescription);
            exit;
        end;

        PrintLineVoided := false;
        if Dec <> 0 then
            if KDSFunctions.TransLineSentToKitchen(REC, LineRec, QtyNotPrinted) then begin
                if Dec < 0 then begin
                    PosTransactionGui.ErrorBeep(QtyNoNegativeToKitchenErr);
                    exit;
                end;
                QtyToReduce := LineRec.Quantity - QtyNotPrinted - Dec;
                if QtyToReduce > 0 then begin
                    if not POSSESSION.MgrKey then begin
                        PosTransactionGui.ErrorBeep(ErrorPrintMsg);
                        exit;
                    end;
                end;
            end;
        Proceed := true;
        POSTransactionEvents.OnAfterValidateChangeQty(REC, LineRec, CurrInput, Proceed);
        if not Proceed then
            exit;
        POSTransactionEvents.OnBeforeChangeQty(REC, LineRec, CurrInput);
        if RemoveCouponDiscount(LineRec) then;
        if not PrintLineVoided then begin
            if LineRec.Quantity <> 0 then
                Factor := Dec / LineRec.Quantity;

            LinkedLine.SetCurrentKey("Receipt No.", "Parent Line");
            LinkedLine.SetRange("Receipt No.", REC."Receipt No.");
            LinkedLine.SetRange("Parent Line", LineRec."Line No.");
            if LinkedLine.FindSet then begin
                LineUpdateInProgress := true;
                repeat
                    if Evaluate(CurrInputDec, CurrInput) then begin
                        if LinkedLine."Line No." <> LineRec."Line No." then begin
                            if LinkedItem.Get(LineRec.Number, LinkedLine."Unit of Measure", LinkedLine.Number) then begin
                                CurrInputDec := CurrInputDec * Abs(LinkedItem."No. of Items");
                                OldQty := LineRec.Quantity * Abs(LinkedItem."No. of Items");
                                if CurrInputDec < OldQty then
                                    LinkedLine."Reduced Quantity" := OldQty - CurrInputDec;
                                Factor := (CurrInputDec / OldQty);
                            end;
                        end else
                            if CurrInputDec < LinkedLine.Quantity then
                                LinkedLine."Reduced Quantity" += LinkedLine.Quantity - CurrInputDec;
                    end;
                    if (Factor <> 0) or ((Factor = 0) and (State = State::PHYS_INV)) then
                        LinkedLine.Validate(Quantity, Round(LinkedLine.Quantity * Factor, 0.00001))
                    else begin
                        VoidLinePressed();
                        exit;
                    end;
                    if LinkedLine."Line No." <> LineRec."Line No." then
                        UpdateQty(LinkedLine, Factor);
                until LinkedLine.Next = 0;
                LineUpdateInProgress := false;
            end;
        end;

        OldQty := LineRec.Quantity;
        POSLINES.SetCurrentLineNo(LineRec."Receipt No.", LineRec."Line No.");
        POSLINES.GetCurrentLine(LineRec);

        if not REC."Sale Is Return Sale" and (Dec < 0) then begin
            ChangeQtyInProgress := true;
            if CheckInfoCode('NEGSALE') then
                exit;
        end else
            if not REC."Sale Is Return Sale" and (OldQty < 0) and (Dec >= 0) then
                InfoUtil.RemoveInfoCode(LineRec, 'NEGSALE');

        ChangeQtyPressedEx;

        if REC."Customer Order" then begin
            COWasCreated := false;
            if STATE = "LSC POS Transaction State"::PAYMENT then begin
                SetPOSState("LSC POS Transaction State"::SALES);
                //SetFunctionMode("LSC POS Command"::ITEM);
                SelectDefaultMenu();
            end;
        end;
    end;

    procedure ChangeQtyPressedEx()
    var
        PosPrice: Codeunit "LSC POS Price Utility";
        QtyChangedMsg: Label 'Quantity changed';
    begin
        WriteMgrStatus;
        PosPrice.CalcPeriodicOnTotalPressed(REC);
        PosFunc.RecalcSlip(REC);
        CalcTotals;
        CurrInput := '';
        InfoTextDescription := QtyChangedMsg;
        OposUtil.DisplaySalesLine('', LineRec.Description, LineRec.Quantity, LineRec.Price, LineRec.Amount, LineRec."Unit of Measure", true);

        //POSTransactionEvents.OnAfterChangeQty(REC, LineRec, CurrInput);

        //HospFunc.ChangedAfterBillPrinted(REC, BillIsPrinted, HospOrderTransStatus);
        if not CheckDiscountOffers(LineRec) then
            CheckNextItemInQueue;
    end;

    procedure UpdateQty(UpdLineRec: Record "LSC POS Trans. Line"; UpdFactor: Decimal)
    var
        POSLinkedLine: Record "LSC POS Trans. Line";
        ErrorCode: Code[30];
        ErrorText: Text;
    begin
        POSLinkedLine.SetCurrentKey("Receipt No.", "Parent Line");
        POSLinkedLine.SetRange("Receipt No.", UpdLineRec."Receipt No.");
        POSLinkedLine.SetRange("Parent Line", UpdLineRec."Line No.");
        if POSLinkedLine.FindSet then
            repeat
                if UpdFactor <> 0 then
                    POSLinkedLine.Validate(Quantity, Round(POSLinkedLine.Quantity * UpdFactor, 0.00001))
                else begin
                    //posfunc.SetCustomerOrder(REC, POSLinkedLine, ErrorCode, ErrorText);
                    if ErrorText <> '' then begin
                        PosTransactionGui.ErrorBeep(ErrorText);
                        exit;
                    end else
                        POSLinkedLine.VoidLine;
                end;
                if POSLinkedLine."Line No." <> UpdLineRec."Line No." then
                    UpdateQty(POSLinkedLine, UpdFactor);
            until POSLinkedLine.Next = 0;
    end;

    procedure ChangePricePressed(Value: Text[30])
    var
        MixMatchLine: Record "LSC POS Trans. Line";
        PeriodicDiscountLine: Record "LSC Periodic Discount Line";
        PeriodicDiscount: Record "LSC Periodic Discount";
        ErrorText: Text[250];
        Dec: Decimal;
        Proceed: Boolean;
        PriceOnlyChangeOnSalesErr: Label 'Price can only be changed on sales line';
        NoPriceChangeOnScaleErr: Label 'Price change is not allowed on scale items.';
        NoChangePriceInStateErr: Label 'Cannot change price in this state';
        NoChangePriceInLineErr: Label 'Price cannot be changed for this line';
        PriceCannotChangeForDealsInMixAndMatchErr: Label 'Price cannot be changed for Deal Price line in an active Mix & Match';
    begin
        if Value <> '' then
            CurrInput := Value;

        if (STATE = "LSC POS Transaction State"::TENDOP) or REC."New Transaction" then begin
            PosTransactionGui.ErrorBeep(NoChangePriceInStateErr);
            exit;
        end;
        Clear(LineRec);

        POSLINES.GetCurrentLine(LineRec);
        Proceed := true;
        //    POSTransactionEvents.OnBeforeValidateChangePrice(REC, LineRec, CurrInput, Proceed, ErrorText);
        if not Proceed then begin
            PosTransactionGui.ErrorBeep(ErrorText);
            exit;
        end;

        if LineRec.Number = '' then begin
            PosTransactionGui.ErrorBeep(NoChangePriceInLineErr);
            exit;
        end;
        if (LineRec."Entry Status" = LineRec."Entry Status"::Voided) or LineRec."Deal Line" then begin
            PosTransactionGui.ErrorBeep(NoChangePriceInLineErr);
            exit;
        end;
        if LineRec."Entry Type" <> LineRec."Entry Type"::Item then begin
            PosTransactionGui.ErrorBeep(PriceOnlyChangeOnSalesErr);
            exit;
        end;

        // if LineRec."Scale Item" and (LineRec."Weight manually Entered" = false) then begin
        //     POSTransScale.InitScale('', '', PosSetup);
        //     if POSTransScale.IsScaleActive() then begin
        //         PosTransactionGui.ErrorBeep(NoPriceChangeOnScaleErr);
        //         exit;
        //     end;
        // end;

        if LineRec."System-Unchangable Price" then begin
            PosTransactionGui.ErrorBeep(NoChangePriceInLineErr);
            exit;
        end;
        if LineRec."Mix & Match Line No." <> 0 then
            if MixMatchLine.Get(LineRec."Receipt No.", LineRec."Disc. Info Line No.") then
                if PeriodicDiscountLine.Get(MixMatchLine.Number, LineRec."Mix & Match Line No.") then begin
                    if PeriodicDiscount.Get(PeriodicDiscountLine."Offer No.") then
                        if PeriodicDiscount."Discount Type" = PeriodicDiscount."Discount Type"::"Deal Price" then begin
                            PosTransactionGui.ErrorBeep(PriceCannotChangeForDealsInMixAndMatchErr);
                            exit;
                        end
                        else
                            if PeriodicDiscountLine."Disc. Type" = PeriodicDiscountLine."Disc. Type"::"Deal Price" then begin
                                PosTransactionGui.ErrorBeep(PriceCannotChangeForDealsInMixAndMatchErr);
                                exit;
                            end;
                end;

        if CurrInput = '' then begin
            PosTransactionGui.OpenNumericKeyboard(PriceMsg, '', Enum::"LSC POS Trans. Numpad Trigger"::ChangePricePressed);
            exit;
        end;

        if not ValidatePrice(Dec, LineRec."Org. Price Inc. VAT", LineRec.Number) then
            exit;

        Proceed := true;
        POSTransactionEvents.OnAfterValidateChangePrice(REC, LineRec, CurrInput, Proceed);
        if not Proceed then
            exit;

        ChangePricePressedDec := Dec;
        if CheckInfoCode('OVERRIDE') then
            exit;

        ChangePricePressedEx(Dec);
    end;

    internal procedure ChangePricePressedEx(Dec: Decimal)
    var
        PosPrice: Codeunit "LSC POS Price Utility";
        COUtility: Codeunit "LSC CO Utility";
        PriceChangedMsg: Label 'Price changed';
    begin
        POSTransactionEvents.OnBeforeChangePrice(REC, LineRec, CurrInput);

        if RemoveCouponDiscount(LineRec) then;
        LineUpdateInProgress := true;
        LineRec.Validate(Price, Dec);
        LineUpdateInProgress := false;
        PosPrice.CalcPeriodicOnTotalPressed(REC);
        UpdateVoucherEntries(LineRec);
        WriteMgrStatus;
        CalcTotals;
        CurrInput := '';
        InfoTextDescription := PriceChangedMsg;
        InfoTextDescription2 := StrSubstNo(BalanceDueIsMsg, FormatAmount(Balance));

        OposUtil.DisplaySalesLine('', LineRec.Description, LineRec.Quantity, LineRec.Price, LineRec.Amount, LineRec."Unit of Measure", true);

        POSTransactionEvents.OnAfterChangePrice(REC, LineRec, CurrInput);

        if REC."Customer Order" then
            COUtility.UpdateOrderLines(REC, CustomerOrderLine_Temp, CustomerOrderDiscountLine_Temp, CustomerOrderHeader_Temp);
    end;

    procedure AskForPrice()
    begin
        POSTransactionEvents.OnBeforeAskForPrice(REC, LineRec, CurrInput, Item);
        //SetFunctionMode("LSC POS Command"::PRICE);
        PosTransactionGui.MessageBeep(StrSubstNo('%1: %2', FunctionSetup.Description, Item.Description));
        SetPosInfoText1(StrSubstNo('%1 %2', Item."No.", Item.Description));

        KeyboardPrice := FindItemPrice(
            Item."No.", REC."Trans. Date", REC."Trans Time", NewLine."Unit of Measure",
            NewLine."Variant Code", REC."Trans. Currency Code", NewLine."Price Group Code",
            LineSalesType, REC."Customer Disc. Group");
        POSTransactionEvents.OnAfterAskForPrice(REC, LineRec, NewLine, CurrInput, Item);
    end;

    procedure ValidatePrice(var Price: Decimal; OrgPrice: Decimal; ItemNo: Code[20]): Boolean
    var
        IsHandled: Boolean;
        InvalidPriceValueErr: Label 'Invalid value in price';
    begin
        if CurrInput = '' then begin
            PosTransactionGui.OpenNumericKeyboard(PriceMsg, '', Enum::"LSC POS Trans. Numpad Trigger"::ValidatePrice);
            exit(false);
        end;

        if not Evaluate(Price, CurrInput) then begin
            PosTransactionGui.ErrorBeep(InvalidPriceValueErr);
            exit(false);
        end;

        if not POSTransactionFunctions.CheckPriceZeroIsValid(Price, Item) then
            exit(false);

        //PosFunc.AdjustAmount(Price);
        if (PosFuncProfile."Maximum Price" <> 0) and (Price > PosFuncProfile."Maximum Price") then begin
            KeyboardPrice := OrgPrice;
            PosTransactionGui.ErrorBeep(StrSubstNo(__PRICE_TOO_HIGH, PosFuncProfile."Maximum Price"));
            exit(false);
        end;
        POSTransactionEvents.OnValidatePricePermissionItem(LineRec, StoreSetup, IsHandled);
        if not IsHandled then begin
            if not POSSESSION.PermissionItem('PRICE', ItemNo, Price, OrgPrice, InfoTextDescription, '', false) then begin
                KeyboardPrice := OrgPrice;
                PosTransactionGui.ErrorBeep(InfoTextDescription);
                exit(false);
            end;
        end;

        WriteMgrStatus;
        exit(true);
    end;

    procedure AskForQuantity()
    begin
        POSTransactionEvents.OnBeforeAskForQuantity(REC, LineRec, CurrInput, Item);
        //SetFunctionMode("LSC POS Command"::QUANTITY);
        PosTransactionGui.MessageBeep(StrSubstNo('%1: %2', FunctionSetup.Description, Item.Description));
        SetPosInfoText1(StrSubstNo('%1 %2', Item."No.", Item.Description));
    end;

    procedure ValidateQuantity(NewQuantity: Decimal; Line: Record "LSC POS Trans. Line"): Boolean
    var
        CustomerOrderCreatePanel: Codeunit "LSC CO Create Panel";
        Proceed: Boolean;
        QtyOverMaxErr: Label 'Quantity of item has exceeded maximum allowed';
        ContinueQst: Label '\Do you want to continue?';
    begin
        Proceed := true;
        //POSTransactionEventsPub.OnBeforeValidateQuantity(NewQuantity, Line, Proceed);
        if not Proceed then
            exit(false);

        // if not CustomerOrderCreatePanel.CustomerOrderIsOKToChangeQty(NewQuantity, Line) then
        //     exit(false);

        if Line."Entry Type" = Line."Entry Type"::Item then begin
            if not ItemDecimalQtyCheck(Line.Number, NewQuantity) then
                exit(false);
        end;

        if (PosFuncProfile."Maximum Quantity" <> 0) and (abs(NewQuantity) > PosFuncProfile."Maximum Quantity") then begin
            PosTransactionGui.ErrorBeep(StrSubstNo(__QTY_TOO_HIGH, PosFuncProfile."Maximum Quantity"));
            exit(false);
        end;

        // if not Line.ValidateItemQty(NewQuantity - Line.Quantity) then begin
        //     if POSSESSION.MgrKey then begin
        //         if not PosTransactionGui.PosConfirm(QtyOverMaxErr + ContinueQst, false) then
        //             exit(false);
        //     end
        //     else begin
        //         PosTransactionGui.ErrorBeep(QtyOverMaxErr);
        //         exit;
        //     end;
        // end;

        // if not POSSESSION.MgrKey then
        //     if not Line.ValidateItemQty(NewQuantity - Line.Quantity) then begin
        //         PosTransactionGui.ErrorBeep(QtyOverMaxErr);
        //         exit;
        //     end;

        // if not Line.CheckUOMDenominator(NewQuantity, InfoTextDescription) then begin
        //     PosTransactionGui.ErrorBeep(InfoTextDescription);
        //     exit(false);
        // end;
        POSTransactionEvents.OnAfterValidateQuantity(NewQuantity, Line);
        exit(true);
    end;

    procedure ValidateQtyInput()
    begin
        if CurrInput = '' then begin
            PosTransactionGui.OpenNumericKeyboard(QtyMsg, '', Enum::"LSC POS Trans. Numpad Trigger"::ValidateQtyInput);
            exit;
        end;

        if not Evaluate(CurrQty, CurrInput) then begin
            PosTransactionGui.ErrorBeep(InvalidValInQtyErr);
            exit;
        end;

        if ValidateQuantity(CurrQty, NewLine) then
            NextItemPhase;
    end;

    procedure CheckInfoCode(Module: Code[10]): Boolean
    var
        InfocodeOnHeader: Boolean;
        IsHandled: Boolean;
        ReturnValue: Boolean;
    begin
        ClearInfoAndInfoUtil();
        POSTransactionEvents.OnBeforeCheckInfoCodeV2(REC, Info, Module, IsHandled, ReturnValue, InfoUtil);
        if IsHandled then
            exit(ReturnValue);
        InfocodeOnHeader := false;
        if LineRec."Receipt No." = '' then
            LineRec."Receipt No." := REC."Receipt No.";
        case Module of
            'ITEM',
          'INCEXP',
          'PAYMENT',
          'MARKUP',
          'MARKDN',
          'NEGSALE',
          'VOID_L',
          'OVERRIDE':
                if not InfoUtil.InfoCodeRequired(Module, LineRec.Number, '') then
                    exit(false);
            'NEG_ADJ',
          'PHYS_INV',
          'CUSTOMER':
                if not InfoUtil.InfoCodeRequired(Module, Customer."No.", '') then
                    exit(false)
                else begin
                    LineRec."Line No." := 0;
                    InfocodeOnHeader := true;
                end;
            'VOID',
          'END',
          'START',
          'REM_TENDER',
          'FLOAT_ENT',
          'OPENDRAWER',
          'TENDER_D':
                if not InfoUtil.InfoCodeRequired(Module, '', '') then
                    exit(false)
                else begin
                    LineRec."Line No." := 0;
                    InfocodeOnHeader := true;
                end;
            'WIC',
            'REFUND',
            'EXCHANGE',
            'TOTDISC':
                if not InfoUtil.InfoCodeRequired(Module, '', '') then
                    exit(false)
                else begin
                    InfocodeOnHeader := true;
                end;
            'CURRENCY':
                if not InfoUtil.InfoCodeRequired(Module, LastCurrencyCode, TenderType.Code) then
                    exit(false);
            else
                exit(false);
        end;

        LastCanceled := false;
        InfoFunction := Module;
        StartFunction := FunctionSetup."Function Code";
        ProcessInfoCode('', false, 0, InfocodeOnHeader);

        exit(true);
    end;

    procedure ProcessInfoCode(SubCode: Code[20]; CodeIsSet: Boolean; Requested: Option AutoOnly,All,RequestOnly; InfocodeOnHeader: Boolean)
    var
        InfoEntry: Record "LSC POS Trans. Infocode Entry";
        SubInfo: Record "LSC Information Subcode";
        EntryType: Record "LSC POS Data Entry Type";
        MenuLine2_l: Record "LSC POS Menu Line";
        FunctionSetup2: Record "LSC POS Command";
        TableSpecInfoCode: Record "LSC Table Specific Infocode";
        TenderInfoCode: Record "LSC Infocode";
        StoreTenderType: Record "LSC Tender Type";
        POSView: Codeunit "LSC POS View";
        KeyBoardCaption: Text[30];
        DefaultValue: Text;
        SubCodeInput: Code[20];
        ItemUOM: Code[10];
        ParentUOM: Code[10];
        ItemQty: Decimal;
        OrgPrice: Decimal;
        UserSelQty: Decimal;
        ItemPrice: Decimal;
        ParentLineNo: Integer;
        ItemCounter: Integer;
        InfoEntryNo: Integer;
        MoreInfo: Boolean;
        SkipInput: Boolean;
        Ok: Boolean;
        Dummy: Boolean;
        SetPrice: Boolean;
        Handled: Boolean;
        IsHandled, IsExit : Boolean;
        TableInfoFound: Boolean;
        NegativeDataEntryAmount: Label 'The Amount cannot be negative when creating a Data Entry';
        LineVoidedMsg: Label 'Line voided !';
        FieldEmptyDataEntryErr: Label 'Field %1 is empty for POS Data Entry %2';
    begin
        MoreInfo := false;
        POSSESSION.SetValue("LSC POS Tag"::"TS_ERROR", '');
        Clear(SubCodeInput);
        if Info.Type = Info.Type::Selection then
            SubCodeInput := CopyStr(CurrInput, 1, 20);
        while InfoUtil.NextInfoCode(Info, LastCanceled, SubCodeInput, CodeIsSet) do begin
            ValidateInfocode_InsertingItem := false;
            POSTransactionEvents.OnBeforeProcessInfoCode(REC, Info);
            Clear(SubCodeInput);
            SkipInput := false;
            CurrInput := '';
            if LineRec."Receipt No." = '' then
                LineRec."Receipt No." := REC."Receipt No.";
            if (Info.Type = Info.Type::"Create Data Entry") and (Info."Data Entry Type" <> '') and (LineRec.Amount < 0) then begin
                TenderInfoCode.Reset();
                TenderInfoCode.SetRange("Data Entry Type", Info."Data Entry Type");
                TenderInfoCode.SetRange(Type, TenderInfoCode.Type::"Apply To Entry");
                if TenderInfoCode.FindFirst() then begin
                    StoreTenderType.Reset();
                    StoreTenderType.SetRange("Store No.", POSSESSION.StoreNo());
                    StoreTenderType.SetRange("Return/Minus Allowed", false);
                    TableInfoFound := false;
                    if StoreTenderType.FindSet() then
                        repeat
                            if TableSpecInfoCode.Get(Database::"LSC Tender Type", StoreTenderType."Primary Key", TenderInfoCode.Code) then
                                TableInfoFound := true;
                        until TableInfoFound or (StoreTenderType.Next() = 0);
                    if TableInfoFound then begin
                        PosTransactionGui.ErrorBeep(NegativeDataEntryAmount);
                        LineRec.Delete();
                        exit;
                    end;
                end;
            end;
            //LastCanceled := not InfoUtil.IsInfoCodeValid(Info, LineRec, Requested);
            if not LastCanceled then begin
                POSTransactionEvents.OnBeforeGetDataEntryProcessInfoCodeV2(Info, SkipInput, MoreInfo, IsHandled, IsExit);
                if IsExit then
                    exit;

                if not IsHandled then
                    if Info.Type = Info.Type::"Create Data Entry" then begin
#pragma warning disable AL0432
                        IsHandled := false;
                        POSTransactionEvents.OnBeforeGetDataEntryProcessInfoCode(Info, SkipInput, MoreInfo, IsHandled);
                        if IsHandled then
                            exit
                        else begin
#pragma warning restore AL0432
                            EntryType.Get(Info."Data Entry Type");
                            if (EntryType.Numbering = EntryType.Numbering::"No. Series") and (EntryType."No. Series" = '') then begin
                                PosTransactionGui.MessageBeep(CopyStr(StrSubstNo(FieldEmptyDataEntryErr, EntryType.FieldCaption("No. Series"), Info."Data Entry Type"), 1, 80));
                                Sleep(2000);
                                PosTransactionGui.MessageBeep(LineVoidedMsg);
                                LineRec."Entry Status" := LineRec."Entry Status"::Voided;
                                LineRec.Modify(true);
                                exit;
                            end;
                            if (EntryType.Numbering <> EntryType.Numbering::None) or
                               ((EntryType.Numbering = EntryType.Numbering::"No. Series") and (EntryType."No. Series" = '')) then begin
                                Ok :=
                                  InfoUtil.IsInputOk(
                                    Info, CurrInput, InfoTextDescription, LineRec, LastCanceled, false,
                                    TrainingActive, Dummy, 0, '', '', false, 0, false, InfoEntryNo);
                                SkipInput := true;
                                if not Ok then
                                    MoreInfo := true;
                                LineRec."System-Unchangable Quantity" := true;
                                LineRec.Modify(true);
                            end;
                        end;
#pragma warning disable AL0432
                    end;
#pragma warning restore AL0432
                IsHandled := false;
                if not SkipInput then begin
                    SubInfo.SetRange(SubInfo.Code, Info.Code);
                    if (Info.Type = Info.Type::Selection) and
                       ((SubInfo.Count = 1) and Info."Input Required" and
                        (Info."Display Option" <> Info."Display Option"::"Pop-up") and
                        (Info."Display Option" <> Info."Display Option"::"Pop-up Dual Display")) or
                       (SubCode <> '')
                    then begin
                        if (SubCode <> '') then
                            SubInfo.Get(Info.Code, SubCode)
                        else
                            SubInfo.FindFirst;
                        CurrInput := SubInfo.Subcode;
                        ValidateInfocode(Requested, InfocodeOnHeader, true);
                        exit;
                    end
                    else begin
                        // SetFunctionMode("LSC POS Command"::INFOCODE);
                        SetInputPrompt(Info.Prompt);
                        MoreInfo := true;

                        POSTransactionEvents.OnProcInfocodeBeforeDisplayCase(Info, Requested, InfocodeOnHeader, IsHandled);
                        if IsHandled then
                            exit;

                        case Info."Display Option" of
                            Info."Display Option"::"Pop-up", Info."Display Option"::"Pop-up Dual Display":
                                begin
                                    // if Info."Display Option" = Info."Display Option"::"Pop-up Dual Display" then
                                    //     POSCtrl.EnableDualDisplayMirroring();
                                    FunctionSetup2.Get(Format("LSC POS Command"::POPUPINFO));
                                    Clear(MenuLine2_l);

                                    PopulatePOSMenuLineForCodeunitRun(Format("LSC POS Command"::POPUPINFO), Info.Code, MenuLine2_l, LineRec, true, true);

                                    if InfocodeOnHeader then
                                        MenuLine2_l."Current-Infocode Trans. Type" := MenuLine2_l."Current-Infocode Trans. Type"::Header
                                    else
                                        MenuLine2_l."Current-Infocode Trans. Type" := MenuLine2_l."Current-Infocode Trans. Type"::" ";
                                    MenuLine2_l."Current-Quantity Handling" := Info."Quantity Handling";

                                    PopupPOSComm.Run(MenuLine2_l);
                                    if MenuLine2_l."Input Process" = MenuLine2_l."Input Process"::" " then begin
                                        CurrInput := MenuLine2_l."Current-INPUT";
                                        if (CurrInput = '') then
                                            Info."Input Required" := (MenuLine2_l."Current-MaxMinSelection" > 0)
                                    end else begin
                                        ValidateInfocode_WaitingForInput_Web := true;
                                        ValidateInfocode_Requested := Requested;
                                        ValidateInfocode_InfocodeOnHdr := InfocodeOnHeader;
                                        exit;
                                    end;
                                end;
                            Info."Display Option"::Lookups:
                                begin
                                    ValidateInfocode_WaitingForInput_Web := true;
                                    ValidateInfocode_Requested := Requested;
                                    ValidateInfocode_InfocodeOnHdr := InfocodeOnHeader;
                                    ValidateInfocode_OneSubcode := false;
                                    LookUp(false, 'INFOCODE', '');
                                    exit;
                                end;
                            Info."Display Option"::"Number Pad":
                                begin
                                    POSTransactionEvents.OnInfocodeDisplayNumpad(Info, CurrInput, IsHandled);
                                    if IsHandled then
                                        exit;

                                    if Info.Prompt = '' then begin
                                        if Info.Description = '' then
                                            KeyBoardCaption := EnterInfocodeMsg
                                        else
                                            KeyBoardCaption := Info.Description;
                                    end else
                                        KeyBoardCaption := Info.Prompt;

                                    ValidateInfocode_WaitingForInput_Web := true;
                                    ValidateInfocode_Requested := Requested;
                                    ValidateInfocode_InfocodeOnHdr := InfocodeOnHeader;
                                    ValidateInfocode_OneSubcode := false;
                                    PosTransactionGui.OpenNumericKeyboard(KeyBoardCaption, '', Enum::"LSC POS Trans. Numpad Trigger"::ValidateInfocode);
                                    exit;
                                end;
                            Info."Display Option"::"Alphabetic Pad":
                                begin
                                    Commit;
                                    IsHandled := false;
                                    POSTransactionEvents.OnInfocodeDisplayAlphabeticPad(Info, CurrInput, DefaultValue, LineRec, IsHandled);
                                    if IsHandled then
                                        exit;

                                    if Info.Prompt = '' then begin
                                        if Info.Description = '' then
                                            KeyBoardCaption := EnterTextMsg
                                        else
                                            KeyBoardCaption := Info.Description;
                                    end else
                                        KeyBoardCaption := Info.Prompt;
                                    ValidateInfocode_WaitingForInput_Web := true;
                                    ValidateInfocode_Requested := Requested;
                                    ValidateInfocode_InfocodeOnHdr := InfocodeOnHeader;
                                    ValidateInfocode_OneSubcode := false;
                                    POSGUI.OpenAlphabeticKeyboard(KeyBoardCaption, DefaultValue, false, '#INFOCODETEXT', MaxStrLen(GlobalMenuLine."Current-INPUT"));
                                    exit;
                                end;
                            else begin
                                //POSTransactionEventsPub.OnProcessBlankInfoDisplayOption(Info, PosTerminal, CurrInput, Handled);
                                if not Handled then
                                    PosTransactionGui.MessageBeep(EnterInfocodeMsg);
                                exit;
                            end;
                        end;
                        ProcessInfoCodeInput(Requested, InfocodeOnHeader);
                        exit;
                    end;
                end;
            end;
        end;

        ValidateInfocode_InsertingItem := true;
        if not MoreInfo then begin
            InfoEntry.SetRange("Receipt No.", LineRec."Receipt No.");
            if (LineRec."Line No." = 0) or (InfocodeOnHeader) then begin
                InfoEntry.SetRange("Transaction Type", InfoEntry."Transaction Type"::Header);
                LineRec.Quantity := 1;
                InfoEntry.SetRange("Line No.", 0);
            end else begin
                case LineRec."Entry Type" of
                    LineRec."Entry Type"::Item:
                        InfoEntry.SetRange("Transaction Type", InfoEntry."Transaction Type"::"Sales Entry");
                    LineRec."Entry Type"::Payment:
                        InfoEntry.SetRange("Transaction Type", InfoEntry."Transaction Type"::"Payment Entry");
                    LineRec."Entry Type"::IncomeExpense:
                        InfoEntry.SetRange("Transaction Type", InfoEntry."Transaction Type"::"Income/Expense Entry");
                    LineRec."Entry Type"::PerDiscount:
                        InfoEntry.SetRange("Transaction Type", InfoEntry."Transaction Type"::"Periodic Discount Info");
                end;
                InfoEntry.SetRange("Line No.", LineRec."Line No.");
            end;

            InfoEntry.SetRange(Status, 0);
            ItemQty := LineRec.Quantity;
            OrgPrice := LineRec.Price;
            POSTransactionEvents.OnAfterSetQuantityAndPrice(ItemQty, OrgPrice);
            ParentLineNo := LineRec."Line No.";
            ParentUOM := LineRec."Unit of Measure";
            ItemCounter := 1;
            if InfoEntry.FindSet then
                repeat
                    if SubInfo.Get(InfoEntry.Infocode, InfoEntry.Subcode) then begin
                        case SubInfo."Trigger Function" of
                            SubInfo."Trigger Function"::Item:
                                if not InfoEntry."Line Inserted and Linked" then begin
                                    ItemPrice := 0;
                                    CurrInput := SubInfo."Trigger Code";
                                    SetPrice := true;

                                    case SubInfo."Price Type" of
                                        SubInfo."Price Type"::Price:
                                            ItemPrice := SubInfo."Amount /Percent";
                                        SubInfo."Price Type"::Percent:
                                            ItemPrice := PosFunc.RoundAmount(OrgPrice * SubInfo."Amount /Percent" / 100);
                                        else
                                            if InfoEntry."Set Price" then
                                                ItemPrice := InfoEntry."New Price"
                                            else
                                                SetPrice := false;
                                    end;
                                    if SubInfo."Qty. Linked to Trigger Line" then
                                        if ItemQty <> 1 then
                                            MultiplyWith := ItemQty;
                                    UserSelQty := InfoEntry."Selected Quantity";
                                    if SubInfo."Qty. per Unit of Measure" <> 0 then
                                        UserSelQty := UserSelQty * SubInfo."Qty. per Unit of Measure";

                                    if SubInfo."Unit of Measure" <> '' then
                                        ItemUOM := SubInfo."Unit of Measure";

                                    TmpSelQty.Init;
                                    TmpSelQty.Type := TmpSelQty.Type::Selection;
                                    TmpSelQty."Item No." := SubInfo."Trigger Code" + Format(ItemCounter);
                                    TmpSelQty."Item No. Length" := StrLen(SubInfo."Trigger Code");
                                    TmpSelQty."User Ref." := POSSESSION.GetOriginalTerminalNo;
                                    TmpSelQty."Set Price" := SetPrice;
                                    TmpSelQty."New Price" := ItemPrice;
                                    TmpSelQty."Qty." := UserSelQty;
                                    TmpSelQty."Unit of Measure" := ItemUOM;
                                    TmpSelQty."Variant Code" := InfoEntry."Entry Variant Code";
                                    TmpSelQty."Serial No." := InfoEntry."Serial No.";
                                    TmpSelQty."From Infocode" := InfoEntry.Infocode;
                                    TmpSelQty."From Subcode" := InfoEntry.Subcode;
                                    TmpSelQty."Linked Line Line No." := InfoEntry."Entry Line No.";
                                    TmpSelQty."Infocode Selected Qty." := InfoEntry."Selected Quantity";
                                    InfoEntry.CalcFields("Link Line");
                                    if InfoEntry."Link Line" then
                                        TmpSelQty."Link to Parent Line No." := ParentLineNo;
                                    if SubInfo."Serial/Lot No. Needed" then begin
                                        while UserSelQty > 0 do begin
                                            TmpSelQty."Qty." := 1;
                                            UserSelQty := UserSelQty - 1;
                                            TmpSelQty."Item No." := SubInfo."Trigger Code" + Format(ItemCounter);
                                            if not TmpSelQty.Insert then;
                                            ItemCounter := ItemCounter + 1;
                                        end;
                                    end else
                                        if not TmpSelQty.Insert then;
                                    ItemCounter := ItemCounter + 1;
                                end;
                            SubInfo."Trigger Function"::"Discount Gr.":
                                begin
                                    REC."Infocode Disc. Group" := SubInfo."Trigger Code";
                                    REC.Modify;
                                    PosFunc.CalcInfoCodeDisc(REC);
                                    PosOfferExt.ReCalcLinePreTotal(REC);
                                end;
                            SubInfo."Trigger Function"::"VAT Bus. Post. Grp":
                                begin
                                    REC."VAT Bus.Posting Group" := SubInfo."Trigger Code";
                                    REC."VAT by InfoCode" := true;
                                    REC.Modify;
                                    PosFunc.ChangeVATBusOnLine(REC);
                                end;
                            SubInfo."Trigger Function"::"Tax Area Code":
                                begin
                                    if POSSESSION.UseSalesTax then begin
                                        REC."Tax Area Code" := SubInfo."Trigger Code";
                                        REC."VAT by InfoCode" := true;
                                        REC.Modify;
                                        PosFunc.ChangeTAXOnLine(REC);
                                        Clear(LineRec);
                                    end;
                                end;
                            SubInfo."Trigger Function"::"Run Object":
                                RunObjPressed(SubInfo."Trigger Code", 'INFOCODE');
                            else begin
                                POSTransactionEvents.OnProcessOtherInfoTrigger(SubInfo, Info, rec, PosTerminal, CurrInput, isHandled);
                                if isHandled then
                                    exit;
                            end;
                        end;
                    end;
                until InfoEntry.Next = 0;
            InfoEntry.ModifyAll(Status, InfoEntry.Status::Processed);
            InfoTextDescription := '';
            CurrInput := '';
            FunctionSetup.Get(StartFunction);
            SetInputPrompt(FunctionSetup.Prompt);
            if ProcessInfoCodeEx then
                exit;
            if POSView.GetCurrMenu(0) = POSSESSION.GetStartMenu() then
                SelectDefaultMenu;
        end;
        POSTransactionEvents.OnAfterProcessInfoCode(REC, Info);

        // if TSUtil.TSInUse(PosFuncProfile) then begin
        //     TSCheckError;
        //     if POSSESSION.GetValue("LSC POS Tag"::"TS_ERROR") <> '' then begin
        //         PosTransactionGui.ErrorBeep(__TSError + ':' + POSSESSION.GetValue("LSC POS Tag"::"TS_ERROR"));
        //         LineRec.VoidLine;
        //         exit;
        //     end;
        // end;
        POSTransactionEvents.OnAfterCheckInfoCode(REC, Info, LineRec);

        CheckNextItemInQueue;
    end;

    local procedure ProcessInfoCodeInput(Requested: Integer; InfocodeOnHeader: Boolean)
    var
        IsHandled: Boolean;
    begin
        if CurrInput = '' then begin
            if Info."Input Required" then begin
                gInfoCodeSelectionOk := false;
                CancelPressed(false, Requested);
            end else
                ProcessInfoCode('', false, Requested, InfocodeOnHeader);
        end else begin
            POSTransactionEvents.OnBeforeValidateInfocodeOnProcessInfoCodeInput(Requested, IsHandled);
            if not IsHandled then
                ValidateInfocode(Requested, InfocodeOnHeader, false);
        end;
    end;

    procedure ProcessInfoCodeEx(): Boolean
    var
        ChangeState: Boolean;
    begin
        if (Info.Type = Info.Type::"Text Input") and (Info."Display Option" = Info."Display Option"::" ") then begin
            if CheckDiscountOffers(NewLine) then
                exit(false);
        end;
        CalcTotals;
        case InfoFunction of
            'PAYMENT':
                CommitPaymentLineEx;
            'VOID':
                VoidTransaction;
            'END':
                PostTransaction(true);
            'CUSTOMER':
                begin
                    if not (Info.Type = Info.Type::"Apply To Entry") then
                        OnlySelectCustomer := true;
                    ChangeState := ProcessCustomerChangeState;
                    ProcessCustomer(ChangeState);
                    POSTransactionEvents.OnAfterValidateCustomer(REC, NewLine, CurrInput, CustomerOrCardNo);
                    if MemberLinkedCustomerInfoCode then begin
                        CheckMemberCard();
                        MemberLinkedCustomerInfoCode := false;
                    end;
                end;
            'START':
                if StartItemNo <> '' then begin
                    CurrInput := StartItemNo;
                    StartItemNo := '';
                    LinkedItemsActive := false;
                    BomLineEntry := false;
                    ItemLine(true, false, 0, 0, '', '', '', '', 0, 0);
                end else
                    if IncExpAccNo <> '' then begin
                        CurrInput := Format(PaymentAmount);
                        IncExpLine;
                    end;
            'ITEM':
                if not REC."Sale Is Return Sale" and (NewLine.Quantity < 0) then
                    CheckInfoCode('NEGSALE');
            'REM_TENDER',
            'FLOAT_ENT',
            'TENDER_D':
                begin
                    if TenderDeclEndOfDay then
                        TD_TenderDeclEndOfDayPressedEx
                    else
                        RunTDCommand;
                end;
            'CURRENCY':
                CurrencyKeyPressed(LastCurrencyCode, 1);
            'MARKDN', 'MARKUP':
                begin
                    if DiscPressedPercentage then
                        DiscPrPressedEx(DiscPrAmtPressedDec)
                    else begin
                        if DiscDealPressedPercentage or DiscDealPressedAmount then begin
                            if DiscDealPressedPercentage then
                                DiscPrPressedOnDealEx(DiscPrAmtPressedDec)
                            else
                                DiscAmtPressedOnDealEx(DiscPrAmtPressedDec);
                        end else
                            DiscAmPressedEx(DiscPrAmtPressedDec);
                    end;
                    SetInfoFunction('ITEM');
                end;
            'TOTDISC':
                if TotalDiscPressedPercentage then
                    TotDiscPrPressed(TotDiscPressedValue, false)
                else
                    TotDiscAmPressed(TotDiscPressedValue, TotDiscAmPressedTotAmount, false);
            'NEGSALE':
                if ChangeQtyInProgress then begin
                    ChangeQtyInProgress := false;
                    ChangeQtyPressedEx;
                end;
            'VOID_L':
                VoidLinePressedEx(VoidLineNoOfVoidedLines, VoidLineLastVoidedLineDescr, VoidLineShowOnDisplay);
            'OPENDRAWER':
                OpenDrawerPressedEx(OpenDrawerPressedRoleID);
            'OVERRIDE':
                ChangePricePressedEx(ChangePricePressedDec);
        end;
        if InfoFunction in ['PAYMENT', 'VOID', 'END'] then
            exit(true);
        exit(false);
    end;

    procedure ValidateInfocode(Requested: Option AutoOnly,All,RequestOnly; InfocodeOnHeader: Boolean; OneSubcode: Boolean): Boolean
    var
        SelectedQty: Record "LSC Selected Quantity";
        LinkedPosTransLine: Record "LSC POS Trans. Line";
        CurrInfo: Record "LSC Infocode";
        SerialNoFromInfocode: Code[50];
        VariantCodeFromInfocode: Code[10];
        KeyBoardCaption: Text[30];
        InfoEntryNo: Integer;
        LinkedLineNo: Integer;
        Ok: Boolean;
        TSError: Boolean;
        TableFound: Boolean;
        IsHandled: Boolean;
        CancelInfocodeMsg: Label 'Press Cancel to cancel the infocode.';
        EnterPin: Label 'Enter PIN';
    begin
        ValidateInfocode_Requested := Requested;
        ValidateInfocode_InfocodeOnHdr := InfocodeOnHeader;

        if (CurrInput = '') and Info."Input Required" then begin
            if (Info."Display Option" = Info."Display Option"::"Number Pad") then begin
                if Info.Prompt = '' then begin
                    if Info.Description = '' then
                        KeyBoardCaption := EnterInfocodeMsg
                    else
                        KeyBoardCaption := Info.Description;
                end else
                    KeyBoardCaption := Info.Prompt;
                ValidateInfocode_OneSubcode := OneSubcode;
                PosTransactionGui.OpenNumericKeyboard(KeyBoardCaption, '', Enum::"LSC POS Trans. Numpad Trigger"::ValidateInfocode);
                exit(true);
            end else
                if (Info."Display Option" = Info."Display Option"::"Alphabetic Pad") then begin
                    if Info.Prompt = '' then begin
                        if Info.Description = '' then
                            KeyBoardCaption := EnterTextMsg
                        else
                            KeyBoardCaption := Info.Description;
                    end else
                        KeyBoardCaption := Info.Prompt;
                    ValidateInfocode_WaitingForInput_Web := true;
                    ValidateInfocode_OneSubcode := false;
                    POSGUI.OpenAlphabeticKeyboard(KeyBoardCaption, '', false, '#INFOCODETEXT', MaxStrLen(GlobalMenuLine."Current-INPUT"));
                    exit(true);
                end;
        end;

        LastCanceled := false;
        TableFound := false;
        if (Info."Multiple Selection" or (Info."Display Option" in [Info."Display Option"::"Pop-up", Info."Display Option"::"Pop-up Dual Display"])) and not OneSubcode
        then begin
            SelectedQty.SetRange(Type, SelectedQty.Type::"Menu Selection");
            SelectedQty.SetRange("User Ref.", POSSESSION.GetOriginalTerminalNo);
            if SelectedQty.FindSet then begin
                repeat
                    if SelectedQty."Qty." <> 0 then begin
                        CurrInfo.Get(SelectedQty."Selection Code");
                        CurrInput := SelectedQty."Selected Subcode";
                        SerialNoFromInfocode := SelectedQty."Serial No.";
                        VariantCodeFromInfocode := SelectedQty."Variant Code";
                        Ok :=
                          InfoUtil.IsInputOk(
                            CurrInfo, CurrInput, InfoTextDescription, LineRec,
                            LastCanceled, false, TrainingActive, TSError, SelectedQty."Qty.",
                            SerialNoFromInfocode, VariantCodeFromInfocode, SelectedQty."Set Price", SelectedQty."New Price",
                            SelectedQty."Line Is Linked to Parent", InfoEntryNo);
                        if SelectedQty."Line Is Linked to Parent" then begin
                            if LinkedPosTransLine.Get(LineRec."Receipt No.", SelectedQty."Linked Line Line No.") then begin
                                LinkedPosTransLine."Infocode Entry Line No." := InfoEntryNo;
                                LinkedPosTransLine.Modify(true);
                            end;
                            if SelectedQty."Last Linked Line Line No." <> 0 then begin
                                LinkedLineNo := SelectedQty."Linked Line Line No." + 10000;
                                while LinkedLineNo <= SelectedQty."Last Linked Line Line No." do begin
                                    if LinkedPosTransLine.Get(LineRec."Receipt No.", LinkedLineNo) then begin
                                        LinkedPosTransLine."Infocode Entry Line No." := InfoEntryNo;
                                        LinkedPosTransLine.Modify(true);
                                    end;
                                    LinkedLineNo += 10000;
                                end;
                            end;
                        end;
                    end;
                until SelectedQty.Next = 0;
                TableFound := true;
            end;
        end;

        if TableFound then
            ProcessInfoCode('', false, Requested, InfocodeOnHeader)
        else begin
            if Info.Type = Info.Type::Group then begin
                PosTransactionGui.MessageBeep(CancelInfocodeMsg);
                exit(true);
            end;
            Ok :=
              InfoUtil.IsInputOk(
                Info, CurrInput, InfoTextDescription, LineRec, LastCanceled, false, TrainingActive, TSError, 0, '', '', false, 0, false, InfoEntryNo);

            if InfoTextDescription = Format("LSC Data Entry Pin Status"::"Missing Pin") then begin
                PosTransactionGui.OpenNumericKeyboard(EnterPIN, '', Enum::"LSC POS Trans. Numpad Trigger"::"Data Entry PIN");
                Requested_g := Requested;
                InfocodeOnHeader_g := InfocodeOnHeader;
                OneSubcode_g := OneSubcode;
                exit(false);
            end;

            if TSError then
                Ok := RunTSError(InfoEntryNo);

            if Ok then begin
                POSTransactionEvents.OnBeforeProcessInfoCodeInValidateInfocode(Info, Requested, InfocodeOnHeader, OneSubcode, IsHandled);
                if not IsHandled then
                    ProcessInfoCode('', false, Requested, InfocodeOnHeader);
            end;
        end;
        exit(false);
    end;

    local procedure RunTSError(InfoEntryNo: Integer): Boolean
    var
        Ok: Boolean;
        Retry: Boolean;
        TSError: Boolean;
        ContinueRetryQst: Label '\\Continue/Retry?';
    begin
        repeat
            Ok := false;
            Retry := PosTransactionGui.PosConfirm(InfoTextDescription + ContinueRetryQst, true);
            if Retry then
                Ok :=
                  InfoUtil.IsInputOk(
                    Info, CurrInput, InfoTextDescription, LineRec, LastCanceled,
                    POSSESSION.MgrKey or POSSESSION.StaffContinueOnTSError, TrainingActive,
                    TSError, 0, '', '', false, 0, false, InfoEntryNo);
        until Ok or not Retry;

        if not Ok then begin
            PosTransactionGui.ErrorBeep(InfoTextDescription);
            exit(false)
        end;
        exit(true);
    end;

    internal procedure CalcPrices(var PosTransLine: Record "LSC POS Trans. Line")
    begin
        PosTransLine.CalcPrices;
    end;

    internal procedure InsertLine(var PosTransLine: Record "LSC POS Trans. Line"; UseLineNo: Integer)
    begin
        PosTransLine.InsertLine(UseLineNo);
    end;

    procedure CalcTotals()
    var
        IsHandled: Boolean;
    begin
        UpdateMarkedLinesInCO();

        if STATE <> "LSC POS Transaction State"::TENDOP then begin
            POSTransactionEvents.OnBeforeGetBalanceCalcTotals(Rec, PosFuncProfile, Balance, IsHandled);
            if not IsHandled then begin
                REC.CalcFields("Gross Amount", "Line Discount", Payment, "Net Amount", "Total Discount", "Income/Exp. Amount", Prepayment);
                Balance := REC."Gross Amount" + REC."Income/Exp. Amount" - REC.Payment;
            end;

            if REC."Sale Is Return Sale" then
                RealBalance := -Balance
            else
                RealBalance := Balance;
        end;
        PosTransactionEvents.OnAfterCalcTotals(REC, Balance, RealBalance);
    end;

    local procedure UpdatemarkedLinesInCo()
    var
        COUtility: Codeunit "LSC CO Utility";
    begin
        IF NOT REC."Customer Order" THEN
            EXIT;

        // if not CustomerOrderSession.IsCustomerOrderEdit() then
        //     exit;

        COUtility.UpdateOrderLines(REC, CustomerOrderLine_Temp, CustomerOrderDiscountLine_Temp, CustomerOrderHeader_Temp);
    end;

    procedure SetStaffID(pStaffID: Code[20])
    var
        Staff: Record "LSC Staff";
        ReturnTxt: Text[80];
    begin
        if REC."Staff ID" = '' then begin
            REC."Staff ID" := pStaffID;
            exit;
        end;

        if REC."Staff ID" <> pStaffID then begin
            if POSSESSION.StaffHasMgrPriv then begin
                if PosFuncProfile."Manager Takeover in Trans." = PosFuncProfile."Manager Takeover in Trans."::Always then
                    REC."Staff ID" := pStaffID;
                if PosFuncProfile."Manager Takeover in Trans." = PosFuncProfile."Manager Takeover in Trans."::"With Confirmation" then
                    if PosTransactionGui.PosConfirm(TakeOverTransQst, false) then begin
                        REC."Staff ID" := pStaffID;
                        REC."Manager ID" := pStaffID;
                    end else begin
                        Staff.Get(pStaffID);
                        REC."Manager ID" := pStaffID;
                        POSSESSION.SetManagerID(Staff, ReturnTxt);
                        POSSESSION.SetStaff(REC."Staff ID");
                    end;
            end
            else begin
                if PosFuncProfile."Staff Takeover in Trans." = PosFuncProfile."Staff Takeover in Trans."::Always then
                    REC."Staff ID" := pStaffID;
                if PosFuncProfile."Staff Takeover in Trans." = PosFuncProfile."Staff Takeover in Trans."::"With Confirmation" then
                    if PosTransactionGui.PosConfirm(TakeOverTransQst, false) then
                        REC."Staff ID" := pStaffID
                    else
                        POSSESSION.ClearManagerID();
            end;
        end;
    end;

    procedure TotalPressed(pSkipTenderDiscAtTotal: Boolean): Boolean
    var
        CheckLine, Splitline : Record "LSC POS Trans. Line";
        POSTransLine_L: Record "LSC POS Trans. Line";
        PosTransLineTemp1: Record "LSC POS Trans. Line" temporary;
        MemberAccountTemp: Record "LSC Member Account" temporary;
        MemberContactTemp: Record "LSC Member Contact" temporary;
        PosPrice: Codeunit "LSC POS Price Utility";
        CouponManagement: Codeunit "LSC Coupon Management";
        //LSRecommendMgt: Codeunit "LSC Recomm. Mgt.";
        COPOSFunctions: Codeunit "LSC CO POS Functions";
        COEditOrder: Codeunit "LSC CO Edit Order";
        ErrorText: Text;
        PerDiscType: Option "' ",Multibuy,"Mix&Match","Disc. Offer","Item Point'";
        OfferType: Enum "LSC POS Trans. Per. Disc. Type";
        NonCustomerOrderAmount, AllreadyPaid, DuePrepayAmount : Decimal;
        CreditCardHold: Boolean;
        SerialTracking, LotTracking : Boolean;
        IsHandled, ReturnValue : Boolean;
        KitchenItemsErr: Label 'There are items that need to be sent to kitchen. You cannot proceed.';
        AssignSerialNoErr: Label 'You must assign a Serial number for item %1.';
        AssignLotNoForItemErr: Label 'You must assign a Lot number for item %1.';
    begin
        IsHandled := false;
        POSTransactionEvents.OnBeforeTotalPressed(REC, IsHandled);
        if IsHandled then
            exit(true);

        if not REC.Get(REC."Receipt No.") then
            exit(False);

        if not POSTransactionFunctions.TotalCheckExchangeTransaction(REC) then
            exit(false);

        //if CustomerOrderSession.IsCustomerOrderEdit() then
        // if not COPOSFunctions.CheckForNoneCoItemsAddedToOrder(REC, ErrorText) then begin
        //     PosTransactionGui.ErrorBeep(ErrorText);
        //     exit(false);
        //end;

        AfterGetRecord;

        SerialTracking := false;
        LotTracking := false;

        POSTransactionEvents.OnBeforeValidateTrackingOnTotal(REC, POSTransLine_L, IsHandled);
        if not IsHandled then begin
            POSTransLine_L.Reset;
            POSTransLine_L.SetRange("Receipt No.", REC."Receipt No.");
            POSTransLine_L.SetRange("Entry Type", POSTransLine_L."Entry Type"::Item);
            POSTransLine_L.SetFilter(POSTransLine_L."Entry Status", '<>%1', POSTransLine_L."Entry Status"::Voided);
            if POSTransLine_L.FindSet then
                repeat
                    if Item.Get(POSTransLine_L.Number) then begin
                        if (Item."Item Tracking Code" <> '') and ItemTrackingCode.Get(Item."Item Tracking Code") then begin
                            if ItemTrackingCode."SN Specific Tracking" or ItemTrackingCode."SN Sales Outbound Tracking" then
                                SerialTracking := true;
                            if ItemTrackingCode."Lot Specific Tracking" or ItemTrackingCode."Lot Sales Outbound Tracking" then
                                LotTracking := true;
                        end;
                        //   POSTransactionEvents.OnBeforeCheckTracking(SerialTracking, LotTracking);
                        if SerialTracking and (POSTransLine_L."Serial No." = '') or LotTracking and (POSTransLine_L."Lot No." = '') then begin
                            if SerialTracking then
                                PosTransactionGui.ErrorBeep(StrSubstNo(AssignSerialNoErr, POSTransLine_L.Description))
                            else
                                PosTransactionGui.ErrorBeep(StrSubstNo(AssignLotNoForItemErr, POSTransLine_L.Description));
                            POSCtrl.IgnorePostCommand;
                            exit(false);
                        end;
                        // if POSTransactionFunctions.PreventNegativeInventoryAutoStockUpdate(PosFuncProfile."Automatic Stock Update", Item, Rec."Sale Is Return Sale", POSTransLine_L) then
                        //     exit(false);

                        // if POSTransLine_L."Line No." = POSTransLine_L."Parent Line" then
                        //     if not POSTransactionFunctions.CheckPriceZeroIsValid(POSTransLine_L.Price, Item) then
                        //         exit(false);
                    end;
                    SerialTracking := false;
                    LotTracking := false;
                until POSTransLine_L.Next = 0;
        end;

        CreditCardHold := REC."Credit Card Hold";
        if CreditCardHold then begin
            REC."Credit Card Hold" := false;
            REC.Modify;
        end;

        // POSTransactionEventsPub.OnBeforeApplyCouponsToTransactionOnTotalPressed(REC, CollectingOrder);

        if not REC."Sale Is Return Sale" then
            CouponManagement.ApplyCouponsToTransaction(REC, true, CollectingOrder);
        Commit;

        if (STATE = "LSC POS Transaction State"::TENDOP) or (STATE = "LSC POS Transaction State"::PHYS_INV) or (STATE = "LSC POS Transaction State"::NEG_ADJ) then begin
            PosTransactionGui.MessageBeep('');
            exit(false);
        end;

        IsHandled := false;
        // POSTransactionEvents.OnTotalPressed_OnBeforeCheckEmptyLine(REC, IsHandled, ReturnValue);
        If not IsHandled then begin
            CheckLine.SetRange("Receipt No.", REC."Receipt No.");
            if CheckLine.IsEmpty then begin
                PosTransactionGui.ErrorBeep(TotalError1);
                POSCtrl.IgnorePostCommand;
                exit(false);
            end;
        end else
            If ReturnValue then
                exit(false);

        if POSSESSION.GetValue("LSC POS Tag"::"SPLIT_PAY") <> 'NOKITCHEN' then
            // if HospFunc.LinesRemainingToBeSentToKitchen(StoreSetup, REC) then begin
            //     PosTransactionGui.ErrorBeep(KitchenItemsErr);
            //     POSCtrl.IgnorePostCommand;
            //     exit(false);
            // end;

        IsHandled := false;
        //  POSTransactionEvents.OnBeforeTotalExecuted(REC, IsHandled);
        if IsHandled then
            exit(true);

        IsHandled := false;
        //  POSTransactionEventsPub.OnBeforePeriodicDiscAndAdditionalBenefitCalcOnTotalPressed(REC, IsHandled);
        if not IsHandled then begin
            if (REC."Retrieved from Receipt No." = '') or (Rec."Sale Is Exchange Sale") then begin
                if PosFuncProfile."Period Disc. on Total Pressed" then
                    PosPrice.CalcPeriodicOnTotalPressed(REC);
                PosFunc.RecalcSlip(REC);
                PosOfferExt.ReCalcOfferSeq(REC, OfferType::"Total Discount");
            end;

            if not REC."Sale Is Return Sale" then
                ProcessAddBenefits("LSC POS Command"::PAYMENT);
        end;

        RetailCharge();
        if PosPrice.IsTransPerDiscType(REC, PerDiscType::"Mix&Match") then begin
            Splitline.Reset;
            Splitline.SetFilter("Receipt No.", REC."Receipt No.");
            if Splitline.FindSet then
                repeat
                    PosPrice.SplitMixMatchLine(Splitline, PosTransLineTemp1);
                until Splitline.Next = 0;
        end;
        CalcTotals;

        POSTransLine_L.Reset;
        POSTransLine_L.SetRange("Receipt No.", REC."Receipt No.");
        POSTransLine_L.SetRange("Entry Type", POSTransLine_L."Entry Type"::Item);
        POSTransLine_L.SetRange(Marked, true);

        if REC."Customer Order" and (POSTransLine_L.Count <> 0) and not COWasCreated then begin
            COAmountToDeductFromTot := 0;
            Commit;
            CustomerOrderCreate;
            COTotalHasBeenPressed := true;
            exit(false);
        end else
            // if REC."Customer Order" then
            //     if CustomerOrderSession.IsCustomerOrderEdit() then begin
            //         //comment24
            //         // MemberContactTemp := Member_.GetMemberRec();
            //         // MemberAccountTemp := Member_.GetAccountRec();
            //         // COEditOrder.CopyMemberAccountInfoFromCoHeader(CustomerOrderHeader_Temp, MemberContactTemp);
            //         // Member_.Set(MemberAccountTemp, MemberContactTemp);
            //     end;

        AllreadyPaid := 0;
        NonCustomerOrderAmount := 0;

        POSTransLine_L.Reset;
        POSTransLine_L.SetRange("Receipt No.", REC."Receipt No.");
        POSTransLine_L.SetRange("Entry Type", POSTransLine_L."Entry Type"::Payment);
        POSTransLine_L.SetFilter(POSTransLine_L."Entry Status", '<>%1', POSTransLine_L."Entry Status"::Voided);
        if POSTransLine_L.FindSet then
            repeat
                AllreadyPaid := AllreadyPaid + POSTransLine_L.Amount;
            until POSTransLine_L.Next = 0;

        POSTransLine_L.Reset;
        POSTransLine_L.SetRange("Receipt No.", REC."Receipt No.");
        POSTransLine_L.SetFilter("Entry Type", '%1|%2', POSTransLine_L."Entry Type"::Item, POSTransLine_L."Entry Type"::IncomeExpense);
        POSTransLine_L.SetFilter("Entry Status", '<>%1', POSTransLine_L."Entry Status"::Voided);
        POSTransLine_L.SetRange(Marked, false);
        if POSTransLine_L.FindSet then
            repeat
                NonCustomerOrderAmount := NonCustomerOrderAmount + POSTransLine_L.Amount;
            until POSTransLine_L.Next = 0;

        POSTransactionEvents.OnTotalPressedBeforeDisplayTotal(PosFuncProfile, Balance, IsHandled);
        if not IsHandled then
            DisplayTotals();

        SetPOSState("LSC POS Transaction State"::PAYMENT);
        //SetFunctionMode("LSC POS Command"::PAYMENT);

        if PrepayCustomerOrder then begin
            // if CustomerOrderSession.IsCustomerOrderEdit() then
            //     DuePrepayAmount := Balance
            // else begin
            //     CustomerOrderLine_Temp.Reset();
            //     CustomerOrderLine_Temp.Calcsums("Prepayment Amount");
            //     DuePrepayAmount := Balance - CustomerOrderLine_Temp."Prepayment Amount" - NonCustomerOrderAmount + AllreadyPaid;
            // end;
            if DuePrepayAmount > 0 then
                InfoTextDescription := StrSubstNo(PrePaymDueMsg, DuePrepayAmount)
            else
                InfoTextDescription := StrSubstNo(BalanceDueIsMsg, FormatAmount(Balance));
        end else
            InfoTextDescription := StrSubstNo(BalanceDueIsMsg, FormatAmount(Balance));

        InfoTextDescription2 := '';

        POSTransactionEvents.OnTotalPressedAfterSetInfoTextDescriptions(CustomerOrderLine_Temp, PosFuncProfile, InfoTextDescription, InfoTextDescription2);

        CurrInput := '';
        REC."Time when Total Pressed" := Time;
        // if REC."Starting Point Balance" <> PosFunc.GetMemberPointBalance then
        //     REC."Starting Point Balance" := PosFunc.GetMemberPointBalance;
        REC.Modify;

        //POSTransactionEvents.OnAfterTotalExecuted(REC);

        SelectDefaultMenu;

        if not pSkipTenderDiscAtTotal then
            POSGUI.PostCommand("LSC POS Command"::TENDER_DISC_AT_TOTAL, '');
        if CreditCardHold then begin
            REC."Credit Card Hold" := true;
            REC.Modify;
        end;

        if MultiplyWith <> 0 then
            MultiplyWith := 0;

        // LSRecommendMgt.MarkRecommendedItems(REC);
        exit(true);
    end;

    procedure PostPressed()
    begin
        if (STATE in ["LSC POS Transaction State"::TENDOP, "LSC POS Transaction State"::NEG_ADJ, "LSC POS Transaction State"::PHYS_INV]) or
           ((STATE = "LSC POS Transaction State"::PAYMENT) and (Balance = 0))
        then begin
            PostTransaction(true);
            exit;
        end;

        PosTransactionGui.MessageBeep('');
    end;

    procedure TotDiscAmPressed(Value: Text[30]; TotAmount: Boolean; InfocodeCheck: Boolean)
    var
        tmpLine: Record "LSC POS Trans. Line";
        DT: Record "LSC POS Trans. Per. Disc. Type";
        TotDiscLine: Record "LSC POS Trans. Line";
        lPOSTransLine: Record "LSC POS Trans. Line";
        PosPriceUtil: Codeunit "LSC POS Price Utility";
        COPOSFunctions: Codeunit "LSC CO POS Functions";
        Dec: Decimal;
        tmpPct: Decimal;
        AmDec: Decimal;
        NewBalance: Decimal;
        "Tax%": Decimal;
        IsHandled: Boolean;
        NoDiscToAmtErr: Label 'Total discount cannot be changed to "Amount".';
        TotalDiscAmtChangedMsg: Label 'Total Discount amount changed';
        TotalDiscAmtMsg: Label 'Total Disc. Amt.';
        TotalPaymAmtMsg: Label 'Total Payment Amt.';
        ItemsWhereAllowedDiscMsg: Label 'for Items where discount is allowed';
    begin
        POSTransactionEvents.OnBeforeTotDiscAmPressed(Value, TotAmount, InfocodeCheck, IsHandled);
        if IsHandled then
            exit;

        if (STATE = "LSC POS Transaction State"::TENDOP) or REC."New Transaction" then begin
            PosTransactionGui.MessageBeep('');
            exit;
        end;

        TotDiscAmPressedTotAmount := TotAmount;

        if (Value = '') and (CurrInput = '') then begin
            if TotAmount then
                PosTransactionGui.OpenNumericKeyboard(TotalPaymAmtMsg, '', Enum::"LSC POS Trans. Numpad Trigger"::TotDiscAmPressed)
            else
                PosTransactionGui.OpenNumericKeyboard(TotalDiscAmtMsg, '', Enum::"LSC POS Trans. Numpad Trigger"::TotDiscAmPressed);
            exit;
        end;

        POSLINES.GetCurrentLine(LineRec);
        if not SkipActionsInTotDiscAmPressed then
            POSTransactionEvents.OnBeforeTotDiscAm(REC, LineRec, CurrInput);
        if (LineRec.Number = '') or (LineRec."Entry Status" = LineRec."Entry Status"::Voided) or (LineRec."Entry Type" = LineRec."Entry Type"::IncomeExpense)
        or (LineRec."Entry Type" = LineRec."Entry Type"::PerDiscount) then begin
            LineRec.SetRange("Receipt No.", LineRec."Receipt No.");
            LineRec.SetRange("Entry Type", LineRec."Entry Type"::Item);
            LineRec.SetFilter("Entry Status", '<>%1', LineRec."Entry Status"::Voided);
            if not LineRec.FindLast then;
            LineRec.SetRange("Receipt No.");
            LineRec.SetRange("Entry Status");
            LineRec.SetRange(Number);
        end;

        PosPriceUtil.GetTransDisc(LineRec, false, DT.DiscType::Total);
        if LineRec."Total Disc. %" <> 0 then begin
            PosTransactionGui.ErrorBeep(NoDiscToAmtErr);
            exit;
        end;
        if Value <> '' then
            CurrInput := Value;
        if not Evaluate(AmDec, CurrInput) then begin
            PosTransactionGui.ErrorBeep(InvalidAmtValueErr);
            exit;
        end;

        NewBalance := CalcBalanceWithOutNoDiscAllowe();

        if TotAmount then begin
            POSTransactionEvents.OnTotDiscAmPressedAfterCalcNewBalance(Rec, PosFunc, NewBalance, "Tax%", AmDec);

            Dec := NewBalance - AmDec;
            if Dec < 0 then begin
                if (Balance <> NewBalance) then
                    PosTransactionGui.ErrorBeep(DiscExceedsBalanceErr + ' ' + ItemsWhereAllowedDiscMsg)
                else
                    PosTransactionGui.ErrorBeep(DiscExceedsBalanceErr);

                exit;
            end;
        end
        else begin
            Dec := AmDec;
        end;

        // PosFunc.AdjustAmount(Dec);
        if LineRec."Tot. Disc Info Line No." <> 0 then
            tmpLine.Get(REC."Receipt No.", LineRec."Tot. Disc Info Line No.");

        if Dec > NewBalance then begin
            if (Balance <> NewBalance) then
                PosTransactionGui.ErrorBeep(DiscExceedsBalanceErr + ' ' + ItemsWhereAllowedDiscMsg)
            else
                PosTransactionGui.ErrorBeep(DiscExceedsBalanceErr);
            exit;
        end;

        if (Balance - tmpLine.Amount) <> 0 then
            tmpPct := Dec / (Balance - tmpLine.Amount) * 100;

        if LineRec."System-Block Manual Discount" then begin
            lPOSTransLine.Reset;
            lPOSTransLine.SetRange("Receipt No.", LineRec."Receipt No.");
            lPOSTransLine.SetRange("Entry Type", lPOSTransLine."Entry Type"::Item);
            lPOSTransLine.SetRange("Entry Status", lPOSTransLine."Entry Status"::" ");
            lPOSTransLine.SetRange("System-Block Manual Discount", false);
            if lPOSTransLine.FindFirst then
                LineRec := lPOSTransLine;
        end;

        if LineRec."Entry Type" = LineRec."Entry Type"::Item then begin
            if not POSSESSION.PermissionItem('TDISC', LineRec.Number, tmpPct, 0, InfoTextDescription, POSSESSION.ManagerID, false) then begin
                PosTransactionGui.ErrorBeep(InfoTextDescription);
                exit;
            end;
        end;
        if not SkipActionsInTotDiscAmPressed then
            if InfocodeCheck then begin
                TotalDiscPressedPercentage := false;
                TotDiscPressedValue := Value;
                if CheckInfoCode('TOTDISC') then
                    exit;
            end;
        Clear(TotDiscLine);
        TotDiscLine.SetCurrentKey("Receipt No.", "Entry Type", "Entry Status");
        TotDiscLine.SetRange("Receipt No.", REC."Receipt No.");
        TotDiscLine.SetRange("Entry Type", TotDiscLine."Entry Type"::TotalDiscount);
        TotDiscLine.SetRange("Entry Status", TotDiscLine."Entry Status"::" ");
        if TotDiscLine.FindSet then begin
            repeat
                TotDiscLine.VoidLine;
            until TotDiscLine.Next = 0;
            LineRec."Tot. Disc Info Line No." := 0;
        end;
        if LineRec.CalcTotalDiscAmt(true, Dec, STATE = "LSC POS Transaction State"::PAYMENT) then begin
            LineRec.Modify(true);
            WriteMgrStatus;
            CalcTotals;
            if (STATE = "LSC POS Transaction State"::PAYMENT) then
                DisplayTotals;
            CurrInput := '';
            InfoTextDescription := TotalDiscAmtChangedMsg;

            if LineRec."Tot. Disc Info Line No." <> 0 then
                if LineRec.Get(LineRec."Receipt No.", LineRec."Tot. Disc Info Line No.") then;
        end
        else begin
            PosPriceUtil.InsertTransDiscAmount(LineRec, 0, DT.DiscType::Total, '');
            PosPriceUtil.InsertTransDiscPercent(LineRec, 0, DT.DiscType::Total, '');
            PosPriceUtil.UpdateTotalAmtDiscPercent(LineRec, 0);
            if Dec = 0 then begin
                CalcTotals;
                if (STATE = "LSC POS Transaction State"::PAYMENT) then
                    DisplayTotals;
                CurrInput := '';
                InfoTextDescription := TotalDiscAmtChangedMsg;
            end else
                PosTransactionGui.ErrorBeep(TotalDiscNotAppliedToAnyItemErr);
        end;

        if LineRec."Tot. Disc Info Line No." <> 0 then
            if LineRec.Get(LineRec."Receipt No.", LineRec."Tot. Disc Info Line No.") then;

        COPOSFunctions.UpdateCustomerOrderFromTotalDiscount(REC, COWasCreated, lPOSTransLine, CustomerOrderLine_Temp, CustomerOrderDiscountLine_Temp);

        if not SkipActionsInTotDiscAmPressed then
            POSTransactionEvents.OnAfterTotDiscAm(REC, LineRec, CurrInput);
        InfoTextDescription2 := StrSubstNo(BalanceDueIsMsg, FormatAmount(Balance));
    end;

    procedure TotDiscPrPressed(Value: Text[30]; InfocodeCheck: Boolean)
    var
        TotDiscLine: Record "LSC POS Trans. Line";
        DT: Record "LSC POS Trans. Per. Disc. Type";
        lPOSTransLine: Record "LSC POS Trans. Line";
        PosPriceUtil: Codeunit "LSC POS Price Utility";
        COPOSFunctions: Codeunit "LSC CO POS Functions";
        Dec: Decimal;
        IsHandled: Boolean;
        TotalDiscInvalidErr: Label 'Total discount cannot be changed to "%".';
        TotalDiscAppliedMsg: Label 'Total discount applied';
        TotalDiscMsg: Label 'Total Disc. %';
    begin
        POSTransactionEvents.OnBeforeTotDiscPrPressed(REC, Value, IsHandled);
        if IsHandled then
            exit;

        if (STATE = "LSC POS Transaction State"::TENDOP) or REC."New Transaction" then begin
            PosTransactionGui.MessageBeep('');
            exit;
        end;

        if (Value = '') and (CurrInput = '') then begin
            PosTransactionGui.OpenNumericKeyboard(TotalDiscMsg, '', Enum::"LSC POS Trans. Numpad Trigger"::TotDiscPrPressed);
            exit;
        end;

        POSLINES.GetCurrentLine(LineRec);
        POSTransactionEvents.OnBeforeTotDiscPr(REC, LineRec, CurrInput);
        if (LineRec.Number = '') or (LineRec."Entry Status" = LineRec."Entry Status"::Voided) or (LineRec."Entry Type" = LineRec."Entry Type"::IncomeExpense)
        or (LineRec."Entry Type" = LineRec."Entry Type"::PerDiscount) then begin
            LineRec.SetRange("Receipt No.", LineRec."Receipt No.");
            LineRec.SetRange("Entry Type", LineRec."Entry Type"::Item);
            LineRec.SetFilter("Entry Status", '<>%1', LineRec."Entry Status"::Voided);
            if not LineRec.FindLast then;
            LineRec.SetRange("Receipt No.");
            LineRec.SetRange("Entry Status");
            LineRec.SetRange(Number);
        end;

        PosPriceUtil.GetTransDisc(LineRec, false, DT.DiscType::Total);

        if (LineRec."Total Disc. %" = 0) and (LineRec."Total Disc. Amount" <> 0) then begin
            PosTransactionGui.ErrorBeep(TotalDiscInvalidErr);
            exit;
        end;

        if Value <> '' then
            CurrInput := Value;

        if not Evaluate(Dec, CurrInput) or (Abs(Dec) > 100) then begin
            PosTransactionGui.ErrorBeep(InvalidValInPercentErr);
            exit;
        end;

        POSTransactionEvents.OnTotDiscPrPressed_OnAfterEvaluateInput(LineRec, Dec, IsHandled);
        if IsHandled then
            exit;

        if LineRec."System-Block Manual Discount" then begin
            lPOSTransLine.Reset;
            lPOSTransLine.SetRange("Receipt No.", LineRec."Receipt No.");
            lPOSTransLine.SetRange("Entry Type", lPOSTransLine."Entry Type"::Item);
            lPOSTransLine.SetRange("Entry Status", lPOSTransLine."Entry Status"::" ");
            lPOSTransLine.SetRange("System-Block Manual Discount", false);
            if lPOSTransLine.FindFirst then
                LineRec := lPOSTransLine;
        end;

        if LineRec."Entry Type" = LineRec."Entry Type"::Item then begin
            if not POSSESSION.PermissionItem('TDISC', LineRec.Number, Dec, 0, InfoTextDescription,
              POSSESSION.ManagerID, false)
            then begin
                PosTransactionGui.ErrorBeep(InfoTextDescription);
                exit;
            end;
        end;

        if InfocodeCheck then begin
            TotalDiscPressedPercentage := true;
            TotDiscPressedValue := Value;
            if CheckInfoCode('TOTDISC') then
                exit;
        end;

        Clear(TotDiscLine);
        TotDiscLine.SetCurrentKey("Receipt No.", "Entry Type", "Entry Status");
        TotDiscLine.SetRange("Receipt No.", REC."Receipt No.");
        TotDiscLine.SetRange("Entry Type", TotDiscLine."Entry Type"::TotalDiscount);
        TotDiscLine.SetRange("Entry Status", TotDiscLine."Entry Status"::" ");
        if TotDiscLine.FindSet then begin
            repeat
                TotDiscLine.VoidLine;
            until TotDiscLine.Next = 0;
            LineRec."Tot. Disc Info Line No." := 0;
        end;
        PosPriceUtil.InsertTransDiscPercent(LineRec, Dec, DT.DiscType::Total, '');
        if LineRec.CalcTotalDiscPct(STATE = "LSC POS Transaction State"::PAYMENT) then begin
            LineRec.Modify(true);
            WriteMgrStatus;
            CalcTotals;
            if (STATE = "LSC POS Transaction State"::PAYMENT) then
                DisplayTotals;
            CurrInput := '';
            InfoTextDescription := TotalDiscAppliedMsg;

            if LineRec."Tot. Disc Info Line No." <> 0 then
                if LineRec.Get(LineRec."Receipt No.", LineRec."Tot. Disc Info Line No.") then;
        end
        else begin
            PosPriceUtil.InsertTransDiscAmount(LineRec, 0, DT.DiscType::Total, '');
            PosPriceUtil.InsertTransDiscPercent(LineRec, 0, DT.DiscType::Total, '');
            PosPriceUtil.UpdateTotalAmtDiscPercent(LineRec, 0);
            if Dec = 0 then begin
                CalcTotals;
                if (STATE = "LSC POS Transaction State"::PAYMENT) then
                    DisplayTotals;
                CurrInput := '';
                InfoTextDescription := TotalDiscAppliedMsg;
            end else
                PosTransactionGui.ErrorBeep(TotalDiscNotAppliedToAnyItemErr);
        end;
        if LineRec."Tot. Disc Info Line No." <> 0 then
            if LineRec.Get(LineRec."Receipt No.", LineRec."Tot. Disc Info Line No.") then;

        COPOSFunctions.UpdateCustomerOrderFromTotalDiscount(REC, COWasCreated, lPOSTransLine, CustomerOrderLine_Temp, CustomerOrderDiscountLine_Temp);

        POSTransactionEvents.OnAfterTotDiscPr(REC, LineRec, CurrInput);
        InfoTextDescription2 := StrSubstNo(BalanceDueIsMsg, FormatAmount(Balance));
    end;

    procedure SalePressed(Keyed: Boolean)
    begin
        SalePressed(Keyed, false);
    end;

    procedure SalePressed(Keyed: Boolean; FromInit: Boolean)
    var
        InitialCommandPressed: Code[20];
        StartPOSActionIsEmpty: Boolean;
        IsHandled: Boolean;
    begin
        if not TestNewTransaction then
            exit;

        InitialCommandPressed := GlobalMenuLine.Command;
        REC."Transaction Type" := REC."Transaction Type"::Sales;
        SetPOSState("LSC POS Transaction State"::SALES);
        POSTransactionEvents.OnBeforeSalePressedStartNewTrans(REC);
        REC."Sale Is Return Sale" := false;
        StartNewTransaction;
        POSTransactionEvents.OnAfterStartNewTransactionSalePressed(Keyed, REC);
        InfoTextDescription := '';
        SelectDefaultMenu;

        POSTransactionEvents.OnAfterSalePressedStartNewTrans(PosFuncProfile, Rec, Keyed, CurrInput, IsHandled);
        if IsHandled then
            exit;

        StartPOSActionIsEmpty := CheckStartPOSActions();
        if StartPOSActionIsEmpty or ((not StartPOSActionIsEmpty) and (InitialCommandPressed <> 'START')) then begin
            POSTransactionEvents.OnBeforeSetFunctionModeSalesPressed(POSFuncProfile, REC, Keyed, CurrInput, IsHandled);
            if not IsHandled then begin
                // if (PosFuncProfile."Sales Person Mode" = PosFuncProfile."Sales Person Mode"::Automatic) then
                //     if POSSESSION.StaffEmploymentType = 2 then begin //BOTH
                //         REC."Sales Staff" := POSSESSION.StaffID;
                //         SetFunctionMode("LSC POS Command"::ITEM);
                //     end else
                //         SetFunctionMode("LSC POS Command"::SALESP)
                // else
                //     SetFunctionMode("LSC POS Command"::ITEM);
            end;
        end;

        if Keyed and not REC."Sale Is Return Sale" then begin
            if FromInit then
                POSGUI.PostCommand("LSC POS Command"::CHECK_INFOCODE, 'START')
            else
                CheckInfoCode('START');
        end;
    end;

    procedure RefundPressed(Keyed: Boolean)
    var
        IsHandled: Boolean;
    begin
        if not TestNewTransaction then
            exit;
        if Keyed then
            if not POSSESSION.Permission("LSC POS Command"::REFUND, InfoTextDescription) then begin
                PosTransactionGui.ErrorBeep(InfoTextDescription);
                exit;
            end;

        REC."Transaction Type" := REC."Transaction Type"::Sales;
        POSTransactionEvents.OnBeforeRefundPressedStartNewTrans(REC);
        REC."Sale Is Return Sale" := true;
        SetPOSState("LSC POS Transaction State"::SALES);
        StartNewTransaction;
        InfoTextDescription := '';
        SelectDefaultMenu;
        POSTransactionEvents.OnBeforeSetFunctionModeRefundPressed(PosFuncProfile, REC, Keyed, IsHandled);
        if not IsHandled then begin
            // if (PosFuncProfile."Sales Person Mode" = PosFuncProfile."Sales Person Mode"::Automatic) then
            //     if POSSESSION.StaffEmploymentType = 2 then begin //BOTH
            //         REC."Sales Staff" := POSSESSION.StaffID;
            //         SetFunctionMode("LSC POS Command"::ITEM);
            //     end else
            //         SetFunctionMode("LSC POS Command"::SALESP)
            // else
            //     SetFunctionMode("LSC POS Command"::ITEM);
        end;
        POSTransactionEvents.OnAfterRefundPressed(REC, LineRec);

        if Keyed and REC."Sale Is Return Sale" then
            CheckInfoCode('REFUND');
    end;

    procedure AmountKeyPressed(TxtAmount: Text[50])
    begin
        CurrInput := TxtAmount;
    end;

    procedure CurrencyKeyPressed(CurrCode: Code[10]; CurrStatus: Integer)
    var
        Currency2: Record Currency;
        TenderTypeCurrencySetup: Record "LSC Tender Type Currency Setup";
        //POSExchangerateconversion: Codeunit "LSC POS Exch. rate conversion";
        AvailablePoints: Decimal;
        IsHandled: Boolean;
        BalanceInMsg: Label 'Balance in %1 %2';
        CurrencyTenderNotActiveErr: Label 'Currency tender not active';
        MemberPointBalanceMsg: Label 'Member Points Balance is %1';
    begin
        // POSTransactionEvents.OnBeforeCurrencyKeyPressed(REC, LineRec, CurrInput, CurrCode, CurrStatus, IsHandled);
        // if IsHandled then
        //     exit;

        // if (STATE = "LSC POS Transaction State"::TENDOP) then begin
        //     TenderTypeCurrencySetup.SetRange("Store No.", StoreSetup."No.");
        //     TenderTypeCurrencySetup.SetRange("Currency Code", CurrCode);
        //     if TenderTypeCurrencySetup.FindFirst then begin
        //         TenderType.Get(StoreSetup."No.", TenderTypeCurrencySetup."Tender Type Code");
        //         if TenderType."Remove/Float Type" = '' then begin
        //             PosTransactionGui.ErrorBeep(AddRemoveTenderTypeMissingErr);
        //             exit;
        //         end;
        //         InitNewLine;
        //     end;
        // end;

        // Currency.Get(CurrCode);
        // LastCurrencyCode := CurrCode;

        // if (CurrInput = '') and (PosFuncProfile."Numeric Keypad on Tender") then begin
        //     CurrencyKeyPressed_CurrCode := CurrCode;
        //     CurrencyKeyPressed_CurrStatus := CurrStatus;
        //     AmountInCurrency :=
        //       Round(
        //         POSExchangerateconversion.POSExchangeLCYToFCY(REC."Trans. Date", CurrCode, Balance) / REC."Currency Factor", Currency."Amount Rounding Precision");
        //     if (STATE <> "LSC POS Transaction State"::TENDOP) and (Balance < 0) then
        //         AmountInCurrency := -AmountInCurrency;

        //     if (STATE = "LSC POS Transaction State"::PAYMENT) or (STATE = "LSC POS Transaction State"::TENDOP) then begin
        //         if (TenderType."Function" = TenderType."Function"::Member) and (AmountInCurrency > 0) and (REC."Member Card No." <> '') then begin
        //             // AvailablePoints := PosFunc.GetMemberPointBalance - PosFunc.PointsUsedInTransaction(0);
        //             if not REC."Sale Is Return Sale" then begin
        //                 if AvailablePoints < AmountInCurrency then
        //                     AmountInCurrency := AvailablePoints;
        //                 if AvailablePoints = 0 then begin
        //                     PosTransactionGui.PosMessage(StrSubstNo(MemberPointBalanceMsg, Format(AvailablePoints)));
        //                     CancelPressed(true, 0);
        //                     exit;
        //                 end;
        //             end;
        //         end;
        //         // OposUtil.DisplayCurrency(Balance, AmountInCurrency, CurrCode);
        //         PosTransactionGui.OpenNumericKeyboard(AmountMsg + ' ' + CurrCode, Format(AmountInCurrency), Enum::"LSC POS Trans. Numpad Trigger"::CurrencyKeyPressed);
        //         exit;
        //     end
        //     else
        //         if (IncExpAccNo <> '') then begin
        //             PosTransactionGui.OpenNumericKeyboard(AmountMsg + ' ' + CurrCode, '', Enum::"LSC POS Trans. Numpad Trigger"::CurrencyKeyPressed);
        //             exit;
        //         end;
        // end;

        // if (CurrStatus <= 0) then begin
        //     AmountInCurrency := 0;
        //     RemainingFCY := 0;
        //     if CurrInput <> '' then begin
        //         if not Evaluate(AmountInCurrency, CurrInput) then begin
        //             PosTransactionGui.ErrorBeep(InvalidAmtValueErr);
        //             exit;
        //         end;
        //         //PosFunc.AdjustAmount(AmountInCurrency);
        //         KeyboardAmount := true;
        //     end
        //     else
        //         KeyboardAmount := false;

        //     if PosFuncProfile."Numeric Keypad on Tender" then begin
        //         AmountInCurrency :=
        //           Round(
        //             POSExchangerateconversion.POSExchangeLCYToFCY(REC."Trans. Date", CurrCode, Balance) / REC."Currency Factor", Currency."Amount Rounding Precision");
        //         if (STATE <> "LSC POS Transaction State"::TENDOP) and (Balance < 0) then
        //             AmountInCurrency := -AmountInCurrency;

        //         if (STATE = "LSC POS Transaction State"::PAYMENT) or (STATE = "LSC POS Transaction State"::TENDOP) then begin
        //             if (TenderType."Function" = TenderType."Function"::Member) and (AmountInCurrency > 0) and (REC."Member Card No." <> '') then begin
        //                 ///AvailablePoints := PosFunc.GetMemberPointBalance - PosFunc.PointsUsedInTransaction(0);
        //                 if not REC."Sale Is Return Sale" then
        //                     if AvailablePoints < AmountInCurrency then
        //                         AmountInCurrency := AvailablePoints;
        //             end;
        //         end else begin
        //             if (IncExpAccNo <> '') then begin
        //                 if CurrInput = '' then begin
        //                     PosTransactionGui.ErrorBeep(CANCELED_TXT);
        //                     exit;
        //                 end;
        //             end;
        //         end;

        //         if not Evaluate(AmountInCurrency, CurrInput) then begin
        //             PosTransactionGui.ErrorBeep(InvalidAmtValueErr);
        //             exit;
        //         end;

        //         if (TenderType."Function" = TenderType."Function"::Member) and (AmountInCurrency > 0) and (REC."Member Card No." <> '') then
        //             if not REC."Sale Is Return Sale" then
        //                 if AmountInCurrency > AvailablePoints then begin
        //                     AmountInCurrency := AvailablePoints;
        //                     PosTransactionGui.PosMessage(StrSubstNo(MemberPointBalanceMsg, Format(AvailablePoints)));
        //                 end;

        //         // PosFunc.AdjustAmount(AmountInCurrency);
        //         KeyboardAmount := true;

        //         InfoTextDescription := StrSubstNo(BalanceInMsg, Currency.Code, PosFunc.FormatCurrency(AmountInCurrency, Currency.Code));

        //         //OposUtil.DisplayCurrency(Balance, AmountInCurrency, Currency.Code);
        //     end;

        //     if CheckInfoCode('CURRENCY') then
        //         exit;
        // end;

        // if not KeyboardAmount then begin
        //     if STATE = "LSC POS Transaction State"::TENDOP then begin
        //         PosTransactionGui.ErrorBeep(AmtEntryRequiredErr);
        //         exit;
        //     end;
        //     AmountInCurrency :=
        //       Round(
        //         POSExchangerateconversion.POSExchangeLCYToFCY(REC."Trans. Date", CurrCode, Balance) / REC."Currency Factor", Currency."Amount Rounding Precision");
        //     InfoTextDescription := StrSubstNo(BalanceInMsg, Currency.Code, PosFunc.FormatCurrency(AmountInCurrency, Currency.Code));
        //     //OposUtil.DisplayCurrency(Balance, AmountInCurrency, Currency.Code);
        // end else begin
        //     if (STATE = "LSC POS Transaction State"::PAYMENT) or (STATE = "LSC POS Transaction State"::TENDOP) then begin
        //         if not TenderType."Foreign Currency" then begin
        //             PosTransactionGui.ErrorBeep(CurrencyTenderNotActiveErr);
        //             exit;
        //         end;
        //         if Currency."LSC Lowest Accept. Denom. Amt." <> 0 then begin
        //             if (AmountInCurrency mod Currency."LSC Lowest Accept. Denom. Amt.") <> 0 then begin
        //                 PosTransactionGui.ErrorBeep(StrSubstNo(LowestAcceptedDenomErr, FormatAmount(Currency."LSC Lowest Accept. Denom. Amt.")));
        //                 exit;
        //             end;
        //         end;
        //         if (STATE <> "LSC POS Transaction State"::TENDOP) and (Balance < 0) then
        //             AmountInCurrency := -AmountInCurrency;
        //         if REC."Trans. Currency Code" <> '' then
        //             Currency2.Get(REC."Trans. Currency Code");
        //         PaymentAmount :=
        //           PosFunc.RoundTender(
        //             TenderType,
        //             Round(
        //               POSExchangerateconversion.POSExchangeFCYToLCY(REC."Trans. Date", CurrCode, AmountInCurrency)
        //               * REC."Currency Factor", Currency2."Amount Rounding Precision"));
        //         if STATE <> "LSC POS Transaction State"::TENDOP then begin
        //             // if not PosFunc.ValidateTender(TenderType, REC."Gross Amount", Balance, PaymentAmount, REC."Sale Is Return Sale", true, InfoTextDescription) then begin
        //             //     PosTransactionGui.ErrorBeep(InfoTextDescription);
        //             //     exit;
        //             // end;
        //         end;

        //         if not TenderCheckloyalty() then
        //             exit;

        //         ChangeTender := false;
        //         InsertPaymentLine;
        //     end else begin
        //         if (IncExpAccNo <> '') then begin
        //             if REC."Trans. Currency Code" <> '' then
        //                 Currency2.Get(REC."Trans. Currency Code");
        //             PaymentAmount :=
        //               Round(POSExchangerateconversion.POSExchangeFCYToLCY(REC."Trans. Date", CurrCode, AmountInCurrency)
        //                 * REC."Currency Factor", Currency2."Amount Rounding Precision");
        //             if IncExpAccount."Account Type" = IncExpAccount."Account Type"::Expense then
        //                 if not REC."New Transaction" then
        //                     PaymentAmount := -PaymentAmount
        //                 else
        //                     if PosFuncProfile."Sales Person Mode" <> PosFuncProfile."Sales Person Mode"::Automatic then
        //                         PaymentAmount := -PaymentAmount;

        //             InitNewLine;
        //             InsertIncExpLine;
        //             SalePressed(false);
        //         end;
        //     end;
        // end;
    end;

    procedure InfoKeyPressed(var MenuLine: Record "LSC POS Menu Line")
    var
        InfoRec: Record "LSC Infocode";
        InfoSubCode: Record "LSC Information Subcode";
        "Code": Text[30];
        SubCode: Code[20];
        InfocodeOnHeader: Boolean;
        InfoKeyParamTooLongErr: Label 'Parameter too long';
        InfoKeyRequiresLineErr: Label 'This infocode requires line';
    begin
        Code := MenuLine.Parameter;

        if (STATE = "LSC POS Transaction State"::TENDOP) or REC."New Transaction" then begin
            PosTransactionGui.MessageBeep('');
            exit;
        end;
        if StrLen(Code) > 20 then begin
            PosTransactionGui.ErrorBeep(InfoKeyParamTooLongErr);
            exit;
        end;

        POSLINES.GetCurrentLine(LineRec);

        InfoRec.Get(Code);
        InfocodeOnHeader := false;
        if InfoRec."Once per Transaction" then begin
            LineRec."Line No." := 0;
            InfocodeOnHeader := true;
        end else
            if LineRec."Line No." = 0 then begin
                PosTransactionGui.ErrorBeep(InfoKeyRequiresLineErr);
                exit;
            end;
        InfoUtil.SetInfoCode(Code);
        LastCanceled := false;
        InfoFunction := 'KEY';
        StartFunction := FunctionSetup."Function Code";
        Clear(Info);

        Clear(SubCode);
        if MenuLine."Post Command" = Format("LSC POS Command"::INFO_SUB) then begin
            InfoSubCode.Get(InfoRec.Code, MenuLine."Post Parameter");
            SubCode := MenuLine."Post Parameter";
            MenuLine."Not Post Command" := true;
        end;
        ProcessInfoCode(SubCode, false, 0, InfocodeOnHeader);
    end;

    procedure TenderOp(Type: Integer): Boolean
    begin
        if not TestNewTransaction then
            exit(false);

        REC."Transaction Type" := Type;

        SetPOSState("LSC POS Transaction State"::TENDOP);
        StartNewTransaction;
        OposUtil.Display('', '');
        OpenDrawerEx('', true);
        //SetFunctionMode("LSC POS Command"::TENDOP);
        InfoTextDescription := '';
        SelectDefaultMenu;

        POSTransactionEvents.OnBeforeTenderOp(REC, LineRec);
        if not StoreSetup."Safe Mgnt. in Use" then begin
            if REC."Transaction Type" = REC."Transaction Type"::"Tender Decl." then
                if CheckInfoCode('TENDER_D') then
                    exit(true);
            if REC."Transaction Type" = REC."Transaction Type"::"Float Entry" then
                if CheckInfoCode('FLOAT_ENT') then
                    exit(true);
            if REC."Transaction Type" = REC."Transaction Type"::"Remove Tender" then
                if CheckInfoCode('REM_TENDER') then
                    exit(true);
        end;
        exit(false);
    end;

    procedure CardTypeKeyPressed(CardCode: Code[10])
    var
        TenderCardTypeMissingMsg: Label 'Tender type does not have cardtypes';
        CardTypeAlreadyBeenSetErr: Label 'Card type has already been set';
    begin
        if STATE <> "LSC POS Transaction State"::TENDOP then begin
            PosTransactionGui.MessageBeep('');
            exit;
        end;

        POSLINES.GetCurrentLine(LineRec);

        if LineRec.Number = '' then begin
            PosTransactionGui.MessageBeep('');
            exit;
        end;
        if not TenderType.Get(LineRec."Store No.", LineRec.Number) then begin
            PosTransactionGui.MessageBeep('');
            exit;
        end;
        if not (TenderType."Function" = TenderType."Function"::Card) then begin
            PosTransactionGui.MessageBeep(TenderCardTypeMissingMsg);
            exit;
        end;
        if LineRec."Card Type" <> '' then begin
            PosTransactionGui.ErrorBeep(CardTypeAlreadyBeenSetErr);
            exit;
        end;
        TenderCardType.Get(LineRec."Store No.", LineRec.Number, CardCode);
        LineRec."Card Type" := CardCode;
        LineRec.Description := TenderCardType.Description;
        LineRec.Modify(true);
        InfoTextDescription := StrSubstNo('%1 %2', LineRec.Description, FormatAmount(LineRec.Amount));
    end;

    procedure PostTransaction(PrintTransaction: Boolean)
    var
        POSTransPostingState: Record "LSC POS Trans. Posting State";
        IsHandled: Boolean;
    begin
        //POSTransactionEventsPub.OnBeforePostTransaction(Rec, IsHandled);
        if IsHandled then
            exit;

        if REC."Staff ID" = '' then begin
            REC."Staff ID" := POSSESSION.StaffID;
            REC.Modify();
        end;
        POSTransPostingState."Receipt No." := rec."Receipt No.";
        POSTransPostingState."Posting Source" := POSSESSION.GetTransPostingSource();
        POSTransPostingState."Posting State" := POSTransPostingState."Posting State"::"Error Checking";
        POSTransPostingState.STATE := Format(STATE);
        POSTransPostingState."Store No." := StoreSetup."No.";
        POSTransPostingState."POS Terminal No." := PosTerminal."No.";
        POSTransPostingState."Tender Type Code" := TenderType.Code;
        POSTransPostingState."POS Hardware Profile ID" := PosSetup."Profile ID";
        POSTransPostingState."Work Shift No." := POSSESSION.WorkShiftNo;
        POSTransPostingState."Training Active" := TrainingActive;
        POSTransPostingState."Global Sales Type" := GLobalSalesType;
        POSTransPostingState."Global Hosp. Type Seq." := GlobalHospTypeSeq;
        POSTransPostingState."POS Functionality Profile ID" := PosFuncProfile."Profile ID";
        POSTransPostingState."Prevent Normal Sale" := (POSSESSION.GetValue("LSC POS Tag"::"PREVENT_NORMSALE") <> '');
        POSTransPostingState.Print := PrintTransaction;
        POSTransPostingState."Current POS Command Code" := FunctionSetup."Function Code";
        POSTransPostingState.Remaining := Remaining;
        POSTransPostingState.RemainingFCY := RemainingFCY;
        // POSTransPostingState."Sales Trans. Printing Enabled" := not POSTransPrint.GetRecPrintDisabled();
        POSTransPostingState."Last Currency Code" := LastCurrencyCode;
        POSTransPostingState.Balance := Balance;
        POSTransPostingState."Gross Amount" := REC."Gross Amount";
        POSTransPostingState."Line Discount" := REC."Line Discount";
        POSTransPostingState."Inc./Exp. Amount" := REC."Income/Exp. Amount";
        POSTransPostingState."Net Amount" := REC."Net Amount";
        POSTransPostingState."Total Discount" := REC."Total Discount";
        POSTransPostingState.Payment := REC.Payment;
        POSTransPostingState.Prepayment := REC.Prepayment;

        // POSTransactionEvents.OnBeforeProcessTransForPostingByState(REC);
        // POSTransactionFunctions.ProcessTransactionForPostingByState(REC, POSTransPostingState);
        // POSTransactionEvents.OnAfterProcessTransForPostingByState(REC);
    end;

    procedure GetLastCardEntryReceiptNo(): Code[20]
    var
        lCardEntry: Record "LSC POS Card Entry";
    begin
        lCardEntry.SetCurrentKey("Store No.", "POS Terminal No.", "Transaction No.", "Line No.");
        lCardEntry.SetRange("Store No.", PosTerminal."Store No.");
        lCardEntry.SetRange("POS Terminal No.", PosTerminal."No.");
        if lCardEntry.FindLast then;
        exit(lCardEntry."Receipt No.");
    end;

    procedure PrintXReport(DoCheck: Boolean)
    var
        PrintUtil: Codeunit "LSC POS Print Utility";
        // SafeDenomPanelCommands: codeunit "LSC Safe Denom. Panel Commands";
        ErrorText: Text;
    begin
        // if PosSetup."Profile ID" = '' then
        //     PosSetup.Get(POSSESSION.HardwareProfileID);

        // if PosTerminal."No." = '' then
        //     PosTerminal.Get(POSSESSION.TerminalNo);

        // if not POSTransPrint.IsPrinterActive() then
        //     exit;

        // if DoCheck then
        //     if not TestNewTransaction then
        //         exit;

        // if POSSESSION.StaffID = '' then begin
        //     PosTransactionGui.PosMessage(ReportOnlyPrintableFromPosErr);
        //     exit;
        // end;

        // if not POSSESSION.Permission("LSC POS Command"::PRINT_X, InfoTextDescription) then begin
        //     PosTransactionGui.ErrorBeep(InfoTextDescription);
        //     exit;
        // end;

        // POSTransactionEvents.OnBeforePrintXReport(REC, DoCheck);

        // if not TSUtil.ReadStatementTransactions(false, ErrorText) then
        //     if (ErrorText <> '') then
        //         if not PosTransactionGui.PosConfirm(TransNoConnectionPrintThisTermOnlyQst, false) then
        //             exit;

        // PrintUtil.Init();
        // if not PrintUtil.PrintXReport then
        //     PosTransactionGui.PosMessage(PrintUtil.GetLastError);

        // TSUtil.UpdateXZReportInformation(false);
        // ClearGlobs();

        // if EFTActive(false) then
        //     if not EFT.EFTGetXReport(REC, true, ErrorText) then
        //         PosTransactionGui.PosMessage(ErrorText);

        // SafeDenomPanelCommands.CheckOfflineLogoffOnRunningReportPrinting();
    end;

    procedure PrintZReport(DoChecks: Boolean; AskUser: Boolean)
    var
        TmpStaff: Record "LSC Staff";
        lStaffRec: Record "LSC Staff";
        StaffStoreLink: Record "LSC STAFF Store Link";
        PosStartStatus: Record "LSC POS Start Status";
        PrintUtil: Codeunit "LSC POS Print Utility";
        //CashMgmt: Codeunit "LSC Cash Management";
        //SafeDenomPanelCommands: codeunit "LSC Safe Denom. Panel Commands";
        ErrorText: Text;
        NoSuspPOSTransactionsVoided: Integer;
        NoOfUnpostedTrans: Integer;
        EODNeedsPostingErr: Label 'End-Of-Day Tender Declaration needs to be posted';
        ZReportConfirmQst: Label 'Are you sure you want to print a Z Report?';
    begin
        // if PosSetup."Profile ID" = '' then
        //     PosSetup.Get(POSSESSION.HardwareProfileID);

        // if PosTerminal."No." = '' then
        //     PosTerminal.Get(POSSESSION.TerminalNo);

        // if not POSTransPrint.IsPrinterActive() then
        //     exit;

        // if POSSESSION.StaffID = '' then
        //     POSSESSION.SetStaff(REC."Staff ID");
        // POSTransactionEvents.OnBeforePrintZReport(REC, DoChecks);

        // PrintUtil.Init();
        // if not PrintUtil.IsZReportPrinterReady then begin
        //     PosTransactionGui.ErrorBeep(PrintUtil.GetLastError);
        //     exit;
        // end;

        // if DoChecks then begin
        //     if POSSESSION.StaffID = '' then begin
        //         PosTransactionGui.PosMessage(ReportOnlyPrintableFromPosErr);
        //         exit;
        //     end;
        //     if not TestNewTransaction then
        //         exit;
        //     NoOfUnpostedTrans := PosFunc.POSSalesTransExistInStore(StoreSetup."No.");
        //     if NoOfUnpostedTrans > 0 then begin
        //         if not PosTransactionGui.PosConfirm(StrSubstNo(UnpostedTransContinueQst, NoOfUnpostedTrans), false) then
        //             exit;
        //     end;
        //     if TrainingActive then begin
        //         PosTransactionGui.ErrorBeep(ZReportNotInTrainingErr);
        //         exit;
        //     end;
        // end;

        // if not POSSESSION.Permission("LSC POS Command"::PRINT_Z, InfoTextDescription) then begin
        //     PosTransactionGui.ErrorBeep(InfoTextDescription);
        //     exit;
        // end;

        // if not (PosFuncProfile.Get(POSSESSION.GetValue("LSC POS Tag"::"LSFUNCPROFILE"))) then
        //     PosFuncProfile.Get(StoreSetup."Functionality Profile");
        // if StoreSetup."Safe Mgnt. in Use" then begin
        //     if REC."Store No." = '' then
        //         REC."Store No." := POSSESSION.StoreNo;
        //     if REC."POS Terminal No." = '' then
        //         REC."POS Terminal No." := POSSESSION.TerminalNo;
        //     if REC."Staff ID" = '' then
        //         REC."Staff ID" := POSSESSION.StaffID;
        //     if not PosTerminal."Exclude from Cash Mgnt." then begin
        //         if not (CashMgmt.GetPOSStartStatus(REC, PosStartStatus)) or (PosStartStatus.Status <> PosStartStatus.Status::"End of Day")
        //         then begin
        //             PosTransactionGui.ErrorBeep(EODNeedsPostingErr);
        //             exit;
        //         end;
        //     end;
        // end;

        // if AskUser then
        //     if not PosTransactionGui.PosConfirm(ZReportConfirmQst, false) then
        //         exit;

        // if TSUtil.GetStaffV2(TmpStaff, StaffStoreLink, POSSESSION.StaffID, ErrorText) then
        //     TmpStaff.Modify;

        // if not TSUtil.ReadStatementTransactions(true, ErrorText) then
        //     if (ErrorText <> '') then
        //         if not PosTransactionGui.PosConfirm(TransNoConnectionPrintThisTermOnlyQst, false) then
        //             exit;

        // if ZReportSuspendProcess(NoSuspPOSTransactionsVoided) then begin
        //     if PrintUtil.PrintZReport(NoSuspPOSTransactionsVoided) then begin
        //         Commit;
        //         if lStaffRec.Get(POSSESSION.StaffID) then;
        //         if TSUtil.UpdateStaff(lStaffRec) then;
        //         TSUtil.UpdateXZReportInformation(true);
        //     end
        //     else
        //         PosTransactionGui.PosMessage(PrintUtil.GetLastError);
        // end;

        // InsertTmpTransaction(false);
        // ClearGlobs;

        // if EFTActive(false) then
        //     if not EFT.EFTGetZReport(REC, true, TrainingActive, ErrorText) then
        //         PosTransactionGui.PosMessage(ErrorText);

        // POSTransactionEvents.OnAfterPrintZReport(REC, DoChecks, AskUser);

        // SafeDenomPanelCommands.CheckOfflineLogoffOnRunningReportPrinting();
    end;

    procedure RunObjPressed(ObjCode: Code[10]; Source: Code[10])
    var
        ObjSetup: Record "LSC POS Run Objects";
        "Object": Record AllObj;
        TmpLine: Record "LSC POS Trans. Line";
        ObjCodeInvalidErr: Label 'Invalid object code';
        ObjNotFoundErr: Label 'Object does not exist. Check setup';
    begin
        if (ObjCode = '') and ObjSetup.Get(CurrInput) then begin
            ObjCode := CurrInput;
            Clear(CurrInput);
        end;
        if not ObjSetup.Get(ObjCode) then begin
            PosTransactionGui.ErrorBeep(ObjCodeInvalidErr);
            exit;
        end;
        if not Object.Get(ObjSetup."Object Type", ObjSetup."Object ID") then begin
            PosTransactionGui.ErrorBeep(ObjNotFoundErr);
            exit;
        end;
        if ObjSetup."Manager Key" then
            if not POSSESSION.MgrKey then begin
                PosTransactionGui.ErrorBeep(MgrKeyRequiredErr);
                exit;
            end;

        Commit;
        POSLINES.GetCurrentLine(TmpLine);
        //PosFunc.RunObject(ObjSetup, Source, REC."Receipt No.", Format(TmpLine."Line No."));
    end;

    procedure VoidPressed()
    var
        CustomerOrderStatusLog_Temp: Record "LSC Customer Order Status Log" temporary;
        CustomerOrderLineTemp: Record "LSC Customer Order Line" temporary;
        POSTransPostingState: Record "LSC POS Trans. Posting State";
        POSSession: Codeunit "LSC POS Session";
        // CustomerOrderCancelUtils: Codeunit LSCCustomerOrderCancelUtils;
        COPOSFunctions: Codeunit "LSC CO POS Functions";
        CustomerOrderID: Code[20];
        ResponseCode: Code[30];
        COLinesToBeVoided: List of [Integer];
        ErrorText: Text;
        AlreaydConfirmed: Boolean;
        VoidTransQst: Label 'Do you want to void the transaction?';
    begin
        if REC."New Transaction" then begin
            PosTransactionGui.MessageBeep('');
            exit;
        end;

        // if not SafeMgmtComm.IsSafeManagementPanel(POSSession.GetValue("LSC POS Tag"::"SAF-VOIDEDPANEL")) and not CustomerOrderHeader_Temp.CancelledOrder then begin
        //     if not POSSession.Permission("LSC POS Command"::VOID, InfoTextDescription) then begin
        //         PosTransactionGui.ErrorBeep(InfoTextDescription);
        //         exit;
        //     end;

        //     if not CheckVoidTransAndKDS(AlreaydConfirmed) then
        //         exit;

        //     if not AlreaydConfirmed then
        //         if POSSession.GetValue("LSC POS Tag"::"SKIPVOIDCONFIRM") <> 'TRUE' then
        //             if not PosTransactionGui.PosConfirm(VoidTransQst, false) then
        //                 exit;
        //     POSSession.DeleteValue("LSC POS Tag"::"SKIPVOIDCONFIRM");

        //     POSSession.SetTransPostingSource(POSTransPostingState."Posting Source"::"Void Pressed");
        //     POSTransactionEvents.OnAfterVoidPressed(REC);

        //     if CheckInfoCode('VOID') then
        //         exit;
        // end
        // else
        //     REC.Get(REC."Receipt No.");

        // if CustomerOrderSession.IsCustomerOrderEdit() then begin
        //     CustomerOrderSession.GetCustomerOrderHeaderNum(CustomerOrderID);
        //     if CustomerOrderID <> '' then
        //         if COPOSFunctions.UnLockOrder(CustomerOrderID, ErrorText) then begin
        //             CustomerOrderSession.ClearCustomerOrderHeaderNum();
        //             ClearAndDeleteAllCOTempVariables();
        //             Clear(CustomerOrderLineCompare_Temp);
        //             CustomerOrderLineCompare_Temp.DeleteAll();
        //             CollectingOrder := false;
        //         end else begin
        //             PosTransactionGui.ErrorBeep(ErrorText);
        //             exit;
        //         end;
        // end;

        if CollectingOrder then begin
            LineRec.Reset();
            LineRec.SetRange("Receipt No.", REC."Receipt No.");
            LineRec.SetRange("Customer Order Line", true);
            LineRec.SetFilter("Entry Type", '%1|%2', LineRec."Entry Type"::Item, LineRec."Entry Type"::IncomeExpense);
            LineRec.SetRange("CO Prepayment Line", false);
            LineRec.SetFilter("Entry Status", '<>%1', LineRec."Entry Status"::Voided);
            if LineRec.FindSet() then
                repeat
                    COLinesToBeVoided.Add(linerec."Line No.");
                until LineRec.Next() = 0;
            // if not CustomerOrderHeader_Temp.CancelledOrder then begin
            //     // POSTransactionEventsPub.UpdateCOStatusWhenVoidingCollect(CustomerOrderHeader_Temp."Document ID", LineRec."POS Terminal No.", COLinesToBeVoided, LineRec);
            //     CustomerOrderSession.GetCustomerOrderIDWhenCollected('');
            // end else
            //     if not CustomerOrderPayment_Temp.IsEmpty then
            //         CustomerOrderSession.GetCustomerOrderIDWhenCollected('');
            LineRec.Reset;
            CollectingOrder := false;
        end;

        POSSession.SetTransPostingSource(POSTransPostingState."Posting Source"::"Void Pressed");
        VoidTransaction;

        if CustomerOrderHeader_Temp.CancelledOrder then begin
            Commit;
            CollectingOrder := false;
            COPOSFunctions.SetStatusLogInfo(CustomerOrderStatusLog_Temp);
            // CustomerOrderSession.GetCustomerOrderIDWhenCollected('');
            // CustomerOrderCancelUtils.SetPosFunctionalityProfile(POSSession.FunctionalityProfileID);
            // CustomerOrderCancelUtils.SendRequest(CustomerOrderID, 0, CustomerOrderLineTemp, CustomerOrderStatusLog_Temp, ResponseCode, ErrorText);
            ClearAndDeleteAllCOTempVariables();
            Clear(CustomerOrderLineCompare_Temp);
            CustomerOrderLineCompare_Temp.DeleteAll();
        end;
    end;

    local procedure ClearAndDeleteAllCOTempVariables()
    begin
        Clear(CustomerOrderHeader_Temp);
        CustomerOrderHeader_Temp.DeleteAll;
        Clear(CustomerOrderPayment_Temp);
        CustomerOrderPayment_Temp.DeleteAll;
        Clear(CustomerOrderLine_Temp);
        CustomerOrderLine_Temp.DeleteAll;
        Clear(CustomerOrderDiscountLine_Temp);
        CustomerOrderDiscountLine_Temp.DeleteAll();
    end;

    procedure VoidTransaction()
    var
        VoidCardEntry: Record "LSC POS Card Entry";
        Transaction: Record "LSC Transaction Header";
        tmpRecord: Record "LSC POS Trans. Line";
        // POSInfoDataMgt: Codeunit "LSC POS InfoData Mgt.";
        ResponseCode: Code[30];
        ErrorText: Text;
        IsHandled, PrintTransaction : Boolean;
        VoidedCardEntryNo: Integer;
        ErrorLineCannotBeVoided: Label 'Line %1 cannot be voided';
        NoVoidingAlreadyVoidedErr: Label 'Cannot void already voided card entry';
    begin
        CurrInput := '';
        InfoTextDescription := '';
        InfoTextDescription2 := '';
        // OposUtil.ClearLastQty();

        if not CheckBillPrinted then
            exit;
        POSTransactionEvents.OnBeforeVoidTransaction(REC, IsHandled);
        if IsHandled then
            exit;

        POSSESSION.UpdatePosPicture(tmpRecord);

        tmpRepayPOSTrans.DeleteAll;
        tmpRepayPOSTransLines.DeleteAll;

        POSTransactionEvents.OnBeforeCheckTransactionLines(REC."Receipt No.");

        LineRec.Reset;
        LineRec.SetRange("Receipt No.", REC."Receipt No.");
        LineRec.SetRange("Entry Status", LineRec."Entry Status"::" ");
        if LineRec.FindSet then
            repeat
                if LineRec."System-Exclude from Void" then begin
                    POSLINES.SetCurrentLine(LineRec);
                    PosTransactionGui.ErrorBeep(StrSubstNo(ErrorLineCannotBeVoided, LineRec.Description));
                    exit;
                end;

                if ((LineRec."Entry Type" = LineRec."Entry Type"::Payment) or
                    ((LineRec."Entry Type" = LineRec."Entry Type"::FreeText) and (LineRec."Text Type" = LineRec."Text Type"::"Pre-Auth Text")))
                    and
                   (LineRec."Card Entry No." <> 0) then begin
                    VoidCardEntry.Get(PosTerminal."Store No.", PosTerminal."No.", LineRec."Card Entry No.");
                    if VoidCardEntry."Transaction Type" in [VoidCardEntry."Transaction Type"::Sale,
                       VoidCardEntry."Transaction Type"::Refund, VoidCardEntry."Transaction Type"::Offline,
                       VoidCardEntry."Transaction Type"::PreAuth, VoidCardEntry."Transaction Type"::UpdatePreAuth,
                       VoidCardEntry."Transaction Type"::FinalizePreAuth]
                    then begin
                        if not VoidCard(VoidCardEntry, VoidedCardEntryNo, ErrorText) then begin
                            PosTransactionGui.ErrorBeep(ErrorText);
                            exit;
                        end;
                        LineRec.VoidLine;
                    end
                    else begin
                        PosTransactionGui.ErrorBeep(NoVoidingAlreadyVoidedErr);
                        exit;
                    end;
                end;

                POSTransactionEvents.OnVoidTransaction(Rec, LineRec);

                if LineRec."Parent Transaction Doc. No." <> '' then begin
                    tmpRepayPOSTrans := REC;
                    if tmpRepayPOSTrans.Insert then;
                    tmpRepayPOSTransLines := LineRec;
                    tmpRepayPOSTransLines.Insert(true);
                end;


                POSTransactionEvents.PosTransactionOnAfterVoidTransaction(LineRec);

                if (LineRec."Entry Type" = LineRec."Entry Type"::Coupon) and
                  (LineRec."Entry Status" = LineRec."Entry Status"::" ") and
                  (LineRec."Coupon Barcode No." <> '') and
                  (LineRec."Coupon Code" <> '')
                then
                    CouponResetReservation(LineRec);
            until LineRec.Next = 0;

        LineRec.Reset;
        LineRec.SetRange("Receipt No.", Rec."Receipt No.");
        if not LineRec.IsEmpty then
            if REC."Retrieved from Receipt No." <> '' then begin
                if PosFuncProfile."TS Void Transactions" or PosFuncProfile."DD Void Transactions" then begin
                    if TSUtil.Initialize then
                        if TSUtil.GetPostedTransaction(REC."Retrieved from Receipt No.", '', '', 0, ResponseCode, ErrorText) then;
                end;
                if Transaction.Get(REC."Retrieved from Store No.", REC."Retrieved from POS Term. No.", REC."Retrieved from Trans. No.")
                then begin
                    Transaction."Refund Receipt No." := '';
                    Transaction.Modify(true);
                    if PosFuncProfile."TS Void Transactions" or PosFuncProfile."DD Void Transactions" then
                        if not (TSUtil.SendTransaction(Transaction, true)) then;
                end;
            end;

        //POSInfoDataMgt.DelSPOInfoData(REC);
        SetErrorCheck;
        REC."Entry Status" := REC."Entry Status"::Voided;
        NotIncludeWebPreAuth := false;
        PrintTransaction := true;
        POSTransactionEvents.OnBeforePostTransactionOnVoidTransaction(PrintTransaction);
        PostTransaction(PrintTransaction);
        PaymentCount := 0;
    end;

    procedure VoidLinePressed()
    var
        SelectedPOSTransLine: Record "LSC POS Trans. Line";
        COEditOrder: Codeunit "LSC CO Edit Order";
        MarkedLines: Boolean;
        NoOfVoidedLines: Integer;
        DisplayErrorText: Text;
        DescrOfLastVoidedLine: Text;
        ErrorOnlyVoidOneLine: Label 'Marked lines include %1 lines. You can only void one %1 line at a time.';
        VoidInfocodeItemIsNotSupported: Label 'Voiding Infocode connected Item is not supported when Editing Customer Order.';
        IsHandled: Boolean;
    begin
        POSTransactionEvents.OnBeforevoidLinePressed(Rec, IsHandled);
        if IsHandled then
            exit;

        // if CustomerOrderSession.IsCustomerOrderEdit() then begin
        //     POSLINES.GetCurrentLine(LineRec);
        //     // if COEditOrder.IsGiftCardEntry(LineRec.Number) then begin  // if there are entries then this is most likely a gift card, Voucher or similar
        //     //     PosTransactionGui.ErrorBeep(VoidInfocodeItemIsNotSupported);
        //     //     exit;
        //     // end;
        // end;

        NoOfVoidedLines := 0;
        DescrOfLastVoidedLine := '';

        LineRec.Reset;
        LineRec.SetRange("Receipt No.", REC."Receipt No.");
        LineRec.SetRange(LineRec."Entry Status", 0);

        if LineRec.IsEmpty then begin
            LineRec.SetRange("Entry Status");
            PosTransactionGui.MessageBeep('');
            exit;
        end;
        LineRec.SetRange("Entry Status");

        if not POSSESSION.Permission("LSC POS Command"::VOID_L, InfoTextDescription) then begin
            PosTransactionGui.ErrorBeep(InfoTextDescription);
            exit;
        end;

        if not CheckBillPrinted then
            exit;

        WriteMgrStatus;

        MarkedLines := false;

        SelectedPOSTransLine.SetRange("Receipt No.", REC."Receipt No.");
        SelectedPOSTransLine.SetRange(Marked, true);
        SelectedPOSTransLine.SetRange("Customer Order Line", false);
        // if CustomerOrderSession.IsCustomerOrderEdit() then
        //     SelectedPOSTransLine.SetRange("Entry Status", LineRec."Entry Status"::Voided);
        POSTransactionEvents.OnBeforeProcessSelectedLines(Rec, SelectedPOSTransLine);
        if SelectedPOSTransLine.FindSet() then begin
            MarkedLines := true;
            repeat
                SelectedPOSTransLine.get(SelectedPOSTransLine."Receipt No.", SelectedPOSTransLine."Line No.");  //In case the line was already voided through linking
                if SelectedPOSTransLine."Entry Type" = SelectedPOSTransLine."Entry Type"::Payment then
                    PosTransactionGui.PosErrorBanner(StrSubstNo(ErrorOnlyVoidOneLine, format(SelectedPOSTransLine."Entry Type")), 5)
                else begin
                    POSLINES.SetCurrentLine(SelectedPOSTransLine);
                    if VoidSingleLine(DisplayErrorText) then begin
                        NoOfVoidedLines += 1;
                        DescrOfLastVoidedLine := SelectedPOSTransLine.Description;
                    end;
                    if DisplayErrorText <> '' then
                        PosTransactionGui.PosErrorBanner(DisplayErrorText, 5);
                end;
            until SelectedPOSTransLine.next = 0;
        end else begin
            if VoidSingleLine(DisplayErrorText) then begin
                NoOfVoidedLines += 1;
                DescrOfLastVoidedLine := Linerec.Description;
            end;
            if DisplayErrorText <> '' then
                PosTransactionGui.ErrorBeep(DisplayErrorText);
        end;

        if MarkedLines then begin
            SelectedPOSTransLine.reset;
            SelectedPOSTransLine.SetRange("Receipt No.", REC."Receipt No.");
            SelectedPOSTransLine.SetRange("Customer Order Line", false);
            // if CustomerOrderSession.IsCustomerOrderEdit() then
            //     SelectedPOSTransLine.SetRange("Entry Status", LineRec."Entry Status"::Voided);
            POSTransactionEvents.OnBeforeUnmarkSelectedLines(Rec, SelectedPOSTransLine);
            SelectedPOSTransLine.ModifyAll(Marked, false);
        end;

        if NoOfVoidedLines > 0 then begin
            VoidLineNoOfVoidedLines := NoOfVoidedLines;
            VoidLineLastVoidedLineDescr := DescrOfLastVoidedLine;
            VoidLineShowOnDisplay := not MarkedLines;
            if CheckInfoCode('VOID_L') then
                exit;

            POSTransactionEvents.OnBeforeVoidLinePressedEx(REC, LineRec);
            VoidLinePressedEx(NoOfVoidedLines, DescrOfLastVoidedLine, (not MarkedLines));

            UpdateMarkedLinesInCO();
        end;
    end;

    procedure VoidSingleLine(var DisplayErrorText: text): Boolean
    var
        VoidCardEntry: Record "LSC POS Card Entry";
        VoucherEntries: Record "LSC Voucher Entries";
        SplitLineRec: Record "LSC POS Trans. Line";
        OfferPoscalculations: Record "LSC Offer Pos Calculation";
        LineTransInfoEntry: Record "LSC POS Trans. Infocode Entry";
        POSAddSalesp: Record "LSC POS Trans. Add. Salesp.";
        POSTransLine2: Record "LSC POS Trans. Line";
        OfferPosCalc: Record "LSC Offer Pos Calculation";
        POSTransPeriodicDisc: Record "LSC POS Trans. Per. Disc. Type";
        POSTransPerDisc: Record "LSC POS Trans. Per. Disc. Type";
        // PosInfoDataMgt: Codeunit "LSC POS InfoData Mgt.";
        // PosPriceUtil: Codeunit "LSC POS Price Utility";
        // POSPrepaymentUtil: Codeunit "LSC POS Prepayment Mgt.";
        //  DealPricingFunctions: Codeunit "LSC Deal Pricing Functions";
        COPosFunc: Codeunit "LSC CO POS Functions";
        ErrorText: Text;
        HandledErrorText: Text;
        ErrorCode: Code[30];
        VoidedCardEntryNo: Integer;
        SumQty: Decimal;
        lPrice: Decimal;
        lQty: Decimal;
        COLinesToBeVoided: List of [Integer];
        LinesFound: Boolean;
        PromOnMember: Boolean;
        Handled: Boolean;
        ReturnValue: Boolean;
        IsHandled: Boolean;
        ErrorPrepaymentCannotBeVoided: Label 'Prepayment line %1 cannot be voided. Void transaction and start new deposit';
        ErrorHigherNumberReturnedIfVoided: Label 'Line %1 cannot be voided.\Voiding would mean higher number returned than sold.';
        ErrorVoidTotalDiscBeforeVoiding: Label 'You need to void the total discount given before voiding the deal line %1.';
        ErrorItemLinkedToCoupon: Label 'Item %1 is linked to a coupon.\Void the coupon before voiding the item.';
        ErrorLineCannotBeVoided: Label 'Line %1 cannot be voided.';
        ErrorLineIsPerDiscount: Label 'Line %1 is a period discount line, it cannot be voided';
        ErrorCardPaymentAlreadyVoided: Label 'The card payment %1 is already voided.';
        ConfirmVoidingPayment: Label 'Voiding payment: ';
        ConfirmVoid: Label '\\Confirm void?';
        ConfirmVoidingCustomer: Label 'Voiding customer:\   ';
        ConfirmVoidingMember: Label 'Voiding Member:\   ';
        ConfirmVoidingAllSplitlines: Label 'Voiding all split lines for item: ';
        COPrepaymenCannotBeVoidedWhenEditOrder: Label 'Prepayment line %1 cannot be voided when editing an order';
        EmptyCardEntry: Record "LSC POS Card Entry";
    begin
        DisplayErrorText := '';

        POSLINES.GetCurrentLine(LineRec);

        if LineRec."Customer Order Line" and LineRec."CO Prepayment Line" then
            // if CustomerOrderSession.IsCustomerOrderEdit() then
            //     if LineRec."Entry Type" = LineRec."Entry Type"::IncomeExpense then begin
            //         DisplayErrorText := StrSubstNo(COPrepaymenCannotBeVoidedWhenEditOrder, LineRec.Description);
            //         exit(false)
            //     end;

        POSTransactionEvents.OnBeforeVoidLine(REC, LineRec, Handled, HandledErrorText, ReturnValue);
        if Handled then begin
            DisplayErrorText := HandledErrorText;
            exit(ReturnValue);
        end;

        if (LineRec."Entry Status" = LineRec."Entry Status"::Voided) then
            exit(false);

        if (LineRec."Entry Type" = LineRec."Entry Type"::PerDiscount) then begin
            DisplayErrorText := StrSubstNo(ErrorLineIsPerDiscount, LineRec.Description);
            exit(false);
        end;

        if LineRec."Parent Transaction Doc. No." <> '' then begin
            DisplayErrorText := StrSubstNo(ErrorPrepaymentCannotBeVoided, LineRec.Description);
            exit(false);
        end;

        if LineRec."System-Exclude from Void" then begin
            DisplayErrorText := StrSubstNo(ErrorLineCannotBeVoided, LineRec.Description);
            exit(false);
        end;

        if (LineRec."Entry Type" = LineRec."Entry Type"::Item) and (LineRec."Coupon Qty Used" <> 0) then begin
            DisplayErrorText := StrSubstNo(ErrorItemLinkedToCoupon, LineRec.Description);
            exit(false);
        end;

        if LineRec."Deal Line" then begin
            if (LineRec."Total Disc. %" <> 0) or (LineRec."Total Disc. Amount" <> 0) then begin
                DisplayErrorText := StrSubstNo(ErrorVoidTotalDiscBeforeVoiding, LineRec.Description);
                exit(false);
            end;
        end;

        if (LineRec."Entry Type" = LineRec."Entry Type"::IncomeExpense) and REC."Customer Order Deposit" then begin
            DisplayErrorText := StrSubstNo(ErrorPrepaymentCannotBeVoided, LineRec.Description);
            exit(false);
        end;

        if not CheckVoidLineAndKDS(DisplayErrorText) then
            exit(false);

        if (LineRec."Entry Type" = LineRec."Entry Type"::Item) and (LineRec.Quantity > 0) then begin
            SumQty := 0;
            if ReturnRestrictions(SumQty, LineRec, false, LinesFound) then begin
                if SumQty - LineRec.Quantity < 0 then begin
                    DisplayErrorText := StrSubstNo(ErrorHigherNumberReturnedIfVoided, LineRec.Description);
                    exit(false);
                end;
            end;
        end;

        if RemoveCouponDiscount(LineRec) then
            PosFunc.RecalcSlip(REC);

        if STATE <> "LSC POS Transaction State"::TENDOP then begin
            POSTransactionEvents.OnBeforeVoidingPaymentOnVoidSingleLine(IsHandled);
            if (LineRec."Entry Type" = LineRec."Entry Type"::Payment) and (not IsHandled) then begin
                if not PosTransactionGui.PosConfirm(ConfirmVoidingPayment + LineRec.Description + ConfirmVoid, true) then
                    exit(false);
                if LineRec."Card Entry No." <> 0 then begin
                    VoidCardEntry.Get(PosTerminal."Store No.", PosTerminal."No.", LineRec."Card Entry No.");
                    if VoidCardEntry."Transaction Type" in [VoidCardEntry."Transaction Type"::"Void Sale",
                       VoidCardEntry."Transaction Type"::"Void Refund", VoidCardEntry."Transaction Type"::"Void Offline"]
                    then begin
                        DisplayErrorText := StrSubstNo(ErrorCardPaymentAlreadyVoided, LineRec.Description);
                        exit(false);
                    end;
                    if not VoidCard(VoidCardEntry, VoidedCardEntryNo, DisplayErrorText) then
                        exit(false);
                end;
            end;
            if LineRec."Entry Type" = LineRec."Entry Type"::FreeText then begin
                if (LineRec."Card/Customer/Coup.Item No" <> '') and (LineRec."Text Type" = LineRec."Text Type"::"Pre-Auth Text") then begin
                    VoidCardEntry.Get(PosTerminal."Store No.", PosTerminal."No.", LineRec."Card Entry No.");
                    if not VoidCard(VoidCardEntry, VoidedCardEntryNo, DisplayErrorText) then
                        exit(false);
                end else
                    if (LineRec."Card/Customer/Coup.Item No" <> '') and (REC."Customer No." <> '') then begin  //customer void
                        if not PosTransactionGui.PosConfirm(ConfirmVoidingCustomer + LineRec.Description + ConfirmVoid, true) then
                            exit(false);
                        Clear(Customer);
                        ProcessCustomer(true);
                    end;

                if (LineRec."Text Type" = LineRec."Text Type"::"Member Text") and (REC."Member Card No." <> '') then begin  //member void
                    if not PosTransactionGui.PosConfirm(ConfirmVoidingMember + LineRec.Description + ConfirmVoid, true) then
                        exit(false);
                    //Member.Init();

                    //PromOnMember := PosPriceUtil.IsPromotionForMember(REC);

                    REC."Member Card No." := '';
                    REC."Member Price Group" := '';

                    POSTransPerDisc.Reset;
                    POSTransPerDisc.SetCurrentKey(DiscType);
                    POSTransPerDisc.SetRange(DiscType, POSTransPerDisc.DiscType::Customer);
                    POSTransPerDisc.SetRange("Receipt No.", REC."Receipt No.");
                    PosFunc.PosTransDiscSetTableFilter(1, POSTransPerDisc);
                    if PosFunc.PosTransDiscFindRec(1, '-', POSTransPerDisc) then begin
                        repeat
                            POSTransLine2.Get(POSTransPerDisc."Receipt No.", POSTransPerDisc."Line No.");
                            //PosPriceUtil.InsertTransDiscPercent(POSTransLine2, 0, POSTransPerDisc.DiscType::Customer, '');
                            POSTransLine2.CalcPrices;
                            // if not PosFuncProfile."Disable POS Prepayment" then
                            //     POSPrepaymentUtil.SetPosTransLinePrepaymentPct(POSTransLine2);
                            POSTransLine2.Modify(true);
                        until PosFunc.PosTransDiscNextRec(1, 1, POSTransPerDisc) = 0;
                    end;

                    REC."Starting Point Balance" := 0;
                    PosFunc.ClearmemberInfo;
                    //PosFunc.ClearPosTransDiscEntryBuffer;
                    REC.Modify;

                    POSTransLine2.Reset;
                    POSTransLine2.SetRange("Receipt No.", REC."Receipt No.");
                    POSTransLine2.SetRange("Entry Type", POSTransLine2."Entry Type"::Item);
                    if POSTransLine2.FindSet then
                        repeat
                            Clear(OfferPosCalc);
                            OfferPosCalc.SetRange("Receipt No.", POSTransLine2."Receipt No.");
                            OfferPosCalc.SetRange("Trans. Line No.", POSTransLine2."Line No.");
                            OfferPosCalc.DeleteAll;
                            // PosPriceUtil.InsertTransDiscPercent(POSTransLine2, 0, POSTransPeriodicDisc.DiscType::"Periodic Disc.", '');
                            if PromOnMember then begin
                                lPrice := POSTransLine2.Price;
                                lQty := POSTransLine2.Quantity;
                                //PosPriceUtil.InsertTransDiscPercent(POSTransLine2, 0, POSTransPeriodicDisc.DiscType::"Periodic Disc.", '');
                                if not POSTransLine2."Deal Line" then
                                    POSTransLine2."Promotion No." := '';
                                POSTransLine2."Mix & Match Line No." := 0;
                                //PosPriceUtil.InsertTransDiscAmount(POSTransLine2, 0, POSTransPeriodicDisc.DiscType::"Periodic Disc.", '');
                                // if not POSTransLine2."Price Change" then
                                //     PosPriceUtil.CalcPrice(POSTransLine2, false);
                                if (lPrice <> POSTransLine2.Price) then begin
                                    POSTransLine2.Validate(Quantity, lQty);
                                    POSTransLine2.Modify(true);
                                end;
                            end;
                            POSTransactionEvents.OnBeforeClearDiscOfferVoidLinePressed(PosFunc, POSTransLine2);
                            PosFunc.ClearPosTransLineOffers(POSTransLine2);
                            //PosPriceUtil.InitGlobals(POSTransLine2, true);
                            //PosPriceUtil.FindPeriodicOffers(POSTransLine2);
                            PosFunc.AddPosTransLineOffers(POSTransLine2);
                            POSTransLine2.Modify(true);
                        until POSTransLine2.Next = 0;
                    //PosPriceUtil.CalcPeriodicOnTotalPressed(REC);
                    //DealPricingFunctions.DealPricing_UpdatePricingForDealsInTransaction(REC);
                    PosFunc.RecalcSlip(REC);
                    REC.Modify;
                    Commit;
                    POSTransactionEvents.OnAfterVoidMemberLineProcessed(LineRec);
                end;
            end
        end;
        CurrInput := '';

        IsHandled := false;
        POSTransactionEvents.OnVoidLine(LineRec, IsHandled, TenderType, StoreSetup, REC, EmptyCardEntry, CustomerOrCardNo, ReadFromMSR, ChangeTender);
        if IsHandled then
            exit;

        if LineRec."Entry Type" = LineRec."Entry Type"::Payment then
            if TenderType.Get(LineRec."Store No.", LineRec.Number) then
                if TenderType."Function" = TenderType."Function"::Coupons then
                    VoidCouponQtyUsed(LineRec);

        if LineRec."Split Origin Line No." <> 0 then begin
            if not PosTransactionGui.PosConfirm(ConfirmVoidingAllSplitlines + LineRec.Description + ConfirmVoid, true) then
                exit(false);
            SplitLineRec.Reset;
            SplitLineRec.SetRange("Receipt No.", LineRec."Receipt No.");
            SplitLineRec.SetRange("Split Origin Line No.", LineRec."Split Origin Line No.");
            SplitLineRec.SetRange(Number, LineRec.Number);
            SplitLineRec.SetFilter("Line No.", '<>%1', LineRec."Line No.");
            if SplitLineRec.FindSet then begin
                repeat
                    SplitLineRec.VoidLine;
                    VoidLinkedLines(SplitLineRec."Line No.");
                until SplitLineRec.Next = 0;

                LineRec.Get(LineRec."Receipt No.", LineRec."Line No.");
            end;
        end;

        if (LineRec."Entry Type" = LineRec."Entry Type"::Coupon) and
          (LineRec."Entry Status" = LineRec."Entry Status"::" ") and
          (LineRec."Coupon Barcode No." <> '') and
          (LineRec."Coupon Code" <> '')
        then
            CouponResetReservation(LineRec);

        if CollectingOrder and LineRec."Customer Order Line" and (LineRec."Entry Type" = LineRec."Entry Type"::Item) then begin
            if not CustomerOrderHeader_Temp.CancelledOrder then begin
                COLinesToBeVoided.Add(LineRec."Line No.");
                // POSTransactionEventsPub.UpdateCOStatusWhenVoidingCollect(CustomerOrderHeader_Temp."Document ID", LineRec."POS Terminal No.", COLinesToBeVoided, LineRec);
                CalcVoidedLineCOPrePayment(COLinesToBeVoided.Get(1));
            end
        end;

        LineRec.VoidLine;

        // COTotalAmount := COPosFunc.GetTotalCustomerOrderAmountInPosTransaction(REC."Receipt No.");

        // if REC."Entry Status" <> REC."Entry Status"::Training then
        //     posfunc.SetCustomerOrder(REC, LineRec, ErrorCode, ErrorText);
        if ErrorText <> '' then begin
            PosTransactionGui.ErrorBeep(ErrorText);
            exit;
        end;

        if not REC."Customer Order" then
            CollectingOrder := false;

        if LineRec."Deal Line" then
            VoidDeal()
        else begin
            VoidLinkedLines(LineRec."Line No.");
        end;

        if VoucherEntries.Get(LineRec."Store No.", LineRec."POS Terminal No.", 0, LineRec."Line No.", LineRec."Receipt No.") then begin
            VoucherEntries.Voided := true;
            VoucherEntries.Modify;
        end;

        LineTransInfoEntry.Reset;
        LineTransInfoEntry.SetRange("Receipt No.", LineRec."Receipt No.");
        LineTransInfoEntry.SetRange("Line No.", LineRec."Line No.");
        LineTransInfoEntry.ModifyAll(Status, LineTransInfoEntry.Status::Voided);

        if (LineRec."Entry Type" in [LineRec."Entry Type"::Item, LineRec."Entry Type"::FreeText]) and  //Void the infocode that triggered the line
           (LineRec."Parent Line" > 0) and
           (LineRec."Parent Line" <> LineRec."Line No.")
        then begin
            if LineTransInfoEntry.Get(
                 LineRec."Receipt No.", LineTransInfoEntry."Transaction Type"::"Sales Entry", LineRec."Parent Line",
                 LineRec."Orig. from Infocode", LineRec."Infocode Entry Line No.")
            then begin
                if LineTransInfoEntry."Selected Quantity" > LineRec."Infocode Selected Qty." then
                    LineTransInfoEntry."Selected Quantity" := LineTransInfoEntry."Selected Quantity" - LineRec."Infocode Selected Qty."
                else
                    LineTransInfoEntry.Status := LineTransInfoEntry.Status::Voided;
                LineTransInfoEntry.Modify;
            end;
        end;

        OfferPoscalculations.SetRange("Receipt No.", LineRec."Receipt No.");
        OfferPoscalculations.SetRange("Trans. Line No.", LineRec."Line No.");
        if OfferPoscalculations.FindFirst then
            OfferPoscalculations.DeleteAll;

        POSAddSalesp.SetRange("Receipt No.", LineRec."Receipt No.");
        POSAddSalesp.SetRange("Line No.", LineRec."Line No.");
        if not POSAddSalesp.IsEmpty then
            POSAddSalesp.DeleteAll;

        // PosInfoDataMgt.DelSPOInfoDataEntry(LineRec);

        POSTransactionEvents.OnAfterVoidLine(REC, LineRec);

        exit(true);
    end;

    procedure VoidLinePressedEx(NoOfVoidedLines: Integer; DescrOfLastVoidedLine: Text; ShowOnDisplay: Boolean)
    var
        //  KDSFunctions: Codeunit "LSC KDS Functions";
        //  COUtility: Codeunit "LSC CO Utility";
        MsgOneLineVoided: label 'Line %1 voided !';
        MsgLinesVoided: label '%1 lines voided !';
    begin
        // PosFunc.RecalcSlip(REC);
        // CalcTotals;

        // if ShowOnDisplay then begin //only show on display if one line (selected) voided
        //     if STATE <> "LSC POS Transaction State"::TENDOP then begin
        //         if LineRec."Entry Type" = LineRec."Entry Type"::Payment then
        //             OposUtil.DisplayTotals(REC."Gross Amount", Balance)
        //         else
        //             if LineRec."Scale Item" or LineRec."Price in Barcode" then
        //                 OposUtil.DisplayScaleLine(
        //                   '', LineRec.Description, -LineRec.Quantity, LineRec.Price,
        //                   -LineRec.Amount, LineRec."Unit of Measure")
        //             else
        //                 OposUtil.DisplaySalesLine('', LineRec.Description, -LineRec.Quantity, LineRec.Price, -LineRec.Amount, LineRec."Unit of Measure", true);
        //     end;
        // end;

        // if NoOfVoidedLines > 1 then
        //     InfoTextDescription := StrSubstNo(MsgLinesVoided, NoOfVoidedLines)
        // else
        //     InfoTextDescription := StrSubstNo(MsgOneLineVoided, DescrOfLastVoidedLine);
        // POSLINES.UpdateAll;

        // KDSFunctions.SendToKDSifOnItemAddedSet(LineRec, REC."Receipt No.", false);

        // if PosFunc.IsInPaymentState then
        //     ProcessAddBenefits(GetFunctionModeEnum);

        // if REC."Customer Order" then
        //     COUtility.UpdateOrderLines(REC, CustomerOrderLine_Temp, CustomerOrderDiscountLine_Temp, CustomerOrderHeader_Temp);

        // POSTransactionFunctions.VoidExchangeTransaction(REC, stateTxt, LineRec);
    end;

    procedure VoidLinkedLines(VoidedLineNo: Integer)
    var
        LinkedLine: Record "LSC POS Trans. Line";
    begin
        LinkedLine.SetCurrentKey("Receipt No.", "Parent Line");
        LinkedLine.SetRange("Receipt No.", REC."Receipt No.");
        LinkedLine.SetRange("Parent Line", VoidedLineNo);
        LinkedLine.SetFilter("Line No.", '<>%1', VoidedLineNo);
        if LinkedLine.FindSet then
            repeat
                LinkedLine.VoidLine;
                VoidLinkedLines(LinkedLine."Line No.");
            until LinkedLine.Next = 0;
    end;

    local procedure CalcVoidedLineCOPrePayment(VoidedLineNo: Integer)
    var
        COLines: Record "LSC POS Trans. Line";
        COPrePaymentAmount: Decimal;
        CoVoidedLineAmount: Decimal;
        COAmountForAllItems: Decimal;
        CoVoidedAmountDifference: Decimal;
    begin
        CoVoidedLineAmount := LineRec.Amount;
        LineRec.SetRange("Entry Type", LineRec."Entry Type"::IncomeExpense);
        if LineRec.IsEmpty then
            exit;
        LineRec.CalcSums(Amount);
        COPrePaymentAmount := -LineRec.Amount;

        COLines.SetRange("Receipt No.", LineRec."Receipt No.");
        COLines.SetRange("Customer Order Line", true);
        COLines.SetRange("Entry Type", COLines."Entry Type"::Item);
        COLines.CalcSums(Amount);
        COAmountForAllItems := COLines.Amount;
        if COAmountForAllItems > 0 then begin
            CoVoidedAmountDifference := COPrePaymentAmount - (COAmountForAllItems - CoVoidedLineAmount);
            if (CoVoidedAmountDifference > 0) or ((COAmountForAllItems - CoVoidedLineAmount) = 0) then begin
                LineRec.SetRange("Entry Type", LineRec."Entry Type"::IncomeExpense);
                linerec.FindLast();
                LineRec.Amount := -(COPrePaymentAmount - CoVoidedAmountDifference);
                LineRec."Net Amount" := -LineRec.Amount;
                LineRec."Net Price" := LineRec."Net Amount";
                LineRec."Price" := LineRec."Amount";
                LineRec.Modify();
            end;
        end;
        LineRec.Reset();
        LineRec.SetRange("Line No.", VoidedLineNo);
        LineRec.SetRange("Receipt No.", LineRec."Receipt No.");
        if LineRec.FindFirst() then
            exit;
    end;

    procedure OpenDrawerPressed(RoleID: Code[10])
    begin
        if not TestNewTransaction then
            exit;
        if not POSSESSION.Permission("LSC POS Command"::OPEN_DR, InfoTextDescription) then begin
            PosTransactionGui.ErrorBeep(InfoTextDescription);
            exit;
        end;
        POSTransactionEvents.OnAfterOpenDrawerPressed(REC, LineRec, CurrInput, RoleID);

        OpenDrawerPressedRoleID := RoleID;

        if CheckInfoCode('OPENDRAWER') then
            exit;
        OpenDrawerPressedEx(RoleID);
    end;

    procedure OpenDrawerPressedEx(RoleID: Code[10])
    var
        tmpTrans: Record "LSC Transaction Header";
    //POSPostUtility: Codeunit "LSC POS Post Utility";
    begin
        // OposUtil.Display('', '');
        // REC."Transaction Type" := REC."Transaction Type"::"Open Drawer";
        // StartNewTransaction;
        // SetErrorCheck;

        // POSPostUtility.ProcessTransaction(REC);

        // if not TrainingActive then begin
        //     if PosFuncProfile."TS Send Transactions" or PosFuncProfile."DD Send Transaction" then begin
        //         POSPostUtility.GetLastTransaction(tmpTrans);
        //         if not (TSUtil.SendTransaction(tmpTrans, false)) then;
        //     end;
        //     OpenDrawer(RoleID);
        //     WaitDrawerClosed(RoleID);
        // end;

        // POSTransactionEvents.OnAfterOpenDrawerPressedEx(RoleId, TrainingActive, tmpTrans);

        // POSSESSION.ClearManagerID;
        // InsertTmpTransaction(false);
    end;

    procedure OpenDrawer(RoleID: Code[10])
    begin
        OpenDrawerEx(RoleID, false);
    end;

    procedure OpenDrawerEx(RoleID: Code[10]; SuppressAlerts: Boolean)
    begin
        // if not OposUtil.IsDrawerOpen(RoleID) then
        //     POSTransactionEvents.OnBeforeOpenDrawer(REC, LineRec, CurrInput);

        // OposUtil.OpenDrawerEx(RoleID, SuppressAlerts);
    end;

    procedure WaitDrawerClosed(RoleID: Code[10])
    var
        StopTime: Time;
        DelayedUpdate: Integer;
        bWasOpen: Boolean;
    begin
        // Commit;

        // DelayedUpdate := 0;
        // // Sleep(500);

        // InitDrawer(RoleID, '');
        // if (DrawerDevice.IsActive()) and (DrawerDevice."Drawer Alert Timeout" > 0) then
        //     StopTime := Time + (DrawerDevice."Drawer Alert Timeout" * 1000)
        // else
        //     StopTime := Time + 40000;  //Default 40 seconds

        // while OposUtil.IsDrawerOpen(RoleID) and (StopTime > Time) do begin
        //     bWasOpen := true;
        //     if DelayedUpdate = 2 then begin
        //         ShowDrawerOpenWarning(RoleID);
        //     end;
        //     DelayedUpdate += 1;
        //     Sleep(500);
        // end;
        // ScreenDisplay('');

        // if bWasOpen and (not OposUtil.IsDrawerOpen(RoleID)) then
        //     POSTransactionEvents.OnAfterWaitDrawerClosed(REC, LineRec, CurrInput);
    end;

    procedure WaitAllDrawersClosed()
    var
        HWProfileDevices: Record "LSC POS Hardware Profile Dev.";
    begin
        // HWProfileDevices.SetRange(HWProfileDevices."Profile ID", PosSetup."Profile ID");
        // HWProfileDevices.SetRange(HWProfileDevices."Device Type", HWProfileDevices."Device Type"::DRAWER);
        // if HWProfileDevices.FindSet then
        //     repeat
        //         if OposUtil.IsDrawerOpen(HWProfileDevices."Device Role") then
        //             WaitDrawerClosed(HWProfileDevices."Device Role");
        //     until HWProfileDevices.Next = 0;

        // if OposUtil.IsDrawerOpen('') then //Default Drawer
        //     WaitDrawerClosed('');
    end;

    procedure LogoffPressed(closePos: Boolean)
    var
        SalesTypes: Record "LSC Sales Type";
        MinAmount: Decimal;
        RetrievedSlipNo: Code[20];
        ErrTxt3: Label 'Deposit is below the limit of %1';
    begin
        POSTransactionEvents.OnBeforeLogoff(REC, SalesTypes, closePos);
        if SalesTypes.Get(GLobalSalesType) then begin
            if ((SalesTypes."Request Deposit (%)" > 0) or (SalesTypes."Minimum Deposit" <> 0)) and (Balance > 0) then begin
                MinAmount := (REC."Gross Amount" + REC."Line Discount") * SalesTypes."Request Deposit (%)" / 100;
                if MinAmount < SalesTypes."Minimum Deposit" then
                    MinAmount := SalesTypes."Minimum Deposit";
                if REC.Payment < MinAmount then begin
                    PosTransactionGui.ErrorBeep(StrSubstNo(ErrTxt3, Format(MinAmount)));
                    exit;
                end;
            end;
        end;

        if PosTerminal."Open Drawer at LI/LO" and not TrainingActive then begin
            OpenDrawer('');
            WaitDrawerClosed('');
        end;

        POSSESSION.SetValue("LSC POS Tag"::"SPLIT_PAY", '');
        POSSESSION.SetValue("LSC POS Tag"::"LASTPOSTRANS", REC."Receipt No.");
        RetrievedSlipNo := POSSESSION.GetValue("LSC POS Tag"::"RetrievedSlipNo");
        if REC."Retrieved from Suspended Trans" or (RetrievedSlipNo = REC."Receipt No.") then
            POSSESSION.SetValue("LSC POS Tag"::"RetrievedSlipNo", Rec."Receipt No.");

        if closePos then
            CloseForm()
        else
            POSSESSION.ClearManagerID;

        if REC."Entry Status" = REC."Entry Status"::InUse then begin
            REC."Entry Status" := REC."Entry Status"::" ";
            REC.Modify(true);
        end;
        POSTransactionEvents.OnAfterLogoff(REC, SalesTypes, closePos);
    end;

    procedure CancelPressed(Hard: Boolean; Requested: Integer)
    var
        VoidCardEntry: Record "LSC POS Card Entry";
        OfferPosCalc: Record "LSC Offer Pos Calculation";
        VoidCardEntryNo: Integer;
        ErrorReason: Text;
        IsHandled: Boolean;
        COFinishCurrentTransactionOrVoid: Label 'Please finish the current transaction or Void it if you want to Cancel.';
        InfocodeRequiredMsg: Label 'Infocode input is required. You need to select or enter an infocode.';
        DiscCancelledMsg: Label 'Discount cancelled!';
        InfoCodeMissingInputMsg: Label 'Input is required for this infocode';
    begin
        if not _Initialized then  //codeunit not initialized, Cancel is coming from other panel
            exit;
        POSTransactionEvents.OnBeforeCancel(REC, CurrInput, Hard);
        if CurrInput <> '' then begin
            CurrInput := '';
            if not Hard then exit;
        end;
        if FunctionSetup."Function Code" = Format("LSC POS Command"::ERRCHK) then
            exit;

        if (STATE = "LSC POS Transaction State"::PAYMENT) and CustomerOrderHeader_Temp.CancelledOrder then begin
            Clear(CurrInput);
            PosTransactionGui.ErrorBeep(COFinishCurrentTransactionOrVoid);
            exit;
        end;

        if FunctionSetup."Function Code" = Format("LSC POS Command"::INFOCODE) then begin
            if Info."Input Required" then begin
                POSTransactionEvents.OnBeforeCheckInfoCodeInputRequired(Info, IsHandled);
                if not IsHandled then
                    if (InfoFunction = 'ITEM') or (InfoFunction = 'PAYMENT') or
                       (InfoFunction = 'INCEXP') or (InfoFunction = 'KEY')
                    then begin
                        if InfoFunction <> 'KEY' then begin
                            if PosTransactionGui.PosConfirm(InfocodeRequiredCancelQst, false) then begin
                                if (LineRec."Entry Type" = LineRec."Entry Type"::Payment) and
                                   (LineRec."Card Entry No." <> 0)
                                then begin
                                    VoidCardEntry.Get(PosTerminal."Store No.", PosTerminal."No.", LineRec."Card Entry No.");
                                    if not VoidCard(VoidCardEntry, VoidCardEntryNo, ErrorReason) then begin
                                        PosTransactionGui.ErrorBeep(ErrorReason);
                                        exit;
                                    end;
                                end;
                                OfferPosCalc.SetRange("Receipt No.", LineRec."Receipt No.");
                                OfferPosCalc.SetRange("Trans. Line No.", LineRec."Line No.");
                                OfferPosCalc.DeleteAll;
                                //POSLINES.DelRecord(LineRec);
                                //POSLINES.DeleteLinkedLines(LineRec."Line No.");
                                FunctionSetup.Get(StartFunction);
                                SetInputPrompt(FunctionSetup.Prompt);
                                InfoTextDescription := '';
                                LineRec.Reset;
                                LineRec.SetRange("Receipt No.", REC."Receipt No.");
                                if LineRec.FindLast then begin
                                    POSLINES.GetCurrentLine(LineRec);
                                end;
                                gCancelOffer := true;
                            end else
                                ProcessInfoCode('', true, Requested, false);
                        end else begin
                            PosTransactionGui.PosMessage(InfocodeRequiredMsg);
                            if Info."Once per Transaction" then
                                ProcessInfoCode('', true, 0, true)
                            else
                                ProcessInfoCode('', true, 0, false);
                        end;
                    end else begin
                        ValidateInput;
                        //POSLINES.DeleteRefundPOSLines(REC, InfoFunction);
                    end;
            end else
                ValidateInput;
            if (InfoFunction <> 'MARKDN') and (InfoFunction <> 'TOTDISC') and
               (InfoFunction <> 'OPENDRAWER') and (InfoFunction <> 'REFUND') and (InfoFunction <> 'OVERRIDE') and (InfoFunction <> 'EXCHANGE')
            then
                exit;
        end;
        MultiplyWith := 1;
        UOMSet := '';
        InfoTextDescription := '';
        InfoTextDescription2 := '';
        if not gInfoCodeSelectionOk then begin
            if InfoFunction in ['MARKDN', 'TOTDISC'] then
                SetPosInfoText1(DiscCancelledMsg);
            if InfoFunction = 'OPENDRAWER' then
                SetPosInfoText1(InfoCodeMissingInputMsg);
        end;
        StartingPaymentsIntoAccount := false;
        if (STATE = "LSC POS Transaction State"::SALES) and not REC."New Transaction" then begin
            Clear(LineRec);
            LineRec.SetRange("Receipt No.", REC."Receipt No.");
            if not LineRec.FindLast then begin
                ClearPOSTransaction;
            end;
        end
        else
            if STATE = "LSC POS Transaction State"::PAYMENT then begin
                if (FunctionSetup."Function Code" = Format("LSC POS Command"::PAYMENT)) and
                   (REC."Transaction Type" <> REC."Transaction Type"::Payment)
                then begin
                    if REC."Sale Is Return Sale" then begin
                        POSTransactionEvents.OnBeforeSelectDefaultMenuInCancelPressed(IsHandled);
                        if not IsHandled then
                            if POSSESSION.GetRefundMenu <> '' then begin
                                if POSGUI.GetCurrMenu(0) <> POSSESSION.GetRefundMenu then begin
                                    SelectDefaultMenu;
                                    exit;
                                end;
                            end
                            else begin
                                if POSGUI.GetCurrMenu(0) <> POSSESSION.GetPaymentMenu then begin
                                    SelectDefaultMenu;
                                    exit;
                                end;
                            end;
                    end
                    else begin
                        if POSGUI.GetCurrMenu(0) <> POSSESSION.GetPaymentMenu then begin
                            SelectDefaultMenu;
                            exit;
                        end;
                    end;

                    SetPOSState("LSC POS Transaction State"::SALES);
                end;
            end;

        //SelectDefaultMenu;
        // if STATE = "LSC POS Transaction State"::TENDOP then
        //     SetFunctionMode("LSC POS Command"::TENDOP)
        // else
        //     if STATE = "LSC POS Transaction State"::PAYMENT then
        //         SetFunctionMode("LSC POS Command"::PAYMENT)
        //     else begin
        //         SetPOSState("LSC POS Transaction State"::SALES);
        //         SetFunctionMode("LSC POS Command"::ITEM);
        //         SetInfoFunction('ITEM');
        //     end;

        SelectDefaultMenu;

        InsertDealLines();
    end;

    procedure SuspendPressed(SaleType: Code[20])
    var
        POSTransSuspensionState: Record "LSC POS Trans. Susp. State";
    begin
        POSTransSuspensionState.init;
        POSTransSuspensionState."Receipt No." := REC."Receipt No.";
        POSTransSuspensionState."Suspension State" := POSTransSuspensionState."Suspension State"::"Initial Error Checking";
        POSTransSuspensionState.STATE := Format(STATE);
        POSTransSuspensionState."Store No." := StoreSetup."No.";
        POSTransSuspensionState."POS Terminal No." := PosTerminal."No.";
        POSTransSuspensionState."Tender Type Code" := TenderType.Code;
        POSTransSuspensionState."POS Hardware Profile ID" := PosSetup."Profile ID";
        POSTransSuspensionState."Work Shift No." := POSSESSION.WorkShiftNo;
        POSTransSuspensionState."Training Active" := TrainingActive;
        POSTransSuspensionState."Suspension Sales Type" := SaleType;
        POSTransSuspensionState."POS Functionality Profile ID" := PosFuncProfile."Profile ID";
        POSTransSuspensionState."Prevent Normal Sale" := (POSSESSION.GetValue("LSC POS Tag"::"PREVENT_NORMSALE") <> '');
        POSTransSuspensionState."Current POS Command Code" := FunctionSetup."Function Code";
        POSTransSuspensionState.Remaining := Remaining;
        POSTransSuspensionState.RemainingFCY := RemainingFCY;
        POSTransSuspensionState."Last Currency Code" := LastCurrencyCode;
        POSTransSuspensionState.Balance := Balance;
        POSTransSuspensionState."Gross Amount" := REC."Gross Amount";
        POSTransSuspensionState."Line Discount" := REC."Line Discount";
        POSTransSuspensionState."Inc./Exp. Amount" := REC."Income/Exp. Amount";
        POSTransSuspensionState."Net Amount" := REC."Net Amount";
        POSTransSuspensionState."Total Discount" := REC."Total Discount";
        POSTransSuspensionState.Payment := REC.Payment;
        POSTransSuspensionState.Prepayment := REC.Prepayment;

        POSTransactionFunctions.ProcessTransactionForSuspensionByState(REC, POSTransSuspensionState);
    end;

    procedure SuspendTransaction(POSTransaction: Record "LSC POS Transaction"; SalesType: Record "LSC Sales Type")
    var
        EmptyTransLine: Record "LSC POS Trans. Line";
        SuspendedPOSTransaction: Record "LSC POS Transaction";
        SendPOSTransSuccess: Boolean;
    begin
        CurrInput := '';
        REC.Get(POSTransaction."Receipt No.");
        CalcTotals;
        POSTransactionEvents.OnAfterSuspend(REC);
        SendPOSTransSuccess := true;

        if REC."Sales Type" = '' then
            SuspendTransWithNoSalesType(SendPOSTransSuccess)
        else
            SuspendTransWithSalesType(SalesType, SendPOSTransSuccess);
        if PosFuncProfile."TS Susp./Retrieve" then
            if SendPOSTransSuccess then begin
                if SuspendedPOSTransaction.Get(POSTransaction."Receipt No.") then
                    SuspendedPOSTransaction.Delete(true);
            end;
        Commit;

        InsertTmpTransaction(false);
        POSTransactionEvents.OnAfterSuspendInsertNewTransaction(REC);
        ClearGlobs;

        POSSESSION.UpdatePosPicture(EmptyTransLine);
    end;

    procedure SuspendTransWithNoSalesType(var SendPOSTransSuccess: Boolean)
    var
        tmpPosItemTransLines: Record "LSC POS Trans. Line" temporary;
        //PrintUtil: Codeunit "LSC POS Print Utility";
        SlipNo: Code[20];
        TmpPosTrans: Record "LSC POS Transaction";
        PaymentSlip: Code[20];
        GrossAmount: Decimal;
        IsHandled: Boolean;
    begin
        // PosFunc.Suspend(SlipNo, REC, PaymentSlip, tmpPosItemTransLines, LastSlipNo, SendPOSTransSuccess);

        // if SlipNo = '' then
        //     SlipNo := REC."Receipt No.";
        // TmpPosTrans.Get(SlipNo);
        // if POSSESSION.PrinterActive then begin
        //     POSTransactionEvents.OnBeforePrintSuspendSlip(REC, GrossAmount, IsHandled);
        //     if not IsHandled then
        //         GrossAmount := REC."Gross Amount";
        //     PrintUtil.Init();
        //     if not PrintUtil.PrintSuspendSlip(TmpPosTrans, GrossAmount, tmpPosItemTransLines) then
        //         PosTransactionGui.PosMessage(PrintUtil.GetLastError);
        // end;
    end;

    procedure SuspendTransWithSalesType(SalesType: Record "LSC Sales Type"; var SendPOSTransSuccess: Boolean)
    var
        PrepaymentLines: Record "LSC POS Trans. Line";
        tmpPosItemTransLines: Record "LSC POS Trans. Line" temporary;
        POSTransPostingState: Record "LSC POS Trans. Posting State";
        TmpPosTrans: Record "LSC POS Transaction";
        TransHeader: Record "LSC Transaction Header";
        // PrintUtil: Codeunit "LSC POS Print Utility";
        //PosOrderConn: Codeunit "LSC POS Order Connection";
        PaymentSlip: Code[20];
        SlipNo: Code[20];
        RECOriginReceiptNo: Code[20];
        RECOriginSalesType: Code[20];
        TSSend, IsHandled : Boolean;
        RECOriginGrossAmount: Decimal;
        RECOriginDate: Date;
        RECOriginTime: Time;
    begin
        // POSTransactionEvents.OnBeforeSuspendPrinting(SalesType, REC, IsHandled);
        // if not IsHandled then
        //     if SalesType."Suspend Printing" = SalesType."Suspend Printing"::"POS Report ID" then
        //         if SalesType."Report ID" <> 0 then begin
        //             ScreenDisplay(PrintingMsg);
        //             REPORT.RunModal(SalesType."Report ID", false, false, REC);
        //             ScreenDisplay('');
        //         end;

        // case SalesType."Suspend Type" of
        //     0:
        //         begin  //Pos Transaction
        //             RECOriginReceiptNo := REC."Receipt No.";
        //             REC.CalcFields("Gross Amount");
        //             RECOriginGrossAmount := REC."Gross Amount";
        //             RECOriginSalesType := REC."Sales Type";
        //             RECOriginDate := REC."Trans. Date";
        //             RECOriginTime := REC."Trans Time";

        //             tmpPosItemTransLines.DeleteAll;
        //             PosFunc.Suspend(SlipNo, REC, PaymentSlip, tmpPosItemTransLines, LastSlipNo, SendPOSTransSuccess);

        //             if not SalesType."Print Item Lines on POS Slip" then begin
        //                 tmpPosItemTransLines.SetRange("Entry Type", tmpPosItemTransLines."Entry Type"::Item);
        //                 tmpPosItemTransLines.DeleteAll;
        //                 tmpPosItemTransLines.SetRange("Entry Type");
        //             end;
        //             TSSend := false;
        //             if PaymentSlip <> '' then begin
        //                 if REC."Receipt No." <> PaymentSlip then begin
        //                     REC.Get(PaymentSlip);
        //                 end;
        //                 AfterGetRecord();
        //                 CalcTotals();
        //                 POSSESSION.SetTransPostingSource(POSTransPostingState."Posting Source"::"Suspended Prepayment");
        //                 PostTransaction(true);
        //                 PrepaymentLines.SetRange("Receipt No.", SlipNo);
        //                 PrepaymentLines.SetFilter("Parent Transaction Doc. No.", PaymentSlip);
        //                 if PrepaymentLines.FindFirst then
        //                     TSSend := true;
        //             end;
        //             if TSSend then begin
        //                 TransHeader.Get(REC."Store No.", REC."POS Terminal No.", TransNo);
        //                 TransHeader."Refund Receipt No." := TransHeader."Receipt No.";
        //                 TransHeader.Modify(true);
        //             end;
        //             TmpPosTrans.Get(SlipNo);
        //             TmpPosTrans.CalcFields("Gross Amount", "Income/Exp. Amount");
        //             if (TmpPosTrans."Gross Amount" = 0) and (TmpPosTrans."Receipt No." <> RECOriginReceiptNo) then begin
        //                 TmpPosTrans."Gross Amount" := RECOriginGrossAmount;
        //                 TmpPosTrans."Sales Type" := RECOriginSalesType;
        //                 TmpPosTrans."Trans. Date" := RECOriginDate;
        //                 TmpPosTrans."Trans Time" := RECOriginTime;
        //                 TmpPosTrans.Modify();
        //             end;

        //             if SalesType."Suspend Printing" = SalesType."Suspend Printing"::Default then
        //                 if POSSESSION.PrinterActive then begin
        //                     PrintUtil.Init();
        //                     PrintUtil.PrintSuspendSlip(TmpPosTrans, TmpPosTrans."Gross Amount", tmpPosItemTransLines);
        //                 end;
        //         end;
        //     1:
        //         begin  //Sales Order
        //             PosOrderConn.UpdateSHSL(REC."Receipt No.", "Sales Document Type"::Quote); // 0
        //             REC.Get(REC."Receipt No.");
        //             AfterGetRecord();
        //             POSTransactionEvents.SuspendTransWithSalesTypeOnBeforeDeleteRecord(REC, SalesType, SendPOSTransSuccess);
        //             REC.Delete(true);
        //         end;
        //     2:
        //         begin  //Sales Quote
        //             PosOrderConn.UpdateSHSL(REC."Receipt No.", "Sales Document Type"::"Order"); // 1
        //             REC.Get(REC."Receipt No.");
        //             AfterGetRecord();
        //             POSTransactionEvents.SuspendTransWithSalesTypeOnBeforeDeleteRecord(REC, SalesType, SendPOSTransSuccess);
        //             REC.Delete(true);
        //         end;
        // end;
    end;

    procedure RetSuspendedPressed(SaleType: Code[20])
    begin
        if not POSSESSION.Permission("LSC POS Command"::SUSPEND, InfoTextDescription) then begin
            PosTransactionGui.ErrorBeep(InfoTextDescription);
            exit;
        end;

        Remaining := 0;
        RemainingFCY := 0;
        CouponCode := '';
        CouponCodeNextItem := '';
        LastCurrencyCode := '';

        if not TestNewTransaction then
            exit;
        POSSESSION.SetValue("LSC POS Tag"::"SALESTYPEFILTER", SaleType);
        if CurrInput <> '' then
            RetSuspendedPressedEx(CurrInput)
        else
            LookUp(false, 'SUSPEND', SaleType);
    end;

    procedure RetSuspendedPressedEx(pReceiptNo: Text)
    var
        Transaction: Record "LSC Transaction Header";
        OldPosTransaction: Record "LSC POS Transaction";
        ReceiptTerminal: Record "LSC POS Terminal";
        SuspTransLine: Record "LSC POS Trans. Line";
        //PosPrice: Codeunit "LSC POS Price Utility";
        ErrorText: Text;
        Error: Text;
        TransNo_l: Code[20];
        ResponseCode: Code[30];
        TermID: Integer;
    begin
        CurrInput := pReceiptNo;
        if CurrInput <> '' then begin
            POSTransactionEvents.OnBeforeRetSuspended(REC, LineRec, CurrInput);

            TransNo_l := CurrInput;
            SalePressed(true);
            CurrInput := '';

            if (CopyStr(TransNo_l, 1, 1) = 'P') and (StrLen(TransNo_l) = 14) then begin
                Evaluate(TermID, CopyStr(TransNo_l, 2, 4));
                ReceiptTerminal.SetCurrentKey("Receipt Barcode ID");
                ReceiptTerminal.SetRange("Receipt Barcode ID", TermID);
                ReceiptTerminal.FindFirst();
                TransNo_l := PosFunc.ZeroPad(ReceiptTerminal."No.", 10) + CopyStr(TransNo_l, 6);
            end else
                if (CopyStr(TransNo_l, 1, 1) = 'P') and (StrLen(TransNo_l) = 20) then
                    TransNo_l := CopyStr(TransNo_l, 2);

            ClearGlobs;
            OldPosTransaction := REC;
            if PosFunc.RetrieveSusp(TransNo_l, REC, Error) then begin
                OldPosTransaction.Reset;
                OldPosTransaction.SetRange("New Transaction", true);
                OldPosTransaction.SetRange("Transaction Type", OldPosTransaction."Transaction Type"::Logoff);
                OldPosTransaction.SetRange("Store No.", REC."Store No.");
                OldPosTransaction.SetRange("POS Terminal No.", REC."POS Terminal No.");
                if OldPosTransaction.FindFirst then
                    OldPosTransaction.Delete(true);

                StateTxt := Format(REC."Transaction Type");

                if (REC."Transaction Type" = REC."Transaction Type"::Sales) and REC."Sale Is Return Sale" then
                    StateTxt := __StateREFUND;
                POSGUI.SetSelectedMenu(POSSESSION.GetSalesMenu);
                InfoTextDescription := TransRetrievedMsg;
                REC.Get(REC."Receipt No.");
                AfterGetRecord();
                REC."Suspend Sales Type" := REC."Sales Type";
                REC."Retrieved From Suspended Trans" := true;
                if (REC."Sales Type" = '') and (REC."Sales Type" <> GLobalSalesType) then begin
                    REC."Sales Type" := GLobalSalesType;
                end;
                REC.Modify;

                PosFunc.PosTransDiscLoad(REC."Receipt No.");

                if REC."Retrieved from Receipt No." <> '' then begin
                    if PosFuncProfile."TS Void Transactions" or PosFuncProfile."DD Void Transactions" then begin
                        if TSUtil.Initialize then
                            TSUtil.GetPostedTransaction(REC."Retrieved from Receipt No.", '', '', 0, ResponseCode, ErrorText);
                    end;
                    if Transaction.Get(REC."Retrieved from Store No.",
                                                  REC."Retrieved from POS Term. No.",
                                                  REC."Retrieved from Trans. No.") then begin
                        Transaction."Refund Receipt No." := REC."Receipt No.";
                        Transaction.Modify(true);

                        if PosFuncProfile."TS Void Transactions" or PosFuncProfile."DD Void Transactions" then
                            if not (TSUtil.SendTransaction(Transaction, true)) then;
                    end;
                end;
                //  Member.LoadMemberInfo(REC."Member Card No.");
                POSTransactionEvents.OnAfterRetSuspended(REC, LineRec, CurrInput);

                SuspTransLine.SetRange("Receipt No.", REC."Receipt No.");
                if SuspTransLine.FindLast then begin
                    POSLINES.SetCurrentLine(SuspTransLine);
                    POSSESSION.UpdatePosPicture(SuspTransLine);
                end;
            end else
                if Error <> '' then
                    PosTransactionGui.ErrorBeep(Error)
                else
                    PosTransactionGui.ErrorBeep(ReceiptNotFoundErr);
        end;
        // if SuspTransLine."Entry Type" = SuspTransLine."Entry Type"::Item then
        //     PosPrice.CalcPrice(SuspTransLine, false);
        CalcTotals;
        TSCheckError;
    end;

    internal procedure GetOrderPressed(SalesType: Code[20])
    var
        SalesTypes: Record "LSC Sales Type";
        //PosOrderConn: Codeunit "LSC POS Order Connection";
        OrderNo: Code[20];
    //  DocType: Enum "Sales Document Type";
    //              OrderRetrievedMsg: Label 'Order %1 retrieved';
    begin
        // Note - This function is not supported for offline POS, only when running the POS online
        if not TestNewTransaction then
            exit;

        /* CouponCode := '';
        CouponCodeNextItem := '';
        Remaining := 0;
        RemainingFCY := 0;
        LastCurrencyCode := '';

        if CurrInput = '' then
            LookUp(false, 'GETORDER', SalesType);
        if CurrInput <> '' then begin
            OrderNo := CurrInput;
            CurrInput := '';
            ClearGlobs;
            DocType := DocType::"Order"; // 1;

            if SalesTypes.Get(SalesType) then
                DocType := "Sales Document Type".FromInteger(SalesTypes."Suspend Type" - 1);

            POSTransactionEvents.OnBeforeGetOrder(Rec, DocType, OrderNo);
            PosOrderConn.GetSHSL(REC."Receipt No.", OrderNo, DocType);
            StateTxt := Format(REC."Transaction Type");

            if (REC."Transaction Type" = REC."Transaction Type"::Sales) and REC."Sale Is Return Sale" then
                StateTxt := __StateREFUND;

            if REC."Transaction Type" = REC."Transaction Type"::Logoff then
                StateTxt := '';

            POSGUI.SetSelectedMenu(POSSESSION.GetSalesMenu);
            REC.Get(REC."Receipt No.");
            AfterGetRecord();
            InfoTextDescription := StrSubstNo(OrderRetrievedMsg, REC."Document No.");
            POSTransactionEvents.OnGetOrderPressedAfterInfoTextDescription(CurrInput, REC, DocType, OrderNo);
        end;
        TSCheckError; */
    end;

    procedure ItemNoPressed()
    var
        PluTableSpecificInfocode: Record "LSC Table Specific Infocode";
        PluInfocode: Record "LSC Infocode";
        GTINBarcode: Code[20];
        Handled: Boolean;
    begin
        //POSTransactionEventsPub.OnItemNoPressed(REC, CurrInput, Handled);
        if Handled then
            exit;

        if SaleIsReturnSale then begin
            if GS1DatabarBarcodeMgmt.IsComplexBarcode(CurrInput) then
                GTINBarcode := GS1DatabarBarcodeMgmt.GetGTINFromDatabar(CurrInput)
            else
                GTINBarcode := CurrInput;

            PluTableSpecificInfocode.SetRange(Value, GTINBarcode);
            PluTableSpecificInfocode.SetRange("Table ID", Database::Item);
            if PluTableSpecificInfocode.FindFirst then
                if PluInfocode.Get(PluTableSpecificInfocode."Infocode Code") then
                    if PluInfocode.Type = PluInfocode.Type::"Create Data Entry" then begin
                        PosTransactionGui.ErrorBeep(RefundGiftCardSale);
                        exit;
                    end;
        end;
        if STATE <> "LSC POS Transaction State"::TENDOP then begin
            LinkedItemsActive := false;
            BomLineEntry := false;
            ItemLine(true, false, 0, 0, '', '', '', '', 0, 0);
        end else
            PosTransactionGui.ErrorBeep(ItemLinesNotAllowedInStateErr);
    end;

    procedure PluKeyPressed(PluNo: Text)
    var
        PluTableSpecificInfocode: Record "LSC Table Specific Infocode";
        PluInfocode: Record "LSC Infocode";
        // ItemVariantsFunctions: Codeunit "LSC Item Variants Functions";
        //  BOUtils: Codeunit "LSC BO Utils";
        VariantDimension: array[6] of Text;
        VariantCode: Code[100];
        ItemNo: Code[100];
        FixedQty: Decimal;
        i: Integer;
        hasVariant: Boolean;
    begin
        if SaleIsReturnSale then begin
            PluTableSpecificInfocode.SetRange(Value, PluNo);
            PluTableSpecificInfocode.SetRange("Table ID", Database::Item);
            if PluTableSpecificInfocode.FindFirst then
                if PluInfocode.Get(PluTableSpecificInfocode."Infocode Code") then
                    if PluInfocode.Type = PluInfocode.Type::"Create Data Entry" then begin
                        PosTransactionGui.ErrorBeep(RefundGiftCardSale);
                        exit;
                    end;
        end;

        if POSTransactionFunctions.SalePressedInPaymentState(STATE) then
            exit;

        SelectedLineNoBeforePLUKEYPressed := POSLINES.GetCurrentLineNo;
        VariantCode := '';
        hasVariant := false;

        // if StrPos(PluNo, '|') > 0 then begin
        //     hasVariant := true;
        //     ItemNo := BOUtils.Token(PluNo, '|');
        //     for i := 1 to 6 do begin
        //         VariantDimension[i] := BOUtils.Token(PluNo, ',');
        //     end;
        //     //VariantCode := ItemVariantsFunctions.ReturnVariant(ItemNo, VariantDimension[1], VariantDimension[2], VariantDimension[3], VariantDimension[4], VariantDimension[5], VariantDimension[6]);
        // end;

        if Evaluate(FixedQty, CurrInput) then begin
            if (DealNo <> '') or hasVariant then
                FixedQty := 1;
        end;
        if STATE <> "LSC POS Transaction State"::TENDOP then begin
            CurrInput := PluNo;
            if hasVariant then begin
                CurrInput := ItemNo
            end;

            LinkedItemsActive := false;
            BomLineEntry := false;
            ItemLine(false, false, FixedQty, 0, VariantCode, '', '', '', 0, 0);
        end
        else
            PosTransactionGui.ErrorBeep(ItemLinesNotAllowedInStateErr);
    end;

    procedure MultiplyPressed(Value: Text[30])
    begin
        if Value = '' then
            CurrInput := Value;
        if Value <> '' then begin
            CurrInput := Value;
            MultiplyQty();
            exit;
        end;

        // PosTransactionGui.OpenNumericKeyboard(SetQuantityText, '', Enum::"LSC POS Trans. Numpad Trigger"::MultiplyQty);
    end;

    procedure MultiplyQty()
    var
        UOM: Record "Unit of Measure";
        MultiplyValue: Decimal;
    begin
        if CurrInput = '' then
            exit;

        if Evaluate(MultiplyValue, CurrInput) then begin
            if MultiplyValue <= 0 then begin
                PosTransactionGui.ErrorBeep(InvalidValInQtyErr);
                CurrInput := '';
                exit;
            end;
            // if STATE = "LSC POS Transaction State"::SALES then
            //     SetFunctionMode("LSC POS Command"::ITEM);
            MultiplyWith := MultiplyWith * MultiplyValue;
            POSTransactionEvents.OnMultiplyQtyAfterMultiplyWithCalc(REC, MultiplyWith, MultiplyValue);

            InfoTextDescription := StrSubstNo('%1 x', Format(MultiplyWith));
            if UOMSet <> '' then begin
                UOM.Get(UOMSet);
                if UOM.Description = '' then
                    UOM.Description := UOM.Code;
                InfoTextDescription := StrSubstNo('%1  %2', InfoTextDescription, UOM.Description);
            end;
        end else
            PosTransactionGui.ErrorBeep(InvalidValInQtyErr);
        CurrInput := '';
    end;

    procedure MultiplyMinusPressed()
    var
        UOM: Record "Unit of Measure";
        MultiplyValue: Decimal;
        NegQtyChangeOnReturnSale: Label 'Quantity cannot be negative when Sale is Return Sale.';
    begin
        if CurrInput = '' then
            CurrInput := '1';
        if Evaluate(MultiplyValue, CurrInput) then begin
            if REC."Sale Is Return Sale" then begin
                PosTransactionGui.ErrorBeep(NegQtyChangeOnReturnSale);
                exit;
            end;

            // if STATE = "LSC POS Transaction State"::SALES then
            //     SetFunctionMode("LSC POS Command"::ITEM);
            MultiplyWith := -Abs(MultiplyWith * MultiplyValue);
            InfoTextDescription := StrSubstNo('%1 x', Format(MultiplyWith));
            if UOMSet <> '' then begin
                UOM.Get(UOMSet);
                if UOM.Description = '' then
                    UOM.Description := UOM.Code;
                InfoTextDescription := StrSubstNo('%1  %2', InfoTextDescription, UOM.Description);
            end;
        end;

        CurrInput := '';
    end;

    procedure PurgePressed()
    var
        PurgingMsg: Label 'Purging...';
    begin
        if not TestNewTransaction then
            exit;
        POSTransactionEvents.OnBeforePurge(REC);

        ScreenDisplay(PurgingMsg);
        //PosFunc.Purge();
        POSTransactionEvents.OnAfterPurge();
        ScreenDisplay('');
    end;

    procedure IncExpPressed(AccNo: Code[20])
    var
        IncExpNotAllowedErr: Label 'Income/Expenses are not allowed in this state!';
        IsHandled: boolean;
    begin
        POSTransactionEvents.OnAccNoCheckOnIncExpPressed(AccNo, IsHandled);
        if IsHandled then
            exit;

        if AccNo = '' then begin
            PosTransactionGui.ErrorBeep('');
            exit;
        end;
        if STATE <> "LSC POS Transaction State"::TENDOP then begin
            IncExpAccNo := AccNo;
            if AccNo <> '' then
                IncExpLine;
        end else
            PosTransactionGui.ErrorBeep(IncExpNotAllowedErr);

        if CoLinesMarkHasChanged() then begin
            COTotalHasBeenPressed := false;
            COWasCreated := false;
        end;

    end;

    procedure CouponPressed()
    var
        ErrorText: Text[250];
        IsHandled: Boolean;
        CouponNoMsg: Label 'Coupon No.';
        CouponNotFoundErr: Label 'Coupon not found.';
        CouponNoNotFoundErr: Label 'Coupon No. %1 is not found.';
    begin
        //POSTransactionEventsPub.OnBeforeCouponPressed(Rec, IsHandled);
        if IsHandled then
            exit;
        if STATE = "LSC POS Transaction State"::TENDOP then begin
            PosTransactionGui.ErrorBeep(CouponsNotAllowedInStateErr);
            exit;
        end;

        if (CurrInput = '') and (CouponCode = '') then begin
            PosTransactionGui.OpenNumericKeyboard(CouponNoMsg, '', Enum::"LSC POS Trans. Numpad Trigger"::CouponPressed);
            exit;
        end;

        if CouponCodeNextItem = '' then begin
            if ProcessCoupon(ErrorText, CopyStr(CurrInput, 1, 22), LineRec) then begin
                if ErrorText <> '' then
                    PosTransactionGui.ErrorBeep(ErrorText);
                CurrInput := '';
                exit;
            end;
            PosTransactionGui.ErrorBeep(StrSubstNo(CouponNoNotFoundErr, CopyStr(CurrInput, 1, 22)));
            CurrInput := '';
            exit;
        end;

        TenderTypeTable.SetRange("Default Function", TenderTypeTable."Default Function"::Coupons);
        if TenderTypeTable.FindFirst then
            CouponTenderType := TenderTypeTable.Code;

        if CouponTenderType = '' then begin
            PosTransactionGui.ErrorBeep(StrSubstNo(SetupCouponsDefinedErr, TenderTypeTable.TableCaption));
            exit;
        end;
        if not TenderType.Get(REC."Store No.", CouponTenderType) then begin
            PosTransactionGui.ErrorBeep(StrSubstNo(SetupCouponsDefinedInErr, TenderType.TableCaption, StoreSetup.TableCaption));
            exit
        end;
        InitNewLine;
        if CouponCode <> '' then
            CurrInput := CouponCode;
        if not PosFunc.LoadCoupon(NewLine, CurrInput, CouponCode) then begin
            PosTransactionGui.ErrorBeep(CouponNotFoundErr);
            exit;
        end;

        if (CouponCode <> '') or (CouponCodeNextItem <> '') then begin
            PosTransactionGui.MessageBeep(ScanItemToTriggerCouponMsg);
            exit;
        end;
        // if not PosFunc.ValidateCoupon(NewLine, CouponTenderType, InfoTextDescription) then begin
        //     PosTransactionGui.ErrorBeep(InfoTextDescription);
        //     exit;
        // end;

        PaymentAmount := NewLine.Amount;
        CustomerOrCardNo := NewLine."Card/Customer/Coup.Item No";
        // if not PosFunc.ValidateTender(TenderType, REC."Gross Amount", Balance, PaymentAmount
        //               , REC."Sale Is Return Sale", false, InfoTextDescription) then begin
        //     PosFunc.DeleteCouponQtyUsed;
        //     PosTransactionGui.ErrorBeep(InfoTextDescription);
        //     exit;
        // end;
        InsertPaymentLine;
    end;

    procedure RemoveTenderPressed()
    var
        POSTransPostingState: Record "LSC POS Trans. Posting State";
    begin
        TenderDeclEndOfDay := false;
        if STATE = "LSC POS Transaction State"::TENDOP then begin
            if REC."Transaction Type" = REC."Transaction Type"::"Remove Tender" then begin
                if not StoreSetup."Safe Mgnt. in Use" then begin
                    POSSESSION.SetTransPostingSource(POSTransPostingState."Posting Source"::"Remove Tender");
                    PostPressed;
                    exit;
                end;
            end else begin
                PosTransactionGui.ErrorBeep(InvalidOperationErr + StrSubstNo(CompleteTransOrCancelMsg, REC."Transaction Type"));
                exit;
            end;
        end else begin
            if not POSSESSION.Permission("LSC POS Command"::REM_TENDER, InfoTextDescription) then begin
                PosTransactionGui.ErrorBeep(InfoTextDescription);
                exit;
            end;
            if TenderOp(REC."Transaction Type"::"Remove Tender") then
                exit;
        end;

        RemoveTenderPressedEx;
    end;

    procedure RemoveTenderPressedEx()
    begin
        if StoreSetup."Safe Mgnt. in Use" then begin
            if REC."Transaction Type" = REC."Transaction Type"::"Remove Tender" then begin
                POSTransactionEvents.OnBeforeRemoveTender(REC, LineRec);
                if CheckInfoCode('REM_TENDER') then
                    exit;
            end;
            RunTDCommand;
        end;
    end;

    procedure RunTDCommand()
    begin
        if StoreSetup."Safe Mgnt. in Use" then
            TD_CommandPressed(false);
    end;

    procedure TenderDeclPressed()
    var
        POSTransPostingState: Record "LSC POS Trans. Posting State";
        NoOfUnpostedTrans: Integer;
    begin
        TenderDeclEndOfDay := false;

        if STATE = "LSC POS Transaction State"::TENDOP then begin
            if REC."Transaction Type" = REC."Transaction Type"::"Tender Decl." then begin
                if not StoreSetup."Safe Mgnt. in Use" then begin
                    POSSESSION.SetTransPostingSource(POSTransPostingState."Posting Source"::"Tender Decl.");
                    PostPressed;
                    exit;
                end;
            end else begin
                PosTransactionGui.ErrorBeep(InvalidOperationErr + StrSubstNo(CompleteTransOrCancelMsg, REC."Transaction Type"));
                exit;
            end;
        end else begin
            if not POSSESSION.Permission("LSC POS Command"::TENDER_D, InfoTextDescription) then begin
                PosTransactionGui.ErrorBeep(InfoTextDescription);
                exit;
            end;
            //NoOfUnpostedTrans := PosFunc.POSSalesTransExistInStore(StoreSetup."No.");
            if NoOfUnpostedTrans > 0 then begin
                if not PosTransactionGui.PosConfirm(StrSubstNo(UnpostedTransContinueQst, NoOfUnpostedTrans), false) then
                    exit;
            end;
            if TenderOp(REC."Transaction Type"::"Tender Decl.") then
                exit;
        end;
        TenderDeclPressedEx;
    end;

    procedure TenderDeclPressedEx()
    begin
        if StoreSetup."Safe Mgnt. in Use" then begin
            if REC."Transaction Type" = REC."Transaction Type"::"Tender Decl." then begin
                POSTransactionEvents.OnBeforeTenderDecl(REC, LineRec);
                if CheckInfoCode('TENDER_D') then
                    exit;
            end;
            RunTDCommand;
        end;
    end;

    // procedure FloatPressed()
    // var
    //     POSTransPostingState: Record "LSC POS Trans. Posting State";
    // begin
    //     TenderDeclEndOfDay := false;

    //     if STATE = "LSC POS Transaction State"::TENDOP then begin
    //         if REC."Transaction Type" = REC."Transaction Type"::"Float Entry" then begin
    //             if not StoreSetup."Safe Mgnt. in Use" then begin
    //                 POSSESSION.SetTransPostingSource(POSTransPostingState."Posting Source"::Float);
    //                 PostPressed;
    //                 exit;
    //             end;
    //         end
    //         else begin
    //             PosTransactionGui.ErrorBeep(InvalidOperationErr + StrSubstNo(CompleteTransOrCancelMsg, REC."Transaction Type"));
    //             exit;
    //         end;
    //     end
    //     else begin
    //         if not POSSESSION.Permission("LSC POS Command"::FLOAT_ENT, InfoTextDescription) then begin
    //             PosTransactionGui.ErrorBeep(InfoTextDescription);
    //             exit;
    //         end;
    //         if TenderOp(REC."Transaction Type"::"Float Entry") then
    //             exit;
    //     end;
    //     FloatPressedEx;
    // end;

    // procedure FloatPressedEx()
    // begin
    //     if StoreSetup."Safe Mgnt. in Use" then begin
    //         if REC."Transaction Type" = REC."Transaction Type"::"Float Entry" then begin
    //             POSTransactionEvents.OnBeforeFloat(REC, LineRec);
    //             if CheckInfoCode('FLOAT_ENT') then
    //                 exit;
    //         end;
    //         RunTDCommand;
    //         POSTransactionEvents.OnAfterFloat(REC, LineRec);
    //     end;
    // end;

    procedure TrainingPressed()
    var
        NoChangeTrainingModeErr: Label 'Training mode cannot be changed within transaction';
    begin
        //POSTransactionEventsPub.OnBeforeTrainingPressed;
        if not REC."New Transaction" then begin
            PosTransactionGui.ErrorBeep(NoChangeTrainingModeErr);
            exit;
        end;
        if not ClientSessionUtility.IsTraningModeValid then
            exit;
        TrainingActive := not TrainingActive;

        if TrainingActive then
            REC."Entry Status" := REC."Entry Status"::Training
        else
            REC."Entry Status" := REC."Entry Status"::" ";

        RefreshTrainingStatus;
        //POSTransactionEventsPub.OnAfterTrainingPressed;
    end;

    procedure UnitOfMeasurePressed(Value: Text[30])
    var
        UOM: Record "Unit of Measure";
    begin
        CurrInput := Value;
        Clear(UOM);
        if (CurrInput <> '') and not UOM.Get(CurrInput) then begin
            PosTransactionGui.ErrorBeep(InvalidUOMErr);
            exit;
        end;
        UOMSet := CurrInput;
        Clear(InfoTextDescription);
        if UOM.Description = '' then
            UOM.Description := UOM.Code;
        if MultiplyWith <> 1 then begin
            InfoTextDescription := StrSubstNo('%1 x', Format(MultiplyWith));
            InfoTextDescription := StrSubstNo('%1  %2', InfoTextDescription, UOM.Description)
        end
        else
            InfoTextDescription := UOM.Description;
        CurrInput := '';
    end;

    procedure FormatAmount(Amount: Decimal): Text[30]
    begin
        exit(PosFunc.FormatAmount(Amount));
    end;

    procedure StartNewTransaction()
    var
        RetailCalendar: Record "LSC Retail Calendar";
        //POSSearch: Codeunit "LSC Search Index";
        // RetailCalendarManagement: Codeunit "LSC Retail Calendar Management";
        // LoadingCardManagement: Codeunit "LSC Loading Card Management";
        FiscalProcessMessageText: text;
        FiscalProcessError: Boolean;
    begin
        // SelectLatestVersion;
        // PosFunc.FiscalProcessAtNewTransaction(FiscalProcessError, FiscalProcessMessageText);
        // if FiscalProcessError THEN begin
        //     PosTransactionGui.PosMessage(FiscalProcessMessageText);
        //     IF POSSESSION.GetValue("LSC POS Tag"::"FISCALERRORSTOP") <> '' THEN
        //         Error('');
        // end;
        // POSSESSION.SetValue("LSC POS Tag"::"TS_ERROR", '');
        // POSTransactionEvents.OnBeforeStartNewTransaction(REC);
        // if PosFuncProfile."Update Search Index" then
        //     POSSearch.IndexFromActionsBackground();

        // CouponCode := '';
        // Remaining := 0;
        // RemainingFCY := 0;
        // SPGOrder := false;

        // LastCurrencyCode := '';
        // REC."New Transaction" := false;
        // REC."Trans. Date" := Today;
        // REC."Original Date" := REC."Trans. Date";
        // REC."Trans Time" := Time;
        // REC."Trans. Date" :=
        //   RetailCalendarManagement.GetStoreTransactionDate(
        //     StoreSetup."No.", RetailCalendar."Calendar Type"::"Opening Hours",
        //     REC."Trans. Date", REC."Trans Time");
        // REC."Shift No." := POSSESSION.WorkShiftNo;
        // REC.Validate("Trans. Currency Code", StoreSetup."Currency Code");
        // StateTxt := Format(REC."Transaction Type");

        // if REC."Transaction Type" = REC."Transaction Type"::Sales then
        //     if REC."Sale Is Exchange Sale" then
        //         stateTxt := ExchangeLbl
        //     else
        //         if REC."Sale Is Return Sale" then
        //             StateTxt := __StateREFUND;

        // POSTransactionEvents.OnStartNewTransactionBeforeInsertLoadCardNoInNewTrans(REC, StoreSetup);
        // if LoadingCardManagement.InsertLoadCardNoInNewTrans(REC) then
        //     REC.Modify;

        // REC.Modify;
        // Clear(LineRec);
        // WriteMgrStatus;
        // PosFunc.WriteLocalVar(LastSlipNo);
        // PosFunc.PosTransDiscLoad(REC."Receipt No.");
        // PosFunc.InitTrackingInstanceID(REC);
        // PosFunc.LoadOfferTables(false);

        // COWasCreated := false;
        // COTotalHasBeenPressed := false;
        // PrepayCustomerOrder := false;
        // CollectingOrder := false;
        // Clear(CustomerOrderHeader_Temp);
        // CustomerOrderHeader_Temp.DeleteAll();
        // POSTransactionEvents.OnAfterStartNewTransaction(REC);
        // POSSESSION.LSCComment_SetActiveReceiptNoForLSCComment(REC."Receipt No.");
    end;

    procedure InsertTmpTransaction(NewLogin: Boolean)
    var
        PosTransaction: Record "LSC POS Transaction";
        SalesType: Record "LSC Sales Type";
        NewReceiptNo: Code[20];
        ReuseTrans: Boolean;
    begin
        // POSTransactionEvents.OnBeforeInsertNewTransaction(REC, LineRec, CurrInput);
        COAmountToDeductFromTot := 0;
        ReuseTrans := false;
        PosTransaction.SetRange("New Transaction", true);
        PosTransaction.SetRange("Transaction Type", PosTransaction."Transaction Type"::Logoff);
        PosTransaction.SetRange("Store No.", POSSESSION.StoreNo);
        PosTransaction.SetRange("POS Terminal No.", POSSESSION.TerminalNo);

        if PosTransaction.FindFirst then begin
            NewReceiptNo := PosTransaction."Receipt No.";
            ReuseTrans := true;
        end;
        // HospFunc.SetCurrDiningTblAndDescr(CurrTableNo, CurrTableDescr);
        PosFunc.ReadLocalVar(LastSlipNo);
        if NewReceiptNo = '' then
            NewReceiptNo :=
              PosFunc.InsertTmpTrans(LastSlipNo, POSSESSION.WorkShiftNo, GLobalSalesType, CurrTableNo, TrainingActive, CurrTableDescr);
        REC.SetRange("Receipt No.", NewReceiptNo);

        REC.Get(NewReceiptNo);
        AfterGetRecord();

        // if ReuseTrans then
        //     PosFunc.InitReusedTrans(REC, POSSESSION.WorkShiftNo, GLobalSalesType, CurrTableNo, TrainingActive, CurrTableDescr);

        // PosFunc.InsertTransInUseOnPos(REC."Receipt No.", POSSESSION.TerminalNo, true, true);

        // if HospFunc.InsertQueueCounterInNewTrans(StoreSetup, REC) then
        //     REC.Modify;

        // POSTransactionEvents.OnAfterInsertNewTransaction(REC, LineRec, CurrInput);
        Commit;

        REC.Get(NewReceiptNo);
        AfterGetRecord();
        // Member.Init();
        REC."Member Card No." := POSSESSION.GetMemberCardNo;
        // Member.LoadMemberInfo(REC."Member Card No.");

        //HospFunc.InsertOccupiedSeat(REC."Table No.", PosFuncProfile."Print Copy No. on Pre-Receipt", REC."Receipt No.", 0);
        if not NewLogin and PosTerminal."Exit After Each Trans." then begin
            if POSSESSION.GetValue("LSC POS Tag"::"CANCELBUTTONPRESSED") = '' then begin
                POSSESSION.SetValue("LSC POS Tag"::"ENDDISPLAY", '');
                SetPOSState('');
                POSSESSION.SetStaff('');

                if Remaining <> 0 then
                    if InfoTextDescription <> '' then
                        POSSESSION.SetValue("LSC POS Tag"::"ENDDISPLAY", InfoTextDescription);

                CloseForm();
                exit;
            end;
            POSSESSION.SetValue("LSC POS Tag"::"CANCELBUTTONPRESSED", '');
        end;

        //SetFunctionMode("LSC POS Command"::ITEM);
        SetPOSState("LSC POS Transaction State"::SALES);
        StateTxt := '';
        if (Remaining = 0) and (RemainingFCY = 0) then begin
            InfoTextDescription := NewTransMsg;
            InfoTextDescription2 := '';
        end;
        SelectDefaultMenu;

        Commit;

        if REC."Sales Type" <> '' then begin
            if SalesType.Get(REC."Sales Type") then
                if SalesType."Request Description" = SalesType."Request Description"::"At Start of Transaction" then
                    POSGUI.PostCommand("LSC POS Command"::REQ_DESCR_TRANSSTART, '');
        end;

        LinePriceGroup := REC."Price Group Code";
        if SalesTypeFilter then begin
            LineSalesType := GLobalSalesType;
            if SalesTypeRec.Get(GLobalSalesType) then
                LinePriceGroup := SalesTypeRec."Price Group";
        end
        else begin
            if REC."Original Sales Type" <> '' then
                LineSalesType := REC."Original Sales Type"   // price group same as header, trans. is pre-order
            else
                LineSalesType := REC."Sales Type";
        end;

        DealNo := '';
        DealAddedPrice := 0;

        COWasCreated := false;
        COTotalHasBeenPressed := false;
    end;

    internal procedure SetMemberInfoWhenPOSNotRunning(MemberCardNo: Text[100])
    var
        ErrorText: Text;
    begin
        // REC."Member Card No." := MemberCardNo;
        // if MemberCardNo = '' then begin
        //     Member.Init();
        //     exit;
        // end;
        // if not Member.LoadMemberInfo(MemberCardNo, ErrorText, true) then begin
        //     Member.Init();
        //     REC."Member Card No." := '';
        // end;
    end;

    procedure SetTransactionIsCancelCO()
    begin
        TransactionIsCancelCO := true;
    end;

    procedure ClearGlobs()
    begin
        Clear(TenderType);
        Clear(Customer);
        Clear(Item);
        Clear(Balance);
        Clear(LineRec);
        Clear(Currency);
        Clear(PaymentAmount);
        Clear(BarcodeMask);
        Clear(PaymentCount);
        POSSESSION.ClearManagerID;
        LastItemNo := '';
        MultiplyWith := 1;
        UOMSet := '';
        CurrGuest := 0;
        CurrMenuType := 0;
        GrossAmountBeforeCreatingCO := 0;
        PreSetSerialLotNo := false;
        ExternalZeroPrice := false;
        InvoiceNo := '';
        PosDataEntryTypeCode := '';
        PosDataEntryBalanceOnly := false;
        Clear(TmpSelQty);
        TmpSelQty.DeleteAll;
        PosFunc.ClearmemberInfo;
        // PosFunc.ClearTransBenefitBuffer;
        // POSLINES.ClearCurrentLine;
        // PosFunc.ClearQRCode;
        // PosFunc.SetOriginalRefundTransactionNo(0);
        MultipleRecordsForReceipt := false;
        CompressDealVariants := false;
        PosFunc.ClearOfferBuffer;
        FromMobileQR := false;
        Clear(SelectedLineNoBeforePLUKEYPressed);
        ItemStockRestrictionOn := false;
        COTotalAmount := 0;
        LinkedItemsNewLineTemp.Reset();
        LinkedItemsNewLineTemp.DeleteAll();
        //#pragma warning disable AL0432
        //         if POSCtrl.PosIsActive then
        //             POSCtrl.SetStackedLookup(false);
        // #pragma warning restore AL0432
        //         POSSESSION.SetValue("LSC POS Tag"::"COPY_TR_SKYP_RETRVDFROMRCPTCPN", '');
        //         POSSESSION.SetValue("LSC POS Tag"::"COPY_TR_SKYP_RETRVDFROMRCPT", '');
        //         ClearAndDeleteAllCOTempVariables();
        //         Clear(CustomerOrderLineCompare_Temp);
        //         CustomerOrderLineCompare_Temp.DeleteAll();
        //         TransactionIsCancelCO := false;
        //         CustomerOrderSession.ClearCustomerOrderEdit();
        //         CustomerOrderSession.ClearSavedDataBuffer();
        //         POSTransactionEventsPub.OnAfterClearGlobs();
    end;

    procedure InsertLogonLogoffTrans(LogAction: Option Logoff,Logon)
    var
        tmpPOSTrans: Record "LSC POS Transaction";
        tmpTrans: Record "LSC Transaction Header";
        RetailCalendar: Record "LSC Retail Calendar";
    //POSPost: Codeunit "LSC POS Post Utility";
    //  RetailCalendarManagement: Codeunit "LSC Retail Calendar Management";
    begin
        // PosFuncProfile.Get(POSSESSION.FunctionalityProfileID);
        // if PosFuncProfile.RegisterLogonLogoff then begin
        //     tmpPOSTrans."Transaction Type" := LogAction;
        //     tmpPOSTrans."Staff ID" := POSSESSION.StaffID;
        //     tmpPOSTrans."Store No." := POSSESSION.StoreNo;
        //     tmpPOSTrans."POS Terminal No." := POSSESSION.TerminalNo;
        //     tmpPOSTrans."Created on POS Terminal" := POSSESSION.TerminalNo;
        //     tmpPOSTrans."Trans. Date" := Today;
        //     tmpPOSTrans."Original Date" := tmpPOSTrans."Trans. Date";
        //     tmpPOSTrans."Trans Time" := Time;
        //     tmpPOSTrans."Trans. Date" :=
        //       RetailCalendarManagement.GetStoreTransactionDate(
        //         StoreSetup."No.", RetailCalendar."Calendar Type"::"Opening Hours",
        //         tmpPOSTrans."Trans. Date", tmpPOSTrans."Trans Time");
        //     tmpPOSTrans."Shift No." := POSSESSION.WorkShiftNo;
        //     if tmpPOSTrans.Insert then;
        //     // POSPost.ProcessTransaction(tmpPOSTrans);
        //     // POSPost.GetLastTransaction(tmpTrans);

        //     if PosFuncProfile."TS Send Transactions" or PosFuncProfile."DD Send Transaction" then
        //         if not (TSUtil.SendTransaction(tmpTrans, false)) then;
        // end;
    end;

    procedure InitNewLine()
    var
        MenuTypeRec: Record "LSC Restaurant Menu Type";
    begin
        Clear(NewLine);
        NewLine."Store No." := REC."Store No.";
        NewLine."POS Terminal No." := REC."POS Terminal No.";
        NewLine."Receipt No." := REC."Receipt No.";
        NewLine."Guest/Seat No." := CurrGuest;
        // if LocalizationExt.IsNALocalizationEnabled then
        //     POSTransScale.SetTareDone(false);
        NewLine."Restaurant Menu Type" := CurrMenuType;
        if (DealNo <> '') and (not LinkedItemsActive) then
            if (CurrMenuType = 0) and (CurrMenuTypeDeal <> 0) then
                NewLine."Restaurant Menu Type" := CurrMenuTypeDeal;
        if NewLine."Restaurant Menu Type" <> 0 then begin
            if MenuTypeRec.Get(REC."Store No.", NewLine."Restaurant Menu Type") then
                NewLine."Restaurant Menu Type Code" := MenuTypeRec."Code on POS";
        end;
        // POSTransactionEventsPub.OnAfterInitNewLine(REC, NewLine, CurrInput);
    end;

    procedure TestNewTransaction(): Boolean
    begin
        if not REC."New Transaction" then
            PosTransactionGui.ErrorBeep(CurrTransMustBeFinishedErr);
        exit(REC."New Transaction");
    end;

    procedure OkNewInput(): Boolean
    var
        PosCommandRec: Record "LSC POS Command";
        PosCommand: Enum "LSC POS Command";
        IsHandled: Boolean;
    begin
        POSCommand := POSCommandRec.CommandToEnum(FunctionSetup."Function Code");

        case PosCommand of
            PosCommand::ADDSALESP,
            PosCommand::ADDSALESP_L,
            PosCommand::CONTACT,
            PosCommand::CARD,
            PosCommand::CARDEXTRA,
            PosCommand::CARDTYPE,
            PosCommand::CHECK,
            PosCommand::CONTROL,
            PosCommand::CUSTOMER,
            PosCommand::ERRCHK,
            PosCommand::EXDATE,
            PosCommand::INFOCODE,
            PosCommand::PASSWORD,
            PosCommand::PRICE,
            PosCommand::QUANTITY,
            PosCommand::SALESP,
            PosCommand::"VARIANT",
            PosCommand::WEIGHT,
            PosCommand::SERIALNO,
            PosCommand::LOTNO,
            PosCommand::INVOICENO,
            PosCommand::DAENTRCODE,
            PosCommand::GETINFO:
                exit(false);
        end;

        POSTransactionEvents.OnOkNewInput(FunctionSetup, IsHandled);
        if IsHandled then
            exit(false);
        exit(true);
    end;

    procedure ProcessBarcode(): Boolean
    var
        Segment: Record "LSC Barcode Mask Segment";
        BcUtil: Codeunit "LSC Barcode Management";
        LoadingCardManagement: Codeunit "LSC Loading Card Management";
        ErrorText: Text;
        DummyCode: Code[20];
        ItemNo: Code[22];
        LoadCardCalledFrom: Option POSTransaction,HospitalityPOSStartup;
        LoadCardInputType: Option Manual,"MSR Card",Barcode,RFID;
        LoadCardEventType: Option Unknown,CreateTrans,LoadTrans,Combine,Uncombine;
        BMFound: Boolean;
        BCFound: Boolean;
        Match: Boolean;
        DummyBool: Boolean;
        Proceed: Boolean;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        POSTransactionEvents.OnBeforeProcessBarcode(REC, LineRec, CurrInput, IsHandled);
        if IsHandled then
            exit(true);

        Clear(ScannedDatabar);
        if GS1DatabarBarcodeMgmt.IsComplexBarcode(CurrInput) then begin
            ScannedDatabar := CurrInput;
            CurrInput := GS1DatabarBarcodeMgmt.GetGTINFromDatabar(ScannedDatabar);
        end;

        BMFound := BcUtil.FindBarcodeMask(CopyStr(CurrInput, 1, 22), BarcodeMask);
        if BMFound then begin
            Proceed := true;
            POSTransactionEvents.OnProcessBarcode(REC, BarcodeMask, CurrInput, Proceed);
            if not Proceed then
                exit(true);
        end;
        BCFound := Barcode.Get(CopyStr(CurrInput, 1, 20));
        POSTransactionEvents.OnAfterProcessBarcode(REC, LineRec, CurrInput);

        IsHandled := false;
        //POSTransactionEventsPub.OnBeforeValidateInputEx(BarcodeMask, FunctionSetup, OkNewInput, IsHandled);
        if IsHandled then
            exit(true);

        if not OkNewInput then begin
            case FunctionSetup."Function Code" of
                Format("LSC POS Command"::CHECK):
                    if BCFound or (not BMFound) or (BMFound and (BarcodeMask.Type = BarcodeMask.Type::Item)) then begin
                        ValidateInput;
                        exit(true);
                    end;
                Format("LSC POS Command"::CUSTOMER):
                    if (not BMFound) or (BMFound and (BarcodeMask.Type = BarcodeMask.Type::Customer)) then begin
                        // if BMFound then
                        //     CurrInput := PosFunc.GetBarcCustomer(CopyStr(CurrInput, 1, 22), BarcodeMask);
                        ValidateInput;
                        exit(true);
                    end;
                Format("LSC POS Command"::INFOCODE):
                    begin
                        if (not BMFound) or (Info.Type = Info.Type::"Text Input") then begin
                            ValidateInput;
                            CheckItemPointOfferPopUp();
                            exit(true);
                        end;
                        Match := false;
                        case BarcodeMask.Type of
                            BarcodeMask.Type::" ":
                                Match := (Info.Type = Info.Type::"Item Input") or
                                         (Info.Type = Info.Type::" ");
                            BarcodeMask.Type::"Data Entry":
                                begin
                                    CurrInput := PosFunc.GetBarcDataEntryCode(CopyStr(CurrInput, 1, 22), BarcodeMask);
                                    Match := true;
                                end;
                            BarcodeMask.Type::Customer:
                                begin
                                    // CurrInput := PosFunc.GetBarcCustomer(CopyStr(CurrInput, 1, 22), BarcodeMask);
                                    // Match := (Info.Type = Info.Type::"Customer Input");
                                end;
                            BarcodeMask.Type::Employee:
                                begin
                                    CurrInput := PosFunc.GetBarcStaff(CopyStr(CurrInput, 1, 22), BarcodeMask);
                                    Match := (Info.Type = Info.Type::"Staff Input");
                                end;
                            BarcodeMask.Type::Item:
                                begin
                                    PosFunc.GetBarcItemInfo(CopyStr(CurrInput, 1, 22), BarcodeMask, ItemNo, DummyBool, DummyBool, DummyCode);
                                    if ItemNo <> '' then
                                        CurrInput := ItemNo;
                                    Match := (Info.Type = Info.Type::"Item Input");
                                end;
                        end;
                        if Match then begin
                            ValidateInput;
                            CheckItemPointOfferPopUp();
                            exit(true);
                        end;
                    end;
            end;
            exit(false);
        end;
        if (StrLen(CurrInput) in [14, 20]) and (CopyStr(CurrInput, 1, 1) in ['T', 'P', 'S']) then begin
            ProcessReceiptBarcode;
            exit(true);
        end;

        IsHandled := false;
        // POSTransactionEventsPub.OnBeforeItemNoPressedInProcessBarCode(BarcodeMask, IsHandled);
        if IsHandled then
            exit(true);

        if IsProcessReceiptBarcode(false) then
            exit(true);

        if BCFound or (not BMFound) or (BMFound and (BarcodeMask.Type = BarcodeMask.Type::Item)) then begin
            ItemNoPressed;
            exit(true);
        end;
        if BMFound and (BarcodeMask.Type = BarcodeMask.Type::Coupon) then begin
            CouponPressed;
            exit(true);
        end;
        if BMFound and (BarcodeMask.Type = BarcodeMask.Type::"Member Card") then begin
            InputMemberCard(CurrInput);
            exit(true);
        end;
        if BMFound and (BarcodeMask.Type = BarcodeMask.Type::Customer) then begin
            // CurrInput := PosFunc.GetBarcCustomer(CopyStr(CurrInput, 1, 22), BarcodeMask);
            // CustomerPressed();
            // exit(true);
        end;
        if BMFound and (BarcodeMask.Type = BarcodeMask.Type::Employee) then begin
            CurrInput := PosFunc.GetBarcStaff(CopyStr(CurrInput, 1, 22), BarcodeMask);
            ChangeStaff(CurrInput);
            CurrInput := '';
            exit(true);
        end;
        if BMFound and (BarcodeMask.Type = BarcodeMask.Type::"Customer Order") then begin
            Segment.SetRange("Mask Entry No.", BarcodeMask."Entry No.");
            Segment.SetRange(Type, Segment.Type::"Any No.");
            if Segment.FindFirst() then begin
                CurrInput := CopyStr(CurrInput, StrLen(BarcodeMask.Prefix) + 1, Segment.Length);
                POSTransactionEvents.COScanned(CurrInput);
            end;
            exit(true);
        end;

        if BMFound and (BarcodeMask.Type = BarcodeMask.Type::"Data Entry") then begin
            CurrInput := PosFunc.GetBarcDataEntryCode(CopyStr(CurrInput, 1, 22), BarcodeMask);
            ValidateInfocode(0, false, false);
            exit(true);
        end;
        if BMFound and (BarcodeMask.Type = BarcodeMask.Type::"Loading Card") then begin
            if not LoadingCardManagement.ProcessLoadingCardEvent(
              CurrInput, REC."Receipt No.", LoadCardCalledFrom::POSTransaction,
              LoadCardInputType::Barcode, LoadCardEventType::Unknown, ErrorText)
            then
                PosTransactionGui.ErrorBeep(ErrorText);
            ClearInput;
            exit(true);
        end;
        exit(false);
    end;

    internal procedure CheckItemPointOfferPopUp()
    var
        POSSession: Codeunit "LSC POS Session";
    begin
        if POSSession.GetValue("LSC POS Tag"::"ITEM_POINT_OFFER") = '1' then begin
            PosCtrl.PostCommand("LSC POS Command"::ITEM_POINT_OFFER, '');
            POSSession.SetValue("LSC POS Tag"::"ITEM_POINT_OFFER", '0');
        end;
    end;

    procedure InputMSRCards()
    begin
        if CurrInput = '' then begin
            PosTransactionGui.OpenNumericKeyboard(CardNoMsg, '', Enum::"LSC POS Trans. Numpad Trigger"::InputMSRCards);
            exit;
        end;

        CheckMSRcards();
        CurrInput := '';
    end;

    procedure CheckMSRcards(): Boolean
    var
        msrCards: Record "LSC MSR Card Link Setup";
        Contacts: Record Contact;
        CustRel: Record "Contact Business Relation";
        TmpTender: Record "LSC Tender Type";
        TmpStaff: Record "LSC Staff";
        LoadingCardManagement: Codeunit "LSC Loading Card Management";
        ReturnTxt: Text[100];
        ErrorText: Text;
        LoadCardCalledFrom: Option POSTransaction,HospitalityPOSStartup;
        LoadCardInputType: Option Manual,"MSR Card",Barcode,RFID;
        LoadCardEventType: Option Unknown,CreateTrans,LoadTrans,Combine,Uncombine;
        StaffIdNotFoundErr: Label 'Staff ID not found';
    begin
        Clear(msrCards);
        if not msrCards.Get(CopyStr(CurrInput, 1, 100)) then
            exit(false);

        case msrCards."Link Type" of
            msrCards."Link Type"::Cashier:
                begin
                    if not TmpStaff.Get(msrCards."Link No.") then begin
                        PosTransactionGui.ErrorBeep(StaffIdNotFoundErr);
                        exit(false);
                    end;

                    if not POSSESSION.Login(PosFuncProfile."Card Logon at Sale" <> 0, TmpStaff.ID, TmpStaff.Password, '', ReturnTxt) then begin
                        PosTransactionGui.ErrorBeep(ReturnTxt);
                        exit(false);
                    end;

                    if PosFuncProfile."Card Logon at Sale" = 0 then begin
                        POSSESSION.SetStaffID(TmpStaff, '');
                        SetStaffID(TmpStaff.ID);
                    end
                    else
                        if not POSSESSION.SetManagerID(TmpStaff, ReturnTxt) then begin
                            PosTransactionGui.MessageBeep(ReturnTxt);
                            exit(false);
                        end;

                    POSGUI.SetRefreshMenuFlag(0);
                    POSGUI.SetRefreshMenuFlag(1);
                    POSGUI.SetRefreshMenuFlag(2);
                    POSGUI.SetRefreshMenuFlag(3);
                end;
            msrCards."Link Type"::Customer:
                begin
                    CurrInput := msrCards."Link No.";
                    TmpTender.SetRange("Store No.", PosTerminal."Store No.");
                    TmpTender.SetRange(TmpTender."Function", TmpTender."Function"::Customer);
                    if TmpTender.FindFirst then
                        if TenderType.Get(TmpTender."Store No.", TmpTender.Code) then begin
                            // SetFunctionMode("LSC POS Command"::CUSTOMER);
                            // OnlySelectCustomer := true;
                        end;
                    ValidateCustomer();
                    OnlySelectCustomer := false;
                end;
            msrCards."Link Type"::Contact:
                begin
                    if msrCards."Link No." <> '' then begin
                        if msrCards."Link No." = Contacts."No." then
                            Contacts.Get(Contacts."No.")
                        else begin
                            if not Contacts.Get(msrCards."Link No.") then
                                Clear(Contacts);
                        end;
                        if msrCards."Link No." = Contacts."No." then begin
                            InfoTextDescription2 := Contacts.Name;
                            CustRel.SetRange(CustRel."Contact No.", Contacts."No.");
                            CustRel.SetRange(CustRel."Link to Table", CustRel."Link to Table"::Customer);
                            if CustRel.FindFirst then begin
                                CurrInput := CustRel."No.";
                                TmpTender.SetRange("Store No.", PosTerminal."Store No.");
                                TmpTender.SetRange(TmpTender."Function", TmpTender."Function"::Customer);
                                if TmpTender.FindFirst then
                                    if TenderType.Get(TmpTender."Store No.", TmpTender.Code) then begin
                                        // SetFunctionMode("LSC POS Command"::CUSTOMER);
                                        // OnlySelectCustomer := true;
                                    end;
                                ValidateCustomer();
                                OnlySelectCustomer := false;
                            end;
                        end;
                        REC."Sell-to Contact No." := msrCards."Link No.";
                        REC.Modify;
                        Commit;
                        InfoTextDescription := REC."Sell-to Contact No.";
                        InfoTextDescription2 := '';
                    end;
                end;
            msrCards."Link Type"::"Loading Card":
                begin
                    if not LoadingCardManagement.ProcessLoadingCardEvent(
                      msrCards."Card Number", REC."Receipt No.", LoadCardCalledFrom::POSTransaction,
                      LoadCardInputType::"MSR Card", LoadCardEventType::Unknown, ErrorText)
                    then begin
                        PosTransactionGui.ErrorBeep(ErrorText);
                        exit(false);
                    end;
                    exit(true);
                end;
        end;
        exit(true);
    end;

    procedure VoidPostedTransaction(): Boolean
    var
        MultipleTransactionHeader: Record "LSC Transaction Header";
        TransRecRef: RecordRef;
        fldRef: FieldRef;
        TransRecID: RecordID;
        ErrorCode: Code[10];
        ErrorText: Text;
    begin
        Clear(RefundTransaction);
        if not TestNewTransaction then
            exit;
        if CurrInput = '' then
            exit;

        if (CopyStr(CurrInput, 1, 22) = CopyStr(RefundTransaction.TableName, 1, 22)) and (Evaluate(TransRecID, CurrInput)) then begin
            if MultipleRecordsForReceipt then begin
                RefundTransaction.Get(TransRecID);
                CurrInput := '';
            end else begin
                TransRecRef.Get(TransRecID);
                fldRef := TransRecRef.Field(15);
                CurrInput := Format(fldRef.Value)
            end;
        end;

        RefundMgt.InitRefund(RefundTransaction, REC."Receipt No.");

        //RefundMgt.InitRefund(RefundTransaction, REC."Receipt No.", MultipleRecordsForReceipt);
        if not RefundMgt.RetrieveTransactionToRefundByReceipt(CurrInput, RefundTransaction, ErrorCode, ErrorText) then begin
            PosTransactionGui.ErrorBeep(ErrorText);
            exit;
        end;

        MultipleRecordsForReceipt := false;
        if CurrInput <> '' then begin
            MultipleTransactionHeader.SetCurrentKey("Receipt No.");
            if (CopyStr(CurrInput, 1, 1) = 'T') then
                MultipleTransactionHeader.SetRange("Receipt No.", CopyStr(CurrInput, 2))
            else
                MultipleTransactionHeader.SetRange("Receipt No.", CurrInput);
            if MultipleTransactionHeader.count > 1 then begin
                POSTransactionFunctions.LookupTransactionListPanelFiltered(CurrInput, NewLine, PosFuncProfile);
                exit;
            end;
        end;

        if RefundTransaction."Transaction No." <> 0 then
            CurrInput := Format(RefundTransaction."Transaction No.");

        if CurrInput <> '' then begin
            // if not RefundMgt.ValidatePostedTransactionRefund(RefundTransaction, REC."Receipt No.", ErrorCode, ErrorText) then begin
            //     PosTransactionGui.ErrorBeep(ErrorText);
            //     exit;
            // end;
            // RefundMgt.PrepareTransToRefund;
            // RefundLookUp(RefundTransaction, REC."Receipt No.");
        end;
        POSTransactionEvents.OnAfterVoidPostedTransaction(REC);
    end;

    internal procedure ProcessRefundSelection(TmpCode: Code[30]; SkipInfocode: boolean)
    var
        VoidCardEntry: Record "LSC POS Card Entry";
        CardEntryNo: Integer;
        ErrorText: Text;
        ErrorCode: Code[10];
        Retry, IsHandled : Boolean;
        RefundCancelledErr: Label 'REFUND CANCELLED';
        CardEntry: Record "LSC POS Card Entry";
    begin
        PosFunc.PosTransDiscFlush;
        POSTransactionEvents.OnBeforeProcessRefundSelection(REC, IsHandled);
        if IsHandled then
            exit;
        if TmpCode = '' then begin //NO LINES SELECTED IN REFUND LOOKUP
            PosTransactionGui.ErrorBeep(RefundCancelledErr);
            exit;
        end;

        CurrInput := '';
        RefundPressed(false);

        VoidInProcess := true;
        // if not RefundMgt.CopyTransRefundInfo(RefundTransaction, REC, ErrorCode, ErrorText) then begin
        //     SetPOSState("LSC POS Transaction State"::SALES);
        //     SetFunctionMode("LSC POS Command"::ITEM);
        //     PosTransactionGui.ErrorBeep(ErrorText);
        //     exit;
        // end;

        // POSTransactionEventsPub.OnProcessRefundSelection(RefundTransaction, REC, false);

        // if Member.LoadMemberInfo(REC."Member Card No.", ErrorText, true) then begin
        //     REC."Starting Point Balance" := Member.TotalRemainingPointsInt;
        //     REC.Modify;
        // end;

        CopyTransSalesperson(RefundTransaction, REC);

        Commit;
        if (RefundTransaction.Date = Today) and (not EFT.DisableVoidCardPrompt) then begin
            POSTransactionEvents.OnBeforeTestVoidCardEntryProcessRefundSelection(IsHandled);
            if not IsHandled then begin
                VoidCardEntry.SetCurrentKey("Store No.", "POS Terminal No.", "Transaction No.", "Line No.");
                VoidCardEntry.SetRange("Store No.", RefundTransaction."Store No.");
                VoidCardEntry.SetRange("POS Terminal No.", RefundTransaction."POS Terminal No.");
                VoidCardEntry.SetRange("Transaction No.", RefundTransaction."Transaction No.");
                if VoidCardEntry.FindSet then
                    repeat
                        CalcTotals;
                        if EFT.TestVoidCardEntry(REC, VoidCardEntry) and (VoidCardEntry.Amount <= Abs(RealBalance)) then begin
                            Retry := True;
                            while Retry do begin
                                Retry := false;
                                if not VoidCard(VoidCardEntry, CardEntryNo, ErrorText) then begin
                                    PosTransactionGui.ErrorBeep(ErrorText);
                                    Retry := PosTransactionGui.PosConfirm(StrSubstNo(RetryCardVoid, ErrorText), true)
                                end
                            end;

                            InsertVoidPaymentLine(VoidCardEntry, CardEntryNo);
                        end;
                    until VoidCardEntry.Next = 0;
            end;
        end;
        VoidInProcess := false;

        POSTransactionEvents.OnAfterProcessRefundSelection(REC, LineRec, CurrInput);

        LineRec.SetRange("Receipt No.", REC."Receipt No.");
        if LineRec.FindFirst then begin
            POSLINES.SetCurrentLine(LineRec);
            UpdateLineInfo();
        end;

        if not SkipInfocode then begin
            CheckInfoCode('REFUND');
            LineRec.SetRange("Receipt No.", REC."Receipt No.");
            LineRec.SetRange("Entry Type", LineRec."Entry Type"::Item);
            if LineRec.FindSet() then
                repeat
                    CheckInfoCode('ITEM');
                until LineRec.Next = 0;
        end;
        CalcTotals();

        if EFT.PostTransactionAfterVoid and (Balance = 0) then begin
            if STATE <> "LSC POS Transaction State"::PAYMENT then
                POSCtrl.PostCommand("LSC POS Command"::TOTAL, '');

            POSCtrl.PostCommand("LSC POS Command"::POST, '');
        end;
    end;

    local procedure InsertVoidPaymentLine(VoidCardEntry: Record "LSC POS Card Entry"; CardEntryNo: Integer)
    var
        CardEntry: Record "LSC POS Card Entry";
    begin
        if not CardEntry.Get(PosTerminal."Store No.", PosTerminal."No.", CardEntryNo) then
            exit;

        InitNewLine;
        if VoidCardEntry."Transaction Type" = VoidCardEntry."Transaction Type"::Refund then
            PaymentAmount := -VoidCardEntry.Amount
        else
            PaymentAmount := VoidCardEntry.Amount;

        ChangeTender := false;
        KeyboardAmount := false;
        TenderType.Get(PosTerminal."Store No.", VoidCardEntry."Tender Type");

        NewLine."Card Type" := VoidCardEntry."Card Type";

        InsertPaymentLine;

        CardEntry."Line No." := NewLine."Line No.";
        CardEntry.Modify();

        Commit;
    end;

    procedure VoidCard(VoidCardEntry: Record "LSC POS Card Entry"; var pCardEntryNo: Integer; var pErrorReason: Text): Boolean
    begin
        exit(EFT.VoidCard(REC, LineRec, VoidCardEntry, pCardEntryNo, pErrorReason));
    end;

    procedure WriteMgrStatus()
    begin
        if REC."Receipt No." = '' then
            exit;

        if not REC.Get(REC."Receipt No.") then
            exit;

        if POSSESSION.MgrKey and (REC."Manager Key" = REC."Manager Key"::Off) then begin
            REC."Manager Key" := REC."Manager Key"::On;
            if REC.Modify then;
        end;

        if not (POSSESSION.ManagerID in ['', REC."Manager ID"]) then begin
            REC."Manager ID" := POSSESSION.ManagerID;
            if REC.Modify then;
        end;
    end;

    procedure RefreshTrainingStatus()
    begin
        REC.Modify;
        Commit;
        if TrainingActive then
            StateTxt2 := __StateTRAINING
        else
            StateTxt2 := '';
        POSSESSION.SetTrainingStatus(TrainingActive);
    end;

    procedure PriceCheckPressed(Curr: Code[20])
    var
        ScanOrEnterItemNoMsg: Label 'Scan or enter item number';
    begin
        if STATE = "LSC POS Transaction State"::TENDOP then begin
            PosTransactionGui.MessageBeep('');
            exit;
        end;
        if Curr <> '' then
            Currency.Get(Curr);
        // SetFunctionMode("LSC POS Command"::CHECK);
        InfoTextDescription := ScanOrEnterItemNoMsg;
        InfoTextDescription2 := '';
        PosTransactionGui.MessageBeep('');
    end;

    procedure ValidatePriceCheck()
    var
        PeriodicDiscount: Record "LSC Periodic Discount";
        TmpLine: Record "LSC POS Trans. Line";
        TransPerDisc: Record "LSC POS Trans. Per. Disc. Type";
        ItemVariant: Record "Item Variant";
        lPeriodicDiscountLineRec: Record "LSC Periodic Discount Line";
        lItemSpecialGroupLinkRec: Record "LSC Item/Special Group Link";
        MenuLine: Record "LSC POS Menu Line";
        rboPriceUtil: Codeunit "LSC Retail Price Utils";
        GS1BestBeforeDate: Date;
        ScannedDatabarCheck: Text;
        OfferCode: Code[20];
        Price, lTmpDiscPrice, WeightInLbsFromBarcode : Decimal;
        OfferCount, Step, MaxNoOfSteps : Integer;
        OfferType: Option Multibuy,"Mix&Match","Disc. Offer";
        lLineFound, IsHandled : Boolean;
        ActiveOffersMsg: Label 'Part of %1 active offers';
    begin
        if CurrInput = '' then
            exit;

        Clear(ScannedDatabarCheck);
        if GS1DatabarBarcodeMgmt.IsComplexBarcode(CurrInput) then begin
            ScannedDatabarCheck := CurrInput;
            CurrInput := GS1DatabarBarcodeMgmt.GetGTINFromDatabar(ScannedDatabarCheck);
        end else
            if StrLen(CurrInput) > 20 then
                CurrInput := CopyStr(CurrInput, 1, 20);

        POSTransactionEvents.OnBeforeValidatePriceCheck(REC, TmpLine, CurrInput);

        TmpLine."Receipt No." := REC."Receipt No.";
        TmpLine."Store No." := REC."Store No.";
        TmpLine."POS Terminal No." := REC."POS Terminal No.";
        TransPerDisc.SetRange("Receipt No.", TmpLine."Receipt No.");
        TransPerDisc.SetRange("Line No.", TmpLine."Line No.");
        TransPerDisc.DeleteAll;
        TmpLine.Quantity := 1;
        TmpLine.Number := CurrInput;
        if not PosFunc.LoadItem(TmpLine) then begin
            PosTransactionGui.ErrorBeep(StrSubstNo(ItemNotOnFileErr, CurrInput));
            exit;
        end;

        if ScannedDatabarCheck <> '' then begin
            GS1DatabarBarcodeMgmt.GetValuesFromDatabar(ScannedDatabarCheck, GTIN_EAN, TmpLine."Expiration Date", TmpLine.Quantity,
              WeightInLbsFromBarcode, TmpLine."Lot No.", TmpLine."Serial No.", GS1BestBeforeDate);
            if (TmpLine.Quantity <> 0) or (WeightInLbsFromBarcode <> 0) then
                TmpLine."Quantity in Barcode" := true;
            if TmpLine."Expiration Date" <> 0D then
                if TmpLine."Expiration Date" < Today then begin
                    PosTransactionGui.ErrorBeep(ItemExpiredError);
                    exit;
                end;

            ScannedDatabarCheck := '';
        end;

        TmpLine."Sales Type" := LineSalesType;
        TmpLine."Price Group Code" := LinePriceGroup;
        if (TmpLine."Unit of Measure" <> '') and (UOMSet = '') then
            UOMSet := TmpLine."Unit of Measure";
        if TmpLine."Variant Code" <> '' then begin
            pluCurrVariant := TmpLine."Variant Code";
            pluCheckPriceMode := true;
        end;
        if pluCurrVariant <> '' then
            TmpLine."Variant Code" := pluCurrVariant;
        TmpLine."Unit of Measure" := UOMSet;
        UOMSet := '';

        Item.Get(TmpLine.Number);
        MenuLine."Menu ID" := '';
        MenuLine.Command := Format("LSC POS Command"::PRICECHK);
        MenuLine.Parameter := Item."No.";
        PosFunc.POSlog(MenuLine, REC."Receipt No.");

        if TmpLine."Unit of Measure" = '' then
            TmpLine."Unit of Measure" := Item."Sales Unit of Measure";

        PriceCheckUnitOfMeasure := TmpLine."Unit of Measure";

        if TmpLine."Price in Barcode" then
            Price := TmpLine.Amount
        else begin
            Price :=
              rboPriceUtil.GetValidRetailPrice2(
                PosTerminal."Store No.", TmpLine.Number, Today, Time,
                TmpLine."Unit of Measure", TmpLine."Variant Code", REC."VAT Bus.Posting Group",
                REC."Trans. Currency Code", TmpLine."Price Group Code", TmpLine."Sales Type",
                REC."Customer Disc. Group");

            rboPriceUtil.GetAdditionalPriceInfo(TmpLine."Promotion No.", TmpLine."InfoCode Disc. Disable");
        end;
        TmpLine.Price := Price;

        POSTransactionEvents.OnValidatePriceCheckAfterInitTmpLine(TmpLine);

        if pluCheckPriceMode and (pluCurrVariant <> '') then
            InfoTextDescription := GetPriceCheckInformationText(Price, pluCurrVariant, false)
        else
            InfoTextDescription := GetPriceCheckInformationText(Price, PriceCheckUnitOfMeasure, false);

        OfferCount := FindActiveOfferInStore(OfferCode, OfferType, TmpLine);
        if OfferCount > 0 then
            if OfferCount = 1 then begin
                PeriodicDiscount.Get(OfferCode);
                InfoTextDescription2 := Format(OfferType) + ' ' + Format(OfferCode) + ' : ' + PeriodicDiscount.Description;
                if OfferType = OfferType::"Disc. Offer" then begin
                    lPeriodicDiscountLineRec.SetCurrentKey("Offer No.", "No.");
                    lPeriodicDiscountLineRec.SetRange("Offer No.", OfferCode);
                    lLineFound := false;
                    Step := 1;
                    MaxNoOfSteps := 5;
                    POSTransactionEvents.OnValidatePriceCheckOnAfterSetMaxNoOfSteps(MaxNoOfSteps);
                    repeat
                        IsHandled := false;
                        POSTransactionEvents.OnValidatePriceCheckOnBeforePerDiscLineFilterByType(lPeriodicDiscountLineRec, Step, IsHandled);
                        if not IsHandled then begin
                            case Step of
                                1:
                                    lPeriodicDiscountLineRec.SetRange(Type, lPeriodicDiscountLineRec.Type::Item);
                                2:
                                    lPeriodicDiscountLineRec.SetRange(Type, lPeriodicDiscountLineRec.Type::"Special Group");
                                3:
                                    lPeriodicDiscountLineRec.SetRange(Type, lPeriodicDiscountLineRec.Type::"Product Group");
                                4:
                                    lPeriodicDiscountLineRec.SetRange(Type, lPeriodicDiscountLineRec.Type::"Item Category");
                                5:
                                    lPeriodicDiscountLineRec.SetRange(Type, lPeriodicDiscountLineRec.Type::All);
                            end;
                        end;
                        if lPeriodicDiscountLineRec.FindSet then
                            repeat
                                IsHandled := false;
                                POSTransactionEvents.OnValidatePriceCheckOnBeforePerDiscLineFilterByNo(lPeriodicDiscountLineRec, Item, Step, lLineFound, IsHandled);
                                if not IsHandled then
                                    case Step of
                                        1:
                                            if lPeriodicDiscountLineRec."No." = Item."No." then begin
                                                lPeriodicDiscountLineRec.SetRange("No.", Item."No.");
                                                lLineFound := true;
                                            end;
                                        2:
                                            if lItemSpecialGroupLinkRec.Get(Item."No.", lPeriodicDiscountLineRec."No.") then begin
                                                lPeriodicDiscountLineRec.SetRange("No.", lItemSpecialGroupLinkRec."Special Group Code");
                                                lLineFound := true;
                                            end;
                                        3:
                                            if lPeriodicDiscountLineRec."No." = Item."LSC Retail Product Code" then begin
                                                lPeriodicDiscountLineRec.SetRange("No.", Item."LSC Retail Product Code");
                                                lLineFound := true;
                                            end;
                                        4:
                                            if lPeriodicDiscountLineRec."No." = Item."Item Category Code" then begin
                                                lPeriodicDiscountLineRec.SetRange("No.", Item."Item Category Code");
                                                lLineFound := true;
                                            end;
                                        5:
                                            lLineFound := true;
                                    end;
                            until (lPeriodicDiscountLineRec.Next = 0) or lLineFound;

                        Step += 1;
                    until lLineFound or (Step > MaxNoOfSteps);
                    if not lPeriodicDiscountLineRec.Exclude then begin
                        lTmpDiscPrice := TmpLine.Amount - ((lPeriodicDiscountLineRec."Deal Price/Disc. %" / 100) * TmpLine.Amount);

                        //POSTransactionEvents.OnValidatePriceCheckOnAfterCalcDiscPrice(TmpLine, PosFuncProfile, lPeriodicDiscountLineRec."Deal Price/Disc. %", lTmpDiscPrice);

                        LastDiscPrice := lTmpDiscPrice;
                        InfoTextDescription2 := Format(PeriodicDiscount.Type) + ' ' + Format(OfferCode)
                                             + PosFuncProfile.GetMultipleItemsSymbol() + FormatAmount(lTmpDiscPrice);
                    end else begin
                        InfoTextDescription2 := '';
                        LastDiscPrice := TmpLine.Amount;
                    end;
                end;
            end else
                InfoTextDescription2 := StrSubstNo(ActiveOffersMsg, OfferCount);

        // POSTransactionEvents.OnValidatePriceCheckBeforeTransPerDiscDelete(TmpLine, TransPerDisc, InfoTextDescription, InfoTextDescription2);

        TransPerDisc.SetRange("Receipt No.", TmpLine."Receipt No.");
        TransPerDisc.SetRange("Line No.", TmpLine."Line No.");
        TransPerDisc.DeleteAll;

        // POSTransactionEvents.OnAfterValidatePriceCheck(InfoTextDescription, Item.Description, PriceCheckUnitOfMeasure, TmpLine.Quantity, Price);

        if Item."LSC Scale Item" then begin
            ItemPhase := -1;
            KeyboardPrice := Price;
            // POSTransScale.AskForWeight(Item);
            exit;
        end;
        if ItemVariant.Get(TmpLine.Number, TmpLine."Variant Code") then
            OposUtil.DisplaySalesLine('', StrSubstNo('%1, %2', Item.Description, ItemVariant."Description 2"), 1, Price, Price, Item."Sales Unit of Measure", true);
        OposUtil.DisplaySalesLine('', Item.Description, 1, Price, Price, Item."Sales Unit of Measure", true);
        ValidatePriceCheckPhase2(Price);
    end;

    local procedure GetPriceCheckInformationText(Price: Decimal; UOM: Code[10]; AddSellItemQuestion: Boolean): Text
    var
        Info: Text;
        DoYouWantToSellTheItem: Label 'Do you want to sell the item?';
    begin
        Info := StrSubstNo(PriceCheckForItem + ' "%1" [%2]: %3', Item.Description, Item."No.", POSSESSION.FormatPricePrUnit(Price, UOM));
        if (AddSellItemQuestion) then begin
            Info := Info + '\' + DoYouWantToSellTheItem;
        end;

        POSTransactionEvents.OnBeforeReturnPriceCheckInfoTxt(Info, Item, Price, UOM);
        exit(Info);
    end;

    procedure ValidatePriceCheckPhase2(var Price: Decimal)
    var
        IsHandled: Boolean;
    begin
        CurrInput := '';
        SetPOSState("LSC POS Transaction State"::SALES);
        //SetFunctionMode("LSC POS Command"::ITEM);
        Clear(Currency);

        POSTransactionEvents.OnAfterValidatePriceCheckPhase2(REC, LineRec, CurrInput, Price, Item."No.", IsHandled, LinkedItemsActive, UOMSet, PriceCheckUnitOfMeasure);
        if IsHandled then
            exit;

        if PosFuncProfile."Item Entry at Pricecheck" then
            if PosTransactionGui.PosConfirm(GetPriceCheckInformationText(Price, PriceCheckUnitOfMeasure, true), false) then begin
                CurrInput := Item."No.";
                LinkedItemsActive := false;
                BomLineEntry := false;
                UOMSet := PriceCheckUnitOfMeasure;
                ItemLine(false, false, CurrQty, 0, '', '', '', '', 0, 0);
            end;
    end;

    procedure ReturnLastPriceCheck() Price: Decimal
    begin
        exit(LastDiscPrice);
    end;

    procedure FindItemPrice(ItemNo: Code[20]; transDate: Date; transTime: Time; UOM: Code[10]; VariantCode: Code[10]; CurrencyCode: Code[10]; PriceGroupCode: Code[10]; SalesTypeCode: Code[20]; CustDiscGroup: Code[20]): Decimal
    var
        rboPriceUtil: Codeunit "LSC Retail Price Utils";
    begin
        exit(
          rboPriceUtil.GetValidRetailPrice2(PosTerminal."Store No.", ItemNo, transDate, transTime, UOM, VariantCode,
          REC."VAT Bus.Posting Group", CurrencyCode, PriceGroupCode, SalesTypeCode, CustDiscGroup));
    end;

    procedure SetErrorCheck()
    begin
        //SetFunctionMode("LSC POS Command"::ERRCHK);
        POSGUI.SetCurrMenu(0, '')
    end;

    procedure ErrorCheck()
    var
        ErrorStateMsg: Label 'In error state, type in 1234 to logout';
    begin
        if CurrInput = '1234' then begin
            CloseForm();
            exit;
        end;
        CurrInput := '';
        PosTransactionGui.PosMessage(ErrorStateMsg);
    end;

    procedure NegAdjPressed()
    var
        NegAdjMsg: Label 'Negative adjustment';
    begin
        if CheckIfSalesLine then
            if not TestNewTransaction then
                exit;
        REC."Transaction Type" := REC."Transaction Type"::NegAdj;
        SetPOSState("LSC POS Transaction State"::NEG_ADJ);
        POSTransactionEvents.OnBeforeNegAdjPressedStartNewTrans(REC);
        REC."Sale Is Return Sale" := false;
        StartNewTransaction;
        //SetFunctionMode("LSC POS Command"::ITEM);
        InfoTextDescription := NegAdjMsg;
        SelectDefaultMenu;

        POSTransactionEvents.OnBeforeNegAdj(REC, LineRec, CurrInput);
        CheckInfoCode(Format("LSC POS Transaction State"::NEG_ADJ));
    end;

    procedure PhysInvPressed()
    var
        PhysInvMsg: Label 'Physical Inventory';
    begin
        if not TestNewTransaction then
            exit;
        REC."Transaction Type" := REC."Transaction Type"::PhysInv;
        SetPOSState("LSC POS Transaction State"::PHYS_INV);
        REC."Sale Is Return Sale" := false;
        StartNewTransaction;
        //SetFunctionMode("LSC POS Command"::ITEM);
        InfoTextDescription := PhysInvMsg;
        SelectDefaultMenu;
        CheckInfoCode(Format("LSC POS Transaction State"::PHYS_INV));
    end;

    procedure TSCheckError(): Boolean
    var
        BackgroundMgt: Codeunit "LSC Background Mgt";
        ErrorMessage: Text;
        SetFlags: Boolean;
    begin
        // if PosFunc.UseBackgroundSession then begin
        //     ErrorMessage := BackgroundMgt.GetSendTransactionLastStatus;
        //     if ErrorMessage <> '' then
        //         POSSESSION.SetValue("LSC POS Tag"::"TS_ERROR", CopyStr(ErrorMessage, 1, 250));
        // end;
        SetFlags := false;
        if PosFuncProfile."Use Background Session" then begin
            if (POSSESSION.GetValue("LSC POS Tag"::"TS_ERROR") <> '') then
                SetFlags := true;
        end else begin
            if (POSSESSION.GetValue("LSC POS Tag"::"TS_ERROR") <> '') or TSUtil.UnsentTransactionsExist then
                SetFlags := true;
        end;
        if SetFlags then begin
            if TSErrorTime = 0T then
                TSErrorTime := Time;
            if POSSESSION.GetValue("LSC POS Tag"::"TS_ERROR") <> '' then begin
                POSGUI.SetTSUnsentTransactionsFlag(false);
                POSGUI.SetTSErrorFlag(true);
            end
            else begin
                POSGUI.SetTSUnsentTransactionsFlag(true);
                POSGUI.SetTSErrorFlag(false);
            end;
            exit(true);
        end
        else begin
            POSGUI.SetTSUnsentTransactionsFlag(false);
            POSGUI.SetTSErrorFlag(false);
            AzureStorageUpdate();
            StartJobQueueUpdate();
            exit(false);
        end;
    end;

    procedure TSSendUnsentTransactions()
    var
        BackgroundMgt: Codeunit "LSC Background Mgt";
    begin
        // if PosFunc.UseBackgroundSession then begin
        //     BackgroundMgt.SendTransaction;
        //     TSCheckError;
        // end else begin
        //     if TSErrorTime <> 0T then begin
        //         if ((Time - TSErrorTime) < 0) or ((Time - TSErrorTime) / 60000 > PosFuncProfile.TSResendDelay) then begin
        //             if TSUtil.UnsentTransactionsExist then begin
        //                 TSUtil.SendUnsentTablesDD3(PosFuncProfile.TSTransResendLimit, false);
        //                 TSCheckError;
        //                 TSErrorTime := Time;
        //             end else
        //                 TSErrorTime := 0T;
        //         end;
        //     end
        //     else begin
        //         TSUtil.SendUnsentTablesDD3(PosFuncProfile.TSTransResendLimit, false);
        //         TSCheckError;
        //     end;
        // end;
    end;

    procedure ProcessSalesPerson()
    var
        Currline: Record "LSC POS Trans. Line";
        POSTransPostingState: Record "LSC POS Trans. Posting State";
        POSTransSuspensionState: Record "LSC POS Trans. Susp. State";
    begin
        if POSTransactionFunctions.GetTransPostingState(REC."Receipt No.", POSTransPostingState) then
            if POSTransPostingState."Posting State" = POSTransPostingState."Posting State"::"Salesperson Input" then begin
                POSTransactionFunctions.ProcessSalesPersonInputOnPosting(REC, CurrInput);
                exit;
            end;

        if POSTransactionFunctions.GetTransSuspensionState(REC."Receipt No.", POSTransSuspensionState) then
            if POSTransSuspensionState."Suspension State" = POSTransSuspensionState."Suspension State"::"Salesperson Input" then begin
                POSTransactionFunctions.ProcessSalesPersonInputOnSuspending(REC, CurrInput);
                exit;
            end;

        if not ValidateSalesPerson then
            exit;

        if (PosFuncProfile."Sales Person Mode" <> PosFuncProfile."Sales Person Mode"::" ") and
           (REC."Sales Staff" <> CurrInput)
        then begin
            REC."Sales Staff" := CurrInput;
            REC.Modify;
            Commit;
        end;

        if PosFuncProfile."Sales Person Mode" = PosFuncProfile."Sales Person Mode"::Manual then begin
            POSLINES.GetCurrentLine(Currline);
            if (Currline."Line No." <> 0) and (Currline."Sales Staff" <> CurrInput) then begin
                Currline."Sales Staff" := CurrInput;
                Currline.Modify(true);
                Commit;
            end;
        end;

        POSTransactionEvents.OnAfterProcessSalesPerson(PosFuncProfile, REC, CurrInput);

        PosTransactionGui.MessageBeep(StrSubstNo(SalesPersonRegisteredErr, CurrInput));

        // SetFunctionMode("LSC POS Command"::ITEM);
        if StartItemNo <> '' then begin
            CurrInput := StartItemNo;
            ItemLine(true, false, 0, 0, '', '', '', '', 0, 0);
        end else
            if IncExpAccNo <> '' then begin
                CurrInput := Format(PaymentAmount);
                IncExpLine;
            end else
                CurrInput := '';
    end;

    procedure ValidateSalesPerson(): Boolean
    var
        tmpStaff: Record "LSC Staff";
        StaffStoreLink: Record "LSC STAFF Store Link";
        SalesType: Record "LSC Sales Type";
        StaffStoreOk: Boolean;
        IsHandled: Boolean;
    begin
        POSTransactionEvents.OnBeforeValidateSalesPerson(PosFuncProfile, REC, IsHandled);
        if IsHandled then
            exit(false);
        Clear(SalesType);
        if SalesType.Get(REC."Sales Type") then;
        if PosFuncProfile."Sales Person Mode" = PosFuncProfile."Sales Person Mode"::" " then begin // or STATE = STATE::ITEM
            if not SalesType."Request Salesperson" then begin
                PosTransactionGui.MessageBeep('');
                exit(false);
            end;
        end;
        // if CurrInput = '' then begin
        //     SetFunctionMode("LSC POS Command"::SALESP);
        //     exit(false);
        // end;
        if not tmpStaff.Get(CurrInput) then begin
            PosTransactionGui.ErrorBeep(StrSubstNo(IsNotOnFileErr, tmpStaff.TableCaption, CurrInput));
            //SetFunctionMode("LSC POS Command"::SALESP);
            exit(false);
        end;
        StaffStoreOk := false;
        if tmpStaff."Store No." = '' then
            StaffStoreOk := true;
        if (not StaffStoreOk) and (tmpStaff."Store No." <> '') and (tmpStaff."Store No." = POSSESSION.StoreNo) then
            StaffStoreOk := true;
        if (not StaffStoreOk) and StaffStoreLink.Get(tmpStaff.ID, POSSESSION.StoreNo) then
            StaffStoreOk := true;
        if (not StaffStoreOk) then begin
            PosTransactionGui.ErrorBeep(StaffIdNotInStoreErr);
            //SetFunctionMode("LSC POS Command"::SALESP);
            exit(false);
        end;

        POSTransactionEvents.OnAfterValidateSalesPersonStaffStore(tmpStaff);

        if LineRec."Entry Type" <> LineRec."Entry Type"::IncomeExpense then
            if (tmpStaff."Employment Type" <> tmpStaff."Employment Type"::"Sales Person") and
               (tmpStaff."Employment Type" <> tmpStaff."Employment Type"::Both)
            then begin
                tmpStaff."Employment Type" := tmpStaff."Employment Type"::"Sales Person";
                PosTransactionGui.ErrorBeep((StrSubstNo(IsNotErr, tmpStaff.TableCaption, CurrInput, tmpStaff."Employment Type")));
                //SetFunctionMode("LSC POS Command"::SALESP);
                exit(false);
            end;

        exit(true);
    end;

    procedure ProcessReceiptBarcode() Success: Boolean
    var
        Type: Text[10];
        StartNewTrans: Label 'Start new transaction to be able to process barcode';
    begin
        if REC."New Transaction" then begin
            Type := CopyStr(CurrInput, 1, 1);
            case Type of
                'T':
                    POSTransactionFunctions.Process_T_Transaction(CurrInput, NewLine, PosFuncProfile, '');
                'P':
                    RetSuspendedPressed('');
                'S':
                    ProcessCODataInput();
            end;
            exit(true);
        end else
            Message(StartNewTrans);

        exit(false);
    end;

    procedure ClearPOSTransaction()
    var
        TransInfocode: Record "LSC POS Trans. Infocode Entry";
    begin
        Clear(LineRec);
        LineRec.SetRange("Receipt No.", REC."Receipt No.");
        if not LineRec.FindLast then begin
            REC."New Transaction" := true;
            Clear(REC."Transaction Type");
            Clear(REC."Trans. Date");
            Clear(REC."Trans Time");
            Clear(REC."Manager Key");
            Clear(REC."Manager ID");
            Clear(REC."Trans. Currency Code");
            Clear(REC."Currency Factor");
            Clear(StateTxt);
            Clear(REC."Sale Is Return Sale");
            Clear(REC."Member Card No.");
            Clear(REC."Starting Point Balance");
            Clear(REC."Customer No.");
            Clear(REC."Customer Disc. Group");
            Clear(REC."Retrieved from Receipt No.");
            POSTransactionEvents.ClearPOSTransactionOnBeforeModify(REC);
            if REC.Modify then;
            TransInfocode.SetRange("Receipt No.", REC."Receipt No.");
            TransInfocode.DeleteAll;
            POSTransactionEvents.OnAfterClearPOSTransaction(REC);
        end;
    end;

    procedure InfocodeTestOnClose(): Boolean
    var
        VoidCardEntry: Record "LSC POS Card Entry";
        VoidedCardEntryNo: Integer;
        ErrorText: Text;
    begin
        if FunctionSetup."Function Code" = Format("LSC POS Command"::INFOCODE) then
            if Info."Input Required" then
                if (InfoFunction = 'ITEM') or (InfoFunction = 'PAYMENT') or (InfoFunction = 'INCEXP') then
                    if PosTransactionGui.PosConfirm(InfocodeRequiredCancelQst, false) then begin
                        if (LineRec."Entry Type" = LineRec."Entry Type"::Payment) and
                           (LineRec."Card Entry No." <> 0) then begin
                            VoidCardEntry.Get(PosTerminal."Store No.", PosTerminal."No.", LineRec."Card Entry No.");
                            if not VoidCard(VoidCardEntry, VoidedCardEntryNo, ErrorText) then begin
                                PosTransactionGui.ErrorBeep(ErrorText);
                                exit(false);
                            end;
                        end;
                        // POSLINES.DelRecord(LineRec);
                        // POSLINES.DeleteLinkedLines(LineRec."Line No.");
                        FunctionSetup.Get(StartFunction);
                        SetInputPrompt(FunctionSetup.Prompt);
                        InfoTextDescription := '';
                        LineRec.Reset;
                        LineRec.SetRange("Receipt No.", REC."Receipt No.");
                        if LineRec.FindLast then begin
                            POSLINES.GetCurrentLine(LineRec);
                        end;
                        exit(true);
                    end else
                        exit(false);

        exit(true);
    end;

    procedure CorrectStaffLogin()
    var
        Msg: Text[120];
    begin
        if not TestNewTransaction then begin
            PosTransactionGui.ErrorBeep(LoginActionsInvalidInTransErr);
            exit;
        end;

        // PosFunc.CorrectStaffTimeReg(POSSESSION.StaffID, Msg);
        InfoTextDescription := CopyStr(Msg, 1, 80);
    end;

    procedure LogInOutStaff(ActionInt: Integer)
    var
        Msg: Text[120];
    begin
        if not TestNewTransaction then begin
            PosTransactionGui.ErrorBeep(LoginActionsInvalidInTransErr);
            exit;
        end;

        //PosFunc.LogStaffInOut(POSSESSION.StaffID, ActionInt, Msg);
        InfoTextDescription := CopyStr(Msg, 1, 80);
    end;

    //TODO: To be removed - This is only here because of functionality around Payment into Account
    //      See for further information: internal procedure LookUp
    procedure OpenNumericKeyboard(Caption: Text; KeybType: Integer; DefaultValue: Text; TriggerNo: Integer)
    begin
        NumericKeyboardTrigger := TriggerNo;
        PosTransactionGui.OpenNumericKeyboard(Caption, DefaultValue, TriggerNo);
    end;

    procedure AskForSerialNo()
    var
        ErrorText: Text[250];
    begin
        ErrorText := '';
        // if not PosFunc.UpdateSerialLotInvLookup(NewLine, Item."Item Tracking Code", ErrorText) then
        //     if not POSSESSION.MgrKey then begin
        //         PosTransactionGui.ErrorBeep(ErrorText);
        //         exit;
        //     end;

        OldFuncMode := FunctionSetup."Function Code";
        //SetFunctionMode("LSC POS Command"::SERIALNO);
        PosTransactionGui.MessageBeep(StrSubstNo('%1: %2', FunctionSetup.Description, Item.Description));
        SetPosInfoText1(StrSubstNo('%1 %2', Item."No.", Item.Description));

        if ErrorText <> '' then begin
            InfoTextDescription2 := CopyStr(ErrorText, 1, MaxStrLen(InfoTextDescription2));
        end;
    end;

    procedure ValidateSerialNo(var ErrorText: Text[250]): Boolean
    var
        SerialInvalidContinueQst: Label 'Serial No Invalid. Error: %1 \Use Anyway?';
        IsHandled: Boolean;
    begin
        // ErrorText := '';
        // if not PosFunc.SerialNoIsValid(NewLine, SerialNo, Item."Item Tracking Code", REC."Sale Is Return Sale", ErrorText) then begin
        //     InfoTextDescription2 := CopyStr(ErrorText, 1, MaxStrLen(InfoTextDescription2));
        //     POSTransactionEvents.OnAfterSerialNoIsValidCheck(IsHandled, ErrorText);
        //     if (POSSESSION.MgrKey or IsHandled) and (SerialNo <> '') then
        //         if PosTransactionGui.PosConfirm(StrSubstNo(SerialInvalidContinueQst, ErrorText), false) then
        //             exit(true)
        //         else begin
        //             ErrorText := CopyStr(StrSubstNo('%1 %2', Item."No.", Item.Description), 1, MaxStrLen(InfoTextDescription)) + '\' + ErrorText;
        //             SerialNo := '';
        //             exit(false);
        //         end
        //     else begin
        //         ErrorText := CopyStr(StrSubstNo('%1 %2', Item."No.", Item.Description), 1, MaxStrLen(InfoTextDescription)) + '\' + ErrorText;
        //         SerialNo := '';
        //         exit(false);
        //     end;
        // end else
        //     exit(true);
    end;

    procedure AskForLotNo()
    var
        ErrorText: Text[250];
    begin
        // ErrorText := '';
        // if not PosFunc.UpdateSerialLotInvLookup(NewLine, Item."Item Tracking Code", ErrorText) then
        //     if not POSSESSION.MgrKey then begin
        //         PosTransactionGui.ErrorBeep(ErrorText);
        //         exit;
        //     end;

        // OldFuncMode := FunctionSetup."Function Code";
        // SetFunctionMode("LSC POS Command"::LOTNO);
        // PosTransactionGui.MessageBeep(StrSubstNo('%1: %2', FunctionSetup.Description, Item.Description));
        // SetPosInfoText1(StrSubstNo('%1 %2', Item."No.", Item.Description));

        // if ErrorText <> '' then begin
        //     InfoTextDescription2 := CopyStr(ErrorText, 1, MaxStrLen(InfoTextDescription2));
        // end;
        // POSTransactionEvents.OnAfterAskForLotNo(REC);
    end;

    procedure ValidateLotNo(var ErrorText: Text[250]): Boolean
    var
        InvalidLotNoContinueQst: Label 'Lot No Invalid. Error: %1 \Use Anyway?';
        Quantity: Decimal;
        IsHandled, ReturnValue : Boolean;
    begin
        // ErrorText := '';
        // if NewLine.Quantity = 0 then
        //     Quantity := 1
        // else
        //     Quantity := NewLine.Quantity;

        // POSTransactionEvents.OnBeforeValidateLotNo(NewLine, IsHandled, ReturnValue, SerialNo, LotNo);
        // if IsHandled then
        //     exit(ReturnValue);

        // if not PosFunc.LotNoIsValid(NewLine, SerialNo, LotNo, Item."Item Tracking Code", REC."Sale Is Return Sale", Quantity, ErrorText) then begin
        //     InfoTextDescription2 := CopyStr(ErrorText, 1, MaxStrLen(InfoTextDescription2));
        //     if (POSSESSION.MgrKey) and (LotNo <> '') then
        //         if PosTransactionGui.PosConfirm(StrSubstNo(InvalidLotNoContinueQst, ErrorText), false) then
        //             exit(true)
        //         else begin
        //             ErrorText := CopyStr(StrSubstNo('%1 %2', Item."No.", Item.Description), 1, MaxStrLen(InfoTextDescription)) + '\' + ErrorText;
        //             LotNo := '';
        //             exit(false);
        //         end
        //     else begin
        //         ErrorText := CopyStr(StrSubstNo('%1 %2', Item."No.", Item.Description), 1, MaxStrLen(InfoTextDescription)) + '\' + ErrorText;
        //         LotNo := '';
        //         exit(false);
        //     end;
        // end else
        //     exit(true);
    end;

    procedure InitPosActions()
    var
        ActionOk: Boolean;
    begin
        Clear(tmpPosActions);
        tmpPosActions.DeleteAll;

        POSAction.Reset;
        if POSAction.FindSet then begin
            repeat
                ActionOk := false;
                if POSAction.Active then begin
                    if (POSAction.Relation = POSAction.Relation::Global) then
                        ActionOk := true
                    else
                        if (POSAction."Relation Code" = PosFuncProfile."Profile ID") then
                            ActionOk := true;
                    if ActionOk then begin
                        tmpPosActions.Number := POSAction."Action Trigger";
                        if tmpPosActions.Insert then;
                    end;
                end;
            until POSAction.Next = 0;
        end;
    end;

    procedure CreateOrderPressed()
    var
        PosOrderConn: Codeunit "LSC POS Order Connection";
        CreateSalesNotAllowedErr: Label 'Create Sales Order not allowed in this state!';
        SalesOrderNotAllowedInPaymTransErr: Label 'Cannot create sales order for a transaction with payment lines.';
        CreateSalesOrderQst: Label 'Do you want to create a sales order for this transaction?';
        OrderCreatedMsg: Label 'Order %1 created.';
    begin
        if STATE = "LSC POS Transaction State"::TENDOP then begin
            PosTransactionGui.ErrorBeep(CreateSalesNotAllowedErr);
            exit;
        end;
        if not POSSESSION.Permission("LSC POS Command"::SUSPEND, InfoTextDescription) then begin  //Create Order treated in the same way as Suspend
            PosTransactionGui.ErrorBeep(InfoTextDescription);
            exit;
        end;

        POSTransactionEvents.OnBeforeCreateOrderOnPOS(REC);
        LineRec.Reset;
        LineRec.SetRange("Receipt No.", REC."Receipt No.");
        LineRec.SetRange(LineRec."Entry Type", LineRec."Entry Type"::Payment);
        LineRec.SetRange("Entry Status", REC."Entry Status"::" ");
        if LineRec.FindFirst then begin
            PosTransactionGui.ErrorBeep(SalesOrderNotAllowedInPaymTransErr);
            exit;
        end;
        LineRec.SetRange(LineRec."Entry Type");
        CurrInput := '';
        if not PosTransactionGui.PosConfirm(CreateSalesOrderQst, false) then
            exit;
        SetErrorCheck;
        PosOrderConn.UpdateSHSL(REC."Receipt No.", "Sales Document Type"::"Order"); // 1

        REC.Get(REC."Receipt No.");
        AfterGetRecord();
        ScreenDisplay(StrSubstNo(OrderCreatedMsg, REC."Document No."));
        InfoTextDescription2 := StrSubstNo(OrderCreatedMsg, REC."Document No.");
        REC.Delete(true);

        Commit;

        InsertTmpTransaction(false);
        ClearGlobs;

        ScreenDisplay('');
    end;

    procedure PostInvoicePressed()
    var
        POSTransLine: Record "LSC POS Trans. Line";
        POSTransInfocodeEntry: Record "LSC POS Trans. Infocode Entry";
        POSTransInfocodeEntryTEMP: Record "LSC POS Trans. Infocode Entry" temporary;
        POSMixMatchEntry: Record "LSC POS Mix & Match Entry";
        OfferPOSCalculations: Record "LSC Offer Pos Calculation";
        POSOrderConn: Codeunit "LSC POS Order Connection";
        POSPostUtility: Codeunit "LSC POS Post Utility";
        ErrorText: Text;
        SalesInvNotAllowedWithPaymTransErr: Label 'Cannot create sales invoice for a transaction with payment lines.';
        PostAndPrintSalesInvQst: Label 'Do you want to post and print a sales invoice for this transaction?';
        InvPostedMsg: Label 'Invoice %1 posted.';
    begin
        // if not PosFunc.PostInvoiceErrorCheck(REC, Format(STATE), InfoTextDescription, InfoTextDescription2, ErrorText) then begin
        //     PosTransactionGui.ErrorBeep(ErrorText);
        //     exit;
        // end;

        // LineRec.Reset;
        // LineRec.SetRange("Receipt No.", REC."Receipt No.");
        // LineRec.SetRange(LineRec."Entry Type", LineRec."Entry Type"::Payment);
        // LineRec.SetRange("Entry Status", REC."Entry Status"::" ");
        // if LineRec.FindFirst then begin
        //     PosTransactionGui.ErrorBeep(SalesInvNotAllowedWithPaymTransErr);
        //     exit;
        // end;

        // LineRec.SetRange(LineRec."Entry Type");
        // CurrInput := '';
        // if not PosTransactionGui.PosConfirm(PostAndPrintSalesInvQst, false) then
        //     exit;

        // if not TestCustomer(Customer."No.", true, false) then
        //     exit;

        // if not PosFunc.ValidateCustomer(Customer, POSSESSION.MgrKey, REC."Sale Is Return Sale", Balance, InfoTextDescription) then begin
        //     PosTransactionGui.ErrorBeep(InfoTextDescription);
        //     InfoTextDescription2 := SelectOtherPaymOrCustMsg;
        //     CurrInput := '';
        //     exit;
        // end;

        // SetErrorCheck;

        // if REC."Document No." <> '' then begin
        //     POSOrderConn.DeleteSH(REC."Receipt No.");
        //     REC."Document No." := '';
        //     REC.Modify;
        // end;

        // ScreenDisplay(StrSubstNo(InvPostedMsg, REC."Document No."));
        // POSOrderConn.UpdateSHSL(REC."Receipt No.", "Sales Document Type"::Invoice); // 2
        // if POSOrderConn.PostAndPrintInvoice(REC."Receipt No.", ErrorText) then begin
        //     REC.Get(REC."Receipt No.");
        //     AfterGetRecord();

        //     POSTransInfocodeEntryTEMP.Reset;
        //     POSTransInfocodeEntryTEMP.DeleteAll;
        //     POSTransInfocodeEntry.SetRange("Receipt No.", REC."Receipt No.");
        //     if POSTransInfocodeEntry.FindSet then
        //         repeat
        //             POSTransInfocodeEntryTEMP := POSTransInfocodeEntry;
        //             if POSTransInfocodeEntryTEMP.Insert then;
        //         until POSTransInfocodeEntry.Next = 0;

        //     POSTransLine.SetRange("Receipt No.", REC."Receipt No.");
        //     POSTransLine.DeleteAll(true);
        //     POSTransInfocodeEntry.SetRange("Receipt No.", REC."Receipt No.");
        //     POSTransInfocodeEntry.DeleteAll;
        //     POSMixMatchEntry.SetRange("Receipt No.", REC."Receipt No.");
        //     POSMixMatchEntry.DeleteAll;
        //     OfferPOSCalculations.SetRange("Receipt No.", REC."Receipt No.");
        //     OfferPOSCalculations.DeleteAll;

        //     if POSTransInfocodeEntryTEMP.FindSet then
        //         repeat
        //             POSTransInfocodeEntry := POSTransInfocodeEntryTEMP;
        //             if POSTransInfocodeEntry.Insert then;
        //         until POSTransInfocodeEntryTEMP.Next = 0;

        //     POSPostUtility.ProcessTransaction(REC);
        // end;

        // Commit;

        // InfoTextDescription2 := '';
        // InsertTmpTransaction(false);
        // ClearGlobs;
        // ScreenDisplay('');

        // if ErrorText <> '' then begin
        //     PosTransactionGui.ErrorBeep(ErrorText);
        //     exit;
        // end;
    end;

    procedure SelectCustPressed(pCustomerNo: Code[20])
    var
        NewTransaction: Boolean;
        CustomerMandatory: Boolean;
        CustomerSelectError: label 'You are not allowed to change Customer when editing a Customer Order.\Cancel the order and create new a new one.';
    begin
        // if CustomerOrderSession.IsCustomerOrderEdit() and (AskConfirmation) then begin
        //     PosTransactionGui.ErrorBeep(CustomerSelectError);
        //     SetPOSState("LSC POS Transaction State"::SALES);
        //     SetFunctionMode("LSC POS Command"::ITEM);
        //     exit;
        // end;

        // if REC."Sale Is Return Sale" and (REC."Customer No." <> '') and (REC."Retrieved from Receipt No." <> '') then begin
        //     PosTransactionGui.ErrorBeep(StrSubstNo(TransBelongsToCustErr, REC."Customer No."));
        //     SetPOSState("LSC POS Transaction State"::PAYMENT);
        //     exit;
        // end;

        // POSTransactionEvents.OnBeforeSelectCustPressed(CustomerMandatory);
        // if (not CustomerMandatory) and (REC."Retrieved from Receipt No." <> '') then begin
        //     PosTransactionGui.ErrorBeep(CustCannotModifiedWhenRefundErr);
        //     exit;
        // end;

        // NewTransaction := REC."New Transaction";
        // SetFunctionMode("LSC POS Command"::CUSTOMER);
        // SetInputPrompt(TenderType."Ask for Card/Account");
        // OnlySelectCustomer := true;

        // if pCustomerNo = '' then
        //     pCustomerNo := CurrInput;

        // if pCustomerNo = '' then begin
        //     LookupCallFunc := 'SELECTCUST';
        //     LookUp(true, '', '');
        //     exit;
        // end
        // else begin
        //     SelectCustPressedEx(pCustomerNo);
        // end;
    end;

    local procedure SelectCustPressedEx(pCustNo: Code[20])
    var
        NewTransaction: Boolean;
        IsHandled: Boolean;
    begin
        CurrInput := pCustNo;
        if pCustNo <> '' then
            SetCustomer(pCustNo);
        POSTransactionEvents.OnBeforeSelectCustPressedEx(pCustNo, IsHandled);
        if IsHandled then begin
            VoidAndCopyTransaction();
            exit;
        end;
        NewTransaction := REC."New Transaction";
        if REC."Customer No." <> '' then begin
            CurrInput := REC."Customer No.";
            TenderType."Function" := TenderType."Function"::Customer;
            if not ValidateCustomer() then
                REC."Customer No." := ''
            else
                POSTransactionEvents.OnAfterSelectCustomer(REC, LineRec, CurrInput);
        end;

        if REC."Customer No." = '' then begin
            if not PosTransactionGui.GetErrormessageFlag() then
                CancelPressed(true, 0);
            exit;
        end;

        if FunctionSetup."Function Code" = Format("LSC POS Command"::INFOCODE) then
            exit;

        OnlySelectCustomer := false;

        // if not NewTransaction then begin
        //     if LAST_STATE = "LSC POS Transaction State"::PAYMENT then begin
        //         SetPOSState("LSC POS Transaction State"::PAYMENT);
        //         if REC."Customer No." = '' then
        //             SetFunctionMode("LSC POS Command"::CUSTOMER)
        //         else
        //             SetFunctionMode("LSC POS Command"::PAYMENT);
        //     end else begin
        //         SetPOSState("LSC POS Transaction State"::SALES);
        //         SetFunctionMode("LSC POS Command"::ITEM);
        //     end;
        //     SelectDefaultMenu;
        // end
        // else begin
        //     if REC."Transaction Type" = REC."Transaction Type"::Payment then begin
        //         SetPOSState("LSC POS Transaction State"::PAYMENT);
        //         POSTransactionFunctions.HandleSalesPersonMode(REC, PosFuncProfile, "LSC POS Command"::PAYMENT);
        //     end
        //     else begin
        //         SetPOSState("LSC POS Transaction State"::SALES);
        //         POSTransactionFunctions.HandleSalesPersonMode(REC, PosFuncProfile, "LSC POS Command"::ITEM);
        //     end;
        // end;
    end;

    procedure ToAccountPressed()
    begin
        SetPOSState("LSC POS Transaction State"::PAYMENT);
    end;

    procedure ViewCustomer(var MenuLine: Record "LSC POS Menu Line")
    var
        SelectCustPanel: Codeunit "LSC POS Create New Customer";
        CustomerSelectError: label 'You are not allowed to change Customer when editing a Customer Order.\Cancel the order and create new a new one.';
    begin
        // if CustomerOrderSession.IsCustomerOrderEdit() then begin
        //     PosTransactionGui.ErrorBeep(CustomerSelectError);
        //     exit;
        // end;

        // Commit;
        // OldFuncMode := GetFunctionMode();
        // SetFunctionMode("LSC POS Command"::CUSTOMER);

        // CreateNewCustomerMenuLine := MenuLine;
        // SelectCustPanel.ShowPanel(CurrInput, REC."Customer No.");
    end;

    procedure ViewCustomerEx(pCustomerNoInp: Text; OkPressed: Boolean)
    var
        CustomerMandatory: Boolean;
        CustomerOk: Boolean;
    begin
        // if (not OkPressed) or (pCustomerNoInp = '') or (Customer."No." = pCustomerNoInp) then begin
        //     if OldFuncMode <> '' then
        //         SetFunctionMode(OldFuncMode)
        //     else
        //         SetFunctionMode("LSC POS Command"::ITEM);
        //     ClearGlobs;
        //     InfoTextDescription := '';
        //     InfoTextDescription2 := '';
        //     CurrInput := '';
        //     exit;
        // end;

        POSTransactionEvents.OnBeforeSelectCustPressedViewCustomerEx(CustomerMandatory);
        if (not CustomerMandatory) and (REC."Retrieved from Receipt No." <> '') then begin
            PosTransactionGui.ErrorBeep(CustCannotModifiedWhenRefundErr);
            exit;
        end;

        TenderType.Get(PosTerminal."Store No.", CreateNewCustomerMenuLine.Parameter);

        CurrInput := pCustomerNoInp;
        OnlySelectCustomer := true;
        if ValidateCustomer then
            CustomerOk := true;
        if FunctionSetup."Function Code" <> Format("LSC POS Command"::INFOCODE) then
            OnlySelectCustomer := false;

        CurrInput := '';
        POSTransactionEvents.OnAfterViewCustomerEx(CustomerOk);
    end;

    procedure TenderCheckloyalty(): Boolean
    var
        PaymentLine: Record "LSC POS Trans. Line";
        ErrorText: Text;
        SyncError: Boolean;
        PointStatus: Decimal;
        MemberPointTenderTypeMissingErr: Label 'Member Point Tender Type missing for Member Club %1';
        BalanceToLow: Label 'Payment exceeds Member Points asset of:';
        MemberPointPaymExistsErr: Label 'Member Point payment already exists';
        MemberPntTenderTypeNotSameErr: Label 'Member Point Tender Type for Member Club %1 is not the same as Tender Type.';
    begin
        // if TenderType."Function" <> TenderType."Function"::Member then
        //     exit(true);
        // if REC."Member Card No." = '' then begin
        //     PosTransactionGui.ErrorBeep(MemberCardRequiredBeforePaymErr);
        //     exit(false);
        // end;
        // PaymentLine.SetRange("Receipt No.", REC."Receipt No.");
        // PaymentLine.SetRange("Entry Type", PaymentLine."Entry Type"::Payment);
        // PaymentLine.SetRange("Entry Status", 0);
        // PaymentLine.SetRange(Number, TenderType.Code);
        // if PaymentLine.FindFirst then begin
        //     PosTransactionGui.ErrorBeep(MemberPointPaymExistsErr);
        //     exit(false)
        // end;
        // if not Member.LoadMemberInfo(REC."Member Card No.", ErrorText, true, SyncError) then begin
        //     if SyncError and POSSESSION.MgrKey then
        //         PointStatus := AmountInCurrency;
        //     PosTransactionGui.ErrorBeep(ErrorText);
        //     exit(false);
        // end;
        // if Member.PointTenderType = '' then begin
        //     PosTransactionGui.ErrorBeep(StrSubstNo(MemberPointTenderTypeMissingErr, Member.Club));
        //     exit(false);
        // end;
        // if Member.PointTenderType <> TenderType.Code then begin
        //     PosTransactionGui.ErrorBeep(StrSubstNo(MemberPntTenderTypeNotSameErr, Member.Club));
        //     exit(false);
        // end;

        // PointStatus := PosFunc.GetMemberPointBalance;
        // if not REC."Sale Is Return Sale" then
        //     if PointStatus < AmountInCurrency + PosFunc.PointsUsedInTransaction(0) then begin
        //         PosTransactionGui.ErrorBeep(StrSubstNo(BalanceToLow, Format(PointStatus)));
        //         exit(false);
        //     end;
        // exit(true);
    end;

    procedure ContactPressed()
    begin
        // SetFunctionMode("LSC POS Command"::CONTACT);
        // PosTransactionGui.MessageBeep('');
    end;

    procedure ValidateContact()
    var
        Contact: Record Contact;
        CustRel: Record "Contact Business Relation";
        Ttype: Record "LSC Tender Type";
        EnterContactNoErr: Label 'Enter Contact Number';
    begin
        // if CurrInput = '' then begin
        //     PosTransactionGui.OpenNumericKeyboard(CustomerMsg, '', Enum::"LSC POS Trans. Numpad Trigger"::ValidateContact);
        //     exit;
        // end;

        // if CurrInput = '' then begin
        //     PosTransactionGui.ErrorBeep(EnterContactNoErr);
        //     exit;
        // end;
        // if not Contact.Get(CopyStr(CurrInput, 1, 20)) then begin
        //     PosTransactionGui.ErrorBeep(EnterContactNoErr);
        //     exit;
        // end;

        // REC."Sell-to Contact No." := CopyStr(CurrInput, 1, 20);
        // InfoTextDescription := Contact.Name;
        // InfoTextDescription2 := '';
        // REC.Modify();
        // Commit;

        // CustRel.SetRange(CustRel."Contact No.", REC."Sell-to Contact No.");
        // CustRel.SetRange(CustRel."Link to Table", CustRel."Link to Table"::Customer);
        // if CustRel.FindFirst then
        //     if Customer.Get(CustRel."No.") then begin
        //         Ttype.SetRange(Ttype."Store No.", PosTerminal."Store No.");
        //         Ttype.SetRange(Ttype."Function", Ttype."Function"::Customer);
        //         if Ttype.FindFirst then begin
        //             TenderType.Get(PosTerminal."Store No.", Ttype.Code);
        //             CurrInput := CustRel."No.";
        //             SetFunctionMode("LSC POS Command"::CUSTOMER);
        //             OnlySelectCustomer := true;
        //             ValidateCustomer();
        //             OnlySelectCustomer := false;
        //             InfoTextDescription := Contact.Name;
        //             InfoTextDescription2 := Customer.Name;
        //         end;
        //     end;

        // CurrInput := '';
        // SetFunctionMode("LSC POS Command"::ITEM);
    end;

    procedure MarkPressed()
    var
        LineRecTmp: Record "LSC POS Trans. Line";
        COUtility: Codeunit "LSC CO Utility";
        ErrorCode: Code[30];
        ErrorText: Text;
        IsHandled: Boolean;
        CoVoidLineNotUnmark: Label 'Customer Order Line cannot be unmarked. Void the line and create a new one instead.';
    begin
        // LineRecTmp.SetRange(LineRecTmp."Receipt No.", REC."Receipt No.");
        // LineRecTmp.SetRange(LineRecTmp."Entry Status", 0);

        // if not LineRecTmp.FindFirst then begin
        //     PosTransactionGui.MessageBeep('');
        //     exit;
        // end;

        // POSLINES.GetCurrentLine(LineRecTmp);
        // POSTransactionEvents.OnBeforeMarkPressed(REC, LineRecTmp, IsHandled);
        // if IsHandled then
        //     exit;

        // LineRecTmp.Get(LineRecTmp."Receipt No.", LineRecTmp."Line No.");
        // PosFunc.MarkLine(LineRecTmp);
        // Commit;
        // POSLINES.SetCurrentLine(LineRecTmp);

        // if LineRecTmp."Customer Order Line" then
        //     if CustomerOrderSession.IsCustomerOrderEdit() then begin
        //         PosFunc.MarkLine(LineRecTmp);
        //         Commit();
        //         POSLINES.SetCurrentLine(LineRecTmp);
        //         PosTransactionGui.ErrorBeep(CoVoidLineNotUnmark);
        //         exit;
        //     end;

        // if (GlobalMenuLine.Parameter <> '') or (LineRecTmp."Customer Order Line" and not LineRecTmp.Marked) then begin
        //     PosFunc.ProcessMarkParameter(REC, LineRecTmp, GlobalMenuLine, ErrorCode, ErrorText);
        //     IF ErrorText <> '' tHEN begin
        //         PosFunc.MarkLine(LineRecTmp);
        //         Commit();
        //         POSLINES.SetCurrentLine(LineRecTmp);
        //         PosTransactionGui.ErrorBeep(ErrorText);
        //         exit;
        //     end;
        // end;

        // if REC."Customer Order" then begin
        //     COUtility.UpdateOrderLines(REC, CustomerOrderLine_Temp, CustomerOrderDiscountLine_Temp, CustomerOrderHeader_Temp);
        //     if CoLinesMarkHasChanged then begin
        //         COWasCreated := false;
        //         COTotalHasBeenPressed := false;
        //         if STATE <> "LSC POS Transaction State"::SALES then begin
        //             SetPOSState("LSC POS Transaction State"::SALES);
        //             SetFunctionMode("LSC POS Command"::ITEM);
        //             SelectDefaultMenu();
        //         end;
        //     end;
        // end;
        // POSTransactionEvents.OnAfterMarkPressed(REC, LineRecTmp);
    end;

    local procedure CoLinesMarkHasChanged(): boolean
    var
        CoHasChanged: Boolean;
    begin
        CustomerOrderLineCompare_Temp.Reset();
        if not CustomerOrderLineCompare_Temp.IsEmpty then
            if CustomerOrderLine_Temp.FindSet() then
                repeat
                    if not CustomerOrderLineCompare_Temp.Get('', CustomerOrderLine_Temp."Line No.") then
                        CoHasChanged := true;
                until (CustomerOrderLine_Temp.next = 0) or CoHasChanged
            else
                CoHasChanged := true;

        // creat a new set to be able to compare again if needed.
        if CustomerOrderLineCompare_Temp.IsEmpty or CoHasChanged then begin
            CustomerOrderLineCompare_Temp.Reset();
            CustomerOrderLineCompare_Temp.DeleteAll();
            if CustomerOrderLine_Temp.FindSet() then
                repeat
                    CustomerOrderLineCompare_Temp := CustomerOrderLine_Temp;
                    CustomerOrderLineCompare_Temp.Insert();
                until CustomerOrderLine_Temp.next = 0;
        end;

        exit(CoHasChanged);
    end;

    procedure TextPressed(Text: Text[100])
    var
        LineRecTmp: Record "LSC POS Trans. Line";
        NxtLine: Integer;
    begin
        if STATE = "LSC POS Transaction State"::TENDOP then begin
            PosTransactionGui.MessageBeep(TextEntryNotAllowedMsg);
            exit;
        end;
        if REC."New Transaction" then
            SalePressed(false);

        if Text = '' then
            Text := CopyStr(CurrInput, 1, 100);

        if Text = '' then begin
            POSGUI.OpenAlphabeticKeyboard(EnterTextMsg, '', false, '#TEXT', MaxStrLen(Text));
            exit;
        end;

        if Text = '' then begin
            PosTransactionGui.MessageBeep('');
            exit;
        end;

        POSLINES.GetCurrentLine(LineRecTmp);
        NxtLine := LineRecTmp."Line No.";
        InitNewLine;
        NewLine."Entry Type" := NewLine."Entry Type"::FreeText;
        NewLine."Text Type" := NewLine."Text Type"::"Freetext Input";
        NewLine.Validate(NewLine.Description, Text);

        repeat
            NxtLine := NxtLine + 1;
            NewLine."Line No." := NxtLine;
        until not (LineRecTmp.Get(NewLine."Receipt No.", NxtLine));

        NewLine.Insert(true);

        Commit;
        CurrInput := '';
        POSLINES.SetCurrentLine(NewLine);
    end;

    procedure TextLinkedPressed(Text: Text[100])
    var
        LineRecTmp: Record "LSC POS Trans. Line";
        KDSFunctions: Codeunit "LSC KDS Functions";
        NxtLine: Integer;
        ParentParentLine: Integer;
        ParentLineNo: Integer;
        ParentIsItem: Boolean;
        QtyNotPrinted: Decimal;
    begin
        if STATE = "LSC POS Transaction State"::TENDOP then begin
            PosTransactionGui.MessageBeep(TextEntryNotAllowedMsg);
            exit;
        end;

        POSLINES.GetCurrentLine(LineRecTmp);

        if KDSFunctions.TransLineSentToKitchen(REC, LineRecTmp, QtyNotPrinted) then begin
            PosTransactionGui.MessageBeep(ChangeOnSentLineError);
            exit;
        end;

        if REC."New Transaction" then
            SalePressed(false);

        if Text = '' then
            Text := CopyStr(CurrInput, 1, 100);

        if Text = '' then begin
            POSGUI.OpenAlphabeticKeyboard(EnterTextMsg, '', false, '#TEXTLINKED', MaxStrLen(Text));
            exit;
        end;

        if Text = '' then begin
            PosTransactionGui.MessageBeep('');
            exit;
        end;

        NxtLine := LineRecTmp."Line No.";
        ParentLineNo := LineRecTmp."Line No.";
        ParentParentLine := LineRecTmp."Parent Line";
        ParentIsItem := (LineRecTmp."Entry Type" = LineRecTmp."Entry Type"::Item);
        InitNewLine;
        NewLine."Entry Type" := NewLine."Entry Type"::FreeText;
        NewLine."Text Type" := NewLine."Text Type"::"Freetext Input";
        NewLine.Validate(NewLine.Description, Text);

        repeat
            NxtLine := NxtLine + 1;
            NewLine."Line No." := NxtLine;
        until not (LineRecTmp.Get(NewLine."Receipt No.", NxtLine));

        if ParentIsItem then
            NewLine."Parent Line" := ParentLineNo
        else begin
            NewLine."Parent Line" := ParentParentLine;
            if ParentParentLine = 0 then
                NewLine."Parent Line" := ParentLineNo;
        end;

        NewLine.Quantity := 1;
        NewLine."Restaurant Menu Type Code" := LineRecTmp."Restaurant Menu Type Code";
        NewLine."Restaurant Menu Type" := LineRecTmp."Restaurant Menu Type";

        // NewLine.SetIndentNo(LineRecTmp);
        POSTransactionEvents.OnBeforeNewLineInsertTextLinkPressed(NewLine);
        NewLine.Insert(true);

        Commit;
        CurrInput := '';
        POSLINES.SetCurrentLine(NewLine);

        KDSFunctions.SendToKDSifOnItemAddedSet(NewLine, REC."Receipt No.", true);
        POSTransactionEvents.OnAfterNewLineInsertTextLinkPressed(NewLine);
    end;

    procedure ToggleGuestPressed()
    var
        ViewingSeatMsg: Label 'Viewing current seat #%1 only';
        ViewingAllGuestsMsg: Label 'Viewing all guests';
    begin
        // POSLINES.GetCurrentLine(LineRec);
        // CurrGuest := LineRec."Guest/Seat No.";

        // if POSLINES.GetFilterCover() = 0 then
        //     POSLINES.SetFilterCover(CurrGuest, GetReceiptNo)
        // else
        //     POSLINES.SetFilterCover(0, GetReceiptNo);

        // if POSLINES.GetFilterCover() = 0 then
        //     InfoTextDescription := ViewingAllGuestsMsg
        // else
        //     InfoTextDescription := StrSubstNo(ViewingSeatMsg, CurrGuest);

        // CurrInput := '';
    end;

    procedure ConfirmOrderPressed(StartFromBeginning: Boolean)
    var
        SalesTypes: Record "LSC Sales Type";
        KDSFunctions: Codeunit "LSC KDS Functions";
        MinAmount: Decimal;
        ErrTxt3: Label 'Deposit is below the limit of %1';
    begin
        // if StartFromBeginning then begin
        //     if SalesTypes.Get(GLobalSalesType) then begin
        //         if ((SalesTypes."Request Deposit (%)" > 0) or (SalesTypes."Minimum Deposit" <> 0)) and (Balance > 0) then begin
        //             MinAmount := (REC."Gross Amount" + REC."Line Discount") * SalesTypes."Request Deposit (%)" / 100;
        //             if MinAmount < SalesTypes."Minimum Deposit" then
        //                 MinAmount := SalesTypes."Minimum Deposit";
        //             if REC.Payment < MinAmount then begin
        //                 PosTransactionGui.ErrorBeep(StrSubstNo(ErrTxt3, Format(MinAmount)));
        //                 exit;
        //             end;
        //         end;
        //     end;

        //     if KDSFunctions.HospCheckKDSConfirmNeeded(1, 'CONFIRM-ORDER', Format(STATE), StoreSetup."No.", REC) then
        //         exit;
        // end;

        // PosFunc.InsertTransInUseOnPos(REC."Receipt No.", POSSESSION.TerminalNo, true, false);

        // if REC."Entry Status" = REC."Entry Status"::InUse then begin
        //     REC."Entry Status" := REC."Entry Status"::" ";
        //     REC.Modify(true);
        // end;
        // SetGlobalSalesType;

        // InsertTmpTransaction(false);
        // ClearGlobs;
    end;

    procedure GetNextInQueuePressed()
    var
        TmpPOSTransQueue: Record "LSC POS Transaction";
        SalesTypeRec_l: Record "LSC Sales Type";
        HospType: Record "LSC Hospitality Type";
        NewPosLines: Record "LSC POS Trans. Line";
        BOUTils: Codeunit "LSC BO Utils";
        OrderNo: Code[20];
        CheckStaffTakeoverProfile: Boolean;
        IsHandled: Boolean;
        NoOrdersInQueueMsg: Label 'There are no orders in queue.';
        NextInQueueMsg: Label 'Next in Queue';
        CornfirmBeforeNextErr: Label 'Confirm the current transaction\before requesting the next one in line.';
        UniqueSaleForDriveThruErr: Label 'The transaction is in use by another terminal. You have to have a unique sales type per pos for drivethru.';
    begin
        NewPosLines.Reset;
        NewPosLines.SetRange("Receipt No.", REC."Receipt No.");
        if NewPosLines.FindFirst then begin
            PosTransactionGui.ErrorBeep(CornfirmBeforeNextErr);
            exit;
        end;
        if not REC."New Transaction" then begin
            if REC."Transaction Type" <> REC."Transaction Type"::Sales then begin
                PosTransactionGui.ErrorBeep(CornfirmBeforeNextErr);
                exit;
            end;
            REC."New Transaction" := true;
            REC."Transaction Type" := REC."Transaction Type"::Logoff;
            REC.Modify;
        end;

        TmpPOSTransQueue.Reset;
        TmpPOSTransQueue.SetCurrentKey("Store No.", "Sales Type", "Table No.", "Transaction Type", "Trans. Date", "Trans Time");
        TmpPOSTransQueue.SetRange("Store No.", POSSESSION.StoreNo);
        TmpPOSTransQueue.SetRange("Sales Type", GLobalSalesType);
        TmpPOSTransQueue.SetRange("Transaction Type", REC."Transaction Type"::Sales);
        TmpPOSTransQueue.SetFilter("Trans. Date", '<>%1', 0D);
        if TmpPOSTransQueue.FindFirst then begin
            OrderNo := TmpPOSTransQueue."Receipt No.";
            // if not PosFunc.InsertTransInUseOnPos(OrderNo, POSSESSION.TerminalNo, false, true) then begin
            //     PosTransactionGui.ErrorBeep(UniqueSaleForDriveThruErr);
            //     exit;
            // end;
            REC.Get(OrderNo);
            AfterGetRecord();
            REC."New Transaction" := false;
            StateTxt := Format(REC."Transaction Type");
            REC."Transaction Type" := REC."Transaction Type"::Sales;
            if REC."Sale Is Exchange Sale" then
                StateTxt := ExchangeLbl
            else
                if REC."Sale Is Return Sale" then
                    StateTxt := __StateREFUND;
            SetPOSState("LSC POS Transaction State"::SALES);
            POSTransactionEvents.OnBeforeSetFunctionModeGetNextInQueuePressed(PosFuncProfile, REC, IsHandled);
            // if not IsHandled then begin
            //     if (PosFuncProfile."Sales Person Mode" = PosFuncProfile."Sales Person Mode"::Automatic) and
            //        (REC."Sales Staff" = '')
            //     then
            //         SetFunctionMode("LSC POS Command"::SALESP)
            //     else
            //         SetFunctionMode("LSC POS Command"::ITEM);
            // end;
            CheckStaffTakeoverProfile := true;
            // if (REC."Staff ID" <> POSSESSION.StaffID) and (REC."Staff ID" <> '') then begin
            //     if BOUTils.IsHospitalityPermitted then begin
            //         if HospType.Get(POSSESSION.StoreNo, GlobalHospTypeSeq, GLobalSalesType) then begin
            //             CheckStaffTakeoverProfile := false;
            //             if POSSESSION.StaffHasMgrPriv then begin
            //                 if HospType."Manager Takeover in Trans." = HospType."Manager Takeover in Trans."::Always then begin
            //                     REC."Staff ID" := POSSESSION.StaffID;
            //                     PosFunc.ChangeStaff(REC);
            //                 end;
            //                 if HospType."Manager Takeover in Trans." = HospType."Manager Takeover in Trans."::"With Confirmation" then
            //                     if PosTransactionGui.PosConfirm(TakeOverTransQst, false) then begin
            //                         REC."Staff ID" := POSSESSION.StaffID;
            //                         PosFunc.ChangeStaff(REC);
            //                     end;
            //             end
            //             else begin
            //                 if HospType."Staff Takeover in Trans." = HospType."Staff Takeover in Trans."::Always then begin
            //                     REC."Staff ID" := POSSESSION.StaffID;
            //                     PosFunc.ChangeStaff(REC);
            //                 end;
            //                 if HospType."Staff Takeover in Trans." = HospType."Staff Takeover in Trans."::"With Confirmation" then
            //                     if PosTransactionGui.PosConfirm(TakeOverTransQst, false) then begin
            //                         REC."Staff ID" := POSSESSION.StaffID;
            //                         PosFunc.ChangeStaff(REC);
            //                     end;
            //             end;
            //         end;
            //     end;

            //     if CheckStaffTakeoverProfile then
            //         SetStaffID(POSSESSION.StaffID);
            // end;
            LinePriceGroup := REC."Price Group Code";
            if SalesTypeFilter then begin
                LineSalesType := GLobalSalesType;
                if SalesTypeRec_l.Get(GLobalSalesType) then
                    LinePriceGroup := SalesTypeRec_l."Price Group";
            end
            else begin
                if REC."Original Sales Type" <> '' then
                    LineSalesType := REC."Original Sales Type"   // price group same as header, trans. is pre-order
                else
                    LineSalesType := REC."Sales Type";
            end;

            InfoTextDescription := NextInQueueMsg;
        end else
            PosTransactionGui.PosMessage(NoOrdersInQueueMsg);

        SelectDefaultMenu;
    end;

    procedure DealPressed(DealCode: Code[20])
    var
        MealPlanMenu: Record "LSC Meal Plan Menu";
        FunctionSetup2: Record "LSC POS Command";
        MembershipCardTemp: Record "LSC Membership Card" temporary;
        MemberAttributeListTemp: Record "LSC Member Attribute List" temporary;
        BOUtil: Codeunit "LSC BO Utils";
        RetailPriceUtils: Codeunit "LSC Retail Price Utils";
        POSPriceUtility: Codeunit "LSC POS Price Utility";
        DealFunctions: Codeunit "LSC Deal Functions";
        FixedQty: Decimal;
        FromSelQty, IsHandled : Boolean;
        ErrorText: Text;
        DealsOnlyInWholeUnitsErr: Label 'Deals can only be sold in whole units';
    begin
        // POSTransactionEvents.OnBeforeDealPressed(DealCode, REC, DealPOSTransLine, Deal, tmpDealLines, IsHandled);
        // if IsHandled then
        //     exit;

        // CompressDealVariants := false;

        // if POSTransactionFunctions.SalePressedInPaymentState(STATE) then
        //     exit;

        // if STATE <> "LSC POS Transaction State"::TENDOP then begin
        //     //check of availabiltity
        //     tmpDealLines.DeleteAll;
        //     Deal.Get(DealCode);
        //     if Deal.Status = Deal.Status::Disabled then begin
        //         PosTransactionGui.ErrorBeep(StrSubstNo(DealInvalidErr, Deal.Description));
        //         exit;
        //     end;

        //     CompressDealVariants := (Deal."Quantity Handling" = Deal."Quantity Handling"::"Multiply Mod. Items w/Qty.");

        //     PriceGr := REC."Price Group Code";
        //     if BOUtil.IsHospitalityPermitted then
        //         if MealPlanMenu.Get(POSGUI.GetCurrMenu(0)) then begin
        //             if MealPlanMenu."Price Group Code" <> '' then
        //                 PriceGr := MealPlanMenu."Price Group Code";
        //         end;

        //     if REC."Member Card No." <> '' then begin
        //         if POSPriceUtility.ValidateOfferMemberInfo(REC, 1) then begin
        //             PosFunc.GetMemberShipCardInfo(MembershipCardTemp);
        //             PosFunc.GetMemberAttributeList(MemberAttributeListTemp);
        //             RetailPriceUtils.SetMemberInfo(MembershipCardTemp, MemberAttributeListTemp);
        //         end;
        //     end;

        //     if not (((Deal."Customer Disc. Group" = '') or (Deal."Customer Disc. Group" = REC."Customer Disc. Group")) and
        //             ((Deal."Currency Code" = '') or (Deal."Currency Code" = StoreSetup."Currency Code")) and
        //             RetailPriceUtils.OfferFiltersPassed(Deal, REC."Store No.", LineSalesType, PriceGr) and
        //             RetailPriceUtils.DiscValPerValid(Deal."Validation Period ID", Today, Time) and
        //             RetailPriceUtils.MemberFilterPassed(Deal."Member Type", Deal."Member Value") and
        //             RetailPriceUtils.MemberAttrFilterPassed(Deal."Member Attribute", Deal."Member Attribute Value"))
        //     then begin
        //         PosTransactionGui.ErrorBeep(StrSubstNo(DealInvalidErr, Deal.Description));
        //         exit;
        //     end;

        //     if not DealFunctions.CheckDealLinesOnDealPressed(Deal, REC, StoreSetup, LastItemNo, ErrorText) then begin
        //         PosTransactionGui.ErrorBeep(ErrorText);
        //         exit;
        //     end;

        //     DealNo := Deal."No.";
        //     FromSelQty := false;
        //     Deal.CalcFields("Deal Modifiers Exist");

        //     if (MultiplyWith - Round(MultiplyWith, 1) <> 0) then begin
        //         DealNo := '';
        //         PosTransactionGui.ErrorBeep(DealsOnlyInWholeUnitsErr);
        //         exit;
        //     end;

        //     if Evaluate(FixedQty, CurrInput) then begin
        //         if (FixedQty - Round(FixedQty, 1) <> 0) then begin
        //             DealNo := '';
        //             PosTransactionGui.ErrorBeep(DealsOnlyInWholeUnitsErr);
        //             exit;
        //         end;
        //         MultiplyWith := MultiplyWith * FixedQty;
        //     end;

        //     if (Deal."Deal Modifiers Exist") and
        //        (Deal."When Deal Pressed" = Deal."When Deal Pressed"::"Display Deal Modifiers")
        //     then begin
        //         FunctionSetup2.Get(Format("LSC POS Command"::POPUPDEALMOD));
        //         Clear(MenuLine2);

        //         PopulatePOSMenuLineForCodeunitRun(Format("LSC POS Command"::POPUPDEALMOD), Deal."No.", MenuLine2, LineRec, true, true);
        //         MenuLine2."Current-Price" := MultiplyWith;

        //         if not FromMobileQR then begin
        //             PopupPOSComm.Run(MenuLine2);
        //             if MenuLine2."Input Process" <> MenuLine2."Input Process"::" " then
        //                 exit;
        //         end;
        //         FromSelQty := true;
        //     end;
        //     ProcessDealPressed(FromSelQty);
        // end
        // else
        //     PosTransactionGui.ErrorBeep(ItemLinesNotAllowedInStateErr);
    end;

    procedure ProcessDealPressed(FromSelQty: Boolean)
    var
        MenuTypeRec: Record "LSC Restaurant Menu Type";
        HospType: Record "LSC Hospitality Type";
        SelectedQty: Record "LSC Selected Quantity";
        DealFunctions: Codeunit "LSC Deal Functions";
        CurrMenuTypeCode: Code[10];
        DealMsg: Label 'Deal';
    begin
        // DealPOSTransLine.SetRange("Receipt No.", REC."Receipt No.");
        // if not DealPOSTransLine.FindLast then
        //     FromLineNo := 9750
        // else
        //     FromLineNo := DealPOSTransLine."Line No." + 250;

        // DealPOSTransLine.Init;
        // DealPOSTransLine."Receipt No." := REC."Receipt No.";
        // DealPOSTransLine."Store No." := REC."Store No.";
        // DealPOSTransLine."POS Terminal No." := REC."POS Terminal No.";
        // DealPOSTransLine."Line No." := FromLineNo;
        // DealPOSTransLine."Entry Type" := DealPOSTransLine."Entry Type"::FreeText;
        // DealPOSTransLine."Text Type" := DealPOSTransLine."Text Type"::"Deal Header";

        // if Deal.Description = '' then
        //     DealPOSTransLine.Description := DealMsg + ' : ' + Deal."No."
        // else
        //     DealPOSTransLine.Description := Deal.Description;

        // DealPOSTransLine."Promotion No." := Deal."No.";
        // DealPOSTransLine."Deal Line" := true;
        // DealPOSTransLine."Price Group Code" := PriceGr;
        // DealPOSTransLine."Sales Type" := REC."Sales Type";
        // DealPOSTransLine."Guest/Seat No." := CurrGuest;
        // if CurrMenuType <> 0 then begin
        //     if MenuTypeRec.Get(REC."Store No.", CurrMenuType) then
        //         CurrMenuTypeCode := MenuTypeRec."Code on POS";
        // end;
        // DealPOSTransLine."Restaurant Menu Type" := CurrMenuType;
        // DealPOSTransLine."Restaurant Menu Type Code" := CurrMenuTypeCode;
        // if CurrMenuType = 0 then begin
        //     CurrMenuTypeDeal := 0;
        //     if HospType.Get(POSSESSION.StoreNo, GlobalHospTypeSeq, GLobalSalesType) then
        //         DefaultMenuType.GetDealDefaultMenuType(HospType, Deal."No.", DealPOSTransLine."Restaurant Menu Type", DealPOSTransLine."Restaurant Menu Type Code", CurrMenuTypeDeal, REC."Store No.");
        // end;

        // DealPOSTransLine.Validate(Quantity, MultiplyWith);
        // MultiplyWith := 1;

        // DealFunctions.GetTmpDealLinesOnProcessDealPressed(Deal, tmpDealLines, DealPOSTransLine, FromSelQty, POSSESSION.GetOriginalTerminalNo());

        // SelectedQty.Reset;
        // SelectedQty.SetRange(Type, SelectedQty.Type::"Menu Selection");
        // SelectedQty.SetRange("User Ref.", POSSESSION.GetOriginalTerminalNo);
        // SelectedQty.DeleteAll;

        // if tmpDealLines.FindFirst then
        //     InsertDealLines()
        // else begin
        //     DealNo := '';
        //     DealAddedPrice := 0;
        // end;
        // CalcTotals;
    end;

    procedure InsertDealLines()
    var
        POSPriceUtility: Codeunit "LSC POS Price Utility";
        MenuID: Code[20];
        Qty: Decimal;
    begin
        // if not tmpDealLines.FindFirst then begin
        //     if DealNo <> '' then begin
        //         DealPOSTransLine.Insert(true);
        //         if (NewLine."Guest/Seat No." <> 0) then
        //             // HospFunc.InsertOccupiedSeat(
        //             //   CurrTableNo, PosFuncProfile."Print Copy No. on Pre-Receipt", REC."Receipt No.", DealPOSTransLine."Guest/Seat No.");

        //         POSPriceUtility.RegisterDeal(DealPOSTransLine);
        //         OposUtil.DisplaySalesLine(DealPOSTransLine."Promotion No.", DealPOSTransLine.Description, DealPOSTransLine.Quantity,
        //                                   DealPOSTransLine.Price, DealPOSTransLine.Amount, DealPOSTransLine."Unit of Measure", PosFuncProfile."Compress When Scanned");
        //     end;
        //     DealNo := '';
        //     DealAddedPrice := 0;
        //     CalcTotals();
        //     exit;
        // end else
        //     if tmpDealLines.Type = tmpDealLines.Type::Item then begin
        //         DealLineDescription := tmpDealLines.Description;
        //         CurrInput := tmpDealLines."No.";
        //         Qty := tmpDealLines.Quantity;
        //         DealVariant := tmpDealLines."Variant Code";
        //         UOMSet := tmpDealLines."Unit of Measure";
        //         if (not CompressDealVariants) and (PosFunc.FindVariant(PosVariant, tmpDealLines."No.") > 1) then begin
        //             tmpDealLines.Quantity -= 1;
        //             Qty := 1;
        //             tmpDealLines.Modify;
        //             if tmpDealLines.Quantity = 0 then
        //                 tmpDealLines.Delete;
        //         end else
        //             tmpDealLines.Delete;
        //         MobileDealLineNo := 0;

        //         if tmpDealLines."Selected Modifier Line No." > 0 then begin
        //             DealModifierLineNo := tmpDealLines."Selected Modifier Line No.";
        //             DealLineNo := tmpDealLines."Selected Deal Line No.";
        //             DealAddedPrice := tmpDealLines."Line Added Amount";
        //         end
        //         else begin
        //             DealAddedPrice := 0;
        //             DealModifierLineNo := 0;
        //             DealLineNo := tmpDealLines."Line No.";
        //             MobileDealLineNo := tmpDealLines."Line No.";
        //         end;
        //         ItemLine(false, false, Qty, 0, '', '', '', '', 0, 0);
        //         DealLineDescription := '';
        //     end
        //     else begin
        //         DealAddedPrice := 0;
        //         MenuID := tmpDealLines."No.";
        //         tmpDealLines.Quantity -= 1;
        //         tmpDealLines.Modify;
        //         if tmpDealLines.Quantity = 0 then
        //             tmpDealLines.Delete;
        //         if not gCancelOffer then
        //             POSGUI.PopupMenu(MenuID);
        //     end;
    end;

    procedure CheckOpenDeals()
    var
        POSTransLine: Record "LSC POS Trans. Line";
        POSTransLine2: Record "LSC POS Trans. Line";
    begin
        POSTransLine.SetRange("Receipt No.", REC."Receipt No.");
        POSTransLine.SetRange("Entry Type", POSTransLine."Entry Type"::Item);
        POSTransLine.SetRange("Deal Line", true);
        if POSTransLine.FindSet then
            repeat
                if not POSTransLine2.Get(REC."Receipt No.", POSTransLine."Disc. Info Line No.") then begin
                    POSTransLine2 := POSTransLine;
                    POSTransLine2.Delete(true);
                end;
            until POSTransLine.Next = 0;
    end;

    procedure VoidDeal()
    var
        LinkedLine: Record "LSC POS Trans. Line";
        POSPriceUtility: Codeunit "LSC POS Price Utility";
        DealPricingFunctions: Codeunit "LSC Deal Pricing Functions";
    begin
        // if LineRec."Disc. Info Line No." <> 0 then begin
        //     VoidLinkedLines(LineRec."Line No.");
        //     POSPriceUtility.RegisterDeal(LineRec);
        // end
        // else begin
        //     DealPricingFunctions.Deal_UpdatePricingOnAfterVoid(REC, LineRec);

        //     LinkedLine.SetRange("Receipt No.", REC."Receipt No.");
        //     LinkedLine.SetRange("Disc. Info Line No.", LineRec."Line No.");
        //     if LinkedLine.FindSet then
        //         repeat
        //             LinkedLine.VoidLine;
        //             VoidLinkedLines(LinkedLine."Line No.");
        //         until LinkedLine.Next = 0;
        // end;
    end;

    procedure DealSwap(VoidLine: Boolean)
    var
        Deal_l: Record "LSC Offer";
        DealLines_l: Record "LSC Offer Line";
        FunctionSetup2: Record "LSC POS Command";
        MenuLine2_l: Record "LSC POS Menu Line";
        NoChangeModifiersOnDealErr: Label 'Changing modifiers is not possible on this deal.';
    begin
        if STATE <> STATE::TENDOP then begin
            POSLINES.GetCurrentLine(LineRec);
            if not LineRec."Deal Line" then begin
                PosTransactionGui.ErrorBeep(LineNotPartOfDealErr);
                exit;
            end;
            Deal_l.Get(LineRec."Promotion No.");
            if Deal_l.Status = Deal_l.Status::Disabled then begin
                PosTransactionGui.ErrorBeep(StrSubstNo(DealInvalidErr, Deal_l.Description));
                exit;
            end;
            Deal_l.CalcFields("Deal Modifiers Exist");
            if not Deal_l."Deal Modifiers Exist" then begin
                PosTransactionGui.ErrorBeep(NoChangeModifiersOnDealErr);
                exit;
            end;
            DealLines_l.Reset;
            DealLines_l.SetRange("Offer No.", Deal_l."No.");
            DealLines_l.SetRange(Type, DealLines_l.Type::"Deal Modifier");
            DealLines_l.SetRange("Show on Extra Request Only", false);
            if DealLines_l.IsEmpty then begin
                PosTransactionGui.ErrorBeep(NoChangeModifiersOnDealErr);
                exit;
            end;
            if VoidLine then begin
                if LineRec."Disc. Info Line No." = 0 then begin
                    PosTransactionGui.ErrorBeep(CannotChangeLineErr);
                    exit;
                end;
                if LineRec."Deal Modifier Line No." = 0 then begin
                    PosTransactionGui.ErrorBeep(CannotChangeLineErr);
                    exit;
                end;
                LineRec.VoidLine;
                VoidLinkedLines(LineRec."Line No.");
            end;

            if LineRec."Disc. Info Line No." <> 0 then
                LineRec.Get(LineRec."Receipt No.", LineRec."Disc. Info Line No.");

            FunctionSetup2.Get(Format("LSC POS Command"::DEALMODCHANGE));
            Clear(MenuLine2_l);

            PopulatePOSMenuLineForCodeunitRun(Format("LSC POS Command"::DEALMODCHANGE), Deal_l."No.", MenuLine2_l, LineRec, true, true);
            MenuLine2_l."Current-Price" := LineRec.Quantity;
            PopupPOSComm.Run(MenuLine2_l);
            if MenuLine2_l."Input Process" <> MenuLine2_l."Input Process"::" " then
                exit;
        end else
            PosTransactionGui.ErrorBeep(ItemLinesNotAllowedInStateErr);
    end;

    procedure ProcessChangedDeal(POSMenuLineIn: Record "LSC POS Menu Line")
    var
        CurrLine: Record "LSC POS Trans. Line";
        POSPriceUtility: Codeunit "LSC POS Price Utility";
        DealChangeCancelledErr: Label 'Deal change cancelled.';
        CancelledAddExtraErr: Label 'Adding extra items cancelled.';
    begin
        // if POSMenuLineIn."Current-INPUT" = '' then begin
        //     case POSMenuLineIn.Command of
        //         Format("LSC POS Command"::DEALMODCHANGE):
        //             PosTransactionGui.ErrorBeep(DealChangeCancelledErr);
        //         Format("LSC POS Command"::DEALMODADDEXTRA):
        //             PosTransactionGui.ErrorBeep(CancelledAddExtraErr);
        //     end;
        //     exit;
        // end;
        // POSPriceUtility.RegisterDeal(LineRec);

        // if CurrLine.Get(REC."Receipt No.", POSMenuLineIn."Current-LINE") then
        //     POSLINES.SetCurrentLine(CurrLine);
    end;

    procedure DealSwitchGroup(DealModTo: Code[20]; LineOnly: Boolean)
    var
        DealFunctions: Codeunit "LSC Deal Functions";
        ErrorText: Text;
    begin
        if STATE <> STATE::TENDOP then begin
            POSLINES.GetCurrentLine(LineRec);

            if not DealFunctions.DealSwitchGroup(REC, LineRec, DealModTo, LineOnly, ErrorText) then begin
                PosTransactionGui.ErrorBeep(ErrorText);
                exit;
            end;
        end else
            PosTransactionGui.ErrorBeep(ItemLinesNotAllowedInStateErr);
    end;

    procedure DealAddExtra()
    var
        Deal_l: Record "LSC Offer";
        DealLines_l: Record "LSC Offer Line";
        FunctionSetup2: Record "LSC POS Command";
        MenuLine2_l: Record "LSC POS Menu Line";
        NoAddExtraDeal: Label 'Adding Extra items to this deal is not possible.';
    begin
        if STATE <> STATE::TENDOP then begin
            POSLINES.GetCurrentLine(LineRec);
            if not LineRec."Deal Line" then begin
                PosTransactionGui.ErrorBeep(LineNotPartOfDealErr);
                exit;
            end;
            if LineRec."Disc. Info Line No." <> 0 then
                LineRec.Get(LineRec."Receipt No.", LineRec."Disc. Info Line No.");
            Deal_l.Get(LineRec."Promotion No.");
            if Deal_l.Status = Deal_l.Status::Disabled then begin
                PosTransactionGui.ErrorBeep(StrSubstNo(DealInvalidErr, Deal_l.Description));
                exit;
            end;
            Deal_l.CalcFields("Deal Modifiers Exist");
            if not Deal_l."Deal Modifiers Exist" then begin
                PosTransactionGui.ErrorBeep(NoAddExtraDeal);
                exit;
            end;
            DealLines_l.Reset;
            DealLines_l.SetRange("Offer No.", Deal_l."No.");
            DealLines_l.SetRange(Type, DealLines_l.Type::"Deal Modifier");
            DealLines_l.SetRange("Show on Extra Request Only", true);
            if DealLines_l.IsEmpty then begin
                PosTransactionGui.ErrorBeep(NoAddExtraDeal);
                exit;
            end;

            FunctionSetup2.Get(Format("LSC POS Command"::DEALMODADDEXTRA));
            Clear(MenuLine2_l);

            PopulatePOSMenuLineForCodeunitRun(Format("LSC POS Command"::DEALMODADDEXTRA), Deal_l."No.", MenuLine2_l, LineRec, true, true);
            MenuLine2_l."Current-Price" := LineRec.Quantity;

            PopupPOSComm.Run(MenuLine2_l);
            if MenuLine2_l."Input Process" <> MenuLine2_l."Input Process"::" " then
                exit;
        end else
            PosTransactionGui.ErrorBeep(ItemLinesNotAllowedInStateErr);
    end;

    procedure MealMenuInsertPressed(MealMenuCode: Code[10])
    var
        DayPlanLine: Record "LSC Day Plan Line";
        FixedQty: Decimal;
        NoPlansForTodaysMenu: Label 'No plan for the menu %1 found today.';
    begin
        FixedQty := 0;
        if Evaluate(FixedQty, CurrInput) then;
        DayPlanLine.Reset;
        DayPlanLine.SetRange("Menu Code", MealMenuCode);
        DayPlanLine.SetRange("Store No.", POSSESSION.StoreNo);
        DayPlanLine.SetRange(Date, Today);
        DayPlanLine.SetFilter(DayPlanLine."Recipe/Item No.", '<>%1', '');
        if DayPlanLine.FindSet then begin
            repeat
                CurrInput := DayPlanLine."Recipe/Item No.";
                MealPlanMenuFromButton := MealMenuCode;
                if CurrInput <> '' then
                    ItemLine(false, false, FixedQty, 0, '', '', '', '', 0, 0);
            until DayPlanLine.Next = 0;
        end else
            PosTransactionGui.ErrorBeep(StrSubstNo(NoPlansForTodaysMenu, MealMenuCode));
    end;

    procedure UseTransaction(NewTrans: Code[20]; UpdDisp: Boolean)
    var
        Diff: Boolean;
        IsHandled: Boolean;
    begin
        // PosFunc.InsertTransInUseOnPos(REC."Receipt No.", POSSESSION.TerminalNo, false, false);
        // if REC."Entry Status" = REC."Entry Status"::InUse then begin
        //     REC.Get(REC."Receipt No.");
        //     REC."Entry Status" := REC."Entry Status"::" ";
        //     REC.Modify;
        // end;
        // REC.Get(NewTrans);
        // AfterGetRecord();
        // REC."Staff ID" := POSSESSION.StaffID;
        // Diff := REC."POS Terminal No." <> POSSESSION.TerminalNo;
        // REC."POS Terminal No." := POSSESSION.TerminalNo;
        // REC."Entry Status" := REC."Entry Status"::InUse;
        // REC.Modify;

        // PosFunc.InsertTransInUseOnPos(REC."Receipt No.", POSSESSION.TerminalNo, true, true);

        // if Diff then begin
        //     LineRec.Reset;
        //     LineRec.SetRange("Receipt No.", REC."Receipt No.");
        //     if LineRec.FindSet then
        //         LineRec.ModifyAll("POS Terminal No.", POSSESSION.TerminalNo);
        // end;
        // Commit;

        // if UpdDisp then
        //     OposUtil.Display(PosTerminal."Customer Display Text 1", PosTerminal."Customer Display Text 2");

        // POSSESSION.RefreshMgrStatus;
        // RefreshTrainingStatus;
        // StateTxt := Format(REC."Transaction Type");

        // case REC."Transaction Type" of
        //     REC."Transaction Type"::Logoff,
        //     REC."Transaction Type"::Sales:
        //         begin
        //             REC."Transaction Type" := REC."Transaction Type"::Sales;
        //             if REC."Sale Is Exchange Sale" then
        //                 StateTxt := ExchangeLbl
        //             else
        //                 if REC."Sale Is Return Sale" then
        //                     StateTxt := 'REFUND';
        //             SetPOSState("LSC POS Transaction State"::SALES);
        //             POSTransactionEvents.OnBeforeSetFunctionModeUseTransaction(PosFuncProfile, REC, NewTrans, UpdDisp, IsHandled);
        //             if not IsHandled then
        //                 POSTransactionFunctions.HandleSalesPersonMode(REC, PosFuncProfile, "LSC POS Command"::ITEM);
        //         end;
        //     REC."Transaction Type"::"Tender Decl.",
        //     REC."Transaction Type"::"Float Entry",
        //     REC."Transaction Type"::"Remove Tender":
        //         begin
        //             SetPOSState("LSC POS Transaction State"::TENDOP);
        //             SetFunctionMode("LSC POS Command"::TENDOP);
        //         end;
        //     REC."Transaction Type"::NegAdj:
        //         begin
        //             POSGUI.SetSelectedMenu(POSSESSION.GetNegAdjMenu);
        //             SetPOSState("LSC POS Transaction State"::NEG_ADJ);
        //         end;
        //     REC."Transaction Type"::PhysInv:
        //         begin
        //             POSGUI.SetSelectedMenu(POSSESSION.GetPhysInvMenu);
        //             SetPOSState("LSC POS Transaction State"::PHYS_INV);
        //         end;
        // end;

        // ClearGlobs();
        // InfoTextDescription := REC.Comment;
        // SelectDefaultMenu;
    end;

    procedure SplitBillPressed()
    var
        HospType: Record "LSC Hospitality Type";
        TmpTrans: Record "LSC POS Transaction";
        TmpTransLine: Record "LSC POS Trans. Line";
        TmpTrans2: Record "LSC POS Transaction";
        KDSFunc: Codeunit "LSC KDS Functions";
        BOUtils: Codeunit "LSC BO Utils";
        Cnt: Integer;
        SplitCnt: Integer;
        CntTotalLines: Integer;
        TableMsg: Label 'Table %1';
        NoSplitBillLinesErr: Label 'No lines marked for bill split';
    begin
        // if (STATE = "LSC POS Transaction State"::TENDOP) or REC."New Transaction" then begin
        //     PosTransactionGui.MessageBeep('');
        //     exit;
        // end;

        // TmpTrans2.SetCurrentKey("Store No.", "Sales Type", "Table No.");
        // TmpTrans2.SetRange("Store No.", REC."Store No.");
        // TmpTrans2.SetRange("Sales Type", REC."Sales Type");
        // TmpTrans2.SetRange("Table No.", REC."Table No.");
        // TmpTrans2.SetRange("Transaction Type", REC."Transaction Type");

        // if TmpTrans2.FindLast then
        //     SplitCnt := TmpTrans2."Split Number" + 1
        // else
        //     SplitCnt := 1;

        // TmpTransLine.SetRange("Receipt No.", REC."Receipt No.");
        // CntTotalLines := TmpTransLine.Count;
        // TmpTransLine.SetRange(Marked, true);
        // Cnt := TmpTransLine.Count();

        // if Cnt <= 0 then begin
        //     PosTransactionGui.ErrorBeep(NoSplitBillLinesErr);
        //     exit;
        // end;
        // if CntTotalLines = Cnt then begin
        //     PosTransactionGui.ErrorBeep(SplitAllLinesError);
        //     exit;
        // end;
        // if KDSFunc.LinesRemainToBeSentToKitchen(TmpTrans2) then begin
        //     PosTransactionGui.ErrorBeep(NotSentToKitchenError);
        //     exit;
        // end;

        // SetErrorCheck;
        // TmpTrans.Get(REC."Receipt No.");
        // InsertTmpTransaction(true);
        // PosFunc.InsertTransInUseOnPos(REC."Receipt No.", POSSESSION.TerminalNo, false, true);

        // REC."Transaction Type" := REC."Transaction Type"::Sales;
        // REC."New Transaction" := false;

        // if CurrGuest <> 0 then
        //     REC."Split Number" := CurrGuest
        // else
        //     REC."Split Number" := SplitCnt;

        // REC.Comment := StrSubstNo(TableMsg, Format(CurrTableNo)) + '/' + Format(REC."Split Number");
        // REC.Modify();
        // Commit;

        // if BOUtils.IsHospitalityPermitted then begin
        //     if HospType.Get(POSSESSION.StoreNo, GlobalHospTypeSeq, GLobalSalesType) then begin
        //         KDSFunc.UpdateKDSOnTransSplit(
        //           TmpTrans, REC, true, 0, HospType."Dining Area ID", HospType."Dining Area ID", HospType."Service Flow ID", true, false);
        //     end;
        // end;

        // PosFunc.CopyMarkedLines(TmpTrans, REC, true, 0, true);
        // REC.Get(REC."Receipt No.");
        // POSLINES.SetFilterCover(0, GetReceiptNo);
        // ClearGlobs();
        // StartNewTransaction;
        // TotalPressed(false);
        // InfoTextDescription := REC.Comment;
    end;

    procedure MakeRepayTrans(): Boolean
    var
        POSTransPostingState: Record "LSC POS Trans. Posting State";
        SalesType: Record "LSC Sales Type";
        NewReceiptNo: Code[20];
        TotAmount: Decimal;
        LineNo: Integer;
        IsHandled: Boolean;
        RefundPrePayMsg: Label 'Refund of prepayment';
        RepayPrePayMsg: Label 'Repay prepayment to customer ?';
    begin
        //Generates repay transaction when voiding trans with prepayment
        if not tmpRepayPOSTrans.FindFirst then
            exit(false);

        NewReceiptNo := PosFunc.InsertTmpTrans(LastSlipNo, POSSESSION.WorkShiftNo, GLobalSalesType, CurrTableNo, TrainingActive, CurrTableDescr);
        REC.SetRange("Receipt No.", NewReceiptNo);
        REC.Get(NewReceiptNo);
        AfterGetRecord();
        REC.TransferFields(tmpRepayPOSTrans, false);
        POSTransactionEvents.OnBeforeMakeRepayTransModifyRec(REC);
        REC."Sale Is Return Sale" := true;
        REC.Modify;
        LineNo := 0;
        TotAmount := 0;
        LineRec.Init;
        if tmpRepayPOSTransLines.FindSet then
            repeat
                LineRec := tmpRepayPOSTransLines;
                LineRec."Receipt No." := REC."Receipt No.";
                LineNo += 10000;
                LineRec."Line No." := LineNo;
                LineRec.Amount := -LineRec.Amount;
                POSTransactionEvents.OnMakeRepayTransBeforeInsertLineRec(LineRec);
                LineRec.Insert;
                TotAmount -= LineRec.Amount;
            until tmpRepayPOSTransLines.Next = 0;

        tmpRepayPOSTrans.DeleteAll;
        tmpRepayPOSTransLines.DeleteAll;

        SalesType.Get(REC."Suspend Sales Type");
        if (SalesType."Voided Prepayment Account No." <> '') then begin
            POSTransactionEvents.OnMakeRepayTransBeforePosConfirm(SalesType, IsHandled);
            if not IsHandled then
                if not PosTransactionGui.PosConfirm(RepayPrePayMsg, false) then begin
                    LineRec.Init;
                    LineRec."Line No." := LineNo + 10000;
                    LineRec."Parent Line" := LineRec."Line No.";
                    LineRec."Store No." := REC."Store No.";
                    LineRec."POS Terminal No." := REC."POS Terminal No.";
                    LineRec."Entry Type" := LineRec."Entry Type"::IncomeExpense;
                    LineRec.Validate(Number, SalesType."Voided Prepayment Account No.");
                    LineRec.Validate(Amount, TotAmount);
                    LineRec.InsertLine;
                    CalcTotals();
                    POSSESSION.SetTransPostingSource(POSTransPostingState."Posting Source"::"Make Repay Trans");
                    PostTransaction(false);
                    exit(true);
                end;
        end;
        SetPOSState("LSC POS Transaction State"::PAYMENT);
        // SetFunctionMode("LSC POS Command"::PAYMENT);
        StateTxt := __StateREFUND;
        InfoTextDescription := RefundPrePayMsg;
        SelectDefaultMenu;
        CalcTotals();

        exit(true);
    end;

    procedure NewSalePressed()
    begin
        if REC."Table No." = 0 then
            if GLobalSalesType <> '' then begin
                InsertTmpTransaction(false);
                ClearGlobs;
            end;
    end;

    procedure ShowDrawerOpenWarning(DrawerRole: Text)
    var
        PostfixText: Text;
        IsHandled: Boolean;
        DrawerOpenMsg: Label 'Drawer open ...';
    begin
        // POSTransactionEvents.OnBeforeShowDrawerOpenWarning(IsHandled);
        // if IsHandled then
        //     exit;

        // PostfixText := '';
        // if DrawerRole <> '' then
        //     PostfixText := '\[' + DrawerRole + '] ';

        // InitDrawer(DrawerRole, '');
        // if (DrawerDevice.IsActive()) and (DrawerDevice."Drawer Open Text" <> '') then
        //     ScreenDisplay(DrawerDevice."Drawer Open Text" + PostfixText)
        // else
        //     ScreenDisplay(DrawerOpenMsg + PostfixText);
    end;

    procedure VariantPressed(VariantParm: Code[20])
    begin
        CurrInput := VariantParm;
        ValidateVariant();
    end;

    local procedure FindActiveOfferInStore(var OfferCode: Code[20]; var OfferType: Option Multibuy,"Mix&Match","Disc. Offer"; var TmpLine: Record "LSC POS Trans. Line") counter: Integer
    var
        PeriodicDiscount: Record "LSC Periodic Discount";
        PeriodicDiscountLines: Record "LSC Periodic Discount Line";
        Item_l: Record Item;
        Promotion: Record "LSC Offer";
        ItemSpecialGroup: Record "LSC Item/Special Group Link";
        PriceUtil: Codeunit "LSC Retail Price Utils";
        DummyDateFormula: DateFormula;
        LineNo: Integer;
        Found: Boolean;
    begin
        Item_l.Get(TmpLine.Number);
        counter := 0;

        if (TmpLine."Promotion No." <> '') and Promotion.Get(TmpLine."Promotion No.") then
            if Promotion."Block Periodic Discount" then
                exit;
        PeriodicDiscount.SetCurrentKey(Status);
        PeriodicDiscount.SetRange(Status, PeriodicDiscount.Status::Enabled);
        PeriodicDiscount.SetFilter("Currency Code", '%1|%2', StoreSetup."Currency Code", '');

        PeriodicDiscountLines.SetCurrentKey("Offer No.", Type, "No.", "Variant Code", "Unit of Measure", "Prod. Group Category");

        if TmpLine."Unit of Measure" = '' then
            TmpLine."Unit of Measure" := Item."Sales Unit of Measure";

        PeriodicDiscountLines.SetFilter("Unit of Measure", '%1|%2', TmpLine."Unit of Measure", '');
        if TmpLine."Variant Code" <> '' then
            PeriodicDiscountLines.SetFilter("Variant Code", '%1|%2', TmpLine."Variant Code", '')
        else
            PeriodicDiscountLines.SetRange("Variant Code", '');

        if PeriodicDiscount.FindSet then
            repeat
                if ((PeriodicDiscount."Customer Disc. Group" = '') or
                    (PeriodicDiscount."Customer Disc. Group" = REC."Customer Disc. Group")) and
                   ((PeriodicDiscount."Member Value" = '') or
                    (PeriodicDiscount."Member Value" = REC."Member Price Group"))
                then begin
                    Found := false;
                    PeriodicDiscountLines.SetRange("Offer No.", PeriodicDiscount."No.");
                    PeriodicDiscountLines.SetRange(Type, PeriodicDiscountLines.Type::Item);
                    PeriodicDiscountLines.SetRange("No.", Item_l."No.");
                    if PeriodicDiscountLines.FindLast then begin
                        if PriceUtil.PeriodDiscFiltersPassed(
                             PeriodicDiscount, StoreSetup."No.", TmpLine."Sales Type", TmpLine."Price Group Code") and
                           PriceUtil.DiscValPerValid(PeriodicDiscount."Validation Period ID", Today, Time)
                        then
                            Found := true;
                    end;

                    if (not Found) and (PeriodicDiscount.Type <> PeriodicDiscount.Type::Multibuy) then begin
                        PeriodicDiscountLines.SetRange(Type, PeriodicDiscountLines.Type::"Product Group");
                        PeriodicDiscountLines.SetRange("No.", Item_l."LSC Retail Product Code");
                        PeriodicDiscountLines.SetRange("Prod. Group Category", Item_l."Item Category Code");

                        Clear(DummyDateFormula);
                        PeriodicDiscountLines.SetRange("Line No.");
                        PeriodicDiscountLines.SetRange("Valid From Before Exp. Date");
                        LineNo := FindLineNoForExpDateOffer(PeriodicDiscountLines, TmpLine);
                        if LineNo <> 0 then
                            PeriodicDiscountLines.SetRange("Line No.", LineNo)
                        else
                            PeriodicDiscountLines.SetRange("Valid From Before Exp. Date", DummyDateFormula);

                        if PeriodicDiscountLines.FindFirst then begin
                            if PriceUtil.PeriodDiscFiltersPassed(
                                 PeriodicDiscount, StoreSetup."No.", TmpLine."Sales Type", TmpLine."Price Group Code") and
                               PriceUtil.DiscValPerValid(PeriodicDiscount."Validation Period ID", Today, Time)
                            then
                                Found := true;
                        end;
                        PeriodicDiscountLines.SetRange("Prod. Group Category");
                    end;

                    if (not Found) and (PeriodicDiscount.Type = PeriodicDiscount.Type::"Disc. Offer") then begin
                        PeriodicDiscountLines.SetRange(Type, PeriodicDiscountLines.Type::"Item Category");
                        PeriodicDiscountLines.SetRange("No.", Item_l."Item Category Code");
                        if PeriodicDiscountLines.FindFirst then begin
                            if PriceUtil.PeriodDiscFiltersPassed(
                                 PeriodicDiscount, StoreSetup."No.", TmpLine."Sales Type", TmpLine."Price Group Code") and
                               PriceUtil.DiscValPerValid(PeriodicDiscount."Validation Period ID", Today, Time)
                            then
                                Found := true;
                        end;
                    end;

                    if (not Found) and (PeriodicDiscount.Type = PeriodicDiscount.Type::"Mix&Match") then begin
                        PeriodicDiscountLines.SetRange(Type, PeriodicDiscountLines.Type::"Item Category");
                        PeriodicDiscountLines.SetRange("No.", Item."Item Category Code");
                        if PeriodicDiscountLines.FindFirst then begin
                            if PriceUtil.PeriodDiscFiltersPassed(
                                 PeriodicDiscount, StoreSetup."No.", TmpLine."Sales Type", TmpLine."Price Group Code") and
                               PriceUtil.DiscValPerValid(PeriodicDiscount."Validation Period ID", Today, Time) then
                                Found := true;
                        end;
                    end;

                    if (not Found) and (PeriodicDiscount.Type = PeriodicDiscount.Type::"Disc. Offer") then begin
                        PeriodicDiscountLines.SetRange(Type, PeriodicDiscountLines.Type::All);
                        PeriodicDiscountLines.SetRange("No.");
                        if PeriodicDiscountLines.FindFirst then begin
                            if PriceUtil.PeriodDiscFiltersPassed(
                                 PeriodicDiscount, StoreSetup."No.", TmpLine."Sales Type", TmpLine."Price Group Code") and
                               PriceUtil.DiscValPerValid(PeriodicDiscount."Validation Period ID", Today, Time) then
                                Found := true;
                        end;
                    end;

                    if (not Found) and (PeriodicDiscount.Type <> PeriodicDiscount.Type::Multibuy) then begin
                        Clear(ItemSpecialGroup);
                        ItemSpecialGroup.SetRange("Item No.", Item."No.");
                        if ItemSpecialGroup.FindSet then begin
                            repeat
                                PeriodicDiscountLines.SetRange(Type, PeriodicDiscountLines.Type::"Special Group");
                                PeriodicDiscountLines.SetRange("No.", ItemSpecialGroup."Special Group Code");
                                if PeriodicDiscountLines.FindFirst then begin
                                    if PriceUtil.PeriodDiscFiltersPassed(
                                       PeriodicDiscount, StoreSetup."No.", TmpLine."Sales Type", TmpLine."Price Group Code") and
                                      PriceUtil.DiscValPerValid(PeriodicDiscount."Validation Period ID", Today, Time)
                                    then
                                        Found := true;
                                end;
                            until (ItemSpecialGroup.Next = 0) or Found;
                        end;
                    end;
                    POSTransactionEvents.OnFindActiveOfferInStoreOnBeforeAddQtyDiscV2(PeriodicDiscountLines, PeriodicDiscount, TmpLine, PriceUtil, Found, StoreSetup, Item_l);
                    if Found then begin
                        Found := false;
                        counter += 1;
                        OfferCode := PeriodicDiscount."No.";
                        OfferType := PeriodicDiscount.Type;
                        if (counter = 1) and (PeriodicDiscount.Type = PeriodicDiscount.Type::"Disc. Offer") then begin
                            TmpLine.AddQtyDisc(1, PeriodicDiscountLines."Deal Price/Disc. %", OfferCode);
                            TmpLine.Validate("Item Disc. Group");
                        end;
                    end;
                end;
            until PeriodicDiscount.Next = 0;
    end;

    procedure TD_CommandPressed(EndOfDay: Boolean)
    var
        PosLookup: Record "LSC POS Lookup";
        PosTrans: Record "LSC POS Transaction";
        PosTransLine: Record "LSC POS Trans. Line";
        FormID: Code[10];
        ParamStr: Text[10];
        ErrorText: Text;
        LogOffOk, WarningOk, IsHandled : Boolean;
        TransServNoConnectionContinueQst: Label 'Transaction server could not be contacted. Amount information is limited to this POS Terminal only.\Continue?';
        TSConnFailedMsg: Label 'Connection to Transaction Server failed.\This can have influence on the %1 Function.';
    begin
        // POSTransactionEvents.OnBeforeTDCommandPressed(REC, EndOfDay, IsHandled);
        // if IsHandled then
        //     exit;

        // FormID := 'TD_DECLARE';
        // LogOffOk := false;
        // StoreSetup.TestField("Safe Mgnt. in Use");
        // ParamStr := CashMgm.CreateParamStr(EndOfDay, REC);
        // POSSESSION.SetValue("LSC POS Tag"::"TD_PARAM", ParamStr);

        // if not TSUtil.ReadStatementTransactions(false, ErrorText) then
        //     if (ErrorText <> '') then
        //         if not PosTransactionGui.PosConfirm(TransServNoConnectionContinueQst, false) then begin
        //             POSSESSION.SetValue("LSC POS Tag"::"TD_PARAM", '');
        //             exit;
        //         end;
        // Clear(PosTransLine);
        // PosTransLine.SetRange("Receipt No.", REC."Receipt No.");
        // if not PosTransLine.FindFirst then begin
        //     PosTransLine.Init;
        //     PosTransLine."Receipt No." := REC."Receipt No.";
        //     PosTransLine."Store No." := REC."Store No.";
        //     PosTransLine."POS Terminal No." := REC."POS Terminal No.";
        //     PosTransLine."Line No." := 10000;
        //     PosTransLine."Entry Type" := PosTransLine."Entry Type"::FreeText;
        //     PosTransLine."Text Type" := PosTransLine."Text Type"::"TD Text";
        //     PosTransLine.Description := Format(REC."Transaction Type");
        //     PosTransLine.Insert;
        // end;

        // PosLookup.Reset;
        // PosLookup.SetRange("Lookup ID", FormID);

        // if not PosLookup.FindLast then begin
        //     PosTransactionGui.MessageBeep('');
        //     TSSendUnsentTransactions;
        //     TSCheckError;
        //     POSSESSION.SetValue("LSC POS Tag"::"TD_PARAM", '');
        //     exit;
        // end;

        // WarningOk := false;
        // if TSUtil.UnsentTransactionsExist then begin
        //     if not PosFunc.UseBackgroundSession then
        //         TSUtil.SendUnsentTablesDD3(PosFuncProfile.TSTransResendLimit, true);
        //     if TSCheckError then begin
        //         if (StoreSetup."Statement Method" = StoreSetup."Statement Method"::Staff) and PosFuncProfile."TS POS Cash Mgt." then begin
        //             PosTransactionGui.PosMessage(StrSubstNo(TSConnFailedMsg, Format(REC."Transaction Type")));
        //             WarningOk := true;
        //         end;
        //     end;
        // end;

        // PosTrans := REC;
        // PosTrans."Staff ID" := POSSESSION.StaffID;

        // Commit;

        // SafeMgmtComm.SetFormID(FormID);
        // SafeMgmtComm.Init;
        // SafeMgmtComm.SetPosTransaction(PosTrans);
        // SafeMgmtComm.SetMgrKey(POSSESSION.MgrKey);
        // SafeMgmtComm.SetWarningOk(WarningOk);
        // SafeMgmtComm.CreateTenderDeclTable();
        // GlobalMenuLine."Current-RECEIPT" := REC."Receipt No.";
        // GlobalMenuLine."Profile ID" := POSSESSION.MenuProfileID();
        // SafeMgmtComm.Run(GlobalMenuLine);
    end;

    procedure TD_CommandPressedCallback(EndOfDay: Boolean)
    var
        Transaction: Record "LSC Transaction Header";
        PosCashDecl: Record "LSC POS Cash Declaration";
        TendDeclState: Code[20];
        LastReceiptNo: Code[20];
        LogOffOk: Boolean;
        LineWithAmount: Boolean;
        IsHandled: Boolean;
        NoSuspPOSTransactionsVoided: Integer;
    begin
        // TendDeclState := SafeMgmtComm.GetTenderDeclState;
        // LastReceiptNo := SafeMgmtComm.GetLastReceiptNo;
        // if TendDeclState = 'POSTED' then begin
        //     if StrLen(LastReceiptNo) > 9 then
        //         LastReceiptNo := DelStr(LastReceiptNo, 1, StrLen(LastReceiptNo) - 9);
        //     LastReceiptNo := DelChr(LastReceiptNo, '<', '0');
        //     if (LastReceiptNo <> '') and (LastReceiptNo <> LastSlipNo) then
        //         LastSlipNo := LastReceiptNo;

        //     SafeMgmtComm.GetLastTransaction(Transaction);
        //     POSTransactionEventsPub.OnAfterTDPressedPOSTEDState(Transaction);
        //     TSUtil.SendAtEndOfTransaction(Transaction);
        //     Commit;

        //     if REC."Start Float Entry" then
        //         InsertTmpTransaction(true)
        //     else
        //         InsertTmpTransaction(false);

        //     ClearGlobs();
        //     LogOffOk := EndOfDay;
        //     PickUpWarning(Transaction);
        // end;

        // if TendDeclState = 'CANCEL' then begin
        //     LineWithAmount := false;
        //     Clear(PosCashDecl);
        //     PosCashDecl.SetRange("Receipt No.", REC."Receipt No.");
        //     if PosCashDecl.FindSet then begin
        //         repeat
        //             if (PosCashDecl.Amount <> 0) or (PosCashDecl."Bank Amount" <> 0) then
        //                 LineWithAmount := true;
        //         until (PosCashDecl.Next = 0) or LineWithAmount;
        //     end;
        // end;
        // if TendDeclState = 'UNCOUNTED' then begin
        //     SafeMgmtComm.GetLastTransaction(Transaction);
        //     TSUtil.SendAtEndOfTransaction(Transaction);
        //     Commit;
        //     LogOffOk := true;
        // end;

        // TSSendUnsentTransactions;
        // TSCheckError;
        // POSSESSION.SetValue("LSC POS Tag"::"TD_PARAM", '');

        // if LogOffOk then begin

        //     if EndOfDay then begin
        //         // if PosFuncProfile."Z-Rep Autopr. after T.Dec EOD" then begin
        //         //     if POSTransPrint.IsPrinterActive() then
        //         //         PrintZReport(false, false)
        //         //     else
        //         //         if (PosFuncProfile."Z-Report Suspend Trans.Process" = PosFuncProfile."Z-Report Suspend Trans.Process"::"Delete older than") or (PosFuncProfile."Z-Report Suspend Trans.Process" = PosFuncProfile."Z-Report Suspend Trans.Process"::Delete) then
        //         //             ZReportSuspendProcess(NoSuspPOSTransactionsVoided);
        //         // end;
        //     end;

        //     POSTransactionEvents.OnBeforeTendDeclareLogOff(EndOfDay, IsHandled);
        //     if IsHandled then
        //         exit;

        //     POSGUI.PostCommand("LSC POS Command"::LOGOFF, '');

        //     POSTransactionEvents.OnAfterTendDeclareLogOff(EndOfDay);
        // end;
    end;

    procedure TD_TenderDeclEndOfDayPressed()
    var
        NoOfSuspTransVoided: Integer;
        NoOfUnpostedTrans: Integer;
        EODConfirmQst: Label 'Do you want to make End of Day declaration?';
    begin
        if STATE = "LSC POS Transaction State"::TENDOP then begin
            if REC."Transaction Type" <> REC."Transaction Type"::"Tender Decl." then begin
                PosTransactionGui.ErrorBeep(InvalidOperationErr + StrSubstNo(CompleteTransOrCancelMsg, REC."Transaction Type"));
                exit;
            end;
        end
        else begin
            if not POSSESSION.Permission("LSC POS Command"::TENDER_D, InfoTextDescription) then begin
                PosTransactionGui.ErrorBeep(InfoTextDescription);
                exit;
            end;
        end;

        StoreSetup.TestField("Safe Mgnt. in Use");
        if not TestNewTransaction then
            exit;

        POSTransactionEvents.OnBeforeTD_TenderDeclEndOfDayPressed(REC, GlobalMenuLine);

        if TrainingActive then begin
            OposUtil.Beeper;
            OposUtil.Beeper;
            PosTransactionGui.PosMessage(EndOfDayDeclNotAllowed);
            DoXYReportCheck := false;
            exit;
        end;

        if not PosTransactionGui.PosConfirm(EODConfirmQst, false) then
            exit;
        // NoOfUnpostedTrans := PosFunc.POSSalesTransExistInStore(StoreSetup."No.");
        if NoOfUnpostedTrans > 0 then
            if not PosTransactionGui.PosConfirm(StrSubstNo(UnpostedTransContinueQst, NoOfUnpostedTrans), false) then
                exit;

        if PosFuncProfile."Z-Report Suspend Trans.Process" = PosFuncProfile."Z-Report Suspend Trans.Process"::Block then
            if not (ZReportSuspendProcess(NoOfSuspTransVoided)) then
                exit;
        TenderDeclEndOfDay := true;
        if STATE <> "LSC POS Transaction State"::TENDOP then
            if TenderOp(REC."Transaction Type"::"Tender Decl.") then
                exit;
        TD_TenderDeclEndOfDayPressedEx;
    end;

    procedure TD_TenderDeclEndOfDayPressedEx()
    begin
        TD_CommandPressed(true);
    end;

    procedure TD_OpenDrawerPressed()
    begin
        if not POSSESSION.Permission("LSC POS Command"::OPEN_DR, InfoTextDescription) then begin
            PosTransactionGui.ErrorBeep(InfoTextDescription);
            exit;
        end;
        OposUtil.Display('', '');
        if not TrainingActive then begin
            OpenDrawer('');
            WaitDrawerClosed('');
        end;
    end;

    procedure TD_CancelPressed()
    var
        PosTransLine: Record "LSC POS Trans. Line";
        TenderDeclaration: Codeunit "LSC Tender Declaration";
    begin
        // if StoreSetup."Safe Mgnt. in Use" then
        //     TenderDeclaration.ClearTenderDeclTable(REC);
        // PosTransLine.Reset;
        // PosTransLine.SetRange("Receipt No.", REC."Receipt No.");
        // PosTransLine.DeleteAll(true);

        // if REC."Start Float Entry" then begin
        //     POSGUI.PostCommand("LSC POS Command"::LOGOFF, '');
        //     exit;
        // end;

        // REC."Transaction Type" := REC."Transaction Type"::Sales;
        // StartNewTransaction;
        // SetPOSState("LSC POS Transaction State"::SALES);
        // SetFunctionMode("LSC POS Command"::ITEM);

        // CancelPressed(true, 0);
    end;

    procedure TD_DuFloatEntry(): Boolean
    var
        PosTrans: Record "LSC POS Transaction";
        POSTransactionLoc: Record "LSC POS Transaction";
        BOUtils: Codeunit "LSC BO Utils";
    begin
        // if (BOUtils.IsHospitalityPermitted and (POSSESSION.GetValue("LSC POS Tag"::"RESTAURANT") <> '')) then
        //     exit(false);

        // if not StoreSetup."Safe Mgnt. in Use" then
        //     exit(false);
        // if PosTerminal."Exclude from Cash Mgnt." then
        //     exit(false);
        // if (StoreSetup."POS Start Amount Method" = StoreSetup."POS Start Amount Method"::Flexible) then
        //     exit(false);

        // PosTrans := REC;
        // PosTrans."Staff ID" := POSSESSION.StaffID;

        // TenderDeclOpenOnADiffPOS := false;
        // OtherPOS := '';
        // if StoreSetup."Statement Method" = StoreSetup."Statement Method"::Staff then begin
        //     POSTransactionLoc.Reset;
        //     POSTransactionLoc.SetRange("Transaction Type", POSTransactionLoc."Transaction Type"::"Float Entry");
        //     POSTransactionLoc.SetFilter("POS Terminal No.", '<>%1', REC."POS Terminal No.");
        //     POSTransactionLoc.SetRange("Staff ID", POSSESSION.StaffID);
        //     if POSTransactionLoc.FindFirst then begin
        //         TenderDeclOpenOnADiffPOS := true;
        //         OtherPOS := POSTransactionLoc."POS Terminal No.";
        //         exit(false);
        //     end;
        // end;
        // if CashMgm.DoFloatEntry(PosTrans) then begin
        //     GlobalMenuLine.Command := Format("LSC POS Command"::FLOAT_ENT);
        //     GlobalMenuLine.Parameter := '';
        // end;

        // exit(CashMgm.DoFloatEntry(PosTrans));
    end;

    procedure TD_MakeFloatEntry()
    var
        MenLine: Record "LSC POS Menu Line";
    begin
        // REC."Transaction Type" := REC."Transaction Type"::"Float Entry";
        // REC."Start Float Entry" := true;
        // StartNewTransaction;
        // SetPOSState("LSC POS Transaction State"::TENDOP);
        // SetFunctionMode("LSC POS Command"::TENDOP);
        // Clear(MenLine);
        // TD_CommandPressed(false);
    end;

    procedure UpdateLineInfo()
    begin
        POSLINES.GetCurrentLine(LineRec);
        InfoTextDescription := LineRec.Description;
        InfoTextDescription2 := '';
        if (LineRec.Number <> '') and (LineRec."Variant Code" <> '') then
            if PosVariant.Get(LineRec.Number, LineRec."Variant Code") then
                InfoTextDescription2 := PosVariant."Description 2";
    end;

    procedure AskForSuggestedQty(SuggestedQty: Decimal)
    begin
        // SetFunctionMode("LSC POS Command"::QUANTITY);
        // PosTransactionGui.OpenNumericKeyboard(QtyMsg, Format(SuggestedQty), "LSC POS Trans. Numpad Trigger"::AskForSuggestedQty);
    end;

    procedure ChangeUnitOfMeasurePressed(MenuLine: Record "LSC POS Menu Line")
    var
        PosComm: Record "LSC POS Command";
        PosPanel: Record "LSC POS Panel";
        lItem: Record Item;
        MenuLineValue: Text[30];
        UOMCode: Code[10];
        ModifyUOM: Boolean;
        AllExcluded: Boolean;
        UOMNoChangeForDealErr: Label 'Unit of Measure cannot be changed for Deal Line';
        UOMNoPopupErr: Label '\All unit of measures are excluded from Pop-up on POS';
    begin
        Clear(LineRec);
        POSLINES.GetCurrentLine(LineRec);

        if LineRec.Number = '' then begin
            PosTransactionGui.PosMessage(CannotChangeLineErr);
            exit;
        end;

        if LineRec."Scale Item" then begin
            PosTransactionGui.ErrorBeep(StrSubstNo(UOMCHNotAllowed, LineRec.FieldCaption("Unit of Measure"), LineRec.FieldCaption("Scale Item")));
            exit;
        end;

        if LineRec."Deal Line" and not MenuLine."From Post Command" then begin
            PosTransactionGui.ErrorBeep(UOMNoChangeForDealErr);
            exit;
        end;

        POSTransactionEvents.OnBeforeChangeUnitOfMeasure(REC, LineRec, CurrInput);

        MenuLineValue := MenuLine.Parameter;
        ModifyUOM := false;

        UOMCode := CopyStr(CurrInput, 1, 10);
        if MenuLineValue <> '' then
            UOMCode := MenuLineValue
        else begin
            if PosComm.Get('POPUPUOM') then begin
                if POSSESSION.GetPosPanelRec(PosComm."POS Panel ID", PosPanel) then begin
                    lItem.Get(LineRec.Number);
                    if IsUOMPopUp(lItem, AllExcluded) then begin
                        if AllExcluded then begin
                            PosTransactionGui.ErrorBeep(StrSubstNo('%1 %2', LineRec.Number, LineRec.Description) + UOMNoPopupErr);
                            exit;
                        end else
                            UOMPopUp(LineRec);
                        exit;
                    end;
                end;
            end;
        end;

        ChangeUnitOfMeasurePressedEx(UOMCode);
    end;

    procedure ChangeUnitOfMeasurePressedEx(UOMCode: Code[10])
    var
        ItemUOM: Record "Item Unit of Measure";
        lItem: Record Item;
        UOM: Record "Unit of Measure";
        DT: Record "LSC POS Trans. Per. Disc. Type";
        OfferPosCalc: Record "LSC Offer Pos Calculation";
        PosPriceUtil: Codeunit "LSC POS Price Utility";
        PromNo: Code[20];
        QtyTmp: Decimal;
        ModifyUOM: Boolean;
        UOMChangedMsg: Label 'Unit of Measure changed to %1';
    begin
        Clear(LineRec);
        POSLINES.GetCurrentLine(LineRec);
        if (UOMCode = '') then begin
            lItem.Get(LineRec.Number);
            UOMCode := LineRec."Unit of Measure";
            // ProductExt.FilterOnValidUOMPricesInStore(ItemUOM, lItem."No.", POSSESSION.StoreNo, LineRec."Variant Code");
            if (UOMCode <> '') then
                ItemUOM.SetFilter(Code, '>%1', UOMCode);
            if not ItemUOM.FindFirst then begin
                ItemUOM.SetRange(Code);
                if not ItemUOM.FindFirst then begin
                    PosTransactionGui.ErrorBeep(StrSubstNo(UOMNotAvailableForItemErr, '', LineRec.Number));
                    exit;
                end;
            end;
            UOMCode := ItemUOM.Code;
            ModifyUOM := true;
            if (UOMCode = LineRec."Unit of Measure") then
                exit;
        end;

        if (UOMCode <> '') and not UOM.Get(UOMCode) then begin
            PosTransactionGui.ErrorBeep(InvalidUOMErr);
            exit;
        end;

        if not ItemUOM.Get(LineRec.Number, UOMCode) then begin
            PosTransactionGui.ErrorBeep(StrSubstNo(UOMNotAvailableForItemErr, UOMCode, LineRec.Number));
            exit;
        end;

        if (ItemUOM.Code <> LineRec."Unit of Measure") then
            ModifyUOM := true;

        QtyTmp := LineRec.Quantity;
        LineRec.Get(LineRec."Receipt No.", LineRec."Line No.");
        PromNo := LineRec."Promotion No.";

        if ModifyUOM then begin
            LineRec.Validate(Quantity, 0);
            LineRec."Entry Status" := 0;
            LineRec."Discount %" := 0;
            LineRec."Discount Amount" := 0;
            LineRec."Disc. Info Line No." := 0;
            LineRec."Discount Triggered" := false;
            LineRec."Quantity Discounted" := 0;
            PosPriceUtil.InsertTransDiscPercent(LineRec, 0, DT.DiscType::"Periodic Disc.", '');
            LineRec."Promotion No." := '';
            LineRec."Mix & Match Line No." := 0;
            PosPriceUtil.InsertTransDiscAmount(LineRec, 0, DT.DiscType::"Periodic Disc.", '');
            Clear(OfferPosCalc);
            OfferPosCalc.SetRange("Receipt No.", LineRec."Receipt No.");
            OfferPosCalc.SetRange("Trans. Line No.", LineRec."Line No.");
            OfferPosCalc.DeleteAll;
            PosFunc.ClearPosTransLineOffers(LineRec);
        end;

        LineRec."Unit of Measure" := UOMCode;
        PosPriceUtil.CalcPrice(LineRec, true);

        if LineRec."Deal Line" and (PromNo <> '') then
            LineRec."Promotion No." := PromNo;

        LineRec.Validate(Quantity, QtyTmp);
        LineRec.Modify(true);
        WriteMgrStatus;
        PosFunc.RecalcSlip(REC);
        REC.Modify;
        Commit;
        CalcTotals;
        DisplayTotals;
        CurrInput := '';

        POSTransactionEvents.OnAfterChangeUnitOfMeasure(REC, LineRec, CurrInput);

        InfoTextDescription := StrSubstNo('%1 %2', LineRec.Number, LineRec.Description);
        InfoTextDescription2 := StrSubstNo(UOMChangedMsg, UOMCode);

        OposUtil.DisplaySalesLine('', LineRec.Description, LineRec.Quantity, LineRec.Price, LineRec.Amount, LineRec."Unit of Measure", true);
    end;

    procedure PickUpWarning(TransHeader: Record "LSC Transaction Header")
    var
        BOUtils: Codeunit "LSC BO Utils";
        PickWarningText: Text[50];
        DescLen: Integer;
        WarnLen: Integer;
        PickupWarningMsg: Label 'PW';
    begin
        if (BOUtils.IsHospitalityPermitted and (POSSESSION.GetValue("LSC POS Tag"::"RESTAURANT") <> '')) then
            exit;

        // PickWarningText := CashMgm.CalcPickUpWarning(TransHeader);
        if (PickWarningText = '') then
            exit;

        if (InfoTextDescription2 <> '') then begin
            DescLen := StrLen(InfoTextDescription);
            WarnLen := StrLen(PickWarningText);
            if ((DescLen + WarnLen + 2) < 80) then begin
                InfoTextDescription2 := InfoTextDescription2 + '. ' + PickWarningText;
            end
            else begin
                if ((DescLen + StrLen(PickupWarningMsg) + 2) < 80) then
                    InfoTextDescription2 := InfoTextDescription2 + '. ' + PickupWarningMsg;
            end;
        end
        else begin
            InfoTextDescription2 := PickWarningText;
        end;
    end;

    procedure UpdateInputDevicesState(var pFunctionSetup: Record "LSC POS Command"; pUsePostActions: Boolean)
    begin
        // if pUsePostActions then begin
        //     case pFunctionSetup."Scanner Action 2" of
        //         pFunctionSetup."Scanner Action 2"::Disable:
        //             OposUtil.DisableScanner();
        //         pFunctionSetup."Scanner Action 2"::Enable:
        //             OposUtil.EnableScanner();
        //     end;
        //     case pFunctionSetup."MSR Action 2" of
        //         pFunctionSetup."MSR Action 2"::Disable:
        //             OposUtil.DisableMSR();
        //         pFunctionSetup."MSR Action 2"::Enable:
        //             OposUtil.EnableMSR();
        //     end;
        // end else begin
        //     case pFunctionSetup."Scanner Action" of
        //         pFunctionSetup."Scanner Action"::Disable:
        //             OposUtil.DisableScanner();
        //         pFunctionSetup."Scanner Action"::Enable:
        //             OposUtil.EnableScanner();
        //     end;
        //     case pFunctionSetup."MSR Action" of
        //         pFunctionSetup."MSR Action"::Disable:
        //             OposUtil.DisableMSR();
        //         pFunctionSetup."MSR Action"::Enable:
        //             OposUtil.EnableMSR();
        //     end;
        // end;
        // POSTransactionEvents.OnAfterUpdateInputDevicesState(pFunctionSetup, pUsePostActions, REC, Format(STATE));
    end;

    procedure CommitPaymentLine()
    var
        EmptyCardEntry: Record "LSC POS Card Entry";
    begin
        CommitPaymentLine(EmptyCardEntry);
    end;

    procedure CommitPaymentLine(var pCardEntry: Record "LSC POS Card Entry")
    var
        POSTransPostingState: Record "LSC POS Trans. Posting State";
    begin
        if pCardEntry."Authorisation Ok" then begin
            //NewLine."Card/Customer/Coup.Item No" := PosFunc.PadCardNo(pCardEntry.GetCardNo);
            NewLine."Card Entry No." := pCardEntry."Entry No.";
            NewLine."Card Type" := pCardEntry."Card Type";
        end;
        NewLine.Modify(true);

        if ProcessTenderOffers then begin
            ProcessTenderOffers := false;
            CardType := '';
            //PosOfferExt.ProcessTenderTypeOffer(REC);
        end;
        Commit;
        POSTransactionEvents.OnAfterCommitPaymentLine(REC, LineRec, TenderType.Code);

        LineRec := NewLine;
        POSLINES.SetCurrentLine(LineRec);
        WriteMgrStatus;
        CalcTotals;
        CurrInput := '';
        Clear(Currency);
        AmountInCurrency := 0;
        CustomerOrCardNo := '';
        InfoTextDescription := StrSubstNo('%1 %2', NewLine.Description, FormatAmount(NewLine.Amount));
        InfoTextDescription2 := '';
        MultiplyWith := 1;
        UOMSet := '';
        if STATE <> "LSC POS Transaction State"::TENDOP then begin
            if not ChangeTender then
                DisplayTotals;
            POSSESSION.SetTransPostingSource(POSTransPostingState."Posting Source"::"Commit Payment");
            if CheckInfoCode(Format("LSC POS Transaction State"::PAYMENT)) then
                exit;
            CommitPaymentLineEx;
        end;
    end;

    procedure CommitPaymentLineEx()
    begin
        if TenderType."Do Not Post" then begin
            REC."Credit Card Hold" := true;
            REC.Modify;
            CalcTotals;
            SetPOSState("LSC POS Transaction State"::PAYMENT);
            // SetFunctionMode("LSC POS Command"::PAYMENT);
        end else begin
            TransactionTendered;
        end;
    end;

    procedure SetPOSState(pState: Enum "LSC POS Transaction State")
    begin
        SetPOSState(Format(pState));
    end;

    procedure GetPOSStateEnum(pState: Code[10]) PosTransactionStateEnum: Enum "LSC POS Transaction State";
    var
        Idx: Integer;
    begin
        if Format(PosTransactionStateEnum).Trim() = '' then
            exit;
        Idx := PosTransactionStateEnum.Names.IndexOf(pState);
        if Idx <= 0 then
            exit;
        PosTransactionStateEnum := Enum::"LSC Pos Transaction State".FromInteger(PosTransactionStateEnum.Ordinals.Get(Idx));
    end;

    procedure SetPOSState(pSTATE: Code[10])
    var
        tmpRecord: Record "LSC POS Trans. Line";
    begin
        // if (STATE = "LSC POS Transaction State"::SALES) and (pSTATE <> Format("LSC POS Transaction State"::SALES)) then begin
        //     POSSESSION.UpdatePosPicture(tmpRecord);
        // end;

        // STATE := GetPOSStateEnum(pSTATE);
        // PosFunc.SetPaymentState(STATE = "LSC POS Transaction State"::PAYMENT);
        // _Initialized := pState <> ''; // SetPOSState(''), e.g. in PosTransaction.Close on Logoff
        // if (LAST_STATE <> STATE) or (Format(STATE) <> pSTATE) then
        //     POSTransactionEvents.OnStateChanged(REC, Format(LAST_STATE), pSTATE)
        // else // fixing '' pSTATE can not be stored in LAST_STATE
        //     if (not LAST_STATE_WAS_NOT_EMPTY and _Initialized) then
        //         POSTransactionEvents.OnStateChanged(REC, '', pSTATE);
        // LAST_STATE_WAS_NOT_EMPTY := pState <> '';
        // LAST_STATE := STATE;
    end;

    procedure ScreenDisplay(pText: Text[250])
    begin
        POSGUI.ScreenDisplay(pText);
    end;

    procedure CloseForm()
    begin
        POSTransactionEvents.OnBeforeCloseForm(REC, LineRec, CurrInput);
        POSSESSION.ClearManagerID;
        POSGUI.ScreenDisplay('');
        ClosePosFlag := true;

        Clear(FunctionSetup);
    end;

    procedure CheckNextItemInQueue()
    var
        OfferPosCalc: Record "LSC Offer Pos Calculation";
        CurrVarCode: Code[10];
        FixMixMatch: Code[20];
        OrgFromInfocode: Code[20];
        OrgFromSubcode: Code[20];
        OrgSelQty: Decimal;
        QtySet: Decimal;
        ParLine: Integer;
        OrgFromEntryNo: Integer;
        PriceSet: Boolean;
    begin
        CurrVarCode := '';

        TmpSelQty.Reset;
        TmpSelQty.SetRange(Type, TmpSelQty.Type::Selection);
        TmpSelQty.SetRange("User Ref.", POSSESSION.GetOriginalTerminalNo);
        if TmpSelQty.FindFirst then begin
            PriceSet := TmpSelQty."Set Price";
            QtySet := TmpSelQty."Qty.";
            ParLine := TmpSelQty."Link to Parent Line No.";
            KeyboardPrice := TmpSelQty."New Price";
            if (KeyboardPrice = 0) and PriceSet then
                ExternalZeroPrice := true;

            UOMSet := TmpSelQty."Unit of Measure";
            CurrVarCode := TmpSelQty."Variant Code";

            if TmpSelQty."Item No. Length" > 0 then begin
                CurrInput := CopyStr(TmpSelQty."Item No.", 1, TmpSelQty."Item No. Length");
                if SerialNo <> '' then begin
                    if TmpSelQty."Serial No. Is Lot No." then
                        LotNo := TmpSelQty."Serial No."
                    else
                        SerialNo := TmpSelQty."Serial No.";
                    PreSetSerialLotNo := true;
                end;
            end else
                CurrInput := TmpSelQty."Item No.";

            OrgFromInfocode := TmpSelQty."From Infocode";
            OrgFromSubcode := TmpSelQty."From Subcode";
            OrgFromEntryNo := TmpSelQty."Infoc. Entry Line No.";
            OrgSelQty := TmpSelQty."Infocode Selected Qty.";

            Clear(FixMixMatch);
            if TmpSelQty."Fixed Mix&Match" then
                FixMixMatch := TmpSelQty."Selection Code";

            TmpSelQty.Delete;
            LinkedItemsActive := false;
            BomLineEntry := false;
            // SetFunctionMode("LSC POS Command"::ITEM);
            ItemLine(
              false, PriceSet, QtySet, ParLine, CurrVarCode, FixMixMatch,
              OrgFromInfocode, OrgFromSubcode, OrgFromEntryNo, OrgSelQty);

            if LineRec."System-Unchangable Offer" then begin
                Clear(OfferPosCalc);
                OfferPosCalc.SetRange("Receipt No.", LineRec."Receipt No.");
                OfferPosCalc.SetRange("Trans. Line No.", LineRec."Line No.");
                OfferPosCalc.SetFilter("Group No.", '<>%1', FixMixMatch);
                OfferPosCalc.DeleteAll;
                PosFunc.ClearPosTransLineOffers(LineRec);
            end;
        end;
    end;

    procedure CheckDiscountOffers(var pPOSTransLine: Record "LSC POS Trans. Line"): Boolean
    begin
        // exit(PopupPOSComm.CheckDiscountOffers(pPOSTransLine));
    end;

    procedure CheckDiscountOffersEx()
    var
        SelectQty: Record "LSC Selected Quantity";
        ItemCounter: Integer;
    begin
        SelectQty.SetRange(Type, SelectQty.Type::"Menu Selection");
        SelectQty.SetRange("User Ref.", POSSESSION.GetOriginalTerminalNo);
        ItemCounter := 1;
        if SelectQty.FindSet then begin
            repeat
                if SelectQty."Qty." <> 0 then begin
                    TmpSelQty.Type := 0;
                    TmpSelQty."User Ref." := SelectQty."User Ref.";
                    TmpSelQty."Item No." := SelectQty."Selected Subcode" + Format(ItemCounter);
                    TmpSelQty."Item No. Length" := StrLen(SelectQty."Selected Subcode");
                    TmpSelQty."Qty." := SelectQty."Qty.";
                    TmpSelQty."Selection Code" := SelectQty."Selection Code";
                    TmpSelQty."Fixed Mix&Match" := SelectQty."Fixed Mix&Match";
                    TmpSelQty."Variant Code" := SelectQty."Variant Code";
                    TmpSelQty."Unit of Measure" := SelectQty."Unit of Measure";

                    if TmpSelQty.Insert then
                        ItemCounter += 1;
                end;
            until SelectQty.Next = 0;
        end;
        SelectQty.DeleteAll(true);
        CheckNextItemInQueue;
    end;

    procedure InfocodeRequestOnLine(Requested: Option AutoOnly,All,RequestOnly)
    var
        KDSFunctions: Codeunit "LSC KDS Functions";
        QtyNotPrinted: Decimal;
        Handled: Boolean;
        NoRequestInfocodeForVoidedMsg: Label 'You cannot request infocodes for a voided line.';
        OnlyRequestInfocodeForItemsMsg: Label 'You can only request infocodes for items.';
        ItemHasNoInfoCodeMsg: Label 'The selected item does not have any infocodes.';
    begin
        //POSTransactionEventsPub.OnBeforeInfocodeRequestOnLine(InfoUtil, Requested, LineRec, Handled);
        if Handled then
            exit;

        Clear(Info);
        POSLINES.GetCurrentLine(LineRec);

        if (LineRec."Entry Type" <> LineRec."Entry Type"::Item) or (LineRec.Number = '') then begin
            PosTransactionGui.MessageBeep(OnlyRequestInfocodeForItemsMsg);
            exit;
        end;

        if (LineRec."Entry Status" = LineRec."Entry Status"::Voided) then begin
            PosTransactionGui.MessageBeep(NoRequestInfocodeForVoidedMsg);
            exit;
        end;

        if KDSFunctions.TransLineSentToKitchen(REC, LineRec, QtyNotPrinted) then begin
            PosTransactionGui.MessageBeep(ChangeOnSentLineError);
            exit;
        end;

        if not InfoUtil.InfoCodeRequired('ITEM', LineRec.Number, '') then begin
            if LineRec."Parent Line" <> LineRec."Line No." then begin
                LineRec.Get(LineRec."Receipt No.", LineRec."Parent Line");
                if not InfoUtil.InfoCodeRequired('ITEM', LineRec.Number, '') then begin
                    PosTransactionGui.MessageBeep(ItemHasNoInfoCodeMsg);
                    exit;
                end;
            end
            else begin
                PosTransactionGui.MessageBeep(ItemHasNoInfoCodeMsg);
                exit;
            end;
        end;

        LastCanceled := false;
        InfoFunction := 'ITEM';
        StartFunction := FunctionSetup."Function Code";
        ProcessInfoCode('', false, Requested, false);
    end;

    procedure SetInputPrompt(var prompt: Text[30])
    begin
        FunctionSetup.Prompt := prompt;
        POSSESSION.SetValue("LSC POS Tag"::"InputPrompt", prompt);
    end;

    procedure ValidateSerialLotInput()
    var
        ErrorText: Text[250];
    begin
        if FunctionSetup."Function Code" = Format("LSC POS Command"::SERIALNO) then begin
            SerialNo := CopyStr(CurrInput, 1, 50);
            if not ValidateSerialNo(ErrorText) then begin
                PosTransactionGui.ErrorBeep(ErrorText, false);
                exit;
            end;
        end;

        if FunctionSetup."Function Code" = Format("LSC POS Command"::LOTNO) then begin
            LotNo := CopyStr(CurrInput, 1, 50);
            if not ValidateLotNo(ErrorText) then begin
                PosTransactionGui.ErrorBeep(ErrorText);
                exit;
            end;
        end;

        NextItemPhase;
    end;

    procedure POSInfo(MenuLine: Record "LSC POS Menu Line")
    var
        //CurrLine: Record "LSC POS Trans. Line";
        //PosTransInfoMgt: Codeunit "LSC POS InfoData Mgt.";
        ErrorStr: Text[50];
    begin
        // POSLINES.GetCurrentLine(CurrLine);
        // MenuLine."Current-RECEIPT" := REC."Receipt No.";
        // MenuLine."Current-LINE" := CurrLine."Line No.";

        // if not PosTransInfoMgt.RunPOSInfo(CurrLine, MenuLine, ErrorStr) then
        //     PosTransactionGui.ErrorBeep(ErrorStr);

        // POSLINES.UpdateAll;
    end;

    procedure POSZoom(MenuLine: Record "LSC POS Menu Line")
    // /* var
    //     // CurrLine: Record "LSC POS Trans. Line";
    //     PosZoomMgt: Codeunit "LSC POS Zoom Mgt."; */
    begin
        // POSLINES.GetCurrentLine(CurrLine);

        // if CurrLine."Line No." = 0 then
        //     exit;

        // MenuLine."Current-RECEIPT" := REC."Receipt No.";
        // MenuLine."Current-LINE" := CurrLine."Line No.";
        // PosZoomMgt.Zoom(MenuLine);
    end;

    procedure PrepaymentAmountTendered(): Boolean
    begin
        exit(REC.Payment >= REC.Prepayment);
    end;

    procedure VoidPrepaymentPressed()
    // var
    //     PosPrepaymentUtil: Codeunit "LSC POS Prepayment Mgt.";
    begin
        // if not POSSESSION.Permission("LSC POS Command"::VOIDPP, InfoTextDescription) then begin
        //     PosTransactionGui.ErrorBeep(InfoTextDescription);
        //     exit;
        // end;

        // POSTransactionEvents.OnBeforeVoidPrepayment(REC);

        // WriteMgrStatus;
        // PosPrepaymentUtil.VoidPrepayment(REC."Receipt No.");
        // POSTransactionEvents.OnAfterVoidPrepayment(REC);
    end;

    procedure VoidPrepaymentLinePressed()
    // var
    //     PosPrepaymentUtil: Codeunit "LSC POS Prepayment Mgt.";
    //     PrePaymVoidedMsg: Label 'Prepayment amount voided';
    begin
        // LineRec.Reset;
        // LineRec.SetRange("Receipt No.", REC."Receipt No.");
        // LineRec.SetRange(LineRec."Entry Status", 0);

        // if not LineRec.FindFirst then begin
        //     LineRec.SetRange(LineRec."Entry Status");
        //     PosTransactionGui.MessageBeep('');
        //     exit;
        // end;

        // LineRec.SetRange(LineRec."Entry Status");

        // if not POSSESSION.Permission("LSC POS Command"::VOIDPP_L, InfoTextDescription) then begin
        //     PosTransactionGui.ErrorBeep(InfoTextDescription);
        //     exit;
        // end;

        // WriteMgrStatus;
        // POSLINES.GetCurrentLine(LineRec);

        // POSTransactionEvents.OnBeforeVoidPrepaymentLine(REC, LineRec);
        // PosPrepaymentUtil.VoidPrepaymentLine(LineRec);

        // POSTransactionEvents.OnAfterVoidPrepaymentLine(REC, LineRec);

        // InfoTextDescription := PrePaymVoidedMsg;
    end;

    procedure ChangePrepaymentLinePressed()
    // var
    //     PosPrepaymentUtil: Codeunit "LSC POS Prepayment Mgt.";
    //     ResultOk: Boolean;
    begin
        // LineRec.Reset;
        // LineRec.SetRange("Receipt No.", REC."Receipt No.");
        // LineRec.SetRange(LineRec."Entry Status", 0);

        // if not LineRec.FindFirst then begin
        //     LineRec.SetRange(LineRec."Entry Status");
        //     PosTransactionGui.MessageBeep('');
        //     exit;
        // end;

        // LineRec.SetRange(LineRec."Entry Status");

        // if not POSSESSION.Permission("LSC POS Command"::CHGPP_L, InfoTextDescription) then begin
        //     PosTransactionGui.ErrorBeep(InfoTextDescription);
        //     exit;
        // end;

        // WriteMgrStatus;
        // POSLINES.GetCurrentLine(LineRec);

        // ResultOk := false;
        // PosPrepaymentUtil.ChangePrepaymentLine(LineRec, CurrInput, ResultOk);
    end;

    procedure AddPrepaymentLinePressed()
    // var
    //     PosPrepaymentUtil: Codeunit "LSC POS Prepayment Mgt.";
    //     ResultOk: Boolean;
    begin
        // LineRec.Reset;
        // LineRec.SetRange("Receipt No.", REC."Receipt No.");
        // LineRec.SetRange(LineRec."Entry Status", 0);

        // if not LineRec.FindFirst then begin
        //     LineRec.SetRange(LineRec."Entry Status");
        //     PosTransactionGui.MessageBeep('');
        //     exit;
        // end;

        // LineRec.SetRange(LineRec."Entry Status");

        // if not POSSESSION.Permission("LSC POS Command"::ADDPP_L, InfoTextDescription) then begin
        //     PosTransactionGui.ErrorBeep(InfoTextDescription);
        //     exit;
        // end;

        // WriteMgrStatus;
        // POSLINES.GetCurrentLine(LineRec);

        // ResultOk := false;
        // PosPrepaymentUtil.AddPrepaymentToLine(LineRec, CurrInput, ResultOk);
    end;

    procedure AskForCustInvoiceNo()
    var
        InvNoMsg: Label 'Please input the Invoice No.';
    begin
        // OldFuncMode := FunctionSetup."Function Code";
        // SetFunctionMode("LSC POS Command"::INVOICENO);
        // PosTransactionGui.MessageBeep(InvNoMsg);
    end;

    procedure ValidateCustomerInvoiceNoInput()
    var
        ErrorTxt: Text[250];
        MsgTxt: Text[250];
        CustomerNo: Code[20];
        IsHandled: Boolean;
        ReturnValue: Boolean;
    begin
        // POSTransactionEventsPub.OnBeforeInputValidateCusInvNoInp_InvPmtAmt(ValidateCusInvNoInp_InvPmtAmt, IsHandled, ReturnValue, CurrInput);
        // if not isHandled then begin
        //     if ValidateCusInvNoInp_InvPmtAmt = '' then begin
        //         PosTransactionGui.OpenNumericKeyboard(AmountMsg, CopyStr(MsgTxt, 1, 50), Enum::"LSC POS Trans. Numpad Trigger"::ValidateCustomerInvoiceNoInput);
        //         exit;
        //     end;
        // end else begin
        //     if not ReturnValue then begin
        //         exit;
        //     end;
        // end;

        // if FunctionSetup."Function Code" = Format("LSC POS Command"::INVOICENO) then begin
        //     InvoiceNo := CopyStr(CurrInput, 1, 20);
        //     if InvoiceNo = '' then
        //         exit;
        //     if not PosFunc.ValidateCustInvoiceNo(InvoiceNo, ErrorTxt, MsgTxt, CustomerNo) then begin
        //         CurrInput := '';
        //         SetFunctionMode("LSC POS Command"::INVOICENO);
        //         PosTransactionGui.ErrorBeep(ErrorTxt);
        //         ClearGlobs;
        //         exit;
        //     end
        //     else begin
        //         REC."Apply to Doc. No." := InvoiceNo;
        //         REC.Modify;
        //         PosTransactionGui.MessageBeep(MsgTxt);
        //         if PaymentAmount = 0 then begin
        //             CurrInput := ValidateCusInvNoInp_InvPmtAmt;
        //             ValidateCusInvNoInp_InvPmtAmt := '';
        //             if CurrInput = '' then begin
        //                 PosTransactionGui.ErrorBeep(CANCELED_TXT);
        //                 exit;
        //             end;
        //             if not Evaluate(PaymentAmount, CurrInput) then begin
        //                 PosTransactionGui.ErrorBeep(InvalidAmtValueErr);
        //                 exit;
        //             end;
        //             if PaymentAmount <= 0 then begin
        //                 PosTransactionGui.ErrorBeep(InvalidAmtValueErr);
        //                 exit;
        //             end;
        //             PosFunc.AdjustAmount(PaymentAmount);
        //             PaymentAmount := -PaymentAmount;
        //             if not TenderType.Get(StoreSetup."No.", PaymentIntoAccTender)
        //                                or (TenderType."Function" <> TenderType."Function"::Customer) then begin
        //                 PosTransactionGui.ErrorBeep(StrSubstNo(InvalidErr, TenderType.TableCaption));
        //                 exit;
        //             end;
        //         end;
        //         Customer.Get(CustomerNo);
        //         ProcessCustomer(true);
        //         exit;
        //     end;
        // end;
        // exit;
    end;

    procedure PaymentIntoAccWithInvPressed(Tender: Code[10])
    begin
        if not TestNewTransaction then
            exit;

        PaymentAmount := 0;
        PaymentIntoAccTender := Tender;
        StartingPaymentsIntoAccount := true;
        REC.Modify;
        AskForCustInvoiceNo;
    end;

    procedure BackDateTransCheck(): Boolean
    var
        lTransactionHeader: Record "LSC Transaction Header";
        NoBackDateTrans: Label 'Back Date Transaction not allowed';
    begin
        if PosFuncProfile."BackDate Trans. Check" then begin
            lTransactionHeader.SetCurrentKey("Store No.", Date);
            lTransactionHeader.SetRange("Store No.", REC."Store No.");
            if lTransactionHeader.FindLast then begin
                if Today < (lTransactionHeader.Date - PosFuncProfile."Days BackDate Trans. Allowed") then begin
                    PosTransactionGui.ErrorBeep(NoBackDateTrans);
                    exit(false);
                end;
            end;
        end;
        exit(true);
    end;

    procedure ItemDecimalQtyCheck(var pItemNo: Code[20]; var pQuantity: Decimal): Boolean
    var
        lItemRec: Record Item;
        lPrGroup: Record "LSC Retail Product Group";
        QtyNoDecimalErr: Label 'Quantity cannot be in Decimal for this item.';
    begin
        if not lItemRec.Get(pItemNo) then
            exit(true);

        if lItemRec."LSC Qty not in Decimal" then
            if pQuantity <> Round(pQuantity, 1) then begin
                PosTransactionGui.ErrorBeep(QtyNoDecimalErr);
                exit(false);
            end;

        if not lPrGroup.Get(lItemRec."Item Category Code", lItemRec."LSC Retail Product Code") then
            exit(true);

        if lPrGroup."Qty not in Decimal" then
            if pQuantity <> Round(pQuantity, 1) then begin
                PosTransactionGui.ErrorBeep(QtyNoDecimalErr);
                exit(false);
            end;

        exit(true);
    end;

    procedure InsertMultipleItems(): Boolean
    var
        SelectQty: Record "LSC Selected Quantity";
        ItemStatusLink: Record "LSC Item Status Link";
        BOUtils: Codeunit "LSC BO Utils";
    begin
        Clear(TmpSelQty);
        TmpSelQty.DeleteAll;
        SelectQty.SetRange(Type, 0);
        SelectQty.SetRange("User Ref.", POSSESSION.GetOriginalTerminalNo);
        if SelectQty.FindSet then begin
            repeat
                if SelectQty."Qty." <> 0 then begin
                    TmpSelQty := SelectQty;
                    if BOUtils.IsBlockSaleOnPOS(SelectQty."Item No.", '', SelectQty."Variant Code", REC."Store No.", StoreSetup."Location Code", Today,
                      ItemStatusLink) then
                        PosTransactionGui.PosMessage(StrSubstNo(IsBlockedErr, Item.TableCaption, SelectQty."Item No."))
                    else
                        if TmpSelQty.Insert then;
                end;
            until SelectQty.Next = 0;
            SelectQty.DeleteAll(true);
            CheckNextItemInQueue;
            exit(true);
        end;
        exit(false);
    end;

    procedure ItemFinderPressed(SetupCode: Code[10])
    begin
        // Clear(ItemFinder);
        // ItemFinder.ShowItemFinder(SetupCode);
    end;

    procedure ProcessItemFinderResult()
    // var
    //     KeyValue: Code[30];
    //     VariantCode: Code[10];
    begin
        // KeyValue := ItemFinder.GetItem;
        // CurrInput := KeyValue;
        // VariantCode := ItemFinder.GetItemVariant(KeyValue);
        // LinkedItemsActive := false;
        // BomLineEntry := false;
        // ItemLine(false, false, 0, 0, VariantCode, '', '', '', 0, 0);
    end;

    procedure CalcBalanceWithOutNoDiscAllowe(): Decimal
    var
        PosTrLine: Record "LSC POS Trans. Line";
        NewBalance: Decimal;
        IsHandled: Boolean;
    begin
        NewBalance := 0;
        PosTrLine.Reset;
        PosTrLine.SetCurrentKey("Receipt No.", "Entry Type", "Entry Status");
        PosTrLine.SetRange("Receipt No.", REC."Receipt No.");
        PosTrLine.SetRange("Entry Type", PosTrLine."Entry Type"::Item);
        PosTrLine.SetRange("Entry Status", PosTrLine."Entry Status"::" ");
        if PosTrLine.FindSet then begin
            repeat
                if not PosTrLine."System-Block Manual Discount" then begin
                    POSTransactionEvents.OnBeforeGetNewBalance(PosTrLine, NewBalance, IsHandled);
                    if not IsHandled then
                        NewBalance := NewBalance + PosTrLine.Amount + PosTrLine."Total Disc. Amount";
                end;
            until PosTrLine.Next = 0;
        end;
        exit(NewBalance);
    end;

    procedure VoidCouponQtyUsed(var pPOSTransLine: Record "LSC POS Trans. Line")
    var
        lCouponHeader: Record "LSC Coupon Header";
        lCouponLine: Record "LSC Coupon Line";
        lPOSTransLine: Record "LSC POS Trans. Line";
        lQtyUsed: Integer;
    begin
        //Subtract 'Coupon Qty Used' for Coupons being voided. If a Coupon.'No of Items to Trigger' > 'Coupon Qty Used' subtracted no error
        //is reported. Items might have been voided after a Coupon was issued.
        if not lCouponHeader.Get(pPOSTransLine."Coupon Code") then begin
            PosTransactionGui.ErrorBeep(InvalidErr);
            exit;
        end;
        if lCouponHeader.Type = lCouponHeader.Type::"Return Coupon" then
            exit;

        lQtyUsed := lCouponHeader."No. of Items to Trigger";
        lCouponLine.SetRange("Coupon Code", lCouponHeader.Code);
        if lCouponLine.FindFirst then
            repeat
                lPOSTransLine.Reset;
                case lCouponLine.Type of
                    lCouponLine.Type::Item:
                        begin
                            lPOSTransLine.SetCurrentKey("Receipt No.", "Entry Type", Number);
                            lPOSTransLine.SetRange("Receipt No.", pPOSTransLine."Receipt No.");
                            lPOSTransLine.SetRange("Entry Type", lPOSTransLine."Entry Type"::Item);
                            lPOSTransLine.SetRange(Number, lCouponLine."No.");
                        end;
                    lCouponLine.Type::"Product Group":
                        begin
                            lPOSTransLine.SetCurrentKey("Receipt No.", "Entry Type", "Item Category Code", "Retail Product Code");
                            lPOSTransLine.SetRange("Receipt No.", pPOSTransLine."Receipt No.");
                            lPOSTransLine.SetRange("Entry Type", lPOSTransLine."Entry Type"::Item);
                            lPOSTransLine.SetRange("Retail Product Code", lCouponLine."No.");
                        end;
                    lCouponLine.Type::"Item Category":
                        begin
                            lPOSTransLine.SetCurrentKey("Receipt No.", "Entry Type", "Item Category Code", "Retail Product Code");
                            lPOSTransLine.SetRange("Receipt No.", pPOSTransLine."Receipt No.");
                            lPOSTransLine.SetRange("Entry Type", lPOSTransLine."Entry Type"::Item);
                            lPOSTransLine.SetRange("Item Category Code", lCouponLine."No.");
                        end;
                    lCouponLine.Type::"Special Group":
                        begin
                            lPOSTransLine.SetCurrentKey("Receipt No.", "Entry Type", "Entry Status");
                            lPOSTransLine.SetRange("Receipt No.", pPOSTransLine."Receipt No.");
                            lPOSTransLine.SetRange("Entry Type", lPOSTransLine."Entry Type"::Item);
                            lPOSTransLine.SetRange("Entry Status", lPOSTransLine."Entry Status"::" ");
                        end;
                end;

                if lPOSTransLine.FindFirst then
                    repeat
                        if (lPOSTransLine."Entry Status" = lPOSTransLine."Entry Status"::" ") then begin
                            lQtyUsed := lQtyUsed - lPOSTransLine."Coupon Qty Used";
                            if lQtyUsed > 0 then
                                lPOSTransLine."Coupon Qty Used" := 0
                            else
                                lPOSTransLine."Coupon Qty Used" := Abs(lQtyUsed);
                            lPOSTransLine.Modify;
                            if lQtyUsed <= 0 then
                                exit;
                        end;
                    until lPOSTransLine.Next = 0;
            until lCouponLine.Next = 0;
    end;

    procedure GetLastTransNo(): Integer
    begin
        exit(gTransNo);
    end;

    procedure SetTrainingMode(TrainMode: Boolean)
    begin
        TrainingActive := TrainMode;
        POSSESSION.SetTrainingStatus(TrainingActive);
    end;

    procedure GetTrainingMode(): Boolean
    begin
        exit(TrainingActive);
    end;

    procedure CleanupCustomer()
    var
        POSTransLine2: Record "LSC POS Trans. Line";
    begin
        Clear(Customer);
        ProcessCustomer(true);

        POSTransLine2.Reset;
        POSTransLine2.SetRange("Receipt No.", REC."Receipt No.");
        POSTransLine2.SetRange("Entry Type", POSTransLine2."Entry Type"::FreeText);
        POSTransLine2.SetRange("Entry Status", 0);
        POSTransLine2.SetRange("Text Type", POSTransLine2."Text Type"::"Cust. Text");
        POSTransLine2.SetFilter("Card/Customer/Coup.Item No", '<>%1', '');
        if POSTransLine2.FindFirst then begin
            POSTransLine2."Entry Status" := POSTransLine2."Entry Status"::Voided;
            POSTransLine2.Modify(true);
        end;
    end;

    procedure SelectDefaultMenu()
    begin
        SelectDefaultMenuFlag := true;
    end;

    procedure GetDefaultMenuSelectedFlag(): Boolean
    begin
        if SelectDefaultMenuFlag then begin
            SelectDefaultMenuFlag := false;
            exit(true);
        end;
        exit(false);
    end;

    internal procedure LookUp(ExecuteCommand: Boolean; FormID: Code[20]; "Filter": Code[29])
    var
        LookupRecRef: RecordRef;
    begin
        if (FormID = 'CUSTOMER') and (NumericKeyboardTrigger = 6) and (CurrInput = '') then begin //DEBUG - Need to Refactor PaymentIntoAccount
            PaymentIntoAccountMenuLine := GlobalMenuLine;
            exit;
        end;
        LookUpEx(ExecuteCommand, FormID, Filter, LookupRecRef);
    end;

    procedure LookUpEx(ExecuteCommand: Boolean; FormID: Code[20]; "Filter": Code[29]; var LookupRecRef: RecordRef): Code[30]
    var
        PosLookup: Record "LSC POS Lookup";
        MenuLine2_l: Record "LSC POS Menu Line";
        VarFrameSetup: Record "LSC Variant FW Setup";
        FunctionSetup2: Record "LSC POS Command";
        Currline: Record "LSC POS Trans. Line";
        NewLineTemp: Record "LSC POS Trans. Line" temporary;
        lInfoSubCode: Record "LSC Information Subcode";
        ItemTmp: Record Item temporary;
        ItemDistribution: Record "LSC Item Distribution";
        DynVarMenuOk: Boolean;
        IsHandled: Boolean;
    begin
        DynVarMenuOk := false;

        if FormID = '' then begin
            PosLookup.SetRange("Default for Function", FunctionSetup."Function Code");
            if PosLookup.FindFirst then
                FormID := PosLookup."Lookup ID";
            if (FormID = '') and (FunctionSetup."Function Code" = Format("LSC POS Command"::CHECK)) then
                FormID := 'ITEM';
        end;

        // POSTransactionEventsPub.OnBeforeLookup(FormID);

        PosLookup.Reset;
        if not POSSESSION.GetPosLookupRec(FormID, PosLookup) then
            exit;

        Commit;
        case FunctionSetup."Function Code" of
            Format("LSC POS Command"::VARIANT):
                begin
                    Filter := Item."No.";
                    if VarFrameSetup.Get(Item."LSC Variant Framework Code") then
                        DynVarMenuOk := VarFrameSetup."Use Pop-up Window"
                    else
                        DynVarMenuOk := true;
                end;
            Format("LSC POS Command"::INFOCODE):
                begin
                    Filter := '';
                    case Info.Type of
                        Info.Type::Selection:
                            begin
                                Filter := Info.Code;
                                lInfoSubCode.SetRange(Code, Info.Code);
                                POSTransactionEvents.OnAfterInfoSubCodeSetFilter(Info, lInfoSubCode);
                                LookupRecRef.GetTable(lInfoSubCode);
                            end;
                        Info.Type::"Item Input":
                            FormID := 'ITEM';
                        Info.Type::"Customer Input":
                            FormID := 'CUSTOMER';
                    end;
                end;
        end;
        if FormID = 'TENDER' then
            Filter := REC."Store No."
        else begin
            if DynVarMenuOk then begin
                FunctionSetup2.Get(Format("LSC POS Command"::POPUPVAR));
                Clear(MenuLine2_l);

                PopulatePOSMenuLineForCodeunitRun(Format("LSC POS Command"::POPUPVAR), Item."No.", MenuLine2_l, Currline, false, true);

                PopupPOSComm.Run(MenuLine2_l);
                if MenuLine2_l."Input Process" <> MenuLine2_l."Input Process"::" " then
                    exit;
            end
            else begin
                NewLineTemp := NewLine;
                if (FormID = '#SPODETAILS') then begin
                    Currline.SetRange("Receipt No.", REC."Receipt No.");
                    if Currline.FindFirst then begin
                        NewLine.Copy(Currline);
                        NewLineTemp := NewLine;
                    end;
                end;
                if (FormID = 'SERIAL_LU') or (FormID = 'LOT_LU') then begin
                    if not PosFunc.PrepareInvLookup(NewLineTemp, true, '', Filter) then
                        exit('');
                end;

                if NewLineTemp."Receipt No." = '' then
                    NewLineTemp."Receipt No." := LastSlipNo;

                if FormID = 'ZOOMINFOL' then begin
                    POSLINES.GetCurrentLine(CurrLine);
                    NewLineTemp := CurrLine;
                end;

                if FormID = '#ITEMATTRIBUTES' then //update Curr Item if Item Lookup was active
                    if POSGUI.GetActiveLookupID = 'ITEM' then
                        NewLineTemp.Number := POSGUI.GetActiveLookupKeyValue;

                POSTransactionEvents.OnBeforeLookupCall(PosLookup, NewLineTemp, POSSESSION.MgrKey, REC."Customer No.", ExecuteCommand, FormID, "Filter", LookupRecRef, IsHandled);
                if not IsHandled then begin
                    if ExecuteCommand then
                        Filter += '[EXECUTE]';

                    NewLineTemp.Description := Item.Description;
                    if FormID = 'ITEM' then begin
                        if PosFuncProfile."POS Item Lookup Method" = PosFuncProfile."POS Item Lookup Method"::"Store Distribution" then begin
                            Item.Reset();
                            if Item.FindSet then
                                repeat
                                    if ItemDistribution.getItemDistribution(Item."No.", REC."Store No.", ItemDistribution) then begin
                                        ItemTmp.Init;
                                        ItemTmp := Item;
                                        ItemTmp.Insert;
                                    end;
                                until Item.Next = 0;
                            LookupRecRef.GetTable(ItemTmp);
                        end;
                        if PosFuncProfile."POS Item Lookup Method" = PosFuncProfile."POS Item Lookup Method"::Disabled then
                            exit;
                    end;

                    POSGUI.Lookup(PosLookup, Filter, NewLineTemp, POSSESSION.MgrKey, REC."Customer No.", LookupRecRef);
                end;
            end;
        end;
    end;

    procedure BackSpace()
    begin
        if StrLen(CurrInput) > 0 then
            CurrInput := CopyStr(CurrInput, 1, StrLen(CurrInput) - 1)
    end;

    procedure InitCommand()
    begin
        Scanned := false;
        ReadFromMSR := false;
        VoidInProcess := false;
    end;

    procedure IsNewTransaction(): Boolean
    begin
        exit(REC."New Transaction");
    end;

    procedure SaleIsReturnSale(): Boolean
    begin
        exit(REC."Sale Is Return Sale");
    end;

    procedure SetProcessTenderOffers(newProcessTenderOffersValue: Boolean)
    begin
        ProcessTenderOffers := newProcessTenderOffersValue;
    end;

    procedure GetStoreNo(): Code[10]
    begin
        exit(REC."Store No.");
    end;

    procedure GetPOSTerminalNo(): Code[10]
    begin
        exit(REC."POS Terminal No.");
    end;

    procedure GetReceiptNo(): Code[20]
    begin
        exit(REC."Receipt No.");
    end;

    procedure GetSalesStaff(): Code[20]
    begin
        exit(REC."Sales Staff");
    end;

    procedure GetDocumentNo(): Code[20]
    begin
        exit(REC."Document No.");
    end;

    procedure GetCustomerNo(): Code[20]
    begin
        exit(REC."Customer No.");
    end;

    procedure GetDiscount(): Decimal
    begin
        exit(-(REC."Line Discount"));
    end;

    procedure GetDiscountTxt(): Text[30]
    begin
        exit(FormatAmount(GetDiscount));
    end;

    procedure GetAmount(): Decimal
    begin
        exit(REC."Gross Amount" + REC."Line Discount" + REC."Income/Exp. Amount");
    end;

    procedure GetAmountTxt(): Text[30]
    begin
        exit(FormatAmount(GetAmount));
    end;

    procedure GetPayment(): Decimal
    begin
        exit(-REC.Payment);
    end;

    procedure GetPaymentTxt(): Text[30]
    begin
        exit(FormatAmount(GetPayment));
    end;

    procedure GetOutstandingBalance(): Decimal
    var
        ReturnValue: Decimal;
    begin
        ReturnValue := Balance;
        POSTransactionEvents.OnGetOutstandingBalance(REC, ReturnValue);
        exit(ReturnValue);
    end;

    procedure GetOutstandingBalanceTxt(): Text[30]
    begin
        exit(FormatAmount(GetOutstandingBalance));
    end;

    procedure GetPrepaymentAmount(): Decimal
    begin
        exit(REC.Prepayment);
    end;

    procedure GetPrepaymentAmountTxt(): Text[30]
    begin
        exit(FormatAmount(GetPrepaymentAmount));
    end;

    procedure GetPrepaymentBalance(): Decimal
    begin
        exit(-1 * (GetPayment - GetPrepaymentAmount));
    end;

    procedure GetPrepaymentBalanceTxt(): Text[30]
    begin
        exit(FormatAmount(GetPrepaymentBalance));
    end;

    procedure GetTotalNetAmount(): Decimal
    begin
        exit(REC."Net Amount" + REC."Line Discount" + REC."Net Income/Exp. Amount");
    end;

    procedure GetTotalNetAmountTxt(): Text[30]
    begin
        exit(FormatAmount(GetTotalNetAmount));
    end;

    procedure GetSalesTax(): Decimal
    begin
        exit(REC."Gross Amount" - REC."Net Amount" + REC."Income/Exp. Amount" - REC."Net Income/Exp. Amount");
    end;

    procedure GetSalesTaxTxt(): Text[30]
    begin
        exit(FormatAmount(GetSalesTax));
    end;

    procedure GetShiftNo(): Code[1]
    begin
        exit(REC."Shift No.");
    end;

    procedure GetStaffID(): Code[20]
    begin
        exit(REC."Staff ID");
    end;

    procedure GetManagerID(): Code[20]
    begin
        exit(REC."Manager ID");
    end;

    procedure GetManagerKey(): Boolean
    begin
        exit(REC."Manager Key" = REC."Manager Key"::On);
    end;

    procedure GetSalesType(): Code[20]
    begin
        exit(REC."Sales Type");
    end;

    procedure GetMenuType(): Code[20]
    var
        MenuTypeRec: Record "LSC Restaurant Menu Type";
    begin
        if CurrMenuType <> 0 then begin
            if MenuTypeRec.Get(REC."Store No.", CurrMenuType) then
                exit(MenuTypeRec."Code on POS");
        end;
    end;

    procedure GetMenuTypeDescription(): Text[30]
    var
        MenuTypeRec: Record "LSC Restaurant Menu Type";
    begin
        if CurrMenuType <> 0 then begin
            if MenuTypeRec.Get(REC."Store No.", CurrMenuType) then
                exit(MenuTypeRec.Description);
        end;
    end;

    procedure GetGuests(): Integer
    begin
        //GetGuests
        exit(CurrGuest);
    end;

    procedure GetCovers(): Integer
    begin
        exit(REC."No. of Covers");
    end;

    procedure GetTableDescr(): Text
    begin
        exit(REC."Dining Tbl. Description");
    end;

    procedure GetComment(): Text
    begin
        exit(REC.Comment);
    end;

    procedure GetPosState(): Code[10]
    begin
        exit(Format(STATE));
    end;

    procedure GetPosInfoText1(): Text
    begin
        exit(InfoTextDescription);
    end;

    procedure AvailabilityModeOn(): Boolean
    begin
        exit(ItemStockRestrictionOn);
    end;

    procedure SetPosInfoText1(pText: Text)
    begin
        InfoTextDescription := pText;
    end;

    procedure GetPosInfoText2(): Text
    begin
        exit(InfoTextDescription2);
    end;

    procedure SetPosInfoText2(pText: Text)
    begin
        InfoTextDescription2 := pText;
    end;

    procedure GetInputPrompt(): Text[30]
    begin
        exit(FunctionSetup.Prompt);
    end;

    procedure SetUnitOfMeasure(UnitOfMeasure: Text)
    begin
        UOMSet := UnitOfMeasure;
    end;

    procedure SetCurrInput(var pCurrInput: Text)
    begin
        CurrInput := pCurrInput;
    end;

    procedure GetCurrInput(): Text
    begin
        exit(CurrInput);
    end;

    procedure AppendInput(pText: Text[30])
    begin
        CurrInput += pText;
    end;

    procedure ClearInput()
    begin
        CurrInput := '';
    end;

    procedure SetLastItemNo(pItemNo: Code[20])
    begin
        LastItemNo := pItemNo;
    end;

    procedure SetInfoFunction(NewInfoFunction: Code[10])
    begin
        InfoFunction := NewInfoFunction;
    end;

    procedure SetStartFunction(NewStartFunction: code[20])
    begin
        StartFunction := NewStartFunction;
    end;

    procedure SetTransNo(var TransNoIn: Integer)
    begin
        gTransNo := TransNoIn;
        TransNo := TransNoIn
    end;

    procedure ClearPluCheckPriceAndVariant()
    begin
        pluCurrVariant := '';
        pluCheckPriceMode := false;
    end;

    procedure ProcessScannerInput(var pScanInput: Text)
    var
        lErrorMessage: Text;
        IsHandled, Found : Boolean;
    begin
        // POSTransactionEventsPub.OnBeforeProcessScannerInput(pScanInput, StoreSetup);

        // if not OkNewInput then begin
        //     if FunctionSetup."Function Code" = Format("LSC POS Command"::DAENTRCODE) then begin
        //         CurrInput := pScanInput;
        //         ValidateDataEntryInput;
        //         exit;
        //     end
        //     else begin
        //         POSTransactionEvents.OnBeforeProcessScannerFunctionCode(FunctionSetup, IsHandled, Found);
        //         if IsHandled then
        //             exit;
        //         if not Found then
        //             if (FunctionSetup."Function Code" <> Format("LSC POS Command"::INFOCODE)) and
        //                (FunctionSetup."Function Code" <> Format("LSC POS Command"::CUSTOMER)) and
        //                (FunctionSetup."Function Code" <> Format("LSC POS Command"::CHECK)) then begin
        //                 OposUtil.Beeper;
        //                 exit;
        //             end;
        //     end;
        // end;
        // Scanned := true;

        // if StrPos(pScanInput, '<mobiledevice>') > 0 then begin
        //     LoadQRTextData(pScanInput);
        //     if QueueMobileLoyaltyQRCode(lErrorMessage) then
        //         ProcessScannerDataInput
        //     else
        //         PosTransactionGui.PosMessage(CopyStr(lErrorMessage, 1, 250));
        //     exit;
        // end;

        // if StrPos(pScanInput, '<mobilehosploy>') > 0 then begin
        //     LoadQRTextData(pScanInput);
        //     if QueueHospLoyalty(lErrorMessage) then
        //         ProcessHospDataInput
        //     else
        //         PosTransactionGui.PosMessage(CopyStr(lErrorMessage, 1, 250));
        //     exit;
        // end;

        // if StrPos(pScanInput, '<CustomerOrder>') > 0 then begin
        //     LoadQRTextData(pScanInput);
        //     if QueueCOQRCode(lErrorMessage) then
        //         ProcessCODataInput
        //     else
        //         PosTransactionGui.PosMessage(CopyStr(lErrorMessage, 1, 250));
        //     exit;
        // end;

        // if StrPos(pScanInput, '<ScanPayGo>') > 0 then begin
        //     LoadQRTextData(pScanInput);
        //     if QueueSPGQRCode(lErrorMessage) then
        //         ProcessSPGDataInput
        //     else
        //         PosTransactionGui.PosMessage(CopyStr(lErrorMessage, 1, 250));
        //     exit;
        // end;

        // CurrInput := pScanInput;
        // if not ProcessBarcode then
        //     PosTransactionGui.ErrorBeep(InvalidBarcodeErr);
    end;

    procedure ProcessMSRInput(var pMSRInput: Text)
    begin
        if EFT.OnMsrData(pMSRInput) then
            exit;

        CurrInput := pMSRInput;

        if FunctionSetup."Function Code" in [Format("LSC POS Command"::CARD), Format("LSC POS Command"::INFOCODE),
         Format("LSC POS Command"::CUSTOMER), Format("LSC POS Command"::DAENTRCODE)] then begin
            ReadFromMSR := true;
            ValidateInput;
        end
        else begin
            if not CheckMSRcards() then
                if not CheckMemberCard then
                    OposUtil.Beeper;
            CurrInput := '';
        end;
    end;

    procedure GetClosePosFlag() retval: Boolean
    begin
        retval := ClosePosFlag;
        ClosePosFlag := false;
    end;

    procedure GetNewLineNo(): Integer
    begin
        exit(NewLine."Line No.");
    end;

    procedure GetSelectLineNoBeforePLUKEYPressed(): Integer
    begin
        exit(SelectedLineNoBeforePLUKEYPressed);
    end;

    procedure GetGlobalSalesType(): Code[20]
    begin
        exit(GLobalSalesType);
    end;

    procedure SetGlobalSalesType()
    begin
        GLobalSalesType := POSSESSION.GetValue("LSC POS Tag"::"SALESTYPE");
        if GLobalSalesType = '' then
            GLobalSalesType := PosTerminal."Default Sales Type";
    end;

    procedure ProcessFuelMessage() retval: Integer
    begin
        POSTransactionEvents.OnProcessFuelMessage(LineRec, REC, retval, CurrInput, CommandRetVal, KeyboardPrice, OverridePrice, MultiplyWith);
    end;

    procedure GetContactID(): Code[20]
    begin
        exit(REC."Sell-to Contact No.");
    end;

    procedure GetStateTxt(): Code[30]
    begin
        exit(StateTxt);
    end;

    procedure GetStateTxt2(): Text[30]
    begin
        exit(StateTxt2);
    end;

    procedure VoidSuspendedTrans(pReceiptNo: Code[20])
    var
        OldPosTransaction: Record "LSC POS Transaction";
        POSTransPostingState: Record "LSC POS Trans. Posting State";
        POSFunctions: Codeunit "LSC POS Functions";
        Error: Text;
    begin
        // if POSFunctions.RetrieveSusp(pReceiptNo, REC, Error) then begin
        //     OldPosTransaction.Reset;
        //     OldPosTransaction.SetRange("New Transaction", true);
        //     OldPosTransaction.SetRange("Transaction Type", OldPosTransaction."Transaction Type"::Logoff);
        //     OldPosTransaction.SetRange("Store No.", REC."Store No.");
        //     OldPosTransaction.SetRange("POS Terminal No.", REC."POS Terminal No.");
        //     if OldPosTransaction.FindFirst then
        //         OldPosTransaction.Delete(true);

        //     PosFunc.ReadLocalVar(LastSlipNo);

        //     StateTxt := Format(REC."Transaction Type");

        //     if (REC."Transaction Type" = REC."Transaction Type"::Sales) and REC."Sale Is Return Sale" then
        //         StateTxt := __StateREFUND;
        //     POSGUI.SetSelectedMenu(POSSESSION.GetSalesMenu);
        //     InfoTextDescription := TransRetrievedMsg;
        //     REC.Get(REC."Receipt No.");
        //     AfterGetRecord();
        //     REC."Suspend Sales Type" := REC."Sales Type";
        //     if REC."Sales Type" <> GLobalSalesType then begin
        //         REC."Sales Type" := GLobalSalesType;
        //         REC.Modify;
        //     end;
        //     Member.LoadMemberInfo(REC."Member Card No.");
        //     PosFunc.PosTransDiscLoad(REC."Receipt No.");
        //     POSSESSION.SetValue("LSC POS Tag"::"RetrievedSlipNo", '');
        //     POSTransactionEventsPub.OnAfterRetrieveSusp(REC);
        // end else
        //     if Error <> '' then
        //         PosTransactionGui.ErrorBeep(__TSError)
        //     else
        //         PosTransactionGui.ErrorBeep(ReceiptNotFoundErr);

        // POSSESSION.SetTransPostingSource(POSTransPostingState."Posting Source"::"Zreport Suspend");
        // VoidTransaction;
    end;

    procedure ZReportSuspendProcess(var NoSuspPOSTransactionsVoided: Integer): Boolean
    var
        POSTransactionSuspend: Record "LSC POS Transaction";
        POSTransactionSuspendTEMP: Record "LSC POS Transaction" temporary;
        POSTransactionSuspendTEMP2: Record "LSC POS Transaction" temporary;
        POSTransLineSuspend: Record "LSC POS Trans. Line";
        POSTransLineSuspendTEMP: Record "LSC POS Trans. Line" temporary;
        GetPosTransSuspListUtils: Codeunit LSCGetPosTransSuspListUtils;
        GetPosTransSuspLinesUtils: Codeunit LSCGetPosTransSuspLinesUtils;
        CalculatedDate: Date;
        ResponseCode: Code[30];
        NoSuspended: Integer;
        IsHandled, ReturnValue : Boolean;
        ErrorText: Text;
        SuspTransExistMsg: Label 'Suspended Transaction exist\Process Stopped';
    begin
        POSTransactionEvents.OnBeforeZReportSuspendProcess(StoreSetup, NoSuspPOSTransactionsVoided, IsHandled, ReturnValue);
        if IsHandled then
            exit(ReturnValue);
        NoSuspPOSTransactionsVoided := 0;
        if PosFuncProfile."Z-Report Suspend Trans.Process" <> PosFuncProfile."Z-Report Suspend Trans.Process"::None then begin
            CalculatedDate := Today;
            if PosFuncProfile."Z-Report Suspend Trans.Process" =
               PosFuncProfile."Z-Report Suspend Trans.Process"::"Delete older than" then begin
                if Format(PosFuncProfile."Z-Report Suspend Date Formula") <> '' then
                    CalculatedDate := CalcDate(PosFuncProfile."Z-Report Suspend Date Formula", Today);
            end;
            POSTransactionSuspendTEMP.Reset;
            POSTransactionSuspendTEMP.DeleteAll;
            if PosFuncProfile."TS Susp./Retrieve" then begin
                GetPosTransSuspListUtils.SetPosFunctionalityProfile(PosFuncProfile."Profile ID");
                GetPosTransSuspListUtils.SendRequest(StoreSetup."No.", ResponseCode, ErrorText, POSTransactionSuspendTEMP);
                //GetPosTransSuspListUtils.SetCommunicationError(ResponseCode, ErrorText);
                if ErrorText <> '' then
                    exit(false);
                if CalculatedDate <> 0D then begin
                    POSTransactionSuspendTEMP.Reset;
                    if POSTransactionSuspendTEMP.FindSet then
                        repeat
                            if POSTransactionSuspendTEMP."Trans. Date" > CalculatedDate then
                                POSTransactionSuspendTEMP.Delete;
                        until POSTransactionSuspendTEMP.Next = 0;
                end;
                POSTransactionSuspendTEMP.Reset;
                if StoreSetup."Statement Method" = StoreSetup."Statement Method"::"POS Terminal" then
                    POSTransactionSuspendTEMP.SetFilter("Created on POS Terminal", '<>%1', REC."POS Terminal No.");
                if StoreSetup."Statement Method" = StoreSetup."Statement Method"::Staff then
                    POSTransactionSuspendTEMP.SetFilter("Staff ID", '<>%1', REC."Staff ID");
                if POSTransactionSuspendTEMP.FindSet() then
                    repeat
                        POSTransactionSuspendTEMP.Delete;
                    until POSTransactionSuspendTEMP.Next = 0;
            end else begin
                POSTransactionSuspend.Reset;
                POSTransactionSuspend.SetCurrentKey("Store No.", "POS Terminal No.", "Staff ID");
                POSTransactionSuspend.SetRange("Store No.", StoreSetup."No.");
                POSTransactionSuspend.SetRange("Entry Status", POSTransactionSuspend."Entry Status"::Suspended);
                if StoreSetup."Statement Method" = StoreSetup."Statement Method"::"POS Terminal" then
                    POSTransactionSuspend.SetRange("Created on POS Terminal", REC."POS Terminal No.");
                if StoreSetup."Statement Method" = StoreSetup."Statement Method"::Staff then
                    POSTransactionSuspend.SetRange("Staff ID", REC."Staff ID");
                if CalculatedDate <> 0D then
                    POSTransactionSuspend.SetRange("Trans. Date", 0D, CalculatedDate);
                if POSTransactionSuspend.FindSet then
                    repeat
                        POSTransactionSuspendTEMP := POSTransactionSuspend;
                        POSTransactionSuspendTEMP.Insert;
                    until POSTransactionSuspend.Next = 0;
            end;

            NoSuspended := 0;
            POSTransactionSuspendTEMP.Reset;
            if POSTransactionSuspendTEMP.FindSet then
                repeat
                    NoSuspended := NoSuspended + 1;
                until POSTransactionSuspendTEMP.Next = 0;

            case PosFuncProfile."Z-Report Suspend Trans.Process" of
                PosFuncProfile."Z-Report Suspend Trans.Process"::Block:
                    begin
                        if NoSuspended > 0 then begin
                            PosTransactionGui.PosMessage(SuspTransExistMsg);
                            exit(false);
                        end;
                    end;
                PosFuncProfile."Z-Report Suspend Trans.Process"::Delete,
                PosFuncProfile."Z-Report Suspend Trans.Process"::"Delete older than":
                    begin
                        if NoSuspended > 0 then begin
                            POSTransactionSuspendTEMP2.Reset;
                            POSTransactionSuspendTEMP2.DeleteAll;
                            POSTransactionSuspendTEMP.Reset;
                            if POSTransactionSuspendTEMP.FindSet then
                                repeat
                                    if PosFuncProfile."TS Susp./Retrieve" then begin
                                        POSTransLineSuspendTEMP.Reset;
                                        POSTransLineSuspendTEMP.DeleteAll;
                                        GetPosTransSuspLinesUtils.SetPosFunctionalityProfile(PosFuncProfile."Profile ID");
                                        GetPosTransSuspLinesUtils.SendRequest(ResponseCode, ErrorText, POSTransactionSuspendTEMP."Receipt No.",
                                            POSTransLineSuspendTEMP."Entry Type"::IncomeExpense.AsInteger(), POSTransLineSuspendTEMP);
                                        //GetPosTransSuspLinesUtils.SetCommunicationError(ResponseCode, ErrorText);
                                        if ErrorText <> '' then
                                            exit(false);
                                        if POSTransLineSuspendTEMP.FindFirst then begin
                                            POSTransactionSuspendTEMP2 := POSTransactionSuspendTEMP;
                                            POSTransactionSuspendTEMP2.Insert;
                                        end;
                                    end else begin
                                        POSTransLineSuspend.Reset;
                                        POSTransLineSuspend.SetCurrentKey("Receipt No.", "Entry Type", "Entry Status");
                                        POSTransLineSuspend.SetRange("Receipt No.", POSTransactionSuspendTEMP."Receipt No.");
                                        POSTransLineSuspend.SetRange("Entry Type", POSTransLineSuspend."Entry Type"::IncomeExpense);
                                        if POSTransLineSuspend.FindFirst then begin
                                            POSTransactionSuspendTEMP2 := POSTransactionSuspendTEMP;
                                            POSTransactionSuspendTEMP2.Insert;
                                        end;
                                    end;
                                until POSTransactionSuspendTEMP.Next = 0;
                            POSTransactionSuspendTEMP2.Reset;
                            if POSTransactionSuspendTEMP2.FindSet then
                                repeat
                                    if POSTransactionSuspendTEMP.Get(POSTransactionSuspendTEMP2."Receipt No.") then
                                        POSTransactionSuspendTEMP.Delete;
                                until POSTransactionSuspendTEMP2.Next = 0;
                            POSTransactionSuspendTEMP.Reset;
                            if POSTransactionSuspendTEMP.FindSet then
                                repeat
                                    VoidSuspendedTrans(POSTransactionSuspendTEMP."Receipt No.");
                                    POSTransactionEvents.GXLOnZReportSuspendProcessOnAfterVoidSuspendedTrans(POSTransactionSuspendTEMP, POSSESSION.TerminalNo);
                                    NoSuspPOSTransactionsVoided := NoSuspPOSTransactionsVoided + 1;
                                until POSTransactionSuspendTEMP.Next = 0;
                        end;
                    end;
            end;
        end;

        exit(true);
    end;

    procedure CheckIfZReportPrinted()
    var
        TransactionHeader: Record "LSC Transaction Header";
        RetailCalendarManagement: Codeunit "LSC Retail Calendar Management";
        RetailCalendar: Record "LSC Retail Calendar";
        CheckDateTime: DateTime;
        TransactionDateTime: DateTime;
        CheckDate: Date;
        CheckTime: Time;
        OpenFrom: Time;
        OpenTo: Time;
        NoOfOldRecords: Integer;
        NoOfNewRecords: Integer;
        OpenAfterMidnight: Boolean;
        IsHandled: Boolean;
        UnprocessedTransBeforeButHasCurrentZReportQst: Label 'There are unprocessed Transaction from last business day\Transactions from current business day exist\Do you want to run Z-Report?';
        UnprocessedTransBeforeZReportQst: Label 'There are unprocessed Transaction from last business day\Do you want to run Z-Report?';
        ZReportNeeded: Label 'Z-Report was not printed for last Tender declaration.\ Do you want to print a Z-Report before opening the POS?';
        BlankInMsg: Label '%1 is blank in the %2.';
    begin
        // POSTransactionEventsPub.OnBeforeCheckIfZReportPrinted(StoreSetup, IsHandled);
        if IsHandled then
            exit;
        if StoreSetup."No." = '' then
            Error(BlankInMsg, StoreSetup.FieldCaption("No."), StoreSetup.TableCaption);

        if (not StoreSetup."POS Check Z-Report") and (not PosFuncProfile."Z-Rep Autopr. after T.Dec EOD") then
            exit;
        if (not POSSESSION.Permission("LSC POS Command"::PRINT_Z, InfoTextDescription)) then
            exit;

        CheckDate := RetailCalendarManagement.Yesterday(Today);
        CheckTime := 235959T;

        if RetailCalendarManagement.GetStoreOpenFromTo(
          StoreSetup."No.", RetailCalendar."Calendar Type"::"Opening Hours",
          CheckDate, OpenFrom, OpenTo, OpenAfterMidnight)
        then begin
            if OpenAfterMidnight then
                CheckDate := Today;
            if OpenTo <> 0T then
                CheckTime := OpenTo;
        end;
        CheckDateTime := CreateDateTime(CheckDate, CheckTime);

        NoOfOldRecords := 0;
        NoOfNewRecords := 0;

        TransactionHeader.Reset;
        TransactionHeader.SetCurrentKey("Statement Code", "Z-Report ID", "Transaction Type", "Entry Status");
        TransactionHeader.SetRange("Statement Code", PosFunc.GetStatementCode);
        TransactionHeader.SetRange("Z-Report ID", '');
        if TransactionHeader.FindSet then
            repeat
                TransactionDateTime := CreateDateTime(TransactionHeader.Date, TransactionHeader.Time);
                if TransactionDateTime <= CheckDateTime then
                    NoOfOldRecords := NoOfOldRecords + 1
                else
                    if (TransactionHeader."Transaction Type" <> TransactionHeader."Transaction Type"::Logon) and
                      (TransactionHeader."Transaction Type" <> TransactionHeader."Transaction Type"::Logoff)
                    then
                        NoOfNewRecords := NoOfNewRecords + 1;
            until TransactionHeader.Next = 0;

        if NoOfOldRecords > 0 then
            if NoOfNewRecords > 0 then begin
                if PosTransactionGui.PosConfirm(UnprocessedTransBeforeButHasCurrentZReportQst, false) then
                    PrintZReport(false, false);
            end else begin
                if PosTransactionGui.PosConfirm(UnprocessedTransBeforeZReportQst, false) then
                    PrintZReport(false, false);
            end;

        if PosFuncProfile."Z-Rep Autopr. after T.Dec EOD" then begin
            TransactionHeader.Reset();
            TransactionHeader.SetRange("Store No.", POSSession.StoreNo());
            TransactionHeader.SetRange("POS Terminal No.", POSSession.TerminalNo);
            if TransactionHeader.FindLast() then
                if (TransactionHeader."Transaction Type" = TransactionHeader."Transaction Type"::"Tender Decl.") and (TransactionHeader."Z-Report ID" = '') then
                    if POSCtrl.PosConfirm(ZReportNeeded, true) then
                        PrintZReport(false, false);
        end;
    end;

    procedure GetLastItemNo(): Code[20]
    begin
        exit(LastItemNo);
    end;

    procedure ClearLastItemNo()
    begin
        LastItemNo := '';
    end;

    internal Procedure AfterGetRecord()
    begin
        REC."Shift No." := POSSESSION.WorkShiftNo;
        REC."POS Terminal No." := POSSESSION.TerminalNo;
        POSTransactionEvents.OnAfterGetRecord(Rec);
    end;

    procedure ViewVoucherEntries(Parameter: Text[50])
    var
        PosDataEntryType: Record "LSC POS Data Entry Type";
        IsMissingInSetupMsg: Label '%1 %2 is missing in setup.';
        FieldMustBeErr: Label 'Field %1 in %2 %3 must be %4';
    begin
        if not REC."New Transaction" then
            if STATE <> "LSC POS Transaction State"::PAYMENT then begin
                PosTransactionGui.ErrorBeep(CommandNotAllowedInStateErr);
                exit;
            end;

        if not PosDataEntryType.Get(Parameter) then begin
            PosTransactionGui.ErrorBeep(StrSubstNo(IsMissingInSetupMsg, PosDataEntryType.TableCaption, Parameter));
            exit;
        end;
        if not PosDataEntryType."Create Voucher Entry" then begin
            PosTransactionGui.ErrorBeep(StrSubstNo(FieldMustBeErr, PosDataEntryType.FieldCaption("Create Voucher Entry"), PosDataEntryType.TableCaption,
              Parameter, true));
            exit;
        end;

        PosDataEntryTypeCode := Parameter;
        AskForDataEntryNo;
    end;

    procedure AskForDataEntryNo()
    var
        MissingDataEntryValueMsg: Label 'Please input value or scan barcode';
    begin
        OldFuncMode := FunctionSetup."Function Code";
        // SetFunctionMode("LSC POS Command"::DAENTRCODE);
        POSTransactionEvents.onAskForDataEntryNo();
        PosTransactionGui.MessageBeep(MissingDataEntryValueMsg);
    end;

    procedure ValidateDataEntryInput()
    var
        PosDataEntryType: Record "LSC POS Data Entry Type";
        BarcodeMask_l: Record "LSC Barcode Mask";
        PosDataEntryType_l: Record "LSC POS Data Entry Type";
        POSInfocodeUtil: Codeunit "LSC POS Infocode Utility";
        PrintUtil: Codeunit "LSC POS Print Utility";
        ExpirationDate: Date;
        ErrorText: Text;
        VoucherNo: Code[20];
        DataEntryType_l: Code[20];
        DataEntryBalance: Decimal;
        TSError: Integer;
        IsHandled, ErrorOccured : Boolean;
        CurrBalanceIsMsg: Label 'Current Balance is %1';
    begin
        if FunctionSetup."Function Code" = Format("LSC POS Command"::DAENTRCODE) then begin
            VoucherNo := CopyStr(CurrInput, 1, 20);
            if VoucherNo = '' then
                exit;

            POSTransactionEvents.OnAfterGetVoucherNoValidateDataEntryInput(PosDataEntryTypeCode, PosDataEntryBalanceOnly, VoucherNo, ErrorOccured);
            if ErrorOccured then
                exit;
            if PosDataEntryType.Get(PosDataEntryTypeCode) then begin
                if BarcodeMask_l.Get(PosDataEntryType."Barcode Mask Entry No") then
                    if StrLen(BarcodeMask_l.Mask) = StrLen(VoucherNo) then
                        VoucherNo := PosFunc.GetBarcDataEntryCode(VoucherNo, BarcodeMask_l);
            end;
            if not PosDataEntryBalanceOnly then begin
                if not POSInfocodeUtil.ViewVoucherEntries(VoucherNo, ErrorText) then begin
                    CurrInput := '';
                    //SetFunctionMode("LSC POS Command"::DAENTRCODE);
                    PosTransactionGui.ErrorBeep(ErrorText);
                    ClearGlobs;
                    exit;
                end else begin
                    SetFunctionMode(OldFuncMode);
                    ClearGlobs;
                    InfoTextDescription := '';
                    InfoTextDescription2 := '';
                    CurrInput := '';
                    exit;
                end;
            end else begin
                if not POSInfocodeUtil.ViewDataEntryBalance(PosDataEntryTypeCode, VoucherNo, TSError, DataEntryBalance, ExpirationDate, ErrorText) then begin
                    SetFunctionMode(OldFuncMode);
                    ClearGlobs;
                    CurrInput := '';
                    PosTransactionGui.ErrorBeep(ErrorText);
                end else begin
                    DataEntryType_l := PosDataEntryTypeCode;
                    SetFunctionMode(OldFuncMode);
                    ClearGlobs;
                    CurrInput := '';
                    if ErrorText = '' then begin
                        POSTransactionEvents.OnValidateDataEntryInputExpirationDate(DataEntryBalance, ExpirationDate, IsHandled);
                        if not IsHandled then
                            if ExpirationDate <> 0D then
                                PosTransactionGui.MessageBeep(StrSubstNo(CurrBalanceAndExpiration, FormatAmount(DataEntryBalance), TypeHelper.FormatDate(ExpirationDate, WindowsLanguage)))
                            else
                                PosTransactionGui.MessageBeep(StrSubstNo(CurrBalanceIsMsg, FormatAmount(DataEntryBalance)))
                    end else
                        PosTransactionGui.MessageBeep(ErrorText);
                    if PosDataEntryType_l.Get(DataEntryType_l) then
                        if PosDataEntryType_l."Print Remaining Balance" then begin
                            PrintUtil.Init();
                            PrintUtil.PrintDataEntryRemainingAmt(DataEntryBalance);
                        end;
                end;
            end;
        end;
    end;

    procedure ViewDataEntryBalance(Parameter: Text[50])
    begin
        if not REC."New Transaction" then
            if STATE <> "LSC POS Transaction State"::PAYMENT then begin
                PosTransactionGui.ErrorBeep(CommandNotAllowedInStateErr);
                exit;
            end;

        PosDataEntryTypeCode := Parameter;
        PosDataEntryBalanceOnly := true;
        AskForDataEntryNo;
    end;

    procedure ChangeBackAmount(): Decimal
    begin
        exit(Remaining);
    end;

    procedure ChangeBackAmoungFCY(): Decimal
    begin
        exit(RemainingFCY);
    end;

    procedure RefundLinePressed()
    begin
        Clear(LineRec);
        POSLINES.GetCurrentLine(LineRec);

        if LineRec."Entry Type" <> LineRec."Entry Type"::Item then
            exit;

        ChangeQtyPressed(Format(LineRec.Quantity * -1));
    end;

    procedure AddSalesPerson(Header: Boolean)
    var
        POSTransAddSalesperson: Record "LSC POS Trans. Add. Salesp.";
        tmpStaff: Record "LSC Staff";
        StaffStoreLink: Record "LSC STAFF Store Link";
        StaffStoreOk: Boolean;
        InavlidInMsg: Label 'Invalid %1 in %2 %3';
        SalesPersonBlockedErr: Label '%1 %2 is blocked!';
    begin
        if PosFuncProfile."Sales Person Mode" = PosFuncProfile."Sales Person Mode"::" " then begin
            PosTransactionGui.MessageBeep('');
            exit;
        end;

        // if CurrInput = '' then begin
        //     if Header then
        //         SetFunctionMode("LSC POS Command"::ADDSALESP)
        //     else
        //         SetFunctionMode("LSC POS Command"::ADDSALESP_L);
        //     exit;
        // end;

        if not tmpStaff.Get(CopyStr(CurrInput, 1, 20)) then begin
            PosTransactionGui.ErrorBeep(StrSubstNo(IsNotOnFileErr, tmpStaff.TableCaption, CurrInput));
            exit;
        end;
        if tmpStaff."Sales Person" = '' then begin
            PosTransactionGui.ErrorBeep(StrSubstNo(InavlidInMsg, tmpStaff.FieldCaption("Sales Person"), tmpStaff.TableCaption, CurrInput));
            exit;
        end;

        if tmpStaff.Blocked then begin
            PosTransactionGui.ErrorBeep(StrSubstNo(SalesPersonBlockedErr, tmpStaff.TableCaption, tmpStaff.ID));
            exit;
        end;

        StaffStoreOk := false;
        if tmpStaff."Store No." = '' then
            StaffStoreOk := true;
        if (not StaffStoreOk) and (tmpStaff."Store No." <> '') and (tmpStaff."Store No." = POSSESSION.StoreNo) then
            StaffStoreOk := true;
        if (not StaffStoreOk) and StaffStoreLink.Get(tmpStaff.ID, POSSESSION.StoreNo) then
            StaffStoreOk := true;
        if (not StaffStoreOk) then begin
            PosTransactionGui.ErrorBeep(StaffIdNotInStoreErr);
            exit;
        end;

        if (tmpStaff."Employment Type" <> tmpStaff."Employment Type"::"Sales Person") and
           (tmpStaff."Employment Type" <> tmpStaff."Employment Type"::Both) then begin
            tmpStaff."Employment Type" := tmpStaff."Employment Type"::"Sales Person";
            PosTransactionGui.ErrorBeep((StrSubstNo(IsNotErr, tmpStaff.TableCaption, CurrInput, tmpStaff."Employment Type")));
            exit;
        end;

        if (PosFuncProfile."Sales Person Mode" <> PosFuncProfile."Sales Person Mode"::" ") and
           (REC."Sales Staff" <> CopyStr(CurrInput, 1, 20))
        then begin
            POSTransAddSalesperson."Receipt No." := REC."Receipt No.";
            POSTransAddSalesperson."Line No." := 0;
            if not (Header) then
                POSTransAddSalesperson."Line No." := POSLINES.GetCurrentLineNo;

            POSTransAddSalesperson."Staff ID" := CopyStr(CurrInput, 1, 20);
            POSTransAddSalesperson."Store No." := REC."Store No.";
            POSTransAddSalesperson.Date := REC."Trans. Date";
            POSTransAddSalesperson.Time := REC."Trans Time";
            POSTransAddSalesperson."POS Terminal No." := REC."POS Terminal No.";
            if not (POSTransAddSalesperson.Insert) then;
        end;

        PosTransactionGui.MessageBeep(StrSubstNo(SalesPersonRegisteredErr, CurrInput));
        CurrInput := '';
        //SetFunctionMode("LSC POS Command"::ITEM);
    end;

    procedure FindIncExpFixedAmount(pAccountNo: Code[20]): Text[30]
    var
        MenuLine2_l: Record "LSC POS Menu Line";
        FunctionSetup2: Record "LSC POS Command";
        ReturnValue: Text[30];
    begin
        FunctionSetup2.Get(Format("LSC POS Command"::POPUPINCEXPAMOUNT));
        Clear(MenuLine2_l);

        PopulatePOSMenuLineForCodeunitRun(Format("LSC POS Command"::POPUPINCEXPAMOUNT), pAccountNo, MenuLine2_l, LineRec, false, true);
        PopupPOSComm.Run(MenuLine2_l);
        ReturnValue := MenuLine2_l."Current-INPUT";

        exit(ReturnValue);
    end;

    procedure FlagWaitDrawerClose()
    begin
        POSGUI.SetWaitDrawerCloseFlag;
    end;

    procedure ChangeSalesType(SalesTypeIn: Code[20]; Command: Code[20])
    var
        PosCommandRec: Record "LSC POS Command";
        PosCommand: Enum "LSC POS Command";
    begin
        // if not PosCommandRec.CommandExists(Command, PosCommand) then
        //     exit;
        // ChangeSalesType(SalesTypeIn, PosCommand);
    end;

    procedure ChangeSalesType(SalesTypeIn: Code[20]; PosCommand: Enum "LSC POS Command")
    var
        PosTrLine: Record "LSC POS Trans. Line";
        PosPriceUtility: Codeunit "LSC POS Price Utility";
        PopupFunctions: Codeunit "LSC Pop-up Functions";
        ErrorTxt: Text;
        RecSalesType: Code[20];
        IsHandled: Boolean;
        ErrorStoreSalesTypeFilterMissing: Label 'To use this command, %1 needs to be filled out.';
        HasToBeInMsg: Label '%1 has to be in %2 %3: %4';
    begin
        // if SalesTypeIn = '' then begin
        //     if PosCommand = PosCommand::SETSALESTYPE_TRANS then
        //         RecSalesType := REC."Sales Type";
        //     if not PopupFunctions.GetSalesTypeParameterFromPopup(Format(PosCommand), RecSalesType, PosTerminal, StoreSetup, (GlobalHospTypeSeq <> 0), ErrorTxt) then
        //         PosTransactionGui.ErrorBeep(errortxt);
        //     exit;
        // end;
        POSTransactionEvents.OnBeforeChangeSalesType(SalesTypeIn, PosCommand);
        if not SalesTypeRec.Get(SalesTypeIn) then
            exit;
        if GlobalHospTypeSeq <> 0 then
            if PosTerminal."Sales Type Filter" <> '' then
                if not BOUtils.IsCodeInFilter(PosTerminal."Sales Type Filter", SalesTypeIn) then begin
                    PosTransactionGui.MessageBeep(StrSubstNo(HasToBeInMsg, REC.FieldCaption("Sales Type"), PosTerminal.TableCaption,
                      PosTerminal.FieldCaption("Sales Type Filter"), PosTerminal."Sales Type Filter"));
                    exit;
                end;
        if GlobalHospTypeSeq = 0 then
            if StoreSetup."Store Sales Type Filter" = '' then begin
                PosTransactionGui.MessageBeep(StrSubstNo(ErrorStoreSalesTypeFilterMissing, StoreSetup.FieldCaption("Store Sales Type Filter")));
                exit;
            end else
                if not BOUtils.IsCodeInFilter(StoreSetup."Store Sales Type Filter", SalesTypeIn) then begin
                    PosTransactionGui.MessageBeep(StrSubstNo(HasToBeInMsg, REC.FieldCaption("Sales Type"), StoreSetup.TableCaption,
                      StoreSetup.FieldCaption("Store Sales Type Filter"), StoreSetup."Store Sales Type Filter"));
                    exit;
                end;
        case PosCommand of
            PosCommand::SETSALESTYPE_LINES:
                begin
                    if LineSalesType <> SalesTypeIn then begin
                        LineSalesType := SalesTypeIn;
                        LinePriceGroup := SalesTypeRec."Price Group";
                    end else begin
                        SalesTypeRec.Get(GLobalSalesType);
                        LineSalesType := GLobalSalesType;
                        LinePriceGroup := SalesTypeRec."Price Group";
                    end;
                end;
            PosCommand::CHSALESTYPE_LINES:
                begin
                    // if not HospFunc.SwitchSalesTypeInMarkedTransactionLines(REC, SalesTypeIn, StoreSetup, POSLINES.GetCurrentLineNo(), ErrorTxt) then begin
                    //     PosTransactionGui.ErrorBeep(ErrorTxt);
                    //     exit;
                    // end;

                    PosPriceUtility.CalcPeriodicOnTotalPressed(REC);
                    PosFunc.RecalcSlip(REC);
                end;
            PosCommand::SETSALESTYPE_TRANS:
                begin
                    PosTrLine.Reset;
                    PosTrLine.SetRange("Receipt No.", REC."Receipt No.");
                    PosTrLine.SetFilter("Line No.", '<>%1', LineRec."Line No.");
                    if PosTrLine.FindFirst then begin
                        PosTransactionGui.ErrorBeep(CurrTransMustBeFinishedErr);
                        exit;
                    end;
                    if REC."Sales Type" = SalesTypeIn then
                        exit;
                    // if not HospFunc.SwitchSalesTypeInTransaction(
                    //   REC, SalesTypeIn, StoreSetup."Store VAT Bus. Post. Gr.", false, GLobalSalesType, GlobalHospTypeSeq, CurrTableNo, CurrTableDescr, ErrorTxt)
                    // then begin
                    //     PosTransactionGui.ErrorBeep(ErrorTxt);
                    //     exit;
                    // end;
                    REC.Modify(true);
                    LineSalesType := REC."Sales Type";
                    LinePriceGroup := REC."Price Group Code";
                end;
            PosCommand::CHSALESTYPE_TRANS:
                begin
                    POSTransactionEvents.OnBeforeProcess_CHSALESTYPE_TRANS(REC, SalesTypeIn, IsHandled);
                    if IsHandled then
                        exit;
                    if SalesTypeIn <> REC."Sales Type" then begin
                        // if not HospFunc.SwitchSalesTypeInTransaction(
                        //   REC, SalesTypeIn, StoreSetup."Store VAT Bus. Post. Gr.", true, GLobalSalesType, GlobalHospTypeSeq, CurrTableNo, CurrTableDescr, ErrorTxt)
                        // then begin
                        //     PosTransactionGui.ErrorBeep(ErrorTxt);
                        //     exit;
                        // end;
                        // REC.Modify(true);
                    end;

                    LineSalesType := REC."Sales Type";
                    LinePriceGroup := REC."Price Group Code";

                    //POSTransactionEventsPub.OnBeforeFindPOSTrLineCHSALESTYPETRANS();

                    // HospFunc.SwitchSalesTypeInTransactionLines(REC, SalesTypeIn, StoreSetup);

                    PosPriceUtility.CalcPeriodicOnTotalPressed(REC);
                    PosFunc.RecalcSlip(REC);
                end;
        end;
    end;

    procedure IssueCouponPressed(IssueCouponCode: Code[10])
    var
        CouponHeader: Record "LSC Coupon Header";
        NoEmptyCouponErr: Label 'Coupon Code must be filled out in Menu Button';
        CouponNotFoundErr: Label 'Coupon Code %1 does not exist';
        CouponNotEnabledErr: Label 'Coupon %1 is not Enabled.';
    begin
        if STATE = "LSC POS Transaction State"::TENDOP then begin
            PosTransactionGui.ErrorBeep(CouponsNotAllowedInStateErr);
            exit;
        end;

        if IssueCouponCode = '' then begin
            PosTransactionGui.ErrorBeep(NoEmptyCouponErr);
            exit;
        end;
        if not CouponHeader.Get(IssueCouponCode) then begin
            PosTransactionGui.ErrorBeep(StrSubstNo(CouponNotFoundErr, IssueCouponCode));
            exit;
        end;
        if CouponHeader.Status <> CouponHeader.Status::Enabled then begin
            PosTransactionGui.ErrorBeep(StrSubstNo(CouponNotEnabledErr, IssueCouponCode));
            exit;
        end;
        if (STATE <> "LSC POS Transaction State"::SALES) or (POSGUI.GetCurrMenu(0) <> POSSESSION.GetSalesMenu) then begin
            SetPOSState("LSC POS Transaction State"::SALES);
            //SetFunctionMode("LSC POS Command"::ITEM);
            SelectDefaultMenu;
            REC."Transaction Type" := REC."Transaction Type"::Sales;
        end;
        if REC."New Transaction" then
            REC."New Transaction" := false;
        InsertCouponLine('', CouponHeader, NewLine."Coupon Function"::Issue, false, CouponHeader."Discount Type", CouponHeader.Value);
        InfoTextDescription := CopyStr(CouponHeader.Description, 1, MaxStrLen(InfoTextDescription));
        InfoTextDescription2 := CopyStr(CouponHeader."Description 2", 1, MaxStrLen(InfoTextDescription2));
    end;

    procedure InsertCouponLine(CouponBarcode: Code[22]; CouponHeader: Record "LSC Coupon Header"; IssueOrUse: Integer; AutomaticallyCreated: Boolean; DiscountType: Integer; DiscountValue: Decimal)
    var
        CouponManagement: Codeunit "LSC Coupon Management";
        RetailPriceUtils: Codeunit "LSC Retail Price Utils";
        ErrorTxt: Text[250];
        LastLineNo: Integer;
        IsHandled: Boolean;
    begin
        LastLineNo := LineRec."Line No.";
        InitNewLine();
        NewLine."Entry Type" := NewLine."Entry Type"::Coupon;
        NewLine."Coupon Function" := IssueOrUse;
        NewLine."Coupon Code" := CouponHeader.Code;
        NewLine."Coupon Barcode No." := CouponBarcode;
        NewLine."Valid in Transaction" := true;

        if (CouponBarcode = CouponHeader.Code) or (CouponBarcode = '') then
            if NewLine."Coupon Function" = NewLine."Coupon Function"::Issue then
                NewLine."Coupon Barcode No." := CouponManagement.CreateCouponBarcode(CouponHeader, 0, ErrorTxt);

        if DiscountType = CouponHeader."Discount Type"::"Discount Amount" then begin
            NewLine."Coupon Amount" := DiscountValue;
            if (CouponHeader."Multiply Value Period ID" <> '') and (CouponHeader."Multiply Value" <> 0) then
                if RetailPriceUtils.DiscValPerValid(CouponHeader."Multiply Value Period ID", REC."Trans. Date", REC."Trans Time") then
                    NewLine."Coupon Amount" := DiscountValue * CouponHeader."Multiply Value";
            NewLine."Coupon Discount %" := 0;
        end
        else begin
            NewLine."Coupon Amount" := 0;
            NewLine."Coupon Discount %" := DiscountValue;
        end;
        NewLine.Description := CopyStr(CouponHeader.Description, 1, MaxStrLen(NewLine.Description));
        NewLine."Automatically Created" := AutomaticallyCreated;
        if (CouponHeader.Affects = CouponHeader.Affects::"Last Item Line") or
          (CouponHeader.Affects = CouponHeader.Affects::"Next Item Line") then
            NewLine."Coupon Linked to Line No." := LastLineNo;
        POSTransactionEvents.OnInsertCouponLineBeforeInsertLine(REC, NewLine, CouponHeader, DiscountValue, IsHandled);
        if IsHandled then
            exit;
        NewLine.InsertLine;
    end;

    procedure IsUOMPopUp(pItem: Record Item; var AllExcluded: Boolean): Boolean
    var
        ItemUOM: Record "Item Unit of Measure";
        ShowAutoPopUp: Boolean;
    begin
        if (newline."Barcode No." <> '') and (newline."Unit of Measure" <> '') then
            exit(false);
        AllExcluded := false;
        ShowAutoPopUp := false;
        if pItem."LSC UOM Pop-up on POS" then
            ShowAutoPopUp := true;

        ItemUOM.Reset;
        ItemUOM.SetRange("Item No.", pItem."No.");
        //ProductExt.FilterOnValidUOMPricesInStore(ItemUOM, pItem."No.", POSSESSION.StoreNo, LineRec."Variant Code");
        if ItemUOM.IsEmpty then begin
            ShowAutoPopUp := false;
            AllExcluded := true;
        end;

        exit(ShowAutoPopUp);
    end;

    procedure UOMPopUp(POSTransLine: Record "LSC POS Trans. Line"): Code[10]
    var
        FunctionSetup2: Record "LSC POS Command";
        MenuLine2_l: Record "LSC POS Menu Line";
    begin
        FunctionSetup2.Get(Format("LSC POS Command"::POPUPUOM));
        Clear(MenuLine2_l);
        PopulatePOSMenuLineForCodeunitRun(Format("LSC POS Command"::POPUPUOM), POSTransLine.Number, MenuLine2_l, LineRec, false, true);

        PopupPOSComm.Run(MenuLine2_l);
        exit(MenuLine2_l."Current-INPUT");
    end;

    procedure ProcessCoupon(var ErrorMsg: Text[250]; ScannedCouponCode: Code[22]; pLineRec: Record "LSC POS Trans. Line"): Boolean
    var
        CouponHeader: Record "LSC Coupon Header";
        CouponEntry: Record "LSC Coupon Entry";
        POSTransLine: Record "LSC POS Trans. Line";
        CouponManagement: Codeunit "LSC Coupon Management";
        POSPriceUtility: Codeunit "LSC POS Price Utility";
        ErrText: Text[250];
        CouponBarcode: Code[22];
        OldState: Enum "LSC POS Transaction State";
        IsHandled, ReturnValue : Boolean;
        CouponOnlyValidNextLastErr: Label 'Coupon only valid for next/last item line. Item not found.';
    begin
        ErrorMsg := '';

        POSTransLine := pLineRec;
        if (REC."Receipt No." = '') and
         (pLineRec."Receipt No." <> '') then
            REC.Get(pLineRec."Receipt No.");

        // if CouponCodeNextItem <> '' then begin
        //     CouponManagement.ReturnCouponHeader(CouponCodeNextItem, REC."POS Terminal No.", CouponHeader, CouponEntry, ErrorMsg);
        //     if ErrorMsg <> '' then
        //         exit(true);
        //     if not CouponManagement.IsCouponValidForItemLine(CouponHeader, POSTransLine) then begin
        //         ErrorMsg := CouponOnlyValidNextLastErr;
        //         exit(true);
        //     end;
        //     ScannedCouponCode := CouponCodeNextItem;
        //     CouponCodeNextItem := '';
        // end
        // else
        //     if not CouponManagement.IsCouponValid(ScannedCouponCode, REC."Member Card No.", CouponHeader, ErrorMsg,
        //        POSTransLine, CouponCodeNextItem, CouponEntry, REC."Store No.")
        //     then begin
        //         if CouponCodeNextItem <> '' then begin
        //             ErrorMsg := ScanItemToTriggerCouponMsg;
        //             exit(true);
        //         end;
        //         if ErrorMsg <> '' then
        //             exit(true);
        //         if CouponHeader.Code = '' then
        //             exit(false);
        //     end
        //     else
        //         if CouponHeader.Code = '' then
        //             exit(false);

        POSTransactionEvents.OnAfterIsCouponValid(REC, POSTransLine, CouponHeader, ErrorMsg, IsHandled, ReturnValue);
        if IsHandled then
            exit(ReturnValue);

        if (STATE <> "LSC POS Transaction State"::SALES) or (POSGUI.GetCurrMenu(0) <> POSSESSION.GetSalesMenu) then begin
            SetPOSState("LSC POS Transaction State"::SALES);
            // SetFunctionMode("LSC POS Command"::ITEM);
            SelectDefaultMenu;
            REC."Transaction Type" := REC."Transaction Type"::Sales;
        end;

        if REC."New Transaction" then begin
            REC."New Transaction" := false;
            REC."Trans. Date" := Today;
            REC."Original Date" := REC."Trans. Date";
            REC."Trans Time" := Time;
            REC.Modify;
        end;

        if CouponHeader.Handling <> CouponHeader.Handling::Tender then begin
            if (CouponEntry."Discount Type" = 0) and (CouponEntry.Value = 0) then begin
                CouponEntry."Discount Type" := CouponHeader."Discount Type";
                if CouponEntry.Value = 0 then
                    CouponEntry.Value := CouponHeader.Value;
            end;
            POSTransactionEvents.OnProcessCouponBeforeInsertCouponLine(CouponEntry);
            InsertCouponLine(ScannedCouponCode, CouponHeader, NewLine."Coupon Function"::Use, false,
              CouponEntry."Discount Type", CouponEntry.Value);
            InfoTextDescription := CopyStr(CouponHeader.Description, 1, MaxStrLen(InfoTextDescription));
            InfoTextDescription2 := CopyStr(CouponHeader."Description 2", 1, MaxStrLen(InfoTextDescription2));
            if CouponHeader."Calculation Type" = CouponHeader."Calculation Type"::"Triggers Offer" then begin
                //POSTransactionEventsPub.OnBeforeAddOffers();
                POSTransLine.Reset;
                POSTransLine.SetRange("Receipt No.", REC."Receipt No.");
                POSTransLine.SetRange("Entry Type", POSTransLine."Entry Type"::Item);
                POSTransLine.SetRange("Entry Status", POSTransLine."Entry Status"::" ");
                if POSTransLine.FindSet then
                    repeat
                        PosFunc.ClearPosTransLineOffers(POSTransLine);
                        POSPriceUtility.InitGlobals(POSTransLine, true);
                        POSPriceUtility.FindPeriodicOffers(POSTransLine);
                        PosFunc.AddPosTransLineOffers(POSTransLine);
                        POSTransLine.Modify(true);
                    until POSTransLine.Next = 0;
                POSPriceUtility.CalcPeriodicOnTotalPressed(REC);
                CalcTotals();
            end;
            exit(true);
        end
        else begin
            TenderTypeTable.Reset;
            TenderTypeTable.SetRange("Default Function", TenderTypeTable."Default Function"::Coupons);
            POSTransactionEvents.OnBeforeFindTenderTypeTable(REC, TenderTypeTable);
            if TenderTypeTable.FindFirst then
                CouponTenderType := TenderTypeTable.Code;
            if CouponTenderType = '' then begin
                PosTransactionGui.ErrorBeep(StrSubstNo(SetupCouponsDefinedErr, TenderTypeTable.TableCaption));
                exit(true);
            end;
            if not TenderType.Get(REC."Store No.", CouponTenderType) then begin
                PosTransactionGui.ErrorBeep(StrSubstNo(SetupCouponsDefinedInErr, TenderType.TableCaption, StoreSetup.TableCaption));
                exit(true)
            end;
            InitNewLine;
            CouponBarcode := CopyStr(CurrInput, 1, 22);
            CurrInput := CouponCode;
            PaymentAmount := 0;
            // if not PosFunc.ValidateTender(TenderType, REC."Gross Amount", Balance, PaymentAmount,
            //   REC."Sale Is Return Sale", false, InfoTextDescription) then begin
            //     PosFunc.DeleteCouponQtyUsed;
            //     PosTransactionGui.ErrorBeep(InfoTextDescription);
            //     exit(true);
            // end;

            OldState := STATE;
            SetPOSState("LSC POS Transaction State"::TENDOP);
            // POSTransactionEventsPub.OnBeforeInsertPaymentLine(REC, PaymentAmount, CouponBarcode);
            InsertPaymentLine;
            SetPOSState(OldState);
            NewLine.Description := CopyStr(CouponHeader.Description, 1, MaxStrLen(NewLine.Description));
            NewLine."Coupon Barcode No." := ScannedCouponCode;
            NewLine."Coupon Code" := CouponHeader.Code;
            if CouponEntry.Value = 0 then
                NewLine."Coupon Amount" := CouponHeader.Value
            else
                NewLine."Coupon Amount" := CouponEntry.Value;
            if CouponBarcode = CouponHeader.Code then
                CouponBarcode := CouponManagement.CreateCouponBarcode(CouponHeader, 0, ErrText);
            NewLine."Coupon EAN Org." := CouponBarcode;
            NewLine.Modify;
            InfoTextDescription := CopyStr(CouponHeader.Description, 1, MaxStrLen(InfoTextDescription));
            InfoTextDescription2 := CopyStr(CouponHeader."Description 2", 1, MaxStrLen(InfoTextDescription2));
            exit(true);
        end;
    end;

    procedure LineDiscOffer(Parameter: Text[50]): Boolean
    var
        OldAmount: Decimal;
        DiscOnlyOnSaleLinesErr: Label 'Discount can only be given on sales line';
    begin
        if (STATE = "LSC POS Transaction State"::TENDOP) or REC."New Transaction" then begin
            PosTransactionGui.MessageBeep('');
            exit(false);
        end;

        POSLINES.GetCurrentLine(LineRec);

        if (LineRec.Number = '') or (LineRec."Entry Status" = LineRec."Entry Status"::Voided) or LineRec."Deal Line" then begin
            PosTransactionGui.MessageBeep('');
            exit(false);
        end;
        if LineRec."Entry Type" <> LineRec."Entry Type"::Item then begin
            PosTransactionGui.ErrorBeep(DiscOnlyOnSaleLinesErr);
            exit(false);
        end;
        if LineRec."System-Block Manual Discount" then begin
            PosTransactionGui.ErrorBeep(DiscNotAllowedForItemErr);
            exit(false);
        end;

        OldAmount := LineRec.Amount;

        PosOfferExt.ProcessLinePreTotal(REC, LineRec, Parameter);
        // if PosOfferExt.TransLineHasManualTransLineDiscOffer(LineRec, Parameter) then
        //     PosOfferExt.ReCalcLinePreTotal(REC);

        WriteMgrStatus;
        CalcTotals;
        CurrInput := '';
        if LineRec.Amount <> OldAmount then
            InfoTextDescription := DiscChangedMsg;
        OposUtil.DisplaySalesLine('', LineRec.Description, LineRec.Quantity, LineRec.Price, LineRec.Amount, LineRec."Unit of Measure", true);

        exit(true);
    end;

    procedure ProcessAddBenefits(lFunctionMode: Enum "LSC POS Command")
    var
        TransBenefitCollectBuffer: Record "LSC Trans. Disc. Benefit Entry" temporary;
        PosPrice: Codeunit "LSC POS Price Utility";
    begin
        CurrFuncMode_g := Format(lFunctionMode);

        // PosFunc.VoidBenefitLines(REC);

        PosPrice.CollectTransAddBenefits(REC."Receipt No.", 1, TransBenefitCollectBuffer);
        TransBenefitCollectBuffer.Reset;

        // if not TransBenefitCollectBuffer.IsEmpty then begin
        //     MultiplyWithTemp := MultiplyWith;
        //     PopupPOSComm.PopUpAdditionalBenefits(TransBenefitCollectBuffer);
        // end;
        exit;
    end;

    procedure ProcessAddBenefitsEx(var TransBenefitCollectBuffer: Record "LSC Trans. Disc. Benefit Entry" temporary)
    var
        POSTransLine2: Record "LSC POS Trans. Line";
        POSTransLine: Record "LSC POS Trans. Line";
        POSTransPeriodicDisc: Record "LSC POS Trans. Per. Disc. Type";
        BOUtils: Codeunit "LSC BO Utils";
        CurrVarCode: Code[10];
        LastLineNo: Integer;
        InsertedOk: Boolean;
        IsHandled: Boolean;
        SavedMultiplyWith: Decimal;
    begin
        //POSTransactionEventsPub.OnBeforeProcessAddBenefitsEx(TransBenefitCollectBuffer, CurrFuncMode_g, IsHandled);
        if IsHandled then
            exit;

        POSTransLine2.SetRange("Receipt No.", REC."Receipt No.");
        POSTransPeriodicDisc.SetRange("Receipt No.", REC."Receipt No.");

        TransBenefitCollectBuffer.Reset;
        if not TransBenefitCollectBuffer.IsEmpty then begin
            SavedMultiplyWith := MultiplyWith;
            MultiplyWith := MultiplyWithTemp;

            if TransBenefitCollectBuffer.FindSet then
                repeat
                    if BOUtils.IsItemComplex(TransBenefitCollectBuffer."No.") then
                        TransBenefitCollectBuffer.Delete
                    else begin
                        POSTransactionEvents.OnBeforeInsertTotalBenefitsLine(REC, TransBenefitCollectBuffer, MultiplyWith);
                        InsertedOk := false;
                        CurrInput := TransBenefitCollectBuffer."No.";
                        CurrVarCode := TransBenefitCollectBuffer."Variant Code";
                        KeyboardPrice := TransBenefitCollectBuffer.Value;
                        if KeyboardPrice = 0 then
                            ExternalZeroPrice := true;
                        LinkedItemsActive := false;
                        BomLineEntry := false;
                        if POSTransLine2.FindLast then
                            LastLineNo := POSTransLine2."Line No."
                        else
                            LastLineNo := 0;
                        IsHandled := false;
                        //POSTransactionEventsPub.OnBeforeCreatingItemLineProcessAddBenefitsEx(REC, TransBenefitCollectBuffer, CurrVarCode, IsHandled);
                        if not IsHandled then
                            ItemLine(false, true, TransBenefitCollectBuffer.Quantity, 0, CurrVarCode, 'SYSTEMEXCL', '', '', 0, 0);
                        if LineRec."Line No." > LastLineNo then
                            if POSTransLine.Get(REC."Receipt No.", LineRec."Line No.") then
                                if POSTransLine.Number = TransBenefitCollectBuffer."No." then
                                    InsertedOk := true;
                        if InsertedOk then begin
                            POSTransPeriodicDisc.SetRange("Line No.", POSTransLine."Line No.");
                            PosFunc.PosTransDiscSetTableFilter(1, POSTransPeriodicDisc);
                            PosFunc.PosTransDiscDeleteAllRec(1);
                            POSTransLine."Benefit Item" := true;
                            POSTransLine."System-Exclude from Offers" := true;
                            POSTransLine."System-Unchangable Quantity" := true;
                            POSTransLine."System-Unchangable Price" := true;
                            POSTransLine."System-Unchangable Discounts" := true;
                            POSTransLine."System-Block Promotion Price" := true;
                            POSTransLine.CalcPrices;
                            POSTransLine.Modify(true);
                        end else
                            TransBenefitCollectBuffer.Delete;
                    end;
                until TransBenefitCollectBuffer.Next = 0;
            // PosFunc.SetTransBenefitBuffer(TransBenefitCollectBuffer);

            MultiplyWith := SavedMultiplyWith;
            MultiplyWithTemp := 0;
            SetFunctionMode(CurrFuncMode_g);
        end;
        // POSTransactionEventsPub.OnAfterProcessAddBenefitsEx(TransBenefitCollectBuffer, POSTransLine, CurrFuncMode_g);
    end;

    procedure ProcessTenderOfferAtTotal(pTenderTypeCode: Code[10]): Boolean
    var
        PosTransTenderTemp: Record "LSC POS Trans. Line" temporary;
        AdditionalPOSCommands: Codeunit "LSC Additional POS Commands";
        CurrPayment: Decimal;
        TenderOffersAvailable: Boolean;
        SkipPopUp: Boolean;
    begin
        ProcessTenderOffers := false;

        // TenderOffersAvailable := PosOfferExt.GetPopUpTenderTypeOffer(REC, pTenderTypeCode, PosTransTenderTemp);
        if not TenderOffersAvailable then
            exit(false);

        SkipPopUp := false;

        if pTenderTypeCode <> '' then begin
            SkipPopUp := true;
            if not PosTransTenderTemp.FindFirst then
                exit(false);
            if PosTransTenderTemp.Count > 1 then
                SkipPopUp := false;
            if SkipPopUp then begin
                TenderTypeTable.Get(PosTransTenderTemp.Number);
                TenderOfferNewBalanc := PosTransTenderTemp.Amount;
                if not Evaluate(CurrPayment, CurrInput) then
                    SkipPopUp := false;
            end;
            if SkipPopUp then begin
                //   PosFunc.AdjustAmount(CurrPayment);
                if CurrPayment < TenderOfferNewBalanc then
                    SkipPopUp := false;
            end;
        end;

        // if not SkipPopUp then
        //     AdditionalPOSCommands.TenderOfferLookup(PosTransTenderTemp);

        exit(true);
    end;

    procedure ProcessTenderOfferAtTotalOnClose(var PosTransTenderTemp: Record "LSC POS Trans. Line" temporary): Boolean
    begin
        if PosTransTenderTemp.FindFirst then begin
            ProcessTenderOffers := true;
            TenderTypeTable.Get(PosTransTenderTemp.Number);
            if TenderTypeTable."Default Card Tender" then begin
                TenderOfferNewBalanc := PosTransTenderTemp.Amount;
                CardType := PosTransTenderTemp."Card Type";
                TenderKeyPressed(PosTransTenderTemp.Number);
            end else
                if TenderTypeTable."Default Currency Tender" then begin
                    TenderOfferNewBalanc := PosTransTenderTemp.Amount;
                    TenderKeyPressed(PosTransTenderTemp.Number);
                    if FunctionSetup."Function Code" = Format("LSC POS Command"::CURRENCY) then
                        CurrencyTenderOfferAtTotalOnClose(PosTransTenderTemp);
                end else begin
                    TenderOfferNewBalanc := PosTransTenderTemp.Amount;
                    TenderKeyPressed(PosTransTenderTemp.Number);
                end;
            exit(true);
        end else
            exit(false);
    end;

    internal procedure CurrencyTenderOfferAtTotalOnClose(PosTransTenderTemp: Record "LSC POS Trans. Line" temporary)
    begin
        CurrInput := format(PosTransTenderTemp.Amount);
        CurrencyKeyPressed(PosTransTenderTemp."Currency Code", 0);
        CurrInput := '';
    end;

    procedure TenderCharge(pStoreNo: Code[10]; var pTenderType: Record "LSC Tender Type"; pCurrentInput: Text; var pTmp: Record "LSC Report Temp Table" temporary; pCardType: Code[10]): Integer
    var
        lTenderTypeSetup: Record "LSC Tender Type Setup";
        lTenderTypeCardSetup: Record "LSC Tender Type Card Setup";
        lTmp: Record "LSC Report Temp Table" temporary;
        lAdditionalPOSCommands: Codeunit "LSC Additional POS Commands";
        lPaymentAmount: Decimal;
        lKey: Integer;
        CHARGE_ZERO: Integer;
        CHARGE_ACCEPTED: Integer;
        CHARGE_CANCEL: Integer;
        lSelected: Boolean;
        TenderChargeContinueQst: Label 'Tender charge is %1% or %2.\Total amount is %3.\Do you want to continue?';
    begin
        // Return values:
        // CHARGE_ZERO     - No Charge defined for Tender Type
        // CHARGE_ACCEPTED - Tender Charge Accepted
        // CHARGE_CANCEL   - Tender Charge not accepted or error

        CHARGE_ZERO := 0;
        CHARGE_ACCEPTED := 1;
        CHARGE_CANCEL := 2;
        //No charge on tender type currency
        lTenderTypeSetup.SetRange("Default Currency Tender", true);
        if lTenderTypeSetup.FindFirst then
            if pTenderType.Code = lTenderTypeSetup.Code then
                exit(CHARGE_CANCEL);

        if pCurrentInput = '' then
            lPaymentAmount := Balance
        else
            if not Evaluate(lPaymentAmount, pCurrentInput) then begin
                PosTransactionGui.ErrorBeep(InvalidAmtValueErr);
                exit(CHARGE_CANCEL);
            end;
        if Balance < lPaymentAmount then
            lPaymentAmount := Balance;
        lSelected := false;
        pTmp.Reset;
        pTmp.DeleteAll;
        lTmp.Reset;
        lTmp.DeleteAll;
        lTenderTypeSetup.Reset;
        lTenderTypeSetup.SetRange("Default Card Tender", true);
        if lTenderTypeSetup.FindFirst then;
        if pTenderType.Code = lTenderTypeSetup.Code then begin //Cards
            lTenderTypeCardSetup.SetRange("Store No.", pStoreNo);
            lTenderTypeCardSetup.SetRange("Tender Type Code", pTenderType.Code);
            if pCardType <> '' then
                lTenderTypeCardSetup.SetRange("Card No.", pCardType);
            lTenderTypeCardSetup.SetFilter("Charge to Account No.", '<>%1', '');
            lTenderTypeCardSetup.SetFilter("Charge %", '>0');
            case lTenderTypeCardSetup.Count of
                0:
                    exit(CHARGE_ZERO);
                1:
                    begin
                        lTenderTypeCardSetup.SetRange("Charge %");
                        if lTenderTypeCardSetup.Count > 1 then begin
                            if lTenderTypeCardSetup.FindSet then begin
                                lKey := 0;
                                repeat
                                    lKey := lKey + 1;
                                    lTmp.Init;
                                    lTmp."User ID" := Format(lKey);
                                    lTmp.Description := lTenderTypeCardSetup.Description;
                                    lTmp.Amount := lPaymentAmount;
                                    lTmp.Amount2 := lTenderTypeCardSetup."Charge %";
                                    lTmp.Amount3 := lTmp.Amount * lTmp.Amount2 / 100;
                                    lTmp."Sales Amount" := PosFunc.RoundTender(pTenderType, lTmp.Amount * (100 + lTmp.Amount2) / 100);
                                    lTmp."Sort Amount" := lTmp."Sales Amount";
                                    lTmp."Sort Code" := lTenderTypeCardSetup."Charge to Account No.";
                                    lTmp.Insert;
                                until lTenderTypeCardSetup.Next = 0;
                                //  lAdditionalPOSCommands.TenderChargeLookup(lTmp, TenderChargeSelect);
                                if lTmp.Count = 0 then
                                    exit(CHARGE_CANCEL);
                                lSelected := true;
                                if TenderChargeSelect = -1 then
                                    exit(-1);
                            end;
                        end
                        else
                            if lTenderTypeCardSetup.FindFirst then begin
                                lTmp.Init;
                                lTmp."User ID" := Format(1);
                                lTmp.Amount := lPaymentAmount;
                                lTmp.Amount2 := lTenderTypeCardSetup."Charge %";
                                lTmp.Amount3 := lTmp.Amount * lTmp.Amount2 / 100;
                                lTmp."Sales Amount" := PosFunc.RoundTender(pTenderType, lTmp.Amount * (100 + lTmp.Amount2) / 100);
                                lTmp."Sort Code" := lTenderTypeCardSetup."Charge to Account No.";
                                lTmp.Insert;
                            end else
                                exit(CHARGE_CANCEL); //should not happen
                    end;
                else begin
                    lTenderTypeCardSetup.SetRange("Charge %");
                    if lTenderTypeCardSetup.FindSet then begin
                        lKey := 0;
                        repeat
                            lKey := lKey + 1;
                            lTmp.Init;
                            lTmp."User ID" := Format(lKey);
                            lTmp.Description := lTenderTypeCardSetup.Description;
                            lTmp.Amount := lPaymentAmount;
                            lTmp.Amount2 := lTenderTypeCardSetup."Charge %";
                            lTmp.Amount3 := lTmp.Amount * lTmp.Amount2 / 100;
                            lTmp."Sales Amount" := PosFunc.RoundTender(pTenderType, lTmp.Amount * (100 + lTmp.Amount2) / 100);
                            lTmp."Sort Amount" := lTmp."Sales Amount";
                            lTmp."Sort Code" := lTenderTypeCardSetup."Charge to Account No.";
                            lTmp.Insert;
                        until lTenderTypeCardSetup.Next = 0;
                        //lAdditionalPOSCommands.TenderChargeLookup(lTmp, TenderChargeSelect);
                        if lTmp.Count = 0 then
                            exit(CHARGE_CANCEL);
                        lSelected := true;
                        if TenderChargeSelect = -1 then
                            exit(-1);
                    end;
                end;
            end; //case
        end else begin //Not Currency or Card
            if (pTenderType."Charge %" > 0) and (pTenderType."Charge to Account No." <> '') then begin
                lTmp.Init;
                lTmp."User ID" := Format(1);
                lTmp.Amount := lPaymentAmount;
                lTmp.Amount2 := pTenderType."Charge %";
                lTmp.Amount3 := lTmp.Amount * lTmp.Amount2 / 100;
                lTmp."Sales Amount" := PosFunc.RoundTender(pTenderType, lTmp.Amount * (100 + lTmp.Amount2) / 100);
                lTmp."Sort Code" := pTenderType."Charge to Account No.";
                lTmp.Insert;
            end else
                exit(CHARGE_ZERO);
        end;
        if not lSelected then begin
            if PosTransactionGui.PosConfirm(StrSubstNo(TenderChargeContinueQst, lTmp.Amount2,
                                   FormatAmount(lTmp.Amount3),
                                   FormatAmount(lTmp."Sales Amount")), false) then begin
                pTmp := lTmp;
                exit(CHARGE_ACCEPTED);
            end else
                exit(CHARGE_CANCEL);
        end else begin
            pTmp := lTmp;
            exit(CHARGE_ACCEPTED);
        end;
    end;

    procedure RemoveCouponDiscount(var POSTransLine: Record "LSC POS Trans. Line"): Boolean
    var
        POSTransPeriodicDisc: Record "LSC POS Trans. Per. Disc. Type";
        POSTransPeriodicDisc2: Record "LSC POS Trans. Per. Disc. Type";
        CouponHeader: Record "LSC Coupon Header";
        POSTransLineLocal: Record "LSC POS Trans. Line";
        OfferLocal: Record "LSC Offer";
        PeriodicDiscountLocal: Record "LSC Periodic Discount";
        OfferPOSCalculation: Record "LSC Offer Pos Calculation";
        MixMatchLine: Record "LSC POS Mix & Match Entry";
        POSPriceUtility: Codeunit "LSC POS Price Utility";
        EntryStatus: Option " ",Voided;
        RemoveDiscountLines: Boolean;
    begin
        if (POSSESSion.GetValue('EXCHANGE_PRESSED_EX') = '1') then
            exit(RemoveDiscountLines);

        POSTransPeriodicDisc.Reset;
        POSTransPeriodicDisc.SetRange("Receipt No.", POSTransLine."Receipt No.");

        if POSTransLine."Entry Type" = POSTransLine."Entry Type"::Coupon then
            POSTransPeriodicDisc.SetRange("Coupon POS Trans. Line No.", POSTransLine."Line No.")
        else
            POSTransPeriodicDisc.SetRange("Line No.", POSTransLine."Line No.");

        POSTransPeriodicDisc.SetRange(DiscType, POSTransPeriodicDisc.DiscType::Coupon);
        PosFunc.PosTransDiscSetTableFilter(1, POSTransPeriodicDisc);
        if PosFunc.PosTransDiscFindSetRec(1, POSTransPeriodicDisc) then begin
            repeat
                POSTransLine."Line Disc. %" := POSTransLine."Line Disc. %" - POSTransPeriodicDisc."Discount %";
                PosFunc.PosTransDiscDeleteRec(POSTransPeriodicDisc);
                if POSTransLine."Entry Type" = POSTransLine."Entry Type"::Coupon then
                    if POSTransLineLocal.Get(POSTransPeriodicDisc."Receipt No.", POSTransPeriodicDisc."Line No.") then begin
                        POSTransLineLocal.CalcPrices();
                        POSTransLineLocal.Modify;
                    end;
            until PosFunc.PosTransDiscNextRec(1, 1, POSTransPeriodicDisc) = 0;
            POSTransLine.CalcPrices();
            POSTransLine.Modify;
        end;
        if POSTransLine."Entry Type" = POSTransLine."Entry Type"::Coupon then
            if CouponHeader.Get(POSTransLine."Coupon Code") then
                if CouponHeader."Calculation Type" = CouponHeader."Calculation Type"::"Triggers Offer" then begin
                    EntryStatus := POSTransLine."Entry Status";
                    POSTransLine."Entry Status" := POSTransLine."Entry Status"::Voided;
                    POSTransLine.Modify;
                    POSTransPeriodicDisc.Reset;
                    POSTransPeriodicDisc.SetRange("Receipt No.", POSTransLine."Receipt No.");
                    POSTransPeriodicDisc.SetFilter(DiscType, '<>%1', POSTransPeriodicDisc.DiscType::Coupon);
                    POSTransPeriodicDisc.SetFilter("Offer No.", '<>%1', '');
                    PosFunc.PosTransDiscSetTableFilter(1, POSTransPeriodicDisc);
                    if PosFunc.PosTransDiscFindSetRec(1, POSTransPeriodicDisc) then
                        repeat
                            RemoveDiscountLines := false;
                            if OfferLocal.Get(POSTransPeriodicDisc."Offer No.") then
                                if OfferLocal."Coupon Code" = CouponHeader.Code then
                                    RemoveDiscountLines := true;
                            if not RemoveDiscountLines then
                                if PeriodicDiscountLocal.Get(POSTransPeriodicDisc."Offer No.") then
                                    if PeriodicDiscountLocal."Coupon Code" = CouponHeader.Code then
                                        RemoveDiscountLines := true;
                            if RemoveDiscountLines then begin
                                POSTransPeriodicDisc2.Reset;
                                POSTransPeriodicDisc2.SetRange("Receipt No.", POSTransLine."Receipt No.");
                                POSTransPeriodicDisc2.SetRange(DiscType, POSTransPeriodicDisc.DiscType);
                                POSTransPeriodicDisc2.SetRange("Offer No.", POSTransPeriodicDisc."Offer No.");
                                PosFunc.PosTransDiscSetTableFilter(2, POSTransPeriodicDisc2);
                                if PosFunc.PosTransDiscFindSetRec(2, POSTransPeriodicDisc2) then
                                    repeat
                                        PosFunc.PosTransDiscDeleteRec(POSTransPeriodicDisc2);
                                        OfferPOSCalculation.Reset;
                                        OfferPOSCalculation.SetRange("Receipt No.", POSTransPeriodicDisc2."Receipt No.");
                                        OfferPOSCalculation.SetRange("Periodic Disc. Type", POSTransPeriodicDisc2."Periodic Disc. Type" - 1);
                                        OfferPOSCalculation.SetFilter("Group No.", '%1', POSTransPeriodicDisc2."Offer No.");
                                        OfferPOSCalculation.SetFilter("Trans. Line No.", '%1', POSTransPeriodicDisc2."Line No.");
                                        if OfferPOSCalculation.FindSet then
                                            OfferPOSCalculation.DeleteAll;
                                        if POSTransLineLocal.Get(POSTransPeriodicDisc2."Receipt No.", POSTransPeriodicDisc2."Line No.") then
                                            PosFunc.ClearPosTransLineOffers(POSTransLineLocal);
                                        MixMatchLine.Reset;
                                        MixMatchLine.SetCurrentKey("Receipt No.", "Line No.");
                                        MixMatchLine.SetRange("Receipt No.", POSTransLineLocal."Receipt No.");
                                        MixMatchLine.SetRange("Line No.", POSTransLineLocal."Line No.");
                                        if MixMatchLine.FindFirst then
                                            MixMatchLine.Delete;
                                        if POSTransLineLocal."Disc. Info Line No." <> 0 then begin
                                            if not POSTransLineLocal."Deal Line" then
                                                POSTransLineLocal."Disc. Info Line No." := 0;
                                            POSTransLineLocal.CalcPrices();
                                            POSTransLineLocal.Modify;
                                        end;
                                        if POSTransLineLocal."Entry Type" = POSTransLineLocal."Entry Type"::PerDiscount then
                                            POSTransLineLocal.Delete;
                                    until PosFunc.PosTransDiscNextRec(2, 1, POSTransPeriodicDisc2) = 0;
                            end;
                        until PosFunc.PosTransDiscNextRec(1, 1, POSTransPeriodicDisc) = 0;
                    POSPriceUtility.CalcPeriodicOnTotalPressed(REC);
                    POSTransLine."Entry Status" := EntryStatus;
                    POSTransLine.Modify;
                end;
        exit(RemoveDiscountLines);
    end;

    procedure GetNewBalanceTenderOffer(pTenderTypeCode: Code[10]): Decimal
    var
        PosTransTenderTemp: Record "LSC POS Trans. Line" temporary;
        TenderType_l: Record "LSC Tender Type";
        RoundedBalance: Decimal;
        TenderOffersAvailable: Boolean;
    begin
        //TenderOffersAvailable := PosOfferExt.GetPopUpTenderTypeOffer(REC, pTenderTypeCode, PosTransTenderTemp);

        RoundedBalance := Balance;
        if TenderType_l.Get(REC."Store No.", pTenderTypeCode) then begin
            case TenderType_l.Rounding of
                TenderType_l.Rounding::Nearest:
                    RoundedBalance := Round(Balance, TenderType_l."Rounding To", '=');
                TenderType_l.Rounding::Up:
                    RoundedBalance := Round(Balance, TenderType_l."Rounding To", '>');
                TenderType_l.Rounding::Down:
                    RoundedBalance := Round(Balance, TenderType_l."Rounding To", '<');
            end;
        end;

        if not TenderOffersAvailable then
            exit(RoundedBalance);

        if PosTransTenderTemp.Count > 1 then
            exit(RoundedBalance);

        if not PosTransTenderTemp.FindFirst then
            exit(RoundedBalance)
        else
            exit(PosTransTenderTemp.Amount);
    end;

    procedure ShowDiscInfo()
    var
        AddPosComm: Codeunit "LSC Additional POS Commands";
        CouponManagement: Codeunit "LSC Coupon Management";
    begin
        CouponManagement.ApplyCouponsToTransaction(REC, false, false);
        Commit;
        // AddPosComm.ShowDiscountInfo(REC);
    end;

    procedure ProcessItemPointOffer(ManualPushed: Boolean)
    var
        TmpItemPointOfferLine: Record "LSC Periodic Discount Line" temporary;
        TmpSelectedItemPointLine: Record "LSC Periodic Discount Line" temporary;
        CurrLine: Record "LSC POS Trans. Line";
        AddPosCommands: Codeunit "LSC Additional POS Commands";
        PosPriceUtil: Codeunit "LSC POS Price Utility";
        ItemPointOfferOnlyForMembersErr: Label 'Item Point Offers are only available for members.';
        ItemPointOfferNotFoundErr: Label 'No Item Point Offer found for the line.';
    begin
        if REC."Member Card No." = '' then begin
            PosTransactionGui.ErrorBeep(ItemPointOfferOnlyForMembersErr);
            exit;
        end;

        POSLINES.GetCurrentLine(CurrLine);
        // if not PosPriceUtil.AutoPromptFormItemPointOffer(CurrLine, TmpItemPointOfferLine, false) then begin
        //     PosTransactionGui.ErrorBeep(ItemPointOfferNotFoundErr);
        //     exit;
        // end;

        if TmpItemPointOfferLine.FindSet then
            repeat
                if TmpItemPointOfferLine.Type <> TmpItemPointOfferLine.Type::Item then begin
                    TmpItemPointOfferLine."No." := CurrLine.Number;
                    TmpItemPointOfferLine."Standard Price Including VAT" := CurrLine.Price;
                    TmpItemPointOfferLine."Offer Price Including VAT" := TmpItemPointOfferLine."Standard Price Including VAT" -
                      TmpItemPointOfferLine."Discount Amount Including VAT";
                    if TmpItemPointOfferLine."Offer Price Including VAT" < 0 then
                        TmpItemPointOfferLine."Offer Price Including VAT" := 0;
                    TmpItemPointOfferLine.Modify;
                end;
            until TmpItemPointOfferLine.Next = 0;

        // if ManualPushed and AddPosCommands.ItemPointOfferLookup(TmpItemPointOfferLine, TmpSelectedItemPointLine, CurrLine) then begin
        // end;
    end;

    procedure ProcessItemPointOfferOnClosePanel(var TmpSelectedItemPointLine: Record "LSC Periodic Discount Line" temporary; var pCurrLine: Record "LSC POS Trans. Line")
    var
        ItemOfferLine: Record "LSC Periodic Discount Line";
        POSPriceUtility: Codeunit "LSC POS Price Utility";
        IsHandled: Boolean;
    begin
        POSTransactionEvents.OnBeforeProcessItemPointOfferOnClosePanel(TmpSelectedItemPointLine, pCurrLine, NewLine, IsHandled);
        if IsHandled then
            exit;
        ItemOfferLine.Get(TmpSelectedItemPointLine."Offer No.", TmpSelectedItemPointLine."Line No.");
        TmpSelectedItemPointLine := ItemOfferLine;
        //POSPriceUtility.SelectItemPointOffer(pCurrLine, TmpSelectedItemPointLine);
        PosFunc.RecalcSlip(REC);
    end;

    procedure GetSeatingCapacity(): Integer
    begin
        exit(REC."Max. Seating Capacity");
    end;

    procedure InputMemberCard(CardNo: Text)
    var
        lPOSTransLine: Record "LSC POS Trans. Line";
        COUtility: Codeunit "LSC CO Utility";
        IsHandled: Boolean;
        MemberPointPaymRequiresVoidContinueQst: Label 'Member Point payment needs to be voided in order to use another Member Card.\Do you want to Void payment line and continue?''';
        MemberChangeError: label 'You are not allowed to change Member when editing a Customer Order.\Cancel the order and create new a new one.';
    begin
        // if CustomerOrderSession.IsCustomerOrderEdit() and (AskConfirmation) then begin
        //     PosTransactionGui.ErrorBeep(MemberChangeError);
        //     SetPOSState("LSC POS Transaction State"::SALES);
        //     //SetFunctionMode("LSC POS Command"::ITEM);
        //     exit;
        // end;

        // POSTransactionEvents.OnAfterCheckCustomerOrderInInputMemberContact(REC, CardNo, IsHandled);
        // if IsHandled then
        //     exit;

        if REC."Member Card No." <> '' then
            if MemberPointPaymentInTrans(lPOSTransLine) then
                if PosTransactionGui.PosConfirm(MemberPointPaymRequiresVoidContinueQst, true) then begin
                    POSLINES.SetCurrentLine(lPOSTransLine);
                    VoidLinePressed;
                    if lPOSTransLine.Get(lPOSTransLine."Receipt No.", lPOSTransLine."Line No.") then
                        if (lPOSTransLine."Entry Status" <> lPOSTransLine."Entry Status"::Voided) then
                            exit;
                end else
                    exit;
        if CardNo <> '' then
            CurrInput := CardNo;
        if CurrInput = '' then begin
            PosTransactionGui.OpenNumericKeyboard(CardNoMsg, '', Enum::"LSC POS Trans. Numpad Trigger"::InputMemberCard);
            exit;
        end;

        // if not COUtility.CustomerOrderUpdateMember(CustomerOrderHeader_Temp, CustomerOrderLine_Temp, CustomerOrderDiscountLine_Temp) then
        //     CheckMemberCard;

        CurrInput := '';
        POSTransactionEvents.OnAfterInputMemberCard(CardNo);
    end;

    procedure UpdatedCOWithDeliveryDate(RequestedDeliveryDate: Date)
    begin
        if CustomerOrderHeader_Temp.FindFirst() then begin
            CustomerOrderHeader_Temp."Requested Delivery Date" := RequestedDeliveryDate;
            CustomerOrderHeader_Temp.modify;
            clear(CustomerOrderLine_Temp);
            CustomerOrderLine_Temp.SetRange("Document ID", CustomerOrderHeader_Temp."Document ID");
            CustomerOrderLine_Temp.Modifyall("Requested Delivery Date", RequestedDeliveryDate);
            clear(RequestedDeliveryDate);
        end;
    end;

    procedure GetNetAmount(): Text[50]
    begin
        exit(FormatAmount(REC."Net Amount"));
    end;

    procedure GetTaxAmount(): Text[50]
    begin
        exit(FormatAmount(REC."Gross Amount" - REC."Net Amount"));
    end;

    procedure GetCustomerName(): Text[100]
    begin
        if REC."Customer No." <> '' then begin
            if Customer.Get(REC."Customer No.") then;
            exit(Customer.Name);
        end;
        exit('');
    end;

    procedure GetCustomerAddress(): Text[100]
    begin
        if REC."Customer No." <> '' then
            exit(Customer.Address)
        else
            exit('');
    end;

    procedure GetCustomerAddress2(): Text[50]
    begin
        if REC."Customer No." <> '' then
            exit(Customer."Address 2")
        else
            exit('');
    end;

    procedure GetCustomerPostCode(): Text[50]
    begin
        if REC."Customer No." <> '' then
            exit(Customer."Post Code")
        else
            exit('');
    end;

    procedure GetCustomerBalance(): Text[50]
    begin
        if REC."Customer No." <> '' then begin
            if (CustomerBalanceCalculated <> REC."Customer No.") or (Customer."Balance (LCY)" = 0) then begin
                if not PosFuncProfile."TS Customer" then
                    Customer.CalcFields("LSC Amt. Charged On POS", "LSC Amt. Charged Posted", "Balance (LCY)");
                CustomerBalanceCalculated := REC."Customer No.";
            end;
            if PosFuncProfile."TS Customer" then
                exit(FormatAmount(BalanceLCYInt + AmtChargedOnPOSInt - AmtChargedPostedInt))
            else
                exit(FormatAmount(Customer."Balance (LCY)" + Customer."LSC Amt. Charged On POS" - Customer."LSC Amt. Charged Posted"));
        end
        else
            exit('');
    end;

    procedure GetCustomerLastSale(): Text[50]
    var
        TransHeader_l: Record "LSC Transaction Header";
    begin
        if REC."Customer No." <> '' then begin
            if (CustomerLastSale <> REC."Customer No.") then begin
                TransHeader_l.SetCurrentKey("Customer No.", Date);
                TransHeader_l.SetRange("Customer No.", REC."Customer No.");
                TransHeader_l.SetRange("Transaction Type", TransHeader_l."Transaction Type"::Sales);
                TransHeader_l.SetRange("Entry Status", 0);
                if TransHeader_l.FindLast then
                    CustomerLastSaleDate := TransHeader_l.Date
                else
                    CustomerLastSaleDate := 0D;
                CustomerLastSale := REC."Customer No.";
            end;
            exit(Format(CustomerLastSaleDate));
        end
        else
            exit('');
    end;

    procedure GetCustomerNo_Caption(): Text[50]
    var
        NoMsg: Label 'No.';
    begin
        if REC."Customer No." <> '' then
            exit(NoMsg)
        else
            exit('');
    end;

    procedure GetCustomerName_Caption(): Text[50]
    var
        NameMsg: Label 'Name';
    begin
        if REC."Customer No." <> '' then
            exit(NameMsg)
        else
            exit('');
    end;

    procedure GetCustomerAddress_Caption(): Text[50]
    var
        AddressMsg: Label 'Address';
    begin
        if REC."Customer No." <> '' then
            exit(AddressMsg)
        else
            exit('');
    end;

    procedure GetCustomerAddress2_Caption(): Text[50]
    var
        Address2Msg: Label 'Address 2';
    begin
        if REC."Customer No." <> '' then
            exit(Address2Msg)
        else
            exit('');
    end;

    procedure GetCustomerPostCode_Caption(): Text[50]
    var
        PostCodeMsg: Label 'Post Code';
    begin
        if REC."Customer No." <> '' then
            exit(PostCodeMsg)
        else
            exit('');
    end;

    procedure GetCustomerBalance_Caption(): Text[50]
    var
        BalanceMsg: Label 'Balance';
    begin
        if REC."Customer No." <> '' then
            exit(BalanceMsg)
        else
            exit('');
    end;

    procedure GetCustomerLastSale_Caption(): Text[50]
    var
        DateOfLastSaleMsg: Label 'Date of Last Sale';
    begin
        if REC."Customer No." <> '' then
            exit(DateOfLastSaleMsg)
        else
            exit('');
    end;

    procedure CheckMemberCard(): Boolean
    var
        CustTemp: Record Customer temporary;
        POSTSUtil: Codeunit "LSC POS Trans. Server Utility";
        ErrorText_l: Text;
        MSRMsg1: Label 'Cardholder Name: %1\Member Club: %2\Member Scheme: %3.';
        IsHandled, ReturnValue : Boolean;
    begin
        // POSTransactionEvents.OnBeforeCheckMemberCard_POSTransaction(CurrInput, IsHandled, ReturnValue);
        // if IsHandled then
        //     exit(ReturnValue);
        // if not MemberLinkedCustomerInfoCode then begin
        //     Rec.SetRecFilter();
        //     Rec.FindFirst();
        //     if not Member.LoadMemberInfo(CurrInput, ErrorText_l, true) then begin
        //         PosTransactionGui.ErrorBeep(ErrorText_l);
        //         exit(false);
        //     end;

        //     POSTransactionEventsPub.OnBeforeSetState(Rec);
        //     if (STATE <> "LSC POS Transaction State"::SALES) or (POSGUI.GetCurrMenu(0) <> POSSESSION.GetSalesMenu) then begin
        //         SetPOSState("LSC POS Transaction State"::SALES);
        //         SetFunctionMode("LSC POS Command"::ITEM);
        //         SelectDefaultMenu;
        //         REC."Transaction Type" := REC."Transaction Type"::Sales;
        //     end;
        //     if REC."New Transaction" then
        //         SalePressed(false);

        //     if (Member.LinkedToCustomerNo <> '') then
        //         if not Customer.Get(Member.LinkedToCustomerNo) then begin
        //             if POSTSUtil.GetCustomer(CustTemp, Member.LinkedToCustomerNo, ErrorText_l) then begin
        //                 Customer.Init();
        //                 Customer := CustTemp;
        //                 Customer.Insert(false);
        //             end;
        //         end;

        //     if (Member.LinkedToCustomerNo <> '') and Customer.Get(Member.LinkedToCustomerNo) then begin
        //         MemberLinkedCustomerInfoCode := true;
        //         if CheckInfocode('CUSTOMER') then
        //             exit;
        //         MemberLinkedCustomerInfoCode := false;
        //         OnlySelectCustomer := true;
        //         ProcessCustomer(false);
        //         OnlySelectCustomer := false;
        //     end;
        // end;

        // ErrorText_l := '';
        // if not Member.CheckMemberCard(REC, ErrorText_l) then begin
        //     if ErrorText_l <> '' then
        //         PosTransactionGui.ErrorBeep(ErrorText_l);
        //     exit(false);
        // end;

        // CalcTotals();

        // if Member.DisplayMessageOnPOS then
        //     PosTransactionGui.PosMessage(StrSubstNo(MSRMsg1, Member.ContactName, Member.CardClubCode, Member.CardSchemeCode));

        // if PosFunc.IsInPaymentState then
        //     ProcessAddBenefits(GetFunctionModeEnum);

        // InfoTextDescription := Member.CardClubCode + ' ' + Member.CardSchemeCode;
        // InfoTextDescription2 := CurrInput;

        // //HospFunc.CreateTransStatusAndKitchenStatusAfterMemberAdded(REC, StoreSetup);
        // Member.OnAfterCheckMemberCard(REC);
        // exit(true);
    end;

    procedure SetInfoPhase(NewInfoPhase: Integer)
    begin
        InfoPhase := NewInfoPhase;
    end;

    procedure NextInfoPhase()
    var
        TareWeightMsg: Label 'Enter tare weight';
        StartingDateWICMsg: Label 'Enter Starting Date from WIC Check.';
        EndingDateWICMsg: Label 'Enter Ending Date from WIC Check.';
    begin
        InfoPhase += 1;
        case InfoPhase of

            101:
                begin
                    FunctionSetup.Prompt := 'Enter date';
                    PosTransactionGui.MessageBeep(StartingDateWICMsg);
                    exit;
                end;

            102:
                begin
                    FunctionSetup.Prompt := 'Enter date';
                    PosTransactionGui.MessageBeep(EndingDateWICMsg);
                    exit;
                end;

            103:
                begin
                    // if ValidateInfo() then begin
                    //     REC."WIC Transaction" := true;
                    //     REC.Modify;
                    //     SalePressed(false);
                    //     CheckInfoCode('WIC');
                    // end else
                    //     SetFunctionMode("LSC POS Command"::ITEM);
                end;

            201:
                begin
                    FunctionSetup.Prompt := TareWeightMsg;
                    PosTransactionGui.MessageBeep('');
                    if Item."LSC Default Tare Weight" <> 0 then
                        CurrInput := Format(Item."LSC Default Tare Weight");
                    exit;
                end;

            211:
                begin
                    FunctionSetup.Prompt := TareWeightMsg;
                    PosTransactionGui.MessageBeep('');
                    exit;
                end;
        end;

        exit;
    end;

    procedure ValidateInfo(): Boolean
    var
        InvalidQtyMsg: Label 'Invalid value in quantity';
        InvalidDateMsg: Label 'Invalid Date: %1';
        InvalidCheckTodayMsg: Label 'Check is not valid today. %1 - %2';
    begin
        case InfoPhase of
            101:
                begin
                    if not Evaluate(StartDate, CurrInput) then begin
                        PosTransactionGui.ErrorBeep(StrSubstNo(InvalidDateMsg, CurrInput));
                        exit(false);
                    end;
                end;

            102:
                begin
                    if not Evaluate(EndDate, CurrInput) then begin
                        PosTransactionGui.ErrorBeep(StrSubstNo(InvalidDateMsg, CurrInput));
                        exit(false);
                    end;
                end;

            103:
                begin
                    CurrInput := '';
                    if (EndDate < StartDate) or
                       (StartDate > Today) or
                       (EndDate < Today) then begin
                        PosTransactionGui.ErrorBeep(StrSubstNo(InvalidCheckTodayMsg, StartDate, EndDate));
                        exit(false);
                    end;
                end;

            201:
                begin
                    // if not POSTransScale.TestAndSetTare(CurrInput) then begin
                    //     PosTransactionGui.ErrorBeep(InvalidQtyMsg);
                    //     exit(false);
                    // end else
                    //     POSTransScale.AskForWeight(Item);
                end;

            211:
                begin
                    // if not POSTransScale.TestAndSetTare(CurrInput) then begin
                    //     PosTransactionGui.ErrorBeep(InvalidQtyMsg);
                    //     exit(false);
                    // end else
                    //     POSTransScale.UpdTare(LineRec.Quantity);
                end;
        end;

        exit(true);
    end;

    procedure CouponResetReservation(POSTransLine: Record "LSC POS Trans. Line")
    var
        CouponHeader: Record "LSC Coupon Header";
        CouponEntry: Record "LSC Coupon Entry";
        CouponEntryTEMP: Record "LSC Coupon Entry" temporary;
        SendSerialCouponUtils: Codeunit LSCSendSerialCouponUtils;
        ResponseCode: Code[30];
        ErrorText: Text;
    begin
        if CouponHeader.Get(POSTransLine."Coupon Code") then
            if CouponHeader."Coupon ID Method" = CouponHeader."Coupon ID Method"::"Serial No." then begin
                CouponEntry.Reset;
                CouponEntry.SetCurrentKey("Coupon Code", Barcode, Status);
                CouponEntry.SetRange("Coupon Code", CouponHeader.Code);
                CouponEntry.SetRange(Barcode, POSTransLine."Coupon Barcode No.");
                CouponEntry.SetRange("Reserved by POS Terminal No.", POSTransLine."POS Terminal No.");
                if CouponEntry.FindFirst then begin
                    CouponEntry."Reserved by POS Terminal No." := '';
                    CouponEntry."Date Reserved on POS" := 0D;
                    CouponEntry.Modify;
                    CouponEntryTEMP.Reset;
                    CouponEntryTEMP.DeleteAll;
                    CouponEntryTEMP := CouponEntry;
                    CouponEntryTEMP.Insert;
                    SendSerialCouponUtils.SetPosFunctionalityProfile(PosFuncProfile."Profile ID");
                    SendSerialCouponUtils.SendRequest(true, CouponEntryTEMP, ResponseCode, ErrorText);
                end;
            end;
    end;

    procedure CheckCreditCardHold()
    var
        FnNotAllowedOnHoldForPaymErr: Label 'Function is not allowed. Current transaction is on hold for expected credit card payment.';
    begin
        if REC."Credit Card Hold" then begin
            PosTransactionGui.PosMessage(FnNotAllowedOnHoldForPaymErr);
            Error('');
        end;
    end;

    procedure InventoryLookupPressed()
    var
        Lookup: Record "LSC POS Lookup";
        CurrlineTemp: Record "LSC POS Trans. Line";
        DataTable: Record "LSC POS Data Table";
        lItem: Record Item;
        lItemVariant: Record "Item Variant";
        lInvLookup: Record "LSC Inventory Lookup Table";
        lInvLookuptmp: Record "LSC Inventory Lookup Table" temporary;
        lStoresInInventoryProfileRec: Record "LSC Stores In Location Profile";
        LookupRecRef: RecordRef;
        ItemTrack: Codeunit "LSC Retail Item Tracking";
        OldFormId: Code[20];
        NewFormID: Code[10];
        "Filter": Code[20];
        SerialLotLookup: Boolean;
    begin
        if StoreSetup."No." = '' then
            GetStoreSetup();
        OldFormId := POSGUI.GetActiveOrLastLookupID;

        Lookup.Reset;
        if not POSSESSION.GetPosLookupRec(OldFormId, Lookup) then
            Clear(Lookup);

        if not DataTable.Get(Lookup."Data Table ID") then
            Clear(DataTable);

        if (OldFormId in ['ITEM', 'VARIANT']) or (DataTable."Table No." = 27) then begin
            CurrlineTemp.Init;
            CurrlineTemp."POS Terminal No." := POSSESSION.TerminalNo;
            if (OldFormId = 'ITEM') or (DataTable."Table No." = 27) then begin
                CurrlineTemp.Number := POSGUI.GetActiveLookupKeyValue;
                LocationPrintItemNo := CurrlineTemp.Number;
                lItemVariant.Reset;
                lItemVariant.SetRange("Item No.", CurrlineTemp.Number);
                if lItemVariant.IsEmpty then
                    NewFormID := 'INV_LU'
                else
                    NewFormID := 'VAR_LU';
            end else begin
                CurrlineTemp.Number := NewLine.Number;
                CurrlineTemp."Variant Code" := POSGUI.GetActiveLookupKeyValue;
                LocationPrintItemNo := CurrlineTemp.Number;
                LocationPrintVariantNo := CurrlineTemp."Variant Code";
                NewFormID := 'VAR_LU';
            end;
            // SerialLotLookup := ItemTrack.IsItemSNTracking(CurrlineTemp.Number) or ItemTrack.IsItemLotTracking(CurrlineTemp.Number);
            // if SerialLotLookup then begin
            //     if ItemTrack.IsItemSNTracking(CurrlineTemp.Number) then
            //         NewFormID := 'SERIAL_LU'
            //     else
            //         NewFormID := 'LOT_LU';
            // end;

            Lookup.Reset;
            if POSSESSION.GetPosLookupRec(NewFormID, Lookup) then
                if PosFunc.PrepareInvLookup(CurrlineTemp, false, StoreSetup."Location Profile", Filter) then begin
                    if lItem.Get(CurrlineTemp.Number) then
                        Lookup."Start Message" := CopyStr(lItem."No." + ' ' + lItem.Description, 1, MaxStrLen(Lookup."Start Message"));
                    lInvLookup.SetRange("Item No.", lItem."No.");
                    if CurrlineTemp."Variant Code" <> '' then
                        lInvLookup.SetRange("Variant Code", CurrlineTemp."Variant Code");
                    if StoreSetup."Location Profile" <> '' then begin
                        lStoresInInventoryProfileRec.SetRange("Inventory Lookup Profile", StoreSetup."Location Profile");
                        if lStoresInInventoryProfileRec.FindSet then
                            repeat
                                lInvLookup.SetRange("Store No.", lStoresInInventoryProfileRec."Store No.");
                                if lInvLookup.FindSet then
                                    repeat
                                        lInvLookuptmp := lInvLookup;
                                        lInvLookuptmp.Insert;
                                    until lInvLookup.Next = 0;
                            until lStoresInInventoryProfileRec.Next = 0;
                    end;
                    LookupRecRef.GetTable(lInvLookuptmp);
                    POSGUI.Lookup(Lookup, Filter, CurrlineTemp, POSSESSION.MgrKey, REC."Customer No.", LookupRecRef);
                end;
        end;
    end;

    procedure UpdateContext()
    begin
        //Remember to add to InsertDefaultTags function in "POS Tag List" Page when adding to this list
        POSTransactionEvents.OnBeforeGetContext(REC, LineRec, CurrInput);
        Rec.CalcFields("Gross Amount", "Line Discount", Payment, "Net Amount", "Total Discount", "Income/Exp. Amount", "Net Income/Exp. Amount", Prepayment);
        RefreshRetailMessageTagText();
        AddTagExpressions();
        UpdateGlobalContext();
        UpdateRecContext();
        AddUserCreatedTags();

        POSTransactionEvents.OnAfterGetContext(REC, LineRec, CurrInput);
    end;

    local procedure UpdateGlobalContext()
    begin
        POSSESSION.SetValue("LSC POS Tag"::"FunctionMode", GetFunctionMode);
        POSSESSION.SetValue("LSC POS Tag"::"InfoText1", GetPosInfoText1);
        POSSESSION.SetValue("LSC POS Tag"::"InfoText2", GetPosInfoText2);
        POSSESSION.SetValue("LSC POS Tag"::"InputPrompt", GetInputPrompt);
        POSSESSION.SetValue("LSC POS Tag"::"Guests", Format(GetGuests));  //not set anywhere else
        POSSESSION.SetValue("LSC POS Tag"::"State", GetPosState);
        POSSESSION.SetValue("LSC POS Tag"::"GlobalSalesType", GetGlobalSalesType); //not set anywhere else
        POSSESSION.SetValue("LSC POS Tag"::"StateTxt", StateTxt);
        POSSESSION.SetValue("LSC POS Tag"::"StateTxt2", StateTxt2);
        POSSESSION.SetValue("LSC POS Tag"::"LastItemNo", GetLastItemNo);
        POSSESSION.SetValue("LSC POS Tag"::"MenuType", Format(GetMenuType)); //not set anywhere else
        POSSESSION.SetValue("LSC POS Tag"::"MenuTypeDescription", GetMenuTypeDescription);
    end;

    local procedure UpdateRecContext()
    begin
        POSSESSION.SetValue("LSC POS Tag"::"IsNewTransaction", Format(IsNewTransaction));
        POSSESSION.SetValue("LSC POS Tag"::"IsReturnSale", Format(SaleIsReturnSale));
        POSSESSION.SetValue("LSC POS Tag"::"StoreNo", GetStoreNo);
        POSSESSION.SetValue("LSC POS Tag"::"ReceiptNo", GetReceiptNo);
        POSSESSION.SetValue("LSC POS Tag"::"SalesStaff", GetSalesStaff);
        POSSESSION.SetValue("LSC POS Tag"::"DocumentNo", GetDocumentNo);
        POSSESSION.SetValue("LSC POS Tag"::"CustomerNo", GetCustomerNo);
        POSSESSION.SetValue("LSC POS Tag"::"Discount", GetDiscountTxt);
        POSSESSION.SetValue("LSC POS Tag"::"Amount", GetAmountTxt);
        POSSESSION.SetValue("LSC POS Tag"::"Payment", GetPaymentTxt);
        POSSESSION.SetValue("LSC POS Tag"::"Balance", GetOutstandingBalanceTxt);
        POSSESSION.SetValue("LSC POS Tag"::"Prepayment", GetPrepaymentAmountTxt);
        POSSESSION.SetValue("LSC POS Tag"::"PrepaymentBalance", GetPrepaymentBalanceTxt);
        POSSESSION.SetValue("LSC POS Tag"::"ShiftNo", GetShiftNo);
        POSSESSION.SetValue("LSC POS Tag"::"TransStaffID", GetStaffID);
        POSSESSION.SetValue("LSC POS Tag"::"TransManagerID", GetManagerID);
        POSSESSION.SetValue("LSC POS Tag"::"TransManagerKey", Format(GetManagerKey()));
        POSSESSION.SetValue("LSC POS Tag"::"TransSalesType", GetSalesType); //not set anywhere else
        POSSESSION.SetValue("LSC POS Tag"::"Covers", Format(GetCovers)); //not set anywhere else
        POSSESSION.SetValue("LSC POS Tag"::"TransDinTblDescr", GetTableDescr);  //Used in Hospitality Functions
        POSSESSION.SetValue("LSC POS Tag"::"Comment", GetComment); //not set anywhere else
        POSSESSION.SetValue("LSC POS Tag"::"ContactNo", GetContactID);
        POSSESSION.SetValue("LSC POS Tag"::"SeatingCapacity", Format(GetSeatingCapacity)); //not set anywhere else
        POSSESSION.SetValue("LSC POS Tag"::"NetAmount", GetNetAmount);
        POSSESSION.SetValue("LSC POS Tag"::"TaxAmount", GetTaxAmount);

        if RetailExt.IsAULocalizationEnabled() then begin
            POSSESSION.SetValue("LSC POS Tag"::"PLBAmount", FormatAmount(PLBMgt.GetTotalPLBAmount(REC."Receipt No.", true)));
            POSSESSION.SetValue("LSC POS Tag"::"NonPLBAmount", FormatAmount(PLBMgt.GetTotalPLBAmount(REC."Receipt No.", false)));
            POSSESSION.SetValue("LSC POS Tag"::"OverridePLBItem", PLBMgt.GetBooleanTxt(REC."Override PLB Item"));
            POSSESSION.SetValue("LSC POS Tag"::"OverridePLBItemStaffID", REC."Override Staff ID");
            POSSESSION.SetValue("LSC POS Tag"::"OverridePLBItemDateTime", Format(REC."Override Date Time"));
        end;

        RetailSetup.Get();
        if RetailSetup."Enable Limitation" then begin
            LimitationMgt.CalcTotalAmount(REC."Receipt No.", LimitationTotalAmount);
            LimitationMgt.CalcPaidAmount(REC."Receipt No.", LimitationPaidAmount);
            LimitationMgt.CalcBalanceAmount(REC."Receipt No.", LimitationBalanceAmount);

            //EBT
            POSSESSION.SetValue("LSC POS Tag"::"LimitationAmount", FormatAmount(LimitationTotalAmount[1]));
            POSSESSION.SetValue("LSC POS Tag"::"LimitationPaidAmount", FormatAmount(LimitationPaidAmount[1]));
            POSSESSION.SetValue("LSC POS Tag"::"LimitationBalanceAmount", FormatAmount(LimitationBalanceAmount[1]));

            //EBT Cash 
            POSSESSION.SetValue("LSC POS Tag"::"EBTCashAmount", FormatAmount(LimitationTotalAmount[2]));
            POSSESSION.SetValue("LSC POS Tag"::"EBTCashPaidAmount", FormatAmount(LimitationPaidAmount[2]));
            POSSESSION.SetValue("LSC POS Tag"::"EBTCashBalanceAmount", FormatAmount(LimitationBalanceAmount[2]));
        end;

        UpdateMemberContext();
        UpdateCustomerContext();
    end;

    local procedure UpdateMemberContext()
    begin
        // Member.UpdateContext(ActiveMemberCardNo());
        // POSTransactionEvents.OnAfterUpdateMemberContext(REC, PosFunc);
    end;

    local procedure UpdateCustomerContext()
    begin
        POSSESSION.SetValue("LSC POS Tag"::"CustomerName", GetCustomerName);
        POSSESSION.SetValue("LSC POS Tag"::"CustomerAddress", GetCustomerAddress);
        POSSESSION.SetValue("LSC POS Tag"::"CustomerAddress2", GetCustomerAddress2);
        POSSESSION.SetValue("LSC POS Tag"::"CustomerPostCode", GetCustomerPostCode);
        POSSESSION.SetValue("LSC POS Tag"::"CustomerBalance", GetCustomerBalance);
        POSSESSION.SetValue("LSC POS Tag"::"CustomerLastSale", GetCustomerLastSale);  //Only works in online environment
        POSSESSION.SetValue("LSC POS Tag"::"CustomerNo_Capt", GetCustomerNo_Caption);
        POSSESSION.SetValue("LSC POS Tag"::"CustomerAddress_Capt", GetCustomerAddress_Caption);
        POSSESSION.SetValue("LSC POS Tag"::"CustomerAddress2_Capt", GetCustomerAddress2_Caption);
        POSSESSION.SetValue("LSC POS Tag"::"CustomerBalance_Capt", GetCustomerBalance_Caption);
        POSSESSION.SetValue("LSC POS Tag"::"CustomerName_Capt", GetCustomerName_Caption);
        POSSESSION.SetValue("LSC POS Tag"::"CustomerPostCode_Capt", GetCustomerPostCode_Caption);
        POSSESSION.SetValue("LSC POS Tag"::"CustomerLastSale_Capt", GetCustomerLastSale_Caption);
    end;

    // POSTag - Tag: <#Name>, Expression: 'Hello %1', SetValue('name', 'World') -> 'Hello World'
    local procedure AddTagExpressions(): Boolean
    var
        POSTag: Record "LSC POS Tag";
        dict: Dictionary of [Text, Text];
        userGeneratedTags: List of [Text];
        tag: Text;
    begin
        POSTag.Reset;
        POSTag.SetFilter(Expression, '<>%1', '');
        if POSTag.IsEmpty then
            exit;
        if POSTag.FindSet then
            repeat
                dict.Add(POSTag.Tag, POSTag.Expression);
                if POSTag."Created By" = POSTag."Created By"::User then
                    userGeneratedTags.Add(POSTag.Tag);
            until POSTag.Next = 0;
        POSSESSION.UpdateTagExpressions(dict);
        foreach tag in userGeneratedTags do begin
            if POSSESSION.GetValue(tag) = '' then
                POSSESSION.SetValue(tag, ''); // force evaluation of the expression
        end;
    end;

    procedure AddUserCreatedTags()
    var
        POSTag: Record "LSC POS Tag";
        RecRefTag: RecordRef;
        RecRefPOSTrans: RecordRef;
        FieldRefTag: FieldRef;
        FieldRefPOSTrans: FieldRef;
        POSTagValue: Text;
        CurrValue: Text;
    begin
        POSTag.Reset;
        POSTag.SetFilter(Type, '%1', POSTag.Type::Transaction);
        POSTag.SetRange("Created By", POSTag."Created By"::User);
        POSTag.SetFilter("POS Trans. Key Field", '>0');
        if POSTag.IsEmpty then
            exit;
        RecRefPOSTrans.GetTable(REC);
        if POSTag.FindSet then
            repeat
                if (POSTag."Table No." <> Database::"LSC POS Transaction") and (POSTag."Table No." > 0) then begin
                    RecRefTag.Close;
                    RecRefTag.Open(POSTag."Table No.");
                    FieldRefPOSTrans := RecRefPOSTrans.Field(POSTag."POS Trans. Key Field");
                    FieldRefTag := RecRefTag.FieldIndex(1);
                    CurrValue := Format(FieldRefPOSTrans.Value);
                    if CurrValue = '' then
                        FieldRefTag.Validate('')
                    else begin
                        FieldRefTag.SetFilter(CurrValue);
                        if RecRefTag.FindFirst then
                            FieldRefTag := RecRefTag.Field(POSTag."Field No.")
                        else
                            FieldRefTag.Validate('');
                    end
                end else
                    if (POSTag."Table No." = Database::"LSC POS Transaction") or (POSTag."Table No." = 0) then begin
                        FieldRefTag := RecRefPOSTrans.Field(POSTag."POS Trans. Key Field")
                    end else
                        FieldRefTag.Validate('');

                if Format(FieldRefTag.Class) = 'FlowField' then
                    FieldRefTag.CalcField;
                POSTagValue := Format(FieldRefTag.Value);
                POSSESSION.SetValue(POSTag.Tag, POSTagValue); // ExtractContextKey
            until POSTag.Next = 0;
    end;

    procedure ProcessScannerDataInput()
    var
        lMemberShipCard: Record "LSC Membership Card";
        lTmpMobileOfferQRCode: Record "LSC Mobile Loyalty QR Code" temporary;
        lPosTransLine: Record "LSC POS Trans. Line";
        TmpItemPointOfferLine: Record "LSC Periodic Discount Line" temporary;
        TmpSelectedItemPointLine: Record "LSC Periodic Discount Line" temporary;
        ItemOfferLine: Record "LSC Periodic Discount Line";
        PosPriceUtil: Codeunit "LSC POS Price Utility";
        lOfferNo: Code[20];
    begin
        // InputMemberCard(PosFunc.QRCardNo);

        // //Process Coupons
        // PosFunc.GetCouponsFromQR(lTmpMobileOfferQRCode);
        // if lTmpMobileOfferQRCode.FindSet then
        //     repeat
        //         CurrInput := lTmpMobileOfferQRCode."Offer ID";
        //         CouponPressed;
        //     until lTmpMobileOfferQRCode.Next = 0;

        // //Process Item Point Offers
        // lPosTransLine.Reset;
        // lPosTransLine.SetRange("Receipt No.", REC."Receipt No.");
        // lPosTransLine.SetRange("Entry Type", lPosTransLine."Entry Type"::Item);
        // if lPosTransLine.FindSet then
        //     repeat
        //         if PosFunc.ItemInQR(lPosTransLine.Number, lOfferNo) then begin
        //             if PosPriceUtil.AutoPromptFormItemPointOffer(lPosTransLine, TmpItemPointOfferLine, false) then begin
        //                 TmpItemPointOfferLine.SetRange("Offer No.", lOfferNo);
        //                 if TmpItemPointOfferLine.FindFirst then begin
        //                     ItemOfferLine.Get(TmpItemPointOfferLine."Offer No.", TmpItemPointOfferLine."Line No.");
        //                     TmpSelectedItemPointLine := ItemOfferLine;
        //                     PosPriceUtil.SelectItemPointOffer(lPosTransLine, TmpSelectedItemPointLine);
        //                     PosFunc.RecalcSlip(REC);
        //                 end;
        //             end;
        //         end;
        //     until lPosTransLine.Next = 0;

        // if lMemberShipCard.Get(PosFunc.QRCardNo) then begin
        //     InfoTextDescription := lMemberShipCard."Club Code" + ' ' + lMemberShipCard."Scheme Code";
        //     InfoTextDescription2 := PosFunc.QRCardNo;
        // end;
    end;

    procedure LoadQRTextData(pQRCode: Text)
    begin
        //PosFunc.LoadQRTextData(pQRCode);
    end;

    procedure QueueMobileLoyaltyQRCode(var pErrorMessage: Text): Boolean
    begin
        // exit(PosFunc.QueueMobileLoyaltyQRCode(pErrorMessage));
    end;

    procedure RefundLookUp(TransactionHeader: Record "LSC Transaction Header"; pNewReceiptNo: Code[20])
    var
        Lookup: Record "LSC POS Lookup";
        FormID: Code[10];
        LookupID: Code[20];
        IsHandled: Boolean;
    begin
        // LookupID := 'REFUND';
        // POSTransactionEventsPub.OnBeforeRefundLookup(RefundTransaction, TransactionHeader, IsHandled, LookupID);
        // if IsHandled then
        //     exit;

        // Lookup.Reset;
        // if POSSESSION.GetPosLookupRec(LookupID, Lookup) then
        //     FormID := Lookup."Lookup ID";

        // if FormID <> '' then begin
        //     PosFunc.PosTransDiscLoad(REC."Receipt No.");
        //     RefundMgt.InitRefund(TransactionHeader, pNewReceiptNo);
        //     RefundMgt.PrepareTransToRefund;
        //     RefundMgt.CreateRefundLookup(Lookup, REC);
        //     PosFunc.PosTransDiscFlush;
        // end;
    end;

    procedure SetCurrentLine(var NewRec: Record "LSC POS Trans. Line")
    begin
        NewLine := NewRec;
    end;

    procedure SetCurrentLineNo(pLineNo: Integer)
    begin
        if pLineNo > 0 then begin
            if (NewLine."Receipt No." <> '') and (NewLine."Line No." = 0) and (not OkNewInput) then begin
                //at this point user is moving around journal, potentially trying to interrupt current activity
                //this is not desired, so we exit early, without getting or clearing NewLine variable
                exit;
            end;

            if not NewLine.Get(NewLine."Receipt No.", pLineNo) then
                Clear(NewLine);
        end;
    end;

    procedure EditMemberContact()
    var
        lPOSMemberContactPopup: Codeunit "LSC POS Member Contact Popup";
        lMemberCardNo: Text;
        lCloseCommand: Text;
        IsHandled: Boolean;
        MemberChangeError: label 'You are not allowed to change Member when editing a Customer Order.\Cancel the order and create new a new one.';
    begin
        // if CustomerOrderSession.IsCustomerOrderEdit() then begin
        //     PosTransactionGui.ErrorBeep(MemberChangeError);
        //     exit;
        // end;

        POSTransactionEvents.OnAfterCheckCustomerOrderInEditMemberContact(REC, gOldMemberCardNo, IsHandled);
        if IsHandled then
            exit;

        gOldMemberCardNo := REC."Member Card No.";
        lMemberCardNo := REC."Member Card No.";
        lCloseCommand := lPOSMemberContactPopup.ShowPanel(lMemberCardNo, 'POSMember');
    end;

    procedure EditMemberContactOK(pCloseCommand: Text; pMemberCardNo: Text)
    begin
        if pCloseCommand = '' then
            exit;

        if pCloseCommand = 'PANELOK' then begin
            if (gOldMemberCardNo <> pMemberCardNo) and (pMemberCardNo <> '') then begin
                CurrInput := pMemberCardNo;
                CheckMemberCard;
                CurrInput := '';
            end;
            POSTransactionEvents.OnPanelOKEditMemberContactOK(REC, pMemberCardNo);
        end
        else
            if pCloseCommand = 'CUSTOMER_ORDER_LIST' then begin
                REC."Member Card No." := pMemberCardNo;
                CustomerOrderList;
            end;
    end;

    procedure AddMemberEmail()
    var
        // RegisterMemberEMail_l: Codeunit "LSC Member E-Mail Register";
        lOldMemberCardNo: Text;
        lMemberCardNo: Text;
    begin
        // lOldMemberCardNo := REC."Member Card No.";
        // RegisterMemberEMail_l.InitPanel(lMemberCardNo);
        // if lOldMemberCardNo <> lMemberCardNo then begin
        //     CurrInput := lMemberCardNo;
        //     CheckMemberCard;
        //     CurrInput := '';
        // end;
    end;

    procedure PrintYReport(DoCheck: Boolean)
    var
        TmpStaff: Record "LSC Staff";
        StaffStoreLink: Record "LSC STAFF Store Link";
        // PrintUtil: Codeunit "LSC POS Print Utility";
        //SafeDenomPanelCommands: codeunit "LSC Safe Denom. Panel Commands";
        ErrorText: Text;
        NoSuspPOSTransactionsVoided: Integer;
        YReportsNotInTrainingMsg: Label 'Y-Reports are not allowed in Training mode';
        YReportPrintSureQst: Label 'Are you sure you want to print a Y Report?';
    begin
        // // if not POSTransPrint.IsPrinterActive() then
        // //     exit;

        // if DoCheck then begin
        //     if not TestNewTransaction then begin
        //         PosTransactionGui.PosMessage(CurrTransMustBeFinishedErr);
        //         exit;
        //     end;
        //     if TrainingActive then begin
        //         PosTransactionGui.PosMessage(YReportsNotInTrainingMsg);
        //         exit;
        //     end;
        // end;
        // if POSSESSION.StaffID = '' then begin
        //     PosTransactionGui.PosMessage(ReportOnlyPrintableFromPosErr);
        //     exit;
        // end;
        // if not POSSESSION.Permission("LSC POS Command"::PRINT_Y, InfoTextDescription) then begin
        //     PosTransactionGui.PosMessage(InfoTextDescription);
        //     exit;
        // end;

        // if StoreSetup."Safe Mgnt. in Use" then begin
        //     if REC."Store No." = '' then
        //         REC."Store No." := POSSESSION.StoreNo;
        //     if REC."POS Terminal No." = '' then
        //         REC."POS Terminal No." := POSSESSION.TerminalNo;
        //     if REC."Staff ID" = '' then
        //         REC."Staff ID" := POSSESSION.StaffID;
        // end;

        // if not PosTransactionGui.PosConfirm(YReportPrintSureQst, false) then
        //     exit;
        // ScreenDisplay(PrintingMsg);
        // if TSUtil.GetStaffV2(TmpStaff, StaffStoreLink, POSSESSION.StaffID, ErrorText) then
        //     TmpStaff.Modify;

        // if not TSUtil.ReadStatementTransactions(true, ErrorText) then
        //     if (ErrorText <> '') then
        //         if not PosTransactionGui.PosConfirm(TransNoConnectionPrintThisTermOnlyQst, false) then
        //             exit;
        // PrintUtil.Init();
        // if not PrintUtil.PrintYReport(NoSuspPOSTransactionsVoided) then
        //     PosTransactionGui.PosMessage(PrintUtil.GetLastError)
        // else
        //     Commit;

        // SafeDenomPanelCommands.CheckOfflineLogoffOnRunningReportPrinting();
    end;

    procedure PreventNormalSaleCheck(): Boolean
    begin
        if STATE = "LSC POS Transaction State"::NEG_ADJ then
            exit(true);
        if POSSESSION.GetValue("LSC POS Tag"::"PREVENT_NORMSALE") <> '' then begin
            if not REC."Sale Is Return Sale" then begin
                PosTransactionGui.ErrorBeep(DiningTableOrContactNameRequiredMsg);
                exit(false);
            end;
        end;
        exit(true);
    end;

    procedure CheckTSStatus()
    var
        AzSError: Label 'Azure Storage Update failed';
        JQError: Label 'Failed to set status to Ready in Job Queue';
    begin
        // if not PosFunc.UseBackgroundSession then
        //     TSUtil.SendUnsentTablesDD3(0, true);
        // TSCheckError;
        // if POSSESSION.GetValue("LSC POS Tag"::"TS_ERROR") <> '' then
        //     PosTransactionGui.PosMessage(CopyStr(__TSError + ':' + POSSESSION.GetValue("LSC POS Tag"::"TS_ERROR"), 1, 250))
        // else
        //     if POSSESSION.GetValue('AZS_ERROR') <> '' then
        //         PosTransactionGui.PosMessage(CopyStr(AzSError + ':' + POSSESSION.GetValue('AZS_ERROR'), 1, 250))
        //     else
        //         if POSSESSION.GetValue('JQ_ERROR') <> '' then
        //             PosTransactionGui.PosMessage(CopyStr(JQError + ':' + POSSESSION.GetValue('JQ_ERROR'), 1, 250))

    end;

    procedure RetailCharge()
    var
        MenuLine2_l: Record "LSC POS Menu Line";
        RetailCharge: Record "LSC Retail Charge";
    begin
        RetailCharge.Reset;
        RetailCharge.SetRange("Store No.", POSSESSION.StoreNo);
        RetailCharge.SetRange("Calc. on Total Pressed", true);
        if not RetailCharge.IsEmpty then begin
            Clear(MenuLine2_l);
            MenuLine2_l.Command := Format("LSC POS Command"::RETAILCHARGE);
            RunCommand(MenuLine2_l);
        end;
    end;

    procedure DisplayTotals()
    var
        DisplayMultiply: Integer;
    begin
        DisplayMultiply := 1;
        if REC."Sale Is Return Sale" then
            DisplayMultiply := -1;

        OposUtil.DisplayTotals(DisplayMultiply * REC."Gross Amount", DisplayMultiply * Balance);
    end;

    procedure CheckBillPrinted(): Boolean
    var
        ErrorTextMsg: text;
        ConfirmTextMsg: text;
    begin
        // if HospFunc.CheckBillPrinted(REC, BillIsPrinted, ErrorTextMsg, ConfirmTextMsg) then
        //     exit(true);

        if ErrorTextMsg <> '' then begin
            PosTransactionGui.ErrorBeep(ErrorTextMsg);
            exit(false);
        end;
        if ConfirmTextMsg <> '' then begin
            if PosTransactionGui.PosConfirm(ConfirmTextMsg, false) then
                exit(true);
            exit(false);
        end;
    end;

    local procedure CheckVoidLineAndKDS(var DisplayErrorText: text): Boolean
    var
        ErrorTextMsg: text;
        ConfirmTextMsg: text;
    begin
        DisplayErrorText := '';
        // if HospFunc.CheckVoidLineAndKDS(REC, LineRec, ErrorTextMsg, ConfirmTextMsg) then
        //     exit(true);

        if ErrorTextMsg <> '' then begin
            DisplayErrorText := ErrorTextMsg;
            exit(false);
        end;
        if ConfirmTextMsg <> '' then begin
            if PosTransactionGui.PosConfirm(ConfirmTextMsg, false) then
                exit(true);
            exit(false);
        end;
    end;

    local procedure CheckVoidTransAndKDS(var AlreadyConfirmed: Boolean): Boolean
    var
        ErrorTextMsg: text;
        ConfirmTextMsg: text;
    begin
        AlreadyConfirmed := false;

        // if HospFunc.CheckVoidTransAndKDS(REC, ErrorTextMsg, ConfirmTextMsg) then
        //     exit(true);

        if ErrorTextMsg <> '' then begin
            PosTransactionGui.ErrorBeep(ErrorTextMsg);
            exit(false);
        end;
        if ConfirmTextMsg <> '' then begin
            if PosTransactionGui.PosConfirm(ConfirmTextMsg, false) then begin
                AlreadyConfirmed := true;
                exit(true);
            end;
            exit(false);
        end;
    end;

    procedure GetStoreSetup()
    begin
        StoreSetup.Get(POSSESSION.StoreNo);
    end;

    procedure LocationProfileEmail()
    var
        lMemberContact: Record "LSC Member Contact";
        EmailForStoresMsg: Label 'E-mail for Stores';
        lEmail: Text;
    begin
        PosFunc.GetCurrMemberContact(lMemberContact);
        lEmail := lMemberContact."E-Mail";
        POSGUI.OpenAlphabeticKeyboard(EmailForStoresMsg, lEmail, false, 'LocationProfileEmail', 1024);
    end;

    local procedure LocationProfileEmailOnClose(pEmail: Text; pPayload: Text)
    var
        xStoreRec: Record "LSC Store";
        StoreRec: Record "LSC Store";
        EmailAccount: Record "Email Account";
        Email: Codeunit Email;
        EmailScenario: Codeunit "Email Scenario";
        EmailMessage: Codeunit "Email Message";
        TempBlob: Codeunit "Temp Blob";
        OStream: OutStream;
        IStream: InStream;
        InventoryReport: Report "LSC Stores In Location Profile";
        lMailSubject: Text;
        lBody: Text;
        EmailAccountOK: Boolean;
        EmailForStoresMsg: Label 'E-mail for Stores';
        EmailInvalidQst: Label 'E-mail %1 is not valid.  Do you want to try again?';
        StoresNearbyMsg: Label 'Stores Nearby';
        PdfInAttachmMsg: Label 'A .pdf file is in attachments with information about stores in the nearby area that have the item on hand.';
        NoStoresHaveItemMsg: Label 'None of the Stores in "Location profile" %1\have Item %2 on hand.';
        EmailWasSentMsg: Label 'E-mail  with a list of stores with item %1 on inventory was sent to %2';
        InvReportMsg: Label 'Inventory Report';
        ItemPdfTkn: Label '- Item %1.pdf ';
        EmailAccNotSetupMsg: Label 'Email Account is not set up correctly.';
    begin
        if pEmail <> '' then begin
            if not PosFunc.CheckValidEmailAddresses(pEmail) then begin
                if PosTransactionGui.PosConfirm(StrSubstNo(EmailInvalidQst, pEmail), true) then begin
                    POSGUI.OpenAlphabeticKeyboard(EmailForStoresMsg, pEmail, false, pPayload, 1024);
                    exit;
                end else
                    exit;
            end;
            Clear(InventoryReport);
            // InventoryReport.SetItemNo(LocationPrintItemNo, LocationPrintVariantNo);
            InventoryReport.SetTableView(xStoreRec);
            EmailAccountOK := false;
            if EmailScenario.GetEmailAccount("Email Scenario"::Default, EmailAccount) then
                if EmailAccount."Email Address" <> '' then
                    if PosFunc.CheckValidEmailAddresses(EmailAccount."Email Address") then
                        EmailAccountOK := true;

            if not EmailAccountOK then begin
                PosTransactionGui.PosMessage(EmailAccNotSetupMsg);
                exit;
            end;

            TempBlob.CreateOutStream(OStream);
            InventoryReport.SaveAs('', ReportFormat::Pdf, OStream);
            TempBlob.CreateInStream(IStream);

            if not TempBlob.HasValue() then begin
                PosTransactionGui.PosMessage(StrSubstNo(NoStoresHaveItemMsg, StoreRec."Location Profile", LocationPrintItemNo));
                exit;
            end;
            PosTransactionGui.ErrorBeep('');

            CompanyInfo.Get;
            lMailSubject := StoresNearbyMsg;
            lBody := PdfInAttachmMsg;
            Recipients.Add(pEmail);
            EmailMessage.Create(Recipients, lMailSubject, lBody, false);
            EmailMessage.AddAttachment(InvReportMsg + StrSubstNo(ItemPdfTkn, LocationPrintItemNo), 'PDF', IStream);

            if not Email.Send(EmailMessage) then
                PosTransactionGui.PosMessage(EmailAccNotSetupMsg)
            else
                PosTransactionGui.PosMessage(StrSubstNo(EmailWasSentMsg, LocationPrintItemNo, pEmail));
        end;
    end;

    procedure LocationProfileSMS()
    var
        lStore: Record "LSC Store";
        lItem: Record Item;
        lProductGroupRec: Record "LSC Retail Product Group";
        lStoresInLocationProfiles: Record "LSC Stores In Location Profile";
        lInvLookupTable: Record "LSC Inventory Lookup Table";
        lStoreLocationProfilesRec: Record "LSC Store Location Profiles";
        lInvLookup: Record "LSC Inventory Lookup Table";
        SMSSetup: Record "LSC SMS Setup";
        lRecordRef: RecordRef;
        lRecordID: RecordID;
        lSMS: Text;
        LocationURL: Text;
        Payload: Text;
        lMinInventory: Integer;
        SmsForStoresMsg: Label 'SMS for Stores';
        StoreDoesNotHaveItemMsg: Label 'Store %1 does not have Item %2 on hand.';
    begin
        if POSCtrl.GetActiveLookupRecordID(lRecordID) then begin
            lRecordRef.Get(lRecordID);
            lRecordRef.SetTable(lInvLookup);
            lStore.Get(lInvLookup."Store No.");
            lStoresInLocationProfiles.SetRange("Inventory Lookup Profile", StoreSetup."Location Profile");
            lStoresInLocationProfiles.SetRange("Store No.", lStore."No.");
            if lStoresInLocationProfiles.FindFirst then begin
                lItem.SetRange("No.", LocationPrintItemNo);
                lItem.FindFirst;
                lProductGroupRec.Reset;
                lProductGroupRec.SetRange(Code, lItem."LSC Retail Product Code");
                lProductGroupRec.FindFirst;

                if lProductGroupRec."Min Loc. Prof. Inventory" > 0 then
                    lMinInventory := lProductGroupRec."Min Loc. Prof. Inventory"
                else begin
                    lStoreLocationProfilesRec.Reset;
                    lStoreLocationProfilesRec.SetRange(ProfileID, lStore."Location Profile");
                    lStoreLocationProfilesRec.FindFirst;
                    lMinInventory := lStoreLocationProfilesRec."Min Inventory";
                end;

                lInvLookupTable.SetRange("Item No.", LocationPrintItemNo);
                lInvLookupTable.SetRange("Store No.", lStore."No.");
                if lInvLookupTable.FindFirst then begin
                    lInvLookupTable.UpdateInventory(PosFuncProfile."TS Inv. Lookup");
                    if (lInvLookupTable."Net Inventory" > lMinInventory) then
                        LocationURL := lStore."Location Url";
                end;
            end;
            if StrLen(LocationURL) = 0 then begin
                PosTransactionGui.PosMessage(StrSubstNo(StoreDoesNotHaveItemMsg, lStore."No.", LocationPrintItemNo));
                exit;
            end else begin
                SMSSetup.Get();
                lSMS := SMSSetup."SMS local Country code";
                Payload := 'LocationProfileSMS,' + LocationURL;
                POSGUI.OpenAlphabeticKeyboard(SmsForStoresMsg, lSMS, false, Payload, 250);
            end;
        end;
    end;

    local procedure LocationProfileSMSOnClose(pSMS: Text; pPayload: Text)
    var
        SMSLog: Record "LSC SMS Message log";
        lInvLookup: Record "LSC Inventory Lookup Table";
        lRecordRef: RecordRef;
        lRecordID: RecordID;
        SMS: Codeunit "LSC SMS functions";
        LocationURL: Text;
        StoresNearbyMsg: Label 'Stores Nearby';
        FailedSmsErr: Label 'Failed to send SMS to Numer/s %1.\Error: %2';
        SmsSentMsg: Label 'SMS  with location path for store %1 was sent to %2';
        UnkownMsg: Label 'Unknown';
    begin
        if pSMS <> '' then begin
            if POSCtrl.GetActiveLookupRecordID(lRecordID) then begin
                lRecordRef.Get(lRecordID);
                lRecordRef.SetTable(lInvLookup);
                LocationURL := SelectStr(2, pPayload);
                while StrPos(LocationURL, '+') > 0 do
                    LocationURL := DelStr(LocationURL, StrPos(LocationURL, '+')) + '%20' + CopyStr(LocationURL, StrPos(LocationURL, '+') + StrLen('+'));

                if SMS.SendSMS(pSMS, LocationURL, StoresNearbyMsg) then
                    PosTransactionGui.PosMessage(StrSubstNo(SmsSentMsg, lInvLookup."Store No.", pSMS))
                else begin
                    if SMSLog.FindLast then
                        PosTransactionGui.PosMessage(StrSubstNo(FailedSmsErr, pSMS, SMSLog."Status Description"))
                    else
                        PosTransactionGui.PosMessage(StrSubstNo(FailedSmsErr, pSMS, UnkownMsg));
                    exit;
                end;
            end;
        end;
    end;

    procedure ProcessHospDataInput()
    var
        lHospLoyaltyTmp: Record "LSC Hosp. Loyalty XML Code" temporary;
        lHospLoyaltyTmp2: Record "LSC Hosp. Loyalty XML Code" temporary;
        lDealModItem: Record "LSC Deal Modifier Item";
        lMemberShipCard: Record "LSC Membership Card";
        SelectQtyTmp: Record "LSC Selected Quantity";
        PublishedOffer: Record "LSC Published Offer";
        lDealID: Code[20];
    begin
        PosTransactionGui.GetAndResetErrorMessageFlag; //sets flag to false
        SequenceNo := 0;
        SelectQtyTmp.Reset;
        SelectQtyTmp.SetRange(Type, SelectQtyTmp.Type::"Menu Selection");
        SelectQtyTmp.SetRange("User Ref.", POSSESSION.GetOriginalTerminalNo);
        SelectQtyTmp.DeleteAll;

        // PosFunc.GetHospLoyalty(lHospLoyaltyTmp);
        lHospLoyaltyTmp.SetRange("Entry Type", lHospLoyaltyTmp."Entry Type"::Saletype);
        if lHospLoyaltyTmp.FindFirst then begin
            CurrInput := lHospLoyaltyTmp."No.";
            ChangeSalesType(lHospLoyaltyTmp."No.", 'SETSALESTYPE_TRANS');
        end;

        lHospLoyaltyTmp.Reset;
        lHospLoyaltyTmp.SetRange("Entry Type", lHospLoyaltyTmp."Entry Type"::Loyaltycard);
        if lHospLoyaltyTmp.FindFirst then begin
            if lMemberShipCard.Get(lHospLoyaltyTmp."No.") then begin
                InfoTextDescription := lMemberShipCard."Club Code" + ' ' + lMemberShipCard."Scheme Code";
                InfoTextDescription2 := lHospLoyaltyTmp."No.";
                InputMemberCard(lHospLoyaltyTmp."No.");
            end;
        end;

        FromMobileQR := true;

        lHospLoyaltyTmp.Reset;
        lHospLoyaltyTmp.SetRange("Entry Type", lHospLoyaltyTmp."Entry Type"::Product);
        if lHospLoyaltyTmp.FindSet then
            repeat
                if lHospLoyaltyTmp."Group ID" = lHospLoyaltyTmp."Entry ID" then begin //Not part of a Deal
                    CurrInput := lHospLoyaltyTmp."No.";
                    ItemLine(false, false, lHospLoyaltyTmp.Qty, 0, '', '', '', '', 0, 0);
                    PosTransactionGui.DisplayErrorMessage;
                end;
            until lHospLoyaltyTmp.Next() = 0;

        lHospLoyaltyTmp.Reset;
        lHospLoyaltyTmp.SetRange("Entry Type", lHospLoyaltyTmp."Entry Type"::Recipe);
        if lHospLoyaltyTmp.FindSet then
            repeat
                if lHospLoyaltyTmp."Group ID" = lHospLoyaltyTmp."Entry ID" then begin //Not part of a Deal
                    CurrInput := lHospLoyaltyTmp."Group ID";
                    ItemLine(false, false, lHospLoyaltyTmp.Qty, 0, '', '', '', '', 0, 0);
                    PosTransactionGui.DisplayErrorMessage;

                    ProcessHospDataRecipe(lHospLoyaltyTmp."Entry ID", NewLine, lHospLoyaltyTmp."Line No.", 0);
                end;
            until lHospLoyaltyTmp.Next() = 0;

        lHospLoyaltyTmp.Reset;
        lHospLoyaltyTmp.SetRange("Entry Type", lHospLoyaltyTmp."Entry Type"::Deal);
        if lHospLoyaltyTmp.FindSet then
            repeat
                SelectQtyTmp.Reset;
                SelectQtyTmp.SetRange(Type, SelectQtyTmp.Type::"Menu Selection");
                SelectQtyTmp.SetRange("User Ref.", POSSESSION.GetOriginalTerminalNo);
                SelectQtyTmp.DeleteAll;

                CurrInput := lHospLoyaltyTmp."Group ID";
                lDealID := lHospLoyaltyTmp."Group ID";

                MobileGroupLineNo := lHospLoyaltyTmp."Line No.";

                //PosFunc.GetHospLoyalty(lHospLoyaltyTmp2);

                lHospLoyaltyTmp2.Reset;
                lHospLoyaltyTmp2.SetRange("Entry Type", lHospLoyaltyTmp2."Entry Type"::Dealmodifier);
                lHospLoyaltyTmp2.SetRange("Group Line No.", MobileGroupLineNo);
                if lHospLoyaltyTmp2.FindSet then
                    repeat
                        if lDealModItem.Get(lDealID, lHospLoyaltyTmp2."Deal Line No.", lHospLoyaltyTmp2."Deal Modifier Line No.") then
                            SetSelQtyDealMod(lDealModItem, lHospLoyaltyTmp2.Qty);
                    until lHospLoyaltyTmp2.Next() = 0;

                MultiplyWith := lHospLoyaltyTmp.Qty;
                DealPressed(lDealID);
                PosTransactionGui.DisplayErrorMessage();

            until lHospLoyaltyTmp.Next() = 0;

        FromMobileQR := false;

        lHospLoyaltyTmp.Reset;
        lHospLoyaltyTmp.SetRange("Entry Type", lHospLoyaltyTmp."Entry Type"::Coupon);
        if lHospLoyaltyTmp.FindSet then
            repeat
                if PublishedOffer.Get(lHospLoyaltyTmp."No.") then begin
                    if PublishedOffer."Discount Type" = PublishedOffer."Discount Type"::Coupon then begin
                        CurrInput := PublishedOffer."Discount No.";
                        CouponPressed;
                    end;
                end;
            until lHospLoyaltyTmp.Next = 0;

        CurrInput := '';

        CalcTotals;
    end;

    procedure ProcessHospDataRecipe(pEntryID: Code[20]; RecipeLine: Record "LSC POS Trans. Line"; GroupLineNo: Integer; DealLineNo: Integer)
    var
        lHospLoyaltyTmp: Record "LSC Hosp. Loyalty XML Code" temporary;
        InfoSubcode: Record "LSC Information Subcode";
        InfoCode: Record "LSC Infocode";
        BomComp: Record "BOM Component";
        ItemUnitofMeasure: Record "Item Unit of Measure";
        BomItem: Record Item;
        ParItem: Record Item;
        InfocodeTmp: Record "LSC Infocode" temporary;
        SelectQtyTmp: Record "LSC Selected Quantity";
        PosTransLine: Record "LSC POS Trans. Line";
        UOMMgmt: Codeunit "Unit of Measure Management";
        lString: Text;
        BomUOM: Code[10];
        BomQty: Decimal;
        BomPrice: Decimal;
        ParentQty: Decimal;
        lLineNo: Integer;
        CompCount: Integer;
        SetPrice: Boolean;
    begin
        // PosFunc.GetHospLoyalty(lHospLoyaltyTmp);
        lLineNo := RecipeLine."Line No." + 10000;

        //Ingredients
        ParItem.Reset;
        if ParItem.Get(RecipeLine.Number) then;
        lHospLoyaltyTmp.Reset;
        lHospLoyaltyTmp.SetRange("Entry Type", lHospLoyaltyTmp."Entry Type"::Ingredient);
        lHospLoyaltyTmp.SetRange("Entry ID", pEntryID);
        lHospLoyaltyTmp.SetRange("Group Line No.", GroupLineNo);
        lHospLoyaltyTmp.SetRange("Deal Line No.", DealLineNo);
        if lHospLoyaltyTmp.FindSet then
            repeat
                BomComp.Reset;
                BomComp.SetRange("Parent Item No.", ParItem."No.");
                BomComp.SetRange(Type, BomComp.Type::Item);
                BomComp.SetRange("No.", lHospLoyaltyTmp."No.");
                if BomComp.FindFirst then begin
                    BomItem.Get(BomComp."No.");
                    if (BomComp."Unit of Measure Code" = ParItem."Base Unit of Measure") and
                       (ItemUnitofMeasure.Get(BomComp."No.", RecipeLine."Unit of Measure"))
                    then begin
                        BomUOM := RecipeLine."Unit of Measure";
                        BomQty := -1 * RecipeLine.Quantity * BomComp."Quantity per";
                    end else begin
                        BomUOM := BomComp."Unit of Measure Code";
                        BomQty :=
                          -1 * RecipeLine.Quantity *
                          UOMMgmt.GetQtyPerUnitOfMeasure(ParItem, RecipeLine."Unit of Measure") * BomComp."Quantity per";
                    end;
                    if BomComp."LSC Exclusion" = BomComp."LSC Exclusion"::"Price Reduces" then begin
                        CompCount := 0;  //already excluded is nothing
                        if (CompCount < ParItem."LSC Max. Ingr. Rem. No Price") and (ParItem."LSC Max. Ingr. Rem. No Price" <> 0) then begin
                            SetPrice := true;
                            BomPrice := 0;
                            CompCount := CompCount + 1;
                        end else begin
                            if BomComp."LSC Price on Exclusion" = 0 then
                                SetPrice := false
                            else begin
                                SetPrice := true;
                                BomPrice := BomComp."LSC Price on Exclusion" / BomComp."Quantity per";
                            end;
                        end;
                    end else begin
                        SetPrice := true;
                        BomPrice := 0;
                    end;

                    // PopupFunc.InsertBomLine(
                    //   RecipeLine, BomComp."No.", BomComp."Line No.", SetPrice, BomPrice, BomQty, BomUOM,
                    //   RecipeLine."Line No.", lLineNo, BomComp."Parent Item No.", false);
                    // lLineNo := lLineNo + 10000;
                end;
            until lHospLoyaltyTmp.Next() = 0;

        //Modifiers
        Clear(InfocodeTmp);
        InfocodeTmp.DeleteAll;

        lHospLoyaltyTmp.Reset;
        lHospLoyaltyTmp.SetCurrentKey(Type, "Group Line No.", "Modifier Group");
        lHospLoyaltyTmp.SetRange("Entry Type", lHospLoyaltyTmp."Entry Type"::Productmodifier);
        lHospLoyaltyTmp.SetRange("Entry ID", pEntryID);
        lHospLoyaltyTmp.SetRange("Group Line No.", GroupLineNo);
        lHospLoyaltyTmp.SetRange("Deal Line No.", DealLineNo);
        if lHospLoyaltyTmp.FindSet then
            repeat
                InfocodeTmp.Code := lHospLoyaltyTmp."Modifier Group";
                if InfocodeTmp.Insert then;
            until lHospLoyaltyTmp.Next = 0;

        InfocodeTmp.Reset;
        if InfocodeTmp.FindSet then begin
            Item.Get(RecipeLine.Number);
            lLineNo -= 10000;  //Lastlineused

            repeat
                InfoCode.Get(InfocodeTmp.Code);

                lHospLoyaltyTmp.Reset;
                lHospLoyaltyTmp.SetCurrentKey(Type, "Group Line No.", "Modifier Group");
                lHospLoyaltyTmp.SetRange("Entry Type", lHospLoyaltyTmp."Entry Type"::Productmodifier);
                lHospLoyaltyTmp.SetRange("Entry ID", pEntryID);
                lHospLoyaltyTmp.SetRange("Group Line No.", GroupLineNo);
                lHospLoyaltyTmp.SetRange("Deal Line No.", DealLineNo);
                lHospLoyaltyTmp.SetRange("Modifier Group", InfocodeTmp.Code);
                if lHospLoyaltyTmp.FindSet then
                    repeat
                        InfoSubcode.Reset;
                        InfoSubcode.SetRange(Code, lHospLoyaltyTmp."Modifier Group");
                        InfoSubcode.SetRange("Trigger Function", InfoSubcode."Trigger Function"::Item);
                        lString := lHospLoyaltyTmp."No.";
                        if StrPos(lString, '|') > 0 then
                            lString := CopyStr(lHospLoyaltyTmp."No.", StrPos(lHospLoyaltyTmp."No.", '|') + 1);
                        InfoSubcode.SetRange(Subcode, lString);
                        if InfoSubcode.FindFirst then
                            SetSelQtyItemMod(InfoSubcode, lHospLoyaltyTmp.Qty);
                    until lHospLoyaltyTmp.Next = 0;

                //  PopupFunc.ItemModCheckPrice(Item."LSC Max. Modifiers No Price", 0, SequenceNo, PosTerminal."No.");
                ParentQty := 1;
                InfoCode."Quantity Handling" := InfoCode."Quantity Handling"::"Multiply Items w/Qty.";
                if RecipeLine.Quantity <> 0 then
                    ParentQty := RecipeLine.Quantity;

                // PopupFunc.InsertLinkedLinesFromInfocode(
                //   RecipeLine."Receipt No.", RecipeLine."Line No.", ParentQty, lLineNo, InfoCode, RecipeLine, PosTerminal."No.", REC."Trans. Currency Code");

                SelectQtyTmp.Reset;
                SelectQtyTmp.SetRange(Type, SelectQtyTmp.Type::"Menu Selection");
                SelectQtyTmp.SetRange("User Ref.", POSSESSION.GetOriginalTerminalNo);
                SelectQtyTmp.DeleteAll;

                PosTransLine.Reset;
                PosTransLine.SetRange("Receipt No.", RecipeLine."Receipt No.");
                if PosTransLine.FindLast then
                    lLineNo := PosTransLine."Line No.";
            until InfocodeTmp.Next = 0;
        end;
    end;

    procedure QueueHospLoyalty(var pErrorMessage: Text): Boolean
    begin
        //  exit(PosFunc.QueueHospLoyalty(pErrorMessage));
    end;

    procedure SetSelQtyDealMod(pDealModItem: Record "LSC Deal Modifier Item"; pQty: Decimal)
    var
        SelectQtyTmp: Record "LSC Selected Quantity";
    begin
        SelectQtyTmp.Init;
        SequenceNo := SequenceNo + 1;
        SelectQtyTmp.Type := SelectQtyTmp.Type::"Menu Selection";
        SelectQtyTmp."User Ref." := POSSESSION.GetOriginalTerminalNo;
        SelectQtyTmp."Item No." := Format(SequenceNo);
        Evaluate(SelectQtyTmp."Selection Code", Format(pDealModItem."Offer Line No."));
        Evaluate(SelectQtyTmp."Selected Subcode", Format(pDealModItem."Deal Modifier Line No."));
        SelectQtyTmp."Variant Code" := pDealModItem."Variant Code";
        SelectQtyTmp."Serial No." := '';
        SelectQtyTmp."Qty." := pQty;
        if pDealModItem."Added Amount" <> 0 then begin
            SelectQtyTmp."New Price" := pDealModItem."Added Amount";
            SelectQtyTmp."Price Information" := SelectQtyTmp."Price Information"::"Extra Charge";
        end;
        SelectQtyTmp."Line Is Linked to Parent" := true;
        SelectQtyTmp."Unit of Measure" := pDealModItem."Unit of Measure";
        SelectQtyTmp."Variant Description" := '';
        SelectQtyTmp."Add. Benefit Line No." := 0;
        SelectQtyTmp.Insert;
    end;

    procedure SetSelQtyItemMod(InfoSubcode: Record "LSC Information Subcode"; pQty: Decimal)
    var
        SelectQtyTmp: Record "LSC Selected Quantity";
    begin
        SelectQtyTmp.Init;
        SequenceNo := SequenceNo + 1;
        SelectQtyTmp.Type := SelectQtyTmp.Type::"Menu Selection";
        SelectQtyTmp."User Ref." := POSSESSION.GetOriginalTerminalNo;
        SelectQtyTmp."Item No." := Format(SequenceNo);
        Evaluate(SelectQtyTmp."Selection Code", InfoSubcode.Code);
        Evaluate(SelectQtyTmp."Selected Subcode", InfoSubcode.Subcode);
        SelectQtyTmp."Variant Code" := InfoSubcode."Variant Code";
        SelectQtyTmp."Serial No." := '';
        SelectQtyTmp."Qty." := pQty;
        case InfoSubcode."Price Handling" of
            InfoSubcode."Price Handling"::"No Charge":
                SelectQtyTmp."Price Information" := SelectQtyTmp."Price Information"::"No Charge";
            InfoSubcode."Price Handling"::"Always charge":
                SelectQtyTmp."Price Information" := SelectQtyTmp."Price Information"::"Extra Charge";
            else begin
                if InfoSubcode."Trigger Function" = InfoSubcode."Trigger Function"::Item then
                    SelectQtyTmp."Price Information" := SelectQtyTmp."Price Information"::Price
                else
                    SelectQtyTmp."Price Information" := SelectQtyTmp."Price Information"::" ";
            end;
        end;
        SelectQtyTmp."New Price" := 0;
        SelectQtyTmp."Line Is Linked to Parent" := true;
        SelectQtyTmp."Unit of Measure" := InfoSubcode."Unit of Measure";
        SelectQtyTmp."Variant Description" := '';
        SelectQtyTmp."Add. Benefit Line No." := 0;
        SelectQtyTmp.Insert;
    end;

    procedure ReOrderMenuType(MenuType_p: Code[1])
    var
        PosTrLine: Record "LSC POS Trans. Line";
        PosTrLineTmp: Record "LSC POS Trans. Line" temporary;
        LineNo_l: Integer;
    begin
        if not CheckBillPrinted then
            exit;
        PosTrLineTmp.DeleteAll;
        PosTrLine.Reset;
        PosTrLine.SetRange("Receipt No.", REC."Receipt No.");
        if not PosTrLine.FindLast then
            exit;
        LineNo_l := PosTrLine."Line No.";
        PosTrLine.SetRange("Entry Status", PosTrLine."Entry Status"::" ");
        if MenuType_p <> '' then
            PosTrLine.SetRange(PosTrLine."Restaurant Menu Type Code", MenuType_p);
        PosTrLine.SetRange(PosTrLine."Round No.", 0);
        if PosTrLine.FindSet then begin
            repeat
                PosTrLineTmp.TransferFields(PosTrLine);
                if PosTrLineTmp.Insert then;
            until PosTrLine.Next = 0;
        end;
        POSTransactionFunctions.ReOrderInsert(PosTrLineTmp, LineNo_l);
    end;

    procedure ReOrderQty(Parameter_p: Text[100])
    var
        PosTrLine: Record "LSC POS Trans. Line";
        PosTrLineTmp: Record "LSC POS Trans. Line" temporary;
        QtyCopy: Decimal;
        LineNo_l: Integer;
        i: Integer;
        NoCopy: Integer;
    begin
        if not CheckBillPrinted then
            exit;
        if (Parameter_p = '') and (CurrInput = '') then begin
            PosTransactionGui.OpenNumericKeyboard(QuantityToReorderText, '1', Enum::"LSC POS Trans. Numpad Trigger"::"Reorder Quantity");
            exit;
        end;
        if CurrInput = '' then begin
            QtyCopy := 1;
            if Evaluate(QtyCopy, Parameter_p) then;
        end else
            if Evaluate(QtyCopy, CurrInput) then;
        PosTrLineTmp.DeleteAll;
        PosTrLine.Reset;
        PosTrLine.SetRange("Receipt No.", REC."Receipt No.");
        if not PosTrLine.FindLast then
            exit;
        LineNo_l := PosTrLine."Line No.";
        PosTrLine.SetRange("Entry Status", PosTrLine."Entry Status"::" ");
        POSLINES.GetCurrentLine(PosTrLine);
        if (PosTrLine."Entry Type" = PosTrLine."Entry Type"::Item) and (PosTrLine."Promotion No." <> '') and (PosTrLine."Line No." <> PosTrLine."Parent Line") then begin
            if PosTrLine.Get(REC."Receipt No.", PosTrLine."Parent Line") then;
        end;
        if (PosTrLine."Entry Type" = PosTrLine."Entry Type"::FreeText) and (PosTrLine."Promotion No." <> '') and (PosTrLine.Quantity <> 1) then
            QtyCopy := 1;
        PosTrLineTmp.TransferFields(PosTrLine);
        PosTrLineTmp.Validate(Quantity, QtyCopy * PosTrLineTmp.Quantity);
        PosTrLineTmp.CalcPrices;
        PosTrLineTmp.Insert;
        if not POSTransactionFunctions.CopyLinkedLines(PosTrLineTmp, PosTrLine."Line No.", QtyCopy) then begin
            NoCopy := QtyCopy;
            for i := 1 to NoCopy do begin
                CurrInput := '1';
                ReOrderQty(Parameter_p);
            end;
            exit;
        end;
        POSTransactionFunctions.ReOrderInsert(PosTrLineTmp, LineNo_l);
        CalcTotals;
        CurrInput := '';
    end;

    procedure CustomerOrderList()
    var
        POSTransLine_l: Record "LSC POS Trans. Line";
        CustomerOrderListPanel: Codeunit "LSC Customer Order List Panel";
        CONotInTrainingMode: Label 'Customer Order functions are not accessible in Training Mode.';
    begin
        if REC."Entry Status" = REC."Entry Status"::Training then begin
            PosTransactionGui.ErrorBeep(CONotInTrainingMode);
            exit;
        end;
        if StateTxt <> Format("LSC POS Transaction State"::SALES) then
            SalePressed(true);

        POSTransLine_l.SetRange("Receipt No.", REC."Receipt No.");
        POSTransLine_l.SetFilter("Text Type", '<>%1', "LSC POS Trans. Line Text Type"::"Member Text");
        if POSTransLine_l.FindFirst then begin
            PosTransactionGui.ErrorBeep(CurrTransMustBeFinishedErr);
            exit;
        end;

        CustomerOrderListPanel.OpenPanel(REC."Receipt No.", false);
    end;

    procedure CustomerOrderListAfterPosting()
    begin
        // SetFunctionMode("LSC POS Command"::ITEM);
        // SelectDefaultMenu;
        // CurrInput := '';
    end;

    procedure CustomerOrder(pParam: Text[100])
    var
        POSTransLine_l: Record "LSC POS Trans. Line";
        COPosFunc: Codeunit "LSC CO POS Functions";
        COListPanel: Codeunit "LSC Customer Order List Panel";
        Payload: Text[1024];
        DocID: Code[40];
        OrderNoMsg: Label 'Order No.';
        TypeParam: Code[10];
        DocStatus: Integer;
        TypeParamNotFoundErr: Label 'TypeParam not found in procedure CustomerOrder';
    begin
        //---------------------------------------------------------------
        // pParm:
        // Direct Input: TypeParm
        // Queue Input : #TypeParm;DocumentId(Guid)
        //
        // TypeParm 0 To Pick
        // TypeParm 1 To Collect
        //---------------------------------------------------------------
        Payload := 'Postrans';

        POSTransLine_l.SetRange("Receipt No.", REC."Receipt No.");
        if POSTransLine_l.FindFirst then begin
            PosTransactionGui.ErrorBeep(CurrTransMustBeFinishedErr);
            exit;
        end;

        if CopyStr(pParam, 1, 1) = '#' then begin
            TypeParam := CopyStr(pParam, 2, 1);
            CurrInput := CopyStr(pParam, 4);
            if (TypeParam = '0') then
                TypeParam := 'TO_PICK'
            else
                TypeParam := 'TO_COLLECT';
        end else
            TypeParam := pParam;

        case TypeParam of
            'TO_PICK':
                TypeParam := '0';
            'TO_COLLECT':
                TypeParam := '1';
            else begin
                PosTransactionGui.ErrorBeep(TypeParamNotFoundErr);
                exit;
            end;
        end;

        if not Evaluate(DocStatus, TypeParam) then
            exit;

        if CurrInput = '' then begin
            CustomerOrder_pParameter := pParam;
            PosTransactionGui.OpenNumericKeyboard(OrderNoMsg, '', Enum::"LSC POS Trans. Numpad Trigger"::CustomerOrder);
            exit;
        end;

        DocID := CurrInput;
        CurrInput := '';

        // case DocStatus of
        //     0: //To Pick
        //         COPosFunc.OrderPick(DocID, 'COLIST');
        //     1: //To Collect
        //         begin
        //             COListPanel.OpenPanel(REC."Receipt No.", true);
        //             COListPanel.GetCollectOrders();
        //             COListPanel.OrderCollect(DocID);
        //             SalePressed(true);
        //         end;
        // end;
    end;

    internal procedure CustomerOrderCreate()
    var
        CustomerOrderHeaderKeepTemp: Record "LSC Customer Order Header";
        MemberContactTemp: Record "LSC Member Contact" temporary;
        MemberAccountTemp: Record "LSC Member Account" temporary;
        COUtility: Codeunit "LSC CO Utility";
        CustomerOrderCreatePanel: Codeunit "LSC CO Create Panel";
        IsHandled: Boolean;
    begin
        // if COTotalHasBeenPressed then
        //     CustomerOrderHeaderKeepTemp := CustomerOrderHeader_Temp;
        // ClearAndDeleteAllCOTempVariables();
        // GrossAmountBeforeCreatingCO := REC."Gross Amount";
        // //MemberContactTemp := Member_.GetMemberRec();
        // //MemberAccountTemp := Member_.GetAccountRec();
        // COUtility.CreateCustOrderTempFromPOSTransaction(REC, CustomerOrderHeader_Temp, CustomerOrderLine_Temp, CustomerOrderDiscountLine_Temp, MemberAccountTemp, MemberContactTemp);
        // gOldMemberCardNo := REC."Member Card No.";
        // if COTotalHasBeenPressed then begin
        //     CustomerOrderHeader_Temp := CustomerOrderHeaderKeepTemp;
        //     CustomerOrderHeader_Temp.Modify();
        // end;
        // POSTransactionEvents.OnBeforeOpenCreatePanel(CustomerOrderLine_Temp, IsHandled);
        // if IsHandled then
        //     exit;

        // CustomerOrderCreatePanel.OpenPanel(0, CustomerOrderHeader_Temp, CustomerOrderLine_Temp, CustomerOrderPayment_Temp, CustomerOrderDiscountLine_Temp, '');
    end;

    procedure QueueCOQRCode(var pErrorMessage: Text): Boolean
    begin
        // exit(PosFunc.QueueCOQRCode(pErrorMessage));
    end;

    procedure GetCODataFromQR(var pDocStatus: Option "To Pick","To Collect"; var pDocumentId: Code[40]): Boolean
    begin
        // exit(PosFunc.GetCODataFromQR(pDocStatus, pDocumentId));
    end;

    procedure GetCODataFromBarcode(var pDocStatus: Option "To Pick","To Collect"; var pDocumentId: Code[40]): Boolean
    var
        WhereCOTxtBegins: Integer;
    begin
        WhereCOTxtBegins := StrPos(CurrInput, ' ');
        pDocumentId := CopyStr(CurrInput, WhereCOTxtBegins + 1);
        pDocStatus := pDocStatus::"To Collect";
        if pDocumentId <> '' then
            exit(true);
    end;

    procedure ProcessCODataInput()
    var
        DocStatus: Option "To Pick","To Collect";
        DocumentId: Code[40];
        DocStatusCode: Code[10];
        ParmText: Text[100];
    begin
        if GetCODataFromQR(DocStatus, DocumentId) then begin
            DocStatusCode := Format(DocStatus, 0, '<Number>');
            ParmText := '#' + DocStatusCode + ';' + Format(DocumentId);
            POSGUI.PostCommand("LSC POS Command"::CUSTOMER_ORDER, ParmText);
        end else
            if GetCODataFromBarcode(DocStatus, DocumentId) then begin
                DocStatusCode := Format(DocStatus, 0, '<Number>');
                ParmText := '#' + DocStatusCode + ';' + Format(DocumentId);
                POSGUI.PostCommand("LSC POS Command"::CUSTOMER_ORDER, ParmText);
            end;
    end;

    procedure ProcessSPGDataInput()
    var
        DocumentId: Code[20];
        ParmText: Text[100];
    begin
        if GetSPGDataFromQR(DocumentId) then begin
            ParmText := Format(DocumentId);
            POSGUI.PostCommand("LSC POS Command"::COLLECTSCANPAYGO, ParmText);
        end;
    end;

    procedure QueueSPGQRCode(var pErrorMessage: Text): Boolean
    begin
        exit(PosFunc.QueueSPGQRCode(pErrorMessage));
    end;

    procedure GetSPGDataFromQR(var pDocumentId: Code[20]): Boolean
    begin
        // exit(PosFunc.GetSPGDataFromQR(pDocumentId));
    end;

    procedure LoadPosTrans(pReceiptNo: Code[20])
    begin
        LoadPosTrans(pReceiptNo, false);
    end;

    procedure LoadPosTrans(pReceiptNo: Code[20]; suppressError: Boolean)
    begin
        if not suppressError then begin
            REC.Get(pReceiptNo);
            exit;
        end;

        if not REC.Get(pReceiptNo) then
            ClearLastError();
    end;

    procedure WebReplication(pParam: Text[100])
    var
        ShowStatus: Boolean;
        ErrorText: Text[1024];
    begin

        // if UpperCase(pParam) = 'SHOWSTATUS' then
        //     ShowStatus := true
        // else
        //     ShowStatus := false;
        // if not PosFunc.WebReplication(ShowStatus, ErrorText) then begin
        //     if ErrorText <> '' then
        //         PosTransactionGui.ErrorBeep(ErrorText);
        //     exit;
        // end;
    end;

    procedure SetHardwareProfile(ProfileID: Code[10])
    begin
        if ProfileID <> '' then
            PosSetup.Get(ProfileID)
        else
            PosSetup.Get(POSSESSION.HardwareProfileID);

        EFT.InitEFTServer;
    end;

    procedure FBPStatus(POSMenuLine: Record "LSC POS Menu Line")
    var
    //POSMemberFBPPanel: Codeunit "LSC POS Member FBP Panel";
    begin
        //POSMemberFBPPanel.Run(POSMenuLine);
    end;

    procedure ShowMemberCouponList(POSMenuLine: Record "LSC POS Menu Line")
    var
        MemberCouponPanelMgt: Codeunit "LSC Member Coupon Panel Mgt.";
    begin
        MemberCouponPanelMgt.Run(POSMenuLine);
    end;

    local procedure CopyPostedTransaction()
    var
        RecordIDLoc: RecordID;
        RecordRefLoc: RecordRef;
        Transaction: Record "LSC Transaction Header";
        ActiveLookupID: Code[20];
        ErrorText: Text;
        TransHasBeenCopiedMsg: Label 'Transaction %1 from %2 at %3 has been copied to the POS';
        TransHasBeenCopiedMsgCustomerOrder: Label 'Transaction %1 linked to Customer Order %2 from %3 at %4 has been copied to the POS';
    begin
        // if POSSESSION.GetValue("LSC POS Tag"::"PREVENT_NORMSALE") <> '' then begin
        //     PosTransactionGui.ErrorBeep(DiningTableOrContactNameRequiredMsg);
        //     if PosTransactionGui.PosConfirm(DiningTableOrContactNameRequiredMsg, false) then;
        //     exit;
        // end;
        // CurrentTableNo := REC."Table No.";
        // CurrentTableDescription := REC.Comment;
        // POSSESSION.SetValue("LSC POS Tag"::"COPY_TR", '1');
        // ActiveLookupID := POSCtrl.GetActiveLookupID();
        // if ActiveLookupID = 'REGISTER' then
        //     if POSCtrl.GetActiveLookupRecordID(RecordIDLoc) then begin
        //         RecordRefLoc.Get(RecordIDLoc);
        //         RecordRefLoc.SetTable(Transaction);
        //         CopyTransaction(Transaction);
        //         REC."New Transaction" := false;
        //         if (PosFuncProfile."Sales Person Mode" = PosFuncProfile."Sales Person Mode"::Automatic) then
        //             REC."Sales Staff" := POSSESSION.StaffID;
        //         REC."Trans. Date" := Today;
        //         REC."Trans Time" := SYSTEM.Time;
        //         REC."Table No." := CurrentTableNo;
        //         REC.Comment := CurrentTableDescription;
        //         REC."Dining Tbl. Description" := CurrentTableDescription;
        //         REC."Sale Is Copied Transaction" := true;
        //         if Member.LoadMemberInfo(REC."Member Card No.", ErrorText, true) then begin
        //             REC."Starting Point Balance" := Member.TotalRemainingPointsInt;
        //         end;
        //         REC.Modify;
        //         Commit;
        //         if Transaction."Customer Order" then
        //             PosTransactionGui.PosMessage(StrSubstNo(TransHasBeenCopiedMsgCustomerOrder, Transaction."Receipt No.", Transaction."Customer Order ID", Transaction.Date, Transaction.Time))
        //         else
        //             PosTransactionGui.PosMessage(StrSubstNo(TransHasBeenCopiedMsg, Transaction."Receipt No.", Transaction.Date, Transaction.Time));
        //     end;
        // POSSESSION.SetValue("LSC POS Tag"::"COPY_TR", '');
    end;

    local procedure VoidAndCopyTransaction()
    var
        EmptyPOSTransLines_L: Record "LSC POS Trans. Line";
        POSTransPostingState: Record "LSC POS Trans. Posting State";
        POSLookup_L: Record "LSC POS Lookup";
        RetailCalendar: Record "LSC Retail Calendar";
        TenderType_L: Record "LSC Tender Type";
        Transaction: Record "LSC Transaction Header";
        TransPaymentEntry_L: Record "LSC Trans. Payment Entry";
        RecordRefLoc: RecordRef;
        RecordIDLoc: RecordID;
        HospitalityPOSCommands: Codeunit "LSC Hospitality POS Startup";
        RetailCalendarManagement: Codeunit "LSC Retail Calendar Management";
        ErrorText: Text;
        ActiveLookupID: Code[20];
        ErrorCode: Code[10];
        KeyValue: Code[30];
        RevReceiptNo: Code[20];
        FoundTenderTypeRecord: Boolean;
        IsHandled: Boolean;
        MgrRequiredErr: Label 'Manager privileges are required for this function';
        TransHasBeenVoidedWithReturnTransMsg: Label 'Transaction %1 has been voided with return transaction %2. It has also been copied to the POS';
        TransHasBeenVoidedWithReturnTransMsgCustomerOrder: Label 'Transaction %1 Linked with Customer Order %2 has been voided with return transaction %3. It has also been copied to the POS';
    begin
        if not POSSESSION.MgrKey then
            Error(MgrRequiredErr);

        ActiveLookupID := POSCtrl.GetActiveLookupID();
        if ActiveLookupID = 'REGISTER' then
            if POSCtrl.GetActiveLookupRecordID(RecordIDLoc) then begin
                RecordRefLoc.Get(RecordIDLoc);
                RecordRefLoc.SetTable(Transaction);
            end;

        POSTransactionEvents.OnBeforeVoidAndCopyTransaction(Transaction, IsHandled);
        if IsHandled then
            exit;

        REC."Transaction Type" := REC."Transaction Type"::Sales;
        REC."Sale Is Return Sale" := true;
        CurrentTableNo := Transaction."Table No.";
        CurrentTableDescription := Transaction.Comment;
        REC."Table No." := CurrentTableNo;
        REC.Comment := CurrentTableDescription;
        REC."Dining Tbl. Description" := CurrentTableDescription;
        REC.Modify;
        RefundMgt.InitRefund(Transaction, REC."Receipt No.");
        POSSESSION.SetValue("LSC POS Tag"::"VOID_AND_COPY_TR", '');
        //  RefundMgt.PrepareTransToRefund;
        // POSSESSION.SetValue("LSC POS Tag"::"VOID_AND_COPY_TR", '1');
        //  KeyValue := RefundMgt.CreateRefundLookup(POSLookup_L, REC);
        POSSESSION.SetValue("LSC POS Tag"::"VOID_AND_COPY_TR", '');
        CalcTotals;
        if (Balance = 0) and (Transaction."Refund Receipt No." <> '') then begin
            EmptyPOSTransLines_L.Reset;
            EmptyPOSTransLines_L.SetRange("Receipt No.", REC."Receipt No.");
            EmptyPOSTransLines_L.SetRange(Quantity, 0);
            EmptyPOSTransLines_L.SetRange(Amount, 0);
            EmptyPOSTransLines_L.DeleteAll;
            Error(StrSubstNo(NoLinesWereEligibleForRef, Transaction."Receipt No."));
        end;
        TransPaymentEntry_L.Reset;
        TransPaymentEntry_L.SetRange("Store No.", Transaction."Store No.");
        TransPaymentEntry_L.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
        TransPaymentEntry_L.SetRange("Transaction No.", Transaction."Transaction No.");
        if TransPaymentEntry_L.FindSet then
            repeat
                InitNewLine();
                NewLine."Entry Type" := NewLine."Entry Type"::Payment;
                NewLine.Validate(Number, TransPaymentEntry_L."Tender Type");
                NewLine.Validate(Amount, TransPaymentEntry_L."Amount Tendered");
                if TransPaymentEntry_L."Currency Code" <> '' then begin
                    NewLine."Currency Code" := TransPaymentEntry_L."Currency Code";
                    NewLine."Amount In Currency" := TransPaymentEntry_L."Amount in Currency";
                end;
                if TenderType_L.Get(TransPaymentEntry_L."Store No.", TransPaymentEntry_L."Tender Type") then
                    if TenderType_L."Function" = TenderType_L."Function"::Card then begin
                        EFT.VoidCardEntriesForTransaction(REC, LineRec, Transaction, RealBalance);
                        NewLine."Card Type" := TransPaymentEntry_L."Card No.";
                    end;

                NewLine.InsertLine;
                if TenderType_L.Get(REC."Store No.", TransPaymentEntry_L."Tender Type") then begin
                    if not FoundTenderTypeRecord then
                        TenderType := TenderType_L;
                    if TenderType_L."Rounding To" <> 0 then
                        TenderType := TenderType;
                    FoundTenderTypeRecord := true;
                end;
            until TransPaymentEntry_L.Next = 0;

        REC."New Transaction" := false;
        if (PosFuncProfile."Sales Person Mode" = PosFuncProfile."Sales Person Mode"::Automatic) then
            REC."Sales Staff" := POSSESSION.StaffID;
        REC."Trans. Date" := Today;
        REC."Trans Time" := SYSTEM.Time;
        REC."Table No." := CurrentTableNo;
        REC.Comment := CurrentTableDescription;
        REC."Dining Tbl. Description" := CurrentTableDescription;
        REC."Customer No." := Transaction."Customer No.";
        REC."Member Card No." := Transaction."Member Card No.";
        REC.Modify;
        Transaction."Refund Receipt No." := REC."Receipt No.";
        Transaction.Modify;
        POSSESSION.SetValue("LSC POS Tag"::"VOIDCOPY-REVRECEIPT", RevReceiptNo);
        POSSESSION.SetValue("LSC POS Tag"::"VOIDCOPY-TR-STORE", Transaction."Store No.");
        POSSESSION.SetValue("LSC POS Tag"::"VOIDCOPY-TR-TERM", Transaction."POS Terminal No.");
        POSSESSION.SetValue("LSC POS Tag"::"VOIDCOPY-TR-NO", Format(Transaction."Transaction No."));
        POSSESSION.SetTransPostingSource(POSTransPostingState."Posting Source"::"Void and Copy");

        // if not RefundMgt.CopyTransRefundInfo(Transaction, REC, ErrorCode, ErrorText) then begin
        //     PosTransactionGui.ErrorBeep(ErrorText);
        //     exit;
        // end;

        // POSTransactionEventsPub.OnProcessRefundSelection(Transaction, REC, true);

        // if Member.LoadMemberInfo(REC."Member Card No.") then begin
        //     REC."Starting Point Balance" := Member.TotalRemainingPointsInt;
        //     REC.Modify;
        // end;

        TransactionTendered;
        POSTransactionEvents.OnAfterTransactionTendered2(IsHandled);
        if IsHandled then
            exit;
        InsertTmpTransaction(true);
        InitNewLine;

        CopyTransaction(Transaction);
        REC."New Transaction" := false;
        if (PosFuncProfile."Sales Person Mode" = PosFuncProfile."Sales Person Mode"::Automatic) then
            REC."Sales Staff" := POSSESSION.StaffID;
        REC."Trans. Date" := RetailCalendarManagement.GetStoreTransactionDate(Transaction."Store No.", RetailCalendar."Calendar Type"::"Opening Hours", Today, SYSTEM.Time);
        REC."Trans Time" := SYSTEM.Time;
        REC."Table No." := CurrentTableNo;
        REC.Comment := CurrentTableDescription;
        REC."Dining Tbl. Description" := CurrentTableDescription;
        REC."Sale Is Copied Transaction" := true;
        REC.Modify;
        Commit;
        if Transaction."Customer Order" then
            PosTransactionGui.PosMessage(StrSubstNo(TransHasBeenVoidedWithReturnTransMsgCustomerOrder, Transaction."Receipt No.", Transaction."Customer Order ID", RevReceiptNo))
        else
            PosTransactionGui.PosMessage(StrSubstNo(TransHasBeenVoidedWithReturnTransMsg, Transaction."Receipt No.", RevReceiptNo));
        if (REC."Table No." > 0) or (REC."No. of Covers" > 0) then begin //Hospitality POS
            POSSESSION.SetValue("LSC POS Tag"::"CURRORDER", REC."Receipt No.");
            // HospitalityPOSCommands.DirectEdit(true);
        end;
    end;

    procedure CopyTransaction(var Transaction: Record "LSC Transaction Header")
    var
        PosTransLineBuffer: Record "LSC POS Trans. Line" temporary;
        PosTransPeriodicDiscBuffer: Record "LSC POS Trans. Per. Disc. Type" temporary;
        DealPosTransLineBuffer: Record "LSC POS Trans. Line" temporary;
        SelectionBuffer: Record "LSC POS Trans. Line" temporary;
        l_PosTransaction: Record "LSC POS Transaction";
        MessageText: Text[250];
        ErrorText: Text[250];
        NewReceiptNo: Code[20];
        IsHandled: Boolean;
        NoValidItemLinesToCopyMsg: Label 'Transaction %1 has been voided. No valid items lines to copy';
    begin
        POSTransactionEvents.OnBeforeCopyTransaction(Transaction, IsHandled);
        if IsHandled then
            exit;

        REC.Init;
        l_PosTransaction.SetRange("New Transaction", true);
        l_PosTransaction.SetRange("Transaction Type", l_PosTransaction."Transaction Type"::Logoff);
        l_PosTransaction.SetRange("Store No.", POSSESSION.StoreNo);
        l_PosTransaction.SetRange("POS Terminal No.", POSSESSION.TerminalNo);

        if l_PosTransaction.FindFirst then
            NewReceiptNo := l_PosTransaction."Receipt No.";

        if NewReceiptNo = '' then
            NewReceiptNo := PosFunc.InsertTmpTrans(LastSlipNo, POSSESSION.WorkShiftNo, GLobalSalesType, CurrTableNo, TrainingActive, CurrTableDescr);

        CopyTransSalesLinesWithoutPopUps := true;
        InitCRTransaction(Transaction, NewReceiptNo);

        PrepareCRTrans(Transaction, REC, PosTransLineBuffer, PosTransPeriodicDiscBuffer, DealPosTransLineBuffer, -1);

        if not ValidateCRLines(PosTransLineBuffer, DealPosTransLineBuffer, SelectionBuffer, MessageText, ErrorText) then
            PosTransactionGui.ErrorBeep(ErrorText);

        if not CreateCRLines(SelectionBuffer, Transaction, PosTransLineBuffer, PosTransPeriodicDiscBuffer, DealPosTransLineBuffer, -1) then begin
            ClearPOSTransaction();
            ClearGlobs();
            StartNewTransaction;
            Error(StrSubstNo(NoValidItemLinesToCopyMsg, Transaction."Receipt No."));
        end;

        CopyTransSalesLinesWithoutPopUps := false;
        TotalPressed(false);

        CopyTransSalesperson(Transaction, REC);
    end;

    local procedure InitCRTransaction(var Transaction: Record "LSC Transaction Header"; pNewReceiptNo: Code[20])
    var
        Store: Record "LSC Store";
        TransHospitalityEntry: Record "LSC Trans. Hospitality Entry";
        RetailCalendar: Record "LSC Retail Calendar";
        RetailCalendarManagement: Codeunit "LSC Retail Calendar Management";
        ErrorText: Text;
    begin
        if pNewReceiptNo <> '' then begin
            REC.SetRange("Receipt No.", pNewReceiptNo);
            REC.Get(pNewReceiptNo);
            Store.Get(Transaction."Store No.");
            REC."Receipt No." := pNewReceiptNo;
        end else
            REC.Init;

        REC."Transaction Type" := Transaction."Transaction Type"::Sales;
        if not CopyTransSalesLinesWithoutPopUps then
            REC."Sale Is Return Sale" := true;
        REC."Trans. Date" := Transaction.Date;
        if REC."Trans. Date" = 0D then
            REC."Trans. Date" := Today;
        REC."Store No." := POSSESSION.StoreNo;
        REC."Created on POS Terminal" := POSSESSION.TerminalNo;
        REC.Validate("Staff ID", POSSESSION.StaffID());
        REC."Sales Staff" := POSSESSION.StaffID();
        REC."POS Terminal No." := POSSESSION.TerminalNo;
        REC.Validate("Hosp. Type Sequence");
        REC."Original Date" := Transaction."Original Date";
        REC."Trans Time" := Time;
        REC."Trans. Date" :=
          RetailCalendarManagement.GetStoreTransactionDate(
            Store."No.", RetailCalendar."Calendar Type"::"Opening Hours",
            REC."Trans. Date", REC."Trans Time");
        REC."Source Type" := Transaction."Source Type";
        REC."Trans. Currency Code" := Transaction."Trans. Currency";
        REC."Customer No." := Transaction."Customer No.";
        REC."Post as Shipment" := Transaction."Post as Shipment";
        REC."Retrieved from Receipt No." := Transaction."Receipt No.";
        REC."Member Card No." := Transaction."Member Card No.";
        REC."Sell-to Contact No." := Transaction."Sell-to Contact No.";
        REC."Gen. Bus. Posting Group" := Transaction."Gen. Bus. Posting Group";
        REC."VAT Bus.Posting Group" := Transaction."VAT Bus.Posting Group";
        REC."Table No." := CurrentTableNo;
        REC.Comment := CurrentTableDescription;
        REC."Dining Tbl. Description" := CurrentTableDescription;
        REC."No. of Covers" := Transaction."No. of Covers";
        if TransHospitalityEntry.Get(Transaction."Store No.", Transaction."POS Terminal No.", Transaction."Transaction No.", 0) then
            REC."Original Receipt No." := TransHospitalityEntry."Original Receipt No.";
        REC."Currency Factor" := Transaction."Currency Factor";
        REC.Modify;

        // if not Member.LoadMemberInfo(REC."Member Card No.", ErrorText) then begin
        //     Member.Init();
        //     REC."Member Card No." := '';
        //     REC.Modify;
        //     PosTransactionGui.MessageBeep(ErrorText);
        // end;
    end;

    local procedure PrepareCRTrans(var pTrans: Record "LSC Transaction Header"; var pPosTrans: Record "LSC POS Transaction"; var pPosTransLineBuffer: Record "LSC POS Trans. Line" temporary; var pPosTransPeriodicDiscBuffer: Record "LSC POS Trans. Per. Disc. Type" temporary; var pDealPosTransLineBuffer: Record "LSC POS Trans. Line" temporary; Multiplier: Integer)
    var
        Item_l: Record Item;
        TransSalesEntry: Record "LSC Trans. Sales Entry";
        VATSetup: Record "VAT Posting Setup";
        Deal_l: Record "LSC Offer";
        DealEntry: Record "LSC Trans. Deal Entry";
        PosFuncProfile_l: Record "LSC POS Func. Profile";
        TransHospitalityEntry: Record "LSC Trans. Hospitality Entry";
        Store: Record "LSC Store";
        UnitOfMeasureMgt: Codeunit "Unit of Measure Management";
        PriceUtil: Codeunit "LSC POS Price Utility";
        LastDealNo: Code[20];
        TotalPrice: Decimal;
        UOMFactor: Decimal;
        DealMsg: Label 'Deal';
    begin
        PosFuncProfile_l.Get(POSSESSION.FunctionalityProfileID);

        Clear(LastDealNo);

        pPosTransLineBuffer.Reset;
        pPosTransLineBuffer.DeleteAll;
        pPosTransPeriodicDiscBuffer.Reset;
        pPosTransPeriodicDiscBuffer.DeleteAll;
        pDealPosTransLineBuffer.Reset;
        pDealPosTransLineBuffer.DeleteAll;

        TransSalesEntry.SetRange("Store No.", pTrans."Store No.");
        TransSalesEntry.SetRange("POS Terminal No.", pTrans."POS Terminal No.");
        TransSalesEntry.SetRange("Transaction No.", pTrans."Transaction No.");
        if POSSESSION.GetValue("LSC POS Tag"::"VOID_AND_COPY_TR") <> '' then
            TransSalesEntry.SetFilter(Quantity, '<0');
        if TransSalesEntry.FindSet then
            repeat
                pPosTransLineBuffer.Init;
                pPosTransLineBuffer."Store No." := pPosTrans."Store No.";
                pPosTransLineBuffer."Receipt No." := pPosTrans."Receipt No.";
                pPosTransLineBuffer."POS Terminal No." := pPosTrans."POS Terminal No.";
                pPosTransLineBuffer."Line No." := TransSalesEntry."Line No.";
                pPosTransLineBuffer."Parent Line" := TransSalesEntry."Parent Line No.";
                pPosTransLineBuffer."Sales Type" := TransSalesEntry."Sales Type";
                Item_l.Get(TransSalesEntry."Item No.");
                Store.Get(TransSalesEntry."Store No.");
                if POSSESSION.GetValue("LSC POS Tag"::"VOID_AND_COPY_TR") = '1' then begin
                    pPosTransLineBuffer."Orig. Trans. Store" := pTrans."Store No.";
                    pPosTransLineBuffer."Orig. Trans. Pos" := pTrans."POS Terminal No.";
                    pPosTransLineBuffer."Orig. Trans. Line No." := TransSalesEntry."Line No.";
                    pPosTransLineBuffer."Orig. Trans. No." := TransSalesEntry."Transaction No.";
                end;
                pPosTransLineBuffer."Entry Type" := pPosTransLineBuffer."Entry Type"::Item;

                if TransSalesEntry."Gen. Bus. Posting Group" <> '' then
                    pPosTransLineBuffer."Gen. Bus. Posting Group" := TransSalesEntry."Gen. Bus. Posting Group"
                else
                    pPosTransLineBuffer."Gen. Bus. Posting Group" := Store."Store Gen. Bus. Post. Gr.";
                if TransSalesEntry."Gen. Prod. Posting Group" <> '' then
                    pPosTransLineBuffer."Gen. Prod. Posting Group" := TransSalesEntry."Gen. Prod. Posting Group"
                else
                    pPosTransLineBuffer."Gen. Prod. Posting Group" := Item_l."Gen. Prod. Posting Group";
                pPosTransLineBuffer."Vat Bus. Posting Group" := TransSalesEntry."VAT Bus. Posting Group";
                if TransSalesEntry."VAT Prod. Posting Group" <> '' then
                    pPosTransLineBuffer."Vat Prod. Posting Group" := TransSalesEntry."VAT Prod. Posting Group"
                else
                    pPosTransLineBuffer."Vat Prod. Posting Group" := Item_l."VAT Prod. Posting Group";
                pPosTransLineBuffer."Barcode No." := TransSalesEntry."Barcode No.";
                pPosTransLineBuffer.Number := TransSalesEntry."Item No.";
                pPosTransLineBuffer."Entry Status" := 0;
                pPosTransLineBuffer.Description := Item_l.Description;
                pPosTransLineBuffer."Item Disc. Group" := Item_l."Item Disc. Group";
                pPosTransLineBuffer."Retail Product Code" := Item_l."LSC Retail Product Code";
                pPosTransLineBuffer."Item Category Code" := Item_l."Item Category Code";
                pPosTransLineBuffer.Price := TransSalesEntry.Price;
                pPosTransLineBuffer."Cost Price" := Item_l."Unit Cost";
                pPosTransLineBuffer."Org. Price Exc. VAT" := TransSalesEntry."Net Price";
                pPosTransLineBuffer."Org. Price Inc. VAT" := TransSalesEntry.Price;
                pPosTransLineBuffer."Net Price" := TransSalesEntry."Net Price";
                pPosTransLineBuffer."Quantity Discounted" := TransSalesEntry.Quantity * Multiplier;
                if Multiplier = 1 then  //Void Transaction
                    pPosTransLineBuffer."Remaining Quantity" := TransSalesEntry."Refund Qty."
                else  //Copy Transaction
                    pPosTransLineBuffer."Remaining Quantity" := -TransSalesEntry.Quantity;

                if TransSalesEntry."UOM Quantity" <> 0 then begin
                    pPosTransLineBuffer.Price := TransSalesEntry."UOM Price";
                    UOMFactor := UnitOfMeasureMgt.GetQtyPerUnitOfMeasure(Item_l, TransSalesEntry."Unit of Measure");
                    pPosTransLineBuffer."Remaining Quantity" := pPosTransLineBuffer."Remaining Quantity" / UOMFactor;
                    pPosTransLineBuffer."Cost Price" := Abs(Round(Item_l."Unit Cost" * UOMFactor, 0.00001));
                    pPosTransLineBuffer."Org. Price Inc. VAT" := TransSalesEntry.Price * TransSalesEntry.Quantity / TransSalesEntry."UOM Quantity";
                    pPosTransLineBuffer."Net Price" := TransSalesEntry."Net Price" * TransSalesEntry.Quantity / TransSalesEntry."UOM Quantity";
                    pPosTransLineBuffer."Org. Price Exc. VAT" := TransSalesEntry."Net Price" * TransSalesEntry.Quantity / TransSalesEntry."UOM Quantity";
                    pPosTransLineBuffer."Quantity Discounted" := TransSalesEntry.Quantity / UOMFactor;
                end;
                pPosTransLineBuffer."VAT Code" := TransSalesEntry."VAT Code";
                VATSetup.Get(pPosTransLineBuffer."Vat Bus. Posting Group", pPosTransLineBuffer."Vat Prod. Posting Group");
                pPosTransLineBuffer."VAT %" := VATSetup."VAT %";
                pPosTransLineBuffer."Cost Amount" := Round((pPosTransLineBuffer."Cost Price" * pPosTransLineBuffer."Remaining Quantity") * Multiplier, PosFuncProfile_l."Amount Rounding to");
                pPosTransLineBuffer."Item Number Scanned" := TransSalesEntry."Item Number Scanned";
                pPosTransLineBuffer."Price in Barcode" := TransSalesEntry."Price in Barcode";
                pPosTransLineBuffer."Price Change" := TransSalesEntry."Price Change";
                pPosTransLineBuffer."Linked No. not Orig." := TransSalesEntry."Linked No. not Orig.";
                pPosTransLineBuffer."Orig. of a Linked Item List" := TransSalesEntry."Orig. of a Linked Item List";
                pPosTransLineBuffer."Scale Item" := TransSalesEntry."Scale Item";
                pPosTransLineBuffer."Weight manually Entered" := TransSalesEntry."Weight Manually Entered";
                pPosTransLineBuffer."Unit of Measure" := TransSalesEntry."Unit of Measure";
                pPosTransLineBuffer."Sales Staff" := TransSalesEntry."Sales Staff";
                pPosTransLineBuffer."Variant Code" := TransSalesEntry."Variant Code";
                pPosTransLineBuffer."Orig Per. Disc. Type" := TransSalesEntry."Periodic Disc. Type";
                pPosTransLineBuffer."Orig Per. Disc. Group" := TransSalesEntry."Periodic Disc. Group";
                pPosTransLineBuffer."Serial No." := TransSalesEntry."Serial No.";
                pPosTransLineBuffer."Lot No." := TransSalesEntry."Lot No.";
                pPosTransLineBuffer."Expiration Date" := TransSalesEntry."Expiration Date";
                TotalPrice := TransSalesEntry.Price * -TransSalesEntry.Quantity;
                if (TotalPrice <> 0) and (TransSalesEntry."Discount %" = 0) then
                    pPosTransLineBuffer."Discount %" := Round((TransSalesEntry."Discount Amount" * Multiplier) / (TotalPrice) * 100, 0.1, '>')
                else
                    pPosTransLineBuffer."Discount %" := TransSalesEntry."Discount %" * Multiplier;
                pPosTransLineBuffer."Discount Amount" := TransSalesEntry."Discount Amount" * Multiplier;

                if Multiplier = -1 then begin //copy
                    pPosTransLineBuffer."Discount %" := -pPosTransLineBuffer."Discount %";
                    pPosTransLineBuffer."Discount Amount" := -pPosTransLineBuffer."Discount Amount";
                end;

                pPosTransLineBuffer."Discount Amt. for Printing" := TransSalesEntry."Discount Amt. For Printing" * Multiplier;
                pPosTransLineBuffer."System-Block Manual Discount" := Multiplier = 1;
                pPosTransLineBuffer."Price Override" := false;
                pPosTransLineBuffer."Disc. Info Line No." := 0;
                pPosTransLineBuffer."Discount Triggered" := false;
                pPosTransLineBuffer."InfoCode Disc. Disable" := Multiplier = 1;
                if TotalPrice <> 0 then begin
                    pPosTransLineBuffer."Periodic Disc. %" := TransSalesEntry."Periodic Discount" / (TotalPrice) * 100;
                    pPosTransLineBuffer."Periodic Discount Amount" := TransSalesEntry."Periodic Discount";
                end;
                pPosTransLineBuffer."Mix & Match Line No." := 0;
                pPosTransLineBuffer."Coupon Discount Amount" := TransSalesEntry."Coupon Discount";
                pPosTransLineBuffer."Coupon Amt. For Printing" := TransSalesEntry."Coupon Amt. For Printing";
                pPosTransLineBuffer."Tot. Disc Info Line No." := 0;
                pPosTransLineBuffer."Total Disc. Amount" := TransSalesEntry."Total Discount";
                pPosTransLineBuffer."Total Disc. %" := TransSalesEntry."Total Disc.%";
                pPosTransLineBuffer."Customer Price" := 0;
                if TotalPrice <> 0 then
                    pPosTransLineBuffer."Customer Disc. %" := TransSalesEntry."Customer Discount" / (TotalPrice) * 100;

                if TransHospitalityEntry.Get(TransSalesEntry."Store No.", TransSalesEntry."POS Terminal No.", TransSalesEntry."Transaction No.", TransSalesEntry."Line No.") then begin
                    pPosTransLineBuffer."Restaurant Menu Type" := TransHospitalityEntry."Restaurant Menu Type";
                    pPosTransLineBuffer."Restaurant Menu Type Code" := TransHospitalityEntry."Restaurant Menu Type Code";
                end;

                pPosTransLineBuffer."System-Unchangable Quantity" := Multiplier = 1;
                pPosTransLineBuffer."System-Unchangable Price" := Multiplier = 1;
                pPosTransLineBuffer."System-Unchangable Discounts" := Multiplier = 1;
                pPosTransLineBuffer."System-Unchangable Offer" := Multiplier = 1;

                if TransSalesEntry."Deal Line" and (TransSalesEntry."Promotion No." <> '') then begin
                    if not pDealPosTransLineBuffer.Get(pPosTransLineBuffer."Receipt No.", TransSalesEntry."Deal Header Line No.") then begin
                        if not Deal_l.Get(TransSalesEntry."Promotion No.") then
                            Clear(Deal_l);
                        DealEntry.Reset;
                        DealEntry.SetRange("Store No.", TransSalesEntry."Store No.");
                        DealEntry.SetRange("POS Terminal No.", TransSalesEntry."POS Terminal No.");
                        DealEntry.SetRange("Transaction No.", TransSalesEntry."Transaction No.");
                        DealEntry.SetRange("Deal Header Line No.", TransSalesEntry."Deal Header Line No.");
                        DealEntry.FindFirst;
                        pDealPosTransLineBuffer.Init;
                        pDealPosTransLineBuffer."Receipt No." := pPosTransLineBuffer."Receipt No.";
                        pDealPosTransLineBuffer."Store No." := pPosTransLineBuffer."Store No.";
                        pDealPosTransLineBuffer."POS Terminal No." := pPosTransLineBuffer."POS Terminal No.";
                        pDealPosTransLineBuffer."Line No." := TransSalesEntry."Deal Header Line No.";
                        pDealPosTransLineBuffer."Entry Type" := pDealPosTransLineBuffer."Entry Type"::FreeText;
                        pDealPosTransLineBuffer."Text Type" := pDealPosTransLineBuffer."Text Type"::"Deal Header";
                        if Deal_l.Description = '' then
                            pDealPosTransLineBuffer.Description := DealMsg + ' : ' + TransSalesEntry."Promotion No."
                        else
                            pDealPosTransLineBuffer.Description := Deal_l.Description;
                        pDealPosTransLineBuffer."Promotion No." := TransSalesEntry."Promotion No.";
                        pDealPosTransLineBuffer."Deal Line" := true;
                        pDealPosTransLineBuffer.Price := DealEntry.Price;
                        pDealPosTransLineBuffer."Price List Code" := DealEntry."Deal Price List Code";
                        pDealPosTransLineBuffer.Quantity := -DealEntry.Quantity * Multiplier;
                        pDealPosTransLineBuffer.Amount := -DealEntry.Amount * Multiplier;
                        pDealPosTransLineBuffer."Deal Added Amount" := -DealEntry."Total Deal Line Added Amt." * Multiplier;
                        pDealPosTransLineBuffer."Deal Modifier Added Amt." := -DealEntry."Total Deal Modifier Added Amt." * Multiplier;
                        pDealPosTransLineBuffer.Insert;
                    end;
                    pPosTransLineBuffer."Deal Line" := true;
                    pPosTransLineBuffer."Disc. Info Line No." := pDealPosTransLineBuffer."Line No.";
                    pPosTransLineBuffer."Promotion No." := TransSalesEntry."Promotion No.";
                    pPosTransLineBuffer."Parent Line" := pDealPosTransLineBuffer."Line No.";
                    pPosTransLineBuffer."Deal Modifier Added Amt." := TransSalesEntry."Deal Modifier Added Amt.";
                    pPosTransLineBuffer."Deal Added Amount" := TransSalesEntry."Deal Line Added Amt.";
                end;

                pPosTransLineBuffer.Amount := -(TransSalesEntry."Net Amount" + TransSalesEntry."VAT Amount");
                //pPosTransLineBuffer.SetIndentNo(pPosTransLineBuffer);
                POSTransactionEvents.OnBeforeInsertPosTransLineBuffer(pPosTransLineBuffer, TransSalesEntry);
                pPosTransLineBuffer.Insert;

                PriceUtil.ReverseTransLineDiscEntries(TransSalesEntry, pPosTransPeriodicDiscBuffer);

            until TransSalesEntry.Next = 0;
    end;

    local procedure CreateCRLines(var pSelectionBuffer: Record "LSC POS Trans. Line" temporary; var pTrans: Record "LSC Transaction Header"; var pPosTransLineBuffer: Record "LSC POS Trans. Line" temporary; var pPosTransPeriodicDiscBuffer: Record "LSC POS Trans. Per. Disc. Type" temporary; var pDealPosTransLineBuffer: Record "LSC POS Trans. Line" temporary; Multiplier: Integer): Boolean
    var
        TransAddSalespers: Record "LSC Trans. Add. Salesperson";
        PosFuncProfile_l: Record "LSC POS Func. Profile";
        DealHeaderPOSTransLine: Record "LSC POS Trans. Line";
        Offer_L: Record "LSC Offer";
        ItemVariant_L: Record "Item Variant";
        TransInfocodeEntry_L: Record "LSC Trans. Infocode Entry";
        POSTransInfocodeEntry_L: Record "LSC POS Trans. Infocode Entry";
        POSTransPeriodicDisc_L: Record "LSC POS Trans. Per. Disc. Type";
        TransCouponEntries: Record "LSC Trans. Coupon Entry";
        TransIncomeExpenseEntry_L: Record "LSC Trans. Inc./Exp. Entry";
        IncomeExpenseAccount_L: Record "LSC Income/Expense Account";
        GLAccount_L: Record "G/L Account";
        VATPostingSetup_L: Record "VAT Posting Setup";
        PeriodicDiscount_L: Record "LSC Periodic Discount";
        PosFunctions: Codeunit "LSC POS Functions";
        PosPriceUtil: Codeunit "LSC POS Price Utility";
        DiscountLinesToShowOnPOS: List of [code[20]];
        NoOfDIscountLines: Integer;
        ListIndex: Integer;
    begin
        PosFuncProfile_l.Get(POSSESSION.FunctionalityProfileID);

        TransAddSalespers.SetRange("Store No.", pTrans."Store No.");
        TransAddSalespers.SetRange("POS Terminal No.", pTrans."POS Terminal No.");
        TransAddSalespers.SetRange("Transaction No.", pTrans."Transaction No.");

        pSelectionBuffer.Reset;
        if not pSelectionBuffer.FindSet then
            exit(false);
        repeat
            pPosTransLineBuffer.Get(pSelectionBuffer."Receipt No.", pSelectionBuffer."Line No.");
            CurrInput := pPosTransLineBuffer.Number;
            if CopyTransSalesLinesWithoutPopUps then begin
                InitNewLine;
                NewLine := pPosTransLineBuffer;
                if NewLine."Parent Line" = 0 then
                    NewLine."Parent Line" := NewLine."Line No.";
                NewLine."Price Group Code" := REC."Price Group Code";
                NewLine."Cost Amount" := -NewLine."Cost Amount";
                NewLine."Guest/Seat No." := CurrGuest;
                NewLine."Created by Staff ID" := REC."Staff ID";
                if NewLine."Variant Code" <> '' then
                    if ItemVariant_L.Get(NewLine.Number, NewLine."Variant Code") then
                        NewLine.Description := CopyStr(NewLine.Description + ' ' + ItemVariant_L."Description 2", 1, MaxStrLen(NewLine.Description));
                NewLine."Net Amount" := Round(NewLine.Amount / (1 + (NewLine."VAT %" / 100)), PosFuncProfile_l."Price Rounding to");
                NewLine."VAT Amount" := NewLine.Amount - NewLine."Net Amount";
                POSTransactionEvents.OnBeforeInsertCopiedTransLine(NewLine, pPosTransLineBuffer, pSelectionBuffer, pTrans);
                if POSSESSION.GetValue("LSC POS Tag"::"VOID_AND_COPY_TR") = '1' then begin
                    NewLine.Insert;
                    POSTransactionEvents.OnAfterInsertCopiedTransLine(NewLine, pPosTransLineBuffer, pSelectionBuffer, pTrans);
                end else begin
                    //  NewLine.GetHeader;
                    NewLine.Insert(true);
                    POSTransactionEvents.OnAfterInsertCopiedTransLine(NewLine, pPosTransLineBuffer, pSelectionBuffer, pTrans);
                    if POSSESSION.GetValue("LSC POS Tag"::"VOID_AND_COPY_TR") <> '1' then begin
                        NewLine."Kitchen Routing" := NewLine."Kitchen Routing"::No; //Function CallKDSRoutingForCopiedLine is called after all lines have been copied
                        NewLine.Modify;
                    end;
                    if (NewLine."Deal Line") and
                      (pPosTransLineBuffer."Disc. Info Line No." > 0) and
                      (NewLine."Promotion No." <> '') and
                      (POSSESSION.GetValue("LSC POS Tag"::"VOID_AND_COPY_TR") <> '1') then
                        if not DealHeaderPOSTransLine.Get(NewLine."Receipt No.", pPosTransLineBuffer."Disc. Info Line No.") then begin
                            DealHeaderPOSTransLine.Init;
                            DealHeaderPOSTransLine."Store No." := REC."Store No.";
                            DealHeaderPOSTransLine."POS Terminal No." := REC."POS Terminal No.";
                            DealHeaderPOSTransLine."Receipt No." := REC."Receipt No.";
                            DealHeaderPOSTransLine."Receipt No." := NewLine."Receipt No.";
                            DealHeaderPOSTransLine."Line No." := pPosTransLineBuffer."Disc. Info Line No.";
                            DealHeaderPOSTransLine."Entry Type" := DealHeaderPOSTransLine."Entry Type"::FreeText;
                            if not Offer_L.Get(NewLine."Promotion No.") then
                                Clear(Offer_L);
                            DealHeaderPOSTransLine.Description := Offer_L.Description;
                            DealHeaderPOSTransLine."Text Type" := DealHeaderPOSTransLine."Text Type"::"Deal Header";
                            DealHeaderPOSTransLine.Price := Offer_L."Deal Price";
                            if pDealPosTransLineBuffer.Get(REC."Receipt No.", DealHeaderPOSTransLine."Line No.") then
                                DealHeaderPOSTransLine.Quantity := -pDealPosTransLineBuffer.Quantity
                            else
                                DealHeaderPOSTransLine.Quantity := 1;
                            DealHeaderPOSTransLine."Price Group Code" := NewLine."Price Group Code";
                            DealHeaderPOSTransLine.Amount := Round(DealHeaderPOSTransLine.Price * DealHeaderPOSTransLine.Quantity, 0.01);
                            DealHeaderPOSTransLine."Promotion No." := NewLine."Promotion No.";
                            DealHeaderPOSTransLine."Deal Line" := true;
                            DealHeaderPOSTransLine."System-Unchangable Price" := true;
                            DealHeaderPOSTransLine."System-Block Periodic Discount" := true;
                            DealHeaderPOSTransLine."Trans. Date" := NewLine."Trans. Date";
                            DealHeaderPOSTransLine."Trans. Time" := NewLine."Trans. Time";
                            DealHeaderPOSTransLine."Sales Type" := NewLine."Sales Type";
                            DealHeaderPOSTransLine."Lines where Line is Parent" := 1;
                            DealHeaderPOSTransLine.Counter := 1;
                            DealHeaderPOSTransLine."Sales Type" := REC."Sales Type";
                            DealHeaderPOSTransLine."Created by Staff ID" := REC."Staff ID";
                            DealHeaderPOSTransLine.Insert;
                        end;
                end;
            end else begin
                ItemNoPressed;
                ChangeQtyPressed(Format(pPosTransLineBuffer.Quantity));
            end;
        until pSelectionBuffer.Next = 0;

        if CopyTransSalesLinesWithoutPopUps and not pTrans."Customer Order" then begin
            TransInfocodeEntry_L.Reset;
            TransInfocodeEntry_L.SetCurrentKey("Store No.", "POS Terminal No.", "Transaction No.");
            TransInfocodeEntry_L.SetRange("Store No.", pTrans."Store No.");
            TransInfocodeEntry_L.SetRange("POS Terminal No.", pTrans."POS Terminal No.");
            TransInfocodeEntry_L.SetRange("Transaction No.", pTrans."Transaction No.");
            if TransInfocodeEntry_L.FindSet then
                repeat
                    POSTransInfocodeEntry_L.Init;
                    POSTransInfocodeEntry_L."Receipt No." := REC."Receipt No.";
                    POSTransInfocodeEntry_L."Transaction Type" := TransInfocodeEntry_L."Transaction Type";
                    POSTransInfocodeEntry_L."Line No." := TransInfocodeEntry_L."Line No.";
                    POSTransInfocodeEntry_L.Infocode := TransInfocodeEntry_L.Infocode;
                    POSTransInfocodeEntry_L."Entry Line No." := TransInfocodeEntry_L."Entry Line No.";
                    POSTransInfocodeEntry_L."Store No." := REC."Store No.";
                    POSTransInfocodeEntry_L.Information := TransInfocodeEntry_L.Information;
                    POSTransInfocodeEntry_L."Info. Amt." := TransInfocodeEntry_L."Info. Amt.";
                    POSTransInfocodeEntry_L.Date := REC."Trans. Date";
                    POSTransInfocodeEntry_L.Time := REC."Trans Time";
                    POSTransInfocodeEntry_L."POS Terminal No." := REC."POS Terminal No.";
                    POSTransInfocodeEntry_L."Staff ID" := REC."Staff ID";
                    POSTransInfocodeEntry_L."No." := TransInfocodeEntry_L."No.";
                    POSTransInfocodeEntry_L."Variant Code" := TransInfocodeEntry_L."Variant Code";
                    if REC."Sale Is Return Sale" then
                        POSTransInfocodeEntry_L.Amount := -TransInfocodeEntry_L.Amount
                    else
                        POSTransInfocodeEntry_L.Amount := TransInfocodeEntry_L.Amount;
                    POSTransInfocodeEntry_L."Type of Input" := TransInfocodeEntry_L."Type of Input";
                    POSTransInfocodeEntry_L.Subcode := TransInfocodeEntry_L.Subcode;
                    POSTransInfocodeEntry_L."Entry Variant Code" := TransInfocodeEntry_L."Entry Variant Code";
                    POSTransInfocodeEntry_L."Entry Trigger Function" := TransInfocodeEntry_L."Entry Trigger Function";
                    POSTransInfocodeEntry_L."Entry Trigger Code" := TransInfocodeEntry_L."Entry Trigger Code";
                    POSTransInfocodeEntry_L."Source Code" := TransInfocodeEntry_L."Source Code";
                    POSTransInfocodeEntry_L."Selected Quantity" := TransInfocodeEntry_L."Selected Quantity";
                    POSTransInfocodeEntry_L."Serial No." := TransInfocodeEntry_L."Serial No.";
                    POSTransInfocodeEntry_L.Counter := TransInfocodeEntry_L.Counter;
                    if POSTransInfocodeEntry_L.Insert then;
                    if NewLine.Get(pTrans."Receipt No.", POSTransInfocodeEntry_L."Entry Line No.") then begin
                        NewLine."Orig. from Infocode" := TransInfocodeEntry_L.Infocode;
                        NewLine."Orig. from Subcode" := TransInfocodeEntry_L.Subcode;
                        NewLine."Infocode Entry Line No." := TransInfocodeEntry_L."Line No.";
                        NewLine."Infocode Selected Qty." := TransInfocodeEntry_L.Quantity;
                        NewLine."Parent Line" := NewLine."Line No.";
                        NewLine.Modify;
                    end
                    else begin
                        InitNewLine;
                        NewLine."Orig. from Infocode" := TransInfocodeEntry_L.Infocode;
                        NewLine."Orig. from Subcode" := TransInfocodeEntry_L.Subcode;
                        NewLine."Infocode Entry Line No." := TransInfocodeEntry_L."Line No.";
                        NewLine."Infocode Selected Qty." := TransInfocodeEntry_L.Quantity;
                        NewLine."Entry Type" := NewLine."Entry Type"::FreeText;
                        NewLine."Text Type" := NewLine."Text Type"::"Freetext Input";
                        NewLine.Description := TransInfocodeEntry_L.Information;
                        NewLine."Line No." := TransInfocodeEntry_L."Line No.";
                        NewLine."Parent Line" := TransInfocodeEntry_L.ParentLine;
                        NewLine."Receipt No." := REC."Receipt No.";
                        NewLine."Store No." := REC."Store No.";
                        NewLine."POS Terminal No." := REC."POS Terminal No.";
                        NewLine.Number := TransInfocodeEntry_L."No.";
                        Newline."Text Type" := TransInfocodeEntry_L."Text Type";
                        if NewLine.Insert then;
                    end;

                until TransInfocodeEntry_L.Next = 0;

            if pPosTransPeriodicDiscBuffer.FindSet then begin
                repeat
                    POSTransPeriodicDisc_L.Init();
                    POSTransPeriodicDisc_L := pPosTransPeriodicDiscBuffer;
                    POSTransPeriodicDisc_L."Receipt No." := REC."Receipt No.";
                    POSTransPeriodicDisc_L."POS Terminal No." := pTrans."POS Terminal No.";

                    if POSTransPeriodicDisc_L.DiscType = POSTransPeriodicDisc_L.DiscType::Coupon then
                        if not DiscountLinesToShowOnPOS.Contains(POSTransPeriodicDisc_L."Offer No.") then
                            DiscountLinesToShowOnPOS.Add(POSTransPeriodicDisc_L."Offer No.");

                    case POSTransPeriodicDisc_L."Periodic Disc. Type" of
                        POSTransPeriodicDisc_L."Periodic Disc. Type"::"Mix&Match":
                            begin
                                if not DiscountLinesToShowOnPOS.Contains(POSTransPeriodicDisc_L."Offer No.") then
                                    DiscountLinesToShowOnPOS.Add(POSTransPeriodicDisc_L."Offer No.");
                            end;
                        POSTransPeriodicDisc_L."Periodic Disc. Type"::Multibuy:
                            begin
                                if not DiscountLinesToShowOnPOS.Contains(POSTransPeriodicDisc_L."Offer No.") then
                                    DiscountLinesToShowOnPOS.Add(POSTransPeriodicDisc_L."Offer No.");
                            end;
                    end;

                    if POSTransPeriodicDisc_L.Insert then
                        if Multiplier = -1 then begin//Copy
                            PosFunctions.PosTransDiscUpdateRec(POSTransPeriodicDisc_L);
                            if POSTransPeriodicDisc_L."Periodic Disc. Type" = POSTransPeriodicDisc_L."Periodic Disc. Type"::"Mix&Match" then begin
                                pPosTransLineBuffer.Get(POSTransPeriodicDisc_L."Receipt No.", POSTransPeriodicDisc_L."Line No.");
                                PosPriceUtil.CalcPeriodicDisc(pPosTransLineBuffer, PosFuncProfile."Period Disc. on Total Pressed");
                            end;
                            if POSTransPeriodicDisc_L.DiscType = POSTransPeriodicDisc_L.DiscType::"Total Discount" then begin
                                POSSESSION.SetValue("LSC POS Tag"::"COPY_TR_SKYP_RETRVDFROMRCPT", 'YES');
                                PosOfferExt.ReCalcOfferSeq(REC, POSTransPeriodicDisc_L.DiscType::"Total Discount");
                                POSSESSION.SetValue("LSC POS Tag"::"COPY_TR_SKYP_RETRVDFROMRCPT", '');
                            end;
                            if POSTransPeriodicDisc_L.DiscType = POSTransPeriodicDisc_L.DiscType::Coupon then
                                POSSESSION.SetValue("LSC POS Tag"::"COPY_TR_SKYP_RETRVDFROMRCPTCPN", 'YES');
                        end;
                until pPosTransPeriodicDiscBuffer.Next = 0;

                NoOfDIscountLines := DiscountLinesToShowOnPOS.Count;
                if NoOfDIscountLines > 0 then begin
                    ListIndex := 1;
                    POSTransPeriodicDisc_L.Reset;
                    POSTransPeriodicDisc_L.SetRange("Receipt No.", REC."Receipt No.");
                    POSTransPeriodicDisc_L.SetRange("POS Terminal No.", pTrans."POS Terminal No.");
                    repeat
                        POSTransPeriodicDisc_L.SetRange("Offer No.", DiscountLinesToShowOnPOS.Get(ListIndex));
                        if POSTransPeriodicDisc_L.FindLast then begin
                            InitNewLine;
                            NewLine."Entry Type" := NewLine."Entry Type"::PerDiscount;
                            NewLine.Number := POSTransPeriodicDisc_L."Offer No.";
                            NewLine."Receipt No." := REC."Receipt No.";
                            NewLine."POS Terminal No." := REC."POS Terminal No.";
                            if POSTransPeriodicDisc_L.DiscType = POSTransPeriodicDisc_L.DiscType::Coupon then begin
                                Newline.Description := POSTransPeriodicDisc_L."Offer No.";
                                Newline."Entry Type" := NewLine."Entry Type"::Coupon;
                                TransCouponEntries.SetRange("Receipt No.", pTrans."Receipt No.");
                                TransCouponEntries.SetRange("Coupon Code", POSTransPeriodicDisc_L."Offer No.");
                                TransCouponEntries.SetRange("Transaction No.", pTrans."Transaction No.");
                                if TransCouponEntries.FindFirst then
                                    NewLine."Line No." := TransCouponEntries."Line No."
                            end
                            else begin
                                NewLine."Line No." := POSTransPeriodicDisc_L."Line No." + 100;
                                PeriodicDiscount_L.Get(NewLine.Number);
                                NewLine.Description := PeriodicDiscount_L.Description;
                            end;
                            if NewLine.Insert then;
                        end;
                        ListIndex += 1;
                    until ListIndex > NoOfDIscountLines;
                end;
            end;
        end;

        TransIncomeExpenseEntry_L.Reset;
        TransIncomeExpenseEntry_L.SetRange("Store No.", pTrans."Store No.");
        TransIncomeExpenseEntry_L.SetRange("POS Terminal No.", pTrans."POS Terminal No.");
        TransIncomeExpenseEntry_L.SetRange("Transaction No.", pTrans."Transaction No.");
        if not pTrans."Customer Order" then
            if TransIncomeExpenseEntry_L.FindSet then
                repeat
                    InitNewLine;
                    NewLine."Entry Type" := NewLine."Entry Type"::IncomeExpense;
                    NewLine."Line No." := TransIncomeExpenseEntry_L."Line No.";
                    NewLine.Number := TransIncomeExpenseEntry_L."No.";
                    NewLine."Retail Charge Code" := TransIncomeExpenseEntry_L."Retail Charge Code";
                    if IncomeExpenseAccount_L.Get(REC."Store No.", TransIncomeExpenseEntry_L."No.") then begin
                        NewLine.Description := IncomeExpenseAccount_L.Description;
                        VATPostingSetup_L.Init;
                        if GLAccount_L.Get(IncomeExpenseAccount_L."G/L Account") then
                            if VATPostingSetup_L.Get(GLAccount_L."VAT Bus. Posting Group", GLAccount_L."VAT Prod. Posting Group") then begin
                                NewLine."VAT Code" := VATPostingSetup_L."LSC POS Terminal VAT Code";
                                if VATPostingSetup_L."VAT Calculation Type" = VATPostingSetup_L."VAT Calculation Type"::"Normal VAT" then
                                    NewLine."VAT %" := VATPostingSetup_L."VAT %";
                                NewLine."Vat Bus. Posting Group" := GLAccount_L."VAT Bus. Posting Group";
                                NewLine."Vat Prod. Posting Group" := GLAccount_L."VAT Prod. Posting Group";
                            end;
                    end
                    else
                        NewLine.Description := Format(NewLine."Entry Type") + ' ' + TransIncomeExpenseEntry_L."No.";
                    NewLine.Price := -TransIncomeExpenseEntry_L.Amount;
                    NewLine."Net Price" := -TransIncomeExpenseEntry_L."Net Amount";
                    NewLine."Net Amount" := -TransIncomeExpenseEntry_L."Net Amount";
                    NewLine."VAT Amount" := -TransIncomeExpenseEntry_L."VAT Amount";
                    NewLine.Amount := NewLine."Net Amount" + NewLine."VAT Amount";
                    NewLine.Quantity := 1;
                    NewLine."VAT Code" := TransIncomeExpenseEntry_L."VAT Code";
                    if TransIncomeExpenseEntry_L."Net Amount" <> 0 then
                        NewLine."VAT %" := Round(TransIncomeExpenseEntry_L."VAT Amount" / TransIncomeExpenseEntry_L."Net Amount" * 100, 0.01)
                    else
                        NewLine."VAT %" := 0;
                    NewLine.Counter := 1;
                    NewLine."Price Change" := true;
                    NewLine."Trans. Date" := REC."Trans. Date";
                    NewLine."Trans. Time" := REC."Trans Time";
                    POSTransactionEvents.OnBeforeInsertIncExpLine(NewLine, REC, TransIncomeExpenseEntry_L);
                    if NewLine.Insert then;
                until TransIncomeExpenseEntry_L.Next = 0;
        if POSSESSION.GetValue("LSC POS Tag"::"COPY_TR") = '1' then begin
            NewLine.Reset;
            NewLine.SetRange("Receipt No.", REC."Receipt No.");
            if NewLine.FindSet then
                repeat
                    CallKDSRoutingForCopiedLine(NewLine);
                    NewLine.Modify;
                until NewLine.Next = 0;
        end;
        exit(true);
    end;

    local procedure CopyTransSalesperson(var pTrans: Record "LSC Transaction Header"; var pPosTrans: Record "LSC POS Transaction")
    var
        TransAddSalesperson: Record "LSC Trans. Add. Salesperson";
        POSTransAddSalesperson: Record "LSC POS Trans. Add. Salesp.";
    begin
        TransAddSalesperson.Reset;
        TransAddSalesperson.SetRange("Store No.", pTrans."Store No.");
        TransAddSalesperson.SetRange("POS Terminal No.", pTrans."POS Terminal No.");
        TransAddSalesperson.SetRange("Transaction No.", pTrans."Transaction No.");
        TransAddSalesperson.SetRange("Line No.", 0);
        if TransAddSalesperson.FindSet then
            repeat
                POSTransAddSalesperson."Receipt No." := pPosTrans."Receipt No.";
                POSTransAddSalesperson."Line No." := 0;
                POSTransAddSalesperson."Staff ID" := TransAddSalesperson."Staff ID";
                POSTransAddSalesperson."Store No." := pPosTrans."Store No.";
                POSTransAddSalesperson.Date := pPosTrans."Trans. Date";
                POSTransAddSalesperson.Time := pPosTrans."Trans Time";
                POSTransAddSalesperson."POS Terminal No." := pPosTrans."POS Terminal No.";
                if not (POSTransAddSalesperson.Insert) then;
            until TransAddSalesperson.Next = 0;
    end;

    local procedure ValidateCRLines(var pPosTransLineBuffer: Record "LSC POS Trans. Line" temporary; var pDealPosTransLineBuffer: Record "LSC POS Trans. Line" temporary; var pSelectionBuffer: Record "LSC POS Trans. Line" temporary; var pMessageText: Text[250]; var pErrorText: Text[250]): Boolean
    var
        SkipThis: Boolean;
    begin
        pPosTransLineBuffer.Reset;
        if POSSESSION.GetValue("LSC POS Tag"::"VOID_AND_COPY_TR") <> '' then
            pPosTransLineBuffer.SetFilter("Remaining Quantity", '>0');
        if pPosTransLineBuffer.FindSet then
            repeat
                SkipThis := false;
                POSTransactionEvents.OnBeforeValidateCRLines(pPosTransLineBuffer, SkipThis, pErrorText);
                if not SkipThis then
                    if not SkipThis then
                        if not ValidateReturnPolicy(pPosTransLineBuffer, pMessageText, pErrorText) then
                            SkipThis := true;
                if SkipThis then
                    exit(false)
                else begin
                    pPosTransLineBuffer.Quantity := pPosTransLineBuffer."Remaining Quantity";
                    TextFilter := pPosTransLineBuffer.GetFilters;
                    if pPosTransLineBuffer."Disc. Info Line No." <> 0 then begin  //Deal item
                        pPosTransLineBuffer."Parent Line" := pPosTransLineBuffer."Disc. Info Line No.";
                        pPosTransLineBuffer."Deal Line" := true;
                        pDealPosTransLineBuffer.Get(pPosTransLineBuffer."Receipt No.", pPosTransLineBuffer."Disc. Info Line No.");
                        if not pDealPosTransLineBuffer.Marked then begin
                            pDealPosTransLineBuffer.Marked := true;
                            pDealPosTransLineBuffer.Modify;
                        end;
                    end;
                    pPosTransLineBuffer.Modify;
                    pSelectionBuffer.Init;
                    pSelectionBuffer."Receipt No." := pPosTransLineBuffer."Receipt No.";
                    pSelectionBuffer."Line No." := pPosTransLineBuffer."Line No.";
                    pSelectionBuffer.Insert;
                end;
            until pPosTransLineBuffer.Next() = 0;

        exit(true);
    end;

    local procedure ValidateReturnPolicy(var pPosTransLineTmp: Record "LSC POS Trans. Line" temporary; var pMessageText: Text[250]; var pErrorText: Text[250]): Boolean
    var
        TransSalesEntry: Record "LSC Trans. Sales Entry";
        ReturnPolicy: Record "LSC Return Policy";
        DatePurchased: Date;
        RetAction: Integer;
    begin
        //ValidateReturnPolicy
        DatePurchased := Today;
        if TransSalesEntry.Get(pPosTransLineTmp."Orig. Trans. Store", pPosTransLineTmp."Orig. Trans. Pos",
           pPosTransLineTmp."Orig. Trans. No.", pPosTransLineTmp."Orig. Trans. Line No.")
        then
            DatePurchased := TransSalesEntry.Date;

        //  RetAction := PosFunc.FindReturnPolicy(pPosTransLineTmp, POSSESSION.MgrKey, DatePurchased, ReturnPolicy, pMessageText, pErrorText);

        if (RetAction > 0) then begin
            if (pErrorText <> '') then
                exit(false);
        end;

        exit(true);
    end;

    local procedure RefreshRetailMessageTagText()
    begin
        // if RetailMessageManagement.OkToCheck then
        //     POSSESSION.SetValue("LSC POS Tag"::"Retail_Message", RetailMessageManagement.GetTagText);
    end;

    local procedure OnIdle_RefreshRetailMessageTagText()
    begin
        // if RetailMessageManagement.OkToCheck then
        //     POSSESSION.SetValue("LSC POS Tag"::"Retail_Message", RetailMessageManagement.GetTagText);
    end;

    local procedure EmailReceiptFromTrans(TmpTrans: Record "LSC Transaction Header" temporary; Invoice: Boolean)
    var
        lCustomer: Record Customer;
        MemberContact: Record "LSC Member Contact";
        MembershipCard: Record "LSC Membership Card";
        Email: Text;
        lPayload: Text;
    begin
        if TmpTrans."Customer No." <> '' then
            if lCustomer.Get(TmpTrans."Customer No.") then
                if lCustomer."E-Mail" <> '' then
                    Email := lCustomer."E-Mail";

        if TmpTrans."Member Card No." <> '' then
            if MembershipCard.Get(TmpTrans."Member Card No.") then
                if MemberContact.Get(MembershipCard."Account No.", MembershipCard."Contact No.") then
                    if MemberContact."E-Mail" <> '' then
                        Email := MemberContact."E-Mail";
        lPayload := 'EmailReceiptFromTrans,';
        if Invoice then
            lPayload += 'TRUE'
        else
            lPayload += 'FALSE';
        GlobalRecordID := TmpTrans.RecordId;
        POSGUI.OpenAlphabeticKeyboard(EmailForReceipt, Email, false, lPayload, 1024);
    end;

    local procedure EmailReceiptFromTransOnClose(pEmail: Text; pPayload: Text)
    var
        RecordID: RecordID;
        RecordRef: RecordRef;
        TmpTrans: Record "LSC Transaction Header" temporary;
        PrintUtil: Codeunit "LSC POS Print Utility";
        Phase: Integer;
        Invoice: Boolean;
    begin
        if pEmail <> '' then begin
            RecordID := GlobalRecordID;
            if RecordRef.Get(RecordID) then begin
                if not PosFunc.CheckValidEmailAddresses(pEmail) then begin
                    if PosTransactionGui.PosConfirm(StrSubstNo(EmailNotValid, pEmail), true) then begin
                        POSGUI.OpenAlphabeticKeyboard(EmailForReceipt, pEmail, false, pPayload, 1024);
                        exit;
                    end else
                        exit;
                end;
                RecordRef.SetTable(TmpTrans);
                Invoice := SelectStr(2, pPayload) = 'TRUE';
                Phase := 0;
                PrintUtil.Init();
                POSTransactionEvents.OnBeforeSetWebPrintingOfEmailReceiptFromTransOnClose(TmpTrans, PrintUtil);
                PrintUtil.SetWebPrinting(true, pEmail, "E-Receipt" + ' - ' + TmpTrans."Receipt No.");
                if Invoice then begin
                    if not PrintUtil.PrintInvoice(TmpTrans) then
                        PosTransactionGui.PosMessage(PrintUtil.GetLastError);
                end
                else begin
                    if not PrintUtil.PrintSlips(TmpTrans, Phase) then
                        PosTransactionGui.PosMessage(PrintUtil.GetLastError);
                end;
                PrintUtil.SetWebPrinting(false, '', '');
            end else
                PosTransactionGui.ErrorBeep(NoTransactionToEmail);
        end;
    end;

    local procedure EmailSlipCopy()
    var
        TmpTrans: Record "LSC Transaction Header";
        RecordRef: RecordRef;
        RecordID: RecordID;
    begin
        if POSCtrl.GetActiveLookupRecordID(RecordID) then begin
            RecordRef.Get(RecordID);
            RecordRef.SetTable(TmpTrans);
            EmailReceiptFromTrans(TmpTrans, false);
        end else
            PosTransactionGui.ErrorBeep(NoTransactionToEmail);
    end;

    local procedure EmailLastSlipCopy()
    var
        TmpTrans: Record "LSC Transaction Header";
    begin
        if PosFunc.FindLastTrans(TmpTrans) then
            EmailReceiptFromTrans(TmpTrans, false);
    end;

    local procedure EmailInvoiceCopy()
    var
        TmpTrans: Record "LSC Transaction Header";
        RecordRef: RecordRef;
        RecordID: RecordID;
    begin
        if POSCtrl.GetActiveLookupRecordID(RecordID) then begin
            RecordRef.Get(RecordID);
            RecordRef.SetTable(TmpTrans);
            EmailReceiptFromTrans(TmpTrans, true);
        end else
            PosTransactionGui.ErrorBeep(NoTransactionToEmail);
    end;

    local procedure EmailLastInvoiceCopy()
    var
        TmpTrans: Record "LSC Transaction Header";
    begin
        if PosFunc.FindLastTrans(TmpTrans) then
            EmailReceiptFromTrans(TmpTrans, true);
    end;

    local procedure EFTCheckLastTrans(pForce: Boolean): Boolean
    var
        lFailedCardEntry: Record "LSC POS Card Entry";
        lErrorMessage: Text;
    begin
        POSTransactionEvents.OnBeforeEFTCheckLastTrans(pForce);

        if not EFTActive(true) then
            exit(false);

        // if not POSTransPrint.IsPrinterActive() then
        //     exit(false);

        if not EFT.GetFailedRequest(REC."Receipt No.", lFailedCardEntry) then
            exit(false);

        if not pForce then
            if not PosTransactionGui.PosConfirm(StrSubstNo(EFTRecoverTrans, lFailedCardEntry."Entry No.", lFailedCardEntry."Transaction Type", lFailedCardEntry.Amount, lFailedCardEntry.Message), true) then
                exit(false);

        OposUtil.DisableScanner;
        if not EFT.ProcessGetLastTransaction(lErrorMessage) then begin
            PosTransactionGui.ErrorBeep(lErrorMessage);
            UpdateInputDevicesState(FunctionSetup, FALSE);
            exit(false);
        end;

        if not EFT.RecoverFailedRequest(lFailedCardEntry, lErrorMessage) then begin
            PosTransactionGui.ErrorBeep(lErrorMessage);
            exit(true);
        end;

        //Successfully recovered LAST EFT Transaction
        //lFailedCardEntry variable contains the new entry
        //Now add a payment line
        //TODO----
        //if lFailedCardEntry."Transaction Type" = lFailedCardEntry."Transaction Type"::CancelPreAuth then
        //or VOID??? then finilize void line...
        //.. 10 Digit TransactionID (saga)

        if TenderType.Get(StoreSetup."No.", lFailedCardEntry."Tender Type") then;
        InsertCardPaymentLine(lFailedCardEntry."Entry No.");

        PosTransactionGui.PosMessage(EFTRecoverTransSuccess);
        exit(true);
    end;

    local procedure CallKDSRoutingForCopiedLine(var NewLine: Record "LSC POS Trans. Line")
    var
        ParentPOSTrLine: Record "LSC POS Trans. Line";
        HospType_L: Record "LSC Hospitality Type";
    // HospSetup_L: Record "LSC Hospitality Setup";
    //SendToKDS: Codeunit "LSC Send to KDS";
    begin
        // if (NewLine."Parent Line" <> 0) and (NewLine."Line No." <> NewLine."Parent Line") then
        //     if ParentPOSTrLine.Get(NewLine."Receipt No.", NewLine."Parent Line") then begin
        //         NewLine."Restaurant Menu Type Code" := ParentPOSTrLine."Restaurant Menu Type Code";
        //         NewLine."Restaurant Menu Type" := ParentPOSTrLine."Restaurant Menu Type";
        //     end;

        // if StoreSetup."Kitchen Prod. System in Use" > 0 then begin
        //     if REC."Entry Status" = REC."Entry Status"::Training then begin
        //         if HospType_L.Get(REC."Store No.", REC."Hosp. Type Sequence", REC."Sales Type") then begin
        //             if not HospType_L."Send Training Trans. to KDS" then
        //                 exit;
        //         end else
        //             exit;
        //     end;
        //     if not (NewLine."Entry Type" in [NewLine."Entry Type"::Item, NewLine."Entry Type"::FreeText]) then
        //         exit;
        //     if NewLine."Kitchen Routing" <> NewLine."Kitchen Routing"::No then
        //         exit;
        //     REC.CalcFields("Is Pre-Order");
        //     if REC."Is Pre-Order" then begin
        //         HospSetup_L.Get;
        //         SendToKDS.SetKDSRouting(NewLine, StoreSetup, HospSetup_L."Pre-Order Sales Type")
        //     end else
        //         SendToKDS.SetKDSRouting(NewLine, StoreSetup, '');
        // end;
    end;

    procedure IsInfocodeAllowMSR(): Boolean
    begin
        exit(Info."Allow MSR Cards");
    end;

    procedure UpdateVoucherEntries(pLineRec: Record "LSC POS Trans. Line")
    var
        PosTransInfoEntry: Record "LSC POS Trans. Infocode Entry";
        VoucherEntries: Record "LSC Voucher Entries";
    begin
        if pLineRec.IsEmpty then
            exit;

        PosTransInfoEntry.Reset;
        PosTransInfoEntry.SetRange("Receipt No.", pLineRec."Receipt No.");
        PosTransInfoEntry.SetRange("Transaction Type", PosTransInfoEntry."Transaction Type"::"Sales Entry");
        PosTransInfoEntry.SetRange("Line No.", pLineRec."Line No.");
        if not PosTransInfoEntry.IsEmpty() then begin
            PosTransInfoEntry.SetAutoCalcFields("Infocode Data Entry Type");
            PosTransInfoEntry.FindSet();
            repeat
                VoucherEntries.Reset;
                VoucherEntries.SetRange("Store No.", PosTransInfoEntry."Store No.");
                VoucherEntries.SetRange("POS Terminal No.", PosTransInfoEntry."POS Terminal No.");
                VoucherEntries.SetRange("Receipt Number", PosTransInfoEntry."Receipt No.");
                VoucherEntries.SetRange("Transaction No.", 0); //To retrieve current transaction.
                VoucherEntries.SetRange("Voucher Type", PosTransInfoEntry."Infocode Data Entry Type");
                VoucherEntries.SetRange("Voucher No.", CopyStr(PosTransInfoEntry.Information, 1, MaxStrLen(VoucherEntries."Voucher No.")));
                if VoucherEntries.FindFirst then begin
                    VoucherEntries.Validate(Amount, pLineRec.Amount);
                    VoucherEntries.Validate("Remaining Amount Now", VoucherEntries.Amount);
                    VoucherEntries.Modify(true);
                end;
            until PosTransInfoEntry.Next() = 0;
        end;
    end;

    local procedure ReturnRestrictions(var Qty: Decimal; var POSTransLine: Record "LSC POS Trans. Line"; FilterOnLineNo: Boolean; var LinesFound: Boolean): Boolean
    var
        POSTransLine2: Record "LSC POS Trans. Line";
    begin
        LinesFound := false;
        IF (ClientSessionUtility.IsReturnInSaleBlocked) AND (Qty <> 0) THEN
            exit(true);
        if not PosTerminal."Return in Transaction" and not POSSESSION.StaffReturnInTransaction then begin
            POSTransLine2.SetRange("Receipt No.", REC."Receipt No.");
            POSTransLine2.SetRange("Entry Type", POSTransLine2."Entry Type"::Item);
            POSTransLine2.SetRange(Number, POSTransLine.Number);
            POSTransLine2.SetRange("Entry Status", 0);
            POSTransLine2.SetRange("Variant Code", POSTransLine."Variant Code");
            if FilterOnLineNo then
                POSTransLine2.SetFilter("Line No.", '<>%1', POSTransLine."Line No.");
            if POSTransLine2.FindSet then begin
                repeat
                    LinesFound := true;
                    Qty := Qty + POSTransLine2.Quantity;
                until POSTransLine2.Next = 0;
            end;
            exit(true);
        end;

        exit(false);
    end;

    procedure ProcessLookupResult(LookupIDAndFilter: Text): Code[60]
    var
        PosLookup_l: Record "LSC POS Lookup";
        MenuLine2: Record "LSC POS Menu Line";
        CustomerLoc: Record Customer;
        CurrLine: Record "LSC POS Trans. Line";
        TmpSelectedItemPointLine: Record "LSC Periodic Discount Line" temporary;
        PosTransTenderTemp: Record "LSC POS Trans. Line" temporary;
        LookupRecID: RecordID;
        AdditionalPOSCommands: Codeunit "LSC Additional POS Commands";
        POSFunctions: Codeunit "LSC POS Functions";
        LookupID: Text;
        LookupFilter: Text;
        Command: Code[20];
        KeyValue: Code[60];
        Execute: Boolean;
        IsHandled: Boolean;
        IsExit: Boolean;
        LookupNotFoundErr: Label 'Lookup %1 not found';
    begin
        LookupID := SelectStr(1, LookupIDAndFilter);

        PosLookup_l.Reset;
        if not POSSESSION.GetPosLookupRec(LookupID, PosLookup_l) then begin
            if LookupID <> '' then
                PosTransactionGui.ErrorBeep(StrSubstNo(LookupNotFoundErr, LookupID))
            else
                PosTransactionGui.MessageBeep('');
            exit;
        end;

        POSTransactionEvents.OnBeforeGetLookupResult(LookupID, Command, KeyValue, Execute, IsHandled);
        if not IsHandled then begin
            Command := POSGUI.GetLookupCommand(PosLookup_l."Lookup ID");
            KeyValue := POSGUI.GetLookupKeyValue(PosLookup_l."Lookup ID");
            Execute := StrPos(LookupIDAndFilter, '[EXECUTE]') > 0;
            if Evaluate(LookupFilter, SelectStr(2, LookupIDAndFilter)) then;

            if (LookupID = 'REGISTER') and (Command = '') then
                Command := 'VOID_TR';
        end;
        //Handles Keyvalue blank and not blank
        case LookupID of
            'REFUND':
                begin
                    // if KeyValue <> '' then
                    //     if not RefundMgt.CreateLinesFromSelectionBuffer() then
                    //         KeyValue := '';

                    // ClearInput;
                    // ProcessRefundSelection(KeyValue, false);
                    // exit(KeyValue);
                end;
            'NOTUSEDCOU':
                if LookupFilter = '#NOTUSEDCOUPONS' then begin
                    POSTransactionFunctions.ProcessNotUsedCoupons(REC."Receipt No.");
                    exit;
                end;
            'TENDOFFER':
                begin
                    // if (KeyValue = '') and (TenderType.Code = '') then
                    //     exit;
                    // ProcessTenderOffers := true;
                    // PosOfferExt.GetPopUpTenderTypeOffer(REC, KeyValue, PosTransTenderTemp);
                    // AdditionalPOSCommands.TenderOfferLookupOnClose(PosTransTenderTemp, KeyValue);
                    // if not ProcessTenderOfferAtTotalOnClose(PosTransTenderTemp) then begin
                    //     TenderOfferNewBalanc := Balance;
                    //     TenderKeyPressed(TenderType.Code);
                    // end;
                    // exit;
                end;
            'TENDCHARGE':
                begin
                    TenderKeyPressed(TenderType.Code);
                    exit;
                end;
        end;

        if KeyValue = '' then begin
            ClearInput;
            PosTransactionGui.ErrorBeep('');
            if (LookupID = 'VARIANT') or (LookupID = 'SERIAL_LU') or (LookupID = 'LOT_LU') or (LookupID = 'CUSTOMER') then begin
                POSTransactionEvents.OnProcessLookupResult_KeyValueEmpty(NewLine);

                MenuLine2.Command := Format("LSC POS Command"::CANCEL);
                MenuLine2.Parameter := KeyValue;
                RunCommand(MenuLine2);
            end;
            OnlySelectCustomer := false;
            POSTransactionEvents.OnBeforeExitProcessLookupResultKeyValueEmpty(LookupID, MenuLine2);
            exit('');
        end;

        //Handles Keyvalue not blank
        case LookupID of
            'GETORDER':
                begin
                    CurrInput := KeyValue;
                    GetOrderPressed('');
                    exit;
                end;
            'VARIANT':
                begin
                    CurrInput := KeyValue;
                    ValidateVariant;
                    PosFunc.RecalcSlip(REC);
                    exit;
                end;
            'SUSPEND':
                begin
                    RetSuspendedPressedEx(KeyValue);
                    exit;
                end;
            'CUSTOMER':
                begin
                    if LookupCallFunc = 'SELECTCUST' then begin
                        LookupCallFunc := '';
                        SelectCustPressedEx(KeyValue);
                        OnlySelectCustomer := false;
                        exit;
                    end;
                    if CustomerLoc.Get(KeyValue) then
                        LookupRecID := CustomerLoc.RecordId;
                    ValidateRecordIDInput(LookupRecID, true);
                    OnlySelectCustomer := false;
                    exit;
                end;
        // AdditionalPOSCommands.ItemPointOfferLookupID:
        //     begin
        //         // Process result from WebPOS panel
        //         POSLINES.GetCurrentLine(CurrLine);
        //         if POSFunctions.GetActiveItemPointOfferLines(CurrLine, TmpSelectedItemPointLine, false) then begin
        //             TmpSelectedItemPointLine.SetRange("Offer No.", CopyStr(KeyValue, StrPos(KeyValue, ';') + 1));
        //             if not TmpSelectedItemPointLine.IsEmpty() then begin
        //                 TmpSelectedItemPointLine.FindFirst();
        //                 ProcessItemPointOfferOnClosePanel(TmpSelectedItemPointLine, CurrLine);
        //             end;
        //         end;
        //     end;
        end;
        // if AdditionalPOSCommands.IsMyLookup(LookupID) then begin
        //     GlobalMenuLine."Current-RECEIPT" := REC."Receipt No.";
        //     GlobalMenuLine."Current-LINE" := POSLINES.GetCurrentLineNo;
        //     AdditionalPOSCommands.ProcessLookupResult(LookupID, KeyValue, true, GlobalMenuLine);
        //     ProcessExternalCommand(GlobalMenuLine);
        //     exit;
        // end;

        if KeyValue <> '' then begin
            if LookupID = 'CUSTOMER' then begin
                if CustomerLoc.Get(KeyValue) then
                    LookupRecID := CustomerLoc.RecordId;
                ValidateRecordIDInput(LookupRecID, true);
                OnlySelectCustomer := false;
                exit;
            end;
        end;

        if OnlySelectCustomer then begin
            if FunctionSetup."Function Code" = Format("LSC POS Command"::INFOCODE) then begin
                CurrInput := KeyValue;
                ValidateInfocode(ValidateInfocode_Requested, ValidateInfocode_InfocodeOnHdr, ValidateInfocode_OneSubcode);
                exit;
            end;

            SetCustomer(KeyValue);
            ClearInput;
            exit;
        end;

        if not Execute then begin
            OnlySelectCustomer := false;
            CurrInput := KeyValue;
            ValidateInput;
            exit(KeyValue);
        end;

        if (Command = '') or not OkNewInput then begin
            CurrInput := KeyValue;
            ValidateInput;
            OnlySelectCustomer := false;
            exit;
        end;

        case Command of
            Format("LSC POS Command"::PLU_K):
                begin
                    if PosFuncProfile."Multiple Item Lookup" then begin
                        if not InsertMultipleItems then begin
                            MenuLine2.Command := Format("LSC POS Command"::PLU_K);
                            MenuLine2.Parameter := KeyValue;
                            RunCommand(MenuLine2);
                        end;
                    end else begin
                        MenuLine2.Command := Command;
                        MenuLine2.Parameter := KeyValue;
                        RunCommand(MenuLine2);
                    end;
                end;
            Format("LSC POS Command"::VOID_TR):
                begin
                    IsHandled := false;
                    POSTransactionEvents.OnLookupResultVoidTR(Command, keyValue, LookupRecID, IsHandled, IsExit);
                    if IsExit then
                        exit;
                    if not IsHandled then
                        POSGUI.GetLookupRecordID(LookupRecID);
                    ValidateRecordIDInput(LookupRecID, false);
                end;
            else begin
                IsHandled := false;
                POSTransactionEvents.OnLookupResultOtherCommand(Command, keyValue, IsHandled);
                if not IsHandled then begin
                    MenuLine2.Command := Command;
                    MenuLine2.Parameter := KeyValue;
                    RunCommand(MenuLine2);
                end;
            end;
        end;
    end;

    procedure ProcessNumpadResult(Payload: Text; InputValue: Text; ResultOK: Boolean)
    var
        POSLookup: Record "LSC POS Lookup";
        // POSMemberFBPPanel: Codeunit "LSC POS Member FBP Panel";
        CurrentAvailabilityFunctions: Codeunit "LSC Current Availab. Functions";
        // POSPrepaymentUtil: Codeunit "LSC POS Prepayment Mgt.";
        COPickingPanel: Codeunit "LSC CO Picking Panel";
        COCollectPanel: Codeunit "LSC CO Collect Panel";
        COPutBackPanel: Codeunit "LSC CO Putback Panel";
        NumPadTrigger: Enum "LSC POS Trans. Numpad Trigger";
        Quantity: Decimal;
        KeyboardTriggerToProcess: Integer;
        InfoEntryNo: Integer;
        InputIntegerValue: Integer;
        IsHandled: Boolean;
        TSError: Boolean;
    begin
        case Payload of
            'PREAUTH', 'PREAUTH-UPDATE', 'PREAUTH-FINALIZE', 'ADDCARDTOFILE':
                begin
                    if ResultOK then begin
                        CurrInput := InputValue;
                        PreauthPressed(Payload, '');
                    end;
                    exit;
                end;
            'PICKQTY':
                begin
                    // if ResultOK then
                    //     COPickingPanel.ChangeLineQuantity(Enum::"LSC CO Line Action"::Pick, InputValue);
                    // exit;
                end;
            'SHORTQTY':
                begin
                    // if ResultOK then
                    //     COPickingPanel.ChangeLineQuantity(Enum::"LSC CO Line Action"::Shortage, InputValue);
                    // exit;
                end;
            'CANCELPICKQTY':
                begin
                    // if ResultOK then
                    //     COPickingPanel.ChangeLineQuantity(Enum::"LSC CO Line Action"::Cancel, InputValue);
                    // exit;
                end;
            'CANCELCOLLECTQTY':
                begin
                    // if ResultOK then
                    //     COCollectPanel.ChangeLineQuantity(Enum::"LSC CO Line Action"::Cancel, InputValue);
                    // exit;
                end;
            'COLLECTQTY':
                begin
                    // if ResultOK then
                    //     COCollectPanel.ChangeLineQuantity(Enum::"LSC CO Line Action"::Collect, InputValue);
                    // exit;
                end;
            'COPUTBACK':
                begin
                    // if ResultOK then
                    //     COPutBackPanel.ChangeLineQuantity(Enum::"LSC CO Line Action"::"Put Back", InputValue);
                    // exit;
                end;
        end;

        NumericKeyboardTrigger := 0;
        Evaluate(KeyboardTriggerToProcess, Payload);
        NumPadTrigger := "LSC POS Trans. Numpad Trigger".FromInteger(KeyboardTriggerToProcess);
        case NumPadTrigger of
            NumPadTrigger::"Input in Item Finder": // 37:
                begin
                    // if ResultOK and (InputValue <> '') then
                    //     ItemFinder.ProcessValueInput(InputValue);
                    // exit;
                end;
            // NumPadTrigger::"AddPrepaymentToLine": // 38:
            //     begin
            //         POSPrepaymentUtil.AddPrepaymentToLine(LineRec, InputValue, ResultOK);
            //         exit;
            //     end;
            // NumPadTrigger::"ChangePrepaymentLine": // 39:
            //     begin
            //         POSPrepaymentUtil.ChangePrepaymentLine(LineRec, InputValue, ResultOK);
            //         exit;
            //     end;
            NumPadTrigger::"Limit Input on Suspending": // 40:
                begin
                    POSTransactionFunctions.ProcessLimitInputOnSuspending(REC, ResultOK, InputValue);
                    exit;
                end;
            NumPadTrigger::"Limit Input on Posting": // 41:
                begin
                    POSTransactionFunctions.ProcessLimitInputOnPosting(REC, ResultOK, InputValue);
                    exit;
                end;
            NumPadTrigger::"Reorder Quantity": // 42:
                begin
                    CurrInput := InputValue;
                    if ResultOK then
                        ReOrderQty(GlobalMenuLine.Parameter);
                    CurrInput := '';
                    exit;
                end;
            else begin
                POSTransactionEvents.OnProcessCustomKeyboardTrigger(KeyboardTriggertoProcess, InputValue, CurrInput, IsHandled);
                if isHandled then
                    exit;
            end;
        end;

        if not ResultOK then begin
            case NumPadTrigger of
                NumPadTrigger::"ValidateInfocode", NumPadTrigger::"ValidatePrice": // 18, 31:
                    CancelPressed(false, 0);
                NumPadTrigger::AskForSuggestedQty: //26
                    CancelPressed(true, 0);
                // NumPadTrigger::"GetNoOfCouponsToAddToTrans_FBP_MemberPanel": // 32:
                //     POSMemberFBPPanel.AddCouponsToTransaction('');
                NumPadTrigger::"TotalPressed": // 36:
                    TotalPressed(false);
            end;
            IsHandled := false;
            POSTransactionEvents.OnBeforeExitWhenResultNotOk(Payload, InputValue, ResultOK, KeyboardTriggerToProcess, IsHandled, Rec);
            if not IsHandled then
                exit;
        end;

        POSTransactionEvents.OnBeforeKeyboardTriggerProcess(KeyboardTriggerToProcess, InputValue, NumPadTrigger);

        case NumPadTrigger of
            NumPadTrigger::"TenderKeyPressedEx": // 1:
                TenderKeyPressedEx(CurrentTenderTypeCode, InputValue);
            NumPadTrigger::"ValidateCard": // 2:
                begin
                    CurrInput := InputValue;
                    ValidateCard;
                end;
            NumPadTrigger::"ValidateCardType": // 3:
                begin
                    CurrInput := InputValue;
                    ValidateCardType;
                end;
            NumPadTrigger::"ValidateCardExtra": // 4:
                begin
                    CurrInput := InputValue;
                    ValidateCardExtra;
                end;
            NumPadTrigger::"ValidateCustomer": // 5:
                begin
                    CurrInput := InputValue;
                    ValidateCustomer;
                end;
            NumPadTrigger::"PaymentIntoAccountPressed": // 6:
                begin
                    CurrInput := InputValue;
                    PaymentIntoAccountPressed(CurrentTenderTypeCode);
                end;
            NumPadTrigger::"IncExpLine": // 7:
                begin
                    CurrInput := InputValue;
                    IncExpLineEx;
                end;
            NumPadTrigger::"ValidateDate": // 8:
                begin
                    CurrInput := InputValue;
                    ValidateDate;
                end;
            NumPadTrigger::"ValidateControl": // 9:
                begin
                    CurrInput := InputValue;
                    ValidateControl;
                end;
            NumPadTrigger::"ValidatePassword": // 10:
                begin
                    CurrInput := InputValue;
                    ValidatePassword;
                end;
            NumPadTrigger::"DiscPrPressed": // 11:
                DiscPrPressed(InputValue);
            NumPadTrigger::"DiscAmPressed - Payment Discount": // 12:
                DiscAmPressed(InputValue, true);
            NumPadTrigger::"DiscAmPressed - Item Discount": // 13:
                DiscAmPressed(InputValue, false);
            NumPadTrigger::"ChangeQtyPressed": // 14:
                ChangeQtyPressed(InputValue);
            // NumPadTrigger::"ValidateWeight": // 15:
            //     begin
            //         CurrInput := InputValue;
            //         POSTransScale.ValidateWeight(POSTransScale.GetFromScaleInValidateWeight());
            //     end;
            NumPadTrigger::"ChangePricePressed": // 16:
                ChangePricePressed(InputValue);
            NumPadTrigger::"ValidateQtyInput": // 17:
                begin
                    CurrInput := InputValue;
                    ValidateQtyInput;
                end;
            NumPadTrigger::"ValidateInfocode": // 18:
                begin
                    ValidateInfocode_WaitingForInput_Web := false;
                    CurrInput := InputValue;
                    ValidateInfocode(ValidateInfocode_Requested, ValidateInfocode_InfocodeOnHdr, ValidateInfocode_OneSubcode);
                end;
            NumPadTrigger::"TotDiscAmPressed": // 19:
                TotDiscAmPressed(InputValue, TotDiscAmPressedTotAmount, true);
            NumPadTrigger::"TotDiscPrPressed": // 20:
                TotDiscPrPressed(InputValue, true);
            NumPadTrigger::"CurrencyKeyPressed": // 21:
                begin
                    CurrInput := InputValue;
                    CurrencyKeyPressed(CurrencyKeyPressed_CurrCode, CurrencyKeyPressed_CurrStatus);
                    if ResultOK then
                        if POSSESSION.GetPosLookupRec('TENDOFFER', POSLookup) then
                            POSCtrl.HidePanel('#LOOKUP', false);
                end;
            NumPadTrigger::"CouponPressed": // 22:
                begin
                    CurrInput := InputValue;
                    CouponPressed;
                end;
            NumPadTrigger::"InputMSRCards": // 23:
                begin
                    CurrInput := InputValue;
                    InputMSRCards;
                end;
            NumPadTrigger::"ValidateContact": // 25:
                begin
                    CurrInput := InputValue;
                    ValidateContact;
                end;
            NumPadTrigger::"AskForSuggestedQty": // 26:
                begin
                    CurrInput := InputValue;
                    ValidateQtyInput();
                end;
            NumPadTrigger::"ValidateCustomerInvoiceNoInput": // 27:
                begin
                    ValidateCusInvNoInp_InvPmtAmt := InputValue;
                    ValidateCustomerInvoiceNoInput;
                end;
            NumPadTrigger::"InputMemberCard": // 28:
                InputMemberCard(InputValue);
            NumPadTrigger::"CustomerOrder": // 29:
                begin
                    CurrInput := InputValue;
                    CustomerOrder(CustomerOrder_pParameter);
                end;
            NumPadTrigger::"AskForWeight": // 30:
                begin //AskForWeight
                    if not Evaluate(CurrQty, InputValue) then
                        CurrQty := 0;
                    NextItemPhase;
                end;
            NumPadTrigger::"ValidatePrice": // 31:
                begin
                    CurrInput := InputValue;
                    if ValidatePrice(KeyboardPrice, KeyboardPrice, Item."No.") then
                        NextItemPhase;
                end;
            // NumPadTrigger::"GetNoOfCouponsToAddToTrans_FBP_MemberPanel": // 32:
            //     begin
            //         POSMemberFBPPanel.AddCouponsToTransaction(InputValue);
            //     end;
            NumPadTrigger::"MultiplyQty": // 33:
                begin
                    CurrInput := InputValue;
                    MultiplyQty();
                end;
            NumPadTrigger::"CurrentAvailability": // 34:
                begin
                    // CurrInput := InputValue;
                    // CurrentAvailabilityFunctions.CurrentAvailabilityPressed(GlobalMenuLineTag, CurrInput);
                end;
            NumPadTrigger::"MarkSelectedLineCallback": // 35:
                begin
                    // Evaluate(Quantity, InputValue);
                    // RefundMgt.MarkSelectedLineCallback(Quantity);
                end;
            NumPadTrigger::"TotalPressed": // 36:
                begin
                    if InputValue <> '' then begin
                        CurrInput := StoreSetup."Web Store Shipping Cost Item";
                        ItemLine(true, false, 0, 0, '', '', '', '', 0, 0);
                        ChangePricePressed(InputValue);
                    end;
                    TotalPressed(false);
                end;
            NumPadTrigger::"Data Entry PIN": //43
                begin
                    if (InputValue = '') or (InputValue = '0') then
                        InputValue := '99999999';
                    if Evaluate(InputIntegerValue, InputValue) then begin
                        if InfoUtil.IsInputOk(Info, CurrInput, InfoTextDescription, LineRec, LastCanceled,
                        POSSESSION.MgrKey or POSSESSION.StaffContinueOnTSError, TrainingActive,
                        TSError, 0, '', '', false, 0, false, InfoEntryNo, InputIntegerValue) then begin
                            if TSError then begin
                                if RunTSError(InfoEntryNo) then begin
                                    POSTransactionEvents.OnBeforeProcessInfoCodeInValidateInfocode(Info, Requested_g, InfocodeOnHeader_g, OneSubcode_g, IsHandled);
                                    if not IsHandled then
                                        ProcessInfoCode('', false, ValidateInfocode_Requested, ValidateInfocode_InfocodeOnHdr);
                                end;
                            end else begin
                                POSTransactionEvents.OnBeforeProcessInfoCodeInValidateInfocode(Info, Requested_g, InfocodeOnHeader_g, OneSubcode_g, IsHandled);
                                if not IsHandled then
                                    ProcessInfoCode('', false, ValidateInfocode_Requested, ValidateInfocode_InfocodeOnHdr);
                            end;
                        end;
                    end
                end;
            else begin
                IsHandled := false;
                // POSTransactionEventsPub.OnAfterKeyboardTriggerToProcess(InputValue, KeyboardTriggerToProcess, Rec, IsHandled, ResultOk);
                if not IsHandled then
                    Message(StrSubstNo(NumpadNotImplemented, KeyboardTriggerToProcess, Payload));
            end;
        end;
    end;

    procedure ProcessKeyboardResult(Payload: Text; InputValue: Text; ResultOK: Boolean)
    var
        POSCreateNewCustomer: Codeunit "LSC POS Create New Customer";
        // SafeDenomPanelCommands: Codeunit "LSC Safe Denom. Panel Commands";
        IsHandled: Boolean;
    begin
        //POSTransactionEventsPub.OnBeforeProcessKeyboardResult(Payload, InputValue, ResultOK, IsHandled);
        if IsHandled then
            exit;

        case Payload of
            '#TEXT':
                begin
                    if ResultOK then
                        TextPressed(InputValue);
                    exit;
                end;
            '#TEXTLINKED':
                begin
                    if ResultOK then
                        TextLinkedPressed(InputValue);
                    exit;
                end;
            '#INFOCODETEXT':
                begin
                    ValidateInfocode_WaitingForInput_Web := false;
                    if ResultOK then begin
                        CurrInput := InputValue;
                        ValidateInfocode(ValidateInfocode_Requested, ValidateInfocode_InfocodeOnHdr, ValidateInfocode_OneSubcode);
                    end;
                    exit;
                end;
            '#ITEMFINDER':
                begin
                    // if ResultOK then
                    //     ItemFinder.ProcessValueInput(InputValue);
                    // exit;
                end;
            '#POSTTRANS-DESCR':
                begin
                    POSTransactionFunctions.ProcessDescriptionInputOnPosting(REC, ResultOK, InputValue);
                    exit;
                end;
            '#SUSPTRANS-DESCR':
                begin
                    POSTransactionFunctions.ProcessDescriptionInputOnSuspending(REC, ResultOK, InputValue);
                    exit;
                end;
            '#TRANSSTART-DESCR':
                begin
                    POSTransactionFunctions.ProcessDescriptionInputForSalesTypeOnTransStart(REC, InputValue, ResultOK);
                    exit;
                end;
            '#NEWCUSTCOMMENT':
                begin
                    // if ResultOK then
                    //     POSCreateNewCustomer.NewComment(InputValue);
                    // exit;
                end;
            // SafeDenomPanelCommands.SafeBagPayload:
            //     begin
            //         if ResultOK then
            //             SafeDenomPanelCommands.BagOrSafeNoPressedOnClosePanel(InputValue, Payload);
            //         exit;
            //     end;
            // SafeDenomPanelCommands.BankBagPayload:
            //     begin
            //         if ResultOK then
            //             SafeDenomPanelCommands.BagOrSafeNoPressedOnClosePanel(InputValue, Payload);
            //         exit;
            //     end;
            'LocationProfileEmail':
                begin
                    if ResultOK then
                        LocationProfileEmailOnClose(InputValue, Payload);
                    exit;
                end;
        end;
        if (SelectStr(1, Payload) = 'LocationProfileSMS') and ResultOK then begin
            LocationProfileSMSOnClose(InputValue, Payload);
            exit;
        end;
        if (SelectStr(1, Payload) = 'EmailReceiptFromTrans') and ResultOK then begin
            EmailReceiptFromTransOnClose(InputValue, Payload);
            exit;
        end;

        // if POSTransactionFunctions.IsPostTransEmailInput(Payload) then
        //     POSTransactionFunctions.ProcessEmailInput(ResultOK, InputValue, Payload)
        // else
        //     if ResultOK then
        Message('[' + Payload + '] ' + PayloadNotImplemented);
    end;

    procedure ProcessCalendarResult(Payload: Text; InputValue: DateTime; ResultOK: Boolean)
    begin
        case Payload of
            '#ITEMFINDER':
                begin
                    if ResultOK then
                        // ItemFinder.ProcessValueInput(Format(DT2Date(InputValue)));
                        exit;
                end;
        end;
    end;

    procedure ProcessInfocodeResult(PopupMenuLine: Record "LSC POS Menu Line")
    begin
        ValidateInfocode_WaitingForInput_Web := false;
        CurrInput := PopupMenuLine."Current-INPUT";

        if PopupMenuLine.Parameter <> '' then
            if Info.Get(PopupMenuLine.Parameter) then;

        if PopupMenuLine."Current-LINE" <> LineRec."Line No." then
            LineRec.Get(REC."Receipt No.", PopupMenuLine."Current-LINE");
        if (CurrInput = '') then
            Info."Input Required" := (PopupMenuLine."Current-MaxMinSelection" > 0);

        ProcessInfoCodeInput(ValidateInfocode_Requested, ValidateInfocode_InfocodeOnHdr);

        if ValidateInfocode_InsertingItem then begin
            ValidateInfocode_InsertingItem := false;
            InsertItemLine2();
        end;
    end;

    procedure GetGlobalMenuLine(var GlobalMenuLineOut: Record "LSC POS Menu Line")
    begin
        GlobalMenuLineOut := GlobalMenuLine;
    end;

    procedure GetNewLine(var NewLineOut: Record "LSC POS Trans. Line")
    begin
        NewLineOut := NewLine;
    end;

    local procedure GetRecommendation(POSMenuLine: Record "LSC POS Menu Line"; onTotal: Boolean)
    var
        LSRecommendSetup: Record "LSC Recomm. Setup";
    //LSRecommendMgt: Codeunit "LSC Recomm. Mgt.";
    //LSRecommendPanel: Codeunit "LSC Recomm. Panel";
    begin
        // if not LSRecommendMgt.GetSetupOnPOS(LSRecommendSetup) then
        //     exit;
        // if onTotal then begin
        //     if LSRecommendSetup."Show Recommendation on Total" then
        //         LSRecommendPanel.Run(POSMenuLine);
        // end else begin
        //     if LSRecommendSetup."Show Recommendation on POS" then
        //         LSRecommendPanel.Run(POSMenuLine);
        // end;
    end;

    local procedure FindLineNoForExpDateOffer(var PeriodicDiscountLine: Record "LSC Periodic Discount Line"; var POSTransLineTEMP: Record "LSC POS Trans. Line" temporary) LineNo: Integer
    var
        OfferValidFromDate: Date;
        OfferValidToDate: Date;
    begin
        // Return true if offer line is for Expiration date and is valid for this specific Trans. Line.
        LineNo := 0;
        if PeriodicDiscountLine.FindSet then
            repeat
                if (CalcDate(PeriodicDiscountLine."Valid From Before Exp. Date", Today) <> Today) then begin
                    if (POSTransLineTEMP."Expiration Date" <> 0D) then begin
                        OfferValidFromDate := CalcDate(PeriodicDiscountLine."Valid From Before Exp. Date", POSTransLineTEMP."Expiration Date" + 1);
                        OfferValidToDate := CalcDate(PeriodicDiscountLine."Valid To Before Exp. Date", POSTransLineTEMP."Expiration Date" + 1);
                        if (Today in [OfferValidFromDate .. OfferValidToDate]) then
                            LineNo := PeriodicDiscountLine."Line No.";
                    end;
                end;
            until (PeriodicDiscountLine.Next = 0) or (LineNo <> 0);
    end;

    local procedure CheckGS1DataBarItemAction(ItemNo: Code[20]; LotNo: Code[50]; ExpirationDate: Date): Boolean
    var
        GS1DataBarItemActions: Record "LSC GS1DataBar Item Actions";
        AddAnyKeyTxtToAdd: Text;
        ValidFromDate: Date;
        ValidToDate: Date;
        OkToSellItem: Boolean;
    begin
        if (LotNo <> '') and (GS1DataBarItemActions.Get(ItemNo, LotNo)) then begin
            if (GS1DataBarItemActions."No. of Days before Expiration" <> 0) or (GS1DataBarItemActions."No. of Days after Expiration" <> 0) then begin
                ValidFromDate := Today - GS1DataBarItemActions."No. of Days after Expiration";
                ValidToDate := Today + GS1DataBarItemActions."No. of Days before Expiration";
                if not (Today in [ValidFromDate .. ValidToDate]) then
                    exit(true);
            end;
            if (GS1DataBarItemActions."Action to Take" = GS1DataBarItemActions."Action to Take"::"Block on POS") or
              (GS1DataBarItemActions."Action to Take" = GS1DataBarItemActions."Action to Take"::"Ask if allowed to sell on POS (with Yes/No Confirm Dialog)") then begin
                if GS1DataBarItemActions."Action to Take" = GS1DataBarItemActions."Action to Take"::"Block on POS" then
                    AddAnyKeyTxtToAdd := '\\' + PressAnyKeyToContinue
                else
                    AddAnyKeyTxtToAdd := '\\' + DoYouStillWantToSell;
                OposUtil.Beeper;
                OposUtil.Beeper;
                if GS1DataBarItemActions."Text on POS" <> '' then
                    OkToSellItem := PosTransactionGui.PosConfirm(GS1DataBarItemActions."Text on POS" + AddAnyKeyTxtToAdd, false)
                else
                    OkToSellItem := PosTransactionGui.PosConfirm(GenericLotNoError + AddAnyKeyTxtToAdd, false);
                if (GS1DataBarItemActions."Action to Take" = GS1DataBarItemActions."Action to Take"::"Ask if allowed to sell on POS (with Yes/No Confirm Dialog)") and
                  (OkToSellItem) then
                    exit(true)
                else
                    exit(false);
            end;
        end;

        if (ExpirationDate > 0D) and (GS1DataBarItemActions.Get(ItemNo, '')) then begin
            if (GS1DataBarItemActions."No. of Days before Expiration" >= 0) or
              (GS1DataBarItemActions."No. of Days after Expiration" > 0) then begin
                ValidFromDate := Today - GS1DataBarItemActions."No. of Days after Expiration";
                ValidToDate := Today + GS1DataBarItemActions."No. of Days before Expiration";
                case ExpirationDate of
                    0D .. ValidFromDate - 1:
                        begin
                            OposUtil.Beeper;
                            OposUtil.Beeper;
                            PosTransactionGui.PosConfirm(ItemExpiredError + '\\' + PressAnyKeyToContinue, false);
                            exit(false);
                        end;
                    ValidFromDate .. ValidToDate:
                        begin
                            if GS1DataBarItemActions."Action to Take" = GS1DataBarItemActions."Action to Take"::"Block on POS" then begin
                                PosTransactionGui.PosConfirm(ItemExpiredError + '\\' + PressAnyKeyToContinue, false);
                                exit(false);
                            end;
                            if GS1DataBarItemActions."Action to Take" =
                              GS1DataBarItemActions."Action to Take"::"Ask if allowed to sell on POS (with Yes/No Confirm Dialog)" then begin
                                OposUtil.Beeper;
                                OposUtil.Beeper;
                                if GS1DataBarItemActions."Text on POS" <> '' then
                                    OkToSellItem := PosTransactionGui.PosConfirm(GS1DataBarItemActions."Text on POS", false)
                                else
                                    OkToSellItem := PosTransactionGui.PosConfirm(ItemIsExpiredOrIsAboutToExp, false);
                                exit(OkToSellItem);
                            end;
                        end;
                    else
                        exit(true);
                end;
            end;
        end;

        if (ExpirationDate > 0D) and (ExpirationDate < Today) and (not GS1DataBarItemActions.Get(ItemNo, '')) then begin
            OposUtil.Beeper;
            OposUtil.Beeper;
            PosTransactionGui.PosMessage(ItemExpiredError);
            exit(false);
        end;

        exit(true);
    end;

    local procedure FindItemUOMForKgOrLbs(ItemNo: Code[20]; ItemDescription: Text; LookForKgOrLbs: Option Kg,Lbs; var ErrMsg: Text[250]) ItemUOM: Code[10]
    var
        ItemUnitofMeasure: Record "Item Unit of Measure";
        ItemUOMNotFound: Label 'Item Unit of Measure for %1 was not found for Item %2 %3';
    begin
        ItemUOM := '';
        ItemUnitofMeasure.Reset;

        ItemUnitofMeasure.SetRange("Item No.", ItemNo);
        if LookForKgOrLbs = LookForKgOrLbs::Kg then
            ItemUnitofMeasure.SetFilter(Code, 'KG*|KILO*')
        else
            if LookForKgOrLbs = LookForKgOrLbs::Lbs then
                ItemUnitofMeasure.SetFilter(Code, 'LB*');
        if not ItemUnitofMeasure.FindFirst then
            ErrMsg := StrSubstNo(ItemUOMNotFound, Format(LookForKgOrLbs), ItemNo, ItemDescription)
        else
            ItemUOM := ItemUnitofMeasure.Code;
    end;

    procedure LoginEx()
    begin
        POSTransactionEvents.OnBeforeLogin(REC, LineRec, CurrInput);
    end;

    procedure LoginExPost()
    begin
        POSTransactionEvents.OnAfterLogin(REC, LineRec, CurrInput);
    end;

    procedure KeyLockChanged()
    begin
        POSTransactionEvents.OnBeforeKeyLockChanged(REC, LineRec, CurrInput);
    end;

    procedure KeyLockChangedPost()
    begin
        POSTransactionEvents.OnAfterKeyLockChanged(REC, LineRec, CurrInput);
    end;

    procedure OnTimer()
    begin
        POSTransactionEvents.OnBeforeOnTimer(REC, LineRec, CurrInput);
    end;

    procedure StaffLogon(var Staff: Record "LSC Staff")
    begin
        POSTransactionEvents.OnBeforeStaffLogon(REC, LineRec, CurrInput, Staff);
    end;

    procedure StaffLogonPost(var Staff: Record "LSC Staff")
    begin
        POSTransactionEvents.OnAfterStaffLogon(REC, LineRec, CurrInput, Staff);
    end;

    procedure CustomerOrderPostShipOrder(DocId: Code[20]; var CustomerOrderLines_Temp: Record "LSC Customer Order Line" temporary)
    var
        POSTransPostingState: Record "LSC POS Trans. Posting State";
        COLineTemp: Record "LSC Customer Order Line" temporary;
        COPOSFunctions: Codeunit "LSC CO POS Functions";
        //COUpdatePaymentUtils: Codeunit LSCCOUpdatePaymentUtils;
        ResponseCode: Code[30];
        ErrorText: Text;
        WebPreAuthNotAuthorized: Boolean;
        NoExchangeAddedToCO: Boolean;
    begin
        // REC.Get(REC."Receipt No.");
        // if REC."Ship Customer Order" then begin
        //     if Balance = 0 then begin
        //         SetPOSState("LSC POS Transaction State"::PAYMENT);
        //         POSSESSION.SetTransPostingSource(POSTransPostingState."Posting Source"::"Customer Order List");
        //         COPOSFunctions.AddPaymentToCustomerOrder(CustomerOrderHeader_Temp, CustomerOrderLines_Temp, CustomerOrderPayment_Temp, REC, DocId, COTotalAmount, PrepayCustomerOrder, 0, AddExtraPaymentToCO::DoNotAdd, false, false, NoExchangeAddedToCO);
        //         COUpdatePaymentUtils.SetPosFunctionalityProfile(PosFuncProfile."Profile ID");
        //         COUpdatePaymentUtils.SendRequest(CustomerOrderPayment_Temp, COLineTemp, WebPreAuthNotAuthorized, ResponseCode, ErrorText);
        //         if not WebPreAuthNotAuthorized then begin
        //             PostTransaction(true);
        //             NotIncludeWebPreAuth := false;
        //         end else
        //             WebPreAuthNotAuthorizedFunc(true);
        //         exit;
        //     end;
        //     SetFunctionMode("LSC POS Command"::ITEM);
        //     SelectDefaultMenu;
        // end;
    end;

    procedure CustomerOrderPostWebShipOrder()
    var
        POSTransPostingState: Record "LSC POS Trans. Posting State";
    begin
        REC.Get(REC."Receipt No.");
        if REC."Ship Customer Order" then begin
            if Balance = 0 then begin
                SetPOSState("LSC POS Transaction State"::PAYMENT);
                POSSESSION.SetTransPostingSource(POSTransPostingState."Posting Source"::"Customer Order List");
                PostTransaction(true);
            end;
        end;
    end;

    procedure CustomerOrderPostTransaction(DocId: Code[20]; var CustomerOrderLines_Temp: Record "LSC Customer Order Line" temporary)
    var
        POSTransPostingState: Record "LSC POS Trans. Posting State";
        COLineTemp: Record "LSC Customer Order Line" temporary;
        COPOSFunctions: Codeunit "LSC CO POS Functions";
        //COUpdatePaymentUtils: Codeunit LSCCOUpdatePaymentUtils;
        ResponseCode: Code[30];
        ErrorText: Text;
        WebPreAuthNotAuthorized: Boolean;
        NoExchangeAddedToCO: Boolean;
    begin
        // REC.Get(REC."Receipt No.");
        // SetPOSState("LSC POS Transaction State"::PAYMENT);
        // POSSESSION.SetTransPostingSource(POSTransPostingState."Posting Source"::"Customer Order List");
        // COPOSFunctions.AddPaymentToCustomerOrder(CustomerOrderHeader_Temp, CustomerOrderLines_Temp, CustomerOrderPayment_Temp, REC, DocId, COTotalAmount, PrepayCustomerOrder, 0, AddExtraPaymentToCO::DoNotAdd, false, false, NoExchangeAddedToCO);
        // COUpdatePaymentUtils.SetPosFunctionalityProfile(PosFuncProfile."Profile ID");
        // COUpdatePaymentUtils.SendRequest(CustomerOrderPayment_Temp, COLineTemp, WebPreAuthNotAuthorized, ResponseCode, ErrorText);
        // PostTransaction(true);
    end;

    procedure ClearInfoAndInfoUtil()
    begin
        Clear(Info);
        Clear(InfoUtil);
    end;

    local procedure MemberPointPaymentInTrans(var pPOSTransLine: Record "LSC POS Trans. Line"): Boolean
    var
        POSTransLine: Record "LSC POS Trans. Line";
        TenderType: Record "LSC Tender Type";
    begin
        if REC.Payment > 0 then begin
            POSTransLine.SetRange("Receipt No.", REC."Receipt No.");
            POSTransLine.SetRange("Entry Type", POSTransLine."Entry Type"::Payment);
            POSTransLine.SetRange("Entry Status", POSTransLine."Entry Status"::" ");
            if POSTransLine.FindSet then
                repeat
                    if TenderType.Get(REC."Store No.", POSTransLine.Number) then
                        if (TenderType."Function" = TenderType."Function"::Member) then begin
                            pPOSTransLine := POSTransLine;
                            exit(true);
                        end;
                until POSTransLine.Next = 0;
        end else
            exit(false);
    end;

    local procedure CheckIfSalesLine(): Boolean
    var
        PosLine: Record "LSC POS Trans. Line";
    begin
        PosLine.Reset;
        PosLine.SetRange("Receipt No.", REC."Receipt No.");

        if PosLine.IsEmpty then
            exit(false);
        exit(true);
    end;

    local procedure SetCustomerOrderInfo(CloseCommand: Code[20]; var COHeaderForPosTransTemp: Record "LSC Customer Order Header" temporary; var COPaymentForPosTransTemp: Record "LSC Customer Order Payment" temporary)
    var
        COPosFunc: Codeunit "LSC CO POS Functions";
    begin
        CollectingOrder := true;
        ClearAndDeleteAllCOTempVariables();
        Clear(CustomerOrderLineCompare_Temp);
        CustomerOrderLineCompare_Temp.DeleteAll();
        CustomerOrderHeader_Temp.Copy(COHeaderForPosTransTemp);
        CustomerOrderHeader_Temp.Insert;
        if COPaymentForPosTransTemp.FindSet then
            repeat
                CustomerOrderPayment_Temp.Init;
                CustomerOrderPayment_Temp.Copy(COPaymentForPosTransTemp);
                CustomerOrderPayment_Temp.Insert;
            until COPaymentForPosTransTemp.Next = 0;
        REC.Get(REC."Receipt No.");
        if CustomerOrderHeader_Temp.CancelledOrder then begin
            SetPOSState("LSC POS Transaction State"::PAYMENT);
            //SetFunctionMode("LSC POS Command"::PAYMENT)
        end else begin
            SetPOSState("LSC POS Transaction State"::SALES);
            // SetFunctionMode("LSC POS Command"::ITEM);
        end;
        StateTxt := Format(REC."Transaction Type");
        SelectDefaultMenu;
        CalcTotals;

        // COTotalAmount := COPosFunc.GetTotalCustomerOrderAmountInPosTransaction(REC."Receipt No.");
        //  CustomerOrderSession.SetCustomerOrderIDWhenCollected(CustomerOrderHeader_Temp."Document ID");
    end;

    internal procedure SetCustomerOrderForEdit(CloseCommand: Code[20]; var COHeaderForPosTransTemp: Record "LSC Customer Order Header" temporary; var COPaymentForPosTransTemp: Record "LSC Customer Order Payment" temporary)
    var
        POSTransLine: Record "LSC POS Trans. Line";
    begin
        ClearAndDeleteAllCOTempVariables();
        Clear(CustomerOrderLineCompare_Temp);
        CustomerOrderLineCompare_Temp.DeleteAll();
        CustomerOrderHeader_Temp.Copy(COHeaderForPosTransTemp);
        CustomerOrderHeader_Temp.Insert;
        if COPaymentForPosTransTemp.FindSet then
            repeat
                CustomerOrderPayment_Temp.Init;
                CustomerOrderPayment_Temp.Copy(COPaymentForPosTransTemp);
                CustomerOrderPayment_Temp.Insert;
            until COPaymentForPosTransTemp.Next = 0;
        REC.Get(REC."Receipt No.");
        SetPOSState("LSC POS Transaction State"::PAYMENT);
        //SetFunctionMode("LSC POS Command"::PAYMENT);
        StateTxt := Format(REC."Transaction Type");
        SelectDefaultMenu;
        CalcTotals;

        POSTransLine.SetRange("Receipt No.", REC."Receipt No.");
        POSTransLine.SetFilter("Entry Type", '%1|%2', POSTransLine."Entry Type"::Item, POSTransLine."Entry Type"::IncomeExpense);
        POSTransLine.SetFilter("Entry Status", '<>%1', POSTransLine."Entry Status"::Voided);
        POSTransLine.SetRange("CO Prepayment Line", false);
        POSTransLine.CalcSums(Amount);

        COTotalAmount := POSTransLine.Amount;
    end;

    procedure SetVendorSourcing(VendorSourcing_p: Boolean)
    begin
        VendorSourcing := VendorSourcing_p;
    end;

    local procedure InitDisplay()
    begin
        InitDisplay('', '');
    end;

    local procedure InitDisplay(RoleID: Code[10]; SubRoleID: Code[20])
    var
        DeviceID: Code[20];
    begin
        if (PosSetup.GetDevice("LSC Hardware Profile Devices"::Display, RoleID, SubRoleID, 0, DeviceID)) then begin
            DisplayDevice.Get(DeviceID);
        end;
    end;

    local procedure InitDrawer()
    begin
        InitDrawer('', '');
    end;

    local procedure InitDrawer(RoleID: Code[10]; SubRoleID: Code[20])
    var
        DeviceID: Code[20];
    begin
        if (PosSetup.GetDevice("LSC Hardware Profile Devices"::Drawer, RoleID, SubRoleID, 0, DeviceID)) then begin
            DrawerDevice.Get(DeviceID);
        end;
    end;

    procedure SetPOSTransaction(PosTransIn: Record "LSC POS Transaction")
    begin
        Rec := PosTransIn;
    end;

    procedure GetPOSTransaction(var PosTransOut: Record "LSC POS Transaction")
    begin
        PosTransOut := Rec;
    end;

    procedure SetNewLine(NewLineIn: Record "LSC POS Trans. Line")
    begin
        NewLine := NewLineIn;
    end;

    procedure SetAmtAndBalance(AmountInCurrencyIn: Decimal; PaymentAmountIn: Decimal; BalanceIn: Decimal);
    begin
        AmountInCurrency := AmountInCurrencyIn;
        PaymentAmount := PaymentAmountIn;
        Balance := BalanceIn;
    end;

    procedure GetAmtAndBalance(var AmountInCurrencyOut: Decimal; var PaymentAmountOut: Decimal; var BalanceOut: Decimal);
    begin
        AmountInCurrencyOut := AmountInCurrency;
        PaymentAmountOut := PaymentAmount;
        BalanceOut := Balance;
    end;

    procedure SetInfoTextDescription(InfoTextDescIn: text; InfoTextDesc2In: text)
    begin
        InfoTextDescription := InfoTextDescIn;
        InfoTextDescription2 := InfoTextDesc2In;
    end;

    procedure GetInfoTextDescription(var InfoTextDescOut: text; var InfoTextDesc2Out: text)
    begin
        InfoTextDescOut := InfoTextDescription;
        InfoTextDesc2Out := InfoTextDescription2;
    end;

    procedure SetSkipActionsInTotDiscAmPressed(SkipActionsInTotDiscAmPressedIn: Boolean)
    begin
        SkipActionsInTotDiscAmPressed := SkipActionsInTotDiscAmPressedIn;
    end;

    procedure GetSkipActionsInTotDiscAmPressed(var SkipActionsInTotDiscAmPressedOut: Boolean)
    begin
        SkipActionsInTotDiscAmPressedOut := SkipActionsInTotDiscAmPressed;
    end;

    procedure IsPosActionTriggerActive(ActionTriggerNo: Integer): Boolean
    begin
        if tmpPosActions.Get(ActionTriggerNo) then
            exit(true)
        else
            exit(false);
    end;

    procedure CheckInfocodeOnNewLine(var PosTransLine: Record "LSC POS Trans. Line"; module: Code[10])
    begin
        LineRec.Get(PosTransLine."Receipt No.", PosTransLine."Line No.");
        CheckInfoCode(module);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC CO Create Panel", CustomerOrderCreated, '', false, false)]
    local procedure OnCustomerOrderCreated(var DataBuffer: Record "LSC Customer Order Header" temporary; var DataLinesBuffer: Record "LSC Customer Order Line" temporary; var DataDiscountLineBuffer: Record "LSC CO Discount Line" temporary)
    var
        POSTransLine_L: Record "LSC POS Trans. Line";
        Store: Record "LSC Store";
        COUtility: Codeunit "LSC CO Utility";
        COPOSFunctions: Codeunit "LSC CO POS Functions";
        IsWarehouse: Boolean;
        IsHandled: Boolean;
        EnterShippingCost: Label 'Please enter Shipping Cost';
        PayFullForShipping: Label 'Full payment has to be made upfront for Shipment Orders \Do you want to continue with the Order?';
        PayFullForWarehouseCollect: Label 'Full payment has to be made upfront for Warehouse Collect Orders \Do you want to continue with the Order?';
        VendorPrepaymentConfirm: Label '%1 has to be prepaid upfront \Do you want to continue with the Order?';
        PayForOrderedNowQst: Label 'Do you want to fully pay for the ordered items now?';
    begin
        Commit;
        ClearAndDeleteAllCOTempVariables();

        POSTransactionEvents.OnBeforeCustomerOrderCreated(REC, DataBuffer, DataLinesBuffer, DataDiscountLineBuffer, IsHandled);
        if IsHandled then
            exit;

        CustomerOrderHeader_Temp.Init;
        CustomerOrderHeader_Temp.TransferFields(Databuffer);
        CustomerOrderHeader_Temp.Insert;

        if Datalinesbuffer.FindSet then
            repeat
                CustomerOrderLine_Temp.Init;
                CustomerOrderLine_Temp.TransferFields(Datalinesbuffer);
                CustomerOrderLine_Temp.Insert;
            until Datalinesbuffer.Next = 0;

        if DataDiscountLineBuffer.FindSet then
            repeat
                CustomerOrderDiscountLine_Temp.Init;
                CustomerOrderDiscountLine_Temp.TransferFields(DataDiscountLineBuffer);
                CustomerOrderDiscountLine_Temp.Insert;
            until DataDiscountLineBuffer.Next = 0;

        Datalinesbuffer.FindFirst();
        Datalinesbuffer.CalcSums("Prepayment Amount");
        IsWarehouse := not Store.FindStore(Datalinesbuffer."Sourcing Location", Store);
        if (Datalinesbuffer."Prepayment Amount" > 0) or
            Datalinesbuffer."Ship Order" or
            (not Datalinesbuffer."Ship Order" and IsWarehouse and not CustomerOrderLine_Temp."Inventory Transfer")
        then begin
            case true of
                (not Datalinesbuffer."Ship Order" and IsWarehouse and not CustomerOrderLine_Temp."Inventory Transfer"):
                    begin
                        POSTransactionEvents.OnBeforeConfirmCOFullPayment(Datalinesbuffer, CustomerOrderLine_Temp, PrepayCustomerOrder, IsHandled);
                        if not IsHandled then
                            PrepayCustomerOrder := PosTransactionGui.PosConfirm(PayFullForWarehouseCollect, false);
                    end;
                Datalinesbuffer."Ship Order":
                    begin
                        POSTransactionEvents.OnBeforeConfirmCOFullPayment(Datalinesbuffer, CustomerOrderLine_Temp, PrepayCustomerOrder, IsHandled);
                        if not IsHandled then
                            PrepayCustomerOrder := PosTransactionGui.PosConfirm(PayFullForShipping, false);
                    end;
                else begin
                    POSTransactionEvents.OnBeforeConfirmCOFullPayment(Datalinesbuffer, CustomerOrderLine_Temp, PrepayCustomerOrder, IsHandled);
                    if not IsHandled then
                        PrepayCustomerOrder := PosTransactionGui.PosConfirm(StrSubstNo(VendorPrepaymentConfirm, Datalinesbuffer."Prepayment Amount"), false);
                end;
            end;
            if not PrepayCustomerOrder then begin
                REC."Customer Order" := false;
                REC.Modify;

                POSTransLine_L.Reset;
                POSTransLine_L.SetRange("Receipt No.", REC."Receipt No.");
                POSTransLine_L.SetRange(Marked, true);
                if POSTransLine_L.FindSet() then
                    repeat
                        POSLINES.SetCurrentLine(POSTransLine_L);
                        VoidLinePressed;
                    until POSTransLine_L.Next() = 0;

                REC.Modify;

                SetPOSState("LSC POS Transaction State"::SALES);
                //SetFunctionMode("LSC POS Command"::ITEM);
                TotalPressed(false);
                exit;
            end;
        end;

        COWasCreated := true;

        if CustomerOrderHeader_Temp."Member Card No." <> gOldMemberCardNo then begin
            InputMemberCard(CustomerOrderHeader_Temp."Member Card No.");
            //COUtility.UpdateOrderLines(REC, CustomerOrderLine_Temp, CustomerOrderDiscountLine_Temp, CustomerOrderHeader_Temp, true);
        end;

        if not COPOSFunctions.ShouldAskToPrePayOrder(CustomerOrderHeader_Temp, CustomerOrderLine_Temp) then begin
            if not COPOSFunctions.ShouldPrePayOrder(CustomerOrderHeader_Temp, CustomerOrderLine_Temp) then begin
                PrepayCustomerOrder := false;
                POSTransLine_L.Reset;
                POSTransLine_L.SetRange("Receipt No.", REC."Receipt No.");
                POSTransLine_L.SetRange(Marked, true);
                if POSTransLine_L.FindSet then
                    repeat
                        COAmountToDeductFromTot := COAmountToDeductFromTot + POSTransLine_L.Amount;
                    until POSTransLine_L.Next = 0;
            end else begin
                PrepayCustomerOrder := true;
                if CustomerOrderLine_Temp.FindFirst then
                    repeat
                        CustomerOrderLine_Temp."Prepayment Amount" := CustomerOrderLine_Temp.Amount;
                        CustomerOrderLine_Temp.Modify;
                    until CustomerOrderLine_Temp.Next = 0;
            end;
        end else begin
            if not PrepayCustomerOrder then
                PrepayCustomerOrder := PosTransactionGui.PosConfirm(PayForOrderedNowQst, false);
            if not PrepayCustomerOrder then begin
                POSTransLine_L.Reset;
                POSTransLine_L.SetRange("Receipt No.", REC."Receipt No.");
                POSTransLine_L.SetRange(Marked, true);
                if POSTransLine_L.FindSet then
                    repeat
                        COAmountToDeductFromTot := COAmountToDeductFromTot + POSTransLine_L.Amount;
                    until POSTransLine_L.Next = 0;
            end;
        end;
        if CustomerOrderHeader_Temp.Get(CustomerOrderHeader_Temp."Document ID") then begin
            if not COPOSFunctions.ShouldAskToPrePayOrder(CustomerOrderHeader_Temp, CustomerOrderLine_Temp) then begin
                if not COPOSFunctions.ShouldPrePayOrder(CustomerOrderHeader_Temp, CustomerOrderLine_Temp) then begin
                    CustomerOrderLine_Temp.Reset;
                    CustomerOrderLine_Temp.SetRange("Document ID", CustomerOrderHeader_Temp."Document ID");
                    CustomerOrderLine_Temp.CalcSums(Amount);
                    COAmountToDeductFromTot := CustomerOrderLine_Temp.Amount;
                    CalcTotals;
                end else
                    if CustomerOrderLine_Temp.FindFirst then
                        repeat
                            CustomerOrderLine_Temp."Prepayment Amount" := CustomerOrderLine_Temp.Amount;
                            CustomerOrderLine_Temp.Modify;
                        until CustomerOrderLine_Temp.Next = 0;
            end else begin
                if not PrepayCustomerOrder then begin
                    CustomerOrderLine_Temp.Reset;
                    CustomerOrderLine_Temp.SetRange("Document ID", CustomerOrderHeader_Temp."Document ID");
                    CustomerOrderLine_Temp.CalcSums(Amount);
                    COAmountToDeductFromTot := CustomerOrderLine_Temp.Amount;
                    CalcTotals;
                end;
            end;
        end;

        POSTransactionEvents.OnCustomerOrderBeforeEnterShippingCost(REC, CustomerOrderHeader_Temp, CustomerOrderLine_Temp, CustomerOrderDiscountLine_Temp, IsHandled);
        if IsHandled then
            exit;

        if CustomerOrderHeader_Temp."Ship Order" then begin
            if StoreSetup."Web Store Shipping Cost Item" <> '' then begin
                IsHandled := false;
                POSTransactionEvents.OnBeforeOpenNumericKeyboardShippingCharge(CustomerOrderHeader_Temp, CustomerOrderLine_Temp, CustomerOrderDiscountLine_Temp, IsHandled);
                if IsHandled then
                    exit;
                PosTransactionGui.OpenNumericKeyboard(EnterShippingCost, '', Enum::"LSC POS Trans. Numpad Trigger"::TotalPressed);
            end;
        end else
            TotalPressed(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC Customer Order List Panel", ProcessModalClose, '', false, false)]
    local procedure OnCustomerOrderListClosed(CloseCommand: Code[20]; var COHeaderForPosTransTemp: Record "LSC Customer Order Header" temporary; var COPaymentForPosTransTemp: Record "LSC Customer Order Payment" temporary)
    var
        COLineTemp: Record "LSC Customer Order Line" temporary;
        SalesShipmentHeaderTemp: Record "Sales Shipment Header" temporary;
        COPosFunctions: Codeunit "LSC CO POS Functions";
        ErrorText: Text;
    begin
        if CloseCommand = 'COLLECT' then
            SetCustomerOrderInfo(CloseCommand, COHeaderForPosTransTemp, COPaymentForPosTransTemp);
        if CloseCommand = 'CANCEL' then begin
            SetCustomerOrderInfo(CloseCommand, COHeaderForPosTransTemp, COPaymentForPosTransTemp);
            if COPaymentForPosTransTemp.IsEmpty then
                VoidPressed;
        end;

        CustomerOrderPostShipOrder(COHeaderForPosTransTemp."Document ID", COLineTemp);
        if CloseCommand = 'CANCEL' then
            COPosFunctions.UpdateOrder(COHeaderForPosTransTemp."Document ID", COLineTemp, SalesShipmentHeaderTemp, ErrorText);

        // if (COHeaderForPosTransTemp."Member Card No." <> '') and (COHeaderForPosTransTemp.CancelledOrder = false) then
        //     Member.LoadMemberInfo(COHeaderForPosTransTemp."Member Card No.");

        CurrInput := '';
    end;

    [EventSubscriber(ObjectType::Codeunit, 10016658, OnDepositPayment, '', false, false)]
    local procedure OnCustomerOrderDeposit(var CustomerOrderHeader: Record "LSC Customer Order Header" temporary; RemainingAmount: Decimal; CloseCommand: Code[20])
    begin
        CurrInput := '';
        if CloseCommand = 'DEPOSIT' then begin
            REC.Get(REC."Receipt No.");
            REC."Customer Order" := true;
            REC."Customer Order ID" := CustomerOrderHeader."Document ID";
            REC."Customer Order Deposit" := true;
            REC.Modify;
            PosTransactionGui.OpenNumericKeyboard(StrSubstNo(EnterValue, PaymAmtMsg), Format(RemainingAmount), Enum::"LSC POS Trans. Numpad Trigger"::"Input in Item Finder");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Controller", OnNumpadResult, '', false, false)]
    local procedure CustomerOrderAddDeposit(payload: Text; inputValue: Text; resultOK: Boolean; var processed: Boolean)
    var
        DepositAmount: Decimal;
        NoIEAccount: Label 'No Income/Expence Account is setup for Store';
    begin
        if payload <> '37' then
            exit;

        if resultOK then begin
            if StoreSetup."Customer Order Inc/Expense Acc" <> '' then begin
                if not Evaluate(DepositAmount, inputValue) then begin
                    PosTransactionGui.ErrorBeep(StrSubstNo(InvalidErr, PaymAmtMsg));
                    exit;
                end;
            end else
                PosTransactionGui.ErrorBeep(NoIEAccount);
        end else
            exit;

        DepositCustomerOrderPayment(inputValue);
    end;

    [EventSubscriber(ObjectType::Codeunit, codeunit::"LSC POS Controller", OnLookupResult, '', false, false)]
    local procedure ProcessMyLookup(LookupID: Text; FilterText: Text; resultOK: Boolean; var processed: Boolean)
    begin
        if processed then
            exit;
        processed := (LookupID = Format(Enum::"LSC POS Input Control Id"::"#TOKENSELECTION"));
        if not processed then
            exit;
        ProcessLookupResult(LookupID, FilterText, resultOK);
    end;

    local procedure ProcessLookupResult(LookupID: Text; FilterText: Text; ResultOK: Boolean)
    var
        LookupValue: Text;
        POSGUI: Codeunit "LSC POS GUI";
        LookupNotFoundText: Label 'Lookup [%1] not implemented.';
    begin
        if not ResultOK then
            exit;

        LookupValue := POSGUI.GetLookupKeyValue(LookupID);

        if LookupID = Format("LSC POS Input Control Id"::"#TOKENSELECTION") then begin
            ValidateCard(LookupValue);
        end
        else
            Message(StrSubstNo(LookupNotFoundText, LookupID));
    end;

    internal procedure DepositCustomerOrderPayment(inputValue: Text)
    var
        ErrorText: Text;
        DepositAmount: Decimal;
        RemainingAmount: Decimal;
    begin
        ClearAndDeleteAllCOTempVariables();
        Clear(CustomerOrderLineCompare_Temp);
        CustomerOrderLineCompare_Temp.DeleteAll();
        PosFunc.GetCustomerOrder('LOOKUP', REC."Customer Order ID", CustomerOrderHeader_Temp, CustomerOrderLine_Temp, CustomerOrderDiscountLine_Temp, CustomerOrderPayment_Temp, ErrorText);
        if ErrorText <> '' then
            PosTransactionGui.ErrorBeep(ErrorText)
        else begin
            CustomerOrderLine_Temp.Reset;
            CustomerOrderLine_Temp.FindSet;
            RemainingAmount := 0;
            CustomerOrderLine_Temp.CalcSums(Amount);
            RemainingAmount := CustomerOrderLine_Temp.Amount;
            if CustomerOrderPayment_Temp.FindFirst then
                repeat
                    RemainingAmount := RemainingAmount - CustomerOrderPayment_Temp."Pre Approved Amount LCY";
                until CustomerOrderPayment_Temp.Next = 0;
        end;

        if DepositAmount > RemainingAmount then begin
            PosTransactionGui.PosMessage(StrSubstNo(DepositMoreThanRemaining, Format(DepositAmount), Format(RemainingAmount)));
            PosTransactionGui.ErrorBeep(StrSubstNo(DepositMoreThanRemaining, Format(DepositAmount), Format(RemainingAmount)));
        end else begin
            CurrInput := inputValue;
            SetPOSState("LSC POS Transaction State"::SALES);
            // SetFunctionMode("LSC POS Command"::ITEM);
            SelectDefaultMenu;
            IncExpAccNo := StoreSetup."Customer Order Inc/Expense Acc";
            IncExpLine;
        end;
    end;

    procedure OverridePLBItem()
    var
        PLBStore: Record "LSC Store";
        OverrideQst: Label 'Are you sure you want to override the PLB item?';
        NoPLBItemErr: Label 'There are no PLB items.';
        PLBStoreErr: Label 'PLB store is not activated.';
        OverridePLBItemErr: Label 'Override PLB item is executed previously.';
    begin
        if not PLBStore.Get(GetStoreNo()) then
            exit;

        if not PLBStore."PLB Store" then begin
            PosTransactionGui.ErrorBeep(PLBStoreErr);
            exit;
        end;

        if REC."Override PLB Item" then begin
            PosTransactionGui.ErrorBeep(OverridePLBItemErr);
            exit;
        end;

        REC.CalcFields("PLB Item");
        if not REC."PLB Item" then begin
            PosTransactionGui.ErrorBeep(NoPLBItemErr);
            exit;
        end;

        if not POSSESSION.MgrKey then begin
            PosTransactionGui.ErrorBeep(MgrKeyRequiredErr);
            exit;
        end;

        if not PosTransactionGui.PosConfirm(OverrideQst, true) then
            exit;

        REC."Override PLB Item" := true;
        REC."Override Staff ID" := GetManagerID();
        if REC."Override Staff ID" = '' then
            REC."Override Staff ID" := GetStaffID();
        REC."Override Date Time" := CurrentDateTime;
        REC.Modify();
        POSSESSION.ClearManagerID();
    end;

    procedure UpdateRestrictedFlag()
    var
        PLBAmount, PaidAmount : Decimal;
        // POSTrans: Record "OPT POS Transaction";
        IsHandled: Boolean;
    begin
        // PLBMgt.OnBeforeUpdateRestrictedFlag(REC, IsHandled);
        // if IsHandled then
        //     exit;

        // PLBAmount := PLBMgt.GetTotalPLBAmount(REC."Receipt No.", true);
        // PaidAmount := PLBMgt.GetTotalPaymentAmount(REC."Receipt No.", 0);

        // REC.RestrictedFlag := not (PaidAmount >= PLBAmount);
        // if (REC."Receipt No." <> '') and (POSTrans.Get(REC."Receipt No.")) then
        //     REC.Modify();
    end;

    procedure GetPLBFlag(PaymentAmount: Decimal): Boolean
    var
        PLBSetup: Record "LSC PLB Setup";
        Store: Record "LSC Store";
        POSTransLine: Record "LSC POS Trans. Line";
        NonPLBAmount: Decimal;
        PLBAmount: Decimal;
        PaidCDCAmount: Decimal;
        PaidNonCDCAmount: Decimal;
        BalanceCDCAmount: Decimal;
    begin
        if not PLBSetup.Get() then
            exit(false);

        if not Store.Get(POSSESSION.StoreNo()) then
            exit(false);

        if (not Store."PLB Store") and (not PLBSetup."Enable PLB") then
            exit(false);

        if (not Store."PLB Store") and (PLBSetup."Enable PLB") then
            exit(false);

        if Rec."Override PLB Item" then
            exit(false);

        if PLBMgt.PaymentToCustomerAccount(REC, POSTransLine) then
            exit(true);

        PLBAmount := PLBMgt.GetTotalPLBAmount(REC."Receipt No.", true);
        if PLBAmount = 0 then
            exit(false);
        PaidNonCDCAmount := PLBMgt.GetTotalPaymentAmount(REC."Receipt No.", 2);
        if PaidNonCDCAmount >= PLBAmount then
            exit(false);

        NonPLBAmount := PLBMgt.GetTotalPLBAmount(REC."Receipt No.", false);
        PaidCDCAmount := PLBMgt.GetTotalPaymentAmount(REC."Receipt No.", 1);
        BalanceCDCAmount := NonPLBAmount - PaidCDCAmount;
        exit(PaymentAmount > BalanceCDCAmount);
    end;

    procedure CDCCardPayment(var CardEntry: Record "LSC POS Card Entry"): Boolean
    var
        TenderCardBinSetup: Record "LSC Tender Card Bin Setup";
    begin
        IF TenderCardBinSetup.Get(CardEntry."Tender Type", CopyStr(CardEntry."Card Number", 1, 6)) then
            if TenderCardBinSetup."CDC Card" then
                exit(true);

        exit(false);
    end;

    procedure GetMerchantoverrideFlag(): Boolean
    begin
        exit(REC."Override PLB Item");
    end;

    procedure GetChangeTender(): Boolean
    begin
        exit(ChangeTender);
    end;

    procedure SetLineRec(NewLineRec: Record "LSC POS Trans. Line")
    begin
        LineRec := NewLineRec;
    end;

    procedure GetLineRec(): Record "LSC POS Trans. Line"
    begin
        exit(LineRec);
    end;

    procedure ClearOverridePLBItem()
    begin
        REC.CalcFields("PLB Item");
        if rec."PLB Item" then
            exit;
        REC."Override PLB Item" := false;
        REC."Override Staff ID" := '';
        REC."Override Date Time" := 0DT;
        REC.RestrictedFlag := false;
        REC.Modify();
    end;

    local procedure CheckVATSetups(POSTransaction: Record "LSC POS Transaction"; Item: Record Item)
    var
        VatSetup: Record "VAT Posting Setup";
        IsHandled: Boolean;
        InvalidVatErr: Label 'Invalid VAT setup on Item';
    begin
        //POSTransactionEventsPub.OnBeforeCheckVATSetups(POSTransaction, Item, IsHandled);
        if IsHandled then
            exit;

        if not VatSetup.Get(POSTransaction."VAT Bus.Posting Group", Item."VAT Prod. Posting Group") then
            if (Item."VAT Bus. Posting Gr. (Price)" = '') or not VatSetup.Get(Item."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group") then begin
                PosTransactionGui.ErrorBeep(InvalidVatErr);
                exit;
            end;
    end;

    local procedure WebPreAuthNotAuthorizedFunc(ShipOrder: Boolean)
    var
        POSTransLine: Record "LSC POS Trans. Line";
    begin
        POSTransLine.Reset;
        POSTransLine.SetRange("Receipt No.", REC."Receipt No.");
        POSTransLine.SetRange("Entry Type", POSTransLine."Entry Type"::IncomeExpense);
        POSTransLine.SetFilter("Entry Status", '<>%1', POSTransLine."Entry Status"::Voided);
        if POSTransLine.FindFirst() then begin
            CustomerOrderPayment_Temp.SetFilter("EFT Authorization Code", '=%1', 'WebPreAuthOnPos');
            CustomerOrderPayment_Temp.SetFilter("Finalized Amount LCY", '<>%1', 0);
            if CustomerOrderPayment_Temp.FindFirst() then
                if Abs(POSTransLine.Amount) >= CustomerOrderPayment_Temp."Finalized Amount LCY" then begin
                    if not ShipOrder then begin
                        //Withdraw Pre-Auth from current PosTransLine amount
                        PaymentAmount := POSTransLine.Amount + CustomerOrderPayment_Temp."Finalized Amount LCY";
                        InitNewLine;
                        InsertPaymentLine;
                        NewLine."Entry Type" := POSTransLine."Entry Type";
                        NewLine.Description := POSTransLine.Description;
                        NewLine.Price := PaymentAmount;
                        NewLine."Net Price" := PaymentAmount;
                        NewLine."Net Amount" := PaymentAmount;
                        NewLine.Modify();
                    end;
                    CalcVoidedLineCOPrePayment(POSTransLine."Line No.");
                    POSTransLine.VoidLine;
                end;
            NotIncludeWebPreAuth := true;
        end;
        POSTransLine.Reset;
        POSTransLine.SetRange("Receipt No.", REC."Receipt No.");
        POSTransLine.SetFilter(Amount, '=%1', 0);
        POSTransLine.SetFilter("Entry Status", '<>%1', POSTransLine."Entry Status"::Voided);
        if POSTransLine.FindFirst() then
            POSTransLine.Delete();
        Clear(CustomerOrderPayment_Temp);
        CustomerOrderPayment_Temp.DeleteAll();
        PosTransactionGui.ErrorBeep(FinalizePaymentNotAuthorized);
    end;

    local procedure CheckStartPOSActions(): Boolean
    begin
        POSAction.SetRange(Active, true);
        POSAction.SetRange("Action Trigger", POSAction."Action Trigger"::"Start POS");
        POSAction.SetRange("Do Action", POSAction."Do Action"::"Run Command");
        POSAction.SetFilter("Action ID", '<>%1', '');
        exit(POSAction.IsEmpty());
    end;

    local procedure CheckForExchangeLineInTrans(ReceiptNo: Code[20]; var PaymentAmount: Decimal; var DoNotUseExchangeLineAsPayToCO: Boolean): Decimal
    var
        POSTransLine: Record "LSC POS Trans. Line";
        NonCustomerOrderAmount, CustomerOrderTotalAmount, TotalExchangeMinusNonCust : Decimal;
        PrepayCustomerOrder: Boolean;
        AddToCustomerOrder: Label 'Do you want to add the Exchange Amount of %1 to the Customer Order?';
    begin
        POSTransLine.SetRange("Receipt No.", ReceiptNo);
        POSTransLine.SetRange("Entry Type", POSTransLine."Entry Type"::Item);
        POSTransLine.SetFilter("Entry Status", '<>%1', POSTransLine."Entry status"::Voided);
        POSTransLine.SetFilter(Quantity, '<%1', 0);
        POSTransLine.CalcSums(Amount);
        TotalExchangeAmount := Abs(POSTransLine.Amount);
        if TotalExchangeAmount > 0 then begin
            POSTransLine.Reset;
            POSTransLine.SetRange("Receipt No.", ReceiptNo);
            POSTransLine.SetFilter("Entry Type", '%1|%2', POSTransLine."Entry Type"::Item, POSTransLine."Entry Type"::IncomeExpense);
            POSTransLine.SetFilter("Entry Status", '<>%1', POSTransLine."Entry Status"::Voided);
            POSTransLine.SetFilter(Quantity, '>%1', 0);
            POSTransLine.SetRange(Marked, false);
            POSTransLine.CalcSums(Amount);
            NonCustomerOrderAmount := POSTransLine.Amount;
            if (TotalExchangeAmount - NonCustomerOrderAmount > 0) then begin //Check if there is Payment left to add to CO
                TotalExchangeMinusNonCust := TotalExchangeAmount - NonCustomerOrderAmount;
                POSTransLine.Reset;
                POSTransLine.SetRange("Receipt No.", ReceiptNo);
                POSTransLine.SetRange("Entry Type", POSTransLine."Entry Type"::Item);
                POSTransLine.SetFilter("Entry Status", '<>%1', POSTransLine."Entry Status"::Voided);
                POSTransLine.SetFilter(Quantity, '>%1', 0);
                POSTransLine.SetRange(Marked, true);
                POSTransLine.CalcSums(Amount);
                CustomerOrderTotalAmount := POSTransLine.Amount;

                if TotalExchangeMinusNonCust > CustomerOrderTotalAmount then begin
                    PrepayCustomerOrder := PosTransactionGui.PosConfirm(StrSubstNo(AddToCustomerOrder, CustomerOrderTotalAmount), false);
                    if PrepayCustomerOrder then
                        exit(CustomerOrderTotalAmount)
                    else
                        PaymentAmount := TotalExchangeMinusNonCust;
                end else begin
                    PrepayCustomerOrder := PosTransactionGui.PosConfirm(StrSubstNo(AddToCustomerOrder, TotalExchangeMinusNonCust), false);
                    if PrepayCustomerOrder then
                        exit(TotalExchangeMinusNonCust)
                    else
                        if PaymentAmount < 0 then
                            DoNotUseExchangeLineAsPayToCO := true;
                end;
            end;
        end;
    end;

    local procedure TogglePrepayCustomerOrder()
    var
        COPOSFunctions: Codeunit "LSC CO POS Functions";
        PrepayCustomerOrderSetToFalse: Label 'Prepayment of Customer Order disabled';
        PrepayCustomerOrderSetToTrue: Label 'Prepayment of Customer Order enabled';
        PrepayCannotBeDisabled: Label 'Customer Order lines have to be paid now. Prepayment cannot be disabled';
        CommandOnlyAvailableInCustomerOrder: Label 'This command can only be used on Customer Orders';
        CommandOnlyAvailableBeforeCreated: Label 'This command can only be used before the Customer Order is created';
    begin
        if not Rec."Customer Order" then begin
            PosTransactionGui.ErrorBeep(CommandOnlyAvailableInCustomerOrder);
            exit;
        end;
        if CustomerOrderLine_Temp.IsEmpty then begin
            PosTransactionGui.ErrorBeep(CommandOnlyAvailableBeforeCreated);
            exit;
        end;
        if COPOSFunctions.ShouldPrePayOrder(CustomerOrderHeader_Temp, CustomerOrderLine_Temp) and PrepayCustomerOrder then begin
            PosTransactionGui.ErrorBeep(PrepayCannotBeDisabled);
            exit;
        end;

        if PrepayCustomerOrder then begin
            PrepayCustomerOrder := false;
            CustomerOrderLine_Temp.Reset;
            CustomerOrderLine_Temp.SetRange("Document ID", CustomerOrderHeader_Temp."Document ID");
            CustomerOrderLine_Temp.CalcSums(Amount);
            COAmountToDeductFromTot := CustomerOrderLine_Temp.Amount;
            CalcTotals;
            PosTransactionGui.PosMessageBanner(PrepayCustomerOrderSetToFalse);
        end else begin
            PrepayCustomerOrder := true;
            COAmountToDeductFromTot := 0;
            if CustomerOrderLine_Temp.FindSet() then
                repeat
                    CustomerOrderLine_Temp."Prepayment Amount" := CustomerOrderLine_Temp.Amount;
                    CustomerOrderLine_Temp.Modify;
                until CustomerOrderLine_Temp.Next = 0;
            PosTransactionGui.PosMessageBanner(PrepayCustomerOrderSetToTrue);
        end;
    end;

    procedure GetTenderType(): Text[20]
    begin
        exit(EBTTenderType);
    end;

    procedure SetEBTTenderType(TenderType: Code[10])
    var
        Limitation: Record "LSC Limitation";
        StoreLimitation: Record "LSC Store Limitation";
        StoreNo: Code[10];
    begin
        StoreNo := POSSESSION.StoreNo();
        StoreLimitation.SetRange("Store No.", StoreNo);
        StoreLimitation.SetRange("Tender Type Code", TenderType);
        if StoreLimitation.FindFirst() then begin
            if Limitation.Get(StoreLimitation.Code) then begin
                case Limitation.Type of
                    Limitation.Type::EBT:
                        EBTTenderType := EBTText;
                    Limitation.Type::EBTCash:
                        EBTTenderType := EBTCashText;
                end;
            end;
        end else
            EBTTenderType := '';
    end;

    procedure GetLinePriceGroup(): Code[10]
    begin
        exit(LinePriceGroup);
    end;

    procedure GetLineSalesType(): Code[20]
    begin
        exit(LineSalesType);
    end;

    procedure GetKeyboardPrice(): Decimal
    begin
        exit(KeyboardPrice);
    end;

    procedure GetMultiplyWith(): Decimal
    begin
        exit(MultiplyWith);
    end;

    procedure SetMultiplyWith(NewMultiplyWith: Decimal)
    begin
        MultiplyWith := NewMultiplyWith;

    end;

    procedure GetCurrQty(): Decimal
    begin
        exit(CurrQty);
    end;

    procedure SetCurrQty(NewCurrQty: Decimal)
    begin
        CurrQty := NewCurrQty;
    end;

    procedure GetPosSetup(): Record "LSC POS Hardware Profile";
    begin
        exit(PosSetup);
    end;

    internal procedure GetCOTemp(var COHeaderTemp: Record "LSC Customer Order Header" temporary; var COLineTemp: Record "LSC Customer Order Line" temporary; var CODiscountLineTemp: Record "LSC CO Discount Line" temporary; var COPaymentTemp: Record "LSC Customer Order Payment" temporary)
    var
        COUtility: Codeunit "LSC CO Utility";
    begin
        //COUtility.GetPOSCOTemp(CustomerOrderHeader_Temp, CustomerOrderLine_Temp, CustomerOrderDiscountLine_Temp, CustomerOrderPayment_Temp, COHeaderTemp, COLineTemp, CODiscountLineTemp, COPaymentTemp);
    end;

    procedure SetCOWasCreated(COCreated: Boolean)
    begin
        COWasCreated := COCreated;
    end;

    internal procedure GetLineUpdateInProgress(): boolean
    begin
        exit(LineUpdateInProgress);
    end;

    procedure IsCustomerOrderEdit(): Boolean
    begin
        exit(COEdit);
    end;

    local procedure AzureStorageUpdate()
    var
        BackgroundMgt: Codeunit "LSC Background Mgt";
        ErrorMessage: Text;
    begin
        POSSESSION.SetValue('AZS_ERROR', '');
        If PosFuncProfile."Run AzS Repl. In Background" then begin
            BackgroundMgt.AzureStorageReplUpdateSession();
            ErrorMessage := BackgroundMgt.GetAzSReplUpdateLastStatus();
            IF ErrorMessage <> '' then begin
                POSSESSION.SetValue('AZS_ERROR', CopyStr(ErrorMessage, 1, 250));
                POSGUI.SetTSErrorFlag(false);
            end;
        end
    end;

    local procedure StartJobQueueUpdate()
    var
        BackgroundMgt: Codeunit "LSC Background Mgt";
        ErrorMessage: Text;
    begin
        POSSESSION.SetValue('JQ_ERROR', '');
        If PosFuncProfile."Keep Sch. Job Queue Entr Ready" then begin
            BackgroundMgt.JobQueueUpdateSession();
            ErrorMessage := BackgroundMgt.GetJobQueueLastStatus();
            IF ErrorMessage <> '' then begin
                POSSESSION.SetValue('JQ_ERROR', CopyStr(ErrorMessage, 1, 250));
                POSGUI.SetTSErrorFlag(false);
            end;
        end
    end;

    internal procedure IsProcessReceiptBarcode(IfConditionNeeded: Boolean): Boolean
    var
        IsHandled: Boolean;
    begin
        POSTransactionEvents.OnBeforeIsProcessReceiptBarcode(IsHandled, CurrInput);
        if IsHandled then
            exit(false);

        if (StrLen(CurrInput) in [14, 20]) and (CopyStr(CurrInput, 1, 1) in ['T', 'P', 'S']) then begin
            if IfConditionNeeded then begin
                if ProcessReceiptBarcode() then
                    exit(true);
            end else begin
                ProcessReceiptBarcode();
                exit(true);
            end;
        end;
        exit(false);
    end;

    internal procedure IsCollectingOrder(): boolean
    begin
        exit(CollectingOrder);
    end;

    procedure IsCustomerOrderPrepaid(): Boolean
    begin
        exit(PrepayCustomerOrder);
    end;

    procedure SetAskConfirmation(AskConfirmationp: Boolean)
    begin
        AskConfirmation := AskConfirmationp;
    end;

    Procedure Data(
       var dPOSTransaction: Record "LSC POS Transaction";
       var dPOSTransLine: Record "LSC POS Trans. Line";
       dVoidCardEntry: Record "LSC POS Card Entry"; pPosterminal: Record "LSC POS Terminal")
    begin
        pPOSTransaction := dPOSTransaction;
        pPOSTransLine := dPOSTransLine;
        pVoidCardEntry := dVoidCardEntry;
        REC := dPOSTransaction;
        LineRec := dPOSTransLine;
        CardEntry := dVoidCardEntry;
        PosTerminal := pPosterminal;
    end;
}