import '../core/magic/libro_dei_sigilli.dart';
import 'avvisi_locali.dart';

/// **IL LIBRO DEI SIGILLI DELL'APP, uno solo.** Ordine DO voce 06.
///
/// Parla col servizio di avvisi vero, `avvisiDelCerchio`, cosi' ogni sigillo
/// che entra programma la sua chiamata. Le schermate accettano un Libro
/// iniettato per le prove; l'app vera passa questo.
final LibroDeiSigilli libroDelCerchio =
    LibroDeiSigilli(avvisi: avvisiDelCerchio);
