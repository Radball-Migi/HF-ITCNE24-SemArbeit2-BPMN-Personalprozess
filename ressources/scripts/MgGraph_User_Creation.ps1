#*******************************************************************#
# Script to Create a User with the Variables of the Camunda Form    #
#*******************************************************************#

# Camunda External Task Handler
# Erforderliche Parameter

$CamundaEndpoint = "http://localhost:8080/engine-rest" # Camunda REST API URL
$WorkerId = "powershell-worker"                        # Worker-ID
$TopicName = "SetStartUserCreation"                     # Topic-Name für den externen Task
$MaxTasks = 1                                          # Maximale Anzahl von Tasks
$LockDuration = 10000                                  # Lockdauer in Millisekunden
$FetchAndLockEndpoint = "$CamundaEndpoint/external-task/fetchAndLock"
$CompleteTaskEndpoint = "$CamundaEndpoint/external-task"


#Functions

# Logfunction for troubleshoot
function Write-Log {
    param (
        [string]$Message,
        [string]$LogStatus
    )

    switch ($LogStatus) {
        "Info" { Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): $Message" }
        "Error" {Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): $Message" -ForegroundColor Red}
        "Success" {Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): $Message" -ForegroundColor Green}
        Default { Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): $Message" }
    }  
}

# Funktion: Camunda Fetch and Lock
function Camunda-FetchAndLock-Task {
    Write-Log -Message "Starte FetchAndLock von Tasks..." -LogStatus "Info"
    $payload = @{
        workerId = $WorkerId
        maxTasks = $MaxTasks
        topics = @(
            @{
                topicName = $TopicName
                lockDuration = $LockDuration
            }
        )
    } | ConvertTo-Json -Depth 10

    $response = Invoke-RestMethod -Uri $FetchAndLockEndpoint -Method Post -ContentType "application/json" -Body $payload
    Write-Log -Message "FetchAndLock abgeschlossen." -LogStatus "Info"
    return $response
}

# Funktion: Task abschliessen
function Complete-Task {
    param ([string]$TaskId, [hashtable]$Variables)

    Write-Log -Message "Schließe Task ID: $TaskId ab..." -LogStatus "Info"
    $payload = @{
        workerId = $WorkerId
        variables = $Variables
    } | ConvertTo-Json -Depth 10

    $response = Invoke-RestMethod -Uri "$CompleteTaskEndpoint/$TaskId/complete" -Method Post -ContentType "application/json" -Body $payload
    Write-Log -Message "Task ID: $TaskId erfolgreich abgeschlossen." -LogStatus "Success"
    return $response
}

function Import-Login {
    Write-Log -Message "Importiere Login-Informationen..." -LogStatus "Info"
    $Logininfos = Get-Content -Path ".\Logininfos.json" | ConvertFrom-Json
    Write-Log -Message "Login-Informationen erfolgreich importiert." -LogStatus "Info"
    return $Logininfos
}

function Connect-MSG {
    param (
        [string]$Tenant = $null,
        [string]$TenantID = $null,
        [string]$ClientID = $null,
        [string]$Thumbprint = $null
    )

    Write-Log -Message "Verbindung mit Microsoft Graph wird hergestellt..." -LogStatus "Info"
    Connect-MgGraph -ClientId $ClientID -CertificateThumbprint $Thumbprint -TenantId $TenantID -NoWelcome
    Write-Log -Message "Verbindung mit Microsoft Graph erfolgreich hergestellt." -LogStatus "Success"
}

function Generate-Password {
    param (
        [int]$length = 1
    )

    Write-Log -Message "Generiere Passwort..." -LogStatus "Info"
    $words = "Bananen" , "Backofen" , "Schüssel" , "Computer" , "Rucksack" , "Teigling" , "Handtuch" , "Fernseh" , "Füller" , "Tische" , "Wanduhr" , "Zitronen" , "Erdbeere" , "Tomaten" , "Freiburg" , "Rümlang" , "Zermatt" , "Willisau" , "Aprikose" , "Pflaumen"
    $specialChars = "!", "$", "?", "%", "#", "&", "+", "." 
    $numbers = 0..9

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

                foreach ($key in $replaceTable.Keys) {
                    $word = $word -replace $key, $replaceTable[$key]
                }

                "$word$specialChar$number"
            }

            $password = -join $password
        } while ($passwords -contains $password)

        $passwords += $password
    }

    Write-Log -Message "Passwort erfolgreich generiert." -LogStatus "Success"
    return $passwords
}

function New-Password {
    param(
        [int]$length = 1,
        $Debug = $false
    )

    Write-Log -Message "Erstelle neues Passwort..." -LogStatus "Info"
    $passwords = Generate-Password -length $length

    switch ($Debug) {
        $true { 
            foreach ($password in $passwords) {
                Write-Output $password
            } 
        }
        $false { }
        Default { }
    }
    return $passwords
}

function Check-UPN {
    param (
        [string]$Name = $null,
        [string]$Surname = $null,
        [string]$Domain = "iseschool2013.onmicrosoft.com"
    )

    Write-Log -Message "Prüfe UPN..." -LogStatus "Info"
    if ($Name -eq $null -or $Surname -eq $null) {
        Write-Log -Message "Fehler: Name oder Nachname fehlt." -LogStatus "Error"
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

    Write-Log -Message "UPN gefunden: $UPN" -LogStatus "Success"
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

    Write-Log -Message "Erstelle neuen Benutzer..." -LogStatus "Info"
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

    Write-Log -Message "Benutzer $DisplayName mit UPN $UPN erfolgreich erstellt." -LogStatus "Success"
}

while ($true) {
    try {
        $Tasks = Camunda-FetchAndLock-Task
        if ($Tasks.Count -eq 0) {
            Write-Log -Message "Keine Tasks gefunden. Warte..." -LogStatus "Info"
            Start-Sleep -Seconds 5
            continue
        }

        foreach ($Task in $Tasks) {
            $TaskId = $Task.id

            Write-Log -Message "Verarbeite Task ID: $TaskId" -LogStatus "Info"

            # Get UserProps of Camunda Form
            $UserProps = $Task.variables

            # Get Login
            $Logininfos = Import-Login

            $Tenant = $Logininfos.Tenant
            $ClientID = $Logininfos.ClientID
            $Thumbprint = $Logininfos.Thumbprint

            # Connection
            Connect-MSG -Tenant $Tenant -ClientID $ClientID -Thumbprint $Thumbprint

            Write-Log -Message "Hole Benutzerinformationen von Camunda..." -LogStatus "Info"
            $UserProps = Get-CamundaVars

            # Creation New User
            Create-NewUser -UserProps $UserProps

            # Variablen für den Abschluss des Tasks
            $outputVariables = @{
                result = @{
                    value = $result
                    type = "Integer"
                }
            }

            Complete-Task -TaskId $taskId -Variables $outputVariables
            Write-Log -Message "Task ID: $taskId abgeschlossen." -LogStatus "Info"
        }
    } catch {
        Write-Log -Message "Fehler: $_" -LogStatus "Error"
        Start-Sleep -Seconds 5
    }
}
