
# generated with CMTools 0.0.15 50d2dd2

#
# Makefile for building the documentation website with pandoc.
#
# Everything that gets published is assembled into $(HTDOCS). Nothing in
# there is committed -- .github/workflows/docs.yml runs this target and
# uploads the directory to GitHub Pages.
#
PROJECT = CL-web-components

PANDOC = $(shell which pandoc)

PAGEFIND = $(shell which pagefind)

HTDOCS = docs

MD_PAGES = $(shell ls -1 *.md)

HTML_PAGES = $(shell ls -1 *.md | sed -E 's|^|$(HTDOCS)/|; s/\.md/\.html/')

# Hand-written pages, copied into the site as-is.
STATIC_PAGES = $(shell ls -1 demo_*.html *test*.html)

# Runtime assets the pages load. LICENSE is linked from the page template.
STATIC_FILES = $(shell ls -1 *.js) LICENSE .nojekyll

STATIC_DIRS = css src

build: pagefind

$(HTML_PAGES): $(MD_PAGES) .FORCE
	@mkdir -p $(HTDOCS)
	if [ -f $(PANDOC) ]; then $(PANDOC) --metadata title=$(notdir $(basename $@)) -s --to html5 $(notdir $(basename $@)).md -o $@ \
		--lua-filter=links-to-html.lua \
		--lua-filter=add-col-scope.lua \
	    --template=page.tmpl; fi
	@if [ $@ = "$(HTDOCS)/README.html" ]; then mv $(HTDOCS)/README.html $(HTDOCS)/index.html; fi

static: .FORCE
	@mkdir -p $(HTDOCS)
	cp -p $(STATIC_PAGES) $(STATIC_FILES) $(HTDOCS)/
	cp -Rp $(STATIC_DIRS) $(HTDOCS)/

# Depends on the pages and assets so the index always matches what ships.
pagefind: $(HTML_PAGES) static
	@if [ -f $(PAGEFIND) ]; then $(PAGEFIND) --site $(HTDOCS) --force-language en-US --exclude-selectors "nav,header,footer"; fi

clean:
	@rm -rf $(HTDOCS)

.FORCE:
