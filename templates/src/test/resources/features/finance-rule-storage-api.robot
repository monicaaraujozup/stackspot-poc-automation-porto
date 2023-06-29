Language: Portuguese
*** Settings ***
Library         SeleniumLibrary
Resource        ../../robot/br.com.portoseguro.payments/steps/FinanceRuleStorageApiSteps.robot
Library         FakerLibrary
Test Tags    regua-de-retentativas    regression    finance-rule-storage-api

*** Test Cases ***
Scenario: Deve inserir a parcela na régua do link
    [Tags]    insere-parcela-na-regua-do-link
    Dado uma solicitacao de insercao de parcela na regua do link com abecs "IRREVERSIBLE" e parcela "2"
    Quando consultar as informações da parcela no banco de dados
    Então o campo "ESTADO_REGUA" deve ser "REGUA_CRIADA"
