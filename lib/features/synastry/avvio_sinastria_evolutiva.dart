import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/entitlement/entitlement_service.dart';
import '../../core/entitlement/listino_degli_eos.dart';
import '../../core/entitlement/question_allowance.dart';
import '../../core/entitlement/tier.dart';
import '../../core/identity/profile_controller.dart';
import '../../design_system/components/la_conferma_della_spesa.dart';
import '../maestri/rotta_arte.dart';
import '../pricing/upgrade_invite.dart';
import '../../core/maestro/maestro.dart';
import '../../core/synastry_evolutiva/cielo_evolutivo.dart';
import '../../core/synastry_evolutiva/le_coppie_scoperte.dart';
import '../../design_system/transizioni/passaggio_del_cerchio.dart';
import 'lo_studio_di_medora.dart';
import 'sinastria_evolutiva_screen.dart';

/// **IL PONTE VERSO LA SINASTRIA EVOLUTIVA.** Ordine FT voce FT.14.
///
/// Chi riceve il segno 15 o tocca la scheda nella home ha solo il PROPRIO
/// cielo gia' in mano (`ProfileController.identity`): il profilo pubblico
/// del Cerchio non porta la data di nascita di nessuno (ordine FT, P9), e
/// un amico che l'abbia gia' detta a voce non l'ha ancora condivisa nel
/// senso che conta per FT.03.
///
/// **NON E' PIU' UNA SCHERMATA NERA.** Ordine FY voce FY.11, 16 ottobre
/// 2026. Il fondatore: *"La sinastria evolutiva inizia con una schermata
/// nera e le funzioni social, niente altro"*. Il ponte era uno `Scaffold`
/// nero che al primo fotogramma spingeva sopra di se' la nascita dell'altra
/// persona, e la scena arrivava solo dopo. Adesso il ponte apre subito la
/// Sinastria evolutiva, con lo studio di Medora e il suo video; la nascita
/// dell'altra persona si chiede dalla scelta sotto la scena
/// ([SinastriaEvolutivaScreen.chiediLaPersona]), e qui resta il conto delle
/// coppie nuove (FT.13). Se la persona ci ripensa, resta sulla scena con la
/// scelta: nessuna lettura a meta', nessun vicolo cieco.
///
/// **LA TENDINA, ORDINE GD VOCE GD.14**: la persona si sceglie dalla tendina
/// che sale sopra la scena, e qui resta solo il conto
/// ([SinastriaEvolutivaScreen.laCoppiaSiConta]). **Una coppia gia' scoperta
/// col suo legame si rilegge senza consumare** (GD.22, [LeCoppieScoperte]);
/// la stessa persona con un altro legame e' una sinastria nuova e si conta
/// come una coppia nuova (GD.16).
class AvvioSinastriaEvolutiva extends StatelessWidget {
  const AvvioSinastriaEvolutiva({
    super.key,
    this.nomeSuggerito,
    this.fabbricaDellaScena,
  });

  /// Il nome dell'amico a cui il segno era mandato, se lo si conosce gia':
  /// non riempie la nascita (che il profilo pubblico non porta), solo il
  /// campo del nome, cosi' chi compila non lo riscrive.
  final String? nomeSuggerito;

  /// La finta del lettore video, per le prove headless.
  final FabbricaDellaScenaSinastria? fabbricaDellaScena;

  /// **LA SOGLIA UNICA DELLE ARTI**: la Sinastria evolutiva si apre col suo
  /// cuore delle preferite (guardia `tue_arti_schermata`), come prima faceva
  /// `SinastriaEvolutivaScreen.route` dopo il ponte.
  static Route<void> route(
          {String? nomeSuggerito,
          FabbricaDellaScenaSinastria? fabbricaDellaScena}) =>
      PassaggioDelCerchio.rotta(
        (_) => SogliaArte(
          id: 'synastry_depth',
          maestro: Maestro.medora,
          child: AvvioSinastriaEvolutiva(
              nomeSuggerito: nomeSuggerito,
              fabbricaDellaScena: fabbricaDellaScena),
        ),
      );

  @override
  Widget build(BuildContext context) {
    // Il proprio cielo si legge una volta: la lettura non cambia sotto gli
    // occhi se il profilo si aggiorna mentre e' aperta.
    final identitaTua =
        Provider.of<ProfileController>(context, listen: false).identity;
    return SinastriaEvolutivaScreen(
      nomeTuo: 'Tu',
      cieloTuo: CieloEvolutivo.perIdentita(identitaTua, nome: 'Tu'),
      fabbricaDellaScena: fabbricaDellaScena,
      nomeSuggerito: nomeSuggerito,
      laCoppiaSiConta: _conta,
    );
  }

  Future<bool> _conta(
      BuildContext context, SceltaDellaSinastria scelta) async {
    // **LA COPPIA GIA' SCOPERTA SI RILEGGE SENZA CONSUMARE**, ordine GD voce
    // GD.22: stessa persona, stesso cielo, stesso legame.
    final impronta =
        LeCoppieScoperte.impronta(scelta.nome, scelta.cielo, scelta.legame);
    if (await LeCoppieScoperte.giaScoperta(impronta)) return true;
    if (!context.mounted) return false;
    // **LA COPPIA NUOVA SI CONTA**, ordine FT voce FT.13, e si conta qui,
    // alla prima lettura. Finche' il server non porta il budget nel listino
    // non si conta niente (`QuestionAllowance.contaLeSinastrieEvolutive`).
    final borsa = _forse<QuestionAllowance>(context);
    final tier = _forse<EntitlementService>(context)?.tier ?? Tier.free;
    if (borsa != null && !borsa.puoiLeggereUnaCoppiaNuova(tier)) {
      await _leCoppieDiOggiSonoFinite(context, borsa);
      if (!context.mounted) return false;
      if (!borsa.puoiLeggereUnaCoppiaNuova(tier)) return false;
    }
    borsa?.registraSinastriaEvolutiva(tier);
    await LeCoppieScoperte.segna(impronta);
    return true;
  }

  /// **MAI UN VICOLO CIECO**: le coppie nuove del giorno finite aprono
  /// l'invito con le due strade, una lettura in piu' a Eos (prezzo dal
  /// listino del server, detto prima del gesto) oppure salire di piano.
  Future<void> _leCoppieDiOggiSonoFinite(
      BuildContext context, QuestionAllowance borsa) async {
    final prezzo =
        borsa.prezzoDelRiscatto(QuestionAllowance.kSinastrieEvolutive);
    await showUpgradeInvite(
      context,
      title: 'Le coppie nuove di oggi sono finite',
      message: 'Domani se ne apre una nuova. Oppure leggi questa subito, o '
          'sali di piano per leggerne di più ogni giorno.',
      riscattoLabel: prezzo == null
          ? null
          : '${ListinoDegliEos.sinastriaEvolutivaInPiu.nome}, '
              '${ListinoDegliEos.prezzo(prezzo)}',
      onRiscatta: prezzo == null
          ? null
          : () async {
              final consenso =
                  await LaConfermaDellaSpesa.degliEos(context, costo: prezzo);
              if (consenso == null || !context.mounted) return;
              await borsa.riscatta(QuestionAllowance.kSinastrieEvolutive,
                  consenso: consenso);
            },
    );
  }

  T? _forse<T>(BuildContext context) {
    try {
      return context.read<T>();
    } catch (senzaProvider) {
      debugPrint('Sinastria evolutiva: manca $T, ripiego ($senzaProvider)');
      return null;
    }
  }
}
