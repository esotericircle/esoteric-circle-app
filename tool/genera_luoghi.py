# -*- coding: utf-8 -*-
"""Genera assets/data/luoghi.csv, l'elenco offline dei luoghi di nascita.

Sorgente: i dump pubblici di GeoNames, licenza CC BY 4.0.
  IT.zip           tutti i toponimi italiani, da cui si prendono i comuni
  cities15000.zip  le citta' del mondo sopra i 15.000 abitanti

Uscita: un CSV compatto, letto una volta sola all'avvio e indicizzato in
memoria. Niente geocoding online: nessuna chiave, nessun costo, nessuna
latenza, nessuna dipendenza dalla rete, in linea col principio deterministico
su dispositivo.

Formato, tre parti:
  riga 1  versione del formato
  riga 2  tabella dei fusi, separati da |, ognuno come IANA=offsetStandardMin
  righe   nome;aka;area;lat;lng;indiceFuso

`aka` e' il nome alternativo su cui la ricerca combacia comunque, e serve alle
citta' estere che in italiano hanno un altro nome: si mostra Londra, si trova
anche digitando London. `area` e' la sigla della provincia per l'Italia oppure
il nome della nazione in italiano per l'estero, e distingue gli omonimi.

Le righe sono ordinate per popolazione decrescente, prima le italiane. La
ricerca scorre nell'ordine del file, quindi Roma esce prima di Romano di
Lombardia senza bisogno di conservare la popolazione, che non serve ad altro.

Uso:
  python tool/genera_luoghi.py <cartella con IT.txt e cities15000.txt>
"""

import io
import os
import sys

