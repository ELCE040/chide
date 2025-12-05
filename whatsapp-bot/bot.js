/**
 * WhatsApp Auto-Reply Bot
 * 
 * This bot automatically replies to incoming WhatsApp messages
 * based on configured keywords and rules.
 * 
 * Usage:
 * 1. Run: npm install
 * 2. Run: npm start
 * 3. Scan the QR code with your WhatsApp mobile app
 * 4. The bot will start auto-replying to messages!
 */

const { Client, LocalAuth } = require('whatsapp-web.js');
const qrcode = require('qrcode-terminal');
const config = require('./config');

// Track contacts we've already welcomed (to avoid spam)
const welcomedContacts = new Set();

// Create WhatsApp client with local authentication (saves session)
const client = new Client({
    authStrategy: new LocalAuth({
        dataPath: './session'
    }),
    puppeteer: {
        headless: true,
        args: [
            '--no-sandbox',
            '--disable-setuid-sandbox',
            '--disable-dev-shm-usage',
            '--disable-accelerated-2d-canvas',
            '--no-first-run',
            '--no-zygote',
            '--disable-gpu'
        ]
    }
});

// Display QR code in terminal for authentication
client.on('qr', (qr) => {
    console.log('\n📱 Scan this QR code with your WhatsApp app:\n');
    qrcode.generate(qr, { small: true });
    console.log('\nWaiting for authentication...\n');
});

// Called when client is ready
client.on('ready', () => {
    console.log('✅ WhatsApp Bot is ready and listening for messages!\n');
    console.log('📋 Configuration:');
    console.log(`   • Away Mode: ${config.awayMode ? 'Enabled' : 'Disabled'}`);
    console.log(`   • Ignore Groups: ${config.ignoreGroups ? 'Yes' : 'No'}`);
    console.log(`   • Reply Delay: ${config.replyDelay}ms`);
    console.log(`   • Keywords configured: ${Object.keys(config.keywordReplies).length}`);
    console.log('\n🎯 Listening for incoming messages...\n');
});

// Handle authentication
client.on('authenticated', () => {
    console.log('🔐 Authentication successful!\n');
});

// Handle authentication failure
client.on('auth_failure', (msg) => {
    console.error('❌ Authentication failed:', msg);
});

// Handle disconnection
client.on('disconnected', (reason) => {
    console.log('🔌 Client disconnected:', reason);
    console.log('Attempting to reconnect...');
    client.initialize();
});

// Main message handler
client.on('message', async (message) => {
    try {
        // Get chat and contact info
        const chat = await message.getChat();
        const contact = await message.getContact();
        
        // Get sender's number (without @c.us suffix)
        const senderNumber = message.from.replace('@c.us', '').replace('@g.us', '');
        
        // Log message if enabled
        if (config.logMessages) {
            const timestamp = new Date().toLocaleString();
            const chatName = chat.isGroup ? `[Group: ${chat.name}]` : `[${contact.pushname || senderNumber}]`;
            console.log(`📩 ${timestamp} ${chatName}: ${message.body}`);
        }

        // Check if we should ignore this message
        if (shouldIgnoreMessage(message, chat, senderNumber)) {
            return;
        }

        // Determine the reply
        const reply = getReply(message.body, senderNumber);
        
        if (reply) {
            // Add delay to seem more natural
            await delay(config.replyDelay);
            
            // Send the reply
            await message.reply(reply);
            
            if (config.logMessages) {
                console.log(`📤 Replied: ${reply.substring(0, 50)}${reply.length > 50 ? '...' : ''}\n`);
            }
        }
    } catch (error) {
        console.error('❌ Error processing message:', error);
    }
});

/**
 * Check if we should ignore this message
 */
function shouldIgnoreMessage(message, chat, senderNumber) {
    // Ignore messages from self
    if (message.fromMe) {
        return true;
    }

    // Ignore status broadcasts
    if (config.ignoreStatus && message.isStatus) {
        return true;
    }

    // Ignore group messages if configured
    if (config.ignoreGroups && chat.isGroup) {
        return true;
    }

    // Ignore specific numbers
    if (config.ignoredNumbers.includes(senderNumber)) {
        return true;
    }

    // Only reply to allowed numbers if the list is not empty
    if (config.allowedNumbers.length > 0 && !config.allowedNumbers.includes(senderNumber)) {
        return true;
    }

    // Ignore non-text messages (images, videos, etc.)
    if (!message.body || message.body.trim() === '') {
        return true;
    }

    return false;
}

/**
 * Get the appropriate reply for a message
 */
function getReply(messageBody, senderNumber) {
    const lowerMessage = messageBody.toLowerCase().trim();

    // Check for welcome message (first time contact)
    if (config.welcomeMessage && !welcomedContacts.has(senderNumber)) {
        welcomedContacts.add(senderNumber);
        return config.welcomeMessage;
    }

    // Check away mode first
    if (config.awayMode && config.awayMessage) {
        return config.awayMessage;
    }

    // Check exact matches first
    if (config.exactReplies[lowerMessage]) {
        return config.exactReplies[lowerMessage];
    }

    // Check keyword matches
    for (const [keyword, reply] of Object.entries(config.keywordReplies)) {
        if (lowerMessage.includes(keyword.toLowerCase())) {
            return reply;
        }
    }

    // Return default reply
    return config.defaultReply;
}

/**
 * Delay helper function
 */
function delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

// Handle graceful shutdown
process.on('SIGINT', async () => {
    console.log('\n\n👋 Shutting down bot...');
    await client.destroy();
    process.exit(0);
});

// Start the client
console.log('🚀 Starting WhatsApp Auto-Reply Bot...\n');
client.initialize();
