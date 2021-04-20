####################################################################################################
# Configuration
####################################################################################################

# Build configuration

BUILD = build
MAKEFILE = Makefile
OUTPUT_FILENAME = textbook
METADATA = metadata.yml
TOC = --toc --toc-depth 3
METADATA_ARGS = --metadata-file $(METADATA)
IMAGES = $(shell find images -type f)
TEMPLATES = $(shell find docs/templates/ -type f)
COVER_IMAGE = images/cover.png
MATH_FORMULAS = --mathjax
CHAPTERS = chapters/*.md

# Chapters content
CONTENT = awk 'FNR==1 && NR!=1 {print "\n\n"}{print}' $(CHAPTERS)
CONTENT_FILTERS = tee # Use this to add sed filters or other piped commands

# Debugging

DEBUG_ARGS = --verbose

# Pandoc filtes - uncomment the following variable to enable cross references filter. For more
# information, check the "Cross references" section on the README.md file.

# FILTER_ARGS = --filter pandoc-crossref

# Combined arguments

ARGS = $(TOC) $(MATH_FORMULAS) $(METADATA_ARGS) $(FILTER_ARGS) $(DEBUG_ARGS)
	
PANDOC_COMMAND = pandoc

# Per-format options

DOCX_ARGS = --standalone --reference-doc docs/templates/docx.docx
EPUB_ARGS = --template docs/templates/epub.html --epub-cover-image $(COVER_IMAGE)
HTML_ARGS = --template docs/templates/lantern.html --standalone --to html5 --section-divs
PDF_ARGS = --template docs/templates/lantern.tex --pdf-engine xelatex

# Per-format file dependencies

BASE_DEPENDENCIES = $(MAKEFILE) $(CHAPTERS) $(METADATA) $(IMAGES) $(TEMPLATES)
DOCX_DEPENDENCIES = $(BASE_DEPENDENCIES)
EPUB_DEPENDENCIES = $(BASE_DEPENDENCIES)
HTML_DEPENDENCIES = $(BASE_DEPENDENCIES)
PDF_DEPENDENCIES = $(BASE_DEPENDENCIES)

####################################################################################################
# Basic actions
####################################################################################################

all:	book

book:	epub html pdf docx

clean:
	rm -r $(BUILD)

####################################################################################################
# File builders
####################################################################################################

epub:	$(BUILD)/$(OUTPUT_FILENAME).epub

html:	$(BUILD)/$(OUTPUT_FILENAME).html

pdf:	$(BUILD)/$(OUTPUT_FILENAME).pdf

docx:	$(BUILD)/$(OUTPUT_FILENAME).docx

$(BUILD)/$(OUTPUT_FILENAME).epub:	$(EPUB_DEPENDENCIES)
	mkdir -p $(BUILD)
	$(CONTENT) | $(CONTENT_FILTERS) | $(PANDOC_COMMAND) $(ARGS) $(EPUB_ARGS) -o $@
	@echo "$@ was built"

$(BUILD)/$(OUTPUT_FILENAME).html:	$(HTML_DEPENDENCIES)
	mkdir -p $(BUILD)
	$(CONTENT) | $(CONTENT_FILTERS) | $(PANDOC_COMMAND) $(ARGS) $(HTML_ARGS) -o $@
	cp --parents $(IMAGES) $(BUILD)
	cp docs/assets/* $(BUILD)
	mv build/textbook.html build/index.html
	@echo "$@ was built"

$(BUILD)/$(OUTPUT_FILENAME).pdf:	$(PDF_DEPENDENCIES)
	mkdir -p $(BUILD)
	$(CONTENT) | $(CONTENT_FILTERS) | $(PANDOC_COMMAND) $(ARGS) $(PDF_ARGS) -o $@
	@echo "$@ was built"

$(BUILD)/$(OUTPUT_FILENAME).docx:	$(DOCX_DEPENDENCIES)
	mkdir -p $(BUILD)
	$(CONTENT) | $(CONTENT_FILTERS) | $(PANDOC_COMMAND) $(ARGS) $(DOCX_ARGS) -o $@
	@echo "$@ was built"
