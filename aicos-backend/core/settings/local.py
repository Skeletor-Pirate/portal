from .base import *

# Ensure DEBUG is True for local development
DEBUG = True

ALLOWED_HOSTS = ['*']

# ------------------------------------------------------------------------
# DATABASE CONFIGURATION (Supabase / PostgreSQL)
# ------------------------------------------------------------------------
# Reads DATABASE_URL from .env: postgres://[user]:[password]@[host]:5432/[db]
DATABASES = {
    'default': env.db('DATABASE_URL')
}

# ------------------------------------------------------------------------
# CORS CONFIGURATION
# ------------------------------------------------------------------------
# Allow local frontend servers (React/Vue/Angular) to communicate with the API
CORS_ALLOWED_ORIGINS = [
    "http://localhost:3000",
    "http://192.168.1.4:3000", "http://192.168.1.75:3000",
    "http://localhost:5173",  # Default Vite port
    "http://127.0.0.1:3000",
    "http://127.0.0.1:5173",
]

# ------------------------------------------------------------------------
# EMAIL CONFIGURATION (Local Testing)
# ------------------------------------------------------------------------
# Output emails to the console instead of sending them. 
# Perfect for testing the /auth/password-reset/ endpoints.
EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'