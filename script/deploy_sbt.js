const hre = require("hardhat");

async function main() {
    // Deploy the contract
    const SBTBurnable = await hre.ethers.getContractFactory("SBTBurnable");
    const sbtBurnable = await SBTBurnable.deploy(
        "AirDAO Burnable SoulBound Token",
        "ABSBT",
        "This SoulBound Token represents membership in the AirDAO community and can be burned by the owner."
    );
    await sbtBurnable.deployed();
    console.log("SBTBurnable contract deployed to:", sbtBurnable.address);

    // Example: Mint a token with a generic metadata URI
    const [owner] = await ethers.getSigners();
    const metadataURI = "https://example.com/metadata/1"; // This could be any URI
    await sbtBurnable.mint(owner.address, metadataURI);
    console.log("Minted SBT with metadata URI:", metadataURI);

    // Get and log the token description
    const description = await sbtBurnable.description();
    console.log("Token description:", description);

    // Example: Burn the token
    const tokenId = 0; // Assuming this is the first token minted
    await sbtBurnable.burn(tokenId);
    console.log("Burned token with ID:", tokenId);

    // Try to get the owner of the burned token (this should fail)
    try {
        await sbtBurnable.ownerOf(tokenId);
    } catch (error) {
        console.log("As expected, cannot get owner of burned token:", error.message);
    }
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });