codeunit 60008 "OPT POS Void Card Functions"
{
    //Access = Internal;

    var
        PosCtrl: Codeunit "LSC POS Control Interface";
        PosSession: Codeunit "LSC POS Session";
        WaitingForSwipe: Boolean;
        CardNo: Text[50];
        ReadCardNo: Text[50];
        Ok: Boolean;
        ReadFromMSR: Boolean;
        IsPreAuth: Boolean;
        VisibleCardNo: Text[50];
        VoucherNo: Text[100];
        VoidAmount: Decimal;
        posfunc: Codeunit "LSC POS Functions";
        Text000: Label 'Re-swipe the card for void:';
        Text001: Label 'Confirm card number for void:';
        Text005: Label 'Not the same card';
        Text006: Label 'Please re-swipe the card';
        Text007: Label 'Cancel Pre-Auth for card';
        Text008: Label 'Voucher: %1';
        Text009: Label 'Amount: %1';

    procedure SetCardNo(Card: Text[50])
    begin
        CardNo := Card;
        VisibleCardNo := posfunc.AstrxPad(CardNo);
    end;

    procedure GetCardNo(): Text[50]
    begin
        exit(ReadCardNo);
    end;

    procedure SetReadFromMSR(FromMSR: Boolean)
    begin
        ReadFromMSR := FromMSR;
    end;

    procedure SetPreAuth(preauth: Boolean)
    begin
        IsPreAuth := preauth;
    end;

    procedure SetVoidDetails(NewVoucherNo: Text[100]; NewVoidAmount: Decimal)
    begin
        VoucherNo := NewVoucherNo;
        VoidAmount := NewVoidAmount;
    end;

    procedure GetOk(): Boolean
    begin
        exit(Ok);
    end;

    procedure RunModal()
    var
        ConfirmText: Text;
    begin
        ConfirmText := GetConfirmText();

        if ReadFromMSR then begin
            WaitingForSwipe := true;
            Ok := PosCtrl.PosConfirm(Text000 + '\' + ConfirmText, false);
            while Ok and (ReadCardNo = '') do begin
                PosCtrl.PosMessage(Text006);
                Ok := PosCtrl.PosConfirm(Text000 + '\' + ConfirmText, false);
            end;

            if not Ok then
                ReadCardNo := '';

            WaitingForSwipe := false;
        end
        else begin
            if IsPreAuth then
                Ok := PosCtrl.PosConfirm(Text007 + '\' + ConfirmText, false)
            else
                Ok := PosCtrl.PosConfirm(Text001 + '\' + ConfirmText, false);
            ReadCardNo := '';
        end;
    end;

    local procedure GetConfirmText(): Text
    var
        ConfirmText: Text;
    begin
        ConfirmText := VisibleCardNo;

        if VoucherNo <> '' then
            ConfirmText := ConfirmText + '\' + StrSubstNo(Text008, VoucherNo);

        if VoidAmount <> 0 then
            ConfirmText := ConfirmText + '\' + StrSubstNo(Text009, VoidAmount);

        exit(ConfirmText);
    end;

    procedure OnMsrData(pTrack2Data: Text): Boolean
    begin
        if not WaitingForSwipe then
            exit(false);

        ReadCardNo := pTrack2Data;
        if CardNo <> CopyStr(ReadCardNo, 1, StrLen(CardNo)) then begin
            ReadCardNo := '';
            PosCtrl.PosMessage(Text005);
            exit(true);
        end;

        PosCtrl.HidePanel(Format("LSC POS Panel Id"::"#CONFIRM"), true);
        exit(true);
    end;
}

