import '../astro/zodiac.dart';
import 'vip_catalog.dart';

/// Una barra infografica del responso: etichetta, valore percentuale e una
/// eventuale battuta breve sotto il numero.
class SynastryBar {
  const SynastryBar({
    required this.label,
    required this.value,
    this.quip = '',
  });

  /// Titolo della barra, a video.
  final String label;

  /// Valore 0..100 per le tre barre piene; per l'incontro e' la parte intera
  /// di una percentuale volutamente minima (vedi [meetingPercent]).
  final int value;

  /// Micro battuta opzionale, mostrata piccola accanto alla barra.
  final String quip;
}

/// L'esito completo della Sinastria VIP, tutto deterministico dai due segni.
///
/// A parita' di coppia il risultato e' identico: nessuna casualita', nessuna
/// AI. E' un gioco simbolico di intrattenimento nella tradizione
/// dell'astrologia relazionale, non una previsione.
class SynastryReport {
  const SynastryReport({
    required this.overall,
    required this.band,
    required this.reading,
    required this.love,
    required this.mental,
    required this.sparks,
    required this.meetingPercent,
    required this.meetingQuip,
  });

  /// Percentuale del cerchio grande, sintesi pesata di amore, mente, scintille.
  final int overall;

  /// Etichetta di fascia del cerchio grande (Anime gemelle, Grande intesa...).
  final String band;

  /// Il testo del responso, medio, composto da relazione tra i segni piu'
  /// carattere del VIP piu' chiusura ironica.
  final String reading;

  final int love;
  final int mental;
  final int sparks;

  /// Possibilita' di incontro, volutamente bassissima: 0,2 .. 4,0 per cento.
  final double meetingPercent;

  /// Micro battuta sulla possibilita' di incontro.
  final String meetingQuip;

  /// Le quattro barre pronte per l'infografica, nell'ordine di layout.
  List<SynastryBar> get bars => [
        SynastryBar(label: 'Affinita\' d\'amore', value: love),
        SynastryBar(label: 'Intesa mentale', value: mental),
        SynastryBar(label: 'Scintille', value: sparks),
        SynastryBar(
          label: 'Possibilita\' di incontro',
          value: meetingPercent.floor(),
          quip: meetingQuip,
        ),
      ];

  /// La possibilita' di incontro formattata con la virgola decimale italiana.
  String get meetingLabel {
    final s = meetingPercent.toStringAsFixed(1).replaceAll('.', ',');
    return '$s%';
  }

  /// La riga sopra il tasto Condividi, con il nome del VIP.
  static String challengeLine(String vipName) =>
      'E tu con $vipName quanto fai? Sfida i tuoi amici.';

  /// Compone il responso completo per l'utente e il VIP dati.
  static SynastryReport forPair(Zodiac user, Vip vip) {
    final vipSign = vip.sign;
    final ea = user.element;
    final eb = vipSign.element;
    final sameSign = user == vipSign;
    final sameElement = ea == eb;
    final sep = _separation(user, vipSign);
    final opposite = sep == 6;
    final complementary = _complementary(ea, eb);
    final tension = _tension(ea, eb);
    final sameModality = _modality(user) == _modality(vipSign);
    final airCount =
        (ea == ZodiacElement.air ? 1 : 0) + (eb == ZodiacElement.air ? 1 : 0);
    final fireCount =
        (ea == ZodiacElement.fire ? 1 : 0) + (eb == ZodiacElement.fire ? 1 : 0);

    // --- Barra amore ---
    var love = sameSign
        ? 96
        : opposite
            ? 90
            : sameElement
                ? 88
                : complementary
                    ? 84
                    : tension
                        ? 70
                        : 66;
    if (sameModality && !sameSign) love += 3;
    if (sep == 4) love += 3; // trigono
    if (sep == 2) love += 2; // sestile
    if (sep == 3) love -= 4; // quadrato
    love = love.clamp(40, 99);

    // --- Barra intesa mentale ---
    var mental = 58 + airCount * 8;
    if (sameModality) mental += 6;
    if (sameElement) {
      mental += 6;
    } else if (complementary) {
      mental += 4;
    } else if (tension) {
      mental += 2;
    }
    if (sep == 2) mental += 4;
    mental = mental.clamp(40, 98);

    // --- Barra scintille, quanto litighereste ---
    var sparks = 30;
    if (sep == 3) sparks += 30; // quadrato: attrito
    if (opposite) sparks += 14;
    if (tension) sparks += 20;
    if (sameModality) sparks += 14; // due caratteri dello stesso tipo si urtano
    sparks += fireCount * 6;
    sparks = sparks.clamp(8, 95);

    // --- Cerchio grande: sintesi pesata delle prime tre, con l'amore in testa ---
    final overall =
        (0.6 * love + 0.25 * mental + 0.15 * sparks).round().clamp(0, 99);

    // --- Possibilita' di incontro, minima e simmetrica per la coppia ---
    final lo = user.index < vipSign.index ? user.index : vipSign.index;
    final hi = user.index < vipSign.index ? vipSign.index : user.index;
    final meeting = ((lo * 7 + hi * 13) % 39) / 10 + 0.2; // 0,2 .. 4,0
    final meetingQuip = _meetingQuips[(lo * 7 + hi * 13) % _meetingQuips.length];

    // --- Testo composto ---
    final relation = _relationLine(
      sameSign: sameSign,
      sameElement: sameElement,
      opposite: opposite,
      ea: ea,
      eb: eb,
      complementary: complementary,
      tension: tension,
    );
    final character = _characterClause(vip);
    final closer =
        _ironicClosers[(user.index + vipSign.index) % _ironicClosers.length];
    final reading = '$relation $character. $closer';

    return SynastryReport(
      overall: overall,
      band: _band(overall),
      reading: reading,
      love: love,
      mental: mental,
      sparks: sparks,
      meetingPercent: meeting,
      meetingQuip: meetingQuip,
    );
  }

