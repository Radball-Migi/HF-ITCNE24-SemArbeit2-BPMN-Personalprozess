# Notizen zum Aufbau für Doku

Camunda Server API: [Camunda Platform REST API](http://localhost:8080/swaggerui/)


Befehl für neuen Docker Container mit vorhandenem Image:
```terminal
docker run -d --name ITCNE-SEMAR2-CAMSRV -p 8080:8080 camunda/camunda-bpm-platform:run-latest
```

Befehl für Image Erstellung aus einem vorhandenen Conatiner: 
```terminal
docker commit <Name des Containers> <Name des Images>
```

Befehl um ein Image zu Tagen:
```terminal
docker tag <Image ID> <Name des Tags/Images>
```

Output für Image erstellung
```Output
C:\Users\miguel.schneider>docker images -a
REPOSITORY                     TAG          IMAGE ID       CREATED        SIZE
camunda/camunda-bpm-platform   run-latest   83d68864ae30   2 months ago   338MB
camunda/camunda-bpm-platform   <none>       a4238897449b   8 months ago   331MB

C:\Users\miguel.schneider>docker ps -a
CONTAINER ID   IMAGE                                     COMMAND                  CREATED          STATUS                       PORTS     NAMES
838737585dbb   camunda/camunda-bpm-platform:run-latest   "/sbin/tini -- ./cam…"   28 minutes ago   Exited (143) 2 minutes ago             ITCNE-SEMAR2-CAMSRV
53ce828c4f3a   a4238897449b                              "/sbin/tini -- ./cam…"   3 months ago     Exited (143) 2 months ago              camundaV7

C:\Users\miguel.schneider>docker commit ITCNE-SEMAR2-CAMSRV
sha256:5fbce1d00ff488d28430d90db3d4651f8a4c5310ed7eba6b097e78b9eb7d5ee4

C:\Users\miguel.schneider>docker images -a
REPOSITORY                     TAG          IMAGE ID       CREATED          SIZE
<none>                         <none>       5fbce1d00ff4   27 seconds ago   339MB
camunda/camunda-bpm-platform   run-latest   83d68864ae30   2 months ago     338MB
camunda/camunda-bpm-platform   <none>       a4238897449b   8 months ago     331MB

C:\Users\miguel.schneider>docker tag 5fbce1d00ff4 img-camunda-srv-empty

C:\Users\miguel.schneider>docker images -a
REPOSITORY                     TAG          IMAGE ID       CREATED         SIZE
img-camunda-srv-empty          latest       5fbce1d00ff4   2 minutes ago   339MB
camunda/camunda-bpm-platform   run-latest   83d68864ae30   2 months ago    338MB
camunda/camunda-bpm-platform   <none>       a4238897449b   8 months ago    331MB

C:\Users\miguel.schneider>docker tag 5fbce1d00ff4 camunda/img-camunda-srv-empty

C:\Users\miguel.schneider>docker images -a
REPOSITORY                      TAG          IMAGE ID       CREATED         SIZE
camunda/img-camunda-srv-empty   latest       5fbce1d00ff4   2 minutes ago   339MB
img-camunda-srv-empty           latest       5fbce1d00ff4   2 minutes ago   339MB
camunda/camunda-bpm-platform    run-latest   83d68864ae30   2 months ago    338MB
camunda/camunda-bpm-platform    <none>       a4238897449b   8 months ago    331MB

C:\Users\miguel.schneider>docker images -a
REPOSITORY                      TAG          IMAGE ID       CREATED         SIZE
camunda/img-camunda-srv-empty   latest       5fbce1d00ff4   3 minutes ago   339MB
camunda/camunda-bpm-platform    run-latest   83d68864ae30   2 months ago    338MB
camunda/camunda-bpm-platform    <none>       a4238897449b   8 months ago    331MB


C:\Users\miguel.schneider>docker ps -a
CONTAINER ID   IMAGE          COMMAND                  CREATED        STATUS                        PORTS     NAMES
53ce828c4f3a   a4238897449b   "/sbin/tini -- ./cam…"   3 months ago   Exited (143) 12 minutes ago             camundaV7

C:\Users\miguel.schneider>docker rename camundaV7 ITCNE-SEMAR2-CAMSRV

C:\Users\miguel.schneider>docker commit camundaV7 img-camundasrv-empty
Error response from daemon: No such container: camundaV7

C:\Users\miguel.schneider>docker commit ITCNE-SEMAR2-CAMSRV img-camundasrv-empty
sha256:d1ef8747ce19df000e2a66eead370d1a25370a772dd06b01a2347d3557b93f5c

C:\Users\miguel.schneider>docker images -a
REPOSITORY                      TAG          IMAGE ID       CREATED          SIZE
img-camundasrv-empty            latest       d1ef8747ce19   7 seconds ago    339MB
camunda/img-camunda-srv-empty   latest       5fbce1d00ff4   27 minutes ago   339MB
camunda/camunda-bpm-platform    run-latest   83d68864ae30   2 months ago     338MB
camunda/camunda-bpm-platform    <none>       a4238897449b   8 months ago     331MB

C:\Users\miguel.schneider>docker run -d --name Test-ITCNE-SEMAR2-CAMSRV -p 8080:8080 img-camundasrv-empty:latest
ccf897a622f8dd0076383c78c98011ee9f4721f0b9db61b28ad5e41421a8369d
docker: Error response from daemon: driver failed programming external connectivity on endpoint Test-ITCNE-SEMAR2-CAMSRV (8c9060491ec3d9fb433e07afd51bef0bfa8b485b89bd5bc0268540f980422815): Bind for 0.0.0.0:8080 failed: port is already allocated.

C:\Users\miguel.schneider>docker run -d --name Test-ITCNE-SEMAR2-CAMSRV -p 8080:8080 img-camundasrv-empty:latest
docker: Error response from daemon: Conflict. The container name "/Test-ITCNE-SEMAR2-CAMSRV" is already in use by container "ccf897a622f8dd0076383c78c98011ee9f4721f0b9db61b28ad5e41421a8369d". You have to remove (or rename) that container to be able to reuse that name.
See 'docker run --help'.

C:\Users\miguel.schneider>docker commit Test-ITCNE-SEMAR2-CAMSRV camunda/img-semar2-camsrv-empty
sha256:a2346eb9121c88a35733dd2c0e3406a041436139a016fc93c20d78d6436bf133

C:\Users\miguel.schneider>docker images -a
REPOSITORY                        TAG          IMAGE ID       CREATED          SIZE
camunda/img-semar2-camsrv-empty   latest       a2346eb9121c   11 seconds ago   347MB
img-camundasrv-empty              latest       d1ef8747ce19   8 minutes ago    339MB
camunda/img-camunda-srv-empty     latest       5fbce1d00ff4   35 minutes ago   339MB
camunda/camunda-bpm-platform      run-latest   83d68864ae30   2 months ago     338MB
camunda/camunda-bpm-platform      <none>       a4238897449b   8 months ago     331MB

C:\Users\miguel.schneider>docker ps -a
CONTAINER ID   IMAGE          COMMAND                  CREATED        STATUS                        PORTS     NAMES
53ce828c4f3a   a4238897449b   "/sbin/tini -- ./cam…"   3 months ago   Exited (143) 12 minutes ago             camundaV7

C:\Users\miguel.schneider>docker rename camundaV7 ITCNE-SEMAR2-CAMSRV

C:\Users\miguel.schneider>docker commit camundaV7 img-camundasrv-empty
Error response from daemon: No such container: camundaV7

C:\Users\miguel.schneider>docker commit ITCNE-SEMAR2-CAMSRV img-camundasrv-empty
sha256:d1ef8747ce19df000e2a66eead370d1a25370a772dd06b01a2347d3557b93f5c

C:\Users\miguel.schneider>docker images -a
REPOSITORY                      TAG          IMAGE ID       CREATED          SIZE
img-camundasrv-empty            latest       d1ef8747ce19   7 seconds ago    339MB
camunda/img-camunda-srv-empty   latest       5fbce1d00ff4   27 minutes ago   339MB
camunda/camunda-bpm-platform    run-latest   83d68864ae30   2 months ago     338MB
camunda/camunda-bpm-platform    <none>       a4238897449b   8 months ago     331MB

C:\Users\miguel.schneider>docker run -d --name Test-ITCNE-SEMAR2-CAMSRV -p 8080:8080 img-camundasrv-empty:latest
ccf897a622f8dd0076383c78c98011ee9f4721f0b9db61b28ad5e41421a8369d
docker: Error response from daemon: driver failed programming external connectivity on endpoint Test-ITCNE-SEMAR2-CAMSRV (8c9060491ec3d9fb433e07afd51bef0bfa8b485b89bd5bc0268540f980422815): Bind for 0.0.0.0:8080 failed: port is already allocated.

C:\Users\miguel.schneider>docker run -d --name Test-ITCNE-SEMAR2-CAMSRV -p 8080:8080 img-camundasrv-empty:latest
docker: Error response from daemon: Conflict. The container name "/Test-ITCNE-SEMAR2-CAMSRV" is already in use by container "ccf897a622f8dd0076383c78c98011ee9f4721f0b9db61b28ad5e41421a8369d". You have to remove (or rename) that container to be able to reuse that name.
See 'docker run --help'.

C:\Users\miguel.schneider>docker commit Test-ITCNE-SEMAR2-CAMSRV camunda/img-semar2-camsrv-empty
sha256:a2346eb9121c88a35733dd2c0e3406a041436139a016fc93c20d78d6436bf133

C:\Users\miguel.schneider>docker images -a
REPOSITORY                        TAG          IMAGE ID       CREATED          SIZE
camunda/img-semar2-camsrv-empty   latest       a2346eb9121c   11 seconds ago   347MB
img-camundasrv-empty              latest       d1ef8747ce19   8 minutes ago    339MB
camunda/img-camunda-srv-empty     latest       5fbce1d00ff4   35 minutes ago   339MB
camunda/camunda-bpm-platform      run-latest   83d68864ae30   2 months ago     338MB
camunda/camunda-bpm-platform      <none>       a4238897449b   8 months ago     331MB

```




## Registrierung der EntraID Application

```Output
PS C:\Users\miguel.schneider> register-PnPEntraIDApp -ApplicationName "PnP and MG Graph for Semarb2 misch" -Tenant iseschool2013.onmicrosoft.com -Interactive
WARNING:
 No permissions specified, using default permissions


Checking if application 'PnP and MG Graph for Semarb2 misch' does not exist yet...Success. Application 'PnP and MG Graph for Semarb2 misch' can be registered.
App PnP and MG Graph for Semarb2 misch with id 058839a7-a056-47ad-8bf9-f56f230c6207 created.

Pfx file               : C:\Users\miguel.schneider\PnP and MG Graph for Semarb2 misch.pfx
Cer file               : C:\Users\miguel.schneider\PnP and MG Graph for Semarb2 misch.cer
AzureAppId/ClientId    : 058839a7-a056-47ad-8bf9-f56f230c6207

```

Instll der Module: 

```PowerShell
# PowerShell-Skript zum Herunterladen, Installieren und Importieren der benötigten Microsoft Graph Module auf CAmunda docker container

# Modul-Installationsfunktion
function Install-GraphModule {
    param (
        [string]$ModuleName
    )
    try {
        Write-Host "Installing module: $ModuleName"
        Install-Module -Name $ModuleName -Scope CurrentUser -Force -AllowClobber
        Write-Host "Successfully installed module: $ModuleName"
    } catch {
        Write-Host "Failed to install module: $ModuleName"
        Write-Host $_.Exception.Message
    }
}

# Benötigte Module
$modules = @(
    "Microsoft.Graph.Authentication",
    "Microsoft.Graph.Users",
    "Microsoft.Graph.Groups"
)

# Module installieren
foreach ($module in $modules) {
    Install-GraphModule -ModuleName $module
}

# Module importieren
foreach ($module in $modules) {
    try {
        Write-Host "Importing module: $module"
        Import-Module $module -Force -ErrorAction Stop
        Write-Host "Successfully imported module: $module"
    } catch {
        Write-Host "Failed to import module: $module"
        Write-Host $_.Exception.Message
    }
}

# Verbindung zu Microsoft Graph herstellen
try {
    Write-Host "Connecting to Microsoft Graph"
    Connect-MgGraph -Scopes "User.ReadWrite.All", "Group.ReadWrite.All"
    Write-Host "Successfully connected to Microsoft Graph"
} catch {
    Write-Host "Failed to connect to Microsoft Graph"
    Write-Host $_.Exception.Message
}
```

Kopieren einer DAte vom Lokalen Comupter zu einem Docker Container

```Terminal
docker cp "C:\Users\miguel.schneider\OneDrive - TBZ\GitHub_Repos_HF\HF-ITCNE24-SemArbeit2-BPMN-Personalprozess\ressources\scripts\MgGraph_User_Creation.ps1" c3df7a5aad77693a30eba71db575749b220b276ff37f004658cc96f7de58f1bf:/tmp/scripts
```

```Output
Successfully copied 10.8kB to c3df7a5aad77693a30eba71db575749b220b276ff37f004658cc96f7de58f1bf:/tmp/scripts
```

Installation von openssl (History auszug)

```Terminal
  15 chmod u+s /bin/su
  16 apk update
  17 apk add oppenssl
  18 apk add curl wget
  19 apk add oppenssl
  20 apk update
  21 apk upgrade
  22 apk add openssl
```

Adminconnection auf Docker Container als Root:

```Terminal
docker exec -it --user root <Container Name> /bin/sh
```
