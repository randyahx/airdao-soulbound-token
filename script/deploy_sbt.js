const hre = require("hardhat");

async function main() {
    // Deploy the contract
    const SoulBoundToken = await hre.ethers.getContractFactory("SoulBoundToken");
    const sbt = await SoulBoundToken.deploy("AirDAO SoulBound Token", "ASBT");
    await sbt.deployed();
    console.log("SoulBoundToken standard deployed to:", sbt.address);

    // Example: Mint a token with a generic metadata URI
    const [owner] = await ethers.getSigners();
    const metadataURI = "https://example.com/metadata/1"; // This could be any URI
    await sbt.mint(owner.address, metadataURI);
    console.log("Minted SBT with metadata URI:", metadataURI);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });