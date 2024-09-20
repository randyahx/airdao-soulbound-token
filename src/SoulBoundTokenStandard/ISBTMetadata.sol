// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ISBTMetadata {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
