/// LA DATA IN ITALIANO, in un posto solo.
///
/// **Perche' esiste.** La stessa riga di dodici mesi era scritta a mano in
/// quattro file diversi: l'Oroscopo, la Sinastria, la cartolina del cielo e la
/// schermata dei dati di nascita. Quattro copie della stessa tabella sono la
/// famiglia delle due porte, e prima o poi una si scrive `settembre` e
/// un'altra `Settembre`. Questa e' la porta comune, e l'ordine BO ha
/// cominciato a farci passare la Sinastria.
const List<String> mesiInItaliano = [
  'gennaio',
  'febbraio',
  'marzo',
  'aprile',
  'maggio',
  'giugno',
  'luglio',
  'agosto',
  'settembre',
  'ottobre',
  'novembre',
  'dicembre',
];

/// "4 giugno 1975". Senza zeri davanti e senza virgole: e' la forma che l'app
/// usa nei cartigli.
String dataItalianaEstesa(DateTime d) =>
    '${d.day} ${mesiInItaliano[d.month - 1]} ${d.year}';
