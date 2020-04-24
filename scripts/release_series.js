require('dotenv').config();
const fs = require('fs');
const path = require('path');
const pinataSDK = require('@pinata/sdk');
const pinata = pinataSDK(process.env.PINATA_API_KEY, process.env.PINATA_SECRET);

async function main() {
  const series = process.argv[2];
  console.log('releasing series ' + series);
  const metadata = require(`../series/${series}/metadata.json`);
  console.log('uploading image');
  const {IpfsHash: image} = await pinata.pinFileToIPFS(fs.createReadStream(path.join(__dirname, '..', 'series', series, 'image.png')));
  console.log(image);
  const prints = metadata.attributes.filter(({trait_type}) => trait_type === 'Print')[0].max_value;
  console.log(`generating metadata for ${prints} prints`);
  const dir = path.join(__dirname, '..', 'build', series);
  if (!fs.existsSync(dir)){
    fs.mkdirSync(dir);
  }
  for (let i = 1; i <= prints; i++) {
    const data = {
      ...metadata,
      name: `${metadata.name} ${i}/${prints}`,
      image: `https://ipfs.io/ipfs/${image}`,
      attributes: metadata.attributes.map(a => a.trait_type === 'Print' ? {...a, value: i} : a)
    };
    fs.writeFileSync(path.join(dir, String(i)), JSON.stringify(data, null, 2));
  }
  const {IpfsHash: result} = await pinata.pinFromFS(dir);
  console.log(result);
}

main();
