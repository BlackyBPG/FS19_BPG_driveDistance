# FS19_BPG_driveDistance
Mit dem Mod DriveDistance wird allen motorisierten Fahrzeugen ein Kilometerzähler für gefahrene Distanzen hinzugefügt. Es wird ein Tageskilometerzähler (TRIP) angezeigt ebenso wie ein Gesamtkilometerzähler (TOTAL) welche auch im Spielstand gespeichert wird.

------------
Ab der Version 1.9.03 werden auch die DashboardKonfigurationen von LS19 unterstützt.
Die empfohlenen Einträge dafür sehen folgendermaßen aus: 

    <dashboard displayType="NUMBER" valueType="distanceTotal" numbers="numbersDistance" precision="0" groups="MOTOR_ACTIVE"/>


für die Tageskilometer: 

    <dashboard displayType="NUMBER" valueType="distanceTrip" numbers="numbersTrip" precision="2" groups="MOTOR_ACTIVE"/>

Die Anzahl Kommastellen bleibt natürlich euch überlassen, auch wie ihr die numbers benennt in eurer Fahrzeug-XML, wichtig dabei ist jedoch das sich die Einträge für die Dashboards in der entsprechenden Sektion im MOTORIZED Bereich eurer Fahrzeug-XML befinden.

------------
Ab Version 1.9.0.4:
- Der Tageskilometerzähler wird beim Tageswechsel wieder auf 0 gesetzt.
- zum ändern der horizontales Position der Tageskilometeranzeige im Script die Zeile 20 anpassen.
- - Angabe ist in Prozent (100% ist komplette Breite der Anzeige der Tageskilometer)
- - positive Werte verschieben die Anzeige nach rechts
- - negative Werte verschieben die Anzeige nach links

------------

![DriveDistance Ingame](https://github.com/BlackyBPG/FS19_BPG_driveDistance/blob/master/bpg_driveDistance.png "DriveDistance Ingame")  ![DriveDistance Ingame](https://github.com/BlackyBPG/FS19_BPG_driveDistance/blob/master/bpg_driveDistance%2BEVM.png "DriveDistance Ingame+EMV")

------------

------------

#### CHANGELOG:

- ##### Version 1.9.0.4 (01.12.2019)
- - add variance for trip distance display
- - reset trip distance after day change

- ##### Version 1.9.0.3 (25.11.2019)
- - add dashboard functionality
- - fix display calculation


- ##### Version 1.9.0.2 (23.11.2019)
- - correct display for total distance in use with TSX EnhancedVehicle mod
- - remove decimal for total distance
- - colorize decimal for trip distance


- ##### Version 1.9.0.1 (11.11.2019)
- - Initial Release for Fs19
