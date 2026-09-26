import 'guardia_del_manifesto.dart';

/// **LA GUARDIA PROPRIA DELL'ORDINE DK.** Scritta dall'ordine DS voce 01, 17
/// settembre 2026: l'ordine DK si era chiuso senza, e nessuna prova se ne
/// accorgeva. Sorveglia che il manifesto chiuso resti quello che e' stato
/// chiuso.
void main() {
  sorvegliaIlManifesto(
    file: 'ORDINE_DK_MANIFESTO.md',
    voci: 8,
    marcatori: {
      'VOCI_TOTALI': 8,
      'VOCI_CHIUSE': 8,
      'VOCI_SBLOCCATE_E_APERTE': 0,
    },
  );
}
