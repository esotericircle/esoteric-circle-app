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
        schermata: 'lib/features/maestri/caligo/rune/rune_draw_screen.dart'),
    SorgenteDelGesto(
        gesto: 'soffio',
        schermata: 'lib/features/rituals/breath_destiny_screen.dart'),
    SorgenteDelGesto(
        gesto: 'alba', schermata: 'lib/features/rituals/dawn_rite_screen.dart'),
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
    // Ordine BF voce 05.b: la meditazione ha una fine, e al compimento la
    // schermata manda il gesto che sveglia aur_50 e aur_51.
    SorgenteDelGesto(
        gesto: 'meditazione',
        schermata:
            'lib/features/maestri/aura/meditation/meditation_screen.dart'),
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
        gesto: 'numero_della_vita',
        schermata: 'lib/features/passport/cosmic_passport_screen.dart'),
    SorgenteDelGesto(
        gesto: 'ora_di_nascita',
        schermata: 'lib/features/passport/cosmic_passport_screen.dart'),
    SorgenteDelGesto(
        gesto: 'angelo_custode',
        schermata: 'lib/features/angels/angels_screen.dart'),
    SorgenteDelGesto(
        gesto: 'animale_guida',
        schermata:
            'lib/features/maestri/caligo/animal/guide_animal_screen.dart'),

    // --- LE ARTI CHE NON ESISTONO ANCORA --------------------------------

    // --- I GESTI CHE NON NASCONO DA UNA SCHERMATA -----------------------
    SorgenteDelGesto(
      gesto: 'presenza',
      derivato: true,
      perche: 'È l\'apertura dell\'app, non un\'arte: nessuna schermata la '
          'compie, la registra il guscio.',
    ),
    // --- I PEZZI COMPOSTI DEL PASSAPORTO, ordine AR voce 02 -------------
    //
    // Il corpus della revisione C nomina cose che la persona TROVA nel
    // Passaporto invece di gesti che compie: la nascita scritta per intero,
    // il Sigillo del Cerchio, la Luna che vegliava, il nome custodito. Non
    // hanno una schermata che li manda, perche' nascono dalla composizione di
    // pezzi che gia' esistono: li deriva `pezziDellIdentitaMaturi`.
    SorgenteDelGesto(
      gesto: 'nascita_completa',
      derivato: true,
      perche: 'Giorno, ora e luogo scritti insieme: si compone dai tre pezzi '
          'che esistono già, non da un gesto in più.',
    ),
    // **TRE PORTE VERE AL POSTO DI TRE DERIVATI.** Ordine BD voce 05: questi
    // tre maturavano in blocco, il Sigillo e la Luna col Passaporto pieno e il
    // nome mai, perché nessuno lo segnava. Ora ognuno ha la sua schermata.
    SorgenteDelGesto(
      gesto: 'sigillo_del_cerchio',
      perche: 'Si scopre aprendo la schermata del Sigillo del Cerchio dal '
          'Passaporto.',
    ),
    SorgenteDelGesto(
      gesto: 'luna_natale',
      perche: 'Si scopre aprendo il portale del cielo di nascita dal '
          'Passaporto.',
    ),
    SorgenteDelGesto(
      gesto: 'nome_proprio',
      perche: 'Matura al primo saluto per nome nel Santuario: è lì che il '
          'Cerchio dimostra di custodirlo.',
    ),
    SorgenteDelGesto(gesto: 'condivisione_stella', derivato: true),
    SorgenteDelGesto(gesto: 'condivisione_frutto', derivato: true),
    SorgenteDelGesto(gesto: 'condivisione_petalo', derivato: true),

    // --- I GESTI NUOVI DEGLI ORDINI BW E BX, ognuno con la sua schermata ---
    //
    // **Un gesto che l'app manda e nessuno censisce e' il difetto che questa
    // lista esiste per impedire.** Svegliando i gradini che dormivano sono
    // nati gesti nuovi: qui si dichiara chi li manda, come per tutti gli
    // altri.
    SorgenteDelGesto(
        gesto: 'ascendente',
        schermata: 'lib/features/onboarding/natal_chart_reveal.dart'),
    SorgenteDelGesto(
        gesto: 'runa_girata',
        schermata: 'lib/features/maestri/caligo/rune/rune_draw_screen.dart'),
    SorgenteDelGesto(
        gesto: 'bosco',
        schermata: 'lib/features/maestri/caligo/animal/bosco_del_cerchio.dart'),
    SorgenteDelGesto(
        gesto: 'due_volti',
        schermata:
            'lib/features/maestri/aura/face/face_constellation_screen.dart'),
    // **I TRE INVITI ACCOLTI ARRIVANO DAL SERVER, non da una schermata.**
    // Ordine BX voce 02: il telefono non puo' sapere se qualcuno e' entrato
    // col tuo invito, lo sa il Cerchio quando quella persona riscatta il
    // codice. La regia li allinea al cammino a ogni apertura, dal conto che
    // lo stato porta con se'.
    SorgenteDelGesto(gesto: 'invito_medora', derivato: true),
    SorgenteDelGesto(gesto: 'invito_aura', derivato: true),
    SorgenteDelGesto(gesto: 'invito_caligo', derivato: true),
  ];

  static SorgenteDelGesto? di(String gesto) {
    for (final s in tutte) {
      if (s.gesto == gesto) return s;
    }
    return null;
  }

  /// Le arti che hanno una schermata e devono quindi mandare il loro gesto.
  static List<SorgenteDelGesto> get conSchermata => [
        for (final s in tutte)
          if (s.costruito) s
      ];

  /// Le arti dichiarate mancanti, che il rapporto elenca.
  static List<SorgenteDelGesto> get senzaSchermata => [
        for (final s in tutte)
          if (!s.costruito && !s.derivato) s
      ];
}
