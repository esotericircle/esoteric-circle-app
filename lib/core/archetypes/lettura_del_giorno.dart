import '../astro/moon_phase.dart';
import 'archetype.dart';
import 'archetype_corpus.dart';
import 'archetype_transits.dart';

/// LA LETTURA DI OGGI DEL TUO ARCHETIPO. Ordine AO voce 06.
///
/// **Cosa risolve.** Chi aveva gia' fatto il Test Archetipo, riaprendolo, non
/// poteva fare piu' niente: la soglia gli chiedeva di ricominciare e basta.
/// Ma l'archetipo e' UN DATO SOLO, deciso il 6 agosto 2026 e registrato in
/// `docs/STATO_VIVO.md`, e le linee guida trasversali dicono che le feature
/// identitarie fisse espongono una card del giorno variabile sui transiti.
/// La figura sta ferma, la lettura cambia: quella lettura e' questa, e non
/// era mai stata mostrata.
///
/// **Da dove viene, e da dove NON viene.** Viene dai pianeti attivi oggi,
/// gli stessi che il test usa nella modalita' col cielo, e dalla tabella
/// curata di `ArchetypeTransits`, che lega ogni pianeta a due archetipi.
/// Non viene da un modello: e' composta con un calcolo deterministico sul
/// giorno, quindi due aperture nello stesso giorno dicono la stessa cosa e
/// domani dice un'altra. E' la stessa regola di tutto il resto del Cerchio,
/// dove i contenuti esoterici poggiano su tradizioni documentate e l'AI al
/// massimo li interpreta.
///
/// **IL LIMITE, dichiarato invece che nascosto.** Il dispositivo sa calcolare
/// in locale due soli corpi, il Sole e la Luna: e' scritto in
/// `ArchetypeSky.pianetiCalcolabili`, che vale due. La tabella dei transiti
/// lega il Sole a Eroe e Sovrano e la Luna a Custode e Innocente, quindi per
/// gli altri OTTO archetipi la riga dei pianeti non arriverebbe mai, e chi
/// ha il Mago leggerebbe ogni giorno la stessa frase. Per questo la lettura
/// ha DUE strati: la riga dei pianeti quando c'e', e sempre la riga della
/// LUNA DI OGGI, che e' un dato astronomico vero, cambia ogni notte e vale
/// per chiunque. Non si inventano pianeti che non sappiamo calcolare.
///
/// **La luna crescente e la luna calante non dicono la stessa cosa**, e non
/// e' una scelta nostra: la tradizione lega il crescere a cio' che si semina
/// e il calare a cio' che si lascia andare. Le due frasi vengono dal corpus
/// dell'archetipo, la luce quando cresce e l'ombra quando cala, quindi non
/// c'e' un secondo corpus da tenere allineato.
class LetturaDelGiorno {
  const LetturaDelGiorno._({
    required this.archetipo,
    required this.righe,
    required this.pianetiInGioco,
  });

  /// L'archetipo di questa persona, che non cambia mai da qui.
  final Archetype archetipo;

  /// Le righe della lettura, una per pianeta che oggi tocca l'archetipo.
  /// Quando il cielo guarda altrove ne resta una sola, che lo dice.
  final List<String> righe;

  /// I pianeti che oggi toccano questo archetipo, in ordine.
  final List<Pianeta> pianetiInGioco;

  /// Vero quando oggi nessun pianeta attivo tocca questo archetipo: resta la
  /// riga della Luna, che vale per chiunque.
  bool get ilCieloGuardaAltrove => pianetiInGioco.isEmpty;

  /// LA RIGA DELLA LUNA DI OGGI, per questo archetipo.
  ///
  /// Cresce: si semina, e si nomina la LUCE dell'archetipo. Cala: si lascia
  /// andare, e si nomina la sua OMBRA, che non e' un rimprovero ma la parte
  /// da cui ci si congeda.
  static String rigaDellaLuna(Archetype archetipo, DateTime quando) {
    final luna = MoonPhase.forDate(quando);
    final voce = ArchetypeCorpus.di(archetipo);
    // **SOLO LA PRIMA FRASE, e non il paragrafo intero.** Le voci del corpus
    // sono paragrafi di cinque frasi, scritti per la scheda del responso:
    // infilarne uno dentro una riga della lettura del giorno dava un muro di
    // testo dove serviva una notizia. Si prende la prima frase, che nel
    // corpus e' sempre quella che dice la cosa in se'.
    final parte = _primaFrase(luna.waxing ? voce.luce : voce.ombra);
    final minuscola =
        parte.isEmpty ? parte : parte[0].toLowerCase() + parte.substring(1);
    return luna.waxing
        ? 'La ${luna.italianName} semina: oggi il tuo ${archetipo.nome} '
            'cresce dove $minuscola'
        : 'La ${luna.italianName} lascia andare: oggi il tuo '
            '${archetipo.nome} può posare $minuscola';
  }

  /// La cornice, la stessa del test: il cielo non causa, si accosta.
  static const String cornice = ArchetypeTransits.corniceSincronicita;

  /// La prima frase di un paragrafo, punto compreso tolto.
  static String _primaFrase(String testo) {
    final punto = testo.indexOf('. ');
    if (punto < 0) {
      return testo.endsWith('.') ? testo.substring(0, testo.length - 1) : testo;
    }
    return testo.substring(0, punto);
  }

  /// Compone la lettura di oggi.
  ///
  /// [pianetiAttivi] arriva da `ArchetypeSky.pianetiDelGiorno`, cioe' dalla
  /// stessa porta che usa il test: una seconda strada per sapere che cielo
  /// c'e' oggi sarebbe la seconda verita' sullo stesso dato.
  static LetturaDelGiorno per(
    Archetype archetipo,
    Set<Pianeta> pianetiAttivi, {
    DateTime? quando,
  }) {
    // L'ordine dei pianeti e' quello della tabella curata, non quello di un
    // insieme: un insieme non ha ordine e la lettura cambierebbe posizione
    // da un'apertura all'altra senza che il cielo sia cambiato.
    final tocchi = <Pianeta>[
      for (final voce in ArchetypeTransits.tabella.entries)
        if (pianetiAttivi.contains(voce.key) && voce.value.contains(archetipo))
          voce.key,
    ];
    return LetturaDelGiorno._(
      archetipo: archetipo,
      pianetiInGioco: tocchi,
      righe: [
        for (final pianeta in tocchi)
          ArchetypeTransits.motivazione(pianeta, archetipo),
        // LA RIGA DELLA LUNA C'E' SEMPRE, ed e' il secondo strato: senza di
        // lei otto archetipi su dodici leggerebbero ogni giorno la stessa
        // frase, perche' i loro pianeti in locale non si calcolano.
        rigaDellaLuna(archetipo, quando ?? DateTime.now()),
      ],
    );
  }
}
