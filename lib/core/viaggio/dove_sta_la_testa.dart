import 'dart:ui';

/// **DOVE STA LA TESTA DI OGNI ANIMALE, e le tre aree che si calcolano da li'.**
/// Ordine DE voce 03, 11 settembre 2026.
///
/// **PERCHE' QUESTO FILE ESISTE.** L'ordine: *"Le tre aree non si possono
/// scrivere uguali per tutti, perche' in un serpente arrotolato o in un pesce
/// la testa non sta dove sta quella del lupo. Quindi ogni animale porta un
/// solo dato, un rettangolo che dice dove sta la sua testa, in un file di
/// dodici righe."*
///
/// **E i dodici NON hanno la stessa forma.** Le misure vere dei file, lette
/// dal disco: aquila 688x807, cavallo 878x844, cervo 765x933, corvo 847x704,
/// falco 805x749, gufo 537x865, lince 689x875, lupo 898x760, orso 900x736,
/// serpente 808x772, tartaruga 936x688, volpe 894x575. Un rettangolo scritto
/// una volta sola per tutti cadrebbe sul collo di uno e sulle zampe di un
/// altro.
///
/// **COME SONO STATI RICAVATI, che l'ordine lascia a chi esegue.** Le dodici
/// immagini sono state montate su un foglio di contatto con **la griglia dei
/// decimi** sovrapposta alla cornice vera dell'immagine, e i rettangoli sono
/// stati letti a occhio su quella griglia. Poi il foglio e' stato rifatto
/// **con i rettangoli disegnati sopra**, e guardato di nuovo: al primo giro
/// tre erano sbagliati (il cervo prendeva solo un palco di corna e lasciava
/// fuori il muso, il gufo era spostato di due decimi a sinistra, la lince di
/// uno), al secondo ne restavano tre da allargare di poco (cervo, serpente,
/// orso). **Il numero che conta e' questo: dodici su dodici verificati
/// guardandoli, non nove su dodici dedotti da una formula.**
///
/// **IL RETTANGOLO E' GENEROSO APPOSTA.** Comprende le corna del cervo, i
/// ciuffi della lince, la lingua del serpente e il becco del corvo: sono la
/// **firma della specie**, e chi le vedesse saprebbe il nome tre discese
/// prima. Meglio coprire un dito di collo in piu' che scoprire mezza corna.
abstract final class DoveStaLaTesta {
  /// **IL RETTANGOLO DELLA TESTA, in frazioni dell'immagine**, per lo stem
  /// del file senza `ani_` e senza `_v1`.
  ///
  /// I quattro numeri sono sinistra, alto, destra, basso, da 0 a 1.
  static const Map<String, Rect> _rettangoli = {
    'aquila': Rect.fromLTRB(0.06, 0.00, 0.30, 0.17),
    'cavallo': Rect.fromLTRB(0.00, 0.02, 0.24, 0.32),
    'cervo': Rect.fromLTRB(0.28, 0.00, 0.94, 0.28),
    'corvo': Rect.fromLTRB(0.68, 0.00, 1.00, 0.24),
    'falco': Rect.fromLTRB(0.00, 0.00, 0.20, 0.22),
    'gufo': Rect.fromLTRB(0.26, 0.00, 0.94, 0.30),
    'lince': Rect.fromLTRB(0.58, 0.04, 1.00, 0.34),
    'lupo': Rect.fromLTRB(0.00, 0.04, 0.24, 0.34),
    'orso': Rect.fromLTRB(0.66, 0.04, 1.00, 0.52),
    'serpente': Rect.fromLTRB(0.44, 0.06, 0.86, 0.34),
    'tartaruga': Rect.fromLTRB(0.72, 0.06, 0.96, 0.34),
    'volpe': Rect.fromLTRB(0.72, 0.06, 1.00, 0.56),
  };

  /// Quanti animali porta questo file. **La guardia lo confronta col
  /// catalogo**: se un tredicesimo animale arrivasse senza la sua riga, la
  /// lente non saprebbe dove non guardare.
  static int get quantiSono => _rettangoli.length;

  /// I nomi, come li scrive il catalogo: minuscoli e senza accenti.
  static Iterable<String> get nomi => _rettangoli.keys;

