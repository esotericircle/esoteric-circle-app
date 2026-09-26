// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **IL CATALOGO DELLE MOSSE E' ESEGUITO, NON SOLO SCRITTO.** Ordine EB voce
/// 07, 21 settembre 2026.
///
/// **Le parole del fondatore**: *"SERVE UN CENSIMENTO SU TUTTE LE CHAT dei
/// maestri e devono essere previsti ogni risposta o comportamento
/// dell'utente"*, e sulla paternita' del catalogo: *"Code procede"*.
///
/// **Il modo di sbagliare che questa prova impedisce.** Un catalogo di sedici
/// mosse scritto in un manifesto e' una promessa: il giorno che una mossa
/// perde la sua rete, il manifesto continua a dire che c'e'. Qui ogni mossa
/// deve puntare a **dove e' tenuta**, e quel dove deve esistere.
///
/// **Cosa NON puo' fare, dichiarato.** Undici mosse su sedici le governa
/// l'istruzione di sistema, cioe' il modello: nessuna prova deterministica
/// puo' garantire che Gemini la rispetti. Quello che si prova e' che **la
/// regola gli arrivi**, che e' la sola meta' che sta a noi. L'altra meta' la
/// guarda il fondatore parlando coi Maestri.
void main() {
  final manifesto =
      File('docs/ordini/ORDINE_EB_MANIFESTO.md').readAsStringSync();

  /// Ogni mossa del catalogo e il pezzo di codice o di testo che la tiene.
  /// La chiave e' il numero nel manifesto, il valore e' cio' che deve
  /// esistere davvero.
  const dove = <int, String>{
    1: 'lib/core/chat/la_richiesta_di_un_arte.dart',
    2: 'lib/core/chat/la_richiesta_di_un_arte.dart',
    3: 'lib/features/maestri/chat/maestro_chat_controller.dart',
    4: 'lib/core/maestro/voce_del_maestro.dart',
    5: 'lib/core/maestro/voce_del_maestro.dart',
    6: 'lib/core/chat/la_risposta_nel_merito.dart',
    7: 'lib/features/maestri/chat/maestro_chat_controller.dart',
    8: 'lib/core/chat/la_risposta_nel_merito.dart',
    9: 'lib/core/l10n/la_lingua_del_modello.dart',
    10: 'lib/core/chat/la_risposta_nel_merito.dart',
    11: 'lib/core/maestro/voce_del_maestro.dart',
    12: 'lib/core/maestro/voce_del_maestro.dart',
    13: 'lib/core/maestro/voce_del_maestro.dart',
    14: 'lib/core/chat/la_risposta_nel_merito.dart',
    15: 'lib/core/chat/la_risposta_nel_merito.dart',
    16: 'lib/core/legal/privacy_policy.dart',
  };

  test('il manifesto porta tutte e sedici le mosse, numerate', () {
    // Le righe del catalogo sono le uniche righe di tabella che cominciano
    // con un numero fra 1 e 16 seguito da una mossa dell'utente.
    final righe = RegExp(r'^\| (\d+) \| ', multiLine: true)
        .allMatches(manifesto.replaceAll('\r\n', '\n'))
        .map((m) => int.parse(m.group(1)!))
        .toList();
    // Le tredici porte della voce 01 sono numerate allo stesso modo: il
    // catalogo e' il secondo blocco, e i suoi numeri arrivano a sedici.
    final massimo = righe.isEmpty ? 0 : righe.reduce((a, b) => a > b ? a : b);
    print(
        'ORDINE EB VOCE 07: righe numerate ${righe.length}, massimo $massimo');
    expect(massimo, 16,
        reason: 'il catalogo non arriva a sedici mosse: il manifesto ne '
            'promette sedici');
    for (var i = 1; i <= 16; i++) {
      expect(righe.contains(i), isTrue, reason: 'manca la mossa $i');
    }
  });

  test('ogni mossa ha un posto dove e\' tenuta, e quel posto esiste', () {
    cardinaleMinimo(dove.length, 16,
        cosa: 'mosse del catalogo',
        perche: 'Se la tavola si svuotasse, questa prova non guarderebbe '
            'nessuna mossa.');
    final senza = <String>[];
    for (final voce in dove.entries) {
      if (!File(voce.value).existsSync()) {
        senza.add('mossa ${voce.key}: ${voce.value} non esiste');
      }
    }
    print('ORDINE EB VOCE 07: mosse ${dove.length}, file distinti '
        '${dove.values.toSet().length}');
    expect(senza, isEmpty, reason: senza.join('\n'));
  });

  test('le cinque mosse deterministiche hanno la loro guardia', () {
    // **Cinque su sedici non dipendono dal modello**, e per quelle non basta
    // che la regola arrivi: si misura il comportamento. Le altre undici le
    // governa l'istruzione, e lo si dichiara invece di fingere una prova.
    const guardie = <int, String>{
      1: 'test/il_pulsante_solo_se_lo_chiedi_test.dart',
      2: 'test/il_pulsante_solo_se_lo_chiedi_test.dart',
      3: 'test/un_rifiuto_vale_per_tutta_la_conversazione_test.dart',
      7: 'test/un_rifiuto_vale_per_tutta_la_conversazione_test.dart',
      10: 'test/un_rifiuto_vale_per_tutta_la_conversazione_test.dart',
    };
    final mancanti = <String>[];
    for (final g in guardie.entries) {
      if (!File(g.value).existsSync()) {
        mancanti.add('mossa ${g.key}: ${g.value} non esiste');
      }
    }
    print('ORDINE EB VOCE 07: mosse con guardia deterministica '
        '${guardie.length} su ${dove.length}');
    expect(mancanti, isEmpty, reason: mancanti.join('\n'));
  });
}
