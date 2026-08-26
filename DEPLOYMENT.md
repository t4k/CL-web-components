# Deployment Workflows

This guide explains how to deploy **CL-web-components** depending on what changed.

---

# Prerequisites

A `media.env` file must exist in the project root before deploying to S3.

It must contain:

```
BUCKET_NAME
BASE_URL
DISTRIBUTION_ID
```

This file is included in gitignore and is **not committed to git**.

---
  
# Deploy Documentation Changes

  
Use this workflow when **only documentation (`.md`) files have changed**.

## Step 1. Edit and push

Edit the Markdown, then commit and push:

```bash
git add <filename>
git commit -m "your commit message"
git push
```

There is no HTML to build by hand. The **Build and deploy docs** workflow
renders every `*.md` with Pandoc, rebuilds the Pagefind index, and publishes
to GitHub Pages on every push to `main`.

## Step 2. Confirm the deployment

Watch the run finish under the repository's **Actions** tab, or from the
command line:

```bash
gh run watch
```

The site updates at <https://caltechlibrary.github.io/CL-web-components/> when
the workflow completes, typically within a minute.

Pull requests build the site but do not publish it, so a change that breaks
the docs fails in review rather than after merge.

---
  
# Deploy Updated Web Component Code
  
  
Use this workflow when **component code in `src/` has changed** and needs to be deployed to the CDN.


## Step 1. Build compiled JavaScript

```bash
make build
```

This command runs `deno task build` and bundles:

- `src/*.js` > matching root-level `.js` files
- `mod.js` > `cl-web-components.js` (combined build)

## Step 2. Preview the S3 upload (optional)

```bash
./publish_to_s3.bash dry-run
```

This shows which files will be uploaded without making changes.

## Step 3. Save and push your working branch

If you added **new files**, stage them first:

```bash
git add <filename>
```

Then commit and push:

```bash
make save msg="your commit message"
```

> `make save` uses `git commit -am` which only commits already-tracked files. New files must be staged with `git add` first.

## Step 4. Deploy to S3 and refresh the CDN

```bash
./publish_to_s3.bash
```

This script:

- Uploads root `*.js` and `css/*.css` files
- Places them under `/cl-webcomponents/` in the S3 bucket
- Creates a **CloudFront cache invalidation** so the CDN serves the new files

The documentation site redeploys on its own when the push lands on `main`.

---
   
# Deploy a New Release  

Use this workflow when creating a **versioned GitHub release**.

## Step 1. Update release metadata

Edit `codemeta.json` and update:

- Version number
- Release notes

## Step 2. Build compiled output

```bash
make build
```

This command also regenerates several files from `codemeta.json`:

- `README.md`
- `version.js`
- `CITATION.cff`
- `about.md`

## Step 3. Build the distribution bundle

```bash
make dist
```

This command:

- Bundles files into `dist/`
- Copies documentation files:
  - `INSTALL.md`
  - `README.md`
  - `about.md`
  - `codemeta.json`
  - `CITATION.cff`
  - `LICENSE`
- Creates a release archive:

```
cl-web-components-<version>.zip
```

## Step 4. Save and push your working branch

If you added **new files**, stage them first:

```bash
git add <filename>
```

Then commit and push:

```bash
make save msg="your commit message"
```

> `make save` uses `git commit -am` which only commits already-tracked files. New files must be staged with `git add` first.

## Step 5. Create a draft GitHub release

```bash
./release.bash
```

This script:

- Reads the version and release notes from `codemeta.json`
- Commits changes
- Creates a **draft GitHub release** using the `gh` CLI
- Uploads the `.zip` archive

## Step 6. Publish the release

Open the GitHub releases page and publish the draft:

https://github.com/caltechlibrary/CL-web-components/releases

---

# Command Reference

| Task | Command |
|-----|---------|
| Compile source code | `make build` |
| Save and push working branch | `make save msg="your message"` |
| Deploy the docs site | Automatic on push to `main` (Actions -> Build and deploy docs) |
| Preview S3 deployment | `./publish_to_s3.bash dry-run` |
| Deploy JS to S3 and invalidate CDN cache | `./publish_to_s3.bash` |
| Invalidate CDN cache only | `./invalidate_cdn.bash` |
| Build distribution bundle | `make dist` |
| Create GitHub release | `./release.bash` |

---

