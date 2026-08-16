# Thick Database Architecture & Postgres-Maximalism 🐘

A fully functional, self-contained Task Manager (Todo list) built using **zero backend code** and **zero frontend frameworks**. This project demonstrates the power of a "Thick Database" architecture where the database is responsible for data storage, business logic, and even rendering the HTML UI.

## Tech Stack
* **PostgreSQL:** The entire "Full Stack". Stores data, runs business logic, and physically writes HTML `<div>` tags via PL/pgSQL functions.
* **PostgREST:** A standalone web server that turns the PostgreSQL database directly into a RESTful API.
* **HTMX:** The frontend glue. A tiny library that allows the static HTML shell to send requests to PostgREST and swap the returned HTML directly into the DOM.

## Architecture Highlights
* ❌ **No Node.js, Python, or Go Backend.**
* ❌ **No React, Vue, or Client-Side JavaScript logic.**
* ✅ **Real-Time Polling:** HTMX polls the database automatically.
* ✅ **Native Dark Mode:** CSS respects your system's color scheme.

## Project Structure
```text
.
├── docker-compose.yml   # Orchestrates the Postgres and PostgREST containers
├── db/
│   └── init.sql         # The heart of the app: Schema, roles, and HTML-generating functions
└── public/
    └── index.html       # A completely static, dumb HTML shell that loads HTMX
```

## How to Run Locally

You only need [Docker Desktop](https://docs.docker.com/desktop/) installed.

1. Clone the repository.
2. Start the database and PostgREST server in the background:
   ```bash
   docker compose up -d
   ```
3. Open the `public/index.html` file directly in your web browser! No local dev server is required to view the frontend.

## How it Works

When you click "Add Task", HTMX intercepts the form submission and sends a POST request to `http://localhost:3000/rpc/add_task`. PostgREST securely executes the `add_task` function inside PostgreSQL. PostgreSQL inserts the data, loops through the tasks, builds a raw HTML string containing all your tasks, and returns it. HTMX catches this HTML string and instantly injects it into your screen. 

## Deployment to Production

If you want to host this on the internet:
1. **The Database:** Spin up a free [Supabase](https://supabase.com) project (which natively runs Postgres and PostgREST) and execute the `db/init.sql` script in their SQL Editor.
2. **The Frontend:** Update `public/index.html` to point to your new Supabase URL and deploy the `public` folder to [Vercel](https://vercel.com) as a static site.
