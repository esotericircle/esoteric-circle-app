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
/// **L'ANGOLO E' IL DESTRO, e la decisione e' del fondatore.** Ordine CQ voce
/// 1.02, 3 settembre 2026.
///
/// L'ordine CO aveva scelto il sinistro, per allineare il cuore fluttuante a
/// quello della barra. **A sinistra pero' c'e' la freccia Indietro**, e sul
/// telefono i due si sono trovati addosso: nelle Rune attaccati, nella Stesa e
/// nell'Oroscopo fusi in un segno solo, con la freccia che non si poteva piu'
/// premere. Parole del fondatore: *"IO AVEVO CHIESTO SOLO DI CENTRARLA
/// VERTICALMENTE. MA CAZZO, IL RISULTATO VA GUARDATO PRIMA DI CHIUDERE UNA
/// VOCE."*
///
/// **La pretesa di questa guardia non cambia di una virgola**: le due case
/// stanno nello stesso angolo. Cambia quale, ed e' una decisione, non una
/// misura. Il fatto che una sovrapposizione non ci sia lo misura
/// `il_cuore_non_copre_niente_test`, sui riquadri veri.
void main() {
  final rotta =
      File('lib/features/maestri/rotta_arte.dart').readAsStringSync();
  final codice = codiceSenzaTesto(rotta);

  test('il cuore fluttuante sta a destra, come quello nella barra', () {
    // Il blocco del cuore sovrapposto: si guarda LUI e non tutto il file,
    // perché in questo file ci sono altri Positioned che non lo riguardano.
    final i = codice.indexOf('class ConCuore');
    expect(i, greaterThanOrEqualTo(0),
        reason: 'il cuore sovrapposto non esiste piu: le arti senza barra '
            'restano senza nessun modo di mettere fra i preferiti');
    final blocco = codice.substring(i);
    expect(blocco, contains('right: 0,'),
        reason: 'IL CUORE FLUTTUANTE E TORNATO A SINISTRA, dove vive la '
            'freccia Indietro: e da li che nasce la sovrapposizione che il '
            'fondatore ha visto');
    expect(blocco.substring(0, blocco.indexOf('CuorePreferita(id: id)')),
        isNot(contains('left: 0,')),
        reason: 'il cuore fluttuante e ancorato anche a sinistra: con tutti e '
            'due i lati fissati si stira per la larghezza dello schermo');
  });

  test('il cuore nella barra sta fra le azioni, cioe a destra', () {
    // **DENTRO `actions`, e non e' un dettaglio.** In una Row due elementi
    // non si possono sovrapporre per costruzione: mettere il cuore fra le
    // azioni rende IMPOSSIBILE la sovrapposizione col punto interrogativo,
    // invece di doverla misurare ogni volta. E il `leading` resta alla sola
    // freccia, che e' il comando che non si puo' coprire.
    expect(codice, contains('const CuoreNellaBarra(),'),
        reason: 'la barra non monta piu il cuore');
    final cuore = codice.indexOf('const CuoreNellaBarra(),');
    final azioni = codice.indexOf('actions: [const CuoreNellaBarra()');
    expect(azioni, greaterThanOrEqualTo(0),
        reason: 'IL CUORE E TORNATO NEL LEADING, accanto alla freccia: e la '
            'sovrapposizione che il fondatore ha visto sul telefono');
    expect(cuore, greaterThanOrEqualTo(azioni),
        reason: 'il cuore sta prima delle azioni, cioe nel leading');
    // E il cuore e' il PRIMO fra le azioni, cosi' il punto interrogativo
    // resta all'estremo destro dove chi cerca aiuto lo cerca.
    expect(codice, contains('actions: [const CuoreNellaBarra(), ...widget.azioni]'),
        reason: 'il cuore non e piu il primo fra le azioni: il punto '
            'interrogativo si sposta da dove la persona lo ha imparato');
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
