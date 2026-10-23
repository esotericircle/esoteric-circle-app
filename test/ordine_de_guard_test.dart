import 'guardia_del_manifesto.dart';

/// **LA GUARDIA PROPRIA DELL'ORDINE DE.** Scritta dall'ordine DS voce 01, 17
/// settembre 2026: l'ordine DE si era chiuso senza, e nessuna prova se ne
/// accorgeva. Sorveglia che il manifesto chiuso resti quello che e' stato
/// chiuso.
void main() {
  sorvegliaIlManifesto(
    file: 'ORDINE_DE_MANIFESTO.md',
    voci: 16,
    nota:
        'MARCATORI CON LE CHIUSE IMPLICITE: il totale e le aperte, non le chiuse',
    marcatori: {
      'VOCI_TOTALI': 16,
      'VOCI_APERTE': 2,
    },
  );
}
