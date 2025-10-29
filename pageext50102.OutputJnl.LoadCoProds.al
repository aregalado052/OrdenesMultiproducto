pageextension 50132 "OutputJnl.LoadCoProds" extends "Output Journal"
{
    actions
    {
        addlast(Processing)
        {
            action(LoadCoProducts)
            {
                Caption = 'Cargar coproductos';
                ApplicationArea = All;
                Image = Import;

                trigger OnAction()
                var
                    Co: Record "Prod. Order Co-Product";
                    Curr: Record "Item Journal Line";
                    NewLine: Record "Item Journal Line";
                    Jnl: Record "Item Journal Line";
                    ProdOrder: Record "Production Order";
                    ProdStatus: Enum "Production Order Status";
                    OrderNo: Code[20];
                    HeaderItem: Code[20];
                begin
                    // Tomar la línea actual del diario
                    if not Curr.Get(Rec."Journal Template Name", Rec."Journal Batch Name", Rec."Line No.") then
                        Curr := Rec;

                    OrderNo := Curr."Order No.";
                    if OrderNo = '' then
                        Error('La línea no está ligada a una orden de producción.');

                    // Obtener Status e ítem cabecera de la orden
                    ProdOrder.Reset();
                    ProdOrder.SetRange("No.", OrderNo);
                    if not ProdOrder.FindFirst() then
                        Error('No se encontró la orden %1.', OrderNo);
                    ProdStatus := ProdOrder.Status;
                    HeaderItem := ProdOrder."Source No.";

                    // Borrar líneas del producto cabecera en este batch
                    Jnl.Reset();
                    Jnl.SetRange("Journal Template Name", Curr."Journal Template Name");
                    Jnl.SetRange("Journal Batch Name", Curr."Journal Batch Name");
                    Jnl.SetRange("Order No.", OrderNo);
                    Jnl.SetRange("Item No.", HeaderItem);
                    if Jnl.FindSet() then
                        repeat
                            Jnl.Delete(true);
                        until Jnl.Next() = 0;

                    // Cargar co-productos definidos para la orden/estado
                    Co.SetRange("Prod. Order No.", OrderNo);
                    Co.SetRange(Status, ProdStatus);
                    if Co.IsEmpty() then
                        Error('No hay coproductos definidos para la orden %1.', OrderNo);

                    if Co.FindSet() then
                        repeat
                            // Evitar duplicados: si ya existe, no insertar
                            Jnl.Reset();
                            Jnl.SetRange("Journal Template Name", Curr."Journal Template Name");
                            Jnl.SetRange("Journal Batch Name", Curr."Journal Batch Name");
                            Jnl.SetRange("Order No.", OrderNo);
                            Jnl.SetRange("Item No.", Co."Item No.");

                            if not Jnl.FindFirst() then begin
                                Clear(NewLine);
                                NewLine.Init();
                                NewLine.Validate("Journal Template Name", Curr."Journal Template Name");
                                NewLine.Validate("Journal Batch Name", Curr."Journal Batch Name");
                                NewLine.Validate("Posting Date", Curr."Posting Date");
                                NewLine.Validate("Order No.", OrderNo);
                                NewLine.Validate("Item No.", Co."Item No.");
                                NewLine.Validate(Quantity, Co."Expected Qty.");
                                // Si tu plantilla lo requiere:
                                // NewLine.Validate("Entry Type", NewLine."Entry Type"::Output);

                                // Copiar almacén/ubicación de la línea actual
                                if Curr."Location Code" <> '' then
                                    NewLine.Validate("Location Code", Curr."Location Code");
                                if Curr."Bin Code" <> '' then
                                    NewLine.Validate("Bin Code", Curr."Bin Code");

                                NewLine.Insert(true);
                            end;
                        until Co.Next() = 0;

                    Message('Coproductos cargados para la orden %1.', OrderNo);
                end;
            }

            action(AssignCoProdCosts)
            {
                Caption = 'Asignar costes coproductos';
                ApplicationArea = All;
                Image = CalculateCost;

                trigger OnAction()
                var
                    Co: Record "Prod. Order Co-Product";
                    Curr: Record "Item Journal Line";
                    Jnl: Record "Item Journal Line";
                    ProdOrder: Record "Production Order";
                    ProdStatus: Enum "Production Order Status";
                    Alloc: Codeunit "CoProd Cost Allocation";
                    OrderNo: Code[20];
                    UC: Decimal;
                begin
                    // Tomar la línea actual del diario
                    if not Curr.Get(Rec."Journal Template Name", Rec."Journal Batch Name", Rec."Line No.") then
                        Curr := Rec;

                    OrderNo := Curr."Order No.";
                    if OrderNo = '' then
                        Error('La línea no está ligada a una orden de producción.');

                    // Obtener Status de la orden
                    ProdOrder.Reset();
                    ProdOrder.SetRange("No.", OrderNo);
                    if not ProdOrder.FindFirst() then
                        Error('No se encontró la orden %1.', OrderNo);
                    ProdStatus := ProdOrder.Status;

                    // Recorrer líneas del batch para esa orden e item, asignando coste si es coproducto
                    Jnl.Reset();
                    Jnl.SetRange("Journal Template Name", Curr."Journal Template Name");
                    Jnl.SetRange("Journal Batch Name", Curr."Journal Batch Name");
                    Jnl.SetRange("Order No.", OrderNo);
                    if Jnl.FindSet() then
                        repeat
                            Co.SetRange("Prod. Order No.", OrderNo);
                            Co.SetRange(Status, ProdStatus);
                            Co.SetRange("Item No.", Jnl."Item No.");
                            if Co.FindFirst() then begin
                                UC := Alloc.ComputeUnitCost(OrderNo, ProdStatus, Jnl."Item No.", Jnl.Quantity);
                                if UC <> 0 then begin
                                    Jnl.Validate("Unit Cost", UC);
                                    Jnl.Modify(true);
                                end;
                            end;
                        until Jnl.Next() = 0;

                    Message('Costes asignados según la configuración de coproductos.');
                end;
            }
        }
    }
}
