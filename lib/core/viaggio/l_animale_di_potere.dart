import '../astro/zodiac.dart';
import '../rituals/animal_catalog.dart';
import '../rituals/guide_animal_derivation.dart';
import 'diario_dei_viaggi.dart';
import 'il_nome_si_puo_dire.dart';
import 'le_ombre_che_ritornano.dart';

/// **L'ANIMALE DI POTERE: SI TROVA, NON SI CALCOLA.** Ordine FZ voci 01 e 02,
/// 17 ottobre 2026.
///
/// **LA FONTE.** Il fondatore, 17 ottobre 2026: *"Come viene scelto l'animale
/// guida nel viaggio dello sciamano? Al di là della discesa e risalita, in
/// verità è già assegnato, come?"*, e poi *"La 2."*, cioè l'animale che si
/// rivela davvero nel viaggio, con la regola delle quattro apparizioni di
/// Michael Harner (*The Way of the Shaman*, 1980): l'animale di potere si
/// riconosce quando si mostra almeno quattro volte.
///
/// **QUESTA E' LA PORTA UNICA NUOVA.** Fino all'ordine FZ la porta era
/// `GuideAnimalDerivation.forSign`: il segno solare, letto alla nascita,
/// decideva l'animale per sempre, e il Viaggio non faceva che mostrarlo a
/// pezzi. L'ordine DG l'aveva chiusa cosi' apposta, dopo che due porte
/// diverse (il segno e "quale ombra e' stata seguita piu' volte") avevano
/// dato due animali diversi alla stessa persona.
///
/// **E QUI LA STORIA SI ROVESCIA, PER UNA RAGIONE DIVERSA.** Il fondatore ha
/// scelto esplicitamente la via in cui l'animale si rivela nel viaggio, non
/// nel cielo: a ogni discesa nove ombre (FZA.01, erano tre), la persona ne
/// segue una a intuito, e quando la stessa ombra e' stata seguita quattro
/// volte (non per forza di fila) quella e' il suo animale. Non e' un ritorno
/// all'errore di DC: li' le quattro discese sceglievano fra ombre decise in
/// parte dal cielo ("il cielo restringe" a tre candidati) e la porta del
/// segno restava aperta in parallelo nel Passaporto. Qui il cielo non entra
/// per niente: le ombre proposte a ogni discesa nascono solo da quali ombre
/// la persona ha gia' seguito, e dall'identita' del dispositivo per quelle
/// mai viste (`LeOmbreCheRitornano.ombreProposte`, FZA.02), e la porta del
/// segno (`GuideAnimalDerivation`) resta viva solo per la migrazione una
/// tantum di chi aveva gia' concluso col vecchio sistema (vedi
/// [migraSeServe]), non per decidere l'animale di nessuno.
///
/// **COSA SOSTITUISCE.** Ogni punto che chiamava `GuideAnimalDerivation.forSign`
/// per MOSTRARE l'animale di una persona (Passaporto, Bosco del Cerchio, carta
/// natale, simbolo dell'attesa, scheda della scelta, Il Ritratto, l'Animale
/// Guida, il Viaggio) passa adesso da qui: [riconosciutoDa] legge il Diario e
/// torna l'animale riconosciuto, o nullo se la persona non ha ancora seguito
/// la stessa ombra quattro volte. Prima del riconoscimento non c'e' nessun
/// animale da mostrare: c'e' solo [sagomaNonRivelata], la stessa per tutti,
/// con la scritta [nonAncoraRivelato].
abstract final class AnimaleDiPotere {
  const AnimaleDiPotere._();

  /// **L'ANIMALE NEUTRO DI CHI NON HA ANCORA RIVELATO NIENTE.**
  ///
  /// Non e' "il suo" animale, non e' derivato dal segno, non e' indovinato:
  /// e' sempre lo stesso per chiunque non abbia ancora riconosciuto il
  /// proprio, preso dal catalogo gia' dipinto (R8: nessun disegno nuovo). La
  /// scelta di usare sempre la prima voce (l'Aquila) e non una scelta legata
  /// alla persona e' deliberata: mostrare sagome diverse a persone diverse,
  /// prima del riconoscimento, sarebbe comunque "mostrare un animale", anche
  /// senza il nome. Serve a chi ha bisogno di un `GuideAnimal` intero, come
  /// il Trionfo dell'Animale in onboarding, che non rivela mai nessun nome
  /// (la guardia lo sorveglia) e quindi puo' mostrare un corpo qualunque.
  static GuideAnimal get animalePlaceholder => AnimalCatalog.animals.first;

