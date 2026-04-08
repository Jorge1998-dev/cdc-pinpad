codeunit 60009 "OPTs POS Transaction GUI"
{
    // Access = Internal;
    // SingleInstance = true;

    var
        ErrorMessageFlag: Boolean;

    #region Get/Set/Reset

    procedure GetAndResetErrorMessageFlag() returnValue: Boolean
    begin
        returnValue := ErrorMessageFlag;
        SetErrorMessageFlag(false);
    end;

    procedure GetErrorMessageFlag(): Boolean
    begin
        exit(ErrorMessageFlag);
    end;

    procedure SetErrorMessageFlag(ErrorMsgFlag: Boolean)
    begin
        ErrorMessageFlag := ErrorMsgFlag;
    end;

    #endregion

    #region Display message dialogs

    procedure PosConfirm(DisplayText: Text; YesDefault: Boolean) ReturnValue: Boolean
    var
        POSTransaction: Codeunit "OPT POS Transaction Impl";
        PosREC: Record "LSC POS Transaction";
    begin
        PosTransaction.GetPOSTransaction(PosREC);

        ReturnValue := ShowPosConfirm(PosREC, DisplayText, YesDefault);
        PosTransaction.SetFunctionMode(PosTransaction.GetFunctionMode());
    end;

    procedure ShowPosConfirm(var REC: Record "LSC POS Transaction"; Txt: Text; YesDefault: Boolean): Boolean
    var
        IsHandled, ReturnValue : Boolean;
        POSTransactionEvents: Codeunit "OPT POS Transaction Events";
        PosGui: Codeunit "LSC POS GUI";
    begin
        POSTransactionEvents.OnBeforePosConfirm(REC, CopyStr(Txt, 1, 100), IsHandled, ReturnValue);
        if IsHandled then
            exit(ReturnValue);

        exit(PosGui.PosConfirm(Txt, YesDefault));
    end;

    procedure PosMessage(DisplayText: Text) ReturnValue: Boolean
    var
        POSTransaction: Codeunit "OPT POS Transaction Impl";
        PosREC: Record "LSC POS Transaction";
    begin
        PosTransaction.GetPOSTransaction(PosREC);
        ReturnValue := ShowPosMessage(PosREC, DisplayText);
        PosTransaction.SetFunctionMode(PosTransaction.GetFunctionMode());
    end;

    procedure ShowPosMessage(var REC: Record "LSC POS Transaction"; Txt: Text): Boolean
    var
        IsHandled, ReturnValue : Boolean;
        POSTransactionEvents: Codeunit "OPT POS Transaction Events";
        PosGui: Codeunit "LSC POS GUI";
    begin
        POSTransactionEvents.OnBeforePosMessage(REC, CopyStr(Txt, 1, 100), IsHandled, ReturnValue);
        if IsHandled then
            exit(ReturnValue);

        exit(PosGui.PosMessage(Txt))
    end;

    procedure DisplayErrorMessage()
    var
        Txt: Text;
        InfoTextDescription: Text;
        InfoTextDescription2: Text;
        POSSession: Codeunit "LSC POS Session";
        POSTransaction: Codeunit "OPT POS Transaction Impl";
    begin
        if POSSession.DialogBoxOnError then
            exit;

        if GetAndResetErrorMessageFlag then begin
            POSTransaction.GetInfoTextDescription(InfoTextDescription, InfoTextDescription2);
            Txt := InfoTextDescription + '\' + InfoTextDescription2;
            if (Txt <> '\') then
                PosMessage(Txt);
        end;
    end;

    #endregion

    #region Display Banners

    procedure PosErrorBanner(ErrorTxt: Text)
    var
        POSSession: Codeunit "LSC POS Session";
    begin
        PosErrorBanner(ErrorTxt, POSSession.ErrorBannerTimeout);
    end;

    procedure PosErrorBanner(ErrorTxt: Text; TimeoutSeconds: Integer)
    var
        POSCtrlInterface: Codeunit "LSC POS Control Interface";
    begin
        POSCtrlInterface.PosMessageBanner(ErrorTxt, "LSC POS Message Banner Level"::Error, TimeoutSeconds * 1000);
    end;

    procedure PosMessageBanner(MessageTxt: Text)
    var
        POSCtrlInterface: Codeunit "LSC POS Control Interface";
        POSSession: Codeunit "LSC POS Session";
    begin
        POSCtrlInterface.PosMessageBanner(MessageTxt, "LSC POS Message Banner Level"::Info, POSSession.MessageBannerTimeout * 1000);
    end;

    #endregion

    #region Display Keyboards
    procedure OpenNumericKeyboard(Caption: Text; DefaultValue: Text; TriggerNo: Enum "LSC POS Trans. Numpad Trigger")
    begin
        OpenNumericKeyboard(Caption, DefaultValue, TriggerNo.AsInteger());
    end;

    procedure OpenNumericKeyboard(Caption: Text; DefaultValue: Text; TriggerNo: Integer)
    var
        POSTransactionEvents: Codeunit "OPT POS Transaction Events";
        KeybType: Integer;
    begin
        POSTransactionEvents.OnBeforeOpenNumericKeyboard(Caption, KeybType, DefaultValue, TriggerNo);
        OpenNumericKeyboard(Caption, DefaultValue, Format(TriggerNo));
    end;

    procedure OpenNumericKeyboard(Caption: Text; DefaultValue: Text; Payload: Text)
    var
        PosGui: Codeunit "LSC POS GUI";
    begin
        Commit;
        PosGui.OpenNumericKeyboard(Caption, DefaultValue, Payload);
    end;

    #endregion

    #region Error beeps

    procedure ErrorBeep(DisplayText: Text)
    begin
        ErrorBeep(DisplayText, true);
    end;

    procedure ErrorBeep(DisplayText: Text; ResetMultiplyWith: Boolean)
    var
        POSTransaction: Codeunit "OPT POS Transaction Impl";
        PosREC: Record "LSC POS Transaction";
    begin
        PosTransaction.GetPOSTransaction(PosREC);
        if ResetMultiplyWith then
            POSTransaction.SetMultiplyWith(1);

        POSTransaction.SetUnitOfMeasure('');
        POSTransaction.ClearInput();
        SetErrorMessageFlag(true);
        POSTransaction.SetProcessTenderOffers(false);

        DisplayError(DisplayText, PosREC);
    end;

    procedure ShowErrorBeep(ErrorMessage: Text)
    var
        POSCtrlInterface: Codeunit "LSC POS Control Interface";
    begin
        POSCtrlInterface.PostCommand(Enum::"LSC POS Command"::ERRORBEEP, ErrorMessage);
    end;

    procedure DisplayError(DisplayText: Text; REC: Record "LSC POS Transaction")
    var
        IsHandled: Boolean;
        POSTransaction: Codeunit "OPT POS Transaction Impl";
        POSTransactionEvents: Codeunit "OPT POS Transaction Events";
        POSSession: Codeunit "LSC POS Session";
    begin
        if StrPos(DisplayText, '\') <> 0 then begin
            POSTransaction.SetPosInfoText1(CopyStr((CopyStr(DisplayText, 1, StrPos(DisplayText, '\') - 1)), 1, 80));
            POSTransaction.SetPosInfoText2(CopyStr((CopyStr(DisplayText, StrPos(DisplayText, '\') + 1)), 1, 80));
        end else
            if DisplayText <> '' then begin
                POSTransaction.SetPosInfoText1(CopyStr(DisplayText, 1, 80));
                POSTransaction.SetPosInfoText2(CopyStr(DisplayText, 80 + 1));
            end;

        if DisplayText <> '' then
            POSTransactionEvents.OnBeforeErrorBeep(REC, CopyStr(DisplayText, 1, 100), IsHandled);
        if IsHandled then
            exit;

        if (DisplayText <> '') then begin
            if POSSession.DialogBoxOnError then
                PosMessage(DisplayText)
            else
                if POSSession.BannerOnError then
                    PosErrorBanner(DisplayText);
        end;
    end;

    procedure MessageBeep(DisplayText: Text)
    var
        IsHandled: Boolean;
        POSTransaction: Codeunit "OPT POS Transaction Impl";
        POSTransactionEvents: Codeunit "OPT POS Transaction Events";
        POSSession: Codeunit "LSC POS Session";
        OposUtil: Codeunit "LSC POS OPOS Utility";
        PosREC: Record "LSC POS Transaction";
    begin
        PosTransaction.GetPOSTransaction(PosREC);
        SetErrorMessageFlag(true);
        POSTransactionEvents.OnBeforeMessageBeep(PosREC, CopyStr(DisplayText, 1, 100), IsHandled);
        if IsHandled then
            exit;

        if DisplayText <> '' then begin
            POSTransaction.SetPosInfoText1(DisplayText);
            POSTransaction.SetPosInfoText2('');
            if POSSession.BannerOnMessage then
                PosMessageBanner(DisplayText);
        end;

        POSTransaction.ClearInput();
        OposUtil.Beeper();
    end;

    #endregion


}