import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/maestro/maestro.dart';
import '../../core/maestro/tempi_dell_attesa.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../maestri/widgets/busto_del_maestro.dart';

/// MEDORA CI PENSA, PRIMA DI RISPONDERE. Ordine P voce 06.
///
/// **Il difetto.** Finita la selezione, i responsi comparivano di colpo. Un
/// responso istantaneo e' un responso letto da un archivio, ed e' esattamente
/// cio' che la persona percepisce: la stesa piu' curata dell'app perdeva
/// credibilita' nell'unico istante in cui doveva guadagnarla.
///
/// **La scena.** Il ritratto di Medora dentro un cerchio di stelle che GIRA, e
/// sotto una riga alla volta che dice cosa sta accadendo. Le righe sono cinque,
/// si alternano, sono nella voce di Medora e nessuna vale per un caricamento
/// qualunque: ognuna nomina le carte, la stesa o il suo sguardo.
///
/// **L'ATTESA MINIMA GARANTITA NON E' RISCRITTA QUI.** I tempi vengono da
/// [TempiDellAttesa], che e' la correzione gia' chiusa alla voce 40 del Registro
/// dei Difetti: due battute intere come minimo, duemila millisecondi ciascuna,
/// dissolvenza in uscita, e con Riduci Movimento la pausa scende a quanto basta
/// perche' la riga si legga. Riscriverne una seconda copia sarebbe un'altra
/// occorrenza della famiglia delle due porte, e le due copie divergono sempre.
///
/// **Nessuno stato senza uscita.** La lettura della stesa e' deterministica e
/// locale, cioe' non c'e' nessuna rete che possa non tornare: la scena non puo'
/// restare a girare perche' non aspetta nessuno. Cio' che la chiude e' il suo
/// stesso minimo garantito, e sopra a quello vige il tetto alla prima parola di
/// [TempiDellAttesa.tettoAllaPrimaParola], che la chiude comunque. Se un giorno
/// il consiglio passera' dal modello, il ripiego con Riprova va agganciato qui,
/// e il tetto e' gia' al suo posto.
/// In che stato si trova la scena dell'attesa.
///
/// Tre stati e non un booleano, perche' la dissolvenza e' un momento vero: il
/// responso c'e' gia' sotto il velo che se ne va, e in quel momento la scena
/// non copre piu' ma non e' ancora sparita.
enum StatoDellAttesa {
  assente,
  piena,
  inUscita;

  bool get inScena => this != StatoDellAttesa.assente;
}

class AttesaDiMedora extends StatefulWidget {
  const AttesaDiMedora({
    super.key,
    required this.palette,
    this.riduciMovimento = false,
    this.rotazione = 0,
  });

  final MaestroPalette palette;

  /// Con Riduci Movimento il cerchio non gira e la pausa si accorcia: resta la
  /// riga che dichiara cosa Medora sta guardando.
  final bool riduciMovimento;

  /// Quale giro di righe. Cresce a ogni stesa, cosi' due stese vicine non
  /// aprono sulla stessa frase.
  final int rotazione;

  /// LE RIGHE, nella voce di Medora.
  ///
  /// Cinque e non tre: il minimo garantito ne mostra due, e con tre sole la
  /// terza stesa di fila ricominciava dalla prima. Nessuna e' generica, cioe'
  /// nessuna potrebbe stare sopra un caricamento di un'altra arte: e' la
  /// differenza fra una pausa che qualcuno abita e una barra travestita.
  static const List<String> righe = [
    'Medora osserva le tre carte insieme.',
    'Medora cerca il filo che lega le tre carte.',
    'Medora pesa la carta del Presente contro le altre due.',
    'Medora guarda in che verso sono uscite le tre carte.',
    'Medora tiene la tua stesa sotto gli occhi, senza fretta.',
  ];

  /// I tempi, letti da [TempiDellAttesa] e non riscritti.
  static Duration get durataMinima => TempiDellAttesa.durataMinima;
  static Duration get durataMinimaRidotta =>
      TempiDellAttesa.durataMinimaRidotta;
  static Duration get durataRiga => TempiDellAttesa.durataBattuta;
  static Duration get dissolvenza => TempiDellAttesa.dissolvenza;
  static Duration get tetto => TempiDellAttesa.tettoAllaPrimaParola;

  /// Quanto dura la scena, dato il regime di movimento.
  static Duration minimaPer({required bool riduciMovimento}) =>
      riduciMovimento ? durataMinimaRidotta : durataMinima;

  @override
  State<AttesaDiMedora> createState() => _AttesaDiMedoraState();
}

