const { Client, GatewayIntentBits, Partials } = require('discord.js');
const { ethers } = require('ethers');
const dotenv = require('dotenv');
const { userWallets, dsbtContract } = require('./server');

dotenv.config();

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
const DISCORD_PORT = process.env.DISCORD_PORT || 3000;

client.on('ready', () => {
    console.log(`Logged in as ${client.user.tag}!`);
});

client.on('guildMemberAdd', async (member) => {
    member.send('Welcome! Please link your wallet using !link');
});

client.on('messageCreate', async (message) => {
    if (message.content.startsWith('!link')) {
        const userId = message.author.id;
        const linkUrl = `http://localhost:${DISCORD_PORT}/link/${userId}`;
        message.reply(`Please visit this URL to link your MetaMask wallet: ${linkUrl}`);
    }

    if (message.content.startsWith('!checkaccess')) {
        console.log('!checkaccess command received');
        const ethAddress = userWallets.get(message.author.id);
        if (!ethAddress) {
            console.log('No linked wallet found for user');
            return message.reply('Please link your wallet first using !link');
        }

        console.log(`Checking access for address: ${ethAddress}`);
        try {
            const balance = await dsbtContract.balanceOf(ethAddress);
            console.log(`Token balance: ${balance.toString()}`);
            if (balance === 0n) {
                return message.reply('You do not have a DSBT token. Please mint one using !link');
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

function startDiscordBot() {
    return client.login(DISCORD_TOKEN);
}

// Add this block to run the bot when the file is executed directly
if (require.main === module) {
    startDiscordBot().catch(error => {
        console.error('Failed to start Discord bot:', error);
    });
}

module.exports = { startDiscordBot };