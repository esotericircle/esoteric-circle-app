// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/features/maestri/live/la_voce_che_tace.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL MICROFONO DEL LIVE SI RIAPRE QUANDO LA VOCE DEL MAESTRO TACE
/// DAVVERO.** Ordine ES voce 22, 30 settembre 2026.
///
/// Sul Realme, venti domande dette dalle casse del PC con la stanza
/// registrata dal microfono del PC (`docs/collaudo/ES/live_realme.txt`): il
/// telefono tornava ad ascoltare 700 millesimi dopo il segnale del volto, e
/// nei turni ordinari la voce di Medora continuava da 1,3 a 2,1 secondi dopo
/// quel segnale (dopo dieci risposte su venti si sentiva ancora per piu' di
/// mezzo secondo a microfono riaperto); in un turno il segnale e' arrivato a
/// 16,2 secondi su 22,8 di voce. Chi parlava
/// appena il Maestro sembrava aver finito gli parlava sopra, e su due domande
/// sentite a pezzi chi trascrive ha scritto una domanda mai detta.
///
/// Qui si misura la regola con i numeri di quella sessione: quanto prima
/// della fine vera della voce si riapre il microfono.
void main() {
  /// Simula la traccia ricevuta dal volto letta ogni 80 millesimi: voce per
  /// [voce] dal momento del segnale, con una pausa fra due frasi di [pausa]
  /// a meta', poi silenzio. Torna dopo quanto la regola riapre il microfono.
  Duration riapre({
    required Duration voce,
    Duration pausa = Duration.zero,
    bool conStatistiche = true,
  }) {
    final regola = LaVoceCheTace();
    var energia = 0.0;
    var durata = 0.0;
    const passo = LaVoceCheTace.passo;
    final meta = voce ~/ 2;
    for (var t = Duration.zero;; t += passo) {
      final parla = t < voce && !(t >= meta && t < meta + pausa);
      // La traccia suona sempre campioni; la voce porta energia, il silenzio
      // quasi niente.
      durata += passo.inMilliseconds / 1000;
      energia += (parla ? 1e-3 : 1e-7) * passo.inMilliseconds / 1000;
      if (regola.lettura(
          energia: conStatistiche ? energia : null,
          durata: conStatistiche ? durata : null,
          adesso: t)) {
        return t;
      }
      if (t > const Duration(seconds: 30)) {
        fail('la regola non riapre mai il microfono');
      }
    }
  }

  test(
      'con la coda misurata sul Realme il microfono non si riapre mentre il '
      'Maestro parla', () {
    // Le code viste nella sessione, con la registrazione messa sull'orologio
    // del telefono: da 1,3 a 2,1 secondi dopo il segnale.
    const code = [1300, 1400, 1500, 1600, 1700, 1800, 1900, 2000, 2100];
    var prima = 0;
    var ritardoMassimo = Duration.zero;
    for (final ms in code) {
      final voce = Duration(milliseconds: ms);
      final quando = riapre(voce: voce);
      if (quando < voce) prima++;
      final ritardo = quando - voce;
      if (ritardo > ritardoMassimo) ritardoMassimo = ritardo;
    }
    // Con la regola di prima: 700 millesimi fissi dopo il segnale.
    final conIlFisso =
        code.where((ms) => ms > 700).length; // riapriva prima della fine
    print('ORDINE ES VOCE 22, IL MICROFONO E LA VOCE: code della voce dopo il '
        'segnale ${code.length} (da ${code.first} a ${code.last} ms); '
        'microfono riaperto mentre il Maestro parla ancora, prima '
        '$conIlFisso su ${code.length} (700 ms fissi), dopo $prima su '
        '${code.length}; dopo la fine della voce si aspetta al piu\' '
        '${ritardoMassimo.inMilliseconds} ms');
    expect(prima, 0);
    // E non si aspetta piu' di un secondo e un decimo dopo la fine vera.
    expect(
        ritardoMassimo, lessThanOrEqualTo(const Duration(milliseconds: 1100)));
  });

  test('la pausa fra due frasi non e\' la fine', () {
    // Una risposta ancora lunga sei secondi con mezzo secondo di pausa fra
    // due frasi: il microfono resta chiuso fino alla fine.
    const voce = Duration(seconds: 6);
    final quando = riapre(voce: voce, pausa: const Duration(milliseconds: 600));
    expect(quando, greaterThanOrEqualTo(voce));
  });

  test('senza statistiche si aspetta la coda misurata, e c\'e\' un tetto', () {
    expect(riapre(voce: const Duration(seconds: 2), conStatistiche: false),
        greaterThanOrEqualTo(LaVoceCheTace.codaSenzaMisura));
    expect(LaVoceCheTace.codaSenzaMisura,
        greaterThanOrEqualTo(const Duration(milliseconds: 3000)));
    // Una traccia che non tace mai non tiene chiuso il microfono per sempre.
    expect(riapre(voce: const Duration(seconds: 60)),
        lessThanOrEqualTo(LaVoceCheTace.tetto));
  });

  test('il segnale del volto non vale prima della fine dell\'audio', () {
    // Il turno visto sul Realme: primo suono a 660 ms, 22.783 ms di voce, e
    // il volto dice "ho finito" a 16.158 ms.
    final manca = LaVoceCheTace.mancaAllaFineMinima(
        primoSuono: const Duration(milliseconds: 660),
        secondiDiVoce: 22.783,
        trascorso: const Duration(milliseconds: 16158));
    print('ORDINE ES VOCE 22, IL SEGNALE IN ANTICIPO: al segnale mancavano '
        '${manca.inMilliseconds} ms alla fine piu\' vicina possibile della '
        'voce; prima si aspettavano 700 ms, dopo ${manca.inMilliseconds} e '
        'poi il silenzio della traccia');
    expect(manca, const Duration(milliseconds: 7285));
    // Un segnale arrivato dopo la fine dell'audio non aggiunge attesa.
    expect(
        LaVoceCheTace.mancaAllaFineMinima(
            primoSuono: const Duration(milliseconds: 300),
            secondiDiVoce: 20,
            trascorso: const Duration(milliseconds: 21500)),
        Duration.zero);
  });

  test('la schermata del LIVE passa dalla regola, e il tempo fisso non c\'e\'',
      () {
    final fonte = File('lib/features/maestri/live/schermata_live.dart')
        .readAsStringSync();
    final dillo = fonte.substring(fonte.indexOf('Future<void> _dillo('),
        fonte.indexOf('Future<void> _ascoltaQuandoSiSente('));
    expect(dillo.contains('LaVoceCheTace.mancaAllaFineMinima('), isTrue);
    expect(dillo.contains('await _aspettaCheTaccia(s.lavoratore);'), isTrue);
    expect(dillo.contains('Duration(milliseconds: 700)'), isFalse,
        reason: 'la coda fissa di 700 ms e\' tornata');
    final aspetta = fonte.substring(
        fonte.indexOf('Future<void> _aspettaCheTaccia('),
        fonte.indexOf('> _laVoceGiaPronta('));
    expect(aspetta.contains('getReceiverStats()'), isTrue);
    expect(aspetta.contains('voce.lettura('), isTrue);
  });
}
