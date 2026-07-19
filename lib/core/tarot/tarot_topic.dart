/// I gruppi in cui si raccolgono gli argomenti della stesa.
enum TarotTopicGroup {
  amore('Amore e sentimenti'),
  lavoro('Lavoro e denaro'),
  vita('Vita e cammino');

  const TarotTopicGroup(this.label);

  final String label;

  /// Il modello di consiglio del gruppo, da `docs/corpus/stesa_interpretazione.md`.
  ///
  /// E' il ripiego deterministico: a runtime Gemini lo specializza sull'argomento
  /// e sulla persona. Sempre azionabile, mai una promessa.
  String get consiglio {
    switch (this) {
      case TarotTopicGroup.amore:
        return 'Non forzare i tempi dell\'altro, porta la tua verità con '
            'dolcezza e osserva cosa torna indietro. La risposta si vede nei '
            'gesti, non nelle parole.';
      case TarotTopicGroup.lavoro:
        return 'Fai il passo concreto che rimandi da tempo, anche piccolo. La '
            'fortuna qui premia chi si muove, non chi aspetta il momento '
            'perfetto.';
      case TarotTopicGroup.vita:
        return 'Prima di decidere, dai un nome a ciò che davvero vuoi. La '
            'strada si chiarisce quando smetti di volerle tutte.';
    }
  }
}

/// L'argomento su cui si direziona la lettura, la lente della stesa.
///
/// Sedici voci in tre gruppi. Salute, medico, legale e domande fataliste
/// restano fuori per etica: non sono voci nascoste ne' bloccate, proprio non
/// esistono nell'elenco.
enum TarotTopic {
  amoreQuadro('Amore, il quadro generale', TarotTopicGroup.amore),
  cosaProva('Cosa prova per me', TarotTopicGroup.amore),
  ritornoAmore('Un ritorno d\'amore', TarotTopicGroup.amore),
  fiducia('Fiducia e tradimento', TarotTopicGroup.amore),
  nuovoIncontro('Un nuovo incontro', TarotTopicGroup.amore),
  scegliereTraDue('Scegliere tra due', TarotTopicGroup.amore),
  lavoroTrovare('Lavoro, trovarlo o cambiarlo', TarotTopicGroup.lavoro),
  carriera('Carriera e crescita', TarotTopicGroup.lavoro),
  denaro('Denaro e fortuna', TarotTopicGroup.lavoro),
  affare('Un affare o una decisione', TarotTopicGroup.lavoro),
  momentoCheVivo('Il momento che vivo, lettura generale', TarotTopicGroup.vita),
  bivio('Una scelta o un bivio', TarotTopicGroup.vita),
  cambiamento('Un cambiamento in arrivo', TarotTopicGroup.vita),
  famiglia('Famiglia e casa', TarotTopicGroup.vita),
  amicizia('Un\'amicizia', TarotTopicGroup.vita),
  progetto('Un progetto o un sogno', TarotTopicGroup.vita);

  const TarotTopic(this.label, this.group);

  final String label;
  final TarotTopicGroup group;

  /// L'argomento di partenza, quello che non presuppone nulla.
  static const TarotTopic predefinito = TarotTopic.momentoCheVivo;

  /// Le voci di un gruppo, nell'ordine del corpus.
  static List<TarotTopic> of(TarotTopicGroup group) =>
      TarotTopic.values.where((t) => t.group == group).toList();

  /// La lente con cui si legge ogni posizione: apre la riga del significato.
  String get lente {
    switch (this) {
      case TarotTopic.amoreQuadro:
        return 'Nel tuo quadro affettivo';
      case TarotTopic.cosaProva:
        return 'Su cosa prova per te';
      case TarotTopic.ritornoAmore:
        return 'Sul ritorno che aspetti';
      case TarotTopic.fiducia:
        return 'Sulla fiducia in gioco';
      case TarotTopic.nuovoIncontro:
        return 'Sull\'incontro che cerchi';
      case TarotTopic.scegliereTraDue:
        return 'Sulla scelta fra i due';
      case TarotTopic.lavoroTrovare:
        return 'Sul lavoro che cerchi';
      case TarotTopic.carriera:
        return 'Sulla tua crescita';
      case TarotTopic.denaro:
        return 'Sul denaro che ti riguarda';
      case TarotTopic.affare:
        return 'Sulla decisione da prendere';
      case TarotTopic.momentoCheVivo:
        return 'Nel momento che vivi';
      case TarotTopic.bivio:
        return 'Sul bivio davanti a te';
      case TarotTopic.cambiamento:
        return 'Sul cambiamento in arrivo';
      case TarotTopic.famiglia:
        return 'Nella tua casa';
      case TarotTopic.amicizia:
        return 'In quell\'amicizia';
      case TarotTopic.progetto:
        return 'Sul progetto che porti';
    }
  }
}
