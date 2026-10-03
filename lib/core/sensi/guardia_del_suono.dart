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
/// **AL RITORNO LA MUSICA RIPARTE, ordine CW voce 01, 7 settembre 2026.**
///
/// Qui c'era scritto il contrario, ed era una decisione che avevo preso io
/// nell'ordine CT quando la voce me lo lasciava scegliere: *"al ritorno non
/// riparte niente da solo"*. **Il fondatore l'ha ribaltata**, e la regola
/// adesso e' che la musica riprende da sola dal punto in cui si era fermata.
///
/// **Cio' che si ricorda e' "stava suonando quando siamo usciti", non "esiste
/// una traccia per questa schermata".** La differenza e' tutto il vincolo
/// dell'ordine: chi era in una schermata muta non deve sentire musica al
/// ritorno, e chi aveva spento la musica dalle impostazioni nemmeno. Una sola
/// domanda al momento di uscire copre tutti e due i casi, perche' in nessuno
/// dei due la musica stava suonando.
///
/// **Il tono e gli effetti no.** Un tono di Meditazione lasciato a meta'
/// mezz'ora fa non e' un luogo dove si torna, e un effetto e' la risposta a un
/// gesto che nessuno sta piu' facendo.
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
        // **AL RITORNO SI CHIEDE LA RIPRESA, ordine CW voce 01.** Qui c'era
        // "di proposito nulla", che era la decisione che avevo preso io con
        // l'ordine CT: il fondatore l'ha ribaltata.
        //
        // **La guardia non sa se qualcosa stava suonando, e non deve
        // saperlo.** Chiede la ripresa sempre, e il motore riprende solo cio'
        // che aveva sospeso lui: chi era in una schermata muta e chi aveva
        // spento la musica dalle impostazioni non avevano musica in corso,
        // quindi per loro questa chiamata non fa niente. Tenere quello stato
        // qui vorrebbe dire due posti che ricordano la stessa cosa.
        motore.riprendi();
    }
  }
}
