﻿// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Finance.VAT.Reporting;

using System.Telemetry;
codeunit 13691 "Setup VAT Reports Config DK"
{
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        MSECSLDKTok: Label 'ECSL-DK', Locked = true;
        VATTok: Label 'DK VAT-VIES Reporting', Locked = true;

    [EventSubscriber(ObjectType::Page, Page::"ECSL Report", 'OnOpenPageEvent', '', false, false)]
    local procedure ConfigureECSL();
    var
        VATReportsConfiguration: Record "VAT Reports Configuration";
    begin
        FeatureTelemetry.LogUptake('0000H8T', VATTok, Enum::"Feature Uptake Status"::Discovered);
        VATReportsConfiguration.SetRange("VAT Report Type", VATReportsConfiguration."VAT Report Type"::"EC Sales List");
        VATReportsConfiguration.SetRange("VAT Report Version", MSECSLDKTok);
        if VATReportsConfiguration.Count() > 0 then
            exit;

        VATReportsConfiguration.SetRange("VAT Report Version", 'CURRENT');
        if VATReportsConfiguration.FindFirst() then
            if VATReportsConfiguration."Submission Codeunit ID" = 0 then begin
                VATReportsConfiguration.Validate("Submission Codeunit ID", Codeunit::"MS - ECSL Report Export File");
                VATReportsConfiguration.Modify(true);
                exit;
            end;

        AddECSLConfiguration();
    end;

    procedure OpenVATReportConfig(Notification: Notification)
    begin
        FeatureTelemetry.LogUptake('0000H8U', VATTok, Enum::"Feature Uptake Status"::"Set up");
        Page.RunModal(Page::"VAT Reports Configuration");
    end;

    local procedure AddECSLConfiguration();
    var
        VATReportsConfiguration: Record "VAT Reports Configuration";
    begin
        with VATReportsConfiguration do begin
            Validate("VAT Report Type", "VAT Report Type"::"EC Sales List");
            Validate("VAT Report Version", MSECSLDKTok);
            Validate("Suggest Lines Codeunit ID", Codeunit::"EC Sales List Suggest Lines");
            Validate("Validate Codeunit ID", CODEUNIT::"ECSL Report Validate");
            Validate("Submission Codeunit ID", Codeunit::"MS - ECSL Report Export File");
            Insert();
        end;
    end;
}
