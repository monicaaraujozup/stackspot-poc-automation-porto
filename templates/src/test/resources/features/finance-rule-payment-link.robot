Language: Portuguese
*** Settings ***
Library         SeleniumLibrary
Resource        ../../robot/br.com.portoseguro.payments/steps/FinanceRulePaymentLinkSteps.robot
Resource        ../../robot/br.com.portoseguro.payments/commons/commons.robot
Library         ../../robot/br.com.portoseguro.payments/utils/kafka/kafkaConsumer.py
Test Setup      inicia_consumer    fin-contract-requested-communication    ${KAFKA_BOOTSTRAP_SERVERS}
Test Teardown   para_consumer
Test Tags       regua-de-retentativas    regression    finance-rule-payment-link

*** Test Cases ***
Scenario: Deve atualizar o estado de parcela com abecs irreversible na regua do link para aguardando pagamento após envio do evento fin-rule-link
    [Tags]    atualiza-estado-aguardando-pagamento-apos-reenvio-link-irreversible
    Dado uma solicitacao de insercao de parcela na regua do link com abecs "IRREVERSIBLE" e parcela "2"
    Quando solicitar o reenvio para o topico "fin-rule-link" da parcela "2"
        E consultar a api da regua do link buscando por id e parcela
    Então o status code deve ser "200"
        E o valor do campo "transitions" deve estar com o valor "REGUA_CRIADA, AGUARDANDO_PAGAMENTO"
        E o valor do campo "state" deve estar com o valor "AGUARDANDO_PAGAMENTO"
        E deve ocorrer um evento no topico fin-contract-requested-communication

Scenario: Deve atualizar o estado de parcela com abecs reversible na regua do link para aguardando pagamento após envio do evento fin-rule-link
    [Tags]    atualiza-estado-aguardando-pagamento-apos-reenvio-link-reversible
    Dado uma solicitacao de insercao de parcela na regua do link com abecs "REVERSIBLE" e parcela "3"
    Quando solicitar o reenvio para o topico "fin-rule-link" da parcela "3"
        E consultar a api da regua do link buscando por id e parcela
    Então o status code deve ser "200"
        E o valor do campo "transitions" deve estar com o valor "REGUA_CRIADA, AGUARDANDO_PAGAMENTO"
        E o valor do campo "state" deve estar com o valor "AGUARDANDO_PAGAMENTO"
        E deve ocorrer um evento no topico fin-contract-requested-communication

Scenario: Deve atualizar o estado de parcela com abecs unknown na regua do link para aguardando pagamento após envio do evento fin-rule-link
    [Tags]    atualiza-estado-aguardando-pagamento-apos-reenvio-link-unknown
    Dado uma solicitacao de insercao de parcela na regua do link com abecs "UNKNOWN" e parcela "12"
    Quando solicitar o reenvio para o topico "fin-rule-link" da parcela "12"
        E consultar a api da regua do link buscando por id e parcela
    Então o status code deve ser "200"
        E o valor do campo "transitions" deve estar com o valor "REGUA_CRIADA, AGUARDANDO_PAGAMENTO"
        E o valor do campo "state" deve estar com o valor "AGUARDANDO_PAGAMENTO"
        E deve ocorrer um evento no topico fin-contract-requested-communication