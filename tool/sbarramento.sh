#!/usr/bin/env bash
# LO SBARRAMENTO: NON SI SPEDISCE SU ROSSO NUOVO. Ordine P voce 03, ordine BZ
# voce 02.
#
# **Perche' esiste.** La build 2171 e' stata spedita con due test rossi. La
# regola che lo vieta esisteva gia', ma viveva in un documento, e un documento
# non ferma niente. Nel file di build c'era anche `ignore_failure: true` sul
# passo delle prove, cioe' il permesso scritto di andare avanti sul rosso.
#
# **E perche' e' cambiato, ordine BZ voce 02.** Lo sbarramento com'era murava
# la porta: la build 2167 dell'8 agosto 2026 e' arrivata su TestFlight e sugli
# iPhone dei fondatori quando le prove erano ancora `ignore_failure: true`;
# dal 12 agosto lo sbarramento c'e', e da quando in suite vive un rosso
# dichiarato e accettato NESSUNA build puo' piu' uscire. Un rosso gia' visto e
# gia' spiegato non e' la stessa cosa di un rosso nuovo, e adesso le due cose
# si distinguono.
#
# **Cosa fa.** Lancia la suite.
#   - Verde: l'archivio si produce.
#   - Rossa su prove tutte elencate in tool/rossi_accettati.txt: l'archivio si
#     produce, e il registro della build stampa ogni rosso accettato col suo
#     nome e la sua ragione.
#   - Rossa su anche UNA prova non elencata: il comando fallisce e l'archivio
#     non si produce.
#
# **L'unico scavalco cieco** resta la variabile d'ambiente SPEDISCO_SU_ROSSO,
# che passa su qualunque rosso, anche mai visto, stampando il proprio nome in
# chiaro nel registro. Chi la usa deve riportare quel nome nel rapporto della
# consegna. Il registro dei rossi accettati non e' uno scavalco: ogni riga ha
# un nome e una ragione scritti da una persona.
#
# **IL FUSO E' DICHIARATO, ordine BZ voce 02.** Quattro prove del cielo
# leggevano l'ora locale della macchina: sul PC del fondatore, che sta a
# Roma, davano un cielo, sul Mac di Codemagic, che sta a UTC, ne davano un
# altro di due ore. Le prove sono state riscritte in istanti assoluti, e qui
# il fuso si dichiara lo stesso: chi legge questo file deve sapere in che ora
# gira la suite, e le due macchine devono girare nella stessa.
#
# Gli argomenti passati allo script arrivano a `flutter test`. La build non ne
# passa nessuno, quindi gira la suite intera; servono a poter provare lo
# sbarramento stesso su un file solo, che e' l'unico modo di vederlo cadere
# senza aspettare l'intera suite.
set -u

export TZ="${TZ:-Europe/Rome}"
QUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ACCETTATI="$QUI/rossi_accettati.txt"
REGISTRO="$(mktemp)"

echo "== LE PROVE, PRIMA DI COSTRUIRE, con TZ=$TZ =="
flutter test "$@" 2>&1 | tee "$REGISTRO"
ESITO=${PIPESTATUS[0]}

# **IL SECONDO CANCELLO: ANCHE LA SUITE DEL SERVER. Ordine CF voce 18.**
#
# **Il fatto che lo motiva.** L'ordine CE e' stato consegnato dichiarando
# "4.032 prove, un solo rosso", ed era vero solo per le prove Flutter: le prove
# del server, che girano con `npm test` dentro `functions/`, erano DUE ROSSE.
# Erano il seguito delle voci CE.07 e CE.08, cioe' aspettavano ancora `null`
# dove adesso ci sono i numeri che hanno sostituito l'illimitato. **Nessuno le
# guardava, perche' quella suite non era toccata ne' da `flutter test` ne' da
# questo file.**
#
# **E' la stessa forma dello sbarramento cieco che tenne ferma la build iOS per
# diciassette giorni**: allora la rete di sicurezza non sapeva quali rossi
# fossero ammessi, adesso non sapeva che esistesse una seconda suite. Una suite
# che nessun cancello guarda non e' una rete di sicurezza.
#
# **Stesso trattamento dei rossi accettati.** I nomi delle prove cadute sul
# server finiscono nello stesso registro delle cadute di Flutter, quindi un
# rosso del server passa solo se e' dichiarato in `tool/rossi_accettati.txt`,
# con un nome e una ragione, come ogni altro.
#
# **Si salta solo se le dipendenze non ci sono**, e lo si dice a voce alta:
# una macchina senza `node_modules` non e' una macchina dove la suite e' verde,
# e chi legge il registro deve poterlo distinguere.
# La crocetta pesante con cui `node --test` marca una prova caduta.
CROCE='✖'
FUNZIONI="$(cd "$QUI/.." && pwd)/functions"
if [ -d "$FUNZIONI/node_modules" ]; then
  echo ""
  echo "== LE PROVE DEL SERVER, con npm test dentro functions/ =="
  REGISTRO_SERVER="$(mktemp)"
  ( cd "$FUNZIONI" && npm test ) 2>&1 | tee "$REGISTRO_SERVER"
  ESITO_SERVER=${PIPESTATUS[0]}
  # **I NOMI DELLE PROVE CADUTE DEL SERVER, e la forma non era quella che
  # avevo scritto per prima.** Avevo cercato "not ok 3 - nome", cioe' il
  # formato TAP: `node --test` qui usa il rapporto a spec, che scrive
  # "X nome (1.53ms)" con la crocetta pesante. La prova del rosso non
  # scattava, e la grandezza misurata e' cambiata, non la soglia. Il nome
  # compare due volte, in linea e nel riepilogo, e la riga "failing tests:"
  # non e' il nome di nessuna prova.
  grep -aE "^[[:space:]]*$CROCE " "$REGISTRO_SERVER" \
    | sed -E "s/^[[:space:]]*$CROCE //" \
    | sed -E 's/ \([0-9.]+ms\)[[:space:]]*$//' \
    | grep -av '^failing tests:$' \
    | sort -u \
    | while IFS= read -r nome; do
        [ -z "$nome" ] && continue
        echo "00:00 +0 -1: $nome [E]" >> "$REGISTRO"
      done
  rm -f "$REGISTRO_SERVER"
  if [ "$ESITO_SERVER" -ne 0 ]; then
    ESITO=1
    echo ""
    echo "== LA SUITE DEL SERVER E' ROSSA =="
  fi
else
  echo ""
  echo "!! LE PROVE DEL SERVER NON SONO STATE ESEGUITE: manca"
  echo "!! $FUNZIONI/node_modules. Esegui 'npm install' dentro functions/."
  echo "!! Questa build non ha guardato la seconda suite."
fi

# **LE CADUTE E GLI ACCETTATI SI LEGGONO PRIMA DEL BIVIO. Ordine CH voce 04.**
#
# Fino al 31 agosto 2026 questo confronto viveva soltanto nel ramo rosso, e
# quando la suite era VERDE non veniva eseguito affatto: un registro pieno di
# righe vecchie passava inosservato proprio nel caso in cui e' piu' facile
# accorgersene, cioe' quando nessuna di quelle prove cade piu'. E quando
# veniva eseguito diceva "AVVISO", che nessuno e' obbligato a leggere.
#
# Quel registro e' l'unico posto in cui un difetto puo' essere messo a tacere
# legalmente. Una riga che sopravvive alla sua ragione spegne un pezzo della
# rete di sicurezza senza che nessuno se ne accorga, ed e' cosi' che questo
# progetto ha gia' perso diciassette giorni di build.
CADUTE="$(sed -nE 's/^[0-9:]+ [+][0-9]+ -[0-9]+: (.*) [[]E[]]$/\1/p' "$REGISTRO" \
  | sed -E 's#^.*[.]dart: ##' | sort -u)"

ACCETTATE=""
if [ -f "$ACCETTATI" ]; then
  # Il percorso si toglie da tutte e due le parti: una riga scritta come la
  # stampa il rapporto ("percorso.dart: nome") vale quanto una col nome nudo,
  # e le due forme non possono piu' divergere.
  ACCETTATE="$(grep -v '^[[:space:]]*#' "$ACCETTATI" | grep -v '^[[:space:]]*$' \
    | sed -E 's/[[:space:]]*[|].*$//' | sed -E 's#^.*[.]dart: ##')"
fi

DI_TROPPO=""
if [ -n "$ACCETTATE" ]; then
  while IFS= read -r nome; do
    [ -z "$nome" ] && continue
    if ! echo "$CADUTE" | grep -Fxq "$nome"; then
      DI_TROPPO="$DI_TROPPO$nome
"
    fi
  done <<< "$ACCETTATE"
fi

if [ -n "$DI_TROPPO" ]; then
  echo ""
  echo "======================================================================"
  echo "  RIGHE DI TROPPO NEL REGISTRO DEI ROSSI ACCETTATI."
  echo "======================================================================"
  echo "  Queste righe mettono a tacere una prova che OGGI PASSA:"
  echo "$DI_TROPPO" | sed 's/^/    /'
  echo "  Una riga che sopravvive alla sua ragione spegne la rete di"
  echo "  sicurezza un pezzo alla volta. Toglila da:"
  echo "    $ACCETTATI"
  echo "  L'ARCHIVIO NON SI PRODUCE."
  echo "======================================================================"
  rm -f "$REGISTRO"
  exit 1
