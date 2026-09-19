import 'dart:io';

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
    test(
        'il Santuario non monta ne\' la domanda dell\'invito ne\' quella '
        'della misura', () {
      final vivi = <String>[];
      for (final segno in const [
        'DomandaDellInvito',
        // `DomandaDellaMisura` non c'e' piu' in nessun file: l'ordine EA
        // voce 12 ha tolto il foglio, che era gia' orfano.
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
      // **LA RIGA HA CAMBIATO CASA, ordine CF voce 16, e si dichiara cosa
      // supera.** Questa prova pretendeva la riga nelle IMPOSTAZIONI, ed era
      // giusto quando la voce CE.03 l'aveva messa li'. Il giorno dopo il
      // fondatore ha chiesto il contrario, con parole sue: "devi eliminare
      // dal menu' impostazioni 'privacy e permessi' [...] questi devono
      // esistere al massimo in un unico posto e cioe' nel menu' utente in un
      // sotto menu'". Il doppione era reale: il menu' utente aveva gia' una
      // voce "Privacy e dati" col nome quasi identico e la stessa icona.
      final menu =
          File('lib/features/account/account_screen.dart').readAsStringSync();
      expect(menu.contains("title: 'Privacy e permessi'"), isTrue,
          reason: 'il sotto menu\' esiste e non ci porta nessuno');
      expect(menu.contains('PrivacyEPermessiScreen.route()'), isTrue);
      // **E LA CANCELLAZIONE SI E' SPOSTATA ANCHE LEI**, per la stessa
      // richiesta: nelle Impostazioni non c'e' piu', nel menu' utente ci sono
      // i suoi due gradi, il cammino che riparte e l'account che sparisce.
      expect(impostazioni.contains('_DeleteDataTile'), isFalse,
          reason: 'la cancellazione e\' tornata nelle Impostazioni: sono due '
              'porte sulla stessa cosa');
      expect(menu.contains("title: 'Cancella i tuoi dati'"), isTrue,
          reason: 'la cancellazione del cammino non si raggiunge piu\'');
    });
  });

  group('CE.01, il consenso si da\' una volta, con un atto', () {
    testWidgets('la misura non si chiede piu\', e non c\'e\' niente da toccare',
        (tester) async {
      // **QUI C'ERANO DUE PROVE, ordine CE voce 01**: che l'interruttore
      // della misura nascesse spento e che nessun consenso si desse senza un
      // tocco. **L'ordine EA voce 12 ha tolto l'interruttore**: il fondatore
      // vuole il conteggio sempre attivo e non disturbante, e cio' che resta
      // sono contatori per giorno senza nessun identificativo, che non sono
      // un dato personale. Restano le altre due cose che questa schermata
      // deve dire, ed e' quello che si prova qui: la riga della privacy
      // policy e il fatto che nessuna casella chieda niente.
      SharedPreferences.setMockInitialValues(const {});
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: ConsensiDellaRegistrazione()),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(Switch), findsNothing,
          reason: 'e\' tornato un interruttore nel foglio dei consensi');
      expect(find.byType(Checkbox), findsNothing,
          reason: 'e\' comparsa una casella da spuntare');
      expect(find.textContaining('privacy policy'), findsOneWidget,
          reason: 'la riga che dice cosa si accetta e\' sparita');
    });

    test('i consensi vivono in un punto solo, sopra le vie d\'accesso', () {
      final vie = File('lib/features/account/custodia_del_cielo.dart')
          .readAsStringSync();
      expect(vie.contains('ConsensiDellaRegistrazione()'), isTrue,
          reason: 'i consensi non sono piu\' dentro il gesto della '
              'registrazione');
      // **DUE COPIE, E LA SECONDA E' LA CURA DELLA VOCE CF.15.** Qui si
      // pretendeva UNA copia sola, con la ragione che le vie d'accesso vivono
      // in tre schermate e tre copie divergerebbero. La ragione regge per le
      // tre vie della registrazione, che infatti passano tutte da
      // `VieDellaCustodia`. **Ma il ramo di chi rientra con un'email gia'
      // registrata non passa di li'**: costruisce il proprio pulsante, e
      // premerlo e' un ingresso nel Cerchio come gli altri. Il fondatore lo
      // ha notato: "quando disinstallo e poi reinstallo inserendo poi la mia
      // e-mail precedente, non dovrebbe esserci scritto che 'facendo click
      // accetti la privacy policy'?"
      //
      // **Due montaggi non sono due copie**: il widget e' uno solo, e cio'
      // che dice sta scritto in un punto solo.
      final quante = 'ConsensiDellaRegistrazione()'.allMatches(vie).length;
      expect(quante, 2,
          reason: 'i consensi sono montati $quante volte: le vie d\'ingresso '
              'sono due, la registrazione e il rientro, e tutte e due devono '
              'dire cosa si accetta');
    });

    test('il conteggio non guarda piu\' nessun consenso', () {
      // **ERA IL CONTRARIO, ordine CE voce 01**: si pretendeva che il
      // registro non mandasse niente a chi non aveva concesso. L'ordine EA
      // voce 12 ha tolto il consenso, perche' cio' che parte non porta
      // nessun identificativo: un nome di evento da un elenco chiuso e, al
      // massimo, una parola di contesto da un elenco chiuso.
      final registro =
          File('lib/core/misura/registro_del_ritorno.dart').readAsStringSync();
      for (final segno in const [
        'ConsensoAllaMisura',
        'ConsensoDellaMisura',
        'rileggiIlConsenso',
      ]) {
        expect(registro.contains(segno), isFalse,
            reason: 'il registro chiede di nuovo un permesso: $segno');
      }
    });
  });
}
