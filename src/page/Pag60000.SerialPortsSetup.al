page 60000 "Serial Ports Setup"
{
    PageType = Worksheet;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "OPT Serial Port Setup";
    CaptionML = ENU = 'Serial Ports Setup Pinpad', ESM = 'Configuracion Puerto Serial Pinpad', ESI = 'Configuracion Puerto Serial Pinpad';
    AutoSplitKey = true;
    layout
    {
        area(Content)
        {
            repeater(Settings)
            {
                field(Store; Rec.Store) { ApplicationArea = all; }
                field("Pos Terminal"; Rec."Pos Terminal") { ApplicationArea = ALL; }
                field(Password; Rec.Password) { ApplicationArea = all; Caption = 'AdminPass'; }
                field(URL; Rec.URL) { ApplicationArea = all; }
                field("Port Name"; Rec."Port Name") { ApplicationArea = All; CaptionML = ENU = 'Port', ESM = 'Puerto', ESP = 'Puerto', ESI = 'Puerto'; }
                field("Port Lafise"; Rec."Port Lafise") { ApplicationArea = all; }
                field(AdminPass_Anulacion; Rec.AdminPass_Anulacion) { ApplicationArea = All; }
                field("Print Receipt Merchant"; Rec."Print Receipt Merchant") { ApplicationArea = all; }

                field("Merchant Cord"; Rec."Merchant Cord") { ApplicationArea = all; }
                field("Terminal Cord"; Rec."Terminal Cord") { ApplicationArea = all; }
                field("Merchant USD"; Rec."Merchant USD") { ApplicationArea = all; }
                field("Terminal USD"; Rec."Terminal USD") { ApplicationArea = all; }
                //field("Logo path"; Rec."Logo path") { ApplicationArea = all; }
            }
        }
    }

    actions
    {

        area(Processing)
        {
            action(Check)
            {
                ApplicationArea = All;
                CaptionML = ENU = 'Initialization', ESP = 'Inicializacion', ESI = 'Inicializacion', ESM = 'Inicializacion';
                trigger OnAction()
                var
                    Respuesta: Text;
                    SetupPinpad: Record "OPT Serial Port Setup";
                begin
                    Clear(SetupPinpad);
                    SetupPinpad.SetRange(No, Rec.No);
                    if SetupPinpad.FindSet() then begin end;
                    //SetupPinpad.SetRange("Pos Terminal");
                    //SetupPinpad.set
                    cConect.Check(SetupPinpad);
                end;
            }
        }
    }

    procedure GetJsonTextField(O: JsonObject; NameObject: Text): Text
    var
        Result: JsonToken;
    begin
        if O.Get(NameObject, Result) then
            exit(Result.AsValue().AsText());
    end;

    var
        cConect: Codeunit ConnectCom;
        tMessage: Text;
}