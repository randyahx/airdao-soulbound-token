## Soulbound Token Standard (SBT)
This can be found under **/src/SoulBoundTokenStandard** and competes for the **Soul Bound Tokens (SBT’s) on AirDAO** prize category. The contract is modelled after ERC721.sol but is non-transferable with reputation management (achievements). Achievements can be granted/revoked to support token gated communities.

This is implemented by writing directly to the metadata through the URI. Usually it's expensive to perform string manipulation to store json strings in the URI but AirDAO is known for cheap fees so it's cheaper to pay gas than to use a decentralized storage like IPFS.


## Token Gated Communities (Discord)
This can be found under **/src/DiscordToken** and competes for the **Token Gated Communities on AirDAO** prize category. It implements the SBT for DSBT (Discord SBT) to assign user roles to allow access to channels after connecting their wallet.  

Wasn't able to finish the implementation in time.

### Deploy Discord Token

Add wallet private key to .env

```
source .env

forge script script/DeployDiscordToken.s.sol --rpc-url <airdao_testnet|airdao_mainnet> --private-key ${PRIVATE_KEY} --broadcast --legacy
```

