import 'package:flutter/foundation.dart';

import 'zodiac.dart';

/// Tiene il segno solare dell'utente, usato dal cosmo di sfondo per evidenziare
/// in oro la costellazione corrispondente.
///
/// **NASCE VUOTO, e deve restare cosi'.** Prima partiva da un segno cablato, e
/// il commento che stai leggendo diceva "un segno di esempio (Leone)" mentre il
/// codice ne metteva un altro: mentiva anche il commento. Quel segnaposto non
/// restava confinato allo sfondo, arrivava alla frase della home e diceva a
/// chiunque "per chi nasce sotto Gemelli", perche' questo controller non
/// conserva niente e un solo punto del progetto si ricordava di riempirlo.
///
/// **Chi vuole il segno vero non lo chiede qui**: lo chiede alla data di
/// nascita, `BirthIdentity.sunSign`, che ce l'ha per costruzione. Questo
/// controller serve a evidenziare in oro una costellazione nel cosmo di sfondo,
/// e quando nessuno gli dice niente non evidenzia nulla, che e' la cosa giusta
/// da fare quando non si sa.
class ZodiacController extends ChangeNotifier {

  /// **DIMENTICA CHI SE NE VA. Ordine BC voce 02.**
  ///
  /// **Il fatto del fondatore**: "ho provato a cancellare l'account, ma i dati
  /// restano... il borsellino, i traguardi e altri dati attualmente restano
  /// anche dopo la conferma della cancellazione."
  ///
  /// **La causa**: cancellare toglieva le chiavi dal disco e chiudeva la
  /// sessione, ma **i controller vivono per tutta la sessione dell'app** e
  /// nessuno li svuotava. Quello che si vedeva a schermo era la memoria, non
  /// il disco, e alla prima scrittura tornava anche sul disco.
  ///
  /// Non si tocca il server: qui si dimentica soltanto cio' che si ricorda.
  void dimenticaChiSeNeVa() {
    _sunSign = null;
    notifyListeners();
  }

  ZodiacController({Zodiac? sunSign}) : _sunSign = sunSign;

  Zodiac? _sunSign;
  Zodiac? get sunSign => _sunSign;

  void setSunSign(Zodiac? sign) {
    if (sign == _sunSign) return;
    _sunSign = sign;
    notifyListeners();
  }
}
