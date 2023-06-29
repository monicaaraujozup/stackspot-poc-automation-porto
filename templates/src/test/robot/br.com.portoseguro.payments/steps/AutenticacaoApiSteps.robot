*** Settings ***
Variables       ../utils/constants/constants.py
Library         BuiltIn
Library         Collections
Library         JSONLibrary
Library         OperatingSystem
Library         SeleniumLibrary
Library         RequestsLibrary
Resource        ../utils/rest/Requests.robot

*** Variables ***
${CLIENT_ID}        ${None}
${CLIENT_SECRET}    ${None}
${rota_token}      /oauth/v2/access-token
${APP_BASE_URL}    ${None}

*** Keywords ***
que seja informado os dados corretos do usuário
    ${auth}                Create List                        ${CLIENT_ID}                          ${CLIENT_SECRET}
    Set Suite Variable     ${auth}    ${auth}
    ${headers}             Create Dictionary                  Content-type=${AUTH_CONTENT_TYPE}
    Set Suite Variable     ${headers}                         ${headers}
    ${body}                Create Dictionary                  grant_type=${GRANT_TYPE}
    Set Suite Variable     ${body}                            ${body}

realizar a requisição no endpoint de autenticação
    ${response}            Enviar uma requisição com método POST   autenticacao    ${auth}    ${APP_BASE_URL}    ${rota_token}    ${headers}    data    ${body}
    Set Suite Variable     ${response}                             ${response}

a API deve retornar status code ${status_code}
    Status Should Be       ${status_code}    ${response}

o token
    ${token}               JSONLibrary.Get Value From Json    ${response.json()}    access_token
    Should Not Be Empty    ${token}

que seja informado dados incorretos do clientId
    ${auth}                Create List                        clientId-incorreto                   ${CLIENT_SECRET}
    Set Suite Variable     ${auth}
    ${headers}             Create Dictionary                  Content-type=${AUTH_CONTENT_TYPE}
    Set Suite Variable     ${headers}                         ${headers}
    ${body}                Create Dictionary                  grant_type=${GRANT_TYPE}
    Set Suite Variable     ${body}                            ${body}