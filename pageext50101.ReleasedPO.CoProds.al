pageextension 50221 "ReleasedPO.CoProds" extends "Released Production Order"
{
    layout
    {
        addlast(Content)
        {
            group(CoProductsGroup)
            {
                Caption = 'Co-Products';
                part(CoProducts; "Prod. Order Co-Products")
                {
                    ApplicationArea = All;
                    SubPageLink = "Prod. Order No." = field("No."), Status = const(Released);
                }
            }
        }
    }
}
