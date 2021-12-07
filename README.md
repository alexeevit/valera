# - Zdarov, this is Valera

I'm a telegram bot with a Markov chain under the hood written in pure Ruby. Simply speaking, you can add me to your chat and I'll listen to you guys. If you want me to say something based on the chat, you have 3 options:

- Use the command `/generate`
- Mention me in a message
- Reply to my message

## Configuration

Use the next environment variables to configure me:

- `REDIS_URL` — the redis instance URL (example: `redis://localhost:6379/7`). I use redis to store the Markov chains.
- `TELEGRAM_API_TOKEN` — a token you obtained from the Telegram's BotFather.
- `APP_ENV` — supported environments: `development`, `production`, `test` (default: `development`).

For the `development` environment you can define the variables in the `.env` file.

## Run

To run the bot locally, use the `bin/bot` binary.

## Deploy

Use the prepared `Capistrano` config files. You only need to define `valera.site` in your `/etc/hosts` and add your ssh public key to the end server. Capistrano will try to deploy the bot into `deploy@valera.site:/var/www/valera`.

To run the server, use the systemd-service config file `valera.service.example`.
