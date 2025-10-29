pageextension 50160 "G/L Register Fix" extends "G/L Registers"
{
    Caption = 'G/L Register Fix Tools';

    layout
    {
        addafter("No.")
        {
            field("From Entry No. View"; Rec."From Entry No.")
            {
                ApplicationArea = All;
                ToolTip = 'Último Entry No. inicial del registro.';
                Editable = false;
            }
            field("To Entry No. View"; Rec."To Entry No.")
            {
                ApplicationArea = All;
                ToolTip = 'Último Entry No. final del registro. Debe coincidir con el último movimiento real.';
                Editable = false; // mantenlo de solo lectura para seguridad
            }
        }
    }

    actions
    {
        addlast(Processing)
        {
            action(SyncToLastGLEntry)
            {
                ApplicationArea = All;
                Caption = 'Sincronizar con último Mov. contabilidad';

                ToolTip = 'Ajusta el "To Entry No." del último G/L Register al último Entry No. real de "Mov. contabilidad".';

                trigger OnAction()
                var
                    GLReg: Record "G/L Register";
                    GLEntry: Record "G/L Entry";
                    LastEntryNo: Integer;
                begin
                    // 1) último Nº mov. real (G/L Entry)
                    if not GLEntry.FindLast() then
                        Error('No hay movimientos en "Mov. contabilidad".');

                    LastEntryNo := GLEntry."Entry No.";

                    // 2) último G/L Register
                    if not GLReg.FindLast() then
                        Error('No hay registros en "G/L Registers".');

                    // 3) si difiere, alinear
                    if GLReg."To Entry No." <> LastEntryNo then begin
                        GLReg.Validate("To Entry No.", LastEntryNo);
                        GLReg.Modify(true);
                        Message('Alineado: "To Entry No." = %1 (según último Mov. contabilidad).', LastEntryNo);
                    end else
                        Message('Ya estaba alineado. Último Entry No. = %1', LastEntryNo);
                end;
            }
        }
    }
}

report 50171 "Sync G/L Register Last Entry"
{
    Caption = 'Sync G/L Register To Last Entry';
    ProcessingOnly = true;
    ApplicationArea = All;
    UsageCategory = Administration;

    trigger OnPreReport()
    var
        GLReg: Record "G/L Register";
        GLEntry: Record "G/L Entry";
        lastNo: Integer;
    begin
        if not GLEntry.FindLast() then
            Error('No hay movimientos en "Mov. contabilidad".');

        lastNo := GLEntry."Entry No.";

        if not GLReg.FindLast() then
            Error('No hay registros en "G/L Registers".');

        if GLReg."To Entry No." <> lastNo then begin
            GLReg.Validate("To Entry No.", lastNo);
            GLReg.Modify(true);
            Message('Alineado: "To Entry No." del último G/L Register = %1', lastNo);
        end else
            Message('Ya estaba alineado. Último Entry No. = %1', lastNo);
    end;
}
