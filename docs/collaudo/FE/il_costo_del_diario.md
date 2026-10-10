# FE.22.15 e 22.18, quanto costa il Diario Cosmico per persona

## Listini letti il 6 ottobre 2026, Belgio (europe-west1)

Fonti: cloud.google.com/storage/pricing e cloud.google.com/firestore/pricing, regione scelta dal selettore della pagina.

**Firestore, edizione Standard**

| Voce | Prezzo |
|---|---|
| Dati archiviati | 0,000226027 USD per GiB all'ora, circa 0,165 USD per GiB al mese |
| Letture | 0,033 USD ogni 100.000 documenti |
| Scritture | 0,099 USD ogni 100.000 documenti |

**Cloud Storage, classe Archive**, l'archivio usato per le voci oltre i dodici mesi

| Voce | Prezzo |
|---|---|
| Dati | 0,000001644 USD per GiB all'ora, circa 0,0012 USD per GiB al mese |
| Scritture (classe A) | 0,05 USD ogni 1.000 |
| Letture (classe B) | 0,05 USD ogni 1.000 |
| Recupero | 0,05 USD per GiB |
| Durata minima | 365 giorni: chi sostituisce o cancella prima paga i 365 giorni |

## Perché l'archivio è un oggetto per persona e per mese

Con un oggetto per voce, il primo disegno (commit `693a68d6`), ogni voce archiviata costava una scrittura di classe A: 0,05 / 1.000 = 0,00005 USD.

La stessa voce, sotto il chilobyte, su Firestore costa circa 0,0000002 USD al mese. Quindi la sola scrittura nell'archivio valeva più di vent'anni della voce su Firestore: l'archivio «a basso costo» costava di più.

Adesso l'archivio è un oggetto per persona e per mese, `diario_archivio/{uid}/{AAAA-MM}.json`. Si scrive quando il mese è finito da dodici mesi, quindi una volta sola. Le funzioni sono `ilMeseDelConfine`, `vaInArchivio` e `ilPercorsoDelMese` in `functions/src/diario.ts`, provate in `functions/src/diario.test.ts`.

## Il conto per una persona attiva

**Le ipotesi.** 100 voci al mese fra responsi e letture; le conversazioni sono una riga per conversazione.

**I pesi sono i tetti dichiarati nel codice**, non medie:
- una riga dell'indice pesa al più 200 byte (`VoceDelRicordo.pesoMassimo`);
- il contenuto di un responso pesa al più 1.000 byte (`RicordoCustodito.pesoMassimo`).

**Sul server:**
- **Indice e contenuto di un anno:** 1.200 voci × 1,2 KB ≈ 1,4 MB su Firestore, cioè 0,0014 GiB × 0,165 ≈ **0,00023 USD al mese**.
- **Dopo dodici mesi il contenuto passa in archivio:** 1,2 MB × 0,0012 USD/GiB ≈ 0,0000014 USD al mese. Le 12 scritture all'anno costano 0,0006 USD all'anno.
- **Aprire il Diario:** 2 letture (misura in `test/il_diario_cosmico_sul_server_test.dart`, con 100 e con 1.000 voci) ≈ 0,00000066 USD. Trenta aperture al mese fanno 0,00002 USD.
- **Riaprire una voce dall'archivio:** una lettura di classe B (0,00005 USD), più il recupero dell'oggetto del mese (circa 0,1 MB, 0,000005 USD).

**Totale per una persona attiva:** meno di 0,0003 USD al mese, cioè meno di tre centesimi di euro ogni cento persone al mese.

**Il cambio in euro non è verificato** in questo documento. Al cambio di circa 0,9 euro per dollaro, l'ordine di grandezza non cambia.
