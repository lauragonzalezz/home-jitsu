# Home-Jitsu

A mobile-first PWA for Brazilian jiu-jitsu practitioners: find training partners
near you, host and join open mats, chat in real time, and leave reviews.

![Home-Jitsu cover](https://user-images.githubusercontent.com/108884517/208539564-8b02a921-28b3-44c5-b7b5-9aeb0a0a8820.png)

## About this project

Home-Jitsu started in 2022 as a bootcamp team project, built by four of us
part-time over a bit less than a month, outside of work hours. The original
concept and pitch were mine, and I did most of the frontend work.

This repository is a **personal portfolio piece**: I (Laura Gonzalez) am
rewriting and modernizing the app **solo** to bring it up to current standards,
as a showcase of how I take a legacy codebase and make it clean, tested, and
production-ready. The frontend and UI/UX get particular attention here, since
that's where my passion and design background lie.

- **Original team project:** [laura-gonzalez-z/home-jitsu](https://github.com/laura-gonzalez-z/home-jitsu)
  — the 2022 bootcamp version, built with Jonathan Troupe, Touhami Abi, and
  Ricky Tran.
- **This repository:** the solo rewrite. Same product, rebuilt the right way.

It's a work in progress. Expect the app to keep changing as the upgrade lands
in small, reviewable steps.

## What I'm modernizing

The bootcamp app worked, but carried the usual shortcuts. The rewrite targets:

- **Current Ruby and Rails 8**, upgrading one minor version at a time.
- **Docker-only local development** — nothing to install on your host (see below).
- **$0 hosting** on free tiers, removing Redis in favor of the Solid trifecta
  (Solid Cable / Queue / Cache) on Postgres.
- **Real tests, CI, and accessible, polished UI** — portfolio quality throughout.

## Tech stack

- **Backend:** Ruby on Rails, PostgreSQL
- **Frontend:** Hotwire (Turbo + Stimulus), Bootstrap
- **Maps:** Mapbox GL · **Images:** Cloudinary · **Auth:** Devise · **Authz:** Pundit
- **Real-time chat:** Action Cable

## Running locally (Docker)

Local development runs entirely in Docker. You do **not** install Ruby, Node, or
Postgres on your machine, and you don't run `rails server` directly — the app and
database run in containers.

### Prerequisites

- Docker Desktop (or a compatible engine) with Docker Compose
- A `.env` file: copy the template and fill in your keys

  ```sh
  cp .env.example .env
  # then set MAPBOX_API_KEY and CLOUDINARY_URL in .env
  ```

### Start the app

From the project root:

```sh
docker compose up          # app + database, logs in your terminal
# or
docker compose up -d       # same, but detached (background)
```

This starts **both** the app and Postgres. Compose brings the database up first,
waits until it's healthy, then boots the app. On the very first run it also
installs dependencies and creates, migrates, and seeds the database automatically.

Then open **http://localhost:3000**.

Seed data is generated with Faker. You can sign in with any seeded user and the
password `123456`.

### Stop the app

```sh
# foreground: press Ctrl+C
docker compose down        # stop and remove containers (your DB data is kept)
```

### Common commands

Run Rails commands inside the running `app` container:

| Task | Command |
| --- | --- |
| Rails console | `docker compose exec app bin/rails console` |
| Run migrations | `docker compose exec app bin/rails db:migrate` |
| Run the test suite | `docker compose exec app bin/rails test` |
| Reset the database | `docker compose exec app bin/rails db:reset` |

If the stack isn't running, use a throwaway container instead:

```sh
docker compose run --rm app bin/rails <command>
```

### Port already in use?

The app binds to host port `3000`. If something else is using it (another app or
project), either stop that app or change the host port in `compose.yaml`:

```yaml
ports:
  - "3001:3000"   # then open http://localhost:3001
```

Only change the number on the left (your machine); the right side is the port
inside the container.

## Credits

Original team (2022):

- **Jonathan Troupe** — [@SaneCashew](https://github.com/SaneCashew)
- **Touhami Abi** — [@touhamiabi](https://github.com/touhamiabi)
- **Laura Gonzalez** — [@laura-gonzalez-z](https://github.com/laura-gonzalez-z)
- **Ricky Tran** — [@shadowSpin1](https://github.com/shadowSpin1)

See the [original project's contributors](https://github.com/laura-gonzalez-z/home-jitsu/graphs/contributors).
