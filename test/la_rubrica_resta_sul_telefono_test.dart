import 'dart:io';

import 'package:esoteric_circle/core/cerchio/il_cerchio_sociale.dart';
import 'package:esoteric_circle/core/cerchio/la_rubrica_del_telefono.dart';
import 'package:esoteric_circle/core/condivisione/la_porta_dei_messaggi.dart';
import 'package:esoteric_circle/core/entitlement/listino_degli_eos.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/legal/privacy_policy.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/cerchio/invita_nel_cerchio_screen.dart';
import 'package:esoteric_circle/features/cerchio/la_richiesta_di_legame.dart';
import 'package:esoteric_circle/features/cerchio/scegli_dalla_rubrica_screen.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';
import 'porta_finta_del_cerchio_sociale.dart';
import 'sorgenti_di_lib.dart';

/// LA RUBRICA RESTA SUL TELEFONO. Ordine FD voce 06.
///
/// La scheda "Chiama chi conosci" in cima a "Chiama nel Cerchio": il permesso
/// della rubrica si chiede solo al tocco, i contatti si leggono in memoria e
/// non escono dal telefono, se ne scelgono al massimo dieci, e il messaggio
/// gia' scritto va all'app dei messaggi, che lo manda solo se la persona lo
/// manda. Le prove a)-j) sono quelle dell'ordine.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Una rubrica di dodici persone, piu' due senza numero e una senza nome.
  final rubrica = [
    for (var i = 0; i < 12; i++)
      ContattoDellaRubrica(
          nome: 'Persona ${String.fromCharCode(76 - i)}',
          numero: '+39 333 000 00${i.toString().padLeft(2, '0')}'),
    const ContattoDellaRubrica(nome: 'Senza Numero', numero: ''),
    const ContattoDellaRubrica(nome: '', numero: '+39 333 999 9999'),
  ];

  late int richieste;
  late List<Uri> consegnati;
  late bool concedi;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    richieste = 0;
    consegnati = [];
    concedi = true;
    LaRubricaDelTelefono.richiesta = () async {
      richieste++;
      return concedi;
    };
    LaRubricaDelTelefono.giaConcessa = () async => false;
    LaRubricaDelTelefono.leggi = () async => rubrica;
    LaPortaDeiMessaggi.apri = (u) async {
      consegnati.add(u);
      return true;
    };
  });

  Future<void> passi(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<PortaFintaDelCerchioSociale> monta(WidgetTester tester,
      {PortaFintaDelCerchioSociale? porta}) async {
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2391);
    addTearDown(tester.view.reset);
    final finta = porta ?? PortaFintaDelCerchioSociale();
    final sociale = IlCerchioSociale(porta: finta);
    await tester.runAsync(() async {
      await sociale.sincronizza(
          identita: BirthIdentity(birthMoment: DateTime(1990, 5, 12, 10)));
      await sociale.caricaIlCerchio();
    });
    IlCerchioSociale.codiceDelLinkPerLaProva('AB12CD34');
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<IlCerchioSociale>.value(value: sociale),
        Provider<AppServices>.value(value: AppServices.offline(null, finta)),
      ],
      child: MaterialApp(
        theme: AppTheme.dark(),
        builder: (c, f) => MaestroScope(neutro: true, child: f!),
        home: const InvitaNelCerchioScreen(),
      ),
    ));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    return finta;
  }

  Future<void> apriLaRubrica(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('invita_rubrica')));
    await passi(tester);
    // Su Android la spiegazione viene prima, con la riga dell'ordine.
    final cta = find.widgetWithText(FilledButton, 'Apri la rubrica');
    if (cta.evaluate().length > 1 ||
        find
            .text('I contatti restano sul tuo telefono e servono solo a '
                'scegliere chi chiamare nel tuo Cerchio.')
            .evaluate()
            .isNotEmpty) {
      await tester.tap(cta.last);
      await passi(tester);
    }
  }

  testWidgets('a) la scheda nuova e\' la prima, e l\'ordine e\' quello scritto',
      (tester) async {
    await monta(tester);
    final titoli = [
      'Chiama chi conosci',
      'Manda il tuo invito',
      'Siete vicini',
      'Hai il suo sigillo?',
    ];
    final y = [for (final t in titoli) tester.getTopLeft(find.text(t)).dy];
    for (var i = 1; i < y.length; i++) {
      expect(y[i], greaterThan(y[i - 1]),
          reason: '${titoli[i]} non viene dopo ${titoli[i - 1]}');
    }
    expect(find.text('Apri la rubrica'), findsOneWidget);
  });

  testWidgets('b) nessuna richiesta all\'apertura, una sola al tocco',
      (tester) async {
    await monta(tester);
    expect(richieste, 0, reason: 'la schermata ha chiesto la rubrica da sola');
    await apriLaRubrica(tester);
    expect(richieste, 1);
    expect(find.byType(ScegliDallaRubricaScreen), findsOneWidget);
  });

  test('b) in lib la rubrica si chiede in un punto solo, al tocco', () {
    final punti = <String>[];
    for (final f in righeDiLib()) {
      final t = senzaCommenti(f.righe.join('\n'));
      if (t.contains('LaRubricaDelTelefono.richiesta') ||
          t.contains('permissions.request(')) {
        punti.add(f.percorso);
      }
    }
    expect(punti.toSet(), {
      'lib/core/cerchio/la_rubrica_del_telefono.dart',
      'lib/features/cerchio/invita_nel_cerchio_screen.dart',
    });
    final schermata =
        File('lib/features/cerchio/invita_nel_cerchio_screen.dart')
            .readAsStringSync();
    final apri = schermata.indexOf('Future<void> _apriLaRubrica()');
    final richiesta = schermata.indexOf('LaRubricaDelTelefono.richiesta');
    final init = schermata.indexOf('void initState()');
    expect(richiesta, greaterThan(apri),
        reason: 'la richiesta sta fuori dal tocco di Apri la rubrica');
    expect(
        schermata
            .substring(init, schermata.indexOf('}', init))
            .contains('richiesta'),
        isFalse);
  });

  testWidgets('c) i nomi e i numeri non escono dal telefono', (tester) async {
    final finta = await monta(tester);
    final prima = finta.chieste.length;
    await apriLaRubrica(tester);
    await tester.tap(find.byKey(const Key('rubrica_0')));
    await tester.tap(find.byKey(const Key('rubrica_1')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('rubrica_manda')));
    await passi(tester);
    final mandato = finta.chieste.skip(prima).map((c) => '${c.$1} ${c.$2}');
    // Si confrontano le sole cifre: un numero puo' partire con gli spazi, coi
    // trattini o senza, ed e' sempre lo stesso numero. La prima stesura
    // cercava il numero senza spazi, e un numero mandato con gli spazi le
    // sfuggiva (innesto A26, verde la prima volta).
    String cifre(String s) => s.replaceAll(RegExp(r'[^0-9]'), '');
    var trovati = 0;
    for (final c in rubrica) {
      final suo = cifre(c.numero);
      for (final m in mandato) {
        if ((c.nome.isNotEmpty && m.contains(c.nome)) ||
            (suo.length >= 6 && cifre(m).contains(suo))) {
          trovati++;
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE FD VOCE 06: chiamate al server durante la scelta e '
        'l\'invio ${mandato.length} ($mandato), con un nome o un numero '
        'della rubrica $trovati');
    expect(trovati, 0);
    // I file della rubrica e dei messaggi non parlano con la rete, non
    // scrivono file e non toccano le preferenze.
    const vietati = [
      'package:http',
      'cloud_functions',
      'cloud_firestore',
      'firebase',
      'dart:io',
      'shared_preferences',
      'path_provider',
      'porta_del_cerchio',
    ];
    final file = [
      'lib/core/cerchio/la_rubrica_del_telefono.dart',
      'lib/core/condivisione/la_porta_dei_messaggi.dart',
      'lib/features/cerchio/scegli_dalla_rubrica_screen.dart',
    ];
    for (final p in file) {
      final t = File(p).readAsStringSync();
      for (final v in vietati) {
        expect(t.contains(v), isFalse, reason: '$p importa $v');
      }
    }
  });

  testWidgets(
      'd) chiusa la scheda, nessun contatto resta in memoria o su disco',
      (tester) async {
    await monta(tester);
    await apriLaRubrica(tester);
    expect(find.text('Persona A'), findsOneWidget);
    await tester.tap(find.byKey(const Key('rubrica_0')));
    await tester.pump();
    Navigator.of(tester.element(find.byType(ScegliDallaRubricaScreen))).pop();
    await passi(tester);
    expect(find.byType(ScegliDallaRubricaScreen), findsNothing);
    expect(find.text('Persona A'), findsNothing);
    final prefs = await SharedPreferences.getInstance();
    for (final k in prefs.getKeys()) {
      final v = '${prefs.get(k)}';
      for (final c in rubrica) {
        expect(v.contains(c.numero.isEmpty ? '#' : c.numero), isFalse);
        expect(c.nome.isNotEmpty && v.contains(c.nome), isFalse);
      }
    }
    // Nessuna lista statica di contatti: la lista vive nello stato.
    for (final p in [
      'lib/core/cerchio/la_rubrica_del_telefono.dart',
      'lib/features/cerchio/scegli_dalla_rubrica_screen.dart',
    ]) {
      expect(
          RegExp(r'static\s+(final\s+|const\s+)?List<ContattoDellaRubrica>\??\s+\w+\s*[=;]')
              .hasMatch(File(p).readAsStringSync()),
          isFalse,
          reason: '$p tiene i contatti in una lista statica');
    }
  });

  testWidgets('e) al decimo le spunte si fermano e compare la riga del tetto',
      (tester) async {
    await monta(tester);
    await apriLaRubrica(tester);
    for (var i = 0; i < 10; i++) {
      final k = find.byKey(Key('rubrica_$i'));
      await tester.ensureVisible(k);
      await tester.tap(k);
      await tester.pump();
    }
    expect(find.text('Dieci per volta.'), findsOneWidget);
    final undicesimo = find.byKey(const Key('rubrica_10'));
    await tester.ensureVisible(undicesimo);
    expect(tester.widget<CheckboxListTile>(undicesimo).onChanged, isNull,
        reason: 'l\'undicesima spunta si attiva ancora');
    await tester.tap(undicesimo, warnIfMissed: false);
    await tester.pump();
    expect(tester.widget<CheckboxListTile>(undicesimo).value, isFalse);
  });

  testWidgets('f) il messaggio porta i destinatari, il link e gli Eos',
      (tester) async {
    await monta(tester);
    await apriLaRubrica(tester);
    for (final i in [0, 1, 2]) {
      await tester.tap(find.byKey(Key('rubrica_$i')));
      await tester.pump();
    }
    await tester.tap(find.byKey(const Key('rubrica_manda')));
    await passi(tester);
    expect(consegnati, hasLength(1));
    final u = Uri.decodeFull(consegnati.single.toString());
    // ignore: avoid_print
    print('ORDINE FD VOCE 06: messaggio consegnato $u');
    final scelti = LaRubricaDelTelefono.scegliibili(rubrica).take(3);
    for (final c in scelti) {
      expect(u, contains(c.numero.replaceAll(RegExp(r'[^0-9+]'), '')));
    }
    expect(
        u,
        contains('Ti chiamo nel mio Cerchio su Esoteric Circle. Entrando da '
            'qui ricevi ${ListinoDegliEos.premioDiChiArrivaConUnInvito} Eos:\n'
            '${IlCerchioSociale.linkDi('AB12CD34')}'));
    // Il numero del listino e' quello che il server paga.
    final server = File('functions/src/borsellino.ts').readAsStringSync();
    final pagato = RegExp(r'EOS_A_CHI_ARRIVA_CON_UN_INVITO = (\d+);')
        .firstMatch(server)!
        .group(1);
    expect(ListinoDegliEos.premioDiChiArrivaConUnInvito, int.parse(pagato!));
    expect(find.byType(ScegliDallaRubricaScreen), findsNothing);
  });

  testWidgets('g) col permesso negato la riga sola, e le altre schede vanno',
      (tester) async {
    concedi = false;
    await monta(tester);
    await apriLaRubrica(tester);
    expect(find.text('La rubrica è chiusa. Puoi sempre mandare il link.'),
        findsOneWidget);
    expect(find.text('Apri la rubrica'), findsNothing);
    expect(richieste, 1);
    // Le altre tre schede restano usabili: il link, il codice, il sigillo.
    for (final k in ['invita_link', 'invita_mostra', 'invita_col_sigillo']) {
      final w = tester.widget<ButtonStyleButton>(find.byKey(Key(k)));
      expect(w.onPressed, isNotNull, reason: '$k non si tocca piu\'');
    }
    // Non si richiede da soli: riaperta la schermata, nessuna richiesta.
    await monta(tester);
    expect(richieste, 1);
    expect(find.text('La rubrica è chiusa. Puoi sempre mandare il link.'),
        findsOneWidget);
  });

  testWidgets('h) una rubrica vuota o senza numeri si dice e non rompe',
      (tester) async {
    LaRubricaDelTelefono.leggi = () async => const [
          ContattoDellaRubrica(nome: 'Senza Numero', numero: ''),
        ];
    await monta(tester);
    await apriLaRubrica(tester);
    expect(find.byKey(const Key('rubrica_vuota')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('h) una rubrica che non si legge si dice vuota e non rompe',
      (tester) async {
    LaRubricaDelTelefono.leggi = () async => throw StateError('rubrica rotta');
    await monta(tester);
    await apriLaRubrica(tester);
    expect(find.byKey(const Key('rubrica_vuota')), findsOneWidget);
  });

  test('i) le righe tolte non esistono a video, e la pagina unica le ha', () {
    const tolte = [
      'Il link vale trenta giorni e porta solo un codice del Cerchio: niente '
          'del tuo nome vero, niente della tua nascita.',
      'Uno mostra il suo codice, l’altro lo inquadra. Il codice vale cinque '
          'minuti: una sua fotografia domani non vale niente.',
    ];
    var file = 0;
    for (final f in righeDiLib()) {
      file++;
      if (f.percorso == 'lib/core/legal/privacy_policy.dart') continue;
      final t = f.righe.join(' ').replaceAll(RegExp(r"'\s+'"), '');
      for (final r in tolte) {
        expect(t.contains(r.substring(0, 40)), isFalse,
            reason: '${f.percorso} mostra ancora "$r"');
      }
    }
    cardinaleMinimo(file, quantiFileHaLib, cosa: 'file di lib');
    final pagina = sezioniDellaPolicy.map((s) => s.corpo).join(' ');
    for (final r in tolte) {
      expect(pagina, contains(r), reason: 'la pagina unica non ha "$r"');
    }
    expect(sezioniDellaPolicy.any((s) => s.titolo.contains('Cerchio')), isTrue);
  });

  testWidgets('j) il link scaduto e il codice scaduto dicono la loro riga',
      (tester) async {
    final finta = _PortaColCodiceScaduto();
    await monta(tester, porta: finta);
    final ctx = tester.element(find.byType(InvitaNelCerchioScreen));
    mostraLaRichiestaDiLegame(ctx, 'AB12CD34');
    await passi(tester);
    expect(
        find.text('Questo invito è scaduto. Chiedi alla persona che te lo ha '
            'mandato di rifarlo.'),
        findsOneWidget);
    ScaffoldMessenger.of(ctx).removeCurrentSnackBar();
    await passi(tester);
    mostraLaRichiestaDiLegame(ctx, 'K7Q2M9');
    await passi(tester);
    expect(find.text('Questo codice non vale più. Fatelo mostrare di nuovo.'),
        findsOneWidget);
  });
}

class _PortaColCodiceScaduto extends PortaFintaDelCerchioSociale {
  @override
  Future<EsitoSociale?> sociale(String porta,
      [Map<String, Object?> corpo = const {}]) async {
    if (porta == 'leggiIlCodice') {
      chieste.add((porta, corpo));
      return const EsitoSociale(dati: {'valido': false});
    }
    return super.sociale(porta, corpo);
  }
}
