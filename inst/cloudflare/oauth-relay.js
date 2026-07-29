/**
 * Cloudflare Worker: zoomer OAuth relay
 *
 * Zoom does not accept localhost redirect URIs, so this Worker acts as a
 * relay: it receives the OAuth redirect from Zoom and immediately issues a
 * 302 to the user's local R session, which is listening on localhost.
 *
 * Setup
 * -----
 * 1. Go to https://workers.cloudflare.com/ and create a new Worker.
 * 2. Paste this script into the Worker editor and deploy.
 * 3. Copy the Worker URL (e.g. https://zoomer-oauth.<handle>.workers.dev).
 * 4. In your Zoom app config, set the OAuth Redirect URL to:
 *      https://zoomer-oauth.<handle>.workers.dev/callback
 * 5. In your .Rprofile, add:
 *      options(zoom.redirect_url = "https://zoomer-oauth.<handle>.workers.dev/callback")
 *      options(zoom.redirect_port = 1410L)  # default; change if port is in use
 *
 * How it works
 * ------------
 * zoomer encodes the local listener port in the OAuth `state` parameter as
 * "{port}:{nonce}". This Worker extracts the port and redirects to:
 *   http://localhost:{port}/callback?<all original query params>
 *
 * The nonce is preserved in state so R can validate the round-trip.
 *
 * Security note
 * -------------
 * The auth code is briefly visible in a URL handled by Cloudflare's
 * infrastructure, but it is never stored — only forwarded via 302. The nonce
 * in `state` provides CSRF protection on the R side.
 */

export default {
  async fetch(request) {
    const url = new URL(request.url);

    // Only handle /callback; return 404 for anything else.
    if (url.pathname !== "/callback") {
      return new Response("Not found", { status: 404 });
    }

    // Extract the local port from the state parameter.
    // zoomer formats state as "{port}:{32-char nonce}".
    const state = url.searchParams.get("state") ?? "";
    const portMatch = state.match(/^(\d+):/);
    const port = portMatch ? portMatch[1] : "1410";

    // Build the localhost target URL, forwarding all query parameters.
    const target = new URL(`http://localhost:${port}/callback`);
    for (const [key, value] of url.searchParams) {
      target.searchParams.set(key, value);
    }

    return Response.redirect(target.toString(), 302);
  },
};
