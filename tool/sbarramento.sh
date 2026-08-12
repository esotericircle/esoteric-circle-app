#!/usr/bin/env bash
# LO SBARRAMENTO: NON SI SPEDISCE SU ROSSO. Ordine P voce 03.
#
# **Perche' esiste.** La build 2171 e' stata spedita con due test rossi. La
# regola che lo vieta esisteva gia', ma viveva in un documento, e un documento
# non ferma niente. Nel file di build c'era anche `ignore_failure: true` sul
# passo delle prove, cioe' il permesso scritto di andare avanti sul rosso.
#
# **Cosa fa.** Lancia la suite. Se non e' interamente verde, ESCE CON ERRORE e
# l'archivio non si produce. Non un avviso, non una nota nel rapporto: il
# comando fallisce.
#
# **L'unico scavalco possibile** e' la variabile d'ambiente SPEDISCO_SU_ROSSO.
# Quando c'e', la build prosegue, ma il suo nome viene stampato in chiaro nel
# registro con la lista dei test caduti: una spedizione su rosso resta
# possibile e diventa impossibile che avvenga in silenzio. Chi la usa deve
# riportare quel nome nel rapporto della consegna.
#
# Gli argomenti passati allo script arrivano a `flutter test`. La build non ne
# passa nessuno, quindi gira la suite intera; servono a poter provare lo
# sbarramento stesso su un file solo, che e' l'unico modo di vederlo cadere
# senza aspettare l'intera suite.
set -u

REGISTRO="$(mktemp)"
echo "== LE PROVE, PRIMA DI COSTRUIRE =="
flutter test "$@" 2>&1 | tee "$REGISTRO"
ESITO=${PIPESTATUS[0]}

if [ "$ESITO" -eq 0 ]; then
  echo "== SUITE VERDE: la build puo' procedere =="
  rm -f "$REGISTRO"
  exit 0
fi

echo ""
echo "======================================================================"
echo "  SUITE ROSSA. L'ARCHIVIO NON SI PRODUCE."
echo "======================================================================"
grep -E "^  [A-Za-z]:.*_test\.dart" "$REGISTRO" | sort -u || true
echo "----------------------------------------------------------------------"

if [ -n "${SPEDISCO_SU_ROSSO:-}" ]; then
  echo ""
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  echo "  SCAVALCO ATTIVO: SPEDISCO_SU_ROSSO"
  echo "  Questa build viene spedita CON LA SUITE ROSSA."
  echo "  Il nome SPEDISCO_SU_ROSSO va riportato nel rapporto della consegna."
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  echo ""
  rm -f "$REGISTRO"
  exit 0
fi

rm -f "$REGISTRO"
exit 1
