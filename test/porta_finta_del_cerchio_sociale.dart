import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';

import 'gli_enigmi_finti.dart';

/// **LA PORTA FINTA DEL CERCHIO SOCIALE**, per le prove e le anteprime
/// dell'ordine EY. Risponde come le porte del server, con la stessa forma dei
/// dati, e tiene il conto di cio' che le e' stato chiesto: una prova guarda
/// cosa il telefono ha mandato, non cosa sperava di mandare.
class PortaFintaDelCerchioSociale extends PortaSpentaDelCerchio {
  PortaFintaDelCerchioSociale({
    this.nome = 'Lunaria',
    this.sigillo = 'K7Q2',
    this.amici = true,
    this.confrontoConcesso = true,
    this.amiciPresenti,
  });

  final String nome;
  final String sigillo;
  final bool amici;
  final bool confrontoConcesso;

  /// Gli amici presenti che la tendina riceve; nulla vuol dire la sola
  /// Stella Lieve (ordine FB voce 01: la prova coi centocinquanta).
  final List<Map<String, Object?>>? amiciPresenti;

  /// Il Ritratto che la porta custodisce (ordine FF): vuoto finche' non si
  /// scrive.
  List<int> ritratto = [];

  /// Ogni porta chiesta, col suo corpo.
  final List<(String, Map<String, Object?>)> chieste = [];

  @override
  bool get viva => true;

  @override
  Future<EsitoDelConsumo?> consuma({
    required String budget,
    required String idMovimento,
  }) async {
    chieste.add(('consuma', {'budget': budget, 'idMovimento': idMovimento}));
    return EsitoDelConsumo(
        concesso: confrontoConcesso, resta: confrontoConcesso ? 4 : 0);
  }

  static const Map<String, Object?> amico = {
    'uid': 'u-stella',
    'nome': 'Stella Lieve',
    'icona': 'animale:6',
    'segno': 'pisces',
    'maestro': 'aura',
    'gradino': 12,
    'sigillo': 'M4XR',
    'semaforo': 'verde',
    'tratti': 3,
  };

