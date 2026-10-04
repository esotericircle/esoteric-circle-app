// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/cerchio/i_segni_del_cerchio.dart';
import 'package:esoteric_circle/core/cerchio/il_cerchio_sociale.dart';
import 'package:esoteric_circle/features/cerchio/widgets/i_segni_ricevuti.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'porta_finta_del_cerchio_sociale.dart';

/// **I SEGNI DICONO IL VERO, ordine FA voci 02 e 06.**
///
/// - FA.02: "Facciamo la sinastria" prometteva un confronto fra due amici e
///   apriva la porta dove si sceglie un VIP. Ogni richiesta deve aprire una
///   funzione che esiste: la prova chiama `rottaDellaRichiesta`, il punto
///   solo da cui le richieste aprono, per ogni segno della categoria, e cade
///   col nome del segno se la destinazione non si raggiunge.
/// - FA.06: nessuna riga e nessuna risposta dei diciotto segni presuppone il
///   genere di chi legge.
///
/// **LE DESINENZE CERCATE**, dichiarate: dopo "sei" (anche "sei stato" o
/// "sei stata"), entro due parole, un participio in -ato, -ata, -uto, -uta,
/// -ito, -ita, -ati, -ate, oppure uno degli aggettivi che in italiano si
/// accordano con chi legge (caro, cara, benvenuto, benvenuta, pronto,
/// pronta, solo, sola, stanco, stanca, sicuro, sicura, contento, contenta,
/// felice escluso perche' non cambia). In piu' qualunque marca del genere fra
/// quadre: con l'ordine FA i segni hanno una forma sola.
void main() {
  final genere = RegExp(
      r'(?<![A-Za-zÀ-ÿ])sei\s+(?:stat[oaie]\s+)?(?:[A-Za-zÀ-ÿ’]+\s+)?'
      r'[A-Za-zÀ-ÿ]*(?:at[oaie]|ut[oaie]|it[oaie])(?![A-Za-zÀ-ÿ])',
      caseSensitive: false);
  final aggettivi = RegExp(
      r'(?<![A-Za-zÀ-ÿ])(?:car[oa]|benvenut[oa]|pront[oa]|sol[oa]|'
      r'stanc[oa]|sicur[oa]|content[oa])(?![A-Za-zÀ-ÿ])',
      caseSensitive: false);
  bool presupponeIlGenere(String riga) =>
      genere.hasMatch(riga) || aggettivi.hasMatch(riga) || riga.contains('[');

  testWidgets('FA.02: ogni richiesta apre una funzione che esiste',
      (tester) async {
    final richieste = ISegniDelCerchio.di(CategoriaDelSegno.richieste);
    cardinaleMinimo(richieste.length, 6,
        cosa: 'segni delle richieste',
        perche:
            'Le richieste sono sei: su un elenco vuoto nessuna mentirebbe.');
    final amico = PersonaDelCerchio.da(PortaFintaDelCerchioSociale.amico);
    final irraggiungibili = [
      for (final s in richieste)
        if (s.apre == null ||
            rottaDellaRichiesta(s.apre!,
                    amico: amico, nascita: DateTime(1990, 3, 5)) ==
                null)
          s.id,
    ];
    final quindici = ISegniDelCerchio.perId('facciamoLaSinastria')!;
    print('FA.02 LE RICHIESTE: ${richieste.length}, con una destinazione che '
        'non si raggiunge ${irraggiungibili.length} $irraggiungibili; il '
        'segno 15 "${quindici.testo}" apre ${quindici.apre?.name}');
    expect(irraggiungibili, isEmpty,
        reason: 'questi segni aprono una cosa che non esiste: '
            '$irraggiungibili');
    expect(quindici.testo, 'Sfidami con un VIP');
    expect(quindici.rigaDiChiRiceve,
        'Qualcuno ti sfida: con quale VIP fai più scintille?');
    expect(quindici.risposte, ['Accetto la sfida', 'Più tardi']);
    expect(quindici.apre, ArteDellaRichiesta.sinastriaVip);
    expect(quindici.categoria, CategoriaDelSegno.richieste);
  });

  test(
      'FA.06: nessuna riga dei diciotto segni presuppone il genere di chi '
      'legge', () {
    final righe = [
      for (final s in ISegniDelCerchio.tutti) ...[
        s.testo,
        s.rigaDiChiRiceve,
        ...s.risposte,
      ],
    ];
    cardinaleMinimo(righe.length, 72,
        cosa: 'righe e risposte dei segni',
        perche: 'Diciotto segni con titolo, riga e almeno due risposte.');
    final colGenere = [
      for (final r in righe)
        if (presupponeIlGenere(r)) r
    ];
    // Le forme cercate prendono davvero le righe col genere: la riga
    // dell'Architetto e la sua marca dell'ordine EZ.
    final diPrima = [
      'Qualcuno ha visto quanto sei arrivato lontano.',
      'Qualcuno ha visto quanto sei arrivata lontano.',
      '[Qualcuno ha visto quanto sei arrivato lontano.|altro|neutro]',
    ];
    print('FA.06 LE RIGHE DEI SEGNI: ${righe.length}, col genere di chi legge '
        '${colGenere.length} $colGenere; le righe di prima prese '
        '${diPrima.where(presupponeIlGenere).length} su ${diPrima.length}');
    expect(diPrima.where(presupponeIlGenere), hasLength(diPrima.length));
    expect(colGenere, isEmpty);
    expect(ISegniDelCerchio.perId('coraggio')!.rigaDiChiRiceve,
        'Qualcuno ha visto quanta strada hai fatto.');
  });
}
