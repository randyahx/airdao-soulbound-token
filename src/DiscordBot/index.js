const { startServer } = require('./server');
const { startDiscordBot } = require('./DiscordBot');

async function main() {
    try {
        await startServer();
        await startDiscordBot();
        console.log('Both server and Discord bot are running.');
    } catch (error) {
        console.error('Error starting services:', error);
    }
}

main();