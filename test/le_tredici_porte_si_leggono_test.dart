// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/face/face_trait.dart';
import 'package:esoteric_circle/features/maestri/chat/chat_openers.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LE TREDICI PORTE SI LEGGONO.** Ordine EI voce 01, 23 settembre 2026.
///
/// ## PERCHE' ESISTE, VISTO CHE UNA GUARDIA C'ERA GIA'
///
/// La voce EB.01 era stata dichiarata chiusa e non portava **nessuna prova
/// apribile**: il fondatore, per controllarla, doveva leggere il codice. La
/// guardia che c'era, `la_chat_sa_a_cosa_rispondono_le_carte`, misura la cosa
/// giusta ma la misura **dentro il codice**, per nome di funzione e per
/// presenza di parametro.
///
/// Questa scrive su disco **cio' che una persona legge davvero** quando tocca
/// "Parlane con il Maestro", tutte e tredici le porte una sotto l'altra, e
/// pretende che quel file esista e sia pieno. Non sostituisce l'altra: le
/// mette accanto la cosa che l'altra non puo' dare, cioe' un file che si apre
/// e si guarda in trenta secondi.
///
/// ## LA COSA CHE IL CENSIMENTO HA CHIARITO, E VA DETTA
///
/// Delle tredici porte, **soltanto due possono portare una domanda della
/// persona**: la Stesa e il Consiglio, perche' sono le uniche due arti in cui
/// la persona **una domanda la pone**. Le altre undici nascono da un gesto o
/// da un dato, non da una domanda: l'Oroscopo dal segno, la Runa dalla gettata,
/// il Viso dal tratto. Pretendere che portino una domanda che non esiste
/// sarebbe pretendere che se la inventino.
void main() {
  /// Le tredici porte, ciascuna col suo esempio realistico e con la
  /// dichiarazione di **che cosa porta**: la domanda della persona, oppure il
  /// dato da cui nasce.
  final porte = <String, ({String testo, String porta})>{
    'Stesa di Tarocchi': (
      porta: 'LA DOMANDA DELLA PERSONA piu\' le carte col verso',
      testo: ChatOpeners.stesa(
        ['Il Papa', 'Re di Spade rovesciato', 'Dieci di Spade'],
        domanda: 'Lavoro e carriera',
      ),
    ),
    'Consiglio dei Maestri': (
      porta: 'LA DOMANDA DELLA PERSONA, per intero',
      testo: ChatOpeners.consiglio(
          'Devo accettare il trasferimento che mi hanno proposto?'),
    ),
    'Animale Guida': (
      porta: 'il nome dell\'animale, col suo articolo dal catalogo',
      testo: ChatOpeners.animale('Lince'),
    ),
    'Runa del Tramonto': (
      porta: 'la runa della sera e il suo verso',
      testo: ChatOpeners.runaTramonto('Isa', 'diritta'),
    ),
    'Estrazione delle Rune': (
      porta: 'la gettata e le rune uscite',
      testo: ChatOpeners.runa('Le tre Norne', ['Fehu', 'Isa', 'Raidho']),
    ),
    'Archetipo': (
      porta: 'l\'archetipo col suo articolo',
      testo: ChatOpeners.archetipo('il Costruttore'),
    ),
    // **Il nome del tratto si prende dall'enum vero, e la prima stesura non lo
    // faceva.** Avevo scritto a mano `('zigomi', 'alti e larghi')` e il testo
    // usciva *"Il mio tratto dominante e' gli alti e larghi"*, che sembrava un
    // difetto della lingua. Non lo era: i nomi veri sono `Zigomi morbidi`,
    // `Sopracciglia folte`, e l'articolo li accorda bene. **Un esempio
    // inventato fa vedere difetti che non esistono e nasconde quelli veri**:
    // qui il dato viene da `FaceTrait`.
    'Costellazione del Viso': (
      porta: 'la categoria del tratto e il tratto',
      testo: ChatOpeners.viso(
        FaceTrait.zigomiMorbidi.categoria.name,
        FaceTrait.zigomiMorbidi.nome,
      ),
    ),
    'Oroscopo': (
      porta: 'il segno',
      testo: ChatOpeners.oroscopo('Capricorno'),
    ),
    'Sinastria VIP': (
      porta: 'il nome e il punteggio',
      testo: ChatOpeners.sinastria('Frida Kahlo', 78),
    ),
    'Sigillo dell\'Intenzione': (
      porta: 'l\'intenzione scritta dalla persona',
      testo: ChatOpeners.sigillo('Trovare il coraggio di dire di no'),
    ),
    'Soffio del Destino': (
      porta: 'il responso del soffio',
      testo: ChatOpeners.soffio(
          'Quello che lasci andare stasera non ti serviva piu\''),
    ),
    'Arcano dell\'Alba': (
      porta: 'la carta col verso e il gesto del mattino',
      testo: ChatOpeners.arcanoAlba('La Stella diritta', 'aprire la finestra'),
    ),
    'Sigillo del Sogno': (
      porta: 'il responso della notte',
      testo: ChatOpeners.sogno(
          'La Luna cala in Cancro: stanotte custodisci invece di cercare'),
    ),
  };

  test('tutte e tredici le porte compongono un testo che una persona legge',
      () {
    // **Il cardinale**, e qui e' scritto a mano: se qualcuno svuotasse la
    // mappa, questa prova scriverebbe un file vuoto e sarebbe verde.
    cardinaleMinimo(porte.length, 13,
        cosa: 'porte di approfondimento verso un Maestro',
        perche: 'Se una porta sparisse dalla mappa, il file di prova non la '
            'mostrerebbe e nessuno se ne accorgerebbe.');

    final magre = <String>[];
    for (final e in porte.entries) {
      final t = e.value.testo.trim();
      // Una porta che compone due parole non porta niente: il Maestro
      // riceverebbe una domanda muta come quella che ha fatto nascere
      // l'ordine EB.
      if (t.length < 25) magre.add('${e.key}: "$t"');
      if (!t.endsWith('?') && !t.contains('.') && !t.contains('«')) {
        magre.add('${e.key}: non porta ne\' una domanda ne\' un dato');
      }
    }
    expect(magre, isEmpty, reason: magre.join('\n'));
  });

  test('le due porte che nascono da una domanda la portano per intero', () {
    // **La cosa vera da provare**, e la sola che distingue questa voce: le
    // carte rispondono a una domanda, e senza quella domanda il Maestro
    // interpreta tre carte nel vuoto. E' il difetto che il fondatore ha visto
    // il 21 settembre 2026.
    // **La domanda si cerca senza il segno finale, ed e' una correzione
    // mia.** La prima stesura pretendeva il punto interrogativo: i
    // compositori lo tolgono apposta, perche' la domanda finisce dentro le
    // virgolette basse e il periodo prosegue. Pretendere il segno misurava la
    // punteggiatura, non il fatto che la domanda ci sia.
    const domanda = 'Devo lasciare il lavoro che ho adesso';
    final stesa =
        ChatOpeners.stesa(['Il Matto', 'La Torre'], domanda: '$domanda?');
    expect(stesa, contains(domanda),
        reason: 'la Stesa apre la chat senza la domanda a cui le carte '
            'rispondevano');
    expect(stesa, contains('Il Matto'),
        reason: 'la Stesa apre la chat senza le carte');

    final consiglio = ChatOpeners.consiglio('$domanda?');
    expect(consiglio, contains('Devo lasciare il lavoro che ho adesso'),
        reason: 'il Consiglio apre una conversazione che non sa di cosa si '
            'stava parlando');
  });

  test('la prova della voce EI.01 resta scritta su disco', () {
    // **La regola della casa, ordine EH voce 02**: una voce si chiude con una
    // prova che si puo' aprire. Nasce qui invece di essere copiata a mano,
    // cosi' a ogni giro si rigenera o cade con la prova.
    final b = StringBuffer()
      ..writeln('LE TREDICI PORTE DI APPROFONDIMENTO VERSO UN MAESTRO')
      ..writeln('Ordine EI voce 01, che riapre la voce EB.01.')
      ..writeln()
      ..writeln('Per ogni porta: il testo che compare nel campo della chat, '
          'esattamente come lo legge una persona prima di inviarlo.')
      ..writeln('Ordine DX voce 01: il testo ASPETTA nel campo e parte solo '
          'quando l\'utente invia.')
      ..writeln();
    var n = 0;
    for (final e in porte.entries) {
      n++;
      b
        ..writeln('--- $n. ${e.key}')
        ..writeln('    porta: ${e.value.porta}')
        ..writeln('    testo: ${e.value.testo}')
        ..writeln();
    }
    b
      ..writeln('DELLE TREDICI, DUE NASCONO DA UNA DOMANDA DELLA PERSONA:')
      ..writeln('la Stesa di Tarocchi e il Consiglio dei Maestri, e tutte e '
          'due la portano per intero.')
      ..writeln('Le altre undici nascono da un gesto o da un dato, non da una '
          'domanda, e portano quel dato.');

    final cartella = Directory('docs/collaudo/EI')..createSync(recursive: true);
    final f = File('${cartella.path}/tredici_porte.txt')
      ..writeAsStringSync(b.toString());
    print('ORDINE EI VOCE 01: porte scritte nella prova $n');
    expect(n, 13);
    expect(f.lengthSync(), greaterThan(900));
  });
}
