import 'package:flutter/material.dart';

import 'scroll_reveal.dart';

/// LA FRECCETTA CHE RUOTA per dire aperto o chiuso.
///
/// **Stava dentro il dominio, privata.** Dal 3 agosto 2026 anche la chat
/// raccoglie le risposte gia' lette, e due copie della stessa animazione sono
/// due porte alla stessa regola: basta che una delle due dimentichi Riduci
/// Movimento perche' l'app si comporti in due modi diversi sulla stessa cosa.
/// Qui c'e' una copia sola, e chi la usa la usa uguale.
///
/// Con movimento spento cambia verso all'istante, senza rotazione: si toglie il
/// moto, mai l'informazione.
class FreccettaDelCollasso extends StatelessWidget {
  const FreccettaDelCollasso({
    super.key,
    required this.aperto,
    required this.color,
    this.size = 22,
  });

  final bool aperto;
  final Color color;
  final double size;

  /// Mezzo giro, non un quarto: aperto e chiuso sono opposti, e mezzo giro e'
  /// l'unico angolo che non lascia dubbi su quale dei due sia.
  static const double giroDellaFreccetta = 0.5;

  @override
  Widget build(BuildContext context) {
    final immobile = ScrollReveal.motionOff(context);
    return AnimatedRotation(
      turns: aperto ? giroDellaFreccetta : 0,
      duration: immobile ? Duration.zero : const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      child: Icon(Icons.expand_more_rounded, size: size, color: color),
    );
  }
}

/// Il contenuto che si apre e si chiude.
///
/// L'apertura e' breve; con Riduci Movimento di sistema o con Quality Tier
/// basso non c'e' animazione, il gruppo appare e sparisce all'istante. La
/// regola e' quella di [ScrollReveal.motionOff], letta da un punto solo.
class Collassabile extends StatelessWidget {
  const Collassabile({
    super.key,
    required this.aperto,
    required this.child,
  });

  final bool aperto;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // A movimento spento non si mette nemmeno in mezzo il riquadro animato: il
    // gruppo c'e' o non c'e', senza nessuna misura da interpolare.
    if (ScrollReveal.motionOff(context)) {
      return aperto ? child : const SizedBox.shrink();
    }
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child:
          aperto ? child : const SizedBox(width: double.infinity, height: 0),
    );
  }
}
