library;

import '../../core/maestro/maestro.dart';

/// L'IMPRONTA DELL'ISTRUZIONE DI SISTEMA, E LA MISURA CHE LE APPARTIENE.
/// Ordine S voce 28.
///
/// **Perche' nasce, e il fatto che l'ha resa necessaria.** L'11 agosto 2026 il
/// commit `97bb997`, voci S.15 e S.17, ha aggiunto dentro `_commonRules` la legge
/// del responso, il confine e una riga sul benessere: **636 caratteri netti su
/// circa 6300, cioe' il 10 per cento**, identici per tutti e tre i Maestri. La
/// misura che dice se i tre Maestri sono ancora riconoscibili, l'attribuzione cieca,
/// era stata presa il 2 agosto: da quel commit **non e' piu' valida**.
///
/// **Nessuna riga e' caduta.** L'artefatto piu' fragile del progetto e' cambiato del
/// dieci per cento e a scoprirlo, undici giorni dopo, e' stato un controllo di
/// premessa fatto a mano. Questo file esiste perche' non succeda una seconda volta.
///
/// **Come funziona.** Si registra l'impronta della stringa emessa per i tre Maestri,
/// insieme alla data e allo stato della misura presa SU QUELLA stringa. Una prova
/// ricompone l'impronta a ogni giro e la confronta. Chi cambia l'istruzione ha due
/// strade e nessuna terza: **rilanciare l'attribuzione cieca e aggiornare questo
/// dato, oppure dichiarare che si consegna con una misura non valida.**
///
/// **IL 98,3 PER CENTO NON E' SCRITTO ACCANTO ALL'IMPRONTA DI OGGI**, ed e' la cosa
/// piu' importante di questo file: quel numero appartiene a una stringa che non
/// esiste piu'. Scriverlo qui sarebbe mettere il falso dentro un dato, che e' peggio
/// che non avere il dato.
class ImprontaDellIstruzione {
  const ImprontaDellIstruzione._();

  /// LE IMPRONTE DI OGGI, sha256 della stringa emessa a profilo e memoria vuoti.
  ///
  /// **A profilo vuoto e non pieno**, perche' col nome e la memoria dentro la
  /// stringa cambia a ogni persona: cio' che si presidia qui e' l'ISTRUZIONE, non
  /// la conversazione.
  static const Map<String, String> impronte = {
    'medora':
        '0bc77eb5e1af347cd234f366c95c876341680bfa075d7d214e64d6f27f12de70',
    'aura': 'aab951f95c60a0135710e054992cdbefd845e4efbd8410b0d21be9e269121eb7',
    'caligo':
        'd31790d3b43d90ab55de2d4deca83f7e5925c424337cf6144b1265a6e39e48cb',
  };

  /// Il giorno in cui queste impronte sono state registrate.
  static const String registrateIl = '13 agosto 2026';

  /// **VERO SOLO QUANDO L'ATTRIBUZIONE CIECA E' STATA MISURATA SU QUESTE
  /// IMPRONTE.** Oggi e' falso, e la prova che lo guarda nasce ROSSA di proposito:
  /// dice il vero, ed e' l'unico modo perche' una misura mancante non passi
  /// inosservata fino alla consegna.
  static const bool attribuzioneValida = false;

  /// L'ultima misura NOTA, con la stringa su cui fu presa. Si tiene perche' un
  /// numero senza il suo oggetto e' una leggenda.
  static const String ultimaMisuraNota =
      '98,3 per cento (59 su 60), 2 agosto 2026, presa su una stringa di circa '
      '6300 caratteri, prima che il commit 97bb997 dell\'11 agosto ne aggiungesse '
      '636 netti con le voci S.15 e S.17.';

  /// Cosa si deve fare perche' [attribuzioneValida] torni vero.
  static const String comeSiRimisura =
      'flutter test tool/attribuzione_cieca.dart, dal PC con una sessione gcloud '
      'attiva. Poi si scrive qui il risultato e si porta attribuzioneValida a '
      'vero. La misura (a) del presagio della voce S.19 chiede lo stesso PC e lo '
      'stesso tipo di chiamata: si pagano insieme, non due volte.';

  /// L'impronta registrata per un Maestro.
  static String? per(Maestro maestro) => impronte[maestro.id];
}
