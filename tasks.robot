*** Settings ***
Documentation       Hintavahti kahdelle eri urheilusivustolle.

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.Excel.Files


*** Tasks ***
Hintavahti kahdelle eri urheilusivustolle.
    Read product from Excel
    Open Browser


*** Keywords ***
Read product from Excel
    Open Workbook    productsToSearch.xlsx
    ${tblProductsToSearch}=    Read Worksheet As Table    header=True
    Close Workbook
    Open browser
    FOR    ${row}    IN    @{tblProductsToSearch}
        Fill and submit search product    ${row}
    END

Fill and submit search product
    [Arguments]    ${productToSearch}
    Input text    class:search-field__query    ${productToSearch}[Products]
    press keys    class:search-field__query    RETURN

Open browser
    Open Available Browser    https://www.stadium.fi/
