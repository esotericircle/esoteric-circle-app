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

# **LO SBARRAMENTO DIVISO SU PIU' MACCHINE. Ordine ACCELERA, 26 settembre
# 2026.** Il fondatore: *"Ma non c'e' modo di accelerare Suite, sbarramenti,
# ecc?"*, e *"Ma se l'accelerazione e' sempre disponibile, usala sempre"*. Su
# una macchina sola lo sbarramento di GitHub durava circa 33 minuti.
#
# **Senza variabili d'ambiente questo file fa esattamente cio' che faceva
# prima**: il PC, la Ronda e le prove dello sbarramento non cambiano. Le due
# modalita' nuove servono a `.github/workflows/verde.yml`:
#
#   - SBARRAMENTO_SOLO=suite|server|scala|chiusure, con SBARRAMENTO_USCITA=
#     <cartella>: si fa UNA fase sola, se ne conservano il registro e l'esito
#     nella cartella, e si esce con zero anche se la fase e' rossa. Decidere
#     non tocca a lei: tocca al giro finale. Per la suite SBARRAMENTO_PEZZO
#     dice quale pezzo e', e i file arrivano in "$@" da
#     `tool/i_pezzi_della_suite.py`.
#   - SBARRAMENTO_DA_REGISTRI=<cartella>, con SBARRAMENTO_PEZZI=<quanti>: non
#     si lancia niente, si leggono i registri conservati dalle macchine e si
#     decide come sempre, con gli stessi cancelli e lo stesso confronto coi
#     rossi accettati. **Un pezzo che manca ferma l'archivio**: una suite di
#     cui manca un sesto non e' una suite verde.
FASE_SOLA="${SBARRAMENTO_SOLO:-}"
DAI_REGISTRI="${SBARRAMENTO_DA_REGISTRI:-}"
USCITA="${SBARRAMENTO_USCITA:-}"
PEZZO="${SBARRAMENTO_PEZZO:-0}"
QUANTI_PEZZI="${SBARRAMENTO_PEZZI:-0}"
if [ -n "$FASE_SOLA" ] && [ -z "$USCITA" ]; then
  echo "SBARRAMENTO_SOLO=$FASE_SOLA vuole SBARRAMENTO_USCITA: dove conservo il registro?"
  exit 1
fi
if [ -n "$FASE_SOLA" ] && [ -n "$DAI_REGISTRI" ]; then
  echo "SBARRAMENTO_SOLO e SBARRAMENTO_DA_REGISTRI insieme non hanno senso."
  exit 1
fi

# Se la fase [nome] va fatta su questa macchina.
fase_da_fare() { [ -z "$FASE_SOLA" ] || [ "$FASE_SOLA" = "$1" ]; }

# Conserva il registro [file] della fase [nome] col suo [esito], ed esce.
conserva_ed_esci() {
  mkdir -p "$USCITA"
  cp "$2" "$USCITA/$1.txt"
  echo "$3" > "$USCITA/$1.esito"
  echo ""
  echo "== FASE $1 CONSERVATA IN $USCITA, esito $3: decide il giro finale =="
  rm -f "$REGISTRO"
  exit 0
}

# Il registro conservato [nome] deve esserci col suo esito, o l'archivio non
# si produce. **Si chiama da sola, mai dentro `$( )`**: la' dentro `exit`
# chiuderebbe soltanto la sottoshell, e un pezzo mancante passerebbe.
pretendi_il_registro() {
  if [ ! -f "$DAI_REGISTRI/$1.txt" ] || [ ! -f "$DAI_REGISTRI/$1.esito" ]; then
    echo ""
    echo "======================================================================"
    echo "  MANCA IL REGISTRO $1 IN $DAI_REGISTRI."
    echo "======================================================================"
    echo "  Una macchina non ha consegnato la sua parte: quello che non si e'"
    echo "  guardato non si puo' dire verde. L'ARCHIVIO NON SI PRODUCE."
    echo "======================================================================"
    rm -f "$QUI/../build/sbarramento_passato.txt" "$REGISTRO"
    exit 1
  fi
}

# L'esito conservato della fase [nome]: solo le cifre.
esito_conservato() { tr -dc '0-9' < "$DAI_REGISTRI/$1.esito"; }

