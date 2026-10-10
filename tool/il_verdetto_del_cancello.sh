#!/usr/bin/env bash
# IL VERDETTO DEL CANCELLO, LEGGIBILE SENZA CREDENZIALI.
# Ordine CODEMAGIC1 voce 05, 16 settembre 2026.
#
# **Il fatto che lo motiva, misurato il 16 settembre.** Il cancello gratuito e'
# diventato lo stesso cancello di Codemagic (voce 02) ed e' caduto al primo
# giro. Le sue annotazioni pubbliche dicevano i numeri delle due suite, ma non
# **la riga per cui si e' fermato**: quella vive nel registro del giro, e il
# registro delle azioni di GitHub **non si legge senza essere autenticati**,
# nemmeno su un repository pubblico. Provato: l'API risponde 403 e la pagina
# web dice "Sign in to view logs".
#
# **Perche' conta.** Un cancello il cui verdetto si legge solo entrando con le
# credenziali e' un cancello che parla a una persona sola. Le annotazioni
# invece **sono pubbliche**, si leggono con una chiamata sola e senza chiave,
# e restano attaccate al commit per sempre.
#
# **Cosa fa.** Prende il registro dello sbarramento e ne ripubblica come
# annotazione i soli blocchi che dicono la decisione: i rossi nuovi, le righe
# di troppo, il conto delle schermate montate. Non aggiunge giudizi e non
# nasconde niente: e' lo stesso testo, portato dove si vede.
set -u

REGISTRO="${1:-}"
MODO="${2:-rosso}"
if [ -z "$REGISTRO" ] || [ ! -f "$REGISTRO" ]; then
  echo "::error title=Il verdetto del cancello::il registro dello sbarramento non esiste: '${REGISTRO}'. Il cancello e' caduto senza lasciare il suo testo."
  exit 0
fi

# **IL VERDE DICE IL VERO, ordine FC voce 08, 4 ottobre 2026.** Il cancello
# esegue la suite intera dall'ordine ACCELERA, e diventa rosso per ogni rosso
# che nessuno ha accettato. Ma un verde con dei rossi accettati e un verde
# senza nessun rosso si leggevano uguali: l'elenco stava nel registro del
# giro, che senza credenziali non si legge, e per settimane nessun rapporto
# ha detto che dentro il verde c'erano sette prove rosse. Adesso il verde lo
# dice pubblicamente, con quanti e quali: un avviso se ci sono rossi
# accettati, una nota se non ce n'e' nessuno.
if [ "$MODO" = "verde" ]; then
  # Il blocco e': il titolo, una riga di trattini, le righe accettate, una
  # riga di trattini. Si prendono le righe fra le due righe di trattini dopo
  # il titolo, e di ognuna il nome della prova (prima della barra).
  ACCETTATI="$(awk '
    /ROSSI ACCETTATI, E SOLO QUELLI/ { dentro = 1; trattini = 0; next }
    dentro && /^ *-{20,} *$/ { trattini++; if (trattini == 2) exit; next }
    dentro && trattini == 1 { print }
  ' "$REGISTRO" | sed 's/^ *//' | cut -d'|' -f1 | sed 's/ *$//')"
  if [ -n "$ACCETTATI" ]; then
    QUANTI="$(printf '%s\n' "$ACCETTATI" | grep -c .)"
    TESTO="$(printf 'VERDE CON %s ROSSI ACCETTATI, ognuno con la sua ragione in tool/rossi_accettati.txt:\n%s' "$QUANTI" "$ACCETTATI")"
    FUGATO="$(printf '%s' "$TESTO" | sed -e 's/%/%25/g' -e 's/\r/%0D/g' \
      | awk '{printf "%s%%0A", $0}' | cut -c1-9000)"
    echo "::warning title=Il verde ha dei rossi accettati::$FUGATO"
    [ -n "${GITHUB_STEP_SUMMARY:-}" ] && printf '## %s\n' "$TESTO" >> "$GITHUB_STEP_SUMMARY"
  else
    echo "::notice title=Il verde e' pieno::nessuna prova rossa, nemmeno fra le accettate."
    [ -n "${GITHUB_STEP_SUMMARY:-}" ] && echo "## Verde pieno: nessuna prova rossa." >> "$GITHUB_STEP_SUMMARY"
  fi
  exit 0
fi

# **I BLOCCHI CHE DICONO LA DECISIONE**, nell'ordine in cui lo sbarramento li
# stampa. Si prende dalla riga che apre il blocco fino alla riga che lo chiude,
# e non si va a pescare altrove: cio' che non e' qui non e' il verdetto.
estrai() {
  # $1 = prima riga del blocco, $2 = quante righe al massimo
  sed -n "/$1/,+$2p" "$REGISTRO"
}

VERDETTO="$(
  estrai 'RIGHE DI TROPPO NEL REGISTRO DEI ROSSI ACCETTATI' 40
  estrai 'ROSSI NUOVI, NON ACCETTATI DA NESSUNO' 40
  estrai 'IL CORREDO A SCALA MASSIMA HA GUARDATO' 8
  estrai 'La suite e. caduta senza nominare nessuna prova' 6
)"

if [ -z "$VERDETTO" ]; then
  # **Nessun blocco: allora il cancello e' caduto prima di decidere**, per
  # esempio su un errore di compilazione. Si porta fuori la coda del registro,
  # che e' il posto dove quell'errore sta.
  VERDETTO="$(printf 'IL CANCELLO E CADUTO SENZA ARRIVARE AL VERDETTO.\nLe ultime quaranta righe del registro:\n'; tail -40 "$REGISTRO")"
fi

# **L'ANNOTAZIONE VUOLE LE ACCAPO SCRITTE**, altrimenti GitHub tiene solo la
# prima riga. Le percentuali si scrivono per prime, o le sequenze di fuga
# scritte dopo verrebbero rotte da questa stessa sostituzione.
FUGATO="$(printf '%s' "$VERDETTO" \
  | sed -e 's/%/%25/g' -e 's/\r/%0D/g' \
  | awk '{printf "%s%%0A", $0}')"

# Il tetto e' quello che GitHub accetta per una annotazione sola.
FUGATO="$(printf '%s' "$FUGATO" | cut -c1-9000)"

echo "::error title=Il verdetto del cancello::$FUGATO"
