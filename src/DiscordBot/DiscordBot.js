const { Client, GatewayIntentBits, Partials } = require('discord.js');
const ethers = require('ethers');
const DSBT_ABI = require('./DSBT_ABI.json'); // You'll need to create this ABI file

const client = new Client({
    intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildMembers,
        GatewayIntentBits.GuildMessages,
        GatewayIntentBits.MessageContent,
    ],
    partials: [Partials.Message, Partials.Channel, Partials.Reaction],
});

const DISCORD_TOKEN = 'YOUR_DISCORD_BOT_TOKEN';
const DSBT_ADDRESS = 'YOUR_DSBT_CONTRACT_ADDRESS';
const RPC_URL = 'YOUR_ETHEREUM_RPC_URL';

const provider = new ethers.providers.JsonRpcProvider(RPC_URL);
const dsbtContract = new ethers.Contract(DSBT_ADDRESS, DSBT_ABI, provider);

// Store user wallet mappings (in a real application, use a database)
const userWallets = new Map();

client.on('ready', () => {
    console.log(`Logged in as ${client.user.tag}!`);
});

client.on('messageCreate', async (message) => {
    if (message.content.startsWith('!link')) {
        const args = message.content.split(' ');
        if (args.length !== 2) {
            return message.reply('Please use the format: !link <ethereum_address>');
        }
        const ethAddress = args[1];
        if (!ethers.utils.isAddress(ethAddress)) {
            return message.reply('Invalid Ethereum address');
        }
        userWallets.set(message.author.id, ethAddress);
        message.reply('Wallet linked successfully. Use !checkaccess to verify your achievements.');
    }

    if (message.content === '!checkaccess') {
        const ethAddress = userWallets.get(message.author.id);
        if (!ethAddress) {
            return message.reply('Please link your wallet first using !link <ethereum_address>');
        }

        try {
            const tokenId = await dsbtContract.tokenOfOwnerByIndex(ethAddress, 0); // Assuming one token per user
            const hasAccess = await dsbtContract.hasAchievement(tokenId, 'access');
            const hasGeneral = await dsbtContract.hasAchievement(tokenId, 'general');
            const hasPrivate = await dsbtContract.hasAchievement(tokenId, 'private');

            if (!hasAccess) {
                return message.reply('You do not have the required achievement to join this server.');
            }

            // Grant server access
            await message.member.roles.add('ACCESS_ROLE_ID');

            if (hasGeneral) {
                await message.member.roles.add('GENERAL_ROLE_ID');
                message.reply('You have been granted access to the general channel.');
            }

            if (hasPrivate) {
                await message.member.roles.add('PRIVATE_ROLE_ID');
                message.reply('You have been granted access to the private channel.');
            }

            if (!hasGeneral && !hasPrivate) {
                message.reply('You have server access, but no additional channel permissions.');
            }
        } catch (error) {
            console.error('Error checking access:', error);
            message.reply('An error occurred while checking your access.');
        }
    }
});

client.login(DISCORD_TOKEN);