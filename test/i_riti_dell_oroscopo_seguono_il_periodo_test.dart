// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/core/horoscope/i_testi_eu.dart';
import 'package:esoteric_circle/core/responsi/i_riti_propiziatori.dart';
import 'package:esoteric_circle/core/responsi/i_riti_propiziatori_dati.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'oroscopo_eu_comune.dart';

/// **I RITI DELL'OROSCOPO SEGUONO IL PERIODO.** Ordine GA voce GA.06, 21
/// ottobre 2026.
///
/// Il fondatore, 19 ottobre 2026: *"ogni risposta deve essere coerente con i
/// simboli o carte o segni altro da interpretare e coerente con la domanda
/// posta dall'utente"*. Il lettore cieco, sul campione di 48 responsi
/// dell'Oroscopo: lo stesso rito parola per parola in oroscopo-7 e 15, 37 e
/// 45, 39 e 47; un rito dell'Anno che diceva "Al primo mattino del periodo"
/// con l'anno cominciato l'8 marzo e oggi il 20 ottobre (oroscopo-32);
/// "Inaugura il tratto" e "fai di questo inizio un traguardo" sotto un anno
/// cominciato a febbraio (45, 47); "pensando a chi ami" sotto una risposta per
/// chi e' senza legame (10). La causa era una sola: le raccolte avevano un
/// solo rito "periodo" per la Settimana, il Mese e l'Anno.
///
/// Si pretende:
/// 1. **un rito per ogni periodo**: per ogni reggente delle tre raccolte e ogni
///    dominio, i riti giorno, settimana, mese e anno, e nessuna chiave
///    "periodo";
/// 2. **nessun rito ripetuto**: nessun testo uguale sotto due chiavi, e nessuna
///    frase di cinque parole o piu' (fuori dalla formula fra virgolette, che
///    torna di proposito) in due riti;
/// 3. **il rito dell'Anno vale in qualunque punto dell'anno**: niente inizi,
///    mesi, stagioni, "periodo";
/// 4. **l'Amore parla anche a chi e' senza legame**;
/// 5. **a video, per la stessa persona nello stesso giorno**, i riti del
///    Giorno, della Settimana, del Mese e dell'Anno dello stesso dominio sono
///    quattro riti diversi.
void main() {
  const reggenti = {
    IRitiPropiziatori.inniOrfici: [
      'Sole', 'Luna', 'Marte', 'Mercurio', 'Giove', 'Venere', 'Saturno', //
    ],
    IRitiPropiziatori.mantraNavagraha: [
      'Surya', 'Chandra', 'Mangala', 'Budha', 'Guru', 'Shukra', 'Shani', //
    ],
    IRitiPropiziatori.gestiTongShu: [
      'Jian', 'Chu', 'Man', 'Ping', 'Ding', 'Zhi', //
      'Po', 'Wei', 'Cheng', 'Shou', 'Kai', 'Bi',
    ],
  };
  const domini = ['Generale', 'Amore', 'Carriera', 'Fortuna'];
  const periodi = ['giorno', 'settimana', 'mese', 'anno'];
  final citazione = RegExp(r'«[^»]*»');

  /// I riti delle tre raccolte dell'Oroscopo, per chiave.
  final riti = {
    for (final e in IRitiPropiziatoriDati.riti.entries)
      if (reggenti.keys.any((r) => e.key.startsWith('$r|'))) e.key: e.value,
  };

  test('un rito per ogni periodo, e nessun rito "periodo"', () {
    final mancano = <String>[];
    for (final r in reggenti.entries) {
      for (final chi in r.value) {
        for (final d in domini) {
          for (final p in periodi) {
            if (IRitiPropiziatori.rito(r.key, [chi, d, p]) == null) {
              mancano.add('${r.key}|$chi|$d|$p');
            }
          }
        }
      }
    }
    final vecchie = [
      for (final k in riti.keys)
        if (!periodi.contains(k.split('|').last)) k
    ];
    cardinaleMinimo(riti.length, 416,
        cosa: 'riti dell\'Oroscopo',
        perche: '(7 + 7 + 12) reggenti, quattro domini, quattro periodi');
    print('ORDINE GA VOCE GA.06: riti dell\'Oroscopo ${riti.length}, mancanti '
        '${mancano.length}, chiavi fuori dai quattro periodi ${vecchie.length}');
    expect(mancano, isEmpty, reason: mancano.take(8).join('\n'));
    expect(vecchie, isEmpty, reason: vecchie.take(8).join('\n'));
  });

  test('nessun rito ripetuto, nessuna frase in due riti', () {
    final perTesto = <String, String>{};
    final perFrase = <String, String>{};
    final doppi = <String>[];
    for (final e in riti.entries) {
      final gia = perTesto[e.value];
      if (gia != null) doppi.add('${e.key} = $gia');
      perTesto[e.value] = e.key;
      final raccolta = e.key.split('|').first;
      for (final f in e.value
          .replaceAll(citazione, '«»')
          .split(RegExp(r'(?<=[.?:;])\s+'))) {
        if (f.trim().split(RegExp(r'\s+')).length < 5) continue;
        final chiave = '$raccolta|${f.trim().toLowerCase()}';
        final prima = perFrase[chiave];
        if (prima != null && prima != e.key) {
          doppi.add('${e.key} e $prima: «${f.trim()}»');
        }
        perFrase[chiave] = e.key;
      }
    }
    cardinaleMinimo(perFrase.length, 1000,
        cosa: 'frasi dei riti dell\'Oroscopo',
        perche: 'quattrocentosedici riti di tre o quattro frasi');
    print('ORDINE GA VOCE GA.06: frasi dei riti ${perFrase.length}, riti o '
        'frasi ripetute ${doppi.length}');
    expect(doppi, isEmpty, reason: doppi.take(8).join('\n'));
  });

  test('il rito dell\'Anno vale in qualunque punto dell\'anno', () {
    final fuori = RegExp(
        r"\b(inizi\w*|inaugur\w*|primo mattino|comincia\w*|si apre|apre|"
        r"prim[oa] giorn[oi]|mesi|ogni mese|met[àa] (dell.)?anno|"
        r"fine dell.anno|periodo|primavera|estate|autunno|inverno|"
        r"stagion\w*)\b",
        caseSensitive: false);
    final colpe = <String>[];
    var anni = 0;
    for (final e in riti.entries) {
      if (!e.key.endsWith('|anno')) continue;
      anni++;
      final m = fuori.firstMatch(e.value.replaceAll(citazione, ''));
      if (m != null) colpe.add('${e.key}: «${m.group(0)}»');
    }
    cardinaleMinimo(anni, 104, cosa: 'riti dell\'Anno');
    print('ORDINE GA VOCE GA.06: riti dell\'Anno $anni, con un inizio o un '
        'tempo fuori dall\'anno ${colpe.length}');
    expect(colpe, isEmpty, reason: colpe.take(8).join('\n'));
  });

  test('l\'Amore parla anche a chi e\' senza legame', () {
    final soloCoppia = RegExp(r'(chi ami|persona amata|il partner|la partner)',
        caseSensitive: false);
    final altraStrada = RegExp(
        r'(o a chi|o chi|o per chi|o di chi|o con chi|chi desideri|'
        r'chi vorresti|senza legame|se cerchi|se non hai|se hai un legame)',
        caseSensitive: false);
    final colpe = <String>[];
    var amori = 0;
    for (final e in riti.entries) {
      if (!e.key.contains('|Amore|')) continue;
      amori++;
      final t = e.value.replaceAll(citazione, '');
      if (soloCoppia.hasMatch(t) && !altraStrada.hasMatch(t)) colpe.add(e.key);
    }
    cardinaleMinimo(amori, 104, cosa: 'riti dell\'Amore');
    print('ORDINE GA VOCE GA.06: riti dell\'Amore $amori, solo per chi ha un '
        'legame ${colpe.length}');
    expect(colpe, isEmpty, reason: colpe.join('\n'));
  });

  test('a video, i quattro periodi dello stesso giorno hanno quattro riti',
      () {
    final uguali = <String>[];
    var confronti = 0;
    final giorni = [
      DateTime(2026, 10, 20),
      DateTime(2026, 10, 23),
      DateTime(2026, 10, 25),
    ];
    for (final persona in dodiciPersone.take(4)) {
      for (final oggi in giorni) {
        for (final t in TradizioneEu.values) {
          if (!persona.legge(t)) continue;
          final perDominio = <HoroscopeDomain, Map<String, String?>>{};
          void metti(HoroscopeDomain d, String periodo, String? rito) =>
              (perDominio[d] ??= {})[periodo] = rito;
          for (final c in persona.giorno(t, oggi)) {
            metti(c.domain, 'Giorno', c.responso?.rito);
          }
          for (final mese in const [false, true]) {
            for (final d in persona.periodo(t, oggi, mese: mese).domini) {
              metti(d.dominio, mese ? 'Mese' : 'Settimana',
                  d.responso(t, mese: mese, lunga: true).rito);
            }
          }
          for (final c in persona.anno(t, oggi)) {
            metti(c.domain, 'Anno', c.responso?.rito);
          }
          for (final e in perDominio.entries) {
            final visti = <String, String>{};
            for (final p in e.value.entries) {
              final rito = p.value;
              if (rito == null) continue;
              confronti++;
              final prima = visti[rito];
              if (prima != null) {
                uguali.add('${persona.nome} ${oggi.day}/${oggi.month} '
                    '${t.name} ${e.key.label}: $prima e ${p.key} hanno lo '
                    'stesso rito');
              }
              visti[rito] = p.key;
            }
          }
        }
      }
    }
    cardinaleMinimo(confronti, 4 * 3 * 2 * 4 * 4,
        cosa: 'riti a video',
        perche: 'quattro persone, tre giorni, almeno due tradizioni, '
            'quattro domini, quattro periodi');
    print('ORDINE GA VOCE GA.06: riti a video $confronti, uguali fra due '
        'periodi dello stesso giorno ${uguali.length}');
    expect(uguali, isEmpty, reason: uguali.take(8).join('\n'));
  });
}
