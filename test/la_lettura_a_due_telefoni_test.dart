import 'package:esoteric_circle/core/cerchio/il_cerchio_sociale.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/core/synastry_evolutiva/cielo_evolutivo.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/synastry/la_nascita_dell_altra_persona.dart';
import 'package:esoteric_circle/features/synastry/la_tua_nascita_per_una_lettura.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'porta_finta_del_cerchio_sociale.dart';

/// **LA LETTURA A DUE TELEFONI**, ordine FT voce FT.03: "Nella lettura a due
/// telefoni la nascita passa solo col consenso esplicito di chi la
/// condivide, una volta per lettura. Non entra mai nel profilo pubblico."
/// La logica del server (un codice, cinque minuti, una lettura) e' provata
/// in `functions/src/sinastria_evolutiva.test.ts`; qui il telefono: niente
/// parte prima del gesto del consenso, il codice arriva, la nascita torna
/// col parere del server sull'amore, e senza server la strada a mano resta.
class _Porta extends PortaFintaDelCerchioSociale {
  _Porta({this.spenta = false, this.amore = true});

  final bool spenta;
  final bool amore;

  @override
  Future<EsitoSociale?> sociale(String porta,
      [Map<String, Object?> corpo = const {}]) async {
    if (porta == 'condividiLaNascita' || porta == 'leggiLaNascita') {
      chieste.add((porta, corpo));
      // Una porta non ancora pubblicata non risponde.
      if (spenta) return null;
      if (porta == 'condividiLaNascita') {
        return EsitoSociale(dati: {
          'codice': 'K7Q2AB',
          // Un istante dichiarato e lontano: il codice vale ancora, e la
          // prova non legge l'orologio vero.
          'scade': DateTime.utc(2100).millisecondsSinceEpoch,
        });
      }
      return EsitoSociale(dati: {
        'nascita': '1992-09-03T08:15:00.000Z',
        'giorno': '1992-09-03',
        'oraNota': true,
        'nome': 'Giulia',
        'amoreApribile': amore,
      });
    }
    return super.sociale(porta, corpo);
  }
}

final _palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));

Future<_Porta> _monta(WidgetTester tester, Widget home,
    {bool spenta = false, bool amore = true}) async {
  SharedPreferences.setMockInitialValues({});
  final porta = _Porta(spenta: spenta, amore: amore);
  final sociale = IlCerchioSociale(porta: porta);
  final identita = BirthIdentity(birthMoment: DateTime(1990, 5, 12, 14, 30));
  await tester.runAsync(() =>
      sociale.sincronizza(identita: identita, oggi: DateTime(2026, 10, 14)));
  await tester.pumpWidget(MultiProvider(
    providers: [
      ChangeNotifierProvider<IlCerchioSociale>.value(value: sociale),
      ChangeNotifierProvider(
          create: (_) => ProfileController(identity: identita)),
      ChangeNotifierProvider(create: (_) => MaestroController()),
    ],
    child: MaterialApp(
      home: home,
      builder: (context, figlio) => MaestroScope(child: figlio!),
    ),
  ));
  await tester.pumpAndSettle();
  return porta;
}

void main() {
  testWidgets(
      'chi condivide: niente parte prima del consenso, poi arriva il codice',
      (tester) async {
    final porta =
        await _monta(tester, LaTuaNascitaPerUnaLettura(palette: _palette));
    expect(porta.chieste.where((c) => c.$1 == 'condividiLaNascita'), isEmpty,
        reason: 'la nascita e\' partita senza il gesto del consenso');
    expect(find.byKey(const Key('la_tua_nascita_codice')), findsNothing);

    await tester.tap(find.byKey(const Key('la_tua_nascita_consenso')));
    await tester.pump();
    await tester.pump();
    final mandata =
        porta.chieste.singleWhere((c) => c.$1 == 'condividiLaNascita').$2;
    expect(mandata['giorno'], '1990-05-12');
    expect(mandata['oraNota'], isA<bool>());
    expect(mandata.keys.toSet(), {'nascita', 'giorno', 'oraNota', 'nome'},
        reason: 'nessun campo del profilo pubblico viaggia col consenso');
    expect(find.text('K7Q2AB'), findsOneWidget);
    expect(find.byKey(const Key('la_tua_nascita_scadenza')), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  Future<void> leggi(WidgetTester tester) async {
    await tester.tap(find.text('apri'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const Key('nascita_altra_codice')), 'k7q2ab');
    await tester.pump();
    await tester.tap(find.byKey(const Key('nascita_altra_leggi')));
    await tester.pumpAndSettle();
  }

  Widget apriIlModulo(void Function(NascitaLetta?) quando) => Builder(
        builder: (context) => Scaffold(
          body: ElevatedButton(
            onPressed: () async => quando(
                await LaNascitaDellAltraPersona.chiedi(context, _palette)),
            child: const Text('apri'),
          ),
        ),
      );

  testWidgets(
      'chi legge: il codice porta la nascita vera e il parere del server '
      'sull\'amore', (tester) async {
    NascitaLetta? letta;
    final porta =
        await _monta(tester, apriIlModulo((r) => letta = r), amore: false);
    await leggi(tester);
    final chiesta =
        porta.chieste.singleWhere((c) => c.$1 == 'leggiLaNascita').$2;
    expect(chiesta['codice'], 'k7q2ab');
    expect(chiesta['giornoMio'], '1990-05-12',
        reason: 'il server rifa\' lo sbarramento col giorno di chi legge');
    expect(letta, isNotNull);
    expect(letta!.nome, 'Giulia');
    expect(letta!.amoreDalServer, isFalse);
    final atteso = CieloEvolutivo.perNascita(
        momentoUtc: DateTime.utc(1992, 9, 3, 8, 15), nome: 'Giulia');
    expect(letta!.cielo.longitudini, atteso.longitudini);
    expect(letta!.cielo.giornoDiNascita, DateTime(1992, 9, 3));
  });

  testWidgets(
      'col Cerchio che non risponde la riga lo dice e la strada a mano resta',
      (tester) async {
    NascitaLetta? letta;
    await _monta(tester, apriIlModulo((r) => letta = r), spenta: true);
    await leggi(tester);
    expect(letta, isNull, reason: 'il modulo si e\' chiuso senza una nascita');
    expect(
        find.byKey(const Key('nascita_altra_riga_del_codice')), findsOneWidget);
    expect(find.text(EsitoDelGesto.silenzio.riga!), findsOneWidget);
    expect(find.byKey(const Key('nascita_altra_data')), findsOneWidget,
        reason: 'senza server la nascita si scrive ancora a mano');
  });
}
