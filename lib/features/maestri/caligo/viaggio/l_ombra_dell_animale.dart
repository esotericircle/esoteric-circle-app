import 'dart:ui' as ui;

import 'package:flutter/material.dart';

// **IN UN FILE SUO DALL'ORDINE DI VOCE 10.** L'ombra nacque nello stesso file
// della lente dell'ordine DE voce 03; la lente e' stata tolta perche' il gesto
// che scosta l'ha sostituita, e l'ombra, che serve all'incontro, al Passaporto,
// ai Trionfi, ai compagni di nascita e alla scheda dell'animale, resta intera.

/// **L'OMBRA VERA DI UN ANIMALE VERO.** Ordine DE voce 03.
///
/// **Serve all'incontro, dove le ombre sono tre e se ne segue una.** Fino a
/// ieri quelle tre ombre le disegnava una formula, e la formula disegnava
/// **sempre un quadrupede**: chi seguiva l'ombra di un'aquila stava seguendo
/// il disegno di un lupo. Adesso l'ombra e' **la sagoma vera di quella
/// illustrazione**, presa dal suo canale alpha.
///
/// **E NON DICE IL NOME, che e' il vincolo della voce DC.02.** La sagoma e'
/// quasi nera e molto sfocata: si legge la massa, la postura e poco altro.
/// Che una delle tre abbia le ali e' un'informazione vera e non e' un nome,
/// ed e' esattamente il genere di cosa che un'ombra deve poter dire.
class OmbraDellAnimale extends StatelessWidget {
  const OmbraDellAnimale({
    super.key,
    required this.immagine,
    required this.quantaLuce,
    this.giaSagoma = false,
  });

  final String immagine;

  /// **SE [immagine] E' GIA' UNA SAGOMA, e non l'illustrazione a colori.**
  /// Ordine DG: i dodici file `ani_ombra_*` sono gia' neri col filo di luce,
  /// e passarli sotto il filtro che butta il colore spegnerebbe proprio quel
  /// filo. L'illustrazione a colori resta la via di ripiego.
  final bool giaSagoma;

  /// Da 0 a 1: quanta luce le arriva addosso. La muove la scena.
  final double quantaLuce;

  /// **QUANTO SFOCA L'OMBRA**, in frazione del lato corto della scena.
  ///
  /// E' l'unica difesa contro il nome: l'ombra non ha nessun velo che si
  /// scosti, e cio' che non deve dire lo nasconde la sfocatura.
  static const double quantoSfoca = 0.030;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, vincoli) {
          final lato = vincoli.biggest.shortestSide.isFinite
              ? vincoli.biggest.shortestSide
              : 320.0;
          return Stack(
            fit: StackFit.expand,
            children: [
              // **LA LUCE DIETRO, che e' cio' che rende un controluce un
              // controluce.** Senza, la sagoma scura finisce su un fondo
              // scuro e l'incontro e' uno schermo vuoto: difetto visto sul
              // telefono 767f596c il 10 settembre 2026, e costato due giri.
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.08),
                    radius: 0.45 + 0.35 * quantaLuce,
                    colors: [
                      const Color(0xFFF0DDB0)
                          .withValues(alpha: 0.34 + 0.34 * quantaLuce),
                      const Color(0xFFB08A4E).withValues(alpha: 0.10),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
              ImageFiltered(
                imageFilter: ui.ImageFilter.blur(
                  sigmaX: lato * quantoSfoca,
                  sigmaY: lato * quantoSfoca,
                  tileMode: TileMode.decal,
                ),
                child: giaSagoma
                    // **LA SAGOMA DELL'ARCHITETTO SI MOSTRA COM'E'.** Ordine
                    // DG: ha gia' il nero e il filo di luce oro sul bordo, e
                    // il filtro qui sotto glielo toglierebbe.
                    ? Image.asset(immagine,
                        key: const Key('viaggio_ombra_vera'),
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink())
                    : ColorFiltered(
                        // **`srcIn` TIENE LA FORMA E BUTTA IL COLORE**: quello
                        // che resta e' esattamente il canale alpha
                        // dell'illustrazione, cioe' la sua sagoma vera. E'
                        // la via di ripiego da quando i dodici file
                        // `ani_ombra_*` esistono.
                        colorFilter: ColorFilter.mode(
                            const Color(0xFF07040D)
                                .withValues(alpha: 0.94 - 0.10 * quantaLuce),
                            BlendMode.srcIn),
                        child: Image.asset(immagine,
                            key: const Key('viaggio_ombra_vera'),
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                                const SizedBox.shrink()),
                      ),
              ),
            ],
          );
        },
      );
}
