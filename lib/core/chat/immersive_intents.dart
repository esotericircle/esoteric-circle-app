import '../maestro/maestro.dart';

/// Le funzioni immersive verso cui la chat puo' instradare.
enum ImmersiveTarget {
  tarocchiStesa,
  cartaNatale,
  sinastriaVip,
  oroscopoGiorno,
  meditazione,
  breathwork,
  costellazioneViso,
  scanChakra,
  frequenze,
  lancioRune,
  sigilloMagico,
  iChing,
  pendolo,
  ritualeCandela,
}

/// Un intento immersivo: se in chat l'utente lo esprime, il Maestro non genera
/// una lettura a testo, invita ad aprire la funzione dedicata.
///
/// Le parole chiave sono in minuscolo e senza accenti scomodi: il
/// classificatore normalizza il testo prima del confronto. L'invito e' la frase
/// in carattere del Maestro, il pulsante apre la funzione (deep link interno).
class ImmersiveIntent {
  const ImmersiveIntent({
    required this.maestro,
    required this.target,
    required this.keywords,
    required this.invite,
    required this.buttonLabel,
  });

  final Maestro maestro;
  final ImmersiveTarget target;
  final List<String> keywords;
  final String invite;
  final String buttonLabel;

  String get id => target.name;
}

/// La lista degli intenti per Maestro, allow-list per dominio. E' un file di
/// sola configurazione: si estende aggiungendo voci qui, senza toccare la logica
/// del classificatore.
class ImmersiveIntents {
  const ImmersiveIntents._();

  static const List<ImmersiveIntent> all = [
    // --- Medora ---
    ImmersiveIntent(
      maestro: Maestro.medora,
      target: ImmersiveTarget.tarocchiStesa,
      keywords: [
        'stesa',
        'stendi le carte',
        'leggi le carte',
        'tira le carte',
        'tarocchi',
        'arcani',
      ],
      invite:
          'Le carte vogliono essere viste, non raccontate. Vieni, stendiamole insieme.',
      buttonLabel: 'Apri la stesa',
    ),
    ImmersiveIntent(
      maestro: Maestro.medora,
      target: ImmersiveTarget.cartaNatale,
      keywords: ['carta natale', 'tema natale', 'mappa natale', 'carta del cielo'],
      invite:
          'La tua mappa del cielo merita di essere guardata, non riassunta. Apriamola.',
      buttonLabel: 'Apri la carta natale',
    ),
    ImmersiveIntent(
      maestro: Maestro.medora,
      target: ImmersiveTarget.sinastriaVip,
      keywords: [
        'sinastria',
        'compatibilita con',
        'affinita con',
        'con un vip',
        'con una celebrita',
      ],
      invite:
          'Due cieli che si sfiorano si leggono meglio a occhi aperti. Scegliamo la stella.',
      buttonLabel: 'Apri la Sinastria VIP',
    ),
    ImmersiveIntent(
      maestro: Maestro.medora,
      target: ImmersiveTarget.oroscopoGiorno,
      keywords: [
        'oroscopo del giorno',
        'oroscopo di oggi',
        'oroscopo oggi',
        'previsione del giorno',
      ],
      invite: 'Il cielo di oggi si mostra meglio che a parole. Guardiamolo insieme.',
      buttonLabel: 'Apri l\'Oracolo del Giorno',
    ),

    // --- Aura ---
    ImmersiveIntent(
      maestro: Maestro.aura,
      target: ImmersiveTarget.meditazione,
      keywords: ['meditazione', 'meditare', 'medita', 'rilassami', 'rilassarmi'],
      invite: 'Non ti serve che ti spieghi la calma, ti serve entrarci. Vieni a respirare.',
      buttonLabel: 'Apri la Meditazione',
    ),
    ImmersiveIntent(
      maestro: Maestro.aura,
      target: ImmersiveTarget.breathwork,
      keywords: ['breathwork', 'respirazione', 'respiro guidato', 'esercizio di respiro'],
      invite: 'Il respiro non si racconta, si fa. Seguimi, un soffio alla volta.',
      buttonLabel: 'Apri il respiro',
    ),
    ImmersiveIntent(
      maestro: Maestro.aura,
      target: ImmersiveTarget.costellazioneViso,
      keywords: ['costellazione del viso', 'lettura del viso', 'morfopsicologia'],
      invite: 'Il tuo volto ha una geometria che va vista. Accendiamo la luce con dolcezza.',
      buttonLabel: 'Apri la Costellazione del viso',
    ),
    ImmersiveIntent(
      maestro: Maestro.aura,
      target: ImmersiveTarget.scanChakra,
      keywords: ['chakra', 'scan dei chakra', 'scansione dei chakra', 'centri energetici'],
      invite: 'I tuoi centri si sentono meglio guardandoli. Facciamo lo scan con calma.',
      buttonLabel: 'Apri lo scan dei chakra',
    ),
    ImmersiveIntent(
      maestro: Maestro.aura,
      target: ImmersiveTarget.frequenze,
      keywords: ['frequenze', 'frequenza sonora', 'suoni curativi', 'battito binaurale'],
      invite: 'Le frequenze si ascoltano, non si descrivono. Mettiti le cuffie, ti guido.',
      buttonLabel: 'Apri le frequenze',
    ),

    // --- Caligo ---
    ImmersiveIntent(
      maestro: Maestro.caligo,
      target: ImmersiveTarget.lancioRune,
      keywords: ['lancio delle rune', 'tira le rune', 'getta le rune', 'runa', 'rune', 'futhark'],
      invite: 'Le rune non si spiegano a parole, si gettano. Vieni, lanciamole.',
      buttonLabel: 'Apri le rune',
    ),
    ImmersiveIntent(
      maestro: Maestro.caligo,
      target: ImmersiveTarget.sigilloMagico,
      keywords: ['sigillo', 'sigillo magico', 'simbolo magico'],
      invite: 'Un sigillo si traccia, non si narra. Disegniamolo insieme.',
      buttonLabel: 'Apri il Sigillo',
    ),
    ImmersiveIntent(
      maestro: Maestro.caligo,
      target: ImmersiveTarget.iChing,
      keywords: ['i-ching', 'i ching', 'iching', 'esagramma'],
      invite: 'L\'I-Ching risponde a chi lancia, non a chi chiede a voce. Lanciamo.',
      buttonLabel: 'Apri l\'I-Ching',
    ),
    ImmersiveIntent(
      maestro: Maestro.caligo,
      target: ImmersiveTarget.pendolo,
      keywords: ['pendolo', 'radioestesia'],
      invite: 'Il pendolo parla col movimento, non con me. Prendilo in mano.',
      buttonLabel: 'Apri il Pendolo',
    ),
    ImmersiveIntent(
      maestro: Maestro.caligo,
      target: ImmersiveTarget.ritualeCandela,
      keywords: ['rituale con candela', 'rito della candela', 'candela', 'magia con la candela'],
      invite: 'Un rito con la candela si accende, non si racconta. Accendiamola.',
      buttonLabel: 'Apri il rito della candela',
    ),
  ];

  /// Gli intenti di un Maestro, ordinati con le chiavi piu' lunghe prima, cosi'
  /// una frase specifica vince su una parola generica.
  static List<ImmersiveIntent> forMaestro(Maestro maestro) =>
      all.where((i) => i.maestro == maestro).toList();
}
