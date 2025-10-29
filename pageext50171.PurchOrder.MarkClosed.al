pageextension 50171 "PurchaseOrder.MarkClosed" extends "Purchase Order"
{
    actions
    {
        addlast(Processing)
        {
            action(MarkClosedCustom)
            {
                ApplicationArea = All;
                Caption = 'Marcar como cerrado (custom)';
                Image = Close;

                trigger OnAction()
                var
                    PH: Record "Purchase Header";
                begin
                    PH.Get(Rec."Document Type", Rec."No.");
                    if PH."Closed (Custom)" then begin
                        Message('Este pedido ya está marcado como cerrado (custom).');
                        exit;
                    end;

                    // Validaciones mínimas (opcional): si ya está totalmente recibido/facturado
                    // if (PH."Amount" <> 0) and (PH."Amount Received Not Invoiced" = 0) then;

                    PH.Validate("Closed (Custom)", true);
                    PH.Modify(true);
                    Message('Pedido %1 marcado como cerrado (custom). Ya no aparecerá en la lista por defecto.', PH."No.");
                end;
            }
        }
    }
}

pageextension 50172 "PurchaseOrderList.HideClosed" extends "Purchase Order List"
{
    layout
    {
        addafter(Status)
        {
            field("Closed (Custom)"; Rec."Closed (Custom)")
            {
                ApplicationArea = All;
                Caption = 'Cerrado (custom)';
                Editable = false;
            }
        }
    }

    actions
    {
        addlast(Navigation)
        {
            action(ToggleShowClosed)
            {
                ApplicationArea = All;
                Image = View;

                trigger OnAction()
                begin
                    ShowClosed := not ShowClosed;

                    if ShowClosed then
                        Rec.SetRange("Closed (Custom)")
                    else
                        Rec.SetRange("Closed (Custom)", false);

                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        // Por defecto, ocultar los cerrados custom
        ShowClosed := false;
        Rec.SetRange("Closed (Custom)", false);
    end;

    local procedure GetToggleCaption(): Text[50]
    begin
        if ShowClosed then
            exit('Ocultar cerrados (custom)')
        else
            exit('Mostrar también cerrados (custom)');
    end;

    var
        ShowClosed: Boolean;
}
