codeunit 50304 "CoProd Validation"
{
    procedure GetSetup(var S: Record "Co-Products Setup")
    begin
        if not S.Get() then begin
            S.Init();
            S.Insert(true);
        end;
    end;

    procedure ValidatePercentSum(OrderNo: Code[20]; Status: Enum "Production Order Status")
    var
        S: Record "Co-Products Setup";
        Co: Record "Prod. Order Co-Product";
        SumPct: Decimal;
    begin
        GetSetup(S);
        if not S."Enforce 100%" then
            exit;

        SumPct := 0;
        Co.SetRange("Prod. Order No.", OrderNo);
        Co.SetRange(Status, Status);
        if Co.FindSet() then
            repeat
                SumPct += Co."Cost Share %";
            until Co.Next() = 0;

        if Round(SumPct, 0.00001) <> 100 then
            Error('La suma de porcentajes de coste de los coproductos debe ser 100%% (actual: %1).', SumPct);
    end;
}
