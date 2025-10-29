page 50310 "Co-Products Setup Card"
{
    PageType = Card;
    SourceTable = "Co-Products Setup";
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Auto Post CoProds"; Rec."Auto Post CoProds") { }
                field("Use Expected Qty"; Rec."Use Expected Qty") { }
                field("CoProd Jnl Template"; Rec."CoProd Jnl Template") { }
                field("CoProd Jnl Batch"; Rec."CoProd Jnl Batch") { }
            }
            group(Validation)
            {
                field("Enforce 100%"; Rec."Enforce 100%") { }
                field("Allocation Mode"; Rec."Allocation Mode") { }
            }
        }
    }

    trigger OnOpenPage()
    var
        S: Record "Co-Products Setup";
    begin
        if not Rec.FindFirst() then begin
            Rec.Init();
            Rec."Enforce 100%" := true; // para tener el “único” registro
            Rec.Insert(true);
        end;
    end;



}