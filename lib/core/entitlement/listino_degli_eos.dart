import 'tier.dart';

/// UNA VOCE DEL LISTINO: cosa si compra, quanto costa, e quante volte al
/// giorno e' gratis per ciascun piano.
class VoceDelListino {
  const VoceDelListino({
    required this.id,
    required this.nome,
    required this.costo,
    required this.budget,
    required this.gratisAlGiorno,
  });

  /// L'identificativo dell'arte nel catalogo, quando ne ha uno.
  final String id;

  /// Come si chiama per una persona.
  final String nome;

  /// Quanti Eos costa una volta finito il gratuito del giorno.
  final int costo;

  /// Il budget del server che conta gli usi gratuiti, quando esiste: e' la
  /// stessa parola che `functions/src/budget.ts` conosce, mai una copia.
  final String? budget;

  /// Quante volte al giorno e' gratis, per piano: Viandante, Iniziato,
  /// Adepto, Illuminato. Nullo vuol dire senza tetto.
  final Map<Tier, int?> gratisAlGiorno;

  /// Quante ne restano oggi con questo piano, dato quante se ne sono gia'
  /// usate. Nullo se il piano non ha tetto: li' non c'e' un residuo da dire.
  int? quanteRestano(Tier tier, int giaUsate) {
    final tetto = gratisAlGiorno[tier];
    if (tetto == null) return null;
    final resta = tetto - giaUsate;
    return resta < 0 ? 0 : resta;
  }
}

/// IL LISTINO DEGLI EOS, IN UN PUNTO SOLO. Ordine AN voce 05.
///
/// **Perche' un listino e non un numero sparso per le schermate.** Un costo
/// scritto dentro la schermata che lo mostra e' un costo che diverge dal
/// prossimo ritocco: la stessa stesa costerebbe 120 in un posto e 150 in un
/// altro, e nessuna prova se ne accorgerebbe. Qui c'e' il dato, e le
/// schermate lo leggono.
///
/// **I numeri.** Vengono dall'economia approvata il 2 agosto e dai briefing,
/// che li confermano dove si sovrappongono
/// (`docs/02_Briefing_Progetto_Definitivo.md`, tabella della sezione 19):
/// carta di tarocchi extra 50, sinastria extra 150, domanda extra a un
/// Maestro 80, stesa completa 250. Il 120 della stesa a tre carte non sta
/// nei briefing e arriva come decisione di Mauro del 18 agosto: e' scritto
/// qui perche' si sappia da dove viene.
///
/// **Cosa gli Eos NON comprano mai**, e non e' una dimenticanza: la memoria
/// dei Maestri, la voce, la profondita' delle risposte, la compatibilita' a
/// tre livelli e le altre funzioni di relazione continuativa restano
/// dell'abbonamento. Un Eos compra un'esperienza singola e conclusa, mai un
/// accesso che dura. La voce AN.06 usa questa distinzione per dire, davanti
/// a ogni lucchetto, quale strada esiste davvero.
class ListinoDegliEos {
  const ListinoDegliEos._();

  /// LA STESA A TRE CARTE.
  static const stesaTreCarte = VoceDelListino(
    id: 'tarot_spread_three',
    nome: 'Una stesa a tre carte',
    costo: 120,
    budget: 'gettate',
    gratisAlGiorno: {
      Tier.free: 1,
      Tier.tier1: null,
      Tier.tier2: null,
      Tier.tier3: null,
    },
  );

  /// LA CARTA SINGOLA IN PIU'.
  static const cartaExtra = VoceDelListino(
    id: 'tarot_card_extra',
    nome: 'Una carta in più',
    costo: 50,
    budget: null,
    gratisAlGiorno: {
      Tier.free: 1,
      Tier.tier1: 3,
      Tier.tier2: null,
      Tier.tier3: null,
    },
  );

  /// LA DOMANDA IN PIU' A UN MAESTRO.
  static const domandaExtra = VoceDelListino(
    id: 'maestro_question',
    nome: 'Una domanda in più',
    costo: 80,
    budget: 'domande',
    gratisAlGiorno: {
      Tier.free: 3,
      Tier.tier1: 5,
      Tier.tier2: 10,
      Tier.tier3: null,
    },
  );

  /// LA SINASTRIA CELEB IN PIU'.
  static const sinastriaExtra = VoceDelListino(
    id: 'synastry_vip',
    nome: 'Una sinastria in più',
    costo: 150,
    budget: 'confronti',
    gratisAlGiorno: {
      Tier.free: 0,
      Tier.tier1: 3,
      Tier.tier2: 5,
      Tier.tier3: null,
    },
  );

  /// LA STESA COMPLETA, la Croce Celtica.
  static const stesaCompleta = VoceDelListino(
    id: 'tarot_spread_full',
    nome: 'Una stesa completa',
    costo: 250,
    budget: null,
    gratisAlGiorno: {
      Tier.free: 0,
      Tier.tier1: 0,
      Tier.tier2: 0,
      Tier.tier3: 0,
    },
  );

  static const List<VoceDelListino> tutte = [
    stesaTreCarte,
    cartaExtra,
    domandaExtra,
    sinastriaExtra,
    stesaCompleta,
  ];

  /// La voce di un'arte, oppure nulla se quell'arte non si compra a Eos.
  static VoceDelListino? perArte(String id) {
    for (final voce in tutte) {
      if (voce.id == id) return voce;
    }
    return null;
  }

  /// **LA SOGLIA DELLA CONFERMA, dichiarata.** Sotto questa cifra la spesa
  /// parte col tocco, perche' chiedere conferma per ogni piccola cosa
  /// insegna a rispondere di si' senza leggere. Sopra, si chiede una volta,
  /// con la possibilita' di non farselo chiedere piu'.
  static const int sogliaDellaConferma = 100;

  /// COME SI CHIAMA LA MONETA, in un punto solo: la parola vive qui e chi
  /// scrive una cifra la compone, invece di incollarla accanto al numero.
  static const String moneta = 'Eos';

  /// Come si scrive un costo, in un punto solo: "120 Eos".
  static String prezzo(int costo) => '$costo $moneta';

  /// Come si dice quanto resta oggi, in lingua del Cerchio.
  static String residuo(int quante, String cosa) {
    if (quante <= 0) return 'Nessuna $cosa gratis oggi';
    if (quante == 1) return '1 $cosa rimasta oggi';
    return '$quante $cosa rimaste oggi';
  }
}
