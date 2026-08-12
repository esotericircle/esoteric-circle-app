/// CHI MANDA I GESTI AL CAMMINO, dichiarato in un punto solo.
/// Ordine P voce 35.
///
/// **Il fatto da cui nasce questo file.** Verificato sui quattro commit
/// dell'ordine O: le sole schermate collegate a `RegiaDelCammino` erano tre,
/// `rune_draw_screen.dart`, `breath_destiny_screen.dart` e
/// `dawn_rite_screen.dart`. `stesa_tre_carte_screen.dart` non compariva in
/// nessuno di quei commit, quindi una stesa completata non registrava niente e
/// nessun traguardo dei tarocchi poteva accendersi, ne' con tre stese ne' con
/// trecento. Nemmeno il Cosmic Passport era collegato, contro quanto si
/// credeva.
///
/// **Perche' un elenco e non una convenzione.** Finche' "chi manda cosa" era
/// una cosa che si sapeva leggendo, un'arte poteva nascere scollegata senza
/// che niente cadesse. Qui ogni gesto nominato dai 165 traguardi dichiara la
/// sua sorgente, e una prova enumera questo elenco e CADE COL NOME DEL FILE
/// quando una schermata che esiste non manda il suo gesto.
///
/// **I gesti senza schermata si dichiarano, non si nascondono.** Dove l'arte
/// non e' ancora costruita il traguardo resta visibile e non ancora
/// raggiungibile, come prescrive l'Allegato A: non si cambia il traguardo, si
/// dichiara il dato mancante.
library;

/// Da dove arriva un gesto del cammino.
class SorgenteDelGesto {
  const SorgenteDelGesto({
    required this.gesto,
    this.schermata,
    this.derivato = false,
    this.perche,
  });

  /// Il nome del gesto, quello che finisce in `DiarioDelCammino.segna`.
  final String gesto;

  /// Il file della schermata che lo manda. Nullo quando l'arte non esiste
  /// ancora, o quando il gesto non nasce da una schermata.
  final String? schermata;

  /// Vero se il gesto non lo manda nessuno perche' si RICAVA da altri: le
  /// ripetizioni, le giornate chiuse, le finestre del cielo. Chiedere a una
  /// schermata di mandarli sarebbe chiederle di sapere cose che non sa.
  final bool derivato;

  /// Perche' non c'e' una schermata, quando non c'e'. Va nel rapporto.
  final String? perche;

  bool get costruito => schermata != null;
}

/// L'elenco, gesto per gesto.
class GestiDelleArti {
  const GestiDelleArti._();

  static const List<SorgenteDelGesto> tutte = [
    // --- LE ARTI CHE COMPIONO UN GESTO E HANNO UNA SCHERMATA ------------
    SorgenteDelGesto(
        gesto: 'stesa',
        schermata: 'lib/features/tarot/stesa_tre_carte_screen.dart'),
    SorgenteDelGesto(
        gesto: 'gettata',
        schermata:
            'lib/features/maestri/caligo/rune/rune_draw_screen.dart'),
    SorgenteDelGesto(
        gesto: 'soffio',
        schermata: 'lib/features/rituals/breath_destiny_screen.dart'),
    SorgenteDelGesto(
        gesto: 'alba',
        schermata: 'lib/features/rituals/dawn_rite_screen.dart'),
    SorgenteDelGesto(
        gesto: 'tramonto',
        schermata: 'lib/features/rituals/sunset_rune_screen.dart'),
    SorgenteDelGesto(
        gesto: 'oracolo',
        schermata: 'lib/features/rituals/day_oracle_screen.dart'),
    SorgenteDelGesto(
        gesto: 'sogno',
        schermata: 'lib/features/rituals/dream_rite_screen.dart'),
    SorgenteDelGesto(
        gesto: 'oroscopo',
        schermata: 'lib/features/horoscope/oroscopo_screen.dart'),
    SorgenteDelGesto(
        gesto: 'sigillo',
        schermata:
            'lib/features/maestri/caligo/sigillo/sigillo_intenzione_screen.dart'),
    SorgenteDelGesto(
        gesto: 'viso',
        schermata:
            'lib/features/maestri/aura/face/face_constellation_screen.dart'),
    SorgenteDelGesto(
        gesto: 'archetipo',
        schermata:
            'lib/features/maestri/aura/archetype/archetype_test_screen.dart'),
    SorgenteDelGesto(
        gesto: 'sinastria',
        schermata: 'lib/features/synastry/sinastria_gallery_screen.dart'),
    SorgenteDelGesto(
        gesto: 'carta_natale',
        schermata: 'lib/features/passport/cosmic_passport_screen.dart'),
    SorgenteDelGesto(
        gesto: 'passaporto',
        schermata: 'lib/features/passport/cosmic_passport_screen.dart'),
    SorgenteDelGesto(
        gesto: 'numero_della_vita',
        schermata: 'lib/features/passport/cosmic_passport_screen.dart'),
    SorgenteDelGesto(
        gesto: 'ora_di_nascita',
        schermata: 'lib/features/passport/cosmic_passport_screen.dart'),
    SorgenteDelGesto(
        gesto: 'luogo_di_nascita',
        schermata: 'lib/features/passport/cosmic_passport_screen.dart'),
    SorgenteDelGesto(
        gesto: 'angelo_custode',
        schermata: 'lib/features/angels/angels_screen.dart'),
    SorgenteDelGesto(
        gesto: 'animale_guida',
        schermata:
            'lib/features/maestri/caligo/animal/guide_animal_screen.dart'),

    // --- LE ARTI CHE NON ESISTONO ANCORA --------------------------------
    SorgenteDelGesto(
      gesto: 'chakra',
      perche: 'La scansione dei chakra è un\'arte in arrivo del catalogo, '
          'chakra_scan: non esiste una schermata da cui compiere il gesto. I '
          'traguardi che la nominano restano visibili e non ancora '
          'raggiungibili.',
    ),
    SorgenteDelGesto(
      gesto: 'meditazione',
      perche: 'La schermata della meditazione ESISTE, ma non modella nessuna '
          'FINE: è un audio che si avvia e si ferma, senza durata nè '
          'compimento. Il traguardo chiede "completa una meditazione fino '
          'alla fine, senza uscire" e quella fine nel prodotto non esiste '
          'ancora. Non si manda un gesto finto: il traguardo resta visibile e '
          'non ancora raggiungibile, come prescrive l\'Allegato A.',
    ),
    SorgenteDelGesto(
      gesto: 'invito',
      perche: 'L\'invito a qualcuno nel Cerchio non ha ancora un flusso '
          'proprio: la condivisione esiste, l\'invito con aggancio no.',
    ),

    // --- I GESTI CHE NON NASCONO DA UNA SCHERMATA -----------------------
    SorgenteDelGesto(
      gesto: 'presenza',
      derivato: true,
      perche: 'È l\'apertura dell\'app, non un\'arte: nessuna schermata la '
          'compie, la registra il guscio.',
    ),
    SorgenteDelGesto(gesto: 'presenza_mattino', derivato: true),
    SorgenteDelGesto(gesto: 'presenza_sera', derivato: true),
    SorgenteDelGesto(gesto: 'condivisione_stella', derivato: true),
    SorgenteDelGesto(gesto: 'condivisione_frutto', derivato: true),
    SorgenteDelGesto(gesto: 'condivisione_petalo', derivato: true),
    SorgenteDelGesto(gesto: 'stella_accesa', derivato: true),
    SorgenteDelGesto(gesto: 'frutto_maturo', derivato: true),
    SorgenteDelGesto(gesto: 'petalo_aperto', derivato: true),
    SorgenteDelGesto(gesto: 'carta_ripetuta', derivato: true),
    SorgenteDelGesto(gesto: 'runa_ripetuta', derivato: true),
    SorgenteDelGesto(gesto: 'stesa_tipo_diverso', derivato: true),
    SorgenteDelGesto(gesto: 'gettata_tipo_diverso', derivato: true),
    SorgenteDelGesto(gesto: 'chakra_diverso', derivato: true),
    SorgenteDelGesto(gesto: 'chakra_ripetuto', derivato: true),
    SorgenteDelGesto(gesto: 'giorno_intero', derivato: true),
    SorgenteDelGesto(gesto: 'giorno_respirato', derivato: true),
    SorgenteDelGesto(gesto: 'notte_compiuta', derivato: true),
    SorgenteDelGesto(gesto: 'finestra_del_cielo', derivato: true),
    SorgenteDelGesto(gesto: 'finestra_del_cielo_corpo', derivato: true),
    SorgenteDelGesto(gesto: 'finestra_del_cielo_notte', derivato: true),
  ];

  static SorgenteDelGesto? di(String gesto) {
    for (final s in tutte) {
      if (s.gesto == gesto) return s;
    }
    return null;
  }

  /// Le arti che hanno una schermata e devono quindi mandare il loro gesto.
  static List<SorgenteDelGesto> get conSchermata =>
      [for (final s in tutte) if (s.costruito) s];

  /// Le arti dichiarate mancanti, che il rapporto elenca.
  static List<SorgenteDelGesto> get senzaSchermata =>
      [for (final s in tutte) if (!s.costruito && !s.derivato) s];
}
