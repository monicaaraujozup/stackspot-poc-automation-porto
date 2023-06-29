*** Settings ***
# Resource    ../../steps/FinanceRuleStorageApiSteps.robot
# Library       RobotMongoDBLibrary.Find
 
*** Keywords ***
Conexão com o banco
    [Arguments]        ${query_string}      ${database}                   ${collection}
    &{resultado}       Create Dictionary    connection=${query_string}    database=${database}    collection=${collection}
    [Return]           ${resultado}