// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document.Attachment;

enum 7275 "File Handler Type" implements "File Handler"
{
    Extensible = false;
    Access = Internal;

    value(0; "CSV Handler")
    {
        Implementation = "File Handler" = "Csv Handler";
    }
}