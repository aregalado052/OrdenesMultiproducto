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

pageextension 50181 AdminEmpresarialInventarioExt extends "Business Manager Role Center"
{
    actions
    {
        // Lo añadimos al final del área de Informes (Reporting)
        addlast(Reporting)
        {
            group(InventoryReports)
            {
                Caption = 'Informes de inventario';

                action(InfoControlInventario)
                {
                    ApplicationArea = All;
                    Caption = 'Información Control Inventario';
                    Image = Report;

                    // Puedes usar por ID o por nombre, las dos son válidas:
                    // RunObject = report "Información Control Inventario";
                    RunObject = report 50401;
                }
            }
        }
    }
}
