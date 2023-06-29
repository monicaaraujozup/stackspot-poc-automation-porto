*** Settings ***
Library         JSONLibrary
Library      RequestsLibrary

*** Keywords ***
compara status code
    [Arguments]    ${status_code}
    Status Should Be    ${status_code}    ${response}