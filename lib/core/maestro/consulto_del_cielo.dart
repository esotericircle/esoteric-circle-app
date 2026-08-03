import '../astro/celestial.dart';
import 'ancoraggio.dart';
import 'lente_del_cielo.dart';
import 'maestro.dart';
import 'natal_context.dart';
import 'voce_del_maestro.dart';

/// Una battuta del consulto: cosa il Maestro sta guardando adesso.
class BattutaDelConsulto {
  const BattutaDelConsulto({
    required this.corpo,
    required this.frase,
    required this.eGenerale,
    this.ancoraggio,
    this.luna,
  });

  /// Il dato da cui nasce, quando ce n'e' uno. La vista lo usa per scegliere
  /// COSA disegnare, e la lente per scegliere COME dirlo: cosi' l'immagine e
  /// la frase vengono dallo stesso dato invece che da due strade diverse.
  final Ancoraggio? ancoraggio;

  /// Il corpo o il punto guardato, per il segno visivo: `ascendente`, `luna`,
  /// `sole`. E' una chiave, non una frase: la scelta dell'immagine sta nella
  /// vista, il dato sta qui.
  final String corpo;

  /// Cosa si legge sotto, gia' in italiano. Per esempio "la tua Luna in Pesci".
  final String frase;

  /// Vero quando la battuta NON e' di questa persona ma del cielo di tutti.
  /// Serve alla vista per dirlo invece di lasciarlo credere.
  final bool eGenerale;

  /// La fase lunare vera di nascita, quando c'e'. Viaggia con la battuta perche'
  /// il disco si disegni dalla stessa misura da cui e' nato il suo nome: la
  /// vista non deve poter scegliere una frazione per conto proprio.
  final MoonIllumination? luna;

  @override
  String toString() => '$corpo: $frase';
}

/// Cosa il Maestro consulta mentre la risposta arriva.
///
/// **Funzione pura, e nessuna inferenza.** Le battute nascono dai dati gia' sul
/// dispositivo: costo zero, rete zero. Si provano senza montare uno schermo,
/// che e' la ragione per cui il testo vive qui e non dentro un widget.
///
/// **Un dato che manca fa SALTARE la sua battuta, e non la fa sostituire.** Due
/// battute vere valgono piu' di tre di cui una inventata: e' la stessa regola
/// dell'ancoraggio, vista dal lato dello schermo.
class ConsultoDelCielo {
  const ConsultoDelCielo._();

  /// Quante battute al massimo. Oltre tre l'attesa smette di essere un consulto
  /// e diventa un'attesa allungata a forza.
  static const int massimoBattute = 3;

  /// Quante battute nominano un DATO VERO di questa persona, al massimo.
  ///
  /// Due, e non tre, e il posto che resta va a una frase del Maestro. Il motivo
  /// non e' estetico: tre righe che elencano tre corpi sono un inventario, e un
  /// inventario non somiglia a nessuno che stia pensando. Una riga che dice
  /// "la tua Luna in Cancro" seguita da una che dice "seguo il transito che si
  /// chiude" e' un Maestro che guarda un dato TUO e poi ci ragiona sopra.
  static const int massimeAncorate = 2;

