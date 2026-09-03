import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'codice_senza_testo.dart';

/// **IL CUORE DEI PREFERITI STA SEMPRE NELLO STESSO ANGOLO.**
/// Ordine CO voce 20, 3 settembre 2026.
///
/// Parole del fondatore: il cuore dei preferiti centrato, e verificato ovunque.
///
/// **Verificato: non stava nello stesso posto.** Il cuore ha due case, ed è
/// giusto che ne abbia due: con una barra vive dentro di lei, senza barra
/// fluttua sopra la scena. Ma le due case stavano in due angoli diversi. Nella
/// barra al capo SINISTRO, accanto alla freccia Indietro, dove l'ordine AL voce
/// 08 l'ha messo e dove la voce AM voce 03 l'ha lasciato dopo che la capsula
/// dell'identità se n'era andata. Fluttuante, in alto a DESTRA.
///
/// **Due angoli per la stessa cosa vogliono dire cercarla.** Chi passa da
/// un'arte con la barra a una senza deve ritrovare un comando che aveva già
/// imparato, e cercare un comando imparato è il modo più sicuro di smettere di
/// usarlo.
///
/// Si è scelto il sinistro perché è quello che una decisione guardata ha già
/// confermato: si sposta il cuore sovrapposto, che di decisioni non ne aveva
/// nessuna.
void main() {
  final rotta =
      File('lib/features/maestri/rotta_arte.dart').readAsStringSync();
  final codice = codiceSenzaTesto(rotta);

  test('il cuore fluttuante sta a sinistra, come quello nella barra', () {
    // Il blocco del cuore sovrapposto: si guarda LUI e non tutto il file,
    // perché in questo file ci sono altri Positioned che non lo riguardano.
    final i = codice.indexOf('class ConCuore');
    expect(i, greaterThanOrEqualTo(0),
        reason: 'il cuore sovrapposto non esiste piu: le arti senza barra '
            'restano senza nessun modo di mettere fra i preferiti');
    final blocco = codice.substring(i);
    expect(blocco, contains('left: 0,'),
        reason: 'IL CUORE FLUTTUANTE E TORNATO A DESTRA, e quello nella barra '
            'sta a sinistra: due angoli per la stessa cosa vogliono dire '
            'cercarla ogni volta');
    expect(blocco.substring(0, blocco.indexOf('CuorePreferita(id: id)')),
        isNot(contains('right: 0,')),
        reason: 'il cuore fluttuante e ancorato anche a destra: con tutti e '
            'due i lati fissati si stira per la larghezza dello schermo');
  });

  test('il cuore nella barra sta al capo sinistro, e ci resta', () {
    // La barra lo monta dentro `leading`, che è il capo sinistro per
    // costruzione: se qualcuno lo spostasse in `actions` finirebbe a destra e
    // le due case tornerebbero a divergere, questa volta dall'altro lato.
    expect(codice, contains('const CuoreNellaBarra(),'),
        reason: 'la barra non monta piu il cuore');
    final leading = codice.indexOf('leading: Row(');
    final azioni = codice.indexOf('actions: widget.azioni');
    final cuore = codice.indexOf('const CuoreNellaBarra(),');
    expect(leading, greaterThanOrEqualTo(0));
    expect(cuore, greaterThan(leading),
        reason: 'il cuore non sta piu dentro il leading della barra');
    if (azioni >= 0) {
      expect(cuore, lessThan(azioni),
          reason: 'IL CUORE E FINITO FRA LE AZIONI, cioe a destra, mentre '
              'quello fluttuante sta a sinistra: le due case divergono di '
              'nuovo, dall altro lato');
    }
  });

  test('le case del cuore sono due, e sono queste', () {
    // **UN CARDINALE SULLE CASE, non sui file.** Se domani nascesse un terzo
    // posto in cui il cuore si monta, questa prova non lo saprebbe e le due
    // che conosce resterebbero in ordine: il conto lo dice.
    var case_ = 0;
    if (codice.contains('class CuoreNellaBarra')) case_++;
    if (codice.contains('class ConCuore')) case_++;
    cardinaleMinimo(case_, 2,
        cosa: 'case dichiarate del cuore dei preferiti',
        perche: 'Se una delle due sparisse, questa prova girerebbe sull altra '
            'e sarebbe verde per non aver guardato quella che manca.');

    // E il cuore vero, quello che disegna, e uno solo: le due case lo montano,
    // non lo riscrivono.
    expect('class CuorePreferita'.allMatches(codice).length, 1,
        reason: 'esiste piu di un cuore che disegna: due disegni della stessa '
            'cosa divergono, ed e cosi che i due angoli sono nati');
  });
}
