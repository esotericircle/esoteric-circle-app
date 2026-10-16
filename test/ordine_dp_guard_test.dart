import 'guardia_del_manifesto.dart';

/// **LA GUARDIA PROPRIA DELL'ORDINE DP.** Scritta dall'ordine DS voce 01, 17
/// settembre 2026: l'ordine DP si era chiuso senza, e nessuna prova se ne
/// accorgeva. Sorveglia che il manifesto chiuso resti quello che e' stato
/// chiuso.
void main() {
  sorvegliaIlManifesto(
    file: 'ORDINE_DP_MANIFESTO.md',
    voci: 6,
    marcatori: {
      'VOCI_TOTALI': 6,
      'VOCI_CHIUSE': 6,
      'VOCI_SBLOCCATE_E_APERTE': 0,
    },
  );
}
