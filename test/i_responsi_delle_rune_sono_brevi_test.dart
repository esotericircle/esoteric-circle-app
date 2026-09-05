import 'package:esoteric_circle/core/responsi/confine_del_responso.dart';
import 'package:esoteric_circle/core/responsi/tetti_dei_responsi.dart';
import 'package:esoteric_circle/core/rituals/runes.dart';
import 'package:flutter_test/flutter_test.dart';

/// I RESPONSI DELLE SINGOLE RUNE SCENDONO ALLA META'. Ordine S voce 20.
///
/// **Il tetto viene dalla misura, non dall'occhio:** 55 caratteri, cioe' la meta'
/// della mediana misurata alla voce S.18, che era 106 per il verso dritto e 111
/// per quello d'ombra.
///
/// **Sono RISCRITTI, non tagliati.** Nella forma breve resta la risposta, cioe'
/// cio' che la runa dice a te, e cade la descrizione del simbolo, che vive nel
/// campo `meaning` della runa, nella sua scheda e nel pannello delle fonti. Un
/// testo tagliato e' un testo non scritto.
void main() {
  test('le ventiquattro rune stanno nel tetto, in entrambi i versi', () {
    final sopra = <String>[];
    final vuoti = <String>[];
    for (final runa in kElderFuthark) {
      for (final verso in [
        ('dritto', runa.upright),
        ('d\'ombra', runa.shadow),
      ]) {
        if (verso.$2.trim().isEmpty) {
          vuoti.add('${runa.name}, verso ${verso.$1}');
          continue;
        }
        if (verso.$2.length > TettiDeiResponsi.runaBreve) {
          sopra.add('${runa.name}, verso ${verso.$1}: '
              '${verso.$2.length} caratteri');
        }
      }
    }
    expect(vuoti, isEmpty,
        reason: 'questi responsi sono vuoti, e un responso vuoto e\' peggio di '
            'uno lungo:\n${vuoti.join("\n")}');
    expect(sopra, isEmpty,
        reason: 'questi responsi superano il tetto di '
            '${TettiDeiResponsi.runaBreve} caratteri:\n${sopra.join("\n")}');
    expect(kElderFuthark.length, 24,
        reason:
            'l\'Elder Futhark ha ventiquattro segni: la prova ne ha guardati '
            '${kElderFuthark.length}');
  });

  test('la descrizione del simbolo NON e\' caduta nel nulla', () {
    // **Cade dal responso, non dall'app.** L'ordine dice che vive nella scheda
    // della runa e nel pannello delle fonti: se fosse sparita, avremmo accorciato
    // buttando, e questa prova sarebbe verde per la ragione sbagliata.
    final senzaSimbolo = <String>[];
    for (final runa in kElderFuthark) {
      if (runa.meaning.trim().isEmpty) senzaSimbolo.add(runa.name);
      if (runa.keyword.trim().isEmpty) {
        senzaSimbolo.add('${runa.name} (parola)');
      }
    }
    expect(senzaSimbolo, isEmpty,
        reason:
            'queste rune hanno perso la descrizione del simbolo insieme alla '
            'lunghezza: $senzaSimbolo');
  });

  test('i responsi brevi stanno dentro il confine', () {
    // Il registro e' diventato piu' diretto, quindi il confine si guarda proprio
    // qui: sono i testi che parlano alla persona in una riga.
    final fuori = <String>[];
    for (final runa in kElderFuthark) {
      for (final testo in [runa.upright, runa.shadow]) {
        for (final v in ConfineDelResponso.violazioni(testo)) {
          fuori.add('${runa.name}: $v');
        }
      }
    }
    expect(fuori, isEmpty,
        reason: 'questi responsi brevi superano il confine:\n'
            '${fuori.join("\n")}');
  });

  test(
      'il tetto e\' dichiarato una volta sola, e la meta\' e\' quella misurata',
      () {
    // La misura sta nella tabella generata: se la mediana cambiasse, la tabella
    // cambierebbe e questa riga andrebbe rivista. Qui si tiene fermo il RAPPORTO
    // fra il tetto e la mediana misurata del verso d'ombra, che era 111.
    // **LA META' SI ARROTONDA PER DIFETTO**, e la prima stesura di questa riga
    // arrotondava al piu' vicino: 111 mezzi fanno 55,5, e un tetto che si
    // arrotonda per eccesso si concede mezzo carattere senza una ragione. Un tetto
    // arrotonda verso il basso.
    expect(TettiDeiResponsi.runaBreve, 111 ~/ 2,
        reason: 'il tetto non e\' piu\' la meta\' della mediana misurata: '
            'rileggi docs/responsi/lunghezze.md prima di cambiarlo');
  });
}
