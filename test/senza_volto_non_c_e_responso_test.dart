import 'dart:io';

import 'package:esoteric_circle/core/face/cancello_della_scansione.dart';
import 'package:esoteric_circle/features/maestri/aura/face/face_silhouette.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **SENZA VOLTO NON C'E' RESPONSO.** Ordine CR voce 01, 6 settembre 2026.
///
/// **Parole del fondatore**: *"attualmente ho provato a fare una foto a un muro
/// e cmq la funzionalita' mi ha dato un responso come se avessi fotografato un
/// viso. al di la' che E' UNA PRESA PER IL CULO ANCHE NEI MIEI CONFRONTI"*.
///
/// **IL DIFETTO, MISURATO E CON LA RIGA.** In
/// `face_constellation_screen.dart` il metodo che scatta cominciava cosi':
///
///     final contorni = _contorniVivi ?? FaceSilhouette.contorni();
///
/// `_contorniVivi` resta nullo finche' il rilevatore non trova un volto.
/// Inquadrando un muro non lo trova mai, e quel `??` metteva al suo posto
/// **la sagoma neutra disegnata a mano**, nata per il ripiego tattile e per le
/// anteprime: proporzioni scelte da un umano, non misurate su nessuno. Da li'
/// la lettura proseguiva identica a quella di un volto vero.
///
/// **Il ripiego tattile non e' il difetto.** Esiste per progetto, ed e' giusto
/// che chi non ha fotocamera possa comunque avere la sua lettura scegliendo i
/// tratti a mano. Il difetto e' che il ripiego **si attivava da solo al posto
/// di una scansione fallita, facendola sembrare riuscita**.
///
/// **La grandezza misurata e' l'ESITO, non l'immagine.** Questa prova non
/// guarda una foto: guarda che il cancello, davanti a una scansione senza
/// volto, restituisca un rifiuto e non una lettura. Un cancello che davanti al
/// nulla produce contorni e' un cancello aperto.
void main() {
  test('senza volto il cancello rifiuta, e dice perche', () {
    final esito = CancelloDellaScansione.giudica(contorniVivi: null);
    // ignore: avoid_print
    print('ORDINE CR VOCE 01: senza volto l esito e ${esito.runtimeType}');
    expect(esito, isA<NessunVolto>(),
        reason: 'senza volto rilevato il cancello lascia passare: e questa la '
            'presa in giro che il fondatore ha visto, un muro fotografato che '
            'produce la lettura di un viso');
    final perche = (esito as NessunVolto).perche;
    expect(perche.trim(), isNotEmpty,
        reason: 'il rifiuto non dice perche: chi resta senza responso deve '
            'sapere che cosa non ha funzionato, o crede che sia rotta l app');
  });

  test('e col volto vero il cancello lascia passare quei contorni', () {
    // Si usa la sagoma canonica COME SE fosse un volto rilevato: qui non e'
    // un ripiego, e' il dato che il rilevatore ha restituito. La differenza
    // fra le due prove non e' il contenuto, e' la PROVENIENZA.
    final veri = FaceSilhouette.contorni();
    final esito = CancelloDellaScansione.giudica(contorniVivi: veri);
    // ignore: avoid_print
    print('ORDINE CR VOCE 01: con un volto rilevato l esito e '
        '${esito.runtimeType}');
    expect(esito, isA<VoltoTrovato>(),
        reason: 'col volto rilevato il cancello rifiuta comunque: cosi non '
            'passa piu nessuno, ed e un difetto peggiore del primo');
    expect((esito as VoltoTrovato).contorni, same(veri),
        reason: 'il cancello restituisce contorni diversi da quelli rilevati: '
            'la lettura nascerebbe da un dato che nessuno ha misurato');
  });

  test('e la schermata non costruisce piu una lettura da un ripiego', () {
    // **SI LEGGE IL SORGENTE, E SI DICHIARA PERCHE'.** La schermata monta una
    // fotocamera vera, che in prova non esiste: montarla qui misurerebbe
    // l'assenza della fotocamera, non l'assenza del ripiego silenzioso.
    final schermata = File(
        'lib/features/maestri/aura/face/face_constellation_screen.dart');
    expect(schermata.existsSync(), isTrue,
        reason: 'la schermata della Costellazione del Viso non esiste piu');
    final testo = schermata.readAsStringSync();
    cardinaleMinimo(testo.length, 5000,
        cosa: 'caratteri del sorgente della schermata riletti',
        perche: 'Su un file vuoto la ricerca non trova nessun ripiego e la '
            'prova passa senza aver letto niente.');

    // Il pattern esatto del difetto: la sagoma di riserva messa al posto del
    // volto mancante, e da li' la lettura.
    final righe = testo.split(String.fromCharCode(10));
    final colpe = <String>[];
    for (var i = 0; i < righe.length; i++) {
      final r = righe[i];
      if (r.trimLeft().startsWith('//') || r.trimLeft().startsWith('///')) {
        continue;
      }
      if (r.contains('_contorniVivi ??') &&
          r.contains('FaceSilhouette.contorni()')) {
        colpe.add('riga ${i + 1}: ${r.trim()}');
      }
    }
    // ignore: avoid_print
    print('ORDINE CR VOCE 01: punti che sostituiscono il volto mancante con '
        'la sagoma disegnata ${colpe.length}');
    expect(colpe, isEmpty,
        reason: 'qui il volto mancante viene sostituito dalla sagoma '
            'disegnata a mano, e la lettura prosegue come se fosse vera:\n  '
            '${colpe.join("\n  ")}\n'
            'Il ripiego tattile resta, ma si sceglie: non si attiva da solo '
            'al posto di una scansione fallita.');
  });
}
