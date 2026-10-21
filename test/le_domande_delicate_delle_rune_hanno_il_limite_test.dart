// ignore_for_file: avoid_print
import 'dart:math';

import 'package:esoteric_circle/core/rituals/il_corpus_del_presagio.g.dart';
import 'package:esoteric_circle/core/rituals/il_presagio_dal_corpus.dart';
import 'package:esoteric_circle/core/rituals/la_risposta_della_gettata.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LE DOMANDE DELICATE DELLE RUNE HANNO IL LIMITE, PER PRIMO.** Ordine GA
/// voce GA.06, la cura delle Rune di Caligo, 21 ottobre 2026.
///
/// La regola (ordine S voce 17, ripresa dalla voce GA.06): *"nessun consiglio
/// su salute, denaro o questioni legali: dove la domanda tocca questi temi il
/// responso lo dice chiaramente e rimanda a chi e' competente (medico,
/// legale, consulente), senza promettere l'esito"*. I lettori ciechi, sul
/// commit 1804c7d7: l'investimento in borsa e la causa legale ricevevano la
/// stessa frase che spinge ad agire (*"hai il vento favorevole, quindi
/// comincia oggi stesso"*), l'operazione al ginocchio un testo minaccioso
/// (*"porta via ciò che era già incrinato"*) e un esito promesso (*"Wunjo
/// dritta risponde di sì"*).
///
/// La guardia scrive per ogni ambito domande in modi diversi, le getta in
/// tutte le gettate, e pretende: che la domanda sia letta come delicata; che
/// la PRIMA frase dica il limite e nomini chi e' competente; che nessun testo
/// del responso principale spinga ad agire o prometta l'esito; che il
/// riquadro rimandi a chi e' competente; che le schede non leggano l'esito
/// (il tema e' "il tuo stato d’animo").
void main() {
  const domande = <AmbitoDelicato, List<String>>{
    AmbitoDelicato.salute: [
      'L\'operazione al ginocchio del mese prossimo andrà bene?',
      'Mi devo operare alla schiena?',
      'Il mio cane guarirà?',
      'La terapia che sto facendo funzionerà?',
      'Gli esami del sangue di martedì andranno bene?',
      'Mia madre uscirà presto dall\'ospedale?',
      'Devo cambiare medico?',
      'Questa malattia passerà?',
      'L\'intervento al cuore di mio padre riuscirà?',
      'Rimarrò incinta quest\'anno?',
    ],
    AmbitoDelicato.legge: [
      'Vincerò la causa contro il mio ex socio?',
      'Devo fare causa al mio datore di lavoro?',
      'Il giudice mi darà ragione?',
      'Conviene denunciare il vicino?',
      'Il divorzio andrà come spero?',
      'Devo cambiare avvocato?',
      'Il ricorso verrà accolto?',
      'Otterrò l\'affidamento dei bambini?',
      'Mi conviene firmare la separazione adesso?',
      'Avrò il risarcimento per l\'incidente?',
    ],
    AmbitoDelicato.denaro: [
      'Conviene investire i miei risparmi in borsa adesso?',
      'Compro casa adesso o aspetto un anno?',
      'Devo chiedere un mutuo?',
      'Le mie azioni saliranno?',
      'Devo prestare dei soldi a mio fratello?',
      'Riuscirò a pagare i debiti entro l\'anno?',
      'Conviene comprare bitcoin?',
      'Lo stipendio basterà per trasferirmi?',
      'Devo accettare l\'eredità di mio zio?',
      'Mi conviene acquistare un appartamento in centro?',
    ],
  };

  final limite = {
    AmbitoDelicato.salute: RegExp(r'medici'),
    AmbitoDelicato.legge: RegExp(r'causa|avvocato'),
    AmbitoDelicato.denaro: RegExp(r'consulente'),
  };
  final competente = {
    AmbitoDelicato.salute: RegExp(r'chi ti segue|medic'),
    AmbitoDelicato.legge: RegExp(r'avvocato'),
    AmbitoDelicato.denaro: RegExp(r'consulente finanziario'),
  };
  // Cio' che non si dice mai su salute, legge e denaro: una spinta ad agire,
  // un esito promesso, una minaccia. Scritto sulle frasi trovate dai lettori
  // ciechi e sulle loro sorelle.
  final vietato = RegExp(
      r'comincia oggi stesso|agisci subito|hai il vento favorevole|'
      r'nessun ostacolo|risponde di sì|un sì pieno|vincerai|guarirai|'
      r'andrà bene|andrà tutto bene|porta via ciò che|si incrina|'
      r'non chiedere pareri|investi(?![a-zà-ÿ])|compra subito|firma subito',
      caseSensitive: false);

  test(
      'salute, legge e denaro: il limite nella prima frase, chi e\' '
      'competente nel riquadro, nessuna spinta e nessun esito promesso', () {
    final colpe = <String>[];
    var composti = 0;
    var lette = 0;
    for (final MapEntry(key: ambito, value: elenco) in domande.entries) {
      for (final d in elenco) {
        lette++;
        final q = LaDomandaLetta.di(d);
        if (q.delicato != ambito) {
          colpe.add('«$d»: letta come ${q.delicato?.name}, e\' ${ambito.name}');
          continue;
        }
        if (IlPresagioDalCorpus.cosaDellaDomanda(d) != 'il tuo stato d’animo') {
          colpe.add('«$d»: le schede leggerebbero '
              '«${IlPresagioDalCorpus.cosaDellaDomanda(d)}»');
        }
        for (final g in gettate) {
          for (var seme = 0; seme < 12; seme++) {
            final esito = RuneCast.getta(g, random: Random(900 + seme));
            final p = IlPresagioDalCorpus.componi(
              corpus: corpusDelPresagio,
              esito: esito,
              domanda: d,
              persona: 'delicata-$seme',
              oggi: DateTime(2026, 10, 21),
              memoria: LaMemoriaDelPresagio(),
              lunga: seme.isOdd,
            );
            composti++;
            final r = p.principale;
            final prima = r.risposta.split(RegExp(r'(?<=\.)\s')).first;
            final dove = '${g.id}, $seme, «$d»';
            if (!prima.contains('rune') || !limite[ambito]!.hasMatch(prima)) {
              colpe.add('$dove: la prima frase non dice il limite: «$prima»');
            }
            if (!competente[ambito]!.hasMatch(r.cosaFare)) {
              colpe.add('$dove: il riquadro non rimanda a chi e\' competente: '
                  '«${r.cosaFare}»');
            }
            for (final t in [r.risposta, r.cosaFare]) {
              final m = vietato.firstMatch(t);
              if (m != null) colpe.add('$dove: «${m[0]}» in «$t»');
            }
            if (RegExp(r'^(Sì|No)\b').hasMatch(r.risposta)) {
              colpe.add('$dove: comincia con un verdetto: «$prima»');
            }
            // Le schede: nessun verdetto a una domanda che non conoscono,
            // e sulla salute nessuno sforzo fisico (i lettori ciechi:
            // "Cammina all'aperto subito dopo un momento difficile" sotto
            // un'operazione al ginocchio).
            for (final s in p.schede) {
              if (!s.titolo.contains(', per te: ')) {
                colpe.add('$dove: il titolo della scheda legge l\'esito: '
                    '«${s.titolo}»');
              }
              if (RegExp(r'^(Sì|No)[,:]|risponde di sì|risposta è sì')
                  .hasMatch(s.risposta)) {
                colpe.add('$dove: una scheda risponde sì: «${s.risposta}»');
              }
              if (ambito == AmbitoDelicato.salute &&
                  IlPresagioDalCorpus.sforzoFisico
                      .hasMatch('${s.risposta} ${s.cosaFare}')) {
                colpe.add('$dove: una scheda chiede uno sforzo fisico: '
                    '«${s.cosaFare}»');
              }
            }
          }
        }
      }
    }
    print('ORDINE GA VOCE GA.06, RUNE: domande delicate $lette, presagi '
        'composti $composti, senza limite o con una spinta ${colpe.length}');
    cardinaleMinimo(lette, 30,
        cosa: 'domande delicate', perche: 'dieci per ambito, scritte diverse');
    cardinaleMinimo(composti, 30 * 4 * 12, cosa: 'presagi delicati composti');
    expect(colpe, isEmpty, reason: colpe.take(20).join('\n'));
  });
}
