codeunit 60007 "OPT POS Transaction EFT"
{
    //Access = Internal;

    var
        EFTUtil: Interface "LSC IEFTUtility";
        EFTUtil2: Interface "LSC IEFTUtility2";
        TokenUtil: Interface "LSC IToken Utility";
        ReferencedReturnsUtil: Interface "LSC IReferenced Returns";
        EFTTipsAmount: Decimal;
        CardOffline: Boolean;
        CardPhase: Integer;
        POSSESSION: Codeunit "LSC POS Session";
        PosTransactionGUI: Codeunit "OPTs POS Transaction GUI";
        VoidCardConfirm: Codeunit "OPT POS Void Card Functions";
        POSTransactionEvents: Codeunit "OPT POS Transaction Events";
        gTokenSelection: Text;
        gTempToken: Record "LSC Token" temporary;
        EFTUtil2OPT: Interface "OPT IEFTUtility2";


    procedure RunCommand(PosCommand: Enum "LSC POS COmmand"; var MenuLine: Record "LSC POS Menu Line"; var REC: Record "LSC POS Transaction"; var LineRec: Record "LSC POS Trans. Line";
                     var CurrInput: Text; TrainingActive: Boolean; PrinterActive: Boolean; var Error: Boolean; var ErrorReason: Text) Handled: Boolean
    begin
        Handled := true;
        Error := false;
        case PosCommand of
            PosCommand::EFT_LAST_TRANS:
                Error := EFTShowLastTrans(ErrorReason);
            PosCommand::EFT_PRINT_LAST_TRANS:
                if PrinterActive then
                    Error := EFTPrintLastTrans(REC, ErrorReason);
            PosCommand::EFT_GET_ZREPORT:
                Error := EFTGetZReport(REC, PrinterActive, TrainingActive, ErrorReason);
            PosCommand::EFT_GET_XREPORT:
                Error := EFTGetXReport(REC, PrinterActive, ErrorReason);
            PosCommand::EFT_START_SESSION:
                Error := EFTStartSession(MenuLine.Parameter, ErrorReason);
            PosCommand::EFT_FINISH_SESSION:
                Error := EFTFinishSession(MenuLine.Parameter, ErrorReason);
            else
                Handled := false;
        end;
    end;

    procedure Init()
    begin
        POSSESSION.GetEFTUtility(EFTUtil);
        POSSESSION.GetEFTUtility2(EFTUtil2);
        POSSESSION.GetEFTTokenUtility(TokenUtil);
        POSSESSION.GetReferencedReturnsUtility(ReferencedReturnsUtil);
    end;

    procedure InitEFTServer()
    begin
        if POSSESSION.EFTActive then
            EFTUtil.InitEFTServer();
    end;

    procedure CloseEFTServer()
    begin
        IF POSSESSION.EFTActive then
            EFTUtil.CloseEFTServer();
    end;

    procedure SetTokenSelectionValue(TokenSelection: Text)
    begin
        gTokenSelection := TokenSelection;
    end;

    local procedure TokenHasAlreadyBeenSelected(): Boolean
    begin
        //The Token has not been selected through lookup
        if gTokenSelection = '' then
            exit(false);

        gTempToken.SetFilter("Token ID", gTokenSelection);
        if gTempToken.IsEmpty() then
            exit(false);

        gTempToken.FindFirst();
        TokenUtil.SetTokenData(gTempToken);
        gTokenSelection := '';
        exit(true);
    end;

    local procedure GetReferencedReturnCardEntry(Transaction: Record "LSC POS Transaction"; var ReferencedCardEntry: Record "LSC POS Card Entry"): Boolean;
    begin
        ReferencedCardEntry.SetCurrentKey("Store No.", "POS Terminal No.", "Transaction No.", "Line No.");
        ReferencedCardEntry.SetRange("Store No.", Transaction."Retrieved from Store No.");
        ReferencedCardEntry.SetRange("POS Terminal No.", Transaction."Retrieved from POS Term. No.");
        ReferencedCardEntry.SetRange("Transaction No.", Transaction."Retrieved from Trans. No.");

        if ReferencedCardEntry.IsEmpty() then
            exit(false);

        exit(ReferencedCardEntry.FindLast());
    end;

    procedure ValidateCard(var REC: Record "LSC POS Transaction";
        var LineRec: Record "LSC POS Trans. Line";
        var CardEntry: Record "LSC POS Card Entry";
        TransType: Option Sale,Preauth,"Update-Preauth","Finalize-Preauth","AddCardToFile";
        TenderType: Code[10];
        var PaymentAmount: Decimal;
        var Balance: Decimal;
        var CurrInput: Text;
        ReadFromMSR: Boolean;
        var Message: Text;
        var Error: Text;
        var UsePaymentToken: Boolean;
        QRCodePayment: Boolean): Boolean
    var
        ReferencedReturnsCardEntry: Record "LSC POS Card Entry";
        EmptyRecordId: RecordId;
        Sign: Decimal;
        ProcessOfflineCardAuthQst: Label 'Process offline card authorisation?';
        OfflineCardAuth: Label 'Offline card authorisation';
    begin
        POSTransactionEvents.OnBeforeValidateCard(REC, LineRec, CurrInput, TenderType);

        EFTUtil.ClearEFT;
        TokenUtil.ClearTokenData();
        EFTUtil.SetTenderType(TenderType);

        if TokenHasAlreadyBeenSelected() then
            UsePaymentToken := false;

        if UsePaymentToken then begin
            UsePaymentToken := false; //Make sure the payment token functionality is not used again unless CardOnFile operation is selected again
            if not (GetPaymentTokenFromStorage(TransTypeToPosCommand(TransType), Enum::"LSC Token Type"::Purchase, enum::"LSC Token Contract Type"::"Card on File", EmptyRecordId, REC, POSSESSION.FunctionalityProfileID(), EFTUtil)) then
                exit;
        end;

        if not ReadFromMSR then begin
            if CurrInput = '99' then begin
                if PosTransactionGUI.ShowPosConfirm(REC, ProcessOfflineCardAuthQst, true) then begin
                    Message := OfflineCardAuth;
                    CardOffline := true;
                end;
                CurrInput := '';
                exit(true);
            end;
            if QRCodePayment then
                EFTUtil.SetQRCode(CurrInput)
            else
                EFTUtil.SetCardNo(CurrInput);
        end else
            EFTUtil.SetTrack2(CurrInput);

        if REC."Sale Is Return Sale" then
            Sign := -1
        else
            Sign := 1;
        if PaymentAmount * Sign < 0 then begin
            EFTUtil.SetTransType(CardEntry."Transaction Type"::Refund);
            EFTUtil.SetAmount(Abs(PaymentAmount));
            EFTUtil.SetVAT(Abs(CalcVatOfPayment(REC, PaymentAmount)));
            EFTUtil.SetTip(0);
            EFTUtil.SetCashback(0);
            EFTUtil.SetCurrencyCode(POSSESSION.ActiveCurrencyCode());
            if GetReferencedReturnCardEntry(REC, ReferencedReturnsCardEntry) then
                ReferencedReturnsUtil.SetReferencedReturns(ReferencedReturnsCardEntry);
            CardOffline := false;
        end
        else begin
            case TransType of
                1, 4:
                    begin
                        if (TransType = 1) then
                            EFTUtil.SetTransType(CardEntry."Transaction Type"::PreAuth)
                        else begin
                            EFTUtil.SetTransType(CardEntry."Transaction Type"::AddCardToFile);
                            TokenUtil.SetTokenData(GetTokenValuesForCreateToken(REC));
                        end;
                        EFTUtil.SetAmount(Abs(PaymentAmount));
                        EFTUtil.SetVAT(Abs(CalcVatOfPayment(REC, PaymentAmount)));
                        EFTUtil.SetCashback(0);
                        EFTUtil.SetCurrencyCode(POSSESSION.ActiveCurrencyCode());
                    end;
                2:
                    begin
                        if not EFTUtil.UpdatePreAuth(CardEntry, PaymentAmount, Error) then begin
                            exit(false);
                        end;
                    end;
                3:
                    begin
                        if PaymentAmount > Balance then begin
                            PaymentAmount := Balance; //Automatically lower amount to Balance if higer.
                        end;

                        if PaymentAmount >= Balance then
                            if not UnprocessedPreAuthCheck(REC, 1) then
                                exit;

                        if not EFTUtil.FinalizePreAuth(CardEntry, PaymentAmount, Error) then begin
                            exit(false);
                        end;
                    end;
                0:
                    begin
                        EFTUtil.SetTransType(CardEntry."Transaction Type"::Sale);
                        EFTUtil.SetAmount(Abs(PaymentAmount));
                        EFTUtil.SetTip(EFTTipsAmount);
                        EFTUtil.SetVAT(Abs(CalcVatOfPayment(REC, PaymentAmount)));
                        EFTUtil.SetCashback(0);
                        EFTUtil.SetCurrencyCode(POSSESSION.ActiveCurrencyCode());

                        if (PaymentAmount * Sign >= 0) and (Abs(PaymentAmount) > Abs(Balance)) then
                            EFTUtil.SetCashback(Abs(PaymentAmount) - Abs(Balance));
                    end;
            end;
        end;
        exit(true);
    end;

    procedure UnprocessedPreAuthCheck(var REC: Record "LSC POS Transaction"; expectedPreAuths: Integer): Boolean
    var
        PreAuthUnprocessed: Label 'There are open Pre-Auths in this transaction.\Would you still like to continue with this payment.';
    begin
        if UnprocessedPreAuth(REC) > expectedPreAuths then
            if not Confirm(PreAuthUnprocessed) then
                exit(false);
        exit(true);
    end;

    procedure NextCardPhase(): Enum "LSC POS Command"
    begin
        if CardPhase = 0 then begin
            CardPhase := CardPhase + 1;
            if EFTUtil.IsComboCard then begin
                exit("LSC POS Command"::CARDTYPE);
            end;
        end;
        if CardPhase = 1 then
            CardPhase := CardPhase + 1;

        if CardPhase = 2 then begin
            CardPhase := CardPhase + 1;
            if CardOffline then begin
                exit("LSC POS Command"::CONTROL);
            end;
        end;
        if CardPhase = 3 then begin
            CardPhase := CardPhase + 1;
            if EFTUtil.IsPasswordRequired(POSSESSION.MgrKey) then begin
                exit("LSC POS Command"::PASSWORD);
            end;
        end;
        exit("LSC POS Command"::" ");
    end;

    procedure SeekAuthorisation(var REC: Record "LSC POS Transaction"; var ReturnMessage: Text) CardEntryNo: Integer
    var
        PosTerminal: Record "LSC POS Terminal";
        IsHandled: Boolean;
    begin
        PosTerminal.Get(POSSESSION.TerminalNo);
        CardEntryNo := EFTUtil.InitLogEntry(REC."Receipt No.");

        POSTransactionEvents.OnBeforeSeekAuthorisation(REC, CardEntryNo, IsHandled);
        if IsHandled then
            exit;

        EFTUtil.SeekAuth;

        while EFTUtil.PollStatus(ReturnMessage) do begin
            Sleep(50);
        end;

        CardEntryNo := EFTUtil.InsertLogEntry();
        SendPaymentTokenToStorage(CardEntryNo, Enum::"LSC Token Type"::Purchase, Enum::"LSC Token Contract Type"::"Card on File", PosTerminal, REC, POSSESSION.FunctionalityProfileID(), EFTUtil, ReturnMessage);
    end;

    procedure CalcVatOfPayment(var REC: Record "LSC POS Transaction"; CalcAmount: Decimal): Decimal
    var
        VatPr: Decimal;
    begin
        if REC."Gross Amount" = CalcAmount then
            exit(REC."Gross Amount" - REC."Net Amount");
        if REC."Net Amount" <> 0 then
            VatPr := ((REC."Gross Amount" / REC."Net Amount") - 1) * 100
        else
            VatPr := 0;
        exit(Round(CalcAmount - (CalcAmount / (1 + VatPr / 100))));
    end;

    procedure AdjustCardAmountForTips(var REC: Record "LSC POS Transaction"; var pPaymentAmount: Decimal; var pBalance: Decimal)
    var
        EFTAskToIncludeTips: Label 'Include Tips amount of %1 in Card Transaction?';
    begin
        REC.CalcFields("Tips Amount");
        EFTTipsAmount := REC."Tips Amount";

        if EFTTipsAmount = 0 then
            exit;

        if EFTUtil.AllwaysIncludeTips then
            exit;

        if EFTUtil.AskToIncludeTips then
            if PosTransactionGUI.ShowPosConfirm(REC, StrSubstNo(EFTAskToIncludeTips, EFTTipsAmount), false) then
                exit;

        pPaymentAmount -= REC."Tips Amount";
        pBalance -= REC."Tips Amount";
        EFTTipsAmount := 0;
    end;


    procedure UnprocessedPreAuth(var REC: Record "LSC POS Transaction") cnt: Integer
    var
        lLineRec: Record "LSC POS Trans. Line";
        lCardEntry: Record "LSC POS Card Entry";
    begin
        lLineRec.SetRange("Receipt No.", REC."Receipt No.");
        lLineRec.SetRange(lLineRec."Entry Status", 0);
        lLineRec.SetRange(lLineRec."Entry Type", lLineRec."Entry Type"::FreeText);
        lLineRec.SetRange(lLineRec."Text Type", lLineRec."Text Type"::"Pre-Auth Text");

        if lLineRec.FindSet then
            repeat
                if lCardEntry.Get(lLineRec."Store No.", lLineRec."POS Terminal No.", lLineRec."Card Entry No.") then
                    if (lCardEntry."Transaction Type" in [lCardEntry."Transaction Type"::PreAuth, lCardEntry."Transaction Type"::UpdatePreAuth]) AND
                        not lCardEntry.Voided then
                        cnt += 1;
            until lLineRec.Next = 0;
    end;

    procedure UseNumpad(): Boolean
    begin
        exit(EFTUtil.UseNumpad);
    end;

    procedure GetCardType(): Code[10]
    begin
        exit(EFTUtil.GetCardType());
    end;

    procedure GetCardTypeName(): Text[30]
    begin
        exit(EFTUtil.GetCardTypeName());
    end;

    procedure IsExpiryDateRequired(): Boolean
    begin
        exit(EFTUtil.IsExpiryDateRequired());
    end;

    procedure SetCardPhase(pPhase: Integer)
    begin
        CardPhase := pPhase;
    end;

    procedure SetComboCard(Credit: Boolean)
    begin
        EFTUtil.SetComboCard(Credit);
    end;

    procedure SetCardOffline(Offline: Boolean)
    begin
        CardOffline := Offline;
    end;

    procedure SetPassword(password: Text)
    begin
        EFTUtil.SetPassword(password);
    end;

    procedure SetExpiryDate(ExDate: Text)
    begin
        EFTUtil.SetExpiryDate(ExDate);
    end;

    procedure GetResult(): Integer
    begin
        exit(EFTUtil.GetResult());
    end;

    procedure GetAmount(): Decimal
    begin
        exit(EFTUtil.GetAmount());
    end;

    procedure ProcessTipAndServiceCharge(var REC: Record "LSC POS Transaction")
    begin
        EFTUtil.ProcessTipAmount(REC."Receipt No.", 5);
        EFTUtil.ProcessServiceChargeAmount(REC."Receipt No.", 8);
    end;

    procedure PreAuthUpdateCount(var pCardEntry: Record "LSC POS Card Entry"): Integer
    begin
        exit(EFTUtil.PreAuthUpdateCount(pCardEntry));
    end;

    procedure CardSlipsPrintingConfirmed(var REC: Record "LSC POS Transaction"): Boolean
    var
        PosTerminal: Record "LSC POS Terminal";
        SessionKeyValues: Codeunit "LSC Session Key Values";
        IsHandled: Boolean;
        ContinueWithCardSlipPrinting: Boolean;
    begin
        POSTransactionEvents.OnBeforeCardSlipsPrintingConfirmed(REC, (SessionKeyValues.GetValue('PRINTCONFRMED') = 'true'), ContinueWithCardSlipPrinting, IsHandled);
        if IsHandled then
            exit(ContinueWithCardSlipPrinting);

        PosTerminal.Get(POSSESSION.TerminalNo);

        if PosTerminal."Sales Slip" <> PosTerminal."Sales Slip"::"Print on Confirmation" then
            exit(true);

        //If the cashier has confirmed that the card slips should not be printed
        //they need to be purged so that they are not printed next time the cashier selects yes
        if SessionKeyValues.GetValue('PRINTCONFRMED') <> 'true' then begin
            EFTUtil.PrintEFTPurge('');
            exit(false);
        end;

        exit(true);
    end;

    procedure PrintCardSlips(var REC: Record "LSC POS Transaction"; cardSlipNo: Text)
    var
        PrintUtil: Codeunit "LSC POS Print Utility";
        Retry: Boolean;
        Ok: Boolean;
        RetryPrinting: Label '%1\Retry printing?';
    begin
        if not POSSESSION.EFTActive() then
            exit;

        if not POSSESSION.PrinterActive() then
            exit;

        if not CardSlipsPrintingConfirmed(REC) then
            exit;

        if EFTUtil.PrintEFTPending('') then
            repeat
                Retry := false;
                PrintUtil.Init();
                Ok := PrintUtil.PrintCardSlipFromEFT('', cardSlipNo);
                if not Ok then begin
                    if PosTransactionGUI.ShowPosConfirm(REC, StrSubstNo(RetryPrinting, PrintUtil.GetPrintErrorTxt), true) then
                        Retry := true
                    else
                        Message(PrintUtil.GetPrintErrorTxt);
                end
            until not Retry;
        EFTUtil.PrintEFTPurge('');
    end;

    procedure ValidateControl(CurrInput: Text; var ErrorReason: Text): Boolean
    var
        CodeRequiresSixDigits: Label 'Code must not excede 6 digits';
        lCardEntry: Record "LSC POS Card Entry";
    begin
        ErrorReason := '';
        if StrLen(CurrInput) > 6 then begin
            ErrorReason := CodeRequiresSixDigits;
            exit(false);
        end;
        EFTUtil.SetAuthCode(CurrInput);
        EFTUtil.SetTransType(lCardEntry."Transaction Type"::Offline);
        CardPhase := 3;
        exit(true);
    end;

    procedure DisableVoidCardPrompt(): Boolean
    begin
        exit(EFTUtil2.DisableVoidCardPrompt());
    end;

    procedure TestVoidCardEntry(var REC: Record "LSC POS Transaction"; var OrgCardEntry: Record "LSC POS Card Entry"): Boolean
    var
        PosFunc: Codeunit "LSC POS Functions";
        VoidEntryForCardMsg: Label 'Void entry for card no. ';
        VoidPrePaymQst: Label 'Do you want to void the payment?';
        posTerminal: record "LSC POS Terminal";
    begin



        POSSESSION.GetEFTUtility(EFTUtil);


        if not EFTUtil.TestVoidCardEntry(OrgCardEntry) then
            exit(false);

        if not PosTransactionGUI.ShowPosConfirm(REC, VoidEntryForCardMsg + PosFunc.AstrxPad(OrgCardEntry.GetCardNo) + '\ ' + VoidPrePaymQst, false) then
            exit(false);

        exit(true);
    end;

    procedure PostTransactionAfterVoid(): Boolean
    begin
        exit(EFTUtil.PostTransactionAfterVoid());
    end;

    procedure VoidCardEntry(var CardEntryToVoid: Record "LSC POS Card Entry"; REC: Record "LSC POS Transaction"; var pVoidedCardEntryNo: Integer; var ErrorReason: Text): Boolean
    var
        PayVoidAbortedMsg: Label 'Payment void operation aborted';
        VoidedCardEntry: Record "LSC POS Card Entry";
        PosTerminal: Record "LSC POS Terminal";
        eFTUTIL2op: Interface "OPT IEFTUtility2";
        eftutilop: Codeunit "OPT POS EFT Utility";
        isHandled: Boolean;
        rLAF: Record "Trans. LAF";
        Postrans: Codeunit "LSC POS Transaction";
    begin
        ErrorReason := '';
        OnGetEFTUtility(EFTUtil2OPT, isHandled);


        POSSESSION.GetEFTTokenUtility(TokenUtil);
        POSSESSION.GetEFTUtility(EFTUtil);
        POSSESSION.GetEFTUtility2(EFTUtil2);
        EFTUtil2OPT := eftutilop;

        EFTUtil.InitEFTServer();
        //POSSESSION.GetEFTUtility2(EFTUtil2OPT);
        Clear(VoidCardConfirm);
        TokenUtil.ClearTokenData();
        VoidCardConfirm.SetCardNo(CardEntryToVoid.GetCardNo);
        if EFTUtil.IsVoidMSRRequired then
            VoidCardConfirm.SetReadFromMSR(CardEntryToVoid."MSR input");
        if CardEntryToVoid."Transaction Type" in [CardEntryToVoid."Transaction Type"::PreAuth, CardEntryToVoid."Transaction Type"::UpdatePreAuth] then
            VoidCardConfirm.SetPreAuth(true);

        VoidCardConfirm.RunModal;
        if not VoidCardConfirm.GetOk then begin
            ErrorReason := PayVoidAbortedMsg;
            exit(false);
        end;




        if CardEntryToVoid."EFT Token" <> '' then
            if not GetPaymentTokenFromStorage(Enum::"LSC POS Command"::CARDONFILE, Enum::"LSC Token Type"::Purchase, enum::"LSC Token Contract Type"::"Card on File", CardEntryToVoid.RecordId,
                                              REC, POSSESSION.FunctionalityProfileID(), EFTUtil) then
                exit;

        if EFTUtil2OPT.VoidCardEntry2(CardEntryToVoid, REC."Receipt No.", true, pVoidedCardEntryNo, ErrorReason) then begin
            //if EFTUtil2.VoidCardEntry2(CardEntryToVoid, REC."Receipt No.", true, pVoidedCardEntryNo, ErrorReason) then begin
            if VoidedCardEntry.Get(REC."Store No.", REC."POS Terminal No.", pVoidedCardEntryNo) then begin
                PosTerminal.Get(POSSESSION.TerminalNo);
                SendPaymentTokenToStorage(pVoidedCardEntryNo, Enum::"LSC Token Type"::Purchase,
                                          Enum::"LSC Token Contract Type"::"Card on File", PosTerminal,
                                          REC, POSSESSION.FunctionalityProfileID(), EFTUtil, ErrorReason);

            end;
            exit(true)
        end;

        exit(false);
    end;

    procedure OnMSRData(pTrack2Data: Text): Boolean
    begin
        exit(VoidCardConfirm.OnMsrData(pTrack2Data));
    end;

    procedure EFTShowLastTrans(var ErrorReason: Text): Boolean
    begin
        ErrorReason := '';

        EFTUtil.ShowLastTransactionInfo;

        if EFTUtil.IsErrorState then begin
            ErrorReason := EFTUtil.GetMessage();
            exit(false);
        end;

        exit(true);
    end;

    procedure EFTPrintLastTrans(var REC: Record "LSC POS Transaction"; var ErrorReason: Text): Boolean
    var
        PrintFromLastQst: Label 'Print Card slips from last transaction?';
    begin
        ErrorReason := '';

        if PosTransactionGUI.ShowPosConfirm(REC, PrintFromLastQst, true) then begin
            EFTUtil.PrintLastTransaction;

            if EFTUtil.IsErrorState then begin
                ErrorReason := EFTUtil.GetMessage();
                exit(false);
            end;
        end;

        exit(true);
    end;

    procedure EFTGetXReport(var REC: Record "LSC POS Transaction"; PrinterActive: Boolean; ErrorReason: Text): Boolean
    var
        IsHandled: Boolean;
        EFTGetXZReportCheck: Label 'Do you want to include information from the EFT device on the %1-Report?';
        PosTerminal: Record "LSC POS Terminal";
        AskUser: Boolean;
    begin
        ErrorReason := '';

        if not PrinterActive then
            exit(false);

        PosTerminal.Get(POSSESSION.TerminalNo);
        if PosTerminal."Include EFT ZReport" = Enum::"LSC Include EFT ZReport"::Never then
            exit(false);

#pragma warning disable AL0432
        AskUser := PosTerminal."Include EFT ZReport" = Enum::"LSC Include EFT ZReport"::Ask;
        POSTransactionEvents.OnEFTGetXReportBeforePOSConfirm(AskUser, IsHandled);
#pragma warning restore AL0432

        POSTransactionEvents.OnBeforeEFTGetXReportPOSConfirm(IsHandled);

        if IsHandled then
            Exit;

        if PosTerminal."Include EFT ZReport" = Enum::"LSC Include EFT ZReport"::Ask then
            if not PosTransactionGUI.ShowPosConfirm(REC, StrSubstNo(EFTGetXZReportCheck, 'X'), false) then
                exit(true);

        EFTUtil.ProcessXReport;

        if EFTUtil.IsErrorState then begin
            ErrorReason := EFTUtil.GetMessage();
            exit(false);
        end;
        exit(true);
    end;

    procedure EFTGetZReport(var REC: Record "LSC POS Transaction"; PrinterActive: Boolean; TrainingActive: Boolean; var ErrorReason: Text): Boolean
    var
        ZReportNotInTrainingErr: Label 'Z-Reports are not allowed in Training mode';
        EFTGetXZReportCheck: Label 'Do you want to include information from the EFT device on the %1-Report?';
        IsHandled: Boolean;
        POSSESSION: Codeunit "LSC POS Session";
        PosTerminal: Record "LSC POS Terminal";
        AskUser: Boolean;
    begin
        ErrorReason := '';

        if not PrinterActive then
            exit(false);

        PosTerminal.Get(POSSESSION.TerminalNo);
        if PosTerminal."Include EFT ZReport" = Enum::"LSC Include EFT ZReport"::Never then
            exit;

        if TrainingActive then begin
            ErrorReason := ZReportNotInTrainingErr;
            exit(false);
        end;

        if not POSSESSION.Permission('PRINT_Z', ErrorReason) then begin //SAME CHECK AS POS Z-REPORT ?
            exit(false);
        end;

#pragma warning disable AL0432
        AskUser := PosTerminal."Include EFT ZReport" = Enum::"LSC Include EFT ZReport"::Ask;
        POSTransactionEvents.OnEFTGetZReportBeforePOSConfirm(AskUser, IsHandled);
#pragma warning restore AL0432

        POSTransactionEvents.OnBeforeEFTGetZReportPOSConfirm(IsHandled);

        if IsHandled then
            exit;

        if PosTerminal."Include EFT ZReport" = Enum::"LSC Include EFT ZReport"::Ask then
            if not PosTransactionGUI.ShowPosConfirm(REC, StrSubstNo(EFTGetXZReportCheck, 'Z'), false) then
                exit;

        EFTUtil.ProcessZReport;

        if EFTUtil.IsErrorState then begin
            ErrorReason := EFTUtil.GetMessage();
            exit(false);
        end;
        exit(true);
    end;

    procedure EFTStartSession(TransID: Text; var ErrorReason: Text): Boolean
    begin
        EFTUtil.StartSession(TransID);

        if EFTUtil.IsErrorState then begin
            ErrorReason := EFTUtil.GetMessage();
            exit(false);
        end;
        exit(true);
    end;

    procedure EFTFinishSession(TransID: Text; var ErrorReason: Text): Boolean
    begin
        EFTUtil.FinishSession(TransID);

        if EFTUtil.IsErrorState then begin
            ErrorReason := EFTUtil.GetMessage();
            exit(false);
        end;
        exit(true);
    end;

    procedure GetFailedRequest(ReceiptNo_p: Code[20]; var CardEntry_p: Record "LSC POS Card Entry"): Boolean
    begin
        exit(EFTUtil.GetFailedRequest(ReceiptNo_p, CardEntry_p));
    end;

    procedure RecoverFailedRequest(var FailedCardEntry_p: Record "LSC POS Card Entry"; var ErrorMessage_p: Text): Boolean
    begin
        exit(EFTUtil.RecoverFailedRequest(FailedCardEntry_p, ErrorMessage_p));
    end;

    procedure ProcessGetLastTransaction(var ErrorReason: Text): Boolean
    begin
        EFTUtil.ProcessGetLastTransaction();

        if EFTUtil.IsErrorState then begin
            ErrorReason := EFTUtil.GetMessage();
            exit(false);
        end;
        exit(true);
    end;


    procedure VoidCardEntriesForTransaction(var REC: Record "LSC POS Transaction"; var LineRec: Record "LSC POS Trans. Line"; var Transaction: Record "LSC Transaction Header"; RealBalance: Decimal): Boolean
    var
        VoidCardEntry: Record "LSC POS Card Entry";
        CardEntry: Record "LSC POS Card Entry";
        CardEntryNo: Integer;
        ErrorText: Text;
        POSCardEntryNotVoidedErr: Label 'POS Card Entry could not be voided properly for the Transaction';
    begin
        VoidCardEntry.SetCurrentKey("Store No.", "POS Terminal No.", "Transaction No.", "Line No.");
        VoidCardEntry.SetRange("Store No.", Transaction."Store No.");
        VoidCardEntry.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
        VoidCardEntry.SetRange("Transaction No.", Transaction."Transaction No.");
        if VoidCardEntry.FindSet then
            repeat
                if TestVoidCardEntry(REC, VoidCardEntry) and (VoidCardEntry.Amount <= Abs(RealBalance)) then begin
                    if not VoidCard(REC, LineRec, VoidCardEntry, CardEntryNo, ErrorText) then
                        PosTransactionGUI.ShowErrorBeep(ErrorText);
                    if not CardEntry.Get(REC."Store No.", REC."POS Terminal No.", CardEntryNo) then
                        PosTransactionGUI.ShowPosMessage(REC, POSCardEntryNotVoidedErr);
                end;
            until VoidCardEntry.Next = 0;
    end;

    procedure VoidCard(var REC: Record "LSC POS Transaction"; var LineRec: Record "LSC POS Trans. Line"; VoidCardEntry: Record "LSC POS Card Entry"; var pCardEntryNo: Integer; var pErrorReason: Text): Boolean
    var
        IsHandled: Boolean;
        OposUtil: Codeunit "LSC POS OPOS Utility";
    begin
        POSTransactionEvents.OnBeforeVoidCard(REC, LineRec, VoidCardEntry, pCardEntryNo, IsHandled);
        if IsHandled then begin
            exit(IsHandled);
        end;

        OposUtil.Beeper;
        exit(VoidCardEntry(VoidCardEntry, REC, pCardEntryNo, pErrorReason));
    end;

    local procedure CheckIfCardOnFileIsAllowed(PosCommand: Enum "LSC POS Command"): Boolean
    begin
        if not (PosCommand in [Enum::"LSC POS Command"::ADDCARDTOFILE, Enum::"LSC POS Command"::CARDONFILE]) then
            exit(false);

        exit(true);
    end;

    procedure ValidateCardOnFile(PosCommand: Enum "LSC POS Command"; PosTransaction: Record "LSC POS Transaction"; var ErrorReason: Text): Boolean
    var
        TokenStorageUtility: Codeunit "LSC Token Storage Utility";
        TokenStorageSetupIsNotValid: Label 'Token Storage Setup is not configured properly. Add Card to File can only be used if those configuration have been set';
        MemberCardNoIsRequiredToUseCardOnFile: Label 'Member Card No. is required to use card on file functionality [%1]';
        IsHandled: Boolean;
        ValidationResult: Boolean;
        ErrorText: Text;
    begin
        POSTransactionEvents.OnBeforeValidateCardOnFile(PosCommand, PosTransaction, IsHandled, ValidationResult, ErrorReason);
        if IsHandled then
            exit(ValidationResult);

        if not CheckIfCardOnFileIsAllowed(PosCommand) then
            exit(false);

        if not TokenStorageUtility.TokenVaultSetupIsValid() then begin
            ErrorReason := TokenStorageSetupIsNotValid;
            exit(false);
        end;

        POSTransactionEvents.OnBeforeCheckingMemberCardNoInValidateCardOnFile(PosCommand, PosTransaction, IsHandled, ValidationResult, ErrorReason);
        if IsHandled then
            exit(ValidationResult);

        if PosTransaction."Member Card No." = '' then begin
            ErrorText := StrSubstNo(MemberCardNoIsRequiredToUseCardOnFile, Format(PosCommand));

            ErrorReason := ErrorText;
            exit(false);
        end;

        exit(true);
    end;

    procedure PreauthPressed(pCommand: Text; pParameter: Text; var REC: Record "LSC POS Transaction"; var LineRec: Record "LSC POS Trans. Line"; var CurrInput: Text; var Balance: Decimal; var PaymentAmount: Decimal; var ErrorReason: Text; var UsePaymentToken: Boolean): Boolean
    var
        lLineRec: Record "LSC POS Trans. Line";
        lTenderTypeSetup: Record "LSC Tender Type Setup";
        TenderType: Record "LSC Tender Type";
        PreauthNotValidForRefund: Label 'Pre-Auths are not valid for Refunds';
        PreAuthNotSelectedText: Label 'Please select a Pre-Auth to use.';
        PreAuthAmountAdjusted: Label 'Pre-Auth amount will be adjusted to outstanding balance of %1 ?';
        PreAuthFinalize: Label 'Finalize Pre-Auth of %1 ?';
        UpdateExistingPreauthText: Label 'A Pre-Auth has already been added.  Would you like to Update it?';
        CardToFileNotSelectedText: Label 'Please select a Card to File line to use.';
        CardEntry: Record "LSC POS Card Entry";
        POSLINES: Codeunit "LSC POS Trans. Lines";
        AmountMsg: Label 'Amount';
        InvalidAmtValueErr: Label 'Invalid value in amount';
        MessageText: Text;
        Success: Boolean;
        lTextType: Enum "LSC POS Trans. Line Text Type";
        PosCommandRec: Record "LSC POS Command";
        PosCommand: Enum "LSC POS Command";
        DisplayNumPadForAmount: Boolean;
        DisplayFinalizeConfirmation: Boolean;
        PreAuthAmount: Decimal;
    begin
        // if not PosCommandRec.CommandExists(pCommand, PosCommand) then
        //     exit(false);

        if PosCommand = Enum::"LSC POS Command"::ADDCARDTOFILE then
            if not ValidateCardOnFile(PosCommand, REC, ErrorReason) then
                exit(false);

        CLEAR(CardEntry);
        if REC."Sale Is Return Sale" then begin
            ErrorReason := PreauthNotValidForRefund;
            exit(false);
        end;

        if pParameter <> '' then
            CurrInput := pParameter; //Might be fixed Preauth amounts?

        POSLINES.GetCurrentLine(LineRec);

        if PosCommand in [Enum::"LSC POS Command"::"PREAUTH-UPDATE", Enum::"LSC POS Command"::"PREAUTH-FINALIZE"] then begin
            if (LineRec."Entry Type" <> LineRec."Entry Type"::FreeText) OR (LineRec."Text Type" <> LineRec."Text Type"::"Pre-Auth Text") then begin
                lLineRec.SetRange("Receipt No.", REC."Receipt No.");
                lLineRec.SetRange(lLineRec."Entry Status", 0);
                lLineRec.SetRange(lLineRec."Entry Type", lLineRec."Entry Type"::FreeText);
                lLineRec.SetRange(lLineRec."Text Type", lLineRec."Text Type"::"Pre-Auth Text");
                if lLineRec.Count = 1 then begin
                    lLineRec.FindFirst();
                    LineRec.Get(lLineRec.RecordID);
                end;
            end;

            if LineRec."Entry Status" = LineRec."Entry Status"::Voided then
                exit(false);

            if not CardEntry.Get(LineRec."Store No.", LineRec."POS Terminal No.", LineRec."Card Entry No.") then begin
                if (lTextType = Enum::"LSC POS Trans. Line Text Type"::"Card On File Text") then
                    ErrorReason := CardToFileNotSelectedText
                else
                    ErrorReason := PreAuthNotSelectedText;
                exit(false);
            end;

            if not CardEntry.Get(LineRec."Store No.", LineRec."POS Terminal No.", LineRec."Card Entry No.") then begin
                ErrorReason := PreAuthNotSelectedText;
                exit(false);
            end;

            if not (CardEntry."Transaction Type" in [CardEntry."Transaction Type"::PreAuth, CardEntry."Transaction Type"::UpdatePreAuth]) then begin
                ErrorReason := PreAuthNotSelectedText;
                exit(false);
            end;

            if PosCommand = Enum::"LSC POS Command"::"PREAUTH-FINALIZE" then begin //Use Default Card Tender to finalize the payment
                lTenderTypeSetup.Reset;
                lTenderTypeSetup.SetRange("Default Card Tender", true);
                lTenderTypeSetup.FindFirst; //lets make this a must
                TenderType.Get(REC."Store No.", lTenderTypeSetup.Code);
                if CardEntry.Amount > Balance then begin
                    if not CONFIRM(StrSubstNo(PreauthAmountAdjusted, Balance)) then
                        exit(false);
                    CurrInput := FORMAT(Balance) //Automatically lower amount to Balance if higer.
                end
                else begin
                    DisplayFinalizeConfirmation := true;
                    POSTransactionEvents.OnBeforeSettingPreAuthFinalizationAmount(PosCommand, CardEntry, Balance, REC, PreAuthAmount, DisplayFinalizeConfirmation);
                    if DisplayFinalizeConfirmation then
                        if not CONFIRM(StrSubstNo(PreAuthFinalize, CardEntry.Amount)) then
                            exit(false);
                    CurrInput := FORMAT(GetDefaultPreAuthAmountValue(CardEntry.Amount, PreAuthAmount));
                end;
            end;
        end;

        //Check if preauth exists for this transaction
        if CurrInput = '' then begin
            DisplayNumPadForAmount := true;
            if PosCommand in [Enum::"LSC POS Command"::PREAUTH, Enum::"LSC POS Command"::ADDCARDTOFILE] then begin
                lTextType := Enum::"LSC POS Trans. Line Text Type"::"Pre-Auth Text";
                if (PosCommand = Enum::"LSC POS Command"::ADDCARDTOFILE) then
                    lTextType := Enum::"LSC POS Trans. Line Text Type"::"Card On File Text";

                lLineRec.SetRange("Receipt No.", REC."Receipt No.");
                lLineRec.SetRange(lLineRec."Entry Status", 0);
                lLineRec.SetRange(lLineRec."Entry Type", lLineRec."Entry Type"::FreeText);
                lLineRec.SetRange(lLineRec."Text Type", lTextType);

                if ((PosCommand = Enum::"LSC POS Command"::PREAUTH) and lLineRec.FindFirst) then begin
                    //Ask if user wants to Update existing Pre-Auth instead of creating a new one, if so then do UPDATE
                    if PosTransactionGUI.ShowPosConfirm(REC, UpdateExistingPreauthText, true) then begin
                        PosCommand := Enum::"LSC POS Command"::"PREAUTH-UPDATE";
                        LineRec.Get(lLineRec.RecordId);
                        POSLINES.SetCurrentLine(LineRec);
                        CardEntry.Get(LineRec."Store No.", LineRec."POS Terminal No.", LineRec."Card Entry No.");
                    end;
                end;
            end;

            //The numpad should not be displayed for Add Card to File
            if PosCommand in [Enum::"LSC POS Command"::PREAUTH, Enum::"LSC POS Command"::"PREAUTH-UPDATE"] then begin
                POSTransactionEvents.OnBeforeSettingPreAuthorizationAmount(PosCommand, lLineRec, CardEntry, Balance, REC, PreAuthAmount, DisplayNumPadForAmount);
                if DisplayNumPadForAmount then begin
                    PosTransactionGUI.OpenNumericKeyboard(AmountMsg, FORMAT(GetDefaultPreAuthAmountValue(CardEntry.Amount, PreAuthAmount)), Format(PosCommand));
                    exit(false);
                end
                else
                    CurrInput := Format(PreAuthAmount);
            end;
            if (PosCommand = Enum::"LSC POS Command"::ADDCARDTOFILE) then
                CurrInput := '0';
        end;

        if not Evaluate(PaymentAmount, CurrInput) then begin
            ErrorReason := InvalidAmtValueErr;
            exit(false);
        end;

        if (PosCommand = Enum::"LSC POS Command"::ADDCARDTOFILE) then
            POSTransactionEvents.OnAfterAddCardPressed(REC, LineRec, CurrInput)
        else
            POSTransactionEvents.OnAfterPreauthPressed(REC, LineRec, CurrInput, TenderType.Code);

        CurrInput := '-(PINPAD)-';
        SetCardOffline(false);

        Success := false;
        case PosCommand of
            Enum::"LSC POS Command"::PREAUTH:
                Success := ValidateCard(REC, LineRec, CardEntry, 1, TenderType.Code, PaymentAmount, Balance, CurrInput, false, MessageText, ErrorReason, UsePaymentToken, TenderType."Scan QR Code");
            Enum::"LSC POS Command"::"PREAUTH-UPDATE":
                Success := ValidateCard(REC, LineRec, CardEntry, 2, TenderType.Code, PaymentAmount, Balance, CurrInput, false, MessageText, ErrorReason, UsePaymentToken, TenderType."Scan QR Code");
            Enum::"LSC POS Command"::"PREAUTH-FINALIZE":
                Success := ValidateCard(REC, LineRec, CardEntry, 3, TenderType.Code, PaymentAmount, Balance, CurrInput, false, MessageText, ErrorReason, UsePaymentToken, TenderType."Scan QR Code");
            Enum::"LSC POS Command"::ADDCARDTOFILE:
                Success := ValidateCard(REC, LineRec, CardEntry, 4, TenderType.Code, PaymentAmount, Balance, CurrInput, false, MessageText, ErrorReason, UsePaymentToken, TenderType."Scan QR Code");
        end;

        if MessageText <> '' then
            PosTransactionGUI.ShowPosMessage(REC, MessageText);

        if (PosCommand = Enum::"LSC POS Command"::ADDCARDTOFILE) then
            POSTransactionEvents.OnAfterAddCardToFileExecuted(REC, LineRec, CurrInput)
        else
            POSTransactionEvents.OnAfterPreauthExecuted(REC, LineRec, CurrInput, TenderType.Code);

        exit(Success);
    end;

    local procedure GetDefaultPreAuthAmountValue(CardEntryAmount: Decimal; DefaultPreAuthAmount: Decimal): Decimal
    begin
        if DefaultPreAuthAmount > 0 then
            exit(DefaultPreAuthAmount);

        exit(CardEntryAmount)
    end;

    procedure GetTokenValuesForCreateToken(var REC: Record "LSC POS Transaction") Token: Record "LSC Token"
    var
        IsHandled: Boolean;
    begin
        POSTransactionEvents.OnBeforeGetTokenValuesForCreateToken(Token, REC, IsHandled);

        If IsHandled then
            exit;

        Token.Init();
        Token."Token Type" := Enum::"LSC Token Type"::" "; //Unknown
        Token.Initiator := Enum::"LSC Token Initiator"::Cardholder;
        Token."Initiator Reason" := Enum::"LSC Token Initiator Reason"::Unscheduled;
    end;

    local procedure TransTypeToPosCommand(TransType: Option Sale,Preauth,"Update-Preauth","Finalize-Preauth","AddCardToFile"): Enum "LSC POS Command"
    begin
        case TransType of
            0:
                exit(Enum::"LSC POS Command"::CARDONFILE);
            1:
                exit(Enum::"LSC POS Command"::PREAUTH);
            2:
                exit(Enum::"LSC POS Command"::"PREAUTH-UPDATE");
            3:
                exit(Enum::"LSC POS Command"::"PREAUTH-FINALIZE");
            4:
                exit(Enum::"LSC POS Command"::ADDCARDTOFILE);
        end;
    end;

    procedure GetPaymentTokenFromStorage(PosCommand: Enum "LSC POS Command"; TokenType: Enum "LSC Token Type"; TokenContractType: Enum "LSC Token Contract Type";
                                        TokenContractId: RecordId; var REC: Record "LSC POS Transaction";
                                        FunctionalityProfileID: Code[10]; EFTUtil: Interface "LSC IEFTUtility"): Boolean
    var
        TempToken: Record "LSC Token" temporary;
        MemberCard: Record "LSC Membership Card";
        MemberCardRecordId: RecordId;
        IsHandled: Boolean;
        Result: Boolean;
        ResponseCode: Code[30];
        // GetContractTokensUtils: Codeunit LSCGetContractTokensUtils;
        ErrorText: Text;
        NoCardOnFileWasFound: Label 'No Card on File was found that could be used for payment';
    begin
        // POSTransactionEvents.OnBeforeGetPaymentTokenFromStorage(IsHandled, TokenType, TokenContractId, TokenContractType, REC);
        // if IsHandled then
        //     exit(true);

        // if not ValidateCardOnFile(PosCommand, REC, ErrorText) then begin
        //     PosTransactionGUI.ShowErrorBeep(ErrorText);
        //     exit(false);
        // end;

        // if (REC."Member Card No." <> '') then
        //     if MemberCard.Get(REC."Member Card No.") then
        //         MemberCardRecordId := MemberCard.RecordId;

        // GetContractTokensUtils.SetPosFunctionalityProfile(FunctionalityProfileID);
        // GetContractTokensUtils.SendRequest(TokenContractId, TokenContractType, Today, MemberCardRecordId, TempToken, Result, ResponseCode, ErrorText);

        // POSTransactionEvents.OnAfterGetPaymentTokenFromStorage(TempToken, Result, ResponseCode, ErrorText, TokenType, REC);

        // if not GetPaymentTokenIsSuccessful(TempToken, ErrorText, NoCardOnFileWasFound) then
        //     exit(false);

        // exit(SelectTokenToUseForPayment(TempToken, MemberCard, TokenType, REC, EFTUtil));
    end;

    procedure SelectTokenToUseForPayment(var TempToken: Record "LSC Token" temporary; MemberCard: Record "LSC Membership Card";
                                        TokenType: Enum "LSC Token Type"; var REC: Record "LSC POS Transaction"; EFTUtil: Interface "LSC IEFTUtility"): Boolean;
    var
        NoCardOnFileWasFound: Label 'No Card on File was found that could be used for payment';
        LookupDoesNotExist: Label '%1 %2 does not exist';
        TokenCount: Integer;
        IsHandled: Boolean;
        PosLookup: Record "LSC POS Lookup";
        PosTrLineTmp: Record "LSC POS Trans. Line" temporary;
        RecRef: RecordRef;
        POSGUI: Codeunit "LSC POS GUI";
    begin
        POSTransactionEvents.OnBeforeSelectTokenToUseForPayment(IsHandled, TempToken, TokenType, MemberCard, REC);
        if IsHandled then
            exit(true);

        if not POSSESSION.GetPosLookupRec(Format(Enum::"LSC POS Input Control Id"::"#TOKENSELECTION"), PosLookup) then begin
            PosTransactionGUI.Errorbeep(StrSubstNo(LookupDoesNotExist, PosLookup.TableName, Format("LSC POS Input Control Id"::"#TOKENSELECTION")), false);
            exit;
        end;

        gTokenSelection := '';

        TokenCount := TempToken.Count();
        case TokenCount of
            0:
                begin
                    GetPaymentTokenIsSuccessful(TempToken, '', NoCardOnFileWasFound);
                    exit(false)
                end;
            1:
                begin
                    if not MemberCard.IsEmpty then begin
                        TempToken.SetRange("Account No.", MemberCard."Account No.");
                        TempToken.SetRange("Contact No.", MemberCard."Contact No.");
                    end;

                    TempToken.SetRange("Token Type", TokenType);
                    if not GetPaymentTokenIsSuccessful(TempToken, '', NoCardOnFileWasFound) then
                        exit(false);

                    TokenUtil.SetTokenData(TempToken);
                    POSTransactionEvents.OnAfterSelectTokenToUseForPayment(TempToken, TokenType, MemberCard, REC);
                    exit(true);
                end;
            else begin
                gTempToken.Copy(TempToken, true);
                RecRef.GetTable(TempToken);
                POSGUI.Lookup(PosLookup, '', PosTrLineTmp, POSSESSION.MgrKey, '', RecRef);
                exit(false);
            end;
        end;

        POSTransactionEvents.OnAfterSelectTokenToUseForPayment(TempToken, TokenType, MemberCard, REC);
    end;

    procedure SendPaymentTokenToStorage(CardEntryNo: Integer; TokenType: Enum "LSC Token Type"; TokenConnectionType: Enum "LSC Token Contract Type";
                                        PosTerminal: Record "LSC POS Terminal"; var REC: Record "LSC POS Transaction"; FunctionalityProfileID: Code[10];
                                        EFTUtil: Interface "LSC IEFTUtility"; var ReturnMessage: Text)
    var
        CardEntry: Record "LSC POS Card Entry";
        MemberCard: Record "LSC Membership Card";
        TempToken: Record "LSC Token" temporary;
        TokenConnection: RecordId;
        // SetTokenEntryV2Util: Codeunit "LSC SetTokenEntryV2Utils";
        TokenStorageUtility: Codeunit "LSC Token Storage Utility";
        IsHandled: Boolean;
        ErrorText: Text;
        Result: Boolean;
        ResponseCode: Code[30];
        CardHasBeenAddedToFile: Label 'Card %1 has been added to file';
    begin
        // if not TokenStorageUtility.TokenVaultSetupIsValid() then
        //     exit;

        // TokenUtil.GetTokenData(TempToken);
        // if TempToken.Token = '' then
        //     exit;

        CardEntry.Get(PosTerminal."Store No.", PosTerminal."No.", CardEntryNo);
#pragma warning disable AL0432
        //TODO: When this is removed TokenType parameter should also be removed
        POSTransactionEvents.OnBeforeCreatingTokenInSendPaymentTokenToStorage(IsHandled, CardEntry, TokenType, REC);
        if CardEntry."EFT Token" <> '' then begin
            TempToken.Token := CardEntry."EFT Token";
            TempToken."Token Type" := TokenType;
        end;
#pragma warning restore AL0432
        POSTransactionEvents.OnBeforeCreatingTokenInSendPaymentTokenToStorageV2(REC, TempToken, IsHandled);
        if IsHandled then
            exit;

        if ((TempToken.Token <> '') and (CardEntry."EFT Token" = '')) then begin
            CardEntry."EFT Token" := TempToken.Token;
            CardEntry.Modify();
        end;

        if MemberCard.Get(REC."Member Card No.") then begin
            TempToken."Account No." := MemberCard."Account No.";
            TempToken."Contact No." := MemberCard."Contact No."
        end;

        TempToken."Card Mask" := CardEntry."Card Number";
        TempToken.Insert();

        TokenConnection := CardEntry.RecordId;

        POSTransactionEvents.OnBeforeSendingPaymentTokenToStorage(IsHandled, CardEntry, TempToken, TokenConnection, TokenConnectionType, REC);
        if IsHandled then
            exit;

        // SetTokenEntryV2Util.SetPosFunctionalityProfile(FunctionalityProfileID);
        // SetTokenEntryV2Util.SendRequest(TempToken, TokenConnection, TokenConnectionType, CardEntry.Amount, CardEntry.RecordId, REC."Member Card No.", Result, ResponseCode, ErrorText);

        POSTransactionEvents.OnAfterSendingPaymentTokenToStorage(CardEntry, TempToken, REC, Result, ResponseCode, ErrorText);

        if ErrorText <> '' then begin
            ReturnMessage := ErrorText;
            exit
        end;

        ReturnMessage := StrSubstNo(CardHasBeenAddedToFile, CardEntry."Card Number");
    end;

    local procedure GetPaymentTokenIsSuccessful(var TempToken: Record "LSC Token" temporary; ErrorText: Text; NoTokenFoundErrorText: Text): Boolean
    begin
        if (ErrorText = '') then
            exit(true);

        if TempToken.IsEmpty then
            Message(NoTokenFoundErrorText)
        else
            Message(ErrorText);
        exit(false);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetEFTUtility(var iEFTUtil: interface "OPT IEFTUtility2"; var isHandled: Boolean)
    begin
    end;

}