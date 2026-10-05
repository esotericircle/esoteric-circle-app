import 'package:flutter_contacts/flutter_contacts.dart';

/// Un contatto della rubrica come serve alla scelta: un nome e un numero.
/// Vive solo in memoria, dentro la schermata della scelta.
class ContattoDellaRubrica {
  const ContattoDellaRubrica({required this.nome, required this.numero});

  final String nome;
  final String numero;
}

/// LA RUBRICA DEL TELEFONO, LETTA IN MEMORIA E BASTA. Ordine FD voce 06.3.
///
/// **I contatti non escono dal telefono.** Questo file legge la rubrica e
/// restituisce un elenco: non scrive niente su disco, non chiama il server,
/// non conserva niente fra un'apertura e l'altra. Non importa ne' la rete,
/// ne' Firebase, ne' le preferenze, ne' i file: la guardia
/// `la_rubrica_resta_sul_telefono_test.dart` lo pretende. Nessun confronto
/// fra la rubrica e gli iscritti: richiederebbe di mandarci i numeri.
abstract final class LaRubricaDelTelefono {
  /// La lettura vera, sostituibile nelle prove (che non hanno una rubrica).
  static Future<List<ContattoDellaRubrica>> Function() leggi = _dalTelefono;

  static Future<List<ContattoDellaRubrica>> _dalTelefono() async {
    final tutti = await FlutterContacts.getAll(
        properties: {ContactProperty.name, ContactProperty.phone});
    return [
      for (final c in tutti)
        for (final p in c.phones.take(1))
          ContattoDellaRubrica(nome: c.displayName ?? '', numero: p.number),
    ];
  }

  /// La richiesta di sistema, in sola lettura: vero se la persona concede,
  /// anche in parte (iOS 18 lascia scegliere alcuni contatti).
  static Future<bool> Function() richiesta = _richiestaDiSistema;

  static Future<bool> _richiestaDiSistema() async {
    final s = await FlutterContacts.permissions.request(PermissionType.read);
    return s == PermissionStatus.granted || s == PermissionStatus.limited;
  }

  /// Se il permesso c'e' gia': il solo controllo del sistema, che non mostra
  /// nessuna finestra. Sostituibile nelle prove.
  static Future<bool> Function() giaConcessa = _controllo;

  static Future<bool> _controllo() async {
    final s = await FlutterContacts.permissions.check(PermissionType.read);
    return s == PermissionStatus.granted || s == PermissionStatus.limited;
  }

  /// I contatti che si possono scegliere: con un nome e almeno un numero, in
  /// ordine alfabetico senza badare alle maiuscole. FD.06.4.
  static List<ContattoDellaRubrica> scegliibili(
      Iterable<ContattoDellaRubrica> grezzi) {
    final buoni = [
      for (final c in grezzi)
        if (c.nome.trim().isNotEmpty &&
            c.numero.replaceAll(RegExp(r'[^0-9+]'), '').length >= 3)
          ContattoDellaRubrica(nome: c.nome.trim(), numero: c.numero.trim()),
    ];
    buoni.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    return buoni;
  }
}
