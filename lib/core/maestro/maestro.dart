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
    domainTitle: 'Astrologia e Destino',
    tagline: 'Legge le stelle e le carte del tuo cammino',
    domainInvite: 'Il cielo che ti disegna, le carte che ti rispondono',
    domainArts: 'Astrologia, Cartomanzia, Destino',
    icon: Icons.auto_awesome_outlined,
    avatarAsset: 'brand_assets/avatars/Medora-1.png',
  ),

  /// Chakra, energia, benessere, psiche. Verde smeraldo con oro.
  aura(
    id: 'aura',
    displayName: 'Aura',
    domainTitle: 'Energia e Benessere',
    tagline: 'Accompagna il respiro e l\'equilibrio interiore',
    domainInvite: 'Il respiro, l\'energia, gli archetipi che ti abitano',
    domainArts: 'Chakra, Energia, Archetipi',
    icon: Icons.spa_outlined,
    avatarAsset: 'brand_assets/avatars/Aura-1.png',
  ),

  /// Rune, rituali, simbologia, magia, Cabala. Rosso con oro.
  caligo(
    id: 'caligo',
    displayName: 'Caligo',
    domainTitle: 'Rune e Simboli',
    tagline: 'Custode delle rune e dei riti antichi',
    domainInvite: 'I segni antichi, i riti, l\'albero dei misteri',
    domainArts: 'Rune, Rituali, Cabala',
    icon: Icons.local_fire_department_outlined,
    avatarAsset: 'brand_assets/avatars/Caligo-1.png',
  );

  const Maestro({
    required this.id,
    required this.displayName,
    required this.domainTitle,
    required this.tagline,
    required this.domainInvite,
    required this.domainArts,
    required this.icon,
    required this.avatarAsset,
  });

  final String id;
  final String displayName;
  final String domainTitle;
  final String tagline;

  /// Invito breve di due righe su cosa si trova nel dominio del Maestro,
  /// mostrato nella bolla di ingresso della home.
  final String domainInvite;

  /// Le tre arti del Maestro, in riga sotto il pulsante di ingresso al dominio.
  final String domainArts;

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