  /// Le battute per questa persona: prima cio' che e' suo, poi la voce di chi
  /// sta guardando.
  ///
  /// **L'ordine non e' estetico.** L'Ascendente dipende dall'ora e dal luogo
  /// esatti, la Luna dal giorno, il Sole dal mese: chi guarda vede scendere il
  /// grado di intimita' del dato, e **la prima cosa che legge e' la piu' sua**.
  /// Conta perche' con Riduci Movimento si mostra la prima e basta: si toglie
  /// il moto, non l'informazione, quindi la prima deve essere quella che vale.
  ///
  /// **Una frase generica si riconosce subito come teatro, una che sa chi sei
  /// no.** Per questo le ancorate vengono prima, e nascono dagli ANCORAGGI,
  /// cioe' dallo stesso elenco che il Maestro riceve nella persona: un secondo
  /// elenco scritto qui prima o poi divergerebbe da quello.
  ///
  /// [rotazione] fa girare le frasi del Maestro, cosi' due attese vicine non
  /// ripetono la stessa riga. Cresce di uno a ogni domanda.
  static List<BattutaDelConsulto> battutePer(
    NatalContext natal, {
    Maestro? maestro,
    int rotazione = 0,
  }) {
    final ancoraggi = VerificaAncoraggio.disponibiliPer(natal: natal);
    final battute = <BattutaDelConsulto>[];
    // Il posto si riserva a chi lo usa: senza un Maestro non c'e' nessuna
    // frase di firma da far entrare, quindi le ancorate si prendono tutto lo
    // spazio invece di lasciarne vuoto un terzo.
    final tetto = maestro == null ? massimoBattute : massimeAncorate;
    for (final ancoraggio in ancoraggi) {
      if (battute.length >= tetto) break;
      // Solo i dati che hanno un corpo da guardare: un fatto di memoria e' un
      // ottimo ancoraggio per la risposta, ma non e' qualcosa che si consulta
      // nel cielo.
      if (!_siGuardaNelCielo(ancoraggio.nome)) continue;
      battute.add(BattutaDelConsulto(
        corpo: _corpoDi(ancoraggio.nome),
        frase: maestro == null
            ? _fraseNeutra(ancoraggio)
            : LenteDelCielo.battuta(maestro, ancoraggio),
        eGenerale: false,
        ancoraggio: ancoraggio,
        luna: natal.moonIllumination,
      ));
    }

    // LE FRASI DEL MAESTRO, a completare.
    //
    // **Portano l'ancoraggio della battuta precedente**, e non e' un dettaglio:
    // il corpo a schermo si disegna da li'. Cosi' mentre la riga cambia, la
    // Luna vera di questa persona resta illuminata invece di lasciare il posto
    // a un punto anonimo. La scena non e' nuova, e' quella che c'era, estesa.
    if (maestro != null) {
      final frasi = VoceDelMaestro.di(maestro).frasiDelConsulto;
      final ereditato = battute.isEmpty ? null : battute.last;
      for (var i = 0; battute.length < massimoBattute; i++) {
        battute.add(BattutaDelConsulto(
          corpo: ereditato?.corpo ?? 'punto',
          frase: frasi[(rotazione + i) % frasi.length],
          // Senza nessun dato di questa persona una frase del Maestro NON e'
          // sua: e' vera di chiunque, e va dichiarata come tale invece di
          // lasciarla credere personale.
          eGenerale: ereditato == null,
          ancoraggio: ereditato?.ancoraggio,
          luna: ereditato?.luna,
        ));
      }
    }

    // Senza carta natale e senza Maestro si consulta il solo Sole, e LO SI
    // DICE: la battuta dichiara di essere generale, cosi' nessuno la scambia
    // per sua.
    if (battute.isEmpty) {
      return const [
        BattutaDelConsulto(
          corpo: 'sole',
          frase: 'il Sole di oggi, che è di tutti',
          eGenerale: true,
        ),
      ];
    }
    return battute;
  }

  /// Quali ancoraggi si guardano nel cielo. Un fatto di memoria no: e' un
  /// ancoraggio vero per la risposta, ma non e' un corpo da consultare.
  static bool _siGuardaNelCielo(String nome) => const {
        'ascendente',
        'segno lunare',
        'segno solare',
        'fase lunare di nascita',
      }.contains(nome);

  /// La chiave del corpo, per la vista.
  static String _corpoDi(String nome) => switch (nome) {
        'ascendente' => 'ascendente',
        'segno lunare' => 'luna',
        'segno solare' => 'sole',
        'fase lunare di nascita' => 'fase',
        _ => 'punto',
      };

  /// La frase senza lente, quando il Maestro non e' noto.
  static String _fraseNeutra(Ancoraggio ancoraggio) => switch (ancoraggio.nome) {
        'ascendente' => 'il tuo Ascendente in ${ancoraggio.valore}',
        'segno lunare' => 'la tua Luna in ${ancoraggio.valore}',
        'segno solare' => 'il tuo Sole in ${ancoraggio.valore}',
        'fase lunare di nascita' =>
          'la ${ancoraggio.valore} sotto cui sei nato',
        _ => ancoraggio.valore,
      };

  /// Vero se il consulto e' solo generale, cioe' non c'e' nulla di questa
  /// persona da guardare. La vista lo usa per dirlo con garbo.
  static bool eSoloGenerale(NatalContext natal) =>
      battutePer(natal).every((b) => b.eGenerale);
}