# Nazioni in italiano, per i codici ISO che compaiono davvero nell'elenco.
PAESI = {
    'AD': 'Andorra', 'AE': 'Emirati Arabi Uniti', 'AF': 'Afghanistan',
    'AG': 'Antigua e Barbuda', 'AI': 'Anguilla', 'AL': 'Albania',
    'AM': 'Armenia', 'AO': 'Angola', 'AR': 'Argentina', 'AS': 'Samoa Americane',
    'AT': 'Austria', 'AU': 'Australia', 'AW': 'Aruba', 'AX': 'Isole Aland',
    'AZ': 'Azerbaigian', 'BA': 'Bosnia ed Erzegovina', 'BB': 'Barbados',
    'BD': 'Bangladesh', 'BE': 'Belgio', 'BF': 'Burkina Faso', 'BG': 'Bulgaria',
    'BH': 'Bahrein', 'BI': 'Burundi', 'BJ': 'Benin', 'BL': 'Saint Barthelemy',
    'BM': 'Bermuda', 'BN': 'Brunei', 'BO': 'Bolivia',
    'BQ': 'Caraibi Olandesi', 'BR': 'Brasile', 'BS': 'Bahamas', 'BT': 'Bhutan',
    'BW': 'Botswana', 'BY': 'Bielorussia', 'BZ': 'Belize', 'CA': 'Canada',
    'CC': 'Isole Cocos', 'CD': 'Congo', 'CF': 'Repubblica Centrafricana',
    'CG': 'Congo', 'CH': 'Svizzera', 'CI': 'Costa d\'Avorio',
    'CK': 'Isole Cook', 'CL': 'Cile', 'CM': 'Camerun', 'CN': 'Cina',
    'CO': 'Colombia', 'CR': 'Costa Rica', 'CU': 'Cuba', 'CV': 'Capo Verde',
    'CW': 'Curacao', 'CX': 'Isola di Natale', 'CY': 'Cipro',
    'CZ': 'Repubblica Ceca', 'DE': 'Germania', 'DJ': 'Gibuti',
    'DK': 'Danimarca', 'DM': 'Dominica', 'DO': 'Repubblica Dominicana',
    'DZ': 'Algeria', 'EC': 'Ecuador', 'EE': 'Estonia', 'EG': 'Egitto',
    'ER': 'Eritrea', 'ES': 'Spagna', 'ET': 'Etiopia', 'FI': 'Finlandia',
    'FJ': 'Figi', 'FK': 'Isole Falkland', 'FM': 'Micronesia',
    'FO': 'Isole Faroe', 'FR': 'Francia', 'GA': 'Gabon', 'GB': 'Regno Unito',
    'GD': 'Grenada', 'GE': 'Georgia', 'GF': 'Guyana Francese',
    'GG': 'Guernsey', 'GH': 'Ghana', 'GI': 'Gibilterra', 'GL': 'Groenlandia',
    'GM': 'Gambia', 'GN': 'Guinea', 'GP': 'Guadalupa',
    'GQ': 'Guinea Equatoriale', 'GR': 'Grecia',
    'GS': 'Georgia del Sud', 'GT': 'Guatemala', 'GU': 'Guam',
    'GW': 'Guinea-Bissau', 'GY': 'Guyana', 'HK': 'Hong Kong', 'HN': 'Honduras',
    'HR': 'Croazia', 'HT': 'Haiti', 'HU': 'Ungheria', 'ID': 'Indonesia',
    'IE': 'Irlanda', 'IL': 'Israele', 'IM': 'Isola di Man', 'IN': 'India',
    'IQ': 'Iraq', 'IR': 'Iran', 'IS': 'Islanda', 'JE': 'Jersey',
    'JM': 'Giamaica', 'JO': 'Giordania', 'JP': 'Giappone', 'KE': 'Kenya',
    'KG': 'Kirghizistan', 'KH': 'Cambogia', 'KI': 'Kiribati', 'KM': 'Comore',
    'KN': 'Saint Kitts e Nevis', 'KP': 'Corea del Nord',
    'KR': 'Corea del Sud', 'KW': 'Kuwait', 'KY': 'Isole Cayman',
    'KZ': 'Kazakistan', 'LA': 'Laos', 'LB': 'Libano', 'LC': 'Santa Lucia',
    'LI': 'Liechtenstein', 'LK': 'Sri Lanka', 'LR': 'Liberia', 'LS': 'Lesotho',
    'LT': 'Lituania', 'LU': 'Lussemburgo', 'LV': 'Lettonia', 'LY': 'Libia',
    'MA': 'Marocco', 'MC': 'Monaco', 'MD': 'Moldavia', 'ME': 'Montenegro',
    'MF': 'Saint Martin', 'MG': 'Madagascar', 'MH': 'Isole Marshall',
    'MK': 'Macedonia del Nord', 'ML': 'Mali', 'MM': 'Birmania',
    'MN': 'Mongolia', 'MO': 'Macao', 'MP': 'Isole Marianne Settentrionali',
    'MQ': 'Martinica', 'MR': 'Mauritania', 'MS': 'Montserrat', 'MT': 'Malta',
    'MU': 'Mauritius', 'MV': 'Maldive', 'MW': 'Malawi', 'MX': 'Messico',
    'MY': 'Malesia', 'MZ': 'Mozambico', 'NA': 'Namibia',
    'NC': 'Nuova Caledonia', 'NE': 'Niger', 'NF': 'Isola Norfolk',
    'NG': 'Nigeria', 'NI': 'Nicaragua', 'NL': 'Paesi Bassi', 'NO': 'Norvegia',
    'NP': 'Nepal', 'NR': 'Nauru', 'NU': 'Niue', 'NZ': 'Nuova Zelanda',
    'OM': 'Oman', 'PA': 'Panama', 'PE': 'Peru', 'PF': 'Polinesia Francese',
    'PG': 'Papua Nuova Guinea', 'PH': 'Filippine', 'PK': 'Pakistan',
    'PL': 'Polonia', 'PM': 'Saint Pierre e Miquelon', 'PN': 'Isole Pitcairn',
    'PR': 'Portorico', 'PS': 'Palestina', 'PT': 'Portogallo', 'PW': 'Palau',
    'PY': 'Paraguay', 'QA': 'Qatar', 'RE': 'Riunione', 'RO': 'Romania',
    'RS': 'Serbia', 'RU': 'Russia', 'RW': 'Ruanda', 'SA': 'Arabia Saudita',
    'SB': 'Isole Salomone', 'SC': 'Seychelles', 'SD': 'Sudan', 'SE': 'Svezia',
    'SG': 'Singapore', 'SH': 'Sant\'Elena', 'SI': 'Slovenia',
    'SJ': 'Svalbard', 'SK': 'Slovacchia', 'SL': 'Sierra Leone',
    'SM': 'San Marino', 'SN': 'Senegal', 'SO': 'Somalia', 'SR': 'Suriname',
    'SS': 'Sud Sudan', 'ST': 'Sao Tome e Principe', 'SV': 'El Salvador',
    'SX': 'Sint Maarten', 'SY': 'Siria', 'SZ': 'Eswatini',
    'TC': 'Isole Turks e Caicos', 'TD': 'Ciad', 'TF': 'Terre Australi Francesi',
    'TG': 'Togo', 'TH': 'Thailandia', 'TJ': 'Tagikistan',
    'TL': 'Timor Est', 'TM': 'Turkmenistan', 'TN': 'Tunisia', 'TO': 'Tonga',
    'TR': 'Turchia', 'TT': 'Trinidad e Tobago', 'TV': 'Tuvalu', 'TW': 'Taiwan',
    'TZ': 'Tanzania', 'UA': 'Ucraina', 'UG': 'Uganda', 'US': 'Stati Uniti',
    'UY': 'Uruguay', 'UZ': 'Uzbekistan', 'VA': 'Citta del Vaticano',
    'VC': 'Saint Vincent e Grenadine', 'VE': 'Venezuela',
    'VG': 'Isole Vergini Britanniche', 'VI': 'Isole Vergini Americane',
    'VN': 'Vietnam', 'VU': 'Vanuatu', 'WF': 'Wallis e Futuna', 'WS': 'Samoa',
    'XK': 'Kosovo', 'YE': 'Yemen', 'YT': 'Mayotte', 'ZA': 'Sudafrica',
    'ZM': 'Zambia', 'ZW': 'Zimbabwe',
}

