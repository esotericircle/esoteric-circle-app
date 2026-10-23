import '../astro/meeus/il_cielo_di_meeus.dart';
import '../astro/birth_details.dart';
import '../identity/birth_identity.dart';
import '../astro/il_fuso_della_nascita.dart';
import '../astro/zodiac.dart';
import 'astro_tradition.dart';
import 'il_capodanno_lunare.dart';
import '../astro/il_segno_del_cielo.dart';

/// **IL SEGNO DELLA PERSONA IN OGNI TRADIZIONE, ordine ES voci 07 e 11.**
///
/// Il fondatore: *"Nel momento in cui seleziona l'oroscopo cinese, ad esempio,
/// non dovrebbe comparire il suo segno zodiacale Cinese al posto di quello
/// occidentale?"*. E per le quattro tradizioni in arrivo il segno si calcola
/// davvero (*"Il tuo segno maya è 9 Ix"*), anche se la lettura non c'e'.
///
/// Ogni segno si calcola da regole scritte e da fonti, mai da un modello: le
/// specifiche, le fonti e le dieci nascite di controllo stanno in
/// `docs/collaudo/ES/in_arrivo.txt` e `docs/collaudo/ES/cinese_e_vedica.txt`.
///
/// - **Occidentale**: il segno del Sole, tropicale.
/// - **Cinese**: l'animale dell'anno, che comincia col Capodanno lunare
///   ([IlCapodannoLunare]); vale la data civile del luogo di nascita.
/// - **Vedica**: il segno siderale della Luna (Chandra rashi), con
///   l'ayanamsa di Lahiri come la usa l'Indian Astronomical Ephemeris.
/// - **Maya**: il giorno dello Tzolk'in classico con la correlazione GMT
///   584283, non il Dreamspell del 1987.
/// - **Celtica**: l'albero del calendario di Robert Graves (1948), che e' una
///   costruzione moderna.
/// - **Egizia**: il decano del Sole, dalla lista di Efestione di Tebe.
/// - **Araba**: la dimora lunare della Luna, 28 settori regolari da 0 gradi
///   Ariete come nel Picatrix e in Agrippa; vuole l'ora di nascita.
class SegnoDellaTradizione {
  const SegnoDellaTradizione({
    required this.tradizione,
    required this.nome,
    required this.frase,
    this.zodiaco,
    this.animale,
    this.certo = true,
    this.nota,
  });

  final AstroTradition tradizione;

  /// Il nome del segno come si scrive sotto la figura: "Cavallo",
  /// "Karka (Cancro)", "9 Ix".
  final String nome;

  /// La frase intera: "Il tuo segno maya è 9 Ix".
  final String frase;

  /// La figura occidentale da mostrare, per l'Occidentale e per i rashi
  /// vedici che la usano; null per Mithuna e Makara, che hanno la loro.
  final Zodiac? zodiaco;

  /// Per la Cinese, l'animale da 0 (Topo) a 11 (Maiale).
  final int? animale;

  /// Falso quando senza l'ora di nascita il segno non si puo' dire.
  final bool certo;

  /// Cio' che la schermata deve dire accanto al segno, quando serve.
  final String? nota;

  /// **IL SEGNO DI UN'ALTRA PERSONA, ordine ES voce 12.** Visto sul Realme il
  /// 30 settembre 2026: nell'oroscopo di un'amica, sotto la figura, stava
  /// scritto "Il tuo segno è Capricorno", e il segno era di Lucia. La frase
  /// e la nota nascono per chi usa l'app; qui si dicono di [nome], e la
  /// guardia `l_oroscopo_dell_amico_parla_dell_amico` conta che nessun "tuo"
  /// resti per un anno di nascite nelle tre tradizioni.
  SegnoDellaTradizione dettoDi(String nome) => SegnoDellaTradizione(
        tradizione: tradizione,
        nome: this.nome,
        frase: frase
            .replaceFirst('Il tuo segno cinese', 'Il segno cinese di $nome')
            .replaceFirst('Il tuo segno vedico', 'Il segno vedico di $nome')
            .replaceFirst('Il tuo segno', 'Il segno di $nome'),
        zodiaco: zodiaco,
        animale: animale,
        certo: certo,
        nota: nota
            ?.replaceFirst('della tua nascita', 'della sua nascita')
            .replaceFirst('è il tuo segno', 'è il suo segno'),
      );
}

/// La nascita come la servono i segni: la data e l'ora del luogo, e il fuso.
class NascitaDeiSegni {
  const NascitaDeiSegni({
    required this.locale,
    required this.oraNota,
    this.fuso,
  });

  /// La nascita dai dati che l'app conserva.
  factory NascitaDeiSegni.daiDettagli(BirthDetails d) => NascitaDeiSegni(
        locale: DateTime(d.date.year, d.date.month, d.date.day,
            d.time?.hour ?? 12, d.time?.minute ?? 0),
        oraNota: d.time != null,
        fuso: d.place?.timezone,
      );

  /// **LA NASCITA DAL PROFILO QUANDO HA L'ORA**, poi dai dettagli della
  /// carta. Visto sul Realme il 29 settembre: la carta era completa, ma i
  /// dettagli salvati non portavano l'ora, e la dimora araba chiedeva
  /// un'ora che la persona aveva gia' dato. L'identita' del profilo
  /// ([BirthIdentity]) porta ora, luogo e fuso: e' la fonte che usa anche
  /// la card da condividere.
  static NascitaDeiSegni? daiDati(BirthDetails? dettagli, BirthIdentity? io) {
    if (io != null && !io.isExample && io.hasBirthTime) {
      return NascitaDeiSegni(
        locale: io.birthMoment,
        oraNota: true,
        fuso: io.birthPlace?.timeZoneId ?? dettagli?.place?.timezone,
      );
    }
    if (dettagli != null) return NascitaDeiSegni.daiDettagli(dettagli);
    if (io != null && !io.isExample) {
      return NascitaDeiSegni(
        locale: io.birthDate,
        oraNota: false,
        fuso: io.birthPlace?.timeZoneId,
      );
    }
    return null;
  }

  /// Data e ora civili del luogo di nascita. Senza ora, mezzogiorno.
  final DateTime locale;
  final bool oraNota;

  /// Il fuso del luogo (`Europe/Rome`); null se il luogo non si sa.
  final String? fuso;
}

abstract final class ISegniDelleTradizioni {
  /// Il segno della persona nella [tradizione].
  static SegnoDellaTradizione per(
      AstroTradition tradizione, NascitaDeiSegni n) {
    switch (tradizione) {
      case AstroTradition.occidentale:
        return occidentale(n);
      case AstroTradition.cinese:
        return cinese(n);
      case AstroTradition.vedica:
        return vedica(n);
      case AstroTradition.maya:
        return maya(n);
      case AstroTradition.celtica:
        return celtica(n);
      case AstroTradition.egizia:
        return egizia(n);
      case AstroTradition.araba:
        return araba(n);
    }
  }

  // ---------------------------------------------------------------------------
  // OCCIDENTALE
  // ---------------------------------------------------------------------------

  static SegnoDellaTradizione occidentale(NascitaDeiSegni n) {
    final z = IlSegnoDelCielo.delSole(_utc(n));
    return SegnoDellaTradizione(
      tradizione: AstroTradition.occidentale,
      nome: z.italianName,
      frase: 'Il tuo segno è ${z.italianName}',
      zodiaco: z,
    );
  }

  // ---------------------------------------------------------------------------
  // CINESE
  // ---------------------------------------------------------------------------

  /// I dodici animali, dal Topo, con l'articolo.
  static const List<(String, String)> animali = [
    ('Topo', 'il'),
    ('Bue', 'il'),
    ('Tigre', 'la'),
    ('Coniglio', 'il'),
    ('Drago', 'il'),
    ('Serpente', 'il'),
    ('Cavallo', 'il'),
    ('Capra', 'la'),
    ('Scimmia', 'la'),
    ('Gallo', 'il'),
    ('Cane', 'il'),
    ('Maiale', 'il'),
  ];

  static SegnoDellaTradizione cinese(NascitaDeiSegni n) {
    final anno = IlCapodannoLunare.annoCinese(n.locale);
    if (anno == null) {
      return const SegnoDellaTradizione(
        tradizione: AstroTradition.cinese,
        nome: 'Fuori dal calendario',
        frase: 'Il calendario cinese dell\'app va dal 1900 al 2100',
        certo: false,
      );
    }
    final i = (anno - 1900) % 12;
    final (nome, articolo) = animali[i];
    return SegnoDellaTradizione(
      tradizione: AstroTradition.cinese,
      nome: nome,
      frase: 'Il tuo segno cinese è $articolo $nome',
      animale: i,
    );
  }

  // ---------------------------------------------------------------------------
  // VEDICA
  // ---------------------------------------------------------------------------

  /// I dodici rashi, da Mesha, col nome italiano.
  static const List<String> rashi = [
    'Mesha',
    'Vrishabha',
    'Mithuna',
    'Karka',
    'Simha',
    'Kanya',
    'Tula',
    'Vrishchika',
    'Dhanu',
    'Makara',
    'Kumbha',
    'Mina',
  ];

  /// La longitudine siderale della Luna all'istante [utc], dalla porta del
  /// cielo: l'ayanamsa di Lahiri e la nutazione stanno la', in una
  /// definizione sola (ordine FD voce 02).
  static double lunaSiderale(DateTime utc) => IlCieloDiMeeus.siderale(
      CorpoCeleste.luna, IlCieloDiMeeus.giornoGiuliano(utc));

  static SegnoDellaTradizione vedica(NascitaDeiSegni n) {
    SegnoDellaTradizione a(int i, {bool certo = true, String? nota}) {
      final nomeIt = Zodiac.values[i].italianName;
      final figuraPropria = i == 2 || i == 9;
      return SegnoDellaTradizione(
        tradizione: AstroTradition.vedica,
        nome: '${rashi[i]} ($nomeIt)',
        frase: 'Il tuo segno vedico è ${rashi[i]} ($nomeIt)',
        zodiaco: figuraPropria ? null : Zodiac.values[i],
        certo: certo,
        nota: nota,
      );
    }

    int alle(DateTime locale) => IlSegnoDelCielo.dellaLongitudine(
            lunaSiderale(IlFusoDellaNascita.inUtc(locale, n.fuso)))
        .index;
    if (n.oraNota) return a(alle(n.locale));
    final (prima, dopo) = _estremiDelGiorno(n.locale);
    final i = alle(prima);
    final j = alle(dopo);
    if (i == j) return a(i);
    // **Il nome dice tutti e due**, non uno come se fosse certo.
    final it = Zodiac.values[i].italianName;
    final jt = Zodiac.values[j].italianName;
    return SegnoDellaTradizione(
        tradizione: AstroTradition.vedica,
        nome: '${rashi[i]} o ${rashi[j]}',
        frase: 'Il tuo segno vedico è ${rashi[i]} ($it) o ${rashi[j]} ($jt)',
        certo: false,
        nota: 'Il giorno della tua nascita la Luna è passata da '
            '${rashi[i]} a ${rashi[j]}: con l\'ora di nascita si sa quale '
            'dei due è il tuo segno.');
  }

  // ---------------------------------------------------------------------------
  // MAYA
  // ---------------------------------------------------------------------------

  /// I venti giorni dello Tzolk'in, da Imix, nella grafia moderna
  /// dell'Academia de Lenguas Mayas de Guatemala (Kettunen e Helmke 2020).
  /// Il segno che sembra un apostrofo e' la lettera modificatrice U+02BC,
  /// l'occlusiva glottidale: non e' un accento mancato.
  static const List<String> giorniMaya = [
    'Imix',
    'Ikʼ',
    'Akʼbʼal',
    'Kʼan',
    'Chikchan',
    'Kimi',
    'Manikʼ',
    'Lamat',
    'Muluk',
    'Ok',
    'Chuwen',
    'Ebʼ',
    'Bʼen',
    'Ix',
    'Men',
    'Kʼibʼ',
    'Kabʼan',
    'Etzʼnabʼ',
    'Kawak',
    'Ajaw',
  ];

  /// La correlazione GMT: il giorno giuliano della data era 13.0.0.0.0.
  static const int correlazioneGmt = 584283;

  /// Il numero del giorno giuliano della data civile (Fliegel e Van Flandern,
  /// 1968). La divisione `~/` tronca verso zero, ed e' quella della formula.
  static int giornoGiulianoCivile(int a, int m, int g) {
    final k = (m - 14) ~/ 12;
    return (1461 * (a + 4800 + k)) ~/ 4 +
        (367 * (m - 2 - 12 * k)) ~/ 12 -
        (3 * ((a + 4900 + k) ~/ 100)) ~/ 4 +
        g -
        32075;
  }

  static SegnoDellaTradizione maya(NascitaDeiSegni n) {
    // Vale la data civile del luogo, non quella in tempo universale.
    final d =
        giornoGiulianoCivile(n.locale.year, n.locale.month, n.locale.day) -
            correlazioneGmt;
    final numero = (d + 3) % 13 + 1;
    final nome = giorniMaya[(d + 19) % 20];
    return SegnoDellaTradizione(
      tradizione: AstroTradition.maya,
      nome: '$numero $nome',
      frase: 'Il tuo segno maya è $numero $nome',
    );
  }

