import 'guardia_del_manifesto.dart';

/// **LA GUARDIA PROPRIA DELL'ORDINE DL.** Scritta dall'ordine DS voce 01, 17
/// settembre 2026: l'ordine DL si era chiuso senza, e nessuna prova se ne
/// accorgeva. Sorveglia che il manifesto chiuso resti quello che e' stato
/// chiuso.
void main() {
  sorvegliaIlManifesto(
    file: 'ORDINE_DL_MANIFESTO.md',
    voci: 15,
    marcatori: {
      'VOCI_TOTALI': 15,
      'VOCI_CHIUSE': 15,
      'VOCI_SBLOCCATE_E_APERTE': 0,
    },
  );
}
