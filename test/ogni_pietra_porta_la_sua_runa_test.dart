// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:esoteric_circle/core/rituals/runes.dart';
import 'package:esoteric_circle/features/rituals/rune_strokes.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// OGNI PIETRA PORTA LA SUA RUNA. Ordine EA voce 22, 20 settembre 2026.
///
/// **Il fatto, da un fondatore**: l'Estrazione Rune diceva *Ingwaz* e la
/// pietra mostrava **Othala**, cioe' il rombo con le gambe. Il difetto non
/// era nei dati, che erano in ordine: era nell'arte, dove il file
/// `22_ingwaz` portava il segno di un'altra runa. Guardate tutte e
/// ventiquattro le pietre, una per una, a occhio: quella era l'unica
/// sbagliata.
///
/// **PERCHE' QUESTA GUARDIA NON MISURA LA FORMA, e va detto.** Il primo
/// tentativo confrontava il solco inciso col disegno a tratti che l'app usa
/// come ripiego, e i numeri dicono che non regge: su pietre GIUSTE la
/// sovrapposizione andava dal 7 per cento di Uruz al 92 di Berkano, perche'
/// i sassi sono fotografati storti e il solco ha lo spessore di una mano che
/// incide, mentre i tratti sono proporzioni ideali. Qualunque soglia li'
/// dentro sarebbe stata una soglia scelta per far passare la prova, che e'
/// il modo piu' rapido di costruire una guardia che non serve a niente.
///
/// **Cosa fa invece.** Tiene ferme tre cose che si possono misurare davvero:
/// i nomi dei file legati al nome e alla posizione della runa, l'esistenza
/// dell'arte e della sua miniatura, e **l'impronta di ogni immagine**. Il
/// giudizio sul segno lo da' l'occhio, una volta, sulla tavola di
/// `docs/anteprime/rune_incise.png`; da quel momento una pietra che cambia
/// senza che nessuno l'abbia riguardata fa cadere questa prova.
void main() {
  /// L'impronta di ogni pietra, dopo la revisione a occhio del 20 settembre
  /// 2026. **Chi cambia una pietra riguarda la tavola e riscrive la riga**,
  /// e nel commit si vede quale runa e' cambiata.
  const impronte = <String, String>{
    'rune_bone_01_fehu_v1': '29d5060322f765b8',
    'rune_bone_02_uruz_v1': '1a730f684b810d62',
    'rune_bone_03_thurisaz_v1': '661632cd6f27b725',
    'rune_bone_04_ansuz_v1': '372de23f8b6ea033',
    'rune_bone_05_raidho_v1': '199792059b900038',
    'rune_bone_06_kenaz_v1': 'f6ed0ce634997d0b',
    'rune_bone_07_gebo_v1': 'cec6dc9f5670d191',
    'rune_bone_08_wunjo_v1': '5d643ead68e0de3f',
    'rune_bone_09_hagalaz_v1': 'ce619f14ead5d5cf',
    'rune_bone_10_nauthiz_v1': '63b6da8e81a41635',
    'rune_bone_11_isa_v1': '05f84a2d785fda6b',
    'rune_bone_12_jera_v1': '60fa1a069be8cc82',
    'rune_bone_13_eihwaz_v1': '852e5c3a65cdb82a',
    'rune_bone_14_perthro_v1': '754e798ffa667af5',
    'rune_bone_15_algiz_v1': 'fd83f7c7ca8664c6',
    'rune_bone_16_sowilo_v1': 'ae398d1f5bd6eb05',
    'rune_bone_17_tiwaz_v1': 'c1e3188f504d71a3',
    'rune_bone_18_berkano_v1': '809f440e42117dca',
    'rune_bone_19_ehwaz_v1': 'fd4e78488f9f2ace',
    'rune_bone_20_mannaz_v1': '64ef35c829d0a75d',
    'rune_bone_21_laguz_v1': 'd6919a9e9150675d',
    // **LA PIETRA CORRETTA DALL'ORDINE EA VOCE 22**: portava Othala, adesso
    // porta il rombo di Ingwaz. L'impronta e' quella dopo la correzione.
    'rune_bone_22_ingwaz_v1': '0bf4d522263c445e',
    'rune_bone_23_dagaz_v1': '26d258c3a34ff4b8',
    'rune_bone_24_othala_v1': '016664a7c262f2a3',
  };

  String improntaDi(String percorso) => sha1
      .convert(File(percorso).readAsBytesSync())
      .toString()
      .substring(0, 16);

  test('il nome del file dice la runa e il suo posto nel Futhark', () {
    final conArte =
        kElderFuthark.where((r) => r.stem != null).toList(growable: false);
    cardinaleMinimo(conArte.length, 24,
        cosa: 'rune con l\'arte incisa',
        perche: 'Se le pietre sparissero dal corpus questa prova sarebbe '
            'verde senza aver guardato nessuna incisione.');
    final storte = <String>[];
    for (final (i, r) in conArte.indexed) {
      final atteso = 'rune_bone_${(i + 1).toString().padLeft(2, '0')}_'
          '${r.name.toLowerCase()}_v1';
      if (r.stem != atteso) {
        storte.add('${r.name} sta al posto ${i + 1} e la sua arte si chiama '
            '${r.stem}, invece di $atteso');
      }
      // E il segno esiste anche come tratti, che e' il ripiego dell'app.
      if (!kRuneStrokes.containsKey(r.name)) {
        storte.add('${r.name} non ha i tratti del ripiego');
      }
    }
    expect(storte, isEmpty, reason: storte.join('\n'));
  });

  test('ogni pietra e\' al suo posto, con la miniatura, e non e\' cambiata',
      () {
    final conArte =
        kElderFuthark.where((r) => r.stem != null).toList(growable: false);
    cardinaleMinimo(impronte.length, 24,
        cosa: 'impronte di pietre dichiarate',
        perche: 'Un elenco vuoto non confronterebbe niente.');
    final guai = <String>[];
    for (final r in conArte) {
      final piena = 'assets/img/rune_bone/${r.stem}.webp';
      final miniatura = 'assets/img_thumb/rune_bone/${r.stem}.webp';
      for (final p in [piena, miniatura]) {
        if (!File(p).existsSync()) guai.add('manca $p');
      }
      final atteso = impronte[r.stem];
      if (atteso == null) {
        guai.add('${r.stem} non ha un\'impronta dichiarata: guarda la tavola '
            'docs/anteprime/rune_incise.png e scrivila');
        continue;
      }
      if (!File(piena).existsSync()) continue;
      final adesso = improntaDi(piena);
      if (adesso != atteso) {
        guai.add('${r.name}: la pietra e\' cambiata ($adesso invece di '
            '$atteso). Riguarda la tavola docs/anteprime/rune_incise.png e, '
            'se il segno e\' quello giusto, riscrivi l\'impronta.');
      }
    }
    print('ORDINE EA VOCE 22: pietre confrontate ${conArte.length}');
    expect(guai, isEmpty, reason: guai.join('\n'));
  });

  test('la tavola che l\'occhio ha guardato esiste, ed e\' di queste pietre',
      () {
    // **SENZA LA TAVOLA, LA REVISIONE A OCCHIO NON HA UN POSTO DOVE STARE**,
    // e la prossima persona non saprebbe dove guardare.
    final tavola = File('docs/anteprime/rune_incise.png');
    expect(tavola.existsSync(), isTrue,
        reason: 'manca docs/anteprime/rune_incise.png: si rigenera con '
            'python tool/tavola_delle_rune.py');
    // La tavola porta accanto il conto delle impronte da cui e' nata: se le
    // pietre cambiano e nessuno la rifa', qui si vede.
    final firma = File('docs/anteprime/rune_incise.sha1');
    expect(firma.existsSync(), isTrue, reason: 'manca la firma della tavola');
    final somma = sha1
        .convert(utf8.encode(impronte.values.join(',')))
        .toString()
        .substring(0, 16);
    expect(firma.readAsStringSync().trim(), somma,
        reason: 'la tavola e\' di altre pietre: rigenerala con '
            'python tool/tavola_delle_rune.py e riguardala');
  });
}
