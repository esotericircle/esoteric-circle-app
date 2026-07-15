import '../astro/zodiac.dart';
import '../maestro/maestro.dart';
import 'daily_rituals.dart';

/// Il tipo di dono del Rito dell'Alba cambia col Maestro di turno.
///
/// Medora orienta con il cielo del giorno, Aura offre un'intenzione energetica,
/// Caligo lascia un monito o un simbolo. L'etichetta rende esplicito il tipo di
/// dono in cima allo stato rivelato.
enum DawnGiftKind {
  orientamento('Orientamento del giorno'),
  intenzione('Intenzione del giorno'),
  monito('Monito del giorno');

  const DawnGiftKind(this.label);

  final String label;
}

/// Il dono del giorno del Rito dell'Alba, in forma strutturata e deterministica.
///
/// Nasce dalla data, quindi lo stesso giorno rende sempre lo stesso dono e a
/// mezzanotte cambia. Il messaggio usa il segno dell'utente quando disponibile,
/// con un ripiego generico quando manca. La parola del giorno e' breve e
/// memorabile, pensata per essere messa in risalto e condivisa.
///
/// L'aggancio a Gemini a runtime, per un dono davvero personale, sara' un layer
/// successivo dietro questa stessa forma: qui resta tutto deterministico, con
/// tabelle per Maestro e per giorno.
class DawnGift {
  const DawnGift({
    required this.maestro,
    required this.kind,
    required this.message,
    required this.word,
    required this.personalized,
  });

  /// Il Maestro di turno che porge il dono.
  final Maestro maestro;

  /// Il tipo di dono, coerente col Maestro.
  final DawnGiftKind kind;

  /// Il messaggio breve e personale del giorno.
  final String message;

  /// La parola del giorno, breve, da mettere in risalto e condividere.
  final String word;

  /// Vero se il messaggio usa il segno dell'utente, falso se e' il ripiego
  /// generico.
  final bool personalized;

  /// Il dono di [date], col segno [sign] dell'utente se disponibile.
  static DawnGift of(DateTime date, {Zodiac? sign}) {
    final maestro = DailyRituals.dawnMaestro(date);
    final day = date.difference(DateTime(date.year)).inDays;
    final pool = _pools[maestro]!;
    final entry = pool[day % pool.length];
    final personalized = sign != null;
    final message = personalized
        ? _weave(maestro, sign, entry.body)
        : _capitalize(entry.body);
    return DawnGift(
      maestro: maestro,
      kind: _kinds[maestro]!,
      message: message,
      word: entry.word,
      personalized: personalized,
    );
  }

  // Intreccia il segno nel corpo, con un attacco coerente col Maestro. I corpi
  // sono scritti in minuscolo iniziale, cosi' l'attacco personale scorre; senza
  // segno, il corpo si presenta con l'iniziale maiuscola.
  static String _weave(Maestro maestro, Zodiac sign, String body) {
    switch (maestro) {
      case Maestro.medora:
        return 'Per il tuo ${sign.italianName}, $body';
      case Maestro.aura:
        return '${sign.italianName}, $body';
      case Maestro.caligo:
        return '${sign.italianName}, ascolta bene: $body';
    }
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  static const Map<Maestro, DawnGiftKind> _kinds = {
    Maestro.medora: DawnGiftKind.orientamento,
    Maestro.aura: DawnGiftKind.intenzione,
    Maestro.caligo: DawnGiftKind.monito,
  };

  // Tabelle per Maestro e per giorno. Corpo in minuscolo iniziale, parola del
  // giorno breve. Nessun trattino lungo nei testi.
  static const Map<Maestro, List<_GiftEntry>> _pools = {
    Maestro.medora: [
      _GiftEntry('oggi il cielo favorisce le scelte nette: una sola, chiara, vale più di mille pensieri.', 'Chiarezza'),
      _GiftEntry('un transito lento ti sostiene: fidati del lavoro già fatto, i frutti stanno arrivando.', 'Fiducia'),
      _GiftEntry('la Luna orienta un legame: una parola sincera, detta oggi, apre più di un discorso lungo.', 'Sincerità'),
      _GiftEntry('il Sole scalda un progetto: dagli luce oggi, senza pretendere tutto subito.', 'Slancio'),
    ],
    Maestro.aura: [
      _GiftEntry('porta oggi una sola intenzione nel respiro: rallenta e lascia che la strada si mostri.', 'Respiro'),
      _GiftEntry('la tua energia chiede dolcezza: un sorso d\'acqua, tre respiri, poi il mondo.', 'Dolcezza'),
      _GiftEntry('posa una mano sul cuore e va\' al tuo ritmo: oggi non a quello della fretta.', 'Ritmo'),
      _GiftEntry('apri il petto e le spalle: fai spazio dentro e qualcosa di sopito si rimette in moto.', 'Apertura'),
    ],
    Maestro.caligo: [
      _GiftEntry('varca la soglia del giorno con fermezza: scegli una cosa da onorare e onorala.', 'Soglia'),
      _GiftEntry('non disperdere il fuoco: un gesto solo, deciso, prima di sera e basta quello.', 'Fuoco'),
      _GiftEntry('la nebbia premia chi ha una meta: cammina deciso, il giorno riconosce il passo saldo.', 'Meta'),
      _GiftEntry('custodisci una brace piccola e salda: non serve un incendio a reggere la giornata.', 'Brace'),
    ],
  };
}

/// Una voce delle tabelle: il corpo del messaggio e la parola del giorno.
class _GiftEntry {
  const _GiftEntry(this.body, this.word);

  final String body;
  final String word;
}
