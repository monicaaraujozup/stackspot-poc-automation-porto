*** Settings ***
Variables       ../utils/constants/constants.py
Library         BuiltIn
Library         Collections
Library         JSONLibrary
Library         FakerLibrary
Library         OperatingSystem
Library         SeleniumLibrary
Library         RequestsLibrary
Resource        ../utils/rest/Requests.robot
Resource        ../utils/mongo/mongo.robot
Library         RobotMongoDBLibrary.Find


*** Variables ***
${rotaReguaLink}               /finance-rule-storage-api/v1/ruleapi
${json_path}                   src/test/robot/br.com.portoseguro.payments/utils/json/InsereParcelaReguaLink.json
${MONGO_CONN_STR}              ${None}
${database}                    meiospagamento
${collection}                  finance_regua_retentativa_link_api
${INGRESS_URL}                 ${None}

*** Keywords ***
uma solicitacao de insercao de parcela na regua do link com abecs "${tipo_do_codigo}" e parcela "${numero_parcela}"
    ${headers}                               Create Dictionary       Content-type=${APP_CONTENT_TYPE}
    ${id_externo}                            Uuid 4
    Set Suite Variable                       ${id_externo}           ${id_externo}
    ${json_file}                             Load Json From File     ${json_path}       
    ${body}                                  Update Value To Json    ${json_file}                         $..externalID              ${id_externo}
    ${body}                                  Update Value To Json    ${body}                              $..currentIntallment       ${numero_parcela}
    ${body}                                  Update Value To Json    ${body}                              $..codeType                ${tipo_do_codigo}
    Enviar uma requisição com método POST    ingressDev              ${null}                              ${INGRESS_URL}             ${rotaReguaLink}           ${headers}    json    ${body} 

consultar as informações da parcela no banco de dados
    ${id_externo}          Convert To String      ${id_externo}
    &{mongo_connect}       Conexão com o banco    ${MONGO_CONN_STR}           ${database}    ${collection}
    &{filtro}              Create Dictionary      NUMERO_ID_EXTERNO=${id_externo}
    ${resultado}           Find                   ${mongo_connect}                  ${filtro}
    Should Not Be Equal    ${resultado}           FOUND ERROR
    Set Suite Variable     ${resultado}           ${resultado}


o campo "${campo}" deve ser "${valor}"
    Log To Console     ${resultado[0]["${campo}"]}
    Should Be Equal    ${valor}    ${resultado[0]["${campo}"]}