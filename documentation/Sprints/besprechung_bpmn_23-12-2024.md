---
layout: default
title: 4.3  Besprechung BPMN & Scripts 23.12.2024
parent: 4. Sprints
nav_order: 5
---

## Besprechung BPMN 23.12.2024

Am 23.12.2024 hatte ich eine Besprechung mit Thomas, um Probleme im Zusammenhang mit BPMN zu klären. Wie ich bereits im [2. Sprint](./sprint2_13-12-2024.md) erwähnt hatte, gab es einige Schwierigkeiten, die gelöst werden mussten:

1. Der Prozess liess sich über Camunda nicht starten.
2. Es traten Probleme mit dem Formular auf.
3. Die Prozessabfrage über ein Script funktionierte nicht.

### Problemlösungen im Gespräch

#### Start des Prozesses

Thomas konnte mir beim Startproblem direkt helfen. Der Fehler lag daran, dass ich das falsche Startereignis hinterlegt hatte. Anstatt eines Startevents hatte ich ein Zwischenergebnis für Mitarbeitende gesetzt. Zudem musste ich für Camunda einen zusätzlichen Prozess erstellen, der ausschliesslich für das System selbst bestimmt ist.

Ein weiterer Punkt war die Abhängigkeit des Eintrittsprozesses von der Geschäftsleitung. Es gibt mehrere Tasks, die vor und nach dem Prozess von der Geschäftsleitung ausgeführt werden. Um dies besser zu strukturieren, habe ich einen separaten Prozess erstellt, der lediglich für die Erfassung des Benutzers sichtbar ist. Details dazu sind auf der Seite [„Verbessern (Improve) Phase“](../Hauptteil/35_verbessern.md) dokumentiert.

#### Formularprobleme

Das Formular hatte Probleme mit einem Datumsfeld, das als Pflichtfeld (`required`) definiert war. Obwohl ich Daten in das Feld eingab, erhielt ich die Fehlermeldung, dass das Feld ausgefüllt werden müsse. Nachdem wir das Pflichtfeld-Attribut entfernt hatten, trat der Fehler nicht mehr auf, allerdings wurde die Variable weiterhin nicht korrekt befüllt, selbst wenn ich ein Datum eingab.

Thomas untersucht nun, warum das Datumsfeld bei Aktivierung des Pflichtfelds diesen Fehler produziert.

#### Fehler beim Testen des Prozesses

Beim Testen des Prozesses stiessen wir auf zwei weitere Probleme:

1. **MessageRefs-Fehler:**  
    Hier lag der Fehler in den MessageRefs-Ereignissen. Um dieses Problem zu beheben, haben wir die Ereignisse auf normale Zwischenereignisse umgestellt.
    
2. **ScriptTasks:**  
    Bei den ScriptTasks gab es das Problem, dass PowerShell nicht korrekt gefunden wurde. Thomas erklärte mir, dass ich stattdessen ServiceTasks verwenden sollte. Er zeigte mir ein Beispiel auf seinem GitLab, wie ich den Task abfragen und damit das Script korrekt auslösen kann.
    

### Fazit und Ausblick

Thomas hat mir in dieser Besprechung viele wertvolle Einblicke gegeben, aus denen ich nun weiter lernen und profitieren kann. Ich werde diese Erkenntnisse in meinen Scripten berücksichtigen und hoffe, dass ich am Ende eine funktionierende Lösung entwickeln kann.

Als Nächstes muss ich mich darum kümmern, wie ich PowerShell in den Camunda-Container integrieren kann. Zusätzlich werde ich weiterhin an der Lösung für das Datumsfeld arbeiten. Diese Aufgaben werden mich während der Weihnachtsferien auf Trab halten, aber ich bin zuversichtlich, dass ich gute Fortschritte machen werde.
