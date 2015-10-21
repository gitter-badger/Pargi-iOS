# Pargi

[![Join the chat at https://gitter.im/Pargi/Pargi-iOS](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/Pargi/Pargi-iOS?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Pargi rakendus iPhone'le. Pargi on sinu abimees mobiilsel parkimisel, siin toimub Pargi modernseks muutmine ning seeläbi ka Swifti populariseerimine, eesti keeles, eesti kasutajale. 

Lühidalt on eesmärgiks luua rakendus, millega saab kasutaja parkida oma auto vähem kui 10 sekundiga ning mille kasutamine ei vaja ühegi konto loomist ega ühegi seadistuse seadmistamist. Luua rakendus avatult ning seeläbi tõstata arutelu Eestis tegutsevate iOSi arendajate ja rakendusi arendada soovivate inimeste vahel.

## Hetkeseis

Projekt on algusfaasis, kogu olemasolev kood on kõrvale pandud ning alustatud on nullist. Hetkel on peamine fookus mudelil ja andmetel ning nende sobival vahendamisel veebist telefoni. Parklate andmed ise leiad [siit](https://github.com/pargi/data). 

Eesmärgiks on kasutada võimalikult palju Swiftile iseloomulikke ja uudseid võtteid, eesmärgiga muuta kood seeläbi loetavamaks ja paremaks näidiseks sellest, milleks Swift võimeline on. Näiteks, mudelikihi puhul eelistatakse klassidele struktuure ning eesmärgiks on pakkuda nii täpset tüübikindlust kui võimalik.

Esialgne tööplaan:

1. Taastada olemasolev funktsionaalsus praegusest App Store versioonist.
2. Planeerida ja implementeerida uus visuaal ja interaktsioon kogu rakendusele, pannes rõhku kiirusele ja effektiivsusele (näiteks kasutades iOS 9 ja iPhone 6s peal 3D Touchi).
3. Analüüsida kriitilise koodi kiirust ja turvalisust, vähendamaks hangumisi ja kiirendamaks tuumfunktsionaalsust.
4. Lisada huvitav uus funktsionaalsus, näiteks kasutades ära iBeacon'eid.

## Kaasalöömine

Kogu koodibaas on avatud tagasisidele, siin hulgas ka juba olemasolev kood. Samuti on oodatud ideed ja ettepanekud rakenduse funktsionaalsuse kohta. Lisaks on ka rakenduse visuaalne pool avatud, seega peaks jaguma võimalusi kaasa lüüa. Siiski, prioriteedid on järgmised:

1. Esmane funktsionaalsus, SMSide saatmine ja kõnede tegemine (parkimise alustamine-lõpetamine). Hetkel [App Store'st saadaval](https://itunes.apple.com/us/app/pargi/id382008856?mt=8) oleva versiooni funktsioonide dubleerimine.
2. Uuendatud visuaal ja interaktsioon, toomaks rakenduse iOS 6 disainilt iOS 9 peale ohverdamata kasutajate [mugavuse ja kiiruse](http://blog.bitsb.in/pargi-kuidas-käsi-käib), eesmärgiks on kasutaja saada parkima alla 10 sekundiga momendist kui rakendus avatakse (või miks mitte ka momendist kui kasutaja auto parkimise lõpetab).
3. Kiire ja täpne geograafiline otsing (siin hulgas ka _weighted_ või kaalutud otsing, mis näiteks võtaks kasutaja ajalugu arvesse).
3. Turvalisus ja töökindlus, ehk kõik hetkel olevas koodis esinevad vead või parendused.
4. Uued funktsioonid, mida hetkel App Store'st saadaval versioonil ei ole.

Kõikide mõtete ja ettepanekutega võib julgelt kontakti võtta kas siinsamas või:
[@henrinormak](https://twitter.com/henrinormak)
[henri.normak @ gmail](mailto://henri.normak@gmail.com?subject=Pargi)
