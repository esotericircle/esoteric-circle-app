/// IL RACCONTO DELLA CORSA PRECEDENTE, a schermo pieno prima di tutto.
///
/// Parte della build diagnostica, dietro [kDiagnosiAttiva]: se la corsa
/// precedente ha lasciato una briciola, la si mostra PRIMA di ogni altra
/// cosa, intro compresa, perche' l'app muore anche durante l'intro e il
/// racconto deve arrivare comunque. Temporaneo e dichiarato, debito annotato
/// in STATO_VIVO.
library;

import 'package:flutter/material.dart';

import '../../design_system/tokens/typography_tokens.dart';

import 'briciole.dart';

class RaccontoDellaCorsa extends StatefulWidget {
  const RaccontoDellaCorsa({super.key, required this.child});

  final Widget child;

  @override
  State<RaccontoDellaCorsa> createState() => _RaccontoDellaCorsaState();
}

class _RaccontoDellaCorsaState extends State<RaccontoDellaCorsa> {
  bool _proseguito = false;

  @override
  Widget build(BuildContext context) {
    final briciola = Briciole.dellaCorsaPrecedente;
    if (!kDiagnosiAttiva || briciola == null || _proseguito) {
      return widget.child;
    }
    final parti = briciola.split('|');
    final tappa = parti.first;
    final orario = parti.length > 1 ? parti[1] : 'orario sconosciuto';
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        color: const Color(0xFF05060A),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Schermata di diagnosi, mostrata quando l'app muore
                // all'avvio: e' l'ultima cosa che si legge prima del nero,
                // quindi la si legge col ruolo come tutto il resto.
                Text('BUILD DIAGNOSTICA',
                    textAlign: TextAlign.center,
                    style: TypographyTokens.corpo()
                        .copyWith(color: const Color(0xFFC9A961),
                            letterSpacing: 3)),
                const SizedBox(height: 24),
                const Text('Ultima tappa raggiunta:',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 18)),
                const SizedBox(height: 12),
                Text(tappa,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(orario,
                    textAlign: TextAlign.center,
                    style: TypographyTokens.corpo()
                        .copyWith(color: Colors.white54)),
                const SizedBox(height: 40),
                FilledButton(
                  onPressed: () => setState(() => _proseguito = true),
                  child: const Text('Prosegui'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
