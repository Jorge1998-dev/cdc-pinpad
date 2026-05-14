codeunit 60001 "OPT Events Pinpad"
{

    var
        TenderType: Record "LSC Tender Type";
        POSGUI: Codeunit "LSC POS GUI";
        GTenderType: Code[10];
        //cuLSCPOSTransaction: Codeunit "LAF LSC POS Transaction Impl";
        cuLSCPOSTransaction: Codeunit "OPT POS Transaction Impl";
        POSSESSION: Codeunit "LSC POS Session";
        //POSSESSION2: Codeunit "LAF LSC POS Session";
        EFTUtil: Interface "Opt LSC IEFTUtility";
        EFTUtil2: Interface "LSC IEFTUtility2";
        EFTUtil2b: Interface "Opt LSC IEFTUtility2";
        VarGlobal: Codeunit ConnectCom;
        TabLAF: Record "Trans. LAF";
        EFTUtilO: Interface "LSC IEFTUtility";
        CurrencyExchangeRate: array[3] of Record "Currency Exchange Rate";
        gCurrency: text;
        EFT_: Codeunit "OPT POS Transaction EFT";
        REC: Record "LSC POS Transaction";
        RefundTransaction: Record "LSC Transaction Header";
        LineRec: Record "LSC POS Trans. Line";
        CardEntryNo: Integer;

        VoidCardEntry: Record "LSC POS Card Entry";
        //CardEntryNo: Integer;
        ErrorText: Text;
        ErrorCode: Code[10];
        Retry, IsHandled : Boolean;
        RefundCancelledErr: Label 'REFUND CANCELLED';
        CardEntry: Record "LSC POS Card Entry";
        // RealBalance: Integer;
        RetryCardVoid: Label '%1\Retry Void?';
        PosTransactionGui: Codeunit "OPTs POS Transaction GUI";
        PosTerminal: Record "LSC POS Terminal";
        NewLine: Record "LSC POS Trans. Line";
        STATE, LAST_STATE : Enum "LSC POS Transaction State";
        PosFuncProfile: Record "LSC POS Func. Profile";
        Balance: Decimal;
        POSTransactionEvents: Codeunit "OPT POS Transaction Events";
        RealBalance: Decimal;
        PaymentAmount: Decimal;
        ChangeTender: Boolean;
        KeyboardAmount: Boolean;
        LocalizationExt: Codeunit "LSC Retail Localization Ext.";
        POSTransactionEventsPub: Codeunit "OPT POS Transaction";
        CurrInput: Text;
        CurrGuest, PaymentCount : Integer;
        CurrMenuType: Integer;
        gInsertTmpPayment: Boolean;
        BarcodeMask: Record "LSC Barcode Mask";
        Currency: Record Currency;
        StoreSetup: Record "LSC Store";
        CustomerOrCardNo: Code[20];
        AmountInCurrency: Decimal;
        TenderCardType: Record "LSC Tender Type Card Setup";
        PosFunc: Codeunit "LSC POS Functions";
        MultiplyWith: Decimal;
        IsLimitation, VendorSourcing, NotIncludeWebPreAuth : Boolean;
        EBTTenderType: Text[20];
        EBTText: Label 'EBT', Locked = true;
        EBTCashText: Label 'EBTCash', Locked = true;
        CurrentPaymentAmount: Decimal;
        LimitationMgt: Codeunit "LSC Limitation Management";

        InfoTextDescription, InfoTextDescription2 : Text;
        ProcessTenderOffers, COEdit : Boolean;
        CardType: Code[10];
        PosOfferExt: Codeunit "LSC POS Offer Ext. Utility";
        POSLINES: Codeunit "LSC POS Trans. Lines";
        OPTPOSTransactionimpl: Codeunit "OPT POS Transaction Impl";
        UOMSet: Code[10];

        OposUtil: Codeunit "LSC POS OPOS Utility";
        COAmountToDeductFromTot: Decimal;
        GrossAmountBeforeCreatingCO, RemainingFCY, Remaining : Decimal;
        //CustomerOrderSession: Codeunit "LSC Customer Order Session";
        CollectingOrder: Boolean;
        CustomerOrderLine_Temp, CustomerOrderLineCompare_Temp : Record "LSC Customer Order Line" temporary;
        CustomerOrderDiscountLine_Temp: Record "LSC CO Discount Line" temporary;
        CustomerOrderPayment_Temp: Record "LSC Customer Order Payment" temporary;
        CustomerOrderHeader_Temp: Record "LSC Customer Order Header" temporary;
        VoidInProcess, PrepayCustomerOrder : Boolean;
        LastCurrencyCode: Code[10];
        POSTransactionFunctions: Codeunit "OPT POS Transaction Functions";
        FinalizePaymentNotAuthorized: Label 'Finalize payment from card not Authorized';
        FunctionSetup: Record "LSC POS Command";
        PosSetup: Record "LSC POS Hardware Profile";


    //POSTransScale: Codeunit "LSC POS Transaction Scale";


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeVoidCard', '', true, true)]
    local procedure OnBeforeVoidCard
        (
        var POSTransaction: Record "LSC POS Transaction";
        var POSTransLine: Record "LSC POS Trans. Line";
        VoidCardEntry: Record "LSC POS Card Entry";
        var CardEntryNo: Integer;
        var IsHandled: Boolean
        );
    var
        CardEntry: Record "LSC POS Card Entry";
        OptTenderType: Record "LSC Tender Type";
        optStore: Record "LSC Store";
        optPosTerminal: Record "LSC POS Terminal";
        POSTransactionC: Codeunit "LSC POS Transaction";
        DelayedUpdate: Integer;
        InfoTextDescription, InfoTextDescription2 : Text;
        SeekingAuthMsg: Label 'Seeking authorisation...';
        STATE_TENDOP: text;
        opSTATE: Code[10];
        pErrorReason: Text;
        cEftUtil: Codeunit "LSC POS EFT Utility";
        InterEFT: Interface "LSC IEFTUtility";
    begin

        POSSESSION.GetEFTUtility(EFTUtilO);
        POSSESSION.GetEFTUtility2(EFTUtil2);
        // POSSESSION2.GetEFTUtility(EFTUtil);
        // POSSESSION2.GetEFTUtility2(EFTUtil2b);
        EFTUtilO.ClearEFT();
        EFTUtilO.SetTenderType(CardEntry."Tender Type");
        if optPosTerminal.Get(POSTransaction."POS Terminal No.") then;
        cuLSCPOSTransaction.Data(POSTransaction, POSTransLine, VoidCardEntry, optPosTerminal);
        cuLSCPOSTransaction.VoidCard(VoidCardEntry, CardEntryNo, pErrorReason);
        // InterEFT.InitEFTServer(POSTransaction."POS Terminal No.",'LAF');
        //cEftUtil.InitEFTServer(POSTransaction."POS Terminal No.", 'LAF');
        IsHandled := true;

    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterTenderKeyPressedEx', '', true, true)]
    local procedure "LSC POS Transaction Events_OnAfterTenderKeyPressedEx"
    (
        var POSTransaction: Record "LSC POS Transaction";
        var POSTransLine: Record "LSC POS Trans. Line";
        var CurrInput: Text;
        var TenderTypeCode: Code[10];
        var TenderAmountText: Text;
        var IsHandled: Boolean
    )
    var
        OpTenderType: record "LSC Tender Type";

        optStore: Record "LSC Store";
        optPosTerminal: Record "LSC POS Terminal";
        optSTATE: Code[10];
        POSTransactionC: Codeunit "LSC POS Transaction";
        STATE_TENDOP: Text;
        LAFInterface: Interface "Opt LSC IEFTUtility";

    begin

        POSSESSION.GetEFTUtility(EFTUtilO);
        POSSESSION.GetEFTUtility2(EFTUtil2);
        EFTUtilO.ClearEFT();
        EFTUtilO.SetTenderType('');

    end;

    procedure ScreenDisplay(pText: Text[250])
    begin
        POSGUI.ScreenDisplay(pText);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeInsertPaymentLine', '', true, true)]
    internal procedure OnBeforeInsertPaymentLine(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var TenderTypeCode: Code[10]; Balance: decimal; PaymentAmount: Decimal; STATE: Code[10]; var isHandled: Boolean)
    var
        rTenderTypeCurr: Record "LSC Tender Type";
        cIngenico: Codeunit ConnectCom;
        dAmount: Decimal;
        POSSESION1: Codeunit "LSC POS Session";
        tDivisa: Text;
        tDivisa2: Text;
        POSMenuLine: Record "LSC POS Menu Line";
        rStore: Record "LSC Store";
        Currency: Record Currency;
        AmountInCurrency: Decimal;
        PosFunc: Codeunit "LSC POS Functions";
        PayEntry: Record "LSC Trans. Payment Entry";
        rTenderTypeCurrencySetup: Record "LSC Tender Type Currency Setup";

    //POSExchangerateconversion: Codeunit "LSC POS Exch. rate conversion";
    begin

        rTenderTypeCurr.Reset();
        if TenderTypeCode <> '' then
            rTenderTypeCurr.Get(POSTransaction."Store No.", TenderTypeCode);

        rStore.Get(POSTransaction."Store No.");
        POSMenuLine.Reset();
        POSMenuLine.SetRange("Profile ID", POSSESION1.MenuProfileID());
        POSMenuLine.SetRange(Command, 'TENDER_K');
        POSMenuLine.SetRange(Parameter, TenderTypeCode);
        IF POSMenuLine.FindSet() then;

        if rTenderTypeCurr."Pinpad Integration" then begin
            Clear(rTenderTypeCurrencySetup);
            rTenderTypeCurrencySetup.SetRange("Store No.", rTenderTypeCurr."Store No.");
            rTenderTypeCurrencySetup.SetRange("Tender Type Code", rTenderTypeCurr.Code);
            if rTenderTypeCurrencySetup.findset() then begin end;


            if CurrInput <> '' then
                Evaluate(dAmount, CurrInput)
            else
                dAmount := 0;
            if not POSTransaction."Sale Is Return Sale" then begin
                //gCurrency := cIngenico.SendSale(dAmount, POSTransaction."Receipt No.", POSMenuLine."Post Parameter", POSTransaction, POSMenuLine.Parameter, PaymentAmount);
                gCurrency := cIngenico.SendSale(dAmount, POSTransaction."Receipt No.", rTenderTypeCurrencySetup."Currency Code", POSTransaction, POSMenuLine.Parameter, PaymentAmount);
            end else begin
                Clear(PayEntry);
                PayEntry.SetRange("Store No.", POSTransaction."Store No.");
                PayEntry.SetRange("POS Terminal No.", POSTransaction."POS Terminal No.");
                PayEntry.SetRange("Receipt No.", POSTransaction."Retrieved from Receipt No.");
                if PayEntry.FindSet() then begin

                    if PayEntry."Currency Code" <> '' then
                        Currency.get(PayEntry."Currency Code");
                    if rTenderTypeCurr."Foreign Currency" and (Currency.Code <> '') then begin
                        POSTransLine."Currency Code" := Currency.Code;
                        POSTransLine."Amount In Currency" := PayEntry."Amount in Currency";
                        POSTransLine.Description := Currency.Code + ' '
                         + PosFunc.FormatCurrency(POSTransLine."Amount In Currency", Currency.Code);
                    end else begin
                        if rTenderTypeCurrencySetup."Currency Code" <> '' then begin
                            //POSTransLine."Currency Code" := POSMenuLine."Post Parameter";
                            POSTransLine."Currency Code" := rTenderTypeCurrencySetup."Currency Code";
                            Currency.get(POSTransLine."Currency Code");
                            AmountInCurrency := Round(POSExchangeLCYToFCY(POSTransaction."Trans. Date", POSMenuLine."Post Parameter", PaymentAmount) / POSTransaction."Currency Factor", Currency."Amount Rounding Precision");
                            POSTransLine."Amount In Currency" := AmountInCurrency;
                            POSTransLine.Description := Currency.Code + ' '
                            + PosFunc.FormatCurrency(POSTransLine."Amount In Currency", Currency.Code);
                        end;

                    end;
                end;

            end;
        end;

    end;
    ///********
    /// 
    procedure POSExchangeLCYToFCY(Date: Date; POSCurrencyCode: Code[10]; Amount: Decimal): Decimal
    var
        POSExchRate: Record "Currency Exchange Rate";
    begin
        if POSCurrencyCode = '' then
            exit(Amount);

        FindCurrency(Date, POSCurrencyCode, 2);
        if CurrencyExchangeRate[2]."LSC POS Exchange Rate Amount" <> 0 then
            exit(Amount / CurrencyExchangeRate[2]."LSC POS Rel. Exch. Rate Amount" * CurrencyExchangeRate[2]."LSC POS Exchange Rate Amount")
        else
            if CurrencyExchangeRate[2]."Relational Currency Code" = '' then
                exit(Amount / CurrencyExchangeRate[2]."Relational Exch. Rate Amount" * CurrencyExchangeRate[2]."Exchange Rate Amount")
            else begin
                FindCurrency(Date, CurrencyExchangeRate[2]."Relational Currency Code", 3);
                Amount := Amount / CurrencyExchangeRate[2]."Relational Exch. Rate Amount" * CurrencyExchangeRate[2]."Exchange Rate Amount";
                exit(Amount / CurrencyExchangeRate[3]."Relational Exch. Rate Amount" * CurrencyExchangeRate[3]."Exchange Rate Amount");
            end;
    end;

    procedure POSExchangeFCYToLCY(Date: Date; POSCurrencyCode: Code[10]; Amount: Decimal): Decimal
    var
        POSExchRate: Record "Currency Exchange Rate";
    begin
        if POSCurrencyCode = '' then
            exit(Amount);

        FindCurrency(Date, POSCurrencyCode, 2);
        if CurrencyExchangeRate[2]."LSC POS Exchange Rate Amount" <> 0 then
            exit(Amount / CurrencyExchangeRate[2]."LSC POS Exchange Rate Amount" * CurrencyExchangeRate[2]."LSC POS Rel. Exch. Rate Amount")
        else
            if CurrencyExchangeRate[2]."Relational Currency Code" = '' then
                exit(Amount / CurrencyExchangeRate[2]."Exchange Rate Amount" * CurrencyExchangeRate[2]."Relational Exch. Rate Amount")
            else begin
                FindCurrency(Date, CurrencyExchangeRate[2]."Relational Currency Code", 3);
                Amount := Amount / CurrencyExchangeRate[2]."Exchange Rate Amount" * CurrencyExchangeRate[2]."Relational Exch. Rate Amount";
                exit(Amount / CurrencyExchangeRate[3]."Exchange Rate Amount" * CurrencyExchangeRate[3]."Relational Exch. Rate Amount");
            end;
    end;

    procedure FindCurrency(Date: Date; CurrencyCode: Code[10]; Number: Integer)
    begin
        if Date = 0D then
            Date := WorkDate;
        CurrencyExchangeRate[Number].SetRange("Currency Code", CurrencyCode);
        CurrencyExchangeRate[Number].SetRange("Starting Date", 0D, Date);
        CurrencyExchangeRate[Number].FindLast;
        CurrencyExchangeRate[Number].TestField("Exchange Rate Amount");
        CurrencyExchangeRate[Number].TestField("Relational Exch. Rate Amount");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterInsertPaymentLine', '', true, true)]
    local procedure OnAfterInsertPaymentLine(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var TenderTypeCode: Code[10]; var SkipCommit: Boolean);
    var
        rtenderType: Record "LSC Tender Type";
        rPosCardEntry: Record "LSC POS Card Entry";
        rCurrency: Record Currency;
        pAmount: Decimal;
        rStores: Record "LSC Store";
    begin
        Clear(rtenderType);
        rtenderType.SetRange(Code, POSTransLine.Number);
        rtenderType.SetRange("Pinpad Integration", true);
        IF rtenderType.FindFirst() then begin
            Clear(rPosCardEntry);
            rPosCardEntry.SetRange("Store No.", POSTransaction."Store No.");
            rPosCardEntry.SetRange("POS Terminal No.", POSTransaction."POS Terminal No.");
            rPosCardEntry.SetRange("Receipt No.", POSTransaction."Receipt No.");
            if rPosCardEntry.FindLast() then begin
                IF (rPosCardEntry."EFT Currency" <> 'NAF') AND (rPosCardEntry."EFT Currency" <> '') THEN begin
                    Clear(rCurrency);
                    rCurrency.get(rPosCardEntry."EFT Currency");
                    POSTransLine.Number := rPosCardEntry."Tender Type";
                    POSTransLine."Currency Code" := rPosCardEntry."EFT Currency";

                    evaluate(pAmount, CurrInput);

                    Clear(rStores);
                    rStores.Get(POSTransLine."Store No.");
                    if rStores."Currency Code" = rCurrency.Code then
                        POSTransLine."Amount In Currency" := pAmount
                    //POSTransLine."Amount In Currency" := Round(POSExchangeLCYToFCY(today, rPosCardEntry."EFT Currency", pAmount), rCurrency."Amount Rounding Precision")
                    else
                        //POSTransLine."Amount In Currency" := Round(POSExchangeLCYToFCY(today, rPosCardEntry."EFT Currency", POSTransLine.Amount), rCurrency."Amount Rounding Precision");

                        POSTransLine."Amount In Currency" := Round(POSExchangeLCYToFCY(today, rPosCardEntry."EFT Currency", pAmount), rCurrency."Amount Rounding Precision");
                    POSTransLine.Description := rPosCardEntry."EFT Currency" + ' ' + Format(POSTransLine."Amount In Currency");
                end;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnBeforeCurrencyKeyPressed, '', false, false)]
    local procedure "LSC POS Transaction Events_OnBeforeCurrencyKeyPressed"(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var CurrCode: Code[10]; var CurrStatus: Integer; var IsHandled: Boolean)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnBeforeTestVoidCardEntryProcessRefundSelection, '', false, false)]
    local procedure "LSC POS Transaction Events_OnBeforeTestVoidCardEntryProcessRefundSelection"(var IsHandled: Boolean)
    var
        OptPosTransaction: Codeunit "OPT POS Transaction Impl";
        POSTransac: Codeunit "LSC POS Transaction";
        POSSESION: Codeunit "LSC POS Session";
        VoidCardEntry: Record "LSC POS Card Entry";
        Retry: Boolean;
        LSPosTranImpl: Codeunit "OPT POS Transaction Impl";
        CardEntry: Record "LSC POS Card Entry";
        OptTenderType: Record "LSC Tender Type";
        optStore: Record "LSC Store";
        optPosTerminal: Record "LSC POS Terminal";
        POSTransactionC: Codeunit "LSC POS Transaction";
        DelayedUpdate: Integer;
        InfoTextDescription, InfoTextDescription2 : Text;
        SeekingAuthMsg: Label 'Seeking authorisation...';
        STATE_TENDOP: text;
        opSTATE: Code[10];
        pErrorReason: Text;
        cEftUtil: Codeunit "LSC POS EFT Utility";
        InterEFT: Interface "LSC IEFTUtility";
        POSTransLine: Record "LSC POS Trans. Line";
        Amount1: Decimal;
        Amount2: Decimal;
        LSCTransPayentry: Record "LSC Trans. Payment Entry";
        Amountdif: Decimal;
        RemainingVoidAmount: Decimal;
        VoidAmount: Decimal;
    begin

        IsHandled := true;
        //if not IsHandled then begin
        Clear(REC);

        REC.SetRange("Store No.", POSSESION.StoreNo());
        REC.SetRange("POS Terminal No.", POSSESION.TerminalNo());
        REC.SetRange("Receipt No.", POSTransac.GetReceiptNo());
        IF REC.FindSet() THEN begin
            RefundTransaction.Reset();
            RefundTransaction.SetRange("Store No.", POSSESION.StoreNo());
            RefundTransaction.SetRange("POS Terminal No.", POSSESION.TerminalNo());
            RefundTransaction.SetRange("Receipt No.", REC."Retrieved from Receipt No.");
            IF not RefundTransaction.FindSet() then
                exit;

            CalcTotals();
            RemainingVoidAmount := Round(Abs(RealBalance), 0.01, '=');
            if RemainingVoidAmount = 0 then
                RemainingVoidAmount := Round(Abs(RefundTransaction."Gross Amount"), 0.01, '=');


            VoidCardEntry.SetCurrentKey("Store No.", "POS Terminal No.", "Transaction No.", "Line No.");
            VoidCardEntry.SetRange("Store No.", RefundTransaction."Store No.");
            VoidCardEntry.SetRange("POS Terminal No.", RefundTransaction."POS Terminal No.");
            VoidCardEntry.SetRange("Transaction No.", RefundTransaction."Transaction No.");
            if VoidCardEntry.FindSet then
                repeat
                    Amount1 := Round(RefundTransaction."Gross Amount", 0.01, '=');
                    Amount2 := Round(RefundTransaction."Gross Amount", 0.01, '=');
                    Clear(LSCTransPayentry);
                    //LSCTransPayentry.SetRange("Receipt No.");
                    LSCTransPayentry.SetRange("Transaction No.", VoidCardEntry."Transaction No.");
                    LSCTransPayentry.SetRange("Store No.", VoidCardEntry."Store No.");
                    LSCTransPayentry.SetRange("POS Terminal No.", VoidCardEntry."POS Terminal No.");
                    if LSCTransPayentry.findset() then begin

                    end;
                    VoidAmount := Round(Abs(VoidCardEntry.Amount), 0.01, '=');
                    Amountdif := VoidAmount - RemainingVoidAmount;
                    //if TestVoidCardEntry(VoidCardEntry) and (VoidCardEntry.Amount <= Abs(RealBalance)) or (Amount1 = Amount2) then begin
                    if TestVoidCardEntry(VoidCardEntry) and (VoidCardEntry."Voucher Number" <> '') and (VoidAmount <= RemainingVoidAmount) then begin
                        //if TestVoidCardEntry(VoidCardEntry) and (Abs(RealBalance) <= VoidCardEntry.Amount) then begin
                        Retry := True;
                        while Retry do begin
                            Retry := false;
                            if not VoidCard(VoidCardEntry, CardEntryNo, ErrorText) then begin
                                PosTransactionGui.ErrorBeep(ErrorText);
                                Retry := PosTransactionGui.PosConfirm(StrSubstNo(RetryCardVoid, ErrorText), true)
                            end
                        end;
                        InsertVoidPaymentLine(VoidCardEntry, CardEntryNo);
                        RemainingVoidAmount := RemainingVoidAmount - VoidAmount;
                    end;
                until VoidCardEntry.Next = 0;
        end;
    end;

    procedure EFT(): Codeunit "OPT POS Transaction EFT"
    begin

        exit(EFT_);
    end;

    procedure CalcTotals()
    var
        IsHandled: Boolean;
    begin
        // UpdateMarkedLinesInCO();

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

    procedure VoidCard(VoidCardEntry: Record "LSC POS Card Entry"; var pCardEntryNo: Integer; var pErrorReason: Text): Boolean
    begin
        exit(EFT.VoidCard(REC, LineRec, VoidCardEntry, pCardEntryNo, pErrorReason));
    end;

    procedure InsertVoidPaymentLine(VoidCardEntry: Record "LSC POS Card Entry"; CardEntryNo: Integer)
    var
        CardEntry: Record "LSC POS Card Entry";
        rCurrency: record Currency;
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

        // CardEntry."Line No." := NewLine."Line No.";
        // IF (VoidCardEntry."EFT Currency" <> 'NAF') AND (VoidCardEntry."EFT Currency" <> '') THEN begin
        //     Clear(rCurrency);
        //     rCurrency.get(VoidCardEntry."EFT Currency");
        //     NewLine."Currency Code" := VoidCardEntry."EFT Currency";
        //     NewLine."Amount In Currency" := Round(POSExchangeLCYToFCY(today, VoidCardEntry."EFT Currency", NewLine.Amount), rCurrency."Amount Rounding Precision");
        //     NewLine.Description := VoidCardEntry."EFT Currency" + ' ' + Format(NewLine."Amount In Currency");
        // end;
        // NewLine.Modify(false);
        // CardEntry.Modify();

        //Commit;
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
        // if (DealNo <> '') and (not LinkedItemsActive) then
        //     if (CurrMenuType = 0) and (CurrMenuTypeDeal <> 0) then
        //         NewLine."Restaurant Menu Type" := CurrMenuTypeDeal;
        // if NewLine."Restaurant Menu Type" <> 0 then begin
        //     if MenuTypeRec.Get(REC."Store No.", NewLine."Restaurant Menu Type") then
        //         NewLine."Restaurant Menu Type Code" := MenuTypeRec."Code on POS";
        // end;
        POSTransactionEventsPub.OnAfterInitNewLine(REC, NewLine, CurrInput);
    end;

    internal procedure TestVoidCardEntry(OrgCardEntry: Record "LSC POS Card Entry"): Boolean
    begin
        PosTerminal.Reset();
        PosTerminal.SetRange("Store No.", POSSESSION.StoreNo());
        PosTerminal.SetRange(PosTerminal."No.", POSSESSION.TerminalNo());
        if PosTerminal.FindSet() then begin

        end;

        if not OrgCardEntry."Authorisation Ok" then
            exit(false);
        if OrgCardEntry.Voided then
            exit(false);
        if not (OrgCardEntry."Transaction Type" in [OrgCardEntry."Transaction Type"::Sale,
                                                    OrgCardEntry."Transaction Type"::Offline,
                                                    OrgCardEntry."Transaction Type"::FinalizePreAuth]) then
            exit(false);
        if OrgCardEntry."Store No." <> PosTerminal."Store No." then
            exit(false);
        if OrgCardEntry."POS Terminal No." <> PosTerminal."No." then
            exit(false);
        if OrgCardEntry.Date <> Today then
            exit(false);
        exit(true);
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
        rPosCardEntry: Record "LSC POS Card Entry";
        rTransLAf: Record "Trans. LAF";
    begin
        if gInsertTmpPayment then begin
            gInsertTmpPayment := false;
            lSkipCommit := true;
        end;

        POSTransactionEvents.OnBeforeInsertPaymentLine(REC, NewLine, CurrInput, TenderType.Code, Balance, PaymentAmount, Format(STATE), isHandled);
        if isHandled then
            exit;

        if REC."New Transaction" then
            SalePressed(false);

        if (BarcodeMask.Type = BarcodeMask.Type::Customer) or (BarcodeMask.Type = BarcodeMask.Type::"Member Card") then
            if (PaymentAmount = 0) and (CustomerOrCardNo = CurrInput) then
                exit;

        POSTransactionEvents.OnBeforeAssignPaymentLine(TenderType, NewLine, REC, StoreSetup, MultiplyWith, LineRec, InfoTextDescription, InfoTextDescription2);

        TenderTypeSetup.Get(TenderType.Code);
        NewLine."Entry Type" := NewLine."Entry Type"::Payment;
        NewLine."Bank Transfer" := TenderTypeSetup."Bank Transfer";
        NewLine.Quantity := MultiplyWith;
        if NewLine.Quantity = 0 then
            NewLine.Quantity := 1;
        NewLine.Validate(Number, TenderType.Code);

        ishandled := false;
        POSTransactionEvents.InsertPaymentLineOnBeforeSetAmountsMultiplyInTenderOperations(TenderType, NewLine, PosFuncProfile, PaymentAmount, isHandled);
        if not isHandled then begin
            if TenderType."Multiply in Tender Operations" then begin
                NewLine.Validate(Price, PaymentAmount);
                NewLine.Validate(Quantity);
                NewLine.CalcPrices
            end else
                NewLine.Validate(Amount, PaymentAmount);
        end;


        Clear(rPosCardEntry);
        rPosCardEntry.SetRange("Store No.", NewLine."Store No.");
        rPosCardEntry.SetRange("POS Terminal No.", NewLine."POS Terminal No.");
        rPosCardEntry.SetRange("Receipt No.", NewLine."Receipt No.");
        if rPosCardEntry.findset() then begin
            Clear(rTransLAf);
            rTransLAf.SetRange("Store No.", NewLine."Store No.");
            rTransLAf.SetRange("POS Terminal No.", NewLine."POS Terminal No.");
            rTransLAf.SetRange("Receipt No.", NewLine."Receipt No.");
            if rTransLAf.findset() then begin end;

            Currency.get(rPosCardEntry."EFT Currency");
            NewLine."Currency Code" := rPosCardEntry."EFT Currency";
            NewLine."Amount In Currency" := rTransLAf."EFT Amount";
        end;

        if TenderType."Foreign Currency" and (Currency.Code <> '') then begin
            NewLine."Currency Code" := Currency.Code;
            // NewLine."Amount In Currency" := AmountInCurrency;
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
        POSTransactionEvents.OnBeforeInsertLineInsertPaymentLine(REC, NewLine, CurrInput, TenderType.Code, Balance, PaymentAmount, Format(STATE), IsHandled);
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

        POSTransactionEvents.OnAfterInsertPaymentLine(REC, NewLine, CurrInput, TenderType.Code, lSkipCommit);

        if not lSkipCommit then
            CommitPaymentLine;
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
        // if not TestNewTransaction then
        //     exit;

        // InitialCommandPressed := GlobalMenuLine.Command;
        // REC."Transaction Type" := REC."Transaction Type"::Sales;
        // SetPOSState("LSC POS Transaction State"::SALES);
        // POSTransactionEvents.OnBeforeSalePressedStartNewTrans(REC);
        // REC."Sale Is Return Sale" := false;
        // StartNewTransaction;
        // POSTransactionEvents.OnAfterStartNewTransactionSalePressed(Keyed, REC);
        // InfoTextDescription := '';
        // SelectDefaultMenu;

        // POSTransactionEvents.OnAfterSalePressedStartNewTrans(PosFuncProfile, Rec, Keyed, CurrInput, IsHandled);
        // if IsHandled then
        //     exit;

        // StartPOSActionIsEmpty := CheckStartPOSActions();
        // if StartPOSActionIsEmpty or ((not StartPOSActionIsEmpty) and (InitialCommandPressed <> 'START')) then begin
        //     POSTransactionEvents.OnBeforeSetFunctionModeSalesPressed(POSFuncProfile, REC, Keyed, CurrInput, IsHandled);
        //     if not IsHandled then begin
        //         if (PosFuncProfile."Sales Person Mode" = PosFuncProfile."Sales Person Mode"::Automatic) then
        //             if POSSESSION.StaffEmploymentType = 2 then begin //BOTH
        //                 REC."Sales Staff" := POSSESSION.StaffID;
        //                 SetFunctionMode("LSC POS Command"::ITEM);
        //             end else
        //                 SetFunctionMode("LSC POS Command"::SALESP)
        //         else
        //             SetFunctionMode("LSC POS Command"::ITEM);
        //     end;
        // end;

        // if Keyed and not REC."Sale Is Return Sale" then begin
        //     if FromInit then
        //         POSGUI.PostCommand("LSC POS Command"::CHECK_INFOCODE, 'START')
        //     else
        //         CheckInfoCode('START');
        // end;
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

    procedure GetTenderType(): Text[20]
    begin
        exit(EBTTenderType);
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
            // NewLine."Card/Customer/Coup.Item No" := PosFunc.PadCardNo(pCardEntry.GetCardNo);
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
        InfoTextDescription := StrSubstNo('%1 %2', NewLine.Description, OPTPOSTransactionimpl.FormatAmount(NewLine.Amount));
        InfoTextDescription2 := '';
        MultiplyWith := 1;
        UOMSet := '';
        if STATE <> "LSC POS Transaction State"::TENDOP then begin
            if not ChangeTender then
                DisplayTotals;
            POSSESSION.SetTransPostingSource(POSTransPostingState."Posting Source"::"Commit Payment");
            // if CheckInfoCode(Format("LSC POS Transaction State"::PAYMENT)) then
            //     exit;
            CommitPaymentLineEx;
        end;
    end;

    procedure CommitPaymentLineEx()
    begin
        if TenderType."Do Not Post" then begin
            REC."Credit Card Hold" := true;
            REC.Modify;
            CalcTotals;
            //SetPOSState("LSC POS Transaction State"::PAYMENT);
            //SetFunctionMode("LSC POS Command"::PAYMENT);
        end else begin
            TransactionTendered;
        end;
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

    procedure DisplayTotals()
    var
        DisplayMultiply: Integer;
    begin
        DisplayMultiply := 1;
        if REC."Sale Is Return Sale" then
            DisplayMultiply := -1;

        OposUtil.DisplayTotals(DisplayMultiply * REC."Gross Amount", DisplayMultiply * Balance);
    end;




    procedure TransactionTendered()
    var
        SalesTypes: Record "LSC Sales Type";
        POSTransLine: Record "LSC POS Trans. Line";
        COLineTemp: Record "LSC Customer Order Line" temporary;
        COPOSFunctions: Codeunit "LSC CO POS Functions";
        //COUpdatePaymentUtils: Codeunit LSCCOUpdatePaymentUtils;
        //POSExchangerateconversion: Codeunit "LSC POS Exch. rate conversion";
        COUtility: Codeunit "LSC CO Utility";
        POSPrintUtility: Codeunit "LSC POS Print Utility";
        // COSession: Codeunit "LSC Customer Order Session";
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
    //POSTransLine:Record "LSC POS Trans. Line";
    begin
        CalcTotals;
        COAmountToDeductFromTot := 0;
        // if (Rec."Gross Amount" <> GrossAmountBeforeCreatingCO) or CustomerOrderSession.IsCustomerOrderEdit() then
        //     if (not CollectingOrder) and (REC."Customer Order") then
        //         COUtility.RecalculateOrderLines(REC, CustomerOrderLine_Temp, CustomerOrderDiscountLine_Temp, CustomerOrderHeader_Temp);

        if (REC."Rounding Amount" <> 0) and REC."Customer Order" then
            RoundedValue := (REC."Gross Amount" + REC."Rounding Amount" = REC.Payment) or (REC."Gross Amount" + REC."Rounding Amount" = abs(REC."Income/Exp. Amount"));

        POSTransactionEvents.OnBeforeTransactionTendered(REC, TenderType, VoidInProcess, Balance, TmpAmount, RoundedValue);

        if not VoidInProcess then begin
            Commit;
            CustomerOrderLine_Temp.SetRange("Line No.");
            if REC."Customer Order" and PrepayCustomerOrder then begin
                CustomerOrderLine_Temp.CalcSums(Amount, "Prepayment Amount");
                CustomerOrderPayment_Temp.CalcSums("Finalized Amount LCY", "Pre Approved Amount LCY");
                COAmountToDeductFromTot := CustomerOrderLine_Temp.Amount - PaymentAmount - CustomerOrderPayment_Temp."Finalized Amount LCY" - CustomerOrderPayment_Temp."Pre Approved Amount LCY";
            end;

            POSTransactionEvents.OnTransactionTenderedAfterInitAmounts(REC, TenderType, PaymentAmount, ChangeTender, IsHandled);
            if IsHandled then
                exit;

            if (PaymentCount >= 1) then begin
                PaymentCount := 0;
                exit
            end else
                if (Balance = 0) or (RoundedValue) then begin
                    if SalesTypes.Get(REC."Sales Type") then
                        if SalesTypes."Payment is Prepayment" then
                            exit;
                    // Member.OnBeforeTender(REC, TenderType);
                    // if CheckInfoCode('END') then
                    //     exit;
                    PaymentCount := PaymentCount + 1;
                    // if VendorSourcing then
                    //     if not COSession.IsCOLineCompressed() then
                    //         if CustomerOrderLine_Temp.FindSet then
                    //             repeat
                    //                 CustomerOrderLine_Temp."Vendor Sourcing" := true;

                    //                 CustomerOrderLine_Temp.Status := CustomerOrderLine_Temp.Status::"To Pick";

                    //                 CustomerOrderLine_Temp.Modify;
                    //             until CustomerOrderLine_Temp.Next = 0;

                    // if not CollectingOrder then begin
                    //     if PaymentAmount <> 0 then begin
                    //         ChangeAmount := COPOSFunctions.AddPaymentToCustomerOrder(CustomerOrderHeader_Temp, CustomerOrderLine_Temp, CustomerOrderPayment_Temp, REC, CustomerOrderHeader_Temp."Document ID", COTotalAmount, PrepayCustomerOrder, CORemainingAmount, AddExtraPaymentToCO, false, false, NoExchangeAddedToCO);
                    //         if not CustomerOrderSession.IsCustomerOrderEdit() then
                    //             if (ChangeAmount <> 0) and not NoExchangeAddedToCO then begin
                    //                 if (TenderType."Change Tend. Code" <> '') and ((-ChangeAmount <= TenderType."Min. Change") or (TenderType."Min. Change" = 0)) then begin
                    //                     if TenderType.Code <> TenderType."Change Tend. Code" then
                    //                         TenderType.Get(StoreSetup."No.", TenderType."Change Tend. Code");
                    //                 end else
                    //                     if ((TenderType."Above Min. Change Tender Type" <> '') and (-ChangeAmount > TenderType."Min. Change")) then
                    //                         if TenderType.Code <> TenderType."Above Min. Change Tender Type" then
                    //                             TenderType.Get(StoreSetup."No.", TenderType."Above Min. Change Tender Type");

                    //                 PaymentAmount := ChangeAmount;
                    //                 ChangeTender := true;
                    //                 InitNewLine;
                    //                 InsertPaymentLine;
                    //             end;
                    //     end;
                    //     PrintCoSlip := COPOSFunctions.FinalizePaymentForCustomerOrder(CustomerOrderHeader_Temp, CustomerOrderLine_Temp, CustomerOrderPayment_Temp, REC, CustomerOrderDiscountLine_Temp);
                    //     if AddExtraPaymentToCO = AddExtraPaymentToCO::DoAdd then begin
                    //         COUpdatePaymentUtils.SetPosFunctionalityProfile(PosFuncProfile."Profile ID");
                    //         COUpdatePaymentUtils.SendRequest(CustomerOrderPayment_Temp, COLineTemp, WebPreAuthNotAuthorized, ResponseCode, ErrorText);
                    //         COUpdatePaymentUtils.SetCommunicationError(ResponseCode, ErrorText);
                    //         if ErrorText <> '' then
                    //             Error(ErrorText);
                    //     end;
                    // end else begin
                    //     if REC."Customer Order" then begin
                    //         ChangeAmount := COPOSFunctions.AddPaymentToCustomerOrder(CustomerOrderHeader_Temp, CustomerOrderLine_Temp, CustomerOrderPayment_Temp, REC, CustomerOrderHeader_Temp."Document ID", COTotalAmount, PrepayCustomerOrder, 0, AddExtraPaymentToCO::DoNotAdd, true, NotIncludeWebPreAuth, NoExchangeAddedToCO);
                    //         COUpdatePaymentUtils.SetPosFunctionalityProfile(PosFuncProfile."Profile ID");
                    //         COUpdatePaymentUtils.SendRequest(CustomerOrderPayment_Temp, CustomerOrderLine_Temp, WebPreAuthNotAuthorized, ResponseCode, ErrorText);
                    //         COUpdatePaymentUtils.SetCommunicationError(ResponseCode, ErrorText);
                    //         if ErrorText <> '' then
                    //             Error(ErrorText);
                    //         if CustomerOrderHeader_Temp.CancelledOrder then
                    //             if not COUtility.CancelExcistingCustomerOrder(CustomerOrderHeader_TEMP, CustomerOrderLine_TEMP, CustomerOrderPayment_TEMP, CustomerOrderDiscountLine_Temp, ErrorText) then
                    //                 Error(ErrorText)
                    //             else begin
                    //                 Clear(CustomerOrderHeader_Temp);
                    //                 CustomerOrderHeader_Temp.DeleteAll();
                    //             end;
                    //     end;
                    // end;

                    if not WebPreAuthNotAuthorized then begin
                        POSTransLine.Reset;
                        POSTransLine.SetRange("Receipt No.", REC."Receipt No.");
                        POSTransLine.SetRange("Entry Type", POSTransLine."Entry Type"::Payment);
                        POSTransLine.SetFilter(Amount, '<=0');
                        POSTransLine.SetRange("CO Exchange Line", false);
                        if POSTransLine.FindLast then
                            if REC."Transaction Type" <> REC."Transaction Type"::Payment then
                                Remaining := POSTransLine.Amount;
                        if (not PrepayCustomerOrder and REC."Customer Order") then
                            Remaining := ChangeAmount;

                        CustomerOrderLine_Temp.CalcSums("Prepayment Amount");
                        CollectingOrder := false;
                        VendorSourcing := false;
                        ReceiptNo := REC."Receipt No.";
                        CustomerOrderID := REC."Customer Order ID";
                        //  COEdit := CustomerOrderSession.IsCustomerOrderEdit();
                        PostTransaction(true);
                        CustomerOrderPayment_Temp.DeleteAll;
                        PaymentCount := 0;
                        NotIncludeWebPreAuth := false;
                        if PrintCoSlip then begin
                            REC.CalcFields("Gross Amount", "Income/Exp. Amount", Payment);
                            POSPrintUtility.Init();
                            POSPrintUtility.PrintCOSlip(CustomerOrderID, ReceiptNo);
                        end;
                        PrintCoSlip := false;
                        exit
                    end else begin
                        WebPreAuthNotAuthorizedFunc(false);
                        if PrintCoSlip then begin
                            ReceiptNo := REC."Receipt No.";
                            CustomerOrderID := REC."Customer Order ID";
                            REC.CalcFields("Gross Amount", "Income/Exp. Amount", Payment);
                            POSPrintUtility.Init();
                            POSPrintUtility.PrintCOSlip(CustomerOrderID, ReceiptNo);
                        end;
                        PrintCoSlip := false;
                        exit;
                    end;
                end;

            if LastCurrencyCode <> '' then
                Currency.Get(LastCurrencyCode);
            PaymentAmount := PosFunc.RoundTender(TenderType, Balance);
            if (PaymentAmount = 0) then begin
                RemainingFCY := 0;
                // if CheckInfoCode('END') then
                //     exit;
                PostTransaction(true);
                PaymentCount := 0;
                exit;
            end;

            if (TenderType."Change Tend. Code" <> '') and (RealBalance < 0) then begin
                if (LastCurrencyCode <> '') and
                    ((TenderType."Above Min. Change Tender Type" = TenderType.Code) or
                    (TenderType."Change Tend. Code" = TenderType.Code))
                then begin
                    if Currency."LSC Lowest Accept. Denom. Amt." = 0 then
                        Currency."LSC Lowest Accept. Denom. Amt." := 0.01;

                    //TmpAmount := Round(POSExchangeLCYToFCY(today, VoidCardEntry."EFT Currency", NewLine.Amount), rCurrency."Amount Rounding Precision");
                    TmpAmount := Round(POSExchangeLCYToFCY(REC."Trans. Date", Currency.Code, Balance), REC."Currency Factor");
                    if Currency."Amount Rounding Precision" <> 0 then
                        TmpAmount := Round(TmpAmount, Currency."Amount Rounding Precision");
                    if (Currency."LSC Lowest Accept. Denom. Amt." < -TmpAmount) or
                        (TenderType."Change Tend. Code" = TenderType.Code) then begin
                        AmountInCurrency := Round(TmpAmount, Currency."LSC Lowest Accept. Denom. Amt.");
                        // PaymentAmount := Round(POSExchangerateconversion.POSExchangeFCYToLCY(REC."Trans. Date", Currency.Code, AmountInCurrency)
                        //                          * REC."Currency Factor", Currency."Amount Rounding Precision");


                        PaymentAmount := Round(POSExchangeFCYToLCY(REC."Trans. Date", Currency.Code, AmountInCurrency)
                       * REC."Currency Factor", Currency."Amount Rounding Precision");
                        RemainingFCY := AmountInCurrency;
                    end
                    else begin
                        Clear(Currency);
                        TenderType.Get(StoreSetup."No.", TenderType."Change Tend. Code");
                        AmountInCurrency := 0;
                        PaymentAmount := PosFunc.RoundTender(TenderType, Balance);
                        Remaining := PaymentAmount;
                    end;
                end
                else begin
                    if not (REC."Sale Is Return Sale") or (REC."Sale Is Return Sale" and (TmpAmount < 0)) then begin
                        if (TenderType."Change Tend. Code" <> '') and
                            ((-RealBalance <= TenderType."Min. Change") or (TenderType."Min. Change" = 0))
                        then
                            TenderType.Get(StoreSetup."No.", TenderType."Change Tend. Code")
                        else
                            if TenderType."Above Min. Change Tender Type" <> '' then
                                TenderType.Get(StoreSetup."No.", TenderType."Above Min. Change Tender Type")
                            else
                                Clear(TenderType);

                        if TenderType.Code <> '' then begin
                            KeyboardAmount := false;
                            PaymentAmount := PosFunc.RoundTender(TenderType, Balance);
                            if TenderType."Rounding To" <> 0 then begin
                                TmpAmount :=
                                  PosFunc.RoundTender(TenderType, REC."Gross Amount" + REC."Income/Exp. Amount" + REC."Service Charge") - REC.Payment;
                            end;
                            Remaining := PaymentAmount;
                        end;
                    end else
                        Clear(TenderType);
                end;

                if TenderType.Code <> '' then begin
                    if (PaymentAmount = 0) then begin
                        // if CheckInfoCode('END') then
                        //     exit;
                        PostTransaction(true);
                        exit;
                    end;

                    ChangeTender := true;
                    InitNewLine;
                    InsertPaymentLine;
                    PaymentCount := 0;
                    exit;
                end;
            end else
                if (TenderType.Code <> '') and (RealBalance >= 0) and ((RealBalance < TenderType."Rounding To") or (RealBalance < Currency."LSC Lowest Accept. Denom. Amt.")) then begin
                    PaymentAmount := 0;
                    RemainingFCY := 0;
                    // if CheckInfoCode('END') then
                    //     exit;
                    PostTransaction(true);
                    PaymentCount := 0;
                    exit;
                end;
        end;

        //SetFunctionMode("LSC POS Command"::PAYMENT);
        if RealBalance < 0 then begin
            if InfoTextDescription <> '' then
                InfoTextDescription2 := TenderChangeMsg
            else
                InfoTextDescription := TenderChangeMsg;
            PosTransactionGui.MessageBeep('');
        end;
        PaymentCount := 0;
        POSTransactionEvents.OnAfterTransactionTendered(RealBalance, InfoTextDescription2);
    end;

    procedure PostTransaction(PrintTransaction: Boolean)
    var
        POSTransPostingState: Record "LSC POS Trans. Posting State";
        IsHandled: Boolean;
    begin
        if PosSetup."Profile ID" = '' then
            PosSetup.Get(POSSESSION.HardwareProfileID);

        POSTransactionEventsPub.OnBeforePostTransaction(Rec, IsHandled);
        if IsHandled then
            exit;

        if REC."Staff ID" = '' then begin
            REC."Staff ID" := POSSESSION.StaffID;
            REC.Modify();
        end;
        POSTransPostingState."Receipt No." := rec."Receipt No.";
        POSTransPostingState."Posting Source" := POSSESSION.GetTransPostingSource();
        POSTransPostingState."Posting State" := POSTransPostingState."Posting State"::"Error Checking";

        POSTransPostingState.STATE := 'PAYMENT'; //Format(STATE);
        POSTransPostingState."Store No." := StoreSetup."No.";
        POSTransPostingState."POS Terminal No." := PosTerminal."No.";
        POSTransPostingState."Tender Type Code" := TenderType.Code;
        POSTransPostingState."POS Hardware Profile ID" := PosSetup."Profile ID";
        POSTransPostingState."Work Shift No." := POSSESSION.WorkShiftNo;
        //POSTransPostingState."Training Active" := TrainingActive;
        //POSTransPostingState."Global Sales Type" := GLobalSalesType;
        //POSTransPostingState."Global Hosp. Type Seq." := GlobalHospTypeSeq;
        POSTransPostingState."POS Functionality Profile ID" := PosFuncProfile."Profile ID";
        POSTransPostingState."Prevent Normal Sale" := (POSSESSION.GetValue("LSC POS Tag"::"PREVENT_NORMSALE") <> '');
        POSTransPostingState.Print := PrintTransaction;
        POSTransPostingState."Current POS Command Code" := FunctionSetup."Function Code";
        //POSTransPostingState.Remaining := Remaining;
        POSTransPostingState.RemainingFCY := RemainingFCY;
        //POSTransPostingState."Sales Trans. Printing Enabled" := not POSTransPrint.GetRecPrintDisabled();
        POSTransPostingState."Last Currency Code" := LastCurrencyCode;
        POSTransPostingState.Balance := Balance;
        POSTransPostingState."Gross Amount" := REC."Gross Amount";
        POSTransPostingState."Line Discount" := REC."Line Discount";
        POSTransPostingState."Inc./Exp. Amount" := REC."Income/Exp. Amount";
        POSTransPostingState."Net Amount" := REC."Net Amount";
        POSTransPostingState."Total Discount" := REC."Total Discount";
        POSTransPostingState.Payment := REC.Payment;
        POSTransPostingState.Prepayment := REC.Prepayment;

        POSTransactionEvents.OnBeforeProcessTransForPostingByState(REC);
        POSTransactionFunctions.ProcessTransactionForPostingByState(REC, POSTransPostingState);
        POSTransactionEvents.OnAfterProcessTransForPostingByState(REC);
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS EFT Utility", OnBeforeEFTRequest, '', false, false)]
    local procedure "LSC POS EFT Utility_OnBeforeEFTRequest"(POSTerminalNo: Text; RequestType: Text; var requestJson: JsonObject; var IsHandled: Boolean; var POSCardEntry: Record "LSC POS Card Entry"; var PEFT2: Page "LSC POS EFT Dialog 2")
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS EFT Utility", OnBeforeVoid, '', false, false)]
    local procedure "LSC POS EFT Utility_OnBeforeVoid"(POSTerminal: Record "LSC POS Terminal"; var EFTReversal: Text; var EFTAmount: Decimal; var EFTTenderType: Text; var EFTResult: Integer; var IsHandled: Boolean; var EFTCurrencyCode: Code[10])
    begin
        IsHandled := true;
    end;


    [EventSubscriber(ObjectType::Table, Database::"LSC Trans. Payment Entry", OnAfterInsertEvent, '', false, false)]
    local procedure LSC_Trans_Payment_Entryoninsert(var Rec: Record "LSC Trans. Payment Entry")
    var
        Items: Record Item;
        rCiaInfo: Record "Company Information";
        rtenderType: Record "LSC Tender Type";
    begin
        Clear(rtenderType);
        rtenderType.SetRange("Store No.", Rec."Store No.");
        rtenderType.setrange(Code, Rec."Tender Type");
        rtenderType.setrange("Pinpad Integration", true);
        if rtenderType.findset() then begin
            Rec."Card No." := '';
            Rec.Modify(false);
        end;

    end;
}
