---
name: km-installer
description: Install KISSmetrics analytics into this project and wire up tracking. Use when the user wants to add KISSmetrics / KM / the _kmq tracking snippet to their site or app, set up page-view or custom-event tracking, or asks to "install KISSmetrics", "add the KM snippet", "track events with Kissmetrics". Works on any stack — detects the framework, inserts the hosted snippet in the right file, optionally adds custom events, and opens a branch for review.
---

# Install KISSmetrics

You are installing KISSmetrics analytics into the user's project. The hosted JS SDK is
browser-side, so it runs on **any** backend — only *where* the snippet goes changes per stack.
Your job: detect the stack, confirm it with the user, drop the snippet in the correct file with
their key pre-filled, optionally wire up custom events, push a review branch, and help them
confirm the first event arrives.


---

## Step 0 — Get the KM key

Ask the user for their **KISSmetrics product key** (`_kmk`). It looks like a long hex string and
is found in the KISSmetrics dashboard under the product's tracking settings. Do not proceed to
edit files until you have it — every snippet must be pre-filled with the real key, never the
`YOUR_KM_KEY` placeholder.

**Sanity-check what they paste.** A valid product key is a ~40-character hex string (`0-9a-f`),
e.g. `68e287cb2aee6731962a534de77239262a73deac`. If they paste something that doesn't look like
that (too short, contains dashes, or is an email/URL), they may have grabbed the wrong value (an
account ID or product GUID instead of the tracking key) — point them back to the product's
tracking settings before continuing.

---

## Step 1 — Detect the stack (read the repo)

Read the repo to identify the stack. Look for these signals, then **tell the user what you found
and ask them to confirm** (offer the most likely option first):

| If you see… | Likely stack | Snippet target file |
|---|---|---|
| `package.json` with `next` | **Next.js** | `app/layout.tsx` (App Router) or `pages/_document.tsx` (Pages Router) |
| `package.json` with `react` (CRA/Vite) | **React** | `public/index.html` or the root entry (`main.tsx`) |
| `package.json` with `vue`/`nuxt` | **Vue / Nuxt** | `index.html` / `nuxt.config` head, or app entry |
| `package.json` with `@angular/core` | **Angular** | `src/index.html` |
| `package.json` with `express` | **Node / Express** | the layout/`head` partial in `views/` |
| `composer.json` / `*.blade.php` | **PHP / Laravel** | `resources/views/layouts/app.blade.php` or `header.php` |
| `requirements.txt` / `manage.py` / `*.html` templates | **Python (Django/Flask)** | `base.html` (the shared template) |
| `Gemfile` / `*.erb` | **Ruby (Rails/Sinatra)** | `app/views/layouts/application.html.erb` |
| `go.mod` | **Go** | the shared head template |
| `*.csproj` / `*.cshtml` | **.NET** | `_Layout.cshtml` |
| `mix.exs` | **Elixir / Phoenix** | the root layout (`root.html.heex`) |
| plain `.html` files only | **Static HTML** | the `<head>` of every page |
| WordPress theme (`wp-content`, `functions.php`) | **WordPress** | see "CRM sites" below |
| Shopify theme (`*.liquid`, `theme.liquid`) | **Shopify** | see "CRM sites" below |

If signals are mixed (e.g. a Next.js frontend in front of a Rails API), the snippet goes in the
**frontend** that renders the HTML the browser loads. When unsure, ask.

### CRM sites (WordPress / Shopify / Wix / Webflow)
If this is a hosted website-builder project, the easiest install is **not** code — it's the
official app/plugin (Shopify app, WordPress plugin) or pasting the snippet into the builder's
"custom code / head" section. Tell the user this and offer to add the snippet to the theme's head
template only if they prefer the code route.

---

## Step 2 — Check if it's already installed

Before editing, search the repo for an existing install so you never add a duplicate:

- Grep for `kissmetrics.io`, `_kmq`, or `_kms` across the codebase.
- If found, tell the user it's already installed, show where, and skip to **Step 5 (verify)** or
  **Step 4 (custom events)** as appropriate.

---

## Step 3 — Insert the snippet

Insert this snippet, with `_kmk` set to the user's real key, as **high in `<head>` as possible**
(before other scripts) in the file identified in Step 1:

```html
<script type="text/javascript">
var _kmq = _kmq || []; var _kmk = _kmk || 'THE_USERS_KM_KEY';
function _kms(u){setTimeout(function(){var d=document,f=d.getElementsByTagName('script')[0],
s=d.createElement('script');s.type='text/javascript';s.async=true;s.src=u;
f.parentNode.insertBefore(s,f);},1);}
_kms('//i.kissmetrics.io/i.js');
_kms('//scripts.kissmetrics.io/' + _kmk + '.2.js');
</script>
```

This loads KISSmetrics' hosted SDK — **nothing else to install** — and starts tracking page views
automatically. It exposes the global `_kmq` queue for custom events.

### Framework-specific placement notes
- **Next.js App Router**: put it in `app/layout.tsx` using `next/script` with
  `strategy="afterInteractive"`, or a raw `<script>` inside the `<head>`. Page-view tracking on
  client-side route changes may need a small route-change listener (call `_kmq.push(['record','Viewed Page'])` on navigation) since SPAs don't reload.
- **React/Vue/Angular SPAs**: the snippet in the HTML shell tracks the first load; for in-app
  route changes, push a page-view event on navigation.
- **Server-rendered (PHP/Django/Rails/Go/.NET/Elixir/static)**: pasting it once in the shared
  layout/head covers every page — no extra work.

After inserting, show the user the exact diff and the file path.

---

## Step 4 — Custom events (optional, ask the user)

Page views are automatic. **Custom events** are the business actions that matter (Signed Up,
Purchased, Upgraded). Ask the user which actions they want to track, then add `_kmq` calls at the
point in the code where each action happens.

The `_kmq` API:

| Command | What it does |
|---|---|
| `_kmq.push(['record','Purchased',{value:49}])` | track an event, with optional properties |
| `_kmq.push(['identify','user@email.com'])` | attach an identity (do this at login/signup) |
| `_kmq.push(['set',{plan:'Pro'}])` | save properties on the person |

Worked example (signup → purchase):
```js
_kmq.push(['identify','sara@acme.com']);
_kmq.push(['set',{ signup_source:'google-ads' }]);
_kmq.push(['record','Signed Up']);
// later, on payment:
_kmq.push(['record','Purchased',{ plan:'Pro', value:49 }]);
```

Where to put each call, by stack (in the view/handler where the action fires):

| Stack | Example |
|---|---|
| **PHP / Laravel** | `@if($order)<script>_kmq.push(['record','Placed Order',{value:{{$order->total}}}]);</script>@endif` |
| **Python / Django** | `{% if order %}<script>_kmq.push(['record','Completed Checkout']);</script>{% endif %}` |
| **Ruby / Rails** | `<% if @order %><script>_kmq.push(['record','Upgraded']);</script><% end %>` |
| **Node / Express** | `<% if (user) { %><script>_kmq.push(['record','Started Trial']);</script><% } %>` |
| **React / SPA** | `onClick={() => window._kmq.push(['record','Clicked Buy'])}` |

Notes:
- In React/SPA code reference it as `window._kmq` (the global) and guard for SSR (`typeof window !== 'undefined'`).
- `identify` should run once the user is known (login/signup), before recording their events.
- Keep event names human-readable and consistent ("Signed Up", not "signup_evt_1").

---

## Step 5 — Open a review branch

Do **not** commit straight to the main branch. Create a branch, commit the changes, and leave it
for the team to review:

1. `git checkout -b feat/km_snippet`
2. Commit the snippet (and any event) changes with a clear message, e.g.
   `Add KISSmetrics tracking snippet and custom events`.
3. If the repo has a remote and the user wants it, push the branch and offer to open a PR for
   developer review/approval. **Never deploy or merge — installation must be reviewed by the
   project's own devs.**

---

## Step 6 — Verify the first event

Help the user confirm tracking actually works:

1. **Check the compiled SDK loads (do this first — it catches a silent failure).** The snippet
   loads `scripts.kissmetrics.io/<key>.2.js`, which is the real SDK that processes the `_kmq`
   queue. Confirm it returns **HTTP 200**, e.g.:
   ```
   curl -s -o /dev/null -w "%{http_code}\n" "https://scripts.kissmetrics.io/<THE_KEY>.2.js"
   ```
   - **200** → the SDK is published; tracking will work.
   - **403** (AccessDenied) → the key is valid but the product's script **was never published**,
     so `_kmq.push(...)` will queue forever and **no events are ever sent**. This is a known trap
     with newly-created products. Stop and tell the user: the install is correct, but tracking
     won't work until KISSmetrics publishes the product's script — they should contact KM support
     / regenerate the product rather than keep debugging their own code.
2. Run the site locally (or in their environment) and load a page in the browser.
3. In the browser devtools **Network** tab, look for requests to `i.kissmetrics.io` /
   `scripts.kissmetrics.io` and to the tracking endpoint (`trc.kissmetrics.io`) firing on page
   load and on the custom events.
4. In the **KISSmetrics dashboard**, the first event/page view should appear under the product's
   live data within ~a minute.
5. Confirm with the user whether data arrived, or help debug if nothing does. Most common causes:
   `<key>.2.js` returning 403 (step 1), wrong key, snippet placed too low / not in the rendered
   head, or an ad-blocker in the test browser.

---

## Summary of what you deliver

- Stack detected **and confirmed with the user**.
- Snippet inserted in the correct file with the **real key** pre-filled (no duplicates).
- Any requested custom events wired up at the right code points.
- All changes on a `feat/km_snippet` branch, committed, ready for the team's review.
- `<key>.2.js` confirmed to load (HTTP 200), and the user helped through verifying the first
  event — or a clear next step to verify it themselves.
