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
    mapping(uint256 => string) private _tokenURIs;

    struct Achievement {
        string title;
        string description;
        uint256 timestamp;
    }

    uint256 private _tokenIdCounter;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _tokenIdCounter = 0;
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
        require(ownerOf(tokenId) != address(0), "SBT: URI query for nonexistent token");
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
    function _mint(address to) internal virtual returns (uint256) {
        if (to == address(0)) {
            revert SBTInvalidReceiver(address(0));
        }
        if (_balances[to] != 0) {
            revert SBTAlreadyHasToken(to);
        }

        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;

        if (_owners[tokenId] != address(0)) {
            revert SBTTokenAlreadyMinted(tokenId);
        }

        _balances[to] += 1;
        _owners[tokenId] = to;
        _tokenURIs[tokenId] = "[]";

        return tokenId;
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

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return ownerOf(tokenId) != address(0);
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(ownerOf(tokenId) != address(0), "SBT: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function _addAchievement(uint256 tokenId, string memory title, string memory description) internal {
        require(msg.sender == _owner(), "SBT: Only owner can add achievements");
        require(ownerOf(tokenId) != address(0), "SBT: Token does not exist");

        string memory currentURI = tokenURI(tokenId);
        string memory newURI = _addAchievementToJSON(currentURI, title, description);
        _setTokenURI(tokenId, newURI);
    }

    function _removeAchievement(uint256 tokenId, string memory title) internal {
        require(msg.sender == _owner(), "SBT: Only owner can remove achievements");
        require(ownerOf(tokenId) != address(0), "SBT: Token does not exist");

        string memory currentURI = tokenURI(tokenId);
        string memory newURI = _removeAchievementFromJSON(currentURI, title);
        _setTokenURI(tokenId, newURI);
    }

    function mint(address to) external virtual returns (uint256) {
        return _mint(to);
    }

    function _getNextTokenId() internal view returns (uint256) {
        return _tokenIdCounter;
    }

    function getTokenIdCounter() public view returns (uint256) {
        return _tokenIdCounter;
    }

    function addAchievement(uint256 tokenId, string memory title, string memory description) external virtual {
        require(msg.sender == _owner(), "SBT: Only owner can add achievements");
        _addAchievement(tokenId, title, description);
    }

    function removeAchievement(uint256 tokenId, string memory title) external virtual {
        require(msg.sender == _owner(), "SBT: Only owner can remove achievements");
        _removeAchievement(tokenId, title);
    }

    function getAchievements(uint256 tokenId) external view returns (Achievement[] memory) {
        require(ownerOf(tokenId) != address(0), "SBT: Token does not exist");
        string memory currentURI = tokenURI(tokenId);
        if (bytes(currentURI).length == 0 || keccak256(bytes(currentURI)) == keccak256(bytes("[]"))) {
            return new Achievement[](0);
        }
        return _parseAchievements(currentURI);
    }

    function _owner() internal view virtual returns (address);

    function _addAchievementToJSON(string memory jsonString, string memory title, string memory description)
        private
        view
        returns (string memory)
    {
        Achievement[] memory achievements = _parseAchievements(jsonString);
        Achievement[] memory newAchievements = new Achievement[](achievements.length + 1);

        for (uint256 i = 0; i < achievements.length; i++) {
            newAchievements[i] = achievements[i];
        }

        newAchievements[achievements.length] = Achievement(title, description, block.timestamp);

        return _stringifyAchievements(newAchievements);
    }

    function _removeAchievementFromJSON(string memory jsonString, string memory title)
        private
        pure
        returns (string memory)
    {
        Achievement[] memory achievements = _parseAchievements(jsonString);
        Achievement[] memory newAchievements = new Achievement[](achievements.length);
        uint256 newIndex = 0;

        for (uint256 i = 0; i < achievements.length; i++) {
            if (keccak256(bytes(achievements[i].title)) != keccak256(bytes(title))) {
                newAchievements[newIndex] = achievements[i];
                newIndex++;
            }
        }

        Achievement[] memory finalAchievements = new Achievement[](newIndex);
        for (uint256 i = 0; i < newIndex; i++) {
            finalAchievements[i] = newAchievements[i];
        }

        return _stringifyAchievements(finalAchievements);
    }

    function _parseAchievements(string memory jsonString) private pure returns (Achievement[] memory) {
        // This is a simplified parser and assumes a specific JSON format
        // In a production environment, consider using a more robust JSON parser
        bytes memory jsonBytes = bytes(jsonString);
        uint256 count = 1;
        for (uint256 i = 0; i < jsonBytes.length; i++) {
            if (jsonBytes[i] == "{") count++;
        }
        Achievement[] memory achievements = new Achievement[](count - 1);
        uint256 index = 0;
        uint256 startPos = 0;
        for (uint256 i = 1; i < jsonBytes.length - 1; i++) {
            if (jsonBytes[i] == "}") {
                achievements[index] = _parseAchievement(substring(jsonString, startPos, i + 1));
                index++;
                startPos = i + 2;
            }
        }
        return achievements;
    }

    function _parseAchievement(string memory achievementJson) private pure returns (Achievement memory) {
        // This is a simplified parser and assumes a specific JSON format
        // In a production environment, consider using a more robust JSON parser
        bytes memory jsonBytes = bytes(achievementJson);
        uint256 titleStart = findPosition(jsonBytes, "title") + 8;
        uint256 titleEnd = findPosition(jsonBytes, "description") - 3;
        uint256 descStart = findPosition(jsonBytes, "description") + 14;
        uint256 descEnd = findPosition(jsonBytes, "timestamp") - 3;
        uint256 timestampStart = findPosition(jsonBytes, "timestamp") + 11;
        uint256 timestampEnd = jsonBytes.length - 1;

        return Achievement(
            substring(achievementJson, titleStart, titleEnd),
            substring(achievementJson, descStart, descEnd),
            parseUint(substring(achievementJson, timestampStart, timestampEnd))
        );
    }

    function _stringifyAchievements(Achievement[] memory achievements) private pure returns (string memory) {
        string memory result = "[";
        for (uint256 i = 0; i < achievements.length; i++) {
            result = string(
                abi.encodePacked(
                    result,
                    i == 0 ? "" : ",",
                    "{\"title\":\"",
                    achievements[i].title,
                    "\",\"description\":\"",
                    achievements[i].description,
                    "\",\"timestamp\":",
                    uint2str(achievements[i].timestamp),
                    "}"
                )
            );
        }
        result = string(abi.encodePacked(result, "]"));
        return result;
    }

    function substring(string memory str, uint256 startIndex, uint256 endIndex) private pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex - startIndex);
        for (uint256 i = startIndex; i < endIndex; i++) {
            result[i - startIndex] = strBytes[i];
        }
        return string(result);
    }

    function findPosition(bytes memory _bytes, string memory _string) private pure returns (uint256) {
        bytes memory stringBytes = bytes(_string);
        for (uint256 i = 0; i < _bytes.length - stringBytes.length; i++) {
            bool found = true;
            for (uint256 j = 0; j < stringBytes.length; j++) {
                if (_bytes[i + j] != stringBytes[j]) {
                    found = false;
                    break;
                }
            }
            if (found) return i;
        }
        return 0;
    }

    function parseUint(string memory _string) private pure returns (uint256) {
        bytes memory stringBytes = bytes(_string);
        uint256 result = 0;
        for (uint256 i = 0; i < stringBytes.length; i++) {
            uint8 c = uint8(stringBytes[i]);
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            }
        }
        return result;
    }

    function uint2str(uint256 _i) private pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = uint8(48 + (_i % 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}
