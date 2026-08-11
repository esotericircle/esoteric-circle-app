import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../core/astro/natal_chart_controller.dart';
import '../../core/entitlement/question_allowance.dart';
import '../../core/sigilli/bonus_della_condivisione.dart';
import '../../core/sigilli/diario_del_cammino.dart';
import '../../core/sigilli/sentieri.dart';
import '../../services/app_services.dart';
import 'celebrazione.dart';

/// LA REGIA DEL CAMMINO, in un punto solo.
///
/// **Un gesto, una porta.** Le schermate non sanno niente di traguardi: dicono
/// soltanto "ho fatto questo", e qui si segna nel diario, si guarda cosa si e'
/// acceso, si accredita il premio sul server e si celebra nella forma giusta.
/// Se ogni schermata facesse da se', prima o poi una accenderebbe un Sigillo
/// senza premio, o lo celebrerebbe due volte.
class RegiaDelCammino {
  const RegiaDelCammino._();

  /// Da chiamare quando un gesto e' COMPIUTO, non quando una scena si apre:
  /// una scena si apre anche per sbaglio, un gesto no.
  static Future<void> dopoUnGesto(
    BuildContext context,
    String gesto, {
    String? oraRituale,
  }) async {
    final diario = context.read<DiarioDelCammino>();
    await diario.segna(gesto, oraRituale: oraRituale);
    if (!context.mounted) return;
    await guardaCosaSiAccende(context);
  }

  /// Guarda l'intero elenco e accende cio' che e' maturato. Si chiama anche
  /// all'avvio: un traguardo del cielo puo' essersi acceso mentre l'app era
  /// chiusa, e trovarlo acceso al ritorno e' proprio il punto.
  static Future<void> guardaCosaSiAccende(BuildContext context) async {
    final diario = context.read<DiarioDelCammino>();
    final carta = context.read<NatalChartController>().chart;
    final stato = diario.statoDelCammino(
      carta: carta,
      segno: carta?.sunSign,
      seriePerRito: const {},
    );
    // La porta e la borsa si prendono PRIMA dell'attesa: leggere il contesto
    // dopo un await e' il modo classico di parlare a un albero che non c'e'
    // piu'.
    final porta = context.read<AppServices>().porta;
    final borsa = context.read<QuestionAllowance>();
    final nuovi = await diario.quelliCheSiAccendono(stato);
    if (nuovi.isEmpty) return;
    for (final traguardo in nuovi) {
      final primoInAssoluto = diario.accesi.isEmpty;
      if (!await diario.accendi(traguardo.id)) continue;
      // IL PREMIO PRIMA DELLA FESTA: se il server non risponde il Sigillo
      // resta acceso lo stesso e l'accredito riparte alla prossima
      // sincronia, perche' il movimento porta il suo identificativo.
      final saldo = await PremioDelTraguardo.accredita(porta, traguardo);
      if (saldo != null) await borsa.sincronizza();
      if (!context.mounted) return;
      await Celebrazione.festeggia(
        context,
        traguardo: traguardo,
        sentiero: _sentieroDi(traguardo),
        primoInAssoluto: primoInAssoluto,
      );
      if (!context.mounted) return;
    }
  }

  static Sentiero _sentieroDi(Traguardo traguardo) {
    for (final sentiero in Sentieri.tutti) {
      if (Sentieri.di(sentiero).any((t) => t.id == traguardo.id)) {
        return sentiero;
      }
    }
    return Sentiero.costellazione;
  }
}
