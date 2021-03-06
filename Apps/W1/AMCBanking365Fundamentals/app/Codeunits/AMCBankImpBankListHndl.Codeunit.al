codeunit 20115 "AMC Bank Imp.BankList Hndl"
{
    Permissions = TableData "AMC Bank Banks" = rimd,
                  TableData "AMC Banking Setup" = r;

    trigger OnRun()
    var
    begin
        GetBankListFromWebService(true, '', 5000, AMCBankingMgt.GetAppCaller());
    end;

    var
        AMCBankServiceRequestMgt: Codeunit "AMC Bank Service Request Mgt.";
        AMCBankingMgt: Codeunit "AMC Banking Mgt.";
        AMCBankServSysErr: Label 'The AMC Banking has returned the following error message:';
        AddnlInfoTxt: Label 'For more information, go to %1.', comment = '%1=Support URL';
        BankListWebCallTxt: Label 'bankList', locked = true;

    [Scope('OnPrem')]
    [Obsolete('This method is obsolete. A new GetBankListFromWebService overload is available', '16.2')]
    procedure GetBankListFromWebService(ShowErrors: Boolean; CountryFilter: Text; Timeout: Integer)
    var
    begin
        GetBankListFromWebService(ShowErrors, CountryFilter, Timeout, AMCBankingMgt.GetAppCaller());
    end;

    [Scope('OnPrem')]
    procedure GetBankListFromWebService(ShowErrors: Boolean; CountryFilter: Text; Timeout: Integer; Appcaller: Text[30])
    var
        TempBlobRequestBody: Codeunit "Temp Blob";
    begin
        SendRequestToWebService(TempBlobRequestBody, ShowErrors, Timeout, CountryFilter, Appcaller);
        InsertBankData(TempBlobRequestBody, CountryFilter);
    end;

    local procedure SendRequestToWebService(var BodyTempBlob: Codeunit "Temp Blob"; EnableUI: Boolean; Timeout: Integer; CountryFilter: Text; Appcaller: Text[30])
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        BankListHttpRequestMessage: HttpRequestMessage;
        BankListHttpResponseMessage: HttpResponseMessage;
        Handled: Boolean;
        Result: Text;
    begin
        AMCBankingMgt.CheckCredentials();
        AMCBankingSetup.Get();

        AMCBankServiceRequestMgt.InitializeHttp(BankListHttpRequestMessage, AMCBankingSetup."Service URL", 'POST');

        PrepareSOAPRequestBody(BankListHttpRequestMessage, CountryFilter);

        //Set Content-Type header
        AMCBankServiceRequestMgt.SetHttpContentsDefaults(BankListHttpRequestMessage);

        if not EnableUI then
            AMCBankServiceRequestMgt.DisableProgressDialog();

        //Send Request to webservice
        Handled := false;
        AMCBankServiceRequestMgt.SetTimeout(TimeOut);
        AMCBankServiceRequestMgt.OnBeforeExecuteWebServiceRequest(Handled, BankListHttpRequestMessage, BankListHttpResponseMessage, BankListWebCallTxt, AppCaller); //For mockup testing
        AMCBankServiceRequestMgt.ExecuteWebServiceRequest(Handled, BankListHttpRequestMessage, BankListHttpResponseMessage, BankListWebCallTxt, AppCaller, true);
        AMCBankServiceRequestMgt.GetWebServiceResponse(BankListHttpResponseMessage, BodyTempBlob, BankListWebCallTxt + AMCBankServiceRequestMgt.GetResponseTag(), true);
        if (AMCBankServiceRequestMgt.HasResponseErrors(BodyTempBlob, AMCBankServiceRequestMgt.GetHeaderXPath(), BankListWebCallTxt + AMCBankServiceRequestMgt.GetResponseTag(), Result, AppCaller)) then
            if EnableUI then
                DisplayErrorFromResponse(BodyTempBlob);

    end;

    local procedure PrepareSOAPRequestBody(var BankListExchHttpRequestMessage: HttpRequestMessage; CountryFilter: Text)
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        contentHttpContent: HttpContent;
        BodyContentXmlDoc: XmlDocument;
        BodyDeclaration: Xmldeclaration;
        EnvelopeXMLElement: XmlElement;
        BodyXMLElement: XMLElement;
        OperationXmlNode: XMLElement;
        ChildXmlElement: XmlElement;
        TempXmlDocText: Text;
    begin
        BodyContentXmlDoc := XmlDocument.Create();
        BodyDeclaration := XmlDeclaration.Create('1.0', 'UTF-8', 'No');
        BodyContentXmlDoc.SetDeclaration(BodyDeclaration);

        AMCBankingSetup.Get();
        AMCBankServiceRequestMgt.CreateEnvelope(BodyContentXmlDoc, EnvelopeXmlElement, AMCBankingSetup.GetUserName(), AMCBankingSetup.GetPassword(), '');
        AMCBankServiceRequestMgt.AddElement(EnvelopeXMLElement, EnvelopeXMLElement.NamespaceUri(), 'Body', '', BodyXMLElement, '', '', '');
        AMCBankServiceRequestMgt.AddElement(BodyXMLElement, AMCBankingMgt.GetNamespace(), BankListWebCallTxt, '', OperationXmlNode, '', '', '');

        AMCBankServiceRequestMgt.AddElement(OperationXmlNode, '', 'productdimgroup', 'BANK', ChildXmlElement, '', '', ''); //V17.5
        AMCBankServiceRequestMgt.AddElement(OperationXmlNode, '', 'banklisttype', 'Compressed', ChildXmlElement, '', '', ''); //V17.5
        AMCBankServiceRequestMgt.AddElement(OperationXmlNode, '', 'filterbycountry', CountryFilter, ChildXmlElement, '', '', '');

        BodyContentXmlDoc.WriteTo(TempXmlDocText);
        AMCBankServiceRequestMgt.RemoveUTF16(TempXmlDocText);
        contentHttpContent.WriteFrom(TempXmlDocText);
        BankListExchHttpRequestMessage.Content(contentHttpContent);
    end;

    local procedure InsertBankData(TempBlob: Codeunit "Temp Blob"; CountryFilter: Text)
    var
        AMCBankBanks: Record "AMC Bank Banks";
        ResponseXMLDoc: XmlDocument;
        BankListXmlNodeList: XmlNodeList;
        ChildNode: XmlNode;
        DataInStream: InStream;
        Found: Boolean;
        ChildCounter: Integer;
    begin
        TempBlob.CreateInStream(DataInStream);
        XmlDocument.ReadFrom(DataInStream, ResponseXmlDoc);

        Found := ResponseXmlDoc.SelectNodes(AMCBankServiceRequestMgt.GetBankXPath(), BankListXmlNodeList); //V17.5

        if (Found) then
            if BankListXmlNodeList.Count() > 0 then begin
                if CountryFilter <> '' then
                    AMCBankBanks.SetRange("Country/Region Code", CountryFilter);

                AMCBankBanks.DeleteAll();

                for ChildCounter := 1 to BankListXmlNodeList.Count() do begin
                    BankListXmlNodeList.Get(ChildCounter, ChildNode);
                    Clear(AMCBankBanks);

                    EVALUATE(AMCBankBanks.Bank, COPYSTR(AMCBankServiceRequestMgt.getNodeValue(ChildNode, './bank'), 1, 50));
                    EVALUATE(AMCBankBanks."Bank Name", COPYSTR(AMCBankServiceRequestMgt.getNodeValue(ChildNode, './bankname'), 1, 50));
                    EVALUATE(AMCBankBanks."Country/Region Code", COPYSTR(AMCBankServiceRequestMgt.getNodeValue(ChildNode, './countryoforigin'), 1, 50));
                    AMCBankBanks."Last Update Date" := TODAY();
                    AMCBankBanks.Insert(true);
                end;
            end;
    end;

    local procedure DisplayErrorFromResponse(BankListTempBlob: Codeunit "Temp Blob")
    var
        ResponseXmlDoc: XmlDocument;
        DataInStream: InStream;
        SysLogXMLNodeList: XmlNodeList;
        SyslogXmlNode: XmlNode;
        Found: Boolean;
        ErrorText: Text;
        j: Integer;
    begin
        BankListTempBlob.CreateInStream(DataInStream);
        XmlDocument.ReadFrom(DataInStream, ResponseXmlDoc);

        Found := ResponseXmlDoc.SelectNodes(AMCBankServiceRequestMgt.GetSysErrXPath(), SysLogXMLNodeList);
        if Found then begin
            ErrorText := AMCBankServSysErr;
            for j := 1 to SysLogXMLNodeList.Count() do begin
                SysLogXMLNodeList.Get(j, SyslogXmlNode);
                ErrorText += '\\' + CopyStr(AMCBankServiceRequestMgt.getNodeValue(SyslogXmlNode, 'text'), 1, 250) + '\' +
                                    CopyStr(AMCBankServiceRequestMgt.getNodeValue(SyslogXmlNode, 'hinttext'), 1, 250) + '\\' +
                                    StrSubstNo(AddnlInfoTxt, AMCBankingMgt.GetSupportURL(ResponseXmlDoc));
            end;
            Error(ErrorText);
        end;
    end;
}

