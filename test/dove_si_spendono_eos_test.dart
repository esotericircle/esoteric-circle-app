import 'dart:io';

import 'package:esoteric_circle/core/entitlement/pacchetti_di_eos.dart';
import 'package:flutter_test/flutter_test.dart';

/// DOVE SI SPENDONO EOS, IL GESTO NON PARTE DA SOLO. Ordine CE voci 05, 06 e
/// 09.
///
/// **Le parole del fondatore:** "serve pulsante consenso esplicito solo se
/// l'utente spende EOS", e sul borsellino "se l'utente vuole comprare EOS, ma
/// cmq non ne ha abbastanza, viene trasportato al borsellino e nel borsellino
/// c'e' l'avvertenza che gli EOS disponibili non bastano con il pulsante
/// acquista un pacchetto EOS o abbonati per continuare".
void main() {
  /// Tutti i file dell'app, letti una volta sola.
  final files = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  String senzaCommenti(File f) => f
      .readAsLinesSync()
      .where((r) => !r.trimLeft().startsWith('//'))
      .join('\n');

  group('CE.05, la porta della spesa', () {
    test('nessuno spende Eos fuori dalla porta della spesa', () {
      // **QUESTA PROVA ENUMERA I CHIAMANTI.** Oggi ne trova zero, ed e' un
      // fatto misurato e dichiarato nel manifesto: nessun punto dell'app
      // spende ancora Eos. La prova non e' inutile per questo, e' il
      // contrario: e' la trappola che il primo punto che nascera' dovra'
      // attraversare.
      final fuori = <String>[];
      for (final f in files) {
        final percorso = f.path.replaceAll(r'\', '/');
        if (percorso.endsWith('porta_della_spesa.dart')) continue;
        if (percorso.endsWith('spesa_degli_eos.dart')) continue;
        final testo = senzaCommenti(f);
        if (testo.contains('SpesaDegliEos.perLaVoce')) fuori.add(percorso);
      }
      // ignore: avoid_print
      print('ORDINE CE VOCE 05: punti che spendono Eos fuori dalla porta '
          '${fuori.length}');
      expect(fuori, isEmpty,
          reason: 'questi punti spendono Eos senza passare dalla porta, '
              'quindi senza pulsante esplicito e senza difesa dal doppio '
              'tocco: $fuori');
    });

    test('la porta si difende dal doppio tocco e paga sull\'esito', () {
      final porta = File('lib/design_system/components/porta_della_spesa.dart');
      final testo = senzaCommenti(porta);
      // Il pulsante si spegne al primo tocco.
      expect(testo.contains('onPressed: _inCorso ? null : _tocca'), isTrue,
          reason: 'il pulsante resta vivo durante la chiamata, e il doppio '
              'tocco spende due volte');
      // E cio' che viene dopo succede SOLO se la spesa e' andata a buon fine.
      expect(testo.contains('case EsitoDellaSpesa.fatta:'), isTrue);
      expect(testo.contains('widget.suSpesaFatta();'), isTrue,
          reason: 'la porta non distingue piu\' l\'esito, quindi un ripiego '
              'addebiterebbe');
    });

    test('a saldo insufficiente si va al borsellino, non in un vicolo', () {
      final testo = senzaCommenti(
          File('lib/design_system/components/porta_della_spesa.dart'));
      expect(testo.contains('EsitoDellaSpesa.saldoInsufficiente'), isTrue);
      expect(testo.contains('PortafoglioDelCerchio.apri(context)'), isTrue,
          reason: 'chi non ha abbastanza Eos resta fermo senza una via');
    });
  });

  group('CE.06 e CE.09, i pacchetti e la via d\'uscita', () {
    final foglio = File('lib/design_system/components/borsellino.dart');

    test('il borsellino dichiara i pacchetti e le due vie', () {
      final testo = senzaCommenti(foglio);
      expect(testo.contains('pacchettiDiEos'), isTrue,
          reason: 'il borsellino non mostra nessun pacchetto');
      expect(testo.contains("Key('portafoglio_pacchetti_avvertenza')"), isTrue,
          reason: 'manca l\'avvertenza che il fondatore ha chiesto');
      expect(testo.contains("Key('portafoglio_oppure_abbonati')"), isTrue,
          reason: 'manca la seconda via, "o abbonati per continuare"');
    });

    test('i tre pacchetti hanno una scala vera, e nessuno arriva al Cammino',
        () {
      expect(pacchettiDiEos, hasLength(3));
      // Ogni pacchetto costa meno per Eos del precedente: la scala esiste ed
      // e' mite, perche' uno sconto forte spingerebbe a comprare scorte
      // invece di abbonarsi.
      for (var i = 1; i < pacchettiDiEos.length; i++) {
        expect(pacchettiDiEos[i].perEos, lessThan(pacchettiDiEos[i - 1].perEos),
            reason: 'il pacchetto ${pacchettiDiEos[i].id} non conviene piu\' '
                'del precedente, quindi non esiste una ragione per prenderlo');
      }
      // ignore: avoid_print
      final detto = pacchettiDiEos
          .map((p) => '${p.eos} Eos a ${p.prezzo} '
              '(${p.perEos.toStringAsFixed(4)} per Eos)')
          .join(', ');
      // ignore: avoid_print
      print('ORDINE CE VOCE 09: $detto');
      // **NESSUNO ARRIVA AI 6.030 DEL CAMMINO COMPLETO**, ed e' una scelta: il
      // cammino deve restare la via piu' ricca.
      for (final p in pacchettiDiEos) {
        expect(p.eos, lessThan(6030),
            reason: '${p.id} da\' piu\' Eos di quanti ne conia il Cammino '
                'intero, e allora camminare non vale piu\' niente');
      }
    });

    test('finche\' non c\'e\' un negozio, non si promette un acquisto', () {
      // Vincolo del fondatore: "si ferma li' e lo DICHIARA a schermo invece di
      // promettere un acquisto che non avviene".
      expect(acquistiCollegatiAUnNegozio, isFalse,
          reason: 'se gli acquisti sono collegati davvero, questa prova va '
              'riscritta insieme al codice che li collega');
      expect(pacchettiNonAncoraInVendita, contains('pubblicazione'),
          reason: 'la frase non dice quando arrivano');
    });
  });
}
