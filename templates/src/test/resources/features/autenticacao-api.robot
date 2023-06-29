Language: Portuguese
*** Settings ***
Library    SeleniumLibrary   
Resource    ../../robot/br.com.portoseguro.payments/steps/AutenticacaoApiSteps.robot
Resource    ../../robot/br.com.portoseguro.payments/commons/commons.robot
Test Tags    sensedea-api    regression    autenticacao

*** Test Cases ***
Scenario: Deve realizar a autenticação
    [Tags]    deve-gerar-token
    Dado que seja informado os dados corretos do usuário
    Quando realizar a requisição no endpoint de autenticação
    Então a API deve retornar status code 200
        E o token

Scenario: Não deve realizar a autenticação quando o clientId estiver incorreto
    [Tags]    nao-deve-gerar-token
    Dado que seja informado dados incorretos do clientId
    Quando realizar a requisição no endpoint de autenticação
    Então a API deve retornar status code 400
