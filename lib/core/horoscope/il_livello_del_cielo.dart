import '../astro/meeus/il_cielo_di_meeus.dart';
import '../astro/natal_chart.dart';
import '../astro/zodiac.dart';
import 'cielo_di_oggi.dart';
import 'corrente_del_cielo.dart';
import 'horoscope.dart';
import 'il_cielo_del_segno.dart';
import 'il_lessico_del_cielo.dart';
import '../astro/il_segno_del_cielo.dart';

/// **IL LIVELLO DI OGNI SCHEDA DAL CIELO VERO, ordine ES voce 28.**
///
/// Il fatto dell'Architetto: l'indicatore era `2 + (seed % 4)`, una hash su
/// segno, giorno, anno e dominio, uguale per tutto il segno anche con la
/// carta natale. Il briefing (sezione 40) lo chiama "anello di
/// favorevolezza": qui nasce dal cielo, con una regola scritta.
///
/// **Con la carta natale**: ogni passaggio del giorno che parla al dominio
/// ([CorrenteDelCielo.vociPer]) pesa +1 se armonico (trigono, sestile), -1
/// se teso (quadratura, opposizione); la congiunzione pesa +1 coi benefici
/// della tradizione (Venere, Giove), -1 coi malefici (Marte, Saturno), +0,5
/// con gli altri. Ogni peso si moltiplica per quanto il passaggio e' stretto:
/// 1 a orbita zero, 0 al limite dei due gradi.
///
/// **Senza carta**: la Luna di oggi e il segno solare. Il segno in cui sta la
/// Luna, contato dal segno della persona, fa l'aspetto fra i due segni:
/// trigono (quinta e nona casa solare) +1, sestile (terza e undicesima)
/// +0,5, congiunzione (prima) +0,5, quadratura (quarta e decima) -1,
/// opposizione (settima) -1, le altre 0. Se la casa solare e' una di quelle
/// del dominio (quinta, settima e ottava per l'Amore; seconda, sesta e decima
/// per la Carriera; seconda, quinta e undicesima per la Fortuna) si aggiunge
/// +0,5.
///
/// Senza carta pesa anche il corpo del dominio (il Sole per il Generale,
/// Venere per l'Amore, Marte per la Carriera, Giove per la Fortuna): la
/// meta' del peso della sua casa solare, piu' 0,5 se e' una casa del
/// dominio.
///
/// **La scala resta quella di prima**, da due a cinque: il livello e'
/// `3 + somma` arrotondato e tenuto fra 2 e 5; il giorno neutro e' 3.
///
/// **IL CLIMA E IL GIORNO**, ordine EU voce 09, 1 ottobre 2026. Il fondatore,
/// sulla Settimana: *"le barre [...] sembrano tutte uguali"*. Misurato per
/// tre persone con la carta e una senza, in quattro settimane
/// (`docs/collaudo/EU/livelli_dei_giorni.txt`): 4 domini-settimana su 64
/// avevano i sette livelli uguali e 26 ne avevano due soli. Il perche' nel
/// calcolo: i pianeti lenti (Giove, Saturno, Urano, Nettuno, Plutone)
/// restano nello stesso aspetto per settimane e si sommavano senza limite,
/// e bastavano due o tre loro aspetti armonici per tenere il livello a 5
/// tutti i giorni; la Luna, il solo corpo che cambia aspetto ogni giorno,
/// contava solo nei due gradi delle voci, cioe' quasi mai all'istante del
/// giorno. Due regole, con la tradizione dietro:
/// - **i lenti fanno il clima e pesano al massimo un gradino** ([lenti],
///   [tettoDelClima]): la distinzione fra i transiti lenti, che segnano
///   periodi di mesi, e quelli veloci, che segnano i giorni, e' quella di
///   Robert Hand, *Planets in Transit* (1976), introduzione;
/// - **la Luna del giorno** ([lunaDelGiorno]): il suo aspetto al corpo
///   natale del dominio conta con la meta' del suo orbe, sei gradi, dai
///   dodici che le da' William Lilly, *Christian Astrology* (1647), libro I.
abstract final class IlLivelloDelCielo {
  static const double orbitaMassima = 2.0;

