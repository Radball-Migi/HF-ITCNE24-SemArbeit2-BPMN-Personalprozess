#*******************************************************************#
# Script to Create a User with the Variables of the camunda Form    #
#*******************************************************************#


#Functions

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

function Connect-MSG {
    param (
        [string]$Tenant = "iseschool2013.onmicrosoft.com",
        [string]$ClientID = "058839a7-a056-47ad-8bf9-f56f230c6207",
        [string]$Thumbprint = "E5925A74E30F1C09CC38744486C8317CEEF88F87"
    )

    Connect-MgGraph -ClientId $ClientID -CertificateThumbprint $Thumbprint -TenantId $Tenant -NoWelcome

}

function Generate-Password {
    param (
        [int]$length = 1
    )

    $words = "Bananen" , "Backofen" , "Schüssel" , "Computer" , "Rucksack" , "Teigling" , "Handtuch" , "Fernseh" , "Füller" , "Tische" , "Wanduhr" , "Zitronen" , "Erdbeere" , "Tomaten" , "Freiburg" , "Rümlang" , "Zermatt" , "Willisau" , "Aprikose" , "Pflaumen"
    $specialChars = "!", "$", "?", "%", "#", "&", "+", "." 
    $numbers = 0..9

    # Ersetzungstabelle
    $replaceTable = @{
        'a' = '@';
        'e' = '3';
        'i' = '1';
        'o' = '0';
    }

    $passwords = @()
    for ($i = 0; $i -lt $length; $i++) {
        do {
            $password = for ($j = 0; $j -lt 1; $j++) {
                $word = $words[(Get-Random -Maximum $words.length)]
                $specialChar = $specialChars[(Get-Random -Maximum $specialChars.length)]
                $number = $numbers[(Get-Random -Maximum $numbers.length)]

                # Ersetze Zeichen im Wort
                foreach ($key in $replaceTable.Keys) {
                    $word = $word -replace $key, $replaceTable[$key]
                }

                "$word$specialChar$number"
            }

            $password = -join $password
        } while ($passwords -contains $password)

        $passwords += $password
    }

    return $passwords
}

function New-Password {
    param(
        [int]$length = 1,
        $Debug = $false
    )
    
    # Passwort generieren
    $passwords = Generate-Password -length $length

    switch ($Debug) {
        $true { 
            foreach ($password in $passwords) {
            Write-Output $password
            } 
        }
        $false {  }
        Default { }
    }
    return $password
}

function Check-UPN {
    param (
        [string]$Name = $null,
        [string]$Surname = $null,
        [string]$Domain = "iseschool2013.onmicrosoft.com"
    )
    
    if ($Name -eq $null -or $Surname -eq $null) {
        $fehler = "fehler"
        return $fehler
    }

    $counter = 1
    $upnFound = $false

    do {
        $UPN = "$Name.$Surname$counter@$domain"
        
        try {
            Get-MgUser -UserId $UPN -ErrorAction Stop
            $counter++
        }
        catch {
            $upnFound = $true
        }
    } until ($upnFound)

    return $UPN
}

function Create-NewUser {
    param (
        $UserProps = $null,
        [string]$Name = $UserProps.Name,
        [string]$Surname = $UserProps.Surname,
        [string]$DisplayName = $UserProps.DisplayName,
        [string]$Domain = "iseschool2013.onmicrosoft.com",
        [string]$Department = $UserProps.Department, #Abteilung
        [string]$Office = $UserProps.Office, #Bürostandort
        [string]$JobTitle = $UserProps.JobTitle, #Position
        [string]$UsageLocation = "Switzerland",
        [bool]$AccountEnabled = $true
    )
    
    $UPN = Check-UPN -Name $Name -Surname $Surname -Domain $Domain

    $password = New-Password

    $SecurePassword = ConvertTo-SecureString $password -AsPlainText -Force

    New-MgUser `
        -UserPrincipalName $UPN `
        -GivenName $Name `
        -Surname $Surname `
        -DisplayName $DisplayName `
        -Mail $UPN `
        -Department $Department `
        -OfficeLocation $Office `
        -JobTitle $JobTitle `
        -UsageLocation $UsageLocation `
        -AccountEnabled $AccountEnabled `
        -PasswordProfile @{Password = $SecurePassword}

}

# Connection
Connect-MSG 

# Get UserProps of Camunda Form
$UserProps = Get-CamundaVars

# Creation New User
Create-NewUser -UserProps $UserProps