# Le citta' estere che in italiano si chiamano in un altro modo. Il nome
# mostrato e' quello italiano, l'aka tiene il nome di GeoNames cosi' si trovano
# in tutti e due i modi. La voce di GeoNames corrispondente viene soppressa,
# riconosciuta dalle coordinate, per non mostrare due volte lo stesso posto.
ESONIMI = {
    'London': 'Londra', 'Paris': 'Parigi', 'Munich': 'Monaco di Baviera',
    'Cologne': 'Colonia', 'Frankfurt am Main': 'Francoforte sul Meno',
    'Nuremberg': 'Norimberga', 'Stuttgart': 'Stoccarda', 'Hamburg': 'Amburgo',
    'Hanover': 'Hannover', 'Dresden': 'Dresda', 'Aachen': 'Aquisgrana',
    'Vienna': 'Vienna', 'Salzburg': 'Salisburgo', 'Innsbruck': 'Innsbruck',
    'Zurich': 'Zurigo', 'Geneva': 'Ginevra', 'Basel': 'Basilea',
    'Bern': 'Berna', 'Lucerne': 'Lucerna', 'Lausanne': 'Losanna',
    'Brussels': 'Bruxelles', 'Antwerp': 'Anversa', 'Ghent': 'Gand',
    'Bruges': 'Bruges', 'Liege': 'Liegi', 'The Hague': 'L\'Aia',
    'Nijmegen': 'Nimega', 'Maastricht': 'Maastricht',
    'Copenhagen': 'Copenaghen', 'Gothenburg': 'Goteborg',
    'Helsinki': 'Helsinki', 'Reykjavik': 'Reykjavik', 'Moscow': 'Mosca',
    'Saint Petersburg': 'San Pietroburgo', 'Nizhniy Novgorod': 'Nizni Novgorod',
    'Warsaw': 'Varsavia', 'Cracow': 'Cracovia', 'Krakow': 'Cracovia',
    'Wroclaw': 'Breslavia', 'Gdansk': 'Danzica', 'Poznan': 'Poznan',
    'Prague': 'Praga', 'Brno': 'Brno', 'Bratislava': 'Bratislava',
    'Bucharest': 'Bucarest', 'Belgrade': 'Belgrado', 'Zagreb': 'Zagabria',
    'Ljubljana': 'Lubiana', 'Sarajevo': 'Sarajevo', 'Skopje': 'Skopje',
    'Sofia': 'Sofia', 'Athens': 'Atene', 'Thessaloniki': 'Salonicco',
    'Istanbul': 'Istanbul', 'Izmir': 'Smirne', 'Ankara': 'Ancara',
    'Nicosia': 'Nicosia', 'Valletta': 'La Valletta', 'Lisbon': 'Lisbona',
    'Oporto': 'Porto', 'Seville': 'Siviglia', 'Sevilla': 'Siviglia',
    'Barcelona': 'Barcellona', 'Zaragoza': 'Saragozza', 'Cordoba': 'Cordova',
    'Bilbao': 'Bilbao', 'Marseille': 'Marsiglia', 'Lyon': 'Lione',
    'Toulouse': 'Tolosa', 'Nice': 'Nizza', 'Bordeaux': 'Bordeaux',
    'Strasbourg': 'Strasburgo', 'Dublin': 'Dublino', 'Cork': 'Cork',
    'Edinburgh': 'Edimburgo', 'Cardiff': 'Cardiff', 'Cairo': 'Il Cairo',
    'Alexandria': 'Alessandria d\'Egitto', 'Algiers': 'Algeri',
    'Tunis': 'Tunisi', 'Tripoli': 'Tripoli', 'Marrakesh': 'Marrakech',
    'Fes': 'Fez', 'Damascus': 'Damasco', 'Aleppo': 'Aleppo',
    'Beirut': 'Beirut', 'Jerusalem': 'Gerusalemme', 'Baghdad': 'Baghdad',
    'Mosul': 'Mosul', 'Tehran': 'Teheran', 'Isfahan': 'Isfahan',
    'Riyadh': 'Riad', 'Mecca': 'La Mecca', 'Medina': 'Medina',
    'Kuwait City': 'Kuwait City', 'Doha': 'Doha', 'Muscat': 'Mascate',
    'Sanaa': 'Sana\'a', 'Addis Ababa': 'Addis Abeba', 'Khartoum': 'Khartum',
    'Mogadishu': 'Mogadiscio', 'Nairobi': 'Nairobi',
    'Dar es Salaam': 'Dar es Salaam', 'Kinshasa': 'Kinshasa',
    'Abidjan': 'Abidjan', 'Accra': 'Accra', 'Dakar': 'Dakar',
    'Cape Town': 'Citta del Capo', 'Pretoria': 'Pretoria',
    'New York City': 'New York', 'Philadelphia': 'Filadelfia',
    'New Orleans': 'New Orleans', 'Mexico City': 'Citta del Messico',
    'Guadalajara': 'Guadalajara', 'Havana': 'L\'Avana',
    'Santo Domingo': 'Santo Domingo', 'Sao Paulo': 'San Paolo',
    'Brasilia': 'Brasilia', 'Salvador': 'Salvador de Bahia',
    'Lima': 'Lima', 'Bogota': 'Bogota', 'Santiago': 'Santiago del Cile',
    'Montevideo': 'Montevideo', 'Asuncion': 'Asuncion', 'Quito': 'Quito',
    'Caracas': 'Caracas', 'Beijing': 'Pechino', 'Nanjing': 'Nanchino',
    'Guangzhou': 'Canton', 'Xian': 'Xi\'an', 'Lhasa': 'Lhasa',
    'Taipei': 'Taipei', 'Seoul': 'Seul', 'Pyongyang': 'Pyongyang',
    'Kyoto': 'Kyoto', 'Osaka': 'Osaka', 'New Delhi': 'Nuova Delhi',
    'Mumbai': 'Mumbai', 'Kolkata': 'Calcutta', 'Chennai': 'Madras',
    'Karachi': 'Karachi', 'Lahore': 'Lahore', 'Kathmandu': 'Kathmandu',
    'Colombo': 'Colombo', 'Bangkok': 'Bangkok', 'Phnom Penh': 'Phnom Penh',
    'Hanoi': 'Hanoi', 'Ho Chi Minh City': 'Ho Chi Minh',
    'Jakarta': 'Giacarta', 'Kuala Lumpur': 'Kuala Lumpur',
    'Manila': 'Manila', 'Singapore': 'Singapore', 'Sydney': 'Sydney',
    'Melbourne': 'Melbourne', 'Auckland': 'Auckland',
    'Wellington': 'Wellington',
}

# Offset standard di riserva, in minuti, per i pochi fusi che dovessero mancare
# da timeZones.txt. La fonte vera degli offset e' quel file, colonna rawOffset,
# cosi' nessun numero e' scritto a mano. Non e' l'offset del giorno di nascita,
# che dipende dall'ora legale di quell'anno: quello lo mette il motore a
# effemeridi. Qui serve solo a orientare la carta.
OFFSET_NOTI = {
    'Europe/Rome': 60, 'Europe/London': 0, 'Europe/Dublin': 0,
    'Europe/Lisbon': 0, 'Atlantic/Canary': 0, 'Atlantic/Reykjavik': 0,
    'Europe/Moscow': 180, 'Europe/Istanbul': 180, 'Europe/Kiev': 120,
    'Europe/Kyiv': 120, 'Europe/Athens': 120, 'Europe/Helsinki': 120,
    'Europe/Bucharest': 120, 'Europe/Sofia': 120, 'Europe/Riga': 120,
    'Europe/Tallinn': 120, 'Europe/Vilnius': 120, 'Europe/Kaliningrad': 120,
    'Asia/Jerusalem': 120, 'Africa/Cairo': 120, 'Africa/Johannesburg': 120,
    'Asia/Dubai': 240, 'Asia/Tehran': 210, 'Asia/Karachi': 300,
    'Asia/Kolkata': 330, 'Asia/Kathmandu': 345, 'Asia/Dhaka': 360,
    'Asia/Bangkok': 420, 'Asia/Jakarta': 420, 'Asia/Shanghai': 480,
    'Asia/Hong_Kong': 480, 'Asia/Taipei': 480, 'Asia/Singapore': 480,
    'Asia/Kuala_Lumpur': 480, 'Asia/Manila': 480, 'Asia/Seoul': 540,
    'Asia/Tokyo': 540, 'Asia/Pyongyang': 540,
    'Australia/Sydney': 600, 'Australia/Melbourne': 600,
    'Australia/Brisbane': 600, 'Australia/Perth': 480,
    'Australia/Adelaide': 570, 'Pacific/Auckland': 720,
    'America/New_York': -300, 'America/Toronto': -300,
    'America/Chicago': -360, 'America/Denver': -420,
    'America/Los_Angeles': -480, 'America/Vancouver': -480,
    'America/Anchorage': -540, 'Pacific/Honolulu': -600,
    'America/Mexico_City': -360, 'America/Bogota': -300, 'America/Lima': -300,
    'America/Sao_Paulo': -180, 'America/Argentina/Buenos_Aires': -180,
    'America/Santiago': -240, 'America/Caracas': -240,
    'America/Havana': -300, 'America/Panama': -300,
}


