import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

/// Integrita' dei preview: la build fallisce se anche un solo file atteso in
/// `docs/preview/` manca. Cosi' la relazione non puo' dichiarare screenshot che
/// non esistono. I file veri li produce `screenshot_capture_test.dart`; qui si
/// verifica soltanto che ci siano tutti.
void main() {
  // I preview obbligatori della Demo, per nome file.
  const required = <String>[
    'piani.png', // schermata prezzi, quattro livelli piu' la card Demo
    'striscia-del-giorno.png', // i quattro riti nella striscia del Santuario
    'runa-tramonto-attesa.png', // Runa del Tramonto, la pietra velata in attesa
    'runa-tramonto-getto.png', // Runa del Tramonto, la pietra scoperta dal getto
    'runa-tramonto-incisione.png', // Runa del Tramonto, il segno inciso a meta'
    'runa-tramonto-voce-uno.png', // Runa del Tramonto, prima voce e trasparenza
    'runa-tramonto-voce-due.png', // Runa del Tramonto, seconda voce dopo la rotazione
    'runa-tramonto-settimana.png', // Runa del Tramonto, la striscia delle sette sere
    'runa-tramonto-sigillo.png', // Runa del Tramonto, il sigillo della settima sera
    'rito-sogno-nebbia.png', // Rito del Sogno, apertura nella nebbia
    'rito-sogno-cielo.png', // Rito del Sogno, il cielo reale rivelato
    'rito-sogno-costellazione.png', // Rito del Sogno, la costellazione unita
    'rito-sogno.png', // Rito del Sogno, il saluto della notte
    'rito-sogno-carta.png', // Rito del Sogno, la carta della notte
    'sigillo-cerchio.png', // Sigillo del Cerchio, nuova esperienza
    'santuario-alto.png', // Santuario, alto pulito
    'santuario-scaffale.png', // Santuario, scaffale funzioni a scorrimento
    'chat-instradamento.png', // instradamento della chat verso una funzione
    'sinastria-galleria.png', // Sinastria VIP, galleria di scelta del VIP
    'sinastria-vip.png', // Sinastria VIP, risultato
    'sinastria-vip-personale.png', // Sinastria VIP, col nome utente reale
    'dominio-medora.png', // dominio, presenza, Consulta e prime sottocategorie
    'dominio-medora-aperto.png', // dominio coi gruppi aperti, le arti in cammino
    'dominio-aura.png', // dominio di Aura, stato di partenza
    'dominio-aura-aperto.png', // dominio di Aura coi gruppi aperti
    'dominio-caligo.png', // dominio di Caligo, stato di partenza
    'dominio-caligo-aperto.png', // dominio di Caligo coi gruppi aperti
    'test-archetipo.png', // Test Archetipo, il responso
    'test-archetipo-card.png', // Test Archetipo, card condivisibile
    'test-archetipo-soglia.png', // Test Archetipo, soglia col selettore transiti
    'test-archetipo-domanda.png', // Test Archetipo, una domanda in corso
    'costellazione-viso-soglia.png', // Costellazione del Viso, soglia col selettore
    'costellazione-viso-sagoma.png', // Costellazione del Viso, costellazione sulla sagoma
    'costellazione-viso.png', // Costellazione del Viso, il responso
    'costellazione-viso-card.png', // Costellazione del Viso, card condivisibile
    'costellazione-viso-ripiego.png', // Costellazione del Viso, ripiego tattile
    'guide-animale-popup.png', // Animale Guida, popup del Test Archetipo
    'guide-animale-viaggio.png', // Animale Guida, il viaggio col tamburo
    'guide-animale-rivelazione.png', // Animale Guida, la rivelazione nella nebbia
    'guide-animale.png', // Animale Guida, il messaggio del momento dopo il viaggio
    'guide-animale-identita.png', // Animale Guida, la lettura fissa di identita'
    'guide-animale-card.png', // Animale Guida, card condivisibile
    'guide-animale-passport.png', // Animale Guida, la faccia nel Cosmic Passport
    'guide-animale-chat.png', // Animale Guida, chat aperta con la domanda scritta
    'rune-soglia.png', // Estrazione Rune, soglia col selettore e il testo dinamico
    'rune-lancio.png', // Estrazione Rune, il lancio nel Pozzo di Urdhr
    'rune-norne.png', // Estrazione Rune, la rivelazione a tre Norne col presagio
    'rune-odino.png', // Estrazione Rune, la gettata a una runa
    'rune-croce.png', // Estrazione Rune, la Croce delle Cinque
    'rune-getto.png', // Estrazione Rune, il getto sul telo, la sorte libera
    'rune-card.png', // Estrazione Rune, card condivisibile con la bindrune
  ];

  test('Tutti i preview obbligatori esistono in docs/preview', () {
    final missing = <String>[
      for (final name in required)
        if (!File('docs/preview/$name').existsSync()) name,
    ];
    expect(
      missing,
      isEmpty,
      reason: 'Preview mancanti in docs/preview: ${missing.join(', ')}. '
          'Rigenera gli screenshot con screenshot_capture_test.dart.',
    );
  });

  test('Ogni preview obbligatorio non e vuoto', () {
    for (final name in required) {
      final file = File('docs/preview/$name');
      if (file.existsSync()) {
        expect(file.lengthSync(), greaterThan(0),
            reason: 'Il preview $name esiste ma e vuoto.');
      }
    }
  });

  // Le sette anteprime della Runa del Tramonto devono mostrare il fondale
  // fotografico vero, non il ripiego procedurale. Il ripiego e' un gradiente
  // puramente verticale: lungo una riga orizzontale il colore non cambia quasi
  // mai. Il fondale dipinto, invece, varia sempre anche in orizzontale. Si misura
  // quindi quanti cambi di colore ci sono lungo le righe della fascia di cielo.
  //
  // Taratura sulle anteprime reali: il valore piu' basso misurato con il fondale
  // vero e' circa 246 cambi su una riga da 1170 punti; col ripiego procedurale
  // scenderebbe quasi a zero. La soglia sta a 60, cioe' quattro volte sotto il
  // caso peggiore buono: fallisce solo se il fondale manca davvero.
  const anteprimeTramonto = <String>[
    'runa-tramonto-attesa.png',
    'runa-tramonto-getto.png',
    'runa-tramonto-incisione.png',
    'runa-tramonto-voce-uno.png',
    'runa-tramonto-voce-due.png',
    'runa-tramonto-settimana.png',
    'runa-tramonto-sigillo.png',
  ];
  const sogliaCambi = 60;

  testWidgets('Le anteprime del Tramonto hanno il fondale vero, non il ripiego',
      (tester) async {
    for (final name in anteprimeTramonto) {
      final file = File('docs/preview/$name');
      expect(file.existsSync(), isTrue, reason: 'manca $name');
      late int cambi;
      await tester.runAsync(() async {
        cambi = await _cambiOrizzontaliNelCielo(file);
      });
      expect(cambi, greaterThan(sogliaCambi),
          reason: 'In $name la fascia di cielo e piatta in orizzontale: '
              'la cattura ha preso il ripiego procedurale invece del fondale. '
              'Controlla il precarico dei tre webp in precacheTramonto.');
    }
  });
}

/// Quanti cambi di colore ci sono lungo le righe della fascia di cielo, cioe'
/// fra il dodici e il ventidue per cento dell'altezza, mediati sulle righe
/// campionate. Zero, o quasi, vuol dire gradiente verticale puro.
Future<int> _cambiOrizzontaliNelCielo(File file) async {
  final codec = await ui.instantiateImageCodec(await file.readAsBytes());
  final frame = await codec.getNextFrame();
  final img = frame.image;
  final dati = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
  if (dati == null) return 0;
  final byte = dati.buffer.asUint8List();
  final w = img.width;
  final da = (img.height * 0.12).round();
  final a = (img.height * 0.22).round();
  var totale = 0;
  var righe = 0;
  for (var y = da; y < a; y += 8) {
    var cambi = 0;
    for (var x = 1; x < w; x++) {
      final i = (y * w + x) * 4;
      final j = (y * w + x - 1) * 4;
      if (byte[i] != byte[j] ||
          byte[i + 1] != byte[j + 1] ||
          byte[i + 2] != byte[j + 2]) {
        cambi++;
      }
    }
    totale += cambi;
    righe++;
  }
  img.dispose();
  return righe == 0 ? 0 : totale ~/ righe;
}
