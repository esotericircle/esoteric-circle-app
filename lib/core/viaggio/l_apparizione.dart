import 'dart:math';

/// **L'APPARIZIONE FUORI DAL VIAGGIO.** Ordine DE voce 10, 11 settembre 2026.
///
/// *"Dopo la rivelazione, ogni tanto e senza preavviso, la sagoma dell'animale
/// attraversa il cielo della home, o passa dietro le carte durante una stesa.
/// Rara: proponi tu la frequenza con un numero e motivala, nell'ordine di un
/// paio di volte a settimana. Mai su richiesta, mai due volte nella stessa
/// sessione, mai durante un momento che chiede attenzione, come una festa o un
/// responso in arrivo. Non porta testo, non e' toccabile, non annuncia niente.
/// Passa e basta. Con Riduci Movimento non compare."*
///
/// **IL NUMERO, e la motivazione che l'ordine chiede.**
///
/// **Un tiro per sessione, con probabilita' un quarto, e mai due volte nello
/// stesso giorno.**
///
/// **Da dove viene il quarto.** L'ordine chiede *"un paio di volte a
/// settimana"*. Una persona che usa questa app la apre **fra una e due volte
/// al giorno**, cioe' fra sette e quattordici sessioni a settimana: con un
/// quarto di probabilita' per sessione l'apparizione capita **da due a tre
/// volte a settimana**, che e' esattamente l'ordine di grandezza chiesto.
///
/// **E il tetto di uno al giorno non e' una sicurezza in piu': e' cio' che
/// tiene il numero dentro l'ordine di grandezza anche per chi apre l'app otto
/// volte al giorno.** Senza quel tetto, chi la apre spesso la vedrebbe **due
/// volte al giorno**, e a quel punto non sarebbe piu' un'apparizione: sarebbe
/// un'animazione della home.
///
/// **PERCHE' UN TIRO SOLO PER SESSIONE, e non uno per schermata.** Perche'
/// l'ordine vieta due apparizioni nella stessa sessione, e il modo piu'
/// semplice di non violarlo e' **non poter** tirare due volte. Un contatore che
/// si ricorda di aver gia' tirato e' una cosa che si puo' dimenticare di
/// azzerare; un tiro solo no.
///
/// **MAI SU RICHIESTA**, che e' la riga piu' importante: non esiste nessun
/// comando, nessun pulsante, nessuna schermata che la faccia comparire. Se
/// esistesse, smetterebbe di essere un'apparizione e diventerebbe una
/// funzione.
class LApparizione {
  const LApparizione._();

  /// **QUANTE VOLTE SU CENTO SESSIONI.** Venticinque.
  static const double quanteProbabilita = 0.25;

  /// **QUANTE AL GIORNO, AL MASSIMO.** Una.
  static const int quanteAlGiorno = 1;

  /// **QUANTO DURA IL PASSAGGIO**, in millisecondi.
  ///
  /// Tremilacinquecento: sotto i tre secondi si legge come un guizzo e chi
  /// stava leggendo non fa in tempo ad alzare gli occhi; sopra i quattro
  /// diventa un'animazione che aspetta di essere guardata, e l'ordine dice
  /// *"passa e basta"*.
  static const Duration quantoDura = Duration(milliseconds: 3500);

  /// **SE L'APPARIZIONE PUO' MOSTRARSI ADESSO.**
  ///
  /// **Le porte sono cinque, in fila, e ognuna chiude per una ragione
  /// diversa.** L'ordine in cui sono scritte non e' casuale: prima le
  /// condizioni che non dipendono dal caso, cosi' chi legge il codice vede
  /// subito che il caso e' l'ultima cosa e non la prima.
  static bool siPuoMostrare({
    /// Falso finche' la persona non ha riconosciuto il suo animale: prima
    /// della quarta discesa non c'e' nessuna sagoma da far passare.
    required bool riconosciuto,

    /// Vero quando il sistema chiede meno movimento. **Regola di casa**, e vale
    /// anche quando il movimento e' bello.
    required bool senzaMoto,

    /// Vero durante una festa, un responso in arrivo, una scena che chiede di
    /// essere guardata. **Un'apparizione dentro un momento che chiede
    /// attenzione non e' un regalo: e' un disturbo.**
    required bool ilMomentoChiedeAttenzione,

    /// Quando si e' mostrata l'ultima volta, oppure nulla se mai.
    required DateTime? ultimaVolta,

    /// Adesso, iniettabile per le prove.
    required DateTime adesso,

    /// Vero se in questa sessione il tiro e' gia' stato fatto.
    required bool giaTirataInQuestaSessione,

    /// Il caso, iniettabile per le prove.
    Random? caso,
  }) {
    if (!riconosciuto) return false;
    if (senzaMoto) return false;
    if (ilMomentoChiedeAttenzione) return false;
    if (giaTirataInQuestaSessione) return false;
    if (ultimaVolta != null && _stessoGiorno(ultimaVolta, adesso)) return false;
    return (caso ?? Random()).nextDouble() < quanteProbabilita;
  }

  static bool _stessoGiorno(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// La chiave dove vive la data dell'ultima apparizione.
  static const String chiaveDellUltima = 'viaggio.apparizione.ultima';

  /// **QUANTE VOLTE A SETTIMANA, per chi apre l'app [sessioniAlGiorno] volte.**
  ///
  /// Serve alla prova che verifica il numero dichiarato invece di crederlo: il
  /// tetto di una al giorno fa da soffitto, quindi la funzione non e' una
  /// semplice moltiplicazione.
  static double quanteASettimana(double sessioniAlGiorno) {
    // La probabilita' di vederla in un giorno dato: uno meno la probabilita'
    // di sbagliare tutti i tiri di quel giorno, col tetto di una sola.
    final mancate = pow(1 - quanteProbabilita, sessioniAlGiorno).toDouble();
    return (1 - mancate) * 7;
  }
}
