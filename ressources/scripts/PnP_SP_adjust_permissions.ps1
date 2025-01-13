#*******************************************************************#
# Script to adjust the Accessrights in SharePoint for the User      #
#*******************************************************************#

#*******************************************************************#
# Script to Create a User with the Variables of the Camunda Form    #
#*******************************************************************#

# Camunda External Task Handler
# Erforderliche Parameter

$CamundaEndpoint = "http://localhost:8080/engine-rest" # Camunda REST API URL
$WorkerId = "powershell-worker"                        # Worker-ID
$TopicName = "SetSPRights"                             # Topic-Name für den externen Task
$MaxTasks = 1                                          # Maximale Anzahl von Tasks
$LockDuration = 10000                                  # Lockdauer in Millisekunden
$FetchAndLockEndpoint = "$CamundaEndpoint/external-task/fetchAndLock"
$CompleteTaskEndpoint = "$CamundaEndpoint/external-task"
$SPMainSite = "https://iseschool2013.sharepoint.com/sites/misch-sem2arbeit/" # Main Site of the SharePoint


#Functions

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

    $TestPath = "/tmp/scripts/Logininfos_camundacontainer1.json" # Testpath for Request get false
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

function Connect-PnP {
    param (
        [string]$Tenant = $null,
        [string]$TenantID = $null,
        [string]$ClientID = $null,
        [string]$Thumbprint = $null,
        [string]$AdminUrl = $null
    )

    Write-Log -Message "Verbindung mit PnP Online wird hergestellt..." -LogStatus "Info"


    Connect-PnPOnline -Url $AdminUrl -ClientId $ClientID -Thumbprint $Thumbprint -NoWelcome

    Write-Log -Message "Verbindung mit "$AdminUrl" erfolgreich hergestellt." -LogStatus "Success"
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

            
            #*****************************************************************************************************************************************************
            #-----------------------------------------------------------------------------------------------------------------------------------------------------
            # Taskpart, welcher ausgeführt wird pro Instanz                                                                                                      ¦
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
            $AdminUrl = $Logininfos.TenantAdminUrl

            # Connection
            Connect-PnP -Tenant $Tenant -ClientID $ClientID -Thumbprint $Thumbprint -TenantID $TenantId

            
            

            #****************************************************************************************************************************************************

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
