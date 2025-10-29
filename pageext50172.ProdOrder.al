page 50278 "PP Prod. Order (Card)"
{
    PageType = Card;
    SourceTable = "Production Order";
    ApplicationArea = All;
    UsageCategory = None; // Oculta en la lupa para que el usuario entre por la lista
    Caption = 'Anular Orden de producción (PP)';

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; Rec."No.") { ApplicationArea = All; Editable = false; }
                field(Status; Rec.Status) { ApplicationArea = All; Editable = false; }
                field(Description; Rec.Description) { ApplicationArea = All; Editable = false; }

                group(Anulacion)
                {
                    Caption = 'Anulación';
                    field("Cancelled By User"; Rec."Cancelled By User") { ApplicationArea = All; Editable = false; }
                    field("Cancelled Date"; Rec."Cancelled Date") { ApplicationArea = All; Editable = false; }
                    field("Cancelled By"; Rec."Cancelled By") { ApplicationArea = All; Editable = false; }
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ArchiveAsCancelled)
            {
                ApplicationArea = All;
                Caption = 'Archivar como anulada';
                Image = Archive;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                ToolTip = 'Marca la orden como anulada y la oculta de las listas activas (sin cambiar estado).';

                trigger OnAction()
                var
                    PO: Record "Production Order";
                    UserRec: Record "User Setup";
                    CurrUserName: Text[50];
                begin
                    // Cargar SIEMPRE por Nº (ignorando buffers raros)
                    PO.Reset();
                    PO.SetRange("No.", Rec."No.");
                    if not PO.FindFirst() then
                        Error('No se encontró la Orden %1.', Rec."No.");

                    if PO."Cancelled By User" then begin
                        Message('La Orden %1 ya está marcada como ANULADA.', PO."No.");
                        exit;
                    end;

                    if not Confirm('¿Seguro que deseas ANULAR la Orden %1?', false, PO."No.") then
                        exit;

                    if UserRec.Get(UserSecurityId()) then
                        CurrUserName := CopyStr(UserRec."User ID", 1, MaxStrLen(PO."Cancelled By"))
                    else
                        CurrUserName := 'SYSTEM';

                    // Marcar anulación (sin tocar Status) y GUARDAR SIN TRIGGERS
                    PO."Cancelled By User" := true;
                    PO."Cancelled Date" := Today;
                    PO."Cancelled By" := CurrUserName;
                    PO.Modify(false); // <<<<<<<<<<<<<< clave: NO dispara OnModify/validaciones de terceros

                    Message('Orden %1 marcada como ANULADA (sin cambiar estado).', PO."No.");
                    CurrPage.Update(false);
                end;
            }



        }
    }
    local procedure LoadByNo(var PO: Record "Production Order"; OrderNo: Code[20]): Boolean
    begin
        PO.Reset();
        PO.SetRange("No.", OrderNo);
        exit(PO.FindFirst());
    end;

}


page 50279 "PP Prod. Orders (Active)"
{
    PageType = List;
    SourceTable = "Production Order";
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'Órdenes de Producción (Activas)';
    SourceTableView = where(Status = const(Released), "Cancelled By User" = const(false));
    CardPageId = "PP Prod. Order (Card)"; // Doble clic abre la Card 50178

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
                field("Cancelled By User"; Rec."Cancelled By User") { ApplicationArea = All; }
                field("Cancelled Date"; Rec."Cancelled Date") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(BulkCancelArchive)
            {
                Caption = 'Archivar como anulada';
                Image = Cancel;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Marca como anuladas (sin cambiar estado) las órdenes seleccionadas y las oculta de las listas activas.';

                trigger OnAction()
                var
                    Sel: Record "Production Order";
                    PO: Record "Production Order";

                    UserRec: Record "User Setup";

                    CurrUserName: Text[50];
                    Done, SkippedAlready : Integer;
                begin
                    CurrPage.SetSelectionFilter(Sel);
                    if Sel.IsEmpty() then begin
                        Message('No hay órdenes seleccionadas.');
                        exit;
                    end;

                    if not Confirm('¿Marcar como ANULADAS las órdenes seleccionadas?', false) then
                        exit;

                    if UserRec.Get(UserSecurityId()) then
                        CurrUserName := CopyStr(UserRec."User ID", 1, 50)
                    else
                        CurrUserName := 'SYSTEM';

                    if Sel.FindSet() then
                        repeat
                            // Releer SIEMPRE por Nº
                            PO.Reset();
                            PO.SetRange("No.", Sel."No.");
                            if PO.FindFirst() then begin
                                if PO."Cancelled By User" then
                                    SkippedAlready += 1
                                else begin
                                    PO."Cancelled By User" := true;
                                    PO."Cancelled Date" := Today;
                                    PO."Cancelled By" := CopyStr(CurrUserName, 1, MaxStrLen(PO."Cancelled By"));
                                    PO.Modify(false); // <<<<<<<< sin triggers
                                    Done += 1;
                                end;
                            end;
                        until Sel.Next() = 0;

                    Message('Anuladas: %1  |  Ya anuladas: %2', Done, SkippedAlready);
                    CurrPage.Update(false);
                end;
            }

        }
    }
    local procedure LoadByNo(var PO: Record "Production Order"; OrderNo: Code[20]): Boolean
    begin
        PO.Reset();
        PO.SetRange("No.", OrderNo);
        exit(PO.FindFirst());
    end;

}


pageextension 50185 "PP Ext Released Prod Orders" extends "Released Production Orders"
{
    trigger OnOpenPage()
    begin
        // Filtro global que el usuario puede quitar, pero entra siempre aplicado
        Rec.SetRange("Cancelled By User", false);
    end;
}


pageextension 50360 "PP Ext Lanz Prod Order Card" extends "Released Production Order"
{
    actions
    {
        addlast(Processing)
        {
            action(ArchiveAsCancelledPP)
            {
                ApplicationArea = All;
                Caption = 'Archivar como anulada';
                Image = Archive;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Visible = true;

                trigger OnAction()
                var
                    PO: Record "Production Order";
                    UserRec: Record "User Setup";
                    CurrUserName: Text[50];
                begin
                    PO.Reset();
                    PO.SetRange("No.", Rec."No.");
                    if not PO.FindFirst() then
                        Error('No se encontró la Orden %1.', Rec."No.");

                    if PO."Cancelled By User" then begin
                        Message('La Orden %1 ya está marcada como ANULADA.', PO."No.");
                        exit;
                    end;

                    if not Confirm('¿Seguro que deseas ANULAR la Orden %1?', false, PO."No.") then
                        exit;

                    if UserRec.Get(UserSecurityId()) then
                        CurrUserName := CopyStr(UserRec."User ID", 1, MaxStrLen(PO."Cancelled By"))
                    else
                        CurrUserName := 'SYSTEM';

                    PO."Cancelled By User" := true;
                    PO."Cancelled Date" := Today;
                    PO."Cancelled By" := CurrUserName;
                    PO.Modify(false); // sin triggers

                    Message('Orden %1 marcada como ANULADA.', PO."No.");
                    CurrPage.Update(false);
                end;
            }
        }

    }



}