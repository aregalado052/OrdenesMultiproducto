page 50300 "Prod. BOM Co-Products"
{
    PageType = ListPart;
    SourceTable = "Prod. BOM Co-Product";
    ApplicationArea = All;

    // 👇 Clave para evitar Line No. = 0 y conflictos con SystemId
    AutoSplitKey = true;
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                // (Opcional) mostrar el No. de línea solo lectura
                // field("Line No."; Rec."Line No.") { ApplicationArea = All; Editable = false; }

                field("Item No."; Rec."Item No.") { ApplicationArea = All; }
                field("Quantity per"; Rec."Quantity per") { ApplicationArea = All; }
                field("Cost Share %"; Rec."Cost Share %") { ApplicationArea = All; }
                field("Co-Product Type"; Rec."Co-Product Type") { ApplicationArea = All; }
                field("Unit of Measure Code"; Rec."Unit of Measure Code") { ApplicationArea = All; }
            }
        }
    }
}

