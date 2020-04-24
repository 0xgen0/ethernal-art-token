pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./Factory.sol";
import "./EthernalArt.sol";
import "./Strings.sol";

contract EthernalArtFactory is Factory, Ownable {
  using Strings for string;

  address public proxyRegistryAddress;
  address public nftAddress;
  string public baseURI = "https://opensea-creatures-api.herokuapp.com/api/factory/";

  /**
   * Enforce the existence of only 100 OpenSea creatures.
   */
  uint256 CREATURE_SUPPLY = 100;

  /**
   * Three different options for minting Creatures (basic, premium, and gold).
   */
  uint256 NUM_OPTIONS = 3;
  uint256 SINGLE_CREATURE_OPTION = 0;
  uint256 MULTIPLE_CREATURE_OPTION = 1;
  uint256 NUM_CREATURES_IN_MULTIPLE_CREATURE_OPTION = 4;

  constructor(address _proxyRegistryAddress, address _nftAddress) public {
    proxyRegistryAddress = _proxyRegistryAddress;
    nftAddress = _nftAddress;
  }

  function name() external view returns (string memory) {
    return "Ethernal Art Factory";
  }

  function symbol() external view returns (string memory) {
    return "EAF";
  }

  function supportsFactoryInterface() public view returns (bool) {
    return true;
  }

  function numOptions() public view returns (uint256) {
    return NUM_OPTIONS;
  }

  function mint(uint256 _optionId, address _toAddress) public {
    // Must be sent from the owner proxy or owner.
    ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
    assert(address(proxyRegistry.proxies(owner())) == msg.sender || owner() == msg.sender || msg.sender == lootBoxNftAddress);
    require(canMint(_optionId));

    EthernalArt art = EthernalArt(nftAddress);
    if (_optionId == SINGLE_CREATURE_OPTION) {
      art.mintTo(_toAddress);
    } else if (_optionId == MULTIPLE_CREATURE_OPTION) {
      for (uint256 i = 0; i < NUM_CREATURES_IN_MULTIPLE_CREATURE_OPTION; i++) {
        art.mintTo(_toAddress);
      }
    }
  }

  function canMint(uint256 _optionId) public view returns (bool) {
    if (_optionId >= NUM_OPTIONS) {
      return false;
    }

    EthernalArt art = EthernalArt(nftAddress);
    uint256 creatureSupply = art.totalSupply();

    uint256 numItemsAllocated = 0;
    if (_optionId == SINGLE_CREATURE_OPTION) {
      numItemsAllocated = 1;
    } else if (_optionId == MULTIPLE_CREATURE_OPTION) {
      numItemsAllocated = NUM_CREATURES_IN_MULTIPLE_CREATURE_OPTION;
    }
    return creatureSupply < (CREATURE_SUPPLY - numItemsAllocated);
  }

  function tokenURI(uint256 _optionId) external view returns (string memory) {
    return Strings.strConcat(
        baseURI,
        Strings.uint2str(_optionId)
    );
  }

  /**
   * Hack to get things to work automatically on OpenSea.
   * Use transferFrom so the frontend doesn't have to worry about different method names.
   */
  function transferFrom(address /* _from */, address _to, uint256 _tokenId) public {
    mint(_tokenId, _to);
  }

  /**
   * Hack to get things to work automatically on OpenSea.
   * Use isApprovedForAll so the frontend doesn't have to worry about different method names.
   */
  function isApprovedForAll(
    address _owner,
    address _operator
  )
    public
    view
    returns (bool)
  {
    if (owner() == _owner && _owner == _operator) {
      return true;
    }

    ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
    if (owner() == _owner && address(proxyRegistry.proxies(_owner)) == _operator) {
      return true;
    }

    return false;
  }

  /**
   * Hack to get things to work automatically on OpenSea.
   * Use isApprovedForAll so the frontend doesn't have to worry about different method names.
   */
  function ownerOf(uint256 /* _tokenId */) public view returns (address _owner) {
    return owner();
  }
}
