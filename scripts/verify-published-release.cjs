// Checks every changed web artifact against the actual public HTTP response.
const fs=require('node:fs'),path=require('node:path'),cp=require('node:child_process'),crypto=require('node:crypto');
process.chdir(path.resolve(__dirname,'..'));
const base=process.argv[2]||'https://thepatchgg.github.io';
const ref=process.argv[3]||'HEAD^';
const release=cp.execFileSync('git',['rev-parse','HEAD'],{encoding:'utf8'}).trim();
const paths=cp.execFileSync('git',['diff','--name-only',ref,'--'],{encoding:'utf8'}).trim().split(/\r?\n/).filter(p=>/\.(html|json|js|css|png|webp|jpg|svg|xml)$/.test(p)&&!p.startsWith('scripts/')&&fs.existsSync(p));
const digest=(buffer,p)=>crypto.createHash('sha256').update(/\.(png|webp|jpg)$/.test(p)?buffer:buffer.toString('utf8').replace(/\r\n/g,'\n')).digest('hex');
let next=0,passed=0;const failures=[];
async function worker(){while(next<paths.length){const p=paths[next++];let error;for(let attempt=0;attempt<3;attempt++){try{const response=await fetch(base+'/'+p+'?release='+release,{signal:AbortSignal.timeout(30000),headers:{'Cache-Control':'no-cache'}});if(!response.ok)throw Error('HTTP '+response.status);const remote=Buffer.from(await response.arrayBuffer());if(digest(remote,p)!==digest(fs.readFileSync(p),p))throw Error('Content differs');passed++;error=null;break;}catch(e){error=String(e);}}if(error)failures.push({path:p,error});if((passed+failures.length)%100===0)console.log('checked='+(passed+failures.length)+'/'+paths.length);}}
Promise.all(Array.from({length:6},worker)).then(()=>{console.log(JSON.stringify({release,base,checked:paths.length,passed,failures},null,2));if(failures.length)process.exitCode=1;});
