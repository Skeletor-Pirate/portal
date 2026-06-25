import axios from 'axios';

// 1. Read the base URL from the .env file, with a safe fallback to localhost for development
const API_URL = process.env.REACT_APP_API_BASE_URL;

// 2. Create an Axios instance with dynamic baseURL
// FIXED: Renamed 'api' to 'apiClient' to match the rest of the file
const apiClient = axios.create({
    baseURL: `${API_URL}/api/v1`,
    headers: {
        'Content-Type': 'application/json',
    },
}); 

// 3. Intercept requests to attach the JWT token
apiClient.interceptors.request.use(
    (config) => {
        // PRODUCTION READY: Only rely on the actual stored session token.
        // Never hardcode JWTs in frontend source code.
        const token = localStorage.getItem('access_token');

        if (token) {
            config.headers.Authorization = `Bearer ${token}`;
        }

        return config;
    },
    (error) => Promise.reject(error)
);

// Optional but highly recommended: Global response interceptor to handle expired tokens
apiClient.interceptors.response.use(
    (response) => response,
    (error) => {
        // If the backend returns a 401 Unauthorized, the token is expired or invalid
        if (error.response && error.response.status === 401) {
            // Clear the bad token and force the user back to the login screen
            localStorage.removeItem('access_token');
            localStorage.removeItem('user_data');
            window.location.href = '/login'; 
        }
        return Promise.reject(error);
    }
);

// 4. Export the configured Axios client
export default apiClient;