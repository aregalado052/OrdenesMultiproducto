pageextension 50303 "ReleasedPO.SyncCoProds" extends "Released Production Order"
{
    actions
    {
        addlast(Processing)
        {
            action(SyncCoProducts)
            {
                Caption = 'Sincronizar coproductos';
                ApplicationArea = All;
                Image = Refresh;
                trigger OnAction()
                var
                    Sync: Codeunit "CoProd Sync From BOM";
                begin
                    Sync.RunForOrder(Rec."No.", Rec.Status);
                    Message('Coproductos sincronizados desde la BOM.');
                end;
            }
        }
    }
}
