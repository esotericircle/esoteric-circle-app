import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/chat/widgets/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// La chat si legge, e la leggibilita' non dipende dal caso.
///
/// Tre difetti visti sulle anteprime della build 2128, tutti e tre veri:
/// il cosmo passava DENTRO le bolle e una stella cadeva sopra il testo; la
/// conversazione era ancorata in alto e con due turni la schermata leggeva come
/// vuota; le bolle prendevano il viola della palette neutra invece del colore
/// del Maestro.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Senza preferenze finte i controllori restano appesi sul canale di
  // piattaforma, e la prova non finisce mai invece di fallire.
  setUp(() => SharedPreferences.setMockInitialValues({}));

  /// Il rosa acceso della "stella forzata": un colore che nella palette non
  /// esiste, cosi' se ricompare dentro la bolla e' passato di sotto e non e'
  /// un'ombra della bolla stessa.
  const stella = Color(0xFFFF00AA);

  // I provider che la bolla pretende: l'avatar dell'utente legge il profilo, e
  // il busto del Maestro il livello di qualita'.
  Widget conScope(Maestro maestro, Widget figlio) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ProfileController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => BirthIdentityController()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: MaestroScope(
            maestro: maestro,
            child: Scaffold(backgroundColor: Colors.black, body: figlio),
          ),
        ),
      );

  group('Il cosmo non passa dentro la bolla', () {
    // Enumerati: i due tipi di bolla per tutti e tre i Maestri. Campionarne
    // una sola avrebbe lasciato scoperta proprio quella dell'utente, che era
    // la piu' trasparente delle due e quella dove la stella si vedeva.
    for (final maestro in Maestro.values) {
      for (final dellUtente in const [true, false]) {
        test(
            'La superficie e\' opaca, ${maestro.id}, '
            '${dellUtente ? "utente" : "maestro"}', () {
          final palette = MaestroPalette.forKey(ThemeKey.of(maestro));
          final colori = ChatBubble.superficieDi(palette, isUser: dellUtente);
          expect(colori, isNotEmpty);
          for (final c in colori) {
            expect(c.a, 1.0,
                reason: 'una tinta translucida lascia passare il cosmo, e la '
                    'leggibilita\' finisce a dipendere da dove il seme mette '
                    'una stella');
          }
        });
      }
    }

    testWidgets('Una stella forzata sotto il testo non lo attraversa',
        (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(360, 797);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final radice = GlobalKey();
      const testo = 'Che cosa mi dice il mio cammino?';
      await tester.pumpWidget(conScope(
        Maestro.medora,
        RepaintBoundary(
          key: radice,
          child: const Stack(
            children: [
              // LA STELLA FORZATA: non una stella qualunque del cosmo, ma una
              // superficie piena che copre tutto il riquadro. Se un solo pixel
              // di questo colore ricompare dentro la bolla, il cosmo passa.
              Positioned.fill(child: ColoredBox(color: stella)),
              Center(
                // La sonda gira sulla bolla dell'UTENTE, e la scelta e'
                // misurata, non di gusto. Provata prima sulla bolla del
                // Maestro, che ha tinte allo 0,95 e 0,80, la prova restava
                // VERDE col difetto dentro: a quelle opacita' la stella filtra
                // cosi' poco che nessuna soglia onesta la vede. La bolla
                // dell'utente sta a 0,20 e 0,08, cioe' e' il caso che percorre
                // davvero il ramo difettoso.
                child: ChatBubble(
                  message: ChatMessage(
                      role: ChatRole.user, text: testo),
                  maestro: Maestro.medora,
                ),
              ),
            ],
          ),
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final centro = tester.getCenter(find.text(testo));
      // TUTTO dentro runAsync: `toByteData` vuole il ciclo di eventi vero, e
      // fuori di qui nel tempo finto non completa mai, cioe' la prova scade
      // invece di fallire. E' il modo piu' facile di scrivere una prova che
      // sembra rotta quando invece e' solo appesa.
      late final int larghezza;
      late final int altezza;
      late final Uint8List byte;
      await tester.runAsync(() async {
        final rb = radice.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
        final immagine = await rb.toImage(pixelRatio: 1.0);
        larghezza = immagine.width;
        altezza = immagine.height;
        final dati =
            await immagine.toByteData(format: ui.ImageByteFormat.rawRgba);
        byte = dati!.buffer.asUint8List();
        immagine.dispose();
      });

      // Si guarda un quadrato di undici punti attorno al centro del testo,
      // cioe' esattamente dove la stella dell'anteprima cadeva.
      var trovati = 0;
      for (var dy = -5; dy <= 5; dy++) {
        for (var dx = -5; dx <= 5; dx++) {
          final x = (centro.dx + dx).round();
          final y = (centro.dy + dy).round();
          if (x < 0 || y < 0 || x >= larghezza || y >= altezza) {
            continue;
          }
          final i = (y * larghezza + x) * 4;
          final r = byte[i], g = byte[i + 1], b = byte[i + 2];
          // Il rosa acceso ha rosso alto, verde nullo e blu medio: nessuna
          // tinta della palette gli somiglia, quindi la soglia e' larga.
          if (r > 200 && g < 60 && b > 120 && b < 200) trovati++;
        }
      }
      expect(trovati, 0,
          reason: 'la stella si vede attraverso la bolla in $trovati punti '
              'sopra il testo: la superficie non e\' opaca');
    });
  });

  group('Il Riprova sta attaccato alla bolla che ha fallito', () {
    testWidgets('C\'e\' quando serve, dentro la bolla', (tester) async {
      var riprovato = false;
      await tester.pumpWidget(conScope(
        Maestro.caligo,
        Center(
          child: ChatBubble(
            message: const ChatMessage(
              role: ChatRole.maestro,
              text: 'La nebbia ha coperto i segni.',
              failed: true,
              ripiego: true,
            ),
            maestro: Maestro.caligo,
            onRetry: () => riprovato = true,
          ),
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final comando = find.byKey(const Key('chat_riprova'));
      expect(comando, findsOneWidget);
      // DENTRO la bolla, non in una striscia altrove: se fosse fuori, questo
      // antenato non lo troverebbe.
      expect(
        find.ancestor(of: comando, matching: find.byType(ChatBubble)),
        findsOneWidget,
        reason: 'il comando deve vivere nella bolla a cui si riferisce',
      );
      await tester.tap(comando);
      expect(riprovato, isTrue);
    });

    testWidgets('Non c\'e\' su una bolla riuscita', (tester) async {
      await tester.pumpWidget(conScope(
        Maestro.aura,
        const Center(
          child: ChatBubble(
            message: ChatMessage(
                role: ChatRole.maestro, text: 'Il respiro ti aspetta.'),
            maestro: Maestro.aura,
          ),
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byKey(const Key('chat_riprova')), findsNothing);
    });
  });

  group('Le superfici di un Maestro dichiarano il loro Maestro', () {
    // Le due superfici che APPARTENGONO a un Maestro: la chat e la Consulta.
    // Il loro colore non puo' dipendere da chi era attivo un istante prima,
    // altrimenti chi ci arriva da una strada che non passa dal Santuario vede
    // il viola della palette neutra invece del blu di Medora.
    //
    // La prova guarda il sorgente e non i pixel, per una ragione: montare la
    // schermata intera richiede mezza applicazione di provider, e una prova
    // che pretende mezza applicazione smette di essere eseguita.
    //
    // Non e' una regola su TUTTI i `MaestroScope` di lib: le schermate
    // condivise, come il Santuario o le Impostazioni, seguono giustamente il
    // Maestro attivo e passare loro un `maestro:` sarebbe sbagliato. L'elenco
    // qui sotto e' esplicito apposta.
    const superficiDiUnMaestro = {
      'lib/features/maestri/chat/maestro_chat_screen.dart':
          'la chat appartiene al Maestro con cui si parla',
      'lib/features/maestri/ask/ask_maestri_screen.dart':
          'la Consulta appartiene al Maestro da cui si parte',
    };

    for (final voce in superficiDiUnMaestro.entries) {
      test('${voce.key.split('/').last} dichiara il Maestro allo scope', () {
        final sorgente = File(voce.key).readAsStringSync();
        final apertura = sorgente.indexOf('MaestroScope(');
        expect(apertura, greaterThanOrEqualTo(0),
            reason: '${voce.key} non monta piu\' uno scope: '
                'se e\' voluto, togli la voce da questo elenco');
        // Si guarda la finestra subito dopo l'apertura dello scope: il
        // parametro, se c'e', sta li' e non a duecento righe di distanza.
        final fine = (apertura + 160).clamp(0, sorgente.length);
        final finestra = sorgente.substring(apertura, fine);
        expect(finestra.contains('maestro:'), isTrue,
            reason: '${voce.key}: lo scope non dichiara il Maestro, quindi '
                'segue quello attivo. ${voce.value}.');
      });
    }
  });
}
