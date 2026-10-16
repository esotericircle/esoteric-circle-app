import 'dart:io';

import 'package:esoteric_circle/core/angels/angel_lore.dart';
import 'package:flutter_test/flutter_test.dart';

/// **QUELLO CHE IL TOOLTIP DEGLI ANGELI DICHIARA DEVE ESSERE VERO.**
/// Ordine CS voci 01 e 02, 6 settembre 2026.
///
/// **Parole del fondatore**, dopo aver letto che le tavole originali non erano
/// state consultate in edizione primaria: *"bisogna riparare, confessare che
/// siamo onesti, in verita' comunica che siamo stati superficiali! e questo non
/// va bene per qualunque funzionalita' e dovrebbe essere LA BASE DI QUESTA
/// APP"*.
///
/// **IL DIVIETO CHE QUESTA GUARDIA FA RISPETTARE.** La voce CS.02 dice: *"non
/// si toglie quella riga senza aver fatto la verifica. Togliere la
/// dichiarazione senza fare il lavoro trasforma un'ammissione onesta in una
/// bugia, che e' molto peggio di cio' da cui si parte"*.
///
/// Il testo a video adesso dichiara che la stampa del 1823 e' stata
/// confrontata. **Se qualcuno cancellasse il documento della verifica e
/// lasciasse la frase, l'app direbbe il falso**, e nessuna prova se ne
/// accorgerebbe. Questa guardia lega le due cose.
void main() {
  final schermata =
      File('lib/features/angels/angels_screen.dart').readAsStringSync();

  test('se il testo dichiara la verifica, il documento deve esistere', () {
    final dichiara = schermata.contains('confrontate con la stampa originale');
    if (!dichiara) {
      // Nessuna dichiarazione, nessun debito: la guardia non ha niente da
      // pretendere. Ma lo si dice, invece di passare in silenzio.
      // ignore: avoid_print
      print('il testo a video non dichiara nessuna verifica sulla fonte');
      return;
    }
    final documento = File('docs/angeli_verifica_lenain.md');
    expect(documento.existsSync(), isTrue,
        reason: 'il tooltip dichiara che la stampa del 1823 e\' stata '
            'confrontata, e il documento della verifica non esiste: l\'app '
            'sta dicendo il falso a chi legge');
    final testo = documento.readAsStringSync();
    expect(testo.length, greaterThan(2000),
        reason: 'il documento della verifica esiste ma e\' troppo corto per '
            'contenere un confronto su settantadue voci');
    for (final atteso in ['Lenain', '1823', 'iapsop', 'Ambelain']) {
      expect(testo, contains(atteso),
          reason: 'il documento della verifica non nomina «$atteso»: non '
              'dice quale fonte e\' stata consultata');
    }
  });

  test('la nota nomina le fonti e NON si scusa', () {
    if (!schermata.contains('angeli_nota_edizioni')) return;
    // **LA REGOLA E\' DEL FONDATORE, e vale per ogni nota di fonte.**
    //
    // Parole sue sulla stesura precedente: *"il testo deve essere positivo
    // e senza dubbi o scuse o confessioni"*, e *"spingerei altri
    // all'approfondimento, anziche' farlo io"*.
    //
    // Una nota che elenca cio' che non ha verificato sposta il lavoro su
    // chi legge. Il metodo e i suoi limiti stanno nel documento della
    // verifica, che e' il posto giusto per loro.
    final nota = schermata.substring(
        schermata.indexOf('angeli_nota_edizioni'));
    final finestra = nota.substring(0, 700);
    for (final scusa in <String>[
      'seconda mano',
      'non e\' stato consultat',
      'edizione primaria',
      'non e\' leggibile',
      'pubblico dominio',
      'repertori',
      'non verificat',
    ]) {
      expect(finestra.contains(scusa), isFalse,
          reason: 'la nota delle fonti contiene «$scusa»: e\' una scusa, '
              'e una nota che si scusa manda chi legge a controllare da '
              'sola');
    }
    // E le fonti si nominano tutte e due, altrimenti la nota afferma
    // senza dire su cosa.
    for (final fonte in ['Lenain', '1823', 'Ambelain']) {
      expect(finestra, contains(fonte),
          reason: 'la nota non nomina «$fonte»');
    }
  });

  test('il corpus non contraddice il testo a video', () {
    final corpus = File('docs/corpus/angeli.md').readAsStringSync();
    expect(corpus, isNot(contains('non sono risultate consultabili '
        'integralmente in rete')),
        reason: 'il corpus dichiara ancora che le tavole di Lenain non sono '
            'consultabili, mentre il tooltip dice che sono state '
            'confrontate: due documenti dell\'app dicono cose opposte');
  });

  test('i settantadue portano tutti nome, gradi, segno e salmo', () {
    // La verifica ha senso solo se i campi ci sono. Un corpus con dei vuoti
    // renderebbe la dichiarazione a video vera a meta'.
    expect(kAngelLore.length, 72,
        reason: 'il corpus non porta settantadue voci');
    for (final a in kAngelLore.values) {
      for (final campo in <String, String>{
        'nome': a.name,
        'gradi': a.degrees,
        'segno': a.sign,
        'salmo': a.psalm,
      }.entries) {
        expect(campo.value.trim(), isNotEmpty,
            reason: 'l\'angelo ${a.number} non ha ${campo.key}');
      }
    }
  });

  test('dal salmo 9 in su ogni voce dichiara la numerazione', () {
    // **DAL SALMO 9 IN POI LE DUE NUMERAZIONI DIVERGONO DI UNO**, quella
    // della Vulgata che Lenain usa e quella ebraica o moderna. Un numero
    // senza la sua numerazione e\' ambiguo, e chi legge non sa quale sia.
    //
    // Ordine CS, voce M3 della scansione: tre voci non la dichiaravano, la
    // 20 Pahaliah, la 22 Ieiaiel e la 24 Haheuiah. I loro numeri della
    // Vulgata sono stati letti sulla stampa del 1823 uno per uno,
    // riconoscendo il versetto dal latino.
    final mute = <String>[];
    for (final a in kAngelLore.values) {
      final m = RegExp(r'[Ss]almo\s+(\d+)').firstMatch(a.psalm);
      if (m == null) continue;
      final n = int.parse(m.group(1)!);
      if (n <= 8) continue;   // fino all\'otto le due numerazioni coincidono
      final dichiara = a.psalm.contains('Vulgata') ||
          a.psalm.contains('ebraic') ||
          a.psalm.contains('CEI');
      if (!dichiara) mute.add('${a.number} ${a.name}');
    }
    expect(mute, isEmpty,
        reason: 'queste voci danno un numero di salmo sopra l\'otto senza '
            'dire quale numerazione usano, e dal nove in poi la Vulgata e '
            'quella ebraica divergono: $mute');
  });

  test('il versetto che due angeli condividono e\' spiegato', () {
    // **STA NELLA FONTE, e va detto.** Lenain assegna lo stesso versetto ad
    // Achaiah e a Daniel, tutti e due con la formula «le 8e. verset»,
    // verificato leggendo le due voci una accanto all'altra sulla stampa
    // del 1823. Chi apre l'app e li vede tutti e due si trova davanti a un
    // doppione che sembra nostro: ordine CS, voce M4.
    final sette = kAngelLore[7]!;
    final cinquanta = kAngelLore[50]!;
    expect(sette.psalm.contains('Miserator'), isTrue,
        reason: 'il settimo non porta piu\' il versetto della fonte');
    expect(cinquanta.psalm.contains('Miserator'), isTrue,
        reason: 'il cinquantesimo non porta piu\' il versetto della fonte');
    for (final a in [sette, cinquanta]) {
      expect(a.psalm.contains('Lenain'), isTrue,
          reason: 'l\'angelo ${a.number} condivide il versetto con un '
              'altro e non dice che sta cosi\' nella fonte: sembra un '
              'doppione nostro');
    }
  });
}
