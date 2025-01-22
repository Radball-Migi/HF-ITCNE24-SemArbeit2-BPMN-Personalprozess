---
layout: default
title: 4.3  Besprechung BPMN & Scripts 23.12.2024
parent: 4. Sprints
nav_order: 5
---

# Besprechung BPMN 23.12.2024

Besprechung mit Thomas betreffend Problemen mit BPMN
Nach Rückspreche mit Thomas, hatten wir für den 23.12.2024 einen Termin, um einige Probleme im BPMN miteinander anzuschauen. 
Wie ich auch bereits im [2. Sprint](./sprint2_13-12-2024.md) erwähnt habe, gab es Probleme:
- Starten des Prozesses über Camunda ging nicht.
- Probleme mit dem Form. 
- Prozessabfrage mit Script ging nicht. 

Beim Gespräch konnte mir Thomas gleich weiterhelfen. 
Meine Fehler waren, beim Starten des Prozesses, hatte ich den falschen Start hinterlegt. 
Der Fehler lag an der Art, wie der Prozess gestartet werden soll. 
Zuerst hatte ich beim Start, beim Mitarbeitenden, Zwischenereignis drin anstelle eines Startevents. 
Des weiteren musste ich einen Zusätzlichen Prozess erstellen, für das Camunda selbst. 
Der Eintrittsprozess ist aktuell noch vermehrt abhängig von der Geschäftsleitung, weshalb es vorher und nachher einige Tasks gibt, welche von ihnen ausgeführt werden. 
Für den Prozess, welcher Camunda ausführt, habe ich nun einen eigenen Prozess erstellt, welcher nur für die Erfassung des Benutzers ersichtlich ist. 
[Siehe auf der Seite "Verbessern (Improve) Phase"](../Hauptteil/34_verbessern.md). 

Beim Form gab es Probleme mit dem Datumsfeld, welches als Required hinterlegt wurde aber als ich Daten eingefügt habe, wurde mir ein Fehler angezeigt, dass ich das Feld ausfüllen soll. 
Als wir dann das Feld nicht Required hinterlegt haben, gab es den Fehler nicht aber auch wenn ich ein Datum hinterlege, wird die Variabel nicht abgefüllt. 

Thomas geht dem nach, weshalb es als Required den Fehler produziert. 

Beim Testen des Prozesses gab es zwei weitere Fehler, einerseits die MessageRefs und die Scriptstasks. 

Gegen die MessageRefs-Errors, haben wir die Ereignisse auf normale Zwischenerreignisse umgestellt.

Bei den Scripttasks hat mit Thomas erklärt, dass wir hier einen ServiceTask erstellen müssen, da leider bei Scripttasks das PowerShell nicht findet. 
Beim ServiceTask, hat er mir auf seinem Gitlab ein Beispiel gezeigt, wie ich den Task abfragen kann und so mein Script ausgelöst werden kann. 

Thomas hat mir heute sehr viel gezeigt, woraus ich nun weiter lernen und auch profitieren kann. 
Ich werde dies weiter in den Script berücksichtigen und am Ende wird es hoffentlich klappen. 
Für das Weitere vorherkommen, muss ich nun schauen, wie ich das PowerShell in den Camunda Container hinzufügen kann. 
Dies und das Datumsfeld, wird mich in den Weihnachtsferien auf trapp halten. 



