// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../SoulBoundTokenStandard/SBT.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DSBT is SBT, Ownable {
    constructor(string memory name_, string memory symbol_) SBT(name_, symbol_) Ownable(msg.sender) {}

    function addAchievement(uint256 tokenId, string memory title, string memory description)
        external
        override
        onlyOwner
    {
        _addAchievement(tokenId, title, description);
    }

    function removeAchievement(uint256 tokenId, string memory title) external override onlyOwner {
        _removeAchievement(tokenId, title);
    }

    function mint(address to) external override onlyOwner returns (uint256) {
        return _mint(to);
    }

    function owner() public view override(Ownable) returns (address) {
        return Ownable.owner();
    }

    function _owner() internal view override returns (address) {
        return Ownable.owner();
    }
}