  // ---------------------------------------------------------------------------
  // CELTICA
  // ---------------------------------------------------------------------------

  /// I tredici mesi di Graves: il giorno d'inizio (mese per cento piu'
  /// giorno), l'albero e il suo articolo. The White Goddess, 1948.
  static const List<(int, String, String)> alberi = [
    (1224, 'Betulla', 'la'),
    (121, 'Sorbo', 'il'),
    (218, 'Frassino', 'il'),
    (318, 'Ontano', 'l\''),
    (415, 'Salice', 'il'),
    (513, 'Biancospino', 'il'),
    (610, 'Quercia', 'la'),
    (708, 'Agrifoglio', 'l\''),
    (805, 'Nocciolo', 'il'),
    (902, 'Vite', 'la'),
    (930, 'Edera', 'l\''),
    (1028, 'Canna', 'la'),
    (1125, 'Sambuco', 'il'),
  ];

  static SegnoDellaTradizione celtica(NascitaDeiSegni n) {
    final md = n.locale.month * 100 + n.locale.day;
    if (md == 1223) {
      return const SegnoDellaTradizione(
        tradizione: AstroTradition.celtica,
        nome: 'Il giorno senza albero',
        frase: 'Il 23 dicembre è il giorno senza albero',
        nota: 'Nel calendario di Graves il 23 dicembre sta fuori dai '
            'tredici mesi: è il giorno in più dell\'anno.',
      );
    }
    var scelto = alberi.first;
    if (md <= 120 || md >= 1224) {
      scelto = alberi.first;
    } else {
      for (final a in alberi.skip(1)) {
        if (md >= a.$1) scelto = a;
      }
    }
    final (_, albero, articolo) = scelto;
    final spazio = articolo.endsWith('\'') ? '' : ' ';
    return SegnoDellaTradizione(
      tradizione: AstroTradition.celtica,
      nome: albero,
      frase: 'Il tuo albero celtico è $articolo$spazio$albero',
    );
  }

  // ---------------------------------------------------------------------------
  // EGIZIA
  // ---------------------------------------------------------------------------

  /// I trentasei decani di Efestione di Tebe, Apotelesmatika I.1, dal primo
  /// dell'Ariete: letti nel greco dell'edizione Engelbrecht (1887). Alcuni
  /// nomi tornano, come nella fonte: la chiave e' il numero, mai il nome.
  static const List<String> decani = [
    'Chontare', 'Chontachre', 'Siket', //
    'Choou', 'Ero', 'Rhombromare',
    'Thosolk', 'Ouare', 'Phouori',
    'Sothis', 'Sit', 'Chnoumis',
    'Charchnoumis', 'Epe', 'Phoupe',
    'Tom', 'Ouestebkoti', 'Aphoso',
    'Souchoe', 'Ptechout', 'Chontare',
    'Stochnene', 'Sesme', 'Sisieme',
    'Reouo', 'Sesme', 'Komme',
    'Smat', 'Sro', 'Isro',
    'Ptiau', 'Aeu', 'Ptibiou',
    'Abiou', 'Chontare', 'Ptibiou',
  ];

  static const List<String> _delSegno = [
    'dell\'Ariete',
    'del Toro',
    'dei Gemelli',
    'del Cancro',
    'del Leone',
    'della Vergine',
    'della Bilancia',
    'dello Scorpione',
    'del Sagittario',
    'del Capricorno',
    'dell\'Acquario',
    'dei Pesci',
  ];

  static const List<String> _ordinali = ['primo', 'secondo', 'terzo'];

  static String _decano(int settore) =>
      '${decani[settore]}, ${_ordinali[settore % 3]} decano '
      '${_delSegno[settore ~/ 3]}';

