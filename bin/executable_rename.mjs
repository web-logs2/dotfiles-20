#!/usr/bin/env zx

const [src,dest,doit]=process.argv.slice(3)

let files=await $`ls`;

files=files.stdout.split('\n').filter(e=>!!e)

for (const e of files){
  const d=e.replace(new RegExp(src),dest);
  if (doit){
    if (e!==d){
      await $`mv ${e} ${d}`
    }
  }else{
    await $`echo mv ${e} ${d}`
  }
}