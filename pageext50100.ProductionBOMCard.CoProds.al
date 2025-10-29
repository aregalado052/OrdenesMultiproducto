pageextension 50265 "ProductionBOM.Card.CoProds" extends "Production BOM"
{


    layout
    {
        addlast(Content)
        {
            group(CoProductsGroup)
            {
                Caption = 'Co-Products';
                part(CoProducts; "Prod. BOM Co-Products")
                {
                    ApplicationArea = All;
                    SubPageLink = "Production BOM No." = field("No.");
                }
            }
        }
    }
}
