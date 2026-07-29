import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/arts/arti_preferite.dart';
import '../../core/maestro/maestro.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// La soglia di un'arte: il suo colore e il suo cuore, in un punto unico.
///
/// Le due cose che ogni arte deve avere stavano sparse. Il colore lo metteva la
/// tessera che apriva l'arte, quindi valeva per una strada sola; il cuore per
/// metterla fra le proprie non esisteva affatto. Qui stanno insieme, e chi
/// aggiunge un'arte domani le ottiene entrambe con una riga, senza doverselo
/// ricordare.
///
/// Prende il posto del MaestroScope nelle rotte delle arti: fa la stessa cosa,
/// piu' il cuore.
class SogliaArte extends StatelessWidget {
  const SogliaArte({
    super.key,
    required this.id,
    required this.maestro,
    required this.child,
  });

  /// L'identificativo dell'arte nel catalogo, quello che lo scaffale personale
  /// usa per ricordarsela.
  final String id;

  /// Il proprietario, che decide il colore dal primo frame.
  final Maestro maestro;

  final Widget child;

  @override
  Widget build(BuildContext context) => MaestroScope(
        maestro: maestro,
        child: ConCuore(id: id, child: child),
      );
}

/// Aggiunge il cuore delle preferite sopra un'arte, in alto a destra.
///
/// Il cuore sta DENTRO l'arte, non solo sulla bolla che la apre: si decide che
/// un'arte ci piace mentre la si usa, non prima di averla vista.
class ConCuore extends StatelessWidget {
  const ConCuore({super.key, required this.id, required this.child});

  final String id;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          top: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                  top: SpacingTokens.sm, right: SpacingTokens.sm),
              child: CuorePreferita(id: id),
            ),
          ),
        ),
      ],
    );
  }
}

/// Il cuore che mette o toglie un'arte dallo scaffale personale.
///
/// Nessun controllo di piano: i preferiti sono una comodita' di chi usa l'app,
/// non merce.
class CuorePreferita extends StatelessWidget {
  const CuorePreferita({super.key, required this.id, this.compatto = false});

  final String id;

  /// Compatto per stare sopra una bolla, pieno per stare dentro l'arte.
  final bool compatto;

  @override
  Widget build(BuildContext context) {
    final preferite = context.watch<ArtiPreferiteController?>();
    if (preferite == null) return const SizedBox.shrink();
    final dentro = preferite.contiene(id);
    final palette = MaestroScope.of(context);

    return Semantics(
      button: true,
      selected: dentro,
      label: dentro ? 'Togli dalle tue arti' : 'Aggiungi alle tue arti',
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: IconButton(
          key: Key('cuore_$id'),
          tooltip: dentro ? 'Togli dalle tue arti' : 'Aggiungi alle tue arti',
          iconSize: compatto ? 18 : 24,
          visualDensity: compatto ? VisualDensity.compact : null,
          icon: Icon(
            dentro ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: dentro ? palette.gold : palette.goldSoft,
            shadows: const [
              // Un'ombra sotto: il cuore sta sopra sfondi di ogni colore.
              Shadow(color: Colors.black54, blurRadius: 6),
            ],
          ),
          onPressed: () => mostraEsito(context, preferite.cambia(id), palette),
        ),
      ),
    );
  }

  /// Dice cosa e' successo, invece di lasciare la persona a indovinare.
  static void mostraEsito(
      BuildContext context, EsitoPreferita esito, MaestroPalette palette) {
    final testo = switch (esito) {
      EsitoPreferita.aggiunta => 'Aggiunta alle tue arti.',
      EsitoPreferita.tolta => 'Tolta dalle tue arti.',
      EsitoPreferita.ripristinata =>
        'Era l\'ultima: le tue arti sono tornate come all\'inizio.',
      EsitoPreferita.pieno =>
        'Le tue arti sono ${ArtiPreferiteController.tetto}: togline una per '
            'fare posto.',
      EsitoPreferita.sconosciuta => 'Quest\'arte non e\' ancora viva.',
    };
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        key: const Key('esito_preferita'),
        duration: const Duration(seconds: 3),
        backgroundColor: palette.surfaceElevated,
        content: Text(testo,
            style: TypographyTokens.body(size: 14)
                .copyWith(color: palette.textPrimary)),
      ));
  }
}
