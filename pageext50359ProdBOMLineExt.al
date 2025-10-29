pageextension 50359 "ProdBOMLineExt" extends "Production BOM Lines"
{
    layout
    {
        // Ancla tras un campo que exista en la página base
        addafter("Quantity per")
        {
            field("Coste Unitario (artículo)"; GetItemUnitCost())
            {
                ApplicationArea = All;
                Caption = 'Coste Unitario';
                Editable = false;
            }
            field("Coste Total"; GetTotalCost())
            {
                ApplicationArea = All;
                Caption = 'Coste Total';
                Editable = false;
            }
        }
    }

    local procedure GetItemUnitCost(): Decimal
    var
        ItemRec: Record Item;
    begin
        // OJO: usar Rec.Type y Rec.Type::Item
        if Rec.Type = Rec.Type::Item then begin
            if ItemRec.Get(Rec."No.") then
                exit(ItemRec."Unit Cost"); // o ItemRec."Standard Cost"
        end;
        exit(0);
    end;

    local procedure GetTotalCost(): Decimal
    begin
        exit(GetItemUnitCost() * Rec."Quantity per");
    end;
}
