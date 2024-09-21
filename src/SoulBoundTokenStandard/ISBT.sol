// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ISBT {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function mint(address to) external returns (uint256 tokenId);
}
