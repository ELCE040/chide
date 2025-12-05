/**
 * WhatsApp Bot Configuration
 * 
 * Customize your auto-reply responses here.
 * You can add keywords and their corresponding replies.
 */

module.exports = {
    // Bot name (used in some responses)
    botName: "AutoReply Bot",

    // Welcome message for first-time contacts (set to null to disable)
    welcomeMessage: "👋 Hello! Thanks for reaching out. I'm an auto-reply bot. How can I help you today?",

    // Away/busy message (sent when enabled)
    awayMessage: "🔔 I'm currently away and will get back to you as soon as possible. Thanks for your patience!",

    // Enable/disable away mode
    awayMode: false,

    // Keywords and their auto-replies (case-insensitive)
    // The bot checks if the message CONTAINS any of these keywords
    keywordReplies: {
        "hello": "👋 Hi there! How can I help you today?",
        "hi": "👋 Hello! What can I do for you?",
        "hey": "👋 Hey! Nice to hear from you!",
        "help": "ℹ️ Here's what I can help you with:\n\n1. Type 'info' for information\n2. Type 'hours' for business hours\n3. Type 'contact' for contact details\n4. Type 'menu' to see all options",
        "menu": "📋 *Menu Options:*\n\n1️⃣ info - Get information\n2️⃣ hours - Business hours\n3️⃣ contact - Contact details\n4️⃣ services - Our services\n5️⃣ price - Pricing information",
        "info": "ℹ️ We are a company dedicated to providing excellent service. Feel free to ask any questions!",
        "hours": "🕐 *Business Hours:*\n\nMonday - Friday: 9:00 AM - 6:00 PM\nSaturday: 10:00 AM - 2:00 PM\nSunday: Closed",
        "contact": "📞 *Contact Information:*\n\n📧 Email: example@email.com\n📱 Phone: +1 234 567 8900\n🌐 Website: www.example.com",
        "services": "🛠️ *Our Services:*\n\n• Service 1\n• Service 2\n• Service 3\n\nContact us for more details!",
        "price": "💰 For pricing information, please contact our sales team or visit our website.",
        "thanks": "🙏 You're welcome! Is there anything else I can help you with?",
        "thank you": "🙏 You're welcome! Feel free to reach out anytime!",
        "bye": "👋 Goodbye! Have a great day!",
        "goodbye": "👋 Take care! Don't hesitate to reach out if you need anything!"
    },

    // Exact match replies (message must match exactly, case-insensitive)
    exactReplies: {
        "?": "❓ Need help? Type 'menu' to see available options.",
        "1": "You selected option 1. Here's the information...",
        "2": "You selected option 2. Here's the information...",
        "3": "You selected option 3. Here's the information..."
    },

    // Default reply when no keyword matches (set to null to not reply)
    defaultReply: "🤖 Thanks for your message! I'm an auto-reply bot. Type 'menu' to see available options, or 'help' if you need assistance.",

    // Ignore messages from groups (set to true to only reply to direct messages)
    ignoreGroups: true,

    // Ignore messages from status broadcasts
    ignoreStatus: true,

    // Delay before sending reply (in milliseconds) - makes it feel more natural
    replyDelay: 1000,

    // Numbers to ignore (add phone numbers with country code, without + or spaces)
    ignoredNumbers: [
        // "1234567890",
    ],

    // Only reply to specific numbers (leave empty to reply to everyone)
    // If not empty, only these numbers will receive auto-replies
    allowedNumbers: [
        // "1234567890",
    ],

    // Log all messages to console
    logMessages: true
};