  static const Set<CorpoCeleste> benefici = {
    CorpoCeleste.venere,
    CorpoCeleste.giove,
  };
  static const Set<CorpoCeleste> malefici = {
    CorpoCeleste.marte,
    CorpoCeleste.saturno,
  };

  /// **I LENTI FANNO IL CLIMA, LA LUNA E I VELOCI FANNO IL GIORNO.** Ordine
  /// EU voce 09, 1 ottobre 2026.
  static const Set<CorpoCeleste> lenti = {
    CorpoCeleste.giove,
    CorpoCeleste.saturno,
    CorpoCeleste.urano,
    CorpoCeleste.nettuno,
    CorpoCeleste.plutone,
  };

  /// Quanto pesa al massimo il clima dei lenti, in gradini.
  static const double tettoDelClima = 1.0;

  /// **L'ORBE DELLA LUNA DEL GIORNO**: la meta' (la "moiety") dei dodici
  /// gradi che William Lilly, *Christian Astrology* (1647), libro I, da' alla
  /// Luna. La Luna fa tredici gradi al giorno: sei gradi prima e sei dopo
  /// l'istante del giorno coprono la giornata.
  static const double orbeDellaLuna = 6.0;

  /// Il corpo natale di ogni dominio, lo stesso del momento chiave della
  /// Settimana: il Sole per il Generale, Venere per l'Amore, Marte per la
  /// Carriera, Giove per la Fortuna.
  static const Map<HoroscopeDomain, String> corpoNataleDi = {
    HoroscopeDomain.generale: 'sun',
    HoroscopeDomain.amore: 'venus',
    HoroscopeDomain.carriera: 'mars',
    HoroscopeDomain.fortuna: 'jupiter',
  };

  /// **LA LUNA DEL GIORNO**: l'aspetto della Luna al corpo natale del
  /// dominio entro [orbeDellaLuna], col suo peso (armonico +1, teso -1,
  /// congiunzione +0,5, per quanto e' stretto) e la voce che la riga nomina.
  /// Nullo senza carta o senza aspetto.
  static (double, VoceDelCielo)? lunaDelGiorno(
      CieloDiOggi cielo, HoroscopeDomain dominio) {
    final luna = cielo.lunaDelGiorno;
    final id = corpoNataleDi[dominio]!;
    final natale = cielo.natali[id];
    if (luna == null || natale == null) return null;
    var distanza = (luna - natale.$2).abs() % 360.0;
    if (distanza > 180) distanza = 360 - distanza;
    for (final a in AspectType.values) {
      final orbe = (distanza - a.angoloEsatto).abs();
      if (orbe > orbeDellaLuna) continue;
      final v = VoceDelCielo(
        transito: CorpoCeleste.luna,
        bersaglio: natale.$1,
        idBersaglio: id,
        aspetto: a,
        orbe: orbe,
        applicativo: null,
        casa: null,
        retrogrado: false,
        giorniDiIncertezza: 0,
      );
      return (pesoDi(v) * (1 - orbe / orbeDellaLuna), v);
    }
    return null;
  }

  /// Il peso di un passaggio, prima dell'orbita.
  static double pesoDi(VoceDelCielo v) {
    switch (v.aspetto.harmony) {
      case AspectHarmony.soft:
        return 1;
      case AspectHarmony.hard:
        return -1;
      case AspectHarmony.neutral:
        if (benefici.contains(v.transito)) return 1;
        if (malefici.contains(v.transito)) return -1;
        return 0.5;
    }
  }

  /// Il peso dell'aspetto fra due segni, dalla casa solare [casa] (1-12).
  static double pesoDellaCasaSolare(int casa) => switch (casa) {
        5 || 9 => 1,
        3 || 11 => 0.5,
        1 => 0.5,
        4 || 10 => -1,
        7 => -1,
        _ => 0,
      };

  /// **Fonte**, ordine EV voce EV.08, verifica dell'Architetto (O-G-005):
  /// gli aspetti fra segni (stesso segno, sestile, quadratura, trigono,
  /// opposizione) sono quelli di Tolomeo, *Tetrabiblos*, libro I, cap. 13.
  /// Le case solari (O-G-004) sono la pratica moderna per chi non ha l'ora
  /// di nascita: lo dichiara la nota del metodo O-M-004.
  // I rapporti col segno, detti in parole di tutti i giorni, stanno in
  // [IlLessicoDelCielo.rapportoDelSegno].

