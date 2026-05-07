# Salesforce Customer Account Validation API

A custom Apex REST API built in Salesforce to validate customer identity and securely expose account information to external systems.

## Features
- Apex REST API
- OAuth 2.0 Authentication
- CPF Validation
- Structured JSON Responses
- HTTP Status Code Handling
- Salesforce Integration Architecture

## Technologies
- Salesforce Apex
- SOQL
- OAuth 2.0
- Postman
- VS Code + SFDX

## Endpoint

GET /services/apexrest/Account/{accountNumber}

## Status Codes

| Code | Meaning |
|---|---|
| 200 | Success |
| 400 | Missing CPF Header |
| 401 | Unauthorized |
| 404 | Account Not Found |

## Example Response


json
{
  \"success\": true,
  \"message\": \"User authenticated successfully\",
  \"statusCode\": 200
}