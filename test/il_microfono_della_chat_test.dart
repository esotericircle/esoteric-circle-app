import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/voce/dettatura.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/chat/widgets/chat_composer.dart';
import 'package:esoteric_circle/services/voce/dettatura_vera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// IL MICROFONO DELLA CHAT. Ordine CI voce 05.
///
/// **I vincoli dell'ordine sono sei, e cinque si provano qui.** Il sesto, il
/// costo zero, non e' una cosa che una prova possa misurare: si legge dal
/// codice, cioe' dal fatto che l'unica dipendenza nuova e' il riconoscitore
/// della piattaforma e che nessun byte di audio esce da questo progetto.
///
/// **Il vincolo che questa prova protegge meglio e' il primo: la dettatura
/// COMPILA e non invia.** E' quello che, sbagliato, farebbe il danno peggiore:
/// una domanda partita senza che nessuno l'abbia riletta, pagata dal budget
/// del giorno.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Widget scena(Dettatura dettatura, {ValueChanged<String>? onSend}) =>
      MaterialApp(
        theme: AppTheme.dark(),
        home: MaestroScope(
          maestro: Maestro.medora,
          child: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: ChatComposer(
                enabled: true,
                dettatura: dettatura,
                onSend: onSend ?? (_) {},
                onSuggestions: () {},
                hintText: 'Scrivi a Medora',
              ),
            ),
          ),
        ),
      );

  testWidgets('senza riconoscimento il microfono NON compare', (tester) async {
    await tester.pumpWidget(scena(const DettaturaSpenta()));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('chat_microfono')), findsNothing,
        reason: 'la piattaforma non sa ascoltare e il microfono compare lo '
            'stesso: un comando che non funziona e\' peggio di un comando '
            'assente, ed e\' il vincolo f dell\'ordine');
  });

  testWidgets('col riconoscimento il microfono compare', (tester) async {
    await tester.pumpWidget(scena(_DettaturaFinta()));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('chat_microfono')), findsOneWidget,
        reason: 'la piattaforma sa ascoltare e il microfono non c\'e\'');
  });

  testWidgets('la dettatura COMPILA il campo e NON invia', (tester) async {
    final inviati = <String>[];
    final finta = _DettaturaFinta();
    await tester.pumpWidget(scena(finta, onSend: inviati.add));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('chat_microfono')));
    await tester.pumpAndSettle();
    finta.di('domani che cielo mi aspetta');
    await tester.pumpAndSettle();

    expect(find.text('domani che cielo mi aspetta'), findsOneWidget,
        reason: 'quello che si e\' detto non e\' finito nel campo');
    expect(inviati, isEmpty,
        reason: 'la dettatura ha INVIATO la domanda: la persona non l\'ha '
            'riletta, non l\'ha corretta, e le e\' stata scalata dal budget '
            'del giorno. E\' il danno peggiore che questa voce puo\' fare');
  });

  testWidgets('la dettatura AGGIUNGE, non cancella quello che c\'era',
      (tester) async {
    final finta = _DettaturaFinta();
    await tester.pumpWidget(scena(finta));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Medora,');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('chat_microfono')));
    await tester.pumpAndSettle();
    finta.di('cosa dice la Luna');
    await tester.pumpAndSettle();

    expect(find.text('Medora, cosa dice la Luna'), findsOneWidget,
        reason: 'la dettatura ha cancellato quello che era gia\' scritto: '
            'nessun comando deve poter buttare via il testo di qualcuno');
  });

  testWidgets(
      'DX.04: dopo l\'invio il campo resta vuoto anche se la dettatura '
      'manda ancora parole', (tester) async {
    final inviati = <String>[];
    final finta = _DettaturaFinta();
    await tester.pumpWidget(scena(finta, onSend: inviati.add));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('chat_microfono')));
    await tester.pumpAndSettle();
    finta.di('Indicate');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('chat_invio')));
    await tester.pumpAndSettle();
    // Il risultato FINALE del riconoscitore arriva dopo il tocco: e' il
    // fatto della cattura del fondatore.
    finta.di('Indicate');
    await tester.pumpAndSettle();

    expect(inviati, ['Indicate']);
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
        reason: 'la parola appena mandata e\' tornata nel campo: la '
            'dettatura ascoltava ancora e ha riscritto il risultato finale');
    expect(finta.fermate, 1,
        reason: 'chi manda ha finito di dettare: l\'ascolto va fermato');
    expect(find.byKey(const Key('chat_microfono')), findsOneWidget);
  });

  group('DX.02: la dettatura ascolta nella lingua dell\'app', () {
    test('sceglie la voce italiana fra quelle della piattaforma', () {
      const ios = ['en-US', 'en-GB', 'it-CH', 'it-IT', 'fr-FR'];
      const android = ['en_US', 'it_IT', 'de_DE'];
      expect(DettaturaVera.voceDellaLingua(const Locale('it'), ios), 'it-IT',
          reason: 'l\'app dichiara l\'italiano senza paese: prima it-IT, '
              'non la svizzera che nell\'elenco viene prima');
      expect(
          DettaturaVera.voceDellaLingua(const Locale('it'), android), 'it_IT');
      expect(DettaturaVera.voceDellaLingua(const Locale('it', 'CH'), ios),
          'it-CH');
      expect(
          DettaturaVera.voceDellaLingua(const Locale('it'), const []), 'it_IT',
          reason: 'senza elenco si chiede per nome, mai nessuna voce: '
              'nessuna voce vuol dire l\'inglese su iPhone');
      expect(DettaturaVera.voceDellaLingua(null, ios), isNull);
    });

    test('la lingua arriva DAVVERO al riconoscitore', () async {
      final motore = _MotoreFinto(const ['en_US', 'it_IT']);
      final dettatura =
          DettaturaVera(motore: motore, lingua: () => const Locale('it'));
      final partita = await dettatura.ascolta(parole: (_) {}, finito: () {});

      expect(partita, isTrue);
      expect(motore.lingueChieste, ['it_IT'],
          reason: 'il riconoscitore ha ascoltato senza lingua, cioe\' con '
              'quella che la piattaforma sceglie: su iPhone l\'inglese, ed '
              'e\' cosi\' che "quindi" e\' diventato "Indicate"');
    });
  });

  testWidgets('col permesso negato compare la riga che porta fuori',
      (tester) async {
    final finta = _DettaturaFinta()..permessoConcesso = false;
    await tester.pumpWidget(scena(finta));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('chat_microfono')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('avviso_permesso_chat')), findsOneWidget,
        reason: 'il permesso e\' negato e non lo dice nessuno: la persona '
            'tocca il microfono e non succede niente, che e\' un vicolo '
            'cieco');
    expect(finta.ascoltiChiesti, 0,
        reason: 'la dettatura e\' partita senza permesso');
  });

  testWidgets('il permesso si chiede AL TOCCO, mai prima', (tester) async {
    final finta = _DettaturaFinta();
    await tester.pumpWidget(scena(finta));
    await tester.pumpAndSettle();
    // Prima del tocco nessuno ha chiesto niente: la sezione 25 delle Linee
    // Guida UX vieta il dialogo di sistema all'apertura di una schermata.
    expect(finta.ascoltiChiesti, 0,
        reason: 'la dettatura e\' partita da sola all\'apertura della chat');
    await tester.tap(find.byKey(const Key('chat_microfono')));
    await tester.pumpAndSettle();
    expect(finta.ascoltiChiesti, 1);
  });
}

/// Una dettatura che dice di esserci e scrive quello che le si passa.
class _DettaturaFinta extends Dettatura {
  int ascoltiChiesti = 0;
  void Function(String)? _parole;

  void di(String detto) => _parole?.call(detto);

  @override
  Future<bool> disponibile() async => true;

  @override
  Future<bool> accendi() async => permessoConcesso;

  /// Cosa risponde il sistema quando la persona sceglie.
  bool permessoConcesso = true;

  @override
  Future<bool> ascolta({
    required void Function(String parole) parole,
    required void Function() finito,
  }) async {
    ascoltiChiesti++;
    _parole = parole;
    return true;
  }

  int fermate = 0;

  @override
  Future<void> ferma() async => fermate++;
}

/// **UN RICONOSCITORE FINTO, dietro la dettatura VERA.** Ordine DX voce 02.
///
/// Non implementa a mano la firma di `listen`, che ha dodici parametri e ne
/// cambia a ogni versione del plugin: guarda le chiamate che gli arrivano e
/// tiene la lingua chiesta. Cosi' la prova passa dal codice vero di
/// `DettaturaVera`, che e' proprio dove il difetto stava.
class _MotoreFinto implements SpeechToText {
  _MotoreFinto(this.lingueDellaPiattaforma);

  final List<String> lingueDellaPiattaforma;
  final List<String?> lingueChieste = [];

  @override
  dynamic noSuchMethod(Invocation chiamata) {
    switch (chiamata.memberName) {
      case #initialize:
        return Future<bool>.value(true);
      case #locales:
        return Future<List<LocaleName>>.value([
          for (final id in lingueDellaPiattaforma) LocaleName(id, id),
        ]);
      case #listen:
        final opzioni =
            chiamata.namedArguments[#listenOptions] as SpeechListenOptions?;
        lingueChieste.add(opzioni?.localeId);
        return Future<void>.value();
    }
    return null;
  }
}
