// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AutomaticAccounts;

using Microsoft.Purchases.Document;

pageextension 4860 "AA Purch. Return Order Subform" extends "Purchase Return Order Subform"
{
    layout
    {
        addafter("Job Planning Line No.")
        {

            field("Automatic Account Group"; Rec."Automatic Account Group")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies an automatic account group code.';
            }
        }
    }
}