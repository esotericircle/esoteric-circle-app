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
    'rito-sogno-nebbia.png', // Sigillo del Sogno, apertura nella nebbia
    'rito-sogno-cielo.png', // Sigillo del Sogno, il cielo reale rivelato
    'rito-sogno-costellazione.png', // Sigillo del Sogno, la costellazione unita
    'rito-sogno.png', // Sigillo del Sogno, il saluto della notte
    'rito-sogno-carta.png', // Sigillo del Sogno, la carta della notte
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

  // Il fondale fotografico del tramonto deve esserci davvero, e non il ripiego
  // procedurale che la schermata dipinge quando i webp mancano.
  //
  // Come si distinguono: il ripiego e' un gradiente verticale, quindi lungo una
  // riga orizzontale il colore non cambia, se non per il dithering di un livello
  // che il canvas applica sempre. Il fondale dipinto porta invece struttura vera.
  // Per questo si contano solo i salti di almeno due livelli su un canale: sotto
  // quella soglia si misurerebbe il rumore del gradiente, non il cielo.
  //
  // Dove si misura: SOLO nei novanta punti piu' a sinistra e nei novanta piu' a
  // destra, e nella fascia fra il ventidue e il trenta per cento dell'altezza. Al
  // centro ci sono pietra, card e testo, i cui bordi da soli farebbero passare il
  // controllo anche senza cielo, cioe' per il motivo sbagliato.
  //
  // Quali anteprime: solo le tre in cui il cielo e' scoperto. Nelle quattro di
  // lettura, sopra il fondale c'e' la velatura scura che lo spegne quasi del
  // tutto, e la misura non separa i due casi: col fondale vero da' 0.5 cambi ogni
  // cento punti, col ripiego 0.0, cioe' gli stessi numeri. Un controllo li' non
  // bloccherebbe niente e darebbe solo una falsa sicurezza, quindi non si mette.
  //
  // Taratura sui file veri, cambi ogni cento punti, lato peggiore fra i due:
  // attesa 7.1, getto 7.1, incisione 9.5. Rigenerando le stesse catture col
  // fondale disattivato il valore scende a 0.00 su tutte e tre. La soglia sta a
  // due, cioe' oltre tre volte sotto il caso buono peggiore e nettamente sopra
  // lo zero del ripiego.
  const anteprimeConCielo = <String>[
    'runa-tramonto-attesa.png',
    'runa-tramonto-getto.png',
    'runa-tramonto-incisione.png',
  ];
  const sogliaCambiPerCento = 2.0;

  testWidgets('Le anteprime col cielo scoperto hanno il fondale vero',
      (tester) async {
    for (final name in anteprimeConCielo) {
      final file = File('docs/preview/$name');
      expect(file.existsSync(), isTrue, reason: 'manca $name');
      late double cambi;
      await tester.runAsync(() async {
        cambi = await _cambiNeiMarginiDelCielo(file);
      });
      expect(cambi, greaterThan(sogliaCambiPerCento),
          reason: 'In $name i margini di cielo sono piatti '
              '(${cambi.toStringAsFixed(2)} cambi ogni cento punti): la cattura '
              'ha preso il ripiego procedurale invece del fondale. Controlla il '
              'precarico dei tre webp in precacheTramonto.');
    }
  });
}

/// I cambi di colore ogni cento punti lungo le righe della fascia di cielo,
/// misurati solo nei margini laterali, dove il fondale e' scoperto, e contando
/// solo i salti di almeno due livelli, cosi' il dithering del gradiente non
/// viene scambiato per struttura. Si prende il lato peggiore fra sinistra e
/// destra: basta un margine coperto per far scattare il controllo.
Future<double> _cambiNeiMarginiDelCielo(File file) async {
  const larghezzaMargine = 90;
  const saltoMinimo = 2;
  final codec = await ui.instantiateImageCodec(await file.readAsBytes());
  final frame = await codec.getNextFrame();
  final img = frame.image;
  final dati = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
  if (dati == null) return 0;
  final byte = dati.buffer.asUint8List();
  final w = img.width;
  final da = (img.height * 0.22).round();
  final a = (img.height * 0.30).round();

  double misura(int x0, int x1) {
    var totale = 0;
    var righe = 0;
    for (var y = da; y < a; y += 4) {
      for (var x = x0 + 1; x < x1; x++) {
        final i = (y * w + x) * 4;
        final j = (y * w + x - 1) * 4;
        var salto = 0;
        for (var c = 0; c < 3; c++) {
          final d = (byte[i + c] - byte[j + c]).abs();
          if (d > salto) salto = d;
        }
        if (salto >= saltoMinimo) totale++;
      }
      righe++;
    }
    if (righe == 0) return 0;
    return (totale / righe) / (x1 - x0) * 100;
  }

  final sinistra = misura(0, larghezzaMargine);
  final destra = misura(w - larghezzaMargine, w);
  img.dispose();
  return sinistra < destra ? sinistra : destra;
}
