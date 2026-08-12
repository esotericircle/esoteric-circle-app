import '../config/app_flags.dart';
import 'sentiero_albero.dart';
import 'sentiero_costellazione.dart';
import 'sentiero_loto.dart';
import 'traguardo.dart';

export 'traguardo.dart';

/// IL REGISTRO DEI TRE SENTIERI, porta unica.
///
/// Chi ha bisogno dei traguardi passa di qui e non dai tre file di dati: cosi'
/// un sentiero nuovo si aggiunge in un punto solo, e le prove che contano
/// famiglie, Eos e ripetizioni guardano un elenco solo.
class Sentieri {
  const Sentieri._();

  static const List<Sentiero> tutti = Sentiero.values;

  /// I TRE AGGANCIO TRASVERSALI, gli unici traguardi che si ripetono sui tre
  /// sentieri per decisione: completare l'identita' vale su ogni cammino, e
  /// chiedere tre volte la stessa cosa sarebbe una tassa, non un traguardo.
  static const List<String> agganciTrasversali = [
    'identita:carta_natale',
    'identita:angelo_custode',
    'identita:animale_guida',
  ];

  static List<Traguardo> di(Sentiero sentiero) => switch (sentiero) {
        Sentiero.costellazione => sentieroDellaCostellazione,
        Sentiero.albero => sentieroDellAlbero,
        Sentiero.loto => sentieroDelLoto,
      };

  /// Tutti i 165, in fila.
  static List<Traguardo> get tuttiITraguardi =>
      [for (final s in tutti) ...di(s)];

  /// I cinquanta piccoli di un sentiero, in ordine di posizione.
  static List<Traguardo> miniDi(Sentiero sentiero) =>
      di(sentiero).where((t) => !t.eGrande).toList()
        ..sort((a, b) => a.posizione.compareTo(b.posizione));

  /// I cinque grandi di un sentiero, in ordine.
  static List<Traguardo> grandiDi(Sentiero sentiero) =>
      di(sentiero).where((t) => t.eGrande).toList()
        ..sort((a, b) => a.posizione.compareTo(b.posizione));

  /// IL CONTO DI UN SENTIERO, E CE N'E' UNO SOLO. Ordine S voce 03.
  ///
  /// **Vale 55 e non 50, per decisione di Mauro, e la ragione e' che i cinque
  /// grandi sono traguardi a tutti gli effetti**: valgono Eos, hanno le loro
  /// condizioni, e dalla voce S.02 sono anche le cinque stelle principali del
  /// disegno. Un totale che li esclude dice alla persona che quelle cinque cose
  /// non contano.
  ///
  /// **Prima i conti a schermo erano DUE**: la lista diceva "50 di 50" mentre le
  /// posizioni per sentiero sono cinquantacinque, e la riga della voce S.03 ne
  /// avrebbe portato un terzo sulla stessa schermata. Adesso chi mostra un totale
  /// lo chiede qui.
  static int quantiInTutto(Sentiero sentiero) => di(sentiero).length;

  /// A CHE PUNTO DEL CAMMINO STA UN TRAGUARDO, da 1 a 55.
  ///
  /// **Non e' la sua posizione**, e la differenza conta: le posizioni dei mini
  /// vanno da 1 a 50 e i cinque grandi stanno a 10, 20, 30, 40 e 50, cioe' i due
  /// elenchi si sovrappongono. Un grande CHIUDE la sua decina, quindi viene dopo
  /// il mini che porta lo stesso numero: "50 di 55" sarebbe stato il quarantanove
  /// per il mini e il cinquantacinque per il grande, e la stessa riga avrebbe
  /// detto due cose.
  static int ordineNelCammino(Traguardo traguardo) {
    final p = traguardo.posizione;
    if (traguardo.eGrande) return p + p ~/ 10;
    return p + (p - 1) ~/ 10;
  }

  /// LA SOMMA DEGLI EOS DI UN SENTIERO, calcolata e non scritta a mano.
  ///
  /// **QUI L'ORDINE O CHIEDE DUE COSE CHE NON POSSONO STARE INSIEME, e la
  /// contraddizione e' aritmetica, non di gusto.** L'ordine pretende 165
  /// traguardi, cioe' 55 per sentiero (50 piccoli piu' 5 grandi), e insieme
  /// che la somma torni a 1.960 per sentiero. Con la curva decisa (i primi
  /// tre piccoli da 20, gli altri da 10, i grandi 80, 150, 250, 400, 600) i
  /// due numeri non si incontrano:
  ///
  /// - 50 piccoli piu' 5 grandi fanno 530 + 1.480 = **2.010** per sentiero,
  ///   cioe' 6.030 in tutto;
  /// - per ottenere 1.960 servirebbero 45 piccoli, cioe' 50 traguardi per
  ///   sentiero e 150 in tutto, con i cinque grandi che PRENDONO il posto dei
  ///   piccoli alle posizioni 10, 20, 30, 40 e 50 invece di aggiungersi.
  ///
  /// Ha vinto il CONTEGGIO, 165, che e' nel titolo dell'ordine e nei criteri
  /// di accettazione ripetuto due volte. La somma resta verificata dal codice
  /// e non a mano, ma contro il totale che la curva produce davvero, non
  /// contro un numero scritto altrove: cambiare la curva per far tornare
  /// 1.960 avrebbe voluto dire decidere al posto di Mauro quanto vale un
  /// premio.
  static int eosDi(Sentiero sentiero) =>
      di(sentiero).fold(0, (somma, t) => somma + t.eos);

  /// La somma che la CURVA produce, ricavata dalla curva stessa e non
  /// ricopiata: e' il numero contro cui la prova confronta il totale vero.
  static int get eosAttesiPerSentiero {
    const piccoli = 50;
    var somma = 0;
    for (var posizione = 1; posizione <= piccoli; posizione++) {
      somma += posizione <= 3 ? 20 : 10;
    }
    for (final valore in Traguardo.eosDeiGrandi) {
      somma += valore;
    }
    return somma;
  }

  static int get eosInTutto =>
      tutti.fold(0, (somma, s) => somma + eosDi(s));

  /// FINO A DOVE ARRIVA IL GRATUITO, decisione gia' presa: i primi venti
  /// traguardi di ciascun sentiero. Dal ventunesimo serve il Tier 1, e gli
  /// Eos gia' presi restano sempre, perche' toglierli sarebbe una punizione
  /// per aver camminato.
  static const int ultimoTraguardoGratuito = 20;

  /// IN DEMO NESSUN TRAGUARDO E' CHIUSO, decisione di Mauro dell'ordine O:
  /// i tre Journal sono vivi in Demo con tutti i traguardi raggiungibili, e
  /// questo cambia lo scope che il Briefing Operativo congelava a "Coming
  /// soon". Fuori dalla Demo il gating resta quello deciso: gratuito fino al
  /// ventesimo, dal ventunesimo il Tier 1, e gli Eos gia' presi restano.
  static bool chiedeIlTier(Traguardo traguardo) =>
      !AppFlags.isDemo && traguardo.posizione > ultimoTraguardoGratuito;
}
