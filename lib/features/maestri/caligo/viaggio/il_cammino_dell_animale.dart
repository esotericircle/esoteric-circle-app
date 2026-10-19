import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/viaggio/la_sequenza_del_cammino.dart';
import '../../../scene/la_scena_in_video.dart';

/// **IL CAMMINO DELL'ANIMALE, I PEZZI DEL VIDEO AL POSTO DEGLI ZOOM.**
/// Ordine FZ voce FZ.05, 17 ottobre 2026.
///
/// Fa girare [sequenza] (`LaSequenzaDelCammino.rivelazione`, o
/// `.perIlGesto` per i tre gesti del segno) pezzo dopo pezzo, ognuno un file
/// che comincia e finisce sul fotogramma della posa: alla giuntura fra due
/// pezzi il vecchio sfuma mentre il nuovo compare, con [giuntura], 0,3
/// secondi (le pose misurate differiscono fra 1,8 e 5,3 su 255, l'ordine lo
/// chiede, e la dissolvenza assorbe quello scarto). Finito l'ultimo pezzo
/// resta fermo sulla posa, o se [sequenza] lo dice dissolve con
/// [dissolvenzaFinale], 0,5 secondi, su [scenaVuota].
///
/// **CON RIDUCI MOVIMENTO: NIENTE VIDEO, FERMA SULLA POSA.** Nessun lettore
/// si apre nemmeno per il primo pezzo: *"con Riduci Movimento: niente video,
/// la carta ferma sulla posa"*.
///
/// **SENZA RETE O IL FILE NON ANCORA SCARICATO, LA STESSA POSA**, mai un
/// riquadro vuoto: la posa e' sempre lo strato di fondo, e un lettore che
/// non si apre ([LettoreDiScena.fallito]) semplicemente non compare sopra di
/// lei.
class IlCamminoDellAnimale extends StatefulWidget {
  IlCamminoDellAnimale({
    super.key,
    required this.sequenza,
    required this.percorsi,
    required this.posa,
    this.scenaVuota,
    this.quandoFinisce,
    LettoreDiScena Function(String percorso)? fabbrica,
  })  : fabbrica = fabbrica ?? LettoreDiScena.veroDaFile,
        assert(
          scenaVuota != null ||
              sequenza.esito != EsitoDelCammino.dissolveNellaScenaVuota,
          'la sequenza vuole la scena vuota e questa carta non la porta',
        );

  final LaSequenzaDelCammino sequenza;

  /// Il percorso (file scaricato o, nelle prove, asset) di ogni pezzo che
  /// [sequenza] puo' nominare.
  final Map<PezzoDelCammino, String> percorsi;

  /// L'immagine ferma del fotogramma di posa: cio' che si vede con Riduci
  /// Movimento, senza rete, o a riposo prima e dopo il cammino.
  final String posa;

  /// L'immagine della scena vuota, per [EsitoDelCammino.dissolveNellaScenaVuota].
  final String? scenaVuota;

  /// Chiamato una volta sola, quando l'ultimo pezzo finisce (o subito, con
  /// Riduci Movimento: la carta e' gia' ferma sulla posa).
  final VoidCallback? quandoFinisce;

  /// Chi apre un lettore per un pezzo: iniettabile nelle prove.
  final LettoreDiScena Function(String percorso) fabbrica;

  static const Duration giuntura = Duration(milliseconds: 300);
  static const Duration dissolvenzaFinale = Duration(milliseconds: 500);

  @override
  State<IlCamminoDellAnimale> createState() => _IlCamminoDellAnimaleState();
}

/// Un pezzo in scena: il suo lettore e se sta sfumando via.
class _Strato {
  _Strato(this.lettore);
  final LettoreDiScena lettore;
  bool sfumaVia = false;
}

class _IlCamminoDellAnimaleState extends State<IlCamminoDellAnimale> {
  int _indice = 0;
  final List<_Strato> _strati = [];
  bool _dissolviNellaScenaVuota = false;
  bool _movimentoRidotto = false;
  bool _giaPartito = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_giaPartito) return;
    _giaPartito = true;
    _movimentoRidotto = MediaQuery.of(context).disableAnimations;
    if (_movimentoRidotto) {
      widget.quandoFinisce?.call();
    } else {
      unawaited(_apri(0));
    }
  }

  @override
  void dispose() {
    for (final s in _strati) {
      s.lettore.chiudi();
    }
    super.dispose();
  }

  Future<void> _apri(int indice) async {
    final percorso = widget.percorsi[widget.sequenza.pezzi[indice]];
    if (percorso == null) {
      // **IL PEZZO NON C'E'**, senza rete o non ancora scaricato: si salta
      // come se fosse finito all'istante, mai un'attesa senza fine. La
      // posa resta lo strato di fondo, e chi aspetta [quandoFinisce] (la
      // riga del segno, per esempio) non resta bloccato per sempre.
      //
      // **UN MICROTASK PRIMA DI `setState`**: al primo pezzo, questo passa
      // da `didChangeDependencies`, cioe' mentre il widget si monta per la
      // prima volta; `setState` durante quella costruzione lancerebbe. Un
      // giro vuoto basta a farlo cadere dopo, come un vero cambio di stato.
      await Future<void>.value();
      if (!mounted) return;
      _avanzaOFinisci(indice);
      return;
    }
    final lettore = widget.fabbrica(percorso);
    final strato = _Strato(lettore);
    lettore.ascolta(() {
      if (!mounted) return;
      if (lettore.finito) _avanzaOFinisci(indice);
      setState(() {});
    });
    await lettore.apri();
    if (!mounted) return;
    setState(() => _strati.add(strato));
    if (lettore.fallito) {
      _avanzaOFinisci(indice);
      return;
    }
    await lettore.volume(0);
    if (!mounted) return;
    await lettore.avvia();
  }

  void _avanzaOFinisci(int indiceFinito) {
    if (indiceFinito != _indice) return;
    final prossimo = _indice + 1;
    if (prossimo < widget.sequenza.pezzi.length) {
      _indice = prossimo;
      unawaited(_apri(prossimo));
      // **IL VECCHIO SFUMA VIA SOLO QUANDO IL NUOVO E' DAVVERO IN SCENA**,
      // non appena questo finisce: altrimenti la giuntura sfuma sul vuoto.
      return;
    }
    setState(() {
      if (widget.sequenza.esito == EsitoDelCammino.dissolveNellaScenaVuota) {
        _dissolviNellaScenaVuota = true;
      }
    });
    widget.quandoFinisce?.call();
  }

  /// Chiamato dal build quando un nuovo strato e' comparso sopra uno
  /// vecchio: il vecchio comincia a sfumare, e dopo [giuntura] si chiude.
  void _avviaLaSfumaturaDiTuttiTranneLUltimo() {
    for (var k = 0; k < _strati.length - 1; k++) {
      final vecchio = _strati[k];
      if (vecchio.sfumaVia) continue;
      vecchio.sfumaVia = true;
      unawaited(Future<void>.delayed(IlCamminoDellAnimale.giuntura, () {
        if (!mounted) return;
        vecchio.lettore.chiudi();
        setState(() => _strati.remove(vecchio));
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_strati.length > 1) _avviaLaSfumaturaDiTuttiTranneLUltimo();
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(widget.posa,
            key: const Key('cammino_posa'),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox.shrink()),
        for (final s in _strati)
          if (!s.lettore.fallito && s.lettore.cominciato)
            AnimatedOpacity(
              key: ValueKey(s),
              opacity: s.sfumaVia ? 0 : 1,
              duration: IlCamminoDellAnimale.giuntura,
              child: s.lettore.disegna(),
            ),
        if (_dissolviNellaScenaVuota && widget.scenaVuota != null)
          AnimatedOpacity(
            key: const Key('cammino_scena_vuota'),
            opacity: 1,
            duration: IlCamminoDellAnimale.dissolvenzaFinale,
            child: Image.asset(widget.scenaVuota!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink()),
          ),
      ],
    );
  }
}