  // Distanza angolare tra due segni, 0 (congiunzione) .. 6 (opposizione).
  static int _separation(Zodiac a, Zodiac b) {
    final diff = (a.index - b.index).abs();
    return diff <= 6 ? diff : 12 - diff;
  }

  // Modalita': 0 cardinale, 1 fisso, 2 mobile, dal ciclo dei dodici segni.
  static int _modality(Zodiac z) => z.index % 3;

  // Fuoco con Aria, Terra con Acqua: si alimentano.
  static bool _complementary(ZodiacElement a, ZodiacElement b) {
    final s = {a, b};
    return (s.contains(ZodiacElement.fire) && s.contains(ZodiacElement.air)) ||
        (s.contains(ZodiacElement.earth) && s.contains(ZodiacElement.water));
  }

  // Fuoco con Acqua, Aria con Terra: opposti che si sfidano.
  static bool _tension(ZodiacElement a, ZodiacElement b) {
    final s = {a, b};
    return (s.contains(ZodiacElement.fire) && s.contains(ZodiacElement.water)) ||
        (s.contains(ZodiacElement.air) && s.contains(ZodiacElement.earth));
  }

  static String _band(int overall) {
    if (overall >= 85) return 'Anime gemelle';
    if (overall >= 75) return 'Grande intesa';
    if (overall >= 64) return 'Bella sintonia';
    if (overall >= 54) return 'Attrazione curiosa';
    return 'Due poli lontani';
  }

  // Riga sulla relazione tra i segni, dal corpus sinastria_testi.md. L'ordine
  // dei rami conta: i segni opposti sono sempre anche complementari, quindi
  // vanno intercettati prima per dare loro la riga dei contrari.
  static String _relationLine({
    required bool sameSign,
    required bool sameElement,
    required bool opposite,
    required ZodiacElement ea,
    required ZodiacElement eb,
    required bool complementary,
    required bool tension,
  }) {
    if (sameSign) return 'Stesso segno, stessa lunghezza d\'onda:';
    if (sameElement) return 'Stesso elemento, vi capireste al volo:';
    if (opposite) return 'Segni opposti, l\'attrazione dei contrari:';
    final s = {ea, eb};
    if (s.contains(ZodiacElement.fire) && s.contains(ZodiacElement.air)) {
      return 'Fuoco e aria, insieme fareste scintille:';
    }
    if (s.contains(ZodiacElement.earth) && s.contains(ZodiacElement.water)) {
      return 'Terra e acqua, un\'intesa che nutre:';
    }
    if (tension) return 'Elementi che si sfidano, tensione e chimica pura:';
    return 'Due mondi diversi, curiosi l\'uno dell\'altro:';
  }

  // Carattere del VIP: la riga del corpus col nome del personaggio al posto del
  // pronome iniziale (lei/lui), cosi' la frase scorre.
  static String _characterClause(Vip vip) {
    final key = vip.stem == null
        ? ''
        : vip.stem!.replaceAll(RegExp(r'_v\d+$'), '');
    var line = _vipCharacters[key] ?? 'che porta con se\' il suo mondo';
    line = line.replaceFirst(RegExp(r'^(lei|lui)\s+'), '');
    return '${vip.name} $line';
  }

  /// Le chiusure ironiche sull'incontro, dal corpus. Se ne sceglie una in modo
  /// deterministico per coppia, cosi' la card resta stabile.
  static const List<String> _ironicClosers = [
    'Che finiate allo stesso tavolo e\' tutto da vedere, ma il cielo ogni tanto ci prova.',
    'Il destino ha i suoi tempi, ma un colpo di scena non si nega a nessuno.',
    'Tra voi, per ora, c\'e\' di mezzo solo qualche milione di follower.',
    'Mai dire mai: le storie migliori iniziano con un caffe\' inaspettato.',
  ];

