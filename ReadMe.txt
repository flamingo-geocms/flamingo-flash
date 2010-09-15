Flamingo 3.0.0 (client)

Aanpassen bestaande installatie:
1. Verwijder het flamingo programmatuur mapje uit de applicatie boom (flamingo met subdirectory fmc en eventueel tpc).
2. Kopieer vervolgens de nieuwe flamingo programmatuur uit de oplevering in de applicatie boom (flamingo map uit de opleverings zip).
3. Wanneer er in de applicatie gebruik wordt gemaakt van zogenaamde tpc componenten pas de configuratie aan:
    a: verwijder de prefix attribuut (xmlns:tpc="tpc") uit de flamingo tag
    b: rename alle tpc tags naar fmc (<tpc ../> -> <fmc../>)    

De documentatie voor het configureren van de nieuwe functionaliteit is te vinden op de Flamingo website http://www.flamingo-mc.org)
Wanneer er in een applicatie gebruik wordt gemaakt van edit functionalteit moet het flash object worden geïnitialiseerd met behulp van de methoden uit authentication.js (addSWFObjectWithAuthentication of addSWFObject).


     