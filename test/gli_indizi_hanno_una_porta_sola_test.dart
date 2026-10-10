// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/entitlement/listino_degli_eos.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **GLI INDIZI HANNO UNA PORTA SOLA.** Ordine FF voce 03, 7 ottobre 2026.
///
/// Gli indizi dei giochi del Cerchio nascono in `functions/src/gli_indizi.ts`
/// e i giochi li chiedono a quello. Un gioco che costruisse un indizio per
/// conto suo (un oggetto con `fonte:` e una delle fonti) potrebbe pescare da
/// dove la porta non pesca, per esempio da un comportamento osservato.
void main() {
  const porta = 'functions/src/gli_indizi.ts';

  test('nessun file del server costruisce un indizio fuori dalla porta', () {
    final sorgenti = Directory('functions/src')
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.ts') && !f.path.endsWith('.test.ts'))
        .toList();
    cardinaleMinimo(sorgenti.length, 30,
        cosa: 'sorgenti del server',
        perche: 'functions/src porta oltre trenta file TypeScript.');
    final fonti = RegExp(
        r'''fonte:\s*["'](ritratto|elemento|modalita|animale|archetipoSecondario)["']''');
    final fuori = [
      for (final f in sorgenti)
        if (f.path.replaceAll(r'\', '/') != porta &&
            fonti.hasMatch(f.readAsStringSync()))
          f.path,
    ];
    expect(File(porta).existsSync(), isTrue);
    expect(fonti.hasMatch(File(porta).readAsStringSync()), isTrue,
        reason: 'la porta non costruisce piu\' indizi: la guardia e\' cieca');
    expect(fuori, isEmpty,
        reason: 'questi file costruiscono un indizio da se\': $fuori');
  });

  test('il prezzo dell\'indizio e\' lo stesso sul telefono e sul server', () {
    final server = File(porta).readAsStringSync();
    final m =
        RegExp(r'export const PREZZO_DELL_INDIZIO = (\d+);').firstMatch(server);
    expect(m, isNotNull, reason: 'il prezzo del server non si legge');
    print('ORDINE FF VOCE 03: indizio ${ListinoDegliEos.indizio.costo} Eos '
        'sul telefono, ${m!.group(1)} sul server');
    expect(ListinoDegliEos.indizio.costo, int.parse(m.group(1)!));
    expect(ListinoDegliEos.segnoDiChiTiHaIndovinato.costo, 20);
  });
}
