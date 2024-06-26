namespace Microsoft.DataMigration.GP.HistoricalData;

page 41003 "Hist. Sales Trx. Lines"
{
    ApplicationArea = All;
    Caption = 'Historical Sales Trx. Lines';
    PageType = ListPart;
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    SourceTable = "Hist. Sales Trx. Line";

    layout
    {
        area(Content)
        {
            repeater(ListData)
            {
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the value of the Item No. field.';
                }
                field("Item Description"; Rec."Item Description")
                {
                    ToolTip = 'Specifies the value of the Item Description field.';
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ToolTip = 'Specifies the value of the Unit of Measure field.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the value of the Quantity field.';

                    trigger OnDrillDown()
                    var
                        HistRecvTrxSerlLotList: Page "Hist. Recv. Trx. SerlLot. List";
                    begin
                        HistRecvTrxSerlLotList.SetFilterSalesTrxLine(Rec);
                        HistRecvTrxSerlLotList.Run();
                    end;
                }
                field("Unit Cost"; Rec."Unit Cost")
                {
                    ToolTip = 'Specifies the value of the Unit Cost field.';
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ToolTip = 'Specifies the value of the Unit Price field.';
                }
                field("Ext. Cost"; Rec."Ext. Cost")
                {
                    ToolTip = 'Specifies the value of the Ext. Cost field.';
                }
                field("Ext. Price"; Rec."Ext. Price")
                {
                    ToolTip = 'Specifies the value of the Ext. Price field.';
                }
                field("Tax Amount"; Rec."Tax Amount")
                {
                    ToolTip = 'Specifies the value of the Tax Amount field.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ToolTip = 'Specifies the value of the Location Code field.';
                }
                field("Ship-to Name"; Rec."Ship-to Name")
                {
                    ToolTip = 'Specifies the value of the Ship-to Name field.';
                }
            }
        }
    }
}