  /// Micro battute sulla barra dell'incontro, deterministiche per coppia.
  static const List<String> _meetingQuips = [
    'quasi zero, ma con stile',
    'il cielo non si sbilancia',
    'serve un miracolo, o un buon aperitivo',
    'praticamente da leggenda',
  ];

  /// I cinquanta caratteri VIP dal corpus, per stem normalizzato senza `_vN`.
  static const Map<String, String> _vipCharacters = {
    'vip_angelina-jolie':
        'divisa tra un set di Hollywood e mezzo mondo da salvare',
    'vip_ariana-grande': 'che arriva a note che tu nemmeno immagini',
    'vip_bad-bunny': 'che riempie gli stadi cantando in spagnolo',
    'vip_beyonce': 'che quando entra si spengono le altre luci',
    'vip_bill-gates': 'che ha riscritto il mondo partendo da un garage',
    'vip_billie-eilish': 'che sussurra e la ascoltano in milioni',
    'vip_brad-pitt': 'che invecchia meglio del vino',
    'vip_chiara-ferragni': 'che di un post sa fare un impero',
    'vip_damiano-david': 'che sul palco perde la camicia ma mai il ritmo',
    'vip_dicaprio': 'che colleziona Oscar e tramonti',
    'vip_drake': 'che trasforma ogni dispiacere in disco di platino',
    'vip_dwayne-johnson': 'che solleva piu\' peso del tuo intero condominio',
    'vip_elon-musk': 'che twitta a mezzanotte e sposta i mercati',
    'vip_emma-watson': 'che dai libri di magia e\' passata a quelli veri',
    'vip_federer': 'che perdeva con eleganza pure quando vinceva',
    'vip_fedez': 'che fa notizia piu\' di un telegiornale',
    'vip_giorgio-armani': 'che ha vestito il mondo di grigio elegante',
    'vip_jeff-bezos': 'che ti consegna tutto tranne il suo tempo libero',
    'vip_kanye-west': 'che una ne fa e cento ne pensa',
    'vip_keanu-reeves': 'che resta gentile pure mentre salva il mondo',
    'vip_kim-kardashian': 'che ha fatto della vita un impero',
    'vip_kylie-jenner': 'che a vent\'anni contava i miliardi',
    'vip_lady-gaga': 'che cambia faccia a ogni canzone ma non voce',
    'vip_lebron-james': 'che a quarant\'anni vola ancora',
    'vip_margot-robbie': 'che ha reso una bambola un fenomeno mondiale',
    'vip_mark-zuckerberg': 'che sa tutto di te ma non risponde ai messaggi',
    'vip_mbappe': 'che corre piu\' veloce del tuo wifi',
    'vip_messi': 'che parla poco e segna sempre',
    'vip_michelle-obama': 'che ha rimesso di moda l\'intelligenza',
    'vip_monica-bellucci': 'che il tempo lo guarda passare senza farsi toccare',
    'vip_nadal': 'che non molla un punto nemmeno per sbaglio',
    'vip_oprah-winfrey': 'che regala macchine e cambia vite',
    'vip_priyanka-chopra': 'che ha conquistato due continenti',
    'vip_rihanna':
        'che tra un disco e l\'altro ti ha pure venduto il fondotinta',
    'vip_ronaldo': 'che si allena mentre tu dormi',
    'vip_scarlett-johansson': 'che ha dato la voce persino ai robot',
    'vip_selena-gomez': 'che sopravvive a Hollywood col sorriso',
    'vip_serena-williams': 'che serve piu\' forte di quanto tu discuti',
    'vip_shakira': 'che con i fianchi non sa mentire',
    'vip_sinner': 'che resta di ghiaccio anche a Wimbledon',
    'vip_snoop-dogg': 'che se la prende comoda da trent\'anni',
    'vip_steve-jobs': 'che ha messo il futuro nella tasca di tutti',
    'vip_taylor-swift': 'che se la lasci ci scrive un album',
    'vip_the-weeknd': 'che canta le notti che tu dimentichi',
    'vip_timothee-chalamet': 'che fa sospirare due generazioni insieme',
    'vip_tom-cruise': 'che gli stunt se li fa da solo',
    'vip_usain-bolt': 'che ha corso piano solo per salutare',
    'vip_valentino-rossi': 'che in curva piega piu\' di te sotto le scadenze',
    'vip_warren-buffett': 'che a colazione compra aziende',
    'vip_zendaya': 'che a ogni red carpet manda in tilt internet',
  };
}
