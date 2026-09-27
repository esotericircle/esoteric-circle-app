// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:esoteric_circle/features/maestri/live/il_parlato_del_maestro.dart';
import 'package:esoteric_circle/features/maestri/live/le_tre_frasi_del_live.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL COLLAUDO DELLE TRE FRASI DEL LIVE, ordine ER voce 12.** 27 settembre
/// 2026.
///
/// Il taglio della voce ER.12 non chiede niente di nuovo al modello: prende
/// la risposta che arriva e ne dice al massimo tre frasi intere
/// (`LeTreFrasiDelLive.di`). Quindi il prima e il dopo si misurano **sulle
/// stesse risposte vere**: le settantadue del LIVE con Flash, il modello di
/// oggi, dodici domande di seguito per Maestro in due giri, dal collaudo
/// dell'ordine EQ voce 03 sull'istruzione definitiva
/// (`docs/collaudo/EQ/eq03/dopo_seconda_stesura/`). Prima e' cio' che la voce
/// diceva, la risposta intera; dopo e' cio' che dice adesso.
///
/// Scrive `docs/collaudo/ER/live_tre_frasi.txt` e, se c'e' `CIECO`, il
/// fascicolo per la lettura alla cieca del merito: le risposte intere e
/// quelle tagliate, mescolate, ognuna con la domanda e lo scambio di prima
/// nella stessa versione, da leggere con la regola dell'ordine EQ voce 03.
///
/// La durata della voce e' una stima a [caratteriAlSecondo], il ritmo del
/// parlato italiano naturale misurato nell'ordine EG: quella vera si legge
/// sul telefono.
const double caratteriAlSecondo = 13;

class _Turno {
  _Turno(this.maestro, this.giro, this.n, this.domanda, this.scritta);
  final String maestro;
  final int giro;
  final int n;
  final String domanda;
  final String scritta;
  String get prima => IlParlatoDelMaestro.daDire(scritta);
  String get dopo => LeTreFrasiDelLive.di(scritta);
}

List<_Turno> _leggi(String maestro, int giro) {
  final f = File('docs/collaudo/EQ/eq03/dopo_seconda_stesura/'
      'LIVE_con_Flash_giro_${giro}_$maestro.md');
  final turni = <_Turno>[];
  final sezioni = f.readAsStringSync().split(RegExp(r'^## ', multiLine: true));
  for (final s in sezioni.skip(1)) {
    final righe = s.split('\n');
    final m = RegExp(r'^(\d+)\. (.*)$').firstMatch(righe.first.trim());
    if (m == null) continue;
    final risposta = [
      for (final r in righe.skip(1))
        if (r.startsWith('>')) r.replaceFirst(RegExp(r'^>\s?'), ''),
    ].join('\n').trim();
    turni.add(_Turno(maestro, giro, int.parse(m.group(1)!), m.group(2)!.trim(),
        risposta));
  }
  return turni;
}

double _mediana(List<num> v) {
  final s = [...v]..sort();
  return s.isEmpty ? 0 : s[s.length ~/ 2].toDouble();
}

