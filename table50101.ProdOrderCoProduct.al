table 50199 "Prod. Order Co-Product"
{
    Caption = 'Prod. Order Co-Product';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Prod. Order No."; Code[20]) { Caption = 'Order No.'; }
        field(2; Status; Enum "Production Order Status") { Caption = 'Status'; }
        field(3; "Line No."; Integer) { Caption = 'Line No.'; }
        field(4; "Item No."; Code[20]) { Caption = 'Item No.'; TableRelation = Item."No."; }
        field(5; "Expected Qty."; Decimal) { Caption = 'Expected Qty.'; DecimalPlaces = 0 : 5; }
        field(6; "Output Qty."; Decimal) { Caption = 'Output Qty.'; DecimalPlaces = 0 : 5; }
        field(7; "Cost Share %"; Decimal) { Caption = 'Cost Share %'; DecimalPlaces = 0 : 5; }
        field(8; "UOM Code"; Code[10]) { Caption = 'UOM'; TableRelation = "Unit of Measure".Code; }
    }

    keys
    {
        key(PK; "Prod. Order No.", Status, "Line No.") { Clustered = true; }
    }
}
