import 'dart:io';

import 'package:esoteric_circle/core/misura/misura_del_ritorno.dart';
import 'package:esoteric_circle/features/account/consensi_della_registrazione.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// I CONSENSI STANNO NELLA REGISTRAZIONE, E I DUE FOGLI NON ESCONO PIU'.
/// Ordine CE, voci 01, 02 e 03.
///
/// **Le parole del fondatore**, sul popup dell'invito incontrato usando l'app
/// senza registrarsi: "ma che cazzo di modo e'? [...] PERCHE NON POSSO AVERE LA
/// NORMALITA'". E sulla forma dei consensi, due volte: "la piu' veloce e non
/// invasiva che rispetti le norme".
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final santuario =
      File('lib/features/santuario/santuario_screen.dart').readAsStringSync();

  group('CE.02, i due fogli non escono piu\' dal Santuario', () {
    test('il Santuario non monta ne\' la domanda dell\'invito ne\' quella '
        'della misura', () {
      final vivi = <String>[];
      for (final segno in const [
        'DomandaDellInvito',
        'DomandaDellaMisura',
        '_forseChiediLInvito',
        '_forseChiediLaMisura',
      ]) {
        if (santuario.contains(segno)) vivi.add(segno);
      }
      // ignore: avoid_print
      print('ORDINE CE VOCE 02: fogli ancora montati dal Santuario '
          '${vivi.length}');
      expect(vivi, isEmpty,
          reason: 'il fondatore ha fatto togliere questi due fogli, e sono '
              'tornati: $vivi');
    });

    test('la porta per riscattare a mano resta nel menu\' Account', () {
      // **Il fondatore ha chiesto di togliere i popup, non ogni strada.**
      // Senza questa porta nessuno potrebbe piu' riscattare un invito nemmeno
      // volendo, e il premio da sessanta Eos diventerebbe irraggiungibile
      // invece che soltanto scomodo.
      final account =
          File('lib/features/account/account_screen.dart').readAsStringSync();
      expect(account.contains('apriIlRiscattoDellInvito'), isTrue,
          reason: 'e\' sparita anche la porta a mano, e adesso il premio '
              'dell\'invito non si puo\' riscuotere in nessun modo');
    });
  });

  group('CE.03, il blocco vive nel sotto menu\'', () {
    final impostazioni =
        File('lib/features/settings/settings_screen.dart').readAsStringSync();
    final sotto = File('lib/features/settings/privacy_e_permessi_screen.dart')
        .readAsStringSync();

    test('le tre voci spostate non sono piu\' nelle Impostazioni', () {
      final rimaste = <String>[];
      for (final segno in const {
        'il disclaimer': 'disclaimerCornice',
        'l\'interruttore della misura': 'InterruttoreDellaMisura',
        'le fonti dei dati': 'fontiDeiDati',
        'i permessi di sistema': 'PermessiDiSistema',
      }.entries) {
        if (impostazioni.contains(segno.value)) rimaste.add(segno.key);
      }
      // ignore: avoid_print
      print('ORDINE CE VOCE 03: voci ancora nelle Impostazioni '
          '${rimaste.length} su 4');
      expect(rimaste, isEmpty,
          reason: 'queste dovevano andare nel sotto menu\': $rimaste');
    });

    test('e sono tutte e quattro dentro il sotto menu\'', () {
      final mancanti = <String>[];
      for (final segno in const {
        'il disclaimer': 'disclaimerCornice',
        'l\'interruttore della misura': 'InterruttoreDellaMisura',
        'le fonti dei dati': 'fontiDeiDati',
        'i permessi di sistema': 'PermessiDiSistema',
      }.entries) {
        if (!sotto.contains(segno.value)) mancanti.add(segno.key);
      }
      // ignore: avoid_print
      print('ORDINE CE VOCE 03: voci dentro il sotto menu\' '
          '${4 - mancanti.length} su 4');
      expect(mancanti, isEmpty,
          reason: 'queste non sono state spostate, sono sparite: $mancanti');
    });

    test('il sotto menu\' e\' raggiungibile da una riga sola', () {
      expect(impostazioni.contains("Key('settings_privacy_e_permessi')"), isTrue,
          reason: 'il sotto menu\' esiste e non ci porta nessuno');
      expect(impostazioni.contains('PrivacyEPermessiScreen.route()'), isTrue);
      // E la cancellazione resta dov'era: il fondatore non l'ha spostata.
      expect(impostazioni.contains('_DeleteDataTile'), isTrue,
          reason: 'la cancellazione doveva restare nelle Impostazioni');
    });
  });

  group('CE.01, il consenso si da\' una volta, con un atto', () {
    testWidgets('l\'interruttore della misura nasce SPENTO', (tester) async {
      // **Un consenso pre-acceso non e' un consenso.** Il GDPR lo dice, e il
      // fondatore ha chiesto una soluzione "che rispetti le norme": e' l'unica
      // cosa qui dentro che la legge chiama consenso, e nasce spento anche per
      // chi lo aveva gia' concesso, perche' questa e' la schermata dove si da'
      // e non dove si rilegge.
      SharedPreferences.setMockInitialValues(
          const {'permesso.misuraDelRitorno': true});
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: ConsensiDellaRegistrazione()),
      ));
      await tester.pumpAndSettle();
      final acceso = tester
          .widget<Switch>(find.byKey(const Key('consenso_misura_interruttore')))
          .value;
      // ignore: avoid_print
      print('ORDINE CE VOCE 01: l\'interruttore nasce acceso? $acceso');
      expect(acceso, isFalse,
          reason: 'il consenso alla misura e\' pre-acceso, e un consenso '
              'pre-acceso non e\' libero');
    });

    testWidgets('nessun consenso si da\' senza un tocco', (tester) async {
      SharedPreferences.setMockInitialValues(const {});
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: ConsensiDellaRegistrazione()),
      ));
      await tester.pumpAndSettle();
      // Montare la schermata non e' un atto della persona.
      expect(await ConsensoDellaMisura.letto(), ConsensoAllaMisura.nonChiesto,
          reason: 'il consenso e\' stato scritto senza che nessuno toccasse '
              'niente');
      await tester.tap(find.byKey(const Key('consenso_misura_interruttore')));
      await tester.pumpAndSettle();
      expect(await ConsensoDellaMisura.letto(), ConsensoAllaMisura.concesso,
          reason: 'il tocco non ha concesso niente');
    });

    test('i consensi vivono in un punto solo, sopra le vie d\'accesso', () {
      final vie =
          File('lib/features/account/custodia_del_cielo.dart').readAsStringSync();
      expect(vie.contains('ConsensiDellaRegistrazione()'), isTrue,
          reason: 'i consensi non sono piu\' dentro il gesto della '
              'registrazione');
      // **Una copia sola.** Le vie d'accesso vivono in tre schermate: se i
      // consensi si montassero accanto a ognuna, tre copie divergerebbero.
      final quante = 'ConsensiDellaRegistrazione()'.allMatches(vie).length;
      expect(quante, 1,
          reason: 'i consensi sono montati $quante volte nello stesso file');
    });

    test('chi non si registra non viene contato', () {
      // La sola porta dove il consenso si da' e' la registrazione: chi non
      // passa di li' resta `nonChiesto`, e il registro non manda niente.
      final registro =
          File('lib/core/misura/registro_del_ritorno.dart').readAsStringSync();
      expect(
          registro.contains(
              'if (_consenso != ConsensoAllaMisura.concesso) return false'),
          isTrue,
          reason: 'il registro manda eventi anche a chi non ha mai concesso '
              'niente');
    });
  });
}
