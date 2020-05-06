require('dotenv').config();
const fs = require('fs');
const path = require('path');
const mkdirp = require('mkdirp');
const pinataSDK = require('@pinata/sdk');
const HDWalletProvider = require("truffle-hdwallet-provider");
const Web3 = require('web3');

const MNEMONIC = process.env.MNEMONIC;
const INFURA_KEY = process.env.INFURA_KEY;
const NFT_CONTRACT_ADDRESS = process.env.NFT_CONTRACT_ADDRESS;
const NETWORK = process.env.NETWORK;
const PINATA_API_KEY = process.env.PINATA_API_KEY;
const PINATA_SECRET = process.env.PINATA_SECRET;
const FROM = process.env.FROM;
const GAS_PRICE = process.env.GAS_PRICE || 10000000000;

if (!MNEMONIC || !INFURA_KEY || !NETWORK || !PINATA_API_KEY || !PINATA_SECRET || !NFT_CONTRACT_ADDRESS) {
  console.error("Please set a mnemonic, infura key, network, pinata auth and contract address.");
  return 1;
}

const pinata = pinataSDK(PINATA_API_KEY, PINATA_SECRET);

const NFT_ABI = [{
  "constant": false,
  "inputs": [
    {
      "internalType": "uint16",
      "name": "_editionId",
      "type": "uint16"
    },
    {
      "internalType": "uint16",
      "name": "size",
      "type": "uint16"
    },
    {
      "internalType": "string",
      "name": "metadata",
      "type": "string"
    }
  ],
  "name": "printEdition",
  "outputs": [],
  "payable": false,
  "stateMutability": "nonpayable",
  "type": "function"
}];

async function main() {
  const edition = process.argv[2];
  if (!edition) {
    console.log('edition has to be specified');
    process.exit(1);
  }
  console.log('releasing edition ' + edition);
  const template = require(`../editions/${edition}/metadata.json`);

  console.log('uploading image');
  const {IpfsHash: image} = await pinata.pinFileToIPFS(fs.createReadStream(path.join(__dirname, '..', 'editions', edition, template.image)));
  console.log(image);

  const prints = template.attributes.filter(({trait_type}) => trait_type === 'Edition')[0].max_value;
  console.log(`generating metadata for ${prints} prints`);
  const dir = path.join(__dirname, '..', 'build', edition);
  mkdirp.sync(dir);
  for (let i = 1; i <= prints; i++) {
    const data = {
      ...template,
      name: `${template.name} ${i}/${prints}`,
      image: `ipfs://${image}`,
      attributes: [
        ...template.attributes.map(a => a.trait_type === 'Edition' ? {...a, value: i} : a)
      ]
    };
    fs.writeFileSync(path.join(dir, String(i)), JSON.stringify(data, null, 2));
  }
  const {IpfsHash: metadata} = await pinata.pinFromFS(dir);
  console.log(metadata);

  console.log('printing');
  const provider = NETWORK === 'development'
      ? new Web3("http://127.0.0.1:8545")
      : new HDWalletProvider(MNEMONIC, `https://${NETWORK}.infura.io/v3/${INFURA_KEY}`, 0, 5);
  const web3 = new Web3(provider);
  let [from] = await web3.eth.getAccounts();
  if (FROM) {
    from = FROM;
  }
  const contract = new web3.eth.Contract(NFT_ABI, NFT_CONTRACT_ADDRESS, {gasLimit: "6000000"});
  const {transactionHash} = await contract.methods.printEdition(edition, prints, metadata).send({from, gasPrice: GAS_PRICE});
  console.log(transactionHash);
}

main()
    .then(() => process.exit(0))
    .catch(err => {
      console.log(err.message);
      process.exit(1)
    });
