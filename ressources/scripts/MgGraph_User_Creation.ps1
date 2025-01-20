#*******************************************************************#
# Script to Create a User with the Variables of the Camunda Form    #
#*******************************************************************#

# Camunda External Task Handler
# Required parameters

$CamundaEndpoint = "http://localhost:8080/engine-rest" # Camunda REST API URL
$WorkerId = "powershell-worker"                        # Worker-ID
$TopicName = "SetStartUserCreation"                     # Topic name for the external task
$MaxTasks = 1                                          # Maximum number of tasks
$LockDuration = 10000                                  # Lock duration in milliseconds
$FetchAndLockEndpoint = "$CamundaEndpoint/external-task/fetchAndLock"
$CompleteTaskEndpoint = "$CamundaEndpoint/external-task"
$Demo = $true
$DemoInterval = 15 #Demo-Interval in Seconds
$Interval = if ($Demo) { $DemoInterval } else { 60 } # Interval evaluation in seconds

#############
# Functions #
#############

# Logfunction for troubleshoot
function Write-Log {
    param (
        [string]$Message,
        [string]$LogStatus
    )

    switch ($LogStatus) {
        "Info" { Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): $Message" }
        "Warning" { Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): $Message" -ForegroundColor Yellow }
        "Error" {Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): $Message" -ForegroundColor Red}
        "Success" {Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): $Message" -ForegroundColor Green}
        Default { Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): $Message" }
    }  
}

# Function: Camunda Fetch and Lock
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

# Function: Task abschliessen
function Complete-Task {
    param (
        [string]$TaskId,
        [hashtable]$Variables
    
    )

    Write-Log -Message "Schliesse Task ID: $TaskId ab..." -LogStatus "Info"
    $payload = @{
        workerId = $WorkerId
        variables = $Variables
    } | ConvertTo-Json -Depth 10

    $response = Invoke-RestMethod -Uri "$CompleteTaskEndpoint/$TaskId/complete" -Method Post -ContentType "application/json" -Body $payload
    Write-Log -Message "Task ID: $TaskId erfolgreich abgeschlossen." -LogStatus "Success"
    return $response
}

# Function: Import Login
function Import-Login {
    Write-Log -Message "Importiere Login-Informationen..." -LogStatus "Info"

    $TestPath = "/tmp/scripts/Logininfos_camundacontainer1.json"
    $PathCamundaContainer = "/tmp/scripts/Logininfos_camundacontainer.json"
    $PathLocal = "./Logininfos_local.json"
    

    if (Test-Path -Path $TestPath) {
        
        Write-Log -Message "Login-Informationen von Camunda-Server importieren" -LogStatus "Warning"
        $Logininfos = Get-Content -Path $PathCamundaContainer | ConvertFrom-Json

    }else {
       
        Write-Log -Message "Login-Informationen von Local importieren" -LogStatus "Warning"
        $Logininfos = Get-Content -Path $PathLocal | ConvertFrom-Json
        
    }
        
    Write-Log -Message "Login-Informationen erfolgreich importiert." -LogStatus "Success"
    return $Logininfos
}

# Function: Establishing a connection with Microsoft Graph
function Connect-MSG {
    param (
        [string]$Tenant = $null,
        [string]$TenantID = $null,
        [string]$ClientID = $null,
        [string]$Thumbprint = $null
    )

    Write-Log -Message "Verbindung mit Microsoft Graph wird hergestellt..." -LogStatus "Info"

    try {
        Connect-MgGraph -ClientId $ClientID -CertificateThumbprint $Thumbprint -TenantId $TenantID -NoWelcome -ErrorAction Stop
        Write-Log -Message "Verbindung mit Microsoft Graph erfolgreich" -LogStatus "success"
    }
    catch {
        Write-Log -Message "Verbindung mit Microsoft Graph fehlgeschlagen" -LogStatus "Error"
    }
}

# Function: Generate Password
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

# Function: New Password
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

