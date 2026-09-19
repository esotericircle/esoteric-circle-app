import '../astro/zodiac.dart';
import 'cielo_della_sinastria.dart';
import 'lo_specchio.dart';
import 'testi_della_sinastria.dart';
import 'testi_dello_specchio.dart';
import 'vip_catalog.dart';

/// I CINQUE PEZZI DEL RESPONSO, ognuno con la sua casa a schermo.
/// Ordine CA voce 04.
///
/// Il corpus `docs/corpus/sinastria_testi.md` li elenca cosi': la frase sopra
/// il cerchio, il titolo della bolla, il corpo della bolla, la nota fuori
/// dalla bolla, la sfida da condividere. Tre di questi **non esistevano**: il
/// responso era una bolla sola con dentro tutto, disclaimer compreso.
class PezziDelResponso {
  const PezziDelResponso({
    required this.sopraIlCerchio,
    required this.titoloDellaBolla,
    required this.corpo,
    required this.nota,
    required this.sfida,
    this.oraDiNascita = '',
    this.luogoDiResidenza = '',
  });

  /// La riga che si legge PRIMA della percentuale. Sostituisce l'etichetta
  /// che stava dentro il cerchio e che dipendeva dalla sola fascia.
  final String sopraIlCerchio;

  /// Il titolo della bolla, da titolo di giornale.
  final String titoloDellaBolla;

  /// Le quattro frasi cucite: apertura, cielo, personaggio, stoccata.
  final String corpo;

  /// Cio' che non deve stare in mezzo alla battuta: l'ora di nascita ignota,
  /// il luogo ignoto, la data dell'attualita'. Vuota quando non c'e' niente
  /// da dichiarare.
  final String nota;

  /// La riga sopra il pulsante di condivisione.
  final String sfida;

  /// **LE DUE RIGHE DEL PERSONAGGIO, in OGNI responso. Ordine CC voce 06g.**
  ///
  /// Rilievo del fondatore, 29 agosto 2026, verbatim: "quando non si conosce
  /// l'orario di nascita del vip c'e' sempre un testo che dice "non si finge
  /// cio' che non si conosce" ecc. eliminalo! al suo posto, ma in ogni responso
  /// inserisci 2 righe con Ora di Nascita: e Luogo di Residenza: e se non si
  /// conosce si mette semplicemente "SCONOSCIUTO" dopo i due punti".
  ///
  /// **Ci sono sempre**, anche quando i due dati si conoscono: e' la richiesta
  /// alla lettera, ed e' anche piu' onesta di prima, perche' prima il silenzio
  /// voleva dire "si sa" e nessuno poteva esserne sicuro.
  final String oraDiNascita;
  final String luogoDiResidenza;
}

/// COMPONE IL RESPONSO SECONDO IL CORPUS, revisione B. Ordine CA voce 04.
///
/// **Perche' esiste.** Il fondatore ha giudicato il responso scarno: "si tratta
/// di un testo che deve diventare virale quindi oltre ad un titolo
/// accattivante, memorabile, malizioso, d'impatto e anche un po' esagerato, il
/// testo descrittivo deve essere altrettanto memorabile". Quello che c'era era
/// un montaggio di tre frammenti che non si parlavano: una riga sull'aspetto
/// in gradi, una frase sul personaggio senza cucitura, e una chiusura uguale
/// per tutti, piu' tre righe di disclaimer dentro la bolla.
///
/// **Nessuna riga di questo file e' scritta qui**: vengono tutte da
/// `TestiDellaSinastria`, che nasce dal corpus. Qui si sceglie e si cuce.
///
/// **La rotazione e' deterministica per coppia**, come gia' faceva la chiusura
/// ironica di prima: la stessa coppia legge sempre lo stesso responso, coppie
/// vicine ne leggono di diversi. Ogni pezzo ha il suo scarto, altrimenti
/// apertura, stoccata e sfida cambierebbero tutte insieme e la rotazione si
/// vedrebbe.
class ResponsoDellaSinastria {
  const ResponsoDellaSinastria._();

