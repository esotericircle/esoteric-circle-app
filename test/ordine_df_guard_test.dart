import 'guardia_del_manifesto.dart';

/// **LA GUARDIA PROPRIA DELL'ORDINE DF.** Scritta dall'ordine DS voce 01, 17
/// settembre 2026: l'ordine DF si era chiuso senza, e nessuna prova se ne
/// accorgeva. Sorveglia che il manifesto chiuso resti quello che e' stato
/// chiuso.
void main() {
  sorvegliaIlManifesto(
    file: 'ORDINE_DF_MANIFESTO.md',
    voci: 0,
    nota:
        'NON ENUMERA LE VOCI: le sette voci stanno nella prosa, e il conto non si rifa dal file',
    marcatori: {
      'VOCI_TOTALI': 7,
      'VOCI_APERTE': 0,
    },
  );
}
