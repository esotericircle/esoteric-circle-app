// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/cerchio/il_cerchio_sociale.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/cerchio/il_tuo_cerchio_screen.dart';
import 'package:esoteric_circle/features/cerchio/widgets/disegni_del_cerchio.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'porta_finta_del_cerchio_sociale.dart';

/// **IL SIGILLO QUANDO DUE NOMI COINCIDONO, ordine FA voce 04.**
///
/// Il nome nel Cerchio non e' unico per scelta: l'unicita' la porta il
/// sigillo, che non si mostra sotto ogni nome. In un elenco compare accanto
/// al nome solo quando due o piu' nomi coincidono nella forma dei nomi
/// riservati, e allora su tutti quelli che coincidono. Il rilievo
/// dell'Architetto: nella cattura del tuo Cerchio "Eco Corvo Mite" compariva
/// due volte, due persone che la schermata non distingueva.
void main() {
  PersonaDelCerchio persona(String uid, String nome, String sigillo) =>
      PersonaDelCerchio(
          uid: uid, nome: nome, icona: 'segno:0', sigillo: sigillo);

  Future<List<String>> sigilliVisti(
      WidgetTester tester, List<PersonaDelCerchio> persone) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ElencoDelCerchio(
          persone: persone,
          child: Column(children: [
            for (final p in persone)
              NomeDellaPersona(
                  nome: p.nome,
                  sigillo: p.sigillo,
                  stile: const TextStyle(fontSize: 18)),
          ]),
        ),
      ),
    ));
    return [
      for (final p in persone)
        if (find
            .textContaining(p.sigillo!, findRichText: true)
            .evaluate()
            .isNotEmpty)
          p.sigillo!,
    ];
  }

  testWidgets(
      'FA.04: due nomi uguali per l\'occhio portano tutti e due il '
      'sigillo, e il terzo no', (tester) async {
    final visti = await sigilliVisti(tester, [
      persona('a', 'Eco Corvo Mite', 'R7KQ'),
      persona('b', 'eco corvo  mite', 'M4XR'),
      persona('c', 'Stella Lieve', 'Z9P0'),
    ]);
    print('FA.04 CON DUE NOMI UGUALI: sigilli a schermo $visti');
    expect(visti, ['R7KQ', 'M4XR']);
  });

  testWidgets('FA.04: senza collisioni nessun sigillo', (tester) async {
    final visti = await sigilliVisti(tester, [
      persona('a', 'Eco Corvo Mite', 'R7KQ'),
      persona('b', 'Luce di Scorpione', 'M4XR'),
      persona('c', 'Stella Lieve', 'Z9P0'),
    ]);
    print('FA.04 SENZA COLLISIONI: sigilli a schermo $visti');
    expect(visti, isEmpty);
  });

  testWidgets(
      'FA.04: nel tuo Cerchio, chi ti cerca e un amico con lo stesso '
      'nome si distinguono', (tester) async {
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2391);
    addTearDown(tester.view.reset);
    final finta = _ConDueNomiUguali();
    final sociale = IlCerchioSociale(porta: finta);
    await sociale.sincronizza(
        identita: BirthIdentity(birthMoment: DateTime(1990, 5, 12, 10)));
    await sociale.caricaIlCerchio();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<IlCerchioSociale>.value(value: sociale),
        Provider<AppServices>.value(value: AppServices.offline(null, finta)),
      ],
      child: MaterialApp(
        theme: AppTheme.dark(),
        home: const MaestroScope(neutro: true, child: IlTuoCerchioScreen()),
      ),
    ));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    final conSigillo = [
      for (final s in ['R7KQ', 'M4XR', 'K2QX'])
        if (find.textContaining(s, findRichText: true).evaluate().isNotEmpty) s,
    ];
    print('FA.04 NEL TUO CERCHIO: sigilli a schermo $conSigillo');
    expect(conSigillo, ['R7KQ', 'M4XR'],
        reason: 'i due "Eco Corvo Mite" devono distinguersi, Stella no');
  });
}

class _ConDueNomiUguali extends PortaFintaDelCerchioSociale {
  @override
  Future<EsitoSociale?> sociale(String porta,
      [Map<String, Object?> corpo = const {}]) async {
    final e = await super.sociale(porta, corpo);
    if (e == null || porta != 'ilMioCerchio') return e;
    return EsitoSociale(dati: {
      ...e.dati,
      'ricevuti': [
        {
          'uid': 'u-corvo',
          'nome': 'Eco Corvo Mite',
          'icona': 'animale:3',
          'sigillo': 'R7KQ',
          'semaforo': 'arancionePieno',
        },
      ],
      'amici': [
        {
          ...PortaFintaDelCerchioSociale.amico,
          'uid': 'u-corvo-2',
          'nome': 'eco corvo mite',
          'sigillo': 'M4XR',
        },
        {...PortaFintaDelCerchioSociale.amico, 'sigillo': 'K2QX'},
      ],
      'inviati': const [],
    });
  }
}
