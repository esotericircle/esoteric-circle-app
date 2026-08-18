/// QUANDO IL TEST ARCHETIPO SI PUO' RIFARE. Ordine AO voce 06.
///
/// **La decisione di Mauro del 18 agosto 2026**: il test si puo' rifare, ma
/// non a piacere, e passano TRE MESI dall'ultimo. A schermo si dichiara il
/// tempo e la data in cui si potra', mai un pulsante spento senza spiegazione.
///
/// **Perche' tre mesi e non un giorno.** L'archetipo e' un DATO SOLO,
/// registrato il 6 agosto 2026: e' la figura che una persona porta, non una
/// risposta che si aggiorna. Rifarlo ogni giorno lo trasformerebbe in una
/// slot machine e toglierebbe senso a tutto cio' che vi poggia, dalla chat
/// di Aura al Passaporto all'Animale Guida. Tre mesi sono il tempo in cui
/// una persona cambia davvero abbastanza da rispondere in modo diverso.
///
/// **E se l'archetipo cambia, cambia SOLO l'emblema.** La carta natale non
/// si tocca mai, perche' e' astronomia e non psicologia: le posizioni dei
/// pianeti alla nascita non dipendono da come si risponde a un quiz. Sta
/// scritto qui perche' nessuno lo riscopra da capo.
///
/// **Questa regola vive da sola, e non dentro `ArchetypeAllowance`**, che e'
/// il tetto GIORNALIERO per livello e serve anche alla Costellazione del
/// Viso: mescolarle vorrebbe dire cambiare il Viso ogni volta che si cambia
/// idea sull'Archetipo.
class RipetizioneDelTest {
  const RipetizioneDelTest._();

  /// Quanto si aspetta fra un test e il successivo. Novanta giorni, che sono
  /// i tre mesi della decisione detti in un'unita' che non cambia di mese in
  /// mese.
  static const int giorniDiAttesa = 90;

  /// La stessa attesa come durata, per chi la vuole confrontare.
  static const Duration attesa = Duration(days: giorniDiAttesa);

  /// La data dalla quale si potra' rifare, dato l'ultimo test.
  ///
  /// **SI CONTANO I GIORNI CIVILI, non una durata assoluta**, ed e' la
  /// stessa lezione dell'ordine AN voce 01. Con `add(Duration(days: 90))` un
  /// test fatto il primo agosto 2026 dava il 29 ottobre invece del 30:
  /// in mezzo cade la fine dell'ora legale, che regala un'ora, e quell'ora
  /// sposta la data indietro di un giorno. Misurato da una prova, non
  /// immaginato.
  static DateTime quandoSiPotra(DateTime ultimo) => DateTime(
        ultimo.year,
        ultimo.month,
        ultimo.day + giorniDiAttesa,
        ultimo.hour,
        ultimo.minute,
        ultimo.second,
      );

  /// Se oggi si puo' rifare. Senza un test precedente si puo' sempre: il
  /// primo non aspetta nessuno.
  static bool siPuoRifare({DateTime? ultimo, required DateTime adesso}) {
    if (ultimo == null) return true;
    return !adesso.isBefore(quandoSiPotra(ultimo));
  }

  /// Quanti giorni mancano, zero se si puo' gia'.
  static int giorniAncora({DateTime? ultimo, required DateTime adesso}) {
    if (ultimo == null) return 0;
    final quando = quandoSiPotra(ultimo);
    if (!adesso.isBefore(quando)) return 0;
    // Si contano i giorni CIVILI, non le ore: chi apre l'app la mattina del
    // giorno buono deve leggere zero, non "mancano ancora sedici ore".
    final da = DateTime(adesso.year, adesso.month, adesso.day);
    final a = DateTime(quando.year, quando.month, quando.day);
    final giorni = a.difference(da).inDays;
    return giorni < 0 ? 0 : giorni;
  }

  /// Come si dice a schermo, con la data vera e mai un tempo vago.
  static String frase({required DateTime ultimo, required DateTime adesso}) {
    final giorni = giorniAncora(ultimo: ultimo, adesso: adesso);
    if (giorni == 0) return 'Puoi rifare il test quando vuoi.';
    final quando = quandoSiPotra(ultimo);
    final data = '${quando.day} ${_mesi[quando.month - 1]} ${quando.year}';
    if (giorni == 1) return 'Potrai rifare il test domani, il $data.';
    return 'Potrai rifare il test fra $giorni giorni, il $data.';
  }

  static const List<String> _mesi = [
    'gennaio',
    'febbraio',
    'marzo',
    'aprile',
    'maggio',
    'giugno',
    'luglio',
    'agosto',
    'settembre',
    'ottobre',
    'novembre',
    'dicembre',
  ];
}
