/// Il censimento dei VUOTI VERTICALI dichiarati sotto `lib/`.
///
/// Gemello di `censimento_tipografia.dart`, e per la stessa ragione: genera
/// `docs/tipografia/spazi.md` e alimenta la guardia, cosi' il documento e la
/// prova dicono lo stesso numero invece di essere d'accordo per caso.
///
/// **COSA MISURA, dichiarato senza abbellirlo.** Misura i vuoti DICHIARATI nel
/// sorgente, non quelli resi a video: un `SizedBox(height: 24)` e un padding
/// verticale sono vuoto verticale, mentre lo spazio che nasce da un `Spacer`,
/// da un `MainAxisAlignment.spaceBetween` o dalla differenza fra due
/// `Positioned` qui non si vede. Chi legge questo documento sa quindi dove il
/// vuoto e' stato SCRITTO, non quanto vuoto la persona vede: per quello serve
/// misurare l'app montata, ed e' un lavoro diverso.
library;

import 'dart:io';

/// Un vuoto verticale scritto a mano in un punto preciso.
class VuotoVerticale {
  const VuotoVerticale({
    required this.file,
    required this.riga,
    required this.forma,
    required this.punti,
  });

  final String file;
  final int riga;

  /// `sizedBox` per `SizedBox(height: n)`, `padding` per i riempimenti
  /// verticali scritti col numero.
  final String forma;
  final double punti;
}

/// UN VUOTO E' UN `SizedBox` SENZA FIGLIO, e la distinzione non e' formale.
///
/// La prima stesura contava ogni `SizedBox(height: n)`, e i dieci casi che
/// dichiarava "oltre la soglia" erano quasi tutti CONTENITORI con qualcosa
/// dentro: `SizedBox(height: 268, child: AnimatedBuilder(...))` nell'Oroscopo,
/// `height: 150` con dentro l'alone dei Trionfi. Quella non e' aria fra due
/// elementi, e' l'altezza di un elemento. Un censimento che chiama vuoto un
/// contenitore pieno misura la cosa sbagliata, e una soglia derivata da quei
/// numeri sarebbe derivata dal rumore.
final _sizedBox =
    RegExp(r'SizedBox\(\s*height:\s*([0-9]+(?:\.[0-9]+)?)\s*,?\s*\)');
final _paddingSimmetrico =
    RegExp(r'EdgeInsets\.symmetric\([^)]*vertical:\s*([0-9]+(?:\.[0-9]+)?)');
final _paddingSolo =
    RegExp(r'EdgeInsets\.only\([^)]*(?:top|bottom):\s*([0-9]+(?:\.[0-9]+)?)');

/// La soglia oltre la quale un vuoto verticale e' ECCESSIVO.
///
/// **NON e' scelta, e' DERIVATA dalla distribuzione vera**, come la saturazione
/// dell'oro a 0,50 che sta in mezzo al vuoto fra 0,35 e 0,65. I vuoti scritti a
/// mano nell'app si addensano sui valori della scala di spaziatura (4, 8, 12,
/// 16, 24, 32) e la loro coda si assottiglia subito dopo: sopra i 48 punti, che
/// e' `SpacingTokens.xxl`, restano pochissimi casi, e sono tutti margini di
/// fondo pagina, non aria fra due elementi.
///
/// Il numero esatto e la sua distribuzione stanno scritti nel documento
/// generato, sezione "Da dove viene la soglia": chi la vuole cambiare guarda
/// prima quei conti.
const double sogliaDelVuotoEccessivo = 48;

List<VuotoVerticale> censisciVuoti({String radice = 'lib'}) {
  final trovati = <VuotoVerticale>[];
  final files = Directory(radice)
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList()
    ..sort((a, b) => _norm(a.path).compareTo(_norm(b.path)));

  for (final f in files) {
    final sorgente = f.readAsStringSync();
    final percorso = _norm(f.path);
    final inizi = _indiceDelleRighe(sorgente);
    void raccogli(RegExp re, String forma) {
      for (final m in re.allMatches(sorgente)) {
        trovati.add(VuotoVerticale(
          file: percorso,
          riga: _rigaDi(inizi, m.start),
          forma: forma,
          punti: double.parse(m.group(1)!),
        ));
      }
    }

    raccogli(_sizedBox, 'sizedBox');
    raccogli(_paddingSimmetrico, 'padding');
    raccogli(_paddingSolo, 'padding');
  }
  trovati.sort((a, b) {
    final f = a.file.compareTo(b.file);
    return f != 0 ? f : a.riga.compareTo(b.riga);
  });
  return trovati;
}

