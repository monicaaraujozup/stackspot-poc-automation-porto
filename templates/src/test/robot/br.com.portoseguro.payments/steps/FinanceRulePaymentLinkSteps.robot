*** Settings ***
Variables       ../utils/constants/constants.py
Library         BuiltIn
Library         Collections
Library         JSONLibrary
Library         OperatingSystem
Library         SeleniumLibrary
Library         RequestsLibrary
Library         FakerLibrary
Resource        ../utils/rest/Requests.robot
Library         ../utils/kafka/kafkaProducer.py
Library         ../utils/kafka/kafkaConsumer.py
Resource        ../commons/commons.robot

*** Variables ***
${EVENTO_PATH}      src/test/robot/br.com.portoseguro.payments/utils/json/PaymentLinkRequest.json
${SCHEMA}           src/test/resources/avro/PaymentLinkRequest.avsc
${json_path}        src/test/robot/br.com.portoseguro.payments/utils/json/InsereParcelaReguaLink.json
${rotaReguaLink}    /finance-rule-storage-api/v1/ruleapi
${INGRESS_URL}      ${None}
${KAFKA_BOOTSTRAP_SERVERS}        ${None}

*** Keywords ***
uma solicitacao de insercao de parcela na regua do link com abecs "${tipo_do_codigo}" e parcela "${numero_parcela}"
    ${headers}                               Create Dictionary       Content-type=${APP_CONTENT_TYPE}
    ${id_externo}                            Uuid 4
    Set Suite Variable                       ${id_externo}           ${id_externo}
    ${json_file}                             Load Json From File     ${json_path}       
    ${body}                                  Update Value To Json    ${json_file}                         $..externalID              ${id_externo}
    ${body}                                  Update Value To Json    ${body}                              $..currentInstallment       ${numero_parcela}
    ${body}                                  Update Value To Json    ${body}                              $..codeType                ${tipo_do_codigo}
    Enviar uma requisição com método POST    ingressDev              ${null}                              ${INGRESS_URL}             ${rotaReguaLink}           ${headers}    json    ${body}

solicitar o reenvio para o topico "${topico}" da parcela "${numero_parcela}"
    Set Global Variable    ${numero_parcela}
    ${EVENTO}              Load Json From File     ${EVENTO_PATH}
    ${EVENTO}              Update Value To Json    ${EVENTO}          $..idExterno                     ${id_externo}
    ${EVENTO}              Update Value To Json    ${EVENTO}          $..metadados.parcela             ${numero_parcela}
    ${EVENTO}              Update Value To Json    ${EVENTO}          $..planoPagamento[0].parcelas    ${numero_parcela} 
    kafkaProducer         ${topico}               ${SCHEMA}          ${EVENTO}                        ${KAFKA_BOOTSTRAP_SERVERS}  

consultar a api da regua do link buscando por id e parcela
    ${response_local}                              Enviar uma requisição com método GET     ingressDev    ${INGRESS_URL}    ${rotaReguaLink}/idexterno/${id_externo}/parcela/${numero_parcela}
    Set Global Variable    ${response}            ${response_local}

deve ocorrer um evento no topico fin-contract-requested-communication
    ${consumer}             aguarda_evento          externalId        ${id_externo}       ${10}
    Log                     ${consumer}
    Should Not Be Equal     ${consumer}             ${None}

o valor do campo "${campo}" deve estar com o valor "${valor_campo}"
    Set Suite Variable    ${chave}                ${campo}
    Set Suite Variable    ${valor_esperado}        ${valor_campo}
    Wait Until Keyword Succeeds    5 s        0.5 s        compara valores


compara valores
    consultar a api da regua do link buscando por id e parcela
    ${campo_response}      Get Value From Json        ${response.json()}        ${chave}
    Should Not Be Empty    ${campo_response}
    ${campo_response}      Convert To String          ${campo_response[0]}
    Should Be Equal        ${campo_response}          ${valor esperado}

o status code deve ser "${status_code}"
    compara status code        ${status_code}