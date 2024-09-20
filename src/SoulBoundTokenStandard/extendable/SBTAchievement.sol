// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../SBT.sol";

abstract contract SBTAchievement is SBT {
    struct Achievement {
        string title;
        string description;
        uint256 timestamp;
    }

    mapping(uint256 => Achievement[]) private _achievements;

    function _addAchievement(uint256 tokenId, string memory title, string memory description) internal {
        require(ownerOf(tokenId) != address(0), "SBTAchievement: Token does not exist");

        Achievement memory newAchievement = Achievement(title, description, block.timestamp);
        _achievements[tokenId].push(newAchievement);
    }

    function _removeAchievement(uint256 tokenId, string memory title) internal {
        require(ownerOf(tokenId) != address(0), "SBTAchievement: Token does not exist");

        Achievement[] storage tokenAchievements = _achievements[tokenId];
        for (uint256 i = 0; i < tokenAchievements.length; i++) {
            if (keccak256(bytes(tokenAchievements[i].title)) == keccak256(bytes(title))) {
                // Move the last element to the position of the element to be removed
                tokenAchievements[i] = tokenAchievements[tokenAchievements.length - 1];
                // Remove the last element
                tokenAchievements.pop();
                return;
            }
        }
        revert("SBTAchievement: Achievement not found");
    }

    function getAchievements(uint256 tokenId) external view returns (Achievement[] memory) {
        require(ownerOf(tokenId) != address(0), "SBTAchievement: Token does not exist");
        return _achievements[tokenId];
    }

    function hasAchievement(uint256 tokenId, string memory title) public view returns (bool) {
        require(ownerOf(tokenId) != address(0), "SBTAchievement: Token does not exist");

        Achievement[] memory tokenAchievements = _achievements[tokenId];
        for (uint256 i = 0; i < tokenAchievements.length; i++) {
            if (keccak256(bytes(tokenAchievements[i].title)) == keccak256(bytes(title))) {
                return true;
            }
        }
        return false;
    }
}
