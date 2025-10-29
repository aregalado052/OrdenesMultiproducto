tableextension 50172 ItemExt_StockControl extends Item
{
    fields
    {
        field(50100; "Control de Stock"; Boolean)
        {
            Caption = 'Control de Stock';
            DataClassification = ToBeClassified;
        }
        field(50101; "Componente"; Boolean)
        {
            Caption = 'Componente';
            DataClassification = ToBeClassified;
        }
    }
}