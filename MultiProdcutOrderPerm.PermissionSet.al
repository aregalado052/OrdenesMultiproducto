permissionset 50132 MProdcutOrderPerm
{
    Assignable = true;
    Permissions = tabledata "Prod. BOM Co-Product" = RIMD,
        tabledata "Co-Products Setup" = RIMD,  // SalesQuoteBufferV2
        tabledata "Prod. Order Co-Product" = RIMD; // PDF Transfer Buffer
}


permissionset 50160 "CO-PROD OPS"
{
    Caption = 'Co-Products – Operativa';
    Assignable = true;

    // Ejecutar nuestro codeunit
    Permissions =
        codeunit CoProdAutoOutputPost = X,

        // Leer fuentes que usa el codeunit
        tabledata "Prod. Order Co-Product" = R,
        tabledata Item = R,
        tabledata "Item Ledger Entry" = R,

        // Insertar líneas en el diario de artículos y preparar lote
        tabledata "Item Journal Line" = RIMD,
        tabledata "Item Journal Batch" = RIMD,
        tabledata "Item Journal Template" = RIMD;

    // (opcional) si tu codeunit llama a estos, dales Execute
    // codeunit "Item Jnl.-Post" = X,
    // codeunit "Item Jnl.-Post Line" = X;
}

permissionset 50162 "GL-TOOLS"
{
    Caption = 'GL Tools (Sync G/L Register)';
    Assignable = true;

    Permissions =
        // Report que sincroniza (el que te pasé: 50161)
        report "Sync G/L Register Last Entry" = X,

        // Tablas necesarias
        tabledata "G/L Entry" = R,      // leer último Entry No.
        tabledata "G/L Register" = RIMD;   // leer/insertar/modificar (ajustar To Entry No.)
}