// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ISBTErrors {
    error SBTInvalidOwner(address owner);
    error SBTNonexistentToken(uint256 tokenId);
    error SBTIncorrectOwner(address sender, uint256 tokenId, address owner);
    error SBTInvalidSender(address sender);
    error SBTInvalidReceiver(address receiver);
    error SBTInsufficientApproval(address operator, uint256 tokenId);
    error SBTInvalidApprover(address approver);
    error SBTInvalidOperator(address operator);
}
