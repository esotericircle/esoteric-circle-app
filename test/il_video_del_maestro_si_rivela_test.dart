import 'dart:io';

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/rivelazione_in_video.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/onboarding/widgets/maestro_card.dart';
import 'package:esoteric_circle/features/onboarding/widgets/velo_di_rivelazione.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL VIDEO DEL MAESTRO AL POSTO DELL'IMMAGINE. Ordine BQ, voci 2 e 3.
///
/// **Perche' le misure passano da un lettore FINTO.** In una prova headless non
/// c'e' nessuna piattaforma che decodifichi un filmato, quindi col lettore vero
/// ogni misura di questa voce sarebbe stata "il video non parte": il ritardo di
/// avvio, il passaggio all'immagine e i lettori liberati non si sarebbero potuti
/// misurare affatto. Il finto sta dietro la stessa porta del vero, quindi cio'
/// che si misura e' il comportamento della SCENA, non quello del lettore.
///
/// **E il lettore vero non resta senza prova**: l'ultimo gruppo monta la scena
/// con la fabbrica predefinita, cioe' `video_player`, e pretende che in assenza
/// di piattaforma la scena mostri comunque l'immagine.
void main() {
  /// Il lettore finto. Conta quanti ne nascono e quanti ne muoiono, e sa dire
  /// il momento esatto in cui gli e' stato chiesto di aprire.
  ///
  /// **Il tempo si legge dall'orologio della prova e non da quello vero**: la
  /// regola di casa vieta i numeri indovinati, e un orologio a muro misura la
  /// macchina. `tester.binding.clock` avanza solo quando la prova lo fa
  /// avanzare, quindi il ritardo misurato e' quello che il codice introduce.
  late _Banco banco;

  setUp(() => banco = _Banco());

  Widget scena(Maestro maestro,
          {bool riduciMovimento = false, FabbricaDiLettori? fabbrica}) =>
      MediaQuery(
        data: MediaQueryData(disableAnimations: riduciMovimento),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: MaestroCardReveal(
              maestro: maestro,
              palette: MaestroPalette.forKey(ThemeKey.of(maestro)),
              reduceMotion: riduciMovimento,
              fabbricaDelVideo: fabbrica ?? banco.crea,
            ),
          ),
        ),
      );

  group('BQ.02, il video parte al posto dell\'immagine', () {
    testWidgets('Il video parte entro 400 millesimi dalla rivelazione',
        (tester) async {
      // **IL TEMPO SI CONTA A FOTOGRAMMI POMPATI, non con un orologio a muro.**
      // Un orologio dentro una prova misura la macchina, e questo repository lo
      // ha gia' pagato una volta nell'ordine BO. Qui il tempo avanza solo
      // quando la prova lo fa avanzare, sedici millesimi per volta, quindi il
      // numero letto e' il ritardo che il CODICE introduce e nient'altro.
      const passo = Duration(milliseconds: 16);
      const tetto = Duration(milliseconds: 400);
      for (final maestro in Maestro.values) {
        banco = _Banco();
        await tester.pumpWidget(scena(maestro));
        var trascorso = Duration.zero;
        while (banco.aperti == 0 && trascorso < tetto) {
          await tester.pump(passo);
          trascorso += passo;
        }
        // ignore: avoid_print
        print('ORDINE BQ VOCE 2: ${maestro.id} il video parte dopo '
            '${trascorso.inMilliseconds} millesimi');
        expect(banco.aperti, 1,
            reason: '${maestro.id}: passati ${trascorso.inMilliseconds} '
                'millesimi e nessun lettore ha ancora ricevuto l\'ordine di '
                'aprire. Il tetto e\' ${tetto.inMilliseconds}');
        expect(trascorso, lessThanOrEqualTo(tetto));
        await tester.pumpWidget(const SizedBox.shrink());
      }
    });

    testWidgets('Ogni Maestro chiede il PROPRIO video', (tester) async {
      for (final maestro in Maestro.values) {
        banco = _Banco();
        await tester.pumpWidget(scena(maestro));
        await tester.pump();
        expect(banco.chiesti.single, RivelazioneInVideo.assetDi(maestro),
            reason: '${maestro.id} chiede un video che non e\' il suo');
        expect(banco.chiesti.single, contains(maestro.id));
        await tester.pumpWidget(const SizedBox.shrink());
      }
    });

    testWidgets('Il video si riproduce una volta sola, senza ciclo',
        (tester) async {
      await tester.pumpWidget(scena(Maestro.medora));
      await tester.pump();
      final lettore = banco.vivi.single;
      expect(lettore.riavvii, 0,
          reason: 'il lettore e\' stato riavviato: allora cicla');
      lettore.finisci();
      await tester.pump();
      expect(lettore.riavvii, 0,
          reason: 'finito il filmato qualcuno lo ha fatto ripartire');
    });

    testWidgets('Alla fine del video l\'immagine non sparisce mai',
        (tester) async {
      // **LA MISURA E' SU OGNI FOTOGRAMMA DELLA TRANSIZIONE, non prima e dopo.**
      // Un nero di un fotogramma solo e' esattamente cio' che si vede a occhio
      // e non si vede in due controlli agli estremi.
      await tester.pumpWidget(scena(Maestro.aura));
      await tester.pump();
      final lettore = banco.vivi.single;
      lettore.pronto = true;
      await tester.pump();
      expect(find.byType(Image), findsOneWidget,
          reason: 'mentre il video suona l\'immagine deve stare sotto, '
              'altrimenti alla fine c\'e\' un passaggio da fare');
      lettore.finisci();
      var fotogrammi = 0;
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        fotogrammi++;
        expect(find.byType(Image), findsOneWidget,
            reason: 'al fotogramma $i dopo la fine del video l\'immagine non '
                'e\' in albero: li\' lo schermo mostra il nero');
      }
      // ignore: avoid_print
      print('ORDINE BQ VOCE 2: fotogrammi controllati dopo la fine '
          '$fotogrammi');
      expect(fotogrammi, 30);
    });

    testWidgets('Dieci aperture e chiusure non lasciano nessun lettore vivo',
        (tester) async {
      for (var giro = 0; giro < 10; giro++) {
        await tester.pumpWidget(scena(Maestro.caligo));
        await tester.pump();
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
      }
      // ignore: avoid_print
      print('ORDINE BQ VOCE 2: lettori nati ${banco.nati}, chiusi '
          '${banco.chiusi}, vivi ${banco.vivi.length}');
      expect(banco.nati, 10,
          reason: 'dieci aperture della scena devono creare dieci lettori');
      expect(banco.vivi, isEmpty,
          reason: 'dopo dieci aperture e chiusure restano ${banco.vivi.length} '
              'lettori vivi: ognuno tiene un decodificatore');
    });
  });

  group('BQ.02, l\'app che va dietro non lascia un fotogramma congelato', () {
    testWidgets('Uscendo dall\'app il lettore si chiude e torna l\'immagine',
        (tester) async {
      // La caccia alla regola viene dalla ricognizione: l'intro CHIUDE il
      // filmato quando l'app passa dietro, invece di metterlo in pausa. Qui
      // vale ancora di piu', perche' sotto c'e' gia' il ritratto del Maestro.
      await tester.pumpWidget(scena(Maestro.medora));
      await tester.pump();
      expect(banco.vivi, hasLength(1));
      tester.binding
          .handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      expect(banco.vivi, isEmpty,
          reason: 'l\'app e\' passata dietro e il lettore e\' rimasto vivo: '
              'al ritorno si vedrebbe un fotogramma congelato');
      expect(find.byType(Image), findsOneWidget,
          reason: 'chiuso il filmato deve riapparire il ritratto');
    });
  });

  group('BQ.03, se il video non parte l\'immagine c\'e\' lo stesso', () {
    testWidgets('Col file assente la scena mostra l\'immagine', (tester) async {
      await tester.pumpWidget(scena(Maestro.medora, fabbrica: _Banco().creaCieco));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      expect(find.byType(Image), findsOneWidget,
          reason: 'il video non e\' partito e la scena e\' rimasta vuota: '
              'e\' la promessa mancata che questa voce esiste per impedire');
      // **E NON BASTA CHE L'IMMAGINE CI SIA: non deve esserci niente sopra.**
      // Un riquadro nero al posto del filmato lascerebbe l'immagine in albero e
      // lo schermo nero lo stesso, cioe' farebbe passare una prova che guarda
      // solo l'albero. Quando il filmato non e' pronto il velo disegna il
      // NULLA, e questa riga lo pretende.
      expect(
        find.descendant(
          of: find.byType(VeloDiRivelazione),
          matching: find.byType(ColoredBox),
        ),
        findsNothing,
        reason: 'col video non pronto il velo disegna qualcosa sopra '
            'l\'immagine: li\' lo schermo mostra quel qualcosa e non il '
            'Maestro',
      );
      expect(tester.takeException(), isNull,
          reason: 'un file mancante non deve lanciare niente in faccia a '
              'nessuno');
    });

    testWidgets('Con Riduci Movimento nessun lettore viene creato',
        (tester) async {
      await tester.pumpWidget(scena(Maestro.aura, riduciMovimento: true));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(banco.nati, 0,
          reason: 'con Riduci Movimento sono nati ${banco.nati} lettori: un '
              'filmato aperto e fermo occupa comunque un decodificatore');
      expect(find.byType(Image), findsOneWidget,
          reason: 'con Riduci Movimento l\'immagine deve esserci subito');
    });

    testWidgets('Anche col lettore VERO la scena non resta mai vuota',
        (tester) async {
      // Nessuna fabbrica finta: qui c'e' `video_player`, che senza piattaforma
      // non inizializza niente. E' il caso reale di questo contenitore, ed e'
      // anche il caso del telefono a cui manca il file.
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Center(
              child: MaestroCardReveal(
                maestro: Maestro.caligo,
                palette: MaestroPalette.caligo,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(Image), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });
  });

  group('BQ.01, i percorsi che i file dovranno avere', () {
    test('Il percorso si compone dall\'identificativo, non da un elenco', () {
      final visti = <String>{};
      for (final maestro in Maestro.values) {
        final asset = RivelazioneInVideo.assetDi(maestro);
        expect(asset, startsWith(RivelazioneInVideo.cartella));
        expect(asset, endsWith('.mp4'));
        expect(asset, asset.toLowerCase(),
            reason: 'nessuna maiuscola nel nome di un asset');
        expect(asset.contains(' '), isFalse,
            reason: 'nessuno spazio nel nome di un asset: l\'originale di '
                'Medora si chiamava "Medora Sorceress Video.mp4"');
        expect(visti.add(asset), isTrue,
            reason: 'due Maestri chiedono lo stesso video');
      }
      expect(visti, hasLength(Maestro.values.length));
    });

    test('La cartella e\' dichiarata nel pubspec anche da vuota', () {
      // Senza questa riga i tre filmati non entrerebbero nel pacchetto il
      // giorno che arrivano, e nessuno se ne accorgerebbe guardando il codice.
      final pubspec = _leggi('pubspec.yaml');
      expect(pubspec, contains('- ${RivelazioneInVideo.cartella}'),
          reason: 'la cartella dei video non e\' dichiarata fra gli asset');
    });
  });
}

String _leggi(String percorso) =>
    // ignore: avoid_slow_async_io
    File(percorso).readAsStringSync();

/// Il banco dei lettori finti: chi nasce, chi muore, cosa gli e' stato chiesto.
class _Banco {
  final List<String> chiesti = [];
  final List<_LettoreFinto> vivi = [];
  int nati = 0;
  int chiusi = 0;
  int aperti = 0;

  LettoreDiRivelazione crea(String asset) {
    chiesti.add(asset);
    nati++;
    final l = _LettoreFinto(this);
    vivi.add(l);
    return l;
  }

  /// Un lettore che non ce la fa mai: il file non c'e', oppure il codec e'
  /// rifiutato. Non lancia, dichiara solo che non e' pronto.
  LettoreDiRivelazione creaCieco(String asset) {
    chiesti.add(asset);
    nati++;
    final l = _LettoreFinto(this)..cieco = true;
    vivi.add(l);
    return l;
  }
}

class _LettoreFinto implements LettoreDiRivelazione {
  _LettoreFinto(this.banco);

  final _Banco banco;
  bool cieco = false;

  @override
  bool pronto = false;
  bool _finito = false;
  int riavvii = 0;
  VoidCallback? _quandoCambia;

  @override
  bool get finito => _finito;

  @override
  Future<void> apri() async {
    if (banco.aperti > 0) riavvii++;
    banco.aperti++;
    if (!cieco) pronto = true;
    _quandoCambia?.call();
  }

  void finisci() {
    _finito = true;
    _quandoCambia?.call();
  }

  @override
  void ascolta(VoidCallback quandoCambia) => _quandoCambia = quandoCambia;

  @override
  Widget disegna() => const ColoredBox(color: Color(0xFF000000));

  @override
  void chiudi() {
    banco.chiusi++;
    banco.vivi.remove(this);
    _quandoCambia = null;
  }
}
