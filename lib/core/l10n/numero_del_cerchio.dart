import 'package:intl/intl.dart';

import 'la_lingua_del_cerchio.dart';

/// IL NUMERO CHE UNA PERSONA LEGGE, NELLA SUA LINGUA. Ordine DM voce 03.
///
/// **Il difetto che cura, e l'app ce l'ha oggi, in italiano.**
/// `toStringAsFixed` e' una funzione di Dart e non sa in che paese sta: mette
/// sempre il punto. In italiano il separatore decimale e' la virgola, e in
/// tre punti dell'app una persona leggeva *"152.3 gradi"* invece di *"152,3
/// gradi"*.
///
/// **E in quattro altri punti qualcuno se n'era gia' accorto**, e aveva
/// scritto a mano `.replaceAll('.', ',')`. Funziona, in italiano: e' proprio
/// il genere di cura che il giorno della seconda lingua diventa un difetto,
/// perche' mette la virgola anche a chi legge in inglese. **Quattro rimedi
/// scritti a mano in quattro posti sono quattro verita' sulla stessa
/// domanda.**
///
/// **Qui la domanda e' una sola**, e la risposta la da' la lingua corrente.
/// Non c'e' nessuna tavola di separatori scritta da noi: il separatore lo sa
/// `intl`, che porta i dati di tutte le lingue. Aggiungere una lingua non
/// vuol dire aggiungere una riga qui.
abstract final class NumeroDelCerchio {
  /// Un numero con [cifre] decimali, col separatore della lingua corrente.
  ///
  /// Con zero cifre non c'e' nessun separatore da scegliere, e la risposta e'
  /// la stessa in ogni lingua: si passa di qui lo stesso, perche' il giorno
  /// che qualcuno cambiera' le cifre non debba ricordarsi di cambiare anche
  /// la strada.
  static String conCifre(num valore, int cifre) =>
      NumberFormat.decimalPatternDigits(
        locale: LaLinguaDelCerchio.corrente.value.codice,
        decimalDigits: cifre,
      ).format(valore);

  /// Un numero intero col separatore delle migliaia della lingua corrente:
  /// *"6.030"* in italiano, *"6,030"* in inglese.
  ///
  /// **Serve al saldo degli Eos, ed e' l'ottavo punto di quest'ordine.** Il
  /// Cammino conia 2.010 Eos per sentiero e 6.030 in tutto, quindi il saldo
  /// supera il mille e un separatore ce l'ha per forza. Lo scriveva a mano
  /// `cifraDegliEos`, col punto: giusto in italiano, e in inglese un saldo di
  /// 6.030 si sarebbe letto **sei virgola zero tre zero**.
  ///
  /// **L'ha trovato il fondatore**, chiedendo se la moneta passasse dal
  /// formattatore nuovo. Non ci passava: ci passa adesso, e in italiano il
  /// testo e' identico al carattere.
  static String interi(int valore) => NumberFormat.decimalPattern(
        LaLinguaDelCerchio.corrente.value.codice,
      ).format(valore);

  /// Una misura in gradi, come si legge nel cielo: *"152,3 gradi"*.
  ///
  /// Sta qui e non nelle schermate perche' i gradi compaiono in tre punti
  /// lontani fra loro, e tre modi di scriverli sarebbero tre modi di
  /// sbagliarli.
  static String gradi(num valore, {int cifre = 1}) =>
      '${conCifre(valore, cifre)} gradi';

  /// Una percentuale gia' in centesimi: *"84,3%"*. Il segno sta attaccato al
  /// numero in italiano come in inglese.
  static String percento(num valore, {int cifre = 1}) =>
      '${conCifre(valore, cifre)}%';
}
