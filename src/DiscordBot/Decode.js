const { ethers } = require('ethers');

function decodeAchievements(encodedData) {
    // Remove '0x' prefix if present
    encodedData = encodedData.startsWith('0x') ? encodedData.slice(2) : encodedData;

    // Define the ABI for the Achievement struct array
    const achievementsAbi = ['tuple(string,string,uint256)[]'];

    // Decode the data
    const decodedData = ethers.AbiCoder.defaultAbiCoder().decode(achievementsAbi, '0x' + encodedData);

    // Process and print the achievements
    console.log('Achievements:');
    decodedData[0].forEach((achievement, index) => {
        console.log(`Achievement ${index + 1}:`);
        console.log(`  Title: ${achievement[0]}`);
        console.log(`  Description: ${achievement[1]}`);
        console.log(`  Timestamp: ${new Date(Number(achievement[2]) * 1000).toUTCString()}`);
        console.log();
    });
}

// Check if encodedData is provided as a command-line argument
if (process.argv.length < 3) {
    console.log('Please provide the encoded data as a command-line argument');
    process.exit(1);
}

const encodedData = process.argv[2];

decodeAchievements(encodedData);