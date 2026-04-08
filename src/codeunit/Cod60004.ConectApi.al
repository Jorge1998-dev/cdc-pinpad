codeunit 60004 ConectApi
{
    trigger OnRun()
    begin
    end;

    procedure GetApi(TextoBody: Text; URLApi: Text[250]): Text
    var
        HttpContents: HttpContent;
        HttpClient: HttpClient;
        HttpResponse: HttpResponseMessage;
        Url: Text;
        ResponseText: Text;
        request: HttpRequestMessage;
        contentHeaders: HttpHeaders;
        SoapActions: Text;
        XMLStream: InStream;
        MsgTictuk: Text;
        ResponseTictuk: Text;
    begin
        HttpContents.Clear();
        HttpContents.GetHeaders(contentHeaders);
        HttpContents.WriteFrom(TextoBody);
        contentHeaders.Remove('Content-Type');
        contentHeaders.Remove('Charset');
        contentHeaders.Clear();

        contentHeaders.Add('Content-Type', 'application/json');
        contentHeaders.Add('SOAPAction', '');

        request.Content(HttpContents);
        request.Method('POST');
        HttpClient.Clear();
        HttpClient.SetBaseAddress(URLApi);
        //OPTREV Descomentar 2 lineas abajo
        IF not HttpClient.Send(request, HttpResponse) then
            Error('LLAMADA INCORRECTA');

        HttpResponse.Content.ReadAs(XMLStream);

        while not XMLStream.EOS do begin
            XMLStream.ReadText(MsgTictuk);
            ResponseTictuk := ResponseTictuk + MsgTictuk;
        end;
        //septiembre
        IF not HttpResponse.IsSuccessStatusCode then
            Error('The WS has returned the following error: \' +
            'Status Code : %1\' +
            'Descripcion: %2\' +
            'Response body: %3',
            HttpResponse.HttpStatusCode,
            HttpResponse.ReasonPhrase, ResponseTictuk);
        exit(ResponseTictuk);
    end;
}
