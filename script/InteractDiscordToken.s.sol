// // SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@forgestd/Script.sol";
import "@forgestd/console.sol";
import "../src/DiscordToken/DSBT.sol";

contract InteractDiscordToken is Script {
    DSBT public dsbtToken;

    function setUp() public {
        // Replace with the actual deployed contract address
        dsbtToken = DSBT(0xBEE236DD56637f5ED6D4c8A6721c694e8580448E);
    }

    function run() public {
        mintToken();
    }

    function mintToken() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address recipient = 0xfa97a95C49369181211679d24F61A49470Bba110;
        string memory tokenURI = "url";

        console.log("Attempting to mint token for address:", recipient);
        console.log("Token URI:", tokenURI);

        uint256 tokenId = dsbtToken.mint(recipient, tokenURI);
        console.log("Token Id: ", tokenId);

        vm.stopBroadcast();
    }

    function addAchievement(uint256 tokenId, string memory title, string memory description) public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        dsbtToken.addAchievement(tokenId, title, description);
        console.log("Achievement added - Token ID:", tokenId, "Title:", title);

        vm.stopBroadcast();
    }

    function removeAchievement(uint256 tokenId, string memory title) public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        dsbtToken.removeAchievement(tokenId, title);
        console.log("Achievement removed - Token ID:", tokenId, "Title:", title);

        vm.stopBroadcast();
    }

    function checkOwner() public view returns (address) {
        return dsbtToken.owner();
    }

    function checkName() public view returns (string memory) {
        return dsbtToken.name();
    }
}
