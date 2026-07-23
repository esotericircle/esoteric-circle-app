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
    'sigillo-cerchio.png', // Sigillo del Cerchio, nuova esperienza
    'santuario-alto.png', // Santuario, alto pulito
    'santuario-scaffale.png', // Santuario, scaffale funzioni a scorrimento
    'chat-instradamento.png', // instradamento della chat verso una funzione
    'sinastria-vip.png', // Sinastria VIP, risultato
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
