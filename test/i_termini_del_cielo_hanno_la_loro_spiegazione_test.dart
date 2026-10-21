// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/horoscope/i_testi_eu.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'oroscopo_eu_comune.dart';

/// **I TERMINI TECNICI DEL "DA DOVE VIENE" HANNO LA LORO SPIEGAZIONE.**
/// Ordine GA voce GA.06, quarto giro, 21 ottobre 2026.
///
/// Il fondatore: *"Le risposte vanno curate, sono la parte più importante e
/// criticata dell'app."* L'ultima lettura cieca indipendente (12 responsi) ha
/// dato D3 sei su dodici, e tutti i sei no erano gergo non spiegato nel "Da
/// dove viene": "in quadratura al tuo segno", "nella tua quarta casa solare",
/// "L'Ascendente della tua Rivoluzione Solare", "Giove era in Mithuna",
/// "dal dio che quel giorno porta al tuo elemento di nascita". Padre: ordine
/// ES voci 02, 03, 08 e 09 (la riga del cielo scritta con le parole dei
/// metodi), rimasta uguale dopo le tre cure GA.06 precedenti.
///
/// **La regola** (dell'ordine di oggi): un termine tecnico compare SOLO
/// insieme alla sua spiegazione, in parole di tutti i giorni, nella stessa
/// riga; oppure non compare e si dice la sostanza. La sostanza viene prima del
/// termine. E il "Da dove viene" resta breve: circa novanta parole nella
/// Breve e circa centotrenta nella Lunga, mai un muro.
///
/// Si leggono i "Da dove viene" veri di dodici persone, nelle tre tradizioni,
/// nei quattro periodi, nei quattro domini, in Breve e in Lunga.
void main() {
  // termine -> (come si riconosce, che cosa deve esserci nella stessa riga)
  final termini = <String, (RegExp, RegExp)>{
    'quadratura': (RegExp(r'\bquadratur'), RegExp(r'tensione')),
    'trigono': (RegExp(r'\btrigon'), RegExp(r'accordo')),
    'sestile': (RegExp(r'\bsestil'), RegExp(r'sintonia')),
    'opposizione': (RegExp(r'\bopposizion'), RegExp(r'(di fronte|contrasto)')),
    'congiunzione': (
      RegExp(r'\bcongiunzion'),
      RegExp(r'(contatto|stesso segno)')
    ),
    'Ascendente': (RegExp(r'Ascendente'), RegExp(r'il segno che sorgeva')),
    'Medio Cielo': (RegExp(r'Medio Cielo'), RegExp(r'il punto più alto')),
    'Rivoluzione Solare': (
      RegExp(r'Rivoluzione Solare'),
      RegExp(r'cielo del (tuo )?compleanno')
    ),
    'casa': (
      RegExp(r'\b(\d+|prima|seconda|terza|quarta|quinta|sesta|settima|ottava|'
          r'nona|decima|undicesima|dodicesima)\s+casa\b|\bcasa\s+\d+|\bcase\b|'
          r'\bcasa\s+(angolare|succedente|cadente)'),
      RegExp(r'(chiama case|dodici case, cioè)')
    ),
    'Sade Sati': (RegExp(r'Sade Sati'), RegExp(r'sette anni e mezzo')),
    'tara': (RegExp(r'\btar[ae]\b|Tara Bala'), RegExp(r'stell')),
    'Chandra Bala': (RegExp(r'Chandra Bala'), RegExp(r'Luna')),
    'Rahu Kalam': (
      RegExp(r'Rahu Kalam'),
      RegExp(r"(l'ora e mezza|il tratto del giorno|ottavo del tempo)")
    ),
    'Chandrashtama': (
      RegExp(r'Chandrashtama'),
      RegExp(r'(ottav|giorno più delicato)')
    ),
    'Naidhana': (RegExp(r'Naidhana'), RegExp(r'(la fine|settima|delicat)')),
    'nome della tara': (
      RegExp(r'\b(Janma|Sampat|Vipat|Kshema|Pratyak|Sadhana|Parama Mitra)\b'),
      RegExp(r'(la nascita|la ricchezza|il pericolo|il benessere|'
          r"l.ostacolo|la riuscita|il grande amico|la tua stessa stella|"
          r'stella della prosperità|stella delle perdite|degli ostacoli|'
          r'realizzazione delle ambizioni)')
    ),
    'BaZi': (RegExp(r'BaZi'), RegExp(r'(lettura cinese|carattere di nascita)')),
    'le dieci forze': (
      RegExp(r'\b(Compagno|Rivale|Nutrimento|Ufficiale|Ricchezza|Sigill\w+|'
          r'Sette Uccisioni)\b'),
      RegExp(r'BaZi')
    ),
    'Tai Sui': (RegExp(r'Tai Sui'), RegExp(r"signore dell'anno")),
    'Tong Shu': (RegExp(r'Tong Shu'), RegExp(r'almanacco')),
  };

  // Le parole che a chi legge non dicono niente e che non devono comparire.
  final vietate = RegExp(r'casa solare|polarità|elemento di nascita|'
      r'\bil dio (di|del|che)|\bdio di (oggi|quel giorno)|\bterna\b|'
      r'\bramo\b|\brami\b|\bMithuna\b|\bMesha\b|\bVrishabha\b|\bKarka\b|'
      r'\bSimha\b|\bKanya\b|\bTula\b|\bVrishchika\b|\bDhanu\b|\bMakara\b|'
      r'\bKumbha\b|\bMina\b|dal tuo Sole di nascita senza');

  final giorni = [
    DateTime(2026, 9, 3),
    DateTime(2026, 10, 14),
    DateTime(2026, 10, 25),
    DateTime(2026, 11, 8),
    DateTime(2026, 12, 19),
    DateTime(2027, 1, 27),
  ];
  final perPeriodo = [DateTime(2026, 10, 20), DateTime(2026, 11, 22)];

  test('ogni termine tecnico ha la sua spiegazione nella stessa riga', () {
    final righe = <(String, bool, String)>[];
    void aggiungi(String chi, bool lunga, String? riga) {
      if (riga != null && riga.trim().isNotEmpty) {
        righe.add((chi, lunga, riga));
      }
    }

    for (final p in dodiciPersone) {
      for (final t in TradizioneEu.values) {
        if (!p.legge(t)) continue;
        for (final lunga in [false, true]) {
          for (final g in giorni) {
            for (final c in p.giorno(t, g, lunga: lunga)) {
              aggiungi('${p.nome} ${t.name} giorno ${c.domain.name} $g', lunga,
                  c.responso?.daDoveViene);
            }
          }
          if (t != TradizioneEu.occidentale || p.conCarta) {
            for (final g in perPeriodo) {
              for (final c in p.anno(t, g, lunga: lunga)) {
                aggiungi('${p.nome} ${t.name} anno ${c.domain.name} $g', lunga,
                    c.responso?.daDoveViene);
              }
            }
          }
        }
      }
    }
    // Settimana e Mese: piu' costosi, una persona su tre.
    for (var i = 0; i < dodiciPersone.length; i += 3) {
      final p = dodiciPersone[i];
      for (final t in TradizioneEu.values) {
        if (!p.legge(t)) continue;
        for (final mese in [false, true]) {
          final per = p.periodo(t, perPeriodo[mese ? 1 : 0], mese: mese);
          for (final dom in per.domini) {
            for (final lunga in [false, true]) {
              aggiungi(
                  '${p.nome} ${t.name} ${mese ? 'mese' : 'settimana'} '
                  '${dom.dominio.name}',
                  lunga,
                  dom.responso(t, mese: mese, lunga: lunga).daDoveViene);
            }
          }
        }
      }
    }

    final mancano = <String>[];
    final vietateTrovate = <String>[];
    final lunghe = <String>[];
    final visti = <String, int>{};
    var piuLunga = 0;
    var piuLungaBreve = 0;
    for (final (chi, lunga, riga) in righe) {
      for (final e in termini.entries) {
        final (cerca, spiega) = e.value;
        if (cerca.hasMatch(riga)) {
          visti[e.key] = (visti[e.key] ?? 0) + 1;
          if (!spiega.hasMatch(riga)) {
            mancano.add('${e.key}: $chi: «$riga»');
          }
        }
      }
      final v = vietate.firstMatch(riga);
      if (v != null) vietateTrovate.add('«${v.group(0)}» in $chi: «$riga»');
      final n = riga.trim().split(RegExp(r'\s+')).length;
      if (lunga) {
        if (n > piuLunga) piuLunga = n;
      } else {
        if (n > piuLungaBreve) piuLungaBreve = n;
      }
      if (n > (lunga ? 140 : 105)) lunghe.add('$n parole, $chi');
    }
    cardinaleMinimo(righe.length, 1200, cosa: 'righe del "Da dove viene"');
    cardinaleMinimo(visti.length, 14, cosa: 'termini tecnici incontrati');
    print('GA.06 giro 4: righe lette ${righe.length}, termini incontrati '
        '${visti.length} ($visti), senza spiegazione ${mancano.length}, '
        'parole vietate ${vietateTrovate.length}, righe troppo lunghe '
        '${lunghe.length}; la piu lunga: Breve $piuLungaBreve, Lunga $piuLunga');
    for (final l in lunghe) {
      print('  TROPPO LUNGA: $l');
    }
    for (final m in mancano) {
      print('  SENZA SPIEGAZIONE: ${m.substring(0, m.indexOf('«'))}');
    }
    expect(vietateTrovate, isEmpty, reason: vietateTrovate.take(5).join('\n'));
    expect(mancano, isEmpty, reason: mancano.take(5).join('\n'));
    expect(lunghe, isEmpty, reason: lunghe.take(5).join('\n'));
  }, timeout: const Timeout(Duration(minutes: 20)));
}
