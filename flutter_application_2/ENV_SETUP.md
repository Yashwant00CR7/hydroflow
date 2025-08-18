# Environment Variables Setup

This Flutter project uses environment variables to securely store API keys and configuration values.

## Setup Instructions

### 1. Create Environment File

Copy the example environment file and fill in your actual API keys:

```bash
cp .env.example .env
```

### 2. Configure Your API Keys

Edit the `.env` file and replace the placeholder values with your actual API keys:

```env
# API Keys
PINECONE_API_KEY=your_actual_pinecone_api_key_here
PINECONE_BASE_URL=your_actual_pinecone_base_url_here

# Add other API keys here as needed
# GROQ_API_KEY=your_groq_api_key_here
# OPENAI_API_KEY=your_openai_api_key_here
```

### 3. Security Notes

- **Never commit your `.env` file to version control** - it's already added to `.gitignore`
- Keep your `.env.example` file updated with new variables (but without actual values)
- Share API keys securely with team members

## Usage in Code

### Accessing Environment Variables

```dart
import 'config/env_config.dart';

// Get API keys
String apiKey = EnvConfig.pineconeApiKey;
String baseUrl = EnvConfig.pineconeBaseUrl;
```

### Adding New Environment Variables

1. Add the variable to your `.env` file:
   ```env
   NEW_API_KEY=your_new_api_key_here
   ```

2. Add the variable to `lib/config/env_config.dart`:
   ```dart
   static const String _newApiKeyKey = 'NEW_API_KEY';
   
   static String get newApiKey {
     return dotenv.env[_newApiKeyKey] ?? '';
   }
   ```

3. Update `.env.example` to include the new variable (without the actual value)

## Current Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `PINECONE_API_KEY` | Pinecone vector database API key | Yes |
| `PINECONE_BASE_URL` | Pinecone service URL | Yes |

## Troubleshooting

### Environment Variables Not Loading

1. Make sure the `.env` file exists in the project root
2. Verify the `.env` file is included in `pubspec.yaml` assets
3. Check that `EnvConfig.load()` is called in `main()` before using any environment variables

### API Key Issues

1. Verify your API keys are correct
2. Check that the keys have the necessary permissions
3. Ensure the base URLs are correct for your Pinecone environment

## Development vs Production

For different environments, you can create multiple `.env` files:
- `.env` - Development (default)
- `.env.production` - Production
- `.env.staging` - Staging

Update the `EnvConfig.load()` method to load the appropriate file based on your build configuration.
