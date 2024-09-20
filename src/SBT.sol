pragma solidity ^0.8.20;

import "./Context.sol";
import "./ISBT.sol";
import "./ISBTMetadata.sol";
import "./ISBTErrors.sol";

contract SBT is Context, ISBT, ISBTMetadata, ISBTErrors {
    string private _name;
    string private _symbol;

    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => string) private _tokenURIs;

    uint256 private _tokenIdCounter;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _tokenIdCounter = 0;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(ISBT).interfaceId || interfaceId == type(ISBTMetadata).interfaceId
            || interfaceId == 0x01ffc9a7; // ERC165 interface ID
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (_owners[tokenId] == address(0)) {
            revert SBTNonexistentToken(tokenId);
        }
        return _tokenURIs[tokenId];
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {
        if (owner == address(0)) {
            revert SBTInvalidOwner(address(0));
        }
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        if (owner == address(0)) {
            revert SBTNonexistentToken(tokenId);
        }
        return owner;
    }

    function mint(address to, string memory metadataURI) external virtual override returns (uint256) {
        if (to == address(0)) {
            revert SBTInvalidReceiver(address(0));
        }
        if (_balances[to] != 0) {
            revert("SBT: Recipient already has a token");
        }

        uint256 tokenId = _tokenIdCounter++;
        _owners[tokenId] = to;
        _balances[to] = 1;
        _tokenURIs[tokenId] = metadataURI;

        emit Minted(to, tokenId);
        return tokenId;
    }
}
