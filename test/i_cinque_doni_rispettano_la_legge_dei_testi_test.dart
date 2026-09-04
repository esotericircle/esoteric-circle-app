import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'codice_senza_testo.dart';

/// **I CINQUE DONI RISPETTANO LA LEGGE DEI TESTI.** Ordine CQ voce 2.01,
/// 4 settembre 2026.
///
/// **La legge, come il fondatore l'ha dettata**, per esteso e nell'ordine: un
/// titolo che sia gia' una risposta, la risposta vera, come si usa, e solo
/// brevemente in fondo la fonte.
///
/// **Cosa misura questa guardia, e cosa non puo' misurare.** Non giudica se
/// una frase sia bella: giudica **l'ordine e la presenza dei quattro strati**,
/// che e' cio' che si puo' misurare senza opinioni. Un testo brutto nel posto
/// giusto resta un problema di corpus, cioe' materia del fondatore; un testo
/// bello nel posto sbagliato e' un difetto di gerarchia, ed e' questo che si
/// sorveglia qui.
///
/// **Il terzo strato, come si usa, vive DENTRO la risposta**, e si dichiara:
/// i corpora dei cinque Doni sono scritti in seconda persona e finiscono con
/// cosa fare, e una riga separata lo direbbe due volte. E' la stessa ragione
/// per cui l'ordine CQ voce 2.03 ha tolto le tre righe del rito: chiedere di
/// lavorare prima di rispondere era il difetto.
void main() {
  /// I cinque Doni, col nome della chiave del loro colpo d'occhio, di quella
  /// del responso e di quella della fonte.
  ///
  /// **L'elenco sta qui e non si scopre a esecuzione**: un elenco scoperto
  /// leggendo una cartella sarebbe verde il giorno che una schermata sparisce.
  const doni = <String, (String file, String risposta, String testo,
      String fonte)>{
    'Alba e Soffio': (
      'lib/features/rituals/ritual_gift_card.dart',
      'alba_titolo_risposta',
      'alba_risposta',
      'gift_base_panel',
    ),
    'Arcano del Giorno': (
      'lib/features/rituals/day_oracle_screen.dart',
      'arcano_sommario',
      'arcano_responso',
      'arcano_provenienza',
    ),
    'Runa del Tramonto': (
      'lib/features/rituals/sunset_rune_screen.dart',
      'sunset_risposta',
      'sunset_voce_uno',
      'sunset_provenienza',
    ),
    'Sigillo del Sogno': (
      'lib/features/rituals/dream_rite_screen.dart',
      'dream_message_title',
      'dream_message',
      'dream_provenienza',
    ),
  };

  test('ogni Dono porta i suoi strati, e nell ordine dettato', () {
    var guardati = 0;
    final storti = <String>[];
    final tavola = <String>[];
    for (final voce in doni.entries) {
      final (file, risposta, testo, fonte) = voce.value;
      final sorgente = File(file).readAsStringSync();
      guardati++;
      final dovePrima = sorgente.indexOf("Key('$risposta')");
      final doveTesto = sorgente.indexOf("Key('$testo')");
      final doveFonte = sorgente.indexOf("Key('$fonte')");
      tavola.add('${voce.key}: risposta $dovePrima, testo $doveTesto, '
          'fonte $doveFonte');
      if (dovePrima < 0) {
        storti.add('${voce.key}: non mostra piu la sua risposta "$risposta"');
        continue;
      }
      if (doveTesto < 0) {
        storti.add('${voce.key}: non mostra piu il suo testo "$testo"');
        continue;
      }
      if (doveFonte < 0) {
        storti.add('${voce.key}: non porta nessuna fonte "$fonte", quindi '
            'chiede di essere creduto');
        continue;
      }
      if (doveTesto < dovePrima) {
        storti.add('${voce.key}: il testo viene PRIMA della risposta');
      }
      if (doveFonte < doveTesto) {
        storti.add('${voce.key}: la fonte viene PRIMA del testo, e la legge '
            'la vuole breve e in fondo');
      }
    }
    // ignore: avoid_print
    print('ORDINE CQ VOCE 2.01: Doni guardati $guardati'
        '${tavola.map((r) => "${String.fromCharCode(10)}  $r").join()}');
    cardinaleMinimo(guardati, 4,
        cosa: 'schermate dei Doni guardate (Alba e Soffio ne condividono una)',
        perche: 'Se una schermata sparisse dall elenco la sua gerarchia '
            'smetterebbe di essere sorvegliata senza che nessuno se ne '
            'accorga.');
    expect(storti, isEmpty,
        reason: 'questi Doni non rispettano la legge dei testi:'
            '${String.fromCharCode(10)}${storti.join(String.fromCharCode(10))}');
  });

  test('e nessuno di loro annuncia piu un rito', () {
    // **LA VOCE 2.03 HA TOLTO LE TRE RIGHE**, e questa riga impedisce che
    // tornino da una porta laterale: la legge dei testi e quella tolta sono
    // la stessa legge, e sorvegliarle insieme le tiene d'accordo.
    final conIlRito = <String>[];
    for (final voce in doni.entries) {
      final sorgente = codiceSenzaTesto(File(voce.value.$1).readAsStringSync());
      if (sorgente.contains('LeTreRigheDelRito(')) conIlRito.add(voce.key);
    }
    // ignore: avoid_print
    print('ORDINE CQ VOCE 2.01: Doni che annunciano ancora un rito '
        '${conIlRito.length}');
    expect(conIlRito, isEmpty,
        reason: 'questi Doni annunciano di nuovo un rito: ${conIlRito.join(", ")}');
  });
}
