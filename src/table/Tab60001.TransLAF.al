table 60001 "Trans. LAF"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Store No."; Code[10]) { Caption = 'Store No.'; DataClassification = CustomerContent; }
        field(2; "POS Terminal No."; Code[10]) { Caption = 'POS Terminal No.'; DataClassification = CustomerContent; }
        field(4; "Transaction No."; Integer) { Caption = 'Transaction No.'; DataClassification = CustomerContent; }
        field(6; "Receipt No."; Code[20]) { Caption = 'Receipt No.'; DataClassification = CustomerContent; }
        field(7; "Message"; Text[100]) { }
        field(8; "Host Response"; Text[100]) { }
        field(9; "Authorization Code"; Text[250]) { }
        field(10; "Response Code"; Text[100]) { }
        field(11; "Date"; Text[30]) { }
        field(12; "Time"; Text[30]) { }
        field(13; "Card Number"; Text[50]) { }
        field(14; "Cardholder Name"; Text[250]) { }
        field(15; "Card Entry Mode"; Text[50]) { }
        field(16; "Voucher Number"; Text[100]) { }
        field(17; "Card Type"; Text[100]) { }
        field(18; "Currency Code"; Text[100]) { }
        field(19; "Amount Authorized"; Text[30]) { }
        field(20; "Software Version"; Text[250]) { }
        field(21; "Serial Number"; Text[250]) { }
        field(22; "Ecr Id"; Text[50]) { }
        field(23; "Range Type"; Text[100]) { }
        field(24; "EMVTagsP55"; Text[1000]) { }
        field(25; "E2"; Text[1000]) { }
        field(26; Trie; Integer) { }
        field(27; "TenderType"; Code[20]) { }
        field(28; TC; text[50]) { }
        field(29; NA; Text[50]) { }
        field(30; "Close Port"; Boolean) { }
        field(31; "EFT Amount"; Decimal) { }
        field(32; "Payment Amount"; Decimal) { }
        field(33; "Void Sale"; Boolean) { }
        field(34; "Transaction Type"; Text[100]) { }
        field(35; DateSettle; date) { }
        field(36; TimeSettle; Time) { }
        field(37; CurrCodeCardEntry; Code[10]) { }
        field(38; bJsonResponse; Blob) { }
        field(39; AID; Text[20]) { }
        field(40; TVR; Text[20]) { }
        field(41; TSI; Text[20]) { }
        field(44; Reference; Text[50]) { }
        field(45; Charge; Text[20]) { }
        field(46; Amount; Text[20]) { }
        field(47; ARQC; Text[50]) { }
        field(48; TerminalId; Text[50]) { }
        field(49; AcquireId; Text[50]) { }
        field(50; claTMSTID; Text[50]) { }
        field(51; BatchInfo; Text[250]) { }
        field(52; claIDTran; Text[20]) { }
        field(53; status; Text[150]) { }
        field(54; NFC; Text[150]) { }
        field(55; Symbol; Text[50]) { }
        field(56; Log; Boolean) { }


    }

    keys
    {
        key(Key1; "Store No.", "POS Terminal No.", "Receipt No.", Trie)
        {
            Clustered = true;
        }
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

    procedure SetRequest(JsonResponse: Text)
    var
        OutStream: OutStream;
    begin
        Clear(bJsonResponse);
        bJsonResponse.CreateOutStream(OutStream, TEXTENCODING::UTF8);
        OutStream.WriteText(JsonResponse);
        Modify();
    end;

    procedure GetRequest() JsonResponse: Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        CalcFields(bJsonResponse);
        bJsonResponse.CreateInStream(InStream, TEXTENCODING::UTF8);
        exit(TypeHelper.TryReadAsTextWithSepAndFieldErrMsg(InStream, TypeHelper.LFSeparator(), FieldName(bJsonResponse)));
    end;

}