def leggi_fusi(path):
    """Gli offset standard dal dump dei fusi di GeoNames, colonna rawOffset,
    cioe' l'ora legale esclusa. E' la fonte unica: senza, l'offset andrebbe
    stimato dalla longitudine e Lagos, che segue il meridiano di Greenwich ma
    sta un'ora avanti, risulterebbe sbagliata di sessanta minuti."""
    fusi = {}
    with io.open(path, encoding='utf-8') as f:
        next(f)
        for line in f:
            c = line.rstrip('\n').split('\t')
            if len(c) < 5:
                continue
            fusi[c[1]] = int(round(float(c[4]) * 60))
    return fusi


def offset_di(tz, lon, tabella):
    """Offset standard del fuso, in minuti. Prima la tabella di GeoNames, poi
    quella di riserva, e solo in ultimo la longitudine."""
    if tz in tabella:
        return tabella[tz]
    if tz in OFFSET_NOTI:
        return OFFSET_NOTI[tz]
    return int(round(lon / 15.0)) * 60


def leggi_italia(path):
    """I comuni italiani, piu' le localita' popolose che comune non sono, come
    Mestre o Marghera, dove pure si nasce. Le seconde non duplicano mai il nome
    di un comune della stessa provincia."""
    comuni, localita, visti = [], [], set()
    with io.open(path, encoding='utf-8') as f:
        for line in f:
            c = line.rstrip('\n').split('\t')
            if len(c) < 19 or c[8] != 'IT':
                continue
            nome, code, prov = c[1], c[7], c[11]
            if not nome or not prov:
                continue
            pop = int(c[14] or 0)
            riga = (nome, prov, float(c[4]), float(c[5]), c[17], pop)
            if code == 'ADM3':
                comuni.append(riga)
                visti.add((nome.lower(), prov))
            elif code in ('PPLA', 'PPLA2', 'PPLA3', 'PPL', 'PPLL') and pop >= 3000:
                localita.append(riga)
    # Le localita' si aggiungono solo dopo aver visto tutti i comuni, cosi' la
    # deduplica vale sull'insieme completo e non sull'ordine del file.
    extra = []
    for r in localita:
        chiave = (r[0].lower(), r[1])
        if chiave in visti:
            continue
        visti.add(chiave)
        extra.append(r)
    return comuni, extra


