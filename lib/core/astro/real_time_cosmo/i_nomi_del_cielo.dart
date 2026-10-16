/// I NOMI ITALIANI DEL CIELO DEL REAL TIME COSMO. Ordine FG parte 2.
///
/// Il catalogo HYG da' le costellazioni con la sigla IAU di tre lettere e le
/// stelle col nome proprio nella forma internazionale dell'IAU (Sirius,
/// Regulus). A schermo la persona legge l'italiano: le 88 costellazioni coi
/// nomi della tradizione astronomica italiana, e le stelle piu' note col nome
/// che hanno in italiano. Le altre restano nella forma IAU, che e' anche
/// quella usata negli atlanti italiani.
library;

const Map<String, String> kCostellazioniInItaliano = {
  'And': 'Andromeda', 'Ant': 'Macchina Pneumatica', 'Aps': 'Uccello del Paradiso',
  'Aqr': 'Acquario', 'Aql': 'Aquila', 'Ara': 'Altare', 'Ari': 'Ariete',
  'Aur': 'Auriga', 'Boo': 'Boote', 'Cae': 'Bulino', 'Cam': 'Giraffa',
  'Cnc': 'Cancro', 'CVn': 'Cani da Caccia', 'CMa': 'Cane Maggiore',
  'CMi': 'Cane Minore', 'Cap': 'Capricorno', 'Car': 'Carena',
  'Cas': 'Cassiopea', 'Cen': 'Centauro', 'Cep': 'Cefeo', 'Cet': 'Balena',
  'Cha': 'Camaleonte', 'Cir': 'Compasso', 'Col': 'Colomba',
  'Com': 'Chioma di Berenice', 'CrA': 'Corona Australe',
  'CrB': 'Corona Boreale', 'Crv': 'Corvo', 'Crt': 'Cratere',
  'Cru': 'Croce del Sud', 'Cyg': 'Cigno', 'Del': 'Delfino', 'Dor': 'Dorado',
  'Dra': 'Dragone', 'Equ': 'Cavallino', 'Eri': 'Eridano', 'For': 'Fornace',
  'Gem': 'Gemelli', 'Gru': 'Gru', 'Her': 'Ercole', 'Hor': 'Orologio',
  'Hya': 'Idra', 'Hyi': 'Idra Maschio', 'Ind': 'Indiano', 'Lac': 'Lucertola',
  'Leo': 'Leone', 'LMi': 'Leone Minore', 'Lep': 'Lepre', 'Lib': 'Bilancia',
  'Lup': 'Lupo', 'Lyn': 'Lince', 'Lyr': 'Lira', 'Men': 'Mensa',
  'Mic': 'Microscopio', 'Mon': 'Unicorno', 'Mus': 'Mosca', 'Nor': 'Squadra',
  'Oct': 'Ottante', 'Oph': 'Ofiuco', 'Ori': 'Orione', 'Pav': 'Pavone',
  'Peg': 'Pegaso', 'Per': 'Perseo', 'Phe': 'Fenice', 'Pic': 'Pittore',
  'Psc': 'Pesci', 'PsA': 'Pesce Australe', 'Pup': 'Poppa', 'Pyx': 'Bussola',
  'Ret': 'Reticolo', 'Sge': 'Freccia', 'Sgr': 'Sagittario',
  'Sco': 'Scorpione', 'Scl': 'Scultore', 'Sct': 'Scudo', 'Ser': 'Serpente',
  'Sex': 'Sestante', 'Tau': 'Toro', 'Tel': 'Telescopio', 'Tri': 'Triangolo',
  'TrA': 'Triangolo Australe', 'Tuc': 'Tucano', 'UMa': 'Orsa Maggiore',
  'UMi': 'Orsa Minore', 'Vel': 'Vele', 'Vir': 'Vergine', 'Vol': 'Pesce Volante',
  'Vul': 'Volpetta',
};

/// Le stelle piu' note col loro nome italiano; le altre restano col nome IAU.
const Map<String, String> kStelleInItaliano = {
  'Sirius': 'Sirio',
  'Canopus': 'Canopo',
  'Arcturus': 'Arturo',
  'Rigil Kentaurus': 'Alfa Centauri',
  'Procyon': 'Procione',
  'Achernar': 'Achernar',
  'Hadar': 'Agena',
  'Acrux': 'Acrux',
  'Aldebaran': 'Aldebaran',
  'Spica': 'Spica',
  'Pollux': 'Polluce',
  'Castor': 'Castore',
  'Regulus': 'Regolo',
  'Polaris': 'Stella Polare',
  'Alcyone': 'Alcione',
  'Bellatrix': 'Bellatrix',
  'Fomalhaut': 'Fomalhaut',
  'Deneb': 'Deneb',
  'Mizar': 'Mizar',
  'Vindemiatrix': 'Vendemmiatrice',
};
