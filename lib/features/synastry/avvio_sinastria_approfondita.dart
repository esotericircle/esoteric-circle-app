import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/entitlement/entitlement_service.dart';
import '../../core/entitlement/listino_degli_eos.dart';
import '../../core/entitlement/question_allowance.dart';
import '../../core/entitlement/tier.dart';
import '../../core/identity/profile_controller.dart';
import '../../design_system/components/la_conferma_della_spesa.dart';
import '../pricing/upgrade_invite.dart';
import '../../core/maestro/maestro.dart';
import '../../core/synastry_approfondita/cielo_approfondito.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/transizioni/passaggio_del_cerchio.dart';
import 'la_nascita_dell_altra_persona.dart';
import 'sinastria_approfondita_screen.dart';

/// **IL PONTE VERSO LA SINASTRIA APPROFONDITA.** Ordine FT voce FT.14.
///
/// Chi riceve il segno 15 o tocca la scheda nella home ha solo il PROPRIO
/// cielo gia' in mano (`ProfileController.identity`): il profilo pubblico
/// del Cerchio non porta la data di nascita di nessuno (ordine FT, P9), e
/// un amico che l'abbia gia' detta a voce non l'ha ancora condivisa nel
/// senso che conta per FT.03. Questo schermo chiede subito la nascita
/// dell'altra persona (per ora la sola strada a mano, FT.03: la lettura a
/// due telefoni resta aperta, il server e' pronto, l'interfaccia no, vedi
/// il rapporto) e poi apre la lettura vera. Se la persona torna indietro
/// prima di darla, non succede niente: nessuna lettura a meta'.
class AvvioSinastriaApprofondita extends StatefulWidget {
  const AvvioSinastriaApprofondita({super.key, this.nomeSuggerito});

  /// Il nome dell'amico a cui il segno era mandato, se lo si conosce gia':
  /// non riempie la nascita (che il profilo pubblico non porta), solo il
  /// campo del nome, cosi' chi compila non lo riscrive.
  final String? nomeSuggerito;

  static Route<void> route({String? nomeSuggerito}) =>
      PassaggioDelCerchio.rotta(
        (_) => AvvioSinastriaApprofondita(nomeSuggerito: nomeSuggerito),
      );

  @override
  State<AvvioSinastriaApprofondita> createState() =>
      _AvvioSinastriaApprofonditaState();
}

class _AvvioSinastriaApprofonditaState
    extends State<AvvioSinastriaApprofondita> {
  bool _avviato = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_avviato) return;
    _avviato = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _avvia());
  }

  Future<void> _avvia() async {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
    final identitaTua = context.read<ProfileController>().identity;
    final cieloTuo = CieloApprofondito.perIdentita(identitaTua, nome: 'Tu');

    final altra = await LaNascitaDellAltraPersona.chiedi(context, palette,
        nomeIniziale: widget.nomeSuggerito);
    if (!mounted) return;
    if (altra == null) {
      Navigator.of(context).maybePop();
      return;
    }
    // **LA COPPIA NUOVA SI CONTA**, ordine FT voce FT.13, e si conta qui,
    // alla prima lettura: chi riapre dal Diario rilegge cio' che ha gia'
    // avuto. Finche' il server non porta il budget nel listino non si conta
    // niente (`QuestionAllowance.contaLeSinastrieApprofondite`).
    final borsa = _forse<QuestionAllowance>();
    final tier = _forse<EntitlementService>()?.tier ?? Tier.free;
    if (borsa != null && !borsa.puoiLeggereUnaCoppiaNuova(tier)) {
      await _leCoppieDiOggiSonoFinite(borsa);
      if (!mounted) return;
      if (!borsa.puoiLeggereUnaCoppiaNuova(tier)) {
        Navigator.of(context).maybePop();
        return;
      }
    }
    borsa?.registraSinastriaApprofondita(tier);
    Navigator.of(context).pushReplacement(SinastriaApprofonditaScreen.route(
      nomeTuo: 'Tu',
      cieloTuo: cieloTuo,
      nomeSuo: altra.nome,
      cieloSuo: altra.cielo,
    ));
  }

  /// **MAI UN VICOLO CIECO**: le coppie nuove del giorno finite aprono
  /// l'invito con le due strade, una lettura in piu' a Eos (prezzo dal
  /// listino del server, detto prima del gesto) oppure salire di piano.
  Future<void> _leCoppieDiOggiSonoFinite(QuestionAllowance borsa) async {
    final prezzo =
        borsa.prezzoDelRiscatto(QuestionAllowance.kSinastrieApprofondite);
    await showUpgradeInvite(
      context,
      title: 'Le coppie nuove di oggi sono finite',
      message: 'Domani se ne apre una nuova. Oppure leggi questa subito, o '
          'sali di piano per leggerne di più ogni giorno.',
      riscattoLabel: prezzo == null
          ? null
          : '${ListinoDegliEos.sinastriaApprofonditaInPiu.nome}, '
              '${ListinoDegliEos.prezzo(prezzo)}',
      onRiscatta: prezzo == null
          ? null
          : () async {
              final consenso =
                  await LaConfermaDellaSpesa.degliEos(context, costo: prezzo);
              if (consenso == null || !mounted) return;
              await borsa.riscatta(QuestionAllowance.kSinastrieApprofondite,
                  consenso: consenso);
            },
    );
  }

  T? _forse<T>() {
    try {
      return context.read<T>();
    } catch (senzaProvider) {
      debugPrint('Sinastria approfondita: manca $T, ripiego ($senzaProvider)');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Il nero del passaggio mentre si apre il modulo della nascita: lo
    // stesso colore della legge unica delle rotte, nessun lampo.
    return const Scaffold(backgroundColor: PassaggioDelCerchio.nero);
  }
}
