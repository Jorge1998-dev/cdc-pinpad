table 60000 "OPT Serial Port Setup"
{
    DataClassification = ToBeClassified;
    CaptionML = ENU = 'Serial Ports Setup Pinpad', ESM = 'Configuración de puertos seriales Pinpad', ESP = 'Configuración de puertos seriales Pinpad', ESI = 'Configuración de puertos seriales Pinpad';

    fields
    {
        field(60000; No; Integer) { DataClassification = ToBeClassified; }
        field(60001; "Port Name"; Code[10]) { }
        field(60002; "Port Lafise"; Code[10]) { CaptionML = ENU = 'Port Lafise', ESM = 'Puerto Lafise', ESP = 'Puerto Lafise', ESI = 'Puerto Lafise'; }
        field(60003; MerchantId; Text[50]) { DataClassification = ToBeClassified; }
        field(60004; "Pos Terminal"; Code[20]) { TableRelation = "LSC POS Terminal"."No." where("Store No." = field(Store)); }
        field(60005; Password; Text[150]) { CaptionML = ENU = 'Contraseña Técnico', ESI = 'Contraseña Técnico', ESM = 'Contraseña Técnico', ESP = 'Contraseña Técnico'; }
        field(60006; AdminPass_Anulacion; Text[150]) { CaptionML = ENU = 'AdminPass', ESM = 'Contraseña anulaciones', ESP = 'Contraseña anulaciones', ESI = 'Contraseña anulaciones'; }
        field(60010; URL; Text[250]) { }
        field(60011; "Print Receipt Merchant"; Boolean) { CaptionML = ENU = 'Print Receipt Merchant', ESM = 'Imprimir recibo de comercio', ESP = 'Imprimir recibo de comercio', ESI = 'Imprimir recibo de comercio'; }
        field(60012; "Logo path"; Text[250]) { CaptionML = ENU = 'Logo path', ESM = 'Ruta del logotipo', ESP = 'Ruta del logotipo', ESI = 'Ruta del logotipo'; }
        field(60013; "Store"; Code[20]) { TableRelation = "LSC Store"; }
        //field(60002; MerchantID; Text[20]) { }
        field(60014; TerminalID; Text[20]) { }
        field(60015; "Merchant Cord"; Text[50]) { }
        field(60016; "Merchant USD"; Text[50]) { }
        field(60017; "Terminal Cord"; Text[50]) { }
        field(60018; "Terminal USD"; Text[50]) { }
    }

    keys
    {
        key(Key1; No)
        {
            Clustered = true;
        }
    }

    var
        myInt: Integer;

    trigger OnInsert()
    var
        SetupPinpad: Record "OPT Serial Port Setup";
        iLine: Integer;
    begin
        // Clear(SetupPinpad);

        // if SetupPinpad.FindLast() then begin
        //     iLine := SetupPinpad.No + 1;
        // end else begin
        //     // SetupPinpad.No := 1;
        // end;
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

}