import 'dart:io';

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/design_system/components/cosmos_background.dart';
import 'package:esoteric_circle/design_system/components/interruttore_del_cerchio.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL COSMO ARRIVA IN FONDO, E GLI INTERRUTTORI SONO DEL CERCHIO.
void main() {
  testWidgets('Il cosmo riempie l\'altezza anche col contenuto corto',
      (tester) async {
    // La segnalazione: nel Test Archetipo, quando compariva l'avviso "Aggiunta
    // alle tue arti", sotto il contenuto si apriva una fascia nera alta quasi un
    // terzo dello schermo. L'avviso non c'entrava: lo Stack del cosmo prendeva
    // l'altezza del contenuto, quindi con un contenuto corto il cielo finiva
    // dove finiva lui. Ogni schermata sta sul cosmo condiviso, per intero.
    await tester.pumpWidget(const MaterialApp(
      home: MaestroScope(
        maestro: Maestro.aura,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: CosmosBackground(
            seed: 7,
            showZodiac: false,
            // Un contenuto volutamente cortissimo, come quando l'avviso
            // ridisegna la schermata e il resto si accorcia.
            child: SizedBox(height: 40),
          ),
        ),
      ),
    ));
    await tester.pump();

    final schermo = tester.getSize(find.byType(MaterialApp));
    final cosmo = tester.getSize(find.byType(CosmosBackground));
    expect(cosmo.height, schermo.height,
        reason: 'il cosmo e\' alto ${cosmo.height} su uno schermo di '
            '${schermo.height}: sotto resta una fascia nera, e il cielo si '
            'interrompe a meta pagina');
  });

  testWidgets('L\'interruttore del Cerchio non ha i colori di Material',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: MaestroScope(
        maestro: Maestro.aura,
        child: Scaffold(
          body: InterruttoreDelCerchio(
            acceso: true,
            onCambia: (_) {},
            titolo: 'Lega al cielo di oggi',
          ),
        ),
      ),
    ));
    await tester.pump();

    final tile = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
    // Non basta il pollice, come si faceva prima: la TRACCIA e' la parte piu'
    // grande, e restava grigia da spenta e viola da accesa.
    expect(tile.activeTrackColor, isNotNull,
        reason: 'la traccia accesa resta quella di Material, viola dentro due '
            'schermate tutte oro e verde');
    expect(tile.inactiveTrackColor, isNotNull,
        reason: 'la traccia spenta resta il grigio di Material');
  });

  test('Chi usa Switch direttamente e\' enumerato', () {
    // Non tutti gli Switch del progetto devono passare da qui: le Impostazioni
    // sono una schermata di sistema e il loro aspetto e' un'altra decisione.
    // Quello che serve e' che l'elenco sia SCRITTO, cosi' il terzo interruttore
    // che nasce dentro un'arte non ricomincia da capo senza accorgersene.
    const attesi = {
      // **IL MENU' DELLE NOTIFICHE**, ordine BC voce 05: i cinque
      // appuntamenti dei Doni hanno un interruttore ciascuno, e sono comandi
      // di sistema come quelli delle Impostazioni, non gesti dentro un'arte.
      // La levetta di Material e' quella che la persona riconosce da tutte le
      // altre app quando accende una notifica.
      'lib/features/account/notifiche_screen.dart',
      // **LA RIGA CON LA LEVETTA DELLE IMPOSTAZIONI**, ordine CE voce 03.
      // Stava dentro `settings_screen.dart` e ne e' uscita quando il blocco
      // della privacy e' andato nel suo sotto menu': e' lo stesso comando di
      // sistema di prima, in un file suo.
      'lib/features/settings/riga_interruttore.dart',
      // **IL CONSENSO ALLA MISURA DEL RITORNO**, ordine CE voce 01: vive
      // dentro il gesto della registrazione ed e' un comando di sistema,
      // non un gesto dentro un'arte. Nasce spento, e la levetta che la
      // persona riconosce da ogni altra app e' quella di Material.
      'lib/features/account/consensi_della_registrazione.dart',
      'lib/features/tarot/tarot_selectors.dart',
    };
    final trovati = <String>{};
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final p = f.path.replaceAll(Platform.pathSeparator, '/');
      if (p.endsWith('interruttore_del_cerchio.dart')) continue;
      final t = f.readAsStringSync();
      if (t.contains('Switch(') || t.contains('SwitchListTile(')) {
        trovati.add(p);
      }
    }
    expect(trovati, attesi,
        reason: 'l\'elenco di chi usa Switch direttamente e\' cambiato: se e\' '
            'un interruttore dentro un\'arte deve passare da '
            'InterruttoreDelCerchio, altrimenti aggiorna questo elenco e di\' '
            'perche\' resta fuori');
  });
}
