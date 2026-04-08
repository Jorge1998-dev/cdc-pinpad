codeunit 60000 ConnectCom
{
    [Scope('onPrem')]
    procedure Check(var SetupPinpad: Record "OPT Serial Port Setup")
    var
        IBaudRate: Integer;
        Respuesta: Text;
        Respuesta2: Text;
        Curl: Text;
        Curl2: Text;
        ApiLAF: Codeunit ConectApi;
        turl: Text;
        tString: Text;
        cBase64Convert: Codeunit "Base64 Convert";
        errorConexion: Text;
        JOrderNoToken: JsonToken;
        JJSonToken: JsonObject;
        ListaDivisa: List of [Text];
        ListNod1Div: List of [Text];
        ListNod2Div: List of [Text];
        GetListDiv: Text;
        GetNod1: Text;
        GetNod2: Text;
    begin
        //SPS.get();
        tString := '';
        tString := tString + '{';
        tString := tString + '   "id":"4",'; // identifica el tipo de transaccion
        tString := tString + '   "claIDTran":"4",';
        //tString := tString + '   "AdminPass":"' + SPS.Password + '"';
        tString := tString + '   "AdminPass":"' + SetupPinpad.Password + '"';
        tString := tString + '}';
        tString := cBase64Convert.ToBase64(tString, TextEncoding::UTF8);
        turl := '';
        turl := SetupPinpad.URL;
        turl := turl.Replace('http://', '');
        Curl2 := SetupPinpad.URL + ':' + SetupPinpad."Port Name" + '/api/SendTrans';
        Curl := Curl + '{';
        Curl := Curl + '  "sHost": "' + turl + '",';
        Curl := Curl + '  "iPort": "' + SetupPinpad."Port Lafise" + '",';
        Curl := Curl + '  "sMessage": "' + tString + '"';
        Curl := Curl + '}';
        Respuesta2 := ApiLAF.GetApi(Curl, Curl2);

        JJSonToken.ReadFrom(Respuesta2);
        SetupPinpad.AdminPass_Anulacion := GetJsonTextField(JJSonToken, 'Admin_Pass');

        GetListDiv := GetJsonTextField(JJSonToken, 'ListAcquirer');
        if GetListDiv <> '' then begin
            if GetListDiv.Contains('~') then begin

                ListaDivisa := GetListDiv.Split('~');
                GetNod1 := ListaDivisa.Get(1);
                GetNod2 := ListaDivisa.Get(2);

                if GetNod1 <> '' then begin
                    ListNod1Div := GetNod1.Split('-');
                    SetupPinpad."Merchant Cord" := ListNod1Div.Get(3);
                    SetupPinpad."Terminal Cord" := ListNod1Div.Get(4);
                end;
                if GetNod2 <> '' then begin
                    ListNod2Div := GetNod2.Split('-');
                    SetupPinpad."Merchant USD" := ListNod2Div.Get(3);
                    SetupPinpad."Terminal USD" := ListNod2Div.Get(4);
                end;
            end;
            SetupPinpad.Modify(false);
        end;

        Message(Respuesta2);
    end;

    procedure SendSale(pAmount: Decimal; pReceipt: Text[100]; pCurrency: Text; REC: Record "LSC POS Transaction"; pTendertype: text; pPaymenAmount: Decimal) CurrencyResp: Text
    var
        Respuesta: Text;
        Respuesta2: Text;
        AmountPP: Text;
        AmountPP2: Text;
        JOrderNoToken: JsonToken;
        JJSonToken: JsonObject;
        pTable: Record "Trans. LAF";
        rTender: Record "LSC Tender Type";
        tLAFResponse: Text;
        tLAFeRROR: Text;
        itries: Integer;
        iErrors: Integer;
        ILineCardEntry: Integer;
        POSSESION2: Codeunit "LSC POS Session";
        Curl: Text;
        Curl2: Text;
        ApiLAF: Codeunit ConectApi;
        cExchange: Codeunit "OPT Events Pinpad";
        CurrencyUSD: Decimal;
        LscTenderType: Record "LSC Tender Type";
        POSGUI: Codeunit "LSC POS GUI";
        tString: Text;
        tString2: Text;
        tCurrency: Text;
        cBase64Convert: Codeunit "Base64 Convert";
        turl: Text;
        iYear: Integer;
        tRepuesta: Text;
        rPosTerminal: Record "LSC POS Terminal";
        rCurrency: Record Currency;
        errorConexion: Text;
        idError: Text;
    begin
        // SPS.get();
        ScreenDisplay('');
        ScreenDisplay('Procesando..');
        Clear(SPS);
        SPS.SetRange(Store, REC."Store No.");
        SPS.SetRange("Pos Terminal", REC."POS Terminal No.");
        if SPS.FindSet() then begin end;

        InitTextVariable();
        Curl := '';
        Curl2 := '';

        Clear(rCurrency);
        Clear(rPosTerminal);
        if pCurrency <> '' then
            rCurrency.get(pCurrency);

        rPosTerminal.SetRange("Store No.", REC."Store No.");
        rPosTerminal.SetRange("No.", REC."POS Terminal No.");
        if rPosTerminal.FindSet() then begin end;
        // IF pCurrency <> '' then begin
        //     if pCurrency = 'USD' then begin
        //         CurrencyUSD := pPaymenAmount;
        //     END else
        //         CurrencyUSD := cExchange.POSExchangeLCYToFCY(today, pCurrency, pPaymenAmount);
        // END ELSE
        CurrencyUSD := pAmount;

        AmountPP2 := DELCHR(FORMAT(CurrencyUSD, 0, '<Precision,2:2><Integer><Decimals>'), '=', '.,');

        Clear(rTender);
        rTender.SetRange("Store No.", POSSESION.StoreNo());
        rTender.SetRange(Code, pTendertype);
        if rTender.FindSet() then begin
        end;

        tString := '';
        tString := tString + '{';
        tString := tString + '   "id":"1",'; // identifica el tipo de transaccion
        tString := tString + '   "claIDTran":"2",';
        tString := tString + '   "monto":"' + AmountPP2 + '",';
        tString := tString + '   "last4":"",';
        tString := tString + '   "expDate":"",';
        tString := tString + '   "Currency":"' + rTender.CurrencyId + '",';
        tString := tString + '   "MerchantID":"' + rTender.Ids + '",';
        tString := tString + '   "PayEntryMode":"Contactless",';
        tString := tString + '   "TxSubType":"1",';
        tString := tString + '   "BaseAmount":"' + AmountPP2 + '"';
        tString := tString + '}';
        tString := cBase64Convert.ToBase64(tString, TextEncoding::UTF8);
        turl := '';
        turl := SPS.URL;
        turl := turl.Replace('http://', '');

        Curl2 := SPS.URL + ':' + SPS."Port Name" + '/api/SendTrans';
        Curl := Curl + '{';
        Curl := Curl + '  "sHost": "' + turl + '",';
        Curl := Curl + '  "iPort": "' + SPS."Port Lafise" + '",';
        Curl := Curl + '  "sMessage": "' + tString + '"';
        Curl := Curl + '}';


        ScreenDisplay('Enviando la peticion al dispositivo..');

        Respuesta := ApiLAF.GetApi(Curl, Curl2);



        //OPTREV +++

        // 000000P042000000552
        // tRepuesta := '{';
        // tRepuesta := tRepuesta + '"authNum":"013632",';
        // tRepuesta := tRepuesta + '"numReceipt":"000050",';
        // tRepuesta := tRepuesta + '"CardHolderName":"PAYWAVE/VISA",';
        // tRepuesta := tRepuesta + '"EMVTagsP55":"9F3303E060C89F34031F00009F3501229F100706011203A02000820220009F3602000B9F26083352D806FB9AA2F19F270180950500000000009F37043430D2559F02060000000000969F03060000000000009F1A0205585F2A0205589A032410299C01005F3401009F6E04207000000000",';
        // tRepuesta := tRepuesta + '"AccountNumber":"3919",';
        // tRepuesta := tRepuesta + '"Brand":"VISACREDITO",';
        // tRepuesta := tRepuesta + '"AID":"A0000000031010",';
        // tRepuesta := tRepuesta + '"TVR":"0000000000",';
        // tRepuesta := tRepuesta + '"ARQC":"3352D806FB9AA2F1",';
        // tRepuesta := tRepuesta + '"TC":"E060C8",';
        // tRepuesta := tRepuesta + '"TSI":"0000",';
        // tRepuesta := tRepuesta + '"NA":"3430D255",';
        // tRepuesta := tRepuesta + '"TerminalId":"83533360",';
        // tRepuesta := tRepuesta + '"AcquireId":"063003000",';
        // tRepuesta := tRepuesta + '"PayEntryMode":"07",';
        // tRepuesta := tRepuesta + '"Lot":"",';
        // tRepuesta := tRepuesta + '"Reference":"430319000029",';
        // tRepuesta := tRepuesta + '"Charge":"000020",';
        // tRepuesta := tRepuesta + '"Discount":"000",';
        // tRepuesta := tRepuesta + '"Amount":"96",';
        // tRepuesta := tRepuesta + '"TxnDate":"1029",';
        // tRepuesta := tRepuesta + '"TxnTime":"195843",';
        // tRepuesta := tRepuesta + '"claIDTran":"2"';
        // tRepuesta := tRepuesta + '}';
        // Respuesta := tRepuesta;
        //
        //OPTREV --

        ///  ////**********
        /// Creacion del log de respuesta Lafise
        pTable.Reset();
        pTable.SetRange("POS Terminal No.", POSSESION.TerminalNo());
        pTable.SetRange("Store No.", POSSESION.StoreNo());
        pTable.SetRange("Receipt No.", pReceipt);
        if pTable.FindLast() then begin
            itries := pTable.Trie;
        end else begin
            itries := 1;
        end;

        Clear(pTable);
        pTable.Init();
        pTable."Store No." := POSSESION.StoreNo();
        pTable."POS Terminal No." := POSSESION.TerminalNo();
        pTable."Receipt No." := pReceipt;
        pTable.Trie := itries + 1;
        pTable."Transaction Type" := 'SALE';
        pTable.Log := true;
        pTable.Insert();
        pTable.SetRequest(Respuesta);
        Commit();
        /// **********

        JJSonToken.ReadFrom(Respuesta);


        idError := GetJsonTextField(JJSonToken, 'id');
        errorConexion := GetStructuredSaleError(JJSonToken, idError);
        if errorConexion <> '' then
            RaisePinpadError(pTable, errorConexion, POSGUI);

        if TryGetPinpadErrorFromField(GetJsonTextField(JJSonToken, 'claAuth'), errorConexion) then
            RaisePinpadError(pTable, errorConexion, POSGUI);

        if TryGetPinpadErrorFromField(GetJsonTextField(JJSonToken, 'authNum'), errorConexion) then
            RaisePinpadError(pTable, errorConexion, POSGUI);

        if TryGetPinpadErrorFromField(GetJsonTextField(JJSonToken, 'status'), errorConexion) then
            RaisePinpadError(pTable, errorConexion, POSGUI);

        pTable.Reset();
        pTable.SetRange("POS Terminal No.", POSSESION.TerminalNo());
        pTable.SetRange("Store No.", POSSESION.StoreNo());
        pTable.SetRange("Receipt No.", pReceipt);
        if pTable.FindLast() then begin
            itries := pTable.Trie;
        end else begin
            itries := 1;
        end;
        iErrors := 0;
        Clear(pTable);
        pTable.Init();
        pTable."Store No." := POSSESION.StoreNo();
        pTable."POS Terminal No." := POSSESION.TerminalNo();
        pTable."Receipt No." := pReceipt;
        pTable.Trie := itries + 1;

        pTable."Authorization Code" := GetJsonTextField(JJSonToken, 'authNum');
        iYear := Date2DMY(Today, 3);
        pTable.Date := CopyStr(Format(iYear), 3, 2) + GetJsonTextField(JJSonToken, 'TxnDate');
        pTable.Time := GetJsonTextField(JJSonToken, 'TxnTime');
        pTable."Card Type" := GetJsonTextField(JJSonToken, 'Brand');
        pTable."Card Number" := GetJsonTextField(JJSonToken, 'AccountNumber');
        pTable."Cardholder Name" := GetJsonTextField(JJSonToken, 'CardHolderName');
        pTable."Payment Amount" := pPaymenAmount;
        pTable."EFT Amount" := CurrencyUSD;
        pTable."Response Code" := '00';
        pTable.Symbol := rCurrency.Symbol;

        case GetJsonTextField(JJSonToken, 'PayEntryMode') of
            '01':
                begin
                    pTable."Card Entry Mode" := 'Manual';
                end;
            '02':
                begin
                    pTable."Card Entry Mode" := 'Banda';
                end;

            '05':
                begin
                    pTable."Card Entry Mode" := 'Chip';
                end;
            '07':
                begin
                    pTable."Card Entry Mode" := 'Contactless';
                end;
        end;

        pTable."Voucher Number" := GetJsonTextField(JJSonToken, 'numReceipt');
        pTable."Card Type" := GetJsonTextField(JJSonToken, 'Brand');
        pTable."Currency Code" := pCurrency;
        pTable.TC := GetJsonTextField(JJSonToken, 'TC');
        pTable.ARQC := GetJsonTextField(JJSonToken, 'ARQC');
        pTable.TVR := GetJsonTextField(JJSonToken, 'TVR');
        pTable.AID := GetJsonTextField(JJSonToken, 'AID');
        pTable."Range Type" := GetJsonTextField(JJSonToken, 'Brand');
        pTable.EMVTagsP55 := GetJsonTextField(JJSonToken, 'EMVTagsP55');
        pTable.TSI := GetJsonTextField(JJSonToken, 'TSI');
        pTable.NA := GetJsonTextField(JJSonToken, 'NA');
        pTable."Amount Authorized" := GetJsonTextField(JJSonToken, 'Amount');
        pTable.TerminalId := GetJsonTextField(JJSonToken, 'TerminalId');

        pTable.AcquireId := GetJsonTextField(JJSonToken, 'AcquireId');
        pTable.claIDTran := GetJsonTextField(JJSonToken, 'claIDTran');
        pTable.Charge := GetJsonTextField(JJSonToken, 'Charge');
        pTable.Reference := GetJsonTextField(JJSonToken, 'Reference');
        pTable."Transaction Type" := 'SALE';

        pTable.TenderType := pTendertype;
        pTable."EFT Amount" := pAmount;
        pTable.Log := false;
        pTable.Insert(false);
        Commit();
        pTable.SetRequest(Respuesta);

        //////
        /// 
        pTable."Host Response" := 'Approved';
        pTable.Modify();

        ILineCardEntry := 0;
        Clear(rCardEntry);
        rCardEntry.SetRange("POS Terminal No.", pTable."POS Terminal No.");
        rCardEntry.SetRange("Store No.", pTable."Store No.");
        if rCardEntry.FindLast() then
            ILineCardEntry := rCardEntry."Entry No." + 1
        else
            ILineCardEntry := 1;

        Clear(rCardEntry);
        rCardEntry.Init();
        rCardEntry."Store No." := pTable."Store No.";
        rCardEntry."POS Terminal No." := pTable."POS Terminal No.";
        rCardEntry."Entry No." := ILineCardEntry;

        rCardEntry."Transaction No." := 1;
        rCardEntry."Receipt No." := pReceipt;
        rCardEntry."EFT POS Terminal No." := pTable."POS Terminal No.";
        rCardEntry."Tender Type" := pTable.TenderType;
        rCardEntry."Transaction Type" := rCardEntry."Transaction Type"::Sale;
        rCardEntry."MSR input" := false;
        rCardEntry.Date := Today;
        rCardEntry.Time := time;
        rCardEntry."Authorisation Ok" := true;
        rCardEntry.Voided := false;
        rCardEntry."Card Number" := cprint.SetCardNumber(pTable."Card Number");
        if strlen(pTable."Card Type") > 10 then
            rCardEntry."Card Type" := CopyStr(pTable."Card Type", 1, 10)
        else
            rCardEntry."Card Type" := pTable."Card Type";


        if pTable."Range Type" <> '' then
            rCardEntry."Card Type" := CopyStr(pTable."Range Type", 1, 10);
        rCardEntry."Card Type Name" := pTable."Range Type";
        rCardEntry."Res.code" := 'Success';
        rCardEntry.Message := pTable."Host Response";
        rCardEntry."EFT Trans. Time" := Format(CreateDateTime(rCardEntry.Date, rCardEntry.Time));
        rCardEntry.Amount := pTable."Payment Amount";
        rCardEntry."EFT Currency" := pCurrency;
        //rCardEntry."EFT TenderType" := pTable."Card Type";
        rCardEntry."EFT Store No." := pTable."Store No.";
        rCardEntry."EFT Authorization Status" := rCardEntry."EFT Authorization Status"::Approved;
        rCardEntry."EFT Transaction Type" := rCardEntry."EFT Transaction Type"::Purchase;
        rCardEntry."EFT Device Name" := 'LAFISE';
        rCardEntry."EFT Terminal ID" := pTable.TerminalId;
        //  rCardEntry."EFT Merchant No." := rPosTerminal."Skip Merchant Receipt"
        rCardEntry."Auth. Source Code" := pTable."Authorization Code";
        rCardEntry."Voucher Number" := pTable."Voucher Number";
        rCardEntry.Insert(true);
        CurrencyResp := pCurrency;
        ScreenDisplay('Approved');
    end;
    // end;

    procedure SendVoid(pVoucher: text; var pReceipt: Record "LSC POS Card Entry"; pTendertype: Text)
    var
        // ConPinpadLAF: DotNet ConnectLAF;
        Respuesta: Text;
        Respuesta2: Text;
        AmountPP: Text;
        JOrderNoToken: JsonToken;
        JJSonToken: JsonObject;
        pTable: Record "Trans. LAF";
        bOpen: Text;
        bClose: Text;
        tTimeOut: Text;
        tCO: Text;
        tPR: Text;
        rTender: Record "LSC Tender Type";
        tSendVoucher: Text;

        tLAFeRROR: Text;
        bError: Text;
        itries: Integer;
        iErrors: Integer;
        //cMessage: Codeunit "LAF LSC POS Transaction Impl";
        ILineCardEntry: Integer;
        POSSESION2: Codeunit "LSC POS Session";
        Curl: Text;
        Curl2: Text;
        ApiLAF: Codeunit ConectApi;
        POSGUI: Codeunit "LSC POS GUI";
        tString: Text;
        tString2: Text;
        tCurrency: Text;
        cBase64Convert: Codeunit "Base64 Convert";
        turl: Text;
        AmountPP2: Text;
        iYear: Integer;
        tRespuesta: Text;
        FindTransLafise: Record "Trans. LAF";
        PosTransaction: Record "LSC POS Transaction";
        rCurrency: Record Currency;
        errorConexion: Text;
        idError: Text;
    begin

        ScreenDisplay('');
        ScreenDisplay('Procesando..');
        //SPS.get();
        Clear(SPS);
        SPS.SetRange(Store, pReceipt."Store No.");
        SPS.SetRange("Pos Terminal", pReceipt."POS Terminal No.");
        if SPS.FindSet() then begin end;

        Clear(PosTransaction);
        PosTransaction.SetRange("Store No.", pReceipt."Store No.");
        PosTransaction.SetRange("POS Terminal No.", pReceipt."POS Terminal No.");
        PosTransaction.SetRange("Receipt No.", pReceipt."Receipt No.");
        if PosTransaction.FindSet() then begin

        end;




        Clear(rTender);
        rTender.SetRange("Store No.", POSSESION.StoreNo());
        rTender.SetRange(Code, pTendertype);
        if rTender.FindSet() then begin
        end;
        tString := '';
        tString := tString + '{';
        tString := tString + '   "id":"2",'; // identifica el tipo de transaccion
        tString := tString + '   "claIDTran":"2",';
        tString := tString + '   "AdminPass":"' + SPS.AdminPass_Anulacion + '",';
        tString := tString + '   "numReceipt":"' + pVoucher + '"';
        tString := tString + '}';
        tString := cBase64Convert.ToBase64(tString, TextEncoding::UTF8);

        turl := '';
        turl := SPS.URL;
        turl := turl.Replace('http://', '');
        Curl2 := SPS.URL + ':' + SPS."Port Name" + '/api/SendTrans';
        Curl := Curl + '{';
        Curl := Curl + '  "sHost": "' + turl + '",';
        Curl := Curl + '  "iPort": "' + SPS."Port Lafise" + '",';
        Curl := Curl + '  "sMessage": "' + tString + '"';
        Curl := Curl + '}';
        ScreenDisplay('Enviando la peticion de anulacion al dispositivo..');

        Respuesta := ApiLAF.GetApi(Curl, Curl2);

        //OPTREV +++
        //// <summary>
        // tRespuesta := '{';
        // tRespuesta := tRespuesta + '"claAuth":"009921",';
        // tRespuesta := tRespuesta + '"VoucherInfoOut":"",';
        // tRespuesta := tRespuesta + '"TxnDate":"1029",';
        // tRespuesta := tRespuesta + '"TxnTime":"195108",';
        // tRespuesta := tRespuesta + '"claIDTran":"2"';
        // tRespuesta := tRespuesta + '}';
        // Respuesta := tRespuesta;
        /// <returns>Return value of type Code[10].</returns>
        /// 
//OPTREV ---
        ///  ////**********
        /// Creacion del log de respuesta Lafise
        pTable.Reset();
        pTable.SetRange("POS Terminal No.", POSSESION.TerminalNo());
        pTable.SetRange("Store No.", POSSESION.StoreNo());
        pTable.SetRange("Receipt No.", pReceipt."Receipt No.");
        if pTable.FindLast() then begin
            itries := pTable.Trie;
        end else begin
            itries := 1;
        end;

        Clear(pTable);
        pTable.Init();
        pTable."Store No." := POSSESION.StoreNo();
        pTable."POS Terminal No." := POSSESION.TerminalNo();
        pTable."Receipt No." := pReceipt."Receipt No.";
        pTable.Trie := itries + 1;
        pTable."Transaction Type" := 'VOID SALE';
        pTable.Reference := 'Anulacion';
        pTable.Log := true;
        pTable.Insert();
        pTable.SetRequest(Respuesta);
        Commit();

        /// **********

        JJSonToken.ReadFrom(Respuesta);
        ScreenDisplay('Obteniendo respuesta del dispositivo..');

        idError := GetJsonTextField(JJSonToken, 'id');
        errorConexion := GetStructuredSaleError(JJSonToken, idError);
        if errorConexion <> '' then
            RaisePinpadError(pTable, errorConexion, POSGUI);

        if TryGetPinpadErrorFromField(GetJsonTextField(JJSonToken, 'claAuth'), errorConexion) then
            RaisePinpadError(pTable, errorConexion, POSGUI);

        if TryGetPinpadErrorFromField(GetJsonTextField(JJSonToken, 'authNum'), errorConexion) then
            RaisePinpadError(pTable, errorConexion, POSGUI);

        if TryGetPinpadErrorFromField(GetJsonTextField(JJSonToken, 'status'), errorConexion) then
            RaisePinpadError(pTable, errorConexion, POSGUI);

        pTable.Reset();
        pTable.SetRange("POS Terminal No.", POSSESION.TerminalNo());
        pTable.SetRange("Store No.", POSSESION.StoreNo());
        pTable.SetRange("Receipt No.", pReceipt."Receipt No.");
        if pTable.FindLast() then begin
            itries := pTable.Trie;
        end else begin
            itries := 1;
        end;


        Clear(FindTransLafise);
        FindTransLafise.SetRange("Store No.", pReceipt."Store No.");
        FindTransLafise.SetRange("POS Terminal No.", pReceipt."POS Terminal No.");
        FindTransLafise.SetRange("Receipt No.", PosTransaction."Retrieved from Receipt No.");
        FindTransLafise.SetRange(Log, false);///
        if FindTransLafise.FindLast() then begin
            iErrors := 0;
            Clear(pTable);
            pTable.Init();
            pTable."Store No." := POSSESION.StoreNo();
            pTable."POS Terminal No." := POSSESION.TerminalNo();
            pTable."Receipt No." := pReceipt."Receipt No.";
            pTable.Trie := itries + 1;
            pTable."Host Response" := 'Approved';
            pTable."Authorization Code" := GetJsonTextField(JJSonToken, 'claAuth');
            pTable."Response Code" := '00';
            iYear := Date2DMY(Today, 3);
            pTable.Date := CopyStr(Format(iYear), 3, 2) + GetJsonTextField(JJSonToken, 'TxnDate');
            pTable.Time := GetJsonTextField(JJSonToken, 'TxnTime');
            pTable."Card Number" := FindTransLafise."Card Number";
            pTable."Cardholder Name" := FindTransLafise."Cardholder Name";
            pTable."Card Entry Mode" := FindTransLafise."Card Entry Mode";
            pTable."Voucher Number" := FindTransLafise."Voucher Number";

            pTable."Card Type" := FindTransLafise."Card Type";
            pTable."Currency Code" := FindTransLafise."Currency Code";
            pTable."Amount Authorized" := FindTransLafise."Amount Authorized";
            pTable.TenderType := pTendertype;
            pTable."Payment Amount" := FindTransLafise."Payment Amount";
            pTable."Void Sale" := true;
            pTable.TerminalId := FindTransLafise.TerminalId;
            pTable."Transaction Type" := 'VOID SALE';
            pTable.CurrCodeCardEntry := FindTransLafise.CurrCodeCardEntry;
            pTable."EFT Amount" := FindTransLafise."EFT Amount";
            pTable.Symbol := FindTransLafise.Symbol;
            pTable.Reference := 'Anulacion';
            pTable.Log := false;
            pTable.Insert();
            pTable.SetRequest(Respuesta);
            ScreenDisplay('Anulacion Aprobada');
        end;
        // pTable.Modify();

        //pReceipt."EFT POS Terminal No." := pTable."POS Terminal No.";
        pReceipt."Tender Type" := pTable.TenderType;
        // pReceipt."Transaction Type" := rCardEntry."Transaction Type"::"Void Sale";
        pReceipt."MSR input" := false;
        pReceipt.Date := Today;
        pReceipt.Time := time;
        pReceipt."Authorisation Ok" := true;
        pReceipt.Voided := false;
        pReceipt."Card Number" := cprint.SetCardNumber(pTable."Card Number");
        if StrLen(pTable."Card Type") > 10 then
            pReceipt."Card Type" := CopyStr(pTable."Card Type", 1, 10)
        else
            pReceipt."Card Type" := pTable."Card Type";
        pReceipt."Card Type Name" := pTable."Range Type";
        pReceipt."Res.code" := 'Success';
        pReceipt.Message := pTable."Host Response";
        pReceipt."EFT Trans. Time" := Format(CreateDateTime(rCardEntry.Date, rCardEntry.Time));
        pReceipt.Amount := pTable."Payment Amount";
        //pReceipt."EFT TenderType" := pTable."Card Type";
        pReceipt."EFT Store No." := pTable."Store No.";
        pReceipt."EFT Authorization Status" := rCardEntry."EFT Authorization Status"::Approved;
        pReceipt."EFT Transaction Type" := rCardEntry."EFT Transaction Type"::Purchase;
        pReceipt."EFT Device Name" := 'LAFISE';
        pReceipt."EFT Currency" := pTable."Currency Code";
        pReceipt."Voucher Number" := pTable."Voucher Number";
        pReceipt."Client Transaction ID" := pTable."Voucher Number";
    end;




    procedure GetTenderType(): Code[10]

    begin
        exit(vTenderType)
    end;

    procedure SetTenderType(pTenderType: Code[10])

    begin
        if pTenderType <> '' then
            vTenderType := pTenderType;
    end;

    procedure GetJsonTextField(O: JsonObject; NameObject: Text): Text
    var
        Result: JsonToken;
    begin
        if O.Get(NameObject, Result) then
            exit(Result.AsValue().AsText());
    end;

    local procedure GetStructuredSaleError(ResponseJson: JsonObject; IdError: Text): Text
    var
        StatusText: Text;
        MessageText: Text;
        TitleText: Text;
        DetailText: Text;
        StatusCode: Integer;
        PinpadErrorText: Text;
    begin
        StatusText := DelChr(GetJsonTextField(ResponseJson, 'status'), '<>', ' ');
        MessageText := GetJsonTextField(ResponseJson, 'Message');
        if MessageText = '' then
            MessageText := GetJsonTextField(ResponseJson, 'message');
        TitleText := GetJsonTextField(ResponseJson, 'title');
        DetailText := GetJsonTextField(ResponseJson, 'detail');

        if Evaluate(StatusCode, StatusText) and (StatusCode >= 400) then begin
            if TryGetPinpadErrorFromField(DetailText, PinpadErrorText) then
                exit(PinpadErrorText);
            if DetailText <> '' then
                exit(DetailText);

            if TryGetPinpadErrorFromField(MessageText, PinpadErrorText) then
                exit(PinpadErrorText);
            if MessageText <> '' then
                exit(MessageText);

            if TitleText <> '' then
                exit(TitleText);

            exit(StrSubstNo('Error de comunicación con pinpad (HTTP %1).', StatusText));
        end;

        if IdError <> '' then begin
            if TryGetPinpadErrorFromField(MessageText, PinpadErrorText) then
                exit(PinpadErrorText);
            if MessageText <> '' then
                exit(MessageText);

            if TryGetPinpadErrorFromField(DetailText, PinpadErrorText) then
                exit(PinpadErrorText);
            if DetailText <> '' then
                exit(DetailText);

            if TitleText <> '' then
                exit(TitleText);

            IdError := DelChr(IdError, '<>', ' ');
            exit(StrSubstNo('Error de pinpad. Id: %1', IdError));
        end;

        if TryGetPinpadErrorFromField(MessageText, PinpadErrorText) then
            exit(PinpadErrorText);

        if TryGetPinpadErrorFromField(DetailText, PinpadErrorText) then
            exit(PinpadErrorText);

        if TryGetPinpadErrorFromField(TitleText, PinpadErrorText) then
            exit(PinpadErrorText);

        exit('');
    end;

    local procedure TryGetPinpadErrorFromField(FieldValue: Text; var ErrorText: Text): Boolean
    var
        RawValue: Text;
        SeparatorPos: Integer;
        ErrorCodeText: Text;
        DetailText: Text;
    begin
        FieldValue := DelChr(FieldValue, '<>', ' ');
        if CopyStr(UpperCase(FieldValue), 1, 3) <> 'ERR' then
            exit(false);

        RawValue := CopyStr(FieldValue, 4);
        while (StrLen(RawValue) > 0) and
              IsErrorSeparator(CopyStr(RawValue, 1, 1)) do
            RawValue := CopyStr(RawValue, 2);
        RawValue := DelChr(RawValue, '<>', ' ');

        if RawValue = '' then begin
            ErrorText := 'Error de pinpad';
            exit(true);
        end;

        SeparatorPos := GetFirstErrorSeparatorPosition(RawValue);
        if SeparatorPos > 0 then begin
            ErrorCodeText := DelChr(CopyStr(RawValue, 1, SeparatorPos - 1), '<>', ' ');
            DetailText := DelChr(CopyStr(RawValue, SeparatorPos + 1), '<>', ' ');
            while (StrLen(DetailText) > 0) and
                  IsErrorSeparator(CopyStr(DetailText, 1, 1)) do
                DetailText := CopyStr(DetailText, 2);
            DetailText := DelChr(DetailText, '<>', ' ');
        end else begin
            ErrorCodeText := DelChr(RawValue, '<>', ' ');
            DetailText := '';
        end;

        if DetailText <> '' then begin
            DetailText := StripSecondaryNumericCode(DetailText);
            ErrorText := DetailText;
            exit(true);
        end;

        if TryGetMappedPinpadError(ErrorCodeText, ErrorText) then
            exit(true);

        ErrorText := RawValue;

        exit(true);
    end;

    local procedure StripSecondaryNumericCode(DetailText: Text): Text
    var
        SeparatorPos: Integer;
        PossibleCode: Text;
        SecondaryCode: Integer;
    begin
        SeparatorPos := GetFirstErrorSeparatorPosition(DetailText);
        if SeparatorPos = 0 then
            exit(DetailText);

        PossibleCode := DelChr(CopyStr(DetailText, 1, SeparatorPos - 1), '<>', ' ');
        if not Evaluate(SecondaryCode, PossibleCode) then
            exit(DetailText);

        DetailText := DelChr(CopyStr(DetailText, SeparatorPos + 1), '<>', ' ');
        while (StrLen(DetailText) > 0) and
              IsErrorSeparator(CopyStr(DetailText, 1, 1)) do
            DetailText := CopyStr(DetailText, 2);

        if DetailText = '' then
            exit(PossibleCode);

        exit(DetailText);
    end;

    local procedure IsErrorSeparator(ValueChar: Text[1]): Boolean
    begin
        exit((ValueChar = ':') or
             (ValueChar = ';') or
             (ValueChar = '-') or
             (ValueChar = ' '));
    end;

    local procedure GetFirstErrorSeparatorPosition(ValueText: Text): Integer
    var
        ColonPos: Integer;
        DashPos: Integer;
        SemicolonPos: Integer;
        SpacePos: Integer;
        MinPos: Integer;
    begin
        MinPos := 0;
        ColonPos := StrPos(ValueText, ':');
        DashPos := StrPos(ValueText, '-');
        SemicolonPos := StrPos(ValueText, ';');
        SpacePos := StrPos(ValueText, ' ');

        if ColonPos > 0 then
            MinPos := ColonPos;
        if (DashPos > 0) and ((MinPos = 0) or (DashPos < MinPos)) then
            MinPos := DashPos;
        if (SemicolonPos > 0) and ((MinPos = 0) or (SemicolonPos < MinPos)) then
            MinPos := SemicolonPos;
        if (SpacePos > 0) and ((MinPos = 0) or (SpacePos < MinPos)) then
            MinPos := SpacePos;

        exit(MinPos);
    end;

    local procedure TryGetMappedPinpadError(CodeText: Text; var ErrorText: Text): Boolean
    var
        ErrorCode: Integer;
    begin
        CodeText := DelChr(CodeText, '<>', ' ');
        if not Evaluate(ErrorCode, CodeText) then
            exit(false);

        if (ErrorCode <= 0) or (ErrorCode > ArrayLen(OnesText)) then
            exit(false);

        if OnesText[ErrorCode] = '' then
            exit(false);

        ErrorText := OnesText[ErrorCode];
        exit(true);
    end;

    local procedure RaisePinpadError(var pTable: Record "Trans. LAF"; ErrorText: Text; POSGUI: Codeunit "LSC POS GUI")
    var
        DisplayText: Text[100];
        ErrorText250: Text[250];
    begin
        if ErrorText = '' then
            ErrorText := 'UNKNOWN';

        pTable.Message := CopyStr(ErrorText, 1, MaxStrLen(pTable.Message));
        pTable.Modify();

        DisplayText := CopyStr(ErrorText, 1, MaxStrLen(DisplayText));
        ScreenDisplay(DisplayText);
        Commit();
        POSGUI.PostCommand("LSC POS Command"::ERRORBEEP, DisplayText);

        ErrorText250 := CopyStr(ErrorText, 1, MaxStrLen(ErrorText250));
        Error(ErrorText250);
    end;

    local procedure ReadJSON(JsonObjectText: Text): Text
    var
        jObject: JsonObject;
        Token: JsonToken;
        tokenArray: JsonToken;
        jObject2: JsonObject;
        jObject3: JsonObject;
        tokenItem: JsonToken;
        tokenPrices: JsonToken;
        iLine: Integer;
        tValorGet: Text;
        TextJson: Text;
        bOpen: Text;
    begin
        iLine := 0;
        jObject.ReadFrom(JsonObjectText);
        Token := jObject.AsToken();

        if Token.IsObject then begin
            jObject2 := Token.AsObject();
            jObject2.Get('CO', tokenItem);
            TextJson := tokenItem.AsValue().AsText();
            bOpen := CopyStr(TextJson, 1, 2);
            TextJson := '';
            jObject3 := Token.AsObject();
            jObject3.Get('PR', tokenPrices);

            tValorGet := Format(tokenItem.AsValue().AsText());
            if bOpen = '01' then
                Error('');

        end;

        exit(TextJson);

    end;

    var
        SPS: Record "OPT Serial Port Setup";
        gMensaje: Text;
        rTenderType: Record "LSC Tender Type";
        vTenderType: Code[10];
        POSSESION: Codeunit "LSC POS Session";
        rCardEntry: Record "LSC POS Card Entry";
        cprint: Codeunit "LAF Printing Utility";
    // rg: Record "LSC POS Card Print Text";


    procedure SendSettle()
    var

        // ConPinpadLAF: DotNet ConnectLAF;
        Respuesta: Text;
        Respuesta2: Text;
        AmountPP: Text;
        JOrderNoToken: JsonToken;
        JJSonToken: JsonObject;
        pTable: Record "Trans. LAF";
        bOpen: Text;
        bClose: Text;
        tTimeOut: Text;
        tCO: Text;
        tPR: Text;
        rTender: Record "LSC Tender Type";
        tLAFResponse: Text;
        tLAFeRROR: Text;
        bError: Text;
        itries: Integer;
        iErrors: Integer;
        //cMessage: Codeunit "LAF LSC POS Transaction Impl";
        ILineCardEntry: Integer;
        POSSESION2: Codeunit "LSC POS Session";
        tOPort: Text;
        fDate: Date;
        fTime: time;
        fTimeRest: Integer;
        ExitTime: Decimal;
        Curl: Text;
        Curl2: Text;
        ApiLAF: Codeunit ConectApi;
        POSGUI: Codeunit "LSC POS GUI";
        tString: Text;
        tString2: Text;
        tCurrency: Text;
        cBase64Convert: Codeunit "Base64 Convert";
        turl: Text;
        AmountPP2: Text;
        errorConexion: Text;
        idError: Text;
    begin
        ScreenDisplay('');
        ScreenDisplay('Enviando la peticion al dispositivo..');
        fDate := Today;
        fTime := Time;
        pTable.Reset();
        pTable.SetCurrentKey("Store No.", "POS Terminal No.", Trie);
        pTable.SetRange("POS Terminal No.", POSSESION.TerminalNo());
        pTable.SetRange("Store No.", POSSESION.StoreNo());
        pTable.SetRange("Transaction Type", 'SETTLE');
        pTable.SetRange(DateSettle, fDate);
        IF pTable.FindLast() then begin
            fTimeRest := fTime - pTable.TimeSettle;
            ExitTime := fTimeRest / 1000;
            ExitTime := ExitTime / 60;
            if ExitTime < 5 then
                exit;
        end;

        Clear(SPS);
        SPS.SetRange(Store, POSSESION2.StoreNo());
        SPS.SetRange("Pos Terminal", POSSESION2.TerminalNo());
        if SPS.FindSet() then begin end;

        // SPS.get();

        tString := '';
        tString := tString + '{';
        tString := tString + '   "id":"3",'; // identifica el tipo de transaccion
        tString := tString + '   "claIDTran":"3",';
        tString := tString + '   "AdminPass":"' + SPS.AdminPass_Anulacion + '"';
        tString := tString + '}';
        tString := cBase64Convert.ToBase64(tString, TextEncoding::UTF8);

        turl := '';
        turl := SPS.URL;
        turl := turl.Replace('http://', '');
        Curl2 := SPS.URL + ':' + SPS."Port Name" + '/api/SendTrans';
        Curl := Curl + '{';
        Curl := Curl + '  "sHost": "' + turl + '",';
        Curl := Curl + '  "iPort": "' + SPS."Port Lafise" + '",';
        Curl := Curl + '  "sMessage": "' + tString + '"';
        Curl := Curl + '}';

        Respuesta := ApiLAF.GetApi(Curl, Curl2);


        pTable.Reset();
        pTable.SetCurrentKey("Store No.", "POS Terminal No.", Trie);
        pTable.SetRange("POS Terminal No.", POSSESION.TerminalNo());
        pTable.SetRange("Store No.", POSSESION.StoreNo());
        pTable.SetRange("Transaction Type", 'SETTLE');
        // pTable.SetRange("Receipt No.", pReceipt);
        if pTable.FindLast() then begin
            itries := pTable.Trie;
        end else begin
            itries := 1;
        end;


        Clear(pTable);
        pTable.Init();
        pTable."Store No." := POSSESION.StoreNo();
        pTable."POS Terminal No." := POSSESION.TerminalNo();
        //pTable."Receipt No." := pReceipt."Receipt No.";
        pTable.Trie := itries + 1;
        pTable."Transaction Type" := 'SETTLE';
        pTable.Reference := '';
        pTable.Log := true;
        pTable.Insert();
        pTable.SetRequest(Respuesta);
        Commit();

        JJSonToken.ReadFrom(Respuesta);



        idError := GetJsonTextField(JJSonToken, 'id');
        errorConexion := GetStructuredSaleError(JJSonToken, idError);
        if errorConexion <> '' then
            RaisePinpadError(pTable, errorConexion, POSGUI);

        if TryGetPinpadErrorFromField(GetJsonTextField(JJSonToken, 'claAuth'), errorConexion) then
            RaisePinpadError(pTable, errorConexion, POSGUI);

        if TryGetPinpadErrorFromField(GetJsonTextField(JJSonToken, 'authNum'), errorConexion) then
            RaisePinpadError(pTable, errorConexion, POSGUI);

        if TryGetPinpadErrorFromField(GetJsonTextField(JJSonToken, 'status'), errorConexion) then
            RaisePinpadError(pTable, errorConexion, POSGUI);


        pTable.Reset();
        pTable.SetCurrentKey("Store No.", "POS Terminal No.", Trie);
        pTable.SetRange("POS Terminal No.", POSSESION.TerminalNo());
        pTable.SetRange("Store No.", POSSESION.StoreNo());
        pTable.SetRange("Transaction Type", 'SETTLE');
        // pTable.SetRange("Receipt No.", pReceipt);
        if pTable.FindLast() then begin
            itries := pTable.Trie;
        end else begin
            itries := 1;
        end;


        iErrors := 0;
        Clear(pTable);
        pTable.Init();
        pTable."Store No." := POSSESION.StoreNo();
        pTable."POS Terminal No." := POSSESION.TerminalNo();
        pTable."Receipt No." := 'S' + Format(itries + 1);
        pTable.Trie := itries + 1;
        pTable.Message := GetJsonTextField(JJSonToken, 'status');
        // pTable."Host Response" := GetJsonTextField(JJSonToken, 'Host Response');
        pTable."Authorization Code" := GetJsonTextField(JJSonToken, 'Authorization Code');
        pTable."Response Code" := '00';
        pTable.status := GetJsonTextField(JJSonToken, 'status');
        pTable.BatchInfo := GetJsonTextField(JJSonToken, 'BatchInfo');
        pTable.TerminalId := GetJsonTextField(JJSonToken, 'TerminalId');
        pTable.AcquireId := GetJsonTextField(JJSonToken, 'AcquireId');

        pTable.claTMSTID := GetJsonTextField(JJSonToken, 'claTMSTID');
        pTable.claIDTran := GetJsonTextField(JJSonToken, 'claIDTran');
        pTable."Transaction Type" := 'SETTLE';
        pTable.DateSettle := Today;
        pTable.TimeSettle := time;

        pTable.Insert();
        pTable.SetRequest(Respuesta);

        //Message('Host Response : ' + pTable."Host Response" + '  Respose Code: ' + pTable."Response Code");

    end;


    procedure SenRepDetail()
    var

        // ConPinpadLAF: DotNet ConnectLAF;
        Respuesta: Text;
        Respuesta2: Text;
        AmountPP: Text;
        JOrderNoToken: JsonToken;
        JJSonToken: JsonObject;
        pTable: Record "Trans. LAF";
        bOpen: Text;
        bClose: Text;
        tTimeOut: Text;
        tCO: Text;
        tPR: Text;
        rTender: Record "LSC Tender Type";
        tLAFResponse: Text;
        tLAFeRROR: Text;
        bError: Text;
        itries: Integer;
        iErrors: Integer;
        //cMessage: Codeunit "LAF LSC POS Transaction Impl";
        ILineCardEntry: Integer;
        POSSESION2: Codeunit "LSC POS Session";
        tOPort: Text;
        fDate: Date;
        fTime: time;
        fTimeRest: Integer;
        ExitTime: Decimal;
        Curl: Text;
        Curl2: Text;
        ApiLAF: Codeunit ConectApi;
        POSGUI: Codeunit "LSC POS GUI";
        tString: Text;
        tString2: Text;
        tCurrency: Text;
        cBase64Convert: Codeunit "Base64 Convert";
        turl: Text;
        AmountPP2: Text;
        errorConexion: Text;
        idError: Text;
    begin


        ScreenDisplay('');
        ScreenDisplay('Enviando la peticion al dispositivo..');
        fDate := Today;
        fTime := Time;
        // pTable.Reset();
        // pTable.SetCurrentKey("Store No.", "POS Terminal No.", Trie);
        // pTable.SetRange("POS Terminal No.", POSSESION.TerminalNo());
        // pTable.SetRange("Store No.", POSSESION.StoreNo());
        // pTable.SetRange("Transaction Type", 'SETTLE');
        // pTable.SetRange(DateSettle, fDate);
        // IF pTable.FindLast() then begin
        //     fTimeRest := fTime - pTable.TimeSettle;
        //     ExitTime := fTimeRest / 1000;
        //     ExitTime := ExitTime / 60;
        //     if ExitTime < 5 then
        //         exit;
        // end;

        //SPS.get();
        Clear(SPS);
        SPS.SetRange(Store, POSSESION2.StoreNo());
        SPS.SetRange("Pos Terminal", POSSESION2.TerminalNo());
        if SPS.FindSet() then begin end;

        tString := '';
        tString := tString + '{';
        tString := tString + '   "id":"7",'; // identifica el tipo de transaccion
        tString := tString + '   "claIDTran":"7",';
        tString := tString + '   "ReportType":"1",';
        tString := tString + '   "AdminPass":"' + SPS.AdminPass_Anulacion + '"';
        tString := tString + '}';
        tString := cBase64Convert.ToBase64(tString, TextEncoding::UTF8);

        turl := '';
        turl := SPS.URL;
        turl := turl.Replace('http://', '');
        Curl2 := SPS.URL + ':' + SPS."Port Name" + '/api/SendTrans';
        Curl := Curl + '{';
        Curl := Curl + '  "sHost": "' + turl + '",';
        Curl := Curl + '  "iPort": "' + SPS."Port Lafise" + '",';
        Curl := Curl + '  "sMessage": "' + tString + '"';
        Curl := Curl + '}';

        Respuesta := ApiLAF.GetApi(Curl, Curl2);



        pTable.Reset();
        pTable.SetCurrentKey("Store No.", "POS Terminal No.", Trie);
        pTable.SetRange("POS Terminal No.", POSSESION.TerminalNo());
        pTable.SetRange("Store No.", POSSESION.StoreNo());
        pTable.SetRange("Transaction Type", 'REPORTDETAIL');
        // pTable.SetRange("Receipt No.", pReceipt);
        if pTable.FindLast() then begin
            itries := pTable.Trie;
        end else begin
            itries := 1;
        end;


        Clear(pTable);
        pTable.Init();
        pTable."Store No." := POSSESION.StoreNo();
        pTable."POS Terminal No." := POSSESION.TerminalNo();
        //pTable."Receipt No." := pReceipt."Receipt No.";
        pTable.Trie := itries + 1;
        pTable."Transaction Type" := 'REPORTDETAIL';
        pTable.Reference := '';
        pTable.Log := true;
        pTable.Insert();
        pTable.SetRequest(Respuesta);
        Commit();


        JJSonToken.ReadFrom(Respuesta);



        idError := GetJsonTextField(JJSonToken, 'id');
        errorConexion := GetStructuredSaleError(JJSonToken, idError);
        if errorConexion <> '' then
            RaisePinpadError(pTable, errorConexion, POSGUI);

        if TryGetPinpadErrorFromField(GetJsonTextField(JJSonToken, 'claAuth'), errorConexion) then
            RaisePinpadError(pTable, errorConexion, POSGUI);

        if TryGetPinpadErrorFromField(GetJsonTextField(JJSonToken, 'authNum'), errorConexion) then
            RaisePinpadError(pTable, errorConexion, POSGUI);

        if TryGetPinpadErrorFromField(GetJsonTextField(JJSonToken, 'status'), errorConexion) then
            RaisePinpadError(pTable, errorConexion, POSGUI);


        pTable.Reset();
        pTable.SetCurrentKey("Store No.", "POS Terminal No.", Trie);
        pTable.SetRange("POS Terminal No.", POSSESION.TerminalNo());
        pTable.SetRange("Store No.", POSSESION.StoreNo());
        pTable.SetRange("Transaction Type", 'REPORTDETAIL');
        // pTable.SetRange("Receipt No.", pReceipt);
        if pTable.FindLast() then begin
            itries := pTable.Trie;
        end else begin
            itries := 1;
        end;


        iErrors := 0;
        Clear(pTable);
        pTable.Init();
        pTable."Store No." := POSSESION.StoreNo();
        pTable."POS Terminal No." := POSSESION.TerminalNo();
        pTable."Receipt No." := 'R' + Format(itries + 1);
        pTable.Trie := itries + 1;
        pTable.Message := GetJsonTextField(JJSonToken, 'status');
        // pTable."Host Response" := GetJsonTextField(JJSonToken, 'Host Response');
        pTable."Authorization Code" := GetJsonTextField(JJSonToken, 'Authorization Code');
        pTable."Response Code" := '00';
        pTable.status := GetJsonTextField(JJSonToken, 'status');
        pTable.BatchInfo := GetJsonTextField(JJSonToken, 'BatchInfo');
        pTable.TerminalId := GetJsonTextField(JJSonToken, 'TerminalId');
        pTable.AcquireId := GetJsonTextField(JJSonToken, 'AcquireId');

        pTable.claTMSTID := GetJsonTextField(JJSonToken, 'claTMSTID');
        pTable.claIDTran := GetJsonTextField(JJSonToken, 'claIDTran');
        pTable."Transaction Type" := 'REPORTDETAIL';
        pTable.DateSettle := Today;
        pTable.TimeSettle := time;
        pTable.Insert();
        ScreenDisplay(pTable.status);
        pTable.SetRequest(Respuesta);
        //Message('Host Response : ' + pTable."Host Response" + '  Respose Code: ' + pTable."Response Code");

    end;

    procedure SendRefund(pAmount: Decimal; pReceipt: Text[100]; pCurrency: Text; REC: Record "LSC POS Transaction"; pTendertype: text; pPaymenAmount: Decimal)
    var
        // ConPinpadLAF: DotNet ConnectLAF;
        Respuesta: Text;
        Respuesta2: Text;
        AmountPP: Text;
        JOrderNoToken: JsonToken;
        JJSonToken: JsonObject;
        pTable: Record "Trans. LAF";
        bOpen: Text;
        bClose: Text;
        tTimeOut: Text;
        tCO: Text;
        tPR: Text;
        rTender: Record "LSC Tender Type";
        tLAFResponse: Text;
        tLAFeRROR: Text;
        bError: Text;
        itries: Integer;
        iErrors: Integer;
        //cMessage: Codeunit "LAF LSC POS Transaction Impl";
        cMessage: Codeunit "OPT POS Transaction Impl";
        ILineCardEntry: Integer;
        POSSESION2: Codeunit "LSC POS Session";
        POSGUI: Codeunit "LSC POS GUI";
    begin
        SPS.get();


        pTable.Reset();
        pTable.SetRange("POS Terminal No.", POSSESION.TerminalNo());
        pTable.SetRange("Store No.", POSSESION.StoreNo());
        pTable.SetRange("Receipt No.", pReceipt);
        if pTable.FindLast() then begin
            itries := pTable.Trie;
        end else begin
            itries := 1;
        end;


        iErrors := 0;
        Clear(pTable);
        pTable.Init();
        pTable."Store No." := POSSESION.StoreNo();
        pTable."POS Terminal No." := POSSESION.TerminalNo();
        pTable."Receipt No." := pReceipt;
        pTable.Trie := itries + 1;
        pTable.Message := GetJsonTextField(JJSonToken, 'Message');
        pTable."Host Response" := GetJsonTextField(JJSonToken, 'Host Response');
        pTable."Authorization Code" := GetJsonTextField(JJSonToken, 'Authorization Code');
        pTable."Response Code" := GetJsonTextField(JJSonToken, 'Response Code');
        pTable.Date := GetJsonTextField(JJSonToken, 'Date');
        pTable.Time := GetJsonTextField(JJSonToken, 'Time');
        pTable."Card Number" := GetJsonTextField(JJSonToken, 'Card Number');
        pTable."Cardholder Name" := GetJsonTextField(JJSonToken, 'Cardholder Name');
        pTable."Card Entry Mode" := GetJsonTextField(JJSonToken, 'Card Entry Mode');
        pTable."Voucher Number" := GetJsonTextField(JJSonToken, 'Voucher Number');
        pTable."Card Type" := GetJsonTextField(JJSonToken, 'Card Type');
        pTable."Currency Code" := GetJsonTextField(JJSonToken, 'Currency Code');
        pTable."Amount Authorized" := GetJsonTextField(JJSonToken, 'Amount Authorized');
        pTable."Software Version" := GetJsonTextField(JJSonToken, 'Software Version');
        pTable."Serial Number" := GetJsonTextField(JJSonToken, 'Serial Number');
        pTable."Ecr Id" := GetJsonTextField(JJSonToken, 'Ecr Id');
        pTable."Range Type" := GetJsonTextField(JJSonToken, 'Range Type');
        //pTable.E1 := GetJsonTextField(JJSonToken, 'E1');
        pTable.E2 := GetJsonTextField(JJSonToken, 'E2');
        pTable.TenderType := pTendertype;
        pTable."Payment Amount" := pPaymenAmount;
        pTable."Transaction Type" := 'SALE';
        pTable.CurrCodeCardEntry := pCurrency;
        tCO := GetJsonTextField(JJSonToken, 'CO');
        tPR := GetJsonTextField(JJSonToken, 'RP');
        bOpen := CopyStr(GetJsonTextField(JJSonToken, 'PO'), 1, 2);


        tTimeOut := GetJsonTextField(JJSonToken, 'TO');
        if CopyStr(tTimeOut, 1, 2) = '01' then begin
            tLAFeRROR := tLAFeRROR + '  ' + tTimeOut;
            iErrors += 1;
        end;


        if tCO <> '' then begin
            bError := CopyStr(tCO, 1, 2);
            if bError = '01' then begin
                tCO := CopyStr(tCO, 3, StrLen(tCO) - 2);
                tLAFeRROR := tCO;
                iErrors += 1;
            end;
            tLAFeRROR := tLAFeRROR;
        end;
        if iErrors <> 0 then begin

            POSGUI.PostCommand("LSC POS Command"::ERRORBEEP, CopyStr(tLAFeRROR, 1, 100));
            //cMessage.ErrorBeep(tLAFeRROR);
            Error('');
        end;

        if pTable."Response Code" <> '00' then begin
            if pTable."Response Code" = '' then begin
                // Error('no response received from the banking device');
                tLAFeRROR := 'no response received from the banking device';
                POSGUI.PostCommand("LSC POS Command"::ERRORBEEP, CopyStr(tLAFeRROR, 1, 100));
                //cMessage.ErrorBeep(tLAFeRROR);
                Error('');
            end else begin
                //Error(tLAFeRROR);
                tLAFeRROR := 'Host Response : ' + pTable."Host Response" + '  Respose Code: ' + pTable."Response Code";
                POSGUI.PostCommand("LSC POS Command"::ERRORBEEP, CopyStr(tLAFeRROR, 1, 100));
                //cMessage.ErrorBeep(tLAFeRROR);
                Error('');

            end;
        end;

        pTable.Insert();
        ILineCardEntry := 0;
        Clear(rCardEntry);
        rCardEntry.SetRange("POS Terminal No.", pTable."POS Terminal No.");
        rCardEntry.SetRange("Store No.", pTable."Store No.");
        if rCardEntry.FindLast() then
            ILineCardEntry := rCardEntry."Entry No." + 1
        else
            ILineCardEntry := 1;

        Clear(rCardEntry);
        rCardEntry.Init();
        rCardEntry."Store No." := pTable."Store No.";
        rCardEntry."POS Terminal No." := pTable."POS Terminal No.";
        rCardEntry."Entry No." := ILineCardEntry;

        rCardEntry."Transaction No." := 1;
        rCardEntry."Receipt No." := pReceipt;
        rCardEntry."EFT POS Terminal No." := pTable."POS Terminal No.";
        rCardEntry."Tender Type" := pTable.TenderType;
        rCardEntry."Transaction Type" := rCardEntry."Transaction Type"::Sale;
        rCardEntry."MSR input" := false;
        rCardEntry.Date := Today;
        rCardEntry.Time := time;
        rCardEntry."Authorisation Ok" := true;
        rCardEntry.Voided := false;
        rCardEntry."Card Number" := cprint.SetCardNumber(pTable."Card Number");
        rCardEntry."Card Type" := pTable."Card Type";
        rCardEntry."Card Type Name" := pTable."Range Type";
        rCardEntry."Res.code" := 'Success';
        rCardEntry.Message := pTable."Host Response";
        rCardEntry."EFT Trans. Time" := Format(CreateDateTime(rCardEntry.Date, rCardEntry.Time));
        rCardEntry.Amount := pTable."Payment Amount";
        rCardEntry."EFT Currency" := pCurrency;
        rCardEntry."EFT TenderType" := pTable."Card Type";
        rCardEntry."EFT Store No." := pTable."Store No.";
        rCardEntry."EFT Authorization Status" := rCardEntry."EFT Authorization Status"::Approved;
        rCardEntry."EFT Transaction Type" := rCardEntry."EFT Transaction Type"::Purchase;
        rCardEntry."EFT Device Name" := 'INGENICO';
        rCardEntry."Voucher Number" := pTable."Voucher Number";
        rCardEntry.Insert(true);
    end;


    local procedure Errores()
    var
        Text1: Text;
    begin

    end;

    procedure InitTextVariable()
    begin
        OnesText[1] := Text001;
        OnesText[2] := Text002;
        OnesText[3] := Text003;
        OnesText[4] := Text004;
        OnesText[5] := Text005;
        OnesText[6] := Text006;
        OnesText[7] := Text007;
        OnesText[8] := Text008;
        OnesText[9] := Text009;
        OnesText[10] := Text0010;
        OnesText[11] := Text011;
        OnesText[12] := Text012;
        OnesText[13] := Text013;
        OnesText[14] := Text014;
        OnesText[15] := Text015;
        OnesText[16] := Text016;
        OnesText[17] := Text017;
        OnesText[18] := Text018;
        OnesText[19] := Text019;
        OnesText[20] := Text020;
        OnesText[21] := Text021;
        OnesText[22] := Text022;
        OnesText[23] := Text023;
        OnesText[24] := Text024;
        OnesText[39] := Text039;
        OnesText[80] := Text080;
        OnesText[98] := Text098;
        OnesText[99] := Text099;

    end;

    var
        OnesText: array[100] of Text[80];
        Text001: label 'Fecha de Expiración Equivocada, Por favor verifique en la tarjeta';
        Text002: label 'Últimos 4 dígitos de la tarjeta equivocados, Por favor verifique en la tarjeta.';
        Text003: label 'Contraseña equivocada';
        Text004: label 'Número de recibo no encontrado.';
        Text005: label 'El recibo ya está anulado.';
        Text006: label 'No se puede anular ese recibo.';
        Text007: label 'Proceso cancelado.';
        Text008: label 'Moneda seleccionada equivocada.';
        Text009: label 'No hay transacciones.';
        Text0010: label 'Error en impresión, No se puede crear el archivo de reporte. dll';
        Text011: label 'Tiempo expirado esperando el ticket desde el PINPAD. dll';
        Text012: label 'Monto de Propina mayor al permitido.';
        Text013: label 'El impuesto no puede ser mayor al monto.';
        Text014: label 'Error reversando transacción';
        Text015: label 'Primero realice el cierre';
        Text016: label 'El monto debe ser mayor de 0';
        Text017: label 'Tarjeta no encontrada';
        Text018: label 'Error con la impresora configurada en VPOS.';
        Text019: label 'No permite ajuste de propina.';
        Text020: label 'Folio no encontrado';
        Text021: label 'MerchantID no de estar vacío.';
        Text022: label 'Timeout esperando lectura de tarjeta';
        Text023: label '';
        Text024: label '';
        Text039: label 'Código diferente de 00,11 en el campo p39 de la trama 0210 del ISO8583';
        Text080: label 'Error en el procesamiento de lectura de tarjeta (EMV, CTLS)';
        Text098: label 'Error procesando';
        Text099: label 'Error de comunicación';
        ScreenDisplayOpen: boolean;
        ScreenDisplayDialog: Dialog;


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
}
