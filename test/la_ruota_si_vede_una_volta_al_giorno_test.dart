import 'package:esoteric_circle/core/horoscope/la_ruota_di_oggi.dart';
import 'package:esoteric_circle/features/scene/la_scena_in_video.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **LA RUOTA DELL'OROSCOPO SI VEDE UNA VOLTA AL GIORNO.** Ordine GB voce 02,
/// 22 ottobre 2026: il filmato della ruota si vede per intero la prima volta
/// che la persona apre l'Oroscopo in un giorno civile, e alle aperture
/// seguenti dello stesso giorno la scena parte gia' ferma.
///
/// Due pezzi separati, provati qui insieme: [LaRuotaDiOggi] (la memoria del
/// giorno, stessa forma di `LaLungaDiOggi`) e `RegiaDellaScena.fermaSubito`
/// (che deve chiudere la porta ad [RegiaDellaScena.avvia]: anche chiamato
/// dopo, non deve mai aprire il lettore. Lo prova una fabbrica che conta le
/// sue chiamate, non il solo stato dei getter, che a lettore mai aperto
/// sarebbero ferma comunque).
class _LettoreCheConta implements LettoreDiScena {
  int aperture = 0;
  @override
  Future<void> apri() async => aperture++;
  @override
  bool get pronto => true;
  @override
  bool get fallito => false;
  @override
  bool get cominciato => true;
  @override
  bool get finito => false;
  @override
  void ascolta(VoidCallback? quandoCambia) {}
  @override
  Future<void> volume(double quanto) async {}
  @override
  Future<void> avvia() async {}
  @override
  Future<void> sospendi() async {}
  @override
  Widget disegna() => const SizedBox.shrink();
  @override
  void chiudi() {}
}

void main() {
  group('LaRuotaDiOggi', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      LaRuotaDiOggi.dimentica();
    });

    test('un giorno mai segnato non e\' visto', () async {
      final oggi = DateTime(2026, 10, 22);
      expect(await LaRuotaDiOggi.vistaOggi(oggi), isFalse,
          reason: 'un giorno su cui non si e\' mai chiamato segna() deve '
              'valere come "non ancora vista", altrimenti il filmato non '
              'parte mai la prima volta');
    });

    test('segnato oggi, oggi e\' vista', () async {
      final oggi = DateTime(2026, 10, 22);
      await LaRuotaDiOggi.segna(oggi);
      expect(await LaRuotaDiOggi.vistaOggi(oggi), isTrue,
          reason: 'dopo segna() lo stesso giorno deve risultare visto');
    });

    test('segnato ieri, oggi non e\' vista', () async {
      final ieri = DateTime(2026, 10, 21);
      final oggi = DateTime(2026, 10, 22);
      await LaRuotaDiOggi.segna(ieri);
      expect(await LaRuotaDiOggi.vistaOggi(oggi), isFalse,
          reason: 'il giorno civile e\' cambiato: il filmato deve tornare a '
              'vedersi per intero, non restare saltato per sempre');
    });
  });

  // **LA DECISIONE SINCRONA, quella che la schermata usa davvero. Ordine GB
  // voce 02.** Nessun `await` davanti: una sessione appena partita non ha
  // mai letto il disco e deve rispondere "non vista", sempre, altrimenti
  // l'apertura del video si sposta di un giro e le prove della scena
  // (FXA.08, FU.15) che misurano quel giro al centesimo di secondo cadono.
  group('LaRuotaDiOggi.vistaOggiSubito, la decisione sincrona', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      LaRuotaDiOggi.dimentica();
    });

    test('una sessione appena partita non ha mai vista subito, anche se '
        'il disco direbbe di si\'', () async {
      final oggi = DateTime(2026, 10, 22);
      await LaRuotaDiOggi.segna(oggi); // scrive sul disco di una sessione...
      LaRuotaDiOggi.dimentica(); // ...e questa sessione non l'ha ancora letto
      expect(LaRuotaDiOggi.vistaOggiSubito(oggi), isFalse,
          reason: 'senza aver scaldato la memoria di questa sessione, la '
              'decisione sincrona deve restare prudente: si vede il '
              'filmato, come quando il disco non risponde');
    });

    test('segna() scalda la memoria sul colpo, senza aspettare il disco',
        () {
      final oggi = DateTime(2026, 10, 22);
      // Senza await: la riga che conta e' quella prima del primo await di
      // segna(), e deve girare comunque.
      // ignore: unawaited_futures
      LaRuotaDiOggi.segna(oggi);
      expect(LaRuotaDiOggi.vistaOggiSubito(oggi), isTrue,
          reason: 'segna() deve scaldare la memoria di sessione subito, '
              'non solo dopo che il disco ha scritto');
    });

    test('vistaOggiSubito non mente su un giorno diverso da quello '
        'scaldato', () {
      final ieri = DateTime(2026, 10, 21);
      final oggi = DateTime(2026, 10, 22);
      // ignore: unawaited_futures
      LaRuotaDiOggi.segna(ieri);
      expect(LaRuotaDiOggi.vistaOggiSubito(oggi), isFalse);
    });
  });

  group('RegiaDellaScena.fermaSubito', () {
    testWidgets(
        'ferma subito la scena, e un avvia successivo non apre piu\' il '
        'lettore', (tester) async {
      final lettore = _LettoreCheConta();
      final regia = RegiaDellaScena(() => lettore);

      regia.fermaSubito();
      expect(regia.ferma, isTrue,
          reason: 'fermaSubito deve lasciare la scena ferma da subito');
      expect(regia.inCorso, isFalse);
      expect(regia.filmatoInScena, isFalse);

      // Come la schermata vera: didChangeDependencies chiama avvia(context)
      // dopo. Deve trovare la porta gia' chiusa da fermaSubito.
      await tester.pumpWidget(MediaQuery(
        data: const MediaQueryData(size: Size(390, 844)),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(builder: (context) {
            regia.avvia(context);
            return const SizedBox.shrink();
          }),
        ),
      ));
      await tester.pump(RegiaDellaScena.attesaMassima);
      await tester.pump(const Duration(milliseconds: 100));

      expect(lettore.aperture, 0,
          reason: 'fermaSubito non ha chiuso la porta ad avvia: il lettore '
              'e\' stato aperto comunque, e la ruota si rivedrebbe per '
              'intero anche nel giorno gia\' visto');
      expect(regia.ferma, isTrue);
      expect(regia.filmatoInScena, isFalse);
    });

    test('chiamata due volte, la seconda non fa nulla', () {
      final lettore = _LettoreCheConta();
      final regia = RegiaDellaScena(() => lettore);
      regia.fermaSubito();
      regia.fermaSubito();
      expect(regia.ferma, isTrue);
      expect(lettore.aperture, 0);
    });
  });
}