  /// Il responso con la persona da una parte e un VIP dall'altra.
  static PezziDelResponso perTeConUnVip({
    required Zodiac tuoSegno,
    required Vip vip,
    required int percento,
    required List<AspettoDiSinastria> aspetti,
    required bool oraDelVipNota,
    required DateTime adesso,
  }) {
    final relazione = TestiDellaSinastria.relazione(tuoSegno, vip.sign);
    final fascia = TestiDellaSinastria.fascia(percento);
    final seme = tuoSegno.index + vip.sign.index * 3 + percento;
    final personaggio = _ilPersonaggio(vip, seme, adesso);
    return PezziDelResponso(
      sopraIlCerchio: TestiDellaSinastria.sopraIlCerchio[relazione]![fascia]!,
      titoloDellaBolla:
          TestiDellaSinastria.titoliDellaBolla[relazione]![fascia]!,
      corpo: [
        _apertura(relazione, tuoSegno, vip.sign, seme),
        _ilCielo(aspetti),
        personaggio,
        // **IL PARAGRAFO DELL'ATTUALITA', che prima era una subordinata.**
        // Ordine CC voce 06d: il fondatore ne vuole uno suo.
        _lAttualita(vip, seme, adesso),
        _laStoccata(vip, fascia, seme),
      ].where((p) => p.isNotEmpty).join(' '),
      nota: _laNota(vip: vip, oraDelVipNota: oraDelVipNota, adesso: adesso),
      sfida: laSfida(nome: vip.name, percento: percento, seme: seme),
      oraDiNascita: _oraDiNascita(oraDelVipNota),
      luogoDiResidenza: _luogoDiResidenza(vip),
    );
  }

  /// Il responso fra due VIP: cambia chi si presenta, non la forma.
  ///
  /// **[barraPiuBassa] e [volta] servono solo allo specchio**, cioè alla
  /// coppia fatta dallo stesso personaggio due volte, ordine DR: la prima
  /// dice quale delle sei barre il calcolo ha messo più in basso, perché il
  /// testo la spieghi guardando il numero vero; la seconda dice quante volte
  /// questa persona ha già aperto una scheda allo specchio, perché la battuta
  /// cambi a ogni giro.
  static PezziDelResponso fraDueVip({
    required Vip primo,
    required Vip secondo,
    required int percento,
    required List<AspettoDiSinastria> aspetti,
    required DateTime adesso,
    String barraPiuBassa = '',
    int volta = 0,
  }) {
    // **LO SPECCHIO PRIMA DI TUTTO**, ordine DR voce 01: una porta sola
    // decide, e qui la si interroga.
    if (LoSpecchio.sono(primo, secondo)) {
      return _alloSpecchio(
        vip: primo,
        percento: percento,
        aspetti: aspetti,
        adesso: adesso,
        barraPiuBassa: barraPiuBassa,
        volta: volta,
      );
    }
    final relazione = TestiDellaSinastria.relazione(primo.sign, secondo.sign);
    final fascia = TestiDellaSinastria.fascia(percento);
    final seme = primo.sign.index + secondo.sign.index * 3 + percento;
    return PezziDelResponso(
      sopraIlCerchio: TestiDellaSinastria.sopraIlCerchio[relazione]![fascia]!,
      titoloDellaBolla:
          TestiDellaSinastria.titoliDellaBolla[relazione]![fascia]!,
      corpo: [
        // **L'APERTURA E' QUELLA SCRITTA PER DUE VIP**, ordine DR voce 05:
        // quelle di sempre danno del tu a chi guarda, che qui non è nessuno
        // dei due.
        _aperturaFraDueVip(relazione, primo.sign, secondo.sign, seme),
        _ilCielo(aspetti),
        // I due si presentano insieme, come nell'esempio del corpus.
        // **IL PUNTO FERMO RESTA ALLA SECONDA META'**, ordine DR voce 05: lo
        // si toglie alla prima perché dopo arriva "; dall'altra", e lo si
        // teneva via anche alla seconda, dove dopo arriva l'attualità con la
        // maiuscola. A video si leggeva "non cambia mai foglio Un'intesa
        // così".
        'Da una parte ${_ilPersonaggio(primo, seme, adesso, conNome: false)}'
            '; dall\'altra '
            '${_ilPersonaggio(secondo, seme + 1, adesso)}',
        _lAttualita(secondo, seme, adesso),
        _laStoccata(secondo, fascia, seme),
      ].where((p) => p.isNotEmpty).join(' '),
      // **LA NOTA, LA SFIDA E LA RESIDENZA PARLANO DELLA COPPIA**, ordine DR
      // voce 05: passavano tutte e tre il solo secondo, e il primo spariva
      // dalla scheda.
      nota: _laNotaDellaCoppia(primo: primo, secondo: secondo, adesso: adesso),
      sfida: sfidaFraDueVip(
          primo: primo.name, secondo: secondo.name, percento: percento,
          seme: seme),
      oraDiNascita: _oraDiNascita(false),
      luogoDiResidenza: _luogoDiResidenzaDellaCoppia(primo, secondo),
    );
  }

