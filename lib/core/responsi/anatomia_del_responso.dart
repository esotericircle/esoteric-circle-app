/// L'ANATOMIA DEL RESPONSO: QUATTRO PARTI E UN ORDINE. Ordine S voce 16.
///
/// **Le quattro parti sono nominate nel codice come struttura, non ricomposte a
/// mano in ogni arte.** Se ogni arte le rimettesse in fila per conto suo, in due
/// mesi avremmo quattro ordini diversi delle stesse quattro parti, e nessuna
/// prova potrebbe dire quale sia quello giusto.
///
/// **LA QUARTA PARTE NON STA NEL RESPONSO**, e questo e' il punto che si dimentica
/// piu' facilmente: la tradizione scende nel pannello delle fonti e del metodo che
/// esiste gia'. Il pannello delle rune, che cita l'Edda poetica e l'Havamal, e' la
/// forma giusta: si estende, non si reinventa. Per questo `Responso` ha tre campi
/// e non quattro, e il quarto e' dichiarato qui sotto come luogo, non come testo.
///
/// **RETENTION, e sta scritto perche' e' una ragione di prodotto e non di stile.**
/// Un responso che spiega un simbolo si esaurisce quando lo leggi. Un responso che
/// risponde alla tua domanda e ti lascia una cosa da fare produce un ritorno,
/// perche' domani vuoi sapere se aveva ragione: [Responso.cosaPuoiFare] e' la
/// parte che fa tornare.
library;

/// LE QUATTRO PARTI, nell'ordine in cui si leggono.
enum ParteDelResponso {
  /// 1. LA RISPOSTA. Da due a quattro righe. Parla alla domanda posta e dice
  /// cosa la lettura vede nella situazione della persona.
  risposta(
    numero: 1,
    nome: 'La risposta',
    cosaFa: 'Parla alla domanda posta e dice cosa la lettura vede nella '
        'situazione della persona.',
    righeMinime: 2,
    righeMassime: 4,
    dentroIlResponso: true,
  ),

  /// 2. COSA PUOI FARE. Una o due righe. Un'indicazione concreta, compibile oggi
  /// o nei prossimi giorni. **Non "ascolta te stesso"**: una cosa che si puo'
  /// davvero fare.
  cosaPuoiFare(
    numero: 2,
    nome: 'Cosa puoi fare',
    cosaFa: 'Un\'indicazione concreta, compibile oggi o nei prossimi giorni. '
        'Non "ascolta te stesso": una cosa che si può davvero fare.',
    righeMinime: 1,
    righeMassime: 2,
    dentroIlResponso: true,
  ),

  /// 3. DA DOVE VIENE. Una o due righe. Perche' quella runa, quella carta o quel
  /// transito dice questo. **E' qui che il simbolo compare: non prima.**
  daDoveViene(
    numero: 3,
    nome: 'Da dove viene',
    cosaFa: 'Perché quella runa, quella carta o quel transito dice questo. '
        'È qui che il simbolo compare: non prima.',
    righeMinime: 1,
    righeMassime: 2,
    dentroIlResponso: true,
  ),

  /// 4. LA TRADIZIONE. **NON sta nel responso**: scende nel pannello delle fonti
  /// e del metodo.
  tradizione(
    numero: 4,
    nome: 'La tradizione',
    cosaFa: 'Non sta nel responso: scende nel pannello delle fonti e del '
        'metodo che esiste già.',
    righeMinime: 0,
    righeMassime: 0,
    dentroIlResponso: false,
  );

  const ParteDelResponso({
    required this.numero,
    required this.nome,
    required this.cosaFa,
    required this.righeMinime,
    required this.righeMassime,
    required this.dentroIlResponso,
  });

  /// La posizione nell'ordine di lettura, da uno a quattro.
  final int numero;

  /// Come si chiama, in parole della persona.
  final String nome;

  /// Che lavoro fa questa parte.
  final String cosaFa;

  final int righeMinime;
  final int righeMassime;

  /// Falso solo per la tradizione, che vive nel pannello delle fonti.
  final bool dentroIlResponso;

  /// Le parti che il responso porta davvero, in ordine.
  static List<ParteDelResponso> get nelResponso =>
      values.where((p) => p.dentroIlResponso).toList();
}

/// UN RESPONSO COMPOSTO, con le sue tre parti e nell'unico ordine ammesso.
///
/// Le arti costruiscono questo, e non una stringa: chi ha in mano un `Responso`
/// non puo' mettere il simbolo per primo nemmeno volendo, perche' l'ordine non
/// e' una convenzione ma la forma dell'oggetto.
class Responso {
  const Responso({
    required this.risposta,
    required this.cosaPuoiFare,
    required this.daDoveViene,
  });

  /// La prima cosa che si legge: cosa la lettura vede nella situazione.
  final String risposta;

  /// La parte che fa tornare: una cosa concreta, compibile.
  final String cosaPuoiFare;

  /// Il simbolo, che compare qui e non prima.
  final String daDoveViene;

  /// Il responso in parole, nell'ordine della sua anatomia.
  ///
  /// Le tre parti si separano con una riga vuota, perche' sono tre letture e non
  /// un paragrafo: chi legge sul telefono deve poter fermarsi dopo la prima.
  String get inParole => [risposta, cosaPuoiFare, daDoveViene]
      .map((p) => p.trim())
      .where((p) => p.isNotEmpty)
      .join('\n\n');

  /// Il testo di una parte, per chi mostra le tre parti separate.
  String parte(ParteDelResponso quale) => switch (quale) {
        ParteDelResponso.risposta => risposta,
        ParteDelResponso.cosaPuoiFare => cosaPuoiFare,
        ParteDelResponso.daDoveViene => daDoveViene,
        // La tradizione non e' nel responso: chi la chiede qui sta cercando nel
        // posto sbagliato, e riceve il vuoto invece di un testo inventato.
        ParteDelResponso.tradizione => '',
      };

  /// Vero se il responso ha tutte e tre le parti che deve avere.
  bool get eIntero =>
      risposta.trim().isNotEmpty &&
      cosaPuoiFare.trim().isNotEmpty &&
      daDoveViene.trim().isNotEmpty;
}
