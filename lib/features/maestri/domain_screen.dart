import 'package:flutter/material.dart';

import '../../core/maestro/maestro.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../services/app_services.dart';
import '../shell/vie_del_cerchio.dart';
import 'maestro_screen.dart';
import 'widgets/domain_pillars.dart';
import 'rotta_arte.dart';
import '../../design_system/transizioni/passaggio_del_cerchio.dart';

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
    return PassaggioDelCerchio.rotta<void>(
        // LA ROTTA DICHIARA LA PROPRIA DESTINAZIONE, rotta piu' argomento.
        //
        // E' il dato su cui la barra decide se TORNARE a una stanza gia' aperta
        // o aprirne una nuova. Sta QUI, nella fabbrica, e non in chi spinge:
        // cosi' ogni porta che apre un dominio, barra, Santuario o guscio, la
        // dichiara senza doverlo sapere. Il perche' un nome o un tipo non
        // bastano sta scritto su DestinazioneDominio.

        // LA ROTTA DICHIARA ANCHE IL PROPRIETARIO, ordine 2163 voce 6: senza
        // `maestro:` lo scope seguiva il controller, e la barra dentro il
        // dominio non sapeva di chi fosse la stanza (voce spenta, colore
        // della provenienza). E' la stessa dichiarazione che la chat fa gia'.
        (_) => MaestroScope(
            maestro: maestro, child: DomainScreen(maestro: maestro)),
        settings: RouteSettings(arguments: DestinazioneDominio(maestro)));
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
        // **LA TESTATA HA DUE CAPI E UN CENTRO PROTETTO, ordine AI voce 02.**
        // Qui c'era uno Stack col titolo centrato sull'intera larghezza e il
        // saldo sovrapposto a destra: con mille Eos il numero entrava nei
        // sottotitoli, ed e' il difetto fotografato da Mauro. Adesso e' una
        // AppBar normale: la freccia e la porta dell'account al capo
        // sinistro, la pillola al capo destro, e il titolo VINCOLATO dallo
        // spazio fra i due per costruzione, quindi non puo' toccare nessuno
        // dei capi. La centratura perfetta sull'intera larghezza si perde di
        // pochi punti, uguali nei tre domini: la protezione vale la deriva.
        toolbarHeight: 88,
        titleSpacing: 0,
        centerTitle: true,
        // **LA PORTA NON VIVE PIU' QUI, ordine AL voce 08**: il volto sta
        // nella capsula dell'identita', sopra il Navigator.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Indietro',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(maestro.displayName,
                textAlign: TextAlign.center,
                style: TypographyTokens.titoloDiSchermata()),
            const SizedBox(height: 2),
            DomainPillars(maestro: maestro),
          ],
        ),
        // IL BORSELLINO, ordine S voce 06, oggi PILLOLA dell'ordine AI: al
        // capo destro, fra le azioni come in ogni altra testata.
        actions: const [AngoloDellaBarra()],
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
