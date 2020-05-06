pragma solidity ^0.5.0;

import "./TradeableERC721Token.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import './Strings.sol';

/**
 * @title EthernalArt
 */
contract EthernalArt is TradeableERC721Token {
  using Strings for string;

  struct Series {
    uint16 size;
    string metadata;
  }

  struct Edition {
    uint16 number;
    uint16 series;
  }

  mapping(uint256 => Edition) public edition;
  mapping(uint16 => Series) public series;
  uint16 public lastSeries = 0;

  event Printed(uint16 indexed series, uint16 size, string metadata);

  constructor(address _proxyRegistryAddress) TradeableERC721Token("Ethernal:Art", "EA", _proxyRegistryAddress) public {  }

  function tokenURI(uint256 _tokenId) external view returns (string memory) {
    Edition storage edition = edition[_tokenId];
    require(edition.series != 0, 'not found');
    return Strings.strConcat(
      "https://ipfs.io/ipfs/",
      series[edition.series].metadata,
      "/",
      Strings.uint2str(uint256(edition.number))
    );
  }

  function printSeries(uint16 _series, uint16 size, string memory metadata) public onlyOwner {
    require(_series == lastSeries + 1, "not next series");
    require(_series > lastSeries, "too many series");
    require(!metadata.equals(series[lastSeries].metadata), "last series was same");
    Series storage series = series[_series];
    series.metadata = metadata;
    series.size = size;
    for (uint16 i = 1; i <= size; i++) {
      uint256 token = mintTo(owner());
      Edition storage edition = edition[token];
      edition.number = i;
      edition.series = _series;
    }
    lastSeries = _series;
    emit Printed(lastSeries, size, metadata);
  }

  function contractURI() public pure returns (string memory) {
    return "https://ipfs.io/ipfs/QmWwwieZERn5e5ubFVQfGbQ94d1Ro4Vrpio7CPDomMmpqd";
  }

  function getSeries(uint16 _series) public view returns (uint16 size, string memory metadata) {
    size = series[_series].size;
    metadata = series[_series].metadata;
  }

  function getEdition(uint256 _tokenId) public view returns (uint16 number, uint16 series) {
    number = edition[_tokenId].number;
    series = edition[_tokenId].series;
  }
}
