import '../maestro/maestro.dart';
import 'rito_alba_corpus.dart';

/// **LA RISPOSTA DEL DONO, cioè le prime due cose che si leggono.**
/// Ordine CO voce 17, 3 settembre 2026.
///
/// **La gerarchia che il fondatore ha dettato**, per esteso e nell'ordine:
///
/// 1. un titolo diretto, che è già una risposta;
/// 2. la risposta vera;
/// 3. il gesto, col suo scopo;
/// 4. la parola del giorno, spiegata;
/// 5. la fonte, breve e in fondo.
///
/// I punti dal terzo al quinto esistevano già ed erano scritti bene. **Quelli
/// che mancavano sono i primi due**, ed è il motivo per cui un Dono si apriva
/// senza dire niente: la prima cosa che si leggeva era un'istruzione, "Cosa
/// fai", e chi apriva doveva compiere il gesto per scoprire che cosa il giorno
/// gli stesse dicendo. **Un dono che chiede di lavorare prima di rispondere
/// non è un dono, è un compito.**
///
/// ## Da dove viene la risposta, e perché non è inventata
///
/// Non c'è nessun modello che scrive queste frasi, e non ci sarà: la regola di
/// casa dice che i contenuti astrologici non si generano, si interpretano.
/// **La risposta nasce da tre ingredienti che il Dono ha già in mano**, e da
/// nessun altro posto:
///
/// - **il fatto vero del cielo** che quel rito nomina, cioè l'ora del sorgere
///   calcolata per il luogo della persona, il segno in cui sta la Luna oggi, o
///   la sua fase. Sono dati misurati, non frasi;
/// - **la lente del Maestro** che porge il dono. Medora legge il tempo e la
///   direzione, Aura il corpo e l'energia, Caligo il simbolo. Sono le stesse
///   tre lenti con cui sono scritte le nove forme del rito, e questa è la
///   ragione per cui lo stesso cielo dà tre risposte diverse senza che
///   nessuna delle tre sia arbitraria;
/// - **la parola del giorno**, che appartiene già al gesto per legame
///   dichiarato, non per coincidenza di indici.
///
/// Nove coppie di lente e fatto, nove titoli e nove risposte: tre Maestri per
/// i tre fatti che il cielo di stamattina sa dire. Il Dono ne prende una sola,
/// quella del cielo che nomina davvero, e la parola ci entra dentro.
/// **Deterministico**: lo stesso giorno e lo stesso cielo danno sempre
/// la stessa risposta, come tutto il resto di questo rito.
///
/// ## Cosa una risposta non fa mai
///
/// **Non promette un esito.** È la stessa regola che governa il `perche` di
/// ogni parola del corpus: si dice che cosa il cielo di oggi indica, mai che
/// cosa succederà. Una risposta che promette è una previsione, e questa app
/// non ne fa.
class RispostaDelDono {
  const RispostaDelDono({required this.titolo, required this.risposta});

  /// Una frase sola, che si legge per prima ed è già la risposta.
  ///
  /// Sta in piedi da sola: chi legge solo questa riga e chiude l'app ha
  /// comunque ricevuto qualcosa.
  final String titolo;

  /// La risposta vera, due o tre frasi, col fatto del cielo dentro.
  final String risposta;

  /// **LA RISPOSTA DEL RITO DELL'ALBA E DEL SOFFIO**, composta dal fatto che
  /// il rito nomina e dalla lente di chi lo porge.
  ///
  /// [parola] è la parola del giorno, che entra nel titolo perché il titolo
  /// deve essere una risposta e non un'introduzione.
  static RispostaDelDono perIlRisveglio({
    required Maestro maestro,
    required DatoDelCielo fatto,
    required String parola,
    required String valoreDelFatto,
  }) {
    final titolo = _titoli[(maestro, fatto)]!;
    final risposta = _risposte[(maestro, fatto)]!;
    return RispostaDelDono(
      titolo: titolo.replaceAll('{parola}', parola.toLowerCase()),
      risposta: risposta
          .replaceAll('{valore}', valoreDelFatto)
          .replaceAll('{parola}', parola.toLowerCase()),
    );
  }

