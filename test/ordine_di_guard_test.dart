import 'guardia_del_manifesto.dart';

/// **LA GUARDIA PROPRIA DELL'ORDINE DI.** Scritta dall'ordine DS voce 01, 17
/// settembre 2026: l'ordine DI si era chiuso senza, e nessuna prova se ne
/// accorgeva. Sorveglia che il manifesto chiuso resti quello che e' stato
/// chiuso.
void main() {
  sorvegliaIlManifesto(
    file: 'ORDINE_DI_MANIFESTO.md',
    voci: 17,
    marcatori: {
      'VOCI_TOTALI': 17,
      'VOCI_CHIUSE': 17,
      'VOCI_SBLOCCATE_E_APERTE': 0,
    },
  );
}
