# Esoteric Circle

App nativa Flutter, un solo codebase per iOS e Android. Ecosistema esoterico
guidato dai tre Maestri AI (Medora, Aura, Caligo).

La fonte di verita' completa sono i quattro briefing in `docs/` e il file
`CLAUDE.md` nella radice. In caso di dubbio, i briefing prevalgono.

## Stato: Checkpoint C1

C1 costruisce l'ossatura dell'app. In questo checkpoint c'e':

1. Scaffolding del progetto Flutter con struttura ordinata (`core`,
   `design_system`, `features`, `services`).
2. Design system 2.5D di base: token di colore, tipografia, profondita' e le
   quattro palette (i tre Maestri piu' lo stato neutro).
3. Navigazione principale e Home Il Santuario, con bottom bar dei tre Maestri.
4. Sistema dei feature flag a tre stati (attiva, Coming soon, premium
   bloccata), con funzioni di esempio in Home nei tre stati.
5. Cambio di Maestro con dissolvenza cromatica dell'intera interfaccia.

Non ci sono ancora contenuti veri, onboarding, chat o oracoli: arrivano nei
checkpoint successivi (vedi `docs/HANDOFF_FASE_C.md`).

## Struttura del codice

- `lib/core/` stato di dominio e regole: Maestro attivo, feature flag,
  entitlement del tier, quality tier.
- `lib/design_system/` token 2.5D (primitivi, semantici, di componente),
  palette dei Maestri, tipografia, componenti riutilizzabili.
- `lib/features/` una cartella per dominio funzionale (home, maestri, shell di
  navigazione).
- `lib/services/` confini verso il mondo esterno (Firebase, AI Gateway, motore
  astrologico): in C1 solo le interfacce, nessun segreto.
- `brand_assets/` sorgenti di brand versionati (avatar, intro).
- `docs/` briefing e dossier di handoff.

## Come si esegue

Serve Flutter stable installato (`flutter doctor` a posto per Android).

```bash
flutter pub get
flutter run          # su device Android reale collegato via USB o su simulatore
```

Comandi utili:

```bash
flutter analyze      # analisi statica, deve essere pulita
flutter test         # test di avviamento, navigazione e feature flag
```

### Nota sulle anteprime

Le anteprime committate in `docs/preview/` nascono dai widget test di cattura.
Durante un normale `flutter test` le catture finiscono in `build/preview/`, che
non e' versionata: la suite verifica che ogni schermata renda ancora, senza mai
sporcare l'albero di lavoro. Per aggiornare davvero i PNG committati serve una
richiesta esplicita, un solo comando:

```bash
./tool/aggiorna_anteprime.sh     # oppure .\tool\aggiorna_anteprime.ps1 su Windows
```

Poi si rivedono le differenze con `git diff --stat docs/preview` e si committa
quello che si vuole tenere.

### Nota sui font

La tipografia usa `google_fonts`, che scarica i font a runtime al primo avvio
(con rete) e li mette in cache; se la rete non e' disponibile ripiega sul font
di sistema. Non ci sono font binari nel repository.

### Nota sui feature flag

In C1 la sorgente dei feature flag e' locale (default del catalogo), cosi'
l'app parte su qualsiasi device senza configurare Firebase. L'architettura e'
gia' pronta per collegare Firebase Remote Config in un checkpoint successivo,
sostituendo solo la sorgente (`FeatureFlagSource`), senza toccare il resto.

## Controlli dimostrativi

In Home, l'icona in alto a destra apre un pannello di revisione (solo per i
checkpoint, non per la produzione) per cambiare al volo il tier dell'utente,
cosi' da vedere le funzioni premium sbloccarsi, e il Quality Tier, per vedere
gli effetti grafici degradare.
