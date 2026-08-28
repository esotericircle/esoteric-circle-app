import 'package:flutter/material.dart';

/// I tre Maestri AI piu' lo stato neutro (nessun Maestro selezionato).
///
/// E' un concetto di dominio, indipendente dai colori: la palette vive nel
/// design system (`MaestroPalette`). Qui restano identita', dominio, icona
/// lineare e avatar. L'icona lineare dorata sostituisce i glifi unicode in
/// attesa dell'iconografia di brand definitiva.
///
/// Riferimento: Master Tecnico sezione 14 e Briefing Operativo sezione 6.
enum Maestro {
  /// Astrologia, cartomanzia, destino, Angeli. Blu profondo con oro.
  medora(
    id: 'medora',
    displayName: 'Medora',
    tagline: 'Legge le stelle e le carte del tuo cammino',
    domainInvite: 'Il cielo che ti disegna, le carte che ti rispondono',
    domainArts: 'Astrologia, Cartomanzia, Destino',
    icon: Icons.auto_awesome_outlined,
    avatarAsset: 'assets/avatars_webp/Medora-1.webp',
  ),

  /// Chakra, energia, benessere, psiche. Verde smeraldo con oro.
  aura(
    id: 'aura',
    displayName: 'Aura',
    tagline: 'Accompagna il respiro e l\'equilibrio interiore',
    domainInvite: 'Il respiro, l\'energia, gli archetipi che ti abitano',
    domainArts: 'Chakra, Energia, Archetipi',
    icon: Icons.spa_outlined,
    avatarAsset: 'assets/avatars_webp/Aura-1.webp',
  ),

  /// Rune, rituali, simbologia, magia, Cabala. Rosso con oro.
  caligo(
    id: 'caligo',
    displayName: 'Caligo',
    tagline: 'Custode delle rune e dei riti antichi',
    domainInvite: 'I segni antichi, i riti, l\'albero dei misteri',
    domainArts: 'Rune, Rituali, Cabala',
    icon: Icons.local_fire_department_outlined,
    avatarAsset: 'assets/avatars_webp/Caligo-1.webp',
  );

  const Maestro({
    required this.id,
    required this.displayName,
    required this.tagline,
    required this.domainInvite,
    required this.domainArts,
    required this.icon,
    required this.avatarAsset,
  });

  final String id;
  final String displayName;
  final String tagline;

  /// Invito breve di due righe su cosa si trova nel dominio del Maestro,
  /// mostrato nella bolla di ingresso della home.
  final String domainInvite;

  /// Le tre arti del Maestro, in riga sotto il pulsante di ingresso al dominio.
  final String domainArts;

  /// **LE ARTI IN DUE PAROLE, ordine BX voce 04.** Servono ai due Maestri di
  /// lato nella home, dove lo spazio e' un terzo di riga: le tre arti per
  /// esteso ci finirebbero troncate a meta' parola, che e' peggio di non
  /// scriverle.
  ///
  /// **Le parole sono quelle del fondatore**, non una sintesi mia: i
  /// fondatori hanno chiesto che dalla home risulti che l'app e' anzitutto
  /// oroscopo, cartomanzia e rune, e queste sono le prime due arti di
  /// ognuno con quei nomi.
  /// **UNA PAROLA SOLA, e la ragione e' l'immagine.** La prima stesura ne
  /// metteva due ("Oroscopo, Tarocchi"), e a schermo si leggevano
  /// "Orosco..." e "Rune, R...": tre puntini al posto della meta' di ogni
  /// parola sono peggio del silenzio. Le prove non lo hanno visto, perche'
  /// nessuna prova guarda i puntini; l'ha visto l'anteprima.
  String get domainArtiBrevi => switch (this) {
        Maestro.medora => 'Astrologia',
        Maestro.aura => 'Chakra',
        Maestro.caligo => 'Rune',
      };

  /// Le tre arti come frase, con la "e" prima dell'ultima e senza virgola
  /// davanti alla congiunzione: "Astrologia, Cartomanzia e Destino".
  ///
  /// **E' l'UNICO modo di dire il dominio di un Maestro.** Accanto viveva un
  /// `domainTitle` che diceva la stessa cosa in forma corta, "Astrologia e
  /// Destino": due campi che descrivono lo stesso oggetto divergono sempre, ed
  /// e' gia' successo in questo progetto con `_curatedArts` accanto ad
  /// `ArtCatalog`. Il corto e' sparito il 5 agosto 2026, non allineato:
  /// allinearli avrebbe lasciato in piedi il modo di farli divergere di nuovo.
  ///
  /// **E non si accorcia per farlo stare.** Togliere la Cartomanzia da Medora
  /// significa dichiarare che conta meno delle altre due, mentre e' una delle
  /// tre arti che il Maestro dichiara. Dove non entra, si rimpicciolisce
  /// oppure va a capo.
  String get domainArtsPhrase {
    final arti =
        domainArts.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    if (arti.length <= 1) return arti.isEmpty ? '' : arti.first;
    final tutte = arti.sublist(0, arti.length - 1).join(', ');
    return '$tutte e ${arti.last}';
  }

  /// Icona lineare del Maestro (placeholder in attesa del brand).
  final IconData icon;

  /// Avatar reale in brand_assets.
  final String avatarAsset;

  /// Ordine fisso da sinistra a destra dove i tre Maestri stanno in fila:
  /// Medora, Caligo, Aura. Vale per la bottom bar e per il selettore in Home.
  /// Nel Santuario non si usa, perche' li' i busti ruotano col selezionato al
  /// centro. Resta distinto dall'ordine di dichiarazione dell'enum, cosi' la
  /// rotazione del Santuario e ogni altra logica possono contare su quello.
  ///
  /// Riferimento: Consolidamento decisioni sezione 9.
  static const List<Maestro> fixedOrder = [medora, caligo, aura];

  static Maestro? fromId(String? id) {
    for (final m in Maestro.values) {
      if (m.id == id) return m;
    }
    return null;
  }
}

/// Chiave semantica del tema attivo: uno dei tre Maestri oppure lo stato
/// neutro usato quando nessun Maestro e' selezionato (viola scuro / nero
/// stellato con oro).
@immutable
class ThemeKey {
  /// Nessun Maestro selezionato: tema neutro.
  const ThemeKey.neutral() : maestro = null;

  /// Tema legato a un Maestro specifico.
  const ThemeKey.of(Maestro this.maestro);

  final Maestro? maestro;

  bool get isNeutral => maestro == null;

  @override
  bool operator ==(Object other) =>
      other is ThemeKey && other.maestro == maestro;

  @override
  int get hashCode => maestro.hashCode;
}
