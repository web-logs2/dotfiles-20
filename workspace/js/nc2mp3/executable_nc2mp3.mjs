#!/usr/bin/env node

import fs from 'fs/promises';
import path from 'path';
import ncAPI from 'NeteaseCloudMusicApi';
import { ID3Writer } from 'browser-id3-writer';
// https://github.com/egoroof/browser-id3-writer
import imageThumbnail from 'image-thumbnail';
// https://github.com/onildoaguiar/image-thumbnail

const BAZINGA = 0xa3;
const BLOCK_SIZE = 256 * 1024;
const CACHE_EXT = '.uc!';
const OUTPUT_EXT = '.mp3';

function decode(buffer) {
  for (let i = 0; i < buffer.length; ++i) {
    buffer[i] ^= BAZINGA;
  }
}

async function decodeFile(target) {
  // const targetPath = path.resolve(module.parent.path, target);
  const targetPath = target;
  const stat = await fs.stat(targetPath);
  let buffer = Buffer.alloc(stat.size);

  const reader = await fs.open(targetPath, 'r');
  for (let offset = 0; offset < stat.size; offset += BLOCK_SIZE) {
    const length =
      offset + BLOCK_SIZE > stat.size ? stat.size - offset : BLOCK_SIZE;
    await reader.read(buffer, offset, length);
  }
  await reader.close();

  decode(buffer);

  const originName = path.basename(targetPath, CACHE_EXT);
  let outputName = originName;
  const lyricPromise = ncAPI.lyric({ id: getMusicIdFromPath(originName) });
  const songInfo = await decodeInfo(originName);
  if (songInfo) {
    outputName = `${songInfo.ar.map((artist) => artist.name).join(',')} - ${
      songInfo.name
    }`;

    const id3Writer = new ID3Writer(buffer);
    id3Writer
      .setFrame('TIT2', songInfo.name) // title
      .setFrame(
        'TPE1',
        songInfo.ar.map((artist) => artist.name)
      ) // artists
      .setFrame('TALB', songInfo.al.name) // 专辑
      .setFrame('TLEN', songInfo.dt) // 时长，毫秒
      .setFrame('TRCK', songInfo.no) // song number in album: '5' or '5/10'
      .setFrame('TPOS', songInfo.cd) // album disc number
      .setFrame('TXXX', {
        description: 'neteaseid',
        value: songInfo.id,
      });
    if (songInfo.publishTime) {
      const publishTime = new Date(songInfo.publishTime);
      id3Writer.setFrame('TYER', publishTime.getFullYear()).setFrame('TXXX', {
        description: 'date',
        value: publishTime.toISOString().split('T')[0],
      });
    }
    try {
      const picRsp = await fetch(songInfo.al.picUrl);
      const pic = Buffer.from(await picRsp.arrayBuffer());
      const picThumbnail = Buffer.from(await imageThumbnail(pic));

      id3Writer.setFrame('APIC', {
        type: 3,
        data: picThumbnail,
        description: 'cover',
      }); // 嵌入图片
    } catch (error) {
      console.log(error);
    }
    try {
      const lyric = (await lyricPromise).body?.lrc?.lyric;
      id3Writer.setFrame('TXXX', {
        description: 'lyrics',
        value: lyric,
      });
    } catch (error) {
      console.log(error);
    }
    id3Writer.addTag();
    buffer = Buffer.from(id3Writer.arrayBuffer);
  }

  const outputPath = outputName + OUTPUT_EXT;
  const writer = await fs.open(outputPath, 'w');
  await writer.write(buffer);
  await writer.close();
  console.log(`saved to ${outputPath}`);
}

async function decodeInfo(filePath) {
  try {
    const rsp = await ncAPI.song_detail({
      ids: getMusicIdFromPath(filePath),
    });
    return rsp.body?.songs?.[0];
  } catch (error) {
    console.log(error);
  }
}

function getMusicIdFromPath(filePath) {
  return path.basename(filePath).split('-')[0];
}

async function main() {
  if (process.argv[2] === '--info') {
    const info = await decodeInfo(process.argv[3]);
    console.log(JSON.stringify(info, null, 2));
  } else {
    process.argv.slice(2).forEach((arg) => decodeFile(arg));
  }
}

main();