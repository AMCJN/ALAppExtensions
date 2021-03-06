pageextension 18602 "Gate Entry Purch. Invoice" extends "Purchase Invoice"
{
    actions
    {
        addlast("F&unctions")
        {
            action("Get Gate Entry Lines")
            {
                ApplicationArea = Basic, Suite;
                Image = GetLines;
                ToolTip = 'View available gate entry lines for attachment.';

                trigger OnAction()
                var
                    GateEntryHandler: Codeunit "Gate Entry Handler";
                begin
                    GateEntryHandler.GetPurchaseGateEntryLines(Rec);
                end;
            }
        }
        addlast("F&unctions")
        {
            action("Attached Gate Entry")
            {
                ApplicationArea = Basic, Suite;
                Image = InwardEntry;
                RunObject = page "Gate Entry Attachment List";
                RunPageLink = "Entry Type" = const(Inward), "Purchase Invoice No." = field("No.");
                ToolTip = 'View attached gate entry list.';
            }
        }
    }
}