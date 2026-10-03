/// I TEMPI DELLA CHIAMATA E DELLA SOVRAPPOSIZIONE. Ordine BO voce 06.
///
/// **Stanno in un file loro e non dentro la scena, per una ragione sola**: il
/// vincolo V1 dell'ordine dice che dal tocco sul VIP al verdetto non devono
/// passare piu' di sei secondi, e un vincolo che nessuno puo' misurare senza
/// aprire l'app non e' un vincolo. Qui i tempi sono un dato, e una prova li
/// somma.
class TempiDellaChiamata {
  const TempiDellaChiamata._();

  /// IL TETTO: dal tocco al verdetto.
  ///
  /// **OTTO SECONDI E NON PIU' SEI. Ordine CA voce 03.** Il vincolo V1 diceva
  /// sei, e con sei ogni aspetto restava acceso trecentottanta millesimi:
  /// parole del fondatore, "l'animazione e' troppo veloce e sembra bloccarsi a
  /// meta', e il testo che compare sotto non si fa in tempo a leggerlo". Il
  /// nome di un aspetto e' un testo, e un testo si legge o non si scrive.
  static const Duration tetto = Duration(milliseconds: 8000);

  /// Il ritratto sale al centro e il resto sprofonda.
  static const Duration laChiamata = Duration(milliseconds: 520);

  /// La sua ruota si disegna, tratto per tratto.
  static const Duration laSuaRuota = Duration(milliseconds: 1150);

  /// Dal basso sale la tua, e si disegna.
  static const Duration laTuaRuota = Duration(milliseconds: 1150);

  /// Le due ruote si avvicinano e si compenetrano, ruotando in senso opposto.
  ///
  /// **MILLE E DUECENTO, ordine CA voce 03**: e' il momento in cui i due cieli
  /// si fondono e in cui si vedono le due carte, ed e' anche il momento in cui
  /// il fondatore ha detto che la scena "sembra bloccarsi a meta'". Non si
  /// bloccava: passava troppo in fretta per leggersi come un gesto.
  static const Duration laSovrapposizione = Duration(milliseconds: 1200);

  /// Ogni aspetto si accende, uno alla volta, dal piu' stretto al piu' largo.
  ///
  /// **NOVECENTO E NON PIU' TRECENTOTTANTA. Ordine CA voce 03.** Sotto questa
  /// riga compare il nome dell'aspetto, e trecentottanta millesimi sono meno
  /// del tempo che serve a leggere tre parole: il testo cambiava prima che
  /// l'occhio ci arrivasse.
  static const Duration unAspetto = Duration(milliseconds: 900);

  /// Quanti aspetti si accendono al massimo.
  ///
  /// **Tre e non tutti.** Gli aspetti fra due cieli sono spesso piu' di dieci:
  /// accenderli tutti sfonderebbe il tetto dei sei secondi e nessuno li
  /// leggerebbe. Tre e' anche il numero che la card della sfida porta, quindi
  /// cio' che si vede accendersi e cio' che si condivide sono la stessa cosa.
  static const int aspettiAccesi = 3;

  /// Quanto dura la sequenza intera, aspetti compresi.
  static Duration intera({required int quantiAspetti}) {
    final accesi =
        quantiAspetti < aspettiAccesi ? quantiAspetti : aspettiAccesi;
    return laChiamata +
        laSuaRuota +
        laTuaRuota +
        laSovrapposizione +
        unAspetto * accesi;
  }

  /// Quanto dura al PEGGIO, cioe' con tutti e tre gli aspetti accesi.
  static Duration get alPeggio => intera(quantiAspetti: aspettiAccesi);

  /// Il salto al verdetto, quando la persona tocca durante la scena.
  ///
  /// **Un tocco in qualunque momento porta al risultato**, dice il vincolo V1,
  /// e chi ne fa dieci di seguito non deve essere punito. Non e' zero: una
  /// dissolvenza brevissima evita il taglio secco, e resta ben sotto i
  /// trecento millesimi che l'ordine concede.
  static const Duration ilSalto = Duration(milliseconds: 180);

  /// **CON RIDUCI MOVIMENTO ogni momento resta, fermo e dichiarato.** Vincolo
  /// V2: nessuna fase si salta in silenzio. Le durate scendono al minimo
  /// leggibile, cosi' la sequenza si vede tutta senza che niente si muova.
  static const Duration passoFermo = Duration(milliseconds: 260);

  static Duration interaFerma({required int quantiAspetti}) {
    final accesi =
        quantiAspetti < aspettiAccesi ? quantiAspetti : aspettiAccesi;
    return passoFermo * (4 + accesi);
  }
}

/// I TEMPI DEL VERDETTO CHE SI COMPONE. Ordine BO voce 07.
///
/// **Il numero grande non compare: si compone contando.** Un numero che appare
/// gia' scritto e' un numero letto da un archivio; un numero che sale davanti
/// agli occhi e' un calcolo che sta accadendo. La differenza e' tutta li'.
class TempiDelVerdetto {
  const TempiDelVerdetto._();

  /// Quanto dura il conteggio. **Sta dentro la finestra 700..1.100 che
  /// l'ordine fissa**, e non e' un numero scelto a caso dentro quella
  /// finestra: novecento e' il centro, cioe' il punto piu' lontano da tutti e
  /// due i bordi.
  static const Duration ilConteggio = Duration(milliseconds: 900);

  /// Lo sfalsamento fra una barra e l'altra.
  ///
  /// **Le barre si riempiono in sequenza e non insieme**: quattro barre che
  /// partono allo stesso istante sono un'unica animazione con quattro teste,
  /// e l'occhio non sa dove guardare.
  static const Duration fraUnaBarraELaltra = Duration(milliseconds: 130);

  /// Quanto ci mette una barra a riempirsi.
  static const Duration unaBarra = Duration(milliseconds: 520);

  /// La pausa prima del titolo della coppia, che **arriva per ultimo e da
  /// solo**: e' la frase che la persona porta via, e arriva quando tutto il
  /// resto ha finito di muoversi.
  static const Duration primaDelTitolo = Duration(milliseconds: 180);

  static const Duration ilTitolo = Duration(milliseconds: 320);

  /// La finestra che l'ordine concede al conteggio.
  static const Duration conteggioMinimo = Duration(milliseconds: 700);
  static const Duration conteggioMassimo = Duration(milliseconds: 1100);

  /// Quanto dura il verdetto intero, con [quanteBarre] barre.
  static Duration intera({required int quanteBarre}) =>
      ilConteggio +
      fraUnaBarraELaltra * (quanteBarre - 1) +
      unaBarra +
      primaDelTitolo +
      ilTitolo;
}
