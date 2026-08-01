import '../astro/night_sky.dart';
import '../astro/zodiac.dart';
import 'animal_catalog.dart';
import 'guide_animal_corpus.dart';

/// Il tema del cielo di oggi, dalla natura del transito. Quattro nature grezze,
/// bastano a colorare il messaggio senza promettere nulla.
enum TemaTransito { armonia, sfida, intensita, quiete }

/// L'aspetto per segno fra un pianeta di transito e un punto natale. Calcolato
/// dalla distanza fra i due segni, non da un orbo fine: onesto con cio' che il
/// dispositivo sa davvero, senza fingere una precisione che non ha.
enum AspettoSegno { congiunzione, sestile, quadrato, trigono, opposizione, nessuno }

/// Il Messaggio del Giorno pronto per la schermata: il testo nella voce
/// dell'animale, piu' i due pezzi di trasparenza (il transito in parole e i dati
/// natali usati), dichiarati in chiaro all'utente.
class MessaggioDelGiorno {
  const MessaggioDelGiorno({
    required this.testo,
    required this.transito,
    required this.datiNatali,
  });

  /// Il messaggio dell'animale per il tema del giorno.
  final String testo;

  /// Il transito di oggi in parole, es. "Oggi la Luna in Scorpione si oppone al
  /// tuo Sole in Cancro."
  final String transito;

  /// I dati della carta natale usati nel calcolo, es. "Sole in Cancro, Luna in
  /// Pesci". L'Ascendente non compare: senza il motore a effemeridi completo non
  /// e' calcolabile offline, e non si inventa.
  final String datiNatali;
}

/// Il Messaggio del Giorno dell'Animale Guida: deterministico dalla data locale
/// e dalla carta dell'utente, calcolato riusando `NightSky`, lo stesso cielo su
/// cui poggiano l'Oroscopo e i Doni del Giorno. Zero AI, zero casualita'.
///
/// Il transito primario e' la Luna di transito di oggi (l'unico pianeta veloce
/// calcolabile offline con Sole) e il suo aspetto per segno al Sole natale (il
/// punto natale garantito offline, cioe' il segno solare dell'utente). La natura
/// dell'aspetto diventa un tema, e dal tema piu' il totem si sceglie in modo
/// deterministico il messaggio dal repertorio dell'animale. Resta fisso fino
/// alla mezzanotte locale e si ricalcola dopo, come l'Oroscopo e i Doni.
class GuideAnimalDay {
  const GuideAnimalDay._();

  /// Calcola il messaggio per [animale] nel giorno [giorno] (data locale), col
  /// Sole natale [soleNatale] (il segno dell'utente) e, se nota, la data di
  /// nascita [nascita] per mostrare la Luna natale nella trasparenza.
  static MessaggioDelGiorno per({
    required GuideAnimal animale,
    required Zodiac soleNatale,
    required DateTime giorno,
    DateTime? nascita,
  }) {
    // Ancoraggio al mezzogiorno del giorno locale: un valore per data, stabile
    // fino alla mezzanotte, come `ArchetypeSky`.
    final gg = DateTime.utc(giorno.year, giorno.month, giorno.day, 12);
    final lunaOggi = NightSky.moonSign(gg);
    final aspetto = _aspettoPerSegno(lunaOggi, soleNatale);
    final tema = _temaDa(aspetto);

    final r = GuideAnimalCorpus.di(animale.name);
    final indice = _indice(animale.name, tema, r.messaggi.length);
    final testo = '${_cornice(tema)} Il tuo totem ti porta un segno: '
        '${r.messaggi[indice]}';

    final transito = 'Oggi la Luna in ${lunaOggi.italianName} '
        '${_fraseAspetto(aspetto)} ${soleNatale.italianName}.';

    final lunaNatale = nascita != null ? NightSky.moonSign(nascita) : null;
    final datiNatali = lunaNatale != null
        ? 'Sole in ${soleNatale.italianName}, Luna in ${lunaNatale.italianName}'
        : 'Sole in ${soleNatale.italianName}';

    return MessaggioDelGiorno(
        testo: testo, transito: transito, datiNatali: datiNatali);
  }

  /// L'aspetto per segno: dalla distanza circolare fra i due segni sullo zodiaco.
  static AspettoSegno _aspettoPerSegno(Zodiac transito, Zodiac natale) {
    var d = (transito.index - natale.index) % 12;
    if (d < 0) d += 12;
    final passi = d > 6 ? 12 - d : d; // 0..6
    return switch (passi) {
      0 => AspettoSegno.congiunzione,
      2 => AspettoSegno.sestile,
      3 => AspettoSegno.quadrato,
      4 => AspettoSegno.trigono,
      6 => AspettoSegno.opposizione,
      _ => AspettoSegno.nessuno,
    };
  }

  static TemaTransito _temaDa(AspettoSegno aspetto) => switch (aspetto) {
        AspettoSegno.congiunzione => TemaTransito.intensita,
        AspettoSegno.sestile => TemaTransito.armonia,
        AspettoSegno.trigono => TemaTransito.armonia,
        AspettoSegno.quadrato => TemaTransito.sfida,
        AspettoSegno.opposizione => TemaTransito.sfida,
        AspettoSegno.nessuno => TemaTransito.quiete,
      };

  static String _cornice(TemaTransito tema) => switch (tema) {
        TemaTransito.armonia => 'Oggi il cielo ti sostiene.',
        TemaTransito.sfida => 'Oggi il cielo ti chiama a muoverti.',
        TemaTransito.intensita => 'Oggi il cielo si fa intenso.',
        TemaTransito.quiete => "Oggi il cielo è quieto.",
      };

  static String _fraseAspetto(AspettoSegno aspetto) => switch (aspetto) {
        AspettoSegno.congiunzione => 'si unisce al tuo Sole in',
        AspettoSegno.sestile => 'apre un sestile al tuo Sole in',
        AspettoSegno.trigono => "è in trigono col tuo Sole in",
        AspettoSegno.quadrato => 'incalza in quadratura il tuo Sole in',
        AspettoSegno.opposizione => 'si oppone al tuo Sole in',
        AspettoSegno.nessuno => 'passa lontana dal tuo Sole in',
      };

  /// Indice deterministico nel repertorio dal totem piu' il tema, con la stessa
  /// hash FNV-1a a 32 bit usata dall'Oroscopo, cosi' lo stile e' uno solo.
  static int _indice(String totem, TemaTransito tema, int lunghezza) {
    final valori = <int>[...totem.codeUnits, tema.index];
    return _fnv1a(valori) % lunghezza;
  }

  static int _fnv1a(List<int> valori) {
    var h = 0x811c9dc5;
    for (final v in valori) {
      h = (h ^ v) & 0xffffffff;
      h = (h * 0x01000193) & 0xffffffff;
    }
    return h;
  }
}
