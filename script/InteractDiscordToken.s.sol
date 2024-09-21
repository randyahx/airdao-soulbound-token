// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/DiscordToken/DSBT.sol";

contract InteractDiscordToken is Script {
    DSBT public dsbtToken;

    function setUp() public {
        // Replace with the actual deployed contract address
        dsbtToken = DSBT(0xD6C6ee22d38D22879263dBb2Fa845B64a7bD055e);
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

        try dsbtToken.mint(recipient, tokenURI) returns (uint256 tokenId) {
            console.log("Token minted successfully. Token ID:", tokenId);
        } catch Error(string memory reason) {
            console.log("Minting failed. Reason:", reason);
        } catch (bytes memory lowLevelData) {
            console.log("Minting failed. Low-level error.");
        }

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
