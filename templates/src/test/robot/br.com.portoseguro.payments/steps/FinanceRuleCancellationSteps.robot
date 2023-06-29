*** Settings ***
Variables       ../utils/constants/constants.py
Library         BuiltIn
Library         Collections
Library         JSONLibrary
Library         OperatingSystem
Library         SeleniumLibrary
Library         RequestsLibrary
Resource        ../utils/rest/Requests.robot
Library         ../utils/kafka/kafkaProducer.py
Library         FakerLibrary
    

*** Variables ***
${SCHEMA}           src/test/resources/avro/CancelRecurrenceConfirmation.avsc
${EVENTO_PATH}      src/test/robot/br.com.portoseguro.payments/utils/json/CancelRecurrenceConfirmation.json
${json_path}        src/test/robot/br.com.portoseguro.payments/utils/json/InsereParcelaReguaLink.json
${rotaReguaLink}    /finance-rule-storage-api/v1/ruleapi
${INGRESS_URL}      ${None}
${KAFKA_BOOTSTRAP_SERVERS}        ${None}

*** Keywords ***
um evento no topico "${topico}"
    ${EVENTO}         Load Json From File     ${EVENTO_PATH}
    ${EVENTO}         Update Value To Json    ${EVENTO}          $..externalId    ${id_externo} 
    kafkaProducer    ${topico}               ${SCHEMA}          ${EVENTO}        ${KAFKA_BOOTSTRAP_SERVERS}     

uma solicitacao de insercao de parcela na regua do link com abecs "${tipo_do_codigo}" e parcela "${numero_parcela}"
    Set Suite Variable                       ${numero_parcela}       ${numero_parcela}        
    ${headers}                               Create Dictionary       Content-type=${APP_CONTENT_TYPE}
    ${id_externo}                            Uuid 4
    Set Suite Variable                       ${id_externo}           ${id_externo}
    ${json_file}                             Load Json From File     ${json_path}       
    ${body}                                  Update Value To Json    ${json_file}                         $..externalID              ${id_externo}
    ${body}                                  Update Value To Json    ${body}                              $..currentIntallment       ${numero_parcela}
    ${body}                                  Update Value To Json    ${body}                              $..codeType                ${tipo_do_codigo}
    Enviar uma requisição com método POST    ingressDev              ${null}                              ${INGRESS_URL}             ${rotaReguaLink}           ${headers}    json    ${body}

ao consultar a api da regua do link buscando por id e parcela o status code "${status_code}"
    ${response}                              Enviar uma requisição com método GET     ingressDev    ${INGRESS_URL}    ${rotaReguaLink}/idexterno/${id_externo}/parcela/${numero_parcela}
    Set Suite Variable                       ${response}                              ${response}

o valor do campo "${campo}" deve estar com o valor "${valor_campo}"
    ${campo_response}    Get Value From Json    ${response.json()}    ${campo}
    ${campo_response}    Convert To String      ${campo_response[0]}
    Should Be Equal      ${campo_response}      ${valor_campo}