  /// **LA COPPIA ALLO SPECCHIO**, ordine DR voci 02, 03 e 04.
  ///
  /// **Il numero non si tocca**: il cerchio e le sei barre mostrano quello
  /// che il calcolo ha prodotto, e il lavoro sta tutto nelle parole, che
  /// spiegano perché non è cento e perché la barra più bassa è quella lì.
  ///
  /// **Chi non c'è più riceve la forma sobria**, senza battute.
  static PezziDelResponso _alloSpecchio({
    required Vip vip,
    required int percento,
    required List<AspettoDiSinastria> aspetti,
    required DateTime adesso,
    required String barraPiuBassa,
    required int volta,
  }) {
    if (vip.eScomparso) {
      return PezziDelResponso(
        sopraIlCerchio: TestiDelloSpecchio.sopraIlCerchioPerChiNonCePiu,
        titoloDellaBolla: TestiDelloSpecchio.titoloPerChiNonCePiu,
        corpo: TestiDelloSpecchio.corpoPerChiNonCePiu
            .map((r) => _conIDati(r, nome: vip.name, percento: percento))
            .join(' '),
        nota: _laNota(vip: vip, oraDelVipNota: false, adesso: adesso),
        sfida: _conIDati(TestiDelloSpecchio.sfidaPerChiNonCePiu,
            nome: vip.name, percento: percento),
        oraDiNascita: _oraDiNascita(false),
        luogoDiResidenza: _luogoDiResidenza(vip),
      );
    }
    final quale = varianteDelloSpecchio(vip, volta);
    final riga = TestiDelloSpecchio.laBarraPiuBassa[barraPiuBassa];
    return PezziDelResponso(
      sopraIlCerchio: TestiDelloSpecchio.sopraIlCerchio[quale],
      titoloDellaBolla: TestiDelloSpecchio.titoli[quale],
      corpo: [
        _conIDati(TestiDelloSpecchio.ilGesto[quale],
            nome: vip.name, percento: percento),
        _conIDati(TestiDelloSpecchio.percheNonCento[quale],
            nome: vip.name, percento: percento),
        // **LA RIGA DELLA BARRA GUARDA LA BARRA VERA**, e quando chi chiama
        // non dice quale sia non si inventa niente: si tace.
        if (riga != null) riga[quale % riga.length],
        TestiDelloSpecchio.chiuse[quale],
      ].where((p) => p.isNotEmpty).join(' '),
      nota: _laNota(vip: vip, oraDelVipNota: false, adesso: adesso),
      sfida: _conIDati(TestiDelloSpecchio.sfide[quale],
          nome: vip.name, percento: percento),
      oraDiNascita: _oraDiNascita(false),
      luogoDiResidenza: _luogoDiResidenza(vip),
    );
  }

  /// **QUALE DELLE DODICI VARIANTI**, dall'identità del personaggio e da
  /// quante volte questa persona ha già aperto una scheda allo specchio.
  ///
  /// **Il conto delle lettere e non `hashCode`**: l'impronta di una stringa
  /// in Dart è stabile dentro una esecuzione ma non è promessa uguale fra
  /// una esecuzione e l'altra, e un testo che cambia al riavvio dell'app
  /// sarebbe un guasto travestito da sorpresa.
  static int varianteDelloSpecchio(Vip vip, int volta) {
    final identita = LoSpecchio.identitaDi(vip);
    var conto = 0;
    for (final c in identita.codeUnits) {
      conto = (conto + c) % TestiDelloSpecchio.quante;
    }
    return (conto + volta) % TestiDelloSpecchio.quante;
  }

