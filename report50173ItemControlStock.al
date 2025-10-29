report 50400 "Inf. Control de Stock (Word)"
{
    Caption = 'Inf. Control de Stock (Word)';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;

    DefaultLayout = Word;
    WordLayout = './layouts/Reporte_Control_de_Stock_Base.docx';

    dataset
    {
        dataitem(ItemCategory; "Item Category")
        {
            // Filtros opcionales aquí (por ejemplo, excluir categorías vacías si quieres)

            column(ItemCategory_Code; Code) { }
            column(ItemCategory_Description; Description) { }

            dataitem(Item; Item)
            {
                DataItemLink = "Item Category Code" = field(Code);
                // Si quieres filtrar por tu booleano:
                DataItemTableView = WHERE("Control de Stock" = CONST(true));

                RequestFilterFields = "No.";

                column(Item_No_; "No.") { }
                column(Item_Description; Description) { }
                column(Item_Inventory; Inventory) { }
                column(Item_UOM; "Base Unit of Measure") { }

                trigger OnAfterGetRecord()
                begin
                    CalcFields(Inventory);
                end;
            }
        }
    }
    requestpage { layout { } }
}


report 50401 "Información Control Inventario"
{
    Caption = 'Información Control de Inventario';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;

    DefaultLayout = Word;
    WordLayout = './layouts/StockComp_NoComp_ByCategory.docx';

    dataset
    {
        // ======= NIVEL 1: CATEGORÍA =======
        dataitem(ItemCategory; "Item Category")
        {
            // Si quieres filtrar categorías desde la request page:
            RequestFilterFields = Code, Description;

            column(IC_Code; Code) { }
            column(IC_Description; Description) { }
            column(IC_FamilyLabel; 'FAMILIA: ') { }
            column(Item_LabelDesc; 'PRODUCTO: ' + Description) { }
            column(IC_Product; 'PRODUCTO : ') { }
            column(IC_PartLabel; 'COMPONENTE: ') { }
            // ======= NIVEL 2A: COMPONENTES =======
            dataitem(CompYes; Item)
            {
                DataItemLink = "Item Category Code" = field(Code);
                DataItemTableView =
                    WHERE("Control de Stock" = CONST(true),
                          "Componente" = CONST(true));
                RequestFilterFields = "No.", "Location Filter", "Variant Filter";

                column(CY_No; "No.") { }
                column(CY_Desc; Description) { }
                column(CY_Inventory; Inventory) { }

                column(CY_Inventory_Desc; StrSubstNo('Total Inventario: %1', GetNoDecimalsWithSign(Inventory))) { }





                column(CY_QtyInReleased; QtyInReleased) { }
                column(CY_QtyInReleased_Desc; StrSubstNo('Total en Ordenes de Producción: %1', Format(QtyInReleased, 0, '<Precision,0:0><Integer>'))) { }
                column(CY_StockMinusReleased; StockMinusReleased) { }
                column(CY_StockMinusReleased_Desc; StrSubstNo('Total en Almacén: %1', GetNoDecimalsWithSign(StockMinusReleased))) { }
                trigger OnAfterGetRecord()
                var
                    POC: Record "Prod. Order Component"; // 5407
                    PO: Record "Production Order";
                    locFilter: Text;
                    varFilter: Text;
                begin
                    // Inventory con FlowFilters
                    CalcFields(Inventory);

                    // En órdenes lanzadas (pendiente base) para este Item como componente
                    QtyInReleased := 0;

                    POC.Reset();
                    POC.SetRange(Status, POC.Status::Released);
                    POC.SetRange("Item No.", "No.");

                    // Propagar filtros de Item a Componentes
                    locFilter := GetFilter("Location Filter");
                    if locFilter <> '' then
                        POC.SetFilter("Location Code", locFilter);

                    varFilter := GetFilter("Variant Filter");
                    if varFilter <> '' then
                        POC.SetFilter("Variant Code", varFilter);

                    // << CLAVE: sumar solo si la cabecera no está "Cancelled By User"
                    if POC.FindSet() then
                        repeat
                            if PO.Get(POC.Status, POC."Prod. Order No.") then
                                if not PO."Cancelled By User" then
                                    QtyInReleased += POC."Remaining Qty. (Base)";
                        until POC.Next() = 0;

                    StockMinusReleased := Inventory - QtyInReleased;
                end;


            }


            // ======= NIVEL 2B: NO COMPONENTES =======
            dataitem(CompNo; Item)
            {
                DataItemLink = "Item Category Code" = field(Code);
                DataItemTableView =
                    WHERE("Control de Stock" = CONST(true),
                          "Componente" = CONST(false));
                RequestFilterFields = "No.", "Location Filter", "Variant Filter";

                column(CN_No; "No.") { }
                column(CN_Desc; Description) { }
                column(CN_Inventory; Inventory) { }

                column(CN_Inventory_Desc; StrSubstNo('Total Inventario: %1', GetNoDecimalsWithSign(Inventory))) { }
                column(CN_QtyInReleased; QtyInReleased) { }
                column(CN_QtyInReleased_Desc; StrSubstNo('Total en Ordenes de Producción: %1', Format(QtyInReleased, 0, '<Precision,0:0><Integer>'))) { }
                column(CN_StockMinusReleased; StockMinusReleased) { }
                column(CN_StockMinusReleased_Desc; StrSubstNo('Total en Almacén: %1', GetNoDecimalsWithSign(StockMinusReleased))) { }

                trigger OnAfterGetRecord()
                var
                    POL: Record "Prod. Order Line"; // 5406
                    PO: Record "Production Order";
                    locFilter: Text;
                    varFilter: Text;
                begin
                    CalcFields(Inventory);

                    // En órdenes lanzadas (pendiente base) para este Item como producto a fabricar
                    QtyInReleased := 0;

                    POL.Reset();
                    POL.SetRange(Status, POL.Status::Released);
                    POL.SetRange("Item No.", "No.");

                    // Propagar filtros de Item a Líneas de OP
                    locFilter := GetFilter("Location Filter");
                    if locFilter <> '' then
                        POL.SetFilter("Location Code", locFilter);

                    varFilter := GetFilter("Variant Filter");
                    if varFilter <> '' then
                        POL.SetFilter("Variant Code", varFilter);

                    // CLAVE: contar solo si la cabecera NO está anulada
                    if POL.FindSet() then
                        repeat
                            if PO.Get(POL.Status, POL."Prod. Order No.") then
                                if not PO."Cancelled By User" then
                                    QtyInReleased += POL."Remaining Qty. (Base)";
                        until POL.Next() = 0;

                    StockMinusReleased := Inventory - QtyInReleased;
                end;

            }
        }
    }

    requestpage
    {
        layout { }
    }
    local procedure GetNoDecimalsWithSign(Value: Decimal): Text
    var
        txt: Text;
    begin
        txt := Format(Abs(Value), 0, '<Precision,0:0><Integer>'); // sin decimales
        if Value < 0 then
            exit('-' + txt);
        exit(txt);
    end;

    var
        QtyInReleased: Decimal;
        StockMinusReleased: Decimal;
}

