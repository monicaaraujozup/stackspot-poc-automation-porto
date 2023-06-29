Language: Portuguese
*** Settings ***
Library     SeleniumLibrary
Resource    ../../robot/br.com.portoseguro.payments/steps/FinanceRuleCancellationSteps.robot
Resource    ../../robot/br.com.portoseguro.payments/commons/commons.robot
Test Tags    regua-de-retentativas    regression    finance-rule-cancellation

*** Test Cases ***
Scenario: Deve enviar a informação de cancelamento de contrato para a api de banco
    [Tags]    processa-cancelamento-de-contrato-irreversible
    Dado uma solicitacao de insercao de parcela na regua do link com abecs "IRREVERSIBLE" e parcela "2"
    Quando um evento no topico "fin-cancellation-recurrence"
    Então ao consultar a api da regua do link buscando por id e parcela o status code "200"
         E o valor do campo "state" deve estar com o valor "RECORRENCIA_CANCELADA"
         E o valor do campo "transitions" deve estar com o valor "REGUA_CRIADA, RECORRENCIA_CANCELADA"

Scenario: Deve enviar a informação de cancelamento de contrato para a api de banco com abecs UNKNOWN
    [Tags]    processa-cancelamento-de-contrato-unknown
    Dado uma solicitacao de insercao de parcela na regua do link com abecs "UNKNOWN" e parcela "2"
    Quando um evento no topico "fin-cancellation-recurrence"
    Então ao consultar a api da regua do link buscando por id e parcela o status code "200"
         E o valor do campo "state" deve estar com o valor "RECORRENCIA_CANCELADA"
         E o valor do campo "transitions" deve estar com o valor "REGUA_CRIADA, RECORRENCIA_CANCELADA"
