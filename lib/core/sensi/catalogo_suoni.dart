/// I CINQUE SUONI del Cerchio, e nessuno di piu'.
///
/// **Il silenzio e' cio' che rende un suono importante.** Le app che stancano
/// suonano a ogni tocco: qui non c'e' suono sui tocchi ordinari, nessuno nello
/// scorrimento, nessuna musica di sottofondo. Cinque momenti soltanto, e ognuno
/// si sente perche' attorno c'e' silenzio.
///
/// **I tre Maestri NON hanno tre suoni diversi.** Sarebbe rumore, non identita':
/// una firma che cambia a seconda di chi parla non e' piu' una firma.
///
/// Il catalogo e' un DATO, non una convenzione scritta in un commento: un test
/// fallisce se una schermata riproduce un suono che non e' qui dentro.
enum SuonoDelCerchio {
  /// L'apertura dell'app, il cosmo che respira. Due secondi.
  ///
  /// UNA volta per sessione e mai a ogni ritorno in home: una firma che si
  /// ripete a ogni passaggio smette di essere una firma e diventa un tic.
  firma('firma.mp3', Duration(seconds: 2)),

  /// Risonanza, animale, angeli, sigillo. Uno o due secondi.
  ///
  /// E' il picco: il momento che si racconta in una frase e' la Risonanza, e
  /// tutto il resto sta sotto quel picco.
  rivelazione('rivelazione.mp3', Duration(milliseconds: 1500)),

  /// LA VOCE DEL PRINCIPIO, sulla schermata nera dell'intro.
  ///
  /// E' il sesto, e per questo la regola dei cinque e' stata riscritta invece
  /// che aggirata: entra nel catalogo come gli altri, perche' il catalogo esiste
  /// proprio per non avere suoni che nascono fuori. Suona una volta per
  /// sessione e prende il posto della firma quando l'intro c'e': due suoni che
  /// si contendono la stessa schermata nera non fanno un'apertura piu' ricca,
  /// fanno rumore.
  ///
  /// Provvisorio quanto l'intro che accompagna.
  principio('principio.mp3', Duration(milliseconds: 2430)),

  /// Chiusura di un rito o di una lettura. Breve, risolutivo.
  ritoCompiuto('rito_compiuto.mp3', Duration(milliseconds: 1500)),

  /// Ingresso nel dominio di un Maestro. Mezzo secondo, discreto.
  soglia('soglia.mp3', Duration(milliseconds: 500)),

  /// Un limite raggiunto. Brevissimo, opaco, senza dramma.
  ///
  /// Il rifiuto non merita teatro: un suono drammatico su un limite lo
  /// trasformerebbe nel momento piu' memorabile dell'app.
  rifiuto('rifiuto.mp3', Duration(milliseconds: 300));

  const SuonoDelCerchio(this.file, this.durataAttesa);

  /// Il nome del file atteso dentro `assets/audio/`.
  final String file;

  /// Quanto dovrebbe durare, per chi sceglie l'asset.
  final Duration durataAttesa;

  /// Il percorso completo dell'asset.
  String get percorso => 'audio/$file';
}
