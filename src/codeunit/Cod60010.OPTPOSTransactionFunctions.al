codeunit 60010 "OPT POS Transaction Functions"
{
    //Access = Internal;
    // SingleInstance = true;

    var
        POSTransPostingStateTmp: Record "LSC POS Trans. Posting State" temporary;
        POSTransSuspensionStateTmp: Record "LSC POS Trans. Susp. State" temporary;
        EPOSControlInterface: Codeunit "LSC POS Control Interface";
        POSTransactionGlob: Codeunit "OPT POS Transaction Impl";
        POSGUI: Codeunit "LSC POS GUI";
        POSSession: Codeunit "LSC POS Session";
        ClientSessionUtility: Codeunit "LSC Client Session Utility";
        POSTransactionEvents: Codeunit "OPT POS Transaction Events";
        PostingSource: Integer;
        ContinueProcessing: Boolean;
        PostingError_g: Boolean;
        CaptionDescription: Label 'Enter description';
        PostingCanceledText: Label 'Posting Canceled';
        SuspensionCanceledText: Label 'Suspension Canceled';
        NoLinesErr: Label 'No lines to exchange.';

    procedure ProcessTransactionForPostingByState(var POSTransaction: Record "LSC POS Transaction"; POSTransPostingState: Record "LSC POS Trans. Posting State"; var PostingError: Boolean)
    begin
        ProcessTransactionForPostingByState(POSTransaction, POSTransPostingState);
        PostingError := PostingError_g;
    end;

    procedure ProcessTransactionForPostingByState(var POSTransaction: Record "LSC POS Transaction"; POSTransPostingState: Record "LSC POS Trans. Posting State")
    var
        PosFuncProfile: Record "LSC POS Func. Profile";
    begin
        //ClientSessionUtility.ClearSkipUpdatingReplicationCounters();
        POSTransPostingStateTmp := POSTransPostingState;
        POSTransPostingStateTmp."Receipt No." := POSTransaction."Receipt No.";
        if not POSTransPostingStateTmp.insert then
            POSTransPostingStateTmp.Modify();
        // if POSTransPostingStateTmp."Training Active" then
        //     ClientSessionUtility.SetSkipUpdatingReplicationCounters();
        ProcessPostingByState(POSTransaction);
        //  ClientSessionUtility.ClearSkipUpdatingReplicationCounters();
        PosFuncProfile.Get(POSSession.FunctionalityProfileID());
        if POSTransPostingState."Training Active" and PosFuncProfile."Backup Training Trans." then
            UpdateReplicationCountersOnVoidedTrainingTransaction(POSTransPostingState."Receipt No.");
    end;

    internal procedure UpdateReplicationCountersOnVoidedTrainingTransaction(ReceiptNo: Code[20])
    var
        VoidedHeader: Record "LSC POS Voided Transaction";
        VoidedLine: Record "LSC POS Voided Trans. Line";
        VoidedInfoCodeEntry: Record "LSCPOSVoidedInfocodeEntry";
    begin
        VoidedHeader.Get(ReceiptNo);
        VoidedHeader.Modify(true); //Validates Replication Counter

        VoidedLine.SetRange("Receipt No.", ReceiptNo);
        if VoidedLine.FindSet() then
            repeat
                VoidedLine.Modify(true); //Validates Replication Counter
            until VoidedLine.Next() = 0;

        VoidedInfoCodeEntry.SetRange("Receipt No.", ReceiptNo);
        if VoidedInfoCodeEntry.FindSet then
            repeat
                VoidedInfoCodeEntry.Modify(true); //Validates Replication Counter
            until VoidedInfoCodeEntry.Next = 0;
    end;

    local procedure ProcessPostingByState(var POSTransaction: Record "LSC POS Transaction")
    var
        // HospitalityFunctions: Codeunit "LSC Hospitality Functions";
        IsHandled: Boolean;
        PostingError: Boolean;
    begin
        POSTransactionEvents.OnBeforeProcessPostingByState2(POSTransaction, POSTransPostingStateTmp, IsHandled);
        if IsHandled then
            exit;

        case POSTransPostingStateTmp."Posting State" of
            POSTransPostingStateTmp."Posting State"::"Error Checking":
                begin
                    if PrintingCheckReturnsError(POSTransaction) then
                        exit;
                    if VoucherCheckReturnsError(POSTransaction) then
                        exit;
                    if ChargeAccountCheckReturnsError(POSTransaction, POSTransaction."Sales Type") then
                        exit;
                    GoToNextPostingState(POSTransaction);
                end;
            POSTransPostingStateTmp."Posting State"::"Limit Input":
                begin
                    if NoInputPostingSource() then
                        GoToNextPostingState(POSTransaction)
                    else begin
                        if LimitInputNeeded(POSTransaction, POSTransaction."Sales Type", POSTransPostingStateTmp.Balance, true) then
                            exit;
                        GoToNextPostingState(POSTransaction)
                    end;
                end;
            POSTransPostingStateTmp."Posting State"::"Balance Checking":
                begin
                    if BalanceCheckingReturnsError(
                         POSTransaction, POSTransaction."Sales Type", POSTransPostingStateTmp.Balance, POSTransPostingStateTmp."Gross Amount",
                         POSTransPostingStateTmp."Line Discount", POSTransPostingStateTmp.Payment, POSTransPostingStateTmp."Order Limit", true)
                    then begin
                        CancelPosting();
                        exit;
                    end;
                    GoToNextPostingState(POSTransaction)
                end;
            POSTransPostingStateTmp."Posting State"::"Salesperson Input":
                begin
                    if NoInputPostingSource() then
                        GoToNextPostingState(POSTransaction)
                    else begin
                        if SalesPersonInputNeeded(POSTransaction, POSTransaction."Sales Type", POSTransPostingStateTmp."Sales Person") then
                            exit;
                        GoToNextPostingState(POSTransaction)
                    end;
                end;
            POSTransPostingStateTmp."Posting State"::"Description Input":
                begin
                    if NoInputPostingSource() then
                        GoToNextPostingState(POSTransaction)
                    else begin
                        if DescriptionInputNeeded(
                             POSTransaction, POSTransaction."Sales Type", POSTransPostingStateTmp."RequestedDescription", POSTransPostingStateTmp."Prevent Normal Sale", true)
                        then
                            exit;
                        GoToNextPostingState(POSTransaction)
                    end;
                end;
            POSTransPostingStateTmp."Posting State"::Processing:
                begin
                    ProcessTransactionBeforePosting(POSTransaction);
                    if not ContinueProcessing then
                        exit;
                    GoToNextPostingState(POSTransaction);
                end;
            POSTransPostingStateTmp."Posting State"::"Coupon Resetting":
                begin
                    if NoInputPostingSource() then
                        GoToNextPostingState(POSTransaction)
                    else begin
                        if NotUsedCouponsCheckInputNeeded(POSTransaction) then
                            exit;
                        GoToNextPostingState(POSTransaction);
                    end;
                end;
            POSTransPostingStateTmp."Posting State"::"KDS Checking":
                begin
                    // if HospitalityFunctions.InsertQueueCounterOnPosting(POSTransaction) then
                    //     POSTransaction.Modify();
                    if NoInputPostingSource() then
                        GoToNextPostingState(POSTransaction)
                    else begin
                        if KDSCheckInputNeeded(POSTransaction) then
                            exit;
                        GoToNextPostingState(POSTransaction);
                    end;
                end;
            POSTransPostingStateTmp."Posting State"::Posting:
                begin
                    IsHandled := false;
                    POSTransactionEvents.OnBeforePostAndDeleteTransaction(POSTransaction, POSTransPostingStateTmp, IsHandled);
                    if IsHandled then
                        exit;

                    PostAndDeleteTransaction(POSTransaction);
                    GoToNextPostingState(POSTransaction);
                end;
            POSTransPostingStateTmp."Posting State"::"Printing and Email Input":
                begin
                    if OnPrintingOrEmailingInputNeeded() then
                        exit;
                    GoToNextPostingState(POSTransaction);
                end;
            POSTransPostingStateTmp."Posting State"::Finalizing:
                begin
                    FinalizePosting();
                    clear(POSTransPostingStateTmp);
                    POSTransPostingStateTmp.DeleteAll();
                end;
        end;
    end;

    local procedure PrintingCheckReturnsError(POSTransaction: Record "LSC POS Transaction"): Boolean
    var
        POSPrintUtility: Codeunit "LSC POS Print Utility";
        ErrorPrintingFailed: Label 'Printer Health Check Failed!';
    begin
        POSPrintUtility.Init();
        // if POSTransPostingStateTmp.Print and (not POSPrintUtility.IsPostPrintOK(POSTransaction)) then begin
        //     PosMessage(ErrorPrintingFailed + '\' + POSPrintUtility.GetLastError);
        //     exit(true);
        // end;
        exit(false);
    end;

    local procedure VoucherCheckReturnsError(POSTransaction: Record "LSC POS Transaction"): Boolean
    var
        ErrorVoucherInvalid: Label 'A Voucher was invalid. Please retry.';
    begin
        if POSTransPostingStateTmp."Posting Source" <> POSTransPostingStateTmp."Posting Source"::"Suspended Prepayment" then begin
            if not ValidateVoucherEntry(POSTransaction."Receipt No.") then begin
                MessageBeep(ErrorVoucherInvalid);
                exit(true);
            end;
        end;
        exit(false);
    end;

    procedure ValidateVoucherEntry(ReceiptNo: Code[20]) VouchersAreOK: Boolean
    var
        lPOSTransaction: Record "LSC POS Transaction";
        lTenderType: Record "LSC Tender Type";
        TableSpecificInfocode: Record "LSC Table Specific Infocode";
        Infocode: Record "LSC Infocode";
        lPOSTransLine: Record "LSC POS Trans. Line";
        POSTransInfocodeEntry: Record "LSC POS Trans. Infocode Entry";
        lVoucherEntries: Record "LSC Voucher Entries";
        lPOSDataEntryType: Record "LSC POS Data Entry Type";
        BOUtils: Codeunit "LSC BO Utils";
        VoucherInfocodeCode: Code[20];
        VoucherNo: Code[20];
    begin
        VouchersAreOK := true;
        if not lPOSTransaction.Get(ReceiptNo) then
            exit;
        if lPOSTransaction."Transaction Type" <> lPOSTransaction."Transaction Type"::Sales then
            exit;
        if lPOSTransaction."Sale Is Return Sale" then
            exit;

        lPOSTransLine.Reset;
        lPOSTransLine.SetCurrentKey("Receipt No.", "Entry Type", Number);
        lPOSTransLine.SetRange("Receipt No.", ReceiptNo);
        lPOSTransLine.SetRange("Entry Type", lPOSTransLine."Entry Type"::Payment);
        lPOSTransLine.SetFilter(Amount, '>0');
        if lPOSTransLine.FindSet then
            repeat
                VoucherInfocodeCode := '';
                if lTenderType.Get(lPOSTransaction."Store No.", lPOSTransLine.Number) then begin
                    TableSpecificInfocode.Reset;
                    TableSpecificInfocode.SetRange("Table ID", Database::"LSC Tender Type");
                    TableSpecificInfocode.SetRange(Value, BOUtils.CombineTableKey(2, lPOSTransaction."Store No.", lPOSTransLine.Number, '', '', ''));
                    TableSpecificInfocode.SetRange("When Required", TableSpecificInfocode."When Required"::Positive);
                    if TableSpecificInfocode.FindSet then
                        repeat
                            if Infocode.Get(TableSpecificInfocode."Infocode Code") then
                                if Infocode."Data Entry Type" <> '' then
                                    if lPOSDataEntryType.Get(Infocode."Data Entry Type") then
                                        if (Infocode.Type = Infocode.Type::"Apply To Entry") and (Infocode."Input Required") and
                                          (lPOSDataEntryType."Create Voucher Entry") then
                                            VoucherInfocodeCode := TableSpecificInfocode."Infocode Code";
                        until (TableSpecificInfocode.Next = 0) or (VoucherInfocodeCode <> '');
                    if VoucherInfocodeCode <> '' then begin
                        VoucherNo := '';
                        POSTransInfocodeEntry.Reset;
                        POSTransInfocodeEntry.SetRange("Receipt No.", ReceiptNo);
                        POSTransInfocodeEntry.SetRange("Transaction Type", POSTransInfocodeEntry."Transaction Type"::"Payment Entry");
                        POSTransInfocodeEntry.SetRange("Line No.", lPOSTransLine."Line No.");
                        POSTransInfocodeEntry.SetRange(Infocode, VoucherInfocodeCode);
                        if POSTransInfocodeEntry.FindFirst then
                            VoucherNo := POSTransInfocodeEntry.Information;
                        lVoucherEntries.Reset;
                        lVoucherEntries.SetRange("Store No.", lPOSTransaction."Store No.");
                        lVoucherEntries.SetRange("Transaction No.", 0);
                        lVoucherEntries.SetRange("Line No.", lPOSTransLine."Line No.");
                        lVoucherEntries.SetRange("Receipt Number", ReceiptNo);
                        lVoucherEntries.SetRange("Voucher No.", VoucherNo);
                        if lPOSTransLine."Entry Status" = lPOSTransLine."Entry Status"::Voided then begin
                            if lVoucherEntries.FindFirst then
                                if not lVoucherEntries.Voided then begin
                                    lVoucherEntries.Voided := true;
                                    lVoucherEntries.Modify(true);
                                    VouchersAreOK := false;
                                end;
                        end
                        else begin
                            if lVoucherEntries.FindFirst then begin
                                if lVoucherEntries.Voided then begin
                                    lPOSTransLine.VoidLine;
                                    VouchersAreOK := false;
                                end
                            end
                            else begin
                                lPOSTransLine.VoidLine;
                                VouchersAreOK := false;
                            end;
                        end;
                    end;
                end;
            until lPOSTransLine.Next = 0;
    end;

    local procedure ChargeAccountCheckReturnsError(POSTransaction: Record "LSC POS Transaction"; SalesTypeCode: Code[20]): Boolean
    var
        SalesType: Record "LSC Sales Type";
        ErrorChargeAccount: Label 'Sale must be charged to a customer account';
    begin
        if SalesTypeCode = '' then
            exit(false);
        SalesType.Get(SalesTypeCode);

        if SalesType."Request Charge Account" then begin
            if POSTransaction."Customer No." = '' then begin
                ErrorBeep(ErrorChargeAccount);
                exit(true);
            end;
        end;
        exit(false);
    end;

    local procedure LimitInputNeeded(POSTransaction: Record "LSC POS Transaction"; SalesTypeCode: Code[20]; Balance: Decimal; OnPosting: Boolean): Boolean
    var
        SalesType: Record "LSC Sales Type";
        CaptionLimit: Label 'Enter Order Limit';
    begin
        if SalesTypeCode = '' then
            exit(false);
        if Balance <= 0 then
            exit(false);
        SalesType.Get(SalesTypeCode);

        if (SalesType."Limit Setting" = SalesType."Limit Setting"::"By Request") and (POSTransaction."Order Limit" = 0) then begin
            if OnPosting then
                POSTransactionGlob.Gui.OpenNumericKeyboard(CaptionLimit, '', Enum::"LSC POS Trans. Numpad Trigger"::"Limit Input on Posting")
            else
                POSTransactionGlob.Gui.OpenNumericKeyboard(CaptionLimit, '', Enum::"LSC POS Trans. Numpad Trigger"::"Limit Input on Suspending");
            exit(true);
        end;
        exit(false);
    end;

    procedure ProcessLimitInputOnPosting(POSTransaction: Record "LSC POS Transaction"; ResultOK: Boolean; Value: Text)
    var
        OrderLimit: Decimal;
    begin
        POSTransPostingStateTmp.Get(POSTransaction."Receipt No.");

        if ResultOK then begin
            if (Evaluate(OrderLimit, Value)) and (OrderLimit > 0) then begin
                POSTransPostingStateTmp."Order Limit" := OrderLimit;
                POSTransPostingStateTmp.Modify();
                GoToNextPostingState(POSTransaction);
            end else
                LimitInputNeeded(POSTransaction, POSTransaction."Sales Type", POSTransPostingStateTmp.Balance, true);
        end else begin
            CancelPosting();
            ErrorBeep(PostingCanceledText);
        end;
    end;

    local procedure BalanceCheckingReturnsError(POSTransaction: Record "LSC POS Transaction"; SalesTypeCode: Code[20]; Balance: Decimal; GrossAmt: Decimal; LineDiscAmt: Decimal; PaymentAmt: Decimal; InputOrderLimit: Decimal; OnPosting: Boolean): Boolean
    var
        SalesType: Record "LSC Sales Type";
        ErrorText: Text;
        MinAmount: Decimal;
        OrderLimit: Decimal;
        ErrorLimitPaymentMissing: Label 'Order limit is based on payment, payment missing';
        ErrorLimitTender: Label 'You cannot suspend - Balance is more than 0';
        ErrorLimit: Label 'You cannot suspend - Sale is above the limit of %1';
        ErrorDeposit: Label 'Deposit is below the minimum required deposit of %1';
    begin
        if SalesTypeCode = '' then
            exit(false);
        if Balance <= 0 then
            exit(false);

        SalesType.Get(SalesTypeCode);

        if ((SalesType."Request Deposit (%)" > 0) or (SalesType."Minimum Deposit" <> 0)) then begin
            MinAmount := (GrossAmt + LineDiscAmt) * SalesType."Request Deposit (%)" / 100;
            if MinAmount < SalesType."Minimum Deposit" then
                MinAmount := SalesType."Minimum Deposit";
            if (PaymentAmt + GetPrePayment(POSTransaction."Receipt No.")) < MinAmount then begin
                ErrorBeep(StrSubstNo(ErrorDeposit, Format(MinAmount)));
                exit(true);
            end;
        end;

        OrderLimit := POSTransaction."Order Limit";
        if InputOrderLimit > 0 then
            OrderLimit := InputOrderLimit;

        if SalesType."Limit Setting" > SalesType."Limit Setting"::None then begin
            ErrorText := ErrorLimit;
            case SalesType."Limit Setting" of
                SalesType."Limit Setting"::"By Default":
                    OrderLimit := SalesType."Default Order Limit";
                SalesType."Limit Setting"::"By Tender":
                    begin
                        if PaymentAmt = 0 then begin
                            ErrorBeep(ErrorLimitPaymentMissing);
                            exit(true);
                        end;
                        OrderLimit := PaymentAmt;
                        ErrorText := ErrorLimitTender;
                    end;
            end;
            if OrderLimit > 0 then
                if Balance > OrderLimit then begin
                    ErrorBeep(StrSubstNo(ErrorText, Format(OrderLimit)));
                    exit(true);
                end;

            //POSTransactionEvents.OnBeforeStoreOrderLimitOnPostingOrOnSuspending(POSTransaction."Receipt No.", OrderLimit, OnPosting);

            if OnPosting then
                StoreOrderLimitOnPosting(POSTransaction."Receipt No.", OrderLimit)
            else
                StoreOrderLimitOnSuspending(POSTransaction."Receipt No.", OrderLimit);
        end;

        exit(false);
    end;

    local procedure StoreOrderLimitOnPosting(ReceiptNo: Code[20]; OrderLimit: Decimal)
    begin
        POSTransPostingStateTmp."Order Limit" := OrderLimit;
        POSTransPostingStateTmp.Modify();
    end;

    local procedure SalesPersonInputNeeded(POSTransaction: Record "LSC POS Transaction"; SalesTypeCode: Code[20]; InputSalesPerson: Code[20]): Boolean
    var
        SalesType: Record "LSC Sales Type";
        CurrInput: Text;
        EnterSalesPerson: Label 'Sales person must be entered';
    begin
        if SalesTypeCode = '' then
            exit(false);
        if InputSalesPerson <> '' then
            exit(false);
        SalesType.Get(SalesTypeCode);

        if SalesType."Request Salesperson" then
            if POSTransaction."Sales Staff" = '' then begin
                CurrInput := '';
                POSTransactionGlob.SetCurrInput(CurrInput);
                //POSTransactionGlob.SetFunctionMode("LSC POS Command"::SALESP);
                ErrorBeep(EnterSalesPerson);
                exit(true);
            end;

        exit(false);
    end;

    procedure ProcessSalesPersonInputOnPosting(POSTransaction: Record "LSC POS Transaction"; Value: Text)
    begin
        if POSTransactionGlob.ValidateSalesPerson then begin
            POSTransPostingStateTmp.Get(POSTransaction."Receipt No.");
            POSTransPostingStateTmp."Sales Person" := Value;
            POSTransPostingStateTmp.Modify();
            GoToNextPostingState(POSTransaction);
        end;
    end;

    local procedure DescriptionInputNeeded(POSTransaction: Record "LSC POS Transaction"; SalesTypeCode: Code[20]; InputDescription: Text; PreventNormalSale: Boolean; OnPosting: Boolean): Boolean
    var
        SalesType: Record "LSC Sales Type";
        PayLoad: Text;
    begin
        if SalesTypeCode = '' then
            exit(false);
        if InputDescription <> '' then
            exit(false);
        SalesType.Get(SalesTypeCode);

        if DescriptionNeededOnPostingOrSuspend(SalesType, OnPosting) then
            if not PreventNormalSale then begin
                if POSTransaction."Requested Description" = '' then begin
                    PayLoad := '#SUSPTRANS-DESCR';
                    if OnPosting then
                        PayLoad := '#POSTTRANS-DESCR';
                    if SalesType."Descr. Request Caption" <> '' then
                        POSGUI.OpenAlphabeticKeyboard(SalesType."Descr. Request Caption", '', false, PayLoad, MaxStrLen(POSTransaction."Requested Description"))
                    else
                        POSGUI.OpenAlphabeticKeyboard(CaptionDescription, '', false, PayLoad, MaxStrLen(POSTransaction."Requested Description"));
                    exit(true);
                end;
            end;
        exit(false);
    end;

    procedure ProcessDescriptionInputOnPosting(POSTransaction: Record "LSC POS Transaction"; ResultOK: Boolean; Value: Text): Boolean
    begin
        POSTransPostingStateTmp.Get(POSTransaction."Receipt No.");

        if ResultOK then begin
            if Value = '' then begin
                DescriptionInputNeeded(POSTransaction, POSTransaction."Sales Type", POSTransPostingStateTmp."RequestedDescription", POSTransPostingStateTmp."Prevent Normal Sale", true);
                exit;
            end;
            POSTransPostingStateTmp."RequestedDescription" := CopyStr(Value, 1, MaxStrLen(POSTransPostingStateTmp.RequestedDescription));
            POSTransPostingStateTmp.Modify();
            GoToNextPostingState(POSTransaction);
        end else begin
            CancelPosting();
            ErrorBeep(PostingCanceledText);
        end;
    end;

    local procedure ProcessTransactionBeforePosting(var POSTransaction: Record "LSC POS Transaction")
    var
        POSCommand: Record "LSC POS Command";
        // COSession: Codeunit "LSC Customer Order Session";
        CustomDimensions: Dictionary of [Text, Text];
        CurrInput: Text;
        PostingText: Label 'Posting...';
    begin
        if POSTransPostingStateTmp."Current POS Command Code" <> Format(Enum::"LSC POS Command"::POST) then
            if POSCommand.Get(Format(Enum::"LSC POS Command"::POST)) then
                POSTransactionGlob.UpdateInputDevicesState(POSCommand, false);

        FillInValuesFromState(POSTransaction);
        CheckPostAsShipment(POSTransaction);

        // if COSession.IsCustomerOrderEdit() then begin
        //     if POSTransaction."Entry Status" <> POSTransaction."Entry Status"::Voided then
        //         POSTransaction.Modify();
        // end else
        POSTransaction.Modify;

        POSTransactionEvents.OnBeforePostPOSTransaction(POSTransaction);

        CurrInput := '';
        POSTransactionGlob.SetCurrInput(CurrInput);
        POSTransactionGlob.SetLastItemNo('');

        Commit;

        ContinueProcessing := true;
        POSTransactionEvents.OnBeforeUpdatePosInfoTextsAndAfterPOSTransCommit(POSTransaction, ContinueProcessing, POSTransPostingStateTmp);
        if not ContinueProcessing then begin
            CustomDimensions.Add('ContinueProcessing', 'false');
            CustomDimensions.Add('CurrentTransaction', POSTransaction."Receipt No.");
            LogMessage('LSC-0001', 'Event subscription that will stop current transaction posting', Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, CustomDimensions);
            exit;
        end;

        UpdatePosInfoTexts();

        POSTransactionGlob.SetErrorCheck;
        POSTransactionGlob.ScreenDisplay(PostingText);

        CheckDrawersToOpen(POSTransaction);
    end;

    local procedure NotUsedCouponsCheckInputNeeded(POSTransaction: Record "LSC POS Transaction"): Boolean
    var
        POSTransLineCpn: Record "LSC POS Trans. Line";
        POSFunctionalityProfile: Record "LSC POS Func. Profile";
        NotUsedCouponsTEMP: Record "LSC POS Trans. Line" temporary;
        AdditionalPOSCommands: Codeunit "LSC Additional POS Commands";
    begin
        if POSTransaction."Entry Status" = POSTransaction."Entry Status"::Voided then
            exit(false);

        NotUsedCouponsTEMP.Reset;
        NotUsedCouponsTEMP.DeleteAll;
        POSTransLineCpn.Reset;
        POSTransLineCpn.SetRange("Receipt No.", POSTransaction."Receipt No.");
        if POSTransLineCpn.FindSet then
            repeat
                if (POSTransLineCpn."Entry Status" = POSTransLineCpn."Entry Status"::" ") and
                   (POSTransLineCpn."Coupon Function" = POSTransLineCpn."Coupon Function"::Use) and
                   (POSTransLineCpn."Coupon Code" <> '') and
                   (POSTransLineCpn."Entry Type" in [POSTransLineCpn."Entry Type"::Coupon, POSTransLineCpn."Entry Type"::Payment]) and
                   (not POSTransLineCpn."Valid in Transaction")
                then begin
                    NotUsedCouponsTEMP := POSTransLineCpn;
                    NotUsedCouponsTEMP.Insert;
                end;
            until POSTransLineCpn.Next = 0;
        if NotUsedCouponsTEMP.FindSet then begin
            if POSFunctionalityProfile.Get(POSTransPostingStateTmp."POS Functionality Profile ID") then;
            repeat
                CouponResetReservation(NotUsedCouponsTEMP, POSFunctionalityProfile);
            until NotUsedCouponsTEMP.Next = 0;
            //AdditionalPOSCommands.CouponsNotUsedLookup(NotUsedCouponsTEMP);
            exit(true);
        end;
        exit(false);
    end;

    procedure ProcessNotUsedCoupons(ReceiptNo: Code[20]): Boolean
    var
        POSTransaction: Record "LSC POS Transaction";
    begin
        POSTransPostingStateTmp.Get(ReceiptNo);
        POSTransaction.Get(ReceiptNo);
        GoToNextPostingState(POSTransaction);
    end;

    procedure CouponResetReservation(POSTransLine: Record "LSC POS Trans. Line"; PosFuncProfile: Record "LSC POS Func. Profile")
    var
        CouponHeader: Record "LSC Coupon Header";
        CouponEntry: Record "LSC Coupon Entry";
        CouponEntryTEMP: Record "LSC Coupon Entry" temporary;
        SendSerialCouponUtils: Codeunit LSCSendSerialCouponUtils;
        ResponseCode: Code[30];
        WSErrorText: Text[1024];
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
                    SendSerialCouponUtils.SendRequest(false, CouponEntryTEMP, ResponseCode, WSErrorText);
                end;
            end;
    end;

    local procedure KDSCheckInputNeeded(POSTransaction: Record "LSC POS Transaction"): Boolean
    var
        KDSFunctions: Codeunit "LSC KDS Functions";
    begin
        if KDSFunctions.HospCheckKDSConfirmNeeded(2, 'POSTTRANS', POSTransPostingStateTmp.STATE, POSTransPostingStateTmp."Store No.", POSTransaction) then
            exit(true);
        exit(false);
    end;

    procedure ProcessKDSCheckInputOnPosting(ReceiptNo: Code[20])
    var
        POSTransaction: Record "LSC POS Transaction";
    begin
        POSTransPostingStateTmp.Get(ReceiptNo);
        POSTransaction.Get(ReceiptNo);
        GoToNextPostingState(POSTransaction);
    end;

    local procedure PostAndDeleteTransaction(var POSTransaction: Record "LSC POS Transaction")
    var
        LastTransaction: Record "LSC Transaction Header";
        PosFuncProfile: Record "LSC POS Func. Profile";
        PostUtil: Codeunit "LSC POS Post Utility";
        DelFunc: Codeunit "LSC Delivery Functions";
        TSUtil: Codeunit "LSC POS Trans. Server Utility";
        CustomDimensions: Dictionary of [Text, Text];
        ReTryCount: Integer;
        MaxReTryCount: Integer;
        PostedOk: Boolean;
        SleepMs: Integer;
    begin
        PosFuncProfile.Get(POSSession.FunctionalityProfileID());
        SaveValuesFromPOSTrans(POSTransaction);
        ReTryCount := 0;
        IF PosFuncProfile."Allow Posting Retries" then
            IF PosFuncProfile."Maximum Posting Tries" > 5 then
                MaxReTryCount := PosFuncProfile."Maximum Posting Tries"
            else
                MaxReTryCount := 5
        else
            MaxReTryCount := 0;
        PostedOk := false;
        While ReTryCount < MaxReTryCount Do begin
            ReTryCount := ReTryCount + 1;
            PostedOk := PostUtil.run(POSTransaction);
            IF PostedOk then
                ReTryCount := MaxReTryCount
            else begin
                Clear(CustomDimensions);
                CustomDimensions.Add('PostingError', GetLastErrorText());
                LogMessage('LSC-0002', 'Transaction posting error', Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, CustomDimensions);
            end;
            IF ReTryCount < MaxReTryCount then begin
                SleepMs := 500 * ReTryCount;
                Sleep(SleepMs);
            end;
        end;
        IF not PostedOk then
            PostUtil.run(POSTransaction);
        POSTransactionGlob.ScreenDisplay('');
        PostUtil.GetLastTransaction(LastTransaction);
        TSUtil.SendAtEndOfTransaction(LastTransaction);
        SaveLastTransaction(LastTransaction);
        POSTransactionGlob.SetTransNo(LastTransaction."Transaction No.");
        Commit;

        POSSession.SetValue("LSC POS Tag"::"LAST_POSTED_RECEIPT", POSTransaction."Receipt No.");
        POSSESSION.SetValue("LSC POS Tag"::"RetrievedSlipNo", '');

        DelFunc.CheckSendFinalOrderToCC(LastTransaction);
        POSTransactionEvents.OnAfterPostPOSTransaction(POSTransaction);
        RaiseVoidEvents(POSTransaction);

        Commit;

        OpenDrawers(POSTransaction);
    end;

    local procedure OnPrintingOrEmailingInputNeeded(): Boolean
    var
        POSHardwareProfile: Record "LSC POS Hardware Profile";
        POSTerminal: Record "LSC POS Terminal";
        LastTransaction: Record "LSC Transaction Header";
        PrinterDevice: Record "LSC POS Printer";
        POSPrintUtility: Codeunit "LSC POS Print Utility";
        DeviceID: Code[20];
        Phase: Integer;
        InputNeeded, IsHandled, ReturnValue : Boolean;
    begin
        if POSTerminal.Get(POSTransPostingStateTmp."POS Terminal No.") then;
        if POSHardwareProfile.Get(POSTransPostingStateTmp."POS Hardware Profile ID") then;
        if LastTransaction.Get(POSTransPostingStateTmp."Last Trans. Store No.", POSTransPostingStateTmp."Last Trans. Pos Terminal", POSTransPostingStateTmp."Last Trans. Trans. No.") then;

        if not POSTransPostingStateTmp.Print then
            exit(false);
        if not POSSession.PrinterActive then
            exit(false);

        if (LastTransaction."Entry Status" = LastTransaction."Entry Status"::Voided) then begin
            if POSTerminal."Void Slip" = POSTerminal."Void Slip"::Print then begin
                if (POSHardwareProfile.GetDevice("LSC Hardware Profile Devices"::Printer, '', '', 0, DeviceID)) then begin //0 = Printer
                    if not (PrinterDevice.Get(DeviceID)) then
                        exit(false);
                end;
                POSPrintUtility.Init();
                if (not POSPrintUtility.PrintSlips(LastTransaction, Phase)) and (POSPrintUtility.GetLastError <> '') then
                    PosMessage(POSPrintUtility.GetLastError);
            end;
            exit(false);
        end;

        if (POSTerminal."Sales Slip" = POSTerminal."Sales Slip"::"E-mail") or (POSTerminal."Sales Slip" = POSTerminal."Sales Slip"::"Print and E-mail") then begin
            if POSTerminal."Only Email Sales Transactions" then
                if POSTransPostingStateTmp."Transaction Type" <> POSTransPostingStateTmp."Transaction Type"::Sales then
                    POSTerminal."Sales Slip" := POSTerminal."Sales Slip"::Print;
            if NoInputPostingSource() then
                POSTerminal."Sales Slip" := POSTerminal."Sales Slip"::Print;
        end;

        if POSTerminal."Sales Slip" <> POSTerminal."Sales Slip"::"E-mail" then begin
            if (POSHardwareProfile.GetDevice("LSC Hardware Profile Devices"::Printer, '', '', 0, DeviceID)) then //0 = Printer
            begin
                if not (PrinterDevice.Get(DeviceID)) then
                    exit(false);
            end;
        end;

        if LastTransaction."Transaction Type" = LastTransaction."Transaction Type"::Sales then
            if ExtraPrintRequired(LastTransaction) then
                if POSTerminal."Sales Slip" = POSTerminal."Sales Slip"::None then
                    POSTerminal."Sales Slip" := POSTerminal."Sales Slip"::Print;

        if (LastTransaction."Transaction Type" <> LastTransaction."Transaction Type"::Sales) or
           (POSTransPostingStateTmp."Sales Trans. Printing Enabled") or
           (LastTransaction."Sale Is Return Sale")
        then begin
            POSTransactionEvents.OnBeforeEmailingInputOrPrint(POSPrintUtility, LastTransaction, Phase, POSTransPostingStateTmp, POSHardwareProfile, POSTerminal, IsHandled, ReturnValue);
            if IsHandled then
                exit(ReturnValue);

            if (POSTerminal."Sales Slip" = POSTerminal."Sales Slip"::None) and (LastTransaction."Transaction Type" in [LastTransaction."Transaction Type"::"Float Entry",
                LastTransaction."Transaction Type"::"Remove Tender", LastTransaction."Transaction Type"::"Change Tender", LastTransaction."Transaction Type"::"Tender Decl."]) then begin
                POSPrintUtility.Init();
                if (not POSPrintUtility.PrintSlips(LastTransaction, Phase)) and (POSPrintUtility.GetLastError <> '') then
                    PosMessage(POSPrintUtility.GetLastError);
                exit(false);
            end;
            if (POSTerminal."Sales Slip" = POSTerminal."Sales Slip"::None) and ExtraPrintRequired(LastTransaction) then begin
                if (not POSPrintUtility.PrintSlips(LastTransaction, Phase)) and (POSPrintUtility.GetLastError <> '') then
                    PosMessage(POSPrintUtility.GetLastError);
                exit(false);
            end;
            if POSTerminal."Sales Slip" in [POSTerminal."Sales Slip"::None, POSTerminal."Sales Slip"::Print, POSTerminal."Sales Slip"::"Print on Confirmation"] then begin
                POSPrintUtility.Init();
                if (not POSPrintUtility.PrintSlips(LastTransaction, Phase)) and (POSPrintUtility.GetLastError <> '') then
                    PosMessage(POSPrintUtility.GetLastError);
                exit(false);
            end;

            if (POSTerminal."Sales Slip" in [POSTerminal."Sales Slip"::"E-mail", POSTerminal."Sales Slip"::"Print and E-mail"]) then begin
                InputNeeded := EmailOrPrint(POSHardwareProfile, POSTerminal, LastTransaction);
                exit(InputNeeded);
            end;
        end;
        exit(false);
    end;

    local procedure EmailOrPrint(POSHardwareProfile: Record "LSC POS Hardware Profile"; POSTerminal: Record "LSC POS Terminal"; LastTransaction: Record "LSC Transaction Header"): Boolean
    var
        Customer: Record Customer;
        MemberContact: Record "LSC Member Contact";
        POSPrintUtility: Codeunit "LSC POS Print Utility";
        POSFunctions: Codeunit "LSC POS Functions";
        SelectText: Text;
        lEmail: Text;
        Phase: Integer;
        SelectedOpt: Integer;
        CustEmailUsed, MemberEmailUsed, IsHandled, ReturnValue : Boolean;
        SelectEmailText: Label 'Send to: %1,Change e-mail,Print';
        EnterEmailText: Label 'Enter e-mail,Print';
    begin
        POSTransactionEvents.OnBeforeEmailOrPrintV2(POSHardwareProfile, POSTerminal, LastTransaction, POSTransPostingStateTmp, IsHandled, ReturnValue);
        if IsHandled then
            exit(ReturnValue);

        CustEmailUsed := false;
        if Customer.Get(POSTransPostingStateTmp."Customer No.") then
            if Customer."E-Mail" <> '' then begin
                lEmail := Customer."E-Mail";
                CustEmailUsed := true;
            end;
        POSFunctions.GetCurrMemberContact(MemberContact);
        if MemberContact."E-Mail" <> '' then begin
            lEmail := MemberContact."E-Mail";
            CustEmailUsed := false;
            MemberEmailUsed := true;
        end;
        if lEmail <> '' then begin
            SelectText := StrSubstNo(SelectEmailText, lEmail);
            SelectedOpt := EPOSControlInterface.SelectOption('', SelectText, 0, false);
        end else begin
            SelectedOpt := EPOSControlInterface.SelectOption('', EnterEmailText, 0, false) + 1;
        end;

        if SelectedOpt = 0 then
            exit(false);
        if (SelectedOpt in [1, 2, 3]) then begin
            if (SelectedOpt = 3) or (POSTerminal."Sales Slip" = POSTerminal."Sales Slip"::"Print and E-mail") then begin
                POSPrintUtility.Init();
                if (not POSPrintUtility.PrintSlips(LastTransaction, Phase)) and (POSPrintUtility.GetLastError <> '') then
                    PosMessage(POSPrintUtility.GetLastError);
            end;
            if SelectedOpt = 3 then
                exit(false);
        end;

        if ((SelectedOpt = 1) and (lEmail = '')) or (SelectedOpt = 2) then begin
            POSTransPostingStateTmp."Email Type" := POSTransPostingStateTmp."Email Type"::Manual;
            if CustEmailUsed then begin
                POSTransPostingStateTmp."Email Type" := POSTransPostingStateTmp."Email Type"::Customer;
                POSTransPostingStateTmp."Customer/Member Email" := Customer."E-Mail";
            end;
            if MemberEmailUsed then begin
                POSTransPostingStateTmp."Email Type" := POSTransPostingStateTmp."Email Type"::Member;
                POSTransPostingStateTmp."Member Account No." := MemberContact."Account No.";
                POSTransPostingStateTmp."Member Contact No." := MemberContact."Contact No.";
                POSTransPostingStateTmp."Customer/Member Email" := MemberContact."E-Mail";
            end;
            POSTransPostingStateTmp."Email Address" := lEmail;
            POSTransPostingStateTmp.Modify();
            GetEmailInput(lEmail);
            exit(true);
        end;
        SendEmail(LastTransaction, lEmail);
        exit(false);
    end;

    local procedure SendEmail(LastTransaction: Record "LSC Transaction Header"; EmailAddress: Text): Boolean
    var
        POSRequestsMgt: Codeunit "LSC POS Requests Mgt";
    begin
        // if EmailAddress <> '' then
        //     POSRequestsMgt.InsertRequest('SLIPEMAIL', LastTransaction, EmailAddress);
    end;

    local procedure GetEmailInput(EmailInput: Text): Boolean
    var
        EmailForReceipt: Label 'E-mail for receipt';
    begin
        POSGUI.OpenAlphabeticKeyboard(
          EmailForReceipt, EmailInput, false, GetEmailPayLoad(POSTransPostingStateTmp."Receipt No."), MaxStrLen(POSTransPostingStateTmp."Customer/Member Email"));
    end;

    procedure ProcessEmailInput(ResultOK: Boolean; InputValue: Text; PayLoad: Text)
    var
        Customer: Record Customer;
        LastTransaction: Record "LSC Transaction Header";
        POSTransaction: Record "LSC POS Transaction";
        MemberContact: Record "LSC Member Contact";
        POSFunctions: Codeunit "LSC POS Functions";
        EmailNotValid: Label 'E-mail %1 is not valid. Try again.';
        ChangeMemberEmailText: Label 'Replace member contact e-mail: %1 with this new mail address: %2?';
        ChangeCustEmailText: Label 'Replace customer e-mail: %1 with this new mail address: %2?';
    begin
        POSTransPostingStateTmp.Get(GetReceiptNoFromEmailPayLoad(PayLoad));
        if ResultOK and (InputValue <> '') then begin
            if not POSFunctions.CheckValidEmailAddresses(InputValue) then begin
                PosMessage(StrSubstNo(EmailNotValid, InputValue));
                GetEmailInput(InputValue);
                exit;
            end;
            case POSTransPostingStateTmp."Email Type" of
                POSTransPostingStateTmp."Email Type"::Customer:
                    begin
                        if (POSTransPostingStateTmp."Customer/Member Email" <> InputValue) then
                            if POSGUI.PosConfirm(StrSubstNo(ChangeCustEmailText, POSTransPostingStateTmp."Customer/Member Email", InputValue), true) then begin
                                if Customer.Get(POSTransPostingStateTmp."Customer No.") then begin
                                    Customer."E-Mail" := InputValue;
                                    Customer.Modify(true);
                                end;
                            end;
                    end;
                POSTransPostingStateTmp."Email Type"::Member:
                    begin
                        if (POSTransPostingStateTmp."Customer/Member Email" <> InputValue) then
                            if POSGUI.PosConfirm(StrSubstNo(ChangeMemberEmailText, POSTransPostingStateTmp."Customer/Member Email", InputValue), true) then begin
                                if MemberContact.Get(POSTransPostingStateTmp."Member Account No.", POSTransPostingStateTmp."Member Contact No.") then begin
                                    MemberContact."E-Mail" := InputValue;
                                    MemberContact.Modify(true);
                                end;
                            end;
                    end;
            end;
            if LastTransaction.Get(POSTransPostingStateTmp."Last Trans. Store No.", POSTransPostingStateTmp."Last Trans. Pos Terminal", POSTransPostingStateTmp."Last Trans. Trans. No.") then;
            SendEmail(LastTransaction, InputValue);
        end;

        GoToNextPostingState(POSTransaction);
    end;

    local procedure FinalizePosting()
    var
        HospType: Record "LSC Hospitality Type";
        LastTransaction: Record "LSC Transaction Header";
        POSRequestsMgt: Codeunit "LSC POS Requests Mgt";
        POSFunctions: Codeunit "LSC POS Functions";
        StayInPosOnPost: Boolean;
    begin
        if LastTransaction.Get(POSTransPostingStateTmp."Last Trans. Store No.", POSTransPostingStateTmp."Last Trans. Pos Terminal", POSTransPostingStateTmp."Last Trans. Trans. No.") then;

        if POSTransPostingStateTmp."Training Active" then begin
            LastTransaction.Delete(true);
            // ClientSessionUtility.ClearSkipUpdatingReplicationCounters();
            LastTransaction.Insert(true);
        end else
            if LastTransaction."Open Drawer" then
                POSTransactionGlob.FlagWaitDrawerClose;

        // POSRequestsMgt.ProcessPendingRequests;
        // if POSRequestsMgt.GetNumberOfPendingRequests > 0 then
        //     if POSRequestsMgt.GetNumberOfRequestsOnError > 0 then
        //         PosMessage(POSRequestsMgt.GetFirstErrorText)
        //     else
        //         PosMessage(StrSubstNo('%1 Pending Requests', POSRequestsMgt.GetNumberOfPendingRequests));

        POSTransactionGlob.TSSendUnsentTransactions;
        POSTransactionGlob.TSCheckError;

        StayInPosOnPost := true;
        if HospType.Get(POSTransPostingStateTmp."Store No.", POSTransPostingStateTmp."Global Hosp. Type Seq.", POSTransPostingStateTmp."Global Sales Type") then
            StayInPosOnPost := (HospType."After Transaction Posted" = HospType."After Transaction Posted"::"Stay in Sales POS");

        //POSFunctions.InsertTransInUseOnPos(LastTransaction."Receipt No.", POSTransPostingStateTmp."POS Terminal No.", true, false);

        if StayInPosOnPost then begin
            if POSTransactionGlob.MakeRepayTrans then
                exit;
            POSTransactionGlob.InsertTmpTransaction(false);
            POSTransactionGlob.ClearGlobs;
            POSTransactionGlob.PickUpWarning(LastTransaction);
            POSTransactionGlob.SetTransNo(LastTransaction."Transaction No.");
            POSTransactionGlob.ClearPluCheckPriceAndVariant;
        end else begin
            POSSession.SetValue("LSC POS Tag"::"ENDDISPLAY", '');
            if POSTransPostingStateTmp.Remaining <> 0 then
                if POSTransactionGlob.GetPosInfoText1 <> '' then
                    POSSession.SetValue("LSC POS Tag"::"ENDDISPLAY", POSTransactionGlob.GetPosInfoText1);
            POSTransactionGlob.SetTransNo(LastTransaction."Transaction No.");
            POSTransactionGlob.CloseForm();
        end;

        case POSTransPostingStateTmp."Posting Source" of
            // POSTransPostingStateTmp."Posting Source"::"Commit Payment":
            //     POSTransactionGlob.SetFunctionMode("LSC POS Command"::ITEM);
            POSTransPostingStateTmp."Posting Source"::"Customer Order List":
                POSTransactionGlob.CustomerOrderListAfterPosting;
            // POSTransPostingStateTmp."Posting Source"::Float:
            //     POSTransactionGlob.FloatPressedEx;
            POSTransPostingStateTmp."Posting Source"::"Post Pressed":
                POSTransactionGlob.Gui.MessageBeep('');
            POSTransPostingStateTmp."Posting Source"::"Remove Tender":
                POSTransactionGlob.RemoveTenderPressedEx;
            POSTransPostingStateTmp."Posting Source"::"Tender Decl.":
                POSTransactionGlob.TenderDeclPressedEx;
        // POSTransPostingStateTmp."Posting Source"::"Void and Copy":
        //     POSTransactionGlob.Member.Image;
        end;
        POSTransactionEvents.OnAfterFinalizePosting(LastTransaction, POSTransPostingStateTmp, StayInPosOnPost);
    end;

    local procedure CheckPostAsShipment(var POSTransaction: Record "LSC POS Transaction")
    var
        CustomerAccountTenderType: Record "LSC Tender Type";
        PaymentPOSTransLine: Record "LSC POS Trans. Line";
        MenuLine: Record "LSC POS Menu Line";
        POSFunctions: Codeunit "LSC POS Functions";
        OtherThanCustomerAccountUsed: Boolean;
    begin
        if POSTransaction."Post as Shipment" then begin
            OtherThanCustomerAccountUsed := false;
            PaymentPOSTransLine.Reset;
            PaymentPOSTransLine.SetCurrentKey("Receipt No.", "Entry Type", "Entry Status");
            PaymentPOSTransLine.SetRange("Receipt No.", POSTransaction."Receipt No.");
            PaymentPOSTransLine.SetRange("Entry Type", PaymentPOSTransLine."Entry Type"::Payment);
            PaymentPOSTransLine.SetRange("Entry Status", PaymentPOSTransLine."Entry Status"::" ");
            PaymentPOSTransLine.SetFilter(Amount, '<>0');
            if PaymentPOSTransLine.FindSet then
                repeat
                    CustomerAccountTenderType.Reset;
                    CustomerAccountTenderType.SetRange("Store No.", POSTransaction."Store No.");
                    CustomerAccountTenderType.SetRange("Function", CustomerAccountTenderType."Function"::Customer);
                    CustomerAccountTenderType.SetRange(Code, PaymentPOSTransLine.Number);
                    if not CustomerAccountTenderType.FindFirst then
                        OtherThanCustomerAccountUsed := true;
                until (PaymentPOSTransLine.Next = 0) or (OtherThanCustomerAccountUsed);
            if OtherThanCustomerAccountUsed then
                POSTransaction."Post as Shipment" := false;
            if POSTransaction."Post as Shipment" then begin
                MenuLine."Menu ID" := '';
                MenuLine.Command := Format(Enum::"LSC POS Command"::PRINTBILL);
                POSFunctions.POSlog(MenuLine, POSTransaction."Receipt No.");
            end;
        end;
    end;

    local procedure CheckDrawersToOpen(POSTransaction: Record "LSC POS Transaction")
    var
        TenderType: Record "LSC Tender Type";
        PaymentPOSTransLine: Record "LSC POS Trans. Line";
        DrawerSetup: Record "LSC POS Drawer Setup";
        DrawersToOpen: Text;
        DrawersToOpenCount: Integer;
        OpenDefaultDrawer: Boolean;
    begin
        if (not POSTransPostingStateTmp."Training Active") and
           (not (POSTransaction."Transaction Type" in
                  [POSTransaction."Transaction Type"::"Remove Tender",
                   POSTransaction."Transaction Type"::"Float Entry",
                   POSTransaction."Transaction Type"::"Change Tender",
                   POSTransaction."Transaction Type"::"Tender Decl."]))
        then begin
            PaymentPOSTransLine.Reset;
            PaymentPOSTransLine.SetCurrentKey("Receipt No.", "Entry Type", "Entry Status");
            PaymentPOSTransLine.SetRange("Receipt No.", POSTransaction."Receipt No.");
            PaymentPOSTransLine.SetRange("Entry Type", PaymentPOSTransLine."Entry Type"::Payment);
            PaymentPOSTransLine.SetRange("Entry Status", PaymentPOSTransLine."Entry Status"::" ");
            PaymentPOSTransLine.SetFilter(Amount, '<>0');
            if PaymentPOSTransLine.FindSet then
                repeat
                    DrawerSetup.SetFilter(Store, '%1|%2', '', POSTransaction."Store No.");
                    DrawerSetup.SetFilter("Tender Type", '%1|%2', '', PaymentPOSTransLine.Number);
                    DrawerSetup.SetFilter(Currency, '%1|%2', '', PaymentPOSTransLine."Currency Code");
                    if DrawerSetup.FindLast then begin
                        if (DrawerSetup."Drawer Role" = '') then
                            OpenDefaultDrawer := true
                        else
                            if StrPos(DrawersToOpen, DrawerSetup."Drawer Role") = 0 then begin
                                DrawersToOpen += DrawerSetup."Drawer Role" + ',';
                                DrawersToOpenCount += 1;
                            end;
                    end else begin
                        if TenderType.Get(POSTransaction."Store No.", PaymentPOSTransLine.Number) then begin
                            if TenderType."Drawer Opens" then
                                if POSTransaction."Entry Status" <> POSTransaction."Entry Status"::Voided then
                                    OpenDefaultDrawer := true;
                            Clear(TenderType);
                        end;
                    end;
                until PaymentPOSTransLine.Next = 0;
        end;
        POSTransPostingStateTmp."Open Default Drawer" := OpenDefaultDrawer;
        POSTransPostingStateTmp."No. of Drawers to Open" := DrawersToOpenCount;
        POSTransPostingStateTmp."Drawers to Open" := DrawersToOpen;
        POSTransPostingStateTmp.Modify();
    end;

    local procedure UpdatePosInfoTexts()
    var
        TenderType: Record "LSC Tender Type";
        POSTransaction: Record "LSC POS Transaction";
        Description: Text;
        Description2: Text;
        ChangeBackText: Label 'Change back in last transaction is ';
    begin
        if TenderType.Get(POSTransPostingStateTmp."Store No.", POSTransPostingStateTmp."Tender Type Code") then;
        if (POSTransPostingStateTmp.Remaining <> 0) or (POSTransPostingStateTmp.RemainingFCY <> 0) then begin
            Description := '';
            if POSTransPostingStateTmp.Remaining <> 0 then
                Description := ChangeBackText + ' ' + TenderType.Description + ' ' + FormatAmount(POSTransPostingStateTmp.Remaining);
            Description2 := '';
            if POSTransPostingStateTmp.RemainingFCY <> 0 then
                Description2 := POSTransPostingStateTmp."Last Currency Code" + ' ' + ChangeBackText + ' ' + FormatAmount(POSTransPostingStateTmp.RemainingFCY);

            POSTransactionGlob.GetPOSTransaction(POSTransaction);
            if abs(POSTransPostingStateTmp.Remaining) = abs(POSTransaction."Rounding Amount") then begin
                clear(Description);
                clear(Description2);
            end;

            POSGUI.UpdatePosInfoTexts(Description, Description2);
            POSTransactionGlob.SetPosInfoText1(Description);
            POSTransactionGlob.SetPosInfoText2(Description2);
        end;
    end;

    local procedure RunReportIfNeeded(POSTransaction: Record "LSC POS Transaction")
    var
        SalesType: Record "LSC Sales Type";
    begin
        if POSTransaction."Sales Type" = '' then
            exit;
        SalesType.Get(POSTransaction."Sales Type");

        if SalesType."Pre-Posting Report ID" <> 0 then
            REPORT.RunModal(SalesType."Pre-Posting Report ID", false, false, POSTransaction);
    end;

    local procedure OpenDrawers(POSTransaction: Record "LSC POS Transaction")
    var
        i: Integer;
    begin
        if not POSTransPostingStateTmp."Training Active" then begin
            if POSTransPostingStateTmp."Open Default Drawer" or (POSTransaction."Transaction Type" = POSTransaction."Transaction Type"::"Open Drawer") then
                POSTransactionGlob.OpenDrawer('');

            for i := 1 to POSTransPostingStateTmp."No. of Drawers to Open" do begin
                POSTransactionGlob.OpenDrawer(SelectStr(i, POSTransPostingStateTmp."Drawers to Open"));
            end;
        end;
    end;

    local procedure SaveLastTransaction(LastTransaction: Record "LSC Transaction Header")
    begin
        POSTransPostingStateTmp."Last Trans. Pos Terminal" := LastTransaction."POS Terminal No.";
        POSTransPostingStateTmp."Last Trans. Store No." := LastTransaction."Store No.";
        POSTransPostingStateTmp."Last Trans. Trans. No." := LastTransaction."Transaction No.";
        POSTransPostingStateTmp.Modify();
    end;

    local procedure FillInValuesFromState(var POSTransaction: Record "LSC POS Transaction")
    begin
        if POSTransPostingStateTmp."Order Limit" > 0 then
            POSTransaction."Order Limit" := POSTransPostingStateTmp."Order Limit";
        if POSTransPostingStateTmp."Sales Person" <> '' then
            POSTransaction."Sales Staff" := POSTransPostingStateTmp."Sales Person";
        if POSTransPostingStateTmp."RequestedDescription" <> '' then begin
            POSTransaction."Requested Description" := POSTransPostingStateTmp."RequestedDescription";
            if POSTransaction.comment = '' then //only put in if empty, Queue counter has precedence
                POSTransaction.Comment := POSTransaction."Requested Description";
        end;
        POSTransaction."Shift No." := POSTransPostingStateTmp."Work Shift No.";
        if POSTransPostingStateTmp."Training Active" then
            POSTransaction."Entry Status" := POSTransaction."Entry Status"::Training;
    end;

    local procedure SaveValuesFromPOSTrans(POSTransaction: Record "LSC POS Transaction")
    begin
        POSTransPostingStateTmp."Customer No." := POSTransaction."Customer No.";
        POSTransPostingStateTmp."Transaction Type" := POSTransaction."Transaction Type";
        POSTransPostingStateTmp.Modify();
    end;

    local procedure PosMessage(MessageText: Text)
    var
        POSTransactionCu: Codeunit "LSC POS Transaction";
    begin
        POSTransactionCu.PosMessage(MessageText);
    end;

    local procedure MessageBeep(MessageText: Text)
    var
        POSTransactionCu: Codeunit "LSC POS Transaction";
    begin
        POSTransactionCu.MessageBeep(MessageText);
    end;

    local procedure ErrorBeep(MessageText: Text)
    var
        POSTransactionCu: Codeunit "LSC POS Transaction";
    begin
        POSTransactionCu.ErrorBeep(MessageText);
    end;

    local procedure FormatAmount(Amount: Decimal): Text
    var
        POSTransactionCu: Codeunit "LSC POS Transaction";
    begin
        exit(POSTransactionCu.FormatAmount(Amount));
    end;

    procedure GoToNextPostingState(POSTransaction: Record "LSC POS Transaction")
    begin
        POSTransPostingStateTmp.Get(POSTransPostingStateTmp."Receipt No.");
        POSTransPostingStateTmp."Posting State" := POSTransPostingStateTmp."Posting State" + 1;
        POSTransPostingStateTmp.Modify();
        ProcessPostingByState(POSTransaction);
    end;

    local procedure CancelPosting()
    begin
        POSTransPostingStateTmp.Get(POSTransPostingStateTmp."Receipt No.");
        POSTransPostingStateTmp."Posting State" := POSTransPostingStateTmp."Posting State"::None;
        POSTransPostingStateTmp.Modify();
    end;

    procedure GetPrePayment(ReceiptNo: Code[20]) res: Decimal
    var
        POSTransLine: Record "LSC POS Trans. Line";
    begin
        //Returns amount of prepayment on the trans
        res := 0;
        POSTransLine.SetRange("Receipt No.", ReceiptNo);
        if POSTransLine.FindSet then
            repeat
                if (POSTransLine."Parent Transaction Doc. No." <> '') and
                  (POSTransLine."Entry Type" = POSTransLine."Entry Type"::IncomeExpense)
                then
                    res -= POSTransLine.Amount;
            until POSTransLine.Next = 0;
        exit(res);
    end;

    local procedure GetReceiptNoFromEmailPayLoad(PayLoad: Text): Code[20]
    begin
        exit(CopyStr(PayLoad, 18));
    end;

    local procedure GetEmailPayLoad(ReceiptNo: Code[20]): Text
    begin
        exit('#POSTTRANS-EMAIL' + ';' + ReceiptNo);
    end;

    procedure IsPostTransEmailInput(PayLoad: Text): Boolean
    begin
        exit(StrPos(PayLoad, '#POSTTRANS-EMAIL') > 0);
    end;

    procedure RequestDescriptionForSalesTypeOnTransStart(POSTransaction: Record "LSC POS Transaction"; PreventNormalSales: Boolean): Boolean
    var
        SalesType: Record "LSC Sales Type";
    begin
        if POSTransaction."Sales Type" = '' then
            exit(false);
        SalesType.Get(POSTransaction."Sales Type");

        if SalesType."Request Description" = SalesType."Request Description"::"At Start of Transaction" then
            if not PreventNormalSales then begin
                if POSTransaction."Requested Description" = '' then begin
                    if SalesType."Descr. Request Caption" <> '' then
                        POSGUI.OpenAlphabeticKeyboard(SalesType."Descr. Request Caption", '', false, '#TRANSSTART-DESCR', SalesType."Req. Description Max Length")
                    else
                        POSGUI.OpenAlphabeticKeyboard(CaptionDescription, '', false, '#TRANSSTART-DESCR', SalesType."Req. Description Max Length");
                    exit(true);
                end;
            end;
        exit(false);
    end;

    procedure ProcessDescriptionInputForSalesTypeOnTransStart(var POSTransaction: Record "LSC POS Transaction"; InputValue: Text; ResultOK: Boolean): Boolean
    begin
        if ResultOK then begin
            POSTransaction.get(POSTransaction."Receipt No.");
            POSTransaction."Requested Description" := InputValue;
            if POSTransaction.comment = '' then
                POSTransaction.Comment := POSTransaction."Requested Description";
            POSTransaction.Modify(true);
        end;
    end;

    local procedure RaiseVoidEvents(POSTransaction: Record "LSC POS Transaction")
    begin
        case POSTransPostingStateTmp."Posting Source" of
            POSTransPostingStateTmp."Posting Source"::"Zreport Suspend":
                POSTransactionEvents.OnAfterVoidTransaction(POSTransaction);
            POSTransPostingStateTmp."Posting Source"::"Void Pressed":
                begin
                    POSTransactionEvents.OnAfterVoidTransaction(POSTransaction);
                    POSTransactionEvents.OnAfterVoidPressedExecuted(POSTransaction);
                end;
        end;
    end;

    procedure ProcessTransactionForSuspensionByState(var POSTransaction: Record "LSC POS Transaction"; POSTransSuspensionState: Record "LSC POS Trans. Susp. State")
    begin
        POSTransSuspensionStateTmp."Receipt No." := POSTransaction."Receipt No.";
        POSTransSuspensionStateTmp := POSTransSuspensionState;
        if not POSTransSuspensionStateTmp.Insert() then
            POSTransSuspensionStateTmp.Modify();
        ProcessSuspensionByState(POSTransaction);
    end;

    local procedure ProcessSuspensionByState(var POSTransaction: Record "LSC POS Transaction")
    var
        ErrorText: Text[250];
        Cancel: Boolean;
    begin
        //SuspendPressed
        case POSTransSuspensionStateTmp."Suspension State" of
            POSTransSuspensionStateTmp."Suspension State"::"Initial Error Checking":
                begin
                    if SuspendStateCheckReturnsError() then
                        exit;
                    if SuspendPermissionCheckReturnsError then
                        exit;
                    if SuspendTrainingCheckReturnsError() then
                        exit;
                    if SuspendHospSalesTypeCheckReturnsError(POSTransaction) then
                        exit;
                    if ChargeAccountCheckReturnsError(POSTransaction, GetSuspendSalesTypeCode(POSTransaction)) then
                        exit;
                    GoToNextSuspensionState(POSTransaction);
                end;
            POSTransSuspensionStateTmp."Suspension State"::"Is Suspend or Retrieve":
                begin
                    if SuspendIsRetrieveSuspendedTrans(POSTransaction) then begin
                        CancelSuspension();
                        exit;
                    end;
                    GoToNextSuspensionState(POSTransaction);
                end;
            POSTransSuspensionStateTmp."Suspension State"::"Secondary Error Checking":
                begin
                    if SuspendCouponCheckReturnsError(POSTransaction) then begin
                        CancelSuspension();
                        exit;
                    end;
                    if SuspendPaymentCheckReturnsError(POSTransaction) then begin
                        CancelSuspension();
                        exit;
                    end;
                    POSTransactionEvents.OnProcessSuspensionByState_SecErrorChecking(POSTransaction, Cancel, ErrorText);
                    if Cancel then begin
                        ErrorBeep(ErrorText);
                        CancelSuspension();
                        exit;
                    end;

                    GoToNextSuspensionState(POSTransaction);
                end;
            POSTransSuspensionStateTmp."Suspension State"::"Confirm Suspend":
                begin
                    if SuspendNotConfirmed(POSTransaction) then begin
                        CancelSuspension();
                        exit;
                    end;

                    GoToNextSuspensionState(POSTransaction);
                end;
            POSTransSuspensionStateTmp."Suspension State"::"Limit Input":
                begin
                    if LimitInputNeeded(POSTransaction, GetSuspendSalesTypeCode(POSTransaction), POSTransSuspensionStateTmp.Balance, false) then
                        exit;
                    GoToNextSuspensionState(POSTransaction);
                end;
            POSTransSuspensionStateTmp."Suspension State"::"Balance Checking":
                begin
                    if BalanceCheckingReturnsError(
                         POSTransaction, GetSuspendSalesTypeCode(POSTransaction), POSTransSuspensionStateTmp.Balance,
                         POSTransSuspensionStateTmp."Gross Amount", POSTransSuspensionStateTmp."Line Discount", POSTransSuspensionStateTmp.Payment, POSTransSuspensionStateTmp."Order Limit", false)
                    then begin
                        CancelSuspension();
                        exit;
                    end;
                    GoToNextSuspensionState(POSTransaction);
                end;
            POSTransSuspensionStateTmp."Suspension State"::"Salesperson Input":
                begin
                    if SalesPersonInputNeeded(POSTransaction, GetSuspendSalesTypeCode(POSTransaction), POSTransSuspensionStateTmp."Sales Person") then
                        exit;
                    GoToNextSuspensionState(POSTransaction);
                end;
            POSTransSuspensionStateTmp."Suspension State"::"Description Input":
                begin
                    if DescriptionInputNeeded(
                         POSTransaction, GetSuspendSalesTypeCode(POSTransaction), POSTransSuspensionStateTmp."Requested Description",
                         POSTransSuspensionStateTmp."Prevent Normal Sale", false)
                    then
                        exit;
                    GoToNextSuspensionState(POSTransaction);
                end;
            POSTransSuspensionStateTmp."Suspension State"::Processing:
                begin
                    SuspendTransaction(POSTransaction);
                    POSTransSuspensionStateTmp.Delete();
                end;
        end;
    end;

    local procedure SuspendStateCheckReturnsError(): Boolean
    var
        ErrorSuspendState: Label 'Suspend not allowed in this state!';
    begin
        if POSTransSuspensionStateTmp.STATE = Format("LSC POS Transaction State"::TENDOP) then begin
            ErrorBeep(ErrorSuspendState);
            exit(true);
        end;
        exit(false);
    end;

    local procedure SuspendPermissionCheckReturnsError(): Boolean
    var
        MessageTxt: Text;
    begin
        if not POSSession.Permission(Enum::"LSC POS Command"::SUSPEND, MessageTxt) then begin
            ErrorBeep(MessageTxt);
            exit(true);
        end;
        exit(false);
    end;

    local procedure SuspendTrainingCheckReturnsError(): Boolean
    var
        ErrorSuspendInTraining: Label 'Suspend/Retrieve is not allowed in Training mode';
    begin
        if POSTransSuspensionStateTmp."Training Active" then begin
            ErrorBeep(ErrorSuspendInTraining);
            exit(true);
        end;
        exit(false);
    end;

    local procedure SuspendHospSalesTypeCheckReturnsError(POSTransaction: Record "LSC POS Transaction"): Boolean
    var
        HospitalityType: Record "LSC Hospitality Type";
        KDSFunctions: Codeunit "LSC KDS Functions";
        ReturnValue: Boolean;
        IsHandled: Boolean;
        ErrorServiceType: Label 'Suspend is not supported for %1.';
        ErrorItemsSentToKitchen: label 'Suspend is not supported when items in the transaction have been sent to kitchen.';
    begin
        POSTransactionEvents.OnBeforeSuspendHospSalesTypeCheckReturnsError(POSTransaction, IsHandled, ReturnValue);
        if IsHandled then
            exit(ReturnValue);

        if POSTransaction."Hosp. Type Sequence" <> 0 then begin
            if HospitalityType.get(POSTransaction."Store No.", POSTransaction."Hosp. Type Sequence", POSTransaction."Sales Type") then begin
                if HospitalityType."Service Type" = HospitalityType."Service Type"::"Dining Table Service" then begin
                    ErrorBeep(StrSubstNo(ErrorServiceType, format(HospitalityType."Service Type")));
                    exit(true);
                end;
                if HospitalityType."Service Type" = HospitalityType."Service Type"::"Delivery&Takeout in Call Center" then begin
                    ErrorBeep(StrSubstNo(ErrorServiceType, format(HospitalityType."Service Type")));
                    exit(true);
                end;
                if HospitalityType."Service Type" = HospitalityType."Service Type"::"Delivery&Takeout in Restaurant" then begin
                    ErrorBeep(StrSubstNo(ErrorServiceType, format(HospitalityType."Service Type")));
                    exit(true);
                end;
            end;
        end;

        if KDSFunctions.ItemsInTransSentToKitchen(POSTransaction) then begin
            ErrorBeep(ErrorItemsSentToKitchen);
            exit(true);
        end;

        exit(false);
    end;

    local procedure SuspendIsRetrieveSuspendedTrans(POSTransaction: Record "LSC POS Transaction"): Boolean
    var
        SalesType: Record "LSC Sales Type";
    begin
        if not POSTransaction."New Transaction" then
            exit(false);

        if POSTransSuspensionStateTmp."Suspension Sales Type" <> '' then
            SalesType.Get(POSTransSuspensionStateTmp."Suspension Sales Type")
        else
            SalesType.Init;
        if SalesType."Suspend Type" = 0 then
            POSTransactionGlob.RetSuspendedPressed(POSTransSuspensionStateTmp."Suspension Sales Type")
        else
            POSTransactionGlob.GetOrderPressed(POSTransSuspensionStateTmp."Suspension Sales Type");
        exit(true);
    end;

    local procedure SuspendCouponCheckReturnsError(POSTransaction: Record "LSC POS Transaction"): Boolean
    var
        POSTransLine: Record "LSC POS Trans. Line";
        ErrorSuspendWithCoupon: Label 'You cannot suspend transaction with coupon lines';
    begin
        POSTransLine.Reset;
        POSTransLine.SetRange("Receipt No.", POSTransaction."Receipt No.");
        POSTransLine.SetRange("Entry Type", POSTransLine."Entry Type"::Coupon);
        POSTransLine.SetRange("Entry Status", POSTransLine."Entry Status"::" ");
        if not POSTransLine.IsEmpty then begin
            ErrorBeep(ErrorSuspendWithCoupon);
            exit(true);
        end;
        exit(false);
    end;

    local procedure SuspendPaymentCheckReturnsError(POSTransaction: Record "LSC POS Transaction"): Boolean
    var
        POSTransLine: Record "LSC POS Trans. Line";
        SalesType: Record "LSC Sales Type";
        ErrorMustNotBeEmpty: Label '%1 must not be empty for %2 %3';
        ErrorSuspendWithPayment: Label 'You cannot suspend transaction with payment lines';
        ErrorSuspendWithSalesTypePayment: Label 'You cannot suspend transaction with %1 %2 with payment lines';
    begin
        GetSuspendSalesType(POSTransaction, SalesType);

        POSTransLine.Reset;
        POSTransLine.SetRange("Receipt No.", POSTransaction."Receipt No.");
        POSTransLine.SetRange("Entry Type", POSTransLine."Entry Type"::Payment);
        POSTransLine.SetRange("Entry Status", POSTransLine."Entry Status"::" ");
        if POSTransLine.FindFirst then begin
            if (SalesType.Code <> '') and (SalesType."Suspend Type" = SalesType."Suspend Type"::"POS Transaction") then begin
                if SalesType."Prepayment Account No." = '' then begin
                    ErrorBeep(StrSubstNo(ErrorMustNotBeEmpty, SalesType.FieldCaption("Prepayment Account No."), SalesType.TableCaption, SalesType.Code));
                    exit(true);
                end;
            end else begin
                if SalesType.Code = '' then
                    ErrorBeep(ErrorSuspendWithPayment)
                else
                    ErrorBeep(StrSubstNo(ErrorSuspendWithSalesTypePayment, SalesType.TableCaption, SalesType.Code));
                exit(true);
            end;
        end;
        exit(false);
    end;

    local procedure SuspendNotConfirmed(POSTransaction: Record "LSC POS Transaction"): Boolean
    var
        SalesType: Record "LSC Sales Type";
        IsHandled: Boolean;
        ConfirmSuspendSaveAsSalesType: Label 'Do you want to save the transaction as %1';
        ConfirmSuspend: Label 'Do you want to suspend the transaction?';
    begin
        GetSuspendSalesType(POSTransaction, SalesType);
        POSTransactionEvents.OnSuspendNotConfirmedBeforeConfirm(IsHandled);
        if IsHandled then
            exit(false);

        if SalesType."Request Confirmation" then begin
            if not POSGUI.PosConfirm(StrSubstNo(ConfirmSuspendSaveAsSalesType, SalesType.Code), false) then
                exit(true);
        end else
            if not POSGUI.PosConfirm(ConfirmSuspend, false) then
                exit(true);

        POSTransactionEvents.OnBeforeSuspend(POSTransaction);

        exit(false);
    end;

    procedure ProcessLimitInputOnSuspending(POSTransaction: Record "LSC POS Transaction"; ResultOK: Boolean; Value: Text)
    var
        OrderLimit: Decimal;
    begin
        POSTransSuspensionStateTmp.Get(POSTransaction."Receipt No.");

        if ResultOK then begin
            if (Evaluate(OrderLimit, Value)) and (OrderLimit > 0) then begin
                POSTransSuspensionStateTmp."Order Limit" := OrderLimit;
                POSTransSuspensionStateTmp.Modify();
                GoToNextSuspensionState(POSTransaction);
            end else
                LimitInputNeeded(POSTransaction, POSTransSuspensionStateTmp."Suspension Sales Type", POSTransSuspensionStateTmp.Balance, false);
        end else begin
            CancelSuspension();
            ErrorBeep(SuspensionCanceledText);
        end;
    end;

    local procedure StoreOrderLimitOnSuspending(ReceiptNo: Code[20]; OrderLimit: Decimal)
    begin
        POSTransSuspensionStateTmp.Get(ReceiptNo);
        POSTransSuspensionStateTmp."Order Limit" := OrderLimit;
        POSTransSuspensionStateTmp.Modify();
    end;

    procedure ProcessSalesPersonInputOnSuspending(POSTransaction: Record "LSC POS Transaction"; Value: Text)
    begin
        if POSTransactionGlob.ValidateSalesPerson then begin
            POSTransSuspensionStateTmp.Get(POSTransaction."Receipt No.");
            POSTransSuspensionStateTmp."Sales Person" := Value;
            POSTransSuspensionStateTmp.Modify();
            GoToNextSuspensionState(POSTransaction);
        end;
    end;

    procedure ProcessDescriptionInputOnSuspending(POSTransaction: Record "LSC POS Transaction"; ResultOK: Boolean; Value: Text): Boolean
    begin
        POSTransSuspensionStateTmp.Get(POSTransaction."Receipt No.");

        if ResultOK then begin
            if Value = '' then begin
                DescriptionInputNeeded(
                  POSTransaction, POSTransSuspensionStateTmp."Suspension Sales Type", POSTransSuspensionStateTmp."Requested Description", POSTransSuspensionStateTmp."Prevent Normal Sale", true);
                exit;
            end;
            POSTransSuspensionStateTmp."Requested Description" := Value;
            POSTransSuspensionStateTmp.Modify();
            GoToNextSuspensionState(POSTransaction);
        end else begin
            CancelSuspension();
            ErrorBeep(SuspensionCanceledText);
        end;
    end;

    local procedure SuspendTransaction(POSTransaction: Record "LSC POS Transaction")
    var
        SalesType: Record "LSC Sales Type";
    begin
        POSTransactionGlob.SetErrorCheck;
        GetSuspendSalesType(POSTransaction, SalesType);
        POSTransaction."Sales Type" := SalesType.Code;

        if POSTransSuspensionStateTmp."Order Limit" > 0 then
            POSTransaction."Order Limit" := POSTransSuspensionStateTmp."Order Limit";
        if POSTransSuspensionStateTmp."Sales Person" <> '' then
            POSTransaction."Sales Staff" := POSTransSuspensionStateTmp."Sales Person";
        if POSTransSuspensionStateTmp."Requested Description" <> '' then begin
            POSTransaction."Requested Description" := POSTransSuspensionStateTmp."Requested Description";
            if POSTransaction.comment = '' then
                POSTransaction.comment := POSTransaction."Requested Description";
        end;

        POSTransaction.Modify(true);
        Commit;

        POSTransactionGlob.SuspendTransaction(POSTransaction, SalesType);
    end;

    procedure GoToNextSuspensionState(POSTransaction: Record "LSC POS Transaction")
    begin
        POSTransSuspensionStateTmp.Get(POSTransSuspensionStateTmp."Receipt No.");
        POSTransSuspensionStateTmp."Suspension State" := POSTransSuspensionStateTmp."Suspension State" + 1;
        POSTransSuspensionStateTmp.Modify();
        ProcessSuspensionByState(POSTransaction);
    end;

    local procedure CancelSuspension()
    begin
        POSTransSuspensionStateTmp.Delete();
    end;

    local procedure GetSuspendSalesType(POSTransaction: Record "LSC POS Transaction"; var SalesType: Record "LSC Sales Type")
    var
        SalesTypeCode: Code[20];
    begin
        SalesTypeCode := GetSuspendSalesTypeCode(POSTransaction);
        if SalesTypeCode <> '' then
            SalesType.Get(SalesTypeCode)
        else
            SalesType.Init;
    end;

    local procedure GetSuspendSalesTypeCode(POSTransaction: Record "LSC POS Transaction"): code[20]
    var
        SalesTypeCode: Code[20];
    begin
        SalesTypeCode := POSTransSuspensionStateTmp."Suspension Sales Type";
        if SalesTypeCode = '' then
            SalesTypeCode := POSTransaction."Sales Type";
        exit(SalesTypeCode);
    end;

    local procedure NoInputPostingSource(): Boolean
    begin
        if POSTransPostingStateTmp."Posting Source" in [POSTransPostingStateTmp."Posting Source"::"Suspended Prepayment", POSTransPostingStateTmp."Posting Source"::"Zreport Suspend"] then
            exit(true);
        exit(false);
    end;

    local procedure DescriptionNeededOnPostingOrSuspend(SalesType: Record "LSC Sales Type"; OnPosting: Boolean): Boolean
    begin
        if OnPosting then begin
            if SalesType."Request Description" in [SalesType."Request Description"::"On Posting", SalesType."Request Description"::"On Suspend and Posting"] then
                exit(true);
            exit(false);
        end;
        if SalesType."Request Description" in [SalesType."Request Description"::"On Suspend", SalesType."Request Description"::"On Suspend and Posting"] then
            exit(true);
        exit(false);
    end;

    procedure ReOrderInsert(var PosTrLineTmp: Record "LSC POS Trans. Line" temporary; var lLineNo: Integer)
    var
        PosTrLine: Record "LSC POS Trans. Line";
        lParentLine: Integer;
        LastParent: Integer;
    begin
        PosTrLineTmp.Reset;
        PosTrLineTmp.SetCurrentKey("Receipt No.", "Parent Line");
        if PosTrLineTmp.FindSet then begin
            lParentLine := PosTrLineTmp."Parent Line";
            LastParent := lLineNo + 10000;
            repeat
                PosTrLine.TransferFields(PosTrLineTmp);
                lLineNo := lLineNo + 10000;
                PosTrLine."Line No." := lLineNo;
                if PosTrLineTmp."Parent Line" = lParentLine then
                    PosTrLine."Parent Line" := LastParent
                else begin
                    lParentLine := PosTrLineTmp."Parent Line";
                    if PosTrLineTmp."Parent Line" = PosTrLineTmp."Line No." then
                        LastParent := lLineNo
                    else
                        LastParent := lLineNo - 10000;
                    PosTrLine."Parent Line" := LastParent;
                end;
                PosTrLine."Round No." := PosTrLine."Round No." + 1;
                PosTrLine."Kitchen Routing" := PosTrLine."Kitchen Routing"::No;
                PosTrLine.Validate(Quantity);
                if PosTrLine."Disc. Info Line No." <> 0 then
                    PosTrLine."Disc. Info Line No." := LastParent;
                PosTrLine.InsertLine;
            until PosTrLineTmp.Next = 0;
        end;
    end;

    procedure CopyLinkedLines(var PosTrLineTmp: Record "LSC POS Trans. Line" temporary; CopyLineNo: Integer; QtyCopy: Decimal): Boolean
    var
        POSTransLine: Record "LSC POS Trans. Line";
        Infocode: Record "LSC Infocode";
        LinkedModifiers: Integer;
    begin
        PosTrLineTmp.CalcFields(PosTrLineTmp."Linked lines are Modifiers");
        LinkedModifiers := PosTrLineTmp."Linked lines are Modifiers";
        POSTransLine.SetCurrentKey("Receipt No.", "Parent Line");
        POSTransLine.SetRange("Receipt No.", PosTrLineTmp."Receipt No.");
        POSTransLine.SetRange("Parent Line", CopyLineNo);
        POSTransLine.SetFilter("Line No.", '<>%1', CopyLineNo);
        if POSTransLine.FindSet then
            repeat
                if (LinkedModifiers > 0) and (QtyCopy <> 1) then
                    if Infocode.Get(POSTransLine."Orig. from Infocode") then
                        if Infocode."Quantity Handling" <> Infocode."Quantity Handling"::"Multiply Items w/Qty." then
                            exit(false);
                PosTrLineTmp.TransferFields(POSTransLine, true);
                if QtyCopy <> 1 then
                    PosTrLineTmp.Quantity := QtyCopy;
                PosTrLineTmp.Insert;
                if not CopyLinkedLines(PosTrLineTmp, POSTransLine."Line No.", QtyCopy) then
                    exit(false);
            until POSTransLine.Next = 0;
        exit(true);
    end;

    procedure GetTransPostingState(ReceiptNo: code[20]; var POSTransPostingState: Record "LSC POS Trans. Posting State"): Boolean
    begin
        if POSTransPostingStateTmp.get(ReceiptNo) then begin
            POSTransPostingState."Posting State" := POSTransPostingStateTmp."Posting State";
            exit(true);
        end;
        exit(false);
    end;

    procedure GetTransSuspensionState(ReceiptNo: code[20]; var POSTransSuspensionState: Record "LSC POS Trans. Susp. State"): Boolean
    begin
        if POSTransSuspensionStateTmp.get(ReceiptNo) then begin
            POSTransSuspensionState."Suspension State" := POSTransSuspensionStateTmp."Suspension State";
            exit(True);
        end;
        exit(false);
    end;

    procedure PreventNegativeInventoryAutoStockUpdate(AutoStockUpdate: Boolean; Item: Record Item; SaleIsReturnSale: Boolean; NewLine: Record "LSC POS Trans. Line"): Boolean
    var
        Store: Record "LSC Store";
        PreventNegativeInventoryErr: Label 'Prevent Negative Inventory\Cannot sell Item: %1 - %2';
        ItemInventory: Decimal;
        Ishandled: Boolean;
    begin
        Store.Get(NewLine."Store No.");
        Item.SetRange("Location Filter", Store."Location Code");

        Ishandled := false;
        POSTransactionEvents.OnBeforeCalculateItemInventory(ItemInventory, Item, Ishandled);
        if not Ishandled then begin
            Item.CalcFields(Inventory);
            ItemInventory := Item.Inventory;
        end;

        if AutoStockUpdate and Item.PreventNegativeInventory() and (not NewLine."Customer Order Line") and (Item.Type = Item.Type::Inventory) and (not SaleIsReturnSale) then
            if ((ItemInventory - NewLine.Quantity) < 0) then begin
                ErrorBeep(StrSubstNo(PreventNegativeInventoryErr, Item.Description, Item."No."));
                exit(true);
            end;
        exit(false);
    end;

    procedure CheckPriceZeroIsValid(Price: Decimal; Item: Record Item): Boolean
    var
        ZeroPriceIsNotValidErr: Label 'Zero is not a valid price for Item %1.';
    begin
        if Price <> 0 then
            exit(true);

        if Item."LSC Zero Price Valid" then
            exit(true);

        ErrorBeep(StrSubstNo(ZeroPriceIsNotValidErr, Item.Description));
        exit(false);
    end;

    internal procedure HandleSalesPersonMode(var REC: Record "LSC POS Transaction"; PosFuncProfile: Record "LSC POS Func. Profile"; PosCommand: Enum "LSC POS Command")
    var
        Staff: Record "LSC Staff";
        IsHandled: Boolean;
    begin
        POSTransactionEvents.OnBeforeHandleSalesPersonMode(REC, PosFuncProfile, PosCommand, IsHandled);
        if IsHandled then
            exit;

        // if PosFuncProfile."Sales Person Mode" = PosFuncProfile."Sales Person Mode"::Automatic then begin
        //     if POSSESSION.StaffEmploymentType() = Staff."Employment Type"::Both then
        //         REC."Sales Staff" := POSSESSION.StaffID();
        //     // if REC."Sales Staff" = '' then
        //     //     POSTransactionGlob.SetFunctionMode("LSC POS Command"::SALESP)
        //     // else
        //     //     POSTransactionGlob.SetFunctionMode(PosCommand);
        // end else
        //     POSTransactionGlob.SetFunctionMode(PosCommand);
    end;

    internal procedure ExchangePressed(ExchangeParameter: Text; var REC: Record "LSC POS Transaction"; var ExchangeTransaction: Record "LSC Transaction Header"; var POSRefundMgt: Codeunit "LSC POS Refund Mgt."; var stateTxt: Code[30])
    var
        TransactionHeader: Record "LSC Transaction Header";
        RecRef: RecordRef;
        RecID: RecordID;
        POSCtrl: Codeunit "LSC POS Control Interface";
        ErrorCode: Code[10];
        ErrorText: Text;
        IsHandled: Boolean;
    begin
        POSTransactionEvents.OnBeforeExchangePressed(ExchangeParameter, REC, ExchangeTransaction, POSRefundMgt, stateTxt, IsHandled);
        if IsHandled then
            exit;

        if ExchangeParameter <> '' then begin
            ProcessExchange(REC, POSRefundMgt, stateTxt, ExchangeParameter);
            exit;
        end;

        if not POSSession.Permission(Enum::"LSC POS Command"::EXCHANGE, ErrorText) then begin
            ErrorBeep(ErrorText);
            exit;
        end;

        if not POSTransactionGlob.TestNewTransaction() then
            exit;

        if POSCtrl.GetActiveLookupID() = 'REGISTER' then
            if POSCtrl.GetActiveLookupRecordID(RecID) then begin
                RecRef.Get(RecID);
                RecRef.SetTable(TransactionHeader);
            end;

        POSRefundMgt.InitRefund(ExchangeTransaction, REC."Receipt No.");
        if not POSRefundMgt.RetrieveTransactionToRefundByReceipt(TransactionHeader."Receipt No.", ExchangeTransaction, ErrorCode, ErrorText) then begin
            ErrorBeep(ErrorText);
            exit;
        end;

        if ExchangeTransaction."Transaction No." <> 0 then begin
            // if not POSRefundMgt.ValidatePostedTransactionRefund(ExchangeTransaction, REC."Receipt No.", ErrorCode, ErrorText) then begin
            //     ErrorBeep(ErrorText);
            //     exit;
            // end;

            ExchangeLookUp(REC, POSRefundMgt, ExchangeTransaction);
        end;
    end;

    local procedure ExchangeLookUp(var REC: Record "LSC POS Transaction"; var POSRefundMgt: Codeunit "LSC POS Refund Mgt."; ExchangeTransaction: Record "LSC Transaction Header")
    var
        POSLookup: Record "LSC POS Lookup";
        PosFunctions: Codeunit "LSC POS Functions";
        IsHandled: Boolean;
    begin
        POSTransactionEvents.OnBeforeExchangeLookup(ExchangeTransaction, IsHandled);
        if IsHandled then
            exit;

        if POSSESSION.GetPosLookupRec('EXCHANGE', POSLookup) then
            if POSLookup."Lookup ID" <> '' then begin
                PosFunctions.PosTransDiscLoad(REC."Receipt No.");
                POSRefundMgt.InitRefund(ExchangeTransaction, REC."Receipt No.");
                // POSRefundMgt.PrepareTransToRefund();
                // POSRefundMgt.CreateRefundLookup(POSLookup, REC);
                PosFunctions.PosTransDiscFlush();
            end;
    end;

    local procedure ProcessExchange(var REC: Record "LSC POS Transaction"; var POSRefundMgt: Codeunit "LSC POS Refund Mgt."; var stateTxt: Code[30]; ExchangeParameter: Text)
    var
        POSCtrl: Codeunit "LSC POS Control Interface";
        IsHandled: Boolean;
        SelectLineMsg: Label 'Please select at least one line to Exchange or press Cancel.';
    begin
        POSTransactionEvents.OnBeforeExchangeProcessLookupResult(REC, POSRefundMgt, stateTxt, IsHandled);
        if IsHandled then
            exit;

        // if not POSRefundMgt.CreateLinesFromSelectionBuffer() then begin
        //     PosMessage(SelectLineMsg);
        //     exit;
        // end;

        POSTransactionGlob.ClearInput();
        POSTransactionGlob.ProcessRefundSelection('Dummy', true);
        ConvertToExchangeTransaction(REC, stateTxt);
        InsertSameLinesAsSales(REC, ExchangeParameter);

        POSCtrl.HidePanel('#LOOKUP', false); //Close transacion lines lookup
        POSCtrl.HidePanel('#LOOKUP', false); //Close transactions lookup
        POSTransactionGlob.CheckInfoCode('EXCHANGE');
    end;

    local procedure ConvertToExchangeTransaction(var REC: Record "LSC POS Transaction"; var stateTxt: Code[30])
    var
        POSTransLine: Record "LSC POS Trans. Line";
        POSLINES: Codeunit "LSC POS Trans. Lines";
        ExchangeState: Label 'EXCHANGE', Locked = true;
    begin
        POSTransLine.SetRange("Receipt No.", REC."Receipt No.");
        POSTransLine.SetRange("Entry Type", POSTransLine."Entry Type"::Item);
        if not POSTransLine.FindSet() then begin
            ErrorBeep(NoLinesErr);
            exit;
        end;

        StateTxt := ExchangeState;
        REC."Sale Is Return Sale" := false;
        REC."Sale Is Exchange Sale" := true;
        REC.Modify();

        POSSession.SetValue("LSC POS Tag"::"EXCHANGE_PRESSED_EX", '1');
        POSTransactionGlob.Gui.GetAndResetErrorMessageFlag();
        repeat
            POSTransLine."Exchange Line" := true;
            POSTransLine."System-Exclude from Offers" := true;
            POSTransLine.Modify();
            ReversePOSTransDisc(POSTransLine);
            POSLINES.SetCurrentLine(POSTransLine);
            POSTransactionGlob.ChangeQtyPressed('-' + format(POSTransLine.Quantity));
            if POSTransactionGlob.Gui.GetAndResetErrorMessageFlag() then begin
                POSSession.SetValue("LSC POS Tag"::"EXCHANGE_PRESSED_EX", '');
                exit;
            end;
            POSLINES.GetCurrentLine(POSTransLine);
        until POSTransLine.Next() = 0;
        POSSession.SetValue("LSC POS Tag"::"EXCHANGE_PRESSED_EX", '');
    end;

    internal procedure ReversePOSTransDisc(var POSTransLine: Record "LSC POS Trans. Line")
    var
        POSTransPerDisc: Record "LSC POS Trans. Per. Disc. Type";
        POSFunc: Codeunit "LSC POS Functions";
    begin
        POSTransPerDisc.Reset;
        POSTransPerDisc.SetRange("Receipt No.", POSTransLine."Receipt No.");
        POSTransPerDisc.SetRange("Line No.", POSTransLine."Line No.");
        POSTransPerDisc.SetRange("Entry Status", POSTransPerDisc."Entry Status"::" ");
        POSFunc.PosTransDiscSetTableFilter(1, POSTransPerDisc);
        if POSFunc.PosTransDiscFindRec(1, '-', POSTransPerDisc) then
            repeat
                POSTransPerDisc."Discount Amount" := -POSTransPerDisc."Discount Amount";
                POSFunc.PosTransDiscUpdateRec(POSTransPerDisc);
            until POSFunc.PosTransDiscNextRec(1, 1, POSTransPerDisc) = 0;
    end;

    local procedure InsertSameLinesAsSales(var REC: Record "LSC POS Transaction"; ExchangeParameter: Text)
    var
        POSTransLine: Record "LSC POS Trans. Line";
        NewPOSTransLine: Record "LSC POS Trans. Line";
        POSTransLines: Codeunit "LSC POS Trans. Lines";
        CurrInput: Text;
    begin
        if ExchangeParameter <> 'SAME' then
            exit;

        POSTransLine.SetRange("Receipt No.", REC."Receipt No.");
        POSTransLine.SetRange("Entry Type", POSTransLine."Entry Type"::Item);
        POSTransLine.SetFilter(Quantity, '<%1', 0);
        if not POSTransLine.FindSet() then begin
            ErrorBeep(NoLinesErr);
            exit;
        end;

        repeat
            CurrInput := format(POSTransLine.Number);
            POSTransactionGlob.SetCurrInput(CurrInput);
            POSTransactionGlob.ItemLine(false, false, Abs(POSTransLine.Quantity), POSTransLine."Line No.", POSTransLine."Variant Code", POSTransLine."Orig Per. Disc. Group", '', '', 0, 0);
            POSTransLines.GetCurrentLine(NewPOSTransLine);
            NewPOSTransLine."Indent No." := POSTransLine."Indent No." + 1;
            NewPOSTransLine.Modify();
            if (NewPOSTransLine."Discount %" = 0) and (POSTransLine."Discount %" > 0) then
                POSTransactionGlob.DiscPrPressedEx(POSTransLine."Discount %");
        until POSTransLine.Next() = 0;
    end;

    internal procedure VoidExchangeTransaction(var REC: Record "LSC POS Transaction"; var stateTxt: Code[30]; LineRec: Record "LSC POS Trans. Line")
    var
        TransactionHeader: Record "LSC Transaction Header";
    begin
        if not REC."Sale Is Exchange Sale" then
            exit;

        if REC."Retrieved from Receipt No." = '' then
            exit;

        if LineRec."Orig. Trans. No." = 0 then
            exit;

        stateTxt := '';

        TransactionHeader.SetRange("Receipt No.", REC."Retrieved from Receipt No.");
        TransactionHeader.FindFirst();
        TransactionHeader."Refund Receipt No." := '';
        TransactionHeader.Modify(true);

        REC."Sale Is Exchange Sale" := false;
        REC."Retrieved from Receipt No." := '';
        REC.Modify();
    end;

    internal procedure TotalCheckExchangeTransaction(var REC: Record "LSC POS Transaction"): Boolean
    var
        POSTransactionline: Record "LSC POS Trans. Line";
        IsHandled, ReturnValue : Boolean;
        ExchangeTransLineMissingErr: Label 'This is an Exchange transaction, an exchange Item is required.';
        ReturnTransLineMissingErr: Label 'This is an Exchange transaction, a return Item is required.';
    begin
        POSTransactionEvents.OnBeforeTotalCheckExchangeTransaction(REC, IsHandled, ReturnValue);
        if IsHandled then
            exit(ReturnValue);

        if not REC."Sale Is Exchange Sale" then
            exit(true);

        if REC."Retrieved from Receipt No." = '' then
            exit(true);

        POSTransactionline.SetRange("Receipt No.", REC."Receipt No.");
        POSTransactionline.SetRange("Entry Type", POSTransactionline."Entry Type"::Item);
        POSTransactionline.SetFilter("Entry Status", '<>%1', POSTransactionline."Entry Status"::Voided);

        POSTransactionline.SetFilter(Quantity, '>0');
        if POSTransactionline.IsEmpty() then begin
            ErrorBeep(ExchangeTransLineMissingErr);
            exit(false);
        end;

        POSTransactionline.SetFilter(Quantity, '<0');
        if POSTransactionline.IsEmpty() then begin
            ErrorBeep(ReturnTransLineMissingErr);
            exit(false);
        end;

        exit(true);
    end;

    internal procedure ExtraPrintRequired(TransactionHeader: Record "LSC Transaction Header"): Boolean
    var
        TransInfocodeEntry: Record "LSC Trans. Infocode Entry";
        CouponEntry: Record "LSC Coupon Entry";
        ReturnValue: Boolean;
        IsHandled: Boolean;
    begin
        POSTransactionEvents.OnBeforeExtraPrintRequired(ReturnValue, IsHandled);
        if IsHandled then
            exit(ReturnValue);

        TransInfocodeEntry.SetRange("Store No.", TransactionHeader."Store No.");
        TransInfocodeEntry.SetRange("Transaction No.", TransactionHeader."Transaction No.");
        TransInfocodeEntry.SetRange("POS Terminal No.", TransactionHeader."POS Terminal No.");
        TransInfocodeEntry.SetRange("Type of Input", TransInfocodeEntry."Type of Input"::"Create Data Entry");
        if TransInfocodeEntry.FindFirst() then
            exit(true);
        CouponEntry.SetRange("Store No.", TransactionHeader."Store No.");
        CouponEntry.SetRange("Transaction No.", TransactionHeader."Transaction No.");
        CouponEntry.SetRange("POS Terminal No.", TransactionHeader."POS Terminal No.");
        CouponEntry.SetRange("Coupon Function", CouponEntry."Coupon Function"::Issue);
        if CouponEntry.FindFirst() then
            exit(true);
        if TransactionHeader."Sale Is Return Sale" then
            exit(true);
        exit(false);
    end;

    internal procedure Process_T_Transaction(var CurrInput: Text; var NewLine: Record "LSC POS Trans. Line"; POSFuncProfile: Record "LSC POS Func. Profile"; Selection: Text)
    var
        RcptScannerBehaviour: Enum "LSC Receipt Scanner Behaviour";
    begin
        if Selection <> '' then begin
            Evaluate(RcptScannerBehaviour, Selection);
            POSFuncProfile."Receipt Scanner Behaviour" := RcptScannerBehaviour;
        end else
            if POSFuncProfile.IsEmpty() then begin
                POSTransactionGlob.VoidPostedTransaction();
                exit;
            end;

        case POSFuncProfile."Receipt Scanner Behaviour" of
            RcptScannerBehaviour::RETURN:
                POSTransactionGlob.VoidPostedTransaction();

            RcptScannerBehaviour::VOID_TR:
                LookupTransactionListPanelFiltered(CurrINput, NewLine, POSFuncProfile);

            RcptScannerBehaviour::ASK:
                ChooseBeahviour();
        end;
    end;

    procedure SearchMemberContact()
    var
        POSMemberContactSearch: Codeunit "LSC POS Member Contact Search";
    begin
        POSMemberContactSearch.SearchMemberContact();
    end;

    internal procedure LookupTransactionListPanelFiltered(var CurrInput: Text; var NewLine: Record "LSC POS Trans. Line"; POSFuncProfile: Record "LSC POS Func. Profile")
    var
        POSLookup: Record "LSC POS Lookup";
        TransactionHeader: Record "LSC Transaction Header";
        TransactionHeaderTemp: Record "LSC Transaction Header" temporary;
        NewLineTemp: Record "LSC POS Trans. Line" temporary;
        LookupRecRef: RecordRef;
        FilterString: Text;
    begin
        if not POSSESSION.GetPosLookupRec('REGISTER', PosLookup) then
            exit;

        if not RetrieveTransactionToRefundByReceipt(CurrInput, POSFuncProfile, TransactionHeader) then
            exit;

        NewLineTemp := NewLine;

        if TransactionHeader.Count > 1 then begin
            if TransactionHeader.FindSet() then
                repeat
                    TransactionHeaderTemp := TransactionHeader;
                    TransactionHeaderTemp.Insert();
                until TransactionHeader.Next() = 0;
            TransactionHeader.Reset();
            LookupRecRef.GetTable(TransactionHeaderTemp);
            EPOSControlInterface.HidePanel('#LOOKUP', false);
        end else
            BuildLookupDataFilterString(TransactionHeader, FilterString);

        CommitIfTSorDD(POSFuncProfile);
        RunPOSLookup(FilterString, PosLookup."Lookup ID", LookupRecRef, POSLookup, NewLineTemp);
    end;

    internal procedure RetrieveTransactionToRefundByReceipt(CurrInput: Text; POSFuncProfile: Record "LSC POS Func. Profile"; var TransactionHeader: Record "LSC Transaction Header"): Boolean
    var
        RefundMgt: Codeunit "LSC POS Refund Mgt.";
        ErrorCode: Code[10];
        ErrorText: Text;
    begin
        // RefundMgt.SetPOSFuncProfile(POSFuncProfile);
        if RefundMgt.RetrieveTransactionToRefundByReceipt(CurrInput, TransactionHeader, ErrorCode, ErrorText) then
            exit(true);

        ErrorBeep(ErrorText);
    end;

    internal procedure BuildLookupDataFilterString(TransactionHeader: Record "LSC Transaction Header"; var FilterString: Text)
    var
        FilterStringTB: TextBuilder;
    begin
        FilterStringTB.Append('§');
        FilterStringTB.Append(TransactionHeader."Store No.");
        FilterStringTB.Append('§');
        FilterStringTB.Append(TransactionHeader."POS Terminal No.");
        FilterStringTB.Append('§');
        FilterStringTB.Append(format(TransactionHeader."Transaction No."));
        FilterStringTB.Append('§');

        FilterString := FilterStringTB.ToText();
    end;

    internal procedure CommitIfTSorDD(POSFuncProfile: Record "LSC POS Func. Profile")
    begin
        //If we triggered the web service call we may have created new records in the database
        //we need to commit to be able to run the POSGUI.Lookup which has a codeunit.run
        if PosFuncProfile."TS Void Transactions" or PosFuncProfile."DD Void Transactions" then
            Commit();
    end;

    internal procedure RunPOSLookup(FilterString: Text; LookupID: Code[20]; LookupRecRef: RecordRef; var POSLookup: Record "LSC POS Lookup"; var NewLineTemp: Record "LSC POS Trans. Line" temporary)
    var
        POSCtrl: Codeunit "LSC POS Control Interface";
    begin
        POSGUI.Lookup(PosLookup, '[EXECUTE]', NewLineTemp, POSSESSION.MgrKey(), '', LookupRecRef);
#pragma warning disable AL0432
        // POSCtrl.OnLookupDataRequest(PosCtrl.ActiveDataGrid(), LookupID, 0, 0, 0, 0, false, FilterString);
#pragma warning restore AL0432
    end;

    local procedure ChooseBeahviour()
    var
        MenuLine: Record "LSC POS Menu Line";
        PopupPOSComm: Codeunit "LSC Pop-up POS Commands";
    begin
        MenuLine.Command := format(Enum::"LSC POS Command"::POPUP_SCANNER_BEHAVI);
        PopupPOSComm.Run(MenuLine);
    end;

    internal procedure SalePressedInPaymentState(STATE: Enum "LSC POS Transaction State"): Boolean
    var
        ErrorStatePayment: label 'POS is in %1 state. Press Cancel to switch to %2 state.';
    begin
        if STATE = STATE::PAYMENT then begin
            ErrorBeep(StrSubstNo(ErrorStatePayment, STATE::PAYMENT, STATE::SALES));
            exit(true);
        end;
        exit(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC Background Mgt", OnBeforeStopAllBackgroundSession, '', false, false)]
    local procedure OnBeforeStopAllBackgroundSession()
    var
        POSTransaction: Record "LSC POS Transaction";
        SalesType: Record "LSC Sales Type";
        SlipNo: Code[20];
    begin
        SlipNo := POSSession.GetValue("LSC POS Tag"::"RetrievedSlipNo");

        if SlipNo <> '' then begin
            if POSTransaction.Get(SlipNo) then begin
                if POSTransaction."Sales Type" <> '' then
                    if SalesType.Get(POSTransaction."Sales Type") then;
                if POSTransaction."Retrieved from Suspended Trans" then
                    POSTransactionGlob.SuspendTransaction(POSTransaction, SalesType);
            end;
        end;
    end;
}
