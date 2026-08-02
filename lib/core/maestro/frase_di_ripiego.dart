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
  });

  /// Quando la voce c'era e non ha risposto: rete caduta, servizio spento,
  /// quota finita. Nel tono del Maestro, e dichiara di non essere una lettura.
  final String silenzio;

  /// Quando la voce non e' proprio accesa su questa installazione. Distinta
  /// dalla precedente perche' non ha senso invitare a riprovare subito.
  final String nonConfigurato;

  /// L'etichetta che accompagna a schermo ogni bolla di ripiego, uguale per
  /// tutti e tre. Corta apposta: deve stare accanto alla bolla senza rubarle
  /// la scena, ma non deve poter passare inosservata.
  static const String etichetta = 'Ripiego, non è la sua voce';

  /// I tre ripieghi, uno per Maestro. Enumerabile: una prova li percorre
  /// tutti, compresi quelli che nascessero domani.
  static const Map<Maestro, RipiegoDelMaestro> perMaestro = {
    Maestro.medora: RipiegoDelMaestro(
      silenzio: 'Il cielo si è coperto e da qui non leggo. '
          'Questa non è la tua lettura, è solo la mia voce che te lo dice: '
          'riproviamo fra poco.',
      nonConfigurato: 'Il cielo non è ancora aperto su questo telefono. '
          'Quando lo sarà, riprendo a leggere da dove eravamo.',
    ),
    Maestro.aura: RipiegoDelMaestro(
      silenzio: 'Il respiro si è fermato un istante e la mia voce con lui. '
          'Quello che leggi adesso non è una risposta, è un\'attesa: '
          'restiamo qui, poi riprendiamo.',
      nonConfigurato: 'La mia voce non è ancora accesa su questo telefono. '
          'Il respiro intanto resta tuo: quello non ha bisogno di me.',
    ),
    Maestro.caligo: RipiegoDelMaestro(
      silenzio: 'La nebbia ha coperto i segni. '
          'Non ti do un presagio che non ho visto: aspetto che si diradi, '
          'poi torniamo.',
      nonConfigurato: 'I segni non sono ancora stati aperti su questo '
          'telefono. Finché restano chiusi non invento nulla.',
    ),
  };

  /// Il ripiego del [maestro] quando la voce tace. Mai nullo: un Maestro senza
  /// ripiego sarebbe un Maestro che resta muto, che e' il difetto da cui
  /// nasce questo file.
  static String silenzioDi(Maestro maestro) =>
      perMaestro[maestro]!.silenzio;

  /// Il ripiego del [maestro] quando la voce non e' configurata.
  static String nonConfiguratoDi(Maestro maestro) =>
      perMaestro[maestro]!.nonConfigurato;
}
