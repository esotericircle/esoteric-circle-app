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
    icon: Icons.auto_awesome_outlined,
    avatarAsset: 'brand_assets/avatars/Medora-1.png',
  ),

  /// Chakra, energia, benessere, psiche. Verde smeraldo con oro.
  aura(
    id: 'aura',
    displayName: 'Aura',
    domainTitle: 'Energia e Benessere',
    tagline: 'Accompagna il respiro e l\'equilibrio interiore',
    icon: Icons.spa_outlined,
    avatarAsset: 'brand_assets/avatars/Aura-1.png',
  ),

  /// Rune, rituali, simbologia, magia, Cabala. Rosso con oro.
  caligo(
    id: 'caligo',
    displayName: 'Caligo',
    domainTitle: 'Rune e Simboli',
    tagline: 'Custode delle rune e dei riti antichi',
    icon: Icons.local_fire_department_outlined,
    avatarAsset: 'brand_assets/avatars/Caligo-1.png',
  );

  const Maestro({
    required this.id,
    required this.displayName,
    required this.domainTitle,
    required this.tagline,
    required this.icon,
    required this.avatarAsset,
  });

  final String id;
  final String displayName;
  final String domainTitle;
  final String tagline;

  /// Icona lineare del Maestro (placeholder in attesa del brand).
  final IconData icon;

  /// Avatar reale in brand_assets.
  final String avatarAsset;

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
