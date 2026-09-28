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
# - GitHub non risponde o rifiuta la domanda, dopo tre tentativi;
# - il limite delle domande di GitHub non si riapre entro il tetto d'attesa.
#
# **IL LIMITE DI GITHUB SI ASPETTA, NON FERMA. Ordine EA voce 15.** Senza
# credenziali GitHub risponde a sessanta domande all'ora per indirizzo, e i
# Mac di Codemagic escono da indirizzi condivisi: la build del fondatore si
# e' fermata su *"API rate limit exceeded"* senza che il cancello fosse rosso.
# Adesso quel rifiuto non consuma i tre tentativi: il cancello legge dalle
# intestazioni l'ora in cui il limite si riapre (`retry-after`, altrimenti
# `x-ratelimit-reset`), stampa che sta aspettando, quanto e fino a che ora, e
# riprova. Nessun token nuovo. **Il tetto** e' `ATTESA_MASSIMA_DEL_LIMITE`,
# 1500 secondi, perche' la build ha sessanta minuti in tutto: se la
# riapertura cade oltre, lo dice subito con l'ora a cui rilanciare, invece di
# tenere acceso un Mac che non arrivera' in fondo.
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
# **E non si prova nemmeno**, ordine EK, 24 settembre 2026: lanciato senza
# console il rimando impiega 3,1 secondi a uscire, e sommati alle letture
# falsavano di dieci secondi l'attesa del limite di GitHub ("Aspetto 82
# secondi" invece di 92): la prova del cancello cadeva anche a macchina
# ferma. Il rimando sta sempre in WindowsApps.
PY=""
for candidato in python3 python; do
  case "$(command -v "$candidato" 2>/dev/null)" in *WindowsApps*) continue ;; esac
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

ATTESA_MASSIMA_DEL_LIMITE="${ATTESA_MASSIMA_DEL_LIMITE:-1500}"
INTESTAZIONI="$(mktemp 2>/dev/null || echo "/tmp/cancello_intestazioni_$$")"
trap 'rm -f "$INTESTAZIONI"' EXIT
domanda=0

chiedi() {
  domanda=$((domanda + 1))
  # La risposta finta esiste solo per le guardie degli ordini CODEMAGIC2 ed
  # EA, che provano ogni esito senza chiedere a GitHub; su Codemagic non e'
  # mai impostata, e se lo fosse il registro lo direbbe qui sotto. Una
  # risposta numerata (`.1`, `.2`) vale per quella domanda, e le sue
  # intestazioni stanno accanto (`.intestazioni`).
  if [ -n "${RISPOSTA_FINTA_DEL_CANCELLO:-}" ]; then
    local finta="$RISPOSTA_FINTA_DEL_CANCELLO"
    if [ -f "$finta.$domanda" ]; then finta="$finta.$domanda"; fi
    echo "   RISPOSTA FINTA, da $finta"
    if [ -f "$finta.intestazioni" ]; then
      cp "$finta.intestazioni" "$INTESTAZIONI"
    else
      : > "$INTESTAZIONI"
    fi
    risposta="$(cat "$finta")"
  else
    risposta="$(curl -sS --max-time 30 -D "$INTESTAZIONI" -H 'Accept: application/vnd.github+json' "$INDIRIZZO" 2>&1)"
  fi
}

# Il rifiuto e' il limite quando lo dice il messaggio o lo dicono le
# intestazioni: le domande rimaste sono zero.
e_il_limite() {
  case "$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')" in
    rifiutata*"rate limit"*) return 0 ;;
  esac
  tr -d '\r' < "$INTESTAZIONI" 2>/dev/null \
    | grep -qi '^x-ratelimit-remaining:[[:space:]]*0[[:space:]]*$'
}

# Quanti secondi mancano alla riapertura, piu' due di margine.
quanto_aspettare() {
  local ora dopo reset
  ora="$(date +%s)"
  dopo="$(grep -i '^retry-after:' "$INTESTAZIONI" 2>/dev/null | head -1 | tr -dc '0-9')"
  if [ -n "$dopo" ]; then echo $((dopo + 2)); return; fi
  reset="$(grep -i '^x-ratelimit-reset:' "$INTESTAZIONI" 2>/dev/null | head -1 | tr -dc '0-9')"
  if [ -n "$reset" ] && [ "$reset" -gt "$ora" ]; then
    echo $((reset - ora + 2))
    return
  fi
  echo 60
}

# L'ora, in UTC, fra quanti secondi: GNU date su Linux, BSD date sul Mac.
ora_fra() {
  local quando=$(( $(date +%s) + $1 ))
  date -u -d "@$quando" +%H:%M:%S 2>/dev/null || date -u -r "$quando" +%H:%M:%S
}

esito=""
tentativo=0
aspettato=0
while :; do
  chiedi
  esito="$(printf '%s' "$risposta" | "$PY" -c "$LETTORE" "$COMMIT")"
  case "$esito" in
    verde|rosso|in_corso|assente) break ;;
  esac
  if e_il_limite "$esito"; then
    attesa="$(quanto_aspettare)"
    if [ $((aspettato + attesa)) -gt "$ATTESA_MASSIMA_DEL_LIMITE" ]; then
      riapre="$(ora_fra "$attesa")"
      esito="limite"
      break
    fi
    echo ""
    echo "== GITHUB HA RAGGIUNTO IL LIMITE DELLE DOMANDE SENZA CREDENZIALI =="
    echo "   Non e' un rosso: e' GitHub che per ora non risponde a questo indirizzo."
    echo "   Aspetto $attesa secondi e riprovo alle $(ora_fra "$attesa") UTC."
    echo "   Attesi finora $aspettato secondi, al massimo $ATTESA_MASSIMA_DEL_LIMITE."
    sleep "${ATTESA_DEL_LIMITE_FORZATA:-$attesa}"
    aspettato=$((aspettato + attesa))
    echo "   Riprovo adesso."
    continue
  fi
  tentativo=$((tentativo + 1))
  echo "Tentativo $tentativo: GitHub non ha dato una risposta leggibile ($esito)."
  if [ "$tentativo" -ge 3 ]; then break; fi
  sleep "${ATTESA_FRA_I_TENTATIVI:-20}"
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
  limite)
    ferma "IL LIMITE DI GITHUB NON SI RIAPRE IN TEMPO PER QUESTA BUILD." \
      "GitHub risponde di nuovo alle $riapre UTC, oltre i $ATTESA_MASSIMA_DEL_LIMITE secondi d'attesa che la build si puo' permettere: si rilancia la build dopo quell'ora. Il cancello non e' rosso."
    ;;
  *)
    ferma "GITHUB NON HA RISPOSTO, TRE VOLTE: $esito" \
      "Senza la risposta non si sa se il commit e' verde. Si rilancia la build fra qualche minuto."
    ;;
esac
