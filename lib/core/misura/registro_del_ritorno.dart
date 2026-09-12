import 'dart:async';

import '../../services/server/porta_del_cerchio.dart';
import 'misura_del_ritorno.dart';

/// IL REGISTRO DEL RITORNO: chi manda gli eventi, e a quali condizioni.
/// Ordine CC voce 09.
///
/// **Perche' una classe e non una riga sparsa.** Una misura chiamata da venti
/// punti diversi diventa venti regole diverse sul consenso: qui la regola e'
/// una, e i venti punti chiamano [segna].
///
/// **Non blocca mai niente.** Ogni chiamata e' senza attesa e ogni guasto
/// muore qui dentro: una schermata non deve rallentare perche' una misura non
/// e' partita, e chi legge un responso non deve saperlo.
class RegistroDelRitorno {
  RegistroDelRitorno({required PortaDelCerchio porta}) : _porta = porta;

  final PortaDelCerchio _porta;

  /// **IL REGISTRO CORRENTE, e perche' e' statico.**
  ///
  /// I cinque gesti che questa voce misura nascono in punti che NON hanno un
  /// BuildContext: la porta della condivisione e' una classe di soli metodi
  /// statici, e il tocco su una notifica arriva prima di qualunque widget.
  /// Pretendere un provider in un servizio condiviso, in questo progetto, ha
  /// gia' fatto cadere quaranta prove lontane dal punto toccato.
  ///
  /// **Nullo di suo, e nullo resta nelle prove**: chi non lo imposta non
  /// misura niente, e nessuna schermata montata da sola cambia comportamento
  /// perche' questa voce esiste.
  static RegistroDelRitorno? corrente;

  /// La via breve per i punti che hanno un gesto e non hanno un contesto di
  /// widget: se nessuno ha acceso la misura, non succede niente.
  static void segnalo(EventoDelRitorno evento, {String? contesto}) {
    corrente?.segnaSenzaAspettare(evento, contesto: contesto);
  }

  /// Il consenso letto una volta e tenuto: leggerlo dal disco a ogni gesto
  /// vorrebbe dire un accesso al disco per ogni tocco.
  ConsensoAllaMisura? _consenso;

  /// **QUANTI EVENTI AL MASSIMO IN UNA SESSIONE.** Ordine CC voce 09.
  ///
  /// Non e' un limite di comodo: senza, un guasto che chiama [segna] in un
  /// ciclo scriverebbe migliaia di righe sul server, e la prima persona ad
  /// accorgersene sarebbe il conto di fine mese. Cinquanta eventi coprono
  /// abbondantemente una sessione vera, che ne fa una decina.
  static const int quantiPerSessione = 50;

  int _mandati = 0;

  /// Quanti eventi sono stati mandati in questa sessione. Pubblico perche' e'
  /// la misura che le prove guardano, invece di frugare nel server finto.
  int get mandati => _mandati;

  /// Rilegge il consenso dal disco. Da chiamare quando la persona risponde
  /// alla domanda, cosi' il primo evento dopo il si' parte davvero.
  Future<void> rileggiIlConsenso() async {
    _consenso = await ConsensoDellaMisura.letto();
  }

  /// **SEGNA UN EVENTO, se e solo se qualcuno lo ha concesso.**
  ///
  /// Torna vero solo quando l'evento e' partito davvero: serve alle prove, che
  /// altrimenti non potrebbero distinguere "non mandato perche' negato" da
  /// "non mandato perche' la rete non c'era".
  Future<bool> segna(EventoDelRitorno evento, {String? contesto}) async {
    _consenso ??= await ConsensoDellaMisura.letto();
    if (_consenso != ConsensoAllaMisura.concesso) return false;
    if (_mandati >= quantiPerSessione) return false;
    if (!_porta.viva) return false;
    _mandati++;
    try {
      return await _porta.segnaLEvento(
        nome: evento.nome,
        // **IL CONTESTO E' UNA PAROLA, e viene da un elenco chiuso**: il nome
        // di un rito, il nome di un dono. Mai un testo scritto dalla persona,
        // mai un identificativo.
        contesto: contesto,
      );
    } catch (errore) {
      // Una misura che non parte non e' un guasto per chi usa l'app.
      return false;
    }
  }

  /// La stessa cosa, per chi non puo' aspettare: si accoda e si dimentica.
  void segnaSenzaAspettare(EventoDelRitorno evento, {String? contesto}) {
    unawaited(segna(evento, contesto: contesto));
  }
}
