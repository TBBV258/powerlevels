# Epic Attribute Tracker

This is a standalone static UI for tracking RPG-style attributes and generating LLM-backed lore and strategy analysis.

Files:
- `index.html` — main UI and client-side JS.

Quick start (serve locally):

1. Change into the project directory:

```bash
cd /home/vansu/Documents/CC
```

2. Serve with a simple static server (Python 3):

```bash
python3 -m http.server 8000
# then open http://localhost:8000 in your browser
```

Notes & recommendations:
- Firebase: `index.html` expects runtime globals `__firebase_config` and optionally `__initial_auth_token` and `__app_id` to be provided before the script runs. For local testing you can create a small wrapper that injects these values into the page or host a server-side route that renders them into the page.

- Gemini / LLM: The page contains a `geminiApiCall` function that currently performs client-side requests to the Generative Language API. Do NOT embed your API keys in client-side code for production. Instead, create a small backend proxy (Node/Express, Flask, etc.) that stores the API key and forwards requests from the frontend. The README below outlines a minimal Node proxy example.

Minimal Node proxy example (recommended):

```js
// server.js
const express = require('express');
const fetch = require('node-fetch');
const app = express();
app.use(express.json());

const API_KEY = process.env.GEMINI_API_KEY; // set in env

app.post('/api/gemini', async (req, res) => {
  const { userQuery, systemPrompt, useSearch } = req.body;
  const model = 'gemini-2.5-flash-preview-09-2025';
  const url = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${API_KEY}`;

  const payload = { contents: [{ parts: [{ text: userQuery }] }], systemInstruction: { parts: [{ text: systemPrompt }] } };
  if (useSearch) payload.tools = [{ google_search: {} }];

  const r = await fetch(url, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(payload) });
  const body = await r.json();
  res.status(r.status).json(body);
});

app.listen(3000, () => console.log('Proxy running on http://localhost:3000'));
```

Then update the frontend to call `/api/gemini` instead of directly calling the public Google API.

Security:
- Keep secrets out of client-side code.
- Use Firebase security rules to lock access to users' documents.

If you want, I can:
- Add the minimal Node proxy and updated frontend wiring.
- Inject a sample `__firebase_config` wrapper for local testing (non-production only).
- Convert this to a small Vite + React app.
Tell me which next step you'd like.

Publishing to GitHub
--------------------
I included a helper script `publish_github.sh` that will create a repository in your GitHub account and push the current directory to it.

Usage (locally):

```bash
# Export your GitHub username and a personal access token with `repo` scope
export GITHUB_USER="your-github-username"
export GITHUB_TOKEN="ghp_xxx..."
# Optionally change repo name:
REPO_NAME=Powerlevel ./publish_github.sh
```

Notes:
- The script will create a repository named `Powerlevel` (or `REPO_NAME`) under your account and push the current directory as `main`.
- For security, do not share or commit your token. Use an environment variable and delete the token from your shell history after use.

Supabase SQL
------------
I added `supabase_schema.sql` which has the `attributes` table and a unique index used by the frontend's upsert. Paste it into the Supabase SQL editor at https://app.supabase.com for your project.

Files added:
- `supabase_schema.sql` — schema to create the `attributes` table and index
- `publish_github.sh` — helper script to create a GitHub repo and push
- `.gitignore` — basic ignores

If you want, I can run the publish script for you, but I'll need a GitHub token and your username to do that here. Alternatively, run the script locally (safer) and tell me if you want me to help check the remote/permissions after you run it.