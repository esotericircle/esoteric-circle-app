import 'dart:ui';

/// **DOVE STA LA TESTA DI OGNI ANIMALE.** Ordine DE voce 03, 11 settembre
/// 2026.
///
/// **DALL'ORDINE DI VOCE 10 serve al velo che si scosta**: le celle della
/// sagoma che cadono dentro questo rettangolo, allargato del margine, sono la
/// testa, e la testa non si scosta prima della quarta discesa
/// (`IlVeloDellAnimale`). **Qui c'erano anche le tre fasce orizzontali della
/// lente**, il suo raggio e il punto dove tenerne il centro: se ne sono andati
/// con la lente, perche' il fondatore ha nominato proprio quelle fasce come il
/// difetto, e nessun altro le usava.
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
  /// catalogo**: se un tredicesimo animale arrivasse senza la sua riga, il
  /// velo non saprebbe quale parte proteggere.
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
  /// una decina di pixel di sfumatura, e una cella che si ferma **esatta**
  /// sul confine ne lascerebbe passare qualcuno.
  static const double margineDiSicurezza = 0.01;
}
