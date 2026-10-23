import json,re,sys
def esiti(f):
    r={}
    for l in open(f,encoding='utf-8'):
        m=re.match(r'^\s*(?:scheda\s*)?(\d+)\s*[|.]\s*(non si capisce|s[iì]|no)(?![a-z])',l,re.I)
        if m: r[int(m.group(1))]=m.group(2).lower()
    return r
for arte,es,ch in [(a,f'esito_scambio2_{a}.md',f'chiave2_{a}.json') for a in ['tarocchi','rune','oracolo','oroscopo']]+[('oracolo v1','esito_scambio_oracolo.md','chiave_oracolo.json')]:
    k={x['scheda']:x['scambiato'] for x in json.load(open(ch,encoding='utf-8'))}
    e=esiti(es)
    ok=0;err=[];dub=[]
    for s,sc in k.items():
        v=e.get(s)
        if v is None or v=='non si capisce': dub.append(s);continue
        giusto = (v=='no')==sc
        if giusto: ok+=1
        else: err.append((s,'scambiato' if sc else 'originale',v))
    print(arte,'schede',len(k),'letti',len(e),'giusti',ok,'sbagliati',len(err),err,'dubbi',dub)
