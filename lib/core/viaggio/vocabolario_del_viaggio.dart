/// **IL VOCABOLARIO DEL VIAGGIO DELLO SCIAMANO.** Ordine DC voce 06,
/// 10 settembre 2026.
///
/// **IL PRINCIPIO, che l'ordine detta e che vale piu' del contenuto**: la
/// risposta del viaggio e' una scena, e la scena **si compone, non si pesca**.
/// E' il principio del mazzo di tarocchi: *"pochi elementi rispondono a tutto
/// perche' il senso nasce dalla combinazione"*.
///
/// **PERCHE' CONTA.** Settantotto carte rispondono a qualunque domanda da
/// seicento anni, e nessuno le ha mai trovate poche.
/// **Quarantaquattro** figure disegnate fanno **8.640 scene distinte**, e ogni
/// disegno lavora in centinaia di scene invece che in una sola. **L ordine dice
/// quaranta: 12 piu 18 piu 10 piu 4 fa quarantaquattro, ed e dichiarato nel
/// manifesto sotto la Regola ZERO.**
///
/// **IL CONTEGGIO NON SI SCRIVE A MANO.** L'ordine e' esplicito: si calcola
/// dal catalogo, e una guardia rifa' il prodotto e verifica che scenda
/// togliendo una categoria. E' la stessa regola gia' applicata alla
/// Costellazione del Viso, dove un numero scritto a mano aveva promesso
/// centoquattromila combinazioni che non reggevano.
///
/// **QUESTO VOCABOLARIO E' PROVVISORIO**, e l'ordine lo dichiara: sta qui in
/// attesa dei disegni del fondatore. **Non se ne aggiunge e non se ne toglie
/// senza dichiararlo**, perche' ogni voce in piu' o in meno cambia il numero
/// che l'app mostra.
library;

/// Le quattro categorie da cui una scena si compone.
enum CategoriaDellaScena {
  luogo('il luogo dove ti porta'),
  cosa('ciò che si trova lì'),
  gesto('cosa fa l\'animale'),
  momento('il momento');

  const CategoriaDellaScena(this.comeSiChiama);

  /// Come la categoria si nomina a chi legge, senza gergo.
  final String comeSiChiama;
}

/// Un elemento del vocabolario: un pezzo di scena disegnato.
class PezzoDellaScena {
  const PezzoDellaScena({
    required this.id,
    required this.nome,
    required this.categoria,
  });

  /// L'id stabile, che non cambia quando il nome si rifinisce: e' quello che
  /// finisce nel Diario e nella memoria, e deve reggere nel tempo.
  final String id;

  /// Come si nomina nella scena, in italiano.
  final String nome;

  final CategoriaDellaScena categoria;
}

abstract final class VocabolarioDelViaggio {
  /// **IL LUOGO DOVE L'ANIMALE PORTA**, dodici.
  static const List<PezzoDellaScena> luoghi = [
    PezzoDellaScena(
        id: 'ponte', nome: 'il ponte', categoria: CategoriaDellaScena.luogo),
    PezzoDellaScena(
        id: 'soglia', nome: 'la soglia', categoria: CategoriaDellaScena.luogo),
    PezzoDellaScena(
        id: 'bivio', nome: 'il bivio', categoria: CategoriaDellaScena.luogo),
    PezzoDellaScena(
        id: 'radura', nome: 'la radura', categoria: CategoriaDellaScena.luogo),
    PezzoDellaScena(
        id: 'grotta', nome: 'la grotta', categoria: CategoriaDellaScena.luogo),
    PezzoDellaScena(
        id: 'fiume', nome: 'il fiume', categoria: CategoriaDellaScena.luogo),
    PezzoDellaScena(
        id: 'cima', nome: 'la cima', categoria: CategoriaDellaScena.luogo),
    PezzoDellaScena(
        id: 'casa_vuota',
        nome: 'la casa vuota',
        categoria: CategoriaDellaScena.luogo),
    PezzoDellaScena(
        id: 'bosco_fitto',
        nome: 'il bosco fitto',
        categoria: CategoriaDellaScena.luogo),
    PezzoDellaScena(
        id: 'riva', nome: 'la riva', categoria: CategoriaDellaScena.luogo),
    PezzoDellaScena(
        id: 'scala', nome: 'la scala', categoria: CategoriaDellaScena.luogo),
    PezzoDellaScena(
        id: 'cerchio_di_pietre',
        nome: 'il cerchio di pietre',
        categoria: CategoriaDellaScena.luogo),
  ];

  /// **CIO' CHE SI TROVA LI'**, diciotto.
  static const List<PezzoDellaScena> cose = [
    PezzoDellaScena(
        id: 'chiave', nome: 'la chiave', categoria: CategoriaDellaScena.cosa),
    PezzoDellaScena(
        id: 'fuoco_acceso',
        nome: 'il fuoco acceso',
        categoria: CategoriaDellaScena.cosa),
    PezzoDellaScena(
        id: 'porta_chiusa',
        nome: 'la porta chiusa',
        categoria: CategoriaDellaScena.cosa),
    PezzoDellaScena(
        id: 'corda', nome: 'la corda', categoria: CategoriaDellaScena.cosa),
    PezzoDellaScena(
        id: 'specchio',
        nome: 'lo specchio',
        categoria: CategoriaDellaScena.cosa),
    PezzoDellaScena(
        id: 'seme', nome: 'il seme', categoria: CategoriaDellaScena.cosa),
    PezzoDellaScena(
        id: 'ferita_nel_tronco',
        nome: 'la ferita nel tronco',
        categoria: CategoriaDellaScena.cosa),
    PezzoDellaScena(
        id: 'nido', nome: 'il nido', categoria: CategoriaDellaScena.cosa),
    PezzoDellaScena(
        id: 'osso', nome: 'l\'osso', categoria: CategoriaDellaScena.cosa),
    PezzoDellaScena(
        id: 'filo', nome: 'il filo', categoria: CategoriaDellaScena.cosa),
    PezzoDellaScena(
        id: 'ciotola_rovesciata',
        nome: 'la ciotola rovesciata',
        categoria: CategoriaDellaScena.cosa),
    PezzoDellaScena(
        id: 'ombra_non_tua',
        nome: 'l\'ombra che non è tua',
        categoria: CategoriaDellaScena.cosa),
    PezzoDellaScena(
        id: 'pietra_spaccata',
        nome: 'la pietra spaccata',
        categoria: CategoriaDellaScena.cosa),
    PezzoDellaScena(
        id: 'piuma', nome: 'la piuma', categoria: CategoriaDellaScena.cosa),
    PezzoDellaScena(
        id: 'acqua_ferma',
        nome: 'l\'acqua ferma',
        categoria: CategoriaDellaScena.cosa),
    PezzoDellaScena(
        id: 'ramo_secco',
        nome: 'il ramo secco',
        categoria: CategoriaDellaScena.cosa),
    PezzoDellaScena(
        id: 'maschera',
        nome: 'la maschera',
        categoria: CategoriaDellaScena.cosa),
    PezzoDellaScena(
        id: 'cerchio_a_terra',
        nome: 'il cerchio tracciato a terra',
        categoria: CategoriaDellaScena.cosa),
  ];

  /// **COSA FA L'ANIMALE**, dieci.
  static const List<PezzoDellaScena> gesti = [
    PezzoDellaScena(
        id: 'si_ferma', nome: 'si ferma', categoria: CategoriaDellaScena.gesto),
    PezzoDellaScena(
        id: 'ti_precede',
        nome: 'ti precede',
        categoria: CategoriaDellaScena.gesto),
    PezzoDellaScena(
        id: 'si_volta',
        nome: 'si volta a guardarti',
        categoria: CategoriaDellaScena.gesto),
    PezzoDellaScena(
        id: 'scava', nome: 'scava', categoria: CategoriaDellaScena.gesto),
    PezzoDellaScena(
        id: 'guarda_in_alto',
        nome: 'guarda in alto',
        categoria: CategoriaDellaScena.gesto),
    PezzoDellaScena(
        id: 'si_mette_in_mezzo',
        nome: 'si mette in mezzo',
        categoria: CategoriaDellaScena.gesto),
    PezzoDellaScena(
        id: 'si_allontana',
        nome: 'si allontana',
        categoria: CategoriaDellaScena.gesto),
    PezzoDellaScena(
        id: 'si_accuccia',
        nome: 'si accuccia',
        categoria: CategoriaDellaScena.gesto),
    PezzoDellaScena(
        id: 'mostra_i_denti',
        nome: 'mostra i denti',
        categoria: CategoriaDellaScena.gesto),
    PezzoDellaScena(
        id: 'aspetta', nome: 'aspetta', categoria: CategoriaDellaScena.gesto),
  ];

  /// **IL MOMENTO**, quattro.
  static const List<PezzoDellaScena> momenti = [
    PezzoDellaScena(
        id: 'alba', nome: 'all\'alba', categoria: CategoriaDellaScena.momento),
    PezzoDellaScena(
        id: 'notte',
        nome: 'nella notte',
        categoria: CategoriaDellaScena.momento),
    PezzoDellaScena(
        id: 'nebbia',
        nome: 'nella nebbia',
        categoria: CategoriaDellaScena.momento),
    PezzoDellaScena(
        id: 'pioggia',
        nome: 'sotto la pioggia',
        categoria: CategoriaDellaScena.momento),
  ];

  /// Tutte e quattro le categorie, in fila.
  static List<List<PezzoDellaScena>> get categorie =>
      [luoghi, cose, gesti, momenti];

  /// Tutti i pezzi disegnati, in fila.
  static List<PezzoDellaScena> get tutti =>
      [for (final c in categorie) ...c];

  /// **QUANTE SCENE DISTINTE ESISTONO**, e il numero si CALCOLA.
  ///
  /// Ordine DC voce 06: *"il conteggio si calcola dal catalogo e non si scrive
  /// a mano, e la guardia lo verifica come gia' fatto per la Costellazione del
  /// Viso"*. Li' un numero scritto a mano aveva promesso centoquattromila
  /// combinazioni, e la promessa non reggeva.
  static int quanteScene() {
    var quante = 1;
    for (final c in categorie) {
      quante *= c.length;
    }
    return quante;
  }

  /// **QUANTI DISEGNI SERVONO** per quelle scene: la somma, non il prodotto.
  ///
  /// E' il numero che dice quanto costa questa funzione, ed e' l'altra meta'
  /// della promessa: **quaranta disegni per ottomila scene**.
  static int quantiDisegni() => tutti.length;

  /// La riga che dichiara l'ampiezza a chi legge, col numero vero.
  static String laRiga() =>
      '${_conIPunti(quanteScene())} scene possibili, da '
      '${quantiDisegni()} figure.';

  /// Il pezzo con questo id, o nulla: serve a rileggere il Diario dopo che i
  /// nomi si sono rifiniti.
  static PezzoDellaScena? di(String id) {
    for (final p in tutti) {
      if (p.id == id) return p;
    }
    return null;
  }

  static String _conIPunti(int n) {
    final cifre = n.toString();
    final b = StringBuffer();
    for (var i = 0; i < cifre.length; i++) {
      if (i > 0 && (cifre.length - i) % 3 == 0) b.write('.');
      b.write(cifre[i]);
    }
    return b.toString();
  }
}
