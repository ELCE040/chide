# WhatsApp Auto-Reply Chatbot

A simple and easy-to-use auto-reply chatbot for WhatsApp built with Node.js and `whatsapp-web.js`.

## Features

- ✅ Automatic message replies
- ✅ Keyword-based responses
- ✅ Business hours support
- ✅ Contact ignore list
- ✅ Group message filtering
- ✅ Easy configuration via environment variables

## Prerequisites

- Node.js (v14 or higher)
- npm or yarn
- A WhatsApp account (personal or business)

## Installation

1. **Clone or download this repository**

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Set up environment variables:**
   ```bash
   cp .env.example .env
   ```
   
   Then edit `.env` file with your preferences:
   ```env
   AUTO_REPLY_ENABLED=true
   DEFAULT_MESSAGE=Hello! Thanks for your message. I'll get back to you soon.
   BUSINESS_HOURS_ENABLED=false
   BUSINESS_HOURS_START=09:00
   BUSINESS_HOURS_END=17:00
   TIMEZONE=UTC
   ```

## Usage

1. **Start the bot:**
   ```bash
   npm start
   ```

2. **Scan the QR code:**
   - A QR code will appear in your terminal
   - Open WhatsApp on your phone
   - Go to Settings → Linked Devices
   - Tap "Link a Device"
   - Scan the QR code displayed in the terminal

3. **Wait for authentication:**
   - Once authenticated, you'll see: `✅ WhatsApp bot is ready!`
   - The bot will now automatically reply to incoming messages

## Configuration

### Basic Settings

Edit `bot.js` to customize:

- **Keywords and responses:** Modify the `keywords` object in the config
- **Default message:** Change `defaultMessage` in config or `.env` file
- **Business hours:** Enable and configure in `.env` file

### Example Keyword Configuration

```javascript
keywords: {
    'hello': 'Hi there! How can I help you?',
    'help': 'I\'m here to help! What do you need?',
    'pricing': 'Our pricing starts at $99/month. Would you like more details?',
    'contact': 'You can reach us at support@example.com',
}
```

### Advanced Features

#### Ignore Specific Contacts

Add contact IDs to the ignore list in `.env`:
```env
IGNORE_LIST=1234567890@c.us,0987654321@c.us
```

To find a contact ID, check the console logs when they send a message.

#### Business Hours

Enable business hours to only reply during specific times:
```env
BUSINESS_HOURS_ENABLED=true
BUSINESS_HOURS_START=09:00
BUSINESS_HOURS_END=17:00
TIMEZONE=America/New_York
```

## How It Works

1. The bot uses WhatsApp Web to connect to your WhatsApp account
2. It listens for incoming messages
3. When a message is received:
   - Checks if it's from a group (skips groups by default)
   - Checks if contact is in ignore list
   - Checks business hours (if enabled)
   - Matches keywords or sends default message
   - Replies automatically

## Important Notes

⚠️ **WhatsApp Terms of Service:**
- This bot uses WhatsApp Web, which is allowed by WhatsApp
- However, automated messaging should comply with WhatsApp's terms
- Use responsibly and don't spam users
- Consider using WhatsApp Business API for commercial use

⚠️ **Security:**
- Never share your `.wwebjs_auth` folder (contains session data)
- Keep your `.env` file private
- The bot runs locally on your machine

## Troubleshooting

### QR Code Not Appearing
- Make sure your terminal supports QR code display
- Check the console for the QR code URL
- Try running in a different terminal

### Authentication Fails
- Delete the `.wwebjs_auth` folder and try again
- Make sure WhatsApp Web is not already open in a browser
- Check your internet connection

### Bot Not Replying
- Check that `AUTO_REPLY_ENABLED=true` in `.env`
- Verify the bot shows "✅ WhatsApp bot is ready!"
- Check console logs for errors
- Make sure messages aren't from groups (if group replies are disabled)

### Session Expired
- If you see "Session expired", delete `.wwebjs_auth` folder
- Restart the bot and scan QR code again

## Customization

### Add Custom Logic

Edit the `message` event handler in `bot.js` to add:
- Database integration
- AI/ML responses (e.g., OpenAI, Google Gemini)
- Media handling
- Scheduled messages
- Analytics tracking

### Example: Add OpenAI Integration

```javascript
const { Configuration, OpenAIApi } = require('openai');

const openai = new OpenAIApi(new Configuration({
    apiKey: process.env.OPENAI_API_KEY
}));

// In message handler:
const response = await openai.createCompletion({
    model: "text-davinci-003",
    prompt: messageBody,
    max_tokens: 150
});
await message.reply(response.data.choices[0].text);
```

## License

MIT

## Support

For issues or questions:
1. Check the troubleshooting section
2. Review the `whatsapp-web.js` documentation
3. Check console logs for error messages

## Disclaimer

This bot is for educational and personal use. Make sure to comply with WhatsApp's Terms of Service and applicable laws in your jurisdiction when using automated messaging.
