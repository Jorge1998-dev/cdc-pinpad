page 60001 "Lafise Log"
{
    ApplicationArea = All;
    Caption = 'Lafise Log';
    PageType = List;
    SourceTable = "Trans. LAF";
    UsageCategory = Administration;
    DelayedInsert = false;
    ModifyAllowed = false;
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                Caption = 'General';

                field("Store No."; Rec."Store No.")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Store No. field.', Comment = '%';
                }
                field("POS Terminal No."; Rec."POS Terminal No.")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the POS Terminal No. field.', Comment = '%';
                }
                field("Receipt No."; Rec."Receipt No.")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Receipt No. field.', Comment = '%';
                }
                field("Transaction No."; Rec."Transaction No.")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Transaction No. field.', Comment = '%';
                }
                field(Message; Rec.Message)
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Message field.', Comment = '%';
                }
                field("Response Code"; Rec."Response Code")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Response Code field.', Comment = '%';
                }
                field("Authorization Code"; Rec."Authorization Code")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Authorization Code field.', Comment = '%';
                }
                field("Amount Authorized"; Rec."Amount Authorized")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Amount Authorized field.', Comment = '%';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Amount field.', Comment = '%';
                }
                field("Card Number"; Rec."Card Number")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Card Number field.', Comment = '%';
                }
                field("Card Entry Mode"; Rec."Card Entry Mode")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Card Entry Mode field.', Comment = '%';
                }
                field("Card Type"; Rec."Card Type")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Card Type field.', Comment = '%';
                }
                field("Cardholder Name"; Rec."Cardholder Name")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Cardholder Name field.', Comment = '%';
                }
                field("Date"; Rec."Date")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Date field.', Comment = '%';
                }
                field("Ecr Id"; Rec."Ecr Id")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Ecr Id field.', Comment = '%';
                }
                field(TC; Rec.TC)
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the TC field.', Comment = '%';
                }
                field(TSI; Rec.TSI)
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the TSI field.', Comment = '%';
                }
                field(TVR; Rec.TVR)
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the TVR field.', Comment = '%';
                }
                field(TenderType; Rec.TenderType)
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the TenderType field.', Comment = '%';
                }
                field(TerminalId; Rec.TerminalId)
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the TerminalId field.', Comment = '%';
                }
                field("Time"; Rec."Time")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Time field.', Comment = '%';
                }
                field("Void Sale"; Rec."Void Sale")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Void Sale field.', Comment = '%';
                }
                field("Voucher Number"; Rec."Voucher Number")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Voucher Number field.', Comment = '%';
                }
                field(tGetJson; tGetJson)
                {
                    ApplicationArea = all;
                    //ToolTip = 'Specifies the value of the bJsonResponse field.', Comment = '%';
                }
                field(claIDTran; Rec.claIDTran)
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the claIDTran field.', Comment = '%';
                }
                field(claTMSTID; Rec.claTMSTID)
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the claTMSTID field.', Comment = '%';
                }
                field(status; Rec.status)
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the status field.', Comment = '%';
                }
                field(TimeSettle; Rec.TimeSettle)
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the TimeSettle field.', Comment = '%';
                }
                field("Transaction Type"; Rec."Transaction Type")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Transaction Type field.', Comment = '%';
                }
                field("Host Response"; Rec."Host Response")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Host Response field.', Comment = '%';
                }

            }

        }
    }
    trigger OnAfterGetRecord()
    var
        myInt: Integer;
    begin
        tGetJson := Rec.GetRequest();
    end;

    var
        tGetJson: Text;
}
