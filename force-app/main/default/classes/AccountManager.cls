/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-08-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@RestResource(urlMapping='/Account/*')
global with sharing class AccountManager {

    @HttpGet
    global static ApiResponse getAccount() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response; // Referência direta para facilitar
        ApiResponse response = new ApiResponse();
        
        try {
            String cpfHeader = req.headers.get('cpf');
            
            // Pega o AccountNumber de forma mais segura
            String accountNumber = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);

            if (String.isBlank(cpfHeader)) {
                return setErrorResponse(res, response, 400, 'Customer CPF header is required');
            }

            // SOQL com verificação de segurança
            SObjectAccessDecision decision = Security.stripInaccessible(
                AccessType.READABLE, 
                [SELECT Id, Name, Phone, CPF__c, BillingCity, BillingPostalCode 
                 FROM Account 
                 WHERE AccountNumber = :accountNumber 
                 LIMIT 1]
            );

            List<Account> accList = (List<Account>) decision.getRecords();

            if (accList.isEmpty()) {
                return setErrorResponse(res, response, 404, 'Account Not Found');
            }

            Account acc = accList[0];
            
            // Valida o CPF
            if (cpfHeader != acc.CPF__c) {
                return setErrorResponse(res, response, 401, 'The CPF informed does not match the account');
            }

            // Sucesso
            res.statusCode = 200;
            response.success = true;
            response.statusCode = 200;
            response.message = 'User authenticated successfully';
            response.accountid = acc.Id;
            response.accountName = acc.Name;
            response.accountPhone = acc.Phone;
            response.addressCity = acc.BillingCity;
            response.addressPostal = acc.BillingPostalCode;

        } catch (Exception e) {
            // Tratamento de erro genérico para não expor stack trace
            setErrorResponse(res, response, 500, 'Internal Server Error: ' + e.getMessage());
        }

        return response;
    }

    // Método auxiliar para evitar repetição de código (Clean Code)
    private static ApiResponse setErrorResponse(RestResponse res, ApiResponse response, Integer code, String msg) {
        res.statusCode = code;
        response.success = false;
        response.statusCode = code;
        response.message = msg;
        return response;
    }

    global class ApiResponse {
        public Boolean success;
        public String message;
        public Integer statusCode;
        public Id accountid;
        public String accountName;
        public String accountPhone;
        public String addressCity;
        public String addressPostal;
    }
}