// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ISBT.sol";

interface ISBTMetadata is ISBT {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
