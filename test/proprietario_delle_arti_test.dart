import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Ogni arte dichiara il proprio Maestro, e nessuna lo prende dalla strada.
///
/// Questa e' una rete strutturale: legge i sorgenti invece di montare le
/// schermate. Serve a impedire la regressione vera, cioe' una nuova arte che
/// nasce senza proprietario e finisce per indossare il colore di chi passava da
/// li'. Un test che montasse una sola rotta lascerebbe scoperte le altre dodici,
/// ed e' esattamente il tipo di copertura parziale che ha prodotto il difetto.
///
/// Il comportamento vero, cioe' che un proprietario dichiarato vince sul tema
/// attivo, e' misurato in `colore_del_proprietario_test.dart`.
void main() {
  /// Chi possiede cosa, secondo `art_catalog.dart`: Medora ha Astrologia,
  /// Compatibilita', Cartomanzia, Lunologia e Destino; Aura ha Chakra, Energia
  /// e Archetipi; Caligo ha Rune, Rituali, Magia e Numerologia.
  const attese = <String, String>{
    'lib/features/horoscope/oroscopo_screen.dart': 'medora',
    'lib/features/synastry/sinastria_vip_screen.dart': 'medora',
    'lib/features/synastry/sinastria_gallery_screen.dart': 'medora',
    'lib/features/tarot/stesa_tre_carte_screen.dart': 'medora',
    'lib/features/angels/angels_screen.dart': 'medora',
    'lib/features/santuario/sky_overview_screen.dart': 'medora',
    'lib/features/maestri/aura/archetype/archetype_test_screen.dart': 'aura',
    'lib/features/maestri/aura/face/face_constellation_screen.dart': 'aura',
    'lib/features/maestri/aura/meditation/meditation_screen.dart': 'aura',
    'lib/features/maestri/caligo/animal/guide_animal_screen.dart': 'caligo',
    'lib/features/maestri/caligo/rune/rune_draw_screen.dart': 'caligo',
    'lib/features/maestri/caligo/sigillo/sigillo_intenzione_screen.dart':
        'caligo',
    'lib/features/rituals/sunset_rune_screen.dart': 'caligo',
  };

  attese.forEach((percorso, proprietario) {
    final nome = percorso.split('/').last;
    test('$nome appartiene a $proprietario', () {
      final sorgente = File(percorso).readAsStringSync();
      expect(sorgente.contains('maestro: Maestro.$proprietario'), isTrue,
          reason: '$percorso non dichiara il proprietario, quindi entrando da '
              'una strada diversa indossa il colore di chi passava prima');
    });
  });

  test('La tessera del cerchio non vira piu il tema', () {
    // La causa del difetto era qui: il colore veniva messo dalla tessera che
    // apre l'arte, quindi valeva per una strada sola. Se qualcuno rimettesse
    // quella riga, il colore tornerebbe a dipendere dal percorso.
    final s =
        File('lib/features/maestri/maestro_screen.dart').readAsStringSync();
    final da = s.indexOf('Future<void> _open(');
    expect(da, greaterThan(0), reason: 'metodo _open non trovato');
    final corpo = s.substring(da, s.indexOf('\n  }', da));
    expect(corpo.contains('selectMaestro'), isFalse,
        reason: 'la tessera vira ancora il tema: il colore torna a dipendere '
            'dalla strada percorsa invece che dall\'arte aperta');
  });
}
