import 'package:flutter/widgets.dart';

/// Cio' che la guardia sa fermare. Il motore vero lo implementa, le prove lo
/// sostituiscono senza toccare la piattaforma.
abstract interface class MotoreSonoro {
  /// Ferma ogni suono in corso.
  Future<void> fermaTutto();

  /// Riprende, se qualcuno lo chiede. La guardia non lo chiama mai da sola.
  Future<void> riprendi();
}

/// LA GUARDIA DEL SUONO: un punto solo che spegne l'audio quando l'app se ne va.
///
/// **Perche' esiste, e perche' sta qui e non nella Meditazione.** Avviata la
/// Meditazione col suono, cambiando funzione o tornando alla home o mandando
/// l'app in secondo piano il suono restava acceso. Il tono suona in ciclo
/// continuo, quindi restava acceso per sempre. In tutto il progetto non
/// esisteva un solo osservatore del ciclo di vita: non e' che l'audio si
/// fermasse male, e' che nessuno gli diceva mai di fermarsi.
///
/// **Le porte sono tutte le schermate che suonano**, oggi due e domani dieci.
/// Per questo il governo sta nel guscio dell'app e non dentro una schermata: una
/// regola messa in una schermata vale per quella schermata soltanto, ed e' la
/// famiglia di difetto che questo progetto ha gia' incontrato sette volte.
///
/// **Al ritorno il suono NON riparte da solo.** Chi rientra nell'app non ha
/// chiesto di risentire un tono che stava suonando mezz'ora prima: se lo vuole,
/// lo riavvia. Ripartire da soli sarebbe la stessa mancanza di rispetto del non
/// fermarsi, al contrario.
class GuardiaDelSuono with WidgetsBindingObserver {
  GuardiaDelSuono({required this.motore});

  final MotoreSonoro motore;

  /// Comincia a sorvegliare il ciclo di vita dell'app.
  void avvia() => WidgetsBinding.instance.addObserver(this);

  void dispose() => WidgetsBinding.instance.removeObserver(this);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) =>
      cambioStato(state);

  /// Il passaggio di stato, esposto perche' le prove possano provocarlo senza
  /// simulare la piattaforma.
  void cambioStato(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        // Anche su `inactive`, non solo su `paused`: una telefonata in arrivo o
        // il centro di controllo aperto tolgono il primo piano senza mettere in
        // pausa, e il suono continuerebbe sopra la chiamata.
        motore.fermaTutto();
      case AppLifecycleState.resumed:
        // Di proposito nulla: il suono non riparte da solo.
        break;
    }
  }
}
