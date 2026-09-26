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

  /// I TRAGUARDI CHE SI RIPETONO SUI TRE SENTIERI, e **adesso non ce n'e'
  /// nessuno.** Ordine U voce 01.
  ///
  /// **Erano tre, ed erano un difetto, non una decisione.** Carta natale, Angelo
  /// Custode e Animale Guida stavano su tutti e tre i sentieri con la stessa
  /// condizione: un gesto solo li accendeva tutti e tre insieme, quindi la stessa
  /// animazione partiva tre volte di seguito e gli Eos si pagavano tre volte per
  /// lo stesso motivo. Misurato: **sessanta Eos per un gesto solo.** Il commento
  /// che stava qui diceva che ripetere l'identita' era una scelta, "chiedere tre
  /// volte la stessa cosa sarebbe una tassa": ma non era chiesta tre volte, era
  /// PAGATA tre volte, che e' il contrario.
  ///
  /// **La lista resta, vuota, e non si cancella.** Serve alle prove che
  /// distinguono una ripetizione voluta da una sbagliata: cancellarla vorrebbe
  /// dire togliere il posto dove una ripetizione futura andrebbe dichiarata, e
  /// allora la prossima nascerebbe in silenzio come queste tre.
  /// `test/un_gesto_una_festa_un_pagamento_test.dart` cade se una condizione
  /// compare su piu' di un traguardo.
  static const List<String> agganciTrasversali = [];

  static List<Traguardo> di(Sentiero sentiero) => switch (sentiero) {
        Sentiero.costellazione => sentieroDellaCostellazione,
        Sentiero.albero => sentieroDellAlbero,
        Sentiero.loto => sentieroDelLoto,
      };

  /// Tutti i 165, in fila.
  static List<Traguardo> get tuttiITraguardi =>
      [for (final s in tutti) ...di(s)];

  /// **I TRAGUARDI CHE UNA PERSONA PUO' DAVVERO RAGGIUNGERE OGGI.**
  /// Ordine CF voce 01.
  ///
  /// Sono i 165 meno i dormienti, cioe' le voci che il corpus dichiara
  /// scritte ma non ancora agganciate a un gesto vivo. **Serve perche'
  /// l\'anello del livello si riempie su questo denominatore e non sui
  /// 165**: un anello che non puo' chiudersi nemmeno giocando per anni
  /// sarebbe una promessa falsa disegnata addosso al volto della persona.
  ///
  /// Il giorno che un dormiente si sveglia questo numero cresce da solo,
  /// perche' legge il corpus e non una costante scritta a mano.
  static List<Traguardo> get raggiungibili =>
      tuttiITraguardi.where((t) => !t.dormiente).toList();

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
  /// **COL CORPUS DELLA REVISIONE C LA SOVRAPPOSIZIONE NON ESISTE PIU', ordine
  /// AR voce 02.** Le posizioni del file vanno da 1 a 55 senza doppioni, e i
  /// cinque grandi stanno a 11, 22, 33, 44 e 55: la posizione E' gia' l'ordine
  /// nel cammino, e il calcolo che rimetteva in fila due elenchi sovrapposti
  /// adesso non ha piu' niente da rimettere in fila. Tenerlo avrebbe spostato
  /// i numeri di cinque posti, e la persona avrebbe letto "60 di 55".
  static int ordineNelCammino(Traguardo traguardo) => traguardo.posizione;

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
  /// **IL TOTALE PER SENTIERO VIENE DAL CORPUS, ordine AR voce 02.** Prima si
  /// RICALCOLAVA con la formula (venti ai primi tre, dieci agli altri, piu' la
  /// scala dei grandi), e una formula che ricalcola un dato e' una seconda
  /// verita' che un giorno diverge. Il numero e' 2.010 per sentiero e lo dice
  /// il file: la guardia confronta la somma vera con questo.
  static const int eosAttesiPerSentiero = 2010;

  /// E in tutto, sui tre sentieri.
  static const int eosAttesiInTutto = 6030;

  static int get eosInTutto => tutti.fold(0, (somma, s) => somma + eosDi(s));

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
