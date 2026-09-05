import 'zodiac.dart';

/// UN SIMBOLO DELLO ZODIACO SIGNIFICA IL SUO SEGNO, e nient'altro.
///
/// **Il dato che ha fatto nascere questo file.** Nell'intestazione della chat
/// c'era un'icona a bilancia, dorata. Chi l'ha disegnata intendeva "metti a
/// confronto"; il fondatore, che e' la persona piu' esperta del dominio in
/// questo progetto, ci ha letto **il segno della Bilancia**. Tolta di li', era
/// rimasta sulla card della Sintesi comparativa con la motivazione che in quel
/// contesto significa confronto.
///
/// **Il significato di un simbolo non lo decide il contesto nella testa di chi
/// disegna, lo decide l'occhio di chi guarda.** E su una superficie che parla
/// di lettura astrologica il rischio e' piu' alto, non piu' basso: proprio li'
/// l'occhio e' gia' predisposto a leggere segni.
///
/// Questa regola vive qui e non nella card, perche' una regola scritta dentro
/// la cosa che corregge non impedisce alla stessa cosa di rinascere fra un mese
/// in un terzo posto.
class SimboliDelloZodiaco {
  const SimboliDelloZodiaco._();

  /// I dodici glifi, RICAVATI dal catalogo dei segni e non riscritti.
  ///
  /// Un elenco copiato divergerebbe dal suo originale. E' il difetto che
  /// questo progetto ha gia' visto piu' volte. Se domani un glifo cambia, la
  /// regola lo segue da sola.
  static List<String> get glifi => [for (final z in Zodiac.values) z.symbol];

  /// Il file che ha il diritto di scrivere quei glifi: quello che li dichiara.
  ///
  /// Altrove un glifo dello zodiaco scritto a mano vuol dire due cose: o e' una
  /// copia del dato, quindi divergera'; oppure e' usato per significare
  /// qualcos'altro, cioe' esattamente cio' che questa regola vieta.
  static const String casaDeiGlifi = 'lib/core/astro/zodiac.dart';

  /// LE ICONE DI SISTEMA CHE UN OCCHIO LEGGE COME UN SEGNO.
  ///
  /// Non sono vietate perche' brutte: sono vietate perche' **l'app ha l'arte
  /// vera per ogni segno**, quindi non ha nessun motivo di dire un segno con
  /// un'icona di sistema. Se una di queste compare, o sta dicendo un segno nel
  /// modo sbagliato, oppure sta dicendo un'altra cosa con la faccia di un
  /// segno. Tutti e due i casi vanno fermati.
  ///
  /// La chiave e' il nome dell'icona come si scrive nel codice, il valore e' il
  /// segno che l'occhio ci legge: serve al messaggio della prova, perche' "non
  /// usare Icons.balance" senza dire perche' si finisce per aggirarlo.
  static const Map<String, String> iconeCheSembranoUnSegno = {
    'Icons.balance': 'la Bilancia',
    'Icons.balance_rounded': 'la Bilancia',
    'Icons.balance_outlined': 'la Bilancia',
    'Icons.scale': 'la Bilancia',
    'Icons.scale_rounded': 'la Bilancia',
    'Icons.scale_outlined': 'la Bilancia',
  };
}
