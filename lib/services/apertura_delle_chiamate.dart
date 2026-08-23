import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/astro/zodiac.dart';
import '../core/identity/profile_controller.dart';
import '../core/rituals/avvisi_del_rito.dart';
import '../core/rituals/daily_elements.dart';
import '../features/horoscope/oroscopo_screen.dart';
import '../features/maestri/caligo/rune/rune_draw_screen.dart';
import '../features/rituals/sunset_rune_screen.dart';
import '../features/santuario/daily_strip.dart';

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
    // **I CINQUE DONI, e ognuno apre il suo rito.** Ordine BC voce 05.
    //
    // Il carico di un Dono e' `dono:nome`, e la rotta la sa gia'
    // `dailyElementRoute`, che e' l'unico posto che lega un Dono alla sua
    // schermata: qui non si riscrive quella mappa, si chiede a lei.
    if (carico.startsWith('dono:')) {
      final nome = carico.substring(5);
      for (final d in DailyElement.values) {
        if (d.name == nome) return dailyElementRoute(d);
      }
      // Un Dono che non esiste piu' non apre niente, come ogni carico
      // sconosciuto: mai un crash per un avviso vecchio.
      return null;
    }
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
