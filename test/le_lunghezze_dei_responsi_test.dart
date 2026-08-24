import 'dart:io';
import 'dart:math';

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/core/rituals/daily_rituals.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/rituals/rune_presage.dart';
import 'package:esoteric_circle/core/rituals/runes.dart';
import 'package:esoteric_circle/core/tarot/tarot_reading.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tetti_della_stesa.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:flutter_test/flutter_test.dart';

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
    final piuLungo =
        puliti.reduce((a, b) => b.length > a.length ? b : a);
    return (
      quanti: puliti.length,
      mediana: mediana,
      massimo: massimo,
      piuLungo: piuLungo.length <= 90
          ? piuLungo
          : '${piuLungo.substring(0, 90)}...',
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
    for (final gettata in gettate) {
      final presagi = <String>[];
      for (var seme = 0; seme < semiDelleGettate; seme++) {
        final esito = RuneCast.getta(gettata, random: Random(seme));
        presagi.add(RunePresagio.componi(esito));
      }
      tutto['Rune, presagio della gettata «${gettata.id}»'] = presagi;
    }

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

    // --- TAROCCHI: le quattro parti della stesa ---
    final sintesi = <String>[];
    final posizioni = <String>[];
    final consigli = <String>[];
    final domande = <String>[];
    for (final argomento in TarotTopic.values) {
      for (var seme = 0; seme < 12; seme++) {
        final stesa = TarotSpread.draw(seed: seme);
        final lettura = TarotReading.of(stesa, argomento);
        sintesi.add(lettura.sintesi);
        for (final p in lettura.posizioni) {
          posizioni.add(p.testo);
        }
        consigli.add(lettura.consiglio);
        domande.add(lettura.domanda);
      }
    }
    tutto['Tarocchi, sintesi'] = sintesi;
    tutto['Tarocchi, bolla di posizione'] = posizioni;
    tutto['Tarocchi, consiglio'] = consigli;
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

    // --- ORACOLO DEL GIORNO: la riga di mezza giornata ---
    final oracoli = <String>[];
    for (var giorno = 0; giorno < giorniDellAnno; giorno++) {
      oracoli.add(DailyRituals.dayOracle(DateTime(2026, 1, 1)
          .add(Duration(days: giorno))));
    }
    tutto['Oracolo del Giorno, la riga'] = oracoli;

    // --- SOGNO e ALBA: i messaggi del giorno ---
    final saluti = <String>[];
    final mattini = <String>[];
    for (var giorno = 0; giorno < giorniDellAnno; giorno++) {
      final quando = DateTime(2026, 1, 1).add(Duration(days: giorno));
      saluti.add(DailyRituals.nightMessage(quando));
      mattini.add(DailyRituals.dawnMessage(quando));
    }
    tutto['Sigillo del Sogno, saluto della notte'] = saluti;
    tutto['Rito dell\'Alba, messaggio del mattino'] = mattini;

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

  test('nessun tetto esistente taglia cio\' che i corpora producono davvero', () {
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
    confronta('Tarocchi, consiglio', TettiDellaStesa.consiglio,
        'TettiDellaStesa.consiglio');
    confronta('Tarocchi, domanda di chiusura', TettiDellaStesa.domanda,
        'TettiDellaStesa.domanda');

    expect(sotto, isEmpty,
        reason: 'questi tetti tagliano testi che il corpus produce davvero:'
            '${String.fromCharCode(10)}${sotto.join(String.fromCharCode(10))}');
  });
}
