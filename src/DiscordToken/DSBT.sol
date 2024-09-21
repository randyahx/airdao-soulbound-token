// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../SoulBoundTokenStandard/extendable/SBTAchievement.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DSBT is SBTAchievement, Ownable {
    uint256 private _tokenIdCounter;

    constructor(string memory name_, string memory symbol_) SBT(name_, symbol_) Ownable(msg.sender) {
        _tokenIdCounter = 0;
    }

    function addAchievement(uint256 tokenId, string memory title, string memory description) external onlyOwner {
        _addAchievement(tokenId, title, description);
    }

    function removeAchievement(uint256 tokenId, string memory title) external onlyOwner {
        _removeAchievement(tokenId, title);
    }

    function mint(address to, string memory metadataURI) external onlyOwner returns (uint256) {
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;
        _mint(to, tokenId, metadataURI);
        return tokenId;
    }

    function owner() public view override(SBTAchievement, Ownable) returns (address) {
        return Ownable.owner();
    }
}