# **IL RAPPORTO SI FISSA, E NON E' UN DETTAGLIO. Ordine CODEMAGIC1 voce 06,
# 16 settembre 2026.**
#
# `flutter test` sceglie da se' come stampare, e **su GitHub Actions sceglie
# un rapporto diverso**: al posto delle righe `00:03 +10 -1: nome [E]` stampa
# `\u2705 nome` e, alla fine, `6 tests passed.`. Misurato accendendo
# GITHUB_ACTIONS=true su questa macchina, non dedotto.
#
# **Cosa costava.** Tutto questo file legge quelle righe: i nomi delle prove
# cadute, il conto delle schermate montate, il confronto col registro dei
# rossi accettati. Con l'altro rapporto **non leggeva niente**: il corredo
# risultava aver montato zero schermate e nessun nome arrivava al confronto.
# Il cancello si fermava lo stesso, ma si fermava per la guardia del cardinale
# minimo, cioe' per "non hai misurato niente", e non per cio' che aveva
# trovato. **Due macchine che stampano in due lingue non sono lo stesso
# cancello**, anche quando eseguono lo stesso comando.
#
# Sta prima di "$@" apposta: chi prova lo sbarramento a mano puo' ancora
# chiedere un altro rapporto, e l'ultimo che passa vince.
echo "== LE PROVE, PRIMA DI COSTRUIRE, con TZ=$TZ =="
if [ -n "$DAI_REGISTRI" ]; then
  # I pezzi della suite, uno per macchina, tutti: da 0 a QUANTI_PEZZI - 1.
  if [ "$QUANTI_PEZZI" -lt 1 ]; then
    echo "SBARRAMENTO_DA_REGISTRI vuole SBARRAMENTO_PEZZI: quanti pezzi aspetto?"
    rm -f "$REGISTRO" "$QUI/../build/sbarramento_passato.txt"
    exit 1
  fi
  ESITO=0
  CONTO_DEI_PEZZI=0
  PEZZO_LETTO="$(mktemp)"
  for ((k = 0; k < QUANTI_PEZZI; k++)); do
    pretendi_il_registro "suite_$k"
    cp "$DAI_REGISTRI/suite_$k.txt" "$PEZZO_LETTO"
    ESITO_PEZZO="$(esito_conservato "suite_$k")"
    cat "$PEZZO_LETTO" >> "$REGISTRO"
    # Le prove passate di ogni pezzo, dal suo massimo: si sommano.
    MASSIMO_PEZZO="$(sed -nE 's/^[0-9:]+ [+]([0-9]+).*$/\1/p' "$PEZZO_LETTO" \
      | sort -n | tail -1)"
    CONTO_DEI_PEZZI=$((CONTO_DEI_PEZZI + ${MASSIMO_PEZZO:-0}))
    echo "== PEZZO $k: ${MASSIMO_PEZZO:-0} prove passate, esito ${ESITO_PEZZO:-?} =="
    [ "${ESITO_PEZZO:-1}" != "0" ] && ESITO=1
  done
  rm -f "$PEZZO_LETTO"
  # Una riga sola col totale, cosi' il gettone conta tutte le prove e non
  # quelle del pezzo piu' grande.
  echo "00:00 +$CONTO_DEI_PEZZI: i $QUANTI_PEZZI pezzi della suite, insieme" >> "$REGISTRO"
elif fase_da_fare suite; then
  flutter test -r expanded "$@" 2>&1 | tee "$REGISTRO"
  ESITO=${PIPESTATUS[0]}
else
  ESITO=0
fi
[ "$FASE_SOLA" = "suite" ] && conserva_ed_esci "suite_$PEZZO" "$REGISTRO" "$ESITO"

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
# Da dove viene la suite del server: dai registri conservati, da questa
# macchina, o da nessuna parte perche' qui si fa un'altra fase sola.
SERVER_DA=""
if [ -n "$DAI_REGISTRI" ]; then
  pretendi_il_registro server
  SERVER_DA="registri"
elif fase_da_fare server && [ -d "$FUNZIONI/node_modules" ]; then
  SERVER_DA="qui"
fi
if [ -n "$SERVER_DA" ]; then
  echo ""
  echo "== LE PROVE DEL SERVER, con npm test dentro functions/ =="
  REGISTRO_SERVER="$(mktemp)"
  if [ "$SERVER_DA" = "registri" ]; then
    cp "$DAI_REGISTRI/server.txt" "$REGISTRO_SERVER"
    cat "$REGISTRO_SERVER"
    ESITO_SERVER="$(esito_conservato server)"
  else
    ( cd "$FUNZIONI" && npm test ) 2>&1 | tee "$REGISTRO_SERVER"
    ESITO_SERVER=${PIPESTATUS[0]}
    [ "$FASE_SOLA" = "server" ] && conserva_ed_esci server "$REGISTRO_SERVER" "$ESITO_SERVER"
  fi
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
  if [ "${ESITO_SERVER:-1}" != "0" ]; then
    ESITO=1
    echo ""
    echo "== LA SUITE DEL SERVER E' ROSSA =="
  fi