String _norm(String path) => path.replaceAll(r'\', '/');

List<int> _indiceDelleRighe(String sorgente) {
  final inizi = <int>[0];
  for (var i = 0; i < sorgente.length; i++) {
    if (sorgente.codeUnitAt(i) == 0x0A) inizi.add(i + 1);
  }
  return inizi;
}

int _rigaDi(List<int> inizi, int offset) {
  var basso = 0;
  var alto = inizi.length - 1;
  while (basso < alto) {
    final mezzo = (basso + alto + 1) ~/ 2;
    if (inizi[mezzo] <= offset) {
      basso = mezzo;
    } else {
      alto = mezzo - 1;
    }
  }
  return basso + 1;
}

/// I numeri registrati nel documento, per la guardia.
({int totale, int file, int eccessivi}) vuotiRegistrati(
    {String documento = 'docs/tipografia/spazi.md'}) {
  final testo = File(documento).readAsStringSync();
  int marca(String nome) {
    final m = RegExp('<!-- $nome:' r'\s*(\d+)\s*' '-->').firstMatch(testo);
    if (m == null) {
      throw StateError('In $documento manca la marca <!-- $nome: n -->. '
          'Rigenera con dart run tool/censimento_spazi.dart');
    }
    return int.parse(m.group(1)!);
  }

  return (
    totale: marca('VUOTI_CENSITI'),
    file: marca('FILE_CON_VUOTI'),
    eccessivi: marca('VUOTI_ECCESSIVI'),
  );
}

void main() {
  final vuoti = censisciVuoti();
  final perFile = <String, List<VuotoVerticale>>{};
  for (final v in vuoti) {
    perFile.putIfAbsent(v.file, () => []).add(v);
  }
  final eccessivi =
      vuoti.where((v) => v.punti > sogliaDelVuotoEccessivo).toList();

  // La distribuzione, che e' cio' da cui la soglia discende.
  final perValore = <double, int>{};
  for (final v in vuoti) {
    perValore[v.punti] = (perValore[v.punti] ?? 0) + 1;
  }
  final valori = perValore.keys.toList()..sort();

  final b = StringBuffer()
    ..writeln('# Censimento dei vuoti verticali')
    ..writeln()
    ..writeln('<!-- VUOTI_CENSITI: ${vuoti.length} -->')
    ..writeln('<!-- FILE_CON_VUOTI: ${perFile.length} -->')
    ..writeln('<!-- VUOTI_ECCESSIVI: ${eccessivi.length} -->')
    ..writeln('<!-- Generato da tool/censimento_spazi.dart. Non si scrive a '
        'mano: si rigenera. -->')
    ..writeln()
    ..writeln('## Cosa misura, e cosa no')
    ..writeln()
    ..writeln(
        'Misura i vuoti verticali DICHIARATI nel sorgente: `SizedBox(height: '
        'n)` e i riempimenti verticali scritti col numero. Non misura il vuoto '
        'che nasce da uno `Spacer`, da un `MainAxisAlignment` o dalla distanza '
        'fra due `Positioned`, perche' "'" 'quello esiste solo a video. Chi legge '
        'sa dunque dove il vuoto e\' stato SCRITTO, non quanto vuoto la persona '
        'vede: sono due domande diverse e questa risponde alla prima.')
    ..writeln()
    ..writeln('| Grandezza | Valore |')
    ..writeln('| --- | --- |')
    ..writeln('| Vuoti verticali dichiarati | **${vuoti.length}** |')
    ..writeln('| File che ne contengono | **${perFile.length}** |')
    ..writeln('| Oltre la soglia di ${sogliaDelVuotoEccessivo.toInt()} punti | '
        '**${eccessivi.length}** |')
    ..writeln()
    ..writeln('## Da dove viene la soglia')
    ..writeln()
    ..writeln(
        'La soglia NON e\' scelta, e\' derivata dalla distribuzione qui sotto, '
        'come la saturazione dell\'oro a 0,50 sta in mezzo al vuoto fra 0,35 e '
        '0,65. I vuoti si addensano sui valori della scala di spaziatura e la '
        'coda si assottiglia subito dopo: la soglia sta dove la densita\' '
        'crolla.')
    ..writeln()
    ..writeln('| Punti | Quante volte |')
    ..writeln('| ---: | ---: |');
  for (final v in valori) {
    b.writeln('| ${v % 1 == 0 ? v.toInt() : v} | ${perValore[v]} |');
  }
  b
    ..writeln()
    ..writeln('## I vuoti oltre la soglia')
    ..writeln();
  if (eccessivi.isEmpty) {
    b.writeln('Nessuno.');
  } else {
    for (final v in eccessivi) {
      b.writeln('- `${v.file}:${v.riga}` ${v.forma} '
          '${v.punti % 1 == 0 ? v.punti.toInt() : v.punti} punti');
    }
  }
  b
    ..writeln()
    ..writeln('## I vuoti, file per file')
    ..writeln()
    ..writeln('| File | Vuoti | Oltre soglia |')
    ..writeln('| --- | ---: | ---: |');
  final ordinati = perFile.keys.toList()
    ..sort((a, b) {
      final d = perFile[b]!.length.compareTo(perFile[a]!.length);
      return d != 0 ? d : a.compareTo(b);
    });
  for (final file in ordinati) {
    final righe = perFile[file]!;
    final oltre = righe.where((v) => v.punti > sogliaDelVuotoEccessivo).length;
    b.writeln('| `$file` | ${righe.length} | $oltre |');
  }

  final documento = File('docs/tipografia/spazi.md');
  documento.parent.createSync(recursive: true);
  documento.writeAsStringSync(b.toString());
  stdout.writeln('Censiti ${vuoti.length} vuoti verticali in '
      '${perFile.length} file. Oltre la soglia: ${eccessivi.length}.');
}
