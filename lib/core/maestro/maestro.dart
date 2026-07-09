import 'package:flutter/widgets.dart';

/// I tre Maestri AI piu' lo stato neutro (nessun Maestro selezionato).
///
/// E' un concetto di dominio, indipendente dai colori: la palette vive nel
/// design system (`MaestroPalette`). Qui restano identita', dominio e simbolo.
///
/// Riferimento: Master Tecnico sezione 14 e Briefing Operativo sezione 6.
enum Maestro {
  /// Astrologia, cartomanzia, destino, Angeli. Blu profondo con oro.
  medora(
    id: 'medora',
    displayName: 'Medora',
    domainTitle: 'Astrologia e Destino',
    tagline: 'Legge le stelle e le carte del tuo cammino',
    symbol: '✧', // stella a otto punte stilizzata
  ),

  /// Chakra, energia, benessere, psiche. Verde smeraldo con oro.
  aura(
    id: 'aura',
    displayName: 'Aura',
    domainTitle: 'Energia e Benessere',
    tagline: 'Accompagna il respiro e l\'equilibrio interiore',
    symbol: '❀', // fiore stilizzato
  ),

  /// Rune, rituali, simbologia, magia, Cabala. Rosso con oro.
  caligo(
    id: 'caligo',
    displayName: 'Caligo',
    domainTitle: 'Rune e Simboli',
    tagline: 'Custode delle rune e dei riti antichi',
    symbol: 'ᚱ', // runa Rad stilizzata
  );

  const Maestro({
    required this.id,
    required this.displayName,
    required this.domainTitle,
    required this.tagline,
    required this.symbol,
  });

  final String id;
  final String displayName;
  final String domainTitle;
  final String tagline;
  final String symbol;

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
