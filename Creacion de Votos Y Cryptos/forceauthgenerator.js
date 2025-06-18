import { forceRegenerateAuthSessions } from './authsessionsgenerator.js';

await forceRegenerateAuthSessions();
console.log('Auth sessions regeneradas.');