import 'dart:async';
import 'dart:io';

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/design_system/components/user_avatar.dart';
import 'package:esoteric_circle/design_system/components/zodiac_glyph.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// L'ICONA DELL'UTENTE NON E' MAI UN CERCHIO VUOTO.
///
/// **Il difetto che l'ha fatta nascere.** Nell'anteprima della chat di Aura del
/// 6 agosto 2026, accanto alla bolla della persona c'era un cerchio vuoto,
/// mentre nella chat di Medora c'era la miniatura del segno. Le due chat
/// passano dalla STESSA porta, `UserAvatar.forUser`: non erano due strade, era
/// una che falliva in silenzio.
///
/// **Due difetti distinti, e vanno separati.**
///
/// 1. Nella cattura l'immagine non era decodificata, perche' in headless
///    nessuno lo fa da solo. Difetto del corredo, chiuso precaricando dentro
///    `capture`.
/// 2. Nell'app, il ramo d'errore di `ZodiacEmblem` restituiva un posto vuoto e
///    **scavalcava i due ripieghi rimasti** della catena dell'avatar. Quello
///    era un ripiego muto vero, e lo chiude questa prova.
///
/// **Una prova che conta widget non basta.** Un `Image` sta nell'albero anche
/// quando il fotogramma non arriva: qui si pretende che l'icona sia
/// DECODIFICATA, e per tutti e tre i Maestri, perche' la porta e' una sola ma
/// il difetto si era visto in una chat sola.
void main() {
  /// I tre segni con cui si prova: uno per Maestro, cosi' se un'arte mancasse
  /// per un segno solo la prova lo direbbe invece di mediare.
  const segni = [Zodiac.leo, Zodiac.cancer, Zodiac.scorpio];

  Widget host(Widget figlio) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: figlio)),
      );

  /// Se il fotogramma di [provider] arriva davvero.
  Future<bool> siDecodifica(
      WidgetTester tester, ImageProvider provider, Element element) async {
    var arrivata = false;
    final atteso = Completer<void>();
    final ascoltatore = ImageStreamListener((info, _) {
      arrivata = info.image.width > 0 && info.image.height > 0;
      if (!atteso.isCompleted) atteso.complete();
    }, onError: (e, s) {
      if (!atteso.isCompleted) atteso.complete();
    });
    await tester.runAsync(() async {
      final stream = provider.resolve(ImageConfiguration.empty);
      stream.addListener(ascoltatore);
      await atteso.future
          .timeout(const Duration(seconds: 5), onTimeout: () {});
      stream.removeListener(ascoltatore);
    });
    return arrivata;
  }

  group('L\'icona dell\'utente si decodifica, in tutte e tre le chat', () {
    for (final segno in segni) {
      testWidgets('il glifo di ${segno.italianName} arriva davvero',
          (tester) async {
        await tester.pumpWidget(host(
          UserAvatar(sign: segno, name: 'Mauro Battaglia', size: 28),
        ));
        await tester.pump();

        // C'e' il glifo, e non le iniziali: la catena ha scelto il gradino 2.
        expect(find.byKey(const Key('user_avatar_sign')), findsOneWidget,
            reason: 'con il segno noto l\'avatar deve mostrare il glifo');
        expect(find.byKey(const Key('user_avatar_initials')), findsNothing);

        final immagini = tester.widgetList<Image>(find.byType(Image)).toList();
        expect(immagini, hasLength(1),
            reason: 'nessuna immagine nell\'albero per ${segno.italianName}');

        final element = tester.element(find.byType(MaterialApp));
        expect(await siDecodifica(tester, immagini.first.image, element), isTrue,
            reason: 'il glifo di ${segno.italianName} e\' nell\'albero ma il '
                'fotogramma non arriva: a schermo sarebbe un cerchio vuoto');
      });
    }

    test('l\'arte esiste su disco per tutti e dodici i segni', () {
      // Un percorso giusto non e' un file: se un'arte cambiasse cartella, la
      // prova qui sopra resterebbe verde sui tre provati e a schermo
      // comparirebbe il vuoto per gli altri nove.
      final mancanti = <String>[];
      for (final z in Zodiac.values) {
        final percorso = ZodiacArt.emblemPath(z);
        if (!File(percorso).existsSync()) {
          mancanti.add('${z.italianName}: $percorso');
        }
      }
      expect(mancanti, isEmpty,
          reason: 'queste arti non esistono, quindi l\'icona sarebbe un '
              'cerchio vuoto:\n${mancanti.join("\n")}');
    });
  });

  group('La catena dei ripieghi non si scavalca', () {
    testWidgets('se il glifo non si decodifica si scende alle iniziali',
        (tester) async {
      // Si punta a un asset che non esiste: e' il caso che prima produceva il
      // cerchio vuoto, perche' il ramo d'errore restituiva un posto vuoto e
      // saltava i due gradini rimasti.
      await tester.pumpWidget(host(
        const ZodiacEmblem(
          sign: Zodiac.leo,
          size: 28,
          assetPath: 'assets/questo_non_esiste_affatto.webp',
          ripiego: Text('MB', key: Key('user_avatar_initials')),
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('user_avatar_initials')), findsOneWidget,
          reason: 'il ramo d\'errore ha restituito il vuoto invece di cadere '
              'sul gradino successivo della catena');
    });

    testWidgets('senza segno si va alle iniziali, senza nome al sigillo',
        (tester) async {
      await tester.pumpWidget(host(
        const UserAvatar(name: 'Mauro Battaglia', size: 28),
      ));
      await tester.pump();
      expect(find.byKey(const Key('user_avatar_initials')), findsOneWidget);

      await tester.pumpWidget(host(const UserAvatar(size: 28)));
      await tester.pump();
      expect(find.byKey(const Key('user_avatar_neutral')), findsOneWidget,
          reason: 'senza segno e senza nome deve restare il sigillo del '
              'Cerchio, mai un cerchio vuoto');
    });

    test('nessun ramo d\'errore dell\'avatar torna un posto vuoto', () {
      // Il difetto era una riga sola, e una riga sola puo' tornare.
      final glifo =
          File('lib/design_system/components/zodiac_glyph.dart').readAsStringSync();
      expect(
        RegExp(r'errorBuilder:[^,]*=>\s*SizedBox\(').hasMatch(glifo),
        isFalse,
        reason: 'il ramo d\'errore torna direttamente un posto vuoto invece di '
            'cadere sul ripiego di chi lo chiama',
      );
      final avatar = File('lib/design_system/components/user_avatar.dart')
          .readAsStringSync();
      expect(avatar, contains('ripiego:'),
          reason: 'l\'avatar non passa piu\' il suo ripiego al glifo, quindi '
              'la catena torna scavalcabile');
    });
  });

  group('Il corredo precarica da solo', () {
    test('capture precarica prima di scattare, e non lo fa a mano nessuno', () {
      final corredo =
          File('test/screenshot_capture_test.dart').readAsStringSync();
      // La chiamata sta DENTRO capture: e' l'unico modo perche' una cattura
      // nuova non possa nascere senza.
      final dentro = corredo.indexOf('Future<void> capture(');
      // **LA FINESTRA E' PIU' LARGA, e la regola PIU' STRETTA.** Ordine AV
      // voce 01: la finestra era di settecento caratteri e un commento nuovo
      // dentro `capture` la faceva cadere pur restando la chiamata al suo
      // posto, cioe' era rossa per un motivo che non era il suo. Adesso guarda
      // il corpo intero, e pretende una cosa in piu': il precaricamento deve
      // restare il comportamento predefinito.
      final fine = corredo.indexOf('Future<void> captureRitual(', dentro);
      final finoAllaFine =
          corredo.substring(dentro, fine > dentro ? fine : dentro + 2500);
      expect(finoAllaFine, contains('precaricaCioCheLaScenaMonta'),
          reason: 'capture non precarica piu\' da solo, quindi la regola torna '
              'a doversi ricordare a mano in ogni cattura');
      expect(finoAllaFine, contains('bool precarica = true'),
          reason: 'il precaricamento non e piu il comportamento predefinito: '
              'una cattura nuova puo nascere senza, per distrazione');
    });
  });
}
