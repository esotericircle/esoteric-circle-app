import 'vip_catalog.dart';

/// **LO SPECCHIO: LA COPPIA FATTA DALLO STESSO PERSONAGGIO DUE VOLTE.**
/// Ordine DR voce 01, 16 settembre 2026.
///
/// **Il fatto, dal fondatore**: nella Sinastria VIP ha scelto due volte lo
/// stesso personaggio, e la scheda si leggeva come un guasto, con la stessa
/// frase stampata due volte di fila. **La decisione**: quel caso non si vieta.
/// Diventa un easter egg che nomina il gesto e lo esagera.
///
/// **PERCHE' SI CHIAMA LO SPECCHIO E NON I GEMELLI.** Il fondatore li chiama
/// gemelli, e nei testi che la persona legge e nei documenti restano gemelli.
/// Nel codice no: `GemelloAstrale` esiste dall'ordine BO voce 10 e vuol dire
/// un'altra cosa, il VIP col cielo piu' vicino al tuo. Due significati sulla
/// stessa parola dentro la stessa cartella sono la famiglia di difetti delle
/// due porte, e qui si evita prima che nasca.
///
/// **UNA PORTA SOLA, e tutto il resto la interroga.** Il riconoscimento non
/// si rifa' nella schermata: la schermata chiede a lei.
abstract final class LoSpecchio {
  /// **L'IDENTITA' DEL PERSONAGGIO, e non la sua data di nascita.**
  ///
  /// Lo `stem` e' il nome del file del ritratto: il catalogo lo porta gia' e
  /// **e' diverso per tutti e cinquanta**, verificato contandoli. Quando manca
  /// si ricade sul nome, che nel catalogo di oggi e' anch'esso unico.
  ///
  /// **La data non serve e ingannerebbe**: due personaggi diversi possono
  /// nascere lo stesso giorno, e quella e' una coincidenza, non una coppia
  /// allo specchio. Nel catalogo di oggi non ce n'e' nessuna, ma un catalogo
  /// che cresce la trovera', e la porta deve essere gia' giusta.
  static String identitaDi(Vip vip) => vip.stem ?? vip.name;

  /// Se i due lati sono lo stesso personaggio.
  static bool sono(Vip primo, Vip secondo) =>
      identitaDi(primo) == identitaDi(secondo);
}
