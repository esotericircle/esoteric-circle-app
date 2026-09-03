import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../settings/settings_controller.dart';
import 'catalogo_suoni.dart';
import 'motore_audio.dart';
import 'voce_del_responso.dart';
import '../maestro/maestro.dart';
import 'regia_della_musica.dart';

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

  /// LA SPIA DEI SUONI, per le prove che devono CONTARLI.
  ///
  /// **Perche' serve.** In prova il plugin audio non c'e', quindi finora
  /// l'unico modo di verificare chi suona era leggere il codice sorgente: una
  /// prova strutturale, che dice se una riga esiste e non se il suono e'
  /// partito una volta o due. L'ordine BK voce 04 chiede la misura vera, cioe'
  /// che i due suoni del consulto partano UNA volta sola e non si sovrappongano,
  /// e una regola del genere non si legge in una riga di sorgente.
  ///
  /// In produzione e' nulla e costa un confronto: nessun elenco che cresce,
  /// nessuna memoria trattenuta.
  @visibleForTesting
  static void Function(SuonoDelCerchio suono)? spia;

  /// Riproduce uno dei tredici suoni del catalogo, se il livello e'
  /// acceso.
  ///
  /// Se il file non c'e' ancora, non succede niente: e' il ripiego
  /// silenzioso dichiarato, che tiene l'app viva finche' gli asset non
  /// arrivano.
  ///
  /// **E LA MUSICA SCENDE DA QUI, ordine CN voce 07.** L'abbassamento sta
  /// dentro la porta dei suoni e non nelle schermate che suonano: se ogni
  /// schermata dovesse ricordarsi di abbassare il tappeto, la prima che
  /// se ne dimenticasse avrebbe un effetto coperto dalla musica, e
  /// nessuno saprebbe dove cercare. **Una porta sola, una regola sola.**
  static Future<void> suona(BuildContext context, SuonoDelCerchio suono) async {
    if (!suonoPermesso(context)) return;
    // La firma si sente all'apertura dell'app e mai a ogni ritorno in home: una
    // firma che si ripete a ogni passaggio smette di essere una firma.
    if (suono == SuonoDelCerchio.firma) {
      if (_giaEmessi.contains(suono)) return;
      _giaEmessi.add(suono);
    }
    spia?.call(suono);
    // La musica scende PRIMA che l'effetto attacchi, e non dopo: la
    // discesa dura 220 millisecondi, cioe' meno del piu' breve dei
    // tredici suoni, quindi non ritarda niente di percepibile.
    unawaited(RegiaDellaMusica.sola.scendiSottoUnEffetto(suono.durataAttesa));
    await _motore.effetto(suono.percorso, volume: suono.volume);
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

  /// Se un SUONO puo' uscire adesso. Ordine BX voce 05: servono
  /// l'interruttore unico e quello dei soli effetti sonori.
  static bool suonoPermesso(BuildContext context) {
    final s = Provider.of<SettingsController?>(context, listen: false);
    return s?.suonoPermesso ?? false;
  }

  /// **LA VOCE DEL RESPONSO, una per Maestro. Ordine BX voce 05.**
  ///
  /// Passa di qui e non dal motore diretto, come ogni altro suono
  /// dell'app: un suono che non passa dalla palette non rispetta gli
  /// interruttori, ed e' esattamente il difetto che la guardia del
  /// catalogo sorveglia da sempre.
  ///
  /// La vibrazione della rivelazione viene PRIMA, come in ogni momento del
  /// Cerchio: chi tiene il telefono muto riceve solo quella.
  static Future<void> responso(BuildContext context, Maestro maestro) async {
    // **LA DECISIONE SI PRENDE SUBITO, prima di ogni attesa.** Cosi' chi
    // guarda da fuori, prova o no, sa gia' che questo responso ha una voce,
    // e la regia non deve restare appesa al suono per continuare il suo
    // lavoro: misurato, aspettarla spostava la festa del cammino di un giro
    // e lasciava un temporizzatore acceso nella cattura dell'Oroscopo.
    // **NELLE ANTEPRIME IL RESPONSO NON TOCCA NIENTE, ne' suono ne'
    // vibrazione.** Lo schema aptico della rivelazione e' fatto di colpi
    // separati da attese, e ogni attesa e' un temporizzatore: nella cattura
    // dell'Oroscopo restava acceso dopo lo smontaggio e la cattura cadeva su
    // "A Timer is still pending". Un'anteprima misura la grafica.
    if (voceSpentaPerLeProve) return;
    final parla = suonoPermesso(context);
    if (parla) spiaDelResponso?.call(maestro);
    // **LA VIBRAZIONE ARRIVA COMUNQUE**, anche a suoni spenti: chi tiene il
    // telefono muto ha solo quella, e il responso deve farsi sentire lo
    // stesso.
    await vibra(context, SchemaAptico.rivelazione);
    if (!context.mounted || !parla) return;
    // **NON SI ASPETTA IL SUONO, e non e' una scorciatoia.** Il responso e'
    // gia' a schermo: chi legge non deve attendere che il lettore audio
    // risponda, e in una prova senza il plugin quell'attesa non finisce mai.
    // Misurato: la guardia di questa voce restava appesa oltre i dieci
    // minuti finche' questa riga aspettava il motore.
    unawaited(_motore.tono(VoceDelResponso.byteDi(maestro), inCiclo: false));
  }

  /// La spia della voce del responso, sorella di [spia]: dice CHI ha
  /// parlato, perche' la prova possa contare i responsi che suonano senza
  /// il plugin audio, che in prova non c'e'.
  @visibleForTesting
  static void Function(Maestro maestro)? spiaDelResponso;

  /// **LA VOCE SPENTA, solo per le ANTEPRIME.**
  ///
  /// Un'anteprima misura la grafica e non il suono, e col plugin audio finto
  /// il lettore lascia acceso un temporizzatore: la cattura dell'Oroscopo
  /// cadeva su "A Timer is still pending" per un suono che nessuno sente.
  /// **Nessun punto di `lib` la tocca, e vale falso in ogni build.** La
  /// spia resta viva anche a voce spenta, cosi' una prova puo' contare chi
  /// avrebbe parlato senza costruire nessun lettore.
  @visibleForTesting
  static bool voceSpentaPerLeProve = false;

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
