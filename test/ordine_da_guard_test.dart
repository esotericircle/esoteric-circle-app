import 'guardia_del_manifesto.dart';

/// **LA GUARDIA PROPRIA DELL'ORDINE DA.** Scritta dall'ordine DS voce 01, 17
/// settembre 2026: l'ordine DA si era chiuso senza, e nessuna prova se ne
/// accorgeva. Sorveglia che il manifesto chiuso resti quello che e' stato
/// chiuso.
void main() {
  sorvegliaIlManifesto(
    file: 'ORDINE_DA_MANIFESTO.md',
    voci: 6,
    marcatori: {
      'VOCI_TOTALI': 6,
      'VOCI_CHIUSE': 6,
      'VOCI_APERTE': 0,
      'VOCI_SENZA_GUARDIA_PROPRIA': 1,
    },
  );
}