  /// La sagoma di [animalePlaceholder], per chi ha bisogno solo del
  /// percorso dell'immagine.
  static String get sagomaNonRivelata => animalePlaceholder.ombraPath;

  /// La scritta che accompagna [sagomaNonRivelata], ovunque nell'app.
  static const String nonAncoraRivelato = 'Non ancora rivelato';

  /// **L'ANIMALE RICONOSCIUTO DA QUESTO DIARIO**, o nullo.
  ///
  /// E' la sola funzione che il resto dell'app deve chiamare per sapere "chi
  /// e' il suo animale": se torna nullo, in nessun punto dell'app compare un
  /// nome o una sagoma riconoscibile, solo [sagomaNonRivelata].
  static GuideAnimal? riconosciutoDa(DiarioDeiViaggi diario) {
    final nome = diario.animaleRiconosciuto;
    if (nome == null) return null;
    return _daNome(nome);
  }

  static GuideAnimal? _daNome(String nome) {
    for (final a in AnimalCatalog.animals) {
      if (a.name == nome) return a;
    }
    return null;
  }

  /// **L'ANIMALE RICONOSCIUTO, DALLA CACHE DI SESSIONE**, per chi disegna
  /// dentro un `build` sincrono e non puo' aspettare un Diario (il simbolo
  /// dell'attesa di Caligo, il bosco del Cerchio, Il Ritratto). Legge
  /// `IlNomeSiPuoDire.animaleRiconosciutoNoto`, che `DiarioDeiViaggi`
  /// aggiorna a ogni `carica`, `segna` e migrazione completata: puo' essere
  /// in ritardo di una sessione rispetto all'archivio vero, e per questo chi
  /// puo' aspettare chiama [riconosciutoDa] o [caricaERisolvi].
  static GuideAnimal? dalCioCheSiSaGia() {
    final nome = IlNomeSiPuoDire.animaleRiconosciutoNoto;
    return nome == null ? null : _daNome(nome);
  }

  /// Vedi [LeOmbreCheRitornano.trovaIlRiconosciuto].
  static String? trovaIlRiconosciuto(List<String> scelteInOrdine) =>
      LeOmbreCheRitornano.trovaIlRiconosciuto(scelteInOrdine);

  /// Vedi [LeOmbreCheRitornano.ombraCheGuida].
  static String? ombraCheGuida(List<String> scelteInOrdine) =>
      LeOmbreCheRitornano.ombraCheGuida(scelteInOrdine);

  /// Vedi [LeOmbreCheRitornano.improteDelCammino].
  static List<String> improteDelCammino(List<String> scelteInOrdine) =>
      LeOmbreCheRitornano.improteDelCammino(scelteInOrdine);

  /// Vedi [LeOmbreCheRitornano.ombreProposte].
  static List<String> ombreProposte(
          List<String> scelteInOrdine, String identita) =>
      LeOmbreCheRitornano.ombreProposte(
          scelteInOrdine: scelteInOrdine, identita: identita);

  /// **LA MIGRAZIONE UNA TANTUM DI FZ.02.**
  ///
  /// Chiamarla dopo ogni `DiarioDeiViaggi.carica()`, prima di leggere
  /// [riconosciutoDa] o `diario.riconosciuto`: e' l'unico punto in cui la
  /// vecchia porta (`GuideAnimalDerivation.forSign`) e' ancora legittima, e
  /// solo per sapere quale animale tenere fisso a chi aveva **gia' concluso**
  /// il viaggio col vecchio sistema (il segno). Chi era a meta' riparte da
  /// capo con le ombre, e questa funzione torna l'avviso di una riga da
  /// mostrare con garbo; chi aveva gia' concluso non ha bisogno di nessun
  /// avviso: tiene l'animale che vedeva, e basta. Torna nullo quando non
  /// c'era niente da migrare (diari nuovi, o migrazione gia' fatta).
  static Future<String?> migraSeServe(
    DiarioDeiViaggi diario,
    Zodiac segnoDiNascita,
  ) =>
      diario.completaMigrazioneFZ02(
        animaleDiNascita: GuideAnimalDerivation.forSign(segnoDiNascita).name,
      );

  /// Scorciatoia per gli schermi: carica il diario, completa la migrazione
  /// se serve, e torna sia l'animale riconosciuto (o nullo) sia l'eventuale
  /// avviso per chi riparte da capo.
  static Future<({GuideAnimal? animale, String? avviso})> caricaERisolvi(
    DiarioDeiViaggi diario,
    Zodiac segnoDiNascita,
  ) async {
    await diario.carica();
    final avviso = await migraSeServe(diario, segnoDiNascita);
    return (animale: riconosciutoDa(diario), avviso: avviso);
  }
}
