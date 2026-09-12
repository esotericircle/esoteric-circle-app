import 'package:esoteric_circle/core/face/scansione_a_pose.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LA SCANSIONE NON SALTA AVANTI.** Ordine CR voci 03 e 04, 6 settembre 2026.
///
/// **Parole dell'ordine**: *"Ogni posa si considera compiuta solo quando
/// l'angolo misurato entra nella soglia e ci resta per il tempo dichiarato. Non
/// si passa alla successiva prima. Se la persona non riesce, la funzione lo
/// dice e ricomincia da quella posa, non salta avanti."*
///
/// **E QUESTA E' ANCHE LA PROVA DI VITALITA', CR.04.** Le quattro pose non sono
/// un vezzo scenico: una fotografia stampata o una faccia su uno schermo non
/// gira la testa. Se la sequenza si potesse compiere senza mai muoversi, il
/// cancello sarebbe finto e la funzione tornerebbe a essere quella che il
/// fondatore ha chiamato una presa in giro.
///
/// **LE SOGLIE SONO DELLA PROVA, NON DEL CODICE.** Se questa prova leggesse
/// `SoglieDellaScansione`, la taratura di domani la farebbe scendere insieme al
/// codice e la prova diventerebbe cieca: e' la stessa lezione della spezzatura
/// dell'Oroscopo, dove una soglia letta dal codice non provava piu' niente.
void main() {
  const soglie = _SogliePerLaProva();
  const passo = Duration(milliseconds: 100);

  /// Porta la scansione all'aggancio, che viene prima di ogni posa.
  ScansioneAPose agganciata() {
    final s = ScansioneAPose(soglie: soglie);
    s.passo(yaw: 0, pitch: 0, trascorso: passo);
    return s;
  }

  test('senza aggancio nessuna posa comincia', () {
    final s = ScansioneAPose(soglie: soglie);
    // Una persona che si presenta gia' girata: la prima posa sarebbe dentro
    // soglia, ma la testa non e' mai stata vista dritta.
    for (var i = 0; i < 30; i++) {
      s.passo(yaw: 40, pitch: 0, trascorso: passo);
    }
    // ignore: avoid_print
    print('ORDINE CR VOCE 03: senza aggancio, pose compiute ${s.compiute}, '
        'agganciato ${s.agganciato}');
    expect(s.agganciato, isFalse,
        reason: 'la scansione si e agganciata su una testa girata: l aggancio '
            'deve avvenire sul fronte, o le misure partono da un riferimento '
            'che non esiste');
    expect(s.compiute, 0,
        reason: 'una posa e stata compiuta senza che la testa sia mai stata '
            'vista dritta: chi si presenta gia girato avrebbe la prima posa '
            'gratis, e la scansione mentirebbe al primo passo');
  });

  test('una posa si compie solo tenendo l angolo per tutto il tempo', () {
    final s = agganciata();
    // Tre decimi su otto richiesti: dentro soglia, ma non abbastanza.
    for (var i = 0; i < 3; i++) {
      s.passo(yaw: 40, pitch: 0, trascorso: passo);
    }
    // ignore: avoid_print
    print('ORDINE CR VOCE 03: dopo 300 ms su ${soglie.tenuta.inMilliseconds} '
        'richiesti, pose compiute ${s.compiute}, progresso '
        '${s.progresso.toStringAsFixed(2)}');
    expect(s.compiute, 0,
        reason: 'la posa si e compiuta prima del tempo di tenuta: un '
            'attraversamento involontario conterebbe come posa');
    expect(s.progresso, greaterThan(0),
        reason: 'il progresso resta a zero mentre l angolo e dentro soglia: '
            'chi guarda non vede che il tempo sta passando');

    // Si completa la tenuta.
    for (var i = 0; i < 6; i++) {
      s.passo(yaw: 40, pitch: 0, trascorso: passo);
    }
    expect(s.compiute, 1,
        reason: 'tenuto l angolo per tutto il tempo, la posa non si e '
            'compiuta: la scansione non avanzerebbe mai');
  });

  test('e perdere l angolo azzera la tenuta, ma non toglie le pose fatte', () {
    final s = agganciata();
    for (var i = 0; i < 6; i++) {
      s.passo(yaw: 40, pitch: 0, trascorso: passo);
    }
    // Torna dritto prima del tempo: la tenuta si azzera.
    s.passo(yaw: 0, pitch: 0, trascorso: passo);
    // ignore: avoid_print
    print('ORDINE CR VOCE 03: perso l angolo, progresso '
        '${s.progresso.toStringAsFixed(2)}, pose compiute ${s.compiute}');
    expect(s.progresso, 0,
        reason: 'la tenuta non si azzera perdendo l angolo: si potrebbe '
            'compiere una posa a pezzi, entrando e uscendo');
    expect(s.compiute, 0,
        reason: 'perdere l angolo ha tolto o aggiunto una posa: deve '
            'ricominciare da quella corrente e da nessun altra');
  });

  test('e la sequenza intera pretende quattro movimenti diversi', () {
    // **QUI VIVE LA PROVA DI VITALITA'.** Si tenta di compiere tutta la
    // scansione restando fermi, che e' cio' che fa una fotografia stampata
    // messa davanti alla fotocamera.
    final fermo = agganciata();
    for (var i = 0; i < 200; i++) {
      fermo.passo(yaw: 0, pitch: 0, trascorso: passo);
    }
    // ignore: avoid_print
    print('ORDINE CR VOCE 04: restando immobili, pose compiute '
        '${fermo.compiute} su ${ScansioneAPose.ordine.length}');
    // **SI PRETENDE ZERO POSE, NON "la scansione non si compie".**
    //
    // La prima stesura diceva `expect(fermo.compiuta, isFalse)`, ed e'
    // restata VERDE sotto l'innesto della Regola A: rendendo la posa
    // destra sempre dentro soglia, restando immobili se ne compiva UNA,
    // le altre tre no, e la scansione intera restava incompiuta. La
    // pretesa misurava il pezzo sano accanto al pezzo rotto.
    //
    // Una posa compiuta senza muoversi e' gia' una crepa nel cancello:
    // la fotografia stampata ne prenderebbe una gratis, e il numero
    // giusto da pretendere e' ZERO.
    expect(fermo.compiute, 0,
        reason: 'restando immobili si compiono ${fermo.compiute} pose: ogni '
            'posa che si compie senza movimento e una crepa nella prova di '
            'vitalita, e una fotografia stampata passerebbe da li');
    expect(fermo.compiuta, isFalse,
        reason: 'la scansione si compie restando immobili: una fotografia '
            'stampata la supererebbe, e la prova di vitalita non esiste');

    // E adesso i quattro movimenti veri, uno per posa.
    final viva = agganciata();
    final angoli = <(double, double)>[(40, 0), (-40, 0), (0, 30), (0, -30)];
    var quante = 0;
    for (final a in angoli) {
      for (var i = 0; i < 9; i++) {
        if (viva.passo(yaw: a.$1, pitch: a.$2, trascorso: passo)) quante++;
      }
    }
    // ignore: avoid_print
    print('ORDINE CR VOCE 04: coi quattro movimenti, pose compiute '
        '${viva.compiute}, scansione compiuta ${viva.compiuta}');
    cardinaleMinimo(angoli.length, 4,
        cosa: 'movimenti diversi provati nella sequenza',
        perche: 'Con meno di quattro movimenti la prova direbbe che la '
            'sequenza si compie senza aver provato tutte le pose.');
    expect(quante, ScansioneAPose.ordine.length,
        reason: 'i quattro movimenti non hanno compiuto quattro pose: o la '
            'sequenza ne salta una, o ne conta due volte la stessa');
    expect(viva.compiuta, isTrue,
        reason: 'fatti tutti e quattro i movimenti la scansione non risulta '
            'compiuta: non finirebbe mai');
  });

  test('e ogni posa chiede un movimento suo, con parole sue', () {
    final richieste = {for (final p in Posa.values) p.richiesta};
    // ignore: avoid_print
    print('ORDINE CR VOCE 03: pose ${Posa.values.length}, richieste distinte '
        '${richieste.length}');
    cardinaleMinimo(Posa.values.length, 4,
        cosa: 'pose dichiarate nel corpus della scansione',
        perche: 'Con meno di quattro pose la prova non guarda la sequenza '
            'che l ordine chiede.');
    expect(richieste.length, Posa.values.length,
        reason: 'due pose chiedono la stessa cosa con le stesse parole: chi '
            'legge non sa che il movimento e cambiato');
    for (final p in Posa.values) {
      expect(p.richiesta.trim(), isNotEmpty,
          reason: 'la posa ${p.name} non dice cosa fare');
    }
  });
}

/// Soglie scelte QUI, e non lette dal codice dell'app: se scendessero insieme
/// a quelle vere, questa prova scenderebbe con loro e smetterebbe di provare.
class _SogliePerLaProva extends SoglieInUso {
  const _SogliePerLaProva();
  @override
  double get gradiDiProfilo => 20;
  @override
  double get gradiDiInclinazione => 15;
  @override
  double get tolleranzaDelFronte => 5;
  @override
  Duration get tenuta => const Duration(milliseconds: 800);
}
