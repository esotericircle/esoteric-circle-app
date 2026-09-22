// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **IL GENERE DELLE CARTE ARRIVA A TUTTI E TRE I MAESTRI.** Ordine EE voce
/// 10, 23 settembre 2026.
///
/// **Il fatto, sulla cattura del Consiglio**: Caligo scriveva *"la Tre di
/// Denari"* e *"La Tre di Coppe"*. Il numero di una carta e' maschile: **il**
/// Tre di Denari.
///
/// **Nessuna regola lo diceva.** L'app il genere lo sa dove scrive lei,
/// `ReversedAgreement` in `tarot_card.dart`, ma i nomi delle carte dentro le
/// letture li scrive il modello, e a lui non arrivava niente: *carta* e'
/// femminile, *tre* no, e la concordanza in italiano la decide il numero che
/// fa da nome. **Padre: PROVENIENZA IGNOTA**, la regola non e' mai esistita.
///
/// **Si guarda che la regola ARRIVI, non che il modello la rispetti.** Che la
/// rispetti si misura col collaudo su Gemini vero, e il suo numero sta nel
/// rapporto: una prova senza rete puo' dire soltanto se la regola e' partita,
/// ed e' cio' che l'ordine EC ha insegnato a distinguere.
void main() {
  test('la regola del genere arriva a tutti e tre i Maestri', () {
    const maestri = Maestro.values;
    cardinaleMinimo(maestri.length, 3,
        cosa: 'Maestri che possono nominare una carta',
        perche: 'La carta puo\' comparire in qualunque lettura: se i Maestri '
            'si riducessero, questa prova guarderebbe meno di quello che '
            'dice.');

    final profilo = UserProfile(courtesyForm: CourtesyForm.masculine);
    final senza = <String>[];
    for (final maestro in maestri) {
      final istruzione = MaestroPersona.systemInstruction(
        maestro: maestro,
        profile: profilo,
        memory: MaestroMemory.empty,
      );
      if (!istruzione.contains('il Tre di Denari')) senza.add(maestro.id);
    }
    print('ORDINE EE VOCE 10: Maestri guardati ${maestri.length}, '
        'senza la regola del genere ${senza.length}');
    expect(senza, isEmpty,
        reason: 'a questi Maestri non arriva la regola del genere delle '
            'carte, quindi possono scrivere "la Tre di Denari": $senza');
  });

  test('e arriva anche alla sintesi comparativa, che le carte le nomina', () {
    final istruzione = MaestroPersona.synthesisInstruction();
    final arriva = istruzione.contains('il Tre di Denari');
    print('ORDINE EE VOCE 10: la regola arriva alla sintesi $arriva');
    expect(arriva, isTrue,
        reason: 'la sintesi comparativa nomina le carte come i Maestri, e '
            'senza la regola puo\' sbagliare il genere come sbagliavano loro');
  });

  test('la regola dice il maschile E il femminile delle figure', () {
    // **Senza questa, la regola potrebbe dire "tutto maschile"** e far
    // scrivere "il Regina di Coppe", che e' un difetto peggiore di quello
    // che cura.
    final istruzione = MaestroPersona.synthesisInstruction();
    print('ORDINE EE VOCE 10: la regola nomina la Regina '
        '${istruzione.contains('la Regina')}');
    expect(istruzione.contains('la Regina'), isTrue,
        reason: 'la regola rende tutto maschile e non dice che le figure '
            'seguono il loro genere: si scriverebbe "il Regina di Coppe"');
  });
}
