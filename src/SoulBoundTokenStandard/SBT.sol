pragma solidity ^0.8.20;

import "./ISBT.sol";
import "./ISBTMetadata.sol";
import "./ISBTErrors.sol";

abstract contract SBT is ISBT, ISBTMetadata, ISBTErrors {
    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    mapping(uint256 tokenId => address) private _owners;
    mapping(address owner => uint256) private _balances;
    mapping(uint256 tokenId => string) private _tokenURIs;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(ISBT).interfaceId || interfaceId == type(ISBTMetadata).interfaceId
            || interfaceId == 0x01ffc9a7; // ERC165 interface ID
    }

    /**
     * @dev See {ISBT-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        if (owner == address(0)) {
            revert SBTInvalidOwner(address(0));
        }
        return _balances[owner];
    }

    /**
     * @dev See {ISBT-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        if (owner == address(0)) {
            revert SBTNonexistentToken(tokenId);
        }
        return owner;
    }

    /**
     * @dev See {ISBTMetadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {ISBTMetadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {ISBTMetadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (_owners[tokenId] == address(0)) {
            revert SBTNonexistentToken(tokenId);
        }
        return _tokenURIs[tokenId];
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     * - `to` must not already own an SBT.
     *
     * Emits a {Minted} event.
     */
    function _mint(address to, uint256 tokenId, string memory metadataURI) internal virtual {
        if (to == address(0)) {
            revert SBTInvalidReceiver(address(0));
        }
        if (_balances[to] != 0) {
            revert SBTAlreadyHasToken(to);
        }
        if (_owners[tokenId] != address(0)) {
            revert SBTTokenAlreadyMinted(tokenId);
        }

        _balances[to] += 1;
        _owners[tokenId] = to;
        _tokenURIs[tokenId] = metadataURI;
    }

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting.
     * Can be used to implement any custom logic before a transfer.
     *
     * Calling conditions:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual {}
}
