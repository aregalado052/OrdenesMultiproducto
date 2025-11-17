codeunit 50172 "SkipCancelledProdOrders"
{
    Subtype = Normal;

    [EventSubscriber(
        ObjectType::Report,
        Report::"Calculate Subcontracts",
        'OnBeforeInsertReqWkshLine',
        '',
        false,
        false)]
    local procedure OnBeforeInsertReqWkshLine_Subcon(
        var ProdOrderRoutingLine: Record "Prod. Order Routing Line";
        var WorkCenter: Record "Work Center";
        var ReqLine: Record "Requisition Line";
        var IsHandled: Boolean;
        ProdOrderLine: Record "Prod. Order Line")
    var
        ProdOrder: Record "Production Order";
    begin
        // Buscamos la cabecera de la orden de producción
        if ProdOrder.Get(ProdOrderLine.Status, ProdOrderLine."Prod. Order No.") then begin
            // Si la orden está marcada como anulada por el usuario, no creamos línea de hoja
            if ProdOrder."Cancelled By User" then begin
                IsHandled := true;  // Evita que el informe inserte la Req. Line
                exit;
            end;
        end;
    end;
}
