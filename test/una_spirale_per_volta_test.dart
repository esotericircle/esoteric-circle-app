import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// UNA SPIRALE PER VOLTA. Ordine AV voce 01.
///
/// **Riscritta sulla nuova animazione.** Sorvegliava il lettore di WebP
/// dell'ordine AT, che e' uscito di scena; cio' che sorveglia non e' cambiato:
/// **due animazioni a schermo pieno nello stesso istante sono illeggibili**, e
/// il premio di entrambe si perde.
void main() {
  test('un solo punto in tutto lib monta la spirale', () {
    var punti = 0;
    final dove = <String>[];
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final nome = f.path.split(Platform.pathSeparator).last;
      if (nome == 'spirale_di_stelle.dart') continue;
      final quante =
          RegExp(r'SpiraleDiStelle\(').allMatches(f.readAsStringSync()).length;
      if (quante > 0) {
        punti += quante;
        dove.add('$nome ($quante)');
      }
    }
    // ignore: avoid_print
    print('ORDINE AV VOCE 01: la spirale si monta in $punti punti di lib: '
        '$dove');
    expect(punti, 1,
        reason: 'la spirale si monta in $punti punti: $dove. Due animazioni a '
            'schermo pieno nello stesso istante sono illeggibili');
  });

  test('nessun filtro e nessuno shader per fotogramma', () {
    // **IL VINCOLO TECNICO DELL'ORDINE, sorvegliato alla sorgente.** Niente
    // MaskFilter, niente sfocature, niente BlendMode.plus, niente shader: su
    // Impeller un filtro per fotogramma e' il modo piu' rapido di far cadere il
    // conto sotto i sessanta.
    // **SI GUARDA IL CODICE, NON I COMMENTI.** Il file NOMINA i filtri
    // vietati per spiegare perche' non li usa, e una guardia che cerca la
    // parola nel testo intero e' rossa per il proprio commento: e' un
    // inciampo in cui questo repo e' gia' caduto due volte.
    final spirale = File('lib/features/sigilli/spirale_di_stelle.dart')
        .readAsLinesSync()
        .where((r) {
      final pulita = r.trimLeft();
      return !pulita.startsWith('//') && !pulita.startsWith('///');
    }).join(String.fromCharCode(10));

    for (final vietato in const [
      'MaskFilter',
      'ImageFilter',
      'BlendMode.plus',
      'Shader',
      'blur',
    ]) {
      expect(spirale.contains(vietato), isFalse,
          reason: 'la spirale usa "$vietato": e un filtro per fotogramma, e '
              'l ordine lo vieta');
    }
  });

  test('i filmati sono spariti per intero', () {
    // **LA DEMOLIZIONE SI CONTA, non si dichiara.** Ordine AV voce 01.
    expect(Directory('assets/transizioni').existsSync(), isFalse,
        reason: 'la cartella dei filmati esiste ancora');
    expect(File('lib/features/sigilli/transizione_di_stelle.dart').existsSync(),
        isFalse,
        reason: 'il lettore di WebP esiste ancora');
    expect(File('pubspec.yaml').readAsStringSync().contains('transizioni'),
        isFalse,
        reason: 'pubspec.yaml dichiara ancora i filmati fra gli asset');
    var richiami = 0;
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      if (f.readAsStringSync().contains('TransizioneDiStelle')) richiami++;
    }
    expect(richiami, 0,
        reason: 'restano $richiami richiami al lettore di WebP in lib');
    // **E LA RIGA IN .gitignore RESTA**: i sorgenti del fondatore stanno sul
    // suo disco e fuori dal repository, come l'ordine chiede.
    expect(
        File('.gitignore').readAsStringSync().contains('transition/'), isTrue,
        reason: 'la riga transition/ e sparita da .gitignore: i sorgenti del '
            'fondatore tornerebbero dentro il repository');
  });
}
