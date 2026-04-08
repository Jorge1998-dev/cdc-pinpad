codeunit 60011 "OPT POS EFT Utility" implements "LSC IEFTUtility", "LSC IEFTPrinter", "LSC IEFTUtility2", "LSC IToken Utility", "LSC IReferenced Returns", "Opt LSC IEFTUtility2", "OPT IEFTUtility2"
{
    SingleInstance = true;

    trigger OnRun()
    begin
        PrintLastTransaction();
    end;

    var
        CardEntry: Record "LSC POS Card Entry";
        EFTPrintLine: Record "LSC POS Card Print Text";
        PosTerminal: Record "LSC POS Terminal";
        POSEFTRecord: Record "LSC POS EFT";
        TokenData: Record "LSC Token";
        ReferencedReturnsTemp: Record "LSC Referenced Returns";
        POSGUI: Codeunit "LSC POS GUI";
        PEFT: Page "LSC POS EFT Dialog";
        PEFT2: Page "LSC POS EFT Dialog 2";
        CRLF: Text;
        CurrentEFTTransactionType: Text;
        EFTAdditionalID: Text;
        EFTMessage: Text[200];
        EFTQRCode: Text;
        EFTToken: Text;
        CurrTenderType: Code[10];
        EFTCurrencyCode: Code[10];
        EFTTenderType: Text;
        EFTAmount: Decimal;
        EFTCashback: Decimal;
        EFTVat: Decimal;
        EFTSurcharge: Decimal;
        EFTSurchargeFromPed: Decimal;
        EFTTip: Decimal;
        EFTTipFromPed: Decimal;
        EFTResult: Integer;
        AutoTestMode: Boolean;
        EFTManualEntry: Boolean;
        EFTAskGratuity: Boolean;
        IsError: Boolean;
        TestCardFlag: Boolean;
        TxtRetryPrinting: Label 'Retry Printing?';
        TxtReceiptCOPY: Label '**  C O P Y  **';
        TxtCurrencyWarning: Label 'Different Currency code detected in response from EFT Service. Contact system admin for assistance.';
        TxtNoTipAccountError: Label 'No %1 setup found with %2 set to %3 in store %4.';
        TxtLastTransInfoMissing: Label 'Unable to get last Transaction info from EFT (%1)';
        TxtLastTransIDMismatch: Label 'Last Transaction Client ID (%1) from EFT does not match the Failed Card Entry (%2).';
        TxtLastTransAlreadyExists: Label 'Last EFT Transaction ID has already been logged.';
        TxtLastTransTypeMismatch: Label 'Last Transaction Type (%1) from EFT does not match the Failed Card Entry (%2).';
        TxtLastTransVerifyRecovery: Label 'Recover last Transacton from EFT?\\Transaction Type:     %1\Card Number......:     %2\Amount.................:     %3\EFT Trans. ID........:     %4\EFT Trans. Time...:     %5\Client Trans. ID ....:%6';
        TxtLastTransRecoveryCancelled: Label 'Last Trans. Recovery rejected by Staff.';
        TxtTransTypeCannotBeUsed: Label 'Transaction Type %1 cannot be used.';
        TxtTransNotAuthorized: Label 'Transaction was not Authorize or has been Voided.';
        TxtVoidUnsupportedTransType: Label 'Card void error!\Unsupported transaction type.';
        TxtPreAuthAlreadyFinalized: Label 'PreAuth entry has already been Finalized.';
        TxtPreAuthAlreadyCancelled: Label 'PreAuth entry has already been Cancelled.';

        TOKENTYPE_UNKNOWN: Label 'Unknown', Locked = true;
        TOKENTYPE_UNSCHEDULED: Label 'Unscheduled', Locked = true;
        TOKENTYPE_RECURRING: Label 'Recurring', Locked = true;
        TOKENTYPE_INSTALLMENTS: Label 'Installments', Locked = true;

        PURCHASE: Label 'Purchase', Locked = true;
        OFFLINEPURCHASE: Label 'OfflinePurchase', Locked = true;
        VOID: Label 'Void', Locked = true;
        REFUND: Label 'Refund', Locked = true;
        GETLASTTRANS: Label 'GetLastTransaction', Locked = true;
        REPRINTLAST: Label 'ReprintLast', Locked = true;
        XREPORT: Label 'XReport', Locked = true;
        ZREPORT: Label 'ZReport', Locked = true;
        PREAUTH: Label 'PreAuth', Locked = true;
        CANCEL_PREAUTH: Label 'CancelPreAuth', Locked = true;
        UPDATE_PREAUTH: Label 'UpdatePreAuth', Locked = true;
        FINALIZE_PREAUTH: Label 'FinalizePreAuth', Locked = true;
        ADDCARDTOFILE: Label 'CreateToken', Locked = true;
        STARTSESS: Label 'StartSession', Locked = true;
        FINISHSESS: Label 'FinishSession', Locked = true;
        PRINTRECEIPT: Label 'PrintReceipt', Locked = true;

        varTransactionType: Label 'TransactionType', Locked = true;
        varAuthorizationStatus: Label 'AuthorizationStatus', Locked = true;
        varAuthorizationCode: Label 'AuthorizationCode', Locked = true;
        varResultCode: Label 'ResultCode', Locked = true;
        varTenderType: Label 'TenderType', Locked = true;
        varQRCode: Label 'QRCode', Locked = true;
        varToken: Label 'Token', Locked = true;
        varAskGratuity: Label 'AskGratuity', Locked = true;
        varManualEntry: Label 'ManualEntry', Locked = true;
        varEnablePLB: Label 'EnablePLB', Locked = true;
        varAmountBreakdown: Label 'AmountBreakdown', Locked = true;
        varTotalAmount: Label 'AmountBreakdown.TotalAmount', Locked = true;
        varCashbackAmount: Label 'AmountBreakdown.CashbackAmount', Locked = true;
        varTaxAmount: Label 'AmountBreakdown.TaxAmount', Locked = true;
        varSurchargeAmount: Label 'AmountBreakdown.SurchargeAmount', Locked = true;
        varTipAmount: Label 'AmountBreakdown.TipAmount', Locked = true;
        varCurrencyCode: Label 'AmountBreakdown.CurrencyCode', Locked = true;
        varBatchNumber: Label 'IDs.BatchNumber', Locked = true;
        varClientTransactionID: Label 'IDs.TransactionId', Locked = true;
        varEFTTransactionID: Label 'IDs.EFTTransactionId', Locked = true;
        varEFTTransDateTime: Label 'IDs.TransactionDateTime', Locked = true;
        varEFTAdditionalID: Label 'IDs.AdditionalId', Locked = true;
        varCardNumber: Label 'CardDetails.CardNumber', Locked = true;
        varCardIssuer: Label 'CardDetails.CardIssuer', Locked = true;
        varCardExpiryDate: Label 'CardDetails.CardExpiryDate', Locked = true;
        varTokenDataID: Label 'TokenData.Id', Locked = true;
        varTokenDataInitiator: Label 'TokenData.Initiator', Locked = true;
        varTokenDataInitiatorReason: Label 'TokenData.InitiatorReason', Locked = true;
        varTokenDataTokenType: Label 'TokenData.TokenType', Locked = true;
        varTokenDataValue: Label 'TokenData.Value', Locked = true;
        ScreenDisplayOpen: boolean;
        ScreenDisplayDialog: Dialog;
        Displaymsg: codeunit ConnectCom;

    internal procedure InitEFTServer()
    begin
        InitEFTServer('', '');
    end;

    internal procedure InitEFTServer(posTerminalNo: Code[10])
    begin
        InitEFTServer(posTerminalNo, '');
    end;

    internal procedure InitEFTServer(posTerminalNo: Code[10]; EFTDeviceID: Code[20])
    var
        HardwareProfile: Record "LSC POS Hardware Profile";
        POSSESSION: Codeunit "LSC POS Session";
        DeviceID: Code[20];
    begin
        if posTerminalNo = '' then
            posTerminalNo := POSSESSION.TerminalNo;
        PosTerminal.Get(posTerminalNo);

        if EFTDeviceID <> '' then begin
            POSEFTRecord.Get(EFTDeviceID);
            exit;
        end;

        HardwareProfile.Get(POSSESSION.HardwareProfileID);
        if HardwareProfile.GetDevice("LSC Hardware Profile Devices"::EFT, '', '', 0, DeviceID) then
            if POSEFTRecord.Get(DeviceID) then;
    end;

    local procedure ClearEFT(DoClearTokenData: Boolean)
    begin
        ClearEFT();
        if DoClearTokenData then
            ClearTokenData();
    end;

    internal procedure ClearEFT()
    begin
        Clear(PEFT2);
        Clear(CardEntry);
        ClearReferencedReturns();
        EFTAmount := 0;
        EFTVat := 0;
        EFTCashback := 0;
        EFTSurcharge := 0;
        EFTSurchargeFromPed := 0;
        EFTTip := 0;
        EFTTipFromPed := 0;
        EFTToken := '';
        EFTManualEntry := false;
        EFTQRCode := '';
        EFTAskGratuity := false;
        EFTResult := 0;
        EFTMessage := '';
        EFTAdditionalID := '';
        EFTCurrencyCode := '';
        EFTTenderType := '';
        CurrTenderType := '';
        IsError := false;
        CurrentEFTTransactionType := '';
        TestCardFlag := false;
    end;

    internal procedure SetTransType(TransType: Integer)
    begin
        CardEntry."Transaction Type" := TransType;
    end;

    internal procedure SetTrack2(Track2: Text)
    begin
        if Track2 <> '-(PINPAD)-' then
            Error('EFT: Wrong version');
    end;

    internal procedure SetCardNo(CardNo: Text)
    begin
        SetTrack2(CardNo);
    end;

    internal procedure SetAmount(CardAmount: Decimal)
    begin
        EFTAmount := Round(CardAmount, 0.01);
    end;

    internal procedure SetVAT(CardVAT: Decimal)
    begin
        EFTVat := Round(CardVAT, 0.01);
    end;

    internal procedure SetCashback(CardCashback: Decimal)
    begin
        EFTCashback := Round(CardCashback, 0.01);
    end;

    internal procedure SetTip(CardTip: Decimal)
    begin
        EFTTip := Round(CardTip, 0.01);
    end;

    internal procedure SetSurcharge(CardSurcharge: Decimal)
    begin
        EFTSurcharge := Round(CardSurcharge, 0.01);
    end;

    internal procedure SetCurrencyCode(pCurrencyCode: Code[10])
    begin
        EFTCurrencyCode := pCurrencyCode;
    end;

    internal procedure SetComboCard(Credit: Boolean)
    begin
    end;

    internal procedure SetAuthCode(AuthCode: Code[10])
    begin
        Error('EFT: Wrong version');
    end;

    internal procedure SetPassword(Password: Code[10])
    begin
    end;

    internal procedure SetVoidTrans(TransNo: Code[10]; BatchNo: Code[10])
    begin
    end;

    internal procedure SetServer(Server: Text[30])
    begin
    end;

    internal procedure SetManualEntry(ManualEntry: Boolean)
    begin
        EFTManualEntry := ManualEntry;
    end;

    internal procedure SetAdditionalID(additionalID: Text)
    begin
        EFTAdditionalID := additionalID;
    end;

    internal procedure SetQRCode(QRCode: Text)
    begin
        EFTQRCode := QRCode;
    end;

    internal procedure SetAskGratuity(AskGratuity: Boolean)
    begin
        EFTAskGratuity := AskGratuity;
    end;

    internal procedure SeekAuth()
    begin
        EFTResult := 0;
    end;

    internal procedure TestCard()
    begin
        TestCardFlag := true;
        SeekAuth;
    end;

    internal procedure PollStatus(var PollStatusTxt: Text[200]): Boolean
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePullStatus(CardEntry, EFTResult, EFTMessage, IsHandled);
        if IsHandled then begin
            PollStatusTxt := EFTMessage;
            exit(false);
        end;

        if TestCardFlag then begin
            TestCardFlag := false;
            EFTResult := 1;
            exit(false);
        end;

        OnBeforeProcessingInPollStatus(CardEntry, EFTAdditionalID, EFTQRCode, EFTCurrencyCode, EFTTenderType, EFTAmount,
                                       EFTCashback, EFTVat, EFTSurcharge, EFTTip, EFTManualEntry, EFTAskGratuity);

        case CardEntry."Transaction Type" of
            CardEntry."Transaction Type"::Sale,
            CardEntry."Transaction Type"::FinalizePreAuth:
                ProcessPurchase;
            CardEntry."Transaction Type"::Offline:
                ProcessOfflinePurchase;
            CardEntry."Transaction Type"::Refund:
                ProcessRefund;
            CardEntry."Transaction Type"::"Void Sale",
            CardEntry."Transaction Type"::"Void Refund",
            CardEntry."Transaction Type"::"Void Offline",
            CardEntry."Transaction Type"::CancelPreAuth:
                ProcessVoid;
            CardEntry."Transaction Type"::PreAuth:
                ProcessPreAuth;
            CardEntry."Transaction Type"::UpdatePreAuth:
                ProcessUpdatePreAuth;
            CardEntry."Transaction Type"::AddCardToFile:
                ProcessAddCardToFile();
        end;
        PollStatusTxt := EFTMessage;
        exit(false);
    end;

    internal procedure SetExpiryDate(ExDate: Text[5])
    begin
    end;

    internal procedure GetCardNumber(): Text[30]
    begin
        exit('');
    end;

    internal procedure GetExpiryDate(): Text[5]
    begin
        exit('');
    end;

    internal procedure GetCardTypeName(): Text[30]
    begin
        exit('');
    end;

    internal procedure GetCardType(): Code[10]
    begin
        exit('-x-');
    end;

    internal procedure GetResult(): Integer
    begin
        exit(EFTResult);
    end;

    internal procedure IsComboCard(): Boolean
    begin
        exit(false);
    end;

    internal procedure IsPollable(): Boolean
    begin
        exit(true);
    end;

    internal procedure IsPasswordRequired(MgrKey: Boolean): Boolean
    begin
        exit(false);
    end;

    internal procedure IsExpiryDateRequired(): Boolean
    begin
        exit(false);
    end;

    internal procedure IsVoidMSRRequired(): Boolean
    begin
        exit(false);
    end;

    internal procedure InsertLogEntry(): Integer
    begin
        exit(InsertLogEntry(false));
    end;

    internal procedure InsertLogEntry(suppressEvent: Boolean): Integer
    var
        RetailLocalizationExt: Codeunit "LSC Retail Localization Ext.";
        PLBMgt: Codeunit "LSC PLB Item Mgt.";
        ReturnNo_l: Integer;
    begin
        CardEntry.Amount := EFTAmount;
        CardEntry.Cashback := EFTCashback;
        CardEntry.VAT := EFTVat;
        CardEntry.Surcharge := EFTSurchargeFromPed;
        CardEntry.Tip := EFTTipFromPed;
        if STRLEN(EFTToken) <= 256 then
            CardEntry."EFT Token" := EFTToken;
        CardEntry."EFT Currency" := EFTCurrencyCode;

        CardEntry.Message := EFTMessage;
        CardEntry."EFT Auth.code" := GetVar(varAuthorizationCode);
        CardEntry."Res.code" := GetVar(varResultCode);
#pragma warning disable AL0432
        // Backwards Compatibility:

        //CardEntry."EFT Tender Type" := CopyStr(EFTTenderType, 1, 10); //Remove Later
        CardEntry."EFT TenderType" := CopyStr(EFTTenderType, 1, 10); //Remove Later
#pragma warning restore AL0432
        CardEntry."EFT TenderType" := CopyStr(EFTTenderType, 1, MaxStrLen(CardEntry."EFT TenderType"));

        CardEntry."EFT Batch No." := GetVar(varBatchNumber);
        CardEntry."Card Number" := GetVar(varCardNumber);
        CardEntry."QR Code" := GetVar(varQRCode);
        CardEntry."Card Type Name" := GetVar(varCardIssuer);
        CardEntry."Expiry Date" := GetVar(varCardExpiryDate);
        CardEntry."EFT Transaction ID" := GetVar(varEFTTransactionID);
        CardEntry."EFT Additional ID" := GetVar(varEFTAdditionalID);
        CardEntry."EFT Trans. Time" := COPYSTR(GetVar(varEFTTransDateTime), 1, 30);

        SetCardType(CardEntry);

        if CardEntry."Transaction Type" = CardEntry."Transaction Type"::PreAuth then begin
            CardEntry."PreAuth Entry Store" := CardEntry."Store No.";
            CardEntry."PreAuth Entry Terminal" := CardEntry."POS Terminal No.";
            CardEntry."PreAuth Entry No." := CardEntry."Entry No.";
        end;

        if EFTResult = 1 then begin
            CardEntry."Authorisation Ok" := true;
        end;

        OnBeforeModifyLogEntry(CardEntry);
        CardEntry.Modify;
        ReturnNo_l := CardEntry."Entry No.";

        if CardEntry."Authorisation Ok" and (CardEntry."Transaction Type" = CardEntry."Transaction Type"::FinalizePreAuth) then
            ClosePreAuth(CardEntry);

        if RetailLocalizationExt.IsAULocalizationEnabled() then
            PLBMgt.PLBCentralPlatformIntegration(CardEntry);

        OnAfterInsertLogEntry(CardEntry);
        exit(ReturnNo_l);
    end;

    procedure NextEntryNo(): Integer
    var
        TmpCardEntry: Record "LSC POS Card Entry";
    begin
        TmpCardEntry.SetRange("Store No.", PosTerminal."Store No.");
        TmpCardEntry.SetRange("POS Terminal No.", PosTerminal."No.");
        if TmpCardEntry.FindLast then
            exit(TmpCardEntry."Entry No." + 1)
        else
            exit(1);
    end;

    internal procedure SetFromMSR(FromMSR: Boolean)
    begin
    end;

    internal procedure SetTenderType(tenderType: Code[10])
    begin
        CurrTenderType := tenderType;
    end;

    internal procedure PreAuthHasBeenFinalized(var PreAuthCardEntry: Record "LSC POS Card Entry"): Boolean
    begin
        exit(PreAuthWasClosedWith(0, PreAuthCardEntry));
    end;

    internal procedure PreAuthHasBeenCancelled(var PreAuthCardEntry: Record "LSC POS Card Entry"): Boolean
    begin
        exit(PreAuthWasClosedWith(1, PreAuthCardEntry));
    end;

    local procedure PreAuthWasClosedWith(ClosedWith: Option "Finalize;Cancel"; var PreAuthCardEntry: Record "LSC POS Card Entry"): Boolean
    var
        lCardEntry: Record "LSC POS Card Entry";
    begin
        lCardEntry.SetCurrentKey("PreAuth Entry Store", "PreAuth Entry Terminal", "PreAuth Entry No.");
        case PreAuthCardEntry."Transaction Type" of
            PreAuthCardEntry."Transaction Type"::UpdatePreAuth:
                begin
                    lCardEntry.SetRange("PreAuth Entry Store", PreAuthCardEntry."PreAuth Entry Store");
                    lCardEntry.SetRange("PreAuth Entry Terminal", PreAuthCardEntry."PreAuth Entry Terminal");
                    lCardEntry.SetRange("PreAuth Entry No.", PreAuthCardEntry."PreAuth Entry No.");
                end;
            PreAuthCardEntry."Transaction Type"::PreAuth:
                begin
                    lCardEntry.SetRange("PreAuth Entry Store", PreAuthCardEntry."Store No.");
                    lCardEntry.SetRange("PreAuth Entry Terminal", PreAuthCardEntry."POS Terminal No.");
                    lCardEntry.SetRange("PreAuth Entry No.", PreAuthCardEntry."Entry No.");
                end;
            else
                exit(false);
        end;
        if not lCardEntry.FindSet() then
            exit(false);
        if ClosedWith = 0 then //Finalize
            lCardEntry.SetRange(lCardEntry."Transaction Type", lCardEntry."Transaction Type"::FinalizePreAuth)
        else //Cancel
            lCardEntry.SetRange(lCardEntry."Transaction Type", lCardEntry."Transaction Type"::CancelPreAuth);
        lCardEntry.SetRange("Authorisation Ok", true);
        if lCardEntry.FindFirst then
            exit(true);

        exit(false);
    end;

    internal procedure PreAuthUpdateCount(var PreAuthCardEntry: Record "LSC POS Card Entry"): Integer
    var
        CardEntry_l: Record "LSC POS Card Entry";
    begin
        CardEntry_l.SetCurrentKey("PreAuth Entry Store", "PreAuth Entry Terminal", "PreAuth Entry No.");
        CardEntry_l.SetRange("PreAuth Entry Store", PreAuthCardEntry."PreAuth Entry Store");
        CardEntry_l.SetRange("PreAuth Entry Terminal", PreAuthCardEntry."PreAuth Entry Terminal");
        CardEntry_l.SetRange("PreAuth Entry No.", PreAuthCardEntry."PreAuth Entry No.");
        exit(CardEntry_l.Count - 1);//Original PreAuth will have "Parent Entry *" fields populated (for sorting)
    end;

    internal procedure TestVoidCardEntry(OrgCardEntry: Record "LSC POS Card Entry"): Boolean
    begin
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

    internal procedure VoidCardEntry(OrgCardEntry: Record "LSC POS Card Entry"; SlipNo: Code[20]; Track2: Text) NewEntryNo: Integer
    var
        ErrorTxt: Text;
    begin
        if not VoidCardEntry2(OrgCardEntry, SlipNo, true, NewEntryNo, ErrorTxt) then
            Error(ErrorTxt);
        exit(NewEntryNo);
    end;

    internal procedure VoidCardEntry2(OrgCardEntry: Record "LSC POS Card Entry"; receiptNo: Code[20]; printSlips: Boolean; var VoidCardEntryNo: Integer; var ErrorReason: Text): Boolean
    var
        MsgTxt: Text;
        PrintUtil: Codeunit "LSC POS Print Utility";
        rLAF: Record "Trans. LAF";
        Postrans: Codeunit "LSC POS Transaction";
        cuConnect: Codeunit ConnectCom;
        POSSESSION: Codeunit "LSC POS Session";
        Cprint: Codeunit "LAF Printing Utility";
    //ErrorB: Codeunit "LAF LSC POS Transaction Impl";
    begin
        ClearEFT(false);
        case OrgCardEntry."Transaction Type" of
            OrgCardEntry."Transaction Type"::Sale, OrgCardEntry."Transaction Type"::FinalizePreAuth:
                SetTransType(CardEntry."Transaction Type"::"Void Sale");
            OrgCardEntry."Transaction Type"::Refund:
                SetTransType(CardEntry."Transaction Type"::"Void Refund");
            OrgCardEntry."Transaction Type"::Offline:
                SetTransType(CardEntry."Transaction Type"::"Void Offline");
            OrgCardEntry."Transaction Type"::PreAuth, OrgCardEntry."Transaction Type"::UpdatePreAuth:
                begin
                    SetTransType(CardEntry."Transaction Type"::CancelPreAuth);
                    //Check if PreAuth has already been finalized
                    if PreAuthHasBeenFinalized(OrgCardEntry) then begin
                        ErrorReason := TxtPreAuthAlreadyFinalized;
                        exit(false);
                    end;
                end
            else begin
                ErrorReason := TxtVoidUnsupportedTransType;
                exit(false);
            end;
        end;

        SetReferencedReturns(OrgCardEntry);
        SetEFTAmountVariables(OrgCardEntry);

        InitLogEntry(receiptNo);

        SeekAuth;
        PollStatus(MsgTxt);

        // if CardEntry."Transaction Type" = CardEntry."Transaction Type"::CancelPreAuth then begin
        CardEntry."PreAuth Entry Store" := OrgCardEntry."PreAuth Entry Store";
        CardEntry."PreAuth Entry Terminal" := OrgCardEntry."PreAuth Entry Terminal";
        CardEntry."PreAuth Entry No." := OrgCardEntry."PreAuth Entry No.";
        // end;
        CardEntry."Store No." := OrgCardEntry."Store No.";
        CardEntry."POS Terminal No." := OrgCardEntry."POS Terminal No.";

        InsertLogEntry(true);
        CardEntry."Receipt No." := receiptNo;
        CardEntry."Tender Type" := OrgCardEntry."Tender Type";
#pragma warning disable AL0432
        // Backwards Compatibility:
        //CardEntry."EFT Tender Type" := OrgCardEntry."EFT Tender Type";
#pragma warning restore AL0432
        CardEntry."EFT TenderType" := OrgCardEntry."EFT TenderType";
        if CardEntry."Card Number" = '' then begin
            CardEntry."Card Number" := OrgCardEntry."Card Number";
            CardEntry."Card Type" := OrgCardEntry."Card Type";
            CardEntry."Card Type Name" := OrgCardEntry."Card Type Name";
        end;
        CardEntry."Voided Slip No." := OrgCardEntry."Receipt No.";
        CardEntry."Voided Entry No." := OrgCardEntry."Entry No.";
        if CardEntry."EFT Transaction ID" <> OrgCardEntry."EFT Transaction ID" then
            CardEntry."Voided EFT Transaction ID" := OrgCardEntry."EFT Transaction ID";
        CardEntry."Extra Data" := OrgCardEntry."Extra Data";
        //Septiembre
        CardEntry."Res.code" := 'Success'; //sept
        CardEntry."EFT Device Name" := 'LAFISE';
        EFTMessage := 'Approved';
        CardEntry.Message := EFTMessage;
        //Septiembre        
        CardEntry.Modify;


        ///******
        cuConnect.SendVoid(OrgCardEntry."Voucher Number", CardEntry, OrgCardEntry."Tender Type");
        rLAF.Reset();
        rLAF.SetRange("POS Terminal No.", POSSESSION.TerminalNo());
        rLAF.SetRange("Store No.", POSSESSION.StoreNo());
        rLAF.SetRange("Receipt No.", Postrans.GetReceiptNo());
        rLAF.SetRange(log, false);
        if rLAF.FindSet() then begin
            CardEntry."EFT Auth.code" := '';
            CardEntry."Card Number" := Cprint.SetCardNumber(rLAF."Card Number");
            CardEntry."Card Type Name" := rLAF."Range Type";
            // CardEntry."EFT TenderType" := rLAF."Card Type";
            CardEntry."EFT Currency" := EFTCurrencyCode;
            CardEntry."EFT Store No." := rLAF."Store No.";
            CardEntry."EFT POS Terminal No." := rLAF."POS Terminal No.";
            CardEntry."Store No." := rLAF."Store No.";
            CardEntry."POS Terminal No." := rLAF."POS Terminal No.";

            if rLAF."Response Code" = '00' then begin
                CardEntry."EFT Authorization Status" := CardEntry."EFT Authorization Status"::Approved;
                CardEntry."Authorisation Ok" := true;
                CardEntry."Res.code" := 'Success';
                CardEntry."EFT Device Name" := 'LAFISE';
                CardEntry."EFT DateTime" := CreateDateTime(TODAY, Time);
                CardEntry."EFT Trans. Time" := Format(rLAF.Time);
                CardEntry."Voucher Number" := rLAF."Voucher Number";
                EFTMessage := 'Approved';
                CardEntry.Message := EFTMessage;

            end else begin
                if rLAF."Response Code" <> '00' then begin
                    Displaymsg.ScreenDisplay(rLAF."Response Code");
                    POSGUI.PostCommand("LSC POS Command"::ERRORBEEP, CopyStr('Response :' + rLAF."Response Code" + ' ' + rLAF."Host Response" + '  Amount Authorized ' + rLAF."Amount Authorized", 1, 100));
                    //ErrorB.ErrorBeep('Response :' + rLAF."Response Code" + ' ' + rLAF."Host Response" + '  Amount Authorized ' + rLAF."Amount Authorized");
                    Error('');
                end;
            end;
            CardEntry.Modify();
        END;

        /// *****
        /// 
        Commit;

        if GetResult <> 1 then begin
            ErrorReason := 'Card void error: ' + MsgTxt;
            exit(false);
        end;

        CardEntry."Authorisation Ok" := true;
        CardEntry.Modify;

        OrgCardEntry.Voided := true;
        OrgCardEntry."Voided Slip No." := '';
        OrgCardEntry."Voided Entry No." := 0;
        OrgCardEntry.Modify;

        if OrgCardEntry."PreAuth Entry No." <> 0 then begin
            VoidPreAuth(OrgCardEntry);
            ClosePreAuth(OrgCardEntry);
        end;

        Commit;
        VoidCardEntryNo := CardEntry."Entry No.";
        OnAfterInsertLogEntry(CardEntry);

        if printSlips then begin
            PrintUtil.Init();
            if not PrintUtil.PrintCardSlipFromEFT('', receiptNo) then
                Message(PrintUtil.GetPrintErrorTxt);
            PrintEFTPurge('');
        end;

        exit(true);
    end;

    local procedure SetEFTAmountVariables(OrgCardEntry: Record "LSC POS Card Entry")
    begin
        EFTAdditionalID := OrgCardEntry."EFT Additional ID";
        EFTAmount := OrgCardEntry.Amount;
        EFTCurrencyCode := OrgCardEntry."EFT Currency";
        EFTCashback := OrgCardEntry.Cashback;
        EFTTenderType := OrgCardEntry."EFT TenderType";
#pragma warning disable AL0432
        // Backwards Compatibility:
        if EFTTenderType = '' then
            EFTTenderType := OrgCardEntry."EFT TenderType";
        //  EFTTenderType := OrgCardEntry."EFT Tender Type";
#pragma warning restore AL0432
        EFTToken := OrgCardEntry."EFT Token";
    end;

    local procedure VoidPreAuth(var pPreAuthCardEntry: Record "LSC POS Card Entry")
    var
        AllEntries: Record "LSC POS Card Entry";
    begin
        AllEntries.SetRange("PreAuth Entry Store", pPreAuthCardEntry."PreAuth Entry Store");
        AllEntries.SetRange("PreAuth Entry Terminal", pPreAuthCardEntry."PreAuth Entry Terminal");
        AllEntries.SetRange("PreAuth Entry No.", pPreAuthCardEntry."PreAuth Entry No.");
        AllEntries.ModifyAll(Voided, true);
    end;

    local procedure ClosePreAuth(var pPreAuthCardEntry: Record "LSC POS Card Entry")
    var
        AllEntries: Record "LSC POS Card Entry";
    begin
        AllEntries.SetRange("PreAuth Entry Store", pPreAuthCardEntry."PreAuth Entry Store");
        AllEntries.SetRange("PreAuth Entry Terminal", pPreAuthCardEntry."PreAuth Entry Terminal");
        AllEntries.SetRange("PreAuth Entry No.", pPreAuthCardEntry."PreAuth Entry No.");
        AllEntries.ModifyAll(Closed, true);
    end;

    internal procedure UpdatePreAuth(var PreAuthCardEntry: Record "LSC POS Card Entry"; NewAmount: Decimal; var ErrorReason: Text): Boolean
    begin
        exit(UsePreAuth(CardEntry."Transaction Type"::UpdatePreAuth, PreAuthCardEntry, NewAmount, ErrorReason));
    end;

    internal procedure FinalizePreAuth(var PreAuthCardEntry: Record "LSC POS Card Entry"; NewAmount: Decimal; var ErrorReason: Text): Boolean
    begin
        exit(UsePreAuth(CardEntry."Transaction Type"::FinalizePreAuth, PreAuthCardEntry, NewAmount, ErrorReason));
    end;

    local procedure UsePreAuth(TransType: Integer; var PreAuthCardEntry: Record "LSC POS Card Entry"; NewAmount: Decimal; var ErrorReason: Text): Boolean
    begin
        if not (PreAuthCardEntry."Transaction Type" in [PreAuthCardEntry."Transaction Type"::PreAuth, PreAuthCardEntry."Transaction Type"::UpdatePreAuth]) then begin
            ErrorReason := StrSubstNo(TxtTransTypeCannotBeUsed, PreAuthCardEntry."Transaction Type");
            exit(false);
        end;

        if PreAuthCardEntry.Voided OR (not PreAuthCardEntry."Authorisation Ok") then begin
            ErrorReason := TxtTransNotAuthorized;
            exit(false);
        end;

        if PreAuthHasBeenCancelled(PreAuthCardEntry) then begin
            ErrorReason := TxtPreAuthAlreadyCancelled;
            exit(false);
        end;

        if PreAuthHasBeenFinalized(PreAuthCardEntry) then begin
            ErrorReason := TxtPreAuthAlreadyFinalized;
            exit(false);
        end;

        CardEntry."Transaction Type" := TransType;
        CardEntry."Line No." := PreAuthCardEntry."Line No.";

        SetReferencedReturns(PreAuthCardEntry);
        SetEFTAmountVariables(PreAuthCardEntry);

        if NewAmount > 0 then
            EFTAmount := NewAmount;

        CardEntry."PreAuth Entry Store" := PreAuthCardEntry."PreAuth Entry Store";
        CardEntry."PreAuth Entry Terminal" := PreAuthCardEntry."PreAuth Entry Terminal";
        CardEntry."PreAuth Entry No." := PreAuthCardEntry."PreAuth Entry No.";

        exit(true);
    end;

    internal procedure CloseEFTServer()
    begin
    end;

    internal procedure InitLogEntry(pReceiptNo: Code[20]): Integer
    var
        POSSESION: codeunit "LSC POS Session";
    begin
        if POSEFTRecord."Currency Code" <> '' then
            EFTCurrencyCode := POSEFTRecord."Currency Code";


        PosTerminal.reset();
        PosTerminal.setrange("Store No.", POSSESION.StoreNo());
        Posterminal.SetRange(PosTerminal."No.", POSSESION.TerminalNo());
        if Posterminal.findset() then begin

        end;
        //PosTerminal.setrange();

        CardEntry."Receipt No." := pReceiptNo;
        CardEntry."Store No." := PosTerminal."Store No.";
        CardEntry."POS Terminal No." := PosTerminal."No.";
        CardEntry."Entry No." := NextEntryNo;
        CardEntry."Tender Type" := CurrTenderType;
        CardEntry."EFT POS Terminal No." := PosTerminal."No.";
        CardEntry."EFT Store No." := PosTerminal."Store No.";
        CardEntry.Date := Today;
        CardEntry.Time := Time;
        CardEntry.Amount := EFTAmount;
        CardEntry.VAT := EFTVat;
        CardEntry.Cashback := EFTCashback;
        CardEntry.Surcharge := EFTSurcharge;
        CardEntry.Tip := EFTTip;
        CardEntry."EFT Currency" := EFTCurrencyCode;
        CardEntry.Message := '<processing>';
        CardEntry."EFT Device Name" := POSEFTRecord."EFT Device Name";
        CardEntry."EFT Server Host" := POSEFTRecord."EFT Server Host";
        if POSEFTRecord."Client Transaction ID Type" = POSEFTRecord."Client Transaction ID Type"::"10Digit" then
            Get10DigitClientTransID(CardEntry);
        CardEntry.Insert(true);
        Commit;
        exit(CardEntry."Entry No.");
    end;

    local procedure Get10DigitClientTransID(var pCardEntry: Record "LSC POS Card Entry")
    var
        TmpText: Text;
        TmpInt: Integer;
        TerminalNo: Integer;
        IsHandled: Boolean;
    begin
        // OnBeforeGet10DigitClientTransID(IsHandled, pCardEntry);
        // if IsHandled then
        //     exit;

        //New Client Trans ID (10 digit) //"POS Terminal No." must be valid number or end in valid 3 digit number
        TmpInt := StrLen(pCardEntry."POS Terminal No.");
        IF TmpInt > 2 then
            TmpText := CopyStr(pCardEntry."POS Terminal No.", TmpInt - 2)
        else
            TmpText := pCardEntry."POS Terminal No.";

        if not Evaluate(TerminalNo, TmpText) then
            exit;

        TmpText := Format(TerminalNo).PadLeft(3, '0');
        TmpText += Format(CardEntry."Entry No." MOD 9999999).PadLeft(7, '0');
        pCardEntry."Client Transaction ID" := TmpText;

        // OnAfterGet10DigitClientTransID(pCardEntry);
    end;

    internal procedure GetAmount(): Decimal
    begin
        exit(EFTAmount);
    end;

    internal procedure GetVat(): Decimal
    begin
        exit(EFTVat);
    end;

    internal procedure GetCashback(): Decimal
    begin
        exit(EFTCashback);
    end;

    internal procedure GetTip(): Decimal
    begin
        exit(EFTTip);
    end;

    internal procedure IsAuthCodeRequired(): Boolean
    begin
        exit(false);
    end;

    internal procedure GetMessage(): Text
    begin
        exit(EFTMessage);
    end;

    internal procedure IsErrorState(): Boolean
    begin
        exit(IsError);
    end;

    local procedure ProcessAddCardToFile()
    var
        IsHandled: Boolean;
    begin
        // OnBeforeProcessAddCardToFile(TokenData, IsHandled);
        // if IsHandled then
        //     exit;

        InitPage();

        StartEFTRequest(ADDCARDTOFILE, GetClientTransactionID(CardEntry));
        SetVar(varTransactionType, ADDCARDTOFILE);
        SetAmountBreakdown(EFTAmount, 0, EFTCashback, EFTSurcharge, EFTTip, EFTCurrencyCode);
        SetTokenDataVar(TokenData);
        SetVar(varToken, EFTToken);

        RunRequest(ADDCARDTOFILE);
        SaveResponse();
    end;

    local procedure ProcessPurchase()
    var
        LocalizationExt: Codeunit "LSC Retail Localization Ext.";
        POSTransaction: Codeunit "LSC POS Transaction";
        TransType_l: Text;
        IsHandled: Boolean;
        EBTTenderType: Text[20];
    begin
        // OnBeforeProcessPurchase(POSTerminal, EFTAmount, EFTResult, IsHandled, EFTCurrencyCode);
        // if IsHandled then
        //     exit;

        TransType_l := PURCHASE;
        if CardEntry."Transaction Type" = CardEntry."Transaction Type"::FinalizePreAuth then
            TransType_l := FINALIZE_PREAUTH;

        InitPage();

        StartEFTRequest(TransType_l, GetClientTransactionID(CardEntry));
        SetVar(varTransactionType, TransType_l);
        SetAmountBreakdown(EFTAmount, 0, EFTCashback, EFTSurcharge, EFTTip, EFTCurrencyCode);
        SetTokenDataVar(TokenData);
        SetVar(varManualEntry, EFTManualEntry);
        SetVar(varQRCode, EFTQRCode);
        SetVar(varAskGratuity, EFTAskGratuity);
        EBTTenderType := POSTransaction.GetTenderType();
        if EBTTenderType <> '' then
            SetVar(varTenderType, EBTTenderType);
        if LocalizationExt.IsAULocalizationEnabled() then
            SetVar(varEnablePLB, POSTransaction.GetPLBFlag(EFTAmount));
        if CardEntry."Transaction Type" = CardEntry."Transaction Type"::FinalizePreAuth then begin
            SetTransactionIdentification(ReferencedReturnsTemp);
            SetCardDetails(ReferencedReturnsTemp);
        end;
        RunRequest(TransType_l);
        SaveResponse();
    end;

    local procedure ProcessOfflinePurchase()
    var
        POSTransaction: Codeunit "LSC POS Transaction";
        EBTTenderType: Text[20];
    begin
        InitPage();
        StartEFTRequest(OFFLINEPURCHASE, GetClientTransactionID(CardEntry));
        SetVar(varTransactionType, PURCHASE); //TODO.. OfflinePurchase is not a Transaction Type?
        SetAmountBreakdown(EFTAmount, 0, EFTCashback, EFTSurcharge, EFTTip, EFTCurrencyCode);
        SetTokenDataVar(TokenData);
        SetVar(varToken, EFTToken);
        SetVar(varManualEntry, EFTManualEntry);
        SetVar(varQRCode, EFTQRCode);
        SetVar(varAskGratuity, EFTAskGratuity);
        EBTTenderType := POSTransaction.GetTenderType();
        if EBTTenderType <> '' then
            SetVar(varTenderType, EBTTenderType);
        RunRequest(OFFLINEPURCHASE);
        SaveResponse();
    end;

    local procedure ProcessRefund()
    var
        IsHandled: Boolean;
        POSTransaction: Codeunit "LSC POS Transaction";
        EBTTenderType: Text[20];
    begin
        // OnBeforeProcessRefund(POSTerminal, EFTAmount, EFTResult, IsHandled, EFTCurrencyCode);
        // if IsHandled then
        //     exit;

        InitPage();
        StartEFTRequest(REFUND, GetClientTransactionID(CardEntry));
        SetVar(varTransactionType, REFUND);
        SetAmountBreakdown(EFTAmount, 0, 0, 0, 0, EFTCurrencyCode);
        SetTokenDataVar(TokenData);
        SetVar(varToken, EFTToken);
        SetVar(varManualEntry, EFTManualEntry);
        SetVar(varQRCode, EFTQRCode);
        EBTTenderType := POSTransaction.GetTenderType();
        if EBTTenderType <> '' then
            SetVar(varTenderType, EBTTenderType)
        else
            SetVar(varTenderType, 'Unknown');
        SetTransactionIdentification(ReferencedReturnsTemp);
        SetCardDetails(ReferencedReturnsTemp);
        RunRequest(REFUND);
        SaveResponse();
    end;

    local procedure ProcessVoid()
    var
        TransType_l: Text;
        IsHandled: Boolean;
    begin
        OnBeforeVoid(POSTerminal, ReferencedReturnsTemp."EFT Transaction ID", EFTAmount, EFTTenderType, EFTResult, IsHandled, EFTCurrencyCode);
        if IsHandled then
            exit;

        InitPage();
        if CardEntry."Transaction Type" = CardEntry."Transaction Type"::CancelPreAuth then
            TransType_l := CANCEL_PREAUTH
        else
            TransType_l := VOID;
        StartEFTRequest(TransType_l, GetClientTransactionID(CardEntry));
        SetVar(varTransactionType, TransType_l);
        SetAmountBreakdown(EFTAmount, 0, 0, 0, 0, EFTCurrencyCode);
        SetTokenDataVar(TokenData);
        SetVar(varToken, EFTToken);
        SetVar(varManualEntry, EFTManualEntry);
        SetVar(varQRCode, EFTQRCode);
        SetVar(varTenderType, EFTTenderType);
        SetTransactionIdentification(ReferencedReturnsTemp);
        SetCardDetails(ReferencedReturnsTemp);
        //RunRequest(TransType_l);
        SaveResponse();
    end;

    internal procedure ShowLastTransactionInfo()
    begin
        ProcessGetLastTransaction();
        if not IsErrorState then
            ShowLastTransactionMessage();
    end;

    internal procedure PrintLastTransaction()
    var
        ClientTransID: Text;
    begin
        if PosTerminal."No." = '' then
            Error('EFT: EFT not initialized');
        ClearEFT(true);
        ProcessGetLastTransaction;
        if IsErrorState then
            exit;
        ClientTransID := GetVar(varClientTransactionID);
        if PrintEFTPending('') then
            PrintPendingLines(TxtReceiptCOPY)
        else
            ReprintLastTrans(); //On PED
    end;

    procedure PrintPendingLinesCopy(ClientTransID_p: Text): Boolean
    begin
        RetrievePrintLines(GetReceiptNoFromClientTransID(ClientTransID_p));
        if not PrintEFTPending('') then
            exit(false);

        PrintPendingLines(TxtReceiptCOPY);
        exit(true);
    end;

    local procedure ReprintLastTrans()
    begin
        ClearEFT(true);
        InitPage();
        StartEFTRequest(REPRINTLAST, '');
        RunRequest(REPRINTLAST);
    end;

    internal procedure ProcessGetLastTransaction()
    begin
        InitPage();
        StartEFTRequest(GETLASTTRANS, '');
        RunRequest(GETLASTTRANS);
        SaveResponse();
    end;

    local procedure ShowLastTransactionMessage()
    var
        LastTransMessage: Text;
        Handled: Boolean;
    begin
        //  OnShowLastTransactionMessage(LastTransMessage, Handled);

        if not Handled then begin
            LastTransMessage := 'EFT Transaction ID: ' + GetVar(varEFTTransactionID) + '\' +
            'Client Transaction ID: ' + GetVar(varClientTransactionID) + '\' +
            'Transaction Time: ' + GetVar(varEFTTransDateTime) + '\' +
            'Card Type: ' + GetVar(varTenderType) + '\' +
            'Authorization Status: ' + GetVar(varAuthorizationStatus) + '\' +
            'Total Amount: ' + GetVar(varTotalAmount) + '\' +
            'AdditionalID: ' + GetVar(varEFTAdditionalID);
        end;

        Message(LastTransMessage)
    end;

    internal procedure ProcessXReport()
    begin
        ClearEFT(true);
        InitPage();
        StartEFTRequest(XREPORT, '');
        RunRequest(XREPORT);
        SaveResponse();
        PrintPendingLines('X-REPORT');
    end;

    internal procedure ProcessZReport()
    begin
        ClearEFT(true);
        InitPage();
        StartEFTRequest(ZREPORT, '');
        RunRequest(ZREPORT);
        SaveResponse();
        PrintPendingLines('Z-REPORT');
    end;

    internal procedure StartSession(TransactionId: Text)
    begin
        InitPage();
        StartEFTRequest(STARTSESS, TransactionId);
        RunRequest(STARTSESS);
    end;

    internal procedure FinishSession(TransactionId: Text)
    begin
        InitPage();
        StartEFTRequest(FINISHSESS, TransactionId);
        RunRequest(FINISHSESS);
    end;

    procedure DirectIO(Command: Integer; var Data: Integer; var StringData: Text)
    begin
        // ClearEFT(true);
        // InitPage();
        // PEFT.DirectIO(Command, Data, StringData);
        // PEFT.RunModal;

        // IsError := PEFT.IsError();
        // EFTMessage := CopyStr(PEFT.GetResultMessage, 1, 200);

        // if not IsError then
        //     PEFT.GetDirectIOResponse(Data, StringData)
    end;

    procedure RetrievePrintLines(ReceiptNo_p: Code[20])
    begin
        RetrievePrintLines(ReceiptNo_p, false, false);
    end;

    internal procedure RetrievePrintLines(ReceiptNo_p: Code[20]; ForceMerchantPrint: Boolean; ForceCustomerPrint: Boolean)
    var
        i: Integer;
        n: Integer;
        PrintMerchantReceipt: Boolean;
        PrintCustomerReceipt: Boolean;
        IsHandled: Boolean;
    begin
        // OnBeforeRetrievePrintLines(EFTPrintLine, IsHandled);
        // if IsHandled then
        //     exit;

        if ReceiptNo_p = '' then
            ReceiptNo_p := CardEntry."Receipt No.";

        Clear(EFTPrintLine);
        EFTPrintLine."Store No." := PosTerminal."Store No.";
        EFTPrintLine."POS Terminal No." := PosTerminal."No.";
        SetNextPrintLineNo(-1, ReceiptNo_p, '');

        PrintNode('ReportResponse.Receipt.Lines.', true);

        PrintMerchantReceipt := (GetVar('MerchantReceipt.Mandatory') = 'true') or (not PosTerminal."Skip Merchant Receipt") or ForceMerchantPrint;

        if PosTerminal."Slip Print Order" = "LSC Slip Print Order"::"Merchant then Customer" then begin
            //  OnBeforePrintMerchantReceipt(CardEntry, PrintMerchantReceipt);
            if PrintMerchantReceipt then
                PrintNode('MerchantReceipt.Lines.', true);
        end;

        PrintCustomerReceipt := (GetVar('CustomerReceipt.Mandatory') = 'true') or (not PosTerminal."Skip Customer Receipt") or ForceCustomerPrint;
        if PrintCustomerReceipt then begin
            n := CountNodes('CustomerReceipt.Lines');
            if n > 0 then begin
                if (EFTResult = 1) and PosTerminal."EFT Embedded Receipt" then begin
                    SetNextPrintLineNo(0, ReceiptNo_p, 'E'); //0 is used for Embedded print only
                end;
                if EFTPrintLine.Destination = '' then
                    PrintEFTLine('')
                else
                    PrintEFTLine('________________________________________');
                for i := 1 to n do begin
                    PrintEFTLineEx(GetVar('CustomerReceipt.Lines.' + Format(i) + '.Line'),
                        FontSizeTextToInt(GetVar('CustomerReceipt.Lines.' + Format(i) + '.TextSize')),
                        FontWeightTextToInt(GetVar('CustomerReceipt.Lines.' + Format(i) + '.TextWeight')));
                end;
                PrintEFTLine('');
                if EFTPrintLine.Destination = '' then
                    PrintEFTLine('');
                PrintEFTLine('<cut>');
            end;
        end;

        if PosTerminal."Slip Print Order" = "LSC Slip Print Order"::"Customer then Merchant" then begin
            if PrintMerchantReceipt then begin
                SetNextPrintLineNo(-1, ReceiptNo_p, '');
                PrintNode('MerchantReceipt.Lines.', true);
            end;
        end;

        if not POSEFTRecord."Discard Print Slips" then begin
            //Persistent storage of receipts on successful authorisations
            if (EFTResult = 1) or (CurrentEFTTransactionType in [XREPORT, ZREPORT]) then begin //SAVE X/Z REPORTS..
                SetNextPrintLineNo(1, ReceiptNo_p, 'R');
                PrintNode('ReportResponse.Receipt.Lines.', false);
                PrintNode('CustomerReceipt.Lines.', false);
                PrintNode('MerchantReceipt.Lines.', false);
            end;
        end;
    end;

    local procedure PrintNode(NodeName: Text; ForPrinting: Boolean)
    var
        i: Integer;
        n: Integer;
    begin
        n := CountNodes(NodeName);
        if n > 0 then begin
            if ForPrinting then
                PrintEFTLine('');
            for i := 1 to n do begin
                PrintEFTLineEx(GetVar(NodeName + Format(i) + '.Line'),
                  FontSizeTextToInt(GetVar(NodeName + Format(i) + '.TextSize')),
                  FontWeightTextToInt(GetVar(NodeName + Format(i) + '.TextWeight')));
            end;
            if ForPrinting then begin
                PrintEFTLine('');
                PrintEFTLine('');
                PrintEFTLine('<cut>');
            end
        end;
    end;

    internal procedure PrintEFT(Txt: Text)
    var
        i: Integer;
        Txt2: Text;
    begin
        repeat
            i := StrPos(Txt, CRLF);
            if i <> 0 then begin
                Txt2 := CopyStr(Txt, 1, i - 1);
                PrintEFTLine(Txt2);
                Txt := CopyStr(Txt, i + 2);
            end
            else
                PrintEFTLine(Txt);
        until i = 0;
    end;

    internal procedure PrintEFTLine(txt: Text)
    begin
        PrintEFTLineEx(txt, 1, 0); //Medium, Normal
    end;

    internal procedure PrintEFTLineEx(Txt: Text; FontSize: Option Small,Medium,Large,Big; FontWeight: Option Normal,Bold)
    begin
        while StrLen(Txt) > 80 do begin
            EFTPrintLine."Line No." := EFTPrintLine."Line No." + 1;
            EFTPrintLine.Description := CopyStr(Txt, 1, 80); //MAX
            EFTPrintLine.FontSize := FontSize;
            EFTPrintLine.FontWeight := FontWeight;
            EFTPrintLine.Insert;
            Txt := CopyStr(Txt, 81);
        end;
        EFTPrintLine."Line No." := EFTPrintLine."Line No." + 1;
        EFTPrintLine.Description := CopyStr(Txt, 1, 80);
        EFTPrintLine.FontSize := FontSize;
        EFTPrintLine.FontWeight := FontWeight;
        EFTPrintLine.Insert;
    end;

    internal procedure PrintEFTPending(Typ: Text[5]): Boolean
    var
        EFTPrintLine: Record "LSC POS Card Print Text";
    begin
        EFTPrintLine.SetRange("Store No.", PosTerminal."Store No.");
        EFTPrintLine.SetRange("POS Terminal No.", PosTerminal."No.");
        EFTPrintLine.SetRange("File No.", -1);
        exit(not EFTPrintLine.IsEmpty);
    end;

    internal procedure PrintEFTPurge(Typ: Text[5])
    var
        EFTPrintLine: Record "LSC POS Card Print Text";
    begin
        EFTPrintLine.SetRange("Store No.", PosTerminal."Store No.");
        EFTPrintLine.SetRange("POS Terminal No.", PosTerminal."No.");
        EFTPrintLine.SetRange("File No.", -1);
        EFTPrintLine.DeleteAll;
        Commit;
    end;

    local procedure SetNextPrintLineNo(FileNo: Integer; ReceiptNo: Code[20]; Destination: Text[5])
    begin
        EFTPrintLine."File No." := FileNo;
        EFTPrintLine.SetRange("Store No.", EFTPrintLine."Store No.");
        EFTPrintLine.SetRange("POS Terminal No.", EFTPrintLine."POS Terminal No.");
        EFTPrintLine.SetRange("File No.", EFTPrintLine."File No.");
        if not EFTPrintLine.FindLast then
            EFTPrintLine."Line No." := 1
        else
            EFTPrintLine."Line No." := EFTPrintLine."Line No." + 1;
        EFTPrintLine."Receipt No." := ReceiptNo;
        EFTPrintLine.Destination := Destination;
    end;

    local procedure SaveResponse()
    var
        TxtResultCode: Text;
    begin

        EFTMessage := 'Approved';
        TxtResultCode := '';
        EFTMessage := 'Approved';
        EFTResult := 1;

        // EFTMessage := CopyStr(PEFT2.GetResultMessage, 1, 200);
        // EFTResult := PEFT2.GetResult;
        // CurrentEFTTransactionType := PEFT2.GetTransactionType();
        // EFTTenderType := GetVar(varTenderType);
        // EFTToken := GetVar(varToken);
        // GetTokenDataResponse(TokenData);
        // TxtResultCode := GetVar(varResultCode);
        // if TxtResultCode = '' then
        //     IsError := PEFT2.IsError()
        // else
        //     IsError := TxtResultCode = 'Error';

        // if CountNodes(varAmountBreakdown) > 1 then begin
        //     if Evaluate(EFTAmount, GetVar(varTotalAmount), 9) then;        //9 = XML/JSON ?
        //     if Evaluate(EFTCashback, GetVar(varCashbackAmount), 9) then;
        //     if Evaluate(EFTVat, GetVar(varTaxAmount), 9) then;
        //     if Evaluate(EFTSurchargeFromPed, GetVar(varSurchargeAmount), 9) then;
        //     if Evaluate(EFTTipFromPed, GetVar(varTipAmount), 9) then;
        //     if Evaluate(EFTCurrencyCode, GetVar(varCurrencyCode), 9) then
        //         if not (EFTCurrencyCode in ['', 'XXX']) then //XXX = Unknown
        //             if not (CardEntry."EFT Currency" in [EFTCurrencyCode, '', 'XXX']) then
        //                 Message(TxtCurrencyWarning);
        // end;

        RetrievePrintLines(CardEntry."Receipt No.");
        Commit;
    end;

    local procedure InitPage()
    begin
        // Commit;
        // IsError := false;
        // EFTResult := 0;
        // Clear(PEFT2);
        // PEFT2.SetEFTDevice(POSEFTRecord);
    end;

    internal procedure ProcessTipAmount(ReceiptNo: Text; SuggestedLineNo: Integer): Integer
    var
        Store: Record "LSC Store";
        PosTr: Record "LSC POS Transaction";
        IncExp: Record "LSC Income/Expense Account";
        PosLine: Record "LSC POS Trans. Line";
        TipAmountFromPed: Decimal;
    begin
        if (EFTTipFromPed = 0) or (EFTTipFromPed = EFTTip) then
            exit(0);

        //Tip Amount has been modified in process
        TipAmountFromPed := EFTTipFromPed - EFTTip;

        Store.Get(PosTerminal."Store No.");
        PosTr.Get(ReceiptNo);
        PosTr.TestField("Store No.", PosTerminal."Store No.");
        PosTr.TestField("POS Terminal No.", PosTerminal."No.");

        IncExp.SetRange("Store No.", PosTerminal."Store No.");
        IncExp.SetRange("Account Type", IncExp."Account Type"::Income);
        IncExp.SetRange("Gratuity Type", IncExp."Gratuity Type"::Tips);
        if not IncExp.FindFirst then begin
            POSGUI.PosConfirm(StrSubstNo(TxtNoTipAccountError, IncExp.TableCaption, IncExp.FieldCaption("Gratuity Type"), Format(IncExp."Gratuity Type"::Tips), PosTerminal."Store No."), false);
            exit(0);
        end;

        if SuggestedLineNo = 0 then
            SuggestedLineNo := 5;

        while PosLine.Get(PosTr."Receipt No.", SuggestedLineNo) do
            SuggestedLineNo += 1;

        PosLine.Init;
        PosLine."Receipt No." := PosTr."Receipt No.";
        PosLine."Store No." := PosTr."Store No.";
        PosLine."POS Terminal No." := PosTr."POS Terminal No.";
        PosLine."Line No." := SuggestedLineNo;
        PosLine."Entry Type" := PosLine."Entry Type"::IncomeExpense;
        PosLine.Validate(Number, IncExp."No.");
        PosLine.Validate(Price, TipAmountFromPed);
        PosLine.Validate(Quantity, 1);

        if PosLine."Card Entry No." = 0 then
            PosLine."Card Entry No." := CardEntry."Entry No.";

        PosLine.CalcPrices;
        PosLine.Insert(true);
        exit(SuggestedLineNo);
    end;

    internal procedure ProcessServiceChargeAmount(ReceiptNo: Text; SuggestedLineNo: Integer): Integer
    var
        Store: Record "LSC Store";
        PosTr: Record "LSC POS Transaction";
        IncExp: Record "LSC Income/Expense Account";
        PosLine: Record "LSC POS Trans. Line";
        SurchargeFromPed: Decimal;
    begin
        if (EFTSurchargeFromPed = 0) or (EFTSurchargeFromPed = EFTSurcharge) then
            exit(0);

        //Amount has been modified in process
        SurchargeFromPed := EFTSurchargeFromPed - EFTSurcharge;

        Store.Get(PosTerminal."Store No.");
        PosTr.Get(ReceiptNo);
        PosTr.TestField("Store No.", PosTerminal."Store No.");
        PosTr.TestField("POS Terminal No.", PosTerminal."No.");

        IncExp.SetRange("Store No.", PosTerminal."Store No.");
        IncExp.SetRange("Account Type", IncExp."Account Type"::Income);
        IncExp.SetRange("Gratuity Type", IncExp."Gratuity Type"::"Service Charge");
        if not IncExp.FindFirst then begin
            POSGUI.PosConfirm(StrSubstNo(TxtNoTipAccountError, IncExp.TableCaption, IncExp.FieldCaption("Gratuity Type"), Format(IncExp."Gratuity Type"::"Service Charge"), PosTerminal."Store No."), false);
            exit(0);
        end;

        if SuggestedLineNo = 0 then
            SuggestedLineNo := 8;

        while PosLine.Get(PosTr."Receipt No.", SuggestedLineNo) do
            SuggestedLineNo += 1;

        PosLine.Init;
        PosLine."Receipt No." := PosTr."Receipt No.";
        PosLine."Store No." := PosTr."Store No.";
        PosLine."POS Terminal No." := PosTr."POS Terminal No.";
        PosLine."Line No." := SuggestedLineNo;
        PosLine."Entry Type" := PosLine."Entry Type"::IncomeExpense;
        PosLine.Validate(Number, IncExp."No.");
        PosLine.Validate(Price, SurchargeFromPed);
        PosLine.Validate(Quantity, 1);

        if PosLine."Card Entry No." = 0 then
            PosLine."Card Entry No." := CardEntry."Entry No.";

        PosLine.CalcPrices;
        PosLine.Insert(true);
        exit(SuggestedLineNo);
    end;

    internal procedure UseNumpad(): Boolean
    begin
        exit(PosTerminal."Use Numpad");
    end;

    internal procedure AllwaysIncludeTips(): Boolean
    begin
        exit(PosTerminal."Tips handling" = "LSC Tips handling"::Include);
    end;

    internal procedure AskToIncludeTips(): Boolean
    begin
        exit(PosTerminal."Tips handling" = "LSC Tips handling"::Ask);
    end;

    procedure SetCardType(var CardEntryRec: Record "LSC POS Card Entry"): Code[10]
    begin
        if POSEFTRecord."Card Type handling" = POSEFTRecord."Card Type handling"::"Use Card No. Series" then begin
            SetCardTypeNameFromNoSeries(CardEntryRec);
        end
        else begin
            CardEntryRec."Card Type Name" := GetVar(varCardIssuer);

            if CardEntryRec."Card Type" = '' then begin
                if not SetCardTypeFromEFTMapping(CardEntryRec) then
                    CardEntryRec."Card Type" := CopyStr(CardEntryRec."Card Type Name", 1, 10);
            end;
        end;
    end;

    internal procedure SetCardTypeNameFromNoSeries(var CardEntryRec: Record "LSC POS Card Entry")
    var
        CardNumbers: Record "LSC Tender TP Card No. Series";
        CardNoSeriesRecID: RecordID;
        MaskedCardNo_fromPED: Text;
        EFTCardType: Text;
        EFTCardTypeName: Text;
    begin
        MaskedCardNo_fromPED := CardEntryRec."Card Number";

        if GetCardNoSerieFromCardNo(CardEntryRec."Store No.", MaskedCardNo_fromPED, CardNoSeriesRecID) then begin
            CardNumbers.Get(CardNoSeriesRecID);
            EFTCardType := CardNumbers."Card No.";
            EFTCardTypeName := CardNumbers.Description;
        end;

        if EFTCardType = '' then
            EFTCardType := POSEFTRecord."Default Card Type";

        CardEntryRec."Card Type" := EFTCardType;
        if EFTCardTypeName <> '' then
            CardEntryRec."Card Type Name" := EFTCardTypeName;
    end;

    local procedure SetCardTypeFromEFTMapping(var CardEntryRec: Record "LSC POS Card Entry"): Boolean
    var
        MappingSetup: Record "LSC EFT Card Type Mapping";
    begin
        MappingSetup.SetFilter("EFT Card Type", '%1|%2', CardEntryRec."Card Type Name", '');
        MappingSetup.SetFilter("Card Type", '<>%1', '');
        if MappingSetup.FindLast then begin
            CardEntryRec."Card Type" := MappingSetup."Card Type";
            exit(true);
        end;
    end;

    procedure GetCardNoSerieFromCardNo(StoreNo: Code[10]; MaskedCardNo: Text; var CardNoSeriesRecID: RecordID): Boolean
    var
        CardNumbers: Record "LSC Tender TP Card No. Series";
        CardNoFirstDigit: Text;
        MaxNoOfDigits: Integer;
        AstPos: Integer;
    begin
        MaxNoOfDigits := 6;
        if POSEFTRecord."Pan No. Digits used" > 0 then
            MaxNoOfDigits := POSEFTRecord."Pan No. Digits used";

        AstPos := StrPos(MaskedCardNo, '*');
        if AstPos > 0 then
            CardNoFirstDigit := CopyStr(CopyStr(MaskedCardNo, 1, AstPos - 1), 1, MaxNoOfDigits)
        else
            CardNoFirstDigit := CopyStr(MaskedCardNo, 1, MaxNoOfDigits);

        if StoreNo = '' then
            StoreNo := PosTerminal."Store No.";

        CardNumbers.Reset;
        CardNumbers.SetRange("Store No.", StoreNo);
        if CardNumbers.Find('-') then
            repeat
                if (CardNumbers."Card Series From" <= CardNoFirstDigit) and
                  (CardNumbers."Card Series To" >= CardNoFirstDigit) then begin //MATCH
                    CardNoSeriesRecID := CardNumbers.RecordId;
                    exit(true);
                end;
            until CardNumbers.Next = 0;

        exit(false);
    end;

    procedure PrintPendingLines(SlipNoText: Text)
    var
        PrintUtil: Codeunit "LSC POS Print Utility";
        Retry: Boolean;
        Ok: Boolean;
    begin
        if PrintEFTPending('') then
            repeat
                Retry := false;
                PrintUtil.Init();
                Ok := PrintUtil.PrintCardSlipFromEFT('', SlipNoText);
                if not Ok then begin
                    if POSGUI.PosConfirm(PrintUtil.GetPrintErrorTxt + '\' + TxtRetryPrinting, true) then
                        Retry := true
                    else
                        Message(PrintUtil.GetPrintErrorTxt);
                end
            until not Retry;

        PrintEFTPurge('');
    end;

    local procedure FontSizeTextToInt(txt: Text): Integer
    begin
        case txt of
            'SMALL':
                exit(0);
            'MEDIUM':
                exit(1);
            'LARGE':
                exit(2);
            'BIG':
                exit(3);
        end;
        exit(1);
    end;

    local procedure FontWeightTextToInt(txt: Text): Integer
    begin
        case txt of
            'NORMAL':
                exit(0);
            'BOLD':
                exit(1);
        end;
        exit(0);
    end;

    internal procedure DisableVoidCardPrompt(): Boolean
    begin
        exit(PosTerminal."Disable Void Card Prompt");
    end;

    internal procedure PostTransactionAfterVoid(): Boolean
    begin
        exit(PosTerminal."Post Transaction after Void");
    end;

    procedure CalculateSurcharge(Amount_p: Decimal; var ChargeSetup_p: Record "LSC Charge Setup") Surcharge: Decimal
    begin
        if Amount_p <= ChargeSetup_p."Amount without Charge" then
            exit;

        if ChargeSetup_p."Rate Type" = ChargeSetup_p."Rate Type"::"% Rate of Payment" then
            Surcharge := (ChargeSetup_p.Rate / 100) * Amount_p
        else
            Surcharge := ChargeSetup_p.Rate;

        if Surcharge < ChargeSetup_p."Min. Charge" then
            Surcharge := ChargeSetup_p."Min. Charge";

        if (ChargeSetup_p."Max. Charge" > 0) and (Surcharge > ChargeSetup_p."Max. Charge") then
            Surcharge := ChargeSetup_p."Max. Charge";
    end;

    internal procedure GetFailedRequest(ReceiptNo_p: Code[20]; var CardEntry_p: Record "LSC POS Card Entry"): Boolean
    begin
        if ReceiptNo_p = '' then
            exit(false);

        exit(GetFailedRequest('', ReceiptNo_p, CardEntry_p));
    end;

    internal procedure GetFailedRequest(TerminalNo_p: Code[10]; ReceiptNo_p: Code[20]; var CardEntry_p: Record "LSC POS Card Entry"): Boolean
    var
        Terminal_l: Record "LSC POS Terminal";
    begin
        if POSEFTRecord.IsEmpty then
            exit(false);

        if POSEFTRecord."Error Recovery" = POSEFTRecord."Error Recovery"::Off then
            exit(false);

        if CardEntry_p.IsTemporary then
            exit(false);

        CardEntry_p.Reset;
        CardEntry_p.SetCurrentKey("Store No.", "POS Terminal No.", "Receipt No.");
        if Terminal_l.Get(TerminalNo_p) then begin
            CardEntry_p.SetRange("Store No.", Terminal_l."Store No.");
            CardEntry_p.SetRange("POS Terminal No.", Terminal_l."No.");
        end;
        CardEntry_p.SetRange("Receipt No.", ReceiptNo_p);
        if CardEntry_p.FindLast then begin //Only Check Last Card Entry logged for this ReceiptNo
                                           //IF pCardEntry."Auth.code" = '' THEN //Should not have got Auth Code?  //OR IS THIS SOMETIMES EMPTY ??
            if not IsRecoveryAllowed(CardEntry_p) then
                exit(false);

            if CardEntry_p."Res.code" <> 'Success' then //Should indicate that Error occured ("Res. Code" is Error or Empty or some intermediate state)
                if CardEntry_p."Recovery Attempt" = 0DT then //Recovery Has not been attempted
                    exit(true);
        end;

        //NO ERROR ENTRY FOUND
        Clear(CardEntry_p);
        exit(false);
    end;

    local procedure IsRecoveryAllowed(CardEntry: Record "LSC POS Card Entry"): Boolean
    begin
        if CardEntry."Transaction Type" = CardEntry."Transaction Type"::AddCardToFile then
            exit(false);

        exit(true);
    end;

    internal procedure RecoverFailedRequest(var FailedCardEntry_p: Record "LSC POS Card Entry"; var ErrorMessage_p: Text): Boolean
    var
        CardEntryRec_l: Record "LSC POS Card Entry";
        LastEFTTransId: Text;
        LastClientTransId: Text;
        LastEFTTransType: Text;
    begin
        LastClientTransId := GetVar(varClientTransactionID);
        if LastClientTransId <> '' then begin
            if GetClientTransactionID(FailedCardEntry_p) <> LastClientTransId then begin
                ErrorMessage_p := StrSubstNo(TxtLastTransIDMismatch, LastClientTransId, GetClientTransactionID(FailedCardEntry_p));
                exit(false);
            end;
        end;

        LastEFTTransId := GetVar(varEFTTransactionID);
        if LastEFTTransId = '' then begin
            ErrorMessage_p := StrSubstNo(TxtLastTransInfoMissing, 'EFT Transaction ID');
            exit(false);
        end;

        CardEntryRec_l.SetCurrentKey("EFT Transaction ID", "EFT Auth.code");
        CardEntryRec_l.SetRange("EFT Transaction ID", LastEFTTransId);
        if CardEntryRec_l.FindFirst then begin //Already Logged this EFT Transaction ID
            ErrorMessage_p := TxtLastTransAlreadyExists;
            exit(false);
        end;

        //CHECK 2: See Card Entry matches the Last Transaction from EFT -->
        LastEFTTransType := GetVar(varTransactionType);

        if LastEFTTransType <> '' then begin
            if (CardEntry."Transaction Type" = CardEntry."Transaction Type"::Sale) and (LastEFTTransType <> PURCHASE) then begin
                ErrorMessage_p := StrSubstNo(TxtLastTransTypeMismatch, LastEFTTransType, PURCHASE);
                exit(false);
            end;
            if (CardEntry."Transaction Type" = CardEntry."Transaction Type"::Refund) and (LastEFTTransType <> REFUND) then begin
                ErrorMessage_p := StrSubstNo(TxtLastTransTypeMismatch, LastEFTTransType, REFUND);
                exit(false);
            end;
            if (CardEntry."Transaction Type" = CardEntry."Transaction Type"::"Void Sale") and (LastEFTTransType <> VOID) then begin
                ErrorMessage_p := StrSubstNo(TxtLastTransTypeMismatch, LastEFTTransType, VOID);
                exit(false);
            end;
            if (CardEntry."Transaction Type" = CardEntry."Transaction Type"::PreAuth) and (LastEFTTransType <> PREAUTH) then begin
                ErrorMessage_p := StrSubstNo(TxtLastTransTypeMismatch, LastEFTTransType, PREAUTH);
                exit(false);
            end;
            if (CardEntry."Transaction Type" = CardEntry."Transaction Type"::CancelPreAuth) and (LastEFTTransType <> CANCEL_PREAUTH) then begin
                ErrorMessage_p := StrSubstNo(TxtLastTransTypeMismatch, LastEFTTransType, CANCEL_PREAUTH);
                exit(false);
            end;
            if (CardEntry."Transaction Type" = CardEntry."Transaction Type"::UpdatePreAuth) and (LastEFTTransType <> UPDATE_PREAUTH) then begin
                ErrorMessage_p := StrSubstNo(TxtLastTransTypeMismatch, LastEFTTransType, UPDATE_PREAUTH);
                exit(false);
            end;
        end;

        //IF ClientTransactionID was empty we need confirmation from Cashier
        if LastClientTransId = '' then begin
            if not Confirm(StrSubstNo(TxtLastTransVerifyRecovery, LastEFTTransType,
                                                                    GetVar(varCardNumber),
                                                                    GetVar(varTotalAmount),
                                                                    LastEFTTransId,
                                                                    GetVar(varEFTTransDateTime),
                                                                    GetVar(varClientTransactionID))) then begin
                ErrorMessage_p := TxtLastTransRecoveryCancelled;
                exit(false);
            end;
        end;
        //OK Assuming this is a match.. start Recovery

        //Mark the failed Entry as recovered and create new copy
        Clear(CardEntry);
        CardEntry.Copy(FailedCardEntry_p);
        CardEntry."Entry No." := NextEntryNo;
        CardEntry."Recovered Entry No." := FailedCardEntry_p."Entry No.";
        CardEntry.Date := Today;
        CardEntry.Time := Time;
        CardEntry.Message := '<recovering>';
        CardEntry.Insert(true);

        FailedCardEntry_p."Recovery Attempt" := CurrentDateTime;
        FailedCardEntry_p.Modify;

        InsertLogEntry(); //Finalize logging of transaction

        FailedCardEntry_p := CardEntry; //Return with new Card Entry
        exit(true);
    end;

    local procedure GetClientTransactionID(var pCardEntry: Record "LSC POS Card Entry"): Text
    begin
        if pCardEntry."Client Transaction ID" <> '' then //New 10 Digit ID
            exit(pCardEntry."Client Transaction ID");

        //Old Client Trans ID (21+alphanumeric)
        exit(Format(pCardEntry."Entry No.") + ',' + pCardEntry."Receipt No.");
    end;

    procedure GetReceiptNoFromClientTransID(var ClientTransID_p: Text): Text
    var
        i: Integer;
        CardEntry_l: Record "LSC POS Card Entry";
    begin
        i := StrPos(ClientTransID_p, ',');
        if i > 0 then
            exit(SelectStr(2, ClientTransID_p));

        if StrLen(ClientTransID_p) = 10 then begin
            CardEntry_l.SetCurrentKey("Client Transaction ID");
            CardEntry_l.SetRange("Client Transaction ID", ClientTransID_p);
            if CardEntry_l.FindFirst() then
                exit(CardEntry_l."Receipt No.");
        end;

        exit(ClientTransID_p);
    end;

    local procedure RunRequest(RequestType: Text)
    var
        Jo: JsonObject;
        Handled: Boolean;
        EntryNo: Integer;
    begin
        PEFT2.GetRequestJson(Jo);
        OnBeforeEFTRequest(POSTerminal."No.", RequestType, Jo, Handled, CardEntry, PEFT2);
        if (Handled) then
            exit;

        EntryNo := CardEntry."Entry No.";
        if EntryNo = 0 then begin
            EntryNo := NextEntryNo - 1;
        end;
        SetCardEntryAndTerminal(EntryNo, PosTerminal."No.");
        if AutoTestMode then begin
            OnAutoTestEFTRequest(POSTerminal."No.", RequestType, Jo);
        end
        else begin
            PEFT2.RunModal;
            PEFT2.GetResponseJson(Jo);
        end;
        OnAfterEFTRequest(POSTerminal."No.", RequestType, Jo);
    end;

    local procedure ProcessPreAuth()
    begin
        InitPage();
        StartEFTRequest(PREAUTH, GetClientTransactionID(CardEntry));
        SetAmountBreakdown(EFTAmount, 0, 0, 0, 0, EFTCurrencyCode);
        SetTokenDataVar(TokenData);
        SetVar(varToken, EFTToken);
        SetVar(varQRCode, EFTQRCode);
        //SetVar('TenderType', 'Unknown');
        RunRequest(PREAUTH);
        SaveResponse();
    end;

    local procedure ProcessUpdatePreAuth()
    begin
        InitPage();
        StartEFTRequest(UPDATE_PREAUTH, GetClientTransactionID(CardEntry));
        SetAmountBreakdown(EFTAmount, 0, 0, 0, 0, EFTCurrencyCode);
        SetTokenDataVar(TokenData);
        SetVar(varToken, EFTToken);
        SetVar(varManualEntry, EFTManualEntry);
        SetVar(varQRCode, EFTQRCode);
        SetTransactionIdentification(ReferencedReturnsTemp);
        SetCardDetails(ReferencedReturnsTemp);
        //SetVar(varTenderType, 'Unknown');
        // RunRequest(UPDATE_PREAUTH);
        SaveResponse();
    end;

    procedure PrintBuffer(PrinterID_p: Text; var pPrintBufferRecRef_p: RecordRef; var ErrorText_p: Text): Boolean
    var
        IsHandled: Boolean;
        ReturnValue: Boolean;
    begin
        // OnBeforePrintBuffer(PrinterID_p, pPrintBufferRecRef_p, ReturnValue, ErrorText_p, IsHandled);
        // if IsHandled then
        //     exit(ReturnValue);

        // InitPage();
        // StartEFTRequest(PRINTRECEIPT, GetClientTransactionID(CardEntry));
        // PEFT2.SetPrintBuffer(pPrintBufferRecRef_p);

        // RunRequest(PRINTRECEIPT);
        // ErrorText_p := PEFT2.GetResultMessage();
        // ReturnValue := not PEFT2.IsError;
        // exit(ReturnValue);
    end;

    //Dialog Wrapping Functions
    procedure GetVar(name: Text): Text
    var
        AutoTestValue: Text;
        Handled: Boolean;
    begin
        // if AutoTestMode then begin
        //     OnAutoTestGetVar(name, AutoTestValue, Handled);
        //     if Handled then
        //         exit(AutoTestValue);
        // end;

        // exit(PEFT2.GetVar(name))
    end;

    local procedure CountNodes(NodeName: Text): Integer
    begin
        //exit(PEFT2.CountNodes(NodeName))
    end;

    local procedure StartEFTRequest(RequestType_p: Text; TransactionID_p: Text)
    begin
        //PEFT2.StartEFTRequest(RequestType_p, TransactionID_p);
    end;

    local procedure SetAmountBreakdown(Amount_p: Decimal; TaxAmount_p: Decimal; CashbackAmount_p: Decimal; SurchargeAmount_p: Decimal; TipAmount_p: Decimal; pCurrencyCode: Code[10])
    begin
        PEFT2.SetAmountBreakdown(Amount_p, TaxAmount_p, CashbackAmount_p, SurchargeAmount_p, TipAmount_p, pCurrencyCode)
    end;

    procedure SetVar(Property_p: Text; Value_p: Text)
    begin
        PEFT2.SetVar(Property_p, Value_p);
    end;

    local procedure SetVar(Property_p: Text; Value_p: Decimal)
    begin
        PEFT2.SetVar(Property_p, Value_p);
    end;

    local procedure SetVar(Property_p: Text; Value_p: Integer)
    begin
        PEFT2.SetVar(Property_p, Value_p);
    end;

    local procedure SetVar(Property_p: Text; Value_p: Boolean)
    begin
        PEFT2.SetVar(Property_p, Value_p);
    end;

    local procedure SetCardEntryAndTerminal(CardEntryNo_p: Integer; TerminalNo_p: Code[10])
    begin
        PEFT2.SetCardEntryAndTerminal(CardEntryNo_p, TerminalNo_p);
    end;

    local procedure SetTransactionIdentification(var ReferencedInformationTemp: Record "LSC Referenced Returns")
    begin
        PEFT2.SetTransactionIdentification(CreateReferencedReturnJson(ReferencedInformationTemp));
    end;

    local procedure SetCardDetails(var ReferencedInformationTemp: Record "LSC Referenced Returns")
    begin
        PEFT2.SetCardDetails(CreateCardDetailsJson(ReferencedInformationTemp));
    end;

    #region Token Data

    internal procedure ClearTokenData()
    begin
        Clear(TokenData);
    end;

    local procedure SetTokenDataVar(TokenData_p: Record "LSC Token")
    begin
        PEFT2.SetTokenDataJson(CreateTokenJson(TokenData_p));
    end;

    local procedure GetTokenDataResponse(var TokenData_p: Record "LSC Token")
    var
        TokenDataReceived: Text;
    begin
        TokenDataReceived := GetVar(varTokenDataValue);
        if TokenDataReceived = '' then
            exit;

        TokenData_p.Token := TokenDataReceived;
        TokenData_p."Token ID External" := GetVar(varTokenDataID);
        TokenData_p.Initiator := TextToInitiator(GetVar(varTokenDataInitiator));
        TokenData_p."Initiator Reason" := TextToInitiatorReason(GetVar(varTokenDataInitiatorReason));
        TokenData_p."Token Type" := TextToTokenType(GetVar(varTokenDataTokenType));
    end;

    internal procedure SetToken(Token: Text)
    begin
        EFTToken := Token;
    end;

    internal procedure SetTokenData(Token: Record "LSC Token")
    begin
        TokenData := Token;
    end;

    internal procedure GetTokenData(var Token: Record "LSC Token")
    begin
        Token := TokenData;
    end;

    internal procedure CreateTokenJson(Token: Record "LSC Token") tokenDataJson: JsonObject
    begin
        if Token."Token ID External" <> '' then
            tokenDataJson.Add('Id', Token."Token ID External")
        else
            tokenDataJson.Add('Id', Token."Token ID");
        tokenDataJson.Add('Initiator', InitiatorToText(Token.Initiator));
        tokenDataJson.Add('InitiatorReason', InitiatorReasonToText(Token."Initiator Reason"));
        tokenDataJson.Add('TokenType', TokenTypeToText(Token."Token Type"));
        tokenDataJson.Add('Value', Token.Token);
    end;

    local procedure TokenTypeToText(TokenType: Enum "LSC Token Type"): Text
    var
        Index: Integer;
        ValueName: Text;
    begin
        case TokenType of
            "LSC Token Type"::" ":
                exit(TOKENTYPE_UNKNOWN);
            "LSC Token Type"::Purchase:
                exit(TOKENTYPE_UNSCHEDULED);
            "LSC Token Type"::Subscription:
                exit(TOKENTYPE_RECURRING);
            "LSC Token Type"::Deposit:
                exit(TOKENTYPE_INSTALLMENTS);
            else begin
                Index := TokenType.Ordinals().IndexOf(TokenType.AsInteger());
                TokenType.Names().Get(Index, ValueName);
                exit(ValueName);
            end;
        end;
    end;

    local procedure InitiatorReasonToText(InitiatorReason: Enum "LSC Token Initiator Reason"): Text
    var
        Index: Integer;
        ValueName: Text;
    begin
        Index := InitiatorReason.Ordinals().IndexOf(InitiatorReason.AsInteger());
        InitiatorReason.Names().Get(Index, ValueName);
        exit(ValueName);
    end;

    local procedure InitiatorToText(Initiator: Enum "LSC Token Initiator"): Text
    var
        Index: Integer;
        ValueName: Text;
    begin
        Index := Initiator.Ordinals().IndexOf(Initiator.AsInteger());
        Initiator.Names().Get(Index, ValueName);
        exit(ValueName);
    end;

    local procedure TextToTokenType(TokenTypeText: Text): Enum "LSC Token Type"
    var
        index: integer;
    begin
        if TokenTypeText = TOKENTYPE_UNKNOWN then
            exit("LSC Token Type"::" ");

        if TokenTypeText = TOKENTYPE_UNSCHEDULED then
            exit("LSC Token Type"::Purchase);

        if TokenTypeText = TOKENTYPE_RECURRING then
            exit("LSC Token Type"::Subscription);

        if TokenTypeText = TOKENTYPE_INSTALLMENTS then
            exit("LSC Token Type"::Deposit);

        index := Enum::"LSC Token Type".Names().IndexOf(TokenTypeText);
        if index <= 0 then
            exit("LSC Token Type"::" ");

        exit(Enum::"LSC Token Type".FromInteger("LSC Token Type".Ordinals().Get(index)));
    end;

    local procedure TextToInitiator(InitiatorText: Text): Enum "LSC Token Initiator"
    var
        index: integer;
    begin
        index := Enum::"LSC Token Initiator".Names().IndexOf(InitiatorText);
        if index <= 0 then
            exit("LSC Token Initiator"::Unknown);

        exit(Enum::"LSC Token Initiator".FromInteger("LSC Token Initiator".Ordinals().Get(index)));
    end;

    local procedure TextToInitiatorReason(InitiatorReasonText: Text): Enum "LSC Token Initiator Reason"
    var
        index: integer;
    begin
        index := Enum::"LSC Token Initiator Reason".Names().IndexOf(InitiatorReasonText);
        if index <= 0 then
            exit("LSC Token Initiator Reason"::Unknown);

        exit(Enum::"LSC Token Initiator Reason".FromInteger("LSC Token Initiator Reason".Ordinals().Get(index)));
    end;

    #endregion
    procedure ScreenDisplay(pText: Text)
    begin
        if (pText = '') AND ScreenDisplayOpen then begin
            ScreenDisplayDialog.Close();
            ScreenDisplayOpen := false;
        end
        else begin
            ScreenDisplayDialog.Open(pText);
            ScreenDisplayOpen := true;
        end;
    end;

    #region Referenced Returns

    internal procedure SetReferencedReturns(CardEntry: Record "LSC POS Card Entry")
    begin
        ReferencedReturnsTemp.CopyFromCardEntry(CardEntry, GetClientTransactionID(CardEntry));
    end;

    internal procedure ClearReferencedReturns()
    begin
        Clear(ReferencedReturnsTemp);
    end;

    internal procedure CreateReferencedReturnJson(var ReferenceInformationTemp: Record "LSC Referenced Returns"): JsonObject
    var
        ReferencedJson: JsonObject;
    begin
        ReferencedJson.Add('TransactionId', ReferenceInformationTemp."Transaction ID");
        ReferencedJson.Add('EFTTransactionId', ReferenceInformationTemp."EFT Transaction ID");
        ReferencedJson.Add('TransactionDateTime', ReferenceInformationTemp."EFT Transaction Date Time");
        ReferencedJson.Add('AdditionalId', ReferenceInformationTemp."Additional ID");
        ReferencedJson.Add('BatchNumber', ReferenceInformationTemp."Batch number");
        ReferencedJson.Add('AuthCode', ReferenceInformationTemp."Authorization Code");
        exit(ReferencedJson);
    end;

    #endregion

    internal procedure CreateCardDetailsJson(var ReferenceInformationTemp: Record "LSC Referenced Returns"): JsonObject
    var
        CardDetailsJson: JsonObject;
    begin
        CardDetailsJson.Add('CardNumber', ReferenceInformationTemp."Card Number");
        CardDetailsJson.Add('CardExpiryDate', ReferenceInformationTemp."Expiry Date");
        CardDetailsJson.Add('CardIssuer', ReferenceInformationTemp."Card Issuer");
        exit(CardDetailsJson);
    end;

    //AutoTest
    procedure SetTestMode(NewValue_p: Boolean)
    begin
        AutoTestMode := NewValue_p;
    end;

    procedure SetAutoTestReponse(ResponseJson_p: JsonObject)
    begin
        PEFT2.SetResponseJson(ResponseJson_p);
    end;

    //EVENTS
    // [IntegrationEvent(false, false)]
    // local procedure OnBeforeProcessRefund(POSTerminal: Record "LSC POS Terminal"; var EFTAmount: Decimal; var EFTResult: Integer; var IsHandled: Boolean; var EFTCurrencyCode: Code[10]);
    // begin
    // end;

    // [IntegrationEvent(false, false)]
    // local procedure OnBeforeProcessPurchase(POSTerminal: Record "LSC POS Terminal"; var EFTAmount: Decimal; var EFTResult: Integer; var IsHandled: Boolean; var EFTCurrencyCode: Code[10]);
    // begin
    // end;

    // [IntegrationEvent(false, false)]
    // local procedure OnBeforeProcessAddCardToFile(var TokenData: Record "LSC Token"; var IsHandled: Boolean);
    // begin
    // end;

    // [IntegrationEvent(false, false)]
    // local procedure OnBeforeRetrievePrintLines(var EFTPrintLine: Record "LSC POS Card Print Text"; var IsHandled: Boolean);
    // begin
    // end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeVoid(POSTerminal: Record "LSC POS Terminal"; var EFTReversal: Text; var EFTAmount: Decimal; var EFTTenderType: Text; var EFTResult: Integer; var IsHandled: Boolean; var EFTCurrencyCode: Code[10]);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeEFTRequest(POSTerminalNo: Text; RequestType: Text; var requestJson: JsonObject; var IsHandled: Boolean; var POSCardEntry: Record "LSC POS Card Entry"; var PEFT2: Page "LSC POS EFT Dialog 2")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterEFTRequest(POSTerminalNo: Text; RequestType: Text; var responseJson: JsonObject);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePullStatus(var POSCardEntry: Record "LSC POS Card Entry"; var EFTResult: Integer; var EFTMessage: Text; var isHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeProcessingInPollStatus(var POSCardEntry: Record "LSC POS Card Entry"; var EFTAdditionalID: Text; var EFTQRCode: Text; var EFTCurrencyCode: Code[10];
                                                   var EFTTenderType: Text; var EFTAmount: Decimal; var EFTCashback: Decimal; var EFTVat: Decimal; var EFTSurcharge: Decimal;
                                                   var EFTTip: Decimal; var EFTManualEntry: Boolean; var EFTAskGratuity: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertLogEntry(CardEntryCopy: Record "LSC POS Card Entry");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModifyLogEntry(var CardEntry: Record "LSC POS Card Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePrintBuffer(pPrinterID: Text; var pPrintBufferRecRef: RecordRef; var pReturnValue: Boolean; var pErrorText: Text; var pIsHandled: Boolean)
    begin
    end;

    //AutoTest
    [IntegrationEvent(true, false)]
    local procedure OnAutoTestEFTRequest(POSTerminalNo: Text; RequestType: Text; var requestJson: JsonObject);
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAutoTestGetVar(pVarName: Text; var pResponse: Text; var pHandled: Boolean);
    begin
    end;

    // [IntegrationEvent(true, false)]
    // local procedure OnShowLastTransactionMessage(var pMessage: Text; var pHandled: Boolean);
    // begin
    // end;

    // [IntegrationEvent(true, false)]
    // local procedure OnBeforePrintMerchantReceipt(var CardEntry: Record "LSC POS Card Entry"; var PrintMerchantReceipt: Boolean);
    // begin
    // end;

    // [IntegrationEvent(false, false)]
    // local procedure OnAfterGet10DigitClientTransID(var CardEntry: Record "LSC POS Card Entry")
    // begin
    // end;

    // [IntegrationEvent(false, false)]
    // local procedure OnBeforeGet10DigitClientTransID(var IsHandled: Boolean; var CardEntry: Record "LSC POS Card Entry")
    // begin
    // end;
}

