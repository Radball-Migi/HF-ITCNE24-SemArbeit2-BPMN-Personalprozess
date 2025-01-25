---
layout: default
title: 3.5 Kontrollieren
parent: 3. Hauptteil
nav_order: 8
---
#  Kontrollieren (Control) Phase

Die Control-Phase ist der fünfte und letzte Schritt in einem Six Sigma Projekt. In dieser Phase werden die in der Improve-Phase implementierten Lösungen überwacht und kontrolliert, um sicherzustellen, dass die Verbesserungen nachhaltig sind und die Prozessleistung stabil bleibt. Ziel ist es, die erzielten Verbesserungen zu standardisieren und in den täglichen Betrieb zu integrieren.

![control](../../ressources/images/control.png)
[Quelle](../Quellverzeichnis/index.md#control-phase) 


Die **Control-Phase** erstreckt sich über einen längeren Zeitraum und hat das Ziel, den angepassten Prozess kontinuierlich auf seine Nachhaltigkeit und mögliche Optimierungspotenziale zu prüfen. In dieser Phase wird sichergestellt, dass der implementierte Prozess stabil läuft und langfristig die gewünschten Ergebnisse liefert.

Allerdings wird es noch eine Weile dauern, bis Camunda den derzeitigen Personaleintrittsprozess der ISEAG vollständig ersetzen kann. Da die Semesterarbeit zeitlich begrenzt ist, habe ich nicht die Möglichkeit, umfassende Langzeitstudien zu meinem Prozess durchzuführen oder dessen langfristige Auswirkungen zu dokumentieren.

Trotzdem habe ich bereits während der [**Improve-Phase**](./34_verbessern.md) kontinuierlich Tests durchgeführt, um sicherzustellen, dass der Prozess in Camunda reibungslos läuft, korrekt durchlaufen wird und erfolgreich abgeschlossen werden kann. Diese Tests bieten zwar keine langfristige Perspektive, bestätigen jedoch die grundsätzliche Funktionalität und Stabilität der neuen Lösung.

## Testing

Für das Testing habe ich verschiedene Szenarien durchgespielt, die in der Praxis auftreten könnten, um die Funktionsfähigkeit des Prozesses sicherzustellen. 
Um das Testing grob zusammen zufassen, habe ich untenstehend eine Tabelle für das Testing erstellt. Mit einer Testingtabelle:

### Testmatrix

| **Test-ID** | **Was wird getestet?**                                                              | **Zweck / Ziel**                                                                                                                  | **Erwartetes Ergebnis**                                                               | **Effektives Ergebnis** | **Dokumentation / Link**          |
| ----------- | ----------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------- | ----------------------- | --------------------------------- |
| T01         | Erfassung neuer Mitarbeiter via HTML-Formular                                       | Wird beim Absenden  des Forms alles via API mit gesendet                                                                          | Beim absenden des Formulars erscheint die Meldung erfolgreich                         |                         | [Dokumentation](#)                |
| T02         | Datenübertragung und Start der Prozessinstanz                                       | Prozessinstanz wird gestartet und die Daten aus dem Formular an den Prozess übergeben                                             | Prozessinstanz wird gestartet und Variablen sind sichtbar in den Tasks                |                         | [Dokumentation](#)                |
| T03         | Übernahme der Tasks und Bestätigung des Genehmigungsantrags                         | Taskübernahme und Exckusive Gateway funktioniert                                                                                  | Task kann übernommen und bearbeitet werden.<br>Nach annahme wird das Signal versendet |                         | [Dokumentation](#)                |
| T04         | Benutzer erstellung wird gestartet und läuft erfolgreich durch. Dauer ca. 5-10 min. | Benutzer wird erstellt, mit Department und Managerzuweisung.<br>Zusätzlich wird der Benutzer auch in die Lizenzgruppe hinzugefügt | Benutzer wird erstellt, in den Properties sind auch Department und Manager zugewiesen |                         | [Dokumentation](#)                |
| T05         | Gruppenzuweisung funktioniert via Script                                            | Zuvor erstellter Benutzer wird den Entra-ID-Gruppen hinzugefügt, anhand der Rollenzuweisung.                                      | Benutzer wird in die Entra-ID-Gruppen hinzugefügt                                     |                         | [Dokumentation](#)                |
| T06         | Time intermidiate Event                                                             | Der Zwischenevent triggert erst wenn das Datum erreicht wird, welches zuvor im Formular eingegeben wurde.                         | Datumsvalue ist im Event drin.                                                        |                         |                                   |
| T07         | Logs                                                                                | Werden die Logs im besagten Pfad erstellt?                                                                                        | Logs werden im Pfad `C:\temp\PErsonaleintritt` erstellt                               |                         | [Logs]()                          |
| T08         | Camunda Server                                                                      | Existiert und funktioniert der Container                                                                                          | Ist der Container vorhanden und läuft dieser auch.                                    |                         | [Camunda Server](#camunda-server) |

**Hinweise**
- **Test-ID:** Eine eindeutige Kennung, um die Tests zu identifizieren und sie einfacher referenzieren zu können.
- **Dokumentation / Link:** Verlinkt direkt zur Dokumentation, spezifischen BPMN-Diagrammen oder zugehörigen Bereichen im Repository.
- Diese Matrix soll sicherstellen, dass alle relevanten Bereiche des Personalprozesses systematisch getestet und dokumentiert werden.


### Camunda

Mithilfe von Camunda konnte ich die BPMN Prozesse aufzeichnen, technisch nutzen und mittels Server eine vollfunktionsfähige Lösung bereitstellen. 

Mithilfe des Camunda Cockpits konnte ich den Status der Prozessinstanzen grafisch nachverfolgen. Dieses Tool ermöglicht es, den Ablauf im Detail zu überprüfen und sicherzustellen, dass sich der Prozess an der richtigen Stelle im Workflow befindet.

#### Camunda Server
Den Camunda Server habe ich aktuell auf einem Docker Container, auf meinem Lokalen Notebook am Laufen. 
Für den ersten Moment ist dies in Ordnung, jedoch ist dies ausbaufähig, damit dieser in Zukunft auch auf Azure laufen würde. 

Der Camunda-Server wurde anhand einem Image erstellt, welches wir auch bereits im Unterricht verwendet haben. mit der bereits eingerichteten API, habe ich ein Image erstellt, welches ich dann für die Semesterarbeit verwenden konnte.

![Image Camunda Server](../../ressources/images/image_camunda_server_on_docker.png)

Mit diesem Image und nachfolgenden Befehl, können wir innerhalb von 10-15 Sekunden einen neuen Container erstellen. 

```Terminal
docker run -d --name ITCNE-SEMAR2-CAMSRV -p 8080:8080 camunda/camunda-bpm-platform:run-latest
```

So entsteht dann dieser Container.

![Camunda Server Container](../../ressources/images/camunda_server_on_docker.png)

### Logs

Damit wir die Fehler im System während dem Betrieb erkennen können, haben wir während der Asuführung ein Log, welches erstellt wird. 
Der Speicherort ist ein ORdner, im `C:\temp`. 
Die Files lauten:
- `.\Personaleintritt\user_creation-2025-01-24.log` 
- `.\Personaleintritt\sp_rights_customize-2025-01-24.log`

![Logs](../../ressources/images/logfiles.png)

### Scripts

Die Scripts wurden mit PowerShell geschrieben und enthalten teilweise auch Python ausschnitte. 
Beim Script wurde alles kommentiert, damit jeder versteht, für was, was steht. 
Wie bereits in der [Control Phase](./34_verbessern.md) erwähnt, werden die Skripte derzeit lokal auf dem Notebook ausgeführt, da es Probleme mit der Zertifikatsanmeldung am Camunda-Server gab. Um keine unnötige Zeit mit der Behebung dieses Problems zu verlieren, habe ich mich entschieden, die Skripte vorerst lokal zu starten. Sobald die Zertifikatsanmeldung gelöst ist, werde ich die Skripte entsprechend integrieren und anpassen.

Das entsprechende Script kann unter folgendem Link eingesehen werden:
- [MgGraph_User_Creation.ps1](https://github.com/Radball-Migi/HF-ITCNE24-SemArbeit2-BPMN-Personalprozess/blob/main/ressources/scripts/MgGraph_User_Creation.ps1)
- [MgGraph_SP_adjust_permissions.ps1](https://github.com/Radball-Migi/HF-ITCNE24-SemArbeit2-BPMN-Personalprozess/blob/main/ressources/scripts/MgGraph_SP_adjust_permissions.ps1)

