#*******************************************************************#
# Script to adjust the Accessrights in SharePoint for the User      #
#*******************************************************************#



# Camunda External Task Handler
# Required parameters

$CamundaEndpoint = "http://localhost:8080/engine-rest" # Camunda REST API URL
$WorkerId = "powershell-worker"                        # Worker-ID
$TopicName = "SetSPRights"                             # Topic name for the external task
$MaxTasks = 1                                          # Maximum number of tasks
$LockDuration = 10000                                  # Lock duration in milliseconds
$FetchAndLockEndpoint = "$CamundaEndpoint/external-task/fetchAndLock"
$CompleteTaskEndpoint = "$CamundaEndpoint/external-task"
$Demo = $true
$DemoInterval = 15 # Demo-Interval in Seconds
$Interval = if ($Demo) { $DemoInterval } else { 60 } # Interval evaluation in seconds


# Functions

# Logfunction for troubleshoot
function Write-Log {
    param (
        [string]$Message,
        [string]$LogStatus
    )

    # Define log directory and file
    $LogDirectory = "C:\temp\Personaleintrittsprozess\logs"
    $LogFile = "$LogDirectory\sp_rights_customize-$(Get-Date -Format 'yyyy-MM-dd').log"

    # Ensure that the log directory exists
    if (-not (Test-Path -Path $LogDirectory)) {
        New-Item -ItemType Directory -Path $LogDirectory -Force | Out-Null
    }

    # Check and add title area if the file is newly created
    if (-not (Test-Path -Path $LogFile)) {
        $ScriptTitle = "MgGraph_SP_adjust_permissions.ps1" # Skripttitle
        $CurrentDate = Get-Date -Format 'yyyy-MM-dd'
        $FullTitle = "$ScriptTitle    -    $CurrentDate"
        $Separator = "*" * $FullTitle.Length
        $TitleBlock = "$Separator`n$FullTitle`n$Separator`n"
        Set-Content -Path $LogFile -Value $TitleBlock
    }

    # Create timestamp
    $TimeStamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

    # Format log message
    $LogEntry = $TimeStamp + ": " + $Message

    # Write log entry in the console
    switch ($LogStatus) {
        "Info" { Write-Host $LogEntry }
        "Warning" { Write-Host $LogEntry -ForegroundColor Yellow }
        "Error" { Write-Host $LogEntry -ForegroundColor Red }
        "Success" { Write-Host $LogEntry -ForegroundColor Green }
        Default { Write-Host $LogEntry }
    }

    # Write log entry to the log-file
    try {
        Add-Content -Path $LogFile -Value $LogEntry
    } catch {
        Write-Host "Fehler beim Schreiben des Logeintrags in die Datei: $_" -ForegroundColor Red
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

    $TestPath = "/tmp/scripts/Logininfos_camundacontainer1.json" # Written incorrectly so that it is not found, since script is currently running locally but later in the container
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

function Connect-MSG {
    param (
        [string]$Tenant = $null,
        [string]$TenantID = $null,
        [string]$ClientID = $null,
        [string]$Thumbprint = $null
    )

    Write-Log -Message "Verbindung mit Microsoft Graph wird hergestellt..." -LogStatus "Info"


    Connect-MgGraph -ClientId $ClientID -CertificateThumbprint $Thumbprint -TenantId $TenantID -NoWelcome

}

function Set-SPRights {
    param (
        [array]$Roles = $null,
        [string]$UserId = $null
    )

    # SharePoint-Groups
    $SP_Admin = "e8dbd8f4-8dca-4b56-b7b0-de6fe71120d4"
    $SP_VR = "2cc0f395-da9f-419b-b61f-85d0bde45a31"
    $SP_GL = "b1e1236f-6044-4ae2-b2bc-e94fd463c555"
    $SP_Lernende = "2d274883-44a9-4081-a1a7-2896ff5f4149"
    $SP_MA = "436d4133-b34a-47a2-8ccf-243655015244"
    $SP_SP = "8f14f1cf-6231-4c9d-a47a-f85a2b59392e"
    $SP_SB = "c050fb50-9ed2-4b18-bdc3-1d6d1425a65c"
    
    # Set Rights foreach Role
    foreach ($Role in $Roles) {
        
        Write-Log -Message "Setze Rechte für Rolle: $Role" -LogStatus "Info"

        switch ($Role) {
            "vr" { 
                try {
                    New-MgGroupMember -groupID $SP_VR -DirectoryObjectId $UserId -ErrorAction Stop # Group: misch-sem2arbeit-SP-VR
                    Write-Log -Message "Rechte für vr gesetzt." -LogStatus "Success"
                } catch {
                    Write-Log -Message "Error beim Setzen der Rechte für vr." -LogStatus "Error"
                }
            }
        
            "gl" { 
                try {
                    New-MgGroupMember -groupID $SP_Admin -DirectoryObjectId $UserId -ErrorAction Stop # Group: misch-sem2arbeit-SP-Admin
                    New-MgGroupMember -groupID $SP_GL -DirectoryObjectId $UserId -ErrorAction Stop # Group: misch-sem2arbeit-SP-GL
                    Write-Log -Message "Rechte für gl gesetzt." -LogStatus "Success"
                } catch {
                    Write-Log -Message "Error beim Setzen der Rechte für gl." -LogStatus "Error"
                }
            }
        
            "stud" {
                try {
                    New-MgGroupMember -groupID $SP_Lernende -DirectoryObjectId $UserId -ErrorAction Stop # Group: misch-sem2arbeit-SP-Lernende
                    Write-Log -Message "Rechte für stud gesetzt." -LogStatus "Success"
                } catch {
                    Write-Log -Message "Error beim Setzen der Rechte für stud." -LogStatus "Error"
                }
            }
        
            "ma" {
                try {
                    New-MgGroupMember -groupID $SP_MA -DirectoryObjectId $UserId -ErrorAction Stop # Group: misch-sem2arbeit-SP-MA
                    Write-Log -Message "Rechte für ma gesetzt." -LogStatus "Success"
                } catch {
                    Write-Log -Message "Error beim Setzen der Rechte für ma." -LogStatus "Error"
                }
            }
        
            "sp" {
                try {
                    New-MgGroupMember -groupID $SP_SP -DirectoryObjectId $UserId -ErrorAction Stop # Group: misch-sem2arbeit-SP-Schluesselpersonen
                    Write-Log -Message "Rechte für sp gesetzt." -LogStatus "Success"
                } catch {
                    Write-Log -Message "Error beim Setzen der Rechte für sp." -LogStatus "Error"
                }
            }
        
            "sb" {
                try {
                    New-MgGroupMember -groupID $SP_SB -DirectoryObjectId $UserId -ErrorAction Stop # Group: misch-sem2arbeit-SP-Sachbearbeitung
                    Write-Log -Message "Rechte für sb gesetzt." -LogStatus "Success"
                } catch {
                    Write-Log -Message "Error beim Setzen der Rechte für sb." -LogStatus "Error"
                }
            }
        
            Default {

                Write-Log -Message "Unbekannte Rolle: $Role" -LogStatus "Error"
            }
        }
    }
    
}

# Function to convert Camunda Roles
function Convert-CamundaRoles {
    param (
        [string]$RawRoles = $null
    )
    
    # Remove the square brackets and create a PowerShell array
    $ConvertedRoles = @($RawRoles -replace '\[|\]', '' -replace '"', '' -split ',')
    
    return $ConvertedRoles
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
            # Task part that is executed per instance                                                                                                      ¦
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

            # Convert Roles from Camunda
            $Roles = Convert-CamundaRoles -RawRoles $UserProps.roles.value
            
            # Set Rights
            Set-SPRights -Roles $Roles -UserId $UserProps.userId.value



            

            #****************************************************************************************************************************************************

            # Variables for the completion of the task
            $outputVariables = @{}

            Complete-Task -TaskId $taskId -Variables $outputVariables
            Write-Log -Message "Task ID: $taskId abgeschlossen." -LogStatus "Info"
        }
    } catch {
        Write-Log -Message "Fehler: $_" -LogStatus "Error"
        Start-Sleep -Seconds $Interval
    }
}
