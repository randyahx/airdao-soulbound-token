// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ISBTErrors {
    error SBTInvalidOwner(address owner);
    error SBTNonexistentToken(uint256 tokenId);
    error SBTInvalidReceiver(address receiver);
    error SBTAlreadyHasToken(address owner);
    error SBTTokenAlreadyMinted(uint256 tokenId);
}
