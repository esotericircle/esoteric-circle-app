# Ordine FE, voci 22.3 e 22.6: censimento in sola lettura

Fonte: `git grep` su `ab61ca83^` e su `HEAD` (b8b78ad5, ramo lavoro-ey), 6 ottobre 2026. Nessun file del repo toccato, nessun flutter lanciato.

---

## COMPITO 1, voce 22.3 ("Custodisci" diventa "Segna nel Diario" con la stella)

### a) PRIMA: `git grep -n "Custodisci" ab61ca83^ -- lib` (35 righe)

| # | File:riga | Classe | Nota |
|---|---|---|---|
| 1 | lib/core/horoscope/oroscopo_cinese_data.dart:232 | contenuto esoterico | "Custodisci ciò che hai: ..." (oroscopo cinese, denaro, Sigillo diretto) |
| 2 | lib/core/legal/privacy_policy.dart:127 | stringa mostrata (informativa) | "col gesto Custodisci o condividendoli" |
| 3 | lib/core/ricordi/arti_con_responso.dart:135 | altro (stringa `perche` del censimento, non mostrata) | il campo `perche` non e' letto da nessuna schermata (grep `.perche`: zero letture da ArteConResponso) |
| 4 | lib/core/ricordi/arti_con_responso.dart:145 | commento | |
| 5 | lib/core/ricordi/arti_con_responso.dart:182 | commento | |
| 6 | lib/core/ricordi/arti_con_responso.dart:221 | commento | |
| 7 | lib/core/ricordi/ricordo_custodito.dart:10 | commento | |
| 8 | lib/core/ricordi/ricordo_custodito.dart:25 | commento | |
| 9 | lib/core/ricordi/scrigno_dei_custoditi.dart:3 | commento | file poi cancellato (FE.22.7) |
| 10 | lib/core/rituals/il_corpus_del_presagio.g.dart:4182 | contenuto esoterico (corpus generato) | "Custodisci quella scintilla ..." |
| 11 | lib/core/settings/settings_controller.dart:90 | commento | |
| 12 | lib/core/tarot/tarot_card.dart:763 | contenuto esoterico (carta) | Paggio/Fante di Coppe rovescio: "Custodisci la tua sensibilità ..." |
| 13 | lib/features/account/account_screen.dart:123 | stringa mostrata (titolo voce di menu') | "Custodisci il tuo cielo" |
| 14 | lib/features/account/custodia_del_cielo.dart:116 | commento | |
| 15 | lib/features/account/custodia_del_cielo.dart:800 | commento | |
| 16 | lib/features/horoscope/oroscopo_screen.dart:4219 | commento | |
| 17 | lib/features/maestri/aura/face/face_constellation_screen.dart:1786 | commento | |
| 18 | lib/features/maestri/caligo/animal/guide_animal_screen.dart:762 | commento | |
| 19 | lib/features/maestri/caligo/animal/guide_animal_screen.dart:763 | commento | |
| 20 | lib/features/maestri/caligo/rune/rune_draw_screen.dart:1672 | commento | |
| 21 | lib/features/maestri/caligo/sigillo/sigillo_intenzione_screen.dart:842 | commento | |
| 22 | lib/features/onboarding/trionfi_screen.dart:225 | commento | |
| 23 | lib/features/ricordi/azioni_del_responso.dart:24 | commento | |
| 24 | lib/features/ricordi/azioni_del_responso.dart:134 | commento | |
| 25 | lib/features/ricordi/azioni_del_responso.dart:265 | commento | |
| 26 | lib/features/ricordi/azioni_del_responso.dart:270 | commento | |
| 27 | **lib/features/ricordi/azioni_del_responso.dart:372** | **stringa mostrata: PULSANTE** | `label: Text(_custodito ? 'Custodito' : 'Custodisci')`, icona segnalibro. E' l'UNICO pulsante "Custodisci": e' la porta sola montata da tutte le 13 arti con responso |
| 28 | lib/features/ricordi/ricordi_screen.dart:995 | stringa mostrata (testo del Diario vuoto) | "Custodisci: quello che tieni resta qui per sempre." |
| 29 | lib/features/rituals/arcano_dell_alba_screen.dart:177 | commento | |
| 30 | lib/features/rituals/arcano_dell_alba_screen.dart:712 | commento | |
| 31 | lib/features/rituals/ritual_gift_card.dart:334 | commento | |
| 32 | lib/features/rituals/sunset_rune_screen.dart:2406 | commento | |
| 33 | lib/features/synastry/sinastria_vip_screen.dart:1100 | commento | |
| 34 | lib/features/tarot/stesa_tre_carte_screen.dart:1813 | commento | |

(La riga 27 contiene anche "Custodito"; con la SnackBar `'Custodito nei Ricordi del Cerchio.'` a :275 erano tre testi mostrati del gesto.)

Totale PRIMA: 25 commenti, 4 stringhe mostrate (pulsante, informativa, Diario vuoto, voce dell'account), 3 contenuti esoterici, 1 altro, piu' la SnackBar "Custodito".

### b) DOPO: `git grep -n "Custodisci" HEAD -- lib` (29 righe)

| # | File:riga | Classe |
|---|---|---|
| 1 | lib/core/horoscope/oroscopo_cinese_data.dart:232 | **contenuto esoterico, MOSTRATO** |
| 2 | lib/core/ricordi/arti_con_responso.dart:135 | altro (stringa `perche`, non mostrata) |
| 3-5 | lib/core/ricordi/arti_con_responso.dart:145, 182, 221 | commento |
| 6-7 | lib/core/ricordi/ricordo_custodito.dart:10, 25 | commento |
| 8 | lib/core/rituals/il_corpus_del_presagio.g.dart:4182 | **contenuto esoterico, MOSTRATO** (corpus generato da docs/corpus/rune/legame.md:44) |
| 9 | lib/core/settings/settings_controller.dart:90 | commento |
| 10 | lib/core/tarot/tarot_card.dart:763 | **contenuto esoterico, MOSTRATO** |
| 11 | **lib/features/account/account_screen.dart:123** | **stringa mostrata, titolo voce di menu'** |
| 12-13 | lib/features/account/custodia_del_cielo.dart:116, 800 | commento |
| 14 | lib/features/horoscope/oroscopo_screen.dart:4219 | commento |
| 15 | lib/features/maestri/aura/face/face_constellation_screen.dart:1786 | commento |
| 16-17 | lib/features/maestri/caligo/animal/guide_animal_screen.dart:762, 763 | commento |
| 18 | lib/features/maestri/caligo/rune/rune_draw_screen.dart:1672 | commento |
| 19 | lib/features/maestri/caligo/sigillo/sigillo_intenzione_screen.dart:842 | commento |
| 20 | lib/features/onboarding/trionfi_screen.dart:225 | commento |
| 21-23 | lib/features/ricordi/azioni_del_responso.dart:24, 134, 247 | commento |
| 24-25 | lib/features/rituals/arcano_dell_alba_screen.dart:177, 712 | commento |
| 26 | lib/features/rituals/ritual_gift_card.dart:334 | commento |
| 27 | lib/features/rituals/sunset_rune_screen.dart:2417 | commento |
| 28 | lib/features/synastry/sinastria_vip_screen.dart:1100 | commento |
| 29 | lib/features/tarot/stesa_tre_carte_screen.dart:1813 | commento |

Spariti: privacy_policy.dart:127 (cambiata in ab61ca83), scrigno_dei_custoditi.dart (file cancellato, FE.22.7), azioni_del_responso.dart:265/270/372 (pulsante cambiato), ricordi_screen.dart:995 (cambiata in ab61ca83).

Fuori dal grep a maiuscola, per completezza: "custodisci" minuscolo come verbo resta in 13 testi di contenuto mostrati (horoscope_data.dart:258, i_testi_eu_vedica_data.dart:3198, oroscopo_vedico_data.dart:120, natal_identity.dart:164, guide_animal_corpus.dart:340 e 367, il_corpus_del_presagio.g.dart:432, 493, 825, 843, 1522, 1708, 4888, 5330). Nei commenti resta anche "CUSTODISCI" maiuscolo (arti_con_responso.dart:4, azioni_del_responso.dart:17). In `functions/`, `assets/`, `web/`: zero.

### c) Dove sta oggi "Segna nel Diario" e se porta la stella

| Pulsante prima | Oggi | Stella |
|---|---|---|
| azioni_del_responso.dart:372 `'Custodito' : 'Custodisci'` (unico pulsante del gesto, montato da 13 arti) | **lib/features/ricordi/azioni_del_responso.dart:387** `label: const Text('Segna nel Diario')`, chiave `responso_custodisci` (:371), tocco `_segna` (:250) che chiama `mettiLaStella` | SI': `Icons.star_rounded` / `Icons.star_border_rounded` (:385-386); il testo resta fisso, la stella si riempie |
| SnackBar :275 `'Custodito nei Ricordi del Cerchio.'` | azioni_del_responso.dart:271 `'Segnato nel Diario Cosmico.'` | n/a |
| (nuovi, FE.22.7, nel Diario) | ricordi_screen.dart:809 tooltip `'Segna nel Diario'` / `'Togli la stella'` sulla riga | SI': star_rounded / star_border_rounded (:811) |
| (nuovo, voce aperta del Diario) | ricordi_screen.dart:1630 `TextButton.icon` `'Segna nel Diario'` | SI': star_rounded / star_border_rounded (:1628) |
| ricordi_screen.dart:995 testo del Diario vuoto | ricordi_screen.dart:995 "Segna nel Diario: quello che segni resta qui per sempre." | n/a (testo) |
| privacy_policy.dart:127 | "col gesto Segna nel Diario o condividendoli" | n/a (testo) |

I 13 punti di montaggio della porta (quindi del pulsante): oroscopo_screen.dart:4257, archetype_test_screen.dart:975, face_constellation_screen.dart:1789, guide_animal_screen.dart:765, rune_draw_screen.dart:1675, sigillo_intenzione_screen.dart:845, arcano_dell_alba_screen.dart:183, breath_destiny_screen.dart:1333, dream_rite_screen.dart:1086, sunset_rune_screen.dart:2420, sinastria_vip_screen.dart:1102, stesa_tre_carte_screen.dart:1814 (piu' la porta stessa). Nessun altro pulsante "Custodisci" scritto a mano esiste in lib (grep `Text(` con "Custod": zero).

Nota: la voce 22.3 dice "carattere per carattere: Segna nel Diario". A pulsante gia' premuto l'etichetta resta "Segna nel Diario" e cambia solo la stella (prima diceva "Custodito"): e' coerente con la lettera, ma un ritocco toglie la stella senza parola che lo dica (il tooltip "Togli la stella" c'e' solo nel Diario).

### d) "Custodisci" ancora MOSTRATO su HEAD

| File:riga | Cos'e' | "In fondo a una funzionalita'"? | Trattamento nella prova test/i_nomi_del_menu_e_del_diario_test.dart | Testo sostitutivo proposto |
|---|---|---|---|---|
| lib/features/account/account_screen.dart:123 `'Custodisci il tuo cielo'` | Titolo di una voce del menu' Account (`_AccountEntry id: 'custodia'`), visibile **solo a chi e' ancora anonimo** (`if (_eAnonimo(context))`, :121). Sottotitolo: promessa della registrazione, "Cielo di nascita, traguardi accesi, ricordi e Eos tornano su qualsiasi telefono". Al tocco apre il foglio della registrazione (custodia_del_cielo.dart: email, Google, Apple). | **NO**: e' una voce di menu' che porta alla registrazione, non il gesto in fondo a un responso. | **Esentata** per costruzione: la prova colpisce solo `s.trim() == 'Custodisci'`, `== 'Custodito'` o `startsWith('Custodisci:')`; il commento della prova (righe 15-18) la nomina esplicitamente come "altra cosa". Quindi la prova di HEAD e' **piu' stretta** della prova a) del fondatore ("una prova cade se restano ... 'Custodisci' in un testo mostrato"). | **"Metti al sicuro il tuo cielo"** (stesso senso: salvare cielo e cammino legandoli a un account; nessun richiamo al Diario, che e' un'altra cosa). Alternativa: "Salva il tuo cielo". Vanno ritoccate le prove che cercano il titolo (grep `Custodisci il tuo cielo` in test/ da fare prima). |
| lib/core/tarot/tarot_card.dart:763 | Testo della carta (Coppe 11, rovescio), mostrato nella stesa | NO, contenuto | Esentato (contiene "Custodisci" ma non e' uguale ne' comincia con "Custodisci:") | "**Abbi cura della** tua sensibilità senza murarla del tutto." (non "Proteggi": la frase prima dice gia' "proteggersi") |
| lib/core/horoscope/oroscopo_cinese_data.dart:232 | Oroscopo cinese, denaro, giornata del Sigillo diretto | NO, contenuto | Esentato | "**Metti al sicuro** ciò che hai: controlla che ..." |
| lib/core/rituals/il_corpus_del_presagio.g.dart:4182 | Presagio delle rune (corpus GENERATO) | NO, contenuto | Esentato | "**Conserva** quella scintilla mentre fai le cose di sempre." Va cambiato alla fonte docs/corpus/rune/legame.md:44 (testi dell'Architetto) e rigenerato con tool/genera_corpus_del_presagio.py; toccare un file di docs chiede la conferma di Mauro (CLAUDE.md). |
| lib/core/ricordi/arti_con_responso.dart:135 | stringa `perche` del censimento, NON mostrata | no | La prova la legge (e' una stringa fuori dai commenti) ma non scatta | per pulizia "Segna nel Diario e Parlane ci sono" |

Se la prova a) del fondatore va presa alla lettera ("Custodisci" in un testo mostrato), oggi cadrebbe su 4 stringhe (account + 3 contenuti), e la prova di HEAD non lo vede perche' esenta per costruzione. Con lettura insensibile alle maiuscole cadrebbe anche sui 13 "custodisci" minuscoli di contenuto (sezione b).

---

## COMPITO 2, voce 22.6 (ogni responso entra nel Diario da se')

### Il meccanismo (verificato)

- **Porta comune**: `AzioniDelResponso.initState` (lib/features/ricordi/azioni_del_responso.dart:178-186) chiama, a frame finito, `_annota()` (:199-215) che chiama `RegistroDeiRicordi.annotaIlResponso` (lib/core/ricordi/registro_dei_ricordi.dart:537) che scrive sul telefono e chiama la callable `annotaNelDiario` (lib/services/ricordi/porta_vera_dei_ricordi.dart:127; server functions/src/diario.ts:274). Nessun tocco richiesto. Quindi un'arte entra **se e solo se il widget AzioniDelResponso viene costruito**.
- **Conversazioni**: il server, nella stessa chiamata che salva il messaggio (`operazione: 'messaggio'`, functions/src/cerchio.ts:1008-1017), chiama `annotaLaConversazione` (functions/src/diario.ts:193), una riga per conversazione alla prima domanda della persona (`role === "user"`). Sul telefono la riga compare subito con `toccaLaConversazione` (registro_dei_ricordi.dart:589) dal callback `segnaNeiRicordi` (maestro_chat_screen.dart:156-168; controller :1228 e :1295).
- **riempiIlDiario** (functions/src/diario.ts:388; chiamata da lib/core/cammino/custode_del_cammino.dart:462): riempimento una tantum delle conversazioni passate, dei vecchi custoditi (con stella) e del vecchio indice `ricordi/{AAAA-MM}`.

### Tabella per arte

| Arte / funzione | Dove nasce o si mostra il responso | Dove entra nel Diario da se' | Esito |
|---|---|---|---|
| Oroscopo, GIORNO (occidentale, vedica, cinese) | lib/features/horoscope/oroscopo_screen.dart:1878 (`if (consulto && _fase == responso) _ShareBlock`), porta a :4257 | azioni_del_responso.dart:185 (arte `oroscopo`) | ENTRA, dopo il gesto "Interroga il cielo" |
| Oroscopo, SETTIMANA e MESE | oroscopo_screen.dart:1582 (occidentale) e :1641 (altre tradizioni) `IlPeriodoView`; card a :1599 `_CondividiIlPeriodo` | nessuna: `_CondividiIlPeriodo` (:4285) ha solo il Condividi; `consulto` vale solo per `HoroscopePeriod.giorno` (:1276) | **NON ENTRA** |
| Oroscopo, ANNO (e PDF dell'anno) | oroscopo_screen.dart:1608 `_lAnno` (def. :928), `IlPdfDellAnno.condividi` :1109 | nessuna (`_lAnno` non monta AzioniDelResponso) | **NON ENTRA** |
| Stesa di Tarocchi | lib/features/tarot/stesa_tre_carte_screen.dart:1814 | azioni_del_responso.dart:185 (arte `stesa`) | ENTRA **solo se la porta viene costruita**: sta in fondo a un `ListView` pigro (`_content`, :1343). Chi chiude prima di scorrere fino in fondo (vista + 250 px di cache) non lascia la voce |
| Sinastria VIP | lib/features/synastry/sinastria_vip_screen.dart:1102 | idem (arte `sinastria`) | ENTRA con la stessa riserva: `ListView` pigro (`_content`, :744) |
| Sinastria, Gemello (podio/schermata del gemello) | lib/features/synastry/schermata_del_gemello.dart:384 `SynastryReport.perCieli` | nessuna | **NON ENTRA** |
| Test Archetipo | lib/features/maestri/aura/archetype/archetype_test_screen.dart:975 | idem (arte `archetipo`) | ENTRA |
| Mappa del Viso | lib/features/maestri/aura/face/face_constellation_screen.dart:1789 | idem (arte `viso`) | ENTRA |
| Estrazione Rune (gettata, con il presagio) | lib/features/maestri/caligo/rune/rune_draw_screen.dart:1675 | idem (arte `gettata`) | ENTRA |
| Sigillo dell'Intenzione | lib/features/maestri/caligo/sigillo/sigillo_intenzione_screen.dart:845 | idem (arte `sigillo`) | ENTRA con riserva: dentro `ListView` pigro (`_scena`, :737) |
| Animale Guida (schermata vecchia) | lib/features/maestri/caligo/animal/guide_animal_screen.dart:765 | idem (arte `animale_guida`) | ENTRA, ma questa schermata si apre solo dal Passaporto (cosmic_passport_screen.dart:649) |
| **Viaggio dello Sciamano** (cio' che lo scaffale apre per `guide_animal`, art_navigation.dart:108-110) | lib/features/maestri/caligo/viaggio/viaggio_dello_sciamano_screen.dart:911 `IlResponsoDelViaggio.componi` | scrive solo nel suo `DiarioDeiViaggi` (:931, lib/core/viaggio/diario_dei_viaggi.dart:442, SharedPreferences). Grep `RegistroDeiRicordi\|annota\|AzioniDel` nella cartella viaggio: zero | **NON ENTRA** nel Diario Cosmico |
| Arcano dell'Alba | lib/features/rituals/arcano_dell_alba_screen.dart:183 | idem (arte `alba`) | ENTRA |
| Soffio del Destino | lib/features/rituals/breath_destiny_screen.dart:1333 (dentro RitualGiftCard) | idem (arte `soffio`) | ENTRA |
| Sigillo del Sogno | lib/features/rituals/dream_rite_screen.dart:1086 | idem (arte `sogno`) | ENTRA |
| Runa del Tramonto | lib/features/rituals/sunset_rune_screen.dart:2420 | idem (arte `tramonto`) | ENTRA |
| Runa del Tramonto, settimana di sette sere | sunset_rune_screen.dart:572 `_custodisciLaSettimana` | sunset_rune_screen.dart:1626 `annotaIlResponso` (arte `settimana_rune`, ComeENato.evento) | ENTRA |
| **Angelo Custode** (i tre angeli) | lib/features/angels/angels_screen.dart:170 `GuardianAngels.forBirth` | nessuna: grep `AzioniDel\|annota\|Registro\|Parlane\|Condividi` in angels_screen.dart: zero | **NON ENTRA** |
| **Consiglio dei Maestri** (Consulta i Maestri) | lib/features/maestri/ask/ask_maestri_screen.dart:318 `services.ai.consult` (lenti) e :393 `services.ai.synthesize` (sintesi, `_SynthesisCard` :669) | nessuna: il file non usa RegistroDeiRicordi ne' AzioniDelResponso; entra solo la chat se la persona tocca "Continua in chat" (:650, ChatOpeners.consiglio :458) | **NON ENTRA** (il responso), entra solo l'eventuale chat dopo |
| **Confronto del cielo con un amico** (Cerchio) | lib/features/cerchio/confronto_del_cielo_screen.dart:320 `confronto.rigaDelGiorno` | nessuna | **NON ENTRA** |
| Chat scritta coi Maestri | maestro_chat_controller.dart:1290 `_persist` -> firestore_maestro_memory_repository.dart:295 | server functions/src/cerchio.ts:1013 -> functions/src/diario.ts:193; telefono maestro_chat_screen.dart:159 | ENTRA (una riga per conversazione, alla prima domanda; con il repository in memoria, senza Firebase, no) |
| LIVE | lib/features/maestri/live/schermata_live.dart:957 `chat.send(testo)` sullo stesso MaestroChatController della chat (l_entrata_nel_vivo.dart:44) | stessa strada della chat (cerchio.ts:1013, diario.ts:193) | ENTRA come conversazione (le frasi a voce sono turni della chat) |
| Meditazione | meditation_screen.dart:487 (memoria sua) | dichiarata `senzaResponso` (arti_con_responso.dart:213) | Non e' responso per dichiarazione |
| Lettura del mese | lib/core/ricordi/lettura_del_mese.dart, mostrata in ricordi_screen.dart:533 | vive dentro il Diario, non come voce | Non applicabile |
| Chakra, Cristalli, Rituali guidati, I Ching, ecc. | art_catalog.dart (chakra_scan :604, crystal_oracle :622, ...) | nessuna rotta in art_navigation.dart (default `null`, :161): Coming soon | Non producono responso oggi |
| Arcano del Giorno (vecchio) | fuso nell'Alba (art_navigation.dart:155) | dichiarato `senzaAzioni` (arti_con_responso.dart:224) | Coperto dall'Alba |

### Riassunto delle falle della 22.6

1. **Viaggio dello Sciamano** (la vera arte "Animale Guida" dello scaffale): NON ENTRA.
2. **Angelo Custode**: NON ENTRA.
3. **Consiglio dei Maestri**: il responso NON ENTRA (solo l'eventuale chat).
4. **Oroscopo Settimana, Mese, Anno** (tutte le tradizioni): NON ENTRANO, entra solo il Giorno.
5. **Confronto del cielo con un amico** e **Gemello della Sinastria**: NON ENTRANO.
6. **Stesa, Sinastria VIP, Sigillo dell'Intenzione**: entrano solo se la persona scorre fino alla porta, perche' AzioniDelResponso sta in un `ListView` pigro e l'annotazione parte dal suo `initState`. Da verificare a video o con una prova che chiude la schermata senza scorrere.

---

## Le cure, 6 ottobre 2026 sera

### FE.22.3

La prova a) del fondatore si legge alla lettera: "una prova cade se restano [...] «Custodisci» in un testo mostrato all'utente". I quattro testi mostrati sono stati riscritti:

| Dove | Prima | Dopo |
|---|---|---|
| `lib/features/account/account_screen.dart` (voce del menu' dell'account) | Custodisci il tuo cielo | Metti al sicuro il tuo cielo |
| `lib/core/tarot/tarot_card.dart` (Coppe 11, rovescio) | Custodisci la tua sensibilità | Abbi cura della tua sensibilità |
| `lib/core/horoscope/oroscopo_cinese_data.dart` e la fonte `docs/corpus/oroscopo_cinese.md` | Custodisci ciò che hai | Metti al sicuro ciò che hai |
| `lib/core/rituals/il_corpus_del_presagio.g.dart`, rigenerato dalla fonte `docs/corpus/rune/legame.md` | Custodisci quella scintilla | Conserva quella scintilla |

Anche la stringa `perche` del censimento (`lib/core/ricordi/arti_con_responso.dart`, non mostrata) dice "Segna nel Diario e Parlane ci sono". La guardia `test/i_nomi_del_menu_e_del_diario_test.dart` cade adesso sulla parola "Custodisci" ovunque stia in una stringa di `lib` (era solo la stringa uguale a "Custodisci" o che cominciava con "Custodisci:"): vista rossa prima del tocco con A34, poi rossa con A83. Il verbo minuscolo dentro una frase di contenuto resta: non e' il nome del gesto.

### FE.22.6

Le nove letture trovate fuori dal Diario entrano da sole dal commit `2ec15848`: un punto solo, `annotaNelDiario` in `lib/features/ricordi/azioni_del_responso.dart`, con `IlResponsoNelDiario` dove il responso compare e `IstantiDeiResponsi` per la chiave. Guardia `test/ogni_lettura_entra_nel_diario_test.dart`, rossa con A77, A78 e A79.
