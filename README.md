# platform-admin
Administration Console for CREDEBL Platform Admin

## Docker Deployment

The image installs its own dependencies with Bun. The Docker build context
excludes local `node_modules`, Next.js output, Git metadata, and environment
files so host dependencies and local secrets are not copied into the image.

Supply the Dockerfile's `NEXT_PUBLIC_*` build arguments before building; Next.js
embeds these settings in the browser bundle. Runtime variables alone do not
update compiled public URLs.

For the configured sibling deployment, rebuild and recreate only this service:

```sh
cd ../deployment-togo
docker compose build platform-admin
docker compose up -d --no-deps platform-admin
```

Validate the image with the build command, then check sign-in and authenticated
API requests at the configured admin portal URL.
