codeunit 60013 "LAF Printing Utility"
{
    Access = Internal;

    var
        ActivePrinter: Record "LSC POS Printer";
        LineLen: Integer;
        ActiveFontType: Option Normal,Bold,Wide,High,WideAndHight,Italic;
        Value: array[10] of Text[100];
        NodeName: array[32] of Text[50];
        Stars: Label '*********************************************************************************';
        Blanks: Label '                                                                                ';
        Zeros: Label '000000000000000000000000000000000000000000000000000000000000000000000000000000000';
        FieldValue: array[10] of Text[100];
    // cPrintPOSBuffer: Codeunit 10000854;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnBeforePrintBarcode', '', false, false)]
    local procedure OnBeforePrintBarcode(var Sender: Codeunit "LSC POS Print Utility"; var Tray: Integer; var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer; var IsHandled: Boolean);

    var
        DSTR1: Text[50];
    begin
        if Tray = 99 then begin
            AddCutLine(2, FormatLine(FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE), PrintBuffer, PrintBufferIndex, LinesPrinted);
            IsHandled := true;
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnAfterPrintSlips', '', false, false)]
    local procedure OnAfterPrintSlips(var Sender: Codeunit "LSC POS Print Utility"; var Transaction: Record "LSC Transaction Header"; var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer; var MsgTxt: Text[50]; PrintSlip: Boolean);
    var
        TenderTyp: Record "LSC Tender Type";
        rLAFTrans: Record "Trans. LAF";
    begin
        rLAFTrans.Reset();
        rLAFTrans.SetRange("Receipt No.", Transaction."Receipt No.");
        rLAFTrans.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
        rLAFTrans.SetRange("Store No.", Transaction."Store No.");
        rLAFTrans.SetRange(Log, false);
        rLAFTrans.SetRange("Response Code", '00');
        if rLAFTrans.FindLast() then begin
            TenderTyp.Reset();
            TenderTyp.SetRange("Store No.", rLAFTrans."Store No.");
            TenderTyp.SetRange(Code, rLAFTrans.TenderType);
            if TenderTyp.FindFirst() then begin
                if TenderTyp."Pinpad Integration" then begin
                    ResetPrintBufferForVoucher(PrintBuffer, PrintBufferIndex, LinesPrinted);
                    IF NOT EvertecPrint_Dynamic(Sender, Transaction, FALSE, 'SALE', '', PrintBuffer, PrintBufferIndex, LinesPrinted) THEN;
                    Sender.ClosePrinter(2);
                end;

            end;
        end;
    end;


    procedure EvertecPrint_Dynamic(var Sender: Codeunit "LSC POS Print Utility"; Transaction: Record "LSC Transaction Header"; Reprint: Boolean; Role: Code[10]; Subrole: Code[10]; var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer): Boolean
    var
        DSTR1: Text[50];
        POSText: Record "LSC POS Terminal Receipt Text";
        ReceiptNo: Code[20];
        Terminal: Record "LSC POS Terminal";
        rLAF: Record "Trans. LAF";
        bcWidth: Integer;
        bcHeight: Integer;
        bc: Text;
        SetupLAF: Record "OPT Serial Port Setup";
        iprint: Integer;
        icontp: Integer;
        NoCard: Text;
        bFound: Boolean;
        iPosition: Integer;
        tValorE1E2: Text;
        rCurrency: Record Currency;
        gNCF: Text;
    begin
        Clear(SetupLAF);
        SetupLAF.SetRange(Store, Transaction."Store No.");
        SetupLAF.SetRange("Pos Terminal", Transaction."POS Terminal No.");
        if SetupLAF.FindSet() then begin end;
        //SetupLAF.Get();
        //PrintUtilPublic.Init();

        ReceiptNo := Transaction."Receipt No.";
        Terminal.Get(Transaction."POS Terminal No.");
        Clear(POSText);

        rLAF.Reset();
        rLAF.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
        rLAF.SetRange("Store No.", Transaction."Store No.");
        rLAF.SetRange("Receipt No.", Transaction."Receipt No.");
        rLAF.SetRange(Log, false);
        rLAF.SetRange("Response Code", '00');

        iprint := rLAF.Count;


        rLAF.Reset();
        rLAF.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
        rLAF.SetRange("Store No.", Transaction."Store No.");
        rLAF.SetRange("Receipt No.", Transaction."Receipt No.");
        rLAF.SetRange(Log, false);
        rLAF.SetRange("Response Code", '00');
        if rLAF.FindSet() then
            repeat
                icontp += 1;
                gNCF := '';
                ////////////
                // print header voucher
                POSText.SetRange("No.", '');
                if Terminal."Receipt Setup Location" = Terminal."Receipt Setup Location"::Terminal then begin
                    POSText.SetRange(Relation, POSText.Relation::Terminal);
                    POSText.SetRange(Number, Terminal."No.");
                end
                else begin
                    POSText.SetRange(Relation, POSText.Relation::Store);
                    POSText.SetRange(Number, Transaction."Store No.");
                end;

                //Sender.PrintBitmap(2, SetupLAF."Logo path", 1);
                // POSText.SetRange(Type, POSText.Type::Top);
                // if not POSText.FindFirst then
                //     POSText.SetRange("No.", '');

                // if POSText.FindSet then begin
                //     repeat
                //         DSTR1 := GetDesignString(POSText);
                //         FieldValue[1] := POSText."Receipt Text";
                //         NodeName[1] := 'Header Line';
                //         Sender.PrintLine(2, FormatLine(FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));
                //     until POSText.Next = 0;
                //     Sender.PrintSeperator(2);
                // end;
                // FieldValue[1] := 'VOUCHER BANCO LAFICE'; 
                FieldValue[1] := 'VOUCHER BANCO LAFISE';
                DSTR1 := '#C######################################';
                Sender.PrintLine(2, FormatLine(FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));

                /// 
                /// 
                IF rLAF."Void Sale" THEN begin
                    FieldValue[1] := 'ANULACION';
                    DSTR1 := '#C######################################';
                    Sender.PrintLine(2, FormatLine(FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));
                    gNCF := Transaction."NCF Affected OPT";
                end else begin
                    FieldValue[1] := 'VENTA';
                    DSTR1 := '#C######################################';
                    Sender.PrintLine(2, FormatLine(FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));
                    gNCF := Transaction."NCF OPT";

                end;

                FieldValue[1] := 'COPIA CLIENTE';
                DSTR1 := '#C######################################';
                Sender.PrintLine(2, FormatLine(FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));

                FieldValue[1] := Refill('FECHA: ' + SetDate(rLAF.Date, 'D'), 'HORA: ' + SetDate(rLAF.Time, 'T'));
                DSTR1 := '#L######################################';
                Sender.PrintLine(2, FormatLine(FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));

                FieldValue[1] := Refill('REFERENCIA: ' + rLAF.Reference, 'TERM: ' + UpperCase(rLAF.TerminalId));
                DSTR1 := '#L######################################';
                Sender.PrintLine(2, FormatLine(FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));

                FieldValue[1] := 'ENTRY MODE: ' + UpperCase(rLAF."Card Entry Mode");//Refill('ENTRY MODE ', UpperCase(rLAF."Card Entry Mode"));
                DSTR1 := '#L######################################';
                Sender.PrintLine(2, FormatLine(FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));

                FieldValue[1] := 'TARJETA: ' + UpperCase(rLAF."Card Number");//Refill('TARJETA ', UpperCase(rLAF."Card Number"));
                DSTR1 := '#L######################################';
                Sender.PrintLine(2, FormatLine(FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));




                FieldValue[1] := Refill('AUTORIZ: ' + rLAF."Authorization Code", 'NCF: ' + gNCF);
                DSTR1 := '#L######################################';
                Sender.PrintLine(2, FormatLine(FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));

                FieldValue[1] := 'MONTO: ' + rLAF.Symbol + ' ' + format(rLAF."EFT Amount");  //SetAmout(rLAF."Amount Authorized");// Refill('MONTO: ', rLAF.CurrCodeCardEntry + ' ' + SetAmout(rLAF."Amount Authorized"));
                DSTR1 := '#L######################################';
                Sender.PrintLine(2, FormatLine(FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));

                FieldValue[1] := ' ';
                Sender.PrintLine(2, FormatLine(FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));

                FieldValue[1] := ' ';

                Sender.PrintLine(2, FormatLine(FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));
                FieldValue[1] := ' ';
                Sender.PrintLine(2, FormatLine(FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));

                if (rLAF."Card Entry Mode".Trim().ToUpper() = 'MANUAL') OR
                     (rLAF."Card Entry Mode".Trim().ToUpper() = 'SWIPE') or (rLAF."Card Entry Mode".Trim().ToUpper() = 'FALLBACK') THEN begin
                    FieldValue[1] := 'SE REQUIERE FIRMA';
                    Sender.PrintSeperator(2);
                end else begin
                    FieldValue[1] := 'NO REQUIERE FIRMA';
                end;

                DSTR1 := '#C######################################';
                Sender.PrintLine(2, FormatLine(FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));

                FieldValue[1] := ' ';
                Sender.PrintLine(2, FormatLine(FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));

                if iprint > 1 then begin
                    if (icontp <> iprint) then begin

                        Value[1] := '';
                        Sender.PrintBarcode(99, bc, bcWidth, bcHeight, Format(Terminal."Print Receipt BC Type"), 2);
                    end else begin
                        if SetupLAF."Print Receipt Merchant" then begin
                            GetReceiptBarcodeWidthAndHeight(Terminal, bcWidth, bcHeight);
                            Value[1] := '';
                            Sender.PrintBarcode(99, bc, bcWidth, bcHeight, Format(Terminal."Print Receipt BC Type"), 2);
                        end;
                    end;
                end else begin
                    if SetupLAF."Print Receipt Merchant" then begin
                        GetReceiptBarcodeWidthAndHeight(Terminal, bcWidth, bcHeight);
                        Value[1] := '';
                        Sender.PrintBarcode(99, bc, bcWidth, bcHeight, Format(Terminal."Print Receipt BC Type"), 2);
                    end;
                end;
            until rLAF.Next() = 0;


        icontp := 0;
        gNCF := '';
        if SetupLAF."Print Receipt Merchant" then begin
            rLAF.Reset();
            rLAF.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
            rLAF.SetRange("Store No.", Transaction."Store No.");
            rLAF.SetRange("Receipt No.", Transaction."Receipt No.");
            rLAF.SetRange(Log, false);
            rLAF.SetRange("Response Code", '00');
            if rLAF.FindSet() then
                repeat
                    icontp += 1;
                    gNCF := '';
                    //PRINT MERCHANT
                    // POSText.SetRange("No.", '');
                    // if Terminal."Receipt Setup Location" = Terminal."Receipt Setup Location"::Terminal then begin
                    //     POSText.SetRange(Relation, POSText.Relation::Terminal);
                    //     POSText.SetRange(Number, Terminal."No.");
                    // end
                    // else begin
                    //     POSText.SetRange(Relation, POSText.Relation::Store);
                    //     POSText.SetRange(Number, Transaction."Store No.");
                    // end;
                    // POSText.SetRange(Type, POSText.Type::Top);

                    // Sender.PrintBitmap(2, SetupLAF."Logo path", 1);

                    // if not POSText.FindFirst then
                    //     POSText.SetRange("No.", '');

                    // if POSText.FindSet then begin
                    //     repeat
                    //         DSTR1 := GetDesignString(POSText);
                    //         FieldValue[1] := POSText."Receipt Text";
                    //         NodeName[1] := 'Header Line';

                    //         Sender.PrintLine(2, FormatLine(FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));
                    //     until POSText.Next = 0;

                    //     Sender.PrintSeperator(2);
                    // end;

                    // FieldValue[1] := 'VOUCHER BANCO LAFICE';
                    FieldValue[1] := 'VOUCHER BANCO LAFISE';
                    DSTR1 := '#C######################################';
                    Sender.PrintLine(2, FormatLine(FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));

                    /// 
                    /// 
                    IF rLAF."Void Sale" THEN begin
                        FieldValue[1] := 'ANULACION';
                        DSTR1 := '#C######################################';
                        Sender.PrintLine(2, FormatLine(FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));
                        //gNCF := Transaction."NCF Affected OPT";
                    end else begin
                        FieldValue[1] := 'VENTA';
                        DSTR1 := '#C######################################';
                        Sender.PrintLine(2, FormatLine(FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));
                        //gNCF := Transaction."NCF OPT";
                    end;

                    FieldValue[1] := 'COPIA COMERCIO';
                    DSTR1 := '#C######################################';
                    Sender.PrintLine(2, FormatLine(FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));

                    FieldValue[1] := Refill('FECHA: ' + SetDate(rLAF.Date, 'D'), 'HORA: ' + SetDate(rLAF.Time, 'T'));
                    DSTR1 := '#L######################################';
                    Sender.PrintLine(2, FormatLine(FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));

                    FieldValue[1] := Refill('REFERENCIA: ' + rLAF.Reference, 'TERM: ' + UpperCase(rLAF.TerminalId));
                    DSTR1 := '#L######################################';
                    Sender.PrintLine(2, FormatLine(FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));

                    FieldValue[1] := 'ENTRY MODE: ' + UpperCase(rLAF."Card Entry Mode");//Refill('ENTRY MODE ', UpperCase(rLAF."Card Entry Mode"));
                    DSTR1 := '#L######################################';
                    Sender.PrintLine(2, FormatLine(FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));

                    FieldValue[1] := 'TARJETA: ' + UpperCase(rLAF."Card Number");//Refill('TARJETA ', UpperCase(rLAF."Card Number"));
                    DSTR1 := '#L######################################';
                    Sender.PrintLine(2, FormatLine(FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));

                    FieldValue[1] := Refill('AUTORIZ: ' + rLAF."Authorization Code", 'NCF: ' + gNCF);
                    DSTR1 := '#L######################################';
                    Sender.PrintLine(2, FormatLine(FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));

                    FieldValue[1] := 'MONTO: ' + rLAF.Symbol + ' ' + format(rLAF."EFT Amount"); // SetAmout(rLAF."Amount Authorized");// Refill('MONTO: ', rLAF.CurrCodeCardEntry + ' ' + SetAmout(rLAF."Amount Authorized"));
                    DSTR1 := '#L######################################';
                    Sender.PrintLine(2, FormatLine(FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));

                    FieldValue[1] := ' ';
                    Sender.PrintLine(2, FormatLine(FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));

                    FieldValue[1] := ' ';

                    Sender.PrintLine(2, FormatLine(FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));
                    FieldValue[1] := ' ';
                    Sender.PrintLine(2, FormatLine(FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));

                    if (rLAF."Card Entry Mode".Trim().ToUpper() = 'MANUAL') OR
                         (rLAF."Card Entry Mode".Trim().ToUpper() = 'SWIPE') or (rLAF."Card Entry Mode".Trim().ToUpper() = 'FALLBACK') THEN begin
                        FieldValue[1] := 'SE REQUIERE FIRMA';
                        Sender.PrintSeperator(2);
                    end else begin
                        FieldValue[1] := 'NO REQUIERE FIRMA';
                    end;

                    DSTR1 := '#C######################################';
                    Sender.PrintLine(2, FormatLine(FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));

                    FieldValue[1] := ' ';

                    Sender.PrintLine(2, FormatLine(FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));
                    if iprint > 1 then begin
                        if icontp <> iprint then begin
                            ///// PrintBAarcode
                            GetReceiptBarcodeWidthAndHeight(Terminal, bcWidth, bcHeight);
                            /// ///
                            Value[1] := '';
                            Sender.PrintBarcode(99, bc, bcWidth, bcHeight, Format(Terminal."Print Receipt BC Type"), 2);
                        end;
                    end;
                until rLAF.Next() = 0;
        end;

        EXIT(TRUE);
    end;

    procedure Refill(tTexto: Text; tValor: Text) Resul: Text;
    var
        iLabel: Integer;
        iValor: Integer;
        iSum: Integer;
        iLoop: Integer;
        jLoop: Integer;
        tAddVacios: Text;
    begin
        iLabel := StrLen(tTexto);
        iValor := StrLen(tValor);
        iSum := iLabel + iValor;

        if iSum < 40 then begin
            jLoop := 40 - iSum;
            for iLoop := 1 to jLoop do begin
                tAddVacios := tAddVacios + ' ';
            end;
        end else begin
            if iSum >= 40 then begin

            end;
        end;

        Resul := tTexto + tAddVacios + tValor;
        exit(Resul);
    end;

    procedure SetCardNumber(pValor: Text) Result: Text
    var
        tValor1: text;
        tValor2: text;
    begin
        if pValor <> '' then begin
            tValor1 := CopyStr(pValor, 1, 4);
            // tValor2 := CopyStr(pValor, 5, 4);
        end;


        exit('************' + tValor1);
    end;

    procedure SetDate(pValor: Text; pType: Text[20]) Resul: Text
    var
        dValor: Text;
    begin
        if (pValor <> '') and (pType = 'D') then begin
            dValor := CopyStr(pValor, 5, 2) + '/' + CopyStr(pValor, 3, 2) + '/' + CopyStr(pValor, 1, 2)
        end;

        if (pValor <> '') and (pType = 'T') then begin
            dValor := CopyStr(pValor, 1, 2) + ':' + CopyStr(pValor, 3, 2) + ':' + CopyStr(pValor, 5, 2)
        end;
        exit(dValor);
    end;

    procedure SetAmout(pValor: Text) Result: Text
    var
        tAAmountDecimal: Text;
    begin
        if pValor <> '' then begin
            if StrLen(pValor) = 1 then begin
                tAAmountDecimal := '0.0' + pValor;
            end else begin
                if StrLen(pValor) = 2 then begin
                    tAAmountDecimal := '0' + CopyStr(pValor, 1, StrLen(pValor) - 2) + '.' + CopyStr(pValor, StrLen(pValor) - 1, 2)
                end else begin

                    tAAmountDecimal := CopyStr(pValor, 1, StrLen(pValor) - 2) + '.' + CopyStr(pValor, StrLen(pValor) - 1, 2)
                end;

            end;


        end;
        exit(tAAmountDecimal);
    end;

    local procedure ResetPrintBufferForVoucher(var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer)
    begin
        PrintBuffer.Reset();
        PrintBuffer.DeleteAll();
        PrintBufferIndex := 1;
        LinesPrinted := 0;
    end;

    procedure AddCutLine(Tray: Integer; TxtLine: Text; var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer)
    var
        DesignTxt: Text;
        DesignPos: Integer;
    begin
        DesignPos := StrPos(TxtLine, '<#DESN>');
        if DesignPos > 0 then begin
            DesignTxt := CopyStr(TxtLine, DesignPos + 7);
            TxtLine := CopyStr(TxtLine, 1, DesignPos - 1);
        end;

        LinesPrinted := LinesPrinted + 1;

        PrintBuffer.Init;
        PrintBuffer."Buffer Index" := PrintBufferIndex;
        PrintBuffer."Station No." := Tray;
        PrintBuffer."Page No." := 1;
        PrintBuffer."Printed Line No." := LinesPrinted;
        PrintBuffer.LineType := PrintBuffer.LineType::EndTransaction;
        PrintBuffer.Height := 1;
        PrintBuffer.Width := 90;
        PrintBuffer.Insert;

        PrintBufferIndex += 1;
    end;

    procedure FormatLine(Txt: Text; Wide: Boolean; Bold: Boolean; High: Boolean; Italic: Boolean): Text
    begin
        if Wide and High then
            ActiveFontType := ActiveFontType::WideAndHight
        else
            if Wide then
                ActiveFontType := ActiveFontType::Wide
            else
                if High then
                    ActiveFontType := ActiveFontType::High
                else
                    if Bold then
                        ActiveFontType := ActiveFontType::Bold
                    else
                        if Italic then
                            ActiveFontType := ActiveFontType::Italic
                        else
                            ActiveFontType := ActiveFontType::Normal;

        exit(Txt);
    end;

    procedure FormatStr(pValue: array[10] of Text; Design: Text): Text
    begin
        exit(FormatStr(pValue, Design, false));
    end;

    procedure FormatStr(pValue: array[10] of Text; Design: Text; WideFont: Boolean): Text
    var
        Type: Text[1];
        AddToStr: Text;
        DesignCopy: Text;
        k: Integer;
        Pos: Integer;
        Pos2: Integer;
        Len: Integer;
        LenValue: Integer;
        a: Integer;
        b: Integer;
        tmpPos: Integer;
    begin

        if (LineLen > 0) and (LineLen <> 40) then begin
            if WideFont then begin
                k := Round(LineLen / 2, 1);
                if not Design.StartsWith('#C') then
                    if StrLen(Design) < 20 then
                        Design := Design.PadRight(20, ' ');
            end
            else begin
                k := LineLen;
                if StrLen(Design) < 40 then
                    Design := Design.PadRight(40, ' ');
            end;
            ResizeDesignText(Design, k);
        end;

        DesignCopy := CopyStr(Design, 1);

        k := 0;
        Pos := StrPos(Design, '#');
        if Pos = 0 then
            exit('');
        while Pos <> 0 do begin
            Pos2 := Pos;
            Type := CopyStr(Design, Pos + 1, 1);
            Pos2 := Pos + 2;
            while CopyStr(Design, Pos2, 1) = '#' do
                Pos2 := Pos2 + 1;
            k := k + 1;
            Len := Pos2 - Pos;
            LenValue := StrLen(pValue[k]);
            if Len < LenValue then begin
                if (Type = 'N') or (Type = 'Z') then
                    AddToStr := CopyStr(Stars, 1, Len)
                else
                    AddToStr := CopyStr(pValue[k], 1, Len);
            end
            else begin
                case Type of
                    'N':
                        AddToStr := CopyStr(Blanks, 1, Len - LenValue) + pValue[k];
                    'Z':
                        AddToStr := CopyStr(Zeros, 1, Len - LenValue) + pValue[k];
                    'T':
                        AddToStr := pValue[k];
                    'L':
                        AddToStr := pValue[k] + CopyStr(Blanks, 1, Len - LenValue);
                    'R':
                        AddToStr := CopyStr(Blanks, 1, Len - LenValue) + pValue[k];
                    'C':
                        begin
                            a := Round((Len - LenValue) / 2, 1, '<');
                            b := Len - LenValue - a;
                            AddToStr := CopyStr(Blanks, 1, a) + pValue[k] + CopyStr(Blanks, 1, b);
                        end;
                end;
            end;
            tmpPos := StrPos(CopyStr(Design, Pos2), '#');
            if Pos <> 1 then
                Design := CopyStr(Design, 1, Pos - 1) + AddToStr + CopyStr(Design, Pos2)
            else
                Design := AddToStr + CopyStr(Design, Pos2);

            if tmpPos <> 0 then
                if (Type = 'T') and (LenValue < Len) then
                    Pos := Pos2 + tmpPos - Len + LenValue - 1
                else
                    Pos := Pos2 + tmpPos - 1
            else
                Pos := 0;
        end;

        exit(Design + '<#DESN>' + DesignCopy);

    end;

    procedure ResizeDesignText(var str: Text; targetLength: Integer)
    var
        sectionStart: array[10] of Integer;
        sectionLength: array[10] of Integer;
        sectionDelta: array[10] of Integer;
        len: Integer;
        section: Boolean;
        sections: Integer;
        totalSectionLength: Integer;
        i: Integer;
        targetSectionLength: Integer;
        factor: Decimal;
        sb: TextBuilder;
        st: Integer;
        retVal: Text;
    begin
        if targetLength < StrLen(str) then begin //start with spaces
            if RemoveExtraSpaces(str, targetLength) <= targetLength then
                exit;
        end;

        len := StrLen(str);
        for i := 1 to len do begin
            if str[i] = '#' then begin
                if not section then begin
                    sections += 1;
                    sectionStart[sections] := i;
                end;
                section := true;
            end
            else
                if str[i] = ' ' then begin
                    if section then begin
                        sectionLength[sections] := i - sectionStart[sections];
                        totalSectionLength += sectionLength[sections];
                    end;
                    section := false;
                end;
        end;
        if section then begin
            sectionLength[sections] := len - sectionStart[sections];
            totalSectionLength += sectionLength[sections];
        end;

        targetSectionLength := totalSectionLength + (targetLength - len);
        factor := targetSectionLength / totalSectionLength;

        for i := 1 to sections do begin
            sectionDelta[i] := Round(sectionLength[i] * factor, 1, '=') - sectionLength[i];
        end;

        if sectionStart[1] > 1 then
            sb.Append(str.Substring(1, sectionStart[1] - 1));

        for i := 1 to sections do begin
            if sectionDelta[i] < 0 then
                sb.Append(str.Substring(sectionStart[i], sectionLength[i] + sectionDelta[i]))
            else begin
                sb.Append(str.Substring(sectionStart[i], sectionLength[i]));
                sb.Append(CopyStr('################################################################################', 1, sectionDelta[i]));
            end;
            st := sectionStart[i] + sectionLength[i];
            if i < sections then
                sb.Append(str.Substring(st, sectionStart[i + 1] - st))
            else
                sb.Append(str.Substring(st));
        end;

        retVal := sb.ToText();
        if StrLen(retVal) > targetLength then
            str := CopyStr(retVal, 1, targetLength)
        else
            str := retVal;
    end;


    procedure RemoveExtraSpaces(var str: Text; targetLength: Integer): Integer
    var
        len: Integer;
        lastPos: Integer;
        lastChar: Char;
        sb: TextBuilder;
        i: Integer;
    begin
        len := StrLen(str);
        lastPos := str.LastIndexOf('  ');
        if lastPos = 0 then //No extra spaces to remove
            exit(len);

        lastPos := len;
        for i := 1 to lastPos do begin
            if (lastChar = ' ') and (str[i] = ' ') and (len > targetLength) then
                len -= 1
            else
                sb.Append(str[i]);

            lastChar := str[i];
        end;

        str := sb.ToText();
        exit(len);
    end;

    local procedure GetDesignString(var POSText: Record "LSC POS Terminal Receipt Text"): Text;
    var
        retVal: Text;

    begin
        case POSText.Align of
            POSText.Align::Left:
                retVal := '#L######################################'; //40 (will be resized by FormatStr)
            POSText.Align::Center:
                retVal := '#C######################################';
            POSText.Align::Right:
                retVal := '#R######################################';
        end;

        if POSText.Wide then
            retVal := CopyStr(retVal, 1, 20);

        exit(retVal);
    end;

    procedure GetReceiptBarcodeWidthAndHeight(var pPosTerminal: Record "LSC POS Terminal"; var bcWidth: Integer; var bcHeight: Integer)
    begin
        if pPosTerminal."Receipt Barcode Width" > 0 then
            bcWidth := pPosTerminal."Receipt Barcode Width"
        else begin
            if (ActivePrinter.Printer = ActivePrinter.Printer::"ePOS-Printer") and
               (pPosTerminal."Print Receipt BC Type" <> pPosTerminal."Print Receipt BC Type"::QRCODE) then
                bcWidth := 2
            else
                bcWidth := 8;
        end;

        if pPosTerminal."Receipt Barcode Height" > 0 then
            bcHeight := pPosTerminal."Receipt Barcode Height"
        else
            bcHeight := 40;
    end;
}
