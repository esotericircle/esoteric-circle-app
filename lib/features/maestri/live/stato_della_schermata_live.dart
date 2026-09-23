import '../../../core/maestro/maestro.dart';
import '../../../services/live/porta_del_live.dart';

/// **I MOMENTI DELLA SCHERMATA LIVE.** Ordine EG voce 05.
///
/// **Vivono qui e non dentro il widget**, e la ragione l'ha insegnata l'ordine
/// EI: una frase chiusa dentro uno `State` privato non la puo' chiamare
/// nessuna prova, e quello che nessuna prova puo' raggiungere non e'
/// sorvegliato da niente. Qui la macchina degli stati si misura al banco, e il
/// widget si limita a disegnarla.
enum MomentoDelLive {
  /// Si sta chiedendo al server di aprire la sessione.
  siApre,

  /// La sessione c'e', ma il volto del Maestro non e' ancora arrivato.
  siAspettaIlVolto,

  /// Il Maestro e' a video e si puo' parlare.
  vivo,

  /// La sessione e' finita, per scelta o perche' il tempo e' scaduto.
  finito,

  /// Non si e' aperta, e il perche' cambia cosa si mostra.
  nonSiApre,
}

/// Cosa la schermata mostra e cosa lascia fare, in un momento dato.
///
/// **Nessuno di questi stati e' un vicolo cieco**, ed e' la regola di casa che
/// piu' rischia di saltare proprio qui: il LIVE ha tante cose che possono
/// andare storte, e ognuna deve lasciare una strada. Chi non ha il diritto
/// riceve un invito, chi ha finito i minuti riceve il saluto del Maestro, chi
/// trova un guasto torna alla chat scritta **senza perdere la conversazione**.
class QuadroDelLive {
  const QuadroDelLive({
    required this.momento,
    required this.maestro,
    this.sessione,
    this.perche,
    this.secondiPassati = 0,
    this.sottotitolo = '',
  });

  final MomentoDelLive momento;
  final Maestro maestro;
  final SessioneLive? sessione;
  final PerchePerILiveNonSiApre? perche;
  final int secondiPassati;

  /// L'ultima cosa detta, che si legge a video. Ordine EG voce 05.
  final String sottotitolo;

  /// **Si puo' sempre scrivere, anche quando il microfono non c'e'.**
  /// `CLAUDE.md`: ogni esperienza basata su un sensore ha sempre un ripiego a
  /// gesto tattile. Qui il sensore e' il microfono e il ripiego e' la
  /// tastiera, e non e' un ripiego di serie B: in treno o accanto a qualcuno
  /// che dorme e' l'unico modo di usare il LIVE.
  bool get siPuoScrivere =>
      momento == MomentoDelLive.vivo ||
      momento == MomentoDelLive.siAspettaIlVolto;

  /// Quanto manca alla fine, in secondi, se la sessione e' viva.
  int mancanoSecondi() {
    final tetto = sessione?.durataMassimaSecondi ?? 0;
    final resta = tetto - secondiPassati;
    return resta < 0 ? 0 : resta;
  }

  /// **Il Maestro saluta prima che il tempo finisca.** Ordine EG voce 06: la
  /// sessione non si tronca a meta' frase, si chiude con un congedo.
  ///
  /// Un minuto e' la finestra: abbastanza perche' il Maestro dica una cosa
  /// intera, poco perche' non sembri che stia gia' andando via.
  bool get eOraDiSalutare =>
      momento == MomentoDelLive.vivo && mancanoSecondi() <= 60;

  /// Vero quando il tempo e' scaduto del tutto.
  bool get ilTempoEFinito => sessione != null && mancanoSecondi() <= 0;

  QuadroDelLive con({
    MomentoDelLive? momento,
    SessioneLive? sessione,
    PerchePerILiveNonSiApre? perche,
    int? secondiPassati,
    String? sottotitolo,
  }) =>
      QuadroDelLive(
        momento: momento ?? this.momento,
        maestro: maestro,
        sessione: sessione ?? this.sessione,
        perche: perche ?? this.perche,
        secondiPassati: secondiPassati ?? this.secondiPassati,
        sottotitolo: sottotitolo ?? this.sottotitolo,
      );

  /// La frase che la persona legge quando il LIVE non si apre.
  ///
  /// **Le tre ragioni danno tre frasi diverse**, e nessuna e' un messaggio
  /// d'errore: sono cose che un Maestro direbbe.
  String laFraseDelRifiuto() => switch (perche) {
        PerchePerILiveNonSiApre.nonEPerTe =>
          'La voce viva non e\' ancora aperta per te. Continua a scrivermi: '
              'ti rispondo qui, come sempre.',
        PerchePerILiveNonSiApre.minutiFiniti =>
          'Per questo mese la mia voce si e\' spesa tutta. Resto qui, in '
              'silenzio e per iscritto, finche\' non torna.',
        _ => 'La voce non arriva, stasera. Scrivimi: quello che ci siamo '
            'detti non si perde.',
      };
}
