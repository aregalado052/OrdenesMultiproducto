codeunit 50307 "CoProd Sync From BOM"
{
    procedure RunForOrder(OrderNo: Code[20]; Status: Enum "Production Order Status")
    var
        ProdOrder: Record "Production Order";
        ItemRec: Record Item;
        BomHdr: Record "Production BOM Header";
        BomCo: Record "Prod. BOM Co-Product";
        Co: Record "Prod. Order Co-Product";
        LineNo: Integer;
    begin
        if not ProdOrder.Get(Status, OrderNo) then
            Error('No existe la orden %1.', OrderNo);

        // Leer la BOM desde el artículo cabecera
        if not ItemRec.Get(ProdOrder."Source No.") then
            Error('El artículo %1 no existe.', ProdOrder."Source No.");
        if ItemRec."Production BOM No." = '' then
            Error('El artículo %1 no tiene "Production BOM No." asignado.', ItemRec."No.");
        if not BomHdr.Get(ItemRec."Production BOM No.") then
            Error('No se encontró la L.M. de producción %1.', ItemRec."Production BOM No.");

        // Limpiar y copiar coproductos
        Co.SetRange("Prod. Order No.", OrderNo);
        Co.SetRange(Status, Status);
        if Co.FindSet() then repeat Co.Delete(); until Co.Next() = 0;

        BomCo.SetRange("Production BOM No.", BomHdr."No.");
        LineNo := 10000;
        if BomCo.FindSet() then
            repeat
                Co.Init();
                Co."Prod. Order No." := OrderNo;
                Co.Status := Status;
                Co."Line No." := LineNo;
                Co."Item No." := BomCo."Item No.";
                Co."Expected Qty." := BomCo."Quantity per" * ProdOrder.Quantity; // escala por qty de orden
                Co."Cost Share %" := BomCo."Cost Share %";
                Co."UOM Code" := BomCo."Unit of Measure Code";
                Co.Insert();
                LineNo += 10000;
            until BomCo.Next() = 0;
    end;

}
