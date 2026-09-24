import 'dart:ui' show Rect;

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

/// **LA PRIMA COSA CHE IL MAESTRO DICE A VOCE.** Ordine EG voce 01.
///
/// Serve a due cose. Alla persona, che sente subito il Maestro invece di un
/// silenzio che sembra un guasto. E al volto: Protoface chiude la sessione se
/// non riceve audio, e un saluto appena il volto entra nella stanza la tiene
/// viva mentre la persona decide cosa dire. Frasi fisse e non composte dal
/// modello: il saluto non deve costare una chiamata, ne' poter sbagliare.
String ilSalutoDellaVoceViva(Maestro maestro) => switch (maestro) {
      Maestro.medora => 'Eccomi. Il cielo di stasera ascolta con me: dimmi '
          'cosa ti porta qui.',
      Maestro.aura => 'Eccomi. Prendi un respiro con me, poi dimmi cosa '
          'senti.',
      Maestro.caligo => 'Sono qui. Le rune tacciono finché non parli tu.',
    };

/// **LA FINESTRA SUL VOLTO.** Ordine EG voce 05, dopo la prova del fondatore
/// del 23 settembre 2026: *"una soluzione elegante potrebbe essere un
/// riquadro al cui interno c'e' l'avatar [...] cosi' il taglio in basso
/// dell'avatar coinciderebbe con il bordo basso del riquadro, come se fosse
/// all'interno di una finestra. Adesso ai lati dell'avatar c'e' molto troppo
/// spazio"*.
///
/// Protoface manda un video quadrato col busto dentro, e **ogni Maestro ci
/// sta in un modo suo**: misurati sul Realme lo stesso giorno, il taglio in
/// basso di Medora cade a 0,852 del quadrato, quello di Aura a 0,998, quello
/// di Caligo a 0,851, e le spalle di Caligo vanno da bordo a bordo mentre
/// quelle di Medora ne occupano poco piu' di meta'. Una finestra sola per
/// tutti avrebbe lasciato sotto Medora il vuoto che il fondatore voleva
/// togliere; qui ogni Maestro ha la sua misura, e la finestra si ritaglia su
/// quella.
class InquadraturaDelVolto {
  const InquadraturaDelVolto({
    required this.alto,
    required this.basso,
    required this.centro,
    this.toppa,
    this.intatto,
  });

  /// Dove comincia la testa, in frazione del lato del video.
  final double alto;

  /// Dove il busto e' tagliato: qui cade il bordo basso della finestra.
  final double basso;

  /// Il centro della testa in orizzontale: la finestra si centra qui.
  final double centro;

  /// **Un buco del mantello da riempire**, in frazioni del lato del video,
  /// quando c'e'. Nel fotogramma di Medora col fondo bianco i bianchi chiusi
  /// dentro la figura sono due: lo spiraglio fra l'orecchino sinistro e il
  /// collo, che e' fondo e va tolto, e un buco sulla spalla sinistra, pixel
  /// da 336 a 362 in orizzontale e da 644 a 658 in verticale su 1.080, che e'
  /// il mantello e va riempito. Nessuna regola automatica li distingue: e'
  /// una differenza di significato, e si dichiara qui, con dieci pixel di
  /// margine attorno. Per Aura e Caligo non c'e' un fotogramma col fondo
  /// bianco su cui contarli, e le loro catture col filtro non ne mostrano.
  final Rect? toppa;

  /// **Una zona dove il bianco e' figura, e si lascia com'e'**, in frazioni
  /// del lato del video. Il cristallo della spilla di Caligo e' bianco e
  /// largo, e lo shader che toglie il fondo lo bucava di nero: misurato sulla
  /// cattura del 23 settembre 2026 dentro la finestra, col bordo d'oro come
  /// riferimento, e riportato al video.
  final Rect? intatto;

  /// Larghezza su altezza della finestra, la stessa per tutti e tre.
  static const proporzione = 0.8;

  /// Lo spazio sopra la testa, in frazione del lato del video: poco, perche'
  /// sopra la testa c'e' l'arco della finestra.
  static const respiro = 0.07;

