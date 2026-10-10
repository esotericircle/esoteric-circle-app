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
      // **LAPIDE, ordine EY Aggiunta 1, 4 ottobre 2026**: qui c'era
      // "EOS_DELL_INVITO_ACCOLTO = 60", la decisione del 18 settembre. Il
      // fondatore l'ha superata con centocinquanta a testa: la prova difende
      // la regola nuova, non quella vecchia.
      expect(listino.contains('EOS_DELL_INVITO_ACCOLTO = 150'), isTrue,
          reason: 'il premio dell\'invito accolto non vale piu\' '
              'centocinquanta Eos');
      expect(listino.contains('EOS_A_CHI_ARRIVA_CON_UN_INVITO = 150'), isTrue,
          reason: 'chi arriva con un invito non riceve piu\' centocinquanta '
              'Eos');
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
          .where((t) =>
              t.condizione.gestiNominati.any((g) => g.startsWith('invito')))
          .map((t) => t.id)
          .toList();
      // ignore: avoid_print
      print('ORDINE CP VOCE 05: gradini che poggiano su un invito '
          '${sullInvito.length} $sullInvito');
      expect(sullInvito, isEmpty,
          reason: 'un gradino e tornato a poggiare sull invito: va bene, ma '
              'va scritto, perche dipende da un altra persona');
    });

    // **LAPIDE, ordine EY voce 17, 4 ottobre 2026.** Qui c'erano due prove
    // dell'ordine BX voce 02: "il link dell'invito porta il codice", che
    // pretendeva `invito=<uid>.<maestro>` nel testo, e "senza uid il link
    // resta quello nudo". Difendevano l'uid in chiaro su WhatsApp, che
    // l'ordine EY ha tolto: il testo adesso porta solo la porta del Maestro,
    // e il codice OPACO lo mette la porta della condivisione. La regola nuova
    // la difende `il_link_d_invito_non_porta_l_uid_test.dart`; qui resta il
    // riscatto, che il codice incollato lo capisce ancora.
    test('Il testo dell\'invito porta la porta del Maestro e nessun uid', () {
      final traguardo = Sentieri.tuttiITraguardi.first;
      final testo = TestoDellaCondivisione.perIlTraguardo(
          traguardo, ModoDellaCondivisione.invitoConDownload,
          maestro: 'aura');
      // ignore: avoid_print
      print('ORDINE EY VOCE 17: il testo dell\'invito dice "$testo"');
      expect(testo.contains('?porta=aura'), isTrue);
      expect(testo.contains('invito='), isFalse);
      // E chi incolla il link d'invito intero deve essere capito lo stesso.
      expect(codiceDaCioCheEStatoIncollato('https://x?invito=AB12CD34.aura'),
          'AB12CD34.aura');
    });
  });
}
