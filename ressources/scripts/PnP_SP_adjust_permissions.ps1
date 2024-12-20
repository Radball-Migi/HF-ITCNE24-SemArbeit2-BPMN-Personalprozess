#*******************************************************************#
# Script to adjust the Accessrights in SharePoint for the User      #
#*******************************************************************#


function Get-CamundaVars {

    # Get Variables from Camunda Form
    $processInstanceId = "" #deine_prozessinstanz_id
    $url = "http://localhost:8080/engine-rest/process-instance/$processInstanceId/variables" # Definiere die URL für den API-Aufruf
    $response = Invoke-RestMethod -Uri $url -Method Get # Rufe die Variablenwerte über die Camunda REST API ab
    $variables = $response | ConvertFrom-Json # Konvertiere die Antwort in ein PowerShell-Objekt

    # Erstelle ein benutzerdefiniertes Objekt und füge die Variablen hinzu
    $UserProps = New-Object PSObject
    $UserProps | Add-Member -MemberType NoteProperty -Name "Name" -Value $variables.variable1.value
    $UserProps | Add-Member -MemberType NoteProperty -Name "Surname" -Value $variables.variable2.value
    $UserProps | Add-Member -MemberType NoteProperty -Name "DisplayName" -Value $variables.variable3.value
    $UserProps | Add-Member -MemberType NoteProperty -Name "Department" -Value $variables.variable4.value
    $UserProps | Add-Member -MemberType NoteProperty -Name "Office" -Value $variables.variable5.value
    $UserProps | Add-Member -MemberType NoteProperty -Name "JobTitle" -Value $variables.variable6.value
    $UserProps | Add-Member -MemberType NoteProperty -Name "Manager" -Value $variables.variable7.value
    $UserProps | Add-Member -MemberType NoteProperty -Name "Position" -Value $variables.variable8.value


    return $UserProps
}

function Connect-MSGandPnP {
    param (
        [string]$Tenant = "iseschool2013.onmicrosoft.com",
        [string]$ClientID = "058839a7-a056-47ad-8bf9-f56f230c6207",
        [string]$Thumbprint = "E5925A74E30F1C09CC38744486C8317CEEF88F87",
        [string]$TenantAdminUrl = "iseschool2013-admin.sharepoint.com"
    )

    Connect-MgGraph -ClientId $ClientID -CertificateThumbprint $Thumbprint -TenantId $Tenant -NoWelcome
    Connect-PnPOnline -Url $TenantAdminUrl -ClientId $ClientID -Thumbprint $Thumbprint

}




$UserPros = Get-CamundaVars
