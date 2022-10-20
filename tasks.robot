*** Settings ***
Documentation       Hintavahti Stadiumille

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.Excel.Files
Library             Collections
Library             String
Library             RPA.Tables
Library             RPA.Email.ImapSmtp    smtp_server=smtp.outlook.com    smtp_port=587


*** Variables ***
${EMAIL}        hintakytta@outlook.com
${PASSWORD}     HinnatAlas123!
${RECIPIENT}    sini.auvinen@student.laurea.fi


*** Tasks ***
Hintavahti Stadiumille
    Read product from Excel
    Open browser
    Get prices
    Save prices to Excel    ${PRICES_OF_PRODUCTS}    @{TBL_PRODUCTS_TO_SEARCH}


*** Keywords ***
Read product from Excel
    Open Workbook    productsToSearch.xlsx
    @{TBL_PRODUCTS_TO_SEARCH}=    Read Worksheet As Table    header=True
    Set Suite Variable    @{TBL_PRODUCTS_TO_SEARCH}
    Close Workbook

Open browser
    Open Available Browser    https://www.stadium.fi/

Get prices
    ${PRICES_OF_PRODUCTS}=    Create List
    Set Suite Variable    ${PRICES_OF_PRODUCTS}
    FOR    ${row}    IN    @{TBL_PRODUCTS_TO_SEARCH}
        Fill and submit search product from Stadium    ${row}
        ${priceOfOneProduct}=    Get Text    class:price--large
        Append To List    ${PRICES_OF_PRODUCTS}    ${priceOfOneProduct}
    END

Fill and submit search product from Stadium
    [Arguments]    ${productToSearch}
    Input text    class:search-field__query    ${productToSearch}[Products]
    press keys    class:search-field__query    RETURN
    Click Element    class:product-card
    Wait Until Page Contains Element    class:price--large

Save prices to Excel
    [Arguments]    ${pricesToExcel}    @{tblProductsToSearch}
    Open Workbook    productsToSearch.xlsx
    ${i}=    Set Variable    ${0}
    Set Suite Variable    ${i}
    ${amountOfProducts}=    Get Length    ${pricesToExcel}
    WHILE    ${i} < ${amountOfProducts}
        ${currentPrice}=    Remove String    ${pricesToExcel}[${i}]    -    ,
        ${oldPrice}=    Get Cell Value    ${i + 2}    2
        ${currentProduct}=    Get Cell Value    ${i + 2}    1
        IF    ${oldPrice} != None
            IF    ${currentPrice} < ${oldPrice}
                Send email to user
                ...    ${currentProduct}
                ...    Päivän hinta tuotteelle ${currentProduct} ${currentPrice} on alhaisempi kuin eilinen ${oldPrice}
            END
        END
        Set Cell Value    ${i + 2}    2    ${currentPrice}
        ${i}=    Evaluate    ${i} + 1
    END
    Save Workbook
    Close Workbook

Send email to user
    [Arguments]    ${emailSubject}    ${emailBody}
    Authorize    account=${EMAIL}    password=${PASSWORD}
    Send Message    sender=${EMAIL}    recipients=${RECIPIENT}    subject=${emailSubject}    body=${emailBody}
