enum 60001 "Baud Rate Ingenico"
{
    Extensible = true;
    AssignmentCompatibility = true;
    value(0; "1200") { }
    value(1; "2400") { }
    value(2; "4800") { }
    value(3; "9600") { }
    value(4; "19200") { }
    value(5; "38400") { }
    value(6; "57600") { }
    value(7; "115200") { }
}
enum 60002 "Data Bits Ingenico"
{
    Extensible = true;
    AssignmentCompatibility = true;
    value(0; "8") { }
    value(1; "7") { }
    value(2; "6") { }
    value(3; "5") { }
}

enum 60003 "Parity Ingenico"
{
    Extensible = true;
    AssignmentCompatibility = true;
    value(0; "None") { }
    value(1; "Even") { }
    value(2; "Odd") { }
    value(3; "Mark") { }
    value(4; "Space") { }
}
enum 60004 "Stop Bits Ingenico"
{
    Extensible = true;
    AssignmentCompatibility = true;
    value(0; "0") { }
    value(1; "1") { }
    value(2; "1.5") { }
    value(3; "2") { }

}
enum 60005 "Handshake Ingenico"
{
    Extensible = true;
    AssignmentCompatibility = true;
    value(0; "None") { }
    value(1; "RequestToSend") { }
    value(2; "RequestToSendXOnXOff") { }
    value(3; "XOnXOff") { }

}