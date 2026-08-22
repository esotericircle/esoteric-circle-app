import 'package:shared_preferences/shared_preferences.dart';

/// COSA IL TELEFONO DIMENTICA QUANDO SI ESCE O SI CANCELLA TUTTO.
/// Ordine AZ, voci 07 e 08.
///
/// **Nasce da due buchi misurati.** Uscire dall'account non esisteva affatto,
/// e cancellare l'account prometteva "qui e sul server" mentre il "qui" non
/// veniva toccato: sul telefono restavano il diario del cammino, i dati di
/// nascita e la preferenza che dice se il rito e' gia' stato fatto.
///
/// **Perche' e' grave e non solo sciatto.** Chi entra dopo troverebbe il
/// cammino di un altro, e la fusione col Cerchio lo manderebbe pure sul
/// server del nuovo arrivato, dove il piu' alto dei contatori vince: i gesti
/// di una persona diventerebbero i traguardi di un'altra.
///
/// **Sta in un posto solo e non e' un vezzo.** L'uscita e la cancellazione
/// devono dimenticare le stesse cose: se ognuna tenesse la sua lista, un
/// giorno una delle due si dimenticherebbe una chiave, e sarebbe proprio la
/// chiave che conta.
class DimenticanzaDelTelefono {
  const DimenticanzaDelTelefono._();

  /// **I PREFISSI DELLE CHIAVI CHE APPARTENGONO A UNA PERSONA.**
  ///
  /// **Sono prefissi e non un elenco di chiavi, e c'e' un motivo misurato**:
  /// la prima stesura di questo file elencava nove chiavi scritte a memoria,
  /// e **nessuna delle nove esisteva davvero**. Le chiavi vere sono
  /// trentotto, contate leggendo le costanti di tutto `lib/`, e crescono a
  /// ogni funzione nuova: un elenco a mano si sarebbe dimenticato proprio
  /// quella aggiunta ieri.
  ///
  /// Per prefisso: `account.`, `allowance.`, `borsellino.`, `cammino.`,
  /// `profile.`, `archetipo.`, `santuario.`, piu' `onboarding.done`.
  static const prefissiDaDimenticare = <String>[
    'account.',
    'allowance.',
    'borsellino.',
    'cammino.',
    'profile.',
    'archetipo.',
    'santuario.',
    'sigilli.',
    'rituale.',
    'onboarding.',
  ];

  /// **COSA NON SI DIMENTICA, ed e' una scelta.**
  ///
  /// Non si svuota tutto con un `clear()`: le preferenze tengono anche cose
  /// che NON sono di nessuno, cioe' come questo telefono e' stato regolato.
  /// La qualita' grafica, il movimento ridotto, i sottotitoli, il suono:
  /// buttarli vorrebbe dire punire chi esce, e rimettere a mano
  /// un'accessibilita' che qualcuno aveva scelto per necessita'.
  static const prefissiCheRestano = <String>['settings.'];

  /// Dimentica cio' che appartiene alla persona che se ne va.
  ///
  /// Torna quante chiavi c'erano davvero: serve alle prove per dire che
  /// qualcosa e' stato dimenticato sul serio, invece di dichiararlo.
  static Future<int> dimentica() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var quante = 0;
      for (final chiave in prefs.getKeys().toList()) {
        final resta =
            prefissiCheRestano.any((p) => chiave.startsWith(p));
        if (resta) continue;
        final va = prefissiDaDimenticare.any((p) => chiave.startsWith(p));
        if (!va) continue;
        await prefs.remove(chiave);
        quante++;
      }
      return quante;
    } catch (errore) {
      // Senza persistenza non c'e' niente da dimenticare, e non e' un guasto.
      return 0;
    }
  }
}
