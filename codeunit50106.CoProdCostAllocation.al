codeunit 50306 "CoProd Cost Allocation"
{
    procedure CalcOrderCost(OrderNo: Code[20]; Status: Enum "Production Order Status"): Decimal
    var
        Total: Decimal;
    begin
        // TODO: sumar consumos materiales + capacidad de la orden a partir de Value Entries / Capacities
        Total := 0;
        exit(Total);
    end;

    procedure CalcTotals(OrderNo: Code[20]; Status: Enum "Production Order Status"; var TotalSharePct: Decimal; var TotalOutputQty: Decimal)
    var
        Co: Record "Prod. Order Co-Product";
    begin
        TotalSharePct := 0;
        TotalOutputQty := 0;
        Co.SetRange("Prod. Order No.", OrderNo);
        Co.SetRange(Status, Status);
        if Co.FindSet() then
            repeat
                TotalSharePct += Co."Cost Share %";
                TotalOutputQty += Co."Output Qty.";
            until Co.Next() = 0;
    end;

    procedure ComputeUnitCost(OrderNo: Code[20]; Status: Enum "Production Order Status"; ItemNo: Code[20]; QtyToPost: Decimal): Decimal
    var
        S: Record "Co-Products Setup";
        Co: Record "Prod. Order Co-Product";
        TotalCost: Decimal;
        TotalSharePct: Decimal;
        TotalOutputQty: Decimal;
        Share: Decimal;
    begin
        TotalCost := CalcOrderCost(OrderNo, Status);
        if TotalCost = 0 then
            exit(0);

        GetSetup(S);
        CalcTotals(OrderNo, Status, TotalSharePct, TotalOutputQty);

        Co.SetRange("Prod. Order No.", OrderNo);
        Co.SetRange(Status, Status);
        Co.SetRange("Item No.", ItemNo);
        if not Co.FindFirst() then
            exit(0);

        case S."Allocation Mode" of
            S."Allocation Mode"::Percent:
                begin
                    if TotalSharePct = 0 then
                        exit(0);
                    Share := TotalCost * (Co."Cost Share %" / TotalSharePct);
                    if QtyToPost = 0 then
                        exit(0);
                    exit(Share / QtyToPost);
                end;
            S."Allocation Mode"::Quantity:
                begin
                    if TotalOutputQty = 0 then
                        exit(0);
                    Share := TotalCost * (Co."Output Qty." / TotalOutputQty);
                    if QtyToPost = 0 then
                        exit(0);
                    exit(Share / QtyToPost);
                end;
        end;
    end;

    local procedure GetSetup(var S: Record "Co-Products Setup")
    begin
        if not S.Get() then begin
            S.Init();
            S.Insert(true);
        end;
    end;
}
