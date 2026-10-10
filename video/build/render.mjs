// Render scenes.html frame-by-frame with Playwright → frames/%06d.png
// usage: node render.mjs <outDir> [fps] [startSec] [endSec] [everyNth]
import { createRequire } from 'node:module';
const require = createRequire(import.meta.url);
const { chromium } = require(process.env.PLAYWRIGHT_PKG || 'playwright');
import { mkdirSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
const here = dirname(fileURLToPath(import.meta.url));
const [,, outDir='frames', fpsS='30', startS='0', endS='', nthS='1'] = process.argv;
const fps=+fpsS, start=+startS, nth=+nthS;
mkdirSync(outDir,{recursive:true});
const browser = await chromium.launch();
const page = await browser.newPage({ viewport:{width:1920,height:1080}, deviceScaleFactor:1 });
await page.goto('file://'+resolve(here,'scenes.html'));
const total = await page.evaluate(()=>window.__total());
const end = endS===''?total:Math.min(+endS,total);
const n0=Math.round(start*fps), n1=Math.round(end*fps);
console.log(`total ${total}s, rendering frames ${n0}..${n1-1} at ${fps}fps (every ${nth})`);
let done=0; const t0=Date.now();
for(let n=n0;n<n1;n+=nth){
  await page.evaluate(t=>window.__seek(t), n/fps);
  await page.screenshot({ path:`${outDir}/${String(n).padStart(6,'0')}.png`, type:'png' });
  if(++done%300===0) console.log(`${n}/${n1}  ${((Date.now()-t0)/1000).toFixed(0)}s`);
}
await browser.close();
console.log('done', done, 'frames');
