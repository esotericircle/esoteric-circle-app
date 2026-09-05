import 'dart:io';

import 'package:esoteric_circle/core/rituals/daily_elements.dart';
import 'package:esoteric_circle/design_system/theme/abito_del_responso.dart';
import 'package:esoteric_circle/design_system/theme/accento_del_maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'sorgenti_di_lib.dart';

/// **NESSUN ACCENTO DICHIARA UN FONDO CHE NON HA SOTTO.** Ordine CQ voce 6.04,
/// 4 settembre 2026.
///
/// **Parole del fondatore**: *"c'e' pure una riga di testo blu che non si vede
/// sullo sfondo cosmico."* E' la riga *"Oggi Medora ha letto il tuo momento"*
/// dell'Arcano del Giorno.
///
/// **IL DIFETTO, MISURATO.** Il colore non e' scritto a mano: passa da
/// `AccentoDelMaestro`, che schiarisce l'accento finche' il contrasto sulla
/// superficie **dichiarata** non raggiunge 4,5. La superficie dichiarata era
/// `neutralDeepest`, cioe' quasi nero. Il meccanismo portava il blu di Medora
/// a `#426DEE`, che su quel nero misura **4,58**: passa, con **otto centesimi
/// di margine**. Sul fondo vero, che e' il cosmo e non il nero, lo stesso blu
/// misura **3,15**.
///
/// **PERCHE' LE GUARDIE DEL CONTRASTO DEGLI ORDINI CI E CL NON LO HANNO
/// PRESO.** Misurano il contrasto **contro la superficie che il codice
/// dichiara**, e quel conto era giusto: 4,58 sopra 4,5. Il difetto non stava
/// nel conto, stava nel dato in ingresso. **Una guardia che verifica un
/// calcolo non puo' accorgersi che il numero da cui parte e' sbagliato**, ed
/// e' la stessa forma della cecita' che questo ordine ha gia' incontrato oggi
/// sulle stelle e sul suono della carta.
///
/// **La grandezza nuova**: non "il contrasto e' sopra la soglia", ma **la
/// superficie dichiarata non e' piu' scura di quella che la schermata dipinge
/// davvero**. Piu' scura vuol dire un contrasto sopravvalutato, cioe' un
/// verde che copre un testo illeggibile.
void main() {
  /// **IL CONFRONTO PASSA DALLA PORTA DELLA CASA.** `contrastoFra` e' la
  /// stessa funzione che il codice usa per decidere l'accento: rifarne una
  /// copia qui vorrebbe dire due conti della stessa cosa, che e' la famiglia
  /// di difetti piu' numerosa di questo progetto. Un fondo e' piu' scuro di
  /// un altro se contrasta di piu' col bianco.
  double quantoEScuro(Color fondo) =>
      AccentoDelMaestro.contrastoFra(const Color(0xFFFFFFFF), fondo);

  test('le schermate dei riti dichiarano il fondo che dipingono davvero', () {
    // Le quattro schermate che montano la riga di chi parla. L'elenco sta
    // qui e non si scopre: scoperto leggendo una cartella sarebbe verde il
    // giorno che una schermata sparisce.
    const schermate = <String, DailyElement>{
      'lib/features/rituals/day_oracle_screen.dart': DailyElement.oracle,
      'lib/features/rituals/dream_rite_screen.dart': DailyElement.night,
      'lib/features/rituals/sunset_rune_screen.dart': DailyElement.rune,
      'lib/features/rituals/ritual_gift_card.dart': DailyElement.dawn,
    };
    final sbagliate = <String>[];
    var guardate = 0;
    for (final voce in schermate.entries) {
      final testo = File(voce.key).readAsStringSync();
      guardate++;
      final dove = testo.indexOf('superficie:');
      if (dove < 0) {
        sbagliate.add('${voce.key.split("/").last}: non dichiara nessuna '
            'superficie');
        continue;
      }
      final riga = testo.substring(dove, dove + 90);
      // **IL FONDO PEGGIORE E' L'UNICA DICHIARAZIONE ONESTA.** Qualunque
      // colore scritto a mano invecchia appena il fondale cambia, e un fondo
      // piu' scuro di quello vero fa passare un testo che non si legge.
      final onesta = riga.contains('superficiePeggiore');
      if (!onesta) {
        sbagliate.add('${voce.key.split("/").last}: dichiara '
            '${riga.split(String.fromCharCode(10)).first.trim()}');
      }
    }
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.04: schermate guardate $guardate, che dichiarano '
        'un fondo diverso da quello vero ${sbagliate.length}');
    cardinaleMinimo(guardate, 4,
        cosa: 'schermate dei riti che montano la riga di chi parla',
        perche: 'Con zero schermate la prova direbbe che nessuna sbaglia per '
            'non averne aperta nessuna.');
    expect(sbagliate, isEmpty,
        reason: 'queste schermate dichiarano al contrasto un fondo piu scuro '
            'di quello che dipingono, quindi il conto passa e il testo non si '
            'legge:${String.fromCharCode(10)}'
            '${sbagliate.join(String.fromCharCode(10))}');
  });

  test('e sul fondo vero i tre accenti stanno sopra la soglia', () {
    // **QUESTO E' IL CONTO CHE MANCAVA**, e si fa sul fondo peggiore invece
    // che su quello dichiarato.
    final peggiore = AbitoDelResponso.di(DailyElement.oracle).superficiePeggiore;
    final magri = <String>[];
    final tavola = <String>[];
    for (final maestro in Maestro.values) {
      final accento = AccentoDelMaestro.su(maestro, superficie: peggiore);
      final k = AccentoDelMaestro.contrastoFra(accento, peggiore);
      tavola.add('${maestro.id} ${k.toStringAsFixed(2)}');
      if (k < AccentoDelMaestro.contrastoMinimo) {
        magri.add('${maestro.id}: ${k.toStringAsFixed(2)}');
      }
    }
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.04: contrasto sul fondo VERO, '
        '${tavola.join(", ")}; soglia ${AccentoDelMaestro.contrastoMinimo}');
    cardinaleMinimo(tavola.length, 3,
        cosa: 'Maestri misurati sul fondo vero',
        perche: 'Con zero Maestri il conto direbbe che vanno tutti bene.');
    expect(magri, isEmpty,
        reason: 'sul fondo che la schermata dipinge davvero questi accenti '
            'non arrivano alla soglia: ${magri.join(", ")}');
  });

  test('e nessun sorgente scrive a mano un fondo piu scuro del vero', () {
    // **LA PORTA E' UNA SOLA.** Un colore scritto a mano accanto a una
    // superficie e' il modo in cui questo difetto e' nato, e sarebbe il modo
    // in cui tornerebbe.
    final quotaVera = quantoEScuro(
        AbitoDelResponso.di(DailyElement.oracle).superficiePeggiore);
    final scritti = <String>[];
    var guardati = 0;
    for (final file in sorgentiDiLib()) {
      guardati++;
      final testo = file.readAsStringSync();
      for (final m in RegExp(r'superficie:\s*(?:const\s*)?Color\(0x([0-9A-Fa-f]{8})\)')
          .allMatches(testo)) {
        final valore = int.parse(m.group(1)!, radix: 16);
        if (quantoEScuro(Color(valore)) > quotaVera) {
          scritti.add('${file.path.split(RegExp(r"[\\/]")).last}: '
              '0x${m.group(1)}');
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.04: sorgenti guardati $guardati, superfici '
        'scritte a mano piu scure del vero ${scritti.length}');
    cardinaleMinimo(guardati, 300,
        cosa: 'sorgenti di lib riletti in cerca di superfici scritte a mano',
        perche: 'Su un elenco vuoto la prova sarebbe verde per non aver '
            'aperto niente.');
    expect(scritti, isEmpty,
        reason: 'queste superfici sono scritte a mano e sono piu scure del '
            'fondo vero: ${scritti.join(", ")}');
  });
}
