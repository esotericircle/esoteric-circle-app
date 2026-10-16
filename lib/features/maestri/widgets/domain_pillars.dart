import 'package:flutter/material.dart';

import '../../../core/maestro/maestro.dart';
import '../../../design_system/theme/maestro_scope.dart';
import '../../../design_system/tokens/typography_tokens.dart';

/// I tre pilastri del dominio, come seconda riga sotto il nome del Maestro.
///
/// Sono le tre arti principali che il Maestro dichiara di se'
/// (`Maestro.domainArts`), non un elenco scritto a mano: Astrologia,
/// Cartomanzia e Destino per Medora, Chakra, Energia e Archetipi per Aura,
/// Rune, Rituali e Numerologia per Caligo. Separati da un punto mediano.
///
/// E' un sottotitolo e basta: dice di che cosa e' fatto il dominio prima ancora
/// che si scorra, e non si tocca. Le sottocategorie si raggiungono scorrendo,
/// come ogni altra cosa nella schermata.
class DomainPillars extends StatelessWidget {
  const DomainPillars({super.key, required this.maestro});

  final Maestro maestro;

  /// I nomi dei pilastri, ricavati dal Maestro stesso.
  static List<String> of(Maestro maestro) => [
        for (final nome in maestro.domainArts.split(','))
          if (nome.trim().isNotEmpty) nome.trim(),
      ];

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final pilastri = of(maestro);
    if (pilastri.isEmpty) return const SizedBox.shrink();
    // UNA FORMA SOLA PER IL DOMINIO, ed e' quella con le virgole.
    //
    // Qui si leggeva "Astrologia · Cartomanzia · Destino" e in chat
    // "Astrologia, Cartomanzia e Destino": la stessa informazione in due
    // composizioni, quindi due modi di ricordarsela e due punti da correggere
    // ogni volta. Vince quella con le virgole e la congiunzione, perche' e'
    // italiano scritto e si legge ad alta voce; i punti medi sono un modo di
    // separare, non di dire. Nasce da `Maestro.domainArtsPhrase`, che e' il
    // punto unico, e questa schermata non compone piu' niente da sola.
    return Text(
      key: const Key('domain_pillars'),
      maestro.domainArtsPhrase,
      // DUE RIGHE, ordine AI voce 02: il titolo del dominio vive ora fra la
      // porta dell'account e la pillola, e nello spazio protetto la frase
      // lunga di Medora non ci sta su una riga. Meglio a capo fra le parole
      // che troncata coi puntini: la frase si legge intera.
      maxLines: 2,
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
      style: TypographyTokens.etichetta().copyWith(
        color: palette.goldSoft.withValues(alpha: 0.85),
        // La spaziatura scende da 0,9 a 0,4 con l'ordine AI voce 02: nello
        // spazio protetto fra porta e pillola (167,7 punti a 360) la riga
        // piu' lunga, "Cartomanzia e Destino", misura 171,3 a 0,9 e si
        // troncava coi puntini; a 0,4 misura 160,8 e la frase entra INTERA
        // su due righe, con 6,9 punti di margine.
        letterSpacing: 0.4,
      ),
    );
  }
}
