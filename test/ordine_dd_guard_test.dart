import 'guardia_del_manifesto.dart';

/// **LA GUARDIA PROPRIA DELL'ORDINE DD.** Scritta dall'ordine DS voce 01, 17
/// settembre 2026: l'ordine DD si era chiuso senza, e nessuna prova se ne
/// accorgeva. Sorveglia che il manifesto chiuso resti quello che e' stato
/// chiuso.
void main() {
  sorvegliaIlManifesto(
    file: 'ORDINE_DD_MANIFESTO.md',
    voci: 15,
    nota:
        'DICHIARA IL FALSO, riportato al fondatore dall\'ordine DS: nomina diciassette voci, ne legge quindici in posizione di dichiarazione e VOCI_TOTALI ne dice sedici. Non corretto',
    marcatori: {
      'VOCI_TOTALI': 16,
      'VOCI_CHIUSE': 14,
      'VOCI_APERTE': 2,
    },
  );
}
