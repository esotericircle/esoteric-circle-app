import 'guardia_del_manifesto.dart';

/// **LA GUARDIA PROPRIA DELL'ORDINE DJ.** Scritta dall'ordine DS voce 01, 17
/// settembre 2026: l'ordine DJ si era chiuso senza, e nessuna prova se ne
/// accorgeva. Sorveglia che il manifesto chiuso resti quello che e' stato
/// chiuso.
void main() {
  sorvegliaIlManifesto(
    file: 'ORDINE_DJ_MANIFESTO.md',
    voci: 11,
    marcatori: {
      'VOCI_TOTALI': 11,
      'VOCI_CHIUSE': 11,
      'VOCI_SBLOCCATE_E_APERTE': 0,
    },
  );
}
