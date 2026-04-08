codeunit 60003 "Button Settle"
{
    TableNo = "LSC POS Menu Line";
    trigger OnRun()
    var
        cSettle: Codeunit ConnectCom;


    begin

        case Rec.Command of
            'SETTLE':
                begin
                    cSettle.SendSettle();
                end;
            'REPORTLAFISE':
                begin
                    cSettle.SenRepDetail();
                end;
        END;

    end;
}