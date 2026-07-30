import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../settings/settings_controller.dart';

/// I QUATTRO SCHEMI APTICI del Cerchio, e nessuno di piu'.
///
/// **Perche' l'aptica viene prima del suono.** La maggior parte delle persone
/// tiene il telefono in silenzio, quindi un'app che affida la propria identita'
/// al suono e' muta per la maggioranza di chi la usa. La vibrazione arriva
/// sempre, anche in una stanza piena di gente.
///
/// **Perche' quattro e non di piu'.** Un vocabolario di gesti si impara solo se
/// e' piccolo. Con dodici schemi nessuno riconosce niente e resta una vibrazione
/// generica, che e' come non averla.
///
/// Il rifiuto NON ha uno schema suo: usa [tocco] due volte. Il rifiuto non
/// merita teatro, e dargli una vibrazione tutta sua lo renderebbe memorabile
/// nel modo sbagliato.
enum SchemaAptico {
  /// Selezione, cambio scheda, spunta. Un tick leggero, quasi subliminale.
  tocco,

  /// Azione compiuta: salvataggio, cuore sui preferiti. Colpo medio secco.
  conferma,

  /// Animale, angeli, sigillo, carta scoperta. Due colpi crescenti, il secondo
  /// pieno.
  rivelazione,

  /// Ingresso nel dominio di un Maestro, inizio di un rito. Un colpo profondo.
  soglia,
}

/// La palette sensoriale: l'unico posto da cui partono vibrazioni e suoni.
///
/// Nessuna schermata chiama `HapticFeedback` per conto proprio. Prima erano
/// diciassette chiamate dirette sparse in sette file, ognuna con la propria idea
/// di quanto forte vibrare: la stessa azione vibrava in modo diverso a seconda
/// di dove la si faceva. Un test conta le chiamate dirette fuori da qui e
/// fallisce se ne trova.
class PaletteSensoriale {
  const PaletteSensoriale._();

  /// Fa vibrare secondo uno schema, se il livello sensoriale e' acceso.
  ///
  /// Il [context] serve a leggere l'interruttore unico. Se manca il controller,
  /// per esempio in una prova che monta un widget da solo, non si vibra: il
  /// silenzio e' il ripiego giusto quando non si sa cosa l'utente ha scelto.
  static Future<void> vibra(BuildContext context, SchemaAptico schema) async {
    if (!acceso(context)) return;
    return eseguiSchema(schema);
  }

  /// Il rifiuto: [SchemaAptico.tocco] due volte, senza uno schema dedicato.
  static Future<void> rifiuto(BuildContext context) async {
    if (!acceso(context)) return;
    await eseguiSchema(SchemaAptico.tocco);
    await Future<void>.delayed(const Duration(milliseconds: 90));
    await eseguiSchema(SchemaAptico.tocco);
  }

  /// Se il livello sensoriale e' acceso, secondo l'interruttore unico.
  static bool acceso(BuildContext context) {
    final s = Provider.of<SettingsController?>(context, listen: false);
    return s?.suonoEVibrazione ?? false;
  }

  /// Esegue lo schema senza guardare l'interruttore.
  ///
  /// Pubblica perche' i test la misurano: verificare quali colpi compongono uno
  /// schema non deve richiedere di montare un albero coi provider.
  static Future<void> eseguiSchema(SchemaAptico schema) async {
    switch (schema) {
      case SchemaAptico.tocco:
        return HapticFeedback.selectionClick();
      case SchemaAptico.conferma:
        return HapticFeedback.mediumImpact();
      case SchemaAptico.rivelazione:
        // Due colpi crescenti: il primo annuncia, il secondo rivela.
        await HapticFeedback.lightImpact();
        await Future<void>.delayed(const Duration(milliseconds: 110));
        return HapticFeedback.heavyImpact();
      case SchemaAptico.soglia:
        return HapticFeedback.heavyImpact();
    }
  }
}