elif fase_da_fare server; then
  echo ""
  echo "!! LE PROVE DEL SERVER NON SONO STATE ESEGUITE: manca"
  echo "!! $FUNZIONI/node_modules. Esegui 'npm install' dentro functions/."
  echo "!! Questa build non ha guardato la seconda suite."
  # Una macchina messa li' apposta per il server non puo' tornare senza.
  [ "$FASE_SOLA" = "server" ] && { rm -f "$REGISTRO"; exit 1; }
fi

# **IL TERZO CANCELLO: IL CORREDO A SCALA MASSIMA. Ordine CM voce 10.**
#
# **Il fatto che lo motiva.** Il 1 settembre 2026 il corredo e' stato girato
# per la prima volta col testo alla scala massima che l'app consente, 1,3, e
# QUARANTADUE schermate su centottantadue si sono rotte. Una su quattro. Nessun
# cancello se n'era accorto, perche' ogni prova gira alla scala uno, che e' la
# scala di chi sviluppa e non quella di chi usa.
#
# **E il pubblico di quest'app il testo grande lo imposta davvero.** Astrologia
# e cartomanzia hanno un pubblico mediamente piu' anziano: la misura grande nel
# sistema non e' un caso di scuola, e' la condizione normale di una parte dei
# lettori. Un difetto che compare solo li' e' un difetto che non vede mai
# nessuno di quelli che lo potrebbero riparare.
#
# **Come entra nel cancello.** Le cadute a scala massima finiscono nello stesso
# registro delle altre, col prefisso "SCALA 1,3:" davanti al nome. Il prefisso
# non e' un vezzo: senza, una riga scritta fra i rossi accettati metterebbe a
# tacere quella stessa cattura ANCHE alla scala uno, e la deroga per il testo
# grande diventerebbe una deroga per tutti.
#
# **Il verso e' obbligato: quell'elenco puo' solo accorciarsi.** Il controllo
# delle righe di troppo, poche righe piu' sotto, fa cadere l'archivio se un
# nome resta scritto fra gli accettati mentre quella cattura ha smesso di
# rompersi. Quindi ogni schermata riparata va tolta dall'elenco, e nessuna
# schermata nuova ci puo' entrare senza che qualcuno la scriva a mano.
CORREDO="screenshot_capture_test.dart"
if [ -f "$QUI/../test/$CORREDO" ] && { [ -n "$DAI_REGISTRI" ] || fase_da_fare scala; }; then
  echo ""
  echo "== IL CORREDO A SCALA MASSIMA, con SCALA_DEL_TESTO=1.3 =="
  REGISTRO_SCALA="$(mktemp)"
  if [ -n "$DAI_REGISTRI" ]; then
    pretendi_il_registro scala
    cp "$DAI_REGISTRI/scala.txt" "$REGISTRO_SCALA"
    cat "$REGISTRO_SCALA"
    ESITO_SCALA="$(esito_conservato scala)"
  else
    SCALA_DEL_TESTO=1.3 flutter test -r expanded "test/$CORREDO" 2>&1 | tee "$REGISTRO_SCALA"
    ESITO_SCALA=${PIPESTATUS[0]}
    [ "$FASE_SOLA" = "scala" ] && conserva_ed_esci scala "$REGISTRO_SCALA" "$ESITO_SCALA"
  fi

  # **IL CARDINALE DEL CORREDO.** Un giro che non monta nessuna schermata non
  # trova nessun difetto, e passerebbe per verde. Il corredo ne monta
  # centottantadue: se ne conta meno di centocinquanta, non e' che le
  # schermate stanno bene, e' che non sono state guardate.
  MONTATE="$(sed -nE 's/^[0-9:]+ [+]([0-9]+).*$/\1/p' "$REGISTRO_SCALA" \
    | tail -1)"
  MONTATE="${MONTATE:-0}"
  CADUTE_SCALA="$(sed -nE \
    's/^[0-9:]+ [+][0-9]+( ~[0-9]+)? -[0-9]+: (.*) [[]E[]]$/\2/p' \
    "$REGISTRO_SCALA" | sed -E 's#^.*[.]dart: ##' | sort -u)"
  QUANTE_SCALA="$(echo "$CADUTE_SCALA" | grep -c . || true)"
  GUARDATE=$((MONTATE + QUANTE_SCALA))
  if [ "$GUARDATE" -lt 150 ]; then
    echo ""
    echo "======================================================================"
    echo "  IL CORREDO A SCALA MASSIMA HA GUARDATO $GUARDATE SCHERMATE."
    echo "======================================================================"
    echo "  Ne pretende almeno centocinquanta. Non e' che le schermate stanno"
    echo "  bene: e' che non sono state montate, e questo cancello stava per"
    echo "  dire il vero su niente."
    echo "  L'ARCHIVIO NON SI PRODUCE."
    echo "======================================================================"
    rm -f "$REGISTRO" "$REGISTRO_SCALA" "$QUI/../build/sbarramento_passato.txt"
    exit 1
  fi
  echo ""
  echo "== IL CORREDO A SCALA MASSIMA HA MONTATO $GUARDATE SCHERMATE =="

  echo "$CADUTE_SCALA" | while IFS= read -r nome; do
    [ -z "$nome" ] && continue
    echo "00:00 +0 -1: SCALA 1,3: $nome [E]" >> "$REGISTRO"
  done

  if [ "${ESITO_SCALA:-1}" != "0" ]; then
    ESITO=1
    echo ""
    echo "== IL CORREDO A SCALA MASSIMA E' ROSSO =="
  fi
elif [ ! -f "$QUI/../test/$CORREDO" ]; then
  echo ""
  echo "!! IL CORREDO NON E' STATO GIRATO A SCALA MASSIMA: manca"
  echo "!! test/$CORREDO. Questa build non ha guardato il testo grande."
  [ "$FASE_SOLA" = "scala" ] && { rm -f "$REGISTRO"; exit 1; }
fi

# **IL QUARTO CANCELLO: LE CHIUSURE DICHIARATE. Ordine EH voce 03.**
#
# **Il fatto che lo motiva, con le parole di chi lo ha subito.** Il 24
# settembre 2026 il fondatore ha scritto: *"Passo meta' del mio tempo a
# verificare che l'ordine dichiarato chiuso sia stato effettivamente concluso,
# verificato e chiuso"*, e *"SE UN ORDINE E' DICHIARATO CONCLUSO E CHIUSO IO
# VOLGIO LA GARANZIA CHE SIA LA VERITA'"*. Aveva ragione: la voce EE.04 era
# scritta CHIUSA con una misura vera che rispondeva a **un'altra domanda**, e
# nessun cancello poteva accorgersene.
#
# **Perche' e' un cancello suo e non una prova come le altre.** La guardia
# `ogni_voce_chiusa_porta_la_sua_prova` gira gia' dentro la suite intera, ma
# solo quando la suite intera gira: chi passa un corredo ristretto in "$@" non
# la tocca, e proprio chi ha fretta e' chi ha piu' bisogno di questo controllo.
# Qui si esegue **sempre**, qualunque cosa ci sia in "$@".
#
# **E non passa dai rossi accettati.** Ogni altro rosso di questo file puo'
# essere messo a tacere scrivendolo in `tool/rossi_accettati.txt` con una
# ragione. Questo no: una riga fra gli accettati vorrebbe dire *"si puo'
# dichiarare chiusa una voce senza prova"*, che e' esattamente la cosa che il
# fondatore ha vietato. Il cancello si chiude e basta.
#
# **E DISTINGUE DUE ASSENZE CHE NON SI SOMIGLIANO.** Scritto la prima volta,
# questo cancello fermava la build ogni volta che non trovava la guardia, e
# cosi' ha fatto cadere **dodici prove** di
# `lo_sbarramento_distingue_i_rossi`, che monta lo sbarramento in una cartella
# finta senza `test/` accanto. Le due assenze dicono cose opposte: **la
# guardia sparita mentre il progetto c'e'** e' qualcuno che ha tolto la rete,
# e la build si ferma; **nessun albero del progetto affatto** vuol dire che
# siamo in una cartella di prova, e allora si dichiara non eseguito a voce
# alta, come fa gia' il terzo cancello col corredo.
#
# **E l'albero si riconosce dal `pubspec.yaml`, non dall'esistenza di
# `test/`.** La prima misura era l'esistenza della cartella, e ha lasciato
# rossa una prova su dodici: la tana che prova il corredo a scala massima una
# `test/` ce l'ha, col solo corredo finto dentro, ed era indistinguibile da un
# albero vero a cui qualcuno avesse tolto la guardia. Il `pubspec.yaml` e' la
# cosa che c'e' **sempre** in un albero di questo progetto e **mai** in una
# cartella temporanea, quindi separa i due casi per davvero. E' la Regola A
# applicata alla lettera: quando il rosso non scattava dove doveva, **si e'
# cambiata la grandezza misurata, non la soglia**.
CHIUSURE="ogni_voce_chiusa_porta_la_sua_prova_test.dart"
if [ ! -f "$QUI/../pubspec.yaml" ]; then
  echo ""
  echo "!! LE CHIUSURE NON SONO STATE CONTROLLATE: non c'e' nessun"
  echo "!! pubspec.yaml accanto a tool/. Questo non e' un albero del progetto."
