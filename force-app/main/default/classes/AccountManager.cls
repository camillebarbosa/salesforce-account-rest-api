/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-07-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@RestResource(urlMapping='/Account/*')
global with sharing class AccountManager {

    @HttpGet
    global static ApiResponse getAccount() {

        RestRequest req = RestContext.request;

        String cpfHeader = req.headers.get('cpf');

        String accountNumber = req.requestURI.substring(
            req.requestURI.lastIndexOf('/') + 1
        );

        List<Account> acc = [
            SELECT Id, Name, Phone, CPF__c, BillingStreet,
            BillingCity,
            BillingState,
            BillingCountry,
            BillingPostalCode
            FROM Account
            WHERE AccountNumber = :accountNumber
            LIMIT 1
        ];

        ApiResponse response = new ApiResponse();
    

        if(String.isBlank(cpfHeader)){
            RestContext.response.statusCode = 400;

            response.success = false;
            response.statusCode = 400;
            response.message = 'Custumer CPF header is required';

            return response;
        }

        // Verifica se encontrou account
        if(acc.isEmpty()){

            RestContext.response.statusCode = 404;
            response.statusCode = 404;
            response.success = false;
            response.message = 'Error: '+ response.statusCode + '!'+' Account not Found';

            return response;
        }

        String cpf = acc[0].CPF__c;

        // Verifica autenticação
        if(cpfHeader != cpf){

            RestContext.response.statusCode = 401;
            response.statusCode = 401;
            response.success = false;
            response.message = 'Error: '+ response.statusCode + '!'+' The CPF Informed Does Not Match the Account';

            return response;
        }
        

        // Sucesso
        response.accountid = acc[0].Id;
        response.accountName =  acc[0].Name;
        response.accountPhone = acc[0].Phone;
        response.addressCity = acc[0].BillingCity;
        response.addressPostal = acc[0].BillingPostalCode;


        response.success = true;
        response.statusCode = 200;
        response.message = 'User authenticated successfully';
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