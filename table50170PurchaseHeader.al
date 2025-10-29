tableextension 50170 "PurchHeader.CloseFlag" extends "Purchase Header"
{
    fields
    {
        field(50171; "Closed (Custom)"; Boolean)
        {
            Caption = 'Closed (Custom)';
            DataClassification = CustomerContent;
        }
    }
}
