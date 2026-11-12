const assert=require('node:assert/strict'),fs=require('node:fs'),vm=require('node:vm'),path=require('node:path');
const root=path.resolve(__dirname,'..');
const read=p=>fs.readFileSync(path.join(root,p),'utf8').replace(/^\uFEFF/,'');
const ctx={window:{}};
vm.runInNewContext(read('assets/js/adopt-eggs.js'),ctx);
vm.runInNewContext(read('assets/js/adopt-egg-guide-data.js'),ctx);
const eggs=JSON.parse(read('data/adopt-me-eggs.json')).eggs;
const verified=JSON.parse(read('data/adopt-me-verified-eggs.json')).eggs;
const values=JSON.parse(read('data/adopt-me-values.json'));
values.petIndex=Object.fromEntries(values.pets.map(p=>[p.slug,p]));
assert.equal(eggs.length,new Set(eggs.map(e=>e.id)).size);
assert.deepEqual(eggs.map(e=>e.id).sort(),verified.map(e=>e.id).sort());
for(const egg of eggs) {
  const art=ctx.window.ThePatchEggs.localEggAssetUrl(egg);
  assert(art.startsWith('/assets/eggs/'),egg.id+' exact local art');
  assert(fs.existsSync(path.join(root,art.slice(1))),egg.id+' art exists');
}
const royal=eggs.find(e=>e.id==='royal-fairytale');
assert.equal(royal.cost,'14 Stars');
assert.equal(royal.chances.Rare,'40%');
assert.equal(royal.chances['Ultra-Rare'],'50%');
assert.equal(royal.chances.Legendary,'10%');
const gem=eggs.find(e=>e.id==='gemstone');
assert.equal(gem.pets.find(p=>p.name==='Amethyst Penguin').chance,'0.05%');
assert(!gem.pets.some(p=>p.name==='Diamond Unicorn'));
for(const id of ['gemstone','throwback','royal-fairytale']) {
  const summary=ctx.window.ThePatchEggs.summarizeEgg(eggs.find(e=>e.id===id),values);
  assert.equal(summary.coveredBenchmarks,0,id+' must not infer unpublished per-pet odds');
  assert(Number.isFinite(summary.expectedValue));
}
assert.equal(ctx.window.ThePatchEggs.parseChance('Not published'),null);
assert.equal(ctx.window.ThePatchEggs.parseChance('9.95% + 0.05% chase'),null);
console.log('Egg checks passed: '+eggs.length+' aligned eggs; exact art, official rates, and unknown odds preserved.');
