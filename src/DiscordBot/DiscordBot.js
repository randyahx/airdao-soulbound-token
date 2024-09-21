const { Client, GatewayIntentBits, Partials } = require('discord.js');
const { ethers } = require('ethers');
const fs = require('fs');
const path = require('path');
const dotenv = require('dotenv');

dotenv.config();

const DSBT_JSON = JSON.parse(fs.readFileSync(path.join(__dirname, 'DSBT.json'), 'utf8'));
const DSBT_ABI = DSBT_JSON.abi;

const client = new Client({
    intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildMembers,
        GatewayIntentBits.GuildMessages,
        GatewayIntentBits.MessageContent,
    ],
    partials: [Partials.Message, Partials.Channel, Partials.Reaction],
});

const DISCORD_TOKEN = process.env.DISCORD_TOKEN;
const DSBT_ADDRESS = process.env.DSBT_ADDRESS;
const RPC_URL = process.env.RPC_URL;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const METADATA_LINK = "metadata";

console.log('DISCORD_TOKEN:', DISCORD_TOKEN ? 'Set' : 'Not set');
console.log('DSBT_ADDRESS:', DSBT_ADDRESS ? 'Set' : 'Not set');
console.log('RPC_URL:', RPC_URL ? 'Set' : 'Not set');
console.log('PRIVATE_KEY:', PRIVATE_KEY ? `Set (length: ${PRIVATE_KEY.length})` : 'Not set');

if (!PRIVATE_KEY) {
    throw new Error('PRIVATE_KEY is not set in the environment variables');
}

const formattedPrivateKey = PRIVATE_KEY.startsWith('0x') ? PRIVATE_KEY.slice(2) : PRIVATE_KEY;

const provider = new ethers.JsonRpcProvider(RPC_URL);
const signer = new ethers.Wallet(formattedPrivateKey, provider);

if (!Array.isArray(DSBT_ABI)) {
    throw new Error('Invalid ABI format. Expected an array.');
}

const dsbtContract = new ethers.Contract(DSBT_ADDRESS, DSBT_ABI, signer);

const userWallets = new Map();

client.on('ready', () => {
    console.log(`Logged in as ${client.user.tag}!`);
});

client.on('guildMemberAdd', async (member) => {
    member.send('Welcome! Please link your wallet using !link <ethereum_address>');
});

