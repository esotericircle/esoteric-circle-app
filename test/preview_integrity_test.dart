import 'dart:io';

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
    'runa-tramonto-chiusa.png', // Runa del Tramonto, stato chiuso
    'runa-tramonto.png', // Runa del Tramonto, stato estratto
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
}
