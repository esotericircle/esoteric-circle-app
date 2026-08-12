import 'dart:io';

import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/sigilli/bonus_della_condivisione.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/services/ai/registro_dei_guasti.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IL SALDO CAMBIA A SCHERMO, E UN GUASTO LASCIA TRACCIA. Ordine S voce 04.
///
/// **Il fatto: le funzioni sono distribuite dal 12 agosto, i traguardi si
/// accendono, le celebrazioni dichiarano "+10 Eos", e il saldo in barra resta 0.**
///
/// **Due passi, e il primo e' una correzione a se'.** Il `catch` attorno
/// all'accredito non registrava niente: se l'accredito fallisce non lo sa nessuno,
/// ne' la persona ne' un registro ne' una prova. Finche' resta cosi', la causa non
/// e' leggibile da fuori e ogni ipotesi vale come le altre. E' lo stesso caso di
/// inizio agosto, quando la causa dell'accesso anonimo era gia' catturata in
/// `AppServices.diagnostics` e non la leggeva nessuno.
///
/// **E una causa e' stata trovata mentre si rendeva leggibile il guasto.** Il
/// saldo nuovo arriva DENTRO la risposta dell'accredito, ed era buttato: si
/// chiamava `sincronizza`, cioe' una seconda chiamata al server per tutto lo
/// stato del giorno. Se quella non risponde, e senza rete non risponde, il numero
/// in barra resta quello vecchio anche con l'accredito andato a buon fine.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('Il saldo cambia appena il server risponde', () {
    test('applicaSaldo muove il numero e avvisa chi guarda', () async {
      final borsa = QuestionAllowance();
      var avvisi = 0;
      borsa.addListener(() => avvisi++);
      expect(borsa.saldoEos, 0);

      await borsa.applicaSaldo(80);
      expect(borsa.saldoEos, 80,
          reason: 'il saldo non si e\' mosso: la barra continuerebbe a dire zero '
              'dopo un traguardo da ottanta Eos');
      expect(avvisi, 1,
          reason: 'nessuno e\' stato avvisato: il numero cambia nel dato e non a '
              'schermo, che e\' esattamente il difetto della voce');
    });

    test('lo stesso saldo non fa rumore', () async {
      // Un traguardo che non muove il saldo non deve far ridisegnare la barra:
      // un avviso per niente e' un fotogramma buttato a ogni sincronia.
      final borsa = QuestionAllowance();
      await borsa.applicaSaldo(30);
      var avvisi = 0;
      borsa.addListener(() => avvisi++);
      await borsa.applicaSaldo(30);
      expect(avvisi, 0);
      expect(borsa.saldoEos, 30);
    });

    test('il saldo applicato SOPRAVVIVE alla chiusura dell\'app', () async {
      final borsa = QuestionAllowance();
      await borsa.applicaSaldo(150);
      // Una borsa nuova, come al prossimo avvio: legge cio' che c'era.
      final dopo = QuestionAllowance();
      await dopo.load();
      expect(dopo.saldoEos, 150,
          reason: 'il saldo applicato non e\' stato scritto: al prossimo avvio la '
              'barra torna a zero e la persona vede sparire i suoi Eos');
    });
  });

  group('Un guasto dell\'accredito lascia traccia', () {
    test('il registro dei guasti raccoglie l\'operazione e il perche\'', () {
      // **Non si prova che l'accredito riesca**, perche' senza server non puo'
      // riuscire: si prova che il suo FALLIMENTO sia leggibile. E' il primo
      // passo della voce, e l'unico che si possa chiudere senza un dispositivo.
      final registro = RegistroDeiGuasti();
      expect(registro.haGuasti, isFalse);
      registro.registra(
        operazione: 'accredito del traguardo med_10',
        errore: 'il server non ha risposto',
      );
      expect(registro.haGuasti, isTrue);
      expect(registro.ultimo!.operazione, contains('accredito del traguardo'));
      expect(registro.ultimo!.messaggio, contains('non ha risposto'));
    });

    test('la regia registra il guasto invece di ingoiarlo', () {
      // Si legge il sorgente: e' l'unico modo di provare che un `catch` non e'
      // muto, perche' un catch muto non lascia niente da misurare a runtime.
      final s = File('lib/features/sigilli/regia_del_cammino.dart')
          .readAsStringSync();
      expect(s, contains('guasti.registra('),
          reason: 'il catch attorno all\'accredito e\' tornato muto: se '
              'l\'accredito fallisce non lo sa nessuno, e la causa del '
              'borsellino a zero torna illeggibile');
      // Due punti: il server che non risponde, e l'eccezione.
      expect('guasti.registra('.allMatches(s).length, greaterThanOrEqualTo(2),
          reason: 'uno dei due modi di fallire non lascia traccia');
      expect(s, contains('borsa.applicaSaldo(saldo)'),
          reason: 'il saldo che il server ha appena detto viene buttato di nuovo, '
              'e si torna ad aspettare una seconda chiamata che senza rete non '
              'arriva');
    });
  });

  group('Il premio si chiede per nome, e il nome esiste', () {
    test('ogni traguardo ha un motivo che il server sa valutare', () {
      // Se il motivo non fosse fra quelli che il server conosce, l'accredito
      // tornerebbe un errore e il saldo resterebbe fermo per sempre: e' una
      // delle quattro strade dell'ordine, e si chiude qui perche' e' l'unica
      // che si puo' misurare senza rete.
      const noti = {
        'traguardo_mini_primi_tre',
        'traguardo_mini',
        'traguardo_grande_10',
        'traguardo_grande_20',
        'traguardo_grande_30',
        'traguardo_grande_40',
        'traguardo_grande_50',
      };
      final sconosciuti = <String>[];
      for (final sentiero in Sentiero.values) {
        for (final t in Sentieri.di(sentiero)) {
          final motivo = PremioDelTraguardo.motivoDi(t);
          if (!noti.contains(motivo)) sconosciuti.add('${t.id}: $motivo');
        }
      }
      expect(sconosciuti, isEmpty,
          reason: 'questi traguardi chiedono un premio con un motivo che il '
              'server non conosce, quindi il loro accredito e\' un errore e il '
              'saldo non si muovera\' mai:\n${sconosciuti.take(8).join("\n")}');
    });

    test('la porta spenta non finge un accredito', () async {
      // Senza server il saldo NON si muove, e va bene: quello che non deve
      // succedere e' che si muova per finta, perche' allora la barra direbbe
      // una cifra che sul server non esiste.
      const porta = PortaSpentaDelCerchio();
      final saldo = await porta.muoviGliEos(
        causale: 'premio_sigillo',
        motivo: 'traguardo_mini',
        idMovimento: 'traguardo-prova-1',
      );
      expect(saldo, isNull,
          reason: 'la porta spenta ha risposto un numero: un saldo inventato in '
              'barra e\' peggio di un saldo fermo');
    });
  });
}
