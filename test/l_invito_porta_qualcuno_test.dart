import 'dart:io';

import 'package:esoteric_circle/core/sigilli/bonus_della_condivisione.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/features/account/riscatta_l_invito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'istante_dichiarato.dart';

/// L'INVITO CHE PORTA QUALCUNO. Ordine BX voce 02.
///
/// **Il difetto, verificato sul codice prima di toccarlo.** Il listino del
/// server pagava `invito_con_download` 60 Eos come bonus della condivisione,
/// cioe' al momento in cui l'invito veniva CONDIVISO: bastava aprire il foglio
/// di sistema e mandare il link a se stessi. La riga che la persona leggeva
/// sotto il pulsante prometteva un'altra cosa, "60 Eos quando il tuo amico
/// entra nel Cerchio", e nessuna attribuzione esisteva da nessuna parte.
///
/// **Firebase Dynamic Links non e' una strada**: Google lo ha spento
/// nell'agosto 2025. Il codice viaggia nel link come parametro, chi arriva lo
/// incolla, e il server attribuisce.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BX.02, il premio si paga a chi porta qualcuno', () {
    test('Il listino del server non paga piu\' la sola condivisione', () {
      // **PRIMO ROSSO DELL'ORDINE**: il premio incassato da un invito
      // condiviso e mai accettato deve valere zero. Si misura sul listino del
      // server, che e' l'unico posto dove il denaro si decide: se
      // `invito_con_download` torna in quel listino, il client puo' di nuovo
      // chiederlo alla condivisione.
      final listino = File('functions/src/borsellino.ts').readAsStringSync();
      final dentro = RegExp(r'BONUS_DELLA_CONDIVISIONE[^}]*}', dotAll: true)
              .firstMatch(listino)
              ?.group(0) ??
          '';
      final ceLInvito = RegExp(r'^\s*invito_con_download\s*:', multiLine: true)
          .hasMatch(dentro);
      // ignore: avoid_print
      print('ORDINE BX VOCE 2: il listino della condivisione paga ancora '
          'l\'invito? $ceLInvito');
      expect(ceLInvito, isFalse,
          reason: 'il listino della condivisione paga di nuovo l\'invito: '
              'chi condivide e non porta nessuno incassa lo stesso');
      // E il premio dell'invito accolto esiste, con il suo valore.
      expect(listino.contains('EOS_DELL_INVITO_ACCOLTO = 60'), isTrue,
          reason: 'il premio dell\'invito accolto non vale piu\' sessanta Eos');
      final cerchio = File('functions/src/cerchio.ts').readAsStringSync();
      expect(cerchio.contains('export const riscattaLInvito'), isTrue,
          reason: 'la porta che paga l\'invito accolto non esiste piu\'');
      expect(cerchio.contains('EOS_DELL_INVITO_ACCOLTO'), isTrue,
          reason: 'la porta dell\'invito non paga piu\' niente');
    });

    test('Le tre voci non maturano senza un ingresso vero', () async {
      // **SECONDO ROSSO DELL'ORDINE**: senza l'ingresso vero della persona
      // invitata, le tre voci restano spente. Il conto arriva dal server e
      // il telefono non lo puo' scrivere da solo.
      SharedPreferences.setMockInitialValues(const {});
      final diario = DiarioDelCammino(orologio: orologioDelleProve);
      await diario.carica();
      final tre = [
        for (final id in ['med_17', 'aur_15', 'cal_16'])
          Sentieri.tuttiITraguardi.firstWhere((t) => t.id == id),
      ];
      for (final voce in tre) {
        expect(voce.dormiente, isFalse,
            reason: '${voce.id} dorme ancora: la condizione non e\' arrivata '
                'al cammino');
      }
      var stato = diario.statoDelCammino();
      for (final voce in tre) {
        expect(voce.condizione.raggiunto(stato), isFalse,
            reason: '"${voce.nome}" si accende senza che nessuno sia entrato');
      }

      // Il server dice che UNA persona e' entrata, dalla porta di Medora.
      await diario.allineaGliInviti(1, perMaestro: const {'medora': 1});
      stato = diario.statoDelCammino();
      // ignore: avoid_print
      print('ORDINE BX VOCE 2: dopo un ingresso dalla porta di Medora, '
          'accendono ${tre.where((t) => t.condizione.raggiunto(stato)).map((t) => t.id).toList()}');
      expect(tre[0].condizione.raggiunto(stato), isTrue,
          reason: 'un ingresso dalla porta di Medora non accende med_17');
      expect(tre[1].condizione.raggiunto(stato), isFalse,
          reason: 'un ingresso dalla porta di Medora accende anche la voce di '
              'Aura: le tre voci misurano lo stesso fatto');
      expect(tre[2].condizione.raggiunto(stato), isFalse,
          reason: 'un ingresso dalla porta di Medora accende anche la voce di '
              'Caligo');
    });

    test('Il link dell\'invito porta il codice, e il codice torna indietro',
        () {
      final codice =
          TestoDellaCondivisione.codiceDellInvito('abc123xyz', 'aura');
      expect(codice, 'abc123xyz.aura');
      final traguardo = Sentieri.tuttiITraguardi.first;
      final testo = TestoDellaCondivisione.perIlTraguardo(
          traguardo, ModoDellaCondivisione.invitoConDownload,
          codiceInvito: codice);
      // ignore: avoid_print
      print('ORDINE BX VOCE 2: il testo dell\'invito dice "$testo"');
      expect(testo.contains('invito=abc123xyz.aura'), isTrue,
          reason: 'il link dell\'invito non porta il codice: chi arriva non '
              'puo\' riconoscere nessuno');
      // E chi incolla il link intero deve essere capito lo stesso.
      expect(codiceDaCioCheEStatoIncollato(testo), 'abc123xyz.aura');
      expect(codiceDaCioCheEStatoIncollato('abc123xyz.aura'), 'abc123xyz.aura');
    });

    test('Senza uid il link resta quello nudo di prima', () {
      final codice = TestoDellaCondivisione.codiceDellInvito(null, 'aura');
      expect(codice, '');
      final testo = TestoDellaCondivisione.perIlTraguardo(
          Sentieri.tuttiITraguardi.first,
          ModoDellaCondivisione.invitoConDownload,
          codiceInvito: codice);
      // ignore: avoid_print
      print('ORDINE BX VOCE 2: senza uid il link porta un codice? '
          '${testo.contains('invito=')}');
      expect(testo.contains('invito='), isFalse,
          reason: 'senza uid il link finge di avere un codice');
    });
  });
}
