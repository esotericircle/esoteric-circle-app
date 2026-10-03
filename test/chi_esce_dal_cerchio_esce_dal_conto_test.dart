// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/services/server/chi_e_online.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// **CHI ESCE DAL CERCHIO ESCE DAL CONTO, E IL CONTO SI RILEGGE PRESTO.**
/// Ordine EV voce 06, il fondatore: *"Dopo cinque minuti o cmq da ieri
/// l'indicatore "ONLINE" RESTA FERMO A 1 sia sul mio Cell e sia sul realme
/// collegato."*, e il 1 ottobre alle 16:34: *"Adesso realme mostra "online
/// 1", ma il mio 2"*.
///
/// Letto nel database alle 14:33 UTC: il Realme aveva chiesto alle 14:32:04,
/// il telefono del fondatore alle 14:32:42. Il Realme aveva contato prima che
/// l'altro arrivasse e non avrebbe richiesto per due minuti; il telefono del
/// fondatore, uscito dall'app per scrivere, restava nel conto altri due
/// minuti e mezzo. Si misura:
/// - il telefono chiede ogni minuto, non ogni due, e il server tiene la
///   finestra a un minuto e mezzo (il passo piu' mezzo minuto);
/// - quando l'app va in pausa il telefono dice al server che esce, e il
///   server lo toglie dal conto subito;
/// - al ritorno chiede subito.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('il passo e la finestra', () {
    final server = File('functions/src/presenza.ts').readAsStringSync();
    final passo =
        RegExp(r'OGNI_QUANTO_CHIEDE_MS = (\d+) \* 1000').firstMatch(server);
    print('CHI ESCE DAL CERCHIO: passo del telefono '
        '${ChiEOnline.ogni.inSeconds} s, del server '
        '${passo == null ? '?' : passo.group(1)} s');
    expect(ChiEOnline.ogni, const Duration(minutes: 1),
        reason: 'il telefono chiede piu\' di rado di un minuto: chi arriva si '
            'vede fino a due minuti dopo');
  });

  test('in pausa il telefono esce, al ritorno chiede', () async {
    final porta = _PortaContata();
    final chi = ChiEOnline(porta: porta)..avvia();
    await Future<void>.delayed(Duration.zero);
    final primaDomanda = porta.domande;
    chi.didChangeAppLifecycleState(AppLifecycleState.paused);
    await Future<void>.delayed(Duration.zero);
    final uscite = porta.uscite;
    chi.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await Future<void>.delayed(Duration.zero);
    print('CHI ESCE DAL CERCHIO: domande all\'avvio $primaDomanda, uscite in '
        'pausa $uscite, domande dopo il ritorno ${porta.domande}');
    expect(primaDomanda, 1);
    expect(uscite, 1, reason: 'in pausa il telefono resta nel conto');
    expect(porta.domande, 2, reason: 'al ritorno non chiede subito');
    chi.dispose();
  });

  test('il server toglie dal conto chi esce', () {
    final cerchio = File('functions/src/cerchio.ts').readAsStringSync();
    final i = cerchio.indexOf('export const chiEOnline');
    final corpo = cerchio.substring(i, cerchio.indexOf('\n});', i));
    expect(corpo.contains('esce'), isTrue,
        reason: 'la porta non sa che qualcuno esce');
    expect(corpo.contains('.delete()'), isTrue,
        reason: 'chi esce resta nel conto fino alla fine della finestra');
  });
}

class _PortaContata extends PortaSpentaDelCerchio {
  int domande = 0;
  int uscite = 0;

  @override
  bool get viva => true;

  @override
  Future<int?> chiEOnline() async {
    domande++;
    return 1;
  }

  @override
  Future<void> esciDalCerchio() async {
    uscite++;
  }
}
