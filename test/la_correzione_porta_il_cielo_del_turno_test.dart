import 'package:esoteric_circle/core/astro/il_cielo_per_il_maestro.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LA CORREZIONE CORTA PORTA IL CIELO DEL TURNO. Ordine EX voce 07.**
///
/// Al banco finale dell'ordine EX la rete delle certezze ha mandato alla
/// correzione corta la risposta "il primo gennaio 2028 Giove sarà in
/// Vergine", e la correzione ha scritto "Giove in Cancro": non chiama la
/// funzione del cielo, e il fatto lo rimetteva a memoria. Adesso riceve il
/// cielo di oggi e dei giorni chiesti nel turno, dalle stesse effemeridi.
void main() {
  test('l\'istruzione della correzione porta i fatti del cielo del turno', () {
    final cielo = IlCieloPerIlMaestro.oggiInRighe(DateTime(2028, 1, 1, 12));
    expect(cielo, contains('Giove'));
    final istruzione = MaestroPersona.istruzioneDellaCorrezione(
      maestro: Maestro.medora,
      profile: UserProfile.empty,
      correzione: 'Togli la certezza.',
      cieloDelTurno: cielo,
    );
    expect(istruzione, contains(cielo));
    expect(istruzione, contains('IL CIELO DI QUESTO TURNO'));
  });
}