  static String _conIDati(String riga,
          {required String nome, required int percento}) =>
      riga.replaceAll('NOME', nome).replaceAll('PERCENTO', '$percento');

  /// LA SFIDA DA CONDIVIDERE, che oggi era sempre la stessa riga.
  static String laSfida(
          {required String nome, required int percento, int seme = 0}) =>
      TestiDellaSinastria.sfide[(seme + 2) % TestiDellaSinastria.sfide.length]
          .replaceAll('NOME', nome)
          .replaceAll('PERCENTO', '$percento per cento');

  /// **LA SFIDA DI UNA COPPIA FRA DUE VIP**, che nomina tutti e due.
  /// Ordine DR voce 05: quella di sempre portava il solo secondo.
  static String sfidaFraDueVip({
    required String primo,
    required String secondo,
    required int percento,
    int seme = 0,
  }) =>
      TestiDellaSinastria.sfideFraDueVip[
              (seme + 2) % TestiDellaSinastria.sfideFraDueVip.length]
          .replaceAll('NOME_A', primo)
          .replaceAll('NOME_B', secondo)
          .replaceAll('PERCENTO', '$percento per cento');

  static String _apertura(
      RelazioneFraSegni relazione, Zodiac a, Zodiac b, int seme) {
    final righe = TestiDellaSinastria.aperture[relazione]!;
    return righe[seme % righe.length]
        .replaceAll('SEGNO_A', a.italianName)
        .replaceAll('SEGNO_B', b.italianName);
  }

  /// **L'APERTURA DI UNA COPPIA FRA DUE VIP**, in terza persona.
  /// Ordine DR voce 05.
  static String _aperturaFraDueVip(
      RelazioneFraSegni relazione, Zodiac a, Zodiac b, int seme) {
    final righe = TestiDellaSinastria.apertureFraDueVip[relazione]!;
    return righe[seme % righe.length]
        .replaceAll('SEGNO_A', a.italianName)
        .replaceAll('SEGNO_B', b.italianName);
  }

  /// IL CIELO RESO LEGGIBILE: quello che vi riguarda, e in coda da dove viene.
  ///
  /// **Rilievo del fondatore, 29 agosto 2026, verbatim:** "la bolla di
  /// responso e' troppo tecnica: parla per 3/4 di transiti e il resto lo dedica
  /// alla risposta vera e propria che interessa all'utente, ma deve essere il
  /// contrario".
  ///
  /// **Cosa e' uscito, e dove e' andato.** I gradi di scarto dall'angolo
  /// esatto: erano la parte piu' tecnica di tutta la bolla e non dicono niente
  /// a chi non fa astrologia. **Non sono spariti**: vivono nella pastiglia
  /// toccabile sotto il responso, dove chi vuole sapere di quell'aspetto lo
  /// tocca e li trova insieme al significato.
  ///
  /// **Il nome dell'aspetto resta**, breve e fra parentesi, perche' e' la prova
  /// che il numero non e' inventato: toglierlo del tutto farebbe di una lettura
  /// una battuta.
  ///
  /// **E il punto fermo di troppo non c'e' piu'.** Le frasi del corpus finiscono
  /// gia' col punto, e qui se ne aggiungeva un altro coi due punti: a video si
  /// leggeva "vi accorgete l'uno dell'altro.: il suo Marte...".
  static String _ilCielo(List<AspettoDiSinastria> aspetti) {
    if (aspetti.isEmpty) {
      return 'I vostri cieli si sfiorano senza toccarsi: nessuno dei punti '
          'che contano cade in aspetto con i tuoi.';
    }
    final primo = aspetti.first;
    final chiave = primo.titolo.toLowerCase();
    final significato = TestiDellaSinastria.cieloLeggibile[chiave] ??
        TestiDellaSinastria.genericoPerPianeta[primo.suo.nome] ??
        TestiDellaSinastria.genericoPerPianeta['Sole']!;
    final senzaPunto = significato.endsWith('.')
        ? significato.substring(0, significato.length - 1)
        : significato;
    return '$senzaPunto (${primo.fatto}).';
  }

