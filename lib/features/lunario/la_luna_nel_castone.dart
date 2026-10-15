import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/lunario/le_lune_della_nasa.dart';

/// I nomi del calendario in italiano (FV.05): la settimana parte dal lunedi'.
abstract final class IlMeseInItaliano {
  static const List<String> mesi = [
    'Gennaio',
    'Febbraio',
    'Marzo',
    'Aprile',
    'Maggio',
    'Giugno',
    'Luglio',
    'Agosto',
    'Settembre',
    'Ottobre',
    'Novembre',
    'Dicembre',
  ];

  /// Le iniziali dei giorni, dal lunedi' alla domenica.
  static const List<String> giorni = ['Lu', 'Ma', 'Me', 'Gi', 'Ve', 'Sa', 'Do'];

  static String titolo(int anno, int mese) => '${mesi[mese - 1]} $anno';

  /// Quante caselle vuote prima del primo giorno: zero se il mese comincia
  /// di lunedi'.
  static int vuoteIniziali(int anno, int mese) =>
      DateTime(anno, mese, 1).weekday - 1;

  /// Quante righe di sette servono al mese.
  static int righe(int anno, int mese) {
    final giorni = DateTime(anno, mese + 1, 0).day;
    return ((vuoteIniziali(anno, mese) + giorni) / 7).ceil();
  }
}

/// **LA LUNA VERA DEL GIORNO NEL SUO CASTONE.** Ordine FV voci FV.03 e
/// FV.05: la fotografia della Luna scelta per elongazione
/// (`LeLuneDellaNasa.immaginePer`), ruotata di 180 gradi per chi sta
/// nell'emisfero sud, dentro il castone d'argento dipinto. Nessuna Luna
/// disegnata dal codice (R9): se la fotografia manca resta il castone vuoto.
class LaLunaNelCastone extends StatelessWidget {
  const LaLunaNelCastone({
    super.key,
    required this.elongazione,
    required this.ruota,
    required this.lato,
  });

  final double elongazione;

  /// Vero nell'emisfero sud (`LeLuneDellaNasa.ruotaPer`).
  final bool ruota;
  final double lato;

  /// Quanto del lato occupa la Luna dentro il castone: l'interno trasparente
  /// del castone dipinto sta fra il 15 e l'85 per cento del lato.
  static const double quotaDellaLuna = 0.7;

  @override
  Widget build(BuildContext context) {
    final foto = LeLuneDellaNasa.immaginePer(elongazione);
    final luna = lato * quotaDellaLuna;
    return SizedBox(
      width: lato,
      height: lato,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (foto != null)
            Transform.rotate(
              angle: ruota ? math.pi : 0,
              child: Image.asset(
                foto,
                width: luna,
                height: luna,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
                errorBuilder: (_, __, ___) => SizedBox(width: luna),
              ),
            ),
          Image.asset(
            LeLuneDellaNasa.castone,
            width: lato,
            height: lato,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
            errorBuilder: (_, __, ___) => SizedBox(width: lato),
          ),
        ],
      ),
    );
  }
}
