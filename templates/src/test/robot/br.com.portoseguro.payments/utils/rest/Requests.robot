*** Settings ***
Library         RequestsLibrary

*** Keywords ***
Enviar uma requisição com método POST
        [Arguments]        ${alias}                    ${auth}                  ${baseUrl}           ${endpoint}              ${headers}              ${body_type}          ${body_request}          
        Create Session     alias=${alias}              auth=${auth}             url=${baseUrl}       headers=${headers}       verify=false            disable_warnings=1    proxies=htpps
        ${response}        POST On Session             alias=${alias}           url=${endpoint}    
        ...                ${body_type}=${body_request}        headers=${headers}       expected_status=any
        [Return]           ${response}

Enviar uma requisição com método GET
        [Arguments]        ${alias}                    ${baseUrl}               ${endpoint}          
        Create Session     alias=${alias}              url=${baseUrl}           verify=false             disable_warnings=1    proxies=htpps
        ${response}        GET On Session              alias=${alias}           url=${endpoint}          expected_status=any
        [Return]           ${response}