  /// IL PERSONAGGIO, con la sua attualita' quando c'e' e vale.
  static String _ilPersonaggio(Vip vip, int seme, DateTime adesso,
      {bool conNome = true}) {
    final presentazione = _presentazioneDi(vip);
    if (vip.eScomparso) {
      // **PER CHI NON C'E' PIU' il tempo cambia e non si fa dell'ironia sulla
      // morte**: la forma e' quella che il corpus dichiara, e nessuna
      // attualita' entra.
      return _chiusa('${vip.name}, che $presentazione', conNome);
    }
    final fatto = vip.attualitaAl(adesso);
    if (fatto == null) {
      return _chiusa('${vip.name}, che $presentazione', conNome);
    }
    final giuntura = TestiDellaSinastria
        .giunture[(seme + 1) % TestiDellaSinastria.giunture.length];
    final composta = giuntura
        .replaceAll('NOME', vip.name)
        .replaceAll('PRESENTAZIONE', presentazione)
        .replaceAll('FATTO', fatto);
    return conNome ? composta : composta.replaceAll(RegExp(r'\.$'), '');
  }

  /// Chiude la frase col punto, e UNO SOLO.
  ///
  /// **Il punto doppio si vedeva a video.** Ordine CC voce 06c: alcune
  /// presentazioni del corpus finiscono gia' col punto, e qui se ne aggiungeva
  /// un altro. L'anteprima leggeva "mezzo mondo da salvare..", che sembra un
  /// puntino di sospensione mancato invece di un errore.
  static String _chiusa(String frase, bool conNome) {
    final nuda =
        frase.endsWith('.') ? frase.substring(0, frase.length - 1) : frase;
    return conNome ? '$nuda.' : nuda;
  }

  /// **IL PARAGRAFO DELL'ATTUALITA'. Ordine CC voce 06d.**
  ///
  /// Vuoto quando non c'e' niente di verificato da dire, e per chi non c'e'
  /// piu': e' la stessa regola dell'ordine BO voce 04, e non si fa cronaca su
  /// chi non puo' smentirla.
  ///
  /// **Le frasi che lo cuciono sono PROVVISORIE**, dichiarate in
  /// `TestiDellaSinastria.attualitaProvvisorie`.
  static String _lAttualita(Vip vip, int seme, DateTime adesso) {
    if (vip.eScomparso) return '';
    final fatto = vip.attualitaAl(adesso);
    if (fatto == null) return '';
    const righe = TestiDellaSinastria.attualitaProvvisorie;
    return righe[(seme + 3) % righe.length].replaceAll('FATTO', fatto);
  }

  /// La presentazione dal corpus, per lo stem del ritratto.
  static String _presentazioneDi(Vip vip) {
    final stem =
        vip.stem == null ? '' : vip.stem!.replaceAll(RegExp(r'_v\d+$'), '');
    return TestiDellaSinastria.presentazioni[stem] ??
        'porta con sé il suo mondo';
  }

  static String _laStoccata(Vip vip, FasciaDiAffinita fascia, int seme) {
    if (vip.eScomparso) {
      return TestiDellaSinastria
          .memoria[seme % TestiDellaSinastria.memoria.length];
    }
    final righe = TestiDellaSinastria.stoccate[fascia]!;
    return righe[(seme + 3) % righe.length];
  }

  /// **LA PAROLA CHE IL FONDATORE HA SCELTO** quando un dato non si conosce.
  /// Maiuscola, come l'ha scritta lui.
  static const String sconosciuto = 'SCONOSCIUTO';

  /// La riga dell'ora di nascita, che c'e' sempre.
  static String _oraDiNascita(bool nota) =>
      nota ? 'Ora di Nascita: nota' : 'Ora di Nascita: $sconosciuto';

  /// La riga del luogo di residenza, che c'e' sempre.
  ///
  /// Per chi non c'e' piu' non si scrive una residenza, e non e' una
  /// dimenticanza: e' la stessa regola per cui l'attualita' non entra.
  static String _luogoDiResidenza(Vip vip) {
    final dove = vip.eScomparso ? null : vip.luogoDiOggi;
    if (dove == null) return 'Luogo di Residenza: $sconosciuto';
    return 'Luogo di Residenza: ${dove.nome}, ${dove.nazione}';
  }

  /// LA NOTA, fuori dalla bolla e in corpo minore.
  ///
  /// Serve, perche' e' la regola di trasparenza del progetto, ma non deve
  /// stare in mezzo alla battuta: erano tre righe su otto dentro il testo che
  /// deve diventare virale.
  static String _laNota({
    required Vip vip,
    required bool oraDelVipNota,
    required DateTime adesso,
  }) {
    final pezzi = <String>[];
    // **IL TESTO DEL "NON SI FINGE" NON C'E' PIU'. Ordine CC voce 06g.** Il
    // fondatore: "eliminalo!". Al suo posto ci sono le due righe di sopra, che
    // dicono la stessa cosa in due parole e stanno in OGNI responso.
    if (vip.luogoDiOggi == null && !vip.eScomparso) {
      pezzi.add(TestiDellaSinastria.notaLuogoIgnoto);
    }
    final dalServer = CorrezioniDeiVip.attualitaDi(vip.name);
    final quando = dalServer?.verificataIl ?? vip.attualitaVerificataIl;
    if (quando != null && vip.attualitaAl(adesso) != null) {
      pezzi.add(TestiDellaSinastria.notaAttualita
          .replaceAll('GIORNO', _giornoItaliano(quando)));
    }
    return pezzi.join(' ');
  }

  /// **LA NOTA DI UNA COPPIA FRA DUE VIP**, ordine DR voce 05.
  ///
  /// Quella di sempre parlava del solo secondo: con due personaggi diversi il
  /// primo spariva dalla scheda, e chi leggeva non sapeva di chi fosse la
  /// notizia o il luogo ignoto. Qui si dice di chi è.
  static String _laNotaDellaCoppia({
    required Vip primo,
    required Vip secondo,
    required DateTime adesso,
  }) {
    final pezzi = <String>[];
    final senzaLuogo = [primo, secondo]
        .where((v) => v.luogoDiOggi == null && !v.eScomparso)
        .toList();
    if (senzaLuogo.length == 2) {
      pezzi.add(TestiDellaSinastria.notaLuogoIgnotoDiTutti
          .replaceAll('NOME_A', primo.name)
          .replaceAll('NOME_B', secondo.name));
    } else if (senzaLuogo.length == 1) {
      pezzi.add(TestiDellaSinastria.notaLuogoIgnotoDiUno
          .replaceAll('NOME', senzaLuogo.first.name));
    }
    for (final v in [primo, secondo]) {
      final dalServer = CorrezioniDeiVip.attualitaDi(v.name);
      final quando = dalServer?.verificataIl ?? v.attualitaVerificataIl;
      if (quando != null && v.attualitaAl(adesso) != null) {
        pezzi.add(TestiDellaSinastria.notaAttualitaDiUno
            .replaceAll('NOME', v.name)
            .replaceAll('GIORNO', _giornoItaliano(quando)));
      }
    }
    return pezzi.join(' ');
  }

  /// **LA RESIDENZA DI UNA COPPIA FRA DUE VIP**, ordine DR voce 05: il valore
  /// prima, e fra parentesi di chi è. Dove il dato non c'è resta la parola
  /// che il fondatore ha scelto.
  static String _luogoDiResidenzaDellaCoppia(Vip primo, Vip secondo) {
    String pezzo(Vip v) {
      final dove = v.eScomparso ? null : v.luogoDiOggi;
      if (dove == null) return '$sconosciuto (${v.name})';
      return '${dove.nome}, ${dove.nazione} (${v.name})';
    }

    return 'Luogo di Residenza: ${pezzo(primo)}; ${pezzo(secondo)}';
  }

  static String _giornoItaliano(DateTime d) {
    const mesi = [
      'gennaio',
      'febbraio',
      'marzo',
      'aprile',
      'maggio',
      'giugno',
      'luglio',
      'agosto',
      'settembre',
      'ottobre',
      'novembre',
      'dicembre'
    ];
    return '${d.day} ${mesi[d.month - 1]} ${d.year}';
  }
}
