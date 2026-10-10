# -*- coding: utf-8 -*-
"""CQ6.02 e CQ6.06: il fischio del responso si spegne.

Un solo difetto, due sintomi: il fischio dopo il sole dell'Alba e i suoni
dell'Oroscopo. E' un tono SINTETIZZATO, non un file, e per questo nessuna
delle quattro pretese della guardia dei suoni lo ha mai visto.
"""
import sys
sys.path.insert(0, 'tool')
from _innesta_tmp import sostituisci  # noqa: E402

NL = chr(10)
A = chr(39)

# --- 1. La porta smette di generare il tono ------------------------------
P = 'lib/core/sensi/palette_sensoriale.dart'
sostituisci(
    P,
    "    // **NON SI ASPETTA IL SUONO, e non e" + A + " una scorciatoia.** Il "
    "responso e" + A + NL +
    "    // gia" + A + " a schermo: chi legge non deve attendere che il lettore "
    "audio" + NL +
    "    // risponda, e in una prova senza il plugin quell" + A + "attesa non "
    "finisce mai." + NL +
    "    // Misurato: la guardia di questa voce restava appesa oltre i dieci" + NL +
    "    // minuti finche" + A + " questa riga aspettava il motore." + NL +
    "    unawaited(_motore.tono(VoceDelResponso.byteDi(maestro), "
    "inCiclo: false));",
    "    // **QUI NON SUONA PIU" + A + " NIENTE, E LA RIGA RESTA A DIRLO. Ordine "
    "CQ" + NL +
    "    // voci 6.02 e 6.06, 4 settembre 2026.**" + NL +
    "    //" + NL +
    "    // Qui partiva un tono SINTETIZZATO dal telefono, novecento millesimi" + NL +
    "    // di fondamentale e quinta, uno per Maestro: 528 hertz per Medora, 432" + NL +
    "    // per Aura, 324 per Caligo. Lo chiedeva l" + A + "ordine BX voce 05, che "
    "voleva" + NL +
    "    // un effetto su ogni responso." + NL +
    "    //" + NL +
    "    // **Il fondatore lo ha sentito come un fischio.** Parole sue del 4" + NL +
    "    // settembre: nel rito dell" + A + "Alba *un fischio che sembra un tono "
    "del" + NL +
    "    // telefono dopo che sollevo il sole*, e nell" + A + "Oroscopo *i suoni "
    "che io" + NL +
    "    // non ti ho inviato*. Erano lo stesso suono, e la mappa lo dice: fra" + NL +
    "    // gli otto responsi ci sono `alba` e `oroscopo`." + NL +
    "    //" + NL +
    "    // **Non si sostituisce con un altro file di mia iniziativa.** Il" + NL +
    "    // fondatore ha chiesto di togliere cio" + A + " che non ha mandato, non di" + NL +
    "    // scegliere io un rimpiazzo: il giorno che manda i tre suoni veri," + NL +
    "    // questa riga torna con i loro nomi. **La vibrazione resta**, ed e" + A + NL +
    "    // qui sopra: chi tiene il telefono muto riceve comunque il responso.")

# --- 2. Il generatore sparisce, e il perche' resta scritto ---------------
Q = 'lib/core/sensi/voce_del_responso.dart'
sostituisci(
    Q,
    "  /// I byte WAV della voce di quel Maestro, pronti per il motore audio." + NL +
    "  ///" + NL +
    "  /// **L" + A + "ampiezza e" + A + " bassa di proposito**: un responso e" + A +
    " una frase detta a" + NL +
    "  /// voce bassa, non un annuncio. Il generatore mette gia" + A + " la "
    "dissolvenza ai" + NL +
    "  /// due capi, quindi non ci sono clic all" + A + "attacco." + NL +
    "  static Uint8List byteDi(Maestro maestro) => _generatore.wav(" + NL +
    "        leftHz: fondamentaleDi(maestro)," + NL +
    "        rightHz: quintaDi(maestro)," + NL +
    "        duration: durata," + NL +
    "        amplitude: 0.22," + NL +
    "      );" + NL,
    "  // **QUI C" + A + "ERA IL GENERATORE, ED E" + A + " STATO TOLTO. Ordine CQ "
    "voci 6.02 e" + NL +
    "  // 6.06, 4 settembre 2026.**" + NL +
    "  //" + NL +
    "  // `byteDi` produceva i byte WAV di un tono sintetizzato, e quel tono e" + A + NL +
    "  // il fischio che il fondatore ha sentito nell" + A + "Alba e nell" + A +
    "Oroscopo. Non" + NL +
    "  // era un file: **per questo nessuna delle quattro pretese della guardia" + NL +
    "  // dei suoni lo ha mai visto**. Quella guardia misura che il tema spenga" + NL +
    "  // il ritorno di sistema, che ogni InkWell porti il suo interruttore, che" + NL +
    "  // nessuna schermata chiami la piattaforma, e che i file del catalogo" + NL +
    "  // esistano. Un tono generato non e" + A + " nessuna delle quattro cose, e" + NL +
    "  // passava in mezzo." + NL +
    "  //" + NL +
    "  // **Le frequenze restano qui sotto**, e non e" + A + " un residuo: se un "
    "giorno" + NL +
    "  // i tre suoni veri arrivano, dicono su che nota erano pensate le tre" + NL +
    "  // voci. Il tono non si genera piu" + A + ", il dato di com" + A + "era resta." + NL)

print('IL FISCHIO E SPENTO')
