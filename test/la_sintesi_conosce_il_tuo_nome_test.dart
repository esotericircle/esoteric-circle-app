// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LA SINTESI CONOSCE LA PERSONA COME LA CONOSCONO I MAESTRI.** Ordine EE
/// voce 09, 23 settembre 2026.
///
/// **Il fatto del fondatore, verbatim**: *"nel confronto dei maestri alla
/// fine, nel riepilogo, mi scrive che non conosce il mio nome"*. Nella stessa
/// schermata, sulla stessa cattura, Aura e Caligo lo chiamavano **Mauro**.
///
/// **La causa, e non era il modello.** `synthesisInstruction` riceveva la
/// sola forma di cortesia e si costruiva un `UserProfile` **vuoto** per il
/// blocco di cortesia. Un profilo senza nome fa scrivere al blocco *"Non
/// conosci ancora il nome della persona. Puoi chiederglielo"*
/// (`il_blocco_di_cortesia.dart:35`), e il modello ha obbedito: ha chiesto
/// il nome. **I Maestri il profilo ce l'hanno**, perche' `reply` lo riceve;
/// la sintesi era l'unica chiamata della catena a non averlo.
///
/// **Padre: PROVENIENZA IGNOTA.** `synthesize` nasce senza il profilo e
/// nessun ordine risulta aver messo a confronto la sua firma con quella di
/// `reply`.
void main() {
  final mauro = UserProfile(
    displayName: 'Mauro',
    courtesyForm: CourtesyForm.masculine,
  );

  test('col profilo, l\'istruzione della sintesi porta il nome', () {
    final istruzione = MaestroPersona.synthesisInstruction(profilo: mauro);
    final conosce = istruzione.contains('Mauro');
    final dichiaraDiNonSapere = istruzione.contains('Non conosci ancora');
    print('ORDINE EE VOCE 09: la sintesi conosce il nome $conosce, '
        'dichiara di non saperlo $dichiaraDiNonSapere');
    expect(conosce, isTrue,
        reason: 'l\'istruzione della sintesi non porta il nome della persona, '
            'quindi la sintesi non puo\' usarlo');
    expect(dichiaraDiNonSapere, isFalse,
        reason: 'l\'istruzione dice al modello che il nome non si conosce, '
            'mentre l\'app lo conosce: e\' la riga che ha fatto scrivere '
            '"Caro, non conosco il tuo nome, ma se vuoi puoi dirmelo"');
  });

  test('e senza profilo si comporta come prima, senza inventare un nome', () {
    // **L'altra meta'.** Chi non ha ancora dato il nome esiste, e la sintesi
    // non deve fingere di conoscerlo: deve poterlo chiedere, come faceva.
    final istruzione = MaestroPersona.synthesisInstruction();
    print('ORDINE EE VOCE 09, senza profilo: dichiara di non sapere '
        '${istruzione.contains('Non conosci ancora')}');
    expect(istruzione.contains('Non conosci ancora'), isTrue,
        reason: 'chi non ha dato il nome non deve sentirsi chiamare con un '
            'nome che nessuno ha detto');
  });

  test('la sintesi riceve la persona come la ricevono i Maestri', () {
    // **Senza questa, le altre due restano verdi a vuoto**: l'istruzione
    // potrebbe saper leggere un profilo che nessuno le passa mai. Si guarda
    // che la firma lo preveda, come la prevede quella della chat.
    final istruzioneConNome =
        MaestroPersona.synthesisInstruction(profilo: mauro);
    final istruzioneSenza = MaestroPersona.synthesisInstruction();
    print('ORDINE EE VOCE 09: con nome ${istruzioneConNome.length} caratteri, '
        'senza ${istruzioneSenza.length}');
    expect(istruzioneConNome, isNot(equals(istruzioneSenza)),
        reason: 'passare il profilo non cambia l\'istruzione: il parametro '
            'c\'e\' ma non arriva da nessuna parte');
  });
}
