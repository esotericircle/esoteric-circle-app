# -*- coding: utf-8 -*-
"""CQ6.12: il PASSO 7 verifica di essere arrivato prima di distribuire."""
import sys
sys.path.insert(0, 'tool')
from _innesta_tmp import sostituisci  # noqa: E402

NL = chr(10)
A = chr(39)
P = 'docs/ordini/DISTRIBUZIONI_DAL_TUO_PC.md'

vecchio = "**1. Porta la tua cartella alla testa nuova.**" + NL
nuovo = (
"**1. Porta la tua cartella alla testa nuova, E VERIFICA DI ESSERCI"
" ARRIVATO.**" + NL + NL +
"**Perche" + A + " la verifica esiste, ordine CQ voce 6.12 del 4 settembre 2026.**"
+ NL +
"Il 4 settembre il comando di distribuzione ha risposto *No function matches"
+ NL +
"the filter: default:attivaIlPianoInDemo*, e sembrava che la funzione non"
" fosse" + NL +
"mai stata scritta. **Era stata scritta e spinta**, col commit `9d980de1`: la"
+ NL +
"cartella era ferma **sessantotto commit indietro**, al primo settembre, e"
" quel" + NL +
"comando cerca la funzione nei file che hai sul disco, non nel ramo." + NL + NL +
"Il passo 1 diceva gia" + A + " di aggiornare, e non bastava: **diceva di fare una"
+ NL +
"cosa senza dire come accorgersi che non era riuscita.** Un" + A + "istruzione che non"
+ NL +
"porta il suo controllo lascia chi la esegue davanti a un errore che parla di"
+ NL +
"un" + A + "altra cosa." + NL)
sostituisci(P, vecchio, nuovo)

# La verifica entra DOPO il pull e PRIMA del deploy.
vecchio2 = "```powershell" + NL + "git pull"
nuovo2 = "```powershell" + NL + "git pull"
assert vecchio2 == nuovo2  # il pull resta dov'e'

print('PASSO 7 SPIEGATO')
