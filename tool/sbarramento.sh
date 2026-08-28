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

if [ "$ESITO" -eq 0 ]; then
  echo "== SUITE VERDE: la build puo' procedere =="
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
CADUTE="$(sed -nE 's/^[0-9:]+ [+][0-9]+ -[0-9]+: (.*) [[]E[]]$/\1/p' "$REGISTRO" \
  | sed -E 's#^.*[.]dart: ##' | sort -u)"

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

# I NOMI ACCETTATI: la riga fino alla barra verticale, senza commenti.
ACCETTATE=""
if [ -f "$ACCETTATI" ]; then
  # Anche qui si toglie il percorso: una riga del registro scritta come la
  # stampa il rapporto ("percorso.dart: nome") vale quanto una scritta col
  # nome nudo, e le due forme non possono piu' divergere.
  ACCETTATE="$(grep -v '^[[:space:]]*#' "$ACCETTATI" | grep -v '^[[:space:]]*$' \
    | sed -E 's/[[:space:]]*[|].*$//' | sed -E 's#^.*[.]dart: ##')"
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

# Le righe del registro che NON sono cadute: vanno tolte, o il registro
# diventa un elenco di permessi che nessuno rilegge piu'.
if [ -n "$ACCETTATE" ]; then
  while IFS= read -r nome; do
    [ -z "$nome" ] && continue
    if ! echo "$CADUTE" | grep -Fxq "$nome"; then
      echo "AVVISO: nel registro dei rossi accettati c'e' \"$nome\", che oggi"
      echo "        non cade piu'. Va tolto da $ACCETTATI."
    fi
  done <<< "$ACCETTATE"
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