  @override
  Future<EsitoSociale?> sociale(String porta,
      [Map<String, Object?> corpo = const {}]) async {
    chieste.add((porta, corpo));
    switch (porta) {
      case 'ilMioProfiloNelCerchio':
      case 'aggiornaIlProfiloNelCerchio':
        return EsitoSociale(dati: {
          'uid': 'u-io',
          'sigillo': sigillo,
          'nome': nome,
          'icona': corpo['icona'] ?? 'segno:4',
          'visibilita': corpo['visibilita'] ?? 'amici',
          'visibilitaEffettiva': corpo['visibilita'] ?? 'amici',
          'chiPuoInvitare': 'tutti',
          'nomeSiRiapre': null,
          'primoNomeLibero': true,
        });
      case 'scegliIlNome':
        return EsitoSociale(dati: {
          'ok': true,
          'profilo': {
            'uid': 'u-io',
            'sigillo': sigillo,
            'nome': corpo['nome'],
            'icona': 'segno:4',
            'visibilita': 'amici',
            'visibilitaEffettiva': 'amici',
            'chiPuoInvitare': 'tutti',
            'primoNomeLibero': false,
          },
        });
      case 'ilMioCerchio':
        return EsitoSociale(dati: {
          'amici': amici ? [amico] : [],
          'ricevuti': [
            {
              'uid': 'u-corvo',
              'nome': 'Eco Corvo Mite',
              'icona': 'animale:3',
              'segno': 'scorpio',
              'maestro': 'caligo',
              'semaforo': 'arancionePieno',
            },
          ],
          'inviati': [
            {
              'uid': 'u-ambra',
              'nome': 'Ambra Toro Lunare',
              'icona': 'segno:1',
              'segno': 'taurus',
              'semaforo': 'arancioneChiaro',
            },
          ],
          'bloccati': [
            {'uid': 'u-x', 'nome': 'Velo Nodo Vigile', 'sigillo': 'Z9P0'},
          ],
          'posti': 15,
          'segniOggi': 2,
          'segniAlGiorno': 20,
          'segni': [
            {
              'id': 's1',
              'segno': 'lunaPerTe',
              'verso': 'ricevuto',
              'con': 'u-stella',
              'nomeCon': 'Stella Lieve',
              'maestroCon': 'aura',
              'quando': 1,
            },
            {
              'id': 's2',
              'segno': 'tiPenso',
              'verso': 'mandato',
              'con': 'u-stella',
              'nomeCon': 'Stella Lieve',
              'quando': 2,
            },
          ],
          'doni': [
            {
              'id': 'd1',
              'dono': 'scintilla',
              'da': 'u-stella',
              'nomeDa': 'Stella Lieve'
            },
          ],
        });
      case 'laTendinaDelCerchio':
        return EsitoSociale(dati: {
          'amiciPresenti': amiciPresenti ??
              const [
                {
                  'uid': 'u-stella',
                  'nome': 'Stella Lieve',
                  'icona': 'animale:6',
                  'segno': 'pisces',
                  'maestro': 'aura',
                  'arte': 'tarocchi',
                },
              ],
          'perArte': {'tarocchi': 14, 'viaggio': 7, 'cerchio': 3, 'rune': 5},
          'somiglianti': [
            {
              'uid': 'u-s1',
              'nome': 'Brace Leone Audace',
              'icona': 'segno:4',
              'segno': 'leo',
              'criterio': 'stessoSegno',
              'semaforo': 'spento',
              'invitabile': true,
            },
            {
              'uid': 'u-s2',
              'nome': 'Onda Gufo Serale',
              'icona': 'animale:5',
              'segno': 'cancer',
              'maestro': 'medora',
              'criterio': 'stessoMaestro',
              'semaforo': 'spento',
              'invitabile': false,
            },
          ],
          'io': {'visibilita': 'amici'},
        });
      case 'ilCodiceDellInvito':
        return EsitoSociale(dati: {
          'codice': corpo['tipo'] == 'vicino' ? 'K7Q2M9' : 'AB12CD34',
          'scade': DateTime.now()
              .add(const Duration(minutes: 5))
              .millisecondsSinceEpoch,
        });
      case 'leggiIlCodice':
        return const EsitoSociale(dati: {
          'valido': true,
          'chi': {
            'uid': 'u-stella',
            'nome': 'Stella Lieve',
            'icona': 'animale:6',
            'segno': 'pisces',
            'maestro': 'aura',
          },
          'semaforo': 'spento',
        });
      // Gli Enigmi del Cerchio, ordine FF.
      case 'ilMioRitratto':
        if (corpo['tratti'] is List) {
          ritratto = [...corpo['tratti'] as List<int>];
        }
        return EsitoSociale(dati: {
          'ok': true,
          'tratti': ritratto,
          'fuoriDaiGiochi': corpo['fuoriDaiGiochi'] == true,
          'archetipo': corpo['archetipo'],
          'animale': corpo['animale'],
        });
      case 'gliEnigmi':
        return EsitoSociale(
            dati:
                GliEnigmiFinti.vista(ritrattoCompilato: ritratto.length == 20));
      case 'unIndovinello':
        return switch (corpo['azione']) {
          'apri' => ritratto.length == 20
              ? EsitoSociale(dati: GliEnigmiFinti.partita())
              : const EsitoSociale(dati: {'ok': false, 'perche': 'ritratto'}),
          'indizio' => const EsitoSociale(dati: {
              'ok': true,
              'indizio': {'fonte': 'elemento', 'valore': 'aria'},
              'n': 1,
              'costo': 0,
              'costoProssimo': 5,
            }),
          _ => const EsitoSociale(dati: {
              'ok': true,
              'giusta': true,
              'punti': 2,
              'era': 'u-orione'
            }),
        };
      default:
        return const EsitoSociale(dati: {'ok': true});
    }
  }
}
