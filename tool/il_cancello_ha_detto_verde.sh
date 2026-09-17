#!/usr/bin/env bash
# IL CANCELLO HA DETTO VERDE SU QUESTO COMMIT? Ordine CODEMAGIC2, 17 settembre
# 2026.
#
# **Perche' esiste.** Fino alla build del 17 settembre il Mac di Codemagic
# rifaceva lo sbarramento intero prima dell'archivio: 46 minuti e 23 secondi,
# e con l'archivio la build ha superato il tetto di 60 minuti ed e' morta
# senza produrre niente. Lo stesso sbarramento, sullo stesso commit, con la
# stessa versione di Flutter e le stesse dipendenze del server, lo fa gia'
# gratis GitHub a ogni spinta (`.github/workflows/verde.yml`, ordine
# CODEMAGIC1): sul commit `65bd5811` in 22 minuti e 24 secondi, verde.
#
# **Cosa fa invece.** Chiede a GitHub, senza credenziali, com'e' finito il
# cancello su ESATTAMENTE il commit che Codemagic sta per costruire, e lascia
# proseguire solo se e' verde. La regola dell'ordine P voce 03, *non si spedisce
# su rosso*, resta intera: cambia solo la macchina che fa la domanda. Costa
# qualche secondo invece di tre quarti d'ora di Mac.
#
# **Quando ferma la build, e lo dice:**
# - il ramo non e' quello canonico (ordine CODEMAGIC2 voce 06);
# - il cancello su questo commit e' rosso;
# - il cancello su questo commit non ha ancora finito: si rilancia quando
#   la spunta su GitHub e' verde, di solito 25 minuti dopo la spinta;
# - il cancello su questo commit non e' mai partito;
# - GitHub non risponde o rifiuta la domanda, dopo tre tentativi.
#
# **L'unico scavalco** resta `SPEDISCO_SU_ROSSO`, lo stesso nome che lo
# sbarramento stampava: una spedizione senza cancello resta possibile, in
# silenzio no.
set -uo pipefail

RAMO_CANONICO="claude/esoteric-circle-master-order-e798aj"
REPOSITORY="esotericircle/esoteric-circle-app"
CANCELLO="verde.yml"

COMMIT="${CM_COMMIT:-$(git rev-parse HEAD)}"
RAMO="${CM_BRANCH:-$(git rev-parse --abbrev-ref HEAD)}"

echo "== IL CANCELLO SU QUESTO COMMIT =="
echo "   ramo:   $RAMO"
echo "   commit: $COMMIT"

if [ "$RAMO" != "$RAMO_CANONICO" ]; then
  echo ""
  echo "======================================================================"
  echo "  QUESTA BUILD PARTE DAL RAMO $RAMO."
  echo "======================================================================"
  echo "  Si costruisce solo da $RAMO_CANONICO: e' il solo ramo"
  echo "  che contiene tutto il lavoro, e main e' fermo al 9 luglio 2026."
  echo "  Su Codemagic: Start new build, scegli quel ramo, rilancia."
  echo "  L'ARCHIVIO NON SI PRODUCE."
  echo "======================================================================"
  exit 1
fi

if [ -n "${SPEDISCO_SU_ROSSO:-}" ]; then
  echo ""
  echo "======================================================================"
  echo "  SCAVALCO ATTIVO: SPEDISCO_SU_ROSSO"
  echo "  Il cancello di GitHub NON e' stato guardato per questa build."
  echo "  Il nome SPEDISCO_SU_ROSSO va riportato nel rapporto della consegna."
  echo "======================================================================"
  exit 0
fi

# Un Python che GIRA, non uno che c'e' soltanto: su Windows `python3` puo'
# essere il rimando al negozio, che esiste nel PATH ed esce con errore.
PY=""
for candidato in python3 python; do
  if command -v "$candidato" >/dev/null 2>&1 \
     && "$candidato" -c 'import json' >/dev/null 2>&1; then
    PY="$candidato"
    break
  fi
