table 50194 "Prod. BOM Co-Product"
{
    Caption = 'Production BOM Co-Product';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Production BOM No."; Code[20])
        {
            Caption = 'BOM No.';
            TableRelation = "Production BOM Header"."No.";
        }
        field(3; "Line No."; Integer) { Caption = 'Line No.'; }
        field(4; "Item No."; Code[20]) { Caption = 'Item No.'; TableRelation = Item."No."; }
        field(5; "Quantity per"; Decimal) { Caption = 'Quantity per'; DecimalPlaces = 0 : 5; }
        field(6; "Cost Share %"; Decimal) { Caption = 'Cost Share %'; DecimalPlaces = 0 : 5; }
        field(7; "Co-Product Type"; Option) { Caption = 'Type'; OptionMembers = Main,CoProduct,ByProduct; }
        field(8; "Unit of Measure Code"; Code[10]) { Caption = 'UOM'; TableRelation = "Unit of Measure".Code; }
    }

    keys
    {
        key(PK; "Production BOM No.", "Line No.") { Clustered = true; }
    }
}
