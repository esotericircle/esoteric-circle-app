# Ordine ES voce 06, chi vede cosa: la mappa dei piani prima e dopo

Letta dal codice, `lib/core/entitlement/plan_catalog.dart`, il 29 settembre 2026. La prova che la
mappa ha queste righe e questi numeri e' `test/entitlement_test.dart`, che il 29 settembre 2026 e'
stata vista rossa sul numero delle righe (attese 35, trovate 36: il conto era mio e sbagliato, la
riga della profondita' non era contata) prima di essere corretta.

## Le righe cambiate o nuove

| Riga | Viandante | Iniziato | Adepto | Illuminato |
|---|---|---|---|---|
| Oroscopo settimanale, prima | Base | Dettagliato | Dettagliato | Dettagliato |
| Oroscopo settimanale, dopo | No | Sì | Sì | Sì |
| Profondità dell'oroscopo (nuova) | Breve | Breve o Approfondita | Breve o Approfondita | Breve o Approfondita |
| Oroscopo dell'anno (nuova) | Con gli Eos | Con gli Eos | Sì | Sì, col PDF |
| Oroscopo per gli amici (nuova) | No | 3 | 10 | Senza limite |

Righe della mappa: prima 33, dopo 36.

## Chi legge queste righe

- `PlanCatalog.haProfondita` legge la riga della profondita' (prima leggeva quella del
  settimanale, che adesso dice solo se il settimanale c'e').
- `AmiciOffline.posti` legge la riga degli amici: "No" vale zero, un numero vale quel numero, il
  resto vale senza limite, piu' i posti comprati.
- La schermata dell'oroscopo apre la Settimana dall'Iniziato, il Mese e l'Anno dall'Adepto;
  l'Anno si apre anche coi 300 Eos per quell'anno.

## I punti dei piani

- Viandante: "Oroscopo settimanale base" diventa "Oroscopo del giorno occidentale; il tuo segno
  cinese e vedico".
- Iniziato: "Oroscopo settimanale dettagliato" diventa "Oroscopo settimanale"; entra "L’oroscopo
  per gli amici, fino a tre". Punti: prima 14, dopo 15.
- Adepto: entrano "Oroscopo dell’anno dal compleanno, con la Rivoluzione Solare" e "L’oroscopo per
  gli amici, fino a dieci". Punti: prima 12, dopo 14.

## I prezzi in Eos

- L'oroscopo dell'anno: 300 (`ListinoDegliEos.oroscopoAnnuale`).
- Un posto in piu' fra gli amici: 100 (`ListinoDegliEos.amicoInPiu`). E' l'unica cosa che gli Eos
  comprano per sempre, per decisione del fondatore.
