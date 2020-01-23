# code-sankey
R-code om een sankeydiagram van de landgebruiksveranderingen te maken

## Doel

Sankey diagram maken voor visualisatie landgebruiksveranderingen. De oefendataset is vervangen door de data van de landgebruiksveranderingen in de Corine-kaarten (1990-2018).

## Methode

### Data uit ArcGIS

De landgebruiksveranderingen in de Corine-kaarten van 1990 en 2018 worden geïdentificeerd met de Combine-tool. Het resultaat is een tabel (**clc_1990_2018**) met de volgende kolommen: 
* `count`: aantal cellen (10 x 10 m) van een landgebruiksveranderingsklasse (c1990 x c2018)
* `c1990`: code van landgebruik in 1990
* `c2018`: code van landgebruik in 2018

Een aparte tabel (**clc_1990_2018_code**) bevat de vertaalsleutel voor de omzetting van de Corine-klassen naar de landgebruiksklassen van NARA (5 of 10 klassen). Voor de uitwerking van de code gebruiken we de versie met de 5 klassen. De tabel bevat de volgende kolommen:
* `clc_code`: Corine code
* `clc_label`: label Corine klasse
* `nara5_code`: code van de NARA landgebruiksklasse (5 ecosystemen) 
* `nara5_label`: lang label van de NARA landgebruiksklasse (5 ecosystemen)
* `nara5_labels`: kort label van de NARA landgebruiksklasse (5 ecosystemen)
* `nara10_code`: code van de NARA landgebruiksklasse (10 ecosystemen)
* `nara10_label`: lang label van de NARA landgebruiksklasse (10 ecosystemen)

### Voorbereiding  data

Na inlezen van beide tabellen, worden de Corine-klassen gegroepeerd per NARA-klasse en gekoppeld aan de bijhorende labels.

### Sankey diagram

Het package `NetworkD3` is beschikbaar op de standaard RStudio-repository, maar ontbreekt een aantal functionaliteiten om de layout van het diagram volledig naar je hand te zetten. Het package `sankeyD3` heeft die extra functionaliteiten wel, maar is alleen in beta-versie beschikbaar op [GitHub](https://github.com/fbreitwieser/sankeyD3). Voor onze oefening gebruiken we `sankeyD3`. 

Een woordje uitleg over hoe de kleuren van het diagram aangepast kunnen worden, vind je [hier](https://www.r-graph-gallery.com/322-custom-colours-in-sankey-diagram.html).

Hexadecimale kleurencodes via [colorbrewer](http://colorbrewer2.org/#type=sequential&scheme=BuGn&n=3)

