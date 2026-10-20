// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/chat/il_filo_del_consulto.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/tarot/la_chiave_di_lettura.dart';
import 'package:esoteric_circle/core/tarot/la_lettura_dal_modello.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread_type.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:flutter_test/flutter_test.dart';

import 'la_voce_vera_di_gemini.dart';

/// **LE QUATTRO CHIAVI DI LETTURA, LETTE DAL MODELLO VERO.** Ordine FS, 13
/// ottobre 2026.
///
/// La domanda del fondatore: le quattro chiavi (Predittiva, Riflessione,
/// Esoterica, Archetipica) danno davvero interpretazioni diverse? La chiave
/// entra nell'istruzione come una riga sola, in fondo, e nessuna prova aveva
/// mai guardato una risposta vera. Due stese a tre carte con seme fisso, una
/// domanda per stesa, le quattro chiavi due volte ciascuna: sedici letture,
/// per la stessa strada dell'app (`LaLetturaDellaStesa.leggi`), ognuna come
/// una persona nuova (il filo del consulto azzerato).
///
/// Misure: Jaccard sulle parole fra due giri della stessa chiave (il rumore)
/// e fra chiavi diverse; le parole segno di ogni chiave; il testo intero
/// accostato per chiave, da leggere a mano.
///
/// ```
/// flutter test -r expanded tool/collaudo_chiavi.dart
/// ```
const stese = [
  (
    argomento: TarotTopic.lavoroTrovare,
    scritta: 'Devo accettare l\'offerta di lavoro a Milano?',
    seme: 101
  ),
  (
    argomento: TarotTopic.amoreQuadro,
    scritta: 'Questa relazione ha un futuro?',
    seme: 303
  ),
];

const giri = 2;

/// Le parole segno di ogni chiave, cercate col confine a mano: la `\b` di
/// Dart non vede le lettere accentate.
const segni = <ReadingKey, List<String>>{
  ReadingKey.esoterica: [
    'elemento',
    'pianeta',
    'segno',
    'simbolo',
    'fuoco',
    'acqua',
    'aria',
    'terra'
  ],
  ReadingKey.archetipica: ['archetipo', 'interiore', 'cammino', 'ombra'],
  ReadingKey.riflessione: ['specchio', 'ti chiedi', 'dentro di te'],
};

const _l = r'A-Za-zÀ-ÿ';

int conta(String testo, String parola) {
  // La radice con la vocale finale libera: simbolo e simboli, archetipo e
  // archetipi. Le parole di piu' termini restano intere.
  final radice = parola.contains(' ')
      ? RegExp.escape(parola)
      : '${RegExp.escape(parola.substring(0, parola.length - 1))}[aeio]?';
  return RegExp('(?<![$_l])$radice(?![$_l])', caseSensitive: false)
      .allMatches(testo)
      .length;
}

Set<String> parole(String testo) => RegExp('[$_l]+')
    .allMatches(testo.toLowerCase())
    .map((m) => m.group(0)!)
    .where((p) => p.length > 2)
    .toSet();

double jaccard(String a, String b) {
  final x = parole(a), y = parole(b);
  final u = x.union(y).length;
  return u == 0 ? 0 : x.intersection(y).length / u;
}

/// La predittiva: la prima frase della risposta dice si' o no?
bool siONoInApertura(String risposta) {
  final prima = risposta.split(RegExp(r'[.!?]')).first;
  return RegExp('(?<![$_l])(sì|no)(?![$_l])', caseSensitive: false)
      .hasMatch(prima);
}

String f(double x) => x.toStringAsFixed(3).replaceAll('.', ',');

