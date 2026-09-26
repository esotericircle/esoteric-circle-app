# Stato asset, manifesto vivo

Questo file traccia, per ogni famiglia di asset grafici, tre cose: il percorso di
origine (nella cartella locale `output/` di Mauro, se esiste), il percorso nel
repo dentro `brand_assets/`, e lo stato. Va aggiornato alla fine di ogni sessione,
come `RELAZIONE_NOTTE.md`. La stessa fotografia vive nella sezione "Stato
avanzamento e percorsi asset" di `docs/01_Master_Briefing_Tecnico_Definitivo.md`.

Stati possibili:

- generato: l'arte esiste in `output/` sulla macchina di Mauro, non ancora nel repo.
- importato: i file sono nel repo dentro `brand_assets/`, registrati in `pubspec.yaml`.
- agganciato: le immagini sono usate a runtime da una funzione dell'app.
- mancante: l'arte non esiste ancora.

Nota sulla sessione corrente: la cartella `output/` non è presente in questo
ambiente di esecuzione remoto (non è mai stata versionata su Git, vive solo in
locale da Mauro). Percio' le famiglie che dipendono da `output/` restano allo
stato precedente: il codice è pronto ad accoglierle, i file vanno importati da
Mauro o pushati nel repo perche' l'agente possa promuoverli.

## Quadro per famiglia

| Famiglia | Origine in output | Percorso nel repo | Stato |
| --- | --- | --- | --- |
| Maestri (avatar) | (a mano, After Effects) | `brand_assets/avatars/Medora-1.png`, `Aura-1.png`, `Caligo-1.png` | agganciato |
| Tempio (fondale Santuario) | | `brand_assets/santuario/tempio.png` | agganciato |
| Intro cinematografica | (a mano) | `brand_assets/intro/Intro-Test-1.mp4` | importato |
| Ritratti VIP | `output/ritratti-vip` | `brand_assets/vip` (da creare) | mancante nel repo, codice pronto |
| Mazzo tarocchi | `output/mazzo-tarocchi` | `brand_assets/tarocchi` (da creare) | mancante nel repo |
| Angeli | `output/angeli` | `brand_assets/angeli` (da creare) | mancante nel repo |
| Animali guida | `output/animali` | `brand_assets/animali` (da creare) | mancante nel repo |
| Cristalli | `output/cristalli` | `brand_assets/cristalli` (da creare) | mancante nel repo |
| Rune | `output/rune_bone` (versione buona) | `brand_assets/rune` (da creare) | mancante nel repo |
| Oggetti rituali del Soffio | | | mancante |
| Bocche dei Maestri | | | mancante |
| Fondali dei rituali giornalieri | | | mancante |

## Dettaglio delle famiglie che dipendono da output/

Queste famiglie non sono state importate in questa sessione perche' la cartella
`output/` non è presente nell'ambiente. Le regole di importazione, da applicare
appena i file sono disponibili, sono queste:

- `output/ritratti-vip` va in `brand_assets/vip`. NON importare
  `output/ritratti_vip_sheet.jpg` (è un contact sheet, non le singole carte).
- `output/mazzo-tarocchi` va in `brand_assets/tarocchi`.
- `output/angeli` va in `brand_assets/angeli`.
- `output/animali` va in `brand_assets/animali`.
- `output/cristalli` va in `brand_assets/cristalli`.
- `output/rune_bone` va in `brand_assets/rune` (versione buona). NON importare
  `output/rune` (versione vecchia).

Regole di importazione: nomi file in minuscolo senza spazi; ogni file oltre i due
o tre MB va ridimensionato a una risoluzione adatta al mobile; ogni nuova cartella
va registrata in `pubspec.yaml` sotto `flutter: assets:`.

## Stato del codice pronto ad accogliere gli asset

- VIP: il modello `Vip` (`lib/core/synastry/vip_catalog.dart`) ha i campi
  `imagePath` e `category` (per il banner basso della card). La Sinastria VIP
  mostra il ritratto nel polo quando `imagePath` è valorizzato, con ripiego a un
  medaglione dorato curato quando manca, e il banner della categoria nel chip.
  Basta valorizzare `imagePath` e `category` (e sostituire le cinque voci
  d'esempio con quelle reali) perche' i ritratti e le categorie reali compaiano.
- Tarocchi: la Stesa a Tre Carte è ancora nello scaffale come funzione, senza una
  schermata dedicata; l'aggancio alle immagini reali arriva quando la schermata
  esiste e le carte sono in `brand_assets/tarocchi`.
- Angeli, animali, cristalli, rune: non c'è ancora una funzione che le consumi, e
  gli asset non sono nel repo; nulla da agganciare finora.