fi

if [ "$ESITO" -eq 0 ]; then
  echo "== SUITE VERDE: la build puo' procedere =="
  echo "== E il registro dei rossi accettati e' vuoto o dice il vero =="
  rm -f "$REGISTRO"
  exit 0
fi

echo ""
echo "======================================================================"
echo "  SUITE ROSSA."
echo "======================================================================"
echo "File con prove cadute:"
grep -E "^  [A-Za-z]:.*_test[.]dart" "$REGISTRO" | sort -u || true

# I NOMI DELLE PROVE CADUTE, dalla riga che il rapporto stampa per ognuna:
#   00:03 +10 -1: nome della prova [E]
# Vale sia col rapporto compatto sia con quello esteso, che usano la stessa
# riga. Una riga "loading /percorso.dart" e' un errore di compilazione, e non
# essendo il nome di nessuna prova non puo' finire fra gli accettati.
# **IL PERCORSO SI TOGLIE, ordine BZ voce 02, integrazione del 28 agosto.**
#
# Quando `flutter test` gira su PIU' file, il rapporto mette davanti al nome
# della prova il PERCORSO ASSOLUTO del file; su un file solo non lo mette. Il
# registro dei rossi accettati porta il nome della prova, quindi nella suite
# intera il confronto non combaciava MAI: la stessa prova risultava insieme
# "guarita" (il registro non la trovava fra le cadute) e "nuova" (la caduta non
# si trovava nel registro). E' la contraddizione letta nel registro di
# costruzione, e le due righe dicevano il vero tutte e due.
#
# **Non era la macchina.** Il percorso della macchina che costruisce e'
# /Users/builder/clone/test/..., quello del PC C:/Users/...: cambiano tutti e
# due, ma il confronto falliva anche sul PC. Il difetto era che il percorso
# entrava nel confronto, non quale percorso fosse. La guardia dello sbarramento
# non lo vedeva perche' i rapporti finti che le davo erano scritti SENZA
# percorso, cioe' nella forma del file singolo: adesso ne porta di tutte e due
# le forme, compresa quella del Mac che costruisce.
#
# Si toglie tutto cio' che sta prima del primo ".dart: ".
# CADUTE e ACCETTATE sono gia' state lette prima del bivio, per la voce CH.04:
# qui non si rileggono, perche' due letture della stessa cosa sono due verita'.

if [ -z "$CADUTE" ]; then
  echo ""
  echo "La suite e' caduta senza nominare nessuna prova: non c'e' niente da"
  echo "confrontare col registro dei rossi accettati, e l'archivio non si"
  echo "produce. Guarda il rapporto qui sopra."
  NUOVE="(nessun nome letto)"
else
  echo ""
  echo "Prove cadute:"
  echo "$CADUTE" | sed 's/^/  /'
fi

NUOVE=""
if [ -n "$CADUTE" ]; then
  while IFS= read -r nome; do
    [ -z "$nome" ] && continue
    if ! echo "$ACCETTATE" | grep -Fxq "$nome"; then
      NUOVE="$NUOVE$nome
"
    fi
  done <<< "$CADUTE"
fi

if [ -z "$NUOVE" ] && [ -n "$CADUTE" ]; then
  echo ""
  echo "----------------------------------------------------------------------"
  echo "  ROSSI ACCETTATI, E SOLO QUELLI. L'ARCHIVIO SI PRODUCE."
  echo "----------------------------------------------------------------------"
  grep -v '^[[:space:]]*#' "$ACCETTATI" | grep -v '^[[:space:]]*$' | sed 's/^/  /'
  echo "----------------------------------------------------------------------"
  rm -f "$REGISTRO"
  exit 0
fi

echo ""
echo "----------------------------------------------------------------------"
echo "  ROSSI NUOVI, NON ACCETTATI DA NESSUNO:"
echo "$NUOVE" | sed 's/^/    /'
echo "  L'ARCHIVIO NON SI PRODUCE."
echo "----------------------------------------------------------------------"

if [ -n "${SPEDISCO_SU_ROSSO:-}" ]; then
  echo ""
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  echo "  SCAVALCO ATTIVO: SPEDISCO_SU_ROSSO"
  echo "  Questa build viene spedita CON ROSSI CHE NESSUNO HA ACCETTATO."
  echo "  Il nome SPEDISCO_SU_ROSSO va riportato nel rapporto della consegna."
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  echo ""
  rm -f "$REGISTRO"
  exit 0
fi

rm -f "$REGISTRO"
exit 1
