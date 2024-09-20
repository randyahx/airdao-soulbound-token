// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/DiscordToken/DSBT.sol";

contract DiscordTokenTest is Test {
    DSBT public discordToken;
    address public owner;
    address public user1;
    address public user2;

    function setUp() public {
        owner = address(this);
        user1 = address(0x1);
        user2 = address(0x2);
        discordToken = new DSBT("Discord SBT", "DSBT");
    }

    function testMint() public {
        uint256 tokenId = discordToken.mint(user1, "https://example.com/token/1");
        assertEq(discordToken.ownerOf(tokenId), user1);
        assertEq(discordToken.balanceOf(user1), 1);
    }

    function testFailMintTwice() public {
        discordToken.mint(user1, "https://example.com/token/1");
        discordToken.mint(user1, "https://example.com/token/2");
    }

    function testAddAchievement() public {
        uint256 tokenId = discordToken.mint(user1, "https://example.com/token/1");
        discordToken.addAchievement(tokenId, "First Achievement", "Description");

        DSBT.Achievement[] memory achievements = discordToken.getAchievements(tokenId);
        assertEq(achievements.length, 1);
        assertEq(achievements[0].title, "First Achievement");
        assertEq(achievements[0].description, "Description");
    }

    function testFailAddAchievementNonOwner() public {
        uint256 tokenId = discordToken.mint(user1, "https://example.com/token/1");
        vm.prank(user2);
        discordToken.addAchievement(tokenId, "First Achievement", "Description");
    }

    function testRemoveAchievement() public {
        uint256 tokenId = discordToken.mint(user1, "https://example.com/token/1");
        discordToken.addAchievement(tokenId, "First Achievement", "Description");
        discordToken.addAchievement(tokenId, "Second Achievement", "Description");

        discordToken.removeAchievement(tokenId, "First Achievement");

        DSBT.Achievement[] memory achievements = discordToken.getAchievements(tokenId);
        assertEq(achievements.length, 1);
        assertEq(achievements[0].title, "Second Achievement");
    }

    function testFailRemoveNonExistentAchievement() public {
        uint256 tokenId = discordToken.mint(user1, "https://example.com/token/1");
        discordToken.removeAchievement(tokenId, "Non-existent Achievement");
    }

    function testHasAchievement() public {
        uint256 tokenId = discordToken.mint(user1, "https://example.com/token/1");
        discordToken.addAchievement(tokenId, "First Achievement", "Description");

        assertTrue(discordToken.hasAchievement(tokenId, "First Achievement"));
        assertFalse(discordToken.hasAchievement(tokenId, "Non-existent Achievement"));
    }
}
