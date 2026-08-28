import '../astro/natal_chart.dart';
import 'cielo_della_sinastria.dart';
import 'altre_affinita.dart';
import 'possibilita_di_incontro.dart';
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
    this.terraComune = 50,
    this.ritmo = 50,
    this.vitaQuotidiana = 50,
    required this.meetingPercent,
    required this.meetingQuip,
    required this.incontro,
    this.eredita,
    this.aspetti = const [],
    this.oraDelVipNota = false,
    this.oraTuaNota = false,
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

  /// **LE TRE DIMENSIONI IN PIU', ordine BX voce 09.** Fondate su tradizione
  /// documentata e calcolate in modo deterministico dai due cieli, come le
  /// tre di prima: vedi `AltreAffinita` per la fonte di ognuna.
  final int terraComune;
  final int ritmo;
  final int vitaQuotidiana;

  /// **LA POSSIBILITA' DI INCONTRO, ordine BO voce 03.** Sta qui dentro col
  /// suo perche', e non e' piu' un numero nudo. Per chi non c'e' piu' non
  /// esiste, e la scena non la mostra.
  final PossibilitaDiIncontro incontro;

  /// L'EREDITA', ordine BO voce 04: cosa del suo cielo vive nel tuo. Nulla
  /// per chi e' in vita, dove la domanda giusta e' l'incontro.
  final String? eredita;

  /// La percentuale nuda, per chi la vuole come numero. Zero per chi non c'e'
  /// piu': la barra non esiste, quindi non c'e' niente da riempire.
  final double meetingPercent;

  /// Micro battuta sulla possibilita' di incontro. **Resta come campo e non
  /// si mostra piu' sotto la barra**: al suo posto c'e' la riga che spiega il
  /// numero, che dice un fatto invece di una battuta.
  final String meetingQuip;

  /// Vero se il VIP non c'e' piu'. La scena cambia domanda.
  bool get eScomparso => !incontro.esiste;

  /// GLI ASPETTI VERI FRA I DUE CIELI, dal piu' stretto al piu' largo.
  ///
  /// **Sono il responso, non un suo ornamento**: le tre barre nascono da qui,
  /// e la voce BO.06 accendera' un filo di luce per ognuno di questi e per
  /// nessun altro. Chi disegna guarda questa lista, non ne compone una sua.
  final List<AspettoDiSinastria> aspetti;

  /// Se l'ora di nascita del VIP e' nota. Falsa per tutti e cinquanta, oggi:
  /// la lettura lo dichiara invece di fingere un Ascendente.
  final bool oraDelVipNota;

  /// Se l'ora di nascita della persona e' nota.
  final bool oraTuaNota;

  /// I tre aspetti piu' forti, che sono i primi tre della lista perche' la
  /// lista e' gia' ordinata per orbo crescente. Servono alla card della sfida.
  List<AspettoDiSinastria> get aspettiPiuForti =>
      aspetti.length <= 3 ? aspetti : aspetti.sublist(0, 3);

  /// LE BARRE PRONTE PER L'INFOGRAFICA, nell'ordine di layout.
  ///
  /// **Sono quattro per chi c'e', TRE per chi non c'e' piu'.** Ordine BO voce
  /// 04: la barra dell'incontro non si mostra spenta ne' a zero, non esiste
  /// proprio, perche' una barra vuota e' comunque una promessa mancata messa
  /// sotto gli occhi.
  List<SynastryBar> get bars => [
        SynastryBar(label: 'Affinità d\'amore', value: love),
        SynastryBar(label: 'Intesa mentale', value: mental),
        SynastryBar(label: 'Scintille', value: sparks),
        // **TRE DIMENSIONI IN PIU', ordine BX voce 09, terzo rilievo.** Le
        // tre di prima guardavano tutte lo stesso materiale, gli aspetti fra
        // i punti personali. Queste guardano cose diverse e ognuna poggia su
        // una tradizione documentata: gli elementi, le qualita' e gli aspetti
        // della Luna con l'Ascendente. Il perche' di ognuna vive in
        // `AltreAffinita`, con la fonte scritta.
        SynastryBar(label: 'Terra comune', value: terraComune),
        SynastryBar(label: 'Ritmo', value: ritmo),
        SynastryBar(label: 'Vita quotidiana', value: vitaQuotidiana),
        if (incontro.esiste)
          SynastryBar(
            label: 'Possibilità di incontro',
            // **LA BARRA DICE QUANTO SI E' VICINI AL MASSIMO POSSIBILE,
            // ordine BX voce 09**: la percentuale cruda su una scala da
            // cento era una barra vuota per tutti, e due coppie diverse
            // sembravano uguali. La riga sotto continua a dire la
            // percentuale vera.
            value: incontro.indiceSullaScala,
            quip: incontro.perche,
          ),
      ];

  /// La possibilita' di incontro formattata con la virgola decimale italiana.
  String get meetingLabel => incontro.etichetta;

  /// La riga sopra il tasto Condividi, con il nome del VIP.
  static String challengeLine(String vipName) =>
      'E tu con $vipName quanto fai? Sfida i tuoi amici.';

  /// COMPONE IL RESPONSO DAL CIELO INTERO. Ordine BO voce 02.
  ///
  /// **Il difetto che questa funzione ha smesso di avere.** Prima prendeva un
  /// segno e un VIP, e del VIP guardava solo il segno solare: cinquanta
  /// personaggi su dodici segni davano allo stesso utente **93 coppie di
  /// responsi numericamente identici**, contate. Adesso prende due CIELI e
  /// guarda gli aspetti veri fra i loro punti, calcolati dalle effemeridi
  /// locali: due VIP dello stesso segno nati in giorni diversi hanno Luna,
  /// Mercurio, Venere e Marte in punti diversi, e quindi responsi diversi.
  ///
  /// Resta deterministico: nessuna casualita', nessuna AI, nessuna rete. La
  /// stessa coppia da' sempre lo stesso esito.
  static SynastryReport perCieli({
    required CieloDiSinastria tuo,
    required Vip vip,
    DoveSei? doveSei,
    DateTime? quando,
    bool cercaIlGiornoMigliore = false,
  }) {
    final suo = CieloDiSinastria.perVip(vip);
    final aspetti = AspettiDiSinastria.fra(tuo, suo);

    // I tre numeri passano dalla porta comune, cosi' il confronto con te e
    // quello fra due VIP restano sulla stessa scala.
    final n = _numeriDa(aspetti);
    final love = n.love;
    final mental = n.mental;
    final sparks = n.sparks;
    final overall = n.overall;

    // **LA POSSIBILITA' DI INCONTRO DA FATTI VERI, ordine BO voce 03.** Se e'
    // in vita, quanto dista la sua citta' dalla tua, quanto si fa vedere.
    // **IL CIELO DEL GIORNO ENTRA QUI, ordine BO voce 12.** Gli aspetti sono
    // quelli gia' calcolati sopra: non se ne ricalcola nessuno, e il grado
    // dove i due cieli si toccano e' l'estremo di ognuno di quelli.
    final incontro = PossibilitaDiIncontro.per(
      vip: vip,
      doveSei: doveSei,
      aspetti: aspetti,
      tuo: tuo,
      suo: suo,
      quando: quando,
      cercaIlGiornoMigliore: cercaIlGiornoMigliore,
    );
    // La battuta resta come dato per chi la vuole, ma sotto la barra adesso
    // c'e' il PERCHE': una frase che dice un fatto vale piu' di una che fa
    // sorridere e non dice niente.
    final meetingQuip = _meetingQuips[
        (tuo.segnoSolare.index + vip.sign.index) % _meetingQuips.length];

    return SynastryReport(
      overall: overall,
      band: _band(overall),
      reading: _lettura(aspetti, vip, tuo, suo),
      love: love,
      mental: mental,
      sparks: sparks,
      terraComune: AltreAffinita.terraComune(tuo, suo),
      ritmo: AltreAffinita.ritmo(tuo, suo),
      vitaQuotidiana: AltreAffinita.vitaQuotidiana(aspetti),
      meetingPercent: incontro.percento,
      meetingQuip: meetingQuip,
      incontro: incontro,
      eredita: EreditaDelCielo.per(vip, aspetti),
      aspetti: aspetti,
      oraDelVipNota: suo.oraNota,
      oraTuaNota: tuo.oraNota,
    );
  }

  /// **IL CONFRONTO FRA DUE CIELI QUALUNQUE, ordine BO voce 13.**
  ///
  /// Le due caselle: la prima e' la persona in modo predefinito e si puo'
  /// sostituire con un VIP, la seconda e' sempre un VIP. Da qui nascono tre
  /// esperienze con una modifica sola: se stessi con un VIP come prima, due
  /// VIP fra loro, e il gioco di sostituirsi a qualcuno.
  ///
  /// **IL RISULTATO E' SIMMETRICO**, ed e' una proprieta' del calcolo e non
  /// una promessa: i tre pesi guardano l'INSIEME dei due punti di un aspetto,
  /// mai quale dei due stia da che parte. Scambiare le caselle non puo'
  /// cambiare un numero, e una prova lo verifica su cento coppie.
  ///
  /// **FRA DUE VIP LA POSSIBILITA' DI INCONTRO NON ESISTE** e non si calcola,
  /// come per chi non c'e' piu': la barra non compare in albero. Al suo posto
  /// c'e' quanto i loro mondi si sfiorano, ricavato dai dati gia' raccolti
  /// nella voce 01, cioe' le citta' e l'esposizione pubblica.
  static SynastryReport fraDueVip({
    required Vip primo,
    required Vip vip2,
  }) {
    final secondo = vip2;
    final cieloA = CieloDiSinastria.perVip(primo);
    final cieloB = CieloDiSinastria.perVip(secondo);
    final aspetti = AspettiDiSinastria.fra(cieloA, cieloB);
    final numeri = _numeriDa(aspetti);
    return SynastryReport(
      overall: numeri.overall,
      band: _band(numeri.overall),
      reading: _letturaFraDue(aspetti, primo, secondo, cieloB),
      love: numeri.love,
      mental: numeri.mental,
      sparks: numeri.sparks,
      // Le tre dimensioni in piu' valgono anche fra due VIP: e' la stessa
      // scala, ordine BX voce 09.
      terraComune: AltreAffinita.terraComune(cieloA, cieloB),
      ritmo: AltreAffinita.ritmo(cieloA, cieloB),
      vitaQuotidiana: AltreAffinita.vitaQuotidiana(aspetti),
      meetingPercent: 0,
      meetingQuip: '',
      incontro: PossibilitaDiIncontro(
        esiste: false,
        percento: 0,
        perche: mondiCheSiSfiorano(primo, secondo),
      ),
      aspetti: aspetti,
      oraDelVipNota: cieloB.oraNota,
      oraTuaNota: cieloA.oraNota,
    );
  }

  /// **QUANTO I LORO MONDI SI SFIORANO**, ordine BO voce 13 punto 6.
  ///
  /// Non e' una possibilita' di incontro, che fra due persone che non sei tu
  /// non ha nessun senso: e' un fatto sulle loro vite pubbliche, ricavato dai
  /// dati del dossier. **Nessuna parola su relazioni reali**, punto 5
  /// dell'ordine: l'app confronta i cieli, non le relazioni.
  static String mondiCheSiSfiorano(Vip a, Vip b) {
    if (a.eScomparso || b.eScomparso) {
      final chi = a.eScomparso ? a : b;
      return '${chi.name} non c\'è più: i loro mondi non si incrociano più '
          'nello stesso tempo.';
    }
    final ca = a.luogoDiOggi;
    final cb = b.luogoDiOggi;
    final esposti = a.esposizione.index <= 1 && b.esposizione.index <= 1;
    if (ca == null || cb == null) {
      return esposti
          ? 'Vivono tutti e due sotto i riflettori, quindi i loro mondi si '
              'sfiorano spesso, anche senza sapere dove abitino.'
          : 'Di almeno uno dei due non si sa pubblicamente dove viva: dei '
              'loro mondi si può dire soltanto quanto si mostrano.';
    }
    final km = PossibilitaDiIncontro.chilometriFra(
        ca.latitudine, ca.longitudine, cb.latitudine, cb.longitudine);
    if (km < 20) {
      return 'Vivono nella stessa città, ${ca.nome}: i loro mondi si '
          'sfiorano di continuo.';
    }
    if (km < 1200) {
      return 'Vivono a ${km.round()} km l\'uno dall\'altro, fra ${ca.nome} e '
          '${cb.nome}: abbastanza vicini da incrociarsi.';
    }
    return 'Vivono a mondi di distanza, fra ${ca.nome} e ${cb.nome}: '
        '${km.round()} km.';
  }

  static String _letturaFraDue(List<AspettoDiSinastria> aspetti, Vip a, Vip b,
      CieloDiSinastria cieloB) {
    if (aspetti.isEmpty) {
      return 'I cieli di ${a.name} e ${b.name} non si toccano in nessuno dei '
          'punti che contano.';
    }
    final primo = aspetti.first;
    return 'Fra ${a.name} e ${b.name} il fatto è questo: '
        '${primo.tuo.ilSuo} ${primo.tuo.nome} '
        'in ${primo.tipo.italianName.toLowerCase()} '
        '${primo.suo.alSuo} ${primo.suo.nome}, '
        'a ${_gradi(primo.orbo)} dall\'angolo esatto.';
  }

  /// I tre numeri da una lista di aspetti. **Sta in un posto solo** perche' il
  /// confronto con te e quello fra due VIP devono dare la stessa scala: due
  /// formule per la stessa cosa divergerebbero al primo ritocco.
  static ({int overall, int love, int mental, int sparks}) _numeriDa(
      List<AspettoDiSinastria> aspetti) {
    var amore = 0.0, mente = 0.0, scintille = 0.0;
    for (final a in aspetti) {
      final forza = a.forzaCon(AspettiDiSinastria.orbo[a.tipo]!);
      amore += _pesoDAmore(a) * forza;
      mente += _pesoDiMente(a) * forza;
      scintille += _pesoDiScintille(a) * forza;
    }
    // **LA SCALA USA TUTTO L'INTERVALLO UTILE. Ordine BX voce 09, primo
    // rilievo.**
    //
    // **Il fatto, misurato prima di toccare qualsiasi cosa**, su seicento
    // coppie vere (dodici nascite sparse nell'anno per cinquanta VIP):
    // l'affinita' totale andava da 35 a 76, ma **quattrocentonovantadue coppie
    // su seicento cadevano fra 45 e 65**, e la fascia dal decimo al novantesimo
    // percentile era larga venti punti soli, da 43 a 63. Il fondatore aveva
    // ragione: due coppie molto diverse davano numeri che si somigliavano.
    //
    // **La causa erano i pavimenti e la curva.** I minimi partivano da 40, e
    // la curva `x/(x+riferimento)` satura verso il mezzo: due terzi della
    // scala non venivano mai usati.
    //
    // **La cura non cambia l'astrologia**: i pesi degli aspetti, gli orbi e le
    // regole della tradizione restano identici, e l'ORDINE fra due coppie non
    // cambia mai. Cambia quanto la stessa differenza si vede: i pavimenti
    // scendono e la distanza dal mezzo si allarga.
    final love =
        _sullaScala(amore, riferimento: 2.4, minimo: 8, massimo: 99);
    final mental =
        _sullaScala(mente, riferimento: 1.6, minimo: 8, massimo: 98);
    final sparks =
        _sullaScala(scintille, riferimento: 2.0, minimo: 4, massimo: 96);
    return (
      overall: (0.6 * love + 0.25 * mental + 0.15 * sparks).round().clamp(0, 99),
      love: love,
      mental: mental,
      sparks: sparks,
    );
  }

  /// Quanto un aspetto pesa sull'amore.
  ///
  /// Le regole sono quelle della tradizione sinastrica e stanno scritte, non
  /// indovinate: Venere e la Luna sono i punti del legame, il trigono e il
  /// sestile scorrono, la congiunzione unisce, l'opposizione attrae e affatica
  /// insieme, la quadratura toglie.
  static double _pesoDAmore(AspettoDiSinastria a) {
    const dolci = {
      PuntoDelCielo.venere,
      PuntoDelCielo.luna,
      PuntoDelCielo.sole,
      PuntoDelCielo.ascendente,
    };
    final tocca = dolci.contains(a.tuo) || dolci.contains(a.suo);
    if (!tocca) return 0;
    final cuore = a.tuo == PuntoDelCielo.venere ||
        a.suo == PuntoDelCielo.venere ||
        a.tuo == PuntoDelCielo.luna ||
        a.suo == PuntoDelCielo.luna;
    switch (a.tipo) {
      case AspectType.trine:
        return cuore ? 1.0 : 0.7;
      case AspectType.conjunction:
        return cuore ? 0.95 : 0.6;
      case AspectType.sextile:
        return cuore ? 0.65 : 0.45;
      case AspectType.opposition:
        return 0.3;
      case AspectType.square:
        return -0.45;
    }
  }

  /// Quanto un aspetto pesa sull'intesa mentale. Mercurio e' il punto della
  /// testa, il Sole e l'Ascendente dicono come ci si presenta all'altro.
  static double _pesoDiMente(AspettoDiSinastria a) {
    const testa = {
      PuntoDelCielo.mercurio,
      PuntoDelCielo.sole,
      PuntoDelCielo.ascendente,
    };
    if (!testa.contains(a.tuo) && !testa.contains(a.suo)) return 0;
    final mercurio =
        a.tuo == PuntoDelCielo.mercurio || a.suo == PuntoDelCielo.mercurio;
    switch (a.tipo) {
      case AspectType.trine:
        return mercurio ? 1.0 : 0.6;
      case AspectType.conjunction:
        return mercurio ? 0.9 : 0.55;
      case AspectType.sextile:
        return mercurio ? 0.7 : 0.4;
      case AspectType.opposition:
        return 0.15;
      case AspectType.square:
        return -0.3;
    }
  }

  /// Quanto un aspetto pesa sulle scintille, cioe' su quanto vi urtereste.
  /// Marte e' il punto dell'attrito, e gli aspetti duri sono quelli che
  /// accendono.
  static double _pesoDiScintille(AspettoDiSinastria a) {
    final marte =
        a.tuo == PuntoDelCielo.marte || a.suo == PuntoDelCielo.marte;
    switch (a.tipo) {
      case AspectType.square:
        return marte ? 1.0 : 0.7;
      case AspectType.opposition:
        return marte ? 0.85 : 0.6;
      case AspectType.conjunction:
        return marte ? 0.6 : 0.15;
      case AspectType.trine:
        return marte ? 0.3 : 0.05;
      case AspectType.sextile:
        return marte ? 0.25 : 0.05;
    }
  }

  /// Porta una somma di aspetti sulla scala 0..100 con una curva morbida.
  ///
  /// La curva e' `x / (x + riferimento)`, che vale mezzo quando la somma
  /// eguaglia il riferimento e non arriva mai al bordo: e' cio' che tiene i
  /// responsi distinti invece di schiacciarli tutti sul massimo. Le somme
  /// negative, che nascono da molte quadrature, scendono sotto il mezzo senza
  /// sfondare il minimo.
  /// **DOVE STA IL MEZZO VERO, e non dove si crederebbe.** Ordine BX voce 09.
  /// Misurato su seicento coppie: la quota grezza della curva ha mediana
  /// intorno a 0,30, non a 0,50. Allargare attorno a mezzo senza saperlo
  /// spingeva tutte le coppie in basso, e la misura lo ha detto subito: la
  /// mediana dell'affinita' era scesa a diciannove.
  static const double _centro = 0.30;

  /// Quanto si allarga la distanza dal centro vero. Uno vorrebbe dire
  /// lasciare le cose come stavano; il numero e' scelto sulla misura delle
  /// seicento coppie e la sua prova lo sorveglia.
  static const double _allargamento = 1.6;

  static int _sullaScala(double somma,
      {required double riferimento,
      required int minimo,
      required int massimo}) {
    final x = somma < 0 ? 0.0 : somma;
    final quota = x / (x + riferimento);
    final penalita = somma < 0 ? (-somma / (-somma + riferimento)) * 0.5 : 0.0;
    final valore = (quota - penalita).clamp(0.0, 1.0);
    // **LA DISTANZA DAL MEZZO SI ALLARGA, ordine BX voce 09.** E' una
    // trasformazione MONOTONA: chi stava sopra resta sopra, chi stava sotto
    // resta sotto, e nessun aspetto cambia peso. Serve solo a far vedere una
    // differenza che c'era gia' e che la curva schiacciava verso il mezzo.
    final allargato =
        (0.5 + (valore - _centro) * _allargamento).clamp(0.0, 1.0);
    return (minimo + allargato * (massimo - minimo)).round();
  }

  /// IL TESTO, che nomina il fatto vero invece di una frase generica.
  static String _lettura(List<AspettoDiSinastria> aspetti, Vip vip,
      CieloDiSinastria tuo, CieloDiSinastria suo) {
    final character = _characterClause(vip);
    final closer = _ironicClosers[
        (tuo.segnoSolare.index + vip.sign.index) % _ironicClosers.length];
    if (aspetti.isEmpty) {
      // Puo' capitare, ed e' un fatto anche questo: due cieli che non si
      // toccano in nessun punto entro l'orbo. Si dice, invece di inventare un
      // aspetto che non c'e'.
      return 'I vostri cieli si sfiorano senza toccarsi: nessuno dei punti '
          'che contano cade in aspetto con i tuoi. $character. $closer';
    }
    final primo = aspetti.first;
    final apertura = 'Il fatto è questo: ${primo.fatto}, '
        'a ${_gradi(primo.orbo)} dall\'angolo esatto.';
    final secondo = aspetti.length > 1 ? aspetti[1] : null;
    final seguito =
        secondo == null ? '' : ' Subito dopo viene ${secondo.fatto}.';
    final senzaOra = suo.oraNota
        ? ''
        : ' Del suo cielo non si conosce l\'ora di nascita: questa lettura '
            'parla ai pianeti e non all\'Ascendente. Non si finge di sapere '
            'ciò che nessuna fonte dichiara.';
    return '$apertura$seguito $character. $closer$senzaOra';
  }

  /// I gradi come si scrivono in italiano: "2,4 gradi".
  static String _gradi(double g) {
    final s = g.toStringAsFixed(1).replaceAll('.', ',');
    return '$s gradi';
  }

  // **LE FUNZIONI DEL SOLO SEGNO SOLARE NON CI SONO PIU', ordine BO voce 02.**
  //
  // Erano `_separation`, `_modality`, `_complementary`, `_tension` e
  // `_relationLine`: la separazione fra i due segni, la loro modalita', gli
  // elementi che si alimentano o si sfidano, e le sei righe di apertura che ne
  // nascevano. Sono state tolte e non spostate, perche' erano il difetto: da
  // loro venivano i 93 responsi identici, e la riga di relazione era
  // esattamente la "frase generica" che l'ordine chiede di sostituire col
  // fatto vero. Il corpus che resta, i caratteri dei cinquanta e le chiusure
  // ironiche, non e' stato toccato: quello parla della persona, non del
  // calcolo.

  static String _band(int overall) {
    if (overall >= 85) return 'Anime gemelle';
    if (overall >= 75) return 'Grande intesa';
    if (overall >= 64) return 'Bella sintonia';
    if (overall >= 54) return 'Attrazione curiosa';
    return 'Due poli lontani';
  }

  // Carattere del VIP: la riga del corpus col nome del personaggio al posto del
  // pronome iniziale (lei/lui), cosi' la frase scorre.
  static String _characterClause(Vip vip) {
    final key = vip.stem == null
        ? ''
        : vip.stem!.replaceAll(RegExp(r'_v\d+$'), '');
    var line = _vipCharacters[key] ?? 'che porta con sé il suo mondo';
    line = line.replaceFirst(RegExp(r'^(lei|lui)\s+'), '');
    return '${vip.name} $line';
  }

  /// Le chiusure ironiche sull'incontro, dal corpus. Se ne sceglie una in modo
  /// deterministico per coppia, cosi' la card resta stabile.
  static const List<String> _ironicClosers = [
    'Che finiate allo stesso tavolo è tutto da vedere, ma il cielo ogni tanto ci prova.',
    'Il destino ha i suoi tempi, ma un colpo di scena non si nega a nessuno.',
    'Tra voi, per ora, c\'è di mezzo solo qualche milione di follower.',
    'Mai dire mai: le storie migliori iniziano con un caffè inaspettato.',
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
    'vip_dwayne-johnson': 'che solleva più peso del tuo intero condominio',
    'vip_elon-musk': 'che twitta a mezzanotte e sposta i mercati',
    'vip_emma-watson': 'che dai libri di magia è passata a quelli veri',
    'vip_federer': 'che perdeva con eleganza pure quando vinceva',
    'vip_fedez': 'che fa notizia più di un telegiornale',
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
    'vip_mbappe': 'che corre più veloce del tuo wifi',
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
    'vip_serena-williams': 'che serve più forte di quanto tu discuti',
    'vip_shakira': 'che con i fianchi non sa mentire',
    'vip_sinner': 'che resta di ghiaccio anche a Wimbledon',
    'vip_snoop-dogg': 'che se la prende comoda da trent\'anni',
    'vip_steve-jobs': 'che ha messo il futuro nella tasca di tutti',
    'vip_taylor-swift': 'che se la lasci ci scrive un album',
    'vip_the-weeknd': 'che canta le notti che tu dimentichi',
    'vip_timothee-chalamet': 'che fa sospirare due generazioni insieme',
    'vip_tom-cruise': 'che gli stunt se li fa da solo',
    'vip_usain-bolt': 'che ha corso piano solo per salutare',
    'vip_valentino-rossi': 'che in curva piega più di te sotto le scadenze',
    'vip_warren-buffett': 'che a colazione compra aziende',
    'vip_zendaya': 'che a ogni red carpet manda in tilt internet',
  };
}
