import 'package:flutter/material.dart';

import '../../../../core/rituals/animal_catalog.dart';

/// **LA GIRANDOLA DEI DODICI, E UNO SOLO SCENDERA' CON TE.**
/// Ordine DC voce 21, 10 settembre 2026.
///
/// **DA DOVE NASCE.** Il fondatore, davanti alla soglia fatta di solo testo:
/// *"sfrutta magari gli asset grafici che hai gia': una girandola anteprima
/// di immagini degli animali, ma solo uno sara' il compagno dell'utente"*.
///
/// **I DODICI TOTEM ESISTONO GIA' E NESSUNO LI GUARDAVA.** Sono in
/// `assets/img_thumb/animali`, dodici file, Total Metal bronzo, oro e rosso
/// con le spirali celtiche e l'alpha vero. Fino a oggi si vedevano **soltanto
/// dopo** aver conosciuto il proprio animale: la porta piu' bella del dominio
/// di Caligo si apriva a chi era gia' arrivato.
///
/// **E NON RIVELA NIENTE, che e' la parte difficile.** La voce DC.02 vieta di
/// dire il nome prima della quarta discesa, e mostrarli tutti e dodici
/// **non lo dice**: dice che sono dodici. Passano **in ombra**, senza nome
/// sotto, senza che nessuno si fermi al centro e senza che si possano
/// toccare. **Non e' un elenco da cui si sceglie, e' una compagnia che
/// aspetta.**
///
/// **IL MOVIMENTO E' LENTO APPOSTA.** Sessanta secondi per il giro intero:
/// piu' veloce diventerebbe un carosello pubblicitario, e questa e' una
/// processione. **Con Riduci Movimento non si muove affatto**, e restano
/// fermi in fila: la regola di casa vale anche quando il movimento e' bello.
class GirandolaDegliAnimali extends StatefulWidget {
  const GirandolaDegliAnimali({
    super.key,
    required this.altezza,
    this.senzaMoto,
  });

  /// L'altezza della fila, che decide anche quanto e' grande un totem.
  final double altezza;

  /// Iniettabile per le prove. Quando e' nullo lo chiede a `MediaQuery`.
  final bool? senzaMoto;

  /// **QUANTO DURA UN GIRO INTERO.**
  static const Duration quantoDuraUnGiro = Duration(seconds: 60);

  /// **QUANTI TOTEM ESISTONO**, e la guardia lo confronta col catalogo: se un
  /// giorno ne arrivasse un tredicesimo senza che nessuno tocchi questa
  /// schermata, la fila lo porterebbe da sola.
  static int quantiSonoDavvero() => AnimalCatalog.animals.length;

  @override
  State<GirandolaDegliAnimali> createState() => _GirandolaDegliAnimaliState();
}

class _GirandolaDegliAnimaliState extends State<GirandolaDegliAnimali>
    with SingleTickerProviderStateMixin {
  late final AnimationController _giro = AnimationController(
    vsync: this,
    duration: GirandolaDegliAnimali.quantoDuraUnGiro,
  );

  @override
  void dispose() {
    _giro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fermo =
        widget.senzaMoto ?? MediaQuery.of(context).disableAnimations;
    if (fermo) {
      if (_giro.isAnimating) _giro.stop();
    } else if (!_giro.isAnimating) {
      _giro.repeat();
    }
    const animali = AnimalCatalog.animals;
    final lato = widget.altezza;
    final passo = lato * 0.86;
    return SizedBox(
      height: lato,
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _giro,
          builder: (context, _) {
            final scorso = fermo ? 0.0 : _giro.value * passo * animali.length;
            return OverflowBox(
              maxWidth: double.infinity,
              alignment: Alignment.centerLeft,
              child: Transform.translate(
                offset: Offset(-scorso, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // **DUE VOLTE LA FILA**, cosi' quando la prima e' uscita
                    // la seconda e' gia' al suo posto e il giro non ha un
                    // salto. Con Riduci Movimento la seconda non si vede mai.
                    for (var i = 0; i < animali.length * 2; i++)
                      _unTotem(animali[i % animali.length], passo, lato),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _unTotem(GuideAnimal a, double passo, double lato) => SizedBox(
        width: passo,
        height: lato,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: lato * 0.05),
          child: Opacity(
            // **IN OMBRA, e non per pudore.** In piena luce sarebbero dodici
            // figurine da catalogo, e la voce DC.02 dice che il nome si
            // conquista: se si vedessero bene, chi guarda comincerebbe a
            // sceglierne uno con gli occhi.
            opacity: 0.52,
            child: ColorFiltered(
              colorFilter: const ColorFilter.mode(
                  Color(0xFF9C7B4A), BlendMode.modulate),
              child: Image.asset(
                a.thumbPath,
                fit: BoxFit.contain,
                // **UN TOTEM CHE NON ARRIVA NON BUCA LA FILA.** Ordine CD:
                // un asset che manca e' un caso, non una schermata rotta.
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      );
}
