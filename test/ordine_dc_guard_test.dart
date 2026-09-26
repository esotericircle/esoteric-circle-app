import 'guardia_del_manifesto.dart';

/// **LA GUARDIA PROPRIA DELL'ORDINE DC.** Scritta dall'ordine DS voce 01, 17
/// settembre 2026: l'ordine DC si era chiuso senza, e nessuna prova se ne
/// accorgeva. Sorveglia che il manifesto chiuso resti quello che e' stato
/// chiuso.
void main() {
  sorvegliaIlManifesto(
    file: 'ORDINE_DC_MANIFESTO.md',
    voci: 21,
    marcatori: {
      'VOCI_TOTALI': 21,
      'VOCI_CHIUSE': 20,
      'VOCI_PARZIALI_E_DICHIARATE': 1,
      'VOCI_APERTE': 0,
    },
  );
}