# **QUANTI ABITANTI SERVONO PERCHE' UN LUOGO ENTRI. Ordine CC voce 07.**
#
# **Prima era 200.000, e quel numero costringeva la gente a mentire.** Con
# quella soglia il catalogo aveva 3.108 luoghi fuori dall'Italia su 241 paesi,
# e 116 paesi erano rappresentati da UNA SOLA citta': la Francia ne aveva 13,
# la Svizzera 3, l'Albania 1. Chi e' nato a Basilea, a Digione o a Valona non
# trovava la sua citta' e doveva sceglierne un'altra, quindi la sua carta
# natale nasceva su coordinate che non erano le sue. Per una carta natale le
# coordinate NON sono un dettaglio: la longitudine sposta l'ora locale e con
# lei le case, la latitudine sposta l'Ascendente.
#
# **Adesso e' 15.000, e non e' una soglia nuova: e' una potatura tolta.** Il
# file `cities15000.txt` contiene esattamente i luoghi sopra i quindicimila
# abitanti, quindi il vecchio filtro era una seconda potatura sopra la prima.
# Togliendola entra tutto cio' che la fonte ha, che e' anche il criterio piu'
# facile da difendere: **non e' una scelta nostra su chi merita di esistere**,
# e' la fonte per intero.
#
# **Nessuna fonte nuova, quindi nessuna licenza nuova.** E' lo stesso dump
# GeoNames che il catalogo usa dal primo giorno, CC BY 4.0, che consente l'uso
# commerciale a patto di attribuire: l'attribuzione vive dentro l'app, in
# `FontiDeiDati`, e una prova pretende che sia a schermo.
#
# **Cosa resta scoperto, detto e non taciuto.** Chi e' nato in un paese sotto i
# quindicimila abitanti continua a non trovarlo, e sceglie il centro vicino.
# L'unico modo per averli tutti sarebbe `allCountries`, che scompattato pesa
# oltre un gigabyte: non e' un asset che si mette dentro un'app.
SOGLIA_DEL_MONDO = 15000


