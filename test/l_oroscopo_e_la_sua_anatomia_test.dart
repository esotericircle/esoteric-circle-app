import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/aspetti_di_oggi.dart';
import 'package:esoteric_circle/core/astro/effemeridi.dart';
import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/horoscope/cielo_di_oggi.dart';
import 'package:esoteric_circle/core/horoscope/corrente_del_cielo.dart';
import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/core/responsi/confine_del_responso.dart';
import 'package:flutter_test/flutter_test.dart';

/// L'OROSCOPO E L'ANATOMIA DEL RESPONSO. Ordine S voce 27.
///
/// **Cosa chiede la voce.** Che l'Oroscopo personalizzato applichi la legge (S.15),
/// l'anatomia (S.16) e il confine (S.17), come hanno fatto le rune e i tarocchi.
///
/// **La misura viene prima della correzione**, come nella voce S.23: si guarda se il
/// difetto c'e' invece di darlo per scontato. Qui le tre parti si cercano nel testo
/// della scheda, che e' cio' che la persona legge.
void main() {
  /// I dodici segni per quattro schede: quarantotto testi per giorno. Si misurano
  /// tre giorni distanti fra loro, cosi' la corrente del cielo cambia e con lei la
  /// riga che dichiara da dove viene la lettura.
  const giorni = [12, 190, 320];

  List<HoroscopeCard> schede(Zodiac segno, int giorno) =>
      Horoscope.forSign(sign: segno, dayOfYear: giorno, year: 2026);

  test('ogni scheda porta la RISPOSTA, e non apre col simbolo', () {
    // **LA REGOLA DELL'ANATOMIA: il simbolo compare in "da dove viene" e non prima.**
    // Nell'Oroscopo il simbolo e' il pianeta o la casa, e la riga che li nomina
    // arriva dopo la sintesi del segno.
    const pianeti = [
      'Sole',
      'Luna',
      'Mercurio',
      'Venere',
      'Marte',
      'Giove',
      'Saturno',
      'Urano',
      'Nettuno',
      'Plutone',
    ];
    final colpe = <String>[];
    for (final segno in Zodiac.values) {
      for (final giorno in giorni) {
        for (final scheda in schede(segno, giorno)) {
          // La prima frase e' la sintesi del segno: se un pianeta comparisse li',
          // la scheda aprirebbe col simbolo.
          final primaFrase = scheda.text.split('.').first;
          for (final p in pianeti) {
            if (primaFrase.contains(p)) {
              colpe.add('${segno.name} giorno $giorno ${scheda.domain.name}: '
                  '"$p" nella prima frase');
            }
          }
          // E la risposta c'e': la sintesi apre il testo.
          if (!scheda.text.startsWith(scheda.synthesis)) {
            colpe.add('${segno.name} giorno $giorno ${scheda.domain.name}: il '
                'testo non apre con la sintesi del segno');
          }
        }
      }
    }
    expect(colpe, isEmpty, reason: colpe.take(8).join('\n'));
  });

  test('MISURA: dove compare il primo nome di pianeta', () {
    // **NON E' UNA SOGLIA, E' UN NUMERO.** Come per i tarocchi: si riporta dove
    // arriva il simbolo dentro il testo, e se un giorno risalisse in testa la prova
    // qui sopra cadrebbe prima.
    const pianeti = [
      'Sole',
      'Luna',
      'Mercurio',
      'Venere',
      'Marte',
      'Giove',
      'Saturno',
      'Urano',
      'Nettuno',
      'Plutone',
    ];
    final quote = <double>[];
    for (final segno in Zodiac.values) {
      for (final giorno in giorni) {
        for (final scheda in schede(segno, giorno)) {
          var primo = scheda.text.length;
          for (final p in pianeti) {
            final i = scheda.text.indexOf(p);
            if (i >= 0 && i < primo) primo = i;
          }
          if (primo < scheda.text.length) {
            quote.add(primo / scheda.text.length);
          }
        }
      }
    }
    if (quote.isEmpty) {
      // ignore: avoid_print
      print('ORDINE S VOCE 27: nessuna scheda nomina un pianeta nel testo.');
      return;
    }
    quote.sort();
    // ignore: avoid_print
    print('ORDINE S VOCE 27: primo nome di pianeta, frazione del testo: '
        'minimo ${(quote.first * 100).toStringAsFixed(1)}, mediana '
        '${(quote[quote.length ~/ 2] * 100).toStringAsFixed(1)}, massimo '
        '${(quote.last * 100).toStringAsFixed(1)} per cento, su ${quote.length} '
        'schede che lo nominano');
  });

  test('ogni scheda porta COSA PUOI FARE, cioe\' una seconda frase', () {
    // La sintesi dice cosa la lettura vede; la corrente del giorno dice cosa fare.
    // Una scheda che porta solo la sintesi e' un responso a una parte sola.
    final povere = <String>[];
    for (final segno in Zodiac.values) {
      for (final giorno in giorni) {
        for (final scheda in schede(segno, giorno)) {
          final dopo = scheda.text.substring(scheda.synthesis.length).trim();
          if (dopo.length < 20) {
            povere.add('${segno.name} giorno $giorno ${scheda.domain.name}: '
                'dopo la sintesi restano ${dopo.length} caratteri');
          }
        }
      }
    }
    expect(povere, isEmpty, reason: povere.take(8).join('\n'));
  });

  test('la riga del cielo, quando c\'e\', apre con una giuntura dichiarata',
      () {
    // **DA DOVE VIENE, ed e' la parte 3.** Le giunture vivono in due famiglie
    // dichiarate in `CorrenteDelCielo`, una coi due punti e una col punto, e la
    // ragione e' grammaticale: dopo i due punti l'italiano vuole la minuscola, e
    // "Marte" la minuscola non la prende.
    final tutte = [
      ...CorrenteDelCielo.giunturaCoiDuePunti,
      ...CorrenteDelCielo.giunturaColPunto,
    ];
    expect(tutte.length, greaterThanOrEqualTo(10),
        reason: 'le due famiglie di giunture si sono svuotate');
    // Nessuna giuntura nomina un pianeta: se lo facesse, il simbolo arriverebbe
    // nella cucitura invece che nella frase, cioe' mezzo passo prima.
    for (final g in tutte) {
      for (final p in const ['Sole', 'Luna', 'Marte', 'Venere']) {
        expect(g.contains(p), isFalse,
            reason: 'la giuntura "$g" nomina $p: il simbolo entra nella '
                'cucitura invece che in "da dove viene"');
      }
    }
  });

  test('i testi dell\'Oroscopo stanno dentro il confine della voce S.17', () {
    // Il confine gia' setaccia l'Oroscopo in `il_confine_del_responso_test`: qui si
    // guarda il testo COMPOSTO, cioe' sintesi piu' corrente, che e' quello che la
    // persona legge davvero e che quella prova non compone.
    final violazioni = <String>[];
    for (final segno in Zodiac.values) {
      for (final giorno in giorni) {
        for (final scheda in schede(segno, giorno)) {
          final v = ConfineDelResponso.violazioni(scheda.text);
          if (v.isNotEmpty) {
            violazioni.add('${segno.name} giorno $giorno '
                '${scheda.domain.name}: ${v.join("; ")}');
          }
        }
      }
    }
    expect(violazioni, isEmpty, reason: violazioni.take(8).join('\n'));
  });

  test('COL CIELO VERO la parte 3 c\'e\', e arriva DOPO la risposta', () {
    // **LA MISURA DI PRIMA NON BASTAVA, e va detto.** `Horoscope.forSign` senza
    // cielo compone il testo dal solo segno: nessuna scheda nomina un pianeta,
    // quindi la prova che cerca il simbolo non misurava niente. La parte 3
    // dell'anatomia, "da dove viene", esiste solo quando la persona ha la carta e il
    // cielo e' vero, ed e' li' che va guardata.
    final voci = [
      const VoceDelCielo(
        transito: CorpoCeleste.venere,
        bersaglio: 'Saturno',
        idBersaglio: 'saturn',
        aspetto: AspectType.trine,
        orbe: 1.8,
        applicativo: true,
        casa: 10,
        retrogrado: false,
        giorniDiIncertezza: 0.01,
      ),
    ];
    const cielo =
        CieloDiOggi(voci: [], livello: LivelloPersonalizzazione.cartaCompleta);
    final vero = CieloDiOggi(
        voci: voci, livello: LivelloPersonalizzazione.cartaCompleta);
    // Senza voci non c'e' riga del cielo: il ripiego resta il testo del segno.
    expect(
        CorrenteDelCielo.componi(
            cielo: cielo, dominio: HoroscopeDomain.amore, profonda: false),
        isNull,
        reason: 'senza voci del cielo la riga non deve nascere: una riga '
            'generica scritta come una vera si legge come vera');
    final riga = CorrenteDelCielo.componi(
        cielo: vero, dominio: HoroscopeDomain.amore, profonda: false);
    expect(riga, isNotNull);

    for (final segno in Zodiac.values) {
      for (final scheda in Horoscope.forSign(
          sign: segno, dayOfYear: 190, year: 2026, cielo: vero)) {
        // **LA RISPOSTA RESTA PRIMA:** il testo apre con la sintesi del segno e la
        // riga del cielo arriva dopo, come vuole l'anatomia.
        expect(scheda.text.startsWith(scheda.synthesis), isTrue,
            reason: '${segno.name} ${scheda.domain.name}: col cielo vero il '
                'testo non apre più con la risposta');
        final dovePianeta = scheda.text.indexOf('Venere');
        if (dovePianeta < 0) continue;
        expect(dovePianeta, greaterThan(scheda.synthesis.length - 1),
            reason: '${segno.name} ${scheda.domain.name}: il pianeta compare '
                'dentro la risposta, cioè prima di "da dove viene"');
      }
    }
  });
}
