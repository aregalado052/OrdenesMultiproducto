tableextension 50171 "ProdOrderExt" extends "Production Order"
{
    fields
    {
        field(50100; "Cancelled By User"; Boolean)
        {
            Caption = 'Anulada por usuario';
            DataClassification = CustomerContent;
        }
        field(50101; "Cancelled Date"; Date)
        {
            Caption = 'Fecha anulación';
            DataClassification = CustomerContent;
        }
        field(50102; "Cancelled By"; Code[50])
        {
            Caption = 'Anulada por';
            DataClassification = CustomerContent;
        }
    }
}
