pageextension 50134 "ReleasedPO.ValidateCoProds" extends "Released Production Order"
{
    actions
    {
        addlast(Processing)
        {
            action(ValidateCoProducts)
            {
                Caption = 'Validar % coproductos (=100)';
                ApplicationArea = All;
                Image = Check;
                trigger OnAction()
                var
                    V: Codeunit "CoProd Validation";
                begin
                    V.ValidatePercentSum(Rec."No.", Rec.Status);
                    Message('Validación OK: 100%%.');
                end;
            }
        }
    }
}
