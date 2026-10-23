import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **QUANTE FESTE SI PERDONO.** Ordine CZ, voce 01, misura prima della cura.
///
/// **Parole del fondatore**: raggiunge traguardi e non vede nessuna festa.
/// Sente il suono degli Eos e vede la perla accendersi, e nient'altro. Ha
/// anche provato di proposito: e' entrato nel sentiero di un Maestro, ha letto
/// quale gesto mancava, ha compiuto quel gesto. **Eos accreditati, perla
/// accesa, nessuna festa.**
///
/// **L'ordine chiede il numero prima della correzione**, e questa prova lo
/// produce: su un anno di uso onesto, quanti traguardi si accendono e quanti
/// di quelli superano `meritaLaScena`.
///
/// **Non e' una guardia**: e' una misura, e resta a documentare il difetto col
/// suo numero. La guardia che impedisce il ritorno e' un'altra.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('LA MISURA: quanti traguardi accesi ottengono la loro festa', () async {
    var accesi = 0;
    var conFesta = 0;
    var persiPerLaScala = 0;
    var persiPerIlTetto = 0;
    var persiPerLaStrada = 0;

    // Un anno, un giorno alla volta, con le venti arti compiute ogni giorno:
    // e' l'uso piu' generoso possibile, quindi il numero che ne esce e' il
    // migliore dei casi, non il peggiore.
    for (var g = 0; g < 365; g++) {
      SharedPreferences.setMockInitialValues(const {});
      var adesso = DateTime(2026, 1, 1).add(Duration(days: g));
      final diario = DiarioDelCammino(orologio: () => adesso);
      await diario.carica();

      for (final gesto in const [
        'carta_natale', 'ascendente', 'oroscopo', 'stesa', 'oracolo',
        'sinastria', 'angelo_custode', 'alba', 'soffio', 'viso', 'archetipo',
        'due_volti', 'meditazione', 'gettata', 'tramonto', 'sogno',
        'runa_girata', 'sigillo', 'animale_guida', 'bosco',
      ]) {
        await diario.segna(gesto);
        final stato = diario.statoDelCammino(
            segno: Zodiac.leo,
            pezziDellIdentita: const {
              'carta_natale', 'viso', 'animale_guida',
            });
        for (final t in await diario.quelliCheSiAccendono(stato)) {
          accesi++;
          if (diario.meritaLaScena(t)) {
            conFesta++;
          } else {
            // **PERCHE' NON L'HA MERITATA, una ragione alla volta.** Senza
            // questa distinzione il numero direbbe che le feste si perdono e
            // non direbbe quale delle tre condizioni le sta mangiando, che e'
            // la sola cosa che serve a chi deve correggere.
            if (!diario.laStradaELibera) {
              persiPerLaStrada++;
            } else {
              final suoSentiero = Sentiero.values.where(
                  (s) => Sentieri.di(s).any((x) => x.id == t.id));
              final eIlProssimo = suoSentiero
                  .any((s) => diario.prossimoDi(s)?.id == t.id);
              if (!eIlProssimo) {
                persiPerLaScala++;
              } else {
                persiPerIlTetto++;
              }
            }
          }
          await diario.accendi(t.id);
          await diario.congeda(t.id);
        }
      }
      adesso = adesso.add(const Duration(days: 1));
    }

    final quota = accesi == 0 ? 0.0 : conFesta * 100 / accesi;
    // ignore: avoid_print
    print('ORDINE CZ VOCE 01, LA MISURA:\n'
        '  traguardi accesi in un anno: $accesi\n'
        '  con la loro festa:           $conFesta (${quota.toStringAsFixed(1)} per cento)\n'
        '  persi per la SCALA lineare:  $persiPerLaScala\n'
        '  persi per il TETTO del giorno: $persiPerIlTetto\n'
        '  persi per la STRADA occupata: $persiPerLaStrada');

    // **IL CARDINALE MINIMO**: senza traguardi accesi questa misura non ha
    // guardato niente e direbbe zero su zero.
    expect(accesi, greaterThan(50),
        reason: 'in un anno si sono accesi solo $accesi traguardi: la '
            'simulazione non ha camminato, e il numero che segue non vale');
  });
}