void main() {
  test('FS: le quattro chiavi di lettura dal modello vero', () async {
    HttpOverrides.global = null;
    final voce = VoceVeraDiGemini();
    await voce.scaldaIlGettone();
    var ingresso = 0, uscita = 0, chiamateVere = 0;
    // testi[stesa][chiave][giro]
    final testi = <int, Map<ReadingKey, List<String>>>{};
    final risposte = <int, Map<ReadingKey, List<String>>>{};
    final righeChiamate = <String>[];
    final accostati = <String>[];
    var nulle = 0;

    for (var s = 0; s < stese.length; s++) {
      final d = stese[s];
      final spread = TarotSpread.draw(
          seed: d.seme, posizioni: TarotSpreadType.treCarte.posizioni);
      testi[s] = {};
      risposte[s] = {};
      accostati.add('######## STESA ${s + 1}: ${d.scritta} (seme ${d.seme}), '
          'carte: ${spread.cards.map((c) => c.displayName).join(', ')}');
      for (final k in ReadingKey.values) {
        testi[s]![k] = [];
        risposte[s]![k] = [];
        for (var g = 0; g < giri; g++) {
          IlFiloDelConsulto.dimentica();
          final cronometro = Stopwatch()..start();
          var chiamateQui = 0;
          final l = await LaLetturaDellaStesa.leggi(
            spread: spread,
            domanda: d.scritta,
            argomento: d.argomento.label,
            forma: CourtesyForm.neutral,
            chiave: k,
            chiamata: (istruzione, richiesta, campi) async {
              final e = await voce.genera(
                istruzione: istruzione,
                richiesta: richiesta,
                campi: campi.keys.toList(),
                modello: LaLetturaDellaStesa.modello,
              );
              ingresso += e.ingresso;
              uscita += e.uscita;
              chiamateVere++;
              chiamateQui++;
              return e.testo;
            },
          );
          cronometro.stop();
          if (l == null) nulle++;
          final esito = l == null
              ? 'NULL, lettura di casa (${LaLetturaDellaStesa.ultimiScarti.join(' | ')})'
              : 'del modello';
          righeChiamate.add('stesa ${s + 1}, ${k.name}, giro ${g + 1}: '
              '${(cronometro.elapsedMilliseconds / 1000).toStringAsFixed(1).replaceAll('.', ',')} s, '
              '$chiamateQui chiamate, $esito');
          print(righeChiamate.last);
          final testo = l == null
              ? ''
              : [
                  // Ordine GA: il modello scrive il solo responso principale,
                  // le carte vengono dal corpus.
                  l.risposta,
                  l.cosaFare,
                  l.titolo,
                ].join('\n');
          testi[s]![k]!.add(testo);
          risposte[s]![k]!.add(l?.risposta ?? '');
          accostati
            ..add('')
            ..add('==== ${k.label.toUpperCase()} (${k.name}), giro ${g + 1}'
                '${l == null ? ', LETTURA DI CASA' : ''}');
          if (l != null) {
            accostati
              ..add('TITOLO: ${l.titolo}')
              ..add('RISPOSTA: ${l.risposta}');
            accostati.add('COSA FARE ADESSO: ${l.cosaFare}');
          }
        }
      }
      accostati.add('');
    }

    // (a) Jaccard.
    final tabella = <String>[
      '(a) JACCARD SULLE PAROLE (parole di tre lettere o piu\'), testo intero',
      '    rumore = due giri della stessa chiave; fra chiavi = media delle '
          'quattro coppie di giri fra due chiavi diverse',
    ];
    for (var s = 0; s < stese.length; s++) {
      tabella.add('  STESA ${s + 1}: ${stese[s].scritta}');
      final rumori = <double>[];
      for (final k in ReadingKey.values) {
        final t = testi[s]![k]!;
        final r =
            (t[0].isEmpty || t[1].isEmpty) ? double.nan : jaccard(t[0], t[1]);
        rumori.add(r);
        tabella.add('    rumore ${k.name.padRight(12)} ${f(r)}');
      }
      final fra = <double>[];
      for (var i = 0; i < ReadingKey.values.length; i++) {
        for (var j = i + 1; j < ReadingKey.values.length; j++) {
          final a = testi[s]![ReadingKey.values[i]]!,
              b = testi[s]![ReadingKey.values[j]]!;
          final v = <double>[
            for (final x in a)
              for (final y in b)
                if (x.isNotEmpty && y.isNotEmpty) jaccard(x, y)
          ];
          final m =
              v.isEmpty ? double.nan : v.reduce((p, q) => p + q) / v.length;
          fra.add(m);
          tabella.add('    fra ${ReadingKey.values[i].name} e '
                      '${ReadingKey.values[j].name}'
                  .padRight(40) +
              f(m));
        }
      }
      double media(List<double> l) {
        final b = l.where((x) => !x.isNaN).toList();
        return b.isEmpty ? double.nan : b.reduce((p, q) => p + q) / b.length;
      }

      tabella.add('    MEDIA rumore ${f(media(rumori))}, MEDIA fra chiavi '
          '${f(media(fra))}');
    }

    // (b) Parole segno.
    tabella
      ..add('')
      ..add('(b) PAROLE SEGNO PER CHIAVE (occorrenze nel testo intero, '
          'somma delle due stese e dei due giri)');
    final intestazione = StringBuffer('    ${''.padRight(16)}');
    for (final k in ReadingKey.values) {
      intestazione.write(k.name.padRight(13));
    }
    tabella.add(intestazione.toString());
    for (final entry in segni.entries) {
      for (final p in entry.value) {
        final riga = StringBuffer(
            '    ${'$p (${entry.key.name.substring(0, 3)})'.padRight(16)}');
        for (final k in ReadingKey.values) {
          var n = 0;
          for (var s = 0; s < stese.length; s++) {
            for (final t in testi[s]![k]!) {
              n += conta(t, p);
            }
          }
          riga.write('$n'.padRight(13));
        }
        tabella.add(riga.toString());
      }
    }
    final rigaSiNo = StringBuffer('    ${'sì/no in apertura'.padRight(16)}');
    for (final k in ReadingKey.values) {
      var n = 0, tot = 0;
      for (var s = 0; s < stese.length; s++) {
        for (final r in risposte[s]![k]!) {
          if (r.isEmpty) continue;
          tot++;
          if (siONoInApertura(r)) n++;
        }
      }
      rigaSiNo.write('$n su $tot'.padRight(13));
    }
    tabella.add(rigaSiNo.toString());

    final costo = (ingresso * 0.30 + uscita * 2.50) / 1e6;
    final righe = <String>[
      'LE QUATTRO CHIAVI DI LETTURA DAL MODELLO, ordine FS',
      'Modello: ${LaLetturaDellaStesa.modello}, regione europe-west1, '
          '${DateTime.now().toUtc().toIso8601String()}',
      'Strada: LaLetturaDellaStesa.leggi(..., chiave: k), stesa a tre carte, '
          'forma neutra, filo del consulto azzerato prima di ogni lettura',
      '',
      'LE LETTURE (${stese.length * ReadingKey.values.length * giri}), '
          'tempo e esito',
      ...righeChiamate,
      'Letture tornate null (lettura di casa): $nulle',
      'Chiamate vere a Vertex: $chiamateVere, gettoni in ingresso $ingresso, '
          'in uscita $uscita, costo ${costo.toStringAsFixed(4).replaceAll('.', ',')} '
          'dollari al listino di Flash (0,30 e 2,50 dollari per milione)',
      '',
      ...tabella,
      '',
      '(c) I TESTI INTERI, ACCOSTATI PER CHIAVE',
      '',
      ...accostati,
    ];
    final testo = righe.join('\n');
    print(testo);
    Directory('docs/collaudo/FS').createSync(recursive: true);
    File('docs/collaudo/FS/le_chiavi_dal_modello.txt')
        .writeAsStringSync('$testo\n');
  }, timeout: const Timeout(Duration(minutes: 20)));
}
