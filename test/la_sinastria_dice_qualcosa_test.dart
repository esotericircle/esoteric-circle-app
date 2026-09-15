import 'package:esoteric_circle/core/synastry/cielo_della_sinastria.dart';
import 'package:esoteric_circle/core/synastry/possibilita_di_incontro.dart';
import 'package:esoteric_circle/core/synastry/synastry_report.dart';
import 'package:esoteric_circle/core/synastry/vip_catalog.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA SINASTRIA DICE QUALCOSA. Ordine BX voce 09.
///
/// **I quattro rilievi del fondatore, misurati e non creduti.** L'ordine
/// diceva che i punteggi stavano sempre fra 45 e 65, che la possibilita' di
/// incontro era sempre bassissima, che le dimensioni erano troppo poche e che
/// non si sapeva se lo stato in vita di un VIP potesse cambiare senza
/// pubblicare l'app.
///
/// **Tre erano veri e uno era falso.** La possibilita' di incontro NON era
/// sempre bassissima: era sempre bassissima **con una citta' sola**, perche'
/// la misura del fondatore usava Milano per tutti. Con le citta' vere di chi
/// legge, i cinque gradini si raggiungono tutti. La correzione e' stata fatta
/// lo stesso, perche' la barra mostrava la percentuale grezza su una scala
/// da zero a cento e a schermo era un filo in ogni caso.
///
/// **La misura e' su 600 coppie vere**, non su un esempio: dodici nascite
/// sparse nell'anno per cinquanta personaggi del catalogo, con tre citta'
/// diverse per chi guarda.
void main() {
  /// Le 600 coppie, calcolate una volta sola.
  late final List<SynastryReport> coppie = () {
    final tutte = <SynastryReport>[];
    for (var mese = 1; mese <= 12; mese++) {
      final tuo = CieloDiSinastria.perNascita(
        momentoUtc: DateTime.utc(1990, mese, 15, 12),
        latitudine: 45.46,
        longitudineDelLuogo: 9.19,
      );
      final dove = switch (mese % 3) {
        0 => const DoveSei(
            citta: 'Los Angeles', latitudine: 34.05, longitudine: -118.24),
        1 =>
          const DoveSei(citta: 'Londra', latitudine: 51.5, longitudine: -0.12),
        _ =>
          const DoveSei(citta: 'Milano', latitudine: 45.46, longitudine: 9.19),
      };
      for (final vip in VipCatalog.vips) {
        tutte.add(SynastryReport.perCieli(tuo: tuo, vip: vip, doveSei: dove));
      }
    }
    return tutte;
  }();

  setUp(CorrezioniDeiVip.azzera);
  tearDown(CorrezioniDeiVip.azzera);

  group('BX.09, i punteggi hanno di nuovo una larghezza', () {
    test('L\'affinita\' non sta piu\' stretta fra 45 e 65', () {
      // **PRIMO ROSSO.** Il difetto era una compressione: i pavimenti a 40 e
      // una curva che schiacciava tutto intorno alla mediana facevano vivere
      // 492 coppie su 600 dentro quella fascia. La grandezza misurata sono i
      // percentili, non il minimo e il massimo: due valori estremi fortunati
      // potrebbero mentire su un mucchio schiacciato.
      final ordinati = [for (final r in coppie) r.overall]..sort();
      int percentile(int p) =>
          ordinati[(ordinati.length * p ~/ 100).clamp(0, ordinati.length - 1)];
      final dentro = ordinati.where((v) => v >= 45 && v <= 65).length;
      // ignore: avoid_print
      print('ORDINE BX VOCE 9: affinita\' su ${ordinati.length} coppie, da '
          '${ordinati.first} a ${ordinati.last}, percentili 10=${percentile(10)} '
          '50=${percentile(50)} 90=${percentile(90)}, dentro 45-65 $dentro');
      expect(percentile(10), lessThanOrEqualTo(35),
          reason: 'il decimo piu\' basso non scende sotto 35: i punteggi sono '
              'di nuovo tutti uguali');
      expect(percentile(90), greaterThanOrEqualTo(68),
          reason: 'il decimo piu\' alto non arriva a 68: nessuna coppia si '
              'distingue');
      expect(dentro * 2, lessThan(ordinati.length),
          reason: 'piu\' di meta\' delle coppie sta ancora fra 45 e 65');
      expect(ordinati.first, lessThanOrEqualTo(20),
          reason: 'nessuna coppia scende sotto 20: il pavimento e\' tornato');
      expect(ordinati.last, greaterThanOrEqualTo(88),
          reason: 'nessuna coppia arriva a 88: il soffitto e\' tornato');
    });

    test('La possibilita\' di incontro raggiunge tutti e cinque i gradini', () {
      // **SECONDO ROSSO.** La barra mostrava la percentuale grezza su una
      // scala da zero a cento: una probabilita' vera del 4 per cento e' un
      // filo invisibile, e chi guarda legge "impossibile" anche quando la
      // parola dice altro. Adesso la barra usa l'indice sulla scala, e le
      // parole coprono tutto l'arco.
      final parole = {for (final r in coppie) r.incontro.inParole};
      final indici = [for (final r in coppie) r.incontro.indiceSullaScala];
      // ignore: avoid_print
      print('ORDINE BX VOCE 9: incontro, gradini raggiunti $parole, indice da '
          '${indici.reduce((a, b) => a < b ? a : b)} a '
          '${indici.reduce((a, b) => a > b ? a : b)}');
      expect(parole.length, 5,
          reason: 'i cinque gradini della possibilita\' di incontro non si '
              'raggiungono tutti: la scala e\' di nuovo schiacciata');
      expect(indici.reduce((a, b) => a > b ? a : b), greaterThanOrEqualTo(60),
          reason: 'la barra dell\'incontro non arriva mai oltre il 60 per '
              'cento della sua larghezza: resta un filo a schermo');
    });

    test('Le dimensioni sono sette, e le tre nuove guardano cose diverse', () {
      // **TERZO ROSSO.** Erano quattro, e tre delle quattro guardavano lo
      // stesso materiale: gli aspetti fra i punti personali.
      final r = coppie.first;
      final nomi = [for (final b in r.bars) b.label];
      // ignore: avoid_print
      print('ORDINE BX VOCE 9: dimensioni ${nomi.length}, $nomi');
      expect(nomi.length, greaterThanOrEqualTo(7),
          reason: 'le dimensioni sono tornate sotto sette');
      for (final atteso in ['Terra comune', 'Ritmo', 'Vita quotidiana']) {
        expect(nomi, contains(atteso),
            reason: 'la dimensione "$atteso" non c\'e\' piu\'');
      }
      // E non sono tre copie: su 600 coppie ognuna deve avere valori suoi.
      for (final quale in ['Terra comune', 'Ritmo', 'Vita quotidiana']) {
        final valori = {
          for (final c in coppie)
            c.bars.firstWhere((b) => b.label == quale).value
        };
        expect(valori.length, greaterThan(1),
            reason: '"$quale" vale sempre lo stesso numero: non misura niente');
      }
    });
  });

  group('BX.09, lo stato in vita cambia senza pubblicare l\'app', () {
    test('Il catalogo compilato da solo non puo\' cambiare', () {
      // **IL FATTO ACCERTATO, come l'ordine chiede.** `vips` e' dichiarata
      // `static const List<Vip>`: nessuna riga di codice puo' cambiarne un
      // campo a runtime, quindi prima di quest'ordine lo stato in vita di una
      // persona poteva cambiare solo con una versione nuova sugli store.
      expect(CorrezioniDeiVip.quante, 0);
      final vivo = VipCatalog.vips.firstWhere((v) => !v.eScomparso);
      expect(vivo.statoInVita, StatoInVita.inVita,
          reason: 'il catalogo compilato non dice piu\' che questa persona e\' '
              'in vita');
    });

    test('Una correzione del server arriva fino a cio\' che si legge', () {
      // **QUARTO ROSSO.** Si misura la strada intera: il documento del server
      // diventa risposta di `statoDelCerchio`, la risposta diventa stato, lo
      // stato diventa correzione, e la correzione cambia la frase che la
      // persona legge. Se un anello si rompe, questo rosso scatta.
      final vivo = VipCatalog.vips.firstWhere((v) => !v.eScomparso);
      final tuo = CieloDiSinastria.perNascita(
        momentoUtc: DateTime.utc(1990, 6, 15, 12),
        latitudine: 45.46,
        longitudineDelLuogo: 9.19,
      );
      const dove =
          DoveSei(citta: 'Milano', latitudine: 45.46, longitudine: 9.19);
      final prima = SynastryReport.perCieli(tuo: tuo, vip: vivo, doveSei: dove);
      expect(prima.incontro.esiste, isTrue,
          reason: 'una persona in vita non si puo\' gia\' incontrare');

      // La risposta del server, con la sola cosa che il documento porta.
      final stato = StatoDelCerchio.daMappa({
        'giorno': '2026-08-28',
        'piano': 'free',
        'spesi': const <String, Object?>{},
        'saldoEos': 100,
        'correzioniDeiVip': {vivo.name: 'scomparso'},
      });
      expect(stato, isNotNull,
          reason: 'lo stato del Cerchio non si legge piu\'');
      expect(stato!.correzioniDeiVip[vivo.name], 'scomparso',
          reason: 'la correzione non sopravvive alla lettura della risposta: '
              'il server puo\' dire quel che vuole, non arriva');
      CorrezioniDeiVip.applica(stato.correzioniDeiVip);

      // ignore: avoid_print
      print('ORDINE BX VOCE 9: dopo la correzione del server, '
          '"${vivo.name}" e\' scomparso? ${vivo.eScomparso}');
      expect(vivo.eScomparso, isTrue,
          reason: 'la correzione del server non cambia lo stato in vita: per '
              'dirlo servirebbe ancora una versione nuova dell\'app');
      final dopo = SynastryReport.perCieli(tuo: tuo, vip: vivo, doveSei: dove);
      expect(dopo.incontro.esiste, isFalse,
          reason: 'l\'app continua a proporre di incontrare una persona che il '
              'server ha dichiarato scomparsa');

      // E il ritorno indietro vale quanto l'andata: una mappa vuota riporta
      // al catalogo compilato, che e' l'ultima verita' conosciuta.
      CorrezioniDeiVip.applica(const {});
      expect(vivo.eScomparso, isFalse,
          reason: 'la correzione resta appiccicata anche quando il server '
              'smette di mandarla');
    });

    test('La correzione tocca lo stato e nient\'altro', () {
      // Il documento del server non deve poter riscrivere l'astrologia di
      // una persona: solo lo stato in vita passa di li'.
      final vivo = VipCatalog.vips.firstWhere((v) => !v.eScomparso);
      final natoQuando = vivo.giornoDiNascita;
      CorrezioniDeiVip.applica({vivo.name: 'scomparso'});
      expect(vivo.giornoDiNascita, natoQuando,
          reason: 'la data di nascita e\' cambiata con la correzione');
      // Parole che non sono uno stato non si applicano.
      CorrezioniDeiVip.applica({vivo.name: 'forse'});
      expect(CorrezioniDeiVip.quante, 0,
          reason: 'una parola che non e\' uno stato entra lo stesso fra le '
              'correzioni');
      expect(vivo.eScomparso, isFalse);
    });
  });
}
