/// I QUATTRO ANELLI D'AMBIENTE del Cerchio, e nessuno di piu'.
/// Ordine CN del 1 settembre 2026.
///
/// **Perche' un catalogo anche per la musica.** Vale la stessa ragione degli
/// effetti: un tappeto sonoro che nasce dentro una schermata e' un tappeto che
/// nessuno sa piu' dove suona. Qui sono quattro, e una guardia cade se una
/// schermata ne suona uno che non e' scritto in questa lista.
///
/// **NON E' UN SELETTORE DI BRANI, ed e' un vincolo di licenza.** Ordine CN
/// voce 11. La licenza Envato Elements copre l'uso in un progetto dichiarato ma
/// **esclude l'uso on demand**, cioe' quello in cui e' la persona a scegliere
/// il contenuto. Musica fissa per schermata sta dentro la licenza; un elenco da
/// cui scegliere il brano no. Per questo la traccia si ricava dal luogo in cui
/// si e', mai da una scelta: non esiste, e non deve esistere, un comando che
/// dica "metti questa".
///
/// **La sonorita' e' gia' decisa qui dentro, non a schermo.** Tutti e quattro
/// sono normalizzati a -23 LUFS-M, sette decibel sotto gli effetti. Il rapporto
/// fra musica ed effetti e' giusto **prima** che qualcuno tocchi un cursore, e
/// i cursori servono a gusto personale, non a rimediare a un difetto.
enum MusicaDelCerchio {
  /// LO SHAMAN. Parte con la prima schermata del Risveglio e non si
  /// interrompe fino alla home compresa; dalle sessioni dopo e' la traccia
  /// della home.
  ///
  /// **Continua a suonare mentre si compie un Dono del Giorno**: spegnerla
  /// farebbe del Dono un buco di silenzio, e un Dono e' il momento in cui
  /// l'app deve sembrare piu' viva, non meno.
  home('ambiente_home.mp3', Duration(milliseconds: 149088)),

  /// L'atmosfera di Medora, nelle schermate del suo dominio.
  medora('ambiente_medora.mp3', Duration(milliseconds: 151253)),

  /// Il deserto di Caligo.
  caligo('ambiente_caligo.mp3', Duration(milliseconds: 131539)),

  /// Il bambu' di Aura.
  ///
  /// **Nel dominio di Aura si', nella Meditazione NO.** La Meditazione tiene
  /// il volume della musica a ZERO per la prescrizione del 31 agosto 2026, che
  /// protegge il battito binaurale generato dal telefono: un tappeto sopra un
  /// battito a 7 Hz coprirebbe proprio la cosa che si va ad ascoltare. Una
  /// prova lo pretende.
  aura('ambiente_aura.mp3', Duration(milliseconds: 188995));

  const MusicaDelCerchio(this.file, this.durata);

  /// Il nome del file dentro `assets/music/`.
  final String file;

  /// Quanto dura l'anello, misurato sul file vero dopo la chiusura.
  final Duration durata;

  /// Il percorso completo dell'asset.
  String get percorso => 'music/$file';
}
