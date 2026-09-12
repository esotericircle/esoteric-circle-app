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
      // **LA PORTA RESTA, IL GRADINO NO. Ordine CP voce 05.**
      //
      // Fino alla revisione E tre gradini, `med_17`, `aur_15` e `cal_16`,
      // premiavano l'invito accolto, uno per Maestro. **La revisione F non ne
      // scrive nessuno**, ed e' una decisione motivata: un invito accolto
      // dipende da un'altra persona, e un gradino che dipende da qualcun
      // altro non e' raggiungibile da chi cammina. La regola 5 del fondatore
      // chiede traguardi raggiungibili con sforzo, non con fortuna altrui.
      //
      // **Cio' che questa prova sorveglia non e' cambiato**: il conto degli
      // ingressi arriva dal server, il telefono non se lo scrive da solo, e
      // ogni porta e' contata per il suo Maestro invece che tutte insieme.
      // Qui si misura direttamente quel conto, che e' il fatto vero; il
      // gradino sopra era solo il premio, e il premio puo' tornare senza che
      // niente di questo cambi.
      expect(diario.statoDelCammino().gestiCompiuti['invito_medora'] ?? 0, 0,
          reason: 'il telefono si e scritto un invito da solo');

      // Il server dice che UNA persona e' entrata, dalla porta di Medora.
      await diario.allineaGliInviti(1, perMaestro: const {'medora': 1});
      // ignore: avoid_print
      print('ORDINE CP VOCE 05: dopo un ingresso dalla porta di Medora, '
          'invito ${diario.statoDelCammino().gestiCompiuti['invito']}, medora '
          '${diario.statoDelCammino().gestiCompiuti['invito_medora']}, aura '
          '${diario.statoDelCammino().gestiCompiuti['invito_aura'] ?? 0}, caligo '
          '${diario.statoDelCammino().gestiCompiuti['invito_caligo'] ?? 0}');
      expect(diario.statoDelCammino().gestiCompiuti['invito'], 1,
          reason: 'il conto degli inviti accolti non e arrivato al diario');
      expect(diario.statoDelCammino().gestiCompiuti['invito_medora'], 1,
          reason: 'la porta di Medora non ha contato il suo ingresso');
      expect(diario.statoDelCammino().gestiCompiuti['invito_aura'] ?? 0, 0,
          reason: 'un ingresso dalla porta di Medora ha contato anche per '
              'Aura: le tre porte misurano lo stesso fatto');
      expect(diario.statoDelCammino().gestiCompiuti['invito_caligo'] ?? 0, 0,
          reason: 'un ingresso dalla porta di Medora ha contato anche per '
              'Caligo');

      // **E NESSUN GRADINO POGGIA SULL'INVITO**, che e' la conseguenza da
      // dichiarare invece di lasciarla implicita: se un giorno tornera', la
      // riga qui sotto cadra' e chi la legge sapra' che il premio e' tornato.
      final sullInvito = Sentieri.tuttiITraguardi
          .where((t) => t.condizione.gestiNominati
              .any((g) => g.startsWith('invito')))
          .map((t) => t.id)
          .toList();
      // ignore: avoid_print
      print('ORDINE CP VOCE 05: gradini che poggiano su un invito '
          '${sullInvito.length} $sullInvito');
      expect(sullInvito, isEmpty,
          reason: 'un gradino e tornato a poggiare sull invito: va bene, ma '
              'va scritto, perche dipende da un altra persona');
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
