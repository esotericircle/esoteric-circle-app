import 'package:esoteric_circle/core/archetypes/archetype.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/maestro/frasi_dell_attesa.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/maestro/tempi_dell_attesa.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/components/consulto_del_cielo_view.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// L'ATTESA SI DEVE POTER LEGGERE.
///
/// **I due difetti che il fondatore ha visto sul telefono.** Toccando
/// "Consulta Medora" compariva per una frazione di secondo un emblema che poi
/// spariva da solo. E le frasi di riflessione duravano 1,6 secondi: sono
/// scritte per essere lette e non se ne aveva il tempo.
void main() {
  const pieno = NatalContext(
    sunSign: 'Cancro',
    moonSign: 'Pesci',
    ascendant: 'Vergine',
    lifeNumber: 7,
    lifeNumberTitle: 'il Cercatore',
  );

  Widget host(Widget figlio, {bool fermo = false}) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => MaestroController()),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (ctx) => MediaQuery(
              data: MediaQuery.of(ctx).copyWith(disableAnimations: fermo),
              child: MaestroScope(child: Scaffold(body: figlio)),
            ),
          ),
        ),
      );

  group('Le frasi dicono il vero', () {
    test('Ogni frase nomina un dato che il prompt manda davvero', () {
      // ENUMERATO leggendo `MaestroPersona`, non a memoria: il blocco natale
      // scrive segno solare, segno lunare, Ascendente, numero della vita e
      // fase lunare di nascita. Se qui comparisse un dato che li' non c'e',
      // la frase dichiarerebbe un lavoro che non stiamo facendo.
      final istruzione = MaestroPersona.systemInstruction(
        maestro: Maestro.medora,
        profile: UserProfile.empty,
        memory: MaestroMemory.empty,
        natal: pieno,
      );
      for (final chiave in const {
        DatoDelContesto.segnoSolare: 'Segno solare',
        DatoDelContesto.segnoLunare: 'Segno lunare',
        DatoDelContesto.ascendente: 'Ascendente',
        DatoDelContesto.numeroDellaVita: 'Numero della vita',
      }.entries) {
        expect(istruzione, contains(chiave.value),
            reason: '${chiave.key} e\' promesso dalle frasi ma non arriva al '
                'modello: sarebbe una costante che dichiara il falso');
      }
    });

    test('I transiti NON compaiono, perche\' non li mandiamo', () {
      // Fra gli esempi di tono c'era "Sto analizzando i transiti". I transiti
      // non entrano nel contesto, quindi quella frase non esiste, e questa
      // prova cade se qualcuno la aggiunge senza mandare il dato.
      for (final maestro in Maestro.values) {
        for (final f in FrasiDellAttesa.perMaestro[maestro]!) {
          expect(f.testo.toLowerCase(), isNot(contains('transit')),
              reason: '${maestro.displayName} dichiara di guardare i transiti, '
                  'che non arrivano al modello');
        }
      }
    });

    test('Un dato che manca fa sparire la sua frase, e ne resta un\'altra', () {
      const senzaAscendente =
          NatalContext(sunSign: 'Cancro', moonSign: 'Pesci');
      for (final maestro in Maestro.values) {
        final frasi = FrasiDellAttesa.per(maestro,
            natal: senzaAscendente, memoria: MaestroMemory.empty);
        final quellaDellAscendente = FrasiDellAttesa.perMaestro[maestro]!
            .firstWhere((f) => f.chiede == DatoDelContesto.ascendente)
            .testo;
        expect(frasi, isNot(contains(quellaDellAscendente)));
        expect(frasi.length, greaterThanOrEqualTo(2),
            reason: 'restano meno di due frasi vere, e il minimo garantito '
                'e\' di due');
      }
    });

    test('Nessuna frase e\' condivisa fra due Maestri', () {
      final viste = <String, Maestro>{};
      for (final maestro in Maestro.values) {
        for (final f in FrasiDellAttesa.perMaestro[maestro]!) {
          expect(viste[f.testo], isNull,
              reason: '"${f.testo}" e\' di due Maestri');
          viste[f.testo] = maestro;
        }
      }
    });
  });

  group('I tempi', () {
    test('Ogni frase resta a schermo due secondi netti', () {
      expect(TempiDellAttesa.durataBattuta.inMilliseconds,
          greaterThanOrEqualTo(2000));
    });

    test('Il minimo garantito e\' di DUE frasi intere', () {
      expect(TempiDellAttesa.durataMinima,
          TempiDellAttesa.durataBattuta * TempiDellAttesa.battuteDellaScena);
      expect(TempiDellAttesa.battuteDellaScena, greaterThanOrEqualTo(2));
      expect(TempiDellAttesa.durataMinima.inMilliseconds,
          greaterThanOrEqualTo(4000));
    });

    test('L\'emblema finisce di colorarsi PRIMA che il minimo scada', () {
      // Se durasse quanto la scena sarebbe una barra di avanzamento
      // travestita, e una barra promette una fine che noi non conosciamo.
      expect(TempiDellAttesa.composizioneDelSimbolo,
          lessThan(TempiDellAttesa.durataMinima));
    });

    test('La prima parola resta sotto il tetto dichiarato', () {
      final conLaRete = TempiDellAttesa.allaPrimaParola(
          TempiDellAttesa.reteMassimaMisurataMs);
      expect(conLaRete, lessThan(TempiDellAttesa.tettoAllaPrimaParola),
          reason: 'si arriva a ${conLaRete.inMilliseconds} millisecondi');
      // E il numero e' quello che l'ordine dichiara: circa 4,2 secondi.
      expect(conLaRete.inMilliseconds, inInclusiveRange(4100, 4400));
    });
  });

  group('La scena a schermo', () {
    testWidgets('L\'emblema e\' quello del Maestro, uno solo e fermo',
        (tester) async {
      tester.view.devicePixelRatio = 3.0;
      tester.view.physicalSize = const Size(360, 797) * 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(host(const ConsultoDelCieloView(
          natal: pieno, maestro: Maestro.caligo)));
      await tester.pump();
      expect(find.byKey(const Key('consulto_corpo')), findsOneWidget);

      // Passa il tempo di tre frasi: l'emblema resta UNO e non cambia.
      final primo = tester.widget(find.byKey(const Key('consulto_corpo')));
      await tester.pump(TempiDellAttesa.durataBattuta);
      await tester.pump(TempiDellAttesa.durataBattuta);
      expect(find.byKey(const Key('consulto_corpo')), findsOneWidget);
      expect(tester.widget(find.byKey(const Key('consulto_corpo'))).runtimeType,
          primo.runtimeType);
    });

    testWidgets('Le frasi si susseguono, e ricominciano senza fermarsi',
        (tester) async {
      tester.view.devicePixelRatio = 3.0;
      tester.view.physicalSize = const Size(360, 797) * 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(host(const ConsultoDelCieloView(
          natal: pieno, maestro: Maestro.medora)));
      await tester.pump();

      final frasi = FrasiDellAttesa.per(Maestro.medora,
          natal: pieno, memoria: MaestroMemory.empty);
      expect(find.text(frasi[0]), findsOneWidget);

      // A UN CAPELLO PRIMA del passo la prima c'e' ancora: e' la misura di
      // quanto resta leggibile, non un controllo che il timer esista.
      await tester.pump(
          TempiDellAttesa.durataBattuta - const Duration(milliseconds: 50));
      expect(find.text(frasi[0]), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text(frasi[1]), findsOneWidget);

      // Girando tutte le frasi si torna alla prima, e l'emblema c'e' ancora.
      for (var i = 0; i < frasi.length; i++) {
        await tester.pump(TempiDellAttesa.durataBattuta);
      }
      expect(find.text(frasi[1]), findsOneWidget);
      expect(find.byKey(const Key('consulto_corpo')), findsOneWidget);
    });

    testWidgets('Con Riduci Movimento nessun controllore viene creato',
        (tester) async {
      tester.view.devicePixelRatio = 3.0;
      tester.view.physicalSize = const Size(360, 797) * 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // L'ARCHETIPO SERVE, ed e' il punto: dal 4 agosto 2026 il simbolo di
      // Aura E' l'archetipo, e senza il Test non ne esiste uno. Senza questa
      // riga la prova cercava un simbolo che giustamente non c'era.
      await tester.pumpWidget(host(
          const ConsultoDelCieloView(
              natal: pieno,
              maestro: Maestro.aura,
              archetipo: Archetype.creatore),
          fermo: true));
      await tester.pump();
      expect(tester.binding.transientCallbackCount, 0,
          reason: 'resta registrato un ticker: un controllore che nessuno fa '
              'girare e comunque un moto che esiste');
      // L'emblema c'e' lo stesso: si spegne il moto, non l'immagine.
      expect(find.byKey(const Key('consulto_corpo')), findsOneWidget);

      // E col moto acceso invece c'e', altrimenti la prova passerebbe anche
      // se la scena non animasse mai niente.
      //
      // La CHIAVE DIVERSA non e' un dettaglio: senza, Flutter riusa lo stesso
      // State, `didChangeDependencies` trova la scena gia' avviata e non crea
      // niente. La prova cadeva per colpa sua, non del codice.
      await tester.pumpWidget(host(const ConsultoDelCieloView(
          key: ValueKey('col moto'), natal: pieno, maestro: Maestro.aura)));
      await tester.pump();
      expect(tester.binding.transientCallbackCount, greaterThan(0),
          reason: 'a moto acceso la scena non anima niente');
    });
  });
}
