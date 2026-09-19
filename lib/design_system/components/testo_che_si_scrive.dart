import 'package:flutter/material.dart';

import '../../core/maestro/tempi_dell_attesa.dart';

/// Il testo che compare come se qualcuno lo stesse scrivendo.
///
/// **Perche' esiste.** La risposta arrivava tutta insieme, e una lettura di
/// settanta parole che appare in un fotogramma sa di macchina: non c'e' nessuno
/// dall'altra parte, c'e' un blocco di testo che si materializza.
///
/// **E si puo' SEMPRE saltare.** Un'animazione da cui non si puo' uscire e' una
/// gabbia, e alla terza domanda diventa fastidio: chi ha gia' letto la prima
/// riga e vuole il resto adesso tocca, e ce l'ha. Per questo [completa] e'
/// pubblico e la bolla intera fa da bersaglio, non una manina in un angolo.
///
/// **Ferma quando serve.** Con Riduci Movimento o Quality Tier basso il testo
/// e' gia' intero: si toglie il movimento, mai il contenuto. Lo decide chi
/// chiama, passando [attiva] a falso, cosi' questa classe non ha da sapere
/// nulla ne' dei provider ne' delle preferenze.
class TestoCheSiScrive extends StatefulWidget {
  const TestoCheSiScrive({
    super.key,
    required this.testo,
    required this.stile,
    required this.durataMassima,
    this.attiva = true,
    this.componi,
  });

  final String testo;
  final TextStyle stile;

  /// Il tetto oltre il quale la scrittura non puo' andare, cioe' quanto resta
  /// del budget dei dieci secondi dopo la pausa del consulto.
  final Duration durataMassima;

  /// Falso quando il testo deve essere gia' intero: Riduci Movimento, qualita'
  /// bassa, oppure semplicemente un messaggio vecchio riletto nella cronologia.
  final bool attiva;

  /// Come si compone il pezzo di testo scritto finora. Nullo vuol dire testo
  /// semplice. Esiste perche' l'enfasi sui nomi noti e' NOSTRA e va applicata
  /// anche mentre il testo compare: farla solo alla fine vorrebbe dire vedere
  /// il testo cambiare colore all'ultimo fotogramma.
  final InlineSpan Function(String testo, TextStyle stile)? componi;

  @override
  State<TestoCheSiScrive> createState() => TestoCheSiScriveState();
}

/// PUBBLICO apposta: la bolla lo raggiunge per completare al tocco, e una prova
/// puo' chiamarlo senza simulare un dito.
class TestoCheSiScriveState extends State<TestoCheSiScrive>
    with SingleTickerProviderStateMixin {
  late final AnimationController _moto = AnimationController(vsync: this);

  @override
  void initState() {
    super.initState();
    _avvia();
  }

  /// **Riparte quando cambia il TESTO, non quando cambia la posizione.**
  ///
  /// La lista della chat e' una `ListView.builder`: gli elementi si riusano per
  /// indice, quindi quando arriva una risposta nuova lo stato che stava sulla
  /// piu' recente si ritrova in mano quella di prima. Senza questo controllo un
  /// messaggio gia' letto si sarebbe rimesso a scriversi da capo ogni volta che
  /// ne arriva uno nuovo.
  @override
  void didUpdateWidget(TestoCheSiScrive vecchio) {
    super.didUpdateWidget(vecchio);
    if (vecchio.testo != widget.testo || vecchio.attiva != widget.attiva) {
      _avvia();
    }
  }

  void _avvia() {
    if (!widget.attiva || widget.testo.isEmpty) {
      _moto
        ..stop()
        ..value = 1;
      return;
    }
    _moto
      ..duration = TempiDellAttesa.durataDiScrittura(
          widget.testo.length, widget.durataMassima)
      ..forward(from: 0);
  }

  /// Salta alla fine. Chiamato dal tocco sulla bolla.
  void completa() {
    if (_moto.isAnimating) {
      _moto
        ..stop()
        ..value = 1;
    }
  }

  /// Vero finche' c'e' qualcosa da saltare: la bolla lo chiede per non
  /// intercettare un tocco che non serve piu' a niente.
  bool get staScrivendo => _moto.value < 1;

  @override
  void dispose() {
    _moto.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _moto,
      builder: (context, _) {
        final quanti = (widget.testo.length * _moto.value).round();
        Widget scritto(String testo) => widget.componi == null
            ? Text(testo, style: widget.stile)
            : Text.rich(widget.componi!(testo, widget.stile));

        // A SCRITTURA FINITA IL TESTO E' UN WIDGET SOLO, come prima che questa
        // classe esistesse.
        //
        // Non e' un'ottimizzazione, e' una correzione: la sovrapposizione qui
        // sotto mette in albero DUE volte lo stesso testo, e ogni prova che
        // cerca una frase a schermo ne trovava due invece di una. Se ne e'
        // accorta subito la prova a pixel della bolla, che non c'entrava
        // niente con la macchina da scrivere. Lo stato normale di un messaggio
        // e' fermo, quindi lo stato normale dell'albero torna a essere quello
        // di prima.
        if (quanti >= widget.testo.length) return scritto(widget.testo);

        // IL TESTO OCCUPA SUBITO LO SPAZIO CHE GLI SERVE.
        //
        // Senza questo la bolla cresce riga per riga mentre scrive, e cio' che
        // sta sotto salta a ogni fotogramma: si legge peggio di un testo che
        // compare tutto insieme, cioe' si perde proprio quello per cui la
        // macchina da scrivere esiste. Il testo intero resta li' trasparente a
        // tenere il posto, e sopra si scopre quello scritto finora.
        return Stack(
          children: [
            Opacity(opacity: 0, child: scritto(widget.testo)),
            scritto(widget.testo.substring(0, quanti)),
          ],
        );
      },
    );
  }
}
