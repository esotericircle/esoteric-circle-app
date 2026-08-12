import 'package:flutter/material.dart';

import '../../core/maestro/maestro.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../services/app_services.dart';
import '../shell/vie_del_cerchio.dart';
import 'maestro_screen.dart';
import 'widgets/domain_pillars.dart';
import '../../design_system/components/borsellino.dart';
import 'rotta_arte.dart';

/// Il dominio di un Maestro, come route spinta sopra il Santuario.
///
/// E' l'hub minimo: l'ingresso Parla con il Maestro verso la chat, piu' le
/// funzioni del dominio nei loro stati. Ha la sua freccia Indietro che torna al
/// Santuario, nessuna bottom bar, cosi' resta superficie immersiva. Dalla chat,
/// Indietro torna qui; da qui, Indietro torna al Santuario.
class DomainScreen extends StatelessWidget {
  const DomainScreen({super.key, required this.maestro});

  final Maestro maestro;

  static Route<void> route({
    required Maestro maestro,
    required AppServices services,
  }) {
    return MaterialPageRoute<void>(
      // LA ROTTA DICHIARA LA PROPRIA DESTINAZIONE, rotta piu' argomento.
      //
      // E' il dato su cui la barra decide se TORNARE a una stanza gia' aperta
      // o aprirne una nuova. Sta QUI, nella fabbrica, e non in chi spinge:
      // cosi' ogni porta che apre un dominio, barra, Santuario o guscio, la
      // dichiara senza doverlo sapere. Il perche' un nome o un tipo non
      // bastano sta scritto su DestinazioneDominio.
      settings: RouteSettings(arguments: DestinazioneDominio(maestro)),
      // LA ROTTA DICHIARA ANCHE IL PROPRIETARIO, ordine 2163 voce 6: senza
      // `maestro:` lo scope seguiva il controller, e la barra dentro il
      // dominio non sapeva di chi fosse la stanza (voce spenta, colore
      // della provenienza). E' la stessa dichiarazione che la chat fa gia'.
      builder: (_) => MaestroScope(
          maestro: maestro, child: DomainScreen(maestro: maestro)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: palette.deepest.withValues(alpha: 0.35),
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: palette.goldSoft),
        automaticallyImplyLeading: false,
        // Il nome del Maestro e, come seconda riga, i tre pilastri del suo
        // dominio: si sa di che cosa e' fatto prima ancora di scorrere.
        //
        // La colonna e' centrata sulla larghezza della SCHERMATA, non sullo
        // spazio che avanza accanto alla freccia: per questo la freccia non e'
        // un `leading` ma sta dentro il titolo, sovrapposta a sinistra, e il
        // titolo occupa tutta la barra (`titleSpacing` a zero). Cosi' il nome
        // resta esattamente al centro in tutti e tre i domini.
        toolbarHeight: 74,
        titleSpacing: 0,
        title: SizedBox(
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(maestro.displayName,
                      textAlign: TextAlign.center,
                      style: TypographyTokens.display(size: 20)),
                  const SizedBox(height: 2),
                  DomainPillars(maestro: maestro),
                ],
              ),
              Positioned(
                left: 0,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  tooltip: 'Indietro',
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
              // IL BORSELLINO, ordine S voce 06, e sta NELLO STACK e non
              // fra le azioni: qui il titolo occupa tutta la barra per
              // tenere il nome del Maestro esattamente al centro in tutti e
              // tre i domini, e un'azione vera glielo sposterebbe. Cosi' il
              // segno resta nello stesso angolo delle altre schermate senza
              // toccare la centratura.
              const Positioned(right: 0, child: AngoloDellaBarra()),
            ],
          ),
        ),
      ),
      // Cosmo senza costellazioni anche qui: superficie calma, nessun
      // rettangolo a portale dietro l'header.
      body: CosmosBackground(
        seed: 12,
        showZodiac: false,
        child: MaestroScreen(maestro: maestro),
      ),
    );
  }
}
