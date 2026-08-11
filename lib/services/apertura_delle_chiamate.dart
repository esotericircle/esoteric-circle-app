import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/astro/zodiac.dart';
import '../core/identity/profile_controller.dart';
import '../core/rituals/avvisi_del_rito.dart';
import '../features/horoscope/oroscopo_screen.dart';
import '../features/maestri/caligo/rune/rune_draw_screen.dart';
import '../features/rituals/sunset_rune_screen.dart';

/// OGNI AVVISO APRE LA SCENA CHE PROMETTE, mai la home. Ordine M voce 2f.
///
/// Il carico dell'avviso toccato arriva qui, e qui c'e' l'UNICA mappa fra i
/// carichi e le scene: la Runa del Tramonto apre il tramonto, l'oroscopo apre
/// l'oroscopo, le gettate aprono l'Estrazione Rune. Un carico sconosciuto non
/// apre niente, che e' comunque la home dove l'app si trova: mai un crash per
/// un avviso vecchio.
class AperturaDelleChiamate {
  const AperturaDelleChiamate._();

  /// La rotta per un carico, costruita col contesto vivo (serve il profilo
  /// per il segno dell'oroscopo). Nulla se il carico non e' riconosciuto.
  static Route<void>? rottaPer(String carico, BuildContext context) {
    switch (carico) {
      case AvvisiDelRito.caricoTramonto:
        final nascita = context.read<ProfileController>().identity.birthDate;
        return SunsetRuneScreen.route(dataNascita: nascita);
      case AvvisiDelRito.caricoOroscopo:
        final segno = context.read<ProfileController>().identity.sunSign ??
            Zodiac.fromDate(DateTime.now());
        return OroscopoScreen.route(userSign: segno);
      case AvvisiDelRito.caricoGettate:
        final profilo = context.read<ProfileController>();
        final segno = profilo.identity.sunSign ?? Zodiac.fromDate(DateTime.now());
        return RuneDrawScreen.route(
            userSign: segno, userBirth: profilo.identity.birthDate);
      default:
        return null;
    }
  }
}
