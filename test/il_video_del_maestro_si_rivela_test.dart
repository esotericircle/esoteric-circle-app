import 'dart:io';

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/rivelazione_in_video.dart';
import 'package:esoteric_circle/features/onboarding/maestro_reveal_screen.dart';
import 'package:esoteric_circle/features/onboarding/widgets/maestro_card.dart';
import 'package:esoteric_circle/features/onboarding/widgets/velo_di_rivelazione.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'attorno_alla_rivelazione.dart';

/// IL VIDEO DEL MAESTRO NELLA RIVELAZIONE. Ordine BQ, voci 2 e 3.
///
/// **LE MISURE SONO LE STESSE, IL PUNTO IN CUI SI PRENDONO E' CAMBIATO.**
/// L'ordine BQ montava la carta e ci cercava dentro il filmato, perche' li' il
/// filmato viveva. L'ordine BR lo ha portato fuori, a fare da sfondo all'intera
/// schermata: da qui in avanti queste prove montano la SCHERMATA e compiono il
/// rito del soffio, altrimenti misurerebbero un pezzo di app che non esiste
/// piu'. Nessuna promessa dell'ordine BQ e' stata lasciata indietro; quella che
/// e' cambiata, cioe' quale ritratto resta a video quando il filmato copre, e'
/// dichiarata riga per riga qui sotto.
///
/// **E il lettore vero non resta senza prova**: l'ultimo gruppo monta la scena
/// con la fabbrica predefinita, cioe' `video_player`, e pretende che in assenza
/// di piattaforma la scena mostri comunque la carta col ritratto.
void main() {
  late BancoDeiLettori banco;

  setUp(() => banco = BancoDeiLettori());

  Widget scena(Maestro maestro,
          {bool riduciMovimento = false, FabbricaDiLettori? fabbrica}) =>
      attornoAllaRivelazione(
        MaestroRevealScreen(
          maestro: maestro,
          onRevealed: (_) {},
          fabbricaDelVideo: fabbrica ?? banco.crea,
        ),
        riduciMovimento: riduciMovimento,
      );

  group('BQ.02, il video parte quando il Maestro si rivela', () {
    testWidgets('Il video parte entro 400 millesimi dalla rivelazione',
        (tester) async {
      // **IL TEMPO SI CONTA A FOTOGRAMMI POMPATI, non con un orologio a muro.**
      // Un orologio dentro una prova misura la macchina, e questo repository lo
      // ha gia' pagato una volta nell'ordine BO. Qui il tempo avanza solo
      // quando la prova lo fa avanzare, sedici millesimi per volta, quindi il
      // numero letto e' il ritardo che il CODICE introduce e nient'altro.
      pinnaLoSchermo(tester);
      const passo = Duration(milliseconds: 16);
      const tetto = Duration(milliseconds: 400);
      for (final maestro in Maestro.values) {
        banco = BancoDeiLettori();
        await tester.pumpWidget(scena(maestro));
        await svelaIlMaestro(tester);
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
      pinnaLoSchermo(tester);
      for (final maestro in Maestro.values) {
        banco = BancoDeiLettori();
        await tester.pumpWidget(scena(maestro));
        await svelaIlMaestro(tester);
        expect(banco.chiesti.single, RivelazioneInVideo.assetDi(maestro),
            reason: '${maestro.id} chiede un video che non e\' il suo');
        expect(banco.chiesti.single, contains(maestro.id));
        await tester.pumpWidget(const SizedBox.shrink());
      }
    });

    testWidgets('Il video si riproduce una volta sola, senza ciclo',
        (tester) async {
      pinnaLoSchermo(tester);
      await tester.pumpWidget(scena(Maestro.medora));
      await svelaIlMaestro(tester);
      final lettore = banco.vivi.single;
      expect(lettore.riavvii, 0,
          reason: 'il lettore e\' stato riavviato: allora cicla');
      lettore.finisci();
      await tester.pump();
      expect(lettore.riavvii, 0,
          reason: 'finito il filmato qualcuno lo ha fatto ripartire');
    });

    testWidgets('Alla fine del video il Maestro non sparisce mai',
        (tester) async {
      // **LA MISURA E' SU OGNI FOTOGRAMMA DELLA TRANSIZIONE, non prima e dopo.**
      // Un nero di un fotogramma solo e' esattamente cio' che si vede a occhio
      // e non si vede in due controlli agli estremi.
      //
      // **COSA E' CAMBIATO CON L'ORDINE BR, ed e' l'unica riga di questa prova
      // che cambia senso.** Prima il ritratto che restava era quello della
      // carta, perche' il filmato finiva e si toglieva. Adesso il filmato non
      // si toglie piu': il ritratto che resta in albero e' quello che il velo
      // tiene SOTTO al filmato, ed e' li' apposta perche' un fotogramma nero
      // resti impossibile anche il giorno che una texture si svuotasse.
      pinnaLoSchermo(tester);
      await tester.pumpWidget(scena(Maestro.aura));
      await svelaIlMaestro(tester);
      final lettore = banco.vivi.single;
      await tester.pump();
      expect(find.byType(Image), findsOneWidget,
          reason: 'mentre il video suona un ritratto del Maestro deve stare '
              'sotto, altrimenti alla fine c\'e\' un passaggio da fare');
      lettore.finisci();
      var fotogrammi = 0;
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        fotogrammi++;
        expect(find.byType(Image), findsOneWidget,
            reason: 'al fotogramma $i dopo la fine del video non c\'e\' nessun '
                'ritratto in albero: li\' lo schermo mostra il nero');
      }
      // ignore: avoid_print
      print('ORDINE BQ VOCE 2: fotogrammi controllati dopo la fine '
          '$fotogrammi');
      expect(fotogrammi, 30);
    });

    testWidgets('Dieci aperture e chiusure non lasciano nessun lettore vivo',
        (tester) async {
      pinnaLoSchermo(tester);
      for (var giro = 0; giro < 10; giro++) {
        await tester.pumpWidget(scena(Maestro.caligo));
        await svelaIlMaestro(tester);
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
    testWidgets('Uscendo dall\'app il lettore si chiude e torna la carta',
        (tester) async {
      // La caccia alla regola viene dalla ricognizione: l'intro CHIUDE il
      // filmato quando l'app passa dietro, invece di metterlo in pausa. Una
      // pausa lascerebbe un fotogramma congelato ad aspettare un ritorno che
      // puo' arrivare mezz'ora dopo.
      pinnaLoSchermo(tester);
      await tester.pumpWidget(scena(Maestro.medora));
      await svelaIlMaestro(tester);
      expect(banco.vivi, hasLength(1));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      expect(banco.vivi, isEmpty,
          reason: 'l\'app e\' passata dietro e il lettore e\' rimasto vivo: '
              'al ritorno si vedrebbe un fotogramma congelato');
      // Un'app in pausa non disegna: cio' che si vede si guarda al
      // ritorno, non mentre sta dietro.
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(find.byType(MaestroCardReveal), findsOneWidget,
          reason: 'chiuso il filmato deve tornare la carta col ritratto. E\' '
              'l\'esito che l\'ordine BR dichiara accettabile, e va visto qui '
              'invece che scoperto sul telefono');
    });
  });

  group('BQ.03, se il video non parte la carta c\'e\' lo stesso', () {
    testWidgets('Col file assente la scena mostra la carta', (tester) async {
      pinnaLoSchermo(tester);
      await tester
          .pumpWidget(scena(Maestro.medora, fabbrica: banco.creaCieco));
      await svelaIlMaestro(tester);
      await tester.pump(const Duration(milliseconds: 16));
      expect(find.byType(MaestroCardReveal), findsOneWidget,
          reason: 'il video non e\' partito e la scena e\' rimasta vuota: '
              'e\' la promessa mancata che questa voce esiste per impedire');
      expect(find.byType(Image), findsOneWidget,
          reason: 'la carta senza il suo ritratto non e\' la carta');
      // **E NON BASTA CHE LA CARTA CI SIA: non deve esserci niente sopra.**
      // Un riquadro nero al posto del filmato lascerebbe la carta in albero e
      // lo schermo nero lo stesso, cioe' farebbe passare una prova che guarda
      // solo l'albero. Quando il filmato non e' pronto il velo disegna il
      // NULLA, e questa riga lo pretende.
      expect(
        find.descendant(
          of: find.byType(VeloDiRivelazione),
          matching: find.byType(ColoredBox),
        ),
        findsNothing,
        reason: 'col video non pronto il velo disegna qualcosa sopra la '
            'scena: li\' lo schermo mostra quel qualcosa e non il Maestro',
      );
      expect(tester.takeException(), isNull,
          reason: 'un file mancante non deve lanciare niente in faccia a '
              'nessuno');
    });

    testWidgets('Con Riduci Movimento nessun lettore viene creato',
        (tester) async {
      pinnaLoSchermo(tester);
      await tester.pumpWidget(scena(Maestro.aura, riduciMovimento: true));
      await svelaIlMaestro(tester);
      await tester.pump(const Duration(milliseconds: 500));
      expect(banco.nati, 0,
          reason: 'con Riduci Movimento sono nati ${banco.nati} lettori: un '
              'filmato aperto e fermo occupa comunque un decodificatore');
      expect(find.byType(MaestroCardReveal), findsOneWidget,
          reason: 'con Riduci Movimento la carta deve esserci subito');
    });

    testWidgets('Anche col lettore VERO la scena non resta mai vuota',
        (tester) async {
      // Nessuna fabbrica finta: qui c'e' `video_player`, che senza piattaforma
      // non inizializza niente. E' il caso reale di una prova headless, ed e'
      // anche il caso del telefono a cui manca il file.
      pinnaLoSchermo(tester);
      await tester.pumpWidget(attornoAllaRivelazione(
        const MaestroRevealScreen(
          maestro: Maestro.caligo,
          onRevealed: _niente,
        ),
      ));
      await svelaIlMaestro(tester);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(MaestroCardReveal), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });
  });

  group('BQ.01, i percorsi che i file hanno', () {
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

    test('La cartella e\' dichiarata nel pubspec', () {
      // Senza questa riga i tre filmati non entrerebbero nel pacchetto, e
      // nessuno se ne accorgerebbe guardando il codice.
      final pubspec = _leggi('pubspec.yaml');
      expect(pubspec, contains('- ${RivelazioneInVideo.cartella}'),
          reason: 'la cartella dei video non e\' dichiarata fra gli asset');
    });

    test('I tre file sono davvero sul disco', () {
      // **I FILE ADESSO CI SONO**, e questa riga lo pretende invece di
      // sperarlo: erano il pezzo che la sessione in cloud non poteva portare.
      for (final maestro in Maestro.values) {
        final f = File(RivelazioneInVideo.assetDi(maestro));
        expect(f.existsSync(), isTrue,
            reason: '${maestro.id} non ha il suo video: ${f.path}');
        expect(f.lengthSync(), greaterThan(0),
            reason: '${maestro.id} ha un video vuoto');
      }
    });
  });
}

void _niente(Maestro maestro) {}

String _leggi(String percorso) =>
    // ignore: avoid_slow_async_io
    File(percorso).readAsStringSync();
