import 'guardia_del_manifesto.dart';

/// **LA GUARDIA PROPRIA DELL'ORDINE DG.** Scritta dall'ordine DS voce 01, 17
/// settembre 2026: l'ordine DG si era chiuso senza, e nessuna prova se ne
/// accorgeva. Sorveglia che il manifesto chiuso resti quello che e' stato
/// chiuso.
void main() {
  sorvegliaIlManifesto(
    file: 'ORDINE_DG_MANIFESTO.md',
    voci: 9,
    marcatori: {
      'VOCI_TOTALI': 9,
      'VOCI_CHIUSE_NEL_CODICE': 8,
      'VOCI_APERTE': 1,
    },
  );
}
