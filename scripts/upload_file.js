require('dotenv').config();
const fs = require('fs');
const pinataSDK = require('@pinata/sdk');
const pinata = pinataSDK(process.env.PINATA_API_KEY, process.env.PINATA_SECRET);

async function main() {
  const file = process.argv[2];
  console.log('uploading file ' + file);
  const result = await pinata.pinFileToIPFS(fs.createReadStream(file));
  console.log(result);
}

main();