  /// **IL GIORNO NEUTRO VALE TRE**, vista sul Realme il 29 settembre: col
  /// centro a 3,5 un giorno senza niente usciva 4 su 5, cioe' sembrava buono.
  /// Adesso il neutro e' 3, gli armonici salgono fino a 5, i tesi scendono
  /// fino a 2, il pavimento di sempre.
  static int _scala(double somma) => (3 + somma).round().clamp(2, 5);

  /// Il livello (2-5) e la riga che dice da dove viene.
  ///
  /// **SESTO GIRO GA.06**: la riga e' il corpo del "Da dove viene" come lo
  /// direbbe un amico che sa leggere il cielo, due frasi: che cosa fa il cielo
  /// e che cosa significa per il campo. Niente quadratura, trigono, casa,
  /// Ascendente: "la Luna va d'accordo con il tuo segno, ti sostiene". Il
  /// corpo che si nomina e' quello che pesa nel verso del livello, cosi' la
  /// riga non dice mai il contrario della risposta.
  static (int, String) per({
    required HoroscopeDomain dominio,
    required Zodiac segno,
    required CieloDiOggi cielo,
    required DateTime quando,
    bool oggi = true,
  }) {
    final quale = oggi ? 'Oggi' : 'Quel giorno';
    final del = oggi ? 'di oggi' : 'di quel giorno';
    if (cielo.ceCieloVero) {
      final voci = CorrenteDelCielo.vociPer(cielo, dominio);
      var delClima = 0.0;
      var delGiorno = 0.0;
      final pesate = <(double, VoceDelCielo)>[];
      // La Luna del giorno al corpo natale del dominio, con la meta' del suo
      // orbe: prende il posto della stessa voce stretta, se c'e'.
      final dellaLuna = lunaDelGiorno(cielo, dominio);
      if (dellaLuna != null) {
        final (p, v) = dellaLuna;
        delGiorno += p;
        pesate.add((p, v));
      }
      for (final v in voci) {
        if (dellaLuna != null &&
            v.transito == CorpoCeleste.luna &&
            v.idBersaglio == corpoNataleDi[dominio]) {
          continue;
        }
        final stretto =
            (1 - v.orbe.abs() / orbitaMassima).clamp(0.0, 1.0).toDouble();
        final p = pesoDi(v) * stretto;
        if (lenti.contains(v.transito)) {
          delClima += p;
        } else {
          delGiorno += p;
        }
        pesate.add((p, v));
      }
      final somma =
          delClima.clamp(-tettoDelClima, tettoDelClima).toDouble() + delGiorno;
      final livello = _scala(somma);
      final verso = livello > 3 ? 1 : (livello < 3 ? -1 : 0);
      // Il passaggio che pesa di piu' nel verso del livello; a livello di
      // mezzo, il piu' forte qualunque sia.
      (double, VoceDelCielo)? scelto;
      for (final e in pesate) {
        if (e.$1 == 0) continue;
        if (verso != 0 && e.$1.sign != verso) continue;
        if (scelto == null || e.$1.abs() > scelto.$1.abs()) scelto = e;
      }
      final frase = scelto == null || verso == 0
          ? '$quale i passaggi del cielo si bilanciano: nessuno spinge in '
              'modo netto su questo campo.'
          : '$quale ${CorrenteDelCielo.colSuoArticolo(scelto.$2.transito, maiuscola: false)} '
              '${IlLessicoDelCielo.rapportoCon(scelto.$2.aspetto)} '
              '${IlLessicoDelCielo.bersaglioInParole(scelto.$2)}: '
              '${IlLessicoDelCielo.effetto(scelto.$1)}.';
      return (
        livello,
        '$frase ${IlLessicoDelCielo.conclusione(dominio, livello, quando: del)}'
      );
    }
    final luna = IlSegnoDelCielo.delCorpo(CorpoCeleste.luna, quando);
    final casa = IlCieloDelSegno.casaSolare(segno, luna);
    final caseDelDominio = CorrenteDelCielo.caseDi[dominio] ?? const <int>{};
    final pLuna = pesoDellaCasaSolare(casa);
    var somma = pLuna;
    final bonusLuna = caseDelDominio.contains(casa);
    if (bonusLuna) somma += 0.5;
    // **E IL CORPO DEL DOMINIO**, vista sul Realme il 29 settembre: con la
    // sola Luna le quattro schede avevano lo stesso livello e la stessa riga,
    // e chi legge si chiede perche'. Il corpo del dominio (il Sole, Venere,
    // Marte, Giove) pesa la meta' della Luna, dalla sua casa solare.
    final corpo = IlCieloDelSegno.corpoDi[dominio]!;
    final suo = IlSegnoDelCielo.delCorpo(corpo, quando);
    final casaSua = IlCieloDelSegno.casaSolare(segno, suo);
    final pCorpo = 0.5 * pesoDellaCasaSolare(casaSua);
    somma += pCorpo;
    if (caseDelDominio.contains(casaSua)) somma += 0.5;
    final livello = _scala(somma);
    final verso = livello > 3 ? 1 : (livello < 3 ? -1 : 0);
    String frase;
    final lunaVale = pLuna != 0 && (verso == 0 || pLuna.sign == verso);
    final corpoVale = pCorpo != 0 && (verso == 0 || pCorpo.sign == verso);
    // A livello di mezzo il rapporto c'e' ma non sposta il giudizio: si dice
    // "ma poco", non "ti mette alla prova" sotto un "in equilibrio".
    String esito(double p) =>
        verso == 0 ? ', ma poco' : ': ${IlLessicoDelCielo.effetto(p)}';
    // La Luna cambia segno ogni due giorni e mezzo: quando spinge nel verso
    // del livello e' lei a dare la ragione, cosi' la riga di una settimana
    // cambia coi giorni; altrimenti il corpo del campo, che e' lento.
    if (lunaVale && corpoVale) {
      // Tutti e due contano: si nominano insieme, cosi' le quattro schede
      // dello stesso giorno non hanno la stessa riga (Realme, 29 settembre)
      // e la riga cambia coi giorni.
      final guida = IlLessicoDelCielo.chiGuida[dominio];
      if (pLuna.sign != pCorpo.sign) {
        frase = '$quale la Luna è in ${luna.italianName} e '
            '${pLuna > 0 ? 'va d\'accordo con' : 'fa attrito con'} il tuo '
            'segno, mentre $guida, è in ${suo.italianName} e '
            '${pCorpo > 0 ? 'va d\'accordo con' : 'fa attrito con'} il tuo '
            'segno: i due si bilanciano.';
      } else {
        frase = '$quale la Luna è in ${luna.italianName} e $guida, è in '
            '${suo.italianName}: '
            '${pLuna > 0 ? 'vanno d\'accordo con' : 'fanno attrito con'} il '
            'tuo segno${verso == 0 ? ', ma poco' : (pLuna > 0 ? ' e ti sostengono' : ' e ti mettono un po\' alla prova')}.';
      }
    } else if (lunaVale) {
      frase = '$quale la Luna è in ${luna.italianName} e '
          '${pLuna > 0 ? 'va d\'accordo con' : 'fa attrito con'} il tuo '
          'segno${esito(pLuna)}.';
    } else if (corpoVale) {
      frase = '$quale ${IlLessicoDelCielo.chiGuida[dominio]}, è in '
          '${suo.italianName} e '
          '${pCorpo > 0 ? 'va d\'accordo con' : 'fa attrito con'} il tuo '
          'segno${esito(pCorpo)}.';
    } else if (verso > 0 && bonusLuna) {
      frase = '$quale la Luna è in ${luna.italianName}, proprio nell\'area '
          'della tua vita che riguarda '
          '${IlLessicoDelCielo.cheCosaRiguarda[dominio]}.';
    } else if (verso > 0 && caseDelDominio.contains(casaSua)) {
      frase = '$quale ${IlLessicoDelCielo.chiGuida[dominio]}, è in '
          '${suo.italianName}, proprio nell\'area della tua vita che '
          'riguarda ${IlLessicoDelCielo.cheCosaRiguarda[dominio]}.';
    } else {
      frase = '$quale la Luna è in ${luna.italianName} e non spinge il tuo '
          'segno né in un senso né nell\'altro.';
    }
    return (
      livello,
      '$frase ${IlLessicoDelCielo.conclusione(dominio, livello, quando: del)}'
    );
  }
}
