import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';
import 'istante_dichiarato.dart';

/// **LA SCENA NON ARRIVA FINCHÉ LA PRECEDENTE NON È STATA CONGEDATA.**
/// Ordine CP voce 01 del 3 settembre 2026, **spostata dalla maturazione alla
/// scena dall'ordine CQ voce 2.13 dello stesso giorno.**
///
/// **Perché si è spostata, e il numero lo dice.** Il freno stava sulla
/// maturazione, e la misura della voce CQ 2.12 ha detto quanto costava: su
/// quattrocento giorni di uso onesto con dodici arti al giorno, **centododici
/// traguardi soddisfatti e TREDICI accesi**, con novantanove gradini già
/// guadagnati che non si accendevano mai. Non era un ritardo, era un muro.
///
/// Parole del fondatore: *il tetto delle feste non deve mai toccare
/// l'accensione del Sigillo né l'accredito degli Eos, solo la scena della
/// festa.* Quindi adesso maturano tutti, si accendono tutti e i loro Eos
/// arrivano tutti; **ciò che resta uno alla volta è la scena**, e questa
/// guardia la misura lì.
///
/// Decisione del fondatore, parole sue: *"il gradino non matura finche' il
/// precedente non e' stato congedato."* Nasce da otto feste viste in due
/// funzionalità la notte fra il 2 e il 3 settembre 2026.
///
/// **Un posto solo per la scena, e un tetto di tre al giorno.** La prima
/// regola del fondatore, del 17 agosto 2026, dice *"non deve esserci la
/// possibilita' di raggiungere piu' di un traguardo alla volta"*: letta sulla
/// scena, vuol dire che non se ne vede più di una per volta, e che ogni
/// sentiero ne mostra al massimo una al giorno. Il conto del giorno peggiore
/// dell'anno resta quello che il fondatore ha approvato con l'ordine CP,
/// **tre**, ed è misurato in
/// `aprire_e_chiudere_non_e_un_cammino_test.dart`.
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

  test('a strada libera UNA SOLA scena, e il posto si occupa', () async {
    final d = await diarioPulito();
    expect(d.laStradaELibera, isTrue,
        reason: 'un Cammino appena nato ha il posto gia occupato');

    final primi = await d.quelliCheSiAccendono(statoGeneroso());
    // **MATURANO TUTTI. Ordine CQ voce 2.13**: il tetto non tocca
    // l'accensione. Cio' che resta uno solo e' la scena.
    final conLaScena = primi.where(d.meritaLaScena).toList();
    // ignore: avoid_print
    print('ORDINE CQ VOCE 2.13: con lo stato generoso maturano '
        '${primi.length} gradini, e di scene ne meritano ${conLaScena.length}');
    expect(primi.length, greaterThan(1),
        reason: 'con uno stato che soddisfa quasi tutto il corpus ne maturano '
            '${primi.length}: il tetto e tornato sulla maturazione, ed e il '
            'muro che la voce CQ 2.12 ha misurato');
    // **TRE CANDIDATE, UNA SOLA A SCHERMO.** Il predicato dice quali gradini
    // hanno diritto alla scena, ed e' uno per sentiero: la regia ne apre UNA
    // e le altre restano senza scena, come dichiara `dopoUnGesto`. Tre e non
    // di piu' e' il tetto del giorno peggiore che il fondatore ha approvato
    // con l'ordine CP.
    expect(conLaScena.length, lessThanOrEqualTo(3),
        reason: 'a strada libera i gradini con diritto alla scena sono '
            '${conLaScena.length}: il tetto e tre, uno per Maestro');
    expect(
        conLaScena.map((t) => Sentiero.values
            .firstWhere((s) => Sentieri.di(s).any((x) => x.id == t.id))).toSet()
            .length,
        conLaScena.length,
        reason: 'due gradini dello stesso sentiero hanno diritto alla scena '
            'nello stesso istante: la scala di quel sentiero non tiene');
    await d.accendi(conLaScena.first.id);
    expect(d.inAttesaDiCongedo, conLaScena.first.id,
        reason: 'il gradino acceso non ha occupato il posto del congedo');
    expect(d.laStradaELibera, isFalse);
  });

  test('col posto occupato NON matura piu niente, per quanti gesti si facciano',
      () async {
    final d = await diarioPulito();
    final primi = await d.quelliCheSiAccendono(statoGeneroso());
    await d.accendi(primi.first.id);

    // **OTTO GIRI, che sono le otto feste viste dal fondatore.** Ogni giro
    // rappresenta un gesto in piu'. **Si contano le SCENE**, ordine CQ voce
    // 2.13: le accensioni non si frenano piu', e frenarle era il muro che la
    // voce 2.12 ha misurato.
    var scene = 0;
    for (var i = 0; i < 8; i++) {
      scene += (await d.quelliCheSiAccendono(statoGeneroso()))
          .where(d.meritaLaScena)
          .length;
    }
    // ignore: avoid_print
    print('ORDINE CQ VOCE 2.13: col posto occupato, otto gesti portano '
        '$scene scene');
    expect(scene, 0,
        reason: 'col gradino precedente ancora da congedare si sono viste '
            'altre $scene feste, ed e esattamente cio che il fondatore ha '
            'visto sul telefono');
  });

  test('congedato il precedente, il Cammino riprende', () async {
    final d = await diarioPulito();
    final primi = await d.quelliCheSiAccendono(statoGeneroso());
    final primaScena = primi.firstWhere(d.meritaLaScena);
    await d.accendi(primaScena.id);
    // La scena e' stata mostrata: e' cosi' che il tetto del giorno la conta.
    d.laScenaEStataMostrata(primaScena);
    await d.congeda(primaScena.id);
    expect(d.laStradaELibera, isTrue,
        reason: 'il congedo non ha liberato il posto: il Cammino resterebbe '
            'fermo per sempre');
    final dopo = await d.quelliCheSiAccendono(statoGeneroso());
    final scenaDopo = dopo.where(d.meritaLaScena).toList();
    // ignore: avoid_print
    print('ORDINE CQ VOCE 2.13: congedata la prima scena, i gradini maturi '
        'sono ${dopo.length} e le scene ${scenaDopo.length}');
    expect(dopo, isNotEmpty,
        reason: 'congedato il precedente non matura piu niente: il freno e '
            'diventato un muro');
    // **E LA SCENA VA A UN ALTRO SENTIERO**, perche' quello di prima ha gia'
    // avuto la sua per oggi: e' il tetto di tre al giorno, uno per Maestro.
    expect(scenaDopo.length, 2,
        reason: 'dopo il congedo i gradini con diritto alla scena sono '
            '${scenaDopo.length} invece di due: il sentiero che ha gia avuto '
            'la sua scena oggi deve restarne fuori');
    expect(scenaDopo.map((t) => t.id), isNot(contains(primaScena.id)));
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
