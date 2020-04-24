pragma solidity ^0.5.0;

import "./TradeableERC721Token.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @title EthernalArt
 * EthernalArt - a contract for my non-fungible creatures.
 */
contract EthernalArt is TradeableERC721Token {
  constructor(address _proxyRegistryAddress) TradeableERC721Token("Ethernal Artwork", "EA", _proxyRegistryAddress) public {  }

  function baseTokenURI() public view returns (string memory) {
    return "https://opensea-creatures-api.herokuapp.com/api/creature/";
  }

  function contractURI() public view returns (string memory) {
    return "https://ipfs.io/ipfs/QmNVWRRHm6CJNv4C4aVntiKSkTFnCfJRacVQMQP6cjNe8R";
  }
}
