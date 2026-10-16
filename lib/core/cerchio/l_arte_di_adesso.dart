import 'package:flutter/widgets.dart';

/// **L'ARTE CHE LA PERSONA STA USANDO, ordine EY voce 08 punto 6.**
///
/// Si scrive nella presenza come CATEGORIA di un elenco chiuso, mai come
/// testo libero, e nella tendina si legge in forma generica: "ai tarocchi",
/// "nel Viaggio". Mai il nome del responso, mai la domanda.
///
/// L'elenco e' lo stesso del server (`ARTI_DELLA_PRESENZA` in
/// `functions/src/sociale.ts`): una prova pretende che i due coincidano.
enum ArteDellaPresenza {
  cerchio('nel Cerchio'),
  oroscopo('all’oroscopo'),
  tarocchi('ai tarocchi'),
  rune('alle rune'),
  angeli('con gli Angeli'),
  archetipi('agli archetipi'),
  viso('alla Mappa del Viso'),
  meditazione('in meditazione'),
  viaggio('nel Viaggio'),
  sigilli('ai sigilli'),
  maestri('con i Maestri'),
  sinastria('alla sinastria'),
  riti('ai riti del giorno'),
  santuario('nel Santuario');

  const ArteDellaPresenza(this.dove);

  /// Dove sta la persona, in forma generica: "Lunaria è ai tarocchi".
  final String dove;

  /// L'arte di un'arte del catalogo, per id: la sola mappa, accanto
  /// all'elenco, cosi' un'arte nuova senza la sua categoria si vede qui.
  static ArteDellaPresenza perLArte(String id) => switch (id) {
        'archetype_test' => archetipi,
        'face_constellation' => viso,
        'guide_animal' => viaggio,
        'guardian_angel' => angeli,
        'magic_sigil' => sigilli,
        'rune_draw' => rune,
        'horoscope' => oroscopo,
        'synastry_vip' => sinastria,
        'tarot_spread_three' => tarocchi,
        'meditation' => meditazione,
        'day_oracle' || 'sunset_rune' || 'breath_destiny' => riti,
        _ => cerchio,
      };
}

/// L'arte di adesso, che la presenza manda al server a ogni passo.
abstract final class LArteDiAdesso {
  static final ValueNotifier<ArteDellaPresenza> attuale =
      ValueNotifier(ArteDellaPresenza.cerchio);

  static final Expando<ArteDellaPresenza> _arteDellaRotta =
      Expando('arte della rotta');

  /// Segna una rotta con la sua arte. Lo fanno le porte delle arti
  /// (`artRouteFor`) e la chat dei Maestri: la schermata non sa niente.
  static R segna<R extends Route<Object?>>(R rotta, ArteDellaPresenza arte) {
    _arteDellaRotta[rotta] = arte;
    return rotta;
  }

  static ArteDellaPresenza? arteDi(Route<Object?>? rotta) =>
      rotta == null ? null : _arteDellaRotta[rotta];
}

/// L'osservatore della navigazione che tiene l'arte di adesso: la rotta in
/// cima porta la sua arte, e una rotta senza arte vale quella sotto di lei
/// (un foglio aperto dentro i tarocchi resta ai tarocchi).
class OsservatoreDellArte extends NavigatorObserver {
  final List<Route<Object?>> _pila = [];

  void _aggiorna() {
    for (final r in _pila.reversed) {
      final arte = LArteDiAdesso.arteDi(r);
      if (arte != null) {
        LArteDiAdesso.attuale.value = arte;
        return;
      }
    }
    LArteDiAdesso.attuale.value = ArteDellaPresenza.cerchio;
  }

  @override
  void didPush(Route<Object?> route, Route<Object?>? previousRoute) {
    _pila.add(route);
    _aggiorna();
  }

  @override
  void didPop(Route<Object?> route, Route<Object?>? previousRoute) {
    _pila.remove(route);
    _aggiorna();
  }

  @override
  void didRemove(Route<Object?> route, Route<Object?>? previousRoute) {
    _pila.remove(route);
    _aggiorna();
  }

  @override
  void didReplace({Route<Object?>? newRoute, Route<Object?>? oldRoute}) {
    final i = oldRoute == null ? -1 : _pila.indexOf(oldRoute);
    if (i >= 0 && newRoute != null) {
      _pila[i] = newRoute;
    } else if (newRoute != null) {
      _pila.add(newRoute);
    }
    _aggiorna();
  }
}

/// L'osservatore montato nell'app, uno solo, come quello del cielo.
final OsservatoreDellArte osservatoreDellArte = OsservatoreDellArte();
