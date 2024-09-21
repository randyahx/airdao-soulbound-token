// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../lib/forge-std/src/Script.sol";
import "../src/DiscordToken/DSBT.sol";

contract DeployDiscordToken is Script {
    DSBT public dsbtToken;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        dsbtToken = new DSBT("DiscordSoulBoundToken", "DSBT");
        console.log("DiscordToken deployed to:", address(dsbtToken));
        console.log("DiscordToken Owner:", dsbtToken.owner());
        vm.stopBroadcast();
    }
}