# Function: Check UPN
function Check-UPN {
    param (
        [string]$Name = $null,
        [string]$Surname = $null,
        [string]$Domain = "iseschool2013.onmicrosoft.com"
    )

    Write-Log -Message "Prüfe UPN..." -LogStatus "Info"
    if ($Name -eq $null -or $Surname -eq $null) {
        Write-Log -Message "Fehler: Name oder Nachname fehlt." -LogStatus "Error"
        return "fehler"
    }

    $counter = 0
    $upnFound = $false

    do {
        if ($counter -eq 0) {
            # Basic UPN without counter
            $UPN = "$Name.$Surname@$Domain"
        } else {
            # UPN with counter
            $UPN = "$Name.$Surname$counter@$Domain"
        }

        try {
            # Check whether the UPN already exists
            Get-MgUser -UserId $UPN -ErrorAction Stop
            $counter++
        }
        catch {
            # UPN is available
            $upnFound = $true
        }
    } until ($upnFound)

    Write-Log -Message "UPN gefunden: $UPN" -LogStatus "Success"

    # Get the last UPN entry (UPN ist free to use)
    $CountOfUPNEntries = $UPN | Measure-Object
    $LastUPNEntry = $CountOfUPNEntries.Count - 1

    return $UPN
}


# Function: Create New User with MG Graph
function Create-NewUser {
    param (
        $UserProps = $null,
        $AccountEnabled = $true,
        [string]$Name = $UserProps.firstname.value,
        [string]$Surname = $UserProps.Surname.value,
        [string]$DisplayName = $Surname + ", " + $Name,
        [string]$Domain = "iseschool2013.onmicrosoft.com",
        [string]$Office = $UserProps.Office.value, # Abteilung
        [string]$DepartmentTeam = $UserProps.Department_Team.value, # Bürostandort_Team
        [string]$DepartmentStud = $UserProps.Department_Stud.value, # Bürostandort_Stud
        [string]$JobTitle = $UserProps.position.value, # Position
        [string]$UsageLocation = "CH",
        [string]$Manager = $UserProps.Manager.value
    )

    Write-Log -Message "Erstelle neuen Benutzer..." -LogStatus "Info"
    $UPN = Check-UPN -Name $Name -Surname $Surname -Domain $Domain

    # Get the last UPN entry (UPN ist free to use)
    $CountOfUPNEntries = $UPN | Measure-Object
    
    $UPN = `
        if ($CountOfUPNEntries.Count -eq 1) {

            $UPN

        }else {
            $LastUPNEntry = $CountOfUPNEntries.Count - 1
            $UPN[$LastUPNEntry]
            
        }
    
    $MailNickname = $UPN.split("@")[0]

    $password = New-Password

    $SecurePassword = ConvertTo-SecureString $password -AsPlainText -Force

    Write-Log -Message "Evaluiere Department" -LogStatus "Info"
    $Department = `
        switch ($DepartmentTeam) {
            "dev_application" { "Application development" }
            "m365_application" { "Application M365" }
            "eng_sys" { "Systemengineer" }
            "sup_sys" { "Systemengineer Support" }
            "stud" { switch ($DepartmentStud) {
                "application" { "Stud Application development" }
                "system" { "Stud Systemengineer / Support" }
                Default {""}
            } }
            Default {}
        }
        
    New-MgUser -UserPrincipalName $UPN -GivenName $Name -Surname $Surname -DisplayName $DisplayName -Mail $UPN -MailNickname $MailNickname -AccountEnabled -Department $Department -OfficeLocation $Office -JobTitle $JobTitle -UsageLocation $UsageLocation -PasswordProfile @{Password = $SecurePassword}

    Write-Log -Message "Benutzer $DisplayName mit UPN $UPN erfolgreich erstellt." -LogStatus "Success"

    return [PSCustomObject]@{
        UPN      = $UPN
        Password = $password
    }
}

# Function: Set Manager
function Set-Manager {
    param (
        [parameter (Mandatory = $true)]
        $UserProps = $null,
        [string]$Manager = $UserProps.Manager.value,
        [string]$UserId = $null
    )

    Write-Log -Message "Setze Manager..." -LogStatus "Info"

    Write-Log -Message "Evaluiere Manager" -LogStatus "Info"

    # Evaluate Manager
    $ManagerUPN = `
        switch ($Manager) {
            "rb" {"miguel.schneider@iseschool2013.onmicrosoft.com"}
            "dz" {"miguel.schneider@iseschool2013.onmicrosoft.com"}
            "fe" {"miguel.schneider@iseschool2013.onmicrosoft.com"}
            "dzw" {"miguel.schneider@iseschool2013.onmicrosoft.com"} 
            Default {}
        }
    
    # Retrieve manager
    try {
        $ManagerObject = Get-MgUser -UserId $ManagerUPN -ErrorAction Stop
        Write-Log -Message "Manager gefunden" -LogStatus "Info"
    }
    catch {
        Write-Log -Message "Manager nicht gefunden" -LogStatus "Error"
    }
    

    # Set manager attribute for the user
    try{
        Update-MgUser -UserId $UserId -Manager $ManagerObject -ErrorAction stop
        Write-Log -Message "Manager erfolgreich gesetzt" -LogStatus "Success"
    }
    catch {
        Write-Log -Message "Manager konnte nicht gesetzt werden" -LogStatus "Error"
    }
        
}

while ($true) {
    try {
        $Tasks = Camunda-FetchAndLock-Task
        if ($Tasks.Count -eq 0) {
            Write-Log -Message "Keine Tasks gefunden. Warte..." -LogStatus "Info"
            Start-Sleep -Seconds $Interval
            continue
        }

        foreach ($Task in $Tasks) {
            $TaskId = $Task.id

            Write-Log -Message "Verarbeite Task ID: $TaskId" -LogStatus "Info"

            
            #*****************************************************************************************************************************************************
            #-----------------------------------------------------------------------------------------------------------------------------------------------------
            # Task part that is executed per instance                                                                                                            ¦
            #-----------------------------------------------------------------------------------------------------------------------------------------------------

            # Get UserProps of Camunda Form
            Write-Log -Message "Hole Benutzerinformationen von Camunda..." -LogStatus "Info"
            $UserProps = $Task.variables

            $UserProps

            # Get Login
            $Logininfos = Import-Login

            $Tenant = $Logininfos.Tenant
            $ClientID = $Logininfos.ClientID
            $Thumbprint = $Logininfos.Thumbprint
            $TenantId = $Logininfos.TenantId

            # Connection
            Connect-MSG -Tenant $Tenant -ClientID $ClientID -Thumbprint $Thumbprint -TenantID $TenantId

            # Creation New User
            $result = Create-NewUser -UserProps $UserProps
            
            # Return Variables
            $UPN = $result.UPN
            $password = $result.Password

            # Whait for the User to be created
            Write-Log -Message "Warte 5 Minuten..." -LogStatus "Info"
            Start-Sleep -Seconds 180

            # Get User ID
            $CreatedUser = Get-MgUser -UserId $UPN
            $UserId = $CreatedUser.Id

            # Add User to M365-Licence-Group
            New-MgGroupMember -groupID "e430d7e5-79da-4008-8c35-b753ace1d2dc" -DirectoryObjectId $UserId # Group: misch-sem2arbeit-M365-Licence

            # Set Manager
            Set-Manager -UserProps $UserProps -UserId $UserId



            #****************************************************************************************************************************************************

            # Variables for the completion of the task
            $outputVariables = @{
                upn = @{
                    value = $UPN
                    type = "String"
                }
                userId = @{
                    value = $UserId
                    type = "String"
                }
                password = @{
                    value = $password
                    type = "String"
                }
            }

            Complete-Task -TaskId $taskId -Variables $outputVariables
            Write-Log -Message "Task ID: $taskId abgeschlossen." -LogStatus "Info"
        }
    } catch {
        Write-Log -Message "Fehler: $_" -LogStatus "Error"
        Start-Sleep -Seconds $Interval
    }
}
