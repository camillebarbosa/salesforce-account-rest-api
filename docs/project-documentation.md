
Salesforce Integration Project Documentation
Customer Account Validation API
1. Project Overview
Project Name

Customer Account Validation REST API

Project Type

Salesforce System Integration

Objective

Develop a secure Apex REST API in Salesforce to allow external systems to validate customer identity and retrieve account information using:

Account Number
CPF validation

The API will be consumed by the company’s e-commerce platform before exposing sensitive customer account data.

2. Business Context

The company owns an online retail website where customers can:

View personal account information
Track orders
Access loyalty benefits
Open support requests

Before returning customer data, the system must validate that the CPF informed by the client matches the CPF stored in Salesforce CRM.

Salesforce acts as the company’s primary customer data platform.

3. Systems Involved
System	Responsibility
Salesforce CRM	Customer data storage
Apex REST API	Exposes account validation service
E-commerce Website	Consumes the REST API
OAuth 2.0 Service	Authentication and token generation
Postman	API testing and validation
4. High-Level Architecture
Customer
   ↓
E-commerce Website
   ↓
OAuth Authentication
   ↓
Salesforce Apex REST API
   ↓
CPF Validation
   ↓
Salesforce Account Data
5. Functional Requirements
FR-01

The API must receive an Account Number through the endpoint URL.

FR-02

The API must receive a CPF value through the HTTP request header.

FR-03

The API must validate if the informed CPF matches the CPF stored in Salesforce.

FR-04

The API must return account information only after successful validation.

FR-05

The API must return standardized JSON responses.

FR-06

The API must use appropriate HTTP status codes.

6. Non-Functional Requirements
Requirement	Description
Security	OAuth 2.0 authentication required
Scalability	REST architecture
Maintainability	Structured response object
Data Protection	Sensitive data must not be exposed
Error Handling	Standardized HTTP status responses
7. Authentication Strategy
Authentication Type

OAuth 2.0

OAuth Flow

Password Grant Type

Required Credentials
Consumer Key
Consumer Secret
Salesforce Username
Password + Security Token
8. API Technical Specification
Endpoint
GET /services/apexrest/Account/{accountNumber}
9. Request Specification
HTTP Method
GET
10. Request Headers
Header	Required	Description
Authorization	Yes	OAuth Bearer Token
cpf	Yes	Customer CPF used for validation
11. Example Request
GET /services/apexrest/Account/CD355119-A HTTP/1.1

Host: company.my.salesforce.com
Authorization: Bearer 00DXXXXXXXXXXXX
cpf: 12345678900
12. Apex REST Resource
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
            SELECT Id, Name, Phone, CPF__c,
                   BillingStreet,
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
            response.message = 'Customer CPF header is required';

            return response;
        }

        if(acc.isEmpty()){

            RestContext.response.statusCode = 404;

            response.success = false;
            response.statusCode = 404;
            response.message = 'Account not found';

            return response;
        }

        String cpf = acc[0].CPF__c;

        if(cpfHeader != cpf){

            RestContext.response.statusCode = 401;

            response.success = false;
            response.statusCode = 401;
            response.message = 'The informed CPF does not match the account';

            return response;
        }

        response.accountid = acc[0].Id;
        response.accountName = acc[0].Name;
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
13. Response Structure
Success Response — 200 OK
{
  "success": true,
  "message": "User authenticated successfully",
  "statusCode": 200,
  "accountid": "001XXXXXXXXXXXX",
  "accountName": "Camille Barbosa",
  "accountPhone": "11999999999",
  "addressCity": "São Paulo",
  "addressPostal": "01000-000"
}
14. Error Responses
400 — Bad Request
Scenario

CPF header was not informed.

Response
{
  "success": false,
  "message": "Customer CPF header is required",
  "statusCode": 400
}
401 — Unauthorized
Scenario

The informed CPF does not match the account.

Response
{
  "success": false,
  "message": "The informed CPF does not match the account",
  "statusCode": 401
}
404 — Not Found
Scenario

Account Number was not found.

Response
{
  "success": false,
  "message": "Account not found",
  "statusCode": 404
}
15. HTTP Status Codes
Status Code	Meaning	Usage
200	OK	Successful authentication
400	Bad Request	Missing CPF header
401	Unauthorized	CPF validation failed
404	Not Found	Account not found
16. Security Design
Implemented Security
OAuth 2.0 authentication
CPF validation
Controlled JSON response
with sharing enforcement
Hidden sensitive fields
Recommended Future Enhancements
JWT Bearer Flow
API rate limiting
Encryption of sensitive data
Logging and monitoring
Named Credentials
Custom Metadata for configuration
17. Test Scenarios
Scenario	Expected Result
Valid Account + Valid CPF	200 OK
Missing CPF Header	400 Bad Request
Invalid CPF	401 Unauthorized
Invalid Account Number	404 Not Found
18. Tools Used
Tool	Purpose
Salesforce Developer Org	Backend platform
Apex	API development
SOQL	Data querying
OAuth 2.0	Authentication
Postman	API testing
VS Code + SFDX	Development environment
GitHub	Version control
19. Future Improvements

Potential next versions:

POST endpoint for account creation
PATCH endpoint for account updates
Swagger/OpenAPI documentation
JWT authentication flow
Experience Cloud integration
Event-driven architecture
Platform Events integration
20. Conclusion

This project simulates a real-world Salesforce integration architecture where external systems securely consume customer information through Apex REST APIs.

The implementation demonstrates:

API security concepts
OAuth authentication
HTTP status code handling
Structured JSON responses
Request validation
Backend integration patterns
Salesforce REST architecture

The solution follows enterprise API design principles commonly used in Salesforce integration projects.