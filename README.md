# Borsha Gadgets

Premium, Cloudflare-friendly static gadget storefront with a separate admin control room.

## Included
- Responsive storefront
- Borsha Signal™ merchandising concept
- Separate admin control room
- No database dependency
- Static HTML/CSS/JS-free deployment path
- Cloudflare Pages compatible

## Deploy
Upload this repository to Cloudflare Pages as a static site. Set the output directory to the repository root.

## Important
Because this version intentionally has no database/backend, admin data is presentation-only. For production authentication, orders, inventory persistence and protected business logic, connect the UI to Cloudflare Workers + D1/KV/R2.

Browser-delivered code can never be made completely invisible; production secrets must stay server-side.
