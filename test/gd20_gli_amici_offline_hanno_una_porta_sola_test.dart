import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'sorgenti_di_lib.dart';

/// **GLI AMICI OFFLINE HANNO UNA PORTA SOLA.** Ordine GD voce GD.20, 23
/// ottobre 2026. Il fondatore: *"la lista di amici offline, devono essere
/// condivisi tra le funzionalità, adesso c'è per l'oroscopo, ma devono essere
/// condivise con le altre funzionalità di compatibilità che verranno"*.
///
/// **COSA MISURA.** Enumera i punti di `lib` che leggono o scrivono la lista
/// degli amici offline e cade se ne esiste piu' di una porta:
/// 1. **chi tocca il disco**: i file che chiamano `SharedPreferences` e
///    nominano la chiave della lista (`'amici_offline'`) devono essere uno
///    solo, `lib/core/amici/amici_offline.dart`. Una seconda lista nata nella
///    Sinastria (o in una funzione che verra') si legge qui come un secondo
///    file;
/// 2. **chi tiene la forma dell'amico**: la classe `Amico` (nome e nascita)
///    vive in quel file solo; una seconda scheda dell'amico in un altro file
///    sarebbe una seconda lista travestita;
/// 3. **chi usa la porta**: le funzioni di compatibilita' passano tutte da
///    `AmiciOffline`. L'Oroscopo (la rubrica `amici_screen.dart`) e la
///    Sinastria evolutiva (la tendina, GD.14) ci sono entrambe; il cardinale
///    minimo e' due.
///
/// Passa dalla porta comune `sorgentiDiLib()`; i suoi insiemi dichiarano il
/// cardinale minimo.
void main() {
  const porta = 'lib/core/amici/amici_offline.dart';
  String percorso(File f) => f.path.replaceAll('\\', '/');

  final sorgenti = {
    for (final f in sorgentiDiLib()) percorso(f): f.readAsStringSync(),
  };

  // Una chiave di amici usata per leggere o scrivere: dichiarata in una
  // costante (`_chiave = 'amici_offline'`) o scritta nella chiamata
  // (`getString('amici_della_sinastria')`). Qualunque chiave che nomina gli
  // amici, non solo quella di oggi: una seconda lista avrebbe un nome suo.
  // Il nome della chiave come voce di un elenco (lo scarico dei dati e le
  // memorie custodite, che la nominano per dire alla persona che cosa porta
  // via) non legge ne' scrive la lista.
  final usaLaChiave = RegExp(
      r"(=\s*'[^']*amic[^']*'|(get|set|remove)\w*\(\s*'[^']*amic[^']*')");

  test('GD.20: un file solo legge e scrive la lista sul telefono', () {
    final suDisco = [
      for (final e in sorgenti.entries)
        if (e.value.contains('SharedPreferences') &&
            usaLaChiave.hasMatch(senzaCommenti(e.value)))
          e.key,
    ];
    // ignore: avoid_print
    print('GD.20 CHI TOCCA LA LISTA SUL DISCO: $suDisco');
    cardinaleMinimo(suDisco.length, 1, cosa: 'file che toccano la lista');
    expect(suDisco, [porta],
        reason: 'la lista degli amici offline si legge o si scrive anche '
            'fuori dalla sua porta: ${suDisco.where((p) => p != porta)}. '
            'Nasce una seconda lista.');
  });

  test('GD.20: la scheda dell\'amico vive nella porta sola', () {
    final schede = [
      for (final e in sorgenti.entries)
        if (RegExp(r'^\s*class\s+Amico\b', multiLine: true)
            .hasMatch(senzaCommenti(e.value)))
          e.key,
    ];
    expect(schede, [porta],
        reason: 'una seconda classe Amico fuori dalla porta: $schede');
  });

  test(
      'GD.20: l\'Oroscopo e la Sinastria evolutiva leggono gli amici dalla '
      'stessa porta', () {
    final chiUsaLaPorta = [
      for (final e in sorgenti.entries)
        if (e.key != porta &&
            senzaCommenti(e.value).contains('AmiciOffline(') &&
            e.value.contains('core/amici/amici_offline.dart'))
          e.key,
    ];
    // ignore: avoid_print
    print('GD.20 CHI USA LA PORTA: $chiUsaLaPorta');
    cardinaleMinimo(chiUsaLaPorta.length, 2,
        cosa: 'funzioni che usano la porta degli amici offline');
    expect(chiUsaLaPorta, contains('lib/features/amici/amici_screen.dart'));
    expect(chiUsaLaPorta,
        contains('lib/features/synastry/la_tendina_della_sinastria.dart'),
        reason: 'la Sinastria evolutiva non legge gli amici offline '
            'dell\'Oroscopo');
  });
}
