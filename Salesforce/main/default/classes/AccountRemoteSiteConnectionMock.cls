@isTest
public class AccountRemoteSiteConnectionMock implements HttpCalloutMock {
    
    protected Integer code;
    protected String type;
    protected String message;
    protected String bodyAsString;
    
    private Map<String, Object> mockResponse;
    
    
    public AccountRemoteSiteConnectionMock(Integer code, String type, String message, String body) {
        this.code = code;
        this.type = type;
        this.message = message;
        this.bodyAsString = body;
    }
    

    /*public AccountRemoteSiteConnectionMock(Map<String, Object> mockResponse) {
        this.mockResponse = mockResponse;
    }*/

    
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse resp = new HttpResponse();
        resp.setStatusCode(code);
        //resp.setStatus(status);
        resp.setBody(bodyAsString);
        
        return resp;
    }
    //AccountRemoteSiteConnectionMock.getPerson_Founded()
    public static String getPerson_Founded() {
		return '{  "personCode": "8661957",'
                    +'  "documentType": 1,'
                    +'  "documentNumber": "2840482",'
                    +'  "isPerson": true,'
                    +'  "addresses": ['
                    +'    {'
                    +'      "type": "L",'
                    +'      "street": "CALLE 1 Y CALLE 2",'
                    +'      "city": "MINGA GUAZU",'
                    +'      "country": "PARAGUAY",'
                    +'      "primary": false'
                    +'    },'
                    +'    {'
                    +'      "type": "P",'
                    +'      "street": "CALLE 1 Y CALLE 2",'
                    +'      "city": "ASUNCION",'
                    +'      "state": "BELLA VISTA",'
                    +'      "country": "PARAGUAY",'
                    +'      "latitude": "-27.3607717",'
                    +'      "longitude": "-55.8491571",'
                    +'      "primary": true'
                    +'    }'
                    +'  ],'
                    +'  "phone": { "number": "0992900382" },'
                    +'  "email": "XXXXX@UENO.COM",'
                    +'  "taxesType": "NC",'
                    +'  "isFATCA": true,'
                    +'  "isEmployee": false,'
                    +'  "businessArea": "MICROEMPRESA",'
                    +'  "accountOfficer": "XXXX XXXX XXXX XXXX",'
                    +'  "originCountry": "PARAGUAY",'
                    +'  "completeName": "CARLOS AGUILERA INCHAUSTI",'
                    +'  "citizenship": "PARAGUAYA",'
                    +'  "birthDate": "1961-12-28",'
                    +'  "accountSource": "BankItti",'
                    +'  "marriageStatus": "C",'
                    +'  "children": 0,'
                    +'  "genderIdentity": "M",'
                    +'  "spouse": {'
                    +'    "personCode": "8661960",'
                    +'    "documentType": 1,'
                    +'    "documentNumber": "8661960",'
                    +'    "addresses": ['
                    +'      {'
                    +'        "type": "P",'
                    +'        "street": "XXXXXXXXXXXXXXXXXXXX",'
                    +'        "city": "MINGA GUAZU",'
                    +'        "country": "PARAGUAY",'
                    +'        "primary": true'
                    +'      },'
                    +'      {'
                    +'        "type": "L",'
                    +'        "street": "XXXXXXXXXXXXXXXXXXXX",'
                    +'        "city": "MINGA GUAZU",'
                    +'        "country": "PARAGUAY",'
                    +'        "primary": false'
                    +'      }'
                    +'    ],'
                    +'    "phone": { "number": "186619" },'
                    +'    "taxesType": "NC",'
                    +'    "isFATCA": false,'
                    +'    "originCountry": "PARAGUAY",'
                    +'    "completeName": "FFFF FFFF FFFF FFFF",'
                    +'    "citizenship": "PARAGUAYA",'
                    +'    "birthDate": "1971-01-12",'
                    +'    "accountSource": "BankItti",'
                    +'    "marriageStatus": "C",'
                    +'    "children": 0,'
                    +'    "genderIdentity": "F",'
                    +'    "education": "SIN ESTUDIOS",'
                    +'    "occupation": "ALQUILER DE BIENES    ",'
                    +'    "housing": "COMPARTIDA FAMILIAR",'
                    +'    "registerDate": "2023-12-07 00:00:00-04:00",'
                    +'    "migrationFrom": "No Migrado"'
                    +'  },'
                    +'  "education": "SIN ESTUDIOS",'
                    +'  "occupation": "ALQUILER DE BIENES    ",'
                    +'  "housing": "COMPARTIDA FAMILIAR",'
                    +'  "registerDate": "2023-12-07 00:00:00-04:00",'
                    +'  "migrationFrom": "No Migrado",'
                    +'  "isPEP": false,'
                    +'  "images": ['
                    +'    {'
                    +'      "url": "http://fo-live01-srv.lnx.elcomercio.local:92/api/Documents/4ac69dc3-78c5-4416-82ca-94e9f4c8c575",'
                    +'      "description": "CEDULA IDENTIDAD - FRENTE"'
                    +'    },'
                    +'    {'
                    +'      "url": "http://fo-live01-srv.lnx.elcomercio.local:92/api/Documents/45ffd913-5b9f-42d9-82a4-1c9c28784005",'
                    +'      "description": "CEDULA DE INDENTIDAD -REVERSO"'
                    +'    },'
                    +'    {'
                    +'      "url": "http://fo-live01-srv.lnx.elcomercio.local:92/api/Documents/ea450f39-da73-4886-8ff0-92eea216e95e",'
                    +'      "description": "FOTOGRAFIA"'
                    +'    }'
                    +'  ]'
                    +'}';
	}
    
    public static String getPerson_Bad() {
        return '{"message":"Parametros vacios se necesita numero de documento o telefono",'
            +'"type":"Internal Server Error",'
            +'"code": 500}';
    }
      public static String getPerson_NotFound() {
        return '{"code":404,"type":"Not Found","message":"Customer not found."}';
    }
    /*public HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        
        response.setBody(body);
        response.setHeader('Content-Type', 'application/json');
        return response;
    }*/
}