  /// I NOVE TITOLI, uno per lente e per fatto.
  ///
  /// Ognuno è una frase affermativa e chiusa, al presente, che dice come sta
  /// oggi la cosa di cui il Maestro si occupa. Nessuno comincia con una
  /// domanda e nessuno rimanda a cio' che viene dopo: **un titolo che rimanda
  /// non è una risposta, è un sommario.**
  static const Map<(Maestro, DatoDelCielo), String> _titoli = {
    // --- MEDORA, il tempo e la direzione ---
    (Maestro.medora, DatoDelCielo.oraDellAlba):
        'Oggi il tuo tempo è già cominciato, e chiede {parola}.',
    (Maestro.medora, DatoDelCielo.segnoLunare):
        'Oggi la direzione te la indica la Luna, e si chiama {parola}.',
    (Maestro.medora, DatoDelCielo.faseLunare):
        'Oggi il giorno è a un punto preciso del suo giro, e vuole {parola}.',
    // --- AURA, il corpo e l'energia ---
    (Maestro.aura, DatoDelCielo.oraDellAlba):
        'Oggi il tuo corpo ha già la luce che gli serve, e chiede {parola}.',
    (Maestro.aura, DatoDelCielo.segnoLunare):
        'Oggi la tua energia ha un colore solo, ed è {parola}.',
    (Maestro.aura, DatoDelCielo.faseLunare):
        'Oggi il respiro è la cosa più corta da cambiare, e porta {parola}.',
    // --- CALIGO, il simbolo ---
    (Maestro.caligo, DatoDelCielo.oraDellAlba):
        'Oggi la luce è tornata a un\'ora precisa, e il segno è {parola}.',
    (Maestro.caligo, DatoDelCielo.segnoLunare):
        'Oggi la Luna porta un segno che ti riguarda, ed è {parola}.',
    (Maestro.caligo, DatoDelCielo.faseLunare):
        'Oggi il buio e la luce stanno in una proporzione sola, e dice '
            '{parola}.',
  };

  /// LE NOVE RISPOSTE, col fatto vero dentro.
  ///
  /// Due o tre frasi. La prima nomina il dato misurato, la seconda dice che
  /// cosa quel dato indica per oggi, la terza, quando c'è, dice dove
  /// guardarlo nella giornata. **Mai un esito, mai una promessa.**
  static const Map<(Maestro, DatoDelCielo), String> _risposte = {
    (Maestro.medora, DatoDelCielo.oraDellAlba):
        'Il sole è sorto alle {valore}, e da quel momento la giornata corre '
            'per conto suo. Non è una fretta: è che il tempo di oggi ha già '
            'un verso, e tu puoi metterti dalla sua parte invece che contro. '
            'La cosa che decidi entro la prima ora è quella che regge fino a '
            'sera.',
    (Maestro.medora, DatoDelCielo.segnoLunare):
        'La Luna è in {valore}, e questo dice il modo in cui oggi le cose si '
            'muovono, non quali. Le giornate hanno un passo, e oggi il passo '
            'è questo: seguirlo costa meno che imporne un altro. Guarda dove '
            'stai andando, prima di guardare quanto in fretta.',
    (Maestro.medora, DatoDelCielo.faseLunare):
        'La Luna è {valore}, cioè il ciclo del mese è a questo punto e non a '
            'un altro. Ogni punto del giro chiede una cosa diversa: c\'è un '
            'tempo per cominciare, uno per tenere, uno per lasciare andare. '
            'Oggi sai a quale sei, e questo basta per non forzare.',
    (Maestro.aura, DatoDelCielo.oraDellAlba):
        'Il sole è sorto alle {valore}, e il corpo lo sa prima della testa: '
            'la luce del mattino è il segnale con cui si rimette in orario da '
            'solo. Non serve fare niente di più che riceverla. Quello che '
            'senti nella prima mezz\'ora è il tono su cui il resto si accorda.',
    (Maestro.aura, DatoDelCielo.segnoLunare):
        'La Luna è in {valore}, e la Luna è la parte di cielo che si occupa '
            'di come ti senti, non di cosa fai. Oggi la tua energia ha una '
            'forma sua, e riconoscerla vale più che spenderla bene. '
            'Ascoltala una volta, presto, prima che la giornata parli più '
            'forte.',
    (Maestro.aura, DatoDelCielo.faseLunare):
        'La Luna è {valore}, e le fasi lunari sono la misura più antica che '
            'esista del salire e dello scendere. Il corpo fa la stessa cosa, '
            'ogni giorno, e il respiro è il punto in cui la puoi toccare. '
            'Non c\'è niente da correggere: solo da sentire a che punto sei.',
    (Maestro.caligo, DatoDelCielo.oraDellAlba):
        'Il sole è tornato alle {valore}, e nessuna tradizione ha mai '
            'considerato ovvio che tornasse. Il segno di oggi è questo: una '
            'cosa che finisce e ricomincia lo stesso. Portalo con te dove '
            'oggi hai la tentazione di chiudere qualcosa per sempre.',
    (Maestro.caligo, DatoDelCielo.segnoLunare):
        'La Luna è in {valore}, e nella tradizione simbolica la Luna è ciò '
            'che si vede solo di riflesso: quello che oggi ti riguarda non ti '
            'arriva di fronte, ti arriva di lato. Non cercarlo dove guardi '
            'già. Guarda cosa si ripete.',
    (Maestro.caligo, DatoDelCielo.faseLunare):
        'La Luna è {valore}, e questa è la proporzione esatta fra la parte '
            'illuminata e quella in ombra, stanotte. Vale come immagine e '
            'basta, senza che nessuno prometta niente: oggi anche in te le '
            'due parti stanno così. Nessuna delle due va tolta.',
  };
}
