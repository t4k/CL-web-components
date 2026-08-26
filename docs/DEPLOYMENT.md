# Deployment Workflows

This guide explains how to deploy **CL-web-components** depending on what changed.

---

# Prerequisites

None for documentation changes.

CDN deployment runs in GitHub Actions using an assumed AWS role, configured
through these repository secrets:

```
AWS_ROLE_TO_ASSUME
AWS_BUCKET
AWS_DISTRIBUTION
```

No local AWS credentials and no `media.env` file are needed.

---
  
# Deploy Documentation Changes

Use this workflow when **only documentation (`.md`) files have changed**.

Documentation is published automatically. Pushing to `main` triggers the
`.github/workflows/docs.yml` GitHub Actions workflow, which
runs Pandoc over every `*.md` file, rebuilds the Pagefind search index, and
deploys the result straight to GitHub Pages. There is no `gh-pages` branch and
no publishing script to run.

## Step 1. Preview (optional)

The site is built entirely by `.github/workflows/docs.yml`. Pandoc renders
every `docs/*.md` page plus the cmt-generated Markdown at the repository root,
the demo pages and runtime assets are copied in, and Pagefind rebuilds the
search index.

Opening a pull request builds the site without publishing it. The run's
`github-pages` artifact is the exact site that would be deployed, so
downloading it is the most accurate preview available.

To check a single page locally:

```bash
pandoc --metadata title=user_manual -s --to html5 docs/user_manual.md \
  -o /tmp/user_manual.html \
  --lua-filter=links-to-html.lua \
  --lua-filter=add-col-scope.lua \
  --template=page.tmpl
```

Documentation sources live in `docs/`. The files `cmt` generates into the
repository root -- `README.md`, `about.md`, `INSTALL.md` and the
`INSTALL_NOTES` pages -- are rendered from there, because `cmt` can only write
to the root. Build scripts and `llm_notes/` stay in the repository but are not
published.

## Step 2. Save and push your working branch

If you added **new files**, stage them first:

```bash
git add <filename>
```

Then commit and push:

```bash
make save msg="your commit message"
```

> `make save` uses `git commit -am` which only commits already-tracked files. New files must be staged with `git add` first.

## Step 3. Confirm the deployment

Once your change is on `main`, watch the run finish under the repository's
**Actions** tab, or from the command line:

```bash
gh run watch
```

The site updates at <https://caltechlibrary.github.io/CL-web-components/> when the
workflow completes, typically within a minute.

---

# Deploy Updated Web Component Code

Use this workflow when **component code in `src/` has changed** and needs to be
deployed to the CDN.

## Step 1. Edit and push

Edit the component under `src/`, then commit and push:

```bash
make save msg="your commit message"
```

The bundles are build output. They are compiled by CI into `dist/`, which is
gitignored, so there is nothing to rebuild or commit by hand.

## Step 2. Publish to the CDN

The **Publish components to CDN** workflow runs automatically when a GitHub
release is published. To push the current `main` without cutting a release,
run it manually from the Actions tab -- it accepts a `dry_run` option that
lists what would be uploaded without uploading it.

The workflow bundles the components, uploads them and `css/*.css` under
`/cl-webcomponents/` in the bucket, and invalidates the CloudFront cache for
that prefix.

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
| Deploy components to the CDN | Actions -> Publish components to CDN |
| Build distribution bundle | `make dist` |
| Create GitHub release | `./release.bash` |

---

