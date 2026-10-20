import 'dart:io';
import 'dart:math';

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/core/rituals/rito_alba.dart';
import 'package:esoteric_circle/core/rituals/arcano_dell_alba/letture_dell_alba_dati.dart';
import 'package:esoteric_circle/core/rituals/il_corpus_del_presagio.g.dart';
import 'package:esoteric_circle/core/rituals/il_presagio_dal_corpus.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/rituals/runes.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/tarot/le_carte_nella_posizione.dart';
import 'package:esoteric_circle/core/tarot/le_carte_nella_posizione_dati.dart';
import 'package:esoteric_circle/core/tarot/tarot_reading.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tetti_della_stesa.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/core/tarot/voce_della_stesa.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// LE LUNGHEZZE SI MISURANO PRIMA DI DECIDERLE. Ordine S voce 18.
///
/// **Perche' questa voce viene prima delle altre della sua sezione.** L'ordine
/// chiede di non accorciare NIENTE prima di avere una tabella con la lunghezza
/// mediana e massima di ogni tipo di responso di ogni arte: i tetti nuovi si
/// scrivono da quella tabella, non a occhio. Senza la misura, "e' troppo lungo"
/// e' un'opinione.
///
/// **SI MISURANO I RESPONSI COMPOSTI, non le stringhe del sorgente.** Un corpus
/// e' fatto di pezzi che si uniscono a runtime: contare i caratteri delle
/// costanti direbbe quanto e' lungo un mattone, non quanto e' lungo il muro. Qui
/// ogni arte viene fatta comporre davvero, su una battuta dichiarata, e si conta
/// il risultato.
///
/// **IL DOCUMENTO SI RIGENERA, non si scrive a mano:** con
/// `--dart-define=AGGIORNA_LUNGHEZZE=1` questa prova riscrive
/// `docs/responsi/lunghezze.md`; senza, lo CONFRONTA e cade se il documento e i
/// corpora si sono allontanati. Un documento che nessuno rigenera mostra uno
/// stato vecchio, ed e' peggio di nessun documento.
void main() {
  const aggiorna =
      String.fromEnvironment('AGGIORNA_LUNGHEZZE', defaultValue: '') == '1';
  final documento = File('docs/responsi/lunghezze.md');

  /// Una misura: quanti testi, la mediana e il massimo in caratteri.
  ({int quanti, int mediana, int massimo, String piuLungo}) misura(
      List<String> testi) {
    final puliti = testi.where((t) => t.trim().isNotEmpty).toList();
    final lunghezze = puliti.map((t) => t.length).toList()..sort();
    if (lunghezze.isEmpty) {
      return (quanti: 0, mediana: 0, massimo: 0, piuLungo: '');
    }
    final mediana = lunghezze[lunghezze.length ~/ 2];
    final massimo = lunghezze.last;
    final piuLungo = puliti.reduce((a, b) => b.length > a.length ? b : a);
    return (
      quanti: puliti.length,
      mediana: mediana,
      massimo: massimo,
      piuLungo:
          piuLungo.length <= 90 ? piuLungo : '${piuLungo.substring(0, 90)}...',
    );
  }

  /// LA BATTUTA DICHIARATA. Non e' un campione a caso: e' un giro completo dove
  /// il corpus e' finito (le ventiquattro rune, i dodici segni, i sedici
  /// argomenti) e un anno intero dove il testo varia col giorno.
  const giorniDellAnno = 366;
  const semiDelleGettate = 200;

  /// I RESPONSI DI OGNI ARTE, composti davvero.
  Map<String, List<String>> componiTutto() {
    final tutto = <String, List<String>>{};

    // --- RUNE: il presagio della gettata, per ognuna delle sue forme ---
    //
    // **SI MISURA IL PRESAGIO VERO, ordine GA, i rossi dell'unione, 20
    // ottobre 2026.** Qui si misurava `RunePresagio.componi`, il presagio a
    // un solo blocco che la schermata delle rune non mostra piu': dall'ordine
    // GA (voci GA.03, GA.05 e GA.07) la gettata si legge da
    // `IlPresagioDalCorpus.componi`, il responso principale nella forma
    // comune (la risposta col verdetto, il "Cosa fare adesso", nella Lunga
    // l'approfondimento e il galdr) e le schede delle pietre. La tabella
    // misurava un testo che nessuno legge. Si misurano i paragrafi del
    // responso principale come si leggono, uniti, in Breve e in Lunga, e le
    // due parti della scheda di una pietra, sulle stesse gettate e sugli
    // stessi semi; la domanda gira fra quattro, la prima vuota.
    const domandeDellaMisura = [
      '',
      'Che cosa mi aspetta nel lavoro?',
      'Come va il mio amore?',
      'Devo cambiare casa?',
    ];
    final schedePietra = <String>[];
    final consigliPietra = <String>[];
    for (final gettata in gettate) {
      final brevi = <String>[];
      final lunghi = <String>[];
      for (var seme = 0; seme < semiDelleGettate; seme++) {
        final esito = RuneCast.getta(gettata, random: Random(seme));
        for (final lunga in const [false, true]) {
          final presagio = IlPresagioDalCorpus.componi(
            corpus: corpusDelPresagio,
            esito: esito,
            domanda: domandeDellaMisura[seme % domandeDellaMisura.length],
            persona: 'misura-$seme',
            oggi: DateTime(2026, 10, 20),
            memoria: LaMemoriaDelPresagio(),
            lunga: lunga,
          );
          (lunga ? lunghi : brevi)
              .add(presagio.principale.paragrafi.join('\n\n'));
          if (!lunga) {
            for (final s in presagio.schede) {
              schedePietra.add(s.risposta);
              consigliPietra.add(s.cosaFare);
            }
          }
        }
      }
      tutto['Rune, presagio della gettata «${gettata.id}»'] = brevi;
      tutto['Rune, presagio Lungo della gettata «${gettata.id}»'] = lunghi;
    }
    tutto['Rune, scheda di una pietra: paragrafo'] = schedePietra;
    tutto['Rune, scheda di una pietra: cosa fare'] = consigliPietra;

    // --- RUNE: il responso della singola runa, nei due versi ---
    //
    // **Servono alla voce S.20**, che vuole il tetto a meta' della mediana: senza
    // questa riga nella tabella, quel tetto sarebbe un numero scelto a occhio.
    tutto['Rune, singola runa: verso dritto'] =
        kElderFuthark.map((r) => r.upright).toList();
    tutto['Rune, singola runa: verso d\'ombra'] =
        kElderFuthark.map((r) => r.shadow).toList();
    tutto['Rune, singola runa: riga breve di significato'] =
        kElderFuthark.map((r) => r.meaning).toList();

    // --- TAROCCHI: le parti della stesa ---
    //
    // **Dall'ordine GA, voci GA.03, GA.05 e GA.07, 20 ottobre 2026**, il
    // Consiglio e' il responso principale di casa, due paragrafi da 40 a 50
    // parole (`VoceDellaStesa.responsoDiCasa`), e ogni carta ha il suo
    // paragrafo e il suo "Cosa fare adesso" dal corpus: si misurano alla
    // fonte, un paragrafo alla volta, perche' il tetto e' di un paragrafo.
    // LAPIDE: la riga "Tarocchi, consiglio", il Consiglio intero in tre
    // paragrafi piu' la domanda.
    final sintesi = <String>[];
    final posizioni = <String>[];
    final cosaFareDelleCarte = <String>[];
    final paragrafi = <String>[];
    final domande = <String>[];
    for (final argomento in TarotTopic.values) {
      for (var seme = 0; seme < 12; seme++) {
        final stesa = TarotSpread.draw(seed: seme);
        final lettura = TarotReading.of(stesa, argomento);
        sintesi.add(lettura.sintesi);
        for (final c in stesa.cards) {
          posizioni
              .add(LeCarteNellaPosizione.letturaDiCasa(c, argomento.group));
          cosaFareDelleCarte
              .add(LeCarteNellaPosizione.cosaFareDi(c, argomento.group));
        }
        paragrafi.addAll(VoceDellaStesa.paragrafi(stesa, argomento));
        domande.add(lettura.domanda);
      }
    }
    tutto['Tarocchi, sintesi'] = sintesi;
    tutto['Tarocchi, bolla di posizione'] = posizioni;
    tutto['Tarocchi, cosa fare di una carta'] = cosaFareDelleCarte;
    tutto['Tarocchi, paragrafo del responso principale'] = paragrafi;
    tutto['Tarocchi, domanda di chiusura'] = domande;

    // --- OROSCOPO: le quattro schede del giorno, per i dodici segni ---
    for (final dominio in HoroscopeDomain.values) {
      final schede = <String>[];
      for (final segno in Zodiac.values) {
        for (var giorno = 1; giorno <= giorniDellAnno; giorno++) {
          final card = Horoscope.cardFor(
            sign: segno,
            dayOfYear: giorno,
            year: 2026,
            domain: dominio,
          );
          schede.add(card.text);
        }
      }
      tutto['Oroscopo, scheda «${dominio.name}»'] = schede;
    }

    // --- L'ARCANO DELL'ALBA: il dono e la chiusura di Medora ---
    // **SI MISURA IL TESTO VIVO.** Ordine CS, voce M1, e ordine DT: l'Arcano
    // del Giorno non c'e' piu', e cio' che la persona legge al mattino sono
    // le letture del corpus dell'Arcano dell'Alba.
    tutto['Arcano dell\'Alba, il dono'] = [
      for (final l in lettureDellAlba) l.dono,
    ];
    tutto['Arcano dell\'Alba, Medora'] = [
      for (final l in lettureDellAlba) l.medora,
    ];

    // --- SOGNO e ALBA: i messaggi del giorno ---
    // Stessa cura: il Rito dell'Alba ha il suo motore, e cio' che si
    // legge sono la parola, il gesto e il respiro.
    final parole = <String>[];
    final gesti = <String>[];
    for (var giorno = 0; giorno < giorniDellAnno; giorno++) {
      final quando = DateTime(2026, 1, 1).add(Duration(days: giorno));
      final rito = RitoAlba.diOggi(quando);
      if (rito == null) continue;
      parole.add(rito.parola);
      gesti.add(rito.gesto);
    }
    tutto['Rito dell\'Alba, la parola'] = parole;
    tutto['Rito dell\'Alba, il gesto'] = gesti;

    return tutto;
  }

  test('la tabella delle lunghezze esiste e dice il vero', () {
    final misure = componiTutto();
    final righe = <String>[
      '# Le lunghezze dei responsi, misurate',
      '',
      'Documento GENERATO dalla prova `test/le_lunghezze_dei_responsi_test.dart`.',
      'Non si scrive a mano: si rigenera con',
      '`flutter test test/le_lunghezze_dei_responsi_test.dart '
          '--dart-define=AGGIORNA_LUNGHEZZE=1`.',
      '',
      'Ordine S voce 18: **prima di accorciare qualunque cosa** si misura, e i',
      'tetti nuovi si scrivono da qui invece che a occhio. Le lunghezze sono in',
      'CARATTERI del responso composto, non delle costanti del corpus: un corpus',
      'e\' fatto di pezzi che si uniscono a runtime, e contare i mattoni non dice',
      'quanto e\' lungo il muro.',
      '',
      'La battuta e\' dichiarata: dove il corpus e\' finito si percorre intero (le',
      'forme della gettata, i sedici argomenti, i dodici segni), dove il testo',
      'varia col giorno si percorre un anno intero ($giorniDellAnno giorni), e le',
      'gettate si ripetono su $semiDelleGettate semi.',
      '',
      'COSA E\' CAMBIATO DOPO LA PRIMA MISURA, perche\' questa tabella dice lo',
      'stato di ADESSO e la voce S.20 ha usato quello di prima: i responsi delle',
      'singole rune misuravano 106 di mediana nel verso dritto e 111 in quello',
      'd\'ombra, e da quei numeri nasce il tetto di 55 caratteri, la meta\' della',
      'mediana piu\' alta arrotondata per difetto. I quarantotto testi sono stati',
      'RISCRITTI per starci dentro, non tagliati, e le righe qui sotto mostrano',
      'percio\' le lunghezze nuove.',
      '',
      '| Responso | Quanti | Mediana | Massimo |',
      '| --- | --- | --- | --- |',
    ];
    final ordinate = misure.keys.toList()..sort();
    for (final nome in ordinate) {
      final m = misura(misure[nome]!);
      righe.add('| $nome | ${m.quanti} | ${m.mediana} | ${m.massimo} |');
    }
    righe
      ..add('')
      ..add('## Il piu\' lungo di ogni tipo, in testa')
      ..add('');
    for (final nome in ordinate) {
      final m = misura(misure[nome]!);
      righe.add('- **$nome** (${m.massimo} caratteri): ${m.piuLungo}');
    }
    righe.add('');
    final atteso = righe.join('\n');

    if (aggiorna) {
      documento.parent.createSync(recursive: true);
      documento.writeAsStringSync(atteso);
      // ignore: avoid_print
      print('LUNGHEZZE: scritte ${ordinate.length} righe in '
          '${documento.path}');
      return;
    }

    expect(documento.existsSync(), isTrue,
        reason: 'docs/responsi/lunghezze.md non esiste: la voce S.18 chiede la '
            'tabella PRIMA di accorciare qualunque cosa. Rigenerala con '
            '--dart-define=AGGIORNA_LUNGHEZZE=1');
    final scritto = documento.readAsStringSync().replaceAll('\r\n', '\n');
    expect(scritto.trim(), atteso.trim(),
        reason: 'la tabella delle lunghezze e i corpora si sono allontanati: '
            'rigenerala con --dart-define=AGGIORNA_LUNGHEZZE=1, e guarda cosa e\' '
            'cambiato prima di rigenerarla');
  });

  test('nessun tetto esistente taglia cio\' che i corpora producono davvero',
      () {
    // **LA SECONDA META' DELLA VOCE 18.** I tetti nuovi si scrivono DALLA
    // tabella, e i tetti che esistono gia' vanno confrontati con la misura: un
    // tetto sotto il massimo vero e' un troncamento che aspetta il giorno giusto,
    // e un testo tagliato e' un testo non scritto. E' gia' costato una voce
    // nell'ordine P.
    final misure = componiTutto();
    int massimoDi(String nome) => misura(misure[nome]!).massimo;

    final sotto = <String>[];
    void confronta(String nome, int tetto, String comeSiChiama) {
      final vero = massimoDi(nome);
      if (tetto < vero) {
        sotto.add('$comeSiChiama vale $tetto e il massimo misurato e\' $vero');
      }
    }

    confronta('Tarocchi, sintesi', TettiDellaStesa.sintesi,
        'TettiDellaStesa.sintesi');
    confronta('Tarocchi, bolla di posizione', TettiDellaStesa.posizione,
        'TettiDellaStesa.posizione');
    confronta('Tarocchi, cosa fare di una carta', TettiDellaStesa.posizione,
        'TettiDellaStesa.posizione');
    confronta('Tarocchi, paragrafo del responso principale',
        TettiDellaStesa.consiglio, 'TettiDellaStesa.consiglio');
    confronta('Tarocchi, domanda di chiusura', TettiDellaStesa.domanda,
        'TettiDellaStesa.domanda');

    expect(sotto, isEmpty,
        reason: 'questi tetti tagliano testi che il corpus produce davvero:'
            '${String.fromCharCode(10)}${sotto.join(String.fromCharCode(10))}');
  });

  test(
      'IL TETTO DELLA CARTA TIENE TUTTE LE COMPOSIZIONI DEL CORPUS, con '
      'margine', () {
    // **Ordine GA voce GA.07**: *"I tetti di lunghezza si rimisurano sui
    // testi nuovi e si scrivono dalla misura"*. Qui non si campiona: ogni
    // scheletro di ogni posizione con ogni registro del suo verso, e ogni
    // "Cosa fare" del corpus, con ogni forma di cortesia.
    var quanti = 0;
    var massimo = 0;
    var piuLungo = '';
    final prima = LaMarcaDelGenere.formaCorrente;
    try {
      for (final f in CourtesyForm.values) {
        LaMarcaDelGenere.formaCorrente = f;
        for (final e in scheletriDelleCarte.entries) {
          final parti = e.key.split('|');
          final registri =
              registriDelleCarte['${parti[1]}|${parti[2]}'] ?? const [];
          for (final scheletro in e.value) {
            for (final registro in registri) {
              final t = LaMarcaDelGenere.risolvi('$scheletro $registro');
              quanti++;
              if (t.length > massimo) {
                massimo = t.length;
                piuLungo = t;
              }
            }
          }
        }
        for (final l in cosaFareDelleCarte.values) {
          for (final t0 in l) {
            final t = LaMarcaDelGenere.risolvi(t0);
            quanti++;
            if (t.length > massimo) {
              massimo = t.length;
              piuLungo = t;
            }
          }
        }
      }
    } finally {
      LaMarcaDelGenere.formaCorrente = prima;
    }
    // ignore: avoid_print
    print('ORDINE GA VOCE 07: paragrafi di carta misurati $quanti, il piu '
        'lungo di $massimo caratteri, tetto ${TettiDellaStesa.posizione}: '
        '$piuLungo');
    // 84.240 paragrafi e 5.616 "Cosa fare" al 20 ottobre 2026.
    cardinaleMinimo(quanti, 84240 + 5616,
        cosa: 'paragrafi di carta del corpus misurati',
        perche: 'Con un corpus vuoto il tetto sarebbe rispettato per non aver '
            'misurato niente.');
    expect(TettiDellaStesa.posizione - massimo,
        greaterThan(TettiDellaStesa.posizione * 0.10),
        reason: 'il paragrafo di carta piu lungo ha $massimo caratteri e il '
            'tetto ${TettiDellaStesa.posizione}: meno del dieci per cento di '
            'margine');
  });
}
