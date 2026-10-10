import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import 'navigation_controller.dart';

/// IL TASTO INDIETRO DELLA HOME. Ordine FD voce 04.
///
/// **Il difetto, misurato.** La home e' la rotta 0 e non aveva nessun
/// `PopScope`: quando sopra non restava niente da sfilare, Android chiudeva
/// l'attivita' al primo tocco, e nel giro sul Realme dell'ordine FC quattro
/// pressioni partite dall'oroscopo di un'amica hanno portato fuori dall'app.
/// Dal Cosmic Passport si usciva al primo tocco, perche' il Passport non e'
/// una rotta ma una vista del guscio. Padre: PROVENIENZA IGNOTA, la home non
/// ha mai avuto una regola per il tasto indietro.
///
/// **La regola.** Dentro le rotte spinte sopra la home il tasto indietro
/// sfila la rotta, come sempre: questo widget sta dentro la rotta 0 e non le
/// tocca. Sulla home:
/// - dal Passport torna al Cerchio;
/// - dal Cerchio il primo tocco mostra [avviso] per [finestra] e non esce;
///   solo un secondo tocco dentro la finestra esce dall'app.
///
/// **E' l'unico punto di `lib` che chiude l'app**, e la guardia
/// `il_tasto_indietro_non_esce_dall_app_test.dart` lo pretende.
class IlTastoIndietroDellaHome extends StatefulWidget {
  const IlTastoIndietroDellaHome({super.key, required this.child, this.adesso});

  final Widget child;

  /// L'orologio, sostituibile nelle prove.
  final DateTime Function()? adesso;

  /// Il testo dell'avviso, alla lettera dell'ordine FD.
  static const String avviso = 'Premi di nuovo per uscire.';

  /// Quanto resta l'avviso, ed entro quanto il secondo tocco esce.
  static const Duration finestra = Duration(seconds: 2);

  @override
  State<IlTastoIndietroDellaHome> createState() =>
      _IlTastoIndietroDellaHomeState();
}

class _IlTastoIndietroDellaHomeState extends State<IlTastoIndietroDellaHome> {
  DateTime? _primoTocco;
  bool _avvisoAcceso = false;
  Timer? _spegni;

  DateTime _ora() => (widget.adesso ?? DateTime.now)();

  void _indietro() {
    final nav = context.read<NavigationController>();
    if (nav.view == ShellView.passport) {
      nav.goToSantuario();
      return;
    }
    final ora = _ora();
    final primo = _primoTocco;
    if (primo != null &&
        ora.difference(primo) <= IlTastoIndietroDellaHome.finestra) {
      _primoTocco = null;
      SystemNavigator.pop();
      return;
    }
    _primoTocco = ora;
    setState(() => _avvisoAcceso = true);
    _spegni?.cancel();
    _spegni = Timer(IlTastoIndietroDellaHome.finestra, () {
      if (mounted) setState(() => _avvisoAcceso = false);
    });
  }

  @override
  void dispose() {
    _spegni?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Il fondo vero: la barra del Cerchio, che sta sopra il Navigator, si
    // aggiunge al padding basso, cosi' l'avviso le sta sopra e non sotto.
    final fondo = MediaQuery.paddingOf(context).bottom;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _indietro();
      },
      child: Stack(
        children: [
          Positioned.fill(child: widget.child),
          Positioned(
            left: 24,
            right: 24,
            bottom: fondo + 16,
            // Sta sopra lo Scaffold, fuori dal suo Material: senza questo il
            // testo prende la sottolineatura gialla dei testi senza Material
            // (vista nell'anteprima dell'ordine FD).
            child: IgnorePointer(
              child: Material(
                type: MaterialType.transparency,
                child: AnimatedOpacity(
                  opacity: _avvisoAcceso ? 1 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: Center(
                    child: Container(
                      key: const Key('home_avviso_uscita'),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color:
                            ColorTokens.neutralDeepest.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                            color: ColorTokens.gold.withValues(alpha: 0.55)),
                      ),
                      child: Text(
                        _avvisoAcceso ? IlTastoIndietroDellaHome.avviso : '',
                        textAlign: TextAlign.center,
                        style: TypographyTokens.corpo()
                            .copyWith(color: ColorTokens.textPrimary),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