elif [ -f "$QUI/../test/$CHIUSURE" ]; then
  echo ""
  echo "== LE CHIUSURE DICHIARATE PORTANO LA LORO PROVA =="
  # **`if ! cmd | tee` LEGGE L'USCITA DI `tee`, CHE E' SEMPRE ZERO.** Scritto
  # cosi' la prima volta, questo cancello non si e' chiuso su un difetto
  # innestato a mano: si e' fermato lo sbarramento, ma per un altro motivo, e
  # il cancello nuovo non ha stampato una riga. **L'ha trovato la prova del
  # rosso, che e' esattamente cio' per cui la Regola A esiste.**
  if [ -n "$DAI_REGISTRI" ]; then
    pretendi_il_registro chiusure
    tee -a "$REGISTRO" < "$DAI_REGISTRI/chiusure.txt"
    ESITO_CHIUSURE="$(esito_conservato chiusure)"
  else
    flutter test -r expanded "test/$CHIUSURE" 2>&1 | tee -a "$REGISTRO"
    ESITO_CHIUSURE=${PIPESTATUS[0]}
    # Su una macchina messa li' per le sole chiusure il registro contiene
    # solo loro: la suite non e' girata qui.
    [ "$FASE_SOLA" = "chiusure" ] && conserva_ed_esci chiusure "$REGISTRO" "$ESITO_CHIUSURE"
  fi
  if [ "${ESITO_CHIUSURE:-1}" != "0" ]; then
    echo ""
    echo "======================================================================"
    echo "  UN MANIFESTO DICHIARA CHIUSA UNA VOCE CHE NON PORTA LA SUA PROVA,"
    echo "  OPPURE NOMINA UNA GUARDIA CHE NON ESISTE PIU'."
    echo "======================================================================"
    echo "  Questo cancello non ha deroghe e non si mette a tacere con una"
    echo "  riga fra i rossi accettati: una deroga qui vorrebbe dire che si"
    echo "  puo' dichiarare chiusa una voce senza prova, ed e' la cosa che"
    echo "  l'ordine EH ha vietato."
    echo ""
    echo "  Si ripara in uno dei tre modi, tutti onesti:"
    echo "  - si scrivono le righe DOMANDA, PROVA e MISURA sotto la voce;"
    echo "  - si riporta la voce ad APERTA IN ATTESA DI VERIFICA;"
    echo "  - se la guardia e' stata tolta da un ordine dopo, si dichiara"
    echo "    nel manifesto: GUARDIA RIMOSSA: <nome> - <ordine e commit>."
    echo "  L'ARCHIVIO NON SI PRODUCE."
    echo "======================================================================"
    rm -f "$REGISTRO" "$QUI/../build/sbarramento_passato.txt"
    exit 1
  fi
