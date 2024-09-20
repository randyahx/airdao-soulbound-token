// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ISoulBoundToken {
    struct Achievement {
        string title;
        string dataURI; // Generic URI for achievement data
        uint256 timestamp;
    }

    event Minted(address indexed to, uint256 indexed tokenId);
    event AchievementAdded(uint256 indexed tokenId, string title, string dataURI, uint256 timestamp);

    function mint(address to, string memory metadataURI) external returns (uint256 tokenId);
    function addAchievement(uint256 tokenId, string memory title, string memory dataURI) external;
    function getAchievements(uint256 tokenId) external view returns (Achievement[] memory);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function balanceOf(address owner) external view returns (uint256 balance);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

contract SoulBoundToken is ISoulBoundToken {
    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => Achievement[]) private _tokenAchievements;
    mapping(uint256 => string) private _tokenURIs;

    uint256 private _tokenIdCounter;

    function mint(address to, string memory metadataURI) external override returns (uint256) {
        require(to != address(0), "Invalid recipient");
        require(_balances[to] == 0, "Recipient already has a SoulBoundToken");

        uint256 tokenId = _tokenIdCounter++;
        _owners[tokenId] = to;
        _balances[to] = 1;
        _tokenURIs[tokenId] = metadataURI;

        emit Minted(to, tokenId);
        return tokenId;
    }

    function addAchievement(uint256 tokenId, string memory title, string memory dataURI) external override {
        require(_owners[tokenId] == msg.sender, "Not the token owner");

        Achievement memory newAchievement = Achievement(title, dataURI, block.timestamp);
        _tokenAchievements[tokenId].push(newAchievement);

        emit AchievementAdded(tokenId, title, dataURI, block.timestamp);
    }

    function getAchievements(uint256 tokenId) external view override returns (Achievement[] memory) {
        require(_owners[tokenId] != address(0), "Token does not exist");
        return _tokenAchievements[tokenId];
    }

    function ownerOf(uint256 tokenId) external view override returns (address owner) {
        owner = _owners[tokenId];
        require(owner != address(0), "Token does not exist");
    }

    function balanceOf(address owner) external view override returns (uint256 balance) {
        return _balances[owner];
    }

    function tokenURI(uint256 tokenId) external view override returns (string memory) {
        require(_owners[tokenId] != address(0), "Token does not exist");
        return _tokenURIs[tokenId];
    }

    function setTokenURI(uint256 tokenId, string memory newTokenURI) external {
        require(_owners[tokenId] == msg.sender, "Not the token owner");
        _tokenURIs[tokenId] = newTokenURI;
    }

    // Prevent transfers
    function _transfer(address from, address to, uint256 tokenId) internal pure {
        revert("SoulBoundToken: transfer is not allowed");
    }
}
