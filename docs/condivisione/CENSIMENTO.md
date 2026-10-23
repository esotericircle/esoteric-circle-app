# Il censimento della condivisione e dell'invito

**Ordine DW voce 01**, 18 settembre 2026. Enumerato dal codice (ogni chiamata a
`PortaDellaCondivisione`, ogni `share...Card`, ogni pulsante Condividi, Invita,
Manda) e verificato sul Realme con la build 2269. Qui c'e' **come era** e
**come e' adesso**, dopo le voci DW.02-DW.08.

La porta e' una sola: `lib/core/condivisione/porta_della_condivisione.dart`.
Nessuna chiamata a `SharePlus` la scavalca (sorveglia `i_nove_ereditati_test`).
Il premio in Eos lo decide il server (`functions/src/borsellino.ts`) e si paga
solo se il sistema dice che la condivisione e' avvenuta; al massimo tre
condivisioni premiate al giorno.

---

## 1. Le funzioni, una per una

| funzione | prima | adesso | premio |
|---|---|---|---|
| Arcano dell'Alba | **niente**: nessun pulsante (esenzione `senzaAzioni`, ordine DT voce 02) | Custodisci, Parlane con Medora, **Condividi con la card** (carta, parola, gesto, perche', Medora) | 15 |
| Soffio del Destino | **solo testo** | **card** (soffione, orientamento, loto di Aura) | 15 |
| Runa del Tramonto | card | card | 15 |
| Rito della Notte | card | card | 15 |
| Oroscopo | card, con **esotericircle.com/oroscopo** stampato a mano | card, dominio dal marchio | 15 |
| Stesa di Tarocchi | card, con **esotericircle.com/tarocchi** stampato a mano | card, dominio dal marchio | 15 |
| Sinastria VIP | card | card | 15 |
| Test Archetipo | card, testo con un percorso `/aura/archetype_test` che nessuno gestisce | card, link dal marchio | 15 |
| Costellazione del Viso | card | card | 15 |
| Estrazione Rune | card | card | 15 |
| Animale Guida | card | card | 15 |
| Cielo di stanotte, Carta Natale | cartolina | cartolina | 15 |
| Sigillo del Cerchio | immagine | immagine | 15 |
| Festa di un traguardo, *Condividi pubblicamente* | **solo testo, senza link** | **card del Sigillo** + link con invito | 30 |
| Festa di un traguardo, *Manda a qualcuno* | **solo testo, senza link, con la frase *"tu eri qui"* rivolta a chi riceve** (lo screenshot dell'iPhone) | **card del Sigillo** + testo per chi riceve + link con invito | 15 |
| Festa di un traguardo, *Invita qualcuno* | solo testo con link | **card del Sigillo** + link con invito, e la promessa dei 60 Eos a testa | 60 all'ingresso |
| Meditazione | card | card | **nessuno**, dichiarato |
| Viaggio dello Sciamano | card | card | **nessuno**, dichiarato |
| Scarico dei tuoi dati | due file | due file | nessuno, per scelta |

**Senza condivisione, e dichiarato**: il Sigillo dell'Intenzione (e' un segno
tracciato col dito, motivato nel registro `arti_con_responso.dart`); la chat
coi Maestri, Chiedi ai Maestri, gli Angeli, il Passaporto, il Calendario e il
Diario, che non producono un responso da mandare.

**Tutte le card** stampano ora `Brand.domain` (`esotericircle.app`), letto dal
marchio. **Tutti i fogli di condivisione** passano l'origine che iPad pretende:
prima, su iPad, share_plus sollevava un errore e la condivisione non partiva.

---

## 2. Invitare un amico

| | prima | adesso |
|---|---|---|
| **da dove si invita** | solo dalla festa di un Sigillo: senza un traguardo acceso non si poteva; per un Sigillo gia' festeggiato, quattro tocchi dal Passaporto | **Account, *Invita un amico***: due tocchi dalla barra, sempre; e la festa di ogni Sigillo |
| **cosa riceve l'amico** | un testo col link; nei modi *pubblico* e *privato* nessun link | il testo spiega cosa fare (*scarica, e quando ti registri incolla questo link*), il link porta il codice, e dalla festa parte anche la card |
| **come si attribuisce** | l'amico doveva trovare da solo Account, *Chi ti ha invitato*; nessuno glielo diceva | **alla prima registrazione il Cerchio chiede una volta *Ti ha invitato qualcuno?***, col pulsante Incolla; la strada dal menu' resta |
| **il premio** | 60 Eos a chi invita, niente a chi arriva | **60 Eos a tutti e due** (`EOS_A_CHI_ARRIVA_CON_UN_INVITO`), idempotente |

**La domanda non torna nel Santuario.** L'ordine CE voce 02 l'aveva tolta
perche' compariva da sola a chi apriva l'app; adesso si fa solo a chi ha appena
ricevuto la dote di benvenuto, una volta, e la sorveglia
`le_card_da_mandare_test.dart`.

---

## 3. Cio' che resta, e di chi e'

1. **`esotericircle.app` non si apre.** Il nome risolve (62.149.128.40) ma la
   connessione sicura fallisce, e un dominio `.app` funziona solo in HTTPS. E'
   l'indirizzo di tutti i link e di tutte le card. **Lo attiva il fondatore**
   (decisione del 18 settembre 2026); finche' non e' attivo, chi tocca un
   link d'invito trova un errore.
2. **Il link non apre l'app.** Nessun App Link su Android, nessun Universal
   Link su iOS. Servono il dominio attivo, due file sul sito
   (`assetlinks.json`, `apple-app-site-association`) e una build.
3. **L'attribuzione automatica non c'e'.** Su Android esiste (Play Install
   Referrer, col link dello store che porta il codice); su iOS non ha un
   equivalente aperto. Oggi il codice lo porta la persona, incollandolo.
4. **Il server va distribuito** perche' chi arriva riceva i suoi 60 Eos:
   `firebase deploy --only functions:riscattaLInvito`.
5. **Meditazione e Viaggio** condividono senza premio. Non e' un errore del
   codice, ma e' una differenza che la persona vede: da decidere.