  /// **IL RETTANGOLO DELLA TESTA per [nome]**, che e' il nome del catalogo
  /// (`Aquila`, `Lupo`) confrontato senza maiuscole.
  ///
  /// **Nullo quando l'animale non ha la sua riga**, e chi legge deve reggere
  /// il nulla: la voce DC dice che un asset che manca e' un caso, non una
  /// schermata rotta. Chi non ha riga **non si vela affatto**, perche' velare
  /// senza sapere dove sta la testa vorrebbe dire scoprirla per caso.
  static Rect? di(String nome) => _rettangoli[nome.toLowerCase()];

  /// **QUANTO SI ALLARGA IL RETTANGOLO PRIMA DI PROIBIRLO.**
  ///
  /// Un centesimo dell'immagine. Il bordo di una sagoma non e' una riga: e'
  /// una decina di pixel di sfumatura, e un cerchio che si ferma **esatto**
  /// sul confine ne lascerebbe passare qualcuno.
  static const double margineDiSicurezza = 0.01;

  /// **IL PIU' BASSO PUNTO DELLA TESTA, col margine.** E' il numero da cui
  /// nascono tutte e tre le aree.
  static double sottoLaTesta(String nome) {
    final r = di(nome);
    if (r == null) return 0.0;
    return (r.bottom + margineDiSicurezza).clamp(0.0, 1.0);
  }

  /// **L'AREA CONCESSA ALLA DISCESA [discesa]**, contata da zero, in frazioni
  /// dell'immagine: sinistra, alto, destra, basso.
  ///
  /// **LA LEGGE, ed e' una sola riga: TUTTO CIO' CHE SI PUO' SCOPRIRE PRIMA
  /// DELLA QUARTA STA SOTTO LA TESTA.** Il corpo disponibile va da
  /// [sottoLaTesta] fino al fondo dell'immagine, e si divide in tre fasce
  /// uguali che si scoprono **dal basso verso l'alto**:
  ///
  /// - **prima discesa, la fascia piu' bassa**: zampe, artigli, code, cio'
  ///   che tocca terra;
  /// - **seconda, quella di mezzo**: corpo, manto, ali chiuse, dorso;
  /// - **terza, la piu' alta delle tre**: collo, spalle, attaccatura delle
  ///   ali, criniera;
  /// - **quarta**: l'immagine intera, e la testa si vede per la prima volta.
  ///
  /// **PERCHE' COSI' E NON A FASCE FISSE.** Con tre terzi uguali dell'intera
  /// immagine, la fascia alta del lupo sarebbe **il muso**, e quella
  /// dell'orso, che ha la testa fino a meta' altezza, sarebbe **mezza
  /// faccia**. Ancorando le tre fasce al punto piu' basso della testa, la
  /// terza discesa di ogni animale finisce dove comincia la sua testa, e non
  /// dove finirebbe quella di un altro.
  ///
  /// **E DA QUI VIENE LA PROVA DELLA REGOLA H**, che non ha bisogno di
  /// guardare i pixel per essere vera: se ogni area sta sotto [sottoLaTesta],
  /// e il centro della lente e' tenuto dentro l'area **rientrato del proprio
  /// raggio**, allora il cerchio non arriva mai sopra quella riga. Il
  /// rettangolo della testa **non puo'** essere scoperto, per costruzione.
  /// **FIN DOVE ARRIVA IL VELO, alla discesa [discesa].** Ordine DG del
  /// 12 settembre 2026.
  ///
  /// Il velo copre **dall'alto della scena fino a questa quota**, e quello che
  /// sta sotto e' gia' stato scoperto nelle discese precedenti. Le fasce si
  /// scoprono dal basso verso l'alto, una per discesa, **e restano scoperte**.
  ///
  /// - alla **prima** vale 1, cioe' il velo copre tutto: non si e' scoperto
  ///   ancora niente;
  /// - alla **seconda** si ferma sopra la fascia bassa, che resta in chiaro;
  /// - alla **quarta** vale [sottoLaTesta], cioe' **resta velata la sola
  ///   testa**, ed e' la lente di quel giorno a scoprirla.
  ///
  /// **Perche' non serve una memoria nuova.** Perche' le fasce si scoprono in
  /// ordine: sapere **quante** discese sono state fatte basta a sapere
  /// **quali** fasce sono gia' aperte.
  static double finDoveArrivaIlVelo(String nome, int discesa) {
    final cima = sottoLaTesta(nome);
    if (discesa <= 0) return 1.0;
    // **DOPO LA QUARTA IL VELO NON C'E' PIU'.**
    if (discesa > quanteFasce) return 0.0;
    if (discesa >= quanteFasce) return cima;
    final altezza = (1.0 - cima) / quanteFasce;
    return cima + altezza * (quanteFasce - discesa);
  }

  /// **QUANTE FASCE SOTTO LA TESTA.** Tre, una per ognuna delle prime tre
  /// discese: la quarta e' della testa.
  static const int quanteFasce = 3;

  static Rect areaDellaDiscesa(String nome, int discesa) {
    // **DOPO LA QUARTA NON C'E' PIU' NIENTE DA SCOPRIRE**, e l'area e'
    // l'immagine intera: e' lo stato della card della rivelazione.
    if (discesa > quanteFasce) return const Rect.fromLTRB(0, 0, 1, 1);
    // **LA QUARTA DISCESA E' LA DISCESA DELLA TESTA.** Ordine DG,
    // 12 settembre 2026: *"solo l'ultimo giorno la lente scoprira' la testa
    // dell'animale"*.
    //
    // **Qui tornava l'immagine intera**, e con `velato` falso: il quarto
    // giorno l'animale si vedeva tutto **senza passare la lente**. La lente
    // non scopriva la testa, la testa era gia' li'.
    if (discesa == quanteFasce) {
      return Rect.fromLTRB(0, 0, 1, sottoLaTesta(nome));
    }
    final cima = sottoLaTesta(nome);
    final altezza = (1.0 - cima) / 3.0;
    // La discesa 0 e' la fascia piu' bassa, la 2 la piu' alta delle tre.
    final quale = discesa.clamp(0, 2);
    final alto = cima + altezza * (2 - quale);
    return Rect.fromLTRB(0, alto, 1, alto + altezza);
  }

  /// **IL DIAMETRO DELLA LENTE, in frazione della LARGHEZZA dell'immagine.**
  ///
  /// Un quarto, e l'ordine dice perche': *"se e' piu' grande si scopre tutto
  /// in due movimenti e il gesto muore"*.
  static const double diametroDellaLente = 0.25;

  /// Il raggio, che e' il numero che serve davvero a chi tiene dentro il
  /// centro.
  static const double raggioDellaLente = diametroDellaLente / 2;

  /// **DOVE PUO' STARE IL CENTRO DELLA LENTE**, dato il rettangolo vero
  /// dell'immagine a schermo, in punti.
  ///
  /// Il centro e' tenuto dentro l'area **rientrato del raggio**, cosi' il
  /// cerchio intero resta dentro. Quando la fascia e' piu' bassa di due
  /// raggi, il centro si ferma sul suo bordo alto piu' il raggio: il cerchio
  /// sborda **verso il basso**, cioe' dentro cio' che si e' gia' visto nelle
  /// discese prima, e **mai verso l'alto**, che e' la parte che conta.
  static Offset tieniDentro({
    required Offset dito,
    required Rect immagine,
    required Rect area,
    required double raggio,
  }) {
    final sinistra = immagine.left + immagine.width * area.left + raggio;
    final destra = immagine.left + immagine.width * area.right - raggio;
    final alto = immagine.top + immagine.height * area.top + raggio;
    final basso = immagine.top + immagine.height * area.bottom - raggio;
    return Offset(
      destra >= sinistra
          ? dito.dx.clamp(sinistra, destra)
          : (sinistra + destra) / 2,
      // **QUANDO NON CI STA, SI PREFERISCE IL BORDO ALTO.** Vedi sopra: e' la
      // differenza fra sbordare su cio' che si e' gia' visto e sbordare sulla
      // testa.
      basso >= alto ? dito.dy.clamp(alto, basso) : alto,
    );
  }
}
