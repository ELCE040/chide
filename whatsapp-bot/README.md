# WhatsApp Auto-Reply Bot 🤖

A simple yet powerful WhatsApp auto-reply chatbot built with Node.js and [whatsapp-web.js](https://github.com/pedroslopez/whatsapp-web.js).

## Features ✨

- 🔑 **Keyword-based replies** - Set up automatic responses for specific keywords
- 👋 **Welcome messages** - Greet first-time contacts automatically
- 🌙 **Away mode** - Enable an away message when you're not available
- 🎯 **Exact match replies** - Respond to exact phrases
- 👥 **Group filtering** - Option to ignore group messages
- 📋 **Allow/Block lists** - Control who receives auto-replies
- 💾 **Session persistence** - Stay logged in between restarts
- ⏱️ **Natural delays** - Configurable reply delay for human-like responses

## Prerequisites 📋

- [Node.js](https://nodejs.org/) version 18 or higher
- A WhatsApp account
- Chrome/Chromium browser (automatically managed by Puppeteer)

## Installation 🛠️

1. **Navigate to the bot directory:**
   ```bash
   cd whatsapp-bot
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Start the bot:**
   ```bash
   npm start
   ```

4. **Scan the QR code:**
   - Open WhatsApp on your phone
   - Go to Settings > Linked Devices > Link a Device
   - Scan the QR code displayed in the terminal

## Configuration ⚙️

Edit the `config.js` file to customize your bot:

### Basic Settings

```javascript
module.exports = {
    // Bot name
    botName: "AutoReply Bot",

    // Welcome message for new contacts
    welcomeMessage: "👋 Hello! Thanks for reaching out...",

    // Away mode message
    awayMessage: "🔔 I'm currently away...",
    awayMode: false,  // Set to true to enable

    // Ignore group messages
    ignoreGroups: true,

    // Reply delay (milliseconds)
    replyDelay: 1000,
};
```

### Keyword Replies

Add keywords and their responses:

```javascript
keywordReplies: {
    "hello": "👋 Hi there!",
    "hours": "🕐 We're open 9 AM - 5 PM",
    "price": "💰 Contact us for pricing",
    // Add more keywords...
}
```

### Exact Match Replies

For messages that must match exactly:

```javascript
exactReplies: {
    "1": "You selected option 1",
    "2": "You selected option 2",
}
```

### Number Filtering

Control who receives replies:

```javascript
// Ignore these numbers (no auto-reply)
ignoredNumbers: ["1234567890"],

// Only reply to these numbers (leave empty for everyone)
allowedNumbers: [],
```

## Usage Examples 📝

### Simple FAQ Bot

```javascript
keywordReplies: {
    "hours": "🕐 Mon-Fri: 9 AM - 6 PM",
    "location": "📍 123 Main Street, City",
    "website": "🌐 www.example.com",
}
```

### Menu-Based Bot

```javascript
keywordReplies: {
    "menu": "Choose an option:\n1. Services\n2. Pricing\n3. Contact",
},
exactReplies: {
    "1": "Our services include...",
    "2": "Our pricing starts at...",
    "3": "Contact us at...",
}
```

### Away Message Bot

```javascript
awayMode: true,
awayMessage: "🌙 Thanks for your message! I'm currently away and will respond when I'm back.",
```

## Running as a Service 🔄

### Using PM2 (Recommended)

1. Install PM2:
   ```bash
   npm install -g pm2
   ```

2. Start the bot:
   ```bash
   pm2 start bot.js --name whatsapp-bot
   ```

3. Auto-start on system boot:
   ```bash
   pm2 startup
   pm2 save
   ```

4. View logs:
   ```bash
   pm2 logs whatsapp-bot
   ```

### Using systemd (Linux)

Create `/etc/systemd/system/whatsapp-bot.service`:

```ini
[Unit]
Description=WhatsApp Auto-Reply Bot
After=network.target

[Service]
Type=simple
User=your-username
WorkingDirectory=/path/to/whatsapp-bot
ExecStart=/usr/bin/node bot.js
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Then enable and start:
```bash
sudo systemctl enable whatsapp-bot
sudo systemctl start whatsapp-bot
```

## Troubleshooting 🔧

### QR Code Not Displaying
- Make sure your terminal supports Unicode characters
- Try running in a different terminal emulator

### Authentication Issues
- Delete the `session` folder and restart
- Make sure your phone has an active internet connection

### Puppeteer/Chrome Issues
On Linux, you may need to install dependencies:
```bash
sudo apt-get install -y gconf-service libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils wget
```

### Bot Not Responding
- Check if `ignoreGroups` is set correctly
- Verify the sender isn't in `ignoredNumbers`
- Check if `allowedNumbers` is restricting replies
- Look at console logs for errors

## Important Notes ⚠️

1. **WhatsApp Terms of Service**: Using automation with WhatsApp may violate their Terms of Service. Use responsibly and at your own risk.

2. **Account Safety**: Avoid sending too many messages too quickly to prevent your account from being flagged.

3. **Session Security**: The `session` folder contains your login credentials. Keep it secure and don't share it.

4. **Phone Requirements**: Your phone must stay connected to the internet for the bot to work.

## License 📄

MIT License - feel free to use and modify as needed!

## Contributing 🤝

Contributions are welcome! Feel free to submit issues and pull requests.
