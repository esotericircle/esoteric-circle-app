import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/account/account_screen.dart';
import 'package:esoteric_circle/features/settings/settings_screen.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// I TITOLI DELLE CARD NON SI SPEZZANO DENTRO LE PAROLE. Ordine AI voce 03.
///
/// **Il difetto, dalla foto di Mauro**: a 360 punti la card dell'account
/// diceva "NOTIFIC HE", perche' il distintivo "In arrivo" rubava la riga e al
/// titolo restavano 83 punti, meno di una parola. La composizione nuova e'
/// dichiarata nella card: titolo e distintivo in un Wrap, il distintivo
/// scende sotto quando non c'e' posto.
///
/// **La grandezza**: per OGNI titolo delle card dell'account e delle
/// impostazioni, alla larghezza reale, ogni a capo deve cadere fra le parole.
/// Un titolo puo' occupare due righe ("I tuoi dati di nascita" lo fa, ed e'
/// sano): non puo' spezzarsi dentro una parola.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Ogni a capo del paragrafo deve cadere su uno spazio del testo.
  List<String> spezzatureNellaParola(RenderParagraph paragrafo, String testo) {
    final pittore = TextPainter(
      text: paragrafo.text,
      textDirection: TextDirection.ltr,
      textScaler: paragrafo.textScaler,
    )..layout(maxWidth: paragrafo.constraints.maxWidth);
    final difetti = <String>[];
    // L'inizio di ogni riga si legge dalla geometria: il carattere sotto il
    // primo punto della riga. Se il carattere PRIMA di quello non e' uno
    // spazio, l'a capo e' caduto dentro una parola.
    final metriche = pittore.computeLineMetrics();
    for (var r = 1; r < metriche.length; r++) {
      final riga = metriche[r];
      final posizione = pittore.getPositionForOffset(
          Offset(riga.left + 1, riga.baseline - riga.ascent / 2));
      final inizio = posizione.offset;
      if (inizio > 0 && inizio < testo.length && testo[inizio - 1] != ' ') {
        difetti
            .add('"${testo.substring(0, inizio)}|${testo.substring(inizio)}"');
      }
    }
    pittore.dispose();
    return difetti;
  }

  Future<void> controlla(
    WidgetTester tester,
    Widget schermata,
    List<String> titoli,
    String nomeSchermata,
  ) async {
    SharedPreferences.setMockInitialValues(const {});
    tester.view.devicePixelRatio = 1.0;
    // La larghezza e' quella REALE del telefono; l'altezza e' alta apposta,
    // cosi' tutte le card sono montate senza scorrere e l'enumerazione le
    // vede tutte.
    tester.view.physicalSize = const Size(360, 1800);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => SettingsController()),
        ChangeNotifierProvider(create: (_) => EntitlementService()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        Provider<AppServices>.value(value: AppServices.offline()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (ctx, child) => MaestroScope(child: child!),
        home: schermata,
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    var osservati = 0;
    final rotti = <String>[];
    for (final titolo in titoli) {
      final trovato = find.text(titolo);
      expect(trovato, findsWidgets,
          reason: 'il titolo "$titolo" non e\' montato su $nomeSchermata: '
              'l\'enumerazione non corrisponde piu\' alla schermata');
      osservati++;
      final difetti = spezzatureNellaParola(
          tester.renderObject<RenderParagraph>(trovato.first), titolo);
      if (difetti.isNotEmpty) {
        rotti.add('$nomeSchermata, $titolo: ${difetti.join(", ")}');
      }
    }
    // **QUANTE OSSERVAZIONI, e cade se sono zero.**
    // ignore: avoid_print
    print('ORDINE AI VOCE 03: $nomeSchermata, titoli osservati $osservati, '
        'spezzati dentro le parole ${rotti.length}');
    expect(osservati, titoli.length);
    expect(rotti, isEmpty,
        reason: 'questi titoli si spezzano dentro una parola alla larghezza '
            'reale: ${rotti.join(" | ")}');
  }

  testWidgets('le card dell\'account non spezzano i titoli', (tester) async {
    await controlla(tester, const AccountScreen(), const [
      'Profilo',
      'I tuoi dati di nascita',
      'Impostazioni',
      'Abbonamento',
      'Notifiche',
      'Privacy',
      'Cancella il tuo account',
    ], 'AccountScreen');
  });

  testWidgets('le card delle impostazioni non spezzano i titoli',
      (tester) async {
    // I titoli di sezione delle impostazioni si rendono MAIUSCOLI dentro
    // SectionTitle: si cercano come compaiono a schermo.
    await controlla(tester, const SettingsScreen(), const [
      'IL TUO PIANO',
      'ASPETTO',
      'Riduci animazioni',
    ], 'SettingsScreen');
  });
}
