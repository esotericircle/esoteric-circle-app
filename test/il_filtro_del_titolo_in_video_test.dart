import 'package:esoteric_circle/core/condivisione/il_filtro_del_titolo_in_video.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL FILTRO DEL TITOLO, SENZA MAI TOCCARE FFMPEG.** Ordine FZ voce
/// FZ.08, 17 ottobre 2026: il titolo e la data devono scriversi sul video
/// senza rompere il filtro quando il nome porta un apostrofo (*"l'Aquila"*).
void main() {
  group('escape', () {
    test('scappa i due punti, l\'apostrofo e il percento', () {
      expect(IlFiltroDelTitoloInVideo.escape('ore 12:30'), 'ore 12\\:30');
      expect(IlFiltroDelTitoloInVideo.escape("l'Aquila"), "l\\'Aquila");
      expect(IlFiltroDelTitoloInVideo.escape('100%'), '100\\%');
    });

    test('scappa la fuga prima di ogni altro carattere, mai due volte', () {
      // Un testo che contiene gia' una barra rovescia non deve raddoppiare
      // le fughe degli altri caratteri.
      expect(IlFiltroDelTitoloInVideo.escape(r'a\b'), r'a\\b');
    });
  });

  group('costruisci', () {
    test('mette tutte e tre le righe nel filtro, in ordine', () {
      final f = IlFiltroDelTitoloInVideo.costruisci(
        percorsoDelFont: '/tmp/Cinzel.ttf',
        rigaUno: 'MI HA TROVATO',
        rigaDue: "L'AQUILA",
        data: '17 ottobre 2026',
      );
      final pezzi = f.split(',drawtext=');
      expect(pezzi.length, 3,
          reason: 'il filtro non porta tre pezzi drawtext distinti');
      expect(f, contains("text='MI HA TROVATO'"));
      expect(f, contains("text='L\\'AQUILA'"),
          reason: 'l\'apostrofo del nome deve essere scappato nel filtro');
      expect(f, contains("text='17 ottobre 2026'"));
      expect(f, contains("fontfile='/tmp/Cinzel.ttf'"));
    });

    test(
        'il nome e la data stanno dentro i 1080 per 1920 del video: '
        'nessuna coordinata y supera 1920', () {
      final f = IlFiltroDelTitoloInVideo.costruisci(
        percorsoDelFont: '/tmp/Cinzel.ttf',
        rigaUno: 'MI HA TROVATO',
        rigaDue: 'IL LUPO',
        data: '17 ottobre 2026',
      );
      final y = RegExp(r'y=(\d+)').allMatches(f).map(
          (m) => int.parse(m.group(1)!));
      for (final valore in y) {
        expect(valore, lessThan(1920),
            reason: 'una riga del titolo esce dal video 1080x1920');
      }
    });
  });
}