client.on('messageCreate', async (message) => {
    if (message.content.startsWith('!link')) {
        const args = message.content.split(' ');
        if (args.length !== 2) {
            return message.reply('Please use the format: !link <ethereum_address>');
        }
        const ethAddress = args[1];
        if (!ethers.isAddress(ethAddress)) {
            return message.reply('Invalid Ethereum address');
        }

        // Generate a unique message for the user to sign
        const nonce = Math.floor(Math.random() * 1000000).toString();
        const messageToSign = `Verify ownership of this wallet for Discord user ${message.author.id}: ${nonce}`;

        // Store the nonce and address temporarily
        userWallets.set(message.author.id, { address: ethAddress, nonce: nonce });

        // Send the verification instructions as a direct message
        try {
            await message.author.send(`Please sign this message to verify your wallet ownership: "${messageToSign}"\n` +
                `Then, use the command: !verify <signature> in a direct message to this bot.`);
            message.reply('Verification instructions have been sent to you via DM.');
        } catch (error) {
            console.error('Error sending DM:', error);
            message.reply('Unable to send you a DM. Please ensure your privacy settings allow DMs from server members.');
        }
    }

    if (message.content.startsWith('!verify')) {
        // Only process verify commands in DMs
        if (message.channel.type !== 1) { // 1 is the channel type for DM
            return message.reply('Please use the !verify command in a direct message to this bot for security reasons.');
        }

        const args = message.content.split(' ');
        if (args.length !== 2) {
            return message.reply('Please use the format: !verify <signature>');
        }
        const signature = args[1];

        const userWallet = userWallets.get(message.author.id);
        if (!userWallet) {
            return message.reply('Please use !link <ethereum_address> first in the server channel.');
        }

        const { address, nonce } = userWallet;
        const messageToSign = `Verify ownership of this wallet for Discord user ${message.author.id}: ${nonce}`;

        try {
            // Recover the address from the signature
            const recoveredAddress = ethers.verifyMessage(messageToSign, signature);

            if (recoveredAddress.toLowerCase() !== address.toLowerCase()) {
                return message.reply('Signature verification failed. Please try again.');
            }

            // Verification successful, now mint the token
            const balance = await dsbtContract.balanceOf(address);
            if (balance > 0n) {
                return message.reply('This address already has a DSBT token. Use !checkaccess to verify your achievements.');
            }

            const tx = await dsbtContract.mint(address, METADATA_LINK);
            await tx.wait();
            message.reply('Wallet verified and token minted successfully. Use !checkaccess to verify your achievements.');

        } catch (error) {
            console.error('Error verifying signature or minting token:', error);
            message.reply('An error occurred during verification or token minting.');
        }

        // Clear the temporary data
        userWallets.delete(message.author.id);
    }

    if (message.content.startsWith('!checkaccess')) {
        console.log('!checkaccess command received');
        const ethAddress = userWallets.get(message.author.id);
        if (!ethAddress) {
            console.log('No linked wallet found for user');
            return message.reply('Please link your wallet first using !link <ethereum_address>');
        }

        console.log(`Checking access for address: ${ethAddress}`);
        try {
            const balance = await dsbtContract.balanceOf(ethAddress);
            console.log(`Token balance: ${balance.toString()}`);
            if (balance === 0n) {
                return message.reply('You do not have a DSBT token. Please mint one using !link <ethereum_address>');
            }

            const tokenId = await dsbtContract.tokenOfOwnerByIndex(ethAddress, 0);
            console.log(`Token ID: ${tokenId.toString()}`);
            const achievements = await dsbtContract.getAchievements(tokenId);
            console.log(`Achievements: ${JSON.stringify(achievements)}`);

            let response = 'Your achievements:\n';
            let hasGeneral = false;
            let hasPrivate = false;

            for (const achievement of achievements) {
                response += `- ${achievement.title}: ${achievement.description}\n`;
                if (achievement.title === 'General') hasGeneral = true;
                if (achievement.title === 'Private') hasPrivate = true;
            }

            message.reply(response);

            // Grant roles based on achievements
            const member = message.member;
            if (hasGeneral) {
                await member.roles.add('1287105178130059275');
                message.reply('You have been granted access to the general channel.');
            }
            if (hasPrivate) {
                await member.roles.add('1287105637028991037');
                message.reply('You have been granted access to the private channel.');
            }
        } catch (error) {
            console.error('Error checking access:', error);
            message.reply('An error occurred while checking your access. Error: ' + error.message);
        }
    }

    if (message.content.startsWith('!grant') || message.content.startsWith('!revoke')) {
        const args = message.content.split(' ');
        if (args.length < 4) {
            return message.reply('Please use the format: !grant <admin_address> <target_address> <achievement_title> <achievement_description> or !revoke <admin_address> <target_address> <achievement_title>');
        }

        const adminAddress = args[1];
        const targetAddress = args[2];
        const title = args[3];

        if (!ethers.isAddress(adminAddress) || !ethers.isAddress(targetAddress)) {
            return message.reply('Invalid Ethereum address provided.');
        }

        try {
            const adminBalance = await dsbtContract.balanceOf(adminAddress);
            if (adminBalance === 0n) {
                return message.reply('The admin address does not have a DSBT token.');
            }

            const adminTokenId = await dsbtContract.tokenOfOwnerByIndex(adminAddress, 0);
            const adminAchievements = await dsbtContract.getAchievements(adminTokenId);

            const isAdmin = adminAchievements.some(achievement => achievement.title === 'admin');

            if (!isAdmin) {
                return message.reply('The provided address does not have the admin achievement to perform this action.');
            }

            const targetTokenId = await dsbtContract.tokenOfOwnerByIndex(targetAddress, 0);

            if (message.content.startsWith('!grant')) {
                const description = args.slice(4).join(' ');
                const tx = await dsbtContract.addAchievement(targetTokenId, title, description);
                await tx.wait();
                message.reply(`Achievement "${title}" granted successfully to ${targetAddress}`);
            } else if (message.content.startsWith('!revoke')) {
                const tx = await dsbtContract.removeAchievement(targetTokenId, title);
                await tx.wait();
                message.reply(`Achievement "${title}" revoked successfully from ${targetAddress}`);
            }
        } catch (error) {
            console.error('Error managing achievement:', error);
            message.reply('An error occurred while managing the achievement.');
        }
    }
});

client.login(DISCORD_TOKEN);