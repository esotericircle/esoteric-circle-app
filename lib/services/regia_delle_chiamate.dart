import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../core/astro/sunset_time.dart';
import '../core/entitlement/entitlement_service.dart';
import '../core/entitlement/question_allowance.dart';
import '../core/horoscope/cielo_di_oggi.dart';
import '../core/horoscope/corrente_del_cielo.dart';
import '../core/identity/natal_identity.dart';
import '../core/rituals/avvisi_del_rito.dart';
import 'avvisi_locali.dart';

/// LA REGIA DELLE CHIAMATE DEL GIORNO, in un punto solo. Ordine M voce 2.
///
/// Chi ha bisogno di riprogrammare le chiamate passa da qui: l'app all'avvio,
/// e l'Estrazione Rune quando l'ultima gettata del giorno si consuma. Due
/// chiamanti, una regia, cosi' i dati (carta, gettate, tramonto) si leggono
/// sempre allo stesso modo e la porta `programmaLeChiamateDelGiorno` resta
/// l'unica che decide cosa parte davvero.
class RegiaDelleChiamate {
  const RegiaDelleChiamate._();

  /// Riprogramma le chiamate coi dati veri del momento. Legge i provider dal
  /// contesto, quindi va chiamata quando l'albero e' vivo. Il `servizio` si
  /// inietta solo nelle prove: l'app vera usa `avvisiDelCerchio`.
  static Future<List<int>> riprogramma(
    BuildContext context, {
    ServizioAvvisi? servizio,
  }) async {
    final porta = servizio ?? avvisiDelCerchio;
    // Il permesso si guarda PRIMA di toccare i provider: senza permesso non
    // parte niente, e chi monta una scena senza tutto l'albero (le prove)
    // non paga letture che non servono. La porta lo ricontrolla comunque.
    if (!porta.disponibile || !await porta.permessoConcesso()) {
      return const [];
    }
    if (!context.mounted) return const [];
    final carta = context.read<BirthIdentityController>().cartaCompleta;
    final borsa = context.read<QuestionAllowance>();
    final piano = context.read<EntitlementService>().tier;
    final adesso = DateTime.now();
    final domani = adesso.add(const Duration(days: 1));
    // Il fatto del mattino parla del cielo di DOMANI, perche' l'avviso suona
    // domani all'alba: un fatto di oggi sarebbe gia' vecchio.
    final cielo = CieloDiOggi.perIlGiorno(adesso: domani, carta: carta);
    return AvvisiDelRito.programmaLeChiamateDelGiorno(
      servizio: porta,
      adesso: adesso,
      // Senza la scena del tramonto aperta non c'e' un'ora vera: si usa
      // l'ora media, la stessa del ripiego di tutta l'app.
      tramonto: SunsetTime.oraMedia(adesso),
      tramontoDiDomani: SunsetTime.oraMedia(domani),
      fattoDiDomani: CorrenteDelCielo.fattoDelGiorno(cielo),
      gettateEsaurite: borsa.gettateRimaste(piano) == 0,
    );
  }
}
