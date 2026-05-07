@RestResource(urlMapping='/Account/*')
global with sharing class AccountManager {

    @HttpGet
    global static Account getAccount() {

        RestRequest req = RestContext.request;

        String apiKey = req.headers.get('x-api-key');

        String accountNumber = req.requestURI.substring(
            req.requestURI.lastIndexOf('/') + 1
        );

        List<Account> acc = [
            SELECT Id, Name, Phone,SLASerialNumber__c
            FROM Account
            WHERE AccountNumber = :accountNumber
            LIMIT 1
        ];
        
        String serialNumber = acc[0].SLASerialNumber__c;
        
        if(apiKey != serialNumber){
            RestContext.response.statusCode = 401;
            return null;
        }

        if(acc.isEmpty()){
            RestContext.response.statusCode = 404;
            return null;
        }

        return acc[0];
    }
}