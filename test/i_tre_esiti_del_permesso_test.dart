import 'dart:io';

import 'package:esoteric_circle/core/permissions/app_permission.dart';
import 'package:esoteric_circle/core/permissions/avviso_del_permesso.dart';
import 'package:esoteric_circle/core/permissions/esito_del_permesso.dart';
import 'package:esoteric_circle/core/permissions/registro_dei_permessi.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// I TRE ESITI DEL PERMESSO RESTANO TRE, PER OGNI PERMESSO.
///
/// Ordine 2166, voce 2. Con l'ordine 2161 la posizione del Tramonto ha
/// imparato a distinguere il no di oggi dal no per sempre; gli altri
/// permessi rispondevano ancora si' o no, e chi aveva negato per sempre non
/// vedeva comparire nessun dialogo e nessuna schermata glielo diceva.
///
/// Le prove ENUMERANO i permessi del registro: un permesso che nascera'
/// domani cade qui il giorno che nasce, senza che nessuno si ricordi di
/// aggiungere una prova.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.aura));

  group('la porta unica distingue i tre esiti', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('concesso quando il sistema dice di si\'', () async {
      final esito = await PortaDelPermesso.chiedi(
        AppPermission.microphone,
        richiestaDiSistema: () async => true,
      );
      expect(esito, EsitoDelPermesso.concesso);
    });

    test('il PRIMO no e\' negato, il SECONDO e\' negato per sempre',
        () async {
      // E' la distinzione che il sistema non sa dare: il dialogo compare una
      // volta sola, quindi un no che torna senza dialogo e' un no definitivo.
      final primo = await PortaDelPermesso.chiedi(
        AppPermission.camera,
        richiestaDiSistema: () async => false,
      );
      expect(primo, EsitoDelPermesso.negato,
          reason: 'Il primo no deve restare richiedibile.');
      final secondo = await PortaDelPermesso.chiedi(
        AppPermission.camera,
        richiestaDiSistema: () async => false,
      );
      expect(secondo, EsitoDelPermesso.negatoPerSempre,
          reason: 'Il secondo no significa che il dialogo non compare piu\': '
              'appiattirlo sul primo e\' il difetto della voce 2.');
    });

    test('un plugin che solleva vuol dire dispositivo senza quel sensore',
        () async {
      final esito = await PortaDelPermesso.chiedi(
        AppPermission.motion,
        richiestaDiSistema: () async => throw StateError('niente sensore'),
      );
      expect(esito, EsitoDelPermesso.nonDisponibile,
          reason: 'Un dispositivo che non ha il sensore non e\' una persona '
              'che ha detto no: le due cose si dicono diversamente.');
    });

    test('i quattro esiti restano quattro valori distinti', () {
      // LA PROVA CHE CADE SE QUALCUNO LI RIFONDE: e' successo una volta con
      // la posizione, e la correzione dura solo finche' qualcuno la guarda.
      expect(EsitoDelPermesso.values.toSet().length, 4);
      expect(EsitoDelPermesso.negato == EsitoDelPermesso.negatoPerSempre,
          isFalse);
    });
  });

  group('l\'avviso a schermo dice cose diverse per esiti diversi', () {
    Widget attorno(EsitoDelPermesso esito, AppPermission permesso) =>
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AvvisoDelPermesso(
                chiave: 'prova',
                permesso: permesso,
                esito: esito,
                palette: palette,
                onRichiedi: () async {},
                onApriImpostazioni: () async {},
              ),
            ),
          ),
        );

    testWidgets('per OGNI permesso, i tre esiti danno tre schermate diverse',
        (tester) async {
      final colpe = <String>[];
      for (final voce in RegistroDeiPermessi.voci) {
        final testi = <EsitoDelPermesso, String>{};
        for (final esito in const [
          EsitoDelPermesso.negato,
          EsitoDelPermesso.negatoPerSempre,
          EsitoDelPermesso.nonDisponibile,
        ]) {
          await tester.pumpWidget(attorno(esito, voce.permesso));
          await tester.pump();
          final avviso = find.byKey(const Key('avviso_permesso_prova'));
          if (avviso.evaluate().isEmpty) {
            colpe.add('${voce.permesso} con $esito: nessun avviso a schermo');
            continue;
          }
          final righe = find.descendant(
              of: avviso, matching: find.byType(Text));
          final testo = [
            for (var i = 0; i < righe.evaluate().length; i++)
              tester.widget<Text>(righe.at(i)).data ?? ''
          ].join(' | ');
          testi[esito] = testo;
          // IL RIPIEGO SI DICE SEMPRE: nessun permesso negato puo' lasciare
          // la persona senza sapere cosa le resta.
          final primeParole = voce.ripiego.split(' ').take(4).join(' ');
          if (esito != EsitoDelPermesso.concesso &&
              !testo.contains(primeParole)) {
            colpe.add('${voce.permesso} con $esito: l\'avviso non nomina il '
                'ripiego dichiarato nel registro');
          }
        }
        // I DUE NO NON DICONO LA STESSA COSA.
        if (testi[EsitoDelPermesso.negato] ==
            testi[EsitoDelPermesso.negatoPerSempre]) {
          colpe.add('${voce.permesso}: negato e negato per sempre mostrano '
              'lo stesso testo, cioe\' sono tornati un esito solo');
        }
      }
      expect(colpe, isEmpty, reason: colpe.join('\n'));
    });

    testWidgets('negato porta a richiedere, negato per sempre porta alle '
        'impostazioni', (tester) async {
      var richieste = 0;
      var impostazioni = 0;
      Widget conContatori(EsitoDelPermesso esito) => MaterialApp(
            home: Scaffold(
              body: Center(
                child: AvvisoDelPermesso(
                  chiave: 'prova',
                  permesso: AppPermission.microphone,
                  esito: esito,
                  palette: palette,
                  onRichiedi: () async => richieste++,
                  onApriImpostazioni: () async => impostazioni++,
                ),
              ),
            ),
          );

      await tester.pumpWidget(conContatori(EsitoDelPermesso.negato));
      await tester.pump();
      await tester.tap(
          find.byKey(const Key('avviso_permesso_richiedi_prova')));
      await tester.pump();
      expect(richieste, 1);
      expect(impostazioni, 0,
          reason: 'Col primo no si richiede, non si mandano le persone nelle '
              'impostazioni.');

      await tester.pumpWidget(conContatori(EsitoDelPermesso.negatoPerSempre));
      await tester.pump();
      await tester.tap(
          find.byKey(const Key('avviso_permesso_impostazioni_prova')));
      await tester.pump();
      expect(impostazioni, 1,
          reason: 'Col no per sempre il pulsante DEVE aprire le impostazioni: '
              'chiedere ancora non mostrerebbe piu\' niente e sembrerebbe un '
              'pulsante rotto.');
      expect(richieste, 1, reason: 'E non deve richiedere.');
    });
  });

  test('nessun punto dell\'app appiattisce i due no', () {
    // L'ENUMERAZIONE SUL SORGENTE: si cercano i punti che chiedono un
    // permesso e si pretende che passino dalla porta unica o, per la
    // posizione, dal dato vero di Geolocator. Un punto che tiene un `bool`
    // ha gia' buttato l'informazione a monte.
    final colpe = <String>[];
    for (final voce in RegistroDeiPermessi.voci) {
      final file = File(voce.doveSiChiede);
      if (!file.existsSync()) continue;
      final sorgente = file.readAsStringSync();
      final passaDallaPorta = sorgente.contains('PortaDelPermesso.chiedi');
      final leggeIlDatoVero = sorgente.contains('deniedForever');
      // Il movimento non ha un permesso da chiedere su nessuna delle due
      // piattaforme: non c'e' niente da distinguere, ed e' scritto nel
      // registro.
      final senzaPermesso = voce.permesso == AppPermission.motion;
      if (!passaDallaPorta && !leggeIlDatoVero && !senzaPermesso) {
        colpe.add('${voce.permesso}: "${voce.doveSiChiede}" non passa dalla '
            'porta dei tre esiti e non legge il dato vero del sistema: i due '
            'no finiscono nello stesso valore.');
      }
    }
    expect(colpe, isEmpty, reason: colpe.join('\n'));
  });
}
