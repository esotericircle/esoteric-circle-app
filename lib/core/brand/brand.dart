/// Identita' di brand in un solo punto, cosi' il nome e il dominio non
/// divergono da nessuna parte. Chi mostra il marchio (cartolina, schermate,
/// testi di condivisione) legge sempre da qui.
class Brand {
  const Brand._();

  /// Nome del prodotto.
  static const String name = 'Esoteric Circle';

  /// Dominio pubblico, senza schema.
  static const String domain = 'esotericircle.app';

  /// URL pubblico completo.
  static const String url = 'https://esotericircle.app';

  /// **DOVE VIVONO I LINK D'INVITO, ordine EY voce 04: un ripiego dichiarato.**
  /// L'ordine li vuole sul dominio del progetto, accanto a `/entra`. Misurato
  /// il 4 ottobre 2026: `esotericircle.app` risolve a un hosting esterno
  /// (62.149.128.40) e non a Firebase Hosting, dove vive la pagina del link
  /// (`/i/**` in `firebase.json`), quindi un link sul dominio non arriverebbe
  /// a nessuna pagina. Finche' il dominio non passa a Firebase Hosting (o non
  /// rinvia `/i/` qui), gli inviti partono dall'indirizzo di Firebase, che
  /// risponde. Il giorno del dominio si cambia questa riga sola.
  static const String urlDegliInviti = 'https://esoteric-circle.web.app';
}
