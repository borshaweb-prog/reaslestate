# Borsha Gadgets

Premium React property platform for Cloudflare deployment.

## Stack
- React + JSX
- Vite
- JavaScript
- React Router
- Lucide icons
- Component-based frontend/admin architecture

## Build
npm install
npm run build

The source UI is React-based. The root index.html is only the minimal Vite document entry; no application UI is hard-coded there.

## Production backend
The current no-database demo persists browser edits in localStorage. For real shared admin data and authentication, connect Cloudflare Workers + D1.