  /// Le misure, prese dal video vero di Protoface sul Realme il 23 settembre
  /// 2026, una sessione per Maestro.
  ///
  /// **Quella di Caligo e' stata presa due volte.** La prima dava il taglio
  /// a 0,885, e nella finestra sotto il busto restava una fascia nera: il suo
  /// saluto sta su una riga sola, l'area del video era piu' alta e il
  /// quadrato stava piu' in basso di quanto la misura supponeva. La seconda
  /// l'ha presa dentro la finestra stessa, dove il bordo e' noto: 48 pixel di
  /// fascia su un lato di 1.494, cioe' 0,032 in meno; e il taglio sta un filo
  /// piu' su ancora, perche' sull'ultima riga del busto c'e' una linea chiara
  /// che e' il bordo dell'immagine da cui l'avatar e' nato.
  /// **QUALE INQUADRATURA, LO DICE L'AVATAR.** Ordine EK voce 04, 24
  /// settembre 2026.
  ///
  /// Gli avatar nati prima dell'ordine EK vengono da tele larghe 1700 per 1200
  /// (Aura 1200 per 1200), che Protoface metteva nel quadrato del video con
  /// due fasce: per loro valgono le misure prese sul Realme dall'ordine EG,
  /// qui sotto in [_diPrima]. Gli avatar nuovi nascono dalle immagini
  /// restaurate e tagliate quadrate, testa e spalle, e il video E' il
  /// quadrato: le loro misure stanno in [_quadrata].
  ///
  /// **L'avatar lo dice il server**, che lo manda con la sessione
  /// (`SessioneLive.avatar`): un telefono con questa build inquadra giusto
  /// sia gli avatar di prima sia quelli nuovi, e il giorno in cui il server
  /// passa ai nuovi nessuno deve aggiornare l'app. Senza avatar, cioe' prima
  /// che la sessione esista e quindi senza video, vale l'inquadratura nuova.
  static const Set<String> avatarDiPrima = {
    'av_01KZ9637K1YZ45H3GNZE95YN6E',
    'av_01KZVCNV16EAMMG75TXFC9D475',
    'av_01KZVB6FCP27NR3GZQ47WJ7QJG',
  };

  static InquadraturaDelVolto di(Maestro maestro, {String? avatar}) =>
      avatarDiPrima.contains(avatar) ? _diPrima(maestro) : _quadrata(maestro);

  /// **L'INQUADRATURA B, per le immagini quadrate.** Ordine EK voce 04.
  ///
  /// Le misure si leggono dall'immagine: ogni quadrato e' stato tagliato con
  /// la cima della testa a 0,08 del lato e la testa al centro, e il busto
  /// arriva al bordo basso (0,995, un filo sopra la riga chiara che Protoface
  /// lascia sull'ultima riga). La toppa di Medora e il cristallo di Caligo li
  /// ha trovati il filtro del volto rifatto in Python sulle immagini nuove,
  /// dopo averlo provato sulle immagini di prima: li' ritrova esattamente le
  /// due zone misurate sul Realme dall'ordine EG. Prove in
  /// `docs/collaudo/EK/volti/`.
  static InquadraturaDelVolto _quadrata(Maestro maestro) => switch (maestro) {
        Maestro.medora => const InquadraturaDelVolto(
            alto: 0.080,
            basso: 0.995,
            centro: 0.500,
            toppa: Rect.fromLTRB(0.195, 0.745, 0.267, 0.796),
          ),
        Maestro.aura =>
          const InquadraturaDelVolto(alto: 0.080, basso: 0.995, centro: 0.500),
        Maestro.caligo => const InquadraturaDelVolto(
            alto: 0.080,
            basso: 0.995,
            centro: 0.500,
            intatto: Rect.fromLTRB(0.387, 0.839, 0.474, 0.986),
          ),
      };

  static InquadraturaDelVolto _diPrima(Maestro maestro) => switch (maestro) {
        Maestro.medora => const InquadraturaDelVolto(
            alto: 0.148,
            basso: 0.852,
            centro: 0.494,
            toppa: Rect.fromLTRB(0.302, 0.587, 0.344, 0.619),
          ),
        Maestro.aura =>
          const InquadraturaDelVolto(alto: 0.026, basso: 0.998, centro: 0.523),
        Maestro.caligo => const InquadraturaDelVolto(
            alto: 0.159,
            basso: 0.851,
            centro: 0.480,
            intatto: Rect.fromLTRB(0.346, 0.706, 0.474, 0.843),
          ),
      };

  /// **Il pezzo del video che si vede dalla finestra**, in frazioni del lato.
  /// Il bordo basso e' il taglio del busto; l'alto lascia [respiro] sopra la
  /// testa, senza uscire dal video; la larghezza segue [proporzione] e la
  /// finestra si centra sulla testa, spostandosi solo quanto serve a non
  /// uscire dal quadrato.
  Rect get ritaglio {
    final sopra = alto - respiro < 0 ? 0.0 : alto - respiro;
    final altezza = basso - sopra;
    final larghezza = altezza * proporzione;
    var sinistra = centro - larghezza / 2;
    if (sinistra < 0) sinistra = 0;
    if (sinistra + larghezza > 1) sinistra = 1 - larghezza;
    return Rect.fromLTWH(sinistra, sopra, larghezza, altezza);
  }
}

/// Perche' la voce viva si e' chiusa da sola, e quindi cosa dire a video.
enum ComeFinisce {
  /// Trenta secondi senza conversazione.
  silenzio,

  /// I minuti della sessione sono finiti.
  tempo,
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
    this.fine,
  });

  final MomentoDelLive momento;
  final Maestro maestro;
  final SessioneLive? sessione;
  final PerchePerILiveNonSiApre? perche;
  final int secondiPassati;

  /// L'ultima cosa detta, che si legge a video. Ordine EG voce 05.
  final String sottotitolo;

  /// Perche' si e' chiusa, quando si e' chiusa da sola.
  final ComeFinisce? fine;

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

  /// **TRENTA SECONDI SENZA CONVERSAZIONE CHIUDONO LA VOCE VIVA.** Parole del
  /// fondatore, 23 settembre 2026: *"dovrebbe esserci una interruzione
  /// automatica se non c'e' conversazione per oltre 30 secondi"*. Protoface
  /// si paga a tempo, e una schermata lasciata aperta sul tavolo consumerebbe
  /// i minuti della persona e i nostri crediti per niente.
  ///
  /// **Il silenzio si conta solo quando nessuno sta facendo niente**: mentre
  /// il Maestro parla o compone la risposta non e' silenzio, e ogni parola
  /// della persona, detta o scritta, lo azzera.
  static const secondiDiSilenzioCheChiudono = 30;

  /// Vero quando il silenzio e' durato abbastanza da chiudere.
  bool chiudePerSilenzio(int secondiDiSilenzio) =>
      momento == MomentoDelLive.vivo &&
      secondiDiSilenzio >= secondiDiSilenzioCheChiudono;

  QuadroDelLive con({
    MomentoDelLive? momento,
    SessioneLive? sessione,
    PerchePerILiveNonSiApre? perche,
    int? secondiPassati,
    String? sottotitolo,
    ComeFinisce? fine,
  }) =>
      QuadroDelLive(
        momento: momento ?? this.momento,
        maestro: maestro,
        sessione: sessione ?? this.sessione,
        perche: perche ?? this.perche,
        secondiPassati: secondiPassati ?? this.secondiPassati,
        sottotitolo: sottotitolo ?? this.sottotitolo,
        fine: fine ?? this.fine,
      );

  /// **Il congedo, quando la voce viva si chiude da sola.** Dice perche', e
  /// dice che niente e' perso: ogni turno detto a voce e' gia' scritto nella
  /// chat. Nessun vicolo cieco: sotto c'e' il ritorno alla conversazione.
  String laFraseDellaFine() => switch (fine) {
        ComeFinisce.tempo => 'Il tempo di questa voce è finito. Quello che '
            'ci siamo detti resta scritto nella nostra conversazione.',
        _ => 'Ci fermiamo qui: per trenta secondi non ci siamo detti niente. '
            'Ho chiuso la voce per non consumare i tuoi minuti. Quello che '
            'ci siamo detti resta scritto nella nostra conversazione.',
      };

  /// La frase che la persona legge quando il LIVE non si apre.
  ///
  /// **Le tre ragioni danno tre frasi diverse**, e nessuna e' un messaggio
  /// d'errore: sono cose che un Maestro direbbe.
  String laFraseDelRifiuto() => switch (perche) {
        PerchePerILiveNonSiApre.nonEPerTe =>
          'La voce viva non è ancora aperta per te. Continua a scrivermi: '
              'ti rispondo qui, come sempre.',
        PerchePerILiveNonSiApre.minutiFiniti =>
          'Per questo mese ho finito il fiato. Resto qui, in silenzio e '
              'per iscritto, finché non torna.',
        _ => 'La voce non arriva, stasera. Scrivimi: quello che ci siamo '
            'detti non si perde.',
      };
}
