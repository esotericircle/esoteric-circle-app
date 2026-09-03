import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';
import 'istante_dichiarato.dart';

/// **IL GRADINO NON MATURA FINCHÉ IL PRECEDENTE NON È STATO CONGEDATO.**
/// Ordine CP voce 01, 3 settembre 2026.
///
/// Decisione del fondatore, parole sue: *"il gradino non matura finche' il
/// precedente non e' stato congedato."* Nasce da otto feste viste in due
/// funzionalità la notte fra il 2 e il 3 settembre 2026.
///
/// **Un posto solo in tutto il Cammino, non uno per sentiero.** La prima
/// regola del fondatore, del 17 agosto 2026, dice *"non deve esserci la
/// possibilita' di raggiungere piu' di un traguardo alla volta"*, e non dice
/// "più di uno per sentiero": con un posto per sentiero un gesto che tocca tre
/// arti ne farebbe maturare tre insieme, che è esattamente ciò che la regola
/// vieta.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<DiarioDelCammino> diarioPulito() async {
    SharedPreferences.setMockInitialValues(const {});
    final d = DiarioDelCammino(orologio: orologioDelleProve);
    await d.carica();
    return d;
  }

  /// Lo stato che soddisfa quanti più gradini possibile: serve a provare che
  /// il freno regge anche quando tutto il resto sarebbe pronto.
  ///
  /// **NON SI SCRIVE A MANO, si costruisce DAL CORPUS.** Ordine CP voce 05.
  /// Prima era un elenco di gesti con un nove accanto, e la revisione F l'ha
  /// reso muto in un colpo solo: i suoi conteggi finivano in `gestiCompiuti`,
  /// mentre il corpus nuovo conta i GIORNI, e lo stato generoso non
  /// soddisfaceva piu' niente. **Una prova sul freno che non ha niente da
  /// frenare e' verde per la ragione sbagliata**, ed e' esattamente quello
  /// che sarebbe successo.
  ///
  /// Adesso lo stato si ricava chiedendo a ogni condizione cosa le serve: un
  /// corpus nuovo lo aggiorna da solo.
  StatoDelCammino statoGeneroso() {
    final giorniConGesto = <String, int>{};
    final costanzeLarghe = <String, int>{};
    final oraFedele = <String, int>{};
    final nellOraGiusta = <String, int>{};
    final giornate = <String, int>{};
    final pezzi = <String>{};
    final cielo = <String>{};
    final oggi = <String>{};
    for (final t in Sentieri.tuttiITraguardi) {
      final c = t.condizione;
      oggi.addAll(c.gestiNominati);
      switch (c) {
        case GestiCompiuti(:final gesto, :final quanti):
          giorniConGesto[gesto] = quanti;
        case GiorniDentroUnArco(:final rito, :final quanti, :final arco):
          costanzeLarghe['$rito:$arco'] = quanti;
        case StessaOraPerGiorni(:final gesto, :final quantiGiorni):
          oraFedele[gesto] = quantiGiorni;
        case GestoNellOraGiusta(:final gesto, :final ora, :final quanteVolte):
          nellOraGiusta['$gesto@$ora'] = quanteVolte;
        case GiornateInsieme(:final chiave, :final quantiGiorni):
          giornate[chiave] = quantiGiorni;
        case PezzoDellIdentita(:final pezzo):
          pezzi.add(pezzo);
        case FinestraDelCielo(:final evento):
          cielo.add(evento);
        default:
          break;
      }
    }
    return StatoDelCammino(
      giorniConGesto: giorniConGesto,
      costanzeLarghe: costanzeLarghe,
      oraFedelePerGesto: oraFedele,
      gestiNellOraGiusta: nellOraGiusta,
      giornateInsieme: giornate,
      pezziDellIdentita: pezzi,
      eventiDelCieloDiOggi: cielo,
      oggiHaFatto: oggi,
    );
  }

  test('lo stato generoso soddisfa davvero quasi tutto il corpus', () async {
    // **IL CARDINALE DI QUESTA PROVA.** Ordine CP voce 05: senza questa riga,
    // uno stato generoso diventato muto renderebbe verdi tutte le prove qui
    // sotto senza che frenino niente. Il numero e' quanti gradini quello
    // stato soddisfa, e si legge.
    // **SI CHIEDE ALLE CONDIZIONI, non al Cammino.** Ordine CP voce 01: dopo
    // la scala il Cammino ne fa maturare al massimo tre, uno per sentiero, e
    // chiederlo a lui darebbe tre invece di centosessantacinque. La domanda
    // qui e' un'altra: **quanti gradini quello stato SODDISFA**, cioe' quanto
    // c'e' da frenare. Se un giorno lo stato generoso diventasse muto, tutte
    // le prove qui sotto sarebbero verdi per non aver frenato niente.
    await diarioPulito();
    final stato = statoGeneroso();
    final soddisfatti = Sentieri.tuttiITraguardi
        .where((t) => t.condizione.raggiunto(stato))
        .length;
    // ignore: avoid_print
    print('ORDINE CP VOCE 05: lo stato generoso soddisfa $soddisfatti gradini '
        'su ${Sentieri.tuttiITraguardi.length}');
    cardinaleMinimo(soddisfatti, 150,
        cosa: 'gradini soddisfatti dallo stato generoso',
        perche: 'Se lo stato generoso smettesse di soddisfare i gradini, '
            'tutte le prove del freno sarebbero verdi per non aver frenato '
            'niente.');
  });

  test('a strada libera matura uno solo, e il posto si occupa', () async {
    final d = await diarioPulito();
    expect(d.laStradaELibera, isTrue,
        reason: 'un Cammino appena nato ha il posto gia occupato');

    final primi = await d.quelliCheSiAccendono(statoGeneroso());
    expect(primi.length, 1,
        reason: 'con uno stato che soddisfa molti gradini ne maturano '
            '${primi.length} insieme: la prima regola del fondatore dice che '
            'non se ne puo raggiungere piu di uno alla volta');
    await d.accendi(primi.first.id);
    expect(d.inAttesaDiCongedo, primi.first.id,
        reason: 'il gradino acceso non ha occupato il posto del congedo');
    expect(d.laStradaELibera, isFalse);
  });

  test('col posto occupato NON matura piu niente, per quanti gesti si facciano',
      () async {
    final d = await diarioPulito();
    final primi = await d.quelliCheSiAccendono(statoGeneroso());
    await d.accendi(primi.first.id);

    // **OTTO GIRI, che sono le otto feste viste dal fondatore.** Ogni giro
    // rappresenta un gesto in piu': prima ognuno drenava un gradino
    // dall'arretrato dei soddisfatti, e otto gesti facevano otto feste.
    var maturati = 0;
    for (var i = 0; i < 8; i++) {
      maturati += (await d.quelliCheSiAccendono(statoGeneroso())).length;
    }
    expect(maturati, 0,
        reason: 'col gradino precedente ancora da congedare ne sono maturati '
            'altri $maturati: sono $maturati feste in piu, ed e esattamente '
            'cio che il fondatore ha visto sul telefono');
  });

  test('congedato il precedente, il Cammino riprende', () async {
    final d = await diarioPulito();
    final primi = await d.quelliCheSiAccendono(statoGeneroso());
    await d.accendi(primi.first.id);
    await d.congeda(primi.first.id);
    expect(d.laStradaELibera, isTrue,
        reason: 'il congedo non ha liberato il posto: il Cammino resterebbe '
            'fermo per sempre');
    final dopo = await d.quelliCheSiAccendono(statoGeneroso());
    expect(dopo.length, 1,
        reason: 'congedato il precedente non matura piu niente: il freno e '
            'diventato un muro');
    expect(dopo.first.id, isNot(primi.first.id));
  });

  test('congedare il gradino sbagliato non apre la strada', () async {
    // Il posto si libera SOLO per chi lo occupa: congedare un altro id
    // aprirebbe la strada a due maturazioni insieme.
    final d = await diarioPulito();
    final primi = await d.quelliCheSiAccendono(statoGeneroso());
    await d.accendi(primi.first.id);
    await d.congeda('un_id_che_non_ce');
    expect(d.laStradaELibera, isFalse,
        reason: 'congedare un gradino che non aspettava ha liberato il posto');
  });

  test('il posto sopravvive alla chiusura dell app', () async {
    SharedPreferences.setMockInitialValues(const {});
    final primo = DiarioDelCammino(orologio: orologioDelleProve);
    await primo.carica();
    final maturati = await primo.quelliCheSiAccendono(statoGeneroso());
    await primo.accendi(maturati.first.id);

    // Si riapre l'app: un diario nuovo che legge lo stesso disco.
    final secondo = DiarioDelCammino(orologio: orologioDelleProve);
    await secondo.carica();
    expect(secondo.inAttesaDiCongedo, maturati.first.id,
        reason: 'chiudere e riaprire l app libera il posto del congedo, cioe '
            'e il modo piu semplice di aggirare la regola');
  });

  test('un id che il corpus non ha piu NON mura il Cammino', () async {
    // Cintura: senza questa riga un corpus riscritto lascerebbe il Cammino
    // fermo per sempre, e nessuno saprebbe perche.
    SharedPreferences.setMockInitialValues(
        const {'cammino.daCongedare': 'un_gradino_che_non_esiste_piu'});
    final d = DiarioDelCammino(orologio: orologioDelleProve);
    await d.carica();
    expect(d.laStradaELibera, isTrue,
        reason: 'il Cammino resta murato da un id che il corpus non ha piu');
  });

  test('il corpus ha abbastanza gradini perche questa prova voglia dire qualcosa',
      () {
    cardinaleMinimo(Sentieri.tuttiITraguardi.length, 100,
        cosa: 'gradini del Cammino',
        perche: 'Se il corpus si svuotasse, queste prove girerebbero su zero '
            'gradini e sarebbero verdi per non aver fatto maturare niente.');
  });
}
