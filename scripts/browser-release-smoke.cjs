const fs = require('node:fs');
const path = require('node:path');
const http = require('node:http');
const assert = require('node:assert/strict');
const { chromium } = require(process.env.PATCH_PLAYWRIGHT_MODULE || 'playwright');
const root = path.resolve(__dirname, '..');
const out = path.resolve(root, '_release-evidence');
fs.mkdirSync(out, { recursive: true });
const article = '/articles/adopt-me-lightning-dimension-guide.html';
const routes = ['/', '/adopt-me.html', article, '/pets/thunderfisher.html', '/pets/electric-hornet.html', '/pets/haetyphoon.html', '/pets/flash-weasel.html', '/articles/adopt-me-pet-encyclopedia.html', '/pet-value-calculator.html', '/neon-calculator.html', '/articles/adopt-me-egg-guide.html', '/egg-value-calculator.html', '/articles/adopt-me-pet-value-list-2026.html', '/market-movers.html', '/inventory-planner.html'];
let server, testBrowser;
async function main() {
  let base = process.argv[2];
  if (!base) {
    server = http.createServer((req, res) => {
      let relative = decodeURIComponent(new URL(req.url, 'http://localhost').pathname);
      if(relative.endsWith('/')) relative += 'index.html';
      const file = path.resolve(root, '.' + relative);
      if (!file.startsWith(root + path.sep) || !fs.existsSync(file)) { res.writeHead(404); res.end(); return; }
      const types = {'.html':'text/html','.js':'application/javascript','.css':'text/css','.json':'application/json','.svg':'image/svg+xml','.png':'image/png','.webp':'image/webp'};
      res.setHeader('Content-Type', types[path.extname(file)] || 'application/octet-stream');
      fs.createReadStream(file).pipe(res);
    });
    await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
    base = 'http://127.0.0.1:' + server.address().port;
  }
  const browser = testBrowser = await chromium.launch({ executablePath:'C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe', headless:true });
  const context = await browser.newContext({viewport:{width:1440,height:1000}});
  await context.route(/googletagmanager|google-analytics|doubleclick|googlesyndication/, route => route.abort());
  const page = await context.newPage();
  const failures = [], checks = [];
  page.on('pageerror', err => failures.push('JS: ' + err.message));
  page.on('response', r => {if(r.url().startsWith(base) && r.status() >= 400) failures.push(r.status()+' '+r.url());});
  for (const route of routes) {
    const response = await page.goto(base + route, {waitUntil:'networkidle'});
    assert.equal(response.status(),200,route);
    await page.locator('h1').first().waitFor();
    if(route==='/' || route==='/adopt-me.html') assert(await page.locator('a[href="'+article+'"]').count()>=2,'Hero and tile must route to Lightning: '+route);
    if(route.includes('encyclopedia')) {
      await page.locator('#catalog-grid a').first().waitFor();
      for(const name of ['Thunderfisher','Electric Hornet','Haetyphoon','Flash Weasel']) {
        await page.locator('#search-input').fill(name);
        assert((await page.locator('#catalog-grid').innerText()).includes(name),name+' encyclopedia');
      }
    }
    if(route==='/pet-value-calculator.html') {
      await page.locator('#give-grid .slot').first().waitFor();
      for(const name of ['Thunderfisher','Electric Hornet','Haetyphoon','Flash Weasel']) {
        await page.locator('#give-grid .slot.empty').first().click();
        await page.locator('#picker-search').fill(name);
        await page.locator('#picker-grid .pet-tile').first().click();
      }
      assert((await page.locator('#give-grid').innerText()).includes('22 pts'),'Haetyphoon default No Potion value');
      assert.equal(await page.locator('#give-grid .slot-val').filter({hasText:'Value pending'}).count(),3);
      assert((await page.locator('#v-label').innerText()).includes('PENDING'),'Pending pet must suppress trade verdict');
      await page.locator('#clear-btn').click();
      for(const side of ['give','recv']) {
        await page.locator('#'+side+'-grid .slot.empty').first().click();
        await page.locator('#picker-search').fill('Turtle');
        await page.locator('#picker-grid .pet-tile').filter({hasText:/^Turtle/}).first().click();
      }
      assert((await page.locator('#v-label').innerText()).includes('FAIR'));
      await page.locator('#give-grid .tog').filter({hasText:/^Neon$/}).click();
      assert(!(await page.locator('#v-label').innerText()).includes('FAIR'),'Neon toggle updates result');
    }
    if(route==='/egg-value-calculator.html') {
      await page.waitForFunction(()=>document.querySelector('#egg-select').options.length===41);
      for(const id of await page.locator('#egg-select option').evaluateAll(nodes=>nodes.map(n=>n.value))) {
        await page.locator('#egg-select').selectOption(id);
        assert(!(await page.locator('#expected-per-hatch').innerText()).includes('NaN'));
        assert((await page.locator('#egg-summary-note').innerText()).length>0);
        await page.locator('#hatch-count').fill('20');
        await page.locator('#hatch-count').dispatchEvent('input');
        await page.evaluate(async()=>{await Promise.all(Array.from(document.querySelectorAll('#selected-egg-card img'),async i=>{i.loading='eager';try{await i.decode();}catch{}}));});
        assert.deepEqual(await page.locator('#selected-egg-card img').evaluateAll(nodes=>nodes.filter(i=>!i.naturalWidth).map(i=>i.src)),[],id+' hatch pool art');
      }
    }
    if(route.includes('adopt-me-egg-guide')) {
      await page.locator('#egg-royal-fairytale').waitFor();
      assert.equal(await page.locator('#egg-card-grid .egg-card').count(),41);
    }
    if(route==='/neon-calculator.html') {
      await page.waitForFunction(()=>document.querySelector('#petSelect').options.length>90);
      await page.locator('#petSelect').selectOption('turtle');
      assert(!(await page.locator('#resultArea').innerText()).includes('Loading'));
    }
    await page.evaluate(async()=>{await Promise.all(Array.from(document.images, async img=>{img.loading='eager';try{await img.decode();}catch{}}));});
    const broken=await page.evaluate(()=>Array.from(document.images).filter(i=>!i.naturalWidth).map(i=>i.src));
    assert.deepEqual(broken,[],route+' broken images');
    checks.push({route,images:await page.locator('img').count(),heading:await page.locator('h1').first().innerText()});
    if(['/',article,'/pets/haetyphoon.html','/pet-value-calculator.html','/articles/adopt-me-egg-guide.html'].includes(route)) await page.screenshot({path:path.join(out,(route==='/'?'home':path.basename(route,'.html'))+'-desktop.png')});
  }
  await page.setViewportSize({width:390,height:844});
  for(const route of ['/',article,'/pet-value-calculator.html','/articles/adopt-me-egg-guide.html']) {
    await page.goto(base+route,{waitUntil:'networkidle'});
    const overflow=await page.evaluate(()=>document.documentElement.scrollWidth>innerWidth+1);
    assert(!overflow,'Mobile horizontal overflow: '+route);
    await page.screenshot({path:path.join(out,(route==='/'?'home':path.basename(route,'.html'))+'-mobile.png')});
  }
  assert.deepEqual(failures,[]);
  const report={base,checkedAt:new Date().toISOString(),desktopPages:checks,mobilePages:4,failures};
  fs.writeFileSync(path.join(out,base.includes('127.0.0.1')?'local-browser.json':'public-browser.json'),JSON.stringify(report,null,2));
  console.log(JSON.stringify(report,null,2));
  await browser.close();
}
main().catch(e=>{console.error(e);process.exitCode=1;}).finally(async()=>{await testBrowser?.close();server?.close();});
