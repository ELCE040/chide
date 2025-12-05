const { Client, LocalAuth, MessageMedia } = require('whatsapp-web.js');
const qrcode = require('qrcode-terminal');
require('dotenv').config();

// Bot configuration
const config = {
    autoReply: process.env.AUTO_REPLY_ENABLED === 'true' || true,
    defaultMessage: process.env.DEFAULT_MESSAGE || "Hello! Thanks for your message. I'll get back to you soon.",
    keywords: {
        // Add keyword-based responses
        'hello': 'Hi there! How can I help you?',
        'hi': 'Hello! What can I do for you?',
        'help': 'I\'m an auto-reply bot. You can ask me questions and I\'ll try to help!',
        'bye': 'Goodbye! Have a great day!',
        'thanks': 'You\'re welcome!',
        'thank you': 'You\'re welcome!',
    },
    // Time-based auto-reply (e.g., only reply during business hours)
    businessHours: {
        enabled: process.env.BUSINESS_HOURS_ENABLED === 'true' || false,
        start: process.env.BUSINESS_HOURS_START || '09:00',
        end: process.env.BUSINESS_HOURS_END || '17:00',
        timezone: process.env.TIMEZONE || 'UTC'
    },
    // Ignore specific contacts or groups
    ignoreList: process.env.IGNORE_LIST ? process.env.IGNORE_LIST.split(',') : []
};

// Initialize WhatsApp client
const client = new Client({
    authStrategy: new LocalAuth({
        dataPath: './.wwebjs_auth'
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

// Generate QR code for authentication
client.on('qr', (qr) => {
    console.log('Scan this QR code with your WhatsApp:');
    qrcode.generate(qr, { small: true });
    console.log('\nOr visit: https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=' + encodeURIComponent(qr));
});

// Client ready
client.on('ready', () => {
    console.log('✅ WhatsApp bot is ready!');
    console.log('Bot is now listening for messages...');
});

// Authentication events
client.on('authenticated', () => {
    console.log('✅ Authentication successful!');
});

client.on('auth_failure', (msg) => {
    console.error('❌ Authentication failed:', msg);
});

client.on('disconnected', (reason) => {
    console.log('❌ Client was disconnected:', reason);
});

// Check if message is within business hours
function isBusinessHours() {
    if (!config.businessHours.enabled) {
        return true;
    }

    const now = new Date();
    const currentTime = now.toLocaleTimeString('en-US', { 
        hour12: false, 
        hour: '2-digit', 
        minute: '2-digit',
        timeZone: config.businessHours.timezone
    });

    return currentTime >= config.businessHours.start && currentTime <= config.businessHours.end;
}

// Generate response based on message content
function generateResponse(message) {
    const lowerMessage = message.toLowerCase().trim();

    // Check for keyword matches
    for (const [keyword, response] of Object.entries(config.keywords)) {
        if (lowerMessage.includes(keyword.toLowerCase())) {
            return response;
        }
    }

    // Default response
    return config.defaultMessage;
}

// Check if contact should be ignored
function shouldIgnore(contactId) {
    return config.ignoreList.some(ignored => contactId.includes(ignored));
}

// Handle incoming messages
client.on('message', async (message) => {
    try {
        // Skip if auto-reply is disabled
        if (!config.autoReply) {
            return;
        }

        // Skip if message is from a group (optional - remove if you want group replies)
        const chat = await message.getChat();
        if (chat.isGroup) {
            return;
        }

        // Skip if contact is in ignore list
        const contact = await message.getContact();
        if (shouldIgnore(contact.id._serialized)) {
            return;
        }

        // Skip if message is from status (broadcast)
        if (message.from === 'status@broadcast') {
            return;
        }

        // Skip if message is sent by the bot itself
        if (message.fromMe) {
            return;
        }

        // Check business hours
        if (!isBusinessHours()) {
            console.log(`⏰ Message received outside business hours from ${contact.pushname || contact.number}`);
            return;
        }

        // Get message content
        const messageBody = message.body;

        // Generate response
        const response = generateResponse(messageBody);

        // Send reply
        await message.reply(response);
        console.log(`✅ Replied to ${contact.pushname || contact.number}: ${response}`);

    } catch (error) {
        console.error('❌ Error handling message:', error);
    }
});

// Handle message creation (for more advanced features)
client.on('message_create', async (message) => {
    // This event fires for both sent and received messages
    // You can add additional logic here if needed
});

// Error handling
client.on('error', (error) => {
    console.error('❌ Client error:', error);
});

// Start the client
console.log('🚀 Starting WhatsApp bot...');
client.initialize();

// Graceful shutdown
process.on('SIGINT', async () => {
    console.log('\n🛑 Shutting down bot...');
    await client.destroy();
    process.exit(0);
});
