import '../astro/zodiac.dart';
import 'cielo_della_sinastria.dart';
import 'testi_della_sinastria.dart';
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
      sopraIlCerchio:
          TestiDellaSinastria.sopraIlCerchio[relazione]![fascia]!,
      titoloDellaBolla:
          TestiDellaSinastria.titoliDellaBolla[relazione]![fascia]!,
      corpo: [
        _apertura(relazione, tuoSegno, vip.sign, seme),
        _ilCielo(aspetti),
        personaggio,
        _laStoccata(vip, fascia, seme),
      ].where((p) => p.isNotEmpty).join(' '),
      nota: _laNota(vip: vip, oraDelVipNota: oraDelVipNota, adesso: adesso),
      sfida: laSfida(nome: vip.name, percento: percento, seme: seme),
    );
  }

  /// Il responso fra due VIP: cambia chi si presenta, non la forma.
  static PezziDelResponso fraDueVip({
    required Vip primo,
    required Vip secondo,
    required int percento,
    required List<AspettoDiSinastria> aspetti,
    required DateTime adesso,
  }) {
    final relazione = TestiDellaSinastria.relazione(primo.sign, secondo.sign);
    final fascia = TestiDellaSinastria.fascia(percento);
    final seme = primo.sign.index + secondo.sign.index * 3 + percento;
    return PezziDelResponso(
      sopraIlCerchio:
          TestiDellaSinastria.sopraIlCerchio[relazione]![fascia]!,
      titoloDellaBolla:
          TestiDellaSinastria.titoliDellaBolla[relazione]![fascia]!,
      corpo: [
        _apertura(relazione, primo.sign, secondo.sign, seme),
        _ilCielo(aspetti),
        // I due si presentano insieme, come nell'esempio del corpus.
        'Da una parte ${_ilPersonaggio(primo, seme, adesso, conNome: false)}'
            '; dall\'altra '
            '${_ilPersonaggio(secondo, seme + 1, adesso, conNome: false)}',
        _laStoccata(secondo, fascia, seme),
      ].where((p) => p.isNotEmpty).join(' '),
      nota: _laNota(vip: secondo, oraDelVipNota: false, adesso: adesso),
      sfida: laSfida(nome: secondo.name, percento: percento, seme: seme),
    );
  }

  /// LA SFIDA DA CONDIVIDERE, che oggi era sempre la stessa riga.
  static String laSfida(
          {required String nome, required int percento, int seme = 0}) =>
      TestiDellaSinastria.sfide[(seme + 2) % TestiDellaSinastria.sfide.length]
          .replaceAll('NOME', nome)
          .replaceAll('PERCENTO', '$percento per cento');

  static String _apertura(
      RelazioneFraSegni relazione, Zodiac a, Zodiac b, int seme) {
    final righe = TestiDellaSinastria.aperture[relazione]!;
    return righe[seme % righe.length]
        .replaceAll('SEGNO_A', a.italianName)
        .replaceAll('SEGNO_B', b.italianName);
  }

  /// IL CIELO RESO LEGGIBILE: prima cosa significa, poi come si chiama.
  ///
  /// Il nome tecnico resta, perche' e' la prova che il numero non e'
  /// inventato, ma viene dopo. Senza aspetti si dice quello, che e' un fatto
  /// anche lui, invece di inventarne uno.
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
    final scarto = primo.orbo < 1
        ? 'esatto al grado'
        : 'a ${primo.gradi} dall\'angolo esatto';
    return '$significato: ${primo.fatto}, $scarto.';
  }

  /// IL PERSONAGGIO, con la sua attualita' quando c'e' e vale.
  static String _ilPersonaggio(Vip vip, int seme, DateTime adesso,
      {bool conNome = true}) {
    final presentazione = _presentazioneDi(vip);
    if (vip.eScomparso) {
      // **PER CHI NON C'E' PIU' il tempo cambia e non si fa dell'ironia sulla
      // morte**: la forma e' quella che il corpus dichiara, e nessuna
      // attualita' entra.
      return conNome
          ? '${vip.name}, che $presentazione.'
          : '${vip.name}, che $presentazione';
    }
    final fatto = vip.attualitaAl(adesso);
    if (fatto == null) {
      return conNome
          ? '${vip.name}, che $presentazione.'
          : '${vip.name}, che $presentazione';
    }
    final giuntura = TestiDellaSinastria
        .giunture[(seme + 1) % TestiDellaSinastria.giunture.length];
    final composta = giuntura
        .replaceAll('NOME', vip.name)
        .replaceAll('PRESENTAZIONE', presentazione)
        .replaceAll('FATTO', fatto);
    return conNome ? composta : composta.replaceAll(RegExp(r'\.$'), '');
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
    if (!oraDelVipNota) pezzi.add(TestiDellaSinastria.notaOraIgnota);
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
