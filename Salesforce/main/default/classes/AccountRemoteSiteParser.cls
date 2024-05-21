public class AccountRemoteSiteParser {

    
    public class AccountResponse {
        public String firstName {get; set;}
        public String middleName {get; set;}
        public String lastName {get; set;}
        public String documentType {get; set;}
        public Integer documentNumber {get; set;}
        public Integer personCode {get; set;}
        public Boolean isPerson {get; set;}
        public String citizen {get; set;}
        public List<AddressResponse> address {get; set;}
        public String personBirthdate {get; set;}
        public String accountSource {get; set;}
        public String website {get; set;}
        public String phone {get; set;}
        public String email {get; set;}
        public String marriageStatus {get; set;}
        public Integer childrens {get; set;}
        public String personGenderIdentity {get; set;}
        public ConyugeResponse spouse {get; set;}
        public String education {get; set;}
        public String occupation {get; set;}
        public String housing {get; set;}
        public String taxesType {get; set;}
        public String registerDate {get; set;}
        public String status {get; set;}
        public String migrationFrom {get; set;}
        public Decimal income {get; set;}
    }
    
    public class AddressResponse {
        public String type {get; set;}
        public String street {get; set;}
        public String city {get; set;}
        public String state {get; set;}
        public String postalCode {get; set;}
        public String country {get; set;}
        public String latitude {get; set;}
        public String longitude {get; set;}
    }
    
    public class ConyugeResponse {
        public String firstName {get; set;}
        public String middleName {get; set;}
        public String lastName {get; set;}
        public String documentType {get; set;}
        public Integer documentNumber {get; set;}
    }
    public static LogsRespon processAccountResponse(LogsRespon accountRes){
        if(accountRes.code != 200 && accountRes.code != null){
            System.debug('<> 200');
            
        }else{
            accountRes.isError = false;
        }
        return accountRes;
    }
    public class LogsRespon{
        public Integer code;
        public String message;
        public Boolean isError;
        public String serviceName;
        public String endpoint;
        public String request;
        public String response;
        
        public LogsRespon(){
            this.isError = false; 
        }
    }
    // Método para imprimir un objeto AccountResponse
    public static void imprimirAccountResponse(AccountResponse account) {
        System.debug('=== Account Response ===');
        System.debug('First Name: ' + account.firstName);
        System.debug('Middle Name: ' + account.middleName);
        System.debug('Last Name: ' + account.lastName);
        System.debug('Document Type: ' + account.documentType);
        System.debug('Document Number: ' + account.documentNumber);
        System.debug('Person Code: ' + account.personCode);
        System.debug('Is Person: ' + account.isPerson);
        System.debug('Citizen: ' + account.citizen);
        System.debug('Person Birthdate: ' + account.personBirthdate);
        System.debug('Account Source: ' + account.accountSource);
        System.debug('Website: ' + account.website);
        System.debug('Phone: ' + account.phone);
        System.debug('Email: ' + account.email);
        System.debug('Marriage Status: ' + account.marriageStatus);
        System.debug('Childrens: ' + account.childrens);
        System.debug('Person Gender Identity: ' + account.personGenderIdentity);
        System.debug('Education: ' + account.education);
        System.debug('Occupation: ' + account.occupation);
        System.debug('Housing: ' + account.housing);
        System.debug('Taxes Type: ' + account.taxesType);
        System.debug('Register Date: ' + account.registerDate);
        System.debug('Status: ' + account.status);
        System.debug('Migration From: ' + account.migrationFrom);
        System.debug('Income: ' + account.income);
        
        // Imprimir direcciones
        if (account.address != null) {
            System.debug('=== Addresses ===');
            for (AddressResponse address : account.address) {
                System.debug('Type: ' + address.type);
                System.debug('Street: ' + address.street);
                System.debug('City: ' + address.city);
                System.debug('State: ' + address.state);
                System.debug('Postal Code: ' + address.postalCode);
                System.debug('Country: ' + address.country);
                System.debug('Latitude: ' + address.latitude);
                System.debug('Longitude: ' + address.longitude);
            }
        }
        
        // Imprimir datos del cónyuge
        if (account.spouse != null) {
            System.debug('=== Spouse ===');
            System.debug('First Name: ' + account.spouse.firstName);
            System.debug('Middle Name: ' + account.spouse.middleName);
            System.debug('Last Name: ' + account.spouse.lastName);
            System.debug('Document Type: ' + account.spouse.documentType);
            System.debug('Document Number: ' + account.spouse.documentNumber);
        }
    }
}