// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/chat/la_risposta_nel_merito.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'sorgenti_di_lib.dart';

/// **IL MAESTRO RISPONDE SEMPRE NEL MERITO.** Ordine EB voci 02, 05 e 06, 21
/// settembre 2026.
///
/// **Il fatto**: due volte di fila, alla stessa domanda, il fondatore ha
/// ricevuto *"Le carte vogliono essere viste, non raccontate. Vieni,
/// stendiamole insieme."* con un pulsante, e nessuna risposta. Parole sue:
/// *"l'utente paga per ogni risposta e le risposte devono essere corrette e
/// coerenti"*.
///
/// **La cura ha due meta', e questa prova guarda la seconda.** Il pulsante lo
/// governa il cancello deterministico di `LaRichiestaDiUnArte`, provato in
/// `il_pulsante_solo_se_lo_chiedi_test.dart`. Qui si pretende che **anche il
/// modello** riceva la regola: un cancello stretto non serve a niente se poi
/// il Maestro, con parole sue, propone la stessa funzione invece di
/// rispondere.
void main() {
  final profilo = UserProfile(displayName: 'Mauro');
  const memoria = MaestroMemory.empty;

  test('i tre Maestri ricevono tutti la regola, e nessuno ne e\' escluso', () {
    const maestri = Maestro.values;
    cardinaleMinimo(maestri.length, 3,
        cosa: 'Maestri del cerchio',
        perche: 'Se l\'elenco si svuotasse, questa prova direbbe di si\' a '
            'nessuno.');
    final senza = <String>[];
    for (final m in maestri) {
      final istruzione = MaestroPersona.systemInstruction(
          maestro: m, profile: profilo, memory: memoria);
      if (!istruzione.contains(LaRispostaNelMerito.intestazione)) {
        senza.add(m.name);
      }
    }
    print('ORDINE EB VOCI 02, 05 e 06: Maestri ${maestri.length}, '
        'senza la regola ${senza.length}');
    expect(senza, isEmpty,
        reason: 'questi Maestri non ricevono la regola della risposta nel '
            'merito: $senza');
  });

  test('la regola dice tutte e cinque le cose che deve dire', () {
    const blocco = LaRispostaNelMerito.perIlModello;
    print('ORDINE EB: il blocco e\' lungo ${blocco.length} caratteri');
    final pretese = <String, String>{
      // Voce 02: nessun invito prende il posto della risposta.
      'al posto della risposta': 'non vieta di proporre una funzione invece '
          'di rispondere, ed e\' il difetto della voce 02',
      // Voce 02: se il responso c'e' gia', si interpreta quello.
      'interpreta quello': 'non dice di interpretare il responso che la '
          'persona ha gia\' in mano',
      // Voce 06: quando mancano i dati, il Maestro li chiede.
      'chiedilo': 'non dice di chiedere cio\' che manca, e il Maestro '
          'rimandera\' altrove',
      // Voce 05: niente ripetizioni.
      'Non ripetere una frase': 'non vieta di ripetere una frase gia\' detta',
      // Voce 05: niente proposte gia' rifiutate.
      'ha rifiutato': 'non dice di tenere conto di un rifiuto',
    };
    final mancanti = <String>[];
    pretese.forEach((pezzo, perche) {
      if (!blocco.contains(pezzo)) mancanti.add(perche);
    });
    expect(mancanti, isEmpty, reason: mancanti.join('\n'));
  });

  test('la regola sta in un punto solo di tutto il codice', () {
    // **Due copie divergono al primo ritocco**, ed e' la ragione per cui il
    // confine del responso e il blocco di cortesia vivono ognuno in un file
    // suo. Si contano le occorrenze dell'intestazione nel codice, **senza i
    // commenti**: questo stesso commento la nomina.
    var quante = 0;
    final dove = <String>[];
    for (final f in sorgentiDiLib()) {
      final testo = senzaCommenti(f.readAsStringSync());
      final n = LaRispostaNelMerito.intestazione.allMatches(testo).length;
      if (n > 0) {
        quante += n;
        dove.add('${f.path}: $n');
      }
    }
    print('ORDINE EB: l\'intestazione compare $quante volte, in $dove');
    expect(quante, 1,
        reason: 'la regola della risposta nel merito e\' scritta $quante '
            'volte: $dove. Due copie divergono al primo ritocco, e da quel '
            'momento i tre Maestri obbediscono a regole diverse');
  });
}
