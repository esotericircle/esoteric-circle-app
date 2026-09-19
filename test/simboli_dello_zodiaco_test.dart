import 'dart:io';

import 'package:esoteric_circle/core/astro/simboli_dello_zodiaco.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:flutter_test/flutter_test.dart';

/// UN SIMBOLO DELLO ZODIACO SIGNIFICA IL SUO SEGNO, e nient'altro.
///
/// **Il dato.** Nell'intestazione della chat c'era un'icona a bilancia, dorata.
/// Chi l'ha disegnata intendeva "metti a confronto"; il fondatore, che e' la
/// persona piu' esperta del dominio in questo progetto, ci ha letto **il segno
/// della Bilancia**. Tolta di li', era rimasta sulla card della Sintesi
/// comparativa con la motivazione che in quel contesto significa confronto.
///
/// **Il significato di un simbolo non lo decide il contesto nella testa di chi
/// disegna, lo decide l'occhio di chi guarda.** Questa prova esiste perche'
/// quella stessa icona non rinasca fra un mese in un terzo posto.
void main() {
  /// Tutti i sorgenti di `lib`, che e' cio' che arriva a video.
  List<File> sorgentiDiLib() => Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  String percorso(File f) => f.path.replaceAll(r'\', '/');

  /// Le righe di codice, senza i commenti: un simbolo NOMINATO in un commento
  /// che spiega perche' non si usa non e' un uso, ed e' anzi il posto giusto
  /// dove nominarlo.
  String codiceDi(File f) => f
      .readAsLinesSync()
      .where((r) => !r.trimLeft().startsWith('//'))
      .where((r) => !r.trimLeft().startsWith('///'))
      .join('\n');

  test('Nessuna icona di sistema che l\'occhio legge come un segno', () {
    // ENUMERATA sull'elenco, non cercata a campione: la bilancia e' quella che
    // il fondatore ha visto, ma la regola vale per tutte quelle che le
    // somigliano, altrimenti si sposta di una sola icona e ricomincia.
    final colpe = <String>[];
    for (final file in sorgentiDiLib()) {
      final p = percorso(file);
      // Il file che DICHIARA la regola nomina per forza le icone che vieta.
      if (p.endsWith('lib/core/astro/simboli_dello_zodiaco.dart')) continue;
      final codice = codiceDi(file);
      for (final voce in SimboliDelloZodiaco.iconeCheSembranoUnSegno.entries) {
        if (codice.contains(voce.key)) {
          colpe.add('$p usa ${voce.key}, che l\'occhio legge come '
              '${voce.value}');
        }
      }
    }
    expect(
      colpe,
      isEmpty,
      reason: 'l\'app ha l\'arte VERA per ogni segno, quindi non ha nessun '
          'motivo di dire un segno con un\'icona di sistema: se una compare, '
          'o sta dicendo un segno nel modo sbagliato, oppure sta dicendo '
          'un\'altra cosa con la faccia di un segno.\n${colpe.join('\n')}',
    );
  });

  test('I dodici glifi vivono SOLO dove sono dichiarati', () {
    // Enumerati da `Zodiac.values`, non riscritti: se domani un glifo cambia,
    // la regola lo segue da sola.
    expect(SimboliDelloZodiaco.glifi.length, Zodiac.values.length);
    expect(SimboliDelloZodiaco.glifi, contains('♎'),
        reason: 'la Bilancia e\' il segno da cui nasce tutta questa regola');

    final colpe = <String>[];
    for (final file in sorgentiDiLib()) {
      final p = percorso(file);
      if (p.endsWith(SimboliDelloZodiaco.casaDeiGlifi)) continue;
      if (p.endsWith('lib/core/astro/simboli_dello_zodiaco.dart')) continue;
      final codice = codiceDi(file);
      for (final glifo in SimboliDelloZodiaco.glifi) {
        if (codice.contains(glifo)) colpe.add('$p scrive $glifo');
      }
    }
    expect(
      colpe,
      isEmpty,
      reason: 'un glifo dello zodiaco scritto fuori dal file che lo dichiara '
          'vuol dire due cose: o e\' una copia del dato, e allora divergerà, '
          'oppure sta significando qualcos\'altro.\n${colpe.join('\n')}',
    );
  });

  test('La card della sintesi porta i TRE VOLTI', () {
    // Il controllo positivo: senza, la prova direbbe solo che la bilancia non
    // c'e', e resterebbe verde anche se al suo posto non ci fosse niente.
    final card = File('lib/features/maestri/ask/ask_maestri_screen.dart')
        .readAsStringSync();
    expect(card.contains('TreVolti('), isTrue,
        reason: 'tolto il simbolo sbagliato, al suo posto ci vuole quello '
            'giusto: piu\' voci, con arte che esiste già');
  });
}
