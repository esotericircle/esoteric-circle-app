import '../tempo/confine_del_giorno.dart';
import '../maestro/voce_del_maestro.dart';
import 'daily_elements.dart';

/// OGNI DONO DICE CHI PARLA, e lo dice da un punto solo.
///
/// **Perche' esiste.** I cinque Doni del giorno arrivano ciascuno dal suo
/// Maestro, ma a schermo non lo dichiarava nessuno: la persona leggeva un
/// responso senza sapere di chi fosse la voce, e i tre Maestri sono la prima
/// cosa che questo prodotto promette. La riga vive qui e non dentro le cinque
/// schermate, che sono di tre famiglie diverse (`RitualGiftCard` per Alba e
/// Soffio, `RitualView` per l'Oracolo, due schermate proprie per Tramonto e
/// Sogno): scriverla in ciascuna avrebbe voluto dire cinque punti che dicono la
/// stessa cosa, e il sesto Dono nascerebbe muto.
///
/// **Il verbo appartiene alla voce del Maestro, e non e' una scelta di stile.**
/// Si prende da `VoceDelMaestro.tipoDiChiusura`, che e' il dato con cui i tre
/// gia' si distinguono nelle risposte: Medora indica una direzione nel tempo,
/// Aura chiede un gesto del corpo, Caligo consegna un simbolo. Cosi' non nasce
/// un secondo elenco di caratteri da tenere allineato al primo, e un Maestro
/// nuovo non puo' esistere senza che il compilatore chieda come apre i suoi
/// Doni.
///
/// **Deterministica, mai a caso.** La formula si sceglie da Maestro, giorno e
/// DONO. Il dono nel seme non e' un di piu': il Rito dell'Alba e il Rito del
/// Sogno ruotano insieme, quindi lo stesso giorno hanno lo stesso Maestro, e
/// senza di lui aprirebbero con la stessa identica riga.
class VoceDelDono {
  const VoceDelDono._();

  /// La riga che apre il Dono, per esempio "Oggi Medora ti indica dove guarda
  /// il cielo".
  static String frase({
    required DailyElement dono,
    required DateTime giorno,
  }) {
    final maestro = DailyElements.maestroFor(dono, giorno);
    final formule = _formulePer(VoceDelMaestro.di(maestro).tipoDiChiusura);
    final quale = _seme([
      maestro.index,
      dono.index,
      _giornoOrdinale(giorno),
      giorno.year,
    ]) %
        formule.length;
    return 'Oggi ${maestro.displayName} ${formule[quale]}';
  }

  /// Le formule di ciascuna voce. Tre per tipo: meno di tre e la rotazione si
  /// riconosce a occhio nudo, molte di piu' e diventerebbero un corpus da
  /// verificare invece di una riga di servizio.
  ///
  /// Nessuna e' condivisa fra i tre, ed e' la stessa regola delle frasi
  /// dell'attesa: una formula che due Maestri potrebbero dire non dice chi
  /// parla, che e' esattamente cio' che questa riga esiste per dire.
  static List<String> _formulePer(TipoDiChiusura chiusura) =>
      switch (chiusura) {
        // Medora legge il tempo: indica quando, non cosa fare.
        TipoDiChiusura.direzioneNelTempo => const [
            'ti indica dove guarda il cielo',
            'ha letto il tuo momento',
            'ti mostra la finestra di oggi',
          ],
        // Aura chiede al corpo: invita, accompagna, non prescrive.
        TipoDiChiusura.gestoDelCorpo => const [
            'ti invita a fermarti un istante',
            'ti accompagna nel respiro',
            'ti chiede un gesto solo',
          ],
        // Caligo consegna un segno: lascia qualcosa da portare.
        TipoDiChiusura.simboloDaPortare => const [
            'ti lascia un segno da portare',
            'ha tracciato il tuo presagio',
            'ti consegna la sua chiave',
          ],
      };

  /// Il giorno dell'anno, che e' cio' che fa cambiare la formula da un giorno
  /// all'altro senza farla dipendere dall'ora.
  ///
  /// **ORDINE BL: normalizzare l'ora non bastava.** Questa riga portava
  /// gia' il giorno a mezzanotte, quindi dentro la giornata era stabile e
  /// il difetto dell'Oroscopo qui non si vedeva. Ma sottraeva due istanti
  /// LOCALI, e nei giorni del cambio d'ora il passo sbagliava: misurato
  /// con `TZ=Europe/Rome`, il 29 e il 30 marzo 2026 davano lo stesso 87,
  /// quindi il dono del 30 ripeteva parola per parola quello del 29.
  static int _giornoOrdinale(DateTime giorno) =>
      ConfineDelGiorno.giornoDellAnno(giorno);

  /// La stessa aritmetica FNV-1a a 32 bit che l'Oroscopo e il Messaggio
  /// dell'Animale usano gia' per le loro scelte deterministiche.
  ///
  /// **E' la terza copia, e va detto.** Le prime due stanno in
  /// `lib/core/horoscope/horoscope.dart` e in
  /// `lib/core/rituals/guide_animal_day.dart`, private tutte e due. Riunirle in
  /// un punto solo tocca due motori gia' verificati e non appartiene a questo
  /// ordine: resta un debito dichiarato, non una svista.
  static int _seme(List<int> valori) {
    var h = 0x811C9DC5;
    for (final v in valori) {
      for (var i = 0; i < 4; i++) {
        h ^= (v >> (i * 8)) & 0xFF;
        h = (h * 0x01000193) & 0xFFFFFFFF;
      }
    }
    return h;
  }
}
