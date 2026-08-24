import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../settings/settings_controller.dart';
import 'catalogo_suoni.dart';
import 'motore_audio.dart';

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

  /// Il motore audio condiviso, uno solo per tutta l'app.
  static final MotoreAudio _motore = MotoreAudio.condiviso;

  /// I suoni gia' emessi in questa sessione, per quelli che vanno emessi una
  /// volta sola.
  static final Set<SuonoDelCerchio> _giaEmessi = <SuonoDelCerchio>{};

  /// Riproduce uno dei cinque suoni del catalogo, se il livello e' acceso.
  ///
  /// Se il file non c'e' ancora, non succede niente: e' il ripiego silenzioso
  /// dichiarato, che tiene l'app viva finche' gli asset non arrivano.
  static Future<void> suona(BuildContext context, SuonoDelCerchio suono) async {
    if (!acceso(context)) return;
    // La firma si sente all'apertura dell'app e mai a ogni ritorno in home: una
    // firma che si ripete a ogni passaggio smette di essere una firma.
    if (suono == SuonoDelCerchio.firma) {
      if (_giaEmessi.contains(suono)) return;
      _giaEmessi.add(suono);
    }
    await _motore.effetto(suono.percorso);
  }

  /// Azzera la memoria dei suoni emessi una volta sola. Serve alle prove.
  @visibleForTesting
  static void dimenticaSessione() => _giaEmessi.clear();

  /// Il gesto completo di un momento: prima la vibrazione, poi il suono.
  ///
  /// L'aptica viene PRIMA, e non e' un dettaglio di ordine: chi tiene il
  /// telefono in silenzio riceve solo quella, quindi deve arrivare comunque e
  /// per prima.
  static Future<void> momento(
    BuildContext context, {
    required SchemaAptico aptica,
    SuonoDelCerchio? suono,
  }) async {
    await vibra(context, aptica);
    // La vibrazione e' appena passata per un await: se nel frattempo il
    // widget e' smontato, il contesto non si tocca piu'.
    if (!context.mounted) return;
    if (suono != null) await suona(context, suono);
  }

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
