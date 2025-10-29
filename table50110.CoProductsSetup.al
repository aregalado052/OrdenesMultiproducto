table 50310 "Co-Products Setup"
{
    Caption = 'Co-Products Setup';
    DataClassification = CustomerContent;

    fields
    {
        // PK original – ¡NO cambiar!
        field(1; "Enforce 100%"; Boolean)
        {
            Caption = 'Require Cost Share = 100%';
        }

        field(2; "Allocation Mode"; Option)
        {
            Caption = 'Allocation Mode';
            OptionMembers = Percent,Quantity;
            OptionCaption = 'Percent,Quantity Produced';
        }

        // === Campos que necesita 50150 ===
        field(10; "Auto Post CoProds"; Boolean)
        {
            Caption = 'Auto Post Co-Products';
        }
        field(20; "Use Expected Qty"; Boolean)
        {
            Caption = 'Use Expected Quantity';
        }
        field(30; "CoProd Jnl Template"; Code[10])
        {
            Caption = 'Item Journal Template';
        }
        field(40; "CoProd Jnl Batch"; Code[10])
        {
            Caption = 'Item Journal Batch';
        }
    }

    keys
    {
        // Mantener la PK original – sin cambios
        key(PK; "Enforce 100%") { Clustered = true; }
    }

    trigger OnInsert()
    begin
        // Defaults seguros para el 50150
        if "CoProd Jnl Template" = '' then
            "CoProd Jnl Template" := 'ITEM';
        if "CoProd Jnl Batch" = '' then
            "CoProd Jnl Batch" := 'AUTOCO';

        // Activado por defecto
        if not "Auto Post CoProds" then
            "Auto Post CoProds" := true;
    end;
}
