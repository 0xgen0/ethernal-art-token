## Ethernal Artwork ERC721 contracts

Contracts for printing artwork editions on chain as NTF's.

## Requirements

### Node version

Either make sure you're running a version of node compliant with the `engines` requirement in `package.json`, or install Node Version Manager [`nvm`](https://github.com/creationix/nvm) and run `nvm use` to use the correct version of node.

```
nvm use
```

## Installation

Run
```bash
npm install
```

If you run into an error while building the dependencies and you're on a Mac, run the code below, remove your `node_modules` folder, and do a fresh `npm install`:

```bash
xcode-select --install # Install Command Line Tools if you haven't already.
sudo xcode-select --switch /Library/Developer/CommandLineTools # Enable command line tools
sudo npm explore npm -g -- npm install node-gyp@latest # Update node-gyp
```

## Deploying

### Deploying to the Rinkeby network

1. You'll need to sign up for [Infura](https://infura.io). and get an API key.
2. Using your API key and the mnemonic for your Metamask wallet (make sure you're using a Metamask seed phrase that you're comfortable using for testing purposes), run:

```
npm run deploy:rinkeby
```

### Preparing Edition

Check out [editions/1/metadata.json](editions/1/metadata.json) as example of Edition metadata, modify or create new Edition based on this template.

Unique number of print in the Edition will be automatically appended after `name` (for example 4/20). 

`image` param specifies relative path to the file that will be uploaded to the IPFS as NFT's image.

Number of prints in the Edition is determined by the `max_value` in `Print` trait.

`Edition` trait identificator will be added automatically by the script later.


### Printing edition

Deployed contract address then have to be set in the `NFT_CONTRACT_ADDRESS` environment variable.

Then you can print Edition you want: directory name in the [editions/](editions/) directory has to be specified (1 in this example). 

This script will:

- Upload image to the IPFS 
- Generate metadata for every individual NFT to the [build/](build/) directory
- Upload whole metadata directory to the IPFS
- Mints all NFT's in the Edition

```
npm run print 1
```
