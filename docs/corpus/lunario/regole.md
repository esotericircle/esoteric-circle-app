<!-- Fonte del corpus del Calendario Lunare, ordine FV voci FV.06 e FV.07. Formato e grammatica in LEGGIMI.md, nella stessa cartella. Si genera con tool/il_corpus_del_lunario.py controlla e genera: le righe scritte a mano non entrano nel Dart finche' non passano i controlli. -->

# Le regole del Calendario Lunare

Una regola per cella "### id": "attivita" (uno o piu' nomi di
`AttivitaDelLunario`, separati da virgola), "quando" (le condizioni, chiave
uguale valore, piu' valori separati da virgola in OR, piu' chiavi separate da
punto e virgola in AND), "peso" (un intero con segno, positivo verso l'oro,
negativo verso l'evitare) oppure "effetto: toglie_oro" (la Luna fuori corso
che spegne l'oro, senza contare nella somma), "fonti" (gli id di fonti.md,
separati da virgola) e "detto" (il testo breve che compare nel perche' del
giorno). La grammatica completa e' in LEGGIMI.md.

### taglio_capelli_crescenti

- attivita: tagliPerCrescere
- quando: luce=crescente
- peso: +2
- fonti: barbanera_capelli
- detto: Luna crescente

### taglio_capelli_rinforzo

- attivita: tagliPerRinforzare
- quando: luce=calante
- peso: +2
- fonti: barbanera_capelli
- detto: Luna calante

### taglio_unghie_calante

- attivita: unghie
- quando: luce=calante
- peso: +2
- fonti: barbanera_capelli
- detto: Luna calante

### semina_radice

- attivita: semina
- quando: bio=radice
- peso: +2
- fonti: thun_biodinamico
- detto: giorno radice, nel metodo di Maria Thun

### semina_frutto

- attivita: semina
- quando: bio=frutto
- peso: +2
- fonti: thun_biodinamico
- detto: giorno frutto, nel metodo di Maria Thun

### trapianto_radice

- attivita: trapianto
- quando: bio=radice
- peso: +2
- fonti: thun_biodinamico
- detto: giorno radice, nel metodo di Maria Thun

### trapianto_foglia

- attivita: trapianto
- quando: bio=foglia
- peso: +2
- fonti: thun_biodinamico
- detto: giorno foglia, nel metodo di Maria Thun

### potatura_calante

- attivita: potatura
- quando: luce=calante
- peso: +2
- fonti: barbanera_orto_fasi
- detto: Luna calante

### raccolto_radice

- attivita: raccolto
- quando: bio=radice
- peso: +2
- fonti: thun_biodinamico
- detto: giorno radice, nel metodo di Maria Thun

### raccolto_frutto

- attivita: raccolto
- quando: bio=frutto
- peso: +2
- fonti: thun_biodinamico
- detto: giorno frutto, nel metodo di Maria Thun

### raccolto_piena

- attivita: raccolto
- quando: fase=piena
- peso: +1
- fonti: barbanera_orto_fasi
- detto: Luna piena

### rinvasi_foglia

- attivita: rinvasi
- quando: bio=foglia
- peso: +2
- fonti: thun_biodinamico
- detto: giorno foglia, nel metodo di Maria Thun

### talee_foglia

- attivita: talee
- quando: bio=foglia
- peso: +2
- fonti: thun_biodinamico
- detto: giorno foglia, nel metodo di Maria Thun

### fiori_fiore

- attivita: fiori
- quando: bio=fiore
- peso: +2
- fonti: thun_biodinamico
- detto: giorno fiore, nel metodo di Maria Thun

### appartamento_foglia

- attivita: pianteDaAppartamento
- quando: bio=foglia
- peso: +2
- fonti: thun_biodinamico
- detto: giorno foglia, nel metodo di Maria Thun

### pulizie_calante

- attivita: pulizie
- quando: luce=calante
- peso: +2
- fonti: barbanera_casa
- detto: Luna calante

### bucato_calante

- attivita: bucato
- quando: luce=calante
- peso: +2
- fonti: barbanera_casa
- detto: Luna calante

### traslochi_crescente

- attivita: traslochi
- quando: luce=crescente
- peso: +2
- fonti: barbanera_casa
- detto: Luna crescente

### lavori_crescente

- attivita: lavori
- quando: luce=crescente
- peso: +2
- fonti: barbanera_casa
- detto: Luna crescente

### conserve_calante

- attivita: conserve
- quando: luce=calante
- peso: +2
- fonti: barbanera_conserve
- detto: Luna calante

### pane_crescente

- attivita: pane
- quando: luce=crescente
- peso: +2
- fonti: barbanera_conserve
- detto: Luna crescente

### travasi_calante

- attivita: travasi
- quando: luce=calante
- peso: +2
- fonti: barbanera_vino
- detto: Luna calante

### imbottigliamento_calante

- attivita: imbottigliamento
- quando: luce=calante
- peso: +2
- fonti: barbanera_vino
- detto: Luna calante

### depilazione_calante

- attivita: depilazione
- quando: luce=calante
- peso: +2
- fonti: barbanera_bellezza
- detto: Luna calante

### trattamenti_crescente

- attivita: trattamenti
- quando: luce=crescente
- peso: +2
- fonti: barbanera_bellezza
- detto: Luna crescente

### pesca_crescente

- attivita: pesca
- quando: luce=crescente
- peso: +2
- fonti: barbanera_pesca
- detto: Luna crescente

### inizi_crescente

- attivita: inizi
- quando: luce=crescente
- peso: +2
- fonti: lilly_elettiva
- detto: Luna crescente

### inizi_fuoricorso

- attivita: inizi
- quando: fuoricorso=si
- effetto: toglie_oro
- fonti: lilly_elettiva
- detto: Luna fuori corso

### viaggi_crescente

- attivita: viaggi
- quando: luce=crescente
- peso: +2
- fonti: lilly_elettiva
- detto: Luna crescente

### viaggi_segni_mobili

- attivita: viaggi
- quando: segno=gemini,virgo,sagittarius,pisces
- peso: +2
- fonti: elettiva_segni_viaggio
- detto: in un segno mobile

### viaggi_fuoricorso

- attivita: viaggi
- quando: fuoricorso=si
- effetto: toglie_oro
- fonti: lilly_elettiva
- detto: Luna fuori corso

### viaggi_segni_fissi_calante

- attivita: viaggi
- quando: luce=calante; segno=taurus,leo,scorpio,aquarius
- peso: -2
- fonti: elettiva_segni_viaggio
- detto: Luna calante in un segno fisso

### amore_crescente

- attivita: primoAppuntamento,dichiarazione,nozze
- quando: luce=crescente
- peso: +2
- fonti: lilly_elettiva
- detto: Luna crescente

### amore_segni_venere

- attivita: primoAppuntamento,dichiarazione,nozze
- quando: segno=taurus,cancer,libra,pisces
- peso: +2
- fonti: elettiva_amore
- detto: in un segno legato a Venere o alla Luna

### amore_fuoricorso

- attivita: primoAppuntamento,dichiarazione,nozze
- quando: fuoricorso=si
- effetto: toglie_oro
- fonti: lilly_elettiva
- detto: Luna fuori corso

### nozze_calante_sconsigliata

- attivita: nozze
- quando: luce=calante
- peso: -3
- fonti: pitre_nozze_calante
- detto: Luna calante
