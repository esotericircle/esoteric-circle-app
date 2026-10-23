import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'codice_senza_testo.dart';
import 'sorgenti_di_lib.dart';

/// NEL REAL TIME COSMO C'E' UN TEMPO SOLO. Aggiunta della Macchina del tempo
/// all'ordine FH, voce C2, scritta come `una_luna_sola`.
///
/// **Il dato che fa nascere questa guardia.** La misura A8 dell'aggiunta ha
/// contato 163 letture di `DateTime.now` in lib. Dentro il Real Time Cosmo
/// ce n'era una sola, nella schermata, e da quella dipendevano il cielo di
/// adesso, la partenza del ritorno e la riga della Luna. Con la Macchina del
/// tempo l'istante mostrato puo' essere il 1900 o il 2100: se un secondo
/// disegno chiedesse l'ora al sistema per conto suo, quel disegno starebbe
/// nel 2026 mentre il cielo sta altrove, e la data arriverebbe da due strade.
///
/// **La regola.** Dentro le cartelle del Real Time Cosmo, schermate e motore,
/// solo `il_tempo_del_cosmo.dart` legge l'orologio di sistema; gli altri
/// chiedono a lui. I commenti e le stringhe non contano: una riga che spiega
/// la regola non la viola.
const _cartelle = [
  'lib/features/real_time_cosmo',
  'lib/core/astro/real_time_cosmo',
];

/// L'unico file autorizzato a leggere l'orologio di sistema.
const _ilTempo = 'lib/features/real_time_cosmo/il_tempo_del_cosmo.dart';

/// Ogni lettura dell'orologio, chiamata o passata come funzione.
final _orologio = RegExp(r'DateTime\s*\.\s*now\b');

/// I file che leggono l'orologio fuori dal tempo del cosmo: "file, riga".
List<String> letturePerdute(Map<String, String> sorgenti) {
  final colpe = <String>[];
  sorgenti.forEach((percorso, sorgente) {
    if (percorso == _ilTempo) return;
    final righe = codiceSenzaTesto(sorgente).split('\n');
    for (var i = 0; i < righe.length; i++) {
      if (_orologio.hasMatch(righe[i])) colpe.add('$percorso riga ${i + 1}');
    }
  });
  return colpe;
}

void main() {
  test('nel Real Time Cosmo solo il tempo del cosmo legge l\'orologio', () {
    final file = sorgentiDiCartelle(_cartelle, minimo: 20);
    final sorgenti = {
      for (final f in file)
        f.path.replaceAll(Platform.pathSeparator, '/'): f.readAsStringSync(),
    };
    expect(sorgenti.containsKey(_ilTempo), isTrue,
        reason: 'il tempo del cosmo non sta piu\' in $_ilTempo');
    // Il tempo del cosmo legge davvero l'orologio: se smettesse, l'adesso
    // arriverebbe da un'altra strada e questa guardia non lo vedrebbe.
    expect(_orologio.hasMatch(codiceSenzaTesto(sorgenti[_ilTempo]!)), isTrue);
    final colpe = letturePerdute(sorgenti);
    // ignore: avoid_print
    print('UN SOLO TEMPO: file guardati ${sorgenti.length}, letture '
        'dell\'orologio fuori dal tempo del cosmo ${colpe.length}');
    expect(colpe, isEmpty,
        reason: 'Leggono l\'orologio di sistema fuori da IlTempoDelCosmo:\n'
            '${colpe.join('\n')}\nSi chiede a IlTempoDelCosmo.adesso().');
  });
}
