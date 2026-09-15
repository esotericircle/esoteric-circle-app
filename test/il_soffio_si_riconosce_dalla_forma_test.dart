import 'dart:math' as math;

import 'package:esoteric_circle/core/rituals/forma_del_soffio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **IL SOFFIO SI RICONOSCE DALLA FORMA, NON DAL VOLUME.** Ordine DD voce 01,
/// 10 settembre 2026.
///
/// **Il fatto del fondatore**: il Soffio del Destino si apre da solo. Basta un
/// rumore nella stanza e i semi volano via senza che nessuno abbia soffiato.
///
/// **La causa era una riga**: `if (!_revealed && amp.current > -18)`, una
/// soglia di volume nuda. Qualunque suono sopra i meno diciotto decibel apriva
/// il dono.
///
/// **I CAMPIONI DI QUESTA GUARDIA SONO SINTETIZZATI, e va detto subito.** Non
/// sono registrazioni: sono segnali costruiti qui, con la forma che quelle
/// famiglie di suono hanno davvero.
///
/// - **la voce**: una fondamentale a centoventi hertz con dieci armoniche a
///   ampiezza calante, che e' il modello a sorgente e filtro della voce
///   parlata;
/// - **la musica**: un accordo di tre note pure, la piu' tonale delle
///   sorgenti;
/// - **il tonfo**: una botta larga di banda che si spegne in fretta, cioe' una
///   porta che sbatte;
/// - **il soffio**: rumore rosa filtrato, che e' cio' che un fiato sul
///   microfono produce davvero, con un inviluppo che sale e scende.
///
/// **Perche' sintetizzati e non registrati.** Una registrazione porta dentro
/// la stanza, il microfono e chi l'ha fatta, e una prova che dipende da un
/// file audio nel repository e' una prova che nessuno rifara' mai. Questi
/// segnali si possono rileggere e discutere riga per riga, ed e' quello che
/// una guardia deve permettere. **Il collaudo sul telefono resta**, e non lo
/// sostituisce niente.
///
/// **IL CONFRONTO E' CON LA REGOLA VECCHIA, come l'ordine chiede.** Ogni
/// campione viene passato alle due regole, e il referto dice quanti falsi
/// aperture faceva la soglia di volume e quante ne fa la forma.
void main() {
  const frequenzaDiCampionamento = 16000;

  /// La vecchia regola, ricostruita qui per poterla misurare: l'ampiezza di
  /// picco in decibel sopra i meno diciotto.
  bool laRegolaVecchia(List<int> campioni) {
    var picco = 0;
    for (final c in campioni) {
      final a = c.abs();
      if (a > picco) picco = a;
    }
    if (picco == 0) return false;
    final db = 20 * (math.log(picco / 32768.0) / math.ln10);
    return db > -18;
  }

  List<int> componi(
      double Function(double t) onda, double durata, double ampiezza) {
    final quanti = (frequenzaDiCampionamento * durata).round();
    return [
      for (var i = 0; i < quanti; i++)
        ((onda(i / frequenzaDiCampionamento) * ampiezza) * 32767)
            .round()
            .clamp(-32768, 32767),
    ];
  }

  /// **LA VOCE**: fondamentale piu' armoniche calanti.
  List<int> voce() {
    final rnd = math.Random(11);
    // Un filo di rumore, perche' nessuna voce e' un segnale puro.
    return componi((t) {
      var v = 0.0;
      for (var k = 1; k <= 10; k++) {
        v += math.sin(2 * math.pi * 120 * k * t) / k;
      }
      return v / 2.9 + (rnd.nextDouble() - 0.5) * 0.02;
    }, 0.6, 0.7);
  }

  /// **LA MUSICA**: tre note pure insieme.
  List<int> musica() => componi((t) {
        return (math.sin(2 * math.pi * 440 * t) +
                math.sin(2 * math.pi * 554.37 * t) +
                math.sin(2 * math.pi * 659.25 * t)) /
            3;
      }, 0.6, 0.8);

  /// **IL TONFO**: largo di banda ma corto, che e' la porta che sbatte.
  List<int> tonfo() {
    final rnd = math.Random(7);
    return componi((t) {
      final spegnimento = math.exp(-t * 60);
      return (rnd.nextDouble() * 2 - 1) * spegnimento;
    }, 0.6, 0.95);
  }

  /// **IL SOFFIO**: rumore d'aria che sale e scende, per mezzo secondo.
  List<int> soffio() {
    final rnd = math.Random(3);
    var b0 = 0.0, b1 = 0.0, b2 = 0.0;
    return componi((t) {
      final bianco = rnd.nextDouble() * 2 - 1;
      // Filtro semplice verso il rosa: l'aria ha piu' energia in basso.
      b0 = 0.99765 * b0 + bianco * 0.0990460;
      b1 = 0.96300 * b1 + bianco * 0.2965164;
      b2 = 0.57000 * b2 + bianco * 1.0526913;
      final rosa = (b0 + b1 + b2 + bianco * 0.1848) / 3.5;
      // L'inviluppo del fiato: sale, tiene, scende.
      final busta = math.sin(math.pi * (t / 0.6).clamp(0.0, 1.0));
      return rosa * busta;
    }, 0.6, 0.9);
  }

  test('LA FORMA SEPARA IL SOFFIO DAGLI ALTRI TRE, e il volume no', () {
    final campioni = <String, (List<int>, bool)>{
      'voce che parla': (voce(), false),
      'musica, tre note': (musica(), false),
      'tonfo, la porta che sbatte': (tonfo(), false),
      'soffio, il fiato sul microfono': (soffio(), true),
    };
    cardinaleMinimo(campioni.length, 4,
        cosa: 'famiglie di suono provate',
        perche: 'Con meno di quattro famiglie questa prova direbbe che la '
            'forma separa il soffio per non aver provato cio che lo confonde.');

    var falseVecchia = 0;
    var falseNuova = 0;
    final sbagliate = <String>[];
    for (final e in campioni.entries) {
      final (dati, eUnSoffio) = e.value;
      final vecchia = laRegolaVecchia(dati);
      final forma = FormaDelSoffio()..aggiungiInteri(dati);
      final nuova = forma.eSoffio;
      // ignore: avoid_print
      print('ORDINE DD VOCE 01: "${e.key}" -> planarita '
          '${forma.planarita.toStringAsFixed(3)}, energia '
          '${forma.energia.toStringAsFixed(4)}, fotogrammi di fila '
          '${forma.catenaInCorso} | soglia di volume: '
          '${vecchia ? "APRE" : "tace"} | forma: '
          '${nuova ? "APRE" : "tace"}');
      if (!eUnSoffio && vecchia) falseVecchia++;
      if (!eUnSoffio && nuova) falseNuova++;
      if (nuova != eUnSoffio) {
        sbagliate.add('"${e.key}": la forma dice '
            '${nuova ? "soffio" : "non soffio"} e non lo e');
      }
    }
    // ignore: avoid_print
    print('ORDINE DD VOCE 01: aperture false con la soglia di volume '
        '$falseVecchia su 3, con la forma $falseNuova su 3');

    expect(sbagliate, isEmpty,
        reason: 'la forma non separa il soffio: ${sbagliate.join(" | ")}');
    // **E IL CONFRONTO SI PRETENDE, non si stampa e basta.** Se un giorno la
    // forma tornasse a sbagliare quanto il volume, questa riga cade.
    expect(falseNuova, lessThan(falseVecchia),
        reason: 'la forma apre il dono per sbaglio $falseNuova volte e la '
            'vecchia soglia di volume $falseVecchia: la cura non ha migliorato '
            'niente');
    expect(falseNuova, 0,
        reason: 'la forma apre ancora il dono su $falseNuova suoni che non '
            'sono soffi');
  });

  test('REGOLA H: UN SOFFIO CORTO NON BASTA, e uno lungo si', () {
    // **La meta opposta.** Una regola che non apre mai passerebbe la prova
    // qui sopra su tre casi su quattro: qui si prova che il soffio vero apre,
    // e che il criterio della durata e quello che tiene fuori i colpi secchi.
    final lungo = soffio();
    final corto = lungo.take(FormaDelSoffio.campioniPerFinestra * 2).toList();

    final formaLunga = FormaDelSoffio()..aggiungiInteri(lungo);
    final formaCorta = FormaDelSoffio()..aggiungiInteri(corto);
    // ignore: avoid_print
    print('ORDINE DD VOCE 01: soffio lungo, fotogrammi di fila '
        '${formaLunga.catenaInCorso}; soffio di due finestre, fotogrammi '
        'di fila ${formaCorta.catenaInCorso}, e ne servono '
        '${FormaDelSoffio.fotogrammiRichiesti}');
    expect(formaLunga.eSoffio, isTrue,
        reason: 'un soffio vero non apre il dono: il ripiego col dito resta, '
            'ma il gesto del rito non funziona');
    expect(formaCorta.eSoffio, isFalse,
        reason: 'due finestre di aria bastano ad aprire il dono: cosi un '
            'colpo secco largo di banda passa lo stesso');
  });

  test('LA PLANARITA DICE IL VERO SUI DUE ESTREMI NOTI', () {
    // **La misura si ancora a due valori che si sanno in anticipo**, e non a
    // se stessa: il rumore bianco vale quasi uno, una nota pura quasi zero.
    // Senza questa prova, una trasformata scritta storta darebbe numeri
    // sbagliati e le soglie sopra si taglierebbero su quelli.
    final rnd = math.Random(5);
    final bianco = [
      for (var i = 0; i < FormaDelSoffio.campioniPerFinestra; i++)
        ((rnd.nextDouble() * 2 - 1) * 20000).round(),
    ];
    final nota = [
      for (var i = 0; i < FormaDelSoffio.campioniPerFinestra; i++)
        (math.sin(2 * math.pi * 440 * i / frequenzaDiCampionamento) * 20000)
            .round(),
    ];
    final pB = FormaDelSoffio.planaritaSpettrale(bianco);
    final pN = FormaDelSoffio.planaritaSpettrale(nota);
    // ignore: avoid_print
    print('ORDINE DD VOCE 01: planarita del rumore bianco '
        '${pB.toStringAsFixed(3)}, di una nota pura ${pN.toStringAsFixed(3)}');
    expect(pB, greaterThan(0.4),
        reason: 'il rumore bianco misura ${pB.toStringAsFixed(3)} di '
            'planarita: la trasformata o la media non stanno facendo il loro '
            'lavoro');
    expect(pN, lessThan(0.05),
        reason: 'una nota pura misura ${pN.toStringAsFixed(3)} di planarita, '
            'cioe sembra rumore: la misura non distingue niente');
  });
}
