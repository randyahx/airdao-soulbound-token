## Soulbound Token Standard (SBT)
This can be found under /src/SoulBoundTokenStandard and competes for the **Soul Bound Tokens (SBT’s) on AirDAO** prize category. The contract is modelled after ERC721.sol but is non-transferable with reputation management.

**SBT.sol** is the standard SBT Contract  

**SBTAchievements.sol** is an extendable that allows achievements to be added/removed for reputation management and specialized purposes such as gatekeeping communities.


## Token Gated Communities (Discord)
This can be found under /src/DiscordToken and competes for the **Token Gated Communities on AirDAO** prize category.  

### Deploy Discord Token

Add wallet private key to .env

```
source .env

forge script script/DeployDiscordToken.s.sol --rpc-url <airdao_testnet|airdao_mainnet> --private-key ${PRIVATE_KEY} --broadcast --legacy
```

### Interact with Discord Token

**Mint token**
```
cast send ${CONTRACT_ADDRESS} "mint(address,string)" ${RECIPIENT_ADDRESS} ${METADATA_URI}
--rpc-url eth_testnet --private-key ${PRIVATE_KEY}  
```

**Check if user owns a token.** This returns a token ID.  
```
cast call ${CONTRACT_ADDRESS} "balanceOf(address)(uint256)" 
${RECIPIENT_ADDRESS} --rpc-url <airdao_testnet|airdao_mainnet>
```

**Get all achievements for a token**
```
cast call 0xBEE236DD56637f5ED6D4c8A6721c694e8580448E "getAchievements(uint256)((string,string)[])" ${TOKEN_ID} --rpc-url eth_testnet
```

**Add achievement to token**
```
cast send ${CONTRACT_ADDRESS} "addAchievement(uint256,string,string)" ${TOKEN_ID} 
${ACHIEVEMENT_TITLE} ${ACHIEVEMENT_DESCRIPTION} --rpc-url <airdao_testnet|airdao_mainnet>
--private-key ${PRIVATE_KEY}
```

**Remove achievement from token**
```
cast send ${CONTRACT_ADDRESS} "removeAchievement(uint256,string)" ${TOKEN_ID} 
${ACHIEVEMENT_TITLE} --rpc-url <airdao_testnet|airdao_mainnet> --private-key ${PRIVATE_KEY}
```

cast send ${CONTRACT_ADDRESS} "mint(address,string)" 0xfa97a95C49369181211679d24F61A49470Bba110 "url" --rpc-url <airdao_testnet|airdao_mainnet> --private-key ${PRIVATE_KEY}

cast call 0xBEE236DD56637f5ED6D4c8A6721c694e8580448E "balanceOf(address)(uint256)" 0xfa97a95C49369181211679d24F61A49470Bba110 --rpc-url eth_testnet

cast send 0xBEE236DD56637f5ED6D4c8A6721c694e8580448E "addAchievement(uint256,string,string)" 1 "general" "general" --rpc-url eth_testnet --private-key ${PRIVATE_KEY}
```
cast send 0xBEE236DD56637f5ED6D4c8A6721c694e8580448E "removeAchievement(uint256,string)" 1 "private" --rpc-url eth_testnet --private-key ${PRIVATE_KEY}