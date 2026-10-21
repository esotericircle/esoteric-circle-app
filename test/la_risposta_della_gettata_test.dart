// ignore_for_file: avoid_print
import 'dart:math';

import 'package:esoteric_circle/core/chat/la_marca_del_genere.dart';
import 'package:esoteric_circle/core/domande/domande_del_cerchio.dart';
import 'package:esoteric_circle/core/responsi/la_forma_del_responso.dart';
import 'package:esoteric_circle/core/rituals/il_corpus_del_presagio.g.dart';
import 'package:esoteric_circle/core/rituals/il_presagio_dal_corpus.dart';
import 'package:esoteric_circle/core/rituals/l_oggetto_della_domanda.dart';
import 'package:esoteric_circle/core/rituals/la_risposta_della_gettata.dart';
import 'package:esoteric_circle/core/rituals/le_risposte_dirette.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/rituals/runes.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LA RISPOSTA DIRETTA DELLA GETTATA, MISURATA. Ordine GA voce GA.06, la
/// cura delle Rune di Caligo, 21 ottobre 2026.**
///
/// Il fondatore, 19 ottobre 2026 alle 23:08: *"risposte dirette
/// immediatamente [...] L'utente deve avere una risposta o una guida, deve
/// sapere cosa fare o non fare [...] E ogni risposta deve essere coerente con
/// i simboli [...] e coerente con la domanda posta dall'utente."*
///
/// Quattro misure:
/// 1. LA LETTURA DELLE DOMANDE: ogni domanda ha il tipo, il tema e l'ambito
///    delicato che chi legge le darebbe; le domande sono quelle dei lettori
///    ciechi e altre, scritte in un altro modo, perche' le regole non siano
///    cucite sulla prova.
/// 2. OGNI FORMA STA FRA 40 E 50 PAROLE: per ognuna delle quaranta pietre
///    nel posto che decide, in ogni gettata, con le ombre negli altri posti,
///    per ogni tipo di domanda e con ogni lunghezza della RISPOSTA del corpus
///    (da 20 a 28 parole), il paragrafo della risposta e il riquadro hanno
///    una forma intera che sta nella misura: niente troncato (voce GA.07).
/// 3. LA RISERVA NON SI USA: sul corpus vero il paragrafo non torna mai alla
///    forma di prima (RISPOSTA piu' VERDETTO) e il riquadro di una domanda
///    non e' mai il GESTO.
/// 4. LA PRIMA FRASE RISPONDE, per tipo di domanda: un verdetto a chi chiede
///    se fare, un criterio a chi sceglie, un modo a chi chiede come, il
///    limite delle rune a chi chiede l'esito, una data, il cuore di un
///    altro; e il tema della domanda dentro la prima frase.
void main() {
  // -------------------------------------------------------------------------
  // 1. LA LETTURA DELLE DOMANDE
  // -------------------------------------------------------------------------

  /// (domanda, tipo, ambito delicato, tema, chiude, doppia)
  const attese = <(String, TipoDiDomanda, AmbitoDelicato?, String, bool, bool)>[
    // Le domande dei lettori ciechi.
    (
      'Lui tornerà da me dopo quello che è successo?',
      TipoDiDomanda.altrui,
      null,
      'l’amore',
      false,
      false
    ),
    (
      'Cosa prova davvero Marco per me?',
      TipoDiDomanda.altrui,
      null,
      'questo legame',
      false,
      false
    ),
    (
      'La mia relazione può durare nonostante la distanza?',
      TipoDiDomanda.previsione,
      null,
      'l’amore',
      false,
      false
    ),
    (
      'Devo dirle che sono innamorato di lei?',
      TipoDiDomanda.decisione,
      null,
      'l’amore',
      false,
      false
    ),
    (
      'Incontrerò qualcuno di importante quest\'anno?',
      TipoDiDomanda.previsione,
      null,
      'l’incontro che cerchi',
      false,
      false
    ),
    (
      'Posso fidarmi del mio compagno?',
      TipoDiDomanda.altrui,
      null,
      'l’amore',
      false,
      false
    ),
    (
      'Ha senso riprovarci con la mia ex?',
      TipoDiDomanda.decisione,
      null,
      'l’amore',
      false,
      false
    ),
    (
      'Come posso ritrovare l\'intesa con mio marito?',
      TipoDiDomanda.come,
      null,
      'l’amore',
      false,
      false
    ),
    (
      'Il colloquio di giovedì andrà bene?',
      TipoDiDomanda.previsione,
      null,
      'il lavoro',
      false,
      false
    ),
    (
      'Devo accettare l\'offerta della nuova azienda?',
      TipoDiDomanda.decisione,
      null,
      'il lavoro',
      false,
      false
    ),
    (
      'Riuscirò a ottenere la promozione che aspetto?',
      TipoDiDomanda.previsione,
      null,
      'il lavoro',
      false,
      false
    ),
    (
      'È il momento giusto per aprire la mia attività?',
      TipoDiDomanda.decisione,
      AmbitoDelicato.denaro,
      'questa decisione',
      false,
      false
    ),
    (
      'Come gestisco il conflitto con il mio capo?',
      TipoDiDomanda.come,
      null,
      'il lavoro',
      false,
      false
    ),
    (
      'Devo lasciare il lavoro per tornare a studiare?',
      TipoDiDomanda.decisione,
      AmbitoDelicato.denaro,
      'questa decisione',
      true,
      false
    ),
    (
      'Il progetto che ho presentato verrà approvato?',
      TipoDiDomanda.previsione,
      null,
      'il progetto',
      false,
      false
    ),
    (
      'Come posso fare pace con mia sorella?',
      TipoDiDomanda.come,
      null,
      'la tua famiglia',
      false,
      false
    ),
    (
      'Mio figlio sta attraversando un periodo difficile, come lo aiuto?',
      TipoDiDomanda.come,
      null,
      'la tua famiglia',
      false,
      false
    ),
    (
      'È giusto andare a vivere lontano dai miei genitori?',
      TipoDiDomanda.decisione,
      null,
      'il trasferimento',
      false,
      false
    ),
    (
      'Come affronto il pranzo di Natale con la famiglia di lui?',
      TipoDiDomanda.come,
      null,
      'la tua famiglia',
      false,
      false
    ),
    (
      'Devo trasferirmi a Milano o restare a Bari?',
      TipoDiDomanda.scelta,
      null,
      'il trasferimento',
      false,
      false
    ),
    (
      'Compro casa adesso o aspetto un anno?',
      TipoDiDomanda.scelta,
      AmbitoDelicato.denaro,
      'questa decisione',
      false,
      false
    ),
    (
      'Devo chiudere l\'amicizia con Giulia?',
      TipoDiDomanda.decisione,
      null,
      'l’amicizia',
      true,
      false
    ),
    (
      'Quale strada scelgo tra i due corsi di laurea?',
      TipoDiDomanda.scelta,
      null,
      'lo studio',
      false,
      false
    ),
    (
      'Arriverà presto la risposta che aspetto?',
      TipoDiDomanda.previsione,
      null,
      'la risposta che aspetti',
      false,
      false
    ),
    (
      'Quando finirà questo periodo di stallo?',
      TipoDiDomanda.quando,
      null,
      'questo periodo',
      false,
      false
    ),
    (
      'Il cambiamento che sento arrivare sarà positivo?',
      TipoDiDomanda.previsione,
      null,
      'il cambiamento',
      false,
      false
    ),
    (
      'Passerò l\'esame di stato a dicembre?',
      TipoDiDomanda.previsione,
      null,
      'lo studio',
      false,
      false
    ),
    (
      'Che cosa mi aspetta?',
      TipoDiDomanda.futuro,
      null,
      'questo momento',
      false,
      false
    ),
    (
      'Andrà tutto bene?',
      TipoDiDomanda.tuttoBene,
      null,
      'questo momento',
      false,
      false
    ),
    (
      'Dimmi qualcosa.',
      TipoDiDomanda.aperta,
      null,
      'questo momento',
      false,
      false
    ),
    (
      'Lui mi ama ancora e troverò lavoro entro Natale?',
      TipoDiDomanda.altrui,
      null,
      'l’amore',
      false,
      true
    ),
    (
      'Devo lasciare Roma, e se lo faccio la mia famiglia capirà?',
      TipoDiDomanda.decisione,
      null,
      'il trasferimento',
      true,
      true
    ),
    (
      'L\'operazione al ginocchio del mese prossimo andrà bene?',
      TipoDiDomanda.previsione,
      AmbitoDelicato.salute,
      'questo periodo',
      false,
      false
    ),
    (
      'Conviene investire i miei risparmi in borsa adesso?',
      TipoDiDomanda.decisione,
      AmbitoDelicato.denaro,
      'questa decisione',
      false,
      false
    ),
    (
      'Vincerò la causa contro il mio ex socio?',
      TipoDiDomanda.previsione,
      AmbitoDelicato.legge,
      'questa vicenda',
      false,
      false
    ),
    // Scritte in un altro modo.
    (
      'Dovrei cambiare lavoro quest’anno?',
      TipoDiDomanda.decisione,
      null,
      'il lavoro',
      false,
      false
    ),
    (
      'Posso fidarmi della mia socia?',
      TipoDiDomanda.altrui,
      null,
      'questo legame',
      false,
      false
    ),
    (
      'Lascio il mio ragazzo o ci riprovo?',
      TipoDiDomanda.scelta,
      null,
      'l’amore',
      false,
      false
    ),
    (
      'Quando troverò l’amore?',
      TipoDiDomanda.quando,
      null,
      'l’amore',
      false,
      false
    ),
    (
      'Supererò il concorso?',
      TipoDiDomanda.previsione,
      null,
      'lo studio',
      false,
      false
    ),
    (
      'Cosa pensa di me la mia collega?',
      TipoDiDomanda.altrui,
      null,
      'il lavoro',
      false,
      false
    ),
    (
      'Mi devo operare alla schiena?',
      TipoDiDomanda.aperta,
      AmbitoDelicato.salute,
      'questo periodo',
      false,
      false
    ),
    (
      'Devo fare causa al mio datore di lavoro?',
      TipoDiDomanda.decisione,
      AmbitoDelicato.legge,
      'questa vicenda',
      false,
      false
    ),
    (
      'Conviene chiedere un mutuo adesso?',
      TipoDiDomanda.decisione,
      AmbitoDelicato.denaro,
      'questa decisione',
      false,
      false
    ),
    (
      'Il mio cane guarirà?',
      TipoDiDomanda.previsione,
      AmbitoDelicato.salute,
      'questo periodo',
      false,
      false
    ),
    (
      'Che ne sarà di me?',
      TipoDiDomanda.futuro,
      null,
      'questo momento',
      false,
      false
    ),
    (
      'Come faccio a dimenticarlo?',
      TipoDiDomanda.come,
      null,
      'ciò che hai chiesto',
      false,
      false
    ),
    (
      'Mi sposerò entro due anni?',
      TipoDiDomanda.previsione,
      null,
      'l’amore',
      false,
      false
    ),
    (
      'Devo lasciarlo, e lui soffrirà?',
      TipoDiDomanda.decisione,
      null,
      'l’amore',
      true,
      true
    ),
    (
      'Faccio bene a restare dove sono, a causa dei figli?',
      TipoDiDomanda.decisione,
      null,
      'la tua famiglia',
      false,
      false
    ),
    (
      'Dovrei vendere l’appartamento di mia madre?',
      TipoDiDomanda.decisione,
      AmbitoDelicato.denaro,
      'questa decisione',
      false,
      false
    ),
    ('', TipoDiDomanda.giornata, null, 'la tua giornata', false, false),
  ];

  test(
      '1. LA LETTURA DELLE DOMANDE: tipo, tema, ambito delicato, chiusura '
      'e domanda doppia', () {
    final sbagliate = <String>[];
    for (final (d, tipo, delicato, tema, chiude, doppia) in attese) {
      final q = LaDomandaLetta.di(d);
      final letto = '${q.tipo.name}, ${q.delicato?.name}, ${q.tema}, '
          'chiude ${q.chiude}, doppia ${q.doppia}';
      final atteso = '${tipo.name}, ${delicato?.name}, $tema, chiude $chiude, '
          'doppia $doppia';
      if (letto != atteso) sbagliate.add('«$d»: letto $letto, atteso $atteso');
    }
    print('ORDINE GA VOCE GA.06, RUNE: domande lette ${attese.length}, '
        'sbagliate ${sbagliate.length}');
    cardinaleMinimo(attese.length, 50,
        cosa: 'domande lette',
        perche: 'le trentatre dei lettori ciechi e almeno diciassette scritte '
            'in un altro modo');
    expect(sbagliate, isEmpty, reason: sbagliate.join('\n'));
  });

  test('1b. LE DOMANDE DEL CERCHIO hanno tutte un tipo scritto', () {
    final cerchio = [
      ...DomandeDelCerchio.generichePerLaGettata,
      ...DomandeDelCerchio.personaliPerLaGettata,
    ];
    cardinaleMinimo(cerchio.length, 12, cosa: 'domande del Cerchio');
    for (final c in cerchio) {
      final q = LaDomandaLetta.di(c.testo);
      // "In amore, dove sto andando?" ha un tipo dalla riapertura (la
      // previsione: cerca una direzione, e il suo cosa fare la segue).
      expect(
          {TipoDiDomanda.aperta, TipoDiDomanda.come, TipoDiDomanda.previsione}
              .contains(q.tipo),
          isTrue,
          reason: c.testo);
      expect(q.delicato, isNull, reason: c.testo);
    }
  });

  test('1c. LE QUARANTA PIETRE hanno la loro lettura', () {
    var n = 0;
    for (final r in kElderFuthark) {
      expect(
          LaPietraLetta.tutte.containsKey(LaPietraLetta.chiave(r.name, false)),
          isTrue,
          reason: r.name);
      n++;
      if (!kRuneSimmetriche.contains(r.name)) {
        expect(
            LaPietraLetta.tutte.containsKey(LaPietraLetta.chiave(r.name, true)),
            isTrue,
            reason: '${r.name} in ombra');
        n++;
      }
    }
    expect(n, 40);
    expect(LaPietraLetta.tutte.length, 40);
  });

  // -------------------------------------------------------------------------
  // 2. OGNI FORMA STA FRA 40 E 50 PAROLE
  // -------------------------------------------------------------------------

  /// Le gettate costruite a mano: [chiave] nel posto che decide, le altre
  /// pietre in ordine, con l'ombra dove dice [ombre] (un bit per posto).
  EsitoGettata costruisci(GettataRune g, String chiave, int ombre) {
    final decide = IlPresagioDalCorpus.indiceDellaPietraCheDecide(g.id);
    final nome = chiave.split('/').first;
    final inOmbra = chiave.endsWith('/ombra');
    final altre = [
      for (final r in kElderFuthark)
        if (r.name != nome && !kRuneSimmetriche.contains(r.name)) r,
    ];
    final n = g.libera ? 7 : g.posizioni.length;
    final pietre = <RunaGettata>[];
    var k = 0;
    for (var i = 0; i < n; i++) {
      final pos = g.posizioni[min(i, g.posizioni.length - 1)];
      if (i == decide) {
        pietre.add(RunaGettata(
            rune: kElderFuthark.firstWhere((r) => r.name == nome),
            verso: inOmbra ? RuneVerso.merkstave : RuneVerso.dritto,
            posizione: pos));
      } else {
        pietre.add(RunaGettata(
            rune: altre[(k++ * 5) % altre.length],
            verso:
                (ombre >> i) & 1 == 1 ? RuneVerso.merkstave : RuneVerso.dritto,
            posizione: pos));
      }
    }
    return EsitoGettata(gettata: g, rune: pietre);
  }

  /// Le ombre negli altri posti: nessuna, una per posto, poi due, tre e
  /// cosi' via fino a tutte (il bit del posto che decide non conta: il suo
  /// verso lo dice la chiave).
  List<int> leOmbre(int n, int decide) {
    if (n == 1) return [0];
    final altri = [
      for (var i = 0; i < n; i++)
        if (i != decide) i
    ];
    final fuori = <int>{0};
    for (final i in altri) {
      fuori.add(1 << i);
    }
    for (var c = 2; c <= altri.length; c++) {
      var m = 0;
      for (final i in altri.take(c)) {
        m |= 1 << i;
      }
      fuori.add(m);
    }
    return fuori.toList();
  }

  final domandeDiProva = <String>[
    for (final a in attese) a.$1,
    for (final c in DomandeDelCerchio.generichePerLaGettata) c.testo,
    for (final c in DomandeDelCerchio.personaliPerLaGettata) c.testo,
  ];

  test(
      '2. OGNI FORMA STA FRA 40 E 50 PAROLE: quaranta pietre nel posto che '
      'decide, ogni gettata, le ombre, ogni domanda, la RISPOSTA da 20 a 28 '
      'parole', () {
    final mancanti = <String>[];
    var paragrafi = 0;
    var riquadri = 0;
    for (final g in gettate) {
      final n = g.libera ? 7 : g.posizioni.length;
      final decide = IlPresagioDalCorpus.indiceDellaPietraCheDecide(g.id);
      for (final chiave in LaPietraLetta.tutte.keys) {
        for (final ombre in leOmbre(n, decide)) {
          final esito = costruisci(g, chiave, ombre);
          for (final d in domandeDiProva) {
            final q = LaDomandaLetta.di(d);
            final dove = '${g.id}, $chiave, ombre $ombre, «$d»';
            if (q.delicato != null) {
              final p = LaRispostaDellaGettata.paragrafoDelicato(
                  domanda: q, esito: esito);
              paragrafi++;
              if (p == null) mancanti.add('$dove: paragrafo delicato');
            } else {
              for (var b = 20; b <= 28; b++) {
                final risposta = List.filled(b, 'parola').join(' ');
                final p = LaRispostaDellaGettata.paragrafoDellaRisposta(
                    domanda: q, esito: esito, risposta: risposta);
                paragrafi++;
                if (p == null) {
                  mancanti.add('$dove, RISPOSTA di $b parole: nessuna forma');
                } else if (!LaFormaDelResponso.aMisura(p)) {
                  mancanti.add('$dove: ${LaFormaDelResponso.parole(p)} parole');
                }
              }
            }
            if (q.tipo == TipoDiDomanda.giornata) continue;
            for (var v = 0; v < 7; v++) {
              final r = LaRispostaDellaGettata.riquadro(
                  domanda: q, esito: esito, variante: v);
              riquadri++;
              if (r == null) {
                mancanti.add('$dove, variante $v: riquadro');
              } else if (r.contains('{') ||
                  r.contains('  ') ||
                  RegExp(r',\s+(e|ed)\s').hasMatch(r)) {
                mancanti.add('$dove: riquadro malformato «$r»');
              }
            }
          }
        }
      }
    }
    print('ORDINE GA VOCE GA.06, RUNE: paragrafi misurati $paragrafi, '
        'riquadri $riquadri, senza forma ${mancanti.length}');
    cardinaleMinimo(paragrafi, 100000,
        cosa: 'paragrafi della risposta misurati',
        perche: 'quattro gettate, quaranta pietre, le ombre, sessanta domande, '
            'nove lunghezze della RISPOSTA');
    expect(mancanti, isEmpty, reason: mancanti.take(30).join('\n'));
  }, timeout: const Timeout(Duration(minutes: 10)));

  // -------------------------------------------------------------------------
  // 3. LA RISERVA NON SI USA, SUL CORPUS VERO
  // -------------------------------------------------------------------------

  test(
      '3. LA RISERVA NON SI USA: mai il VERDETTO nel paragrafo, mai il GESTO '
      'nel riquadro di una domanda', () {
    final verdetti = {
      for (final g in corpusDelPresagio.voci['verdetto']!.values)
        for (final v in g)
          if (v.trim().isNotEmpty) LaMarcaDelGenere.risolvi(v.trim()),
    };
    final gesti = {
      for (final g in corpusDelPresagio.voci['gesto']!.values)
        for (final v in g)
          if (v.trim().isNotEmpty)
            LaMarcaDelGenere.risolvi(
                    v.trim().replaceAll('{cosa}', 'la tua giornata'))
                .split(' ')
                .take(8)
                .join(' '),
    };
    final colpe = <String>[];
    var composti = 0;
    for (final g in gettate) {
      for (var seme = 0; seme < 40; seme++) {
        final esito = RuneCast.getta(g, random: Random(seme));
        for (final d in domandeDiProva) {
          final p = IlPresagioDalCorpus.componi(
            corpus: corpusDelPresagio,
            esito: esito,
            domanda: d,
            persona: 'p-$seme',
            oggi: DateTime(2026, 10, 21),
            memoria: LaMemoriaDelPresagio(),
            lunga: seme.isOdd,
          );
          composti++;
          final r = p.principale;
          if (verdetti.any(r.risposta.contains)) {
            colpe.add('${g.id}, $seme, «$d»: il VERDETTO nel paragrafo');
          }
          final inizio = r.cosaFare.split(' ').take(8).join(' ');
          // Dal secondo giro della voce GA.06 il GESTO resta il riquadro
          // di chi getta senza domanda e delle domande aperte del Cerchio
          // ("Cosa devo sapere sul mio momento?"), che non hanno un tipo
          // del corpus diretto; ogni domanda con un tipo ha il riquadro
          // scritto per lei (`azione.md`), e una domanda di salute, legge
          // o denaro il suo.
          final q = LaDomandaLetta.di(d);
          final haIlSuo = LeRisposteDirette.tipoDelCorpus(q, d) != null ||
              q.delicato != null ||
              q.doppia;
          if (haIlSuo && gesti.contains(inizio)) {
            colpe.add('${g.id}, $seme, «$d»: il GESTO nel riquadro');
          }
          if (d.trim().isEmpty && !gesti.contains(inizio)) {
            colpe.add('${g.id}, $seme: senza domanda il riquadro non e\' il '
                'GESTO');
          }
        }
      }
    }
    print('ORDINE GA VOCE GA.06, RUNE: presagi composti $composti, riserve '
        'usate ${colpe.length}');
    cardinaleMinimo(composti, 4 * 40 * 60, cosa: 'presagi composti');
    expect(colpe, isEmpty, reason: colpe.take(20).join('\n'));
  }, timeout: const Timeout(Duration(minutes: 10)));

  // -------------------------------------------------------------------------
  // 4. LA PRIMA FRASE RISPONDE
  // -------------------------------------------------------------------------

  /// La prima frase: fino al primo punto seguito da uno spazio e da una
  /// maiuscola.
  String primaFrase(String t) {
    final m = RegExp(r'\.\s+(?=[A-ZÀ-Ý])').firstMatch(t);
    return m == null ? t : t.substring(0, m.start + 1);
  }

  test(
      '4. LA PRIMA FRASE RISPONDE: il verdetto, il criterio, il modo o il '
      'limite delle rune, e il tema della domanda', () {
    final colpe = <String>[];
    var lette = 0;
    for (final g in gettate) {
      for (var seme = 0; seme < 30; seme++) {
        final esito = RuneCast.getta(g, random: Random(500 + seme));
        final decide = IlPresagioDalCorpus.pietraCheDecide(esito);
        final modo =
            LaRispostaDellaGettata.maiuscola(LaPietraLetta.di(decide).modo);
        for (final d in domandeDiProva) {
          final q = LaDomandaLetta.di(d);
          final p = IlPresagioDalCorpus.componi(
            corpus: corpusDelPresagio,
            esito: esito,
            domanda: d,
            persona: 'q-$seme',
            oggi: DateTime(2026, 10, 21),
            memoria: LaMemoriaDelPresagio(),
          );
          lette++;
          final prima = primaFrase(p.principale.risposta);
          final dove = '${g.id}, $seme, «$d»: «$prima»';
          // **LE RISPOSTE DIRETTE**, secondo giro della voce GA.06: il
          // paragrafo di una domanda con un tipo del corpus e' una voce
          // intera di `diretta.md`, e la sua prima frase si misura con le
          // regole di `tool/controlla_le_risposte_dirette_delle_rune.py`:
          // nelle decisioni un verdetto e l'azione di chi chiede; negli altri
          // tipi la cosa della domanda e mai un si' o un no; nella scelta il
          // criterio; in quando, previsione, altrui e vaghe il limite delle
          // rune con una negazione; nelle vaghe l'invito a precisare.
          final tipoDiretto = LeRisposteDirette.tipoDelCorpus(q, d);
          if (tipoDiretto != null) {
            final r = p.principale.risposta;
            final colpeDirette = <String>[
              if (tipoDiretto == 'decisione' &&
                  !RegExp(r'^(Sì|No(?![a-zà-ÿ])|Non(?![a-zà-ÿ])|Ancora no|'
                          r'Aspetta|Rimanda|Fermati|Meglio|Prima(?![a-zà-ÿ]))')
                      .hasMatch(prima))
                'non comincia con un verdetto',
              if (tipoDiretto == 'decisione' &&
                  !LOggettoDellaDomanda.azioni(q.azione).any(prima.contains))
                'non nomina l\'azione di chi chiede',
              if (tipoDiretto != 'decisione' &&
                  !LeRisposteDirette.valori(q, d, tipoDiretto)
                      .any(prima.contains))
                'non nomina la cosa della domanda',
              if (tipoDiretto != 'decisione' &&
                  RegExp(r'^(Sì|No)(?![a-zà-ÿ])').hasMatch(prima))
                'un sì o un no a una domanda che non li chiede',
              if (tipoDiretto == 'scelta' &&
                  !RegExp(r'scegl|strad|preferisc', caseSensitive: false)
                      .hasMatch(prima))
                'non dà il criterio di scelta',
              if (const {'quando', 'previsione', 'altrui', 'vaga'}
                      .contains(tipoDiretto) &&
                  !(LaDomandaLetta.parola(r'rune|runa|pietr\w*|gettata|segni')
                          .hasMatch(prima.toLowerCase()) &&
                      LaDomandaLetta.parola(r'non|nessun\w*|né')
                          .hasMatch(prima.toLowerCase())))
                'non dice il limite delle rune',
              if (tipoDiretto == 'vaga' &&
                  !RegExp(
                          r'precis|riformul|dimmi|raccontami|una domanda (più|'
                          r'meglio)|domanda (concreta|mirata)|nomina|restringi|'
                          r'scegli una (cosa|domanda)',
                          caseSensitive: false)
                      .hasMatch(r))
                'non invita a precisare la domanda',
            ];
            for (final c in colpeDirette) {
              colpe.add('$dove: $c');
            }
            if (q.doppia &&
                !RegExp(r'[Ll]a seconda( domanda)?[ ,].*un’altra gettata')
                    .hasMatch(r)) {
              colpe.add('$dove: la domanda doppia non e\' separata');
            }
            continue;
          }
          final atteso = q.delicato != null
              ? switch (q.delicato!) {
                  AmbitoDelicato.salute => RegExp(r'medici.*non le rune'),
                  AmbitoDelicato.legge =>
                    RegExp(r'^Le rune non predicono l’esito di una '
                        r'(causa|vicenda legale)'),
                  AmbitoDelicato.denaro => q.sceltaDiVita
                      ? RegExp(r'^(Le rune non valutano i conti|Sui conti di '
                          r'questa scelta|I numeri di questa scelta)')
                      : RegExp(r'^Le rune non danno consigli'),
                }
              : switch (q.tipo) {
                  TipoDiDomanda.decisione => RegExp(r'^(Sì|Non |No)'),
                  TipoDiDomanda.scelta => RegExp(r'^(Fra |Scegli )'),
                  TipoDiDomanda.come => RegExp('^${RegExp.escape(modo)}:'),
                  TipoDiDomanda.quando => RegExp(r'^Le rune non danno date'),
                  TipoDiDomanda.previsione =>
                    RegExp(r'^Le rune non predicono l’esito'),
                  TipoDiDomanda.altrui =>
                    RegExp(r'^Le rune non leggono il cuore'),
                  TipoDiDomanda.tuttoBene =>
                    RegExp(r'^Le rune non promettono che vada tutto bene'),
                  TipoDiDomanda.futuro =>
                    RegExp(r'^Le rune non mostrano un futuro già scritto'),
                  TipoDiDomanda.giornata => RegExp(r'^La tua giornata'),
                  TipoDiDomanda.aperta => RegExp(r'^Per .+ la gettata indica'),
                };
          if (!atteso.hasMatch(prima)) colpe.add('$dove: non risponde');
          if (q.delicato == null &&
              q.tipo != TipoDiDomanda.giornata &&
              !prima.contains(q.tema) &&
              !(q.tipo == TipoDiDomanda.scelta && prima.startsWith('Fra ')) &&
              !(q.tipo == TipoDiDomanda.decisione && q.azione != null)) {
            colpe.add('$dove: manca il tema «${q.tema}»');
          }
          if (q.doppia &&
              !RegExp(r'[Ll]a seconda( domanda)?[ ,].*un’altra gettata')
                  .hasMatch(p.principale.risposta)) {
            colpe.add('$dove: la domanda doppia non e\' separata');
          }
        }
      }
    }
    print('ORDINE GA VOCE GA.06, RUNE: prime frasi lette $lette, che non '
        'rispondono ${colpe.length}');
    cardinaleMinimo(lette, 4 * 30 * 60, cosa: 'prime frasi lette');
    expect(colpe, isEmpty, reason: colpe.take(20).join('\n'));
  }, timeout: const Timeout(Duration(minutes: 10)));
}
