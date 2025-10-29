codeunit 50311 "CoProdAutoOutputPost"
{

    Subtype = Normal;

    // ─────────────────────────────────────────────────────────────────────────────
    // EVENT SUBSCRIBER
    // ─────────────────────────────────────────────────────────────────────────────
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnAfterPostItemJnlLine', '', false, false)]
    local procedure OnAfterPostItemJnlLine_HandleCoProducts(
        var ItemJournalLine: Record "Item Journal Line";
        var ItemLedgEntryNo: Integer;
        var ValueEntryNo: Integer;
        CalledFromAdjustment: Boolean)
    var
        CoProdJnlTemplateName: Code[10];
        CoProdJnlBatchName: Code[10];
        UseExpectedQty: Boolean;
        AutoEnabled: Boolean;

        CoStd: Record "Prod. Order Co-Product";
        QtyToPost: Decimal;
        OutputsCreated: Integer;
    begin

        // Ignorar si el posteo viene de un ajuste (cierre/terminación puede lanzar ajustes)
        if CalledFromAdjustment then
            exit;
        // Solo nos interesa cuando se ha registrado una SALIDA (Output)
        if ItemJournalLine."Entry Type" <> ItemJournalLine."Entry Type"::Output then
            exit;

        // 🔒 Solo OP de PRODUCCIÓN (evita compras/otros)
        if ItemJournalLine."Order Type" <> ItemJournalLine."Order Type"::Production then
            exit;

        // Necesitamos el Nº de OP del movimiento del padre
        if ItemJournalLine."Order No." = '' then
            exit;

        // Leer Setup (usa defaults si no existe registro)
        GetSetup(CoProdJnlTemplateName, CoProdJnlBatchName, UseExpectedQty, AutoEnabled);
        if not AutoEnabled then
            exit;

        // Asegurar el lote de Diario de artículos para generar las líneas
        EnsureItemJnlBatchExists(CoProdJnlTemplateName, CoProdJnlBatchName);

        OutputsCreated := 0;

        CoStd.Reset();
        CoStd.SetRange("Prod. Order No.", ItemJournalLine."Order No.");
        if CoStd.FindSet() then
            repeat
                // Cantidad a usar según Setup
                QtyToPost := CoStd."Output Qty.";
                if UseExpectedQty then
                    QtyToPost := CoStd."Expected Qty.";

                // Solo procesar si hay cantidad y NO es el mismo ítem que el padre
                if (QtyToPost > 0) and (CoStd."Item No." <> ItemJournalLine."Item No.")
                and (not AlreadyPostedCoProd(ItemJournalLine, CoStd."Item No.")) then begin
                    CreateAndPostCoProductAsAdjmt(
                        ItemJournalLine,
                        CoStd."Item No.",
                        QtyToPost,
                        CoStd."UOM Code",
                        CoProdJnlTemplateName,
                        CoProdJnlBatchName);

                    OutputsCreated += 1;
                end;
            until CoStd.Next() = 0;

        if OutputsCreated > 0 then
            Message('Co-productos registrados: %1', OutputsCreated);

    end;


    local procedure AlreadyPostedCoProd(var BaseJnlLine: Record "Item Journal Line"; CoItemNo: Code[20]): Boolean
    var
        ILE: Record "Item Ledger Entry";
        DescTxt: Text[100];
    begin
        DescTxt := CopyStr(StrSubstNo('[AUTO COPROD] %1 %2', BaseJnlLine."Order No.", CoItemNo), 1, 100);

        ILE.Reset();
        ILE.SetRange("Item No.", CoItemNo);
        ILE.SetRange("Entry Type", ILE."Entry Type"::"Positive Adjmt.");
        ILE.SetRange(Description, DescTxt);

        // OJO: SIN filtros por "Document No." ni "Posting Date"
        exit(ILE.FindFirst());
    end;



    // ─────────────────────────────────────────────────────────────────────────────
    // CREA Y POSTEA UNA LÍNEA DE AJUSTE POSITIVO PARA EL CO-PRODUCTO
    // ─────────────────────────────────────────────────────────────────────────────
    local procedure CreateAndPostCoProductAsAdjmt(
        var BaseJnlLine: Record "Item Journal Line";
        CoItemNo: Code[20];
        Qty: Decimal;
        Uom: Code[10];
        Tpl: Code[10];
        Bch: Code[10])
    var
        NewLine: Record "Item Journal Line";
        PostLine: Codeunit "Item Jnl.-Post Line";
        ItemRec: Record Item;
        NextNo: Integer;
        AutoDesc: Text[100];
    begin
        // Cabecera / lote
        NewLine.Init();
        NewLine.Validate("Journal Template Name", Tpl);
        NewLine.Validate("Journal Batch Name", Bch);

        // Numeración (salta cada 10000)
        NextNo := GetNextLineNo(Tpl, Bch);
        NewLine.Validate("Line No.", NextNo);

        // Heredar fecha / documento del movimiento del padre
        NewLine.Validate("Posting Date", BaseJnlLine."Posting Date");
        if BaseJnlLine."Document No." <> '' then
            NewLine.Validate("Document No.", BaseJnlLine."Document No.");

        // CO-PRODUCTO como Ajuste positivo → evita Order Line No. / Item=1026
        NewLine.Validate("Entry Type", NewLine."Entry Type"::"Positive Adjmt.");
        NewLine.Validate("Item No.", CoItemNo);

        // UOM
        if Uom <> '' then
            NewLine.Validate("Unit of Measure Code", Uom)
        else if BaseJnlLine."Unit of Measure Code" <> '' then
            NewLine.Validate("Unit of Measure Code", BaseJnlLine."Unit of Measure Code")
        else if ItemRec.Get(CoItemNo) and (ItemRec."Base Unit of Measure" <> '') then
            NewLine.Validate("Unit of Measure Code", ItemRec."Base Unit of Measure");

        // Almacén / Ubicación igual que el padre
        if BaseJnlLine."Location Code" <> '' then
            NewLine.Validate("Location Code", BaseJnlLine."Location Code");
        if BaseJnlLine."Bin Code" <> '' then
            NewLine.Validate("Bin Code", BaseJnlLine."Bin Code");

        // Cantidad (en Ajuste positivo se usa Quantity)
        NewLine.Validate(Quantity, Qty);

        // Trazabilidad: guarda la OP en Documento externo
        if BaseJnlLine."Order No." <> '' then
            NewLine.Validate("External Document No.", BaseJnlLine."Order No.");

        // Marca descripción
        AutoDesc := CopyStr(StrSubstNo('[AUTO COPROD] %1 %2', BaseJnlLine."Order No.", CoItemNo), 1, 100);
        NewLine.Validate(Description, AutoDesc);

        // Insertar y postear
        NewLine.Insert(true);
        //PostLine.RunWithCheck(NewLine);
    end;

    // ─────────────────────────────────────────────────────────────────────────────
    // LECTURA DE SETUP (50110)
    // ─────────────────────────────────────────────────────────────────────────────
    local procedure GetSetup(var Tpl: Code[10]; var Bch: Code[10]; var UseExpected: Boolean; var AutoEnabled: Boolean)
    var
        S: Record "Co-Products Setup"; // table 50110
    begin
        Tpl := 'ITEM';
        Bch := 'AUTOCO';
        UseExpected := false;
        AutoEnabled := true;

        if S.FindFirst() then begin
            if S."CoProd Jnl Template" <> '' then
                Tpl := S."CoProd Jnl Template";
            if S."CoProd Jnl Batch" <> '' then
                Bch := S."CoProd Jnl Batch";
            UseExpected := S."Use Expected Qty";
            AutoEnabled := S."Auto Post CoProds";
        end;
    end;

    // ─────────────────────────────────────────────────────────────────────────────
    // ASEGURAR PLANTILLA / LOTE DEL DIARIO DE ARTÍCULOS
    // ─────────────────────────────────────────────────────────────────────────────
    local procedure EnsureItemJnlBatchExists(Tpl: Code[10]; Bch: Code[10])
    var
        T: Record "Item Journal Template";
        B: Record "Item Journal Batch";
    begin
        if not T.Get(Tpl) then begin
            T.Init();
            T.Validate(Name, Tpl);
            T.Validate(Description, 'Auto Co-Products');
            T.Insert(true);
        end;

        B.Reset();
        B.SetRange("Journal Template Name", Tpl);
        B.SetRange(Name, Bch);
        if not B.FindFirst() then begin
            B.Init();
            B.Validate("Journal Template Name", Tpl);
            B.Validate(Name, Bch);
            B.Validate(Description, 'Auto Co-Products');
            B.Insert(true);
        end;
    end;

    // ─────────────────────────────────────────────────────────────────────────────
    // SIGUIENTE Nº LÍNEA EN DIARIO DE ARTÍCULOS
    // ─────────────────────────────────────────────────────────────────────────────
    local procedure GetNextLineNo(Tpl: Code[10]; Bch: Code[10]): Integer
    var
        L: Record "Item Journal Line";
    begin
        L.Reset();
        L.SetRange("Journal Template Name", Tpl);
        L.SetRange("Journal Batch Name", Bch);
        if L.FindLast() then
            exit(L."Line No." + 10000)
        else
            exit(10000);
    end;
}
