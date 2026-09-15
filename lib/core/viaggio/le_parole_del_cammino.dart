import 'i_quattro_viaggi.dart';

/// **LE PAROLE DEL CAMMINO A STRATI, in un posto solo.** Ordine DQ voci 01,
/// 02, 03 e 04, 15 settembre 2026.
///
/// **La decisione del fondatore**: la domanda e' una sola e accompagna tutte
/// e quattro le discese della rivelazione, e ogni discesa risale con uno
/// strato piu' profondo della stessa risposta. Qui stanno le parole che la
/// persona legge: la soglia, il riquadro del cambio, la risalita e il Diario
/// le prendono da qui, e nessuno le riscrive.
abstract final class LeParoleDelCammino {
  /// **LA RIGA SOPRA LA DOMANDA**, dalla seconda discesa. Ordine DQ voce 01:
  /// *"Sei sceso per questo"*. **Con la marca del genere**, perche' il
  /// participio dice il genere di chi legge: al femminile *"Sei scesa"*, e a
  /// chi non l'ha detto *"Sei qui"*.
  static const String seiScesoPerQuesto =
      '[Sei sceso|Sei scesa|Sei qui] per questo';

  /// **IL PULSANTE CHE APRE LA SCELTA**, con le parole dell'ordine DQ voce 03.
  static const String cambiaLaDomanda = 'Cambia la domanda';

  /// **IL RIQUADRO CHE CHIEDE CONFERMA**, due paragrafi con le parole
  /// dell'ordine DQ voce 03. **Una virgola sola non c'e'**, quella prima di
  /// *"e l'animale"*: la regola di casa non vuole una virgola davanti alla
  /// *e*, e il fondatore l'ha gia' decisa per un testo suo consegnato parola
  /// per parola, le cornici del presagio, quando la virgola e' stilistica e
  /// si toglie senza cambiare il senso. Vedi `test/language_rule_test.dart`.
  static const List<String> avvisoDelCambio = [
    'Nel Mondo di Sotto si scende una volta sola per ogni domanda e '
        "l'animale si mostra quattro volte a chi tiene la stessa. Cambiarla "
        'non è un errore: è cominciare un altro viaggio.',
    'Le discese che hai già fatto restano nel tuo Diario. Il cammino verso '
        'il tuo animale riparte dalla prima.',
  ];

  static const String tengoQuestaDomanda = 'Tengo questa domanda';
  static const String comincioUnAltroViaggio = 'Comincio un altro viaggio';

  /// **I QUATTRO STRATI, come li legge la persona**, ordine DQ voce 02.
  static const List<String> stratiConDomanda = [
    'Che cosa hai portato giù davvero',
    'Che cosa ti trattiene',
    'Che cosa hai già in mano',
    'Che cosa fare',
  ];

  /// **I QUATTRO STRATI DI CHI SCENDE SENZA DOMANDA**, ordine DQ voce 04.
  /// *"Che cosa di lui ti somiglia"* nell'ordine: qui *"dell'animale"*,
  /// perche' prima della quarta discesa non si sa se e' il Lupo o la Volpe.
  static const List<String> stratiDellIncontro = [
    'Che cosa ti ha portato a cercarlo',
    "Che cosa dell'animale ti somiglia",
    'Che cosa ti chiede',
    'Chi è',
  ];

  static const List<String> _ordinali = ['Primo', 'Secondo', 'Terzo', 'Quarto'];

  static int _indice(int strato) =>
      strato.clamp(1, IQuattroViaggi.quanteDiscese) - 1;

  /// *"Terzo strato: che cosa hai già in mano"*.
  static String etichettaDelloStrato(int strato, {required bool conDomanda}) {
    final i = _indice(strato);
    final che = (conDomanda ? stratiConDomanda : stratiDellIncontro)[i];
    return '${_ordinali[i]} strato: ${che[0].toLowerCase()}${che.substring(1)}';
  }

  /// *"Oggi scendi al terzo strato: che cosa hai già in mano."*
  static String oggiScendiAl(int strato, {required bool conDomanda}) {
    final i = _indice(strato);
    final che = (conDomanda ? stratiConDomanda : stratiDellIncontro)[i];
    return 'Oggi scendi al ${_ordinali[i].toLowerCase()} strato: '
        '${che[0].toLowerCase()}${che.substring(1)}.';
  }

  /// *"Due strati su quattro"*, in parole e mai in numeri.
  static String quantiStrati(int n) {
    final quanti = n.clamp(1, IQuattroViaggi.quanteDiscese);
    final parola = quanti == 1
        ? 'Uno strato'
        : '${_maiuscola(IQuattroViaggi.inLettere(quanti))} strati';
    return '$parola su quattro';
  }

  /// **LA DOMANDA DI CHI SCENDE SOLTANTO PER INCONTRARLO**, dentro un cammino.
  /// Il pronome e' *lo*: prima della quarta discesa l'animale non ha ancora
  /// un nome, e resta l'animale.
  static const String soloPerIncontrarlo =
      "Soltanto per incontrarlo. Le quattro discese parlano dell'incontro.";

  static const String laDomandaDelCammino = 'LA DOMANDA DEL CAMMINO';
  static const String rileggiIQuattroStrati = 'Rileggi i quattro strati';
  static const String ilDiario = 'Il Diario dei viaggi';
  static const String leAltreDiscese = 'LE ALTRE DISCESE';
  static const String diarioVuoto =
      'Il Diario si riempie a ogni discesa: qui ritrovi le domande e le '
      'risposte.';

  static String _maiuscola(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}
