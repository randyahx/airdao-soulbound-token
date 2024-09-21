## Soulbound Token Standard (SBT)
This can be found under /src/SoulBoundTokenStandard
The contract is modelled after ERC721.sol but is non-transferable with reputation management.
**SBT.sol** is the standard SBT Contract  
**SBTAchievements.sol** is an extendable that allows achievements to be added/removed for reputation management and specialized purposes such as gatekeeping communities.

## Discord Token for gatekeeping Discord server
This can be found under /src/DiscordToken

### Deploy Discord Token

Add wallet private key to .env

```
source .env

forge script script/DeployDiscordToken.s.sol --rpc-url <airdao_testnet|airdao_mainnet> --private-key ${PRIVATE_KEY} --broadcast --legacy
```

### Check Contract State

```
forge script script/InteractDiscordToken.s.sol:InteractDiscordToken --sig "checkContractState()" --rpc-url <airdao_testnet|airdao_mainnet>  
```

### Interact with Discord Token

```
forge script script/InteractDiscordToken.s.sol:InteractDiscordToken --sig "mintToken(address,string)" <recipient_address> "<metadata_uri>" --rpc-url <airdao_testnet|airdao_mainnet> --broadcast --legacy

forge script script/InteractDiscordToken.s.sol:InteractDiscordToken --sig "addAchievement(uint256,string,string)" <token_id> "<title>" "<description>" --rpc-url <airdao_testnet|airdao_mainnet> --broadcast --legacy

forge script script/InteractDiscordToken.s.sol:InteractDiscordToken --sig "removeAchievement(uint256,string)" <token_id> "<title>" --rpc-url <airdao_testnet|airdao_mainnet> --broadcast --legacy
```

cast send ${CONTRACT_ADDRESS} "mint(address,string)" ${RECIPIENT_ADDRESS} "url" --rpc-url eth_testnet --private-key ${PRIVATE_KEY}

cast send 0xBEE236DD56637f5ED6D4c8A6721c694e8580448E "mint(address,string)" 0xfa97a95C49369181211679d24F61A49470Bba110 "url" --rpc-url eth_testnet --private-key ${PRIVATE_KEY}

cast call 0xBEE236DD56637f5ED6D4c8A6721c694e8580448E "balanceOf(address)(uint256)" 0xfa97a95C49369181211679d24F61A49470Bba110 --rpc-url eth_testnet

cast send 0xBEE236DD56637f5ED6D4c8A6721c694e8580448E "addAchievement(uint256,string,string)" 1 "general" "general" --rpc-url eth_testnet --private-key ${PRIVATE_KEY}