def leggi_mondo(path):
    """Le citta' del mondo fuori dall'Italia: tutto cio' che la fonte ha sopra
    [SOGLIA_DEL_MONDO] abitanti, piu' tutte le capitali, che contano a
    prescindere dalla dimensione."""
    fuori = []
    with io.open(path, encoding='utf-8') as f:
        for line in f:
            c = line.rstrip('\n').split('\t')
            if len(c) < 19 or c[8] == 'IT':
                continue
            pop = int(c[14] or 0)
            if pop < SOGLIA_DEL_MONDO and c[7] != 'PPLC':
                continue
            paese = PAESI.get(c[8])
            if paese is None:
                continue
            fuori.append((c[1], paese, float(c[4]), float(c[5]), c[17], pop))
    return fuori


def main():
    src = sys.argv[1] if len(sys.argv) > 1 else '.'
    dest = os.path.join('assets', 'data', 'luoghi.csv')

    comuni, frazioni = leggi_italia(os.path.join(src, 'IT.txt'))
    mondo = leggi_mondo(os.path.join(src, 'cities15000.txt'))
    tabella_fusi = leggi_fusi(os.path.join(src, 'timeZones.txt'))

    # L'esonimo prende il posto del nome di GeoNames e se lo tiene come aka.
    # Vale solo per la PRIMA citta' con quel nome, cioe' la piu' popolosa,
    # altrimenti London in Ontario diventerebbe Londra pure lei.
    finali = []
    for nome, prov, lat, lon, tz, pop in sorted(
            comuni + frazioni, key=lambda r: -r[5]):
        finali.append((nome, '', prov, lat, lon, tz, pop))
    usati = set()
    for nome, paese, lat, lon, tz, pop in sorted(mondo, key=lambda r: -r[5]):
        it = ESONIMI.get(nome)
        if it and it != nome and nome not in usati:
            usati.add(nome)
            finali.append((it, nome, paese, lat, lon, tz, pop))
        else:
            finali.append((nome, '', paese, lat, lon, tz, pop))

    # Niente doppioni esatti (nome, area): esistono davvero, per esempio
    # citta' cinesi diverse che condividono la romanizzazione, e in lista due
    # voci uguali producono due chiavi identiche, che per Flutter e' uno
    # schianto (Duplicate keys found). Si tiene la prima, cioe' la piu'
    # popolosa, perche' l'elenco e' gia' in quell'ordine.
    unici, chiavi = [], set()
    for r in finali:
        k = (r[0].lower(), r[2])
        if k in chiavi:
            continue
        chiavi.add(k)
        unici.append(r)
    print('doppioni (nome, area) scartati: %d' % (len(finali) - len(unici)))
    finali = unici

    # Ogni fuso si porta dietro la longitudine della sua citta' piu' popolosa,
    # che serve solo quando il fuso non e' in tabella: il ripiego sul meridiano
    # sbaglia al massimo di un'ora, mentre calcolarlo sulla longitudine zero
    # avrebbe dato l'ora di Greenwich a mezzo mondo.
    fusi = []
    indice = {}
    lon_del_fuso = {}
    for r in finali:
        tz = r[5]
        if tz not in indice:
            indice[tz] = len(fusi)
            fusi.append(tz)
            lon_del_fuso[tz] = r[4]

    righe = ['v1',
             '|'.join('%s=%d' % (t, offset_di(t, lon_del_fuso[t], tabella_fusi))
                      for t in fusi)]
    for nome, aka, area, lat, lon, tz, _pop in finali:
        nome = nome.replace(';', ' ')
        aka = aka.replace(';', ' ')
        area = area.replace(';', ' ')
        righe.append('%s;%s;%s;%.4f;%.4f;%d' %
                     (nome, aka, area, lat, lon, indice[tz]))

    with io.open(dest, 'w', encoding='utf-8', newline='\n') as f:
        f.write('\n'.join(righe) + '\n')

    peso = os.path.getsize(dest)
    print('comuni italiani: %d' % len(comuni))
    print('localita italiane in piu\': %d' % len(frazioni))
    print('estere: %d' % len(mondo))
    print('totale righe: %d' % len(finali))
    print('fusi distinti: %d' % len(fusi))
    print('peso: %d byte (%.2f MiB)' % (peso, peso / 1048576.0))


if __name__ == '__main__':
    main()
