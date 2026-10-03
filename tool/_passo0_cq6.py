# -*- coding: utf-8 -*-
"""CQ6.12: il PASSO 0 chiede a git quanto sei indietro, invece di
confrontare con uno sha scritto a mano che invecchia a ogni consegna."""
import sys
sys.path.insert(0, 'tool')
from _innesta_tmp import sostituisci  # noqa: E402

NL = chr(10)
A = chr(39)
P = 'docs/ordini/DISTRIBUZIONI_DAL_TUO_PC.md'
RAMO = 'claude/esoteric-circle-master-order-e798aj'

vecchio = (
"**Perche" + A + " viene prima di tutto.** Nella tua cartella," + NL +
"`C:" + chr(92) + "Users" + chr(92) + "user" + chr(92) + "Desktop" + chr(92) +
"esoteric-circle-app`, il lavoro dell" + A + "ordine CG oggi" + NL +
"**non c" + A + "e" + A + "**. Verificato il 31 agosto 2026: "
"`docs/ordini/ORDINE_CG_MANIFESTO.md`" + NL +
"non c" + A + "e" + A + ", `functions/src/lapidi.ts` non c" + A + "e" + A +
", e il puntatore del ramo non viene" + NL +
"toccato dal 15 agosto 2026. **Se distribuissi da li" + A + " adesso, manderesti in"
+ NL + "produzione la versione di due ordini fa.**" + NL + NL +
"```powershell" + NL +
"cd C:" + chr(92) + "Users" + chr(92) + "user" + chr(92) + "Desktop" +
chr(92) + "esoteric-circle-app" + NL +
"git pull --ff-only" + NL +
"```" + NL + NL +
"**Cosa devi leggere.** Un elenco di file cambiati e in fondo una riga tipo"
+ NL + "`Fast-forward`. Poi verifica con questo:" + NL + NL +
"```powershell" + NL +
"git log --oneline -1" + NL +
"```" + NL + NL +
"**Cosa devi leggere**: la riga deve cominciare con lo sha della testa di"
+ NL +
"oggi oppure con uno piu" + A + " recente, e NON con `078d24b4`. **La testa del 1"
+ NL +
"settembre 2026, ordine CN, comincia con ``345b5ccb``.**" + NL)

nuovo = (
"**Perche" + A + " viene prima di tutto.** I comandi di distribuzione mandano in"
+ NL +
"produzione **i file che hai sul disco**, non il ramo: da una cartella vecchia"
+ NL +
"manderesti su la versione di due ordini fa, e da una cartella vecchia una"
+ NL +
"funzione appena scritta semplicemente non esiste." + NL + NL +
"**IL CONTROLLO E" + A + " CAMBIATO, E LA RAGIONE VA LETTA. Ordine CQ voce 6.12,"
+ NL + "4 settembre 2026.**" + NL + NL +
"Fino a oggi questo passo diceva: *la riga NON deve cominciare con"
+ NL +
"`078d24b4`*, e nominava lo sha della testa di allora. Il 4 settembre la"
+ NL +
"cartella era ferma a `24eaf172`, che non e" + A + " `078d24b4`: **il controllo"
+ NL +
"diceva di stare a posto mentre l" + A + "albero era indietro di sessantotto"
+ NL +
"commit**, tre giorni di lavoro. Poi il comando di distribuzione ha risposto"
+ NL +
"*No function matches the filter*, e la funzione sembrava non essere mai stata"
+ NL + "scritta. Era scritta e spinta." + NL + NL +
"**Uno sha scritto a mano invecchia a ogni consegna, e un controllo che"
+ NL +
"invecchia diventa un permesso.** Adesso il numero lo chiede a git, e vale"
+ NL + "sempre." + NL + NL +
"```powershell" + NL +
"cd C:" + chr(92) + "Users" + chr(92) + "user" + chr(92) + "Desktop" +
chr(92) + "esoteric-circle-app" + NL +
"git fetch origin" + NL +
"git rev-list --count HEAD..origin/" + RAMO + NL +
"```" + NL + NL +
"**Cosa devi leggere**: **`0`**, e nient" + A + "altro. Qualunque altro numero e" + A +
NL +
"il numero di commit che ti mancano, e finche" + A + " non e" + A + " zero **non "
"distribuire" + NL +
"niente**: FERMATI QUI e porta la cartella avanti." + NL + NL +
"```powershell" + NL +
"git pull --ff-only" + NL +
"```" + NL + NL +
"**Cosa devi leggere.** Un elenco di file cambiati e in fondo una riga tipo"
+ NL +
"`Fast-forward`. Poi **rifai il conto di sopra**: deve dire `0`. Il conto e" + A +
NL + "il controllo, il pull e" + A + " solo il rimedio." + NL)

sostituisci(P, vecchio, nuovo)
print('PASSO 0 NON INVECCHIA PIU')