else
  echo ""
  echo "======================================================================"
  echo "  LA GUARDIA DELLE CHIUSURE NON ESISTE PIU': test/$CHIUSURE"
  echo "======================================================================"
  echo "  Era la garanzia che un ordine dichiarato chiuso lo fosse davvero."
  echo "  Se e' sparita, questa build non ha nessuna garanzia da offrire."
  echo "  L'ARCHIVIO NON SI PRODUCE."
  echo "======================================================================"
  rm -f "$REGISTRO" "$QUI/../build/sbarramento_passato.txt"
  exit 1
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
#
# **E ANCHE DOPO UNA PROVA SALTATA, ordine DK voce 06.** Quando la suite salta
# una prova il rapporto scrive `+3790 ~2 -1:` e non `+3790 -1:`, e qui le righe
# si leggevano soltanto nella seconda forma. Dall'ordine DI la suite salta le
# due prove col modello vero, che senza token non girano: il 14 settembre 2026
# il rosso di legge caduto dopo i salti non si e' letto, la sua riga fra gli
# accettati e' sembrata di troppo e l'archivio non si e' prodotto. **E il buco
# era peggiore**: un rosso nuovo caduto dopo i salti, accanto a un rosso
# accettato caduto prima, non si leggeva, e lo sbarramento costruiva
# l'archivio sui soli rossi accettati.
CADUTE="$(sed -nE 's/^[0-9:]+ [+][0-9]+( ~[0-9]+)? -[0-9]+: (.*) [[]E[]]$/\2/p' \
  "$REGISTRO" | sed -E 's#^.*[.]dart: ##' | sort -u)"

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
  rm -f "$REGISTRO" "$QUI/../build/sbarramento_passato.txt"
  exit 1
fi


# **LA PROVA CHE LO SBARRAMENTO E' PASSATO SU QUESTO ALBERO.**
# Ordine CZ voce 14, 8 settembre 2026.
#
# **La falla che chiude.** CI.04 era rossa dall'ordine CT e ha attraversato
# una consegna intera senza fermarla. Cercata la ragione negli strumenti:
# `tool/consegna.py` NON nominava lo sbarramento in nessuna riga. Erano due
# strumenti separati, e niente obbligava il primo a essere passato prima del
# secondo: chi costruiva l'archivio e lo caricava consegnava su qualunque
# rosso, **senza scavalco e senza lasciare traccia**. Lo scavalco dichiarato,
# SPEDISCO_SU_ROSSO, almeno si stampa; saltare lo sbarramento non si vedeva.
#
# **Come si chiude.** Qui si scrive un gettone col numero di build del
# pubspec e col conto delle prove che hanno girato. La consegna lo legge e
# rifiuta di caricare se manca o se il numero non e' il suo: **un gettone di
# ieri non vale per la build di oggi**.
scrivi_il_gettone() {
  NUMERO="$(sed -nE 's/^version: [0-9.]+[+]([0-9]+).*/\1/p' "$QUI/../pubspec.yaml")"
  # **IL MASSIMO, NON L'ULTIMO.** Il registro non contiene solo il rapporto di
  # `flutter test`: dopo di lui ci si aggiungono righe sintetiche `00:00 +0 -1`
  # per le cadute delle altre suite, e `tail -1` pescava una di quelle. Il
  # gettone diceva `prove=0` dopo quattromilasettecento prove passate. Il conto
  # delle passate cresce e non torna indietro, quindi la grandezza giusta e' il
  # suo massimo.
  PASSATE="$(sed -nE 's/^[0-9:]+ [+]([0-9]+).*$/\1/p' "$REGISTRO" \
    | sort -n | tail -1)"
  mkdir -p "$QUI/../build"
  {
    echo "SBARRAMENTO_PASSATO"
    echo "numero=${NUMERO:-ignoto}"
    echo "prove=${PASSATE:-0}"
    echo "quando=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "esito=$1"
  } > "$QUI/../build/sbarramento_passato.txt"
  echo "== GETTONE SCRITTO: numero ${NUMERO:-ignoto}, ${PASSATE:-0} prove =="
}

if [ "$ESITO" -eq 0 ]; then
  echo "== SUITE VERDE: la build puo' procedere =="
  echo "== E il registro dei rossi accettati e' vuoto o dice il vero =="
  scrivi_il_gettone "verde"
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

# **L'AZZERAMENTO STA PRIMA, ordine ACCELERA.** Stava dopo il blocco qui
# sotto e cancellava "(nessun nome letto)": quando la suite cadeva senza
# nominare nessuna prova, l'elenco dei rossi nuovi si stampava vuoto.
NUOVE=""
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
  scrivi_il_gettone "rossi accettati"
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
  scrivi_il_gettone "scavalco SPEDISCO_SU_ROSSO"
  rm -f "$REGISTRO"
  exit 0
fi

# **E SE LA SUITE E' ROSSA IL GETTONE SI CANCELLA**, cosi' un gettone vecchio
# non copre una corsa nuova andata male.
rm -f "$QUI/../build/sbarramento_passato.txt"
rm -f "$REGISTRO" "$QUI/../build/sbarramento_passato.txt"
exit 1
