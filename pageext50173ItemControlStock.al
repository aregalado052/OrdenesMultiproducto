pageextension 50279 ItemCardExt_StockControl extends "Item Card"
{
    layout
    {
        addlast(Item) // o el grupo que prefieras
        {
            field("Control de Stock"; Rec."Control de Stock")
            {
                ApplicationArea = All;
            }
            field("Componente"; Rec."Componente")
            {
                ApplicationArea = All;
            }
        }

    }
}

pageextension 50179 ItemListExt_StockControl extends "Item List"
{
    layout
    {
        addlast(Control1)
        {
            field("Control de Stock"; Rec."Control de Stock")
            {
                ApplicationArea = All;
            }
            field("Componente"; Rec."Componente")
            {
                ApplicationArea = All;
            }
        }
    }
}
