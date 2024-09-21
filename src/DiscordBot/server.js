const express = require('express');
const http = require('http');
const path = require('path');
const { ethers } = require('ethers');
const dotenv = require('dotenv');
const fs = require('fs');

dotenv.config();

const app = express();
const server = http.createServer(app);

const publicPath = path.join(__dirname, '..', '..', 'public');
app.use(express.static(publicPath));
app.use(express.json());

const DSBT_JSON = JSON.parse(fs.readFileSync(path.join(__dirname, 'DSBT.json'), 'utf8'));
const DSBT_ABI = DSBT_JSON.abi;

const DSBT_ADDRESS = process.env.DSBT_ADDRESS;
const RPC_URL = process.env.RPC_URL;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const METADATA_LINK = "metadata";
const SERVER_PORT = 3000; // Fixed port 3000

if (!PRIVATE_KEY) {
    throw new Error('PRIVATE_KEY is not set in the environment variables');
}

const formattedPrivateKey = PRIVATE_KEY.startsWith('0x') ? PRIVATE_KEY.slice(2) : PRIVATE_KEY;

const provider = new ethers.JsonRpcProvider(RPC_URL);
const signer = new ethers.Wallet(formattedPrivateKey, provider);

const dsbtContract = new ethers.Contract(DSBT_ADDRESS, DSBT_ABI, signer);

const pendingVerifications = new Map();
const userWallets = new Map();

app.get('/link/:userId', (req, res) => {
    const userId = req.params.userId;
    const nonce = Math.floor(Math.random() * 1000000).toString();
    pendingVerifications.set(userId, { nonce, timestamp: Date.now() });

    res.sendFile(path.join(publicPath, 'link.html'));
});

app.get('/', (req, res) => {
    res.sendFile(path.join(publicPath, 'index.html'));
});

app.post('/verify', async (req, res) => {
    const { userId, address, signature } = req.body;
    const verification = pendingVerifications.get(userId);

    if (!verification) {
        return res.status(400).json({ error: 'Invalid or expired verification request' });
    }

    const messageToSign = `Verify ownership of this wallet for Discord user ${userId}: ${verification.nonce}`;

    try {
        const recoveredAddress = ethers.verifyMessage(messageToSign, signature);

        if (recoveredAddress.toLowerCase() !== address.toLowerCase()) {
            return res.status(400).json({ error: 'Signature verification failed' });
        }

        const balance = await dsbtContract.balanceOf(address);
        if (balance > 0n) {
            return res.status(400).json({ error: 'This address already has a DSBT token' });
        }

        const tx = await dsbtContract.mint(address, METADATA_LINK);
        await tx.wait();

        pendingVerifications.delete(userId);
        userWallets.set(userId, address);

        res.json({ success: true, message: 'Wallet verified and token minted successfully' });
    } catch (error) {
        console.error('Error verifying signature or minting token:', error);
        res.status(500).json({ error: 'An error occurred during verification or token minting' });
    }
});

function startServer() {
    return new Promise((resolve, reject) => {
        server.listen(SERVER_PORT, () => {
            console.log(`Server running on port ${SERVER_PORT}`);
            resolve();
        }).on('error', (error) => {
            if (error.code === 'EADDRINUSE') {
                console.error(`Port ${SERVER_PORT} is already in use. Please free up the port and try again.`);
            } else {
                console.error('Failed to start server:', error);
            }
            reject(error);
        });
    });
}

// Add this block to run the server when the file is executed directly
if (require.main === module) {
    startServer().then(() => {
        console.log('Server started successfully');
    }).catch(error => {
        console.error('Failed to start server:', error);
        process.exit(1);
    });
}

module.exports = { userWallets, dsbtContract, startServer };