class _AttesaDiMedoraState extends State<AttesaDiMedora>
    with SingleTickerProviderStateMixin {
  /// Il cerchio di stelle che gira. NULLO a moto fermo, e non creato e lasciato
  /// fermo: un controllore che nessuno fa girare resta un ticker registrato.
  AnimationController? _giro;

  Timer? _passo;
  late int _corrente = AttesaDiMedora.righe.isEmpty
      ? 0
      : widget.rotazione % AttesaDiMedora.righe.length;

  @override
  void initState() {
    super.initState();
    if (!widget.riduciMovimento) {
      _giro = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 2600),
      )..repeat();
    }
    // Le righe si alternano anche con Riduci Movimento, perche' cambiare una
    // riga di testo non e' movimento: e' contenuto, e il contenuto non si
    // toglie mai.
    _passo = Timer.periodic(AttesaDiMedora.durataRiga, (_) {
      if (!mounted) return;
      setState(() =>
          _corrente = (_corrente + 1) % AttesaDiMedora.righe.length);
    });
  }

  @override
  void dispose() {
    _passo?.cancel();
    _giro?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final riga = AttesaDiMedora.righe[_corrente % AttesaDiMedora.righe.length];
    // NON si posiziona da se'. Chi la monta la mette dove va: qui c'era un
    // `Positioned.fill`, e infilandola dentro la dissolvenza Flutter si trovava
    // un dato di posizione senza uno Stack a cui darlo.
    return DecoratedBox(
        // La sovrimpressione copre la scena: la stesa che sta sotto non deve
        // rubare l'attenzione a cio' che Medora sta facendo.
        decoration: BoxDecoration(
          color: palette.deepest.withValues(alpha: 0.88),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(SpacingTokens.lg),
            child: Column(
              key: const Key('stesa_attesa'),
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 176,
                  height: 176,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_giro != null)
                        AnimatedBuilder(
                          animation: _giro!,
                          builder: (context, _) => CustomPaint(
                            size: const Size.square(176),
                            painter: _CerchioDiStelle(
                              giro: _giro!.value,
                              palette: palette,
                            ),
                          ),
                        )
                      else
                        CustomPaint(
                          size: const Size.square(176),
                          painter: _CerchioDiStelle(giro: 0, palette: palette),
                        ),
                      // IL RITRATTO DI MEDORA, dalla porta unica del busto: qui
                      // non nasce un secondo modo di mostrare un Maestro.
                      ClipOval(
                        child: SizedBox(
                          width: 116,
                          height: 116,
                          child: BustoDelMaestro(
                            maestro: Maestro.medora,
                            height: 116,
                            // L'alone e' gia' il cerchio di stelle attorno: due
                            // aloni sommati fanno una macchia.
                            aura: false,
                            respira: !widget.riduciMovimento,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: SpacingTokens.md),
                Text(
                  riga,
                  key: ValueKey('stesa_attesa_riga_$_corrente'),
                  textAlign: TextAlign.center,
                  style: TypographyTokens.display(size: 18)
                      .copyWith(color: palette.goldSoft),
                ),
              ],
            ),
          ),
        ),
    );
  }
}

/// Il cerchio di stelle attorno al ritratto: dodici punti che girano piano.
///
/// Dodici come i segni, non un numero qualunque, ed e' il solo ornamento della
/// scena: quello che deve leggersi e' il volto e la riga.
class _CerchioDiStelle extends CustomPainter {
  _CerchioDiStelle({required this.giro, required this.palette});

  final double giro;
  final MaestroPalette palette;

  static const int quante = 12;

  @override
  void paint(Canvas canvas, Size size) {
    final centro = size.center(Offset.zero);
    final raggio = size.shortestSide / 2 - 6;
    final anello = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = palette.gold.withValues(alpha: 0.22);
    canvas.drawCircle(centro, raggio, anello);
    for (var i = 0; i < quante; i++) {
      final angolo = (i / quante + giro) * 2 * math.pi;
      final punto = Offset(
        centro.dx + raggio * math.cos(angolo),
        centro.dy + raggio * math.sin(angolo),
      );
      // Le stelle piu' vicine alla cima sono le piu' vive: il giro si legge
      // anche da fermo, in una cattura.
      final vivezza = 0.35 + 0.65 * ((i / quante + giro) % 1);
      canvas.drawCircle(
        punto,
        1.6 + 1.4 * vivezza,
        Paint()..color = palette.goldSoft.withValues(alpha: 0.25 + 0.6 * vivezza),
      );
    }
  }

  @override
  bool shouldRepaint(_CerchioDiStelle old) =>
      old.giro != giro || old.palette != palette;
}
