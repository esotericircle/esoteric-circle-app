import 'maestro.dart';

/// Cosa dice un Maestro quando non ha potuto rispondere davvero.
///
/// E' un dato, non una stringa dentro un controllore: i tre ripieghi si
/// enumerano, si provano e si correggono in un punto solo. La regola che vive
/// qui e' una sola e vale sempre: **un ripiego dichiara di essere un ripiego**,
/// nel codice con [ChatMessage.ripiego] e a schermo con [etichetta]. Prima la
/// chat mostrava "Le stelle si sono velate un istante" per tutti e tre i
/// Maestri, senza dire che non era una risposta, e il Consulta sostituiva la
/// voce dell'AI con l'oracolo deterministico senza dirlo affatto.
class RipiegoDelMaestro {
  const RipiegoDelMaestro({
    required this.silenzio,
    required this.nonConfigurato,
    required this.interrotto,
  });

  /// Quando la voce c'era e non ha risposto: rete caduta, servizio spento,
  /// quota finita. Nel tono del Maestro, e dichiara di non essere una lettura.
  final String silenzio;

  /// Quando la voce non e' proprio accesa su questa installazione. Distinta
  /// dalla precedente perche' non ha senso invitare a riprovare subito.
  final String nonConfigurato;

  /// QUANDO L'APP SI E' CHIUSA MENTRE LA RISPOSTA ERA IN VOLO.
  ///
  /// Distinta dalle altre due perche' la causa e' diversa da tutte e due: la
  /// voce non ha taciuto e non era spenta, semplicemente nessuno era piu' li'
  /// ad ascoltarla. Riaprendo, quel turno non puo' restare in attesa, perche'
  /// aspetterebbe per sempre una risposta che nessuno sta piu' generando, e
  /// non puo' nemmeno sparire, perche' allora la domanda resterebbe sola.
  final String interrotto;

  /// L'etichetta che accompagna a schermo ogni bolla di ripiego.
  ///
  /// Corta apposta: deve stare accanto alla bolla senza rubarle la scena, ma
  /// non deve poter passare inosservata.
  ///
  /// **Diceva "Ripiego, non è la sua voce", e la parola era sbagliata.** Nel
  /// resto dell'app "voce" e' l'audio sintetizzato dei Maestri, quello che si
  /// compra col piano: qui significava il Maestro. Delle tre confusioni che il
  /// fondatore ha trovato questa era la peggiore, perche' arriva nel momento in
  /// cui la persona ha gia' letto qualcosa che non capisce ed e' confusa.
  ///
  /// Adesso dice la stessa cosa senza equivoci, e la dice per esteso: cio' che
  /// stai leggendo l'ha composto l'app dai dati del cielo, non l'ha detto il
  /// Maestro. Il nome viene da [Maestro.displayName] e non e' scritto a mano,
  /// altrimenti il giorno che un Maestro cambia nome l'etichetta resta indietro.
  static String etichettaDi(Maestro maestro) =>
      'Lettura del cielo, non la risposta di ${maestro.displayName}';

  /// I tre ripieghi, uno per Maestro. Enumerabile: una prova li percorre
  /// tutti, compresi quelli che nascessero domani.
  static const Map<Maestro, RipiegoDelMaestro> perMaestro = {
    Maestro.medora: RipiegoDelMaestro(
      silenzio: 'Il cielo si è coperto e da qui non leggo. '
          'Questa non è la tua lettura, sono io che te lo dico: '
          'riproviamo fra poco.',
      nonConfigurato: 'Il cielo non è ancora aperto su questo telefono. '
          'Quando lo sarà, riprendo a leggere da dove eravamo.',
      interrotto: 'Stavo leggendo per te e ci siamo persi per strada. '
          'La domanda è ancora qui: quando vuoi, la riprendo da capo.',
    ),
    Maestro.aura: RipiegoDelMaestro(
      silenzio: 'Il respiro si è fermato un istante, insieme a me. '
          'Quello che leggi adesso non è una risposta, è un\'attesa: '
          'restiamo qui, poi riprendiamo.',
      nonConfigurato: 'Non sono ancora accesa su questo telefono. '
          'Il respiro intanto resta tuo: quello non ha bisogno di me.',
      interrotto: 'Il respiro si era già mosso, poi ci siamo interrotti. '
          'Quello che mi hai chiesto non l\'ho perso: riprendiamo da lì.',
    ),
    Maestro.caligo: RipiegoDelMaestro(
      silenzio: 'La nebbia ha coperto i segni. '
          'Non ti do un presagio che non ho visto: aspetto che si diradi, '
          'poi torniamo.',
      nonConfigurato: 'I segni non sono ancora stati aperti su questo '
          'telefono. Finché restano chiusi non invento nulla.',
      interrotto: 'I segni erano aperti e la lettura si è spezzata a metà. '
          'Non ti do un presagio monco: la tua domanda resta, chiedimela di '
          'nuovo quando vuoi.',
    ),
  };

  /// Il ripiego del [maestro] quando la voce tace. Mai nullo: un Maestro senza
  /// ripiego sarebbe un Maestro che resta muto, che e' il difetto da cui
  /// nasce questo file.
  static String silenzioDi(Maestro maestro) => perMaestro[maestro]!.silenzio;

  /// Il ripiego del [maestro] quando la voce non e' configurata.
  static String nonConfiguratoDi(Maestro maestro) =>
      perMaestro[maestro]!.nonConfigurato;

  /// Il ripiego del [maestro] per un turno rimasto a meta'.
  static String interrottoDi(Maestro maestro) =>
      perMaestro[maestro]!.interrotto;
}