void main() {
  test('le tre frasi del LIVE, prima e dopo sulle stesse risposte', () {
    const maestri = ['medora', 'aura', 'caligo'];
    final righe = <String>[
      'ORDINE ER VOCE 12: LE TRE FRASI DEL LIVE, ${DateTime.now()}',
      'Risposte vere del LIVE con Flash, dodici domande di seguito per '
          'Maestro, due giri (le due esecuzioni), dal collaudo dell\'ordine EQ '
          'voce 03 sull\'istruzione definitiva: '
          'docs/collaudo/EQ/eq03/dopo_seconda_stesura/.',
      'PRIMA: la voce diceva la risposta intera (IlParlatoDelMaestro.daDire). '
          'DOPO: la voce dice LeTreFrasiDelLive.di, al massimo tre frasi '
          'intere.',
      'Durata della voce stimata a $caratteriAlSecondo caratteri al secondo '
          '(ordine EG).',
      '',
    ];
    final tutti = <_Turno>[];
    for (final giro in [1, 2]) {
      final delGiro = [for (final m in maestri) ..._leggi(m, giro)];
      tutti.addAll(delGiro);
      final oltrePrima = delGiro
          .where((t) => LeTreFrasiDelLive.frasiDi(t.prima).length > 3)
          .length;
      final oltreDopo = delGiro
          .where((t) => LeTreFrasiDelLive.frasiDi(t.dopo).length > 3)
          .length;
      final tagliateAMeta = delGiro
          .where((t) =>
              t.dopo.isNotEmpty && !RegExp(r'[.!?…]$').hasMatch(t.dopo.trim()))
          .length;
      // Una frase detta dopo che non e' una frase intera della risposta.
      final nonIntere = delGiro.where((t) {
        final intere = LeTreFrasiDelLive.frasiDi(t.prima).toSet();
        return LeTreFrasiDelLive.frasiDi(t.dopo)
            .any((f) => !intere.contains(f));
      }).length;
      final secPrima = [
        for (final t in delGiro) t.prima.length / caratteriAlSecondo
      ];
      final secDopo = [
        for (final t in delGiro) t.dopo.length / caratteriAlSecondo
      ];
      righe
        ..add('== ESECUZIONE $giro (giro $giro): ${delGiro.length} turni')
        ..add('turni con piu\' di tre frasi dette: prima $oltrePrima su '
            '${delGiro.length}, dopo $oltreDopo su ${delGiro.length}')
        ..add('frasi dette, mediana: prima '
            '${_mediana([
              for (final t in delGiro) LeTreFrasiDelLive.frasiDi(t.prima).length
            ]).toStringAsFixed(0)}, dopo '
            '${_mediana([
              for (final t in delGiro) LeTreFrasiDelLive.frasiDi(t.dopo).length
            ]).toStringAsFixed(0)}')
        ..add('durata della voce stimata, mediana: prima '
            '${_mediana(secPrima).toStringAsFixed(1)} s (massimo '
            '${secPrima.reduce(max).toStringAsFixed(1)}), dopo '
            '${_mediana(secDopo).toStringAsFixed(1)} s (massimo '
            '${secDopo.reduce(max).toStringAsFixed(1)})')
        ..add('frasi tagliate a meta\': dopo $tagliateAMeta; frasi dette che '
            'non sono una frase intera della risposta: dopo $nonIntere')
        ..add('');
    }
    righe.add('== I TURNI');
    for (final t in tutti) {
      righe
        ..add('[${t.maestro} giro ${t.giro}, ${t.n}] ${t.domanda}')
        ..add('    PRIMA (${LeTreFrasiDelLive.frasiDi(t.prima).length} frasi, '
            '${t.prima.length} caratteri): ${t.prima}')
        ..add('    DOPO (${LeTreFrasiDelLive.frasiDi(t.dopo).length} frasi, '
            '${t.dopo.length} caratteri): ${t.dopo}');
    }
    File('docs/collaudo/ER/live_tre_frasi.txt')
        .writeAsStringSync('${righe.join('\n')}\n');
    print(righe.take(20).join('\n'));

    // **IL FASCICOLO ALLA CIECA**: ogni turno due volte, intero e tagliato,
    // con lo scambio di prima nella stessa versione.
    final cieco = Platform.environment['CIECO'];
    if (cieco == null) return;
    final voci = <Map<String, Object>>[];
    for (final versione in ['intera', 'tagliata']) {
      for (var i = 0; i < tutti.length; i++) {
        final t = tutti[i];
        final prec = i > 0 &&
                tutti[i - 1].maestro == t.maestro &&
                tutti[i - 1].giro == t.giro
            ? tutti[i - 1]
            : null;
        String testo(_Turno x) => versione == 'intera' ? x.prima : x.dopo;
        voci.add({
          'maestro': t.maestro,
          'giro': t.giro,
          'n': t.n,
          'versione': versione,
          'domandaPrima': prec?.domanda ?? '(nessuna)',
          'rispostaPrima': prec == null ? '(nessuna)' : testo(prec),
          'domanda': t.domanda,
          'risposta': testo(t),
        });
      }
    }
    voci.shuffle(Random(12));
    final fascicolo = StringBuffer();
    final chiave = <String, Object>{};
    for (var i = 0; i < voci.length; i++) {
      final id = 'L${(i + 1).toString().padLeft(3, '0')}';
      final v = voci[i];
      chiave[id] = v;
      fascicolo
        ..writeln(id)
        ..writeln('MAESTRO: ${v['maestro']}')
        ..writeln('SCAMBIO DI PRIMA: «${v['domandaPrima']}» -> '
            '«${v['rispostaPrima']}»')
        ..writeln('DOMANDA: ${v['domanda']}')
        ..writeln('RISPOSTA DETTA DAL MAESTRO: ${v['risposta']}')
        ..writeln();
    }
    File('$cieco/cieco_live_er12.txt').writeAsStringSync('$fascicolo');
    File('$cieco/chiave_live_er12.json').writeAsStringSync(
        const JsonEncoder.withIndent(' ').convert(chiave));
    print('fascicolo alla cieca: ${voci.length} voci');
  });
}
