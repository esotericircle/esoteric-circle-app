import 'package:flutter/material.dart';

import 'santuario_bottom_bar.dart';

/// LO SPAZIO DELLA BARRA VIVE DENTRO CIO' CHE SCORRE.
///
/// **Decisione di Mauro del 7 agosto 2026, che SUPERA il compromesso della
/// 2156.** Quel compromesso teneva lo spazio della barra FUORI dal contenuto:
/// in home uno slot fisso rimpiccioliva la schermata, e quando la barra si
/// ritirava restava una fascia vuota. Nel dominio invece il contenuto scorreva
/// sotto la barra, e Mauro ha scelto quel comportamento per tutte e cinque le
/// schermate: chi legge il commento della 2156 sul padding costante fuori dal
/// contenuto NON lo ripristini, e' stato superato da questa scelta, non
/// smentito da un difetto.
///
/// **Come funziona.** `BarraDelCerchio` consegna lo spazio via `MediaQuery`
/// nel padding basso. Le schermate NON lo consumano piu' con un `SafeArea`
/// fuori dallo scroll: dichiarano `bottom: false` e mettono QUESTO widget in
/// coda a cio' che scorre. Cosi' il contenuto passa sotto la barra mentre si
/// scorre, la fascia dietro la barra mostra contenuto invece di vuoto, e
/// l'ultimo elemento risale sopra la barra grazie a questa coda.
///
/// **Perche' un widget e non un numero.** La quantita' giusta e' il padding
/// basso del `MediaQuery` del punto in cui si sta, che somma la barra e il
/// bordo di sistema: scriverla a mano in cinque schermate sono cinque numeri
/// che divergono. Qui e' un dato solo, e una prova enumera chi lo usa.
///
/// **L'eccezione dichiarata: la chat.** Il campo di scrittura non e' contenuto
/// che scorre, e' uno strumento ancorato: sotto la barra sarebbe inutilizzabile
/// e la 2156 ha misurato cosa succede a farlo saltare, 123 punti in un
/// fotogramma. La chat consuma quindi lo spazio col suo `SafeArea` per tenere
/// il campo sopra la barra, mentre i messaggi scorrono gia' dietro il campo,
/// che e' il comportamento del dominio applicato alla parte che scorre.
class SpazioDellaBarraNelloScroll extends StatelessWidget {
  const SpazioDellaBarraNelloScroll({super.key});

  /// Quanto spazio serve in coda: la barra piu' il bordo di sistema.
  ///
  /// **COSTANTE, non piu' il padding vivo, ordine M voce 1e.** Il padding
  /// iniettato dalla barra vale zero quando la barra e' ritirata: la coda si
  /// accorciava, lo scorrimento arrivava piu' in basso, e quando la barra
  /// tornava le ultime card restavano sotto di lei e sotto ESPLORA. Con la
  /// misura piena e ferma, il fondo dello scorrimento tiene sempre l'ultima
  /// card sopra la barra, qualunque sia lo stato della corsa.
  static double quanto(BuildContext context) {
    // La barra, quando e' visibile, INIETTA gia' la propria altezza nel
    // padding basso: in quel caso il padding vivo E' la misura piena e
    // sommarle la barra la conterebbe due volte. Quando e' ritirata, o non
    // c'e' (le prove che montano la schermata da sola), il padding porta solo
    // il bordo di sistema e la barra va aggiunta.
    final vivo = MediaQuery.paddingOf(context).bottom;
    return vivo >= SantuarioBottomBar.altezzaResa
        ? vivo
        : vivo + SantuarioBottomBar.altezzaResa;
  }

  @override
  Widget build(BuildContext context) =>
      SizedBox(height: quanto(context));
}

/// La stessa coda, per gli scroll a sliver.
class SliverSpazioDellaBarra extends StatelessWidget {
  const SliverSpazioDellaBarra({super.key});

  @override
  Widget build(BuildContext context) =>
      const SliverToBoxAdapter(child: SpazioDellaBarraNelloScroll());
}
