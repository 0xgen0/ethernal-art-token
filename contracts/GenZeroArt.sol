pragma solidity ^0.5.0;

import "./TradeableERC721Token.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @title GenZeroArt
 * GenZeroArt - a contract for my non-fungible creatures.
 */
contract GenZeroArt is TradeableERC721Token {
  constructor(address _proxyRegistryAddress) TradeableERC721Token("Gen0 Art", "GZR", _proxyRegistryAddress) public {  }

  function baseTokenURI() public view returns (string memory) {
    return "https://opensea-creatures-api.herokuapp.com/api/creature/";
  }
}
