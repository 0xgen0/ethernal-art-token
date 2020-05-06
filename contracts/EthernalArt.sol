pragma solidity ^0.5.0;

import "./TradeableERC721Token.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import './Strings.sol';

/**
 * @title EthernalArt
 */
contract EthernalArt is TradeableERC721Token {
  using Strings for string;

  struct Edition {
    uint16 size;
    string metadata;
  }

  struct Print {
    uint16 number;
    uint16 edition;
  }

  mapping(uint256 => Print) public prints;
  mapping(uint16 => Edition) public editions;
  uint16 public lastEdition = 0;

  event EditionPrinted(uint16 indexed edition, uint16 size, string metadata);

  constructor(address _proxyRegistryAddress) TradeableERC721Token("Ethernal:Art", "EA", _proxyRegistryAddress) public {  }

  function tokenURI(uint256 _tokenId) external view returns (string memory) {
    Print storage print = prints[_tokenId];
    return Strings.strConcat(
      "ipfs://",
      editions[print.edition].metadata,
      "/",
      Strings.uint2str(uint256(print.number))
    );
  }

  function printEdition(uint16 _editionId, uint16 size, string memory metadata) public onlyOwner {
    require(_editionId == lastEdition + 1, "not next edition");
    require(_editionId > lastEdition, "too many editions");
    require(!metadata.equals(editions[lastEdition].metadata), "last edition was same");
    Edition storage edition = editions[_editionId];
    edition.metadata = metadata;
    edition.size = size;
    for (uint16 i = 1; i <= size; i++) {
      uint256 token = mintTo(owner());
      Print storage print = prints[token];
      print.number = i;
      print.edition = _editionId;
    }
    lastEdition = _editionId;
    emit EditionPrinted(lastEdition, size, metadata);
  }

  function contractURI() public pure returns (string memory) {
    return "ipfs://QmTJfzn5C4q64Yd5U51n51HfDBuXTCpyUTYCyxiiLeb54W";
  }

  function getEdition(uint16 _editionId) public view returns (uint16 size, string memory metadata) {
    size = editions[_editionId].size;
    metadata = editions[_editionId].metadata;
  }

  function getPrint(uint256 _tokenId) public view returns (uint16 number, uint16 edition) {
    number = prints[_tokenId].number;
    edition = prints[_tokenId].edition;
  }
}
