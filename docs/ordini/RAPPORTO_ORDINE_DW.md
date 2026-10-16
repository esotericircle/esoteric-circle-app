# RAPPORTO DELL'ORDINE DW, LA CONDIVISIONE E L'INVITO

**Data:** 18 settembre 2026. **Ramo:** `claude/esoteric-circle-master-order-e798aj`.
**Manifesto:** `docs/ordini/ORDINE_DW_MANIFESTO.md`. **Censimento:**
`docs/condivisione/CENSIMENTO.md`.

**Otto voci, otto chiuse.** Consegnato con **Android 2270**, release
`4dbhcbfokjhrg`, accesa sul Realme. **Visto sul telefono**: sotto l'Arcano
girato ci sono Condividi, Custodisci e Parlane con Medora; Condividi apre il
foglio di Android con il file `arcano_dell_alba.png`; dalla home *Invita un
amico* e' a due tocchi (l'avatar, poi la voce) e apre il foglio col messaggio
nuovo. Le tre card, fotografate al banco, stanno in `docs/collaudo/DW/`.

---

## 1. COSA NON ANDAVA

Sul Realme, con la 2269, l'Arcano dell'Alba **non si poteva condividere**:
nessun pulsante, quindi nessuna card. Dall'iPhone di un fondatore, *Manda a
qualcuno* della festa di un Sigillo mandava *"Guarda cosa ho acceso nel
Cerchio: ... tu eri qui con l'Arcano dell'Alba"*: una frase scritta per chi
aveva acceso il Sigillo, letta dall'amico come rivolta a lui, **senza link e
senza immagine**. Il censimento ha trovato il resto:

- il Soffio del Destino mandava **un testo solo**;
- due card stampavano **esotericircle.com** a mano, mentre il marchio dice
  **esotericircle.app**;
- **su iPad nessuna condivisione partiva**: share_plus pretende l'origine del
  foglio, la porta non la passava, l'errore veniva inghiottito;
- **invitare qualcuno si poteva solo dalla festa di un Sigillo**, e chi
  arrivava doveva trovare da solo, nel menu' Account, dove incollare il codice;
  **chi arrivava non riceveva niente**.

## 2. COSA E' CAMBIATO

| | prima | adesso |
|---|---|---|
| Arcano dell'Alba | niente | Custodisci, Parlane con Medora, Condividi con la card: carta, parola, gesto col perche', Medora |
| Soffio del Destino | testo | card col soffione e il loto |
| festa di un Sigillo | testo, due modi su tre senza link | card del Sigillo, testo per chi riceve, link con l'invito in tutti e tre |
| domini | due | uno, da `Brand` |
| iPad | la condivisione non partiva | l'origine del foglio passa sempre |
| invitare | solo dopo un Sigillo | anche da Account, *Invita un amico*, sempre |
| chi arriva | doveva cercare dove incollare | alla prima registrazione il Cerchio glielo chiede, una volta |
| premio | 60 Eos a chi invita | **60 a tutti e due** |

## 3. LE DECISIONI DEL FONDATORE

Tre, prese il 18 settembre 2026:

1. **Il dominio resta `esotericircle.app`**, e lo attiva lui. **Oggi non si
   apre**: il nome risolve (62.149.128.40) ma la connessione sicura fallisce.
   Finche' non e' attivo, ogni link d'invito porta a un errore.
2. **La domanda dell'invito torna all'ingresso, dopo la registrazione.**
   L'ordine CE voce 02 l'aveva tolta perche' compariva da sola nel Santuario:
   adesso si fa solo a chi ha appena ricevuto la dote di benvenuto, una volta,
   e mai nel Santuario.
3. **60 Eos anche a chi arriva.**

## 4. COSA SERVE DAL PC DEL FONDATORE

```
firebase deploy --only functions:riscattaLInvito,functions:scriviLaMemoria
```

`riscattaLInvito` paga chi arriva; `scriviLaMemoria` e' la seconda difesa
dell'ordine DV. E l'HTTPS su `esotericircle.app`.

## 5. COSA RESTA

- **Il link non apre l'app**: servono il dominio attivo, i due file per App
  Links e Universal Links sul sito e una build.
- **L'attribuzione automatica non c'e'**: su Android si puo' fare col Play
  Install Referrer, su iOS non esiste un equivalente aperto.
- **Meditazione e Viaggio dello Sciamano** condividono senza premio: da
  decidere.

## 6. I PADRI

- L'Arcano senza pulsanti: **ordine DT voce 02**, commit `47b3c2be` del 17
  settembre 2026, che vietava ogni comando sulla schermata; il rapporto DT
  segnalava il conflitto con l'ordine CG e lo lasciava aperto.
- Il Soffio a solo testo: **ordine BB voce 06** (*"si condivide cio' che si
  vede"*), che ha tolto la parola e ha lasciato il testo senza card.
- Il messaggio privato con la frase del traguardo e senza link: **ordine S voce
  08**, che ha scritto i tre testi.
- I domini a mano: la card della Stesa nasce col commit `03ceaf1f` (*"Stesa a
  Tre Carte di Medora... card condivisibile"*), che non nomina un ordine:
  **PROVENIENZA IGNOTA** come voce; quella dell'Oroscopo ne ha copiato la forma;
  per l'Archetipo, **PROVENIENZA IGNOTA**.
- L'iPad: **PROVENIENZA IGNOTA**, la porta e' nata senza l'origine.
- L'invito solo dalla festa: **ordine BX voce 02**, che ha dato all'invito il
  suo codice ma una porta sola; la domanda all'ingresso tolta dall'**ordine CE
  voce 02**.

## 7. LE PROVE

`le_card_da_mandare_test.dart` (nuova): card del Soffio e del Sigillo, un
dominio solo, l'origine del foglio, i tre messaggi di ogni Sigillo, l'invito.
`l_arcano_dell_alba_si_gira_test.dart`: le tre azioni a carta girata e la card.
`custodisci_e_parlane_test.dart`: ogni arte che condivide manda un'immagine.
Ognuna vista rossa: dominio a mano nella Stesa; quattro chiamate su quattro
senza origine; la frase del traguardo rimessa (165 cadute); le azioni tolte
all'Arcano; il Soffio col testo solo.
