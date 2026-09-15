import 'package:flutter/material.dart';

import 'passaggio_del_cerchio.dart';

/// IL VELO DEL CERCHIO: fogli e dialoghi sotto la stessa legge delle rotte.
/// Ordine CF voce 09.
///
/// **La richiesta del fondatore, verbatim dall'ordine CC**: "voglio che questo
/// flash sia nero e che ci sia sempre ad ogni cambio schermata. niente deve
/// apparire di botto." E il suo fatto sulla build 2215: "avevo chiesto che
/// OGNI SCHERMATA DI FUNZIONALITA' DOVEVA APPARIRE CON UN FLASH NERO!"
///
/// **Perche' la prova dell'ordine CC era verde, ed e' il caso da manuale di
/// una prova che misura la grandezza sbagliata.** Quel censimento contava le
/// ROTTE: quarantatre `PassaggioDelCerchio.rotta` sotto la legge e due veli
/// trasparenti dichiarati fuori. Rimisurato adesso: **e' ancora vero**. Ma un
/// foglio che sale e un dialogo che appare NON sono rotte, quindi il
/// censimento non li ha mai guardati, e per la persona davanti allo schermo
/// sono cambi di schermata identici a una rotta.
///
/// **Cosa impone questa legge.** Non un lampo nero sopra un foglio, che
/// coprirebbe la schermata da cui il foglio nasce: il velo dietro il foglio e'
/// **lo stesso nero del passaggio**, alla stessa opacita' dichiarata e per la
/// stessa durata. Cosi' fra una rotta e un foglio la persona vede la stessa
/// materia, e niente arriva di colpo su un fondo estraneo.
///
/// **Il nero di Flutter non e' il nostro.** `showModalBottomSheet` mette
/// `Colors.black54`, cioe' un nero neutro: sul cosmo blu del Cerchio quel
/// grigio si vede, ed e' la ragione per cui i fogli sembravano di un'altra
/// app.
class VeloDelCerchio {
  const VeloDelCerchio._();

  /// L'opacita' del velo dietro un foglio o un dialogo.
  ///
  /// **Settantadue centesimi, e non e' un numero a caso**: e' l'opacita' con
  /// cui la barra dell'identita' vela il cosmo, quindi la stessa quantita' di
  /// buio che il Cerchio usa gia' per staccare un piano da quello sotto.
  static const double opacita = 0.72;

  /// Il colore del velo: il nero del passaggio, non quello del framework.
  static Color barriera = PassaggioDelCerchio.nero.withValues(alpha: opacita);

  /// Quanto ci mette il velo a salire, uguale al passaggio fra due schermate.
  static const Duration durata = PassaggioDelCerchio.durata;
}

/// IL FOGLIO CHE SALE, sotto la legge del velo. Ordine CF voce 09.
///
/// Sostituisce `showModalBottomSheet` in ogni punto dell'app: i parametri sono
/// quelli che l'app usa davvero, e chi ne volesse uno nuovo lo aggiunge qui,
/// dove si vede.
Future<T?> foglioDelCerchio<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
  bool isScrollControlled = false,
  bool isDismissible = true,
  bool enableDrag = true,
  ShapeBorder? shape,
  BoxConstraints? constraints,
}) {
  return showModalBottomSheet<T>(
    context: context,
    builder: builder,
    backgroundColor: backgroundColor,
    isScrollControlled: isScrollControlled,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    shape: shape,
    constraints: constraints,
    barrierColor: VeloDelCerchio.barriera,
  );
}

/// IL DIALOGO, sotto la stessa legge. Ordine CF voce 09.
Future<T?> dialogoDelCerchio<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? barrierColor,
  bool barrierDismissible = true,
}) {
  return showDialog<T>(
    context: context,
    builder: builder,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor ?? VeloDelCerchio.barriera,
  );
}

/// IL DIALOGO GENERALE, per chi costruisce la propria pagina. Ordine CF
/// voce 09.
Future<T?> dialogoGeneraleDelCerchio<T>({
  required BuildContext context,
  required RoutePageBuilder pageBuilder,
  bool barrierDismissible = false,
  String? barrierLabel,
  Color? barrierColor,
  Duration? transitionDuration,
  RouteTransitionsBuilder? transitionBuilder,
}) {
  return showGeneralDialog<T>(
    context: context,
    // **LA ROTTA SI VESTE DA SOLA, ordine CF voce 09.** Una rotta aperta
    // con `showGeneralDialog` non ha nessun `Material` sopra di se', e i
    // suoi testi ricadono sulla riga gialla di sistema: e' un difetto che
    // il progetto ha gia' incontrato, e una guardia lo sorveglia. Adesso
    // che tutti i dialoghi generali passano da qui, il `Material` si
    // mette in un punto solo invece che in ognuno.
    pageBuilder: (contesto, entra, esce) => Material(
      type: MaterialType.transparency,
      child: pageBuilder(contesto, entra, esce),
    ),
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel,
    barrierColor: barrierColor ?? VeloDelCerchio.barriera,
    transitionDuration: transitionDuration ?? VeloDelCerchio.durata,
    transitionBuilder: transitionBuilder,
  );
}