done
if [ -z "$PY" ]; then
  echo "Manca python3 su questa macchina: non so leggere la risposta di GitHub." >&2
  echo "L'ARCHIVIO NON SI PRODUCE." >&2
  exit 1
fi

INDIRIZZO="https://api.github.com/repos/$REPOSITORY/actions/workflows/$CANCELLO/runs?head_sha=$COMMIT&per_page=50"

LETTORE='
import json, sys
commit = sys.argv[1]
try:
    dati = json.load(sys.stdin)
except Exception:
    print("illeggibile")
    sys.exit(0)
giri = dati.get("workflow_runs")
if giri is None:
    print("rifiutata " + str(dati.get("message", ""))[:160])
    sys.exit(0)
giri = [g for g in giri if g.get("head_sha") == commit]
for g in giri:
    sys.stderr.write("   giro %s, %s, %s, %s\n" % (g.get("id"), g.get("event"), g.get("status"), g.get("conclusion")))
if any(g.get("conclusion") == "success" for g in giri):
    print("verde")
elif any(g.get("status") != "completed" for g in giri):
    print("in_corso")
elif giri:
    print("rosso")
else:
    print("assente")
'

esito=""
for tentativo in 1 2 3; do
  # La risposta finta esiste solo per la guardia dell'ordine CODEMAGIC2, che
  # prova ogni esito senza chiedere a GitHub; su Codemagic non e' mai
  # impostata, e se lo fosse il registro lo direbbe qui sotto.
  if [ -n "${RISPOSTA_FINTA_DEL_CANCELLO:-}" ]; then
    echo "   RISPOSTA FINTA, da $RISPOSTA_FINTA_DEL_CANCELLO"
    risposta="$(cat "$RISPOSTA_FINTA_DEL_CANCELLO")"
  else
    risposta="$(curl -sS --max-time 30 -H 'Accept: application/vnd.github+json' "$INDIRIZZO" 2>&1)"
  fi
  esito="$(printf '%s' "$risposta" | "$PY" -c "$LETTORE" "$COMMIT")"
  case "$esito" in
    verde|rosso|in_corso|assente) break ;;
  esac
  echo "Tentativo $tentativo: GitHub non ha dato una risposta leggibile ($esito)."
  if [ "$tentativo" -lt 3 ]; then sleep "${ATTESA_FRA_I_TENTATIVI:-20}"; fi
done

ferma() {
  echo ""
  echo "======================================================================"
  echo "  $1"
  echo "======================================================================"
  echo "  $2"
  echo "  Il cancello: https://github.com/$REPOSITORY/actions/workflows/$CANCELLO"
  echo "  L'ARCHIVIO NON SI PRODUCE."
  echo "======================================================================"
  exit 1
}

case "$esito" in
  verde)
    echo ""
    echo "== IL CANCELLO E' VERDE SU $COMMIT: lo sbarramento intero e' passato su GitHub =="
    exit 0
    ;;
  rosso)
    ferma "IL CANCELLO E' ROSSO SU QUESTO COMMIT." \
      "Le prove sono cadute su GitHub: si ripara, si spinge, e si costruisce il commit nuovo."
    ;;
  in_corso)
    ferma "IL CANCELLO NON HA ANCORA FINITO SU QUESTO COMMIT." \
      "Si rilancia la build quando la spunta del commit su GitHub e' verde."
    ;;
  assente)
    ferma "IL CANCELLO NON E' MAI PARTITO SU QUESTO COMMIT." \
      "Nessun giro di $CANCELLO per $COMMIT: si lancia a mano da GitHub, Run workflow, sul ramo canonico."
    ;;
  *)
    ferma "GITHUB NON HA RISPOSTO, TRE VOLTE: $esito" \
      "Senza la risposta non si sa se il commit e' verde. Si rilancia la build fra qualche minuto."
    ;;
esac
