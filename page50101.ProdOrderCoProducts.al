page 50301 "Prod. Order Co-Products"
{
    PageType = ListPart;
    SourceTable = "Prod. Order Co-Product";
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Item No."; Rec."Item No.") { ApplicationArea = All; }
                field("Expected Qty."; Rec."Expected Qty.") { ApplicationArea = All; }
                field("Output Qty."; Rec."Output Qty.") { ApplicationArea = All; }
                field("Cost Share %"; Rec."Cost Share %") { ApplicationArea = All; }
                field("UOM Code"; Rec."UOM Code") { ApplicationArea = All; }
            }
        }
    }
}