  static SegnoDellaTradizione egizia(NascitaDeiSegni n) {
    int alle(DateTime locale) =>
        (_sole(IlFusoDellaNascita.inUtc(locale, n.fuso)) ~/ 10) % 36;
    // In grande il solo nome del decano: "Phouori, terzo decano dei
    // Gemelli" occupava quattro righe sul Realme. Il resto sta nella frase.
    SegnoDellaTradizione a(int s, {bool certo = true, String? nota}) =>
        SegnoDellaTradizione(
          tradizione: AstroTradition.egizia,
          nome: decani[s],
          frase: 'Il tuo decano egizio è ${_decano(s)}',
          certo: certo,
          nota: nota,
        );
    if (n.oraNota) return a(alle(n.locale));
    final (prima, dopo) = _estremiDelGiorno(n.locale);
    final s = alle(prima);
    final t = alle(dopo);
    if (s == t) return a(s);
    return SegnoDellaTradizione(
        tradizione: AstroTradition.egizia,
        nome: '${decani[s]} o ${decani[t]}',
        frase: 'Il tuo decano egizio è ${_decano(s)}, o ${_decano(t)}',
        certo: false,
        nota: 'Il giorno della tua nascita il Sole è passato da '
            '${decani[s]} a ${decani[t]}: con l\'ora di nascita si sa quale '
            'dei due è il tuo decano.');
  }

  // ---------------------------------------------------------------------------
  // ARABA
  // ---------------------------------------------------------------------------

  /// Le ventotto dimore lunari (manazil al-qamar) e il loro significato.
  static const List<(String, String)> dimore = [
    ('al-Sharatain', 'i due segni'),
    ('al-Butain', 'il piccolo ventre'),
    ('al-Thurayya', 'le Pleiadi'),
    ('al-Dabaran', 'l\'inseguitore'),
    ('al-Haqʼa', 'il ciuffo bianco'),
    ('al-Hanʼa', 'il marchio'),
    ('al-Dhiraʼ', 'l\'avambraccio'),
    ('al-Nathra', 'la punta del naso'),
    ('al-Tarf', 'lo sguardo'),
    ('al-Jabha', 'la fronte'),
    ('al-Zubra', 'la criniera'),
    ('al-Sarfa', 'il mutamento'),
    ('al-ʼAwwaʼ', 'il latratore'),
    ('al-Simak', 'l\'inerme'),
    ('al-Ghafr', 'la copertura'),
    ('al-Zubana', 'le chele'),
    ('al-Iklil', 'la corona'),
    ('al-Qalb', 'il cuore'),
    ('al-Shawla', 'il pungiglione'),
    ('al-Naʼaʼim', 'gli struzzi'),
    ('al-Balda', 'la città'),
    ('Saʼd al-Dhabih', 'la fortuna del sacrificatore'),
    ('Saʼd Bulaʼ', 'la fortuna dell\'inghiottitore'),
    ('Saʼd al-Suʼud', 'la fortuna delle fortune'),
    ('Saʼd al-Akhbiya', 'la fortuna delle tende'),
    ('al-Fargh al-Muqaddam', 'il primo beccuccio'),
    ('al-Fargh al-Muʼakhkhar', 'il secondo beccuccio'),
    ('Batn al-Hut', 'il ventre del pesce'),
  ];

  /// La dimora (da 0 a 27) della Luna all'istante [utc]: settori regolari di
  /// 360/28 gradi dall'inizio dell'Ariete tropicale.
  static int dimoraAlle(DateTime utc) {
    final l = IlCieloDiMeeus.longitudine(
        CorpoCeleste.luna, IlCieloDiMeeus.giornoGiuliano(utc));
    return (l / (360.0 / 28.0)).floor() % 28;
  }

  static SegnoDellaTradizione araba(NascitaDeiSegni n) {
    if (!n.oraNota) {
      return const SegnoDellaTradizione(
        tradizione: AstroTradition.araba,
        nome: 'Serve l\'ora di nascita',
        frase: 'La tua dimora lunare vuole l\'ora di nascita',
        certo: false,
        nota: 'La Luna attraversa una dimora in circa un giorno: senza l\'ora '
            'di nascita non si può dire in quale fosse.',
      );
    }
    final i = dimoraAlle(IlFusoDellaNascita.inUtc(n.locale, n.fuso));
    final (nome, senso) = dimore[i];
    return SegnoDellaTradizione(
      tradizione: AstroTradition.araba,
      nome: '$nome, $senso',
      frase: 'La tua dimora lunare è $nome, $senso',
    );
  }

  // ---------------------------------------------------------------------------

  static DateTime _utc(NascitaDeiSegni n) =>
      IlFusoDellaNascita.inUtc(n.locale, n.fuso);

  // Il Sole di nascita, dalla porta del cielo.
  static double _sole(DateTime utc) =>
      IlCieloDiMeeus.longitudineAllIstante(CorpoCeleste.sole, utc);

  static (DateTime, DateTime) _estremiDelGiorno(DateTime g) => (
        DateTime(g.year, g.month, g.day, 0, 0),
        DateTime(g.year, g.month, g.day, 23, 59),
      );

}
