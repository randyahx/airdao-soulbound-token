const hre = require("hardhat");

async function main() {
    const SoulBoundToken = await hre.ethers.getContractFactory("SoulBoundToken");
    const sbt = await SoulBoundToken.deploy("AirDAO SoulBound Token", "ASBT");

    await sbt.deployed();

    console.log("SoulBoundToken deployed to:", sbt.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });