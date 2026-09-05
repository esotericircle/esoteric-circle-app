/// IL CENSIMENTO DEL CONTRASTO, ordine P voce 14.
///
/// **Perche' nasce.** Il censimento tipografico misura le DIMENSIONI e non vede
/// questo difetto: `SOTTO_IL_PAVIMENTO: 0` resta vero mentre un testo e'
/// illeggibile. Un testo a 18 punti in oro su avorio si legge peggio di uno a 14
/// in bianco su nero, e nessuna misura di carattere lo dice.
///
/// **Cosa censisce, esattamente.** Ogni coppia INCHIOSTRO su SUPERFICIE che i
/// token dell'app possono produrre: le quattro palette dei Maestri per i loro
/// tre inchiostri e le loro tre superfici, piu' le coppie del regime chiaro. Non
/// e' un elenco scritto a mano: i colori si leggono dai file dei token, quindi
/// una tinta nuova entra nel censimento appena nasce.
///
/// **Cosa NON censisce, dichiarato.** I colori composti a runtime, per esempio
/// un accento che nasce da `AccentoDelMaestro` o un'opacita' applicata in un
/// widget, non compaiono nei file dei token e questo strumento non li vede. Per
/// quelli esiste la misura sul fotogramma vero, che campiona il fondo reso:
/// `docs/tipografia/alba_contrasto.md`. Le due misure sono complementari, e
/// dirlo qui e' cio' che impedisce di credere che questa sola basti.
///
/// **La formula e' scritta due volte, e la seconda copia e' sorvegliata.** Qui
/// non si puo' importare `AccentoDelMaestro`, perche' passa da `dart:ui` e
/// questo strumento gira sulla VM senza motore. La copia c'e', ma
/// `test/tipografia_nel_dato_test.dart` verifica che le due diano lo STESSO
/// numero: due copie che nessuno confronta divergono, due copie confrontate da
/// una prova no.
library;

import 'dart:io';

/// Un colore dichiarato in un file di token.
class ColoreDichiarato {
  const ColoreDichiarato({
    required this.nome,
    required this.file,
    required this.riga,
    required this.valore,
  });

  final String nome;
  final String file;
  final int riga;

  /// Il valore a 32 bit, alpha compreso.
  final int valore;

  int get alpha => (valore >> 24) & 0xFF;
  int get rosso => (valore >> 16) & 0xFF;
  int get verde => (valore >> 8) & 0xFF;
  int get blu => valore & 0xFF;

  /// Vero se il colore e' pieno. I colori con alpha non sono ne' inchiostri ne'
  /// superfici finche' non si sa cosa hanno sotto, e cosa hanno sotto lo sa
  /// solo il fotogramma.
  bool get opaco => alpha == 0xFF;

  @override
  String toString() => '$nome ($file:$riga)';
}

/// Una coppia censita: un inchiostro su una superficie, col suo contrasto.
class CoppiaCensita {
  const CoppiaCensita({
    required this.inchiostro,
    required this.superficie,
    required this.contrasto,
    required this.soglia,
  });

  final ColoreDichiarato inchiostro;
  final ColoreDichiarato superficie;
  final double contrasto;
  final double soglia;

  bool get passa => contrasto >= soglia;
}

/// LA SOGLIA DI LETTURA, dalle WCAG. E' la stessa di `RegimeChiaro`.
const double sogliaDiLettura = 4.5;

/// La luminanza relativa di un colore a otto bit per canale, formula WCAG.
double luminanzaRelativa(int r, int g, int b) {
  double canale(int v) {
    final f = v / 255;
    if (f <= 0.03928) return f / 12.92;
    // La potenza 2,4 senza dart:math: si fa con l'esponenziale in serie.
    return _potenza((f + 0.055) / 1.055, 2.4);
  }

  return 0.2126 * canale(r) + 0.7152 * canale(g) + 0.0722 * canale(b);
}

/// [base] elevato a [esponente], per basi positive.
///
/// Scritta a mano perche' `dart:math` c'e', ma tenerla qui accanto alla formula
/// rende leggibile in un punto solo tutto cio' che il censimento calcola.
double _potenza(double base, double esponente) {
  if (base <= 0) return 0;
  // e^(esponente * ln(base)), con le due serie classiche.
  return _esponenziale(esponente * _logaritmo(base));
}

double _logaritmo(double x) {
  // Si porta x vicino a uno raddoppiando o dimezzando, poi la serie di atanh.
  var n = 0;
  var v = x;
  while (v > 1.5) {
    v /= 2;
    n++;
  }
  while (v < 0.6666666666666666) {
    v *= 2;
    n--;
  }
  final z = (v - 1) / (v + 1);
  final z2 = z * z;
  var somma = 0.0;
  var termine = z;
  for (var k = 1; k <= 25; k += 2) {
    somma += termine / k;
    termine *= z2;
  }
  return 2 * somma + n * 0.6931471805599453;
}

double _esponenziale(double x) {
  var somma = 1.0;
  var termine = 1.0;
  for (var k = 1; k <= 40; k++) {
    termine *= x / k;
    somma += termine;
  }
  return somma;
}

/// Il rapporto di contrasto fra due colori pieni.
double contrastoFra(ColoreDichiarato a, ColoreDichiarato b) {
  final la = luminanzaRelativa(a.rosso, a.verde, a.blu);
  final lb = luminanzaRelativa(b.rosso, b.verde, b.blu);
  final chiaro = la > lb ? la : lb;
  final scuro = la > lb ? lb : la;
  return (chiaro + 0.05) / (scuro + 0.05);
}

/// I file dei token da cui si leggono i colori.
const List<String> fileDeiToken = [
  'lib/design_system/tokens/color_tokens.dart',
  'lib/design_system/tokens/regime_chiaro.dart',
];

/// Legge tutti i colori dichiarati nei file dei token.
List<ColoreDichiarato> coloriDichiarati() {
  final trovati = <ColoreDichiarato>[];
  final forma = RegExp(
      r'Color\s+(\w+)\s*=\s*(?:const\s+)?Color\(0x([0-9A-Fa-f]{8})\)');
  for (final file in fileDeiToken) {
    final f = File(file);
    if (!f.existsSync()) continue;
    final righe = f.readAsLinesSync();
    for (var i = 0; i < righe.length; i++) {
      final m = forma.firstMatch(righe[i]);
      if (m == null) continue;
      trovati.add(ColoreDichiarato(
        nome: m.group(1)!,
        file: file,
        riga: i + 1,
        valore: int.parse(m.group(2)!, radix: 16),
      ));
    }
  }
  return trovati;
}

/// Chi e' un inchiostro e chi e' una superficie, dal nome del token.
///
/// I nomi di questa app dicono il ruolo: `text...`, `testo...`, `gold...` sono
/// inchiostri; `...Deepest`, `...Deep`, `...Surface`, `superficie...` sono
/// superfici. Dedurlo dal nome invece di elencarli a mano vuol dire che un
/// token nuovo entra nel censimento senza che nessuno se ne ricordi.
bool eInchiostro(String nome) =>
    nome.startsWith('text') ||
    nome.startsWith('testo') ||
    nome.startsWith('gold');

/// **UN INCHIOSTRO NON E' MAI UNA SUPERFICIE**, e la prima stesura lo
/// dimenticava: `goldDeep` contiene `Deep`, quindi finiva fra le superfici e il
/// censimento produceva la coppia `goldDeep` su `goldDeep`, contrasto 1,00. Una
/// coppia che non esiste non e' un difetto trovato, e' rumore che gonfia il
/// numero e lo rende inservibile come cricchetto.
bool eSuperficie(String nome) =>
    !eInchiostro(nome) &&
    (nome.contains('Deepest') ||
        nome.contains('Deep') ||
        nome.contains('Surface') ||
        nome.startsWith('superficie') ||
        nome.startsWith('vetro'));

/// La famiglia cromatica di un token: il regime scuro, quello chiaro, il comune.
///
/// **I nomi dicono gia' il regime.** Gli inchiostri del regime scuro si chiamano
/// all'inglese, `textPrimary`, `textSecondary`, `textMuted`, perche' vengono dai
/// primitivi; quelli del regime chiaro si chiamano in italiano, `testoSuChiaro`
/// e `testoMutoSuChiaro`, perche' sono nati con l'ordine P. L'oro e' comune al
/// buio e, sul chiaro, non e' colore di testo per la voce 13.
String famigliaDi(String nome) {
  final basso = nome.toLowerCase();
  if (basso.startsWith('testo') ||
      basso.startsWith('superficie') ||
      basso.startsWith('vetro')) {
    return 'chiaro';
  }
  if (basso.startsWith('text')) return 'scuro';
  for (final f in const ['medora', 'aura', 'caligo', 'neutral']) {
    if (basso.startsWith(f)) return 'scuro';
  }
  return 'comune';
}

/// Il censimento: ogni coppia inchiostro su superficie che i token producono.
List<CoppiaCensita> censisciIlContrasto() {
  final colori = coloriDichiarati().where((c) => c.opaco).toList();
  final inchiostri = colori.where((c) => eInchiostro(c.nome)).toList();
  final superfici = colori.where((c) => eSuperficie(c.nome)).toList();
  final coppie = <CoppiaCensita>[];
  for (final superficie in superfici) {
    final famiglia = famigliaDi(superficie.nome);
    for (final inchiostro in inchiostri) {
      final sua = famigliaDi(inchiostro.nome);
      // Su una superficie chiara vanno solo gli inchiostri del regime chiaro:
      // l'oro sul chiaro non e' colore di testo, voce 13, e gli inchiostri del
      // buio li' non compaiono mai.
      if (famiglia == 'chiaro' && sua != 'chiaro') continue;
      // Su una superficie scura non va l'inchiostro nato per il chiaro.
      if (famiglia != 'chiaro' && sua == 'chiaro') continue;
      coppie.add(CoppiaCensita(
        inchiostro: inchiostro,
        superficie: superficie,
        contrasto: contrastoFra(inchiostro, superficie),
        soglia: sogliaDiLettura,
      ));
    }
  }
  coppie.sort((a, b) => a.contrasto.compareTo(b.contrasto));
  return coppie;
}

/// Il documento del censimento.
const String documento = 'docs/tipografia/contrasto.md';

/// I due numeri registrati nel documento.
({int censite, int sotto}) numeriDelContrasto() {
  final testo = File(documento).readAsStringSync();
  int marca(String nome) {
    final m = RegExp('$nome:\\s*(\\d+)').firstMatch(testo);
    if (m == null) {
      throw StateError('$documento non porta il marcatore $nome');
    }
    return int.parse(m.group(1)!);
  }

  return (censite: marca('COPPIE_CENSITE'), sotto: marca('SOTTO_IL_CONTRASTO'));
}

void main() {
  final coppie = censisciIlContrasto();
  final sotto = coppie.where((c) => !c.passa).toList();

  final righe = <String>[
    '# Il censimento del contrasto',
    '',
    '<!-- COPPIE_CENSITE: ${coppie.length} -->',
    '<!-- SOTTO_IL_CONTRASTO: ${sotto.length} -->',
    '<!-- Generato da tool/censimento_contrasto.dart. Non si scrive a mano: '
        'si rigenera. -->',
    '',
    'Ordine P voce 14. Il censimento tipografico misura le DIMENSIONI e non '
        'vede questo difetto: `SOTTO_IL_PAVIMENTO: 0` resta vero mentre un '
        'testo e\' illeggibile. Un testo a 18 punti in oro su avorio si legge '
        'peggio di uno a 14 in bianco su nero.',
    '',
    'Il numero `SOTTO_IL_CONTRASTO` puo\' solo SCENDERE: '
        '`test/tipografia_nel_dato_test.dart` lo rilegge da qui e cade se '
        'cresce. Stessa logica a cricchetto degli altri censimenti.',
    '',
    '## Cosa entra nel conto, e cosa no',
    '',
    'Entra ogni coppia INCHIOSTRO su SUPERFICIE che i token possono produrre, '
        'letta dai file dei token e non da un elenco scritto a mano: '
        '${fileDeiToken.join(', ')}. Un inchiostro si misura sulle superfici '
        'della sua famiglia cromatica, perche\' il blu di Medora non compare '
        'mai sotto il rosso di Caligo.',
    '',
    '**NON entra cio\' che nasce a runtime**: un accento composto da '
        '`AccentoDelMaestro`, un\'opacita\' applicata dentro un widget, un '
        'vetro semitrasparente sopra una fotografia. Quei colori non stanno nei '
        'token e nessuna lettura statica li vede. Per loro esiste la misura sul '
        'fotogramma vero, `docs/tipografia/alba_contrasto.md`, che campiona il '
        'fondo RESO. Le due misure sono complementari, e credere che questa '
        'sola basti sarebbe il difetto di prima con un documento in piu\'.',
    '',
    '## I due numeri',
    '',
    '| Grandezza | Valore |',
    '| --- | ---: |',
    '| Coppie censite | **${coppie.length}** |',
    '| Sotto ${sogliaDiLettura.toStringAsFixed(1)} a 1 | **${sotto.length}** |',
    '',
    '## Le coppie, dalla peggiore alla migliore',
    '',
    '| Inchiostro | Superficie | Contrasto | Passa |',
    '| --- | --- | ---: | --- |',
    for (final c in coppie)
      '| `${c.inchiostro.nome}` | `${c.superficie.nome}` | '
          '${c.contrasto.toStringAsFixed(2)} | ${c.passa ? 'si\'' : '**NO**'} |',
    '',
  ];

  File(documento).writeAsStringSync(righe.join('\n'));
  stdout.writeln('COPPIE_CENSITE: ${coppie.length}');
  stdout.writeln('SOTTO_IL_CONTRASTO: ${sotto.length}');
}
