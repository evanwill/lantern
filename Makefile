# textbook content settings
OUTPUT_FILENAME = textbook
OUTPUT_DIRECTORY = public
# looks for :Zone.Identifier files added by https://github.com/microsoft/WSL/issues/4609
CHECK = $(shell find . -name '*:Zone.Identifier' -delete)
IMAGES = $(shell find source/images -type f)
CHAPTERS = source/chapters/*.md
CONTENT = awk 'FNR==1 && NR!=1 {print "\n\n"}{print}' $(CHAPTERS)

# output configuration files
HTML = --verbose --filter pandoc-crossref --defaults assets/defaults/html.yml
DOCX = --defaults assets/defaults/docx.yml
LATEX = --filter pandoc-crossref --defaults assets/defaults/latex.yml --no-highlight
EPUB = --verbose --defaults assets/defaults/epub.yml --mathml

# utilities
MAKEFILE = Makefile
PANDOC_COMMAND = pandoc
BASE_DEPENDENCIES = $(MAKEFILE) $(CHECK) $(CHAPTERS) $(IMAGES) 

# build commands
textbook:	html docx latex epub pdf

epub:	$(OUTPUT_DIRECTORY)/$(OUTPUT_FILENAME).epub

html:	$(OUTPUT_DIRECTORY)/$(OUTPUT_FILENAME).html

pdf:	$(OUTPUT_DIRECTORY)/$(OUTPUT_FILENAME).pdf

docx:	$(OUTPUT_DIRECTORY)/$(OUTPUT_FILENAME).docx

latex:	$(OUTPUT_DIRECTORY)/$(OUTPUT_FILENAME).tex

markdown:
	bash ./assets/scripts/preprocess.sh

clean:
	rm -r $(OUTPUT_DIRECTORY)

# recipes for outputs
$(OUTPUT_DIRECTORY)/$(OUTPUT_FILENAME).epub:	$(BASE_DEPENDENCIES)
	mkdir -p $(OUTPUT_DIRECTORY)
	$(CONTENT) | tee | $(PANDOC_COMMAND) $(EPUB) -o $@
	@echo "$@ was built"

$(OUTPUT_DIRECTORY)/$(OUTPUT_FILENAME).html:	$(BASE_DEPENDENCIES)
	mkdir -p $(OUTPUT_DIRECTORY)
	$(CONTENT) | tee | $(PANDOC_COMMAND) $(HTML) -o $@
	cp $(IMAGES) $(OUTPUT_DIRECTORY)
	cp assets/lib/* $(OUTPUT_DIRECTORY)
	cp assets/styles/* $(OUTPUT_DIRECTORY)
	mv $(OUTPUT_DIRECTORY)/$(OUTPUT_FILENAME).html $(OUTPUT_DIRECTORY)/index.html
	@echo "$@ was built"

$(OUTPUT_DIRECTORY)/$(OUTPUT_FILENAME).pdf:	$(BASE_DEPENDENCIES)
	mkdir -p $(OUTPUT_DIRECTORY)
	$(CONTENT) | tee | $(PANDOC_COMMAND) $(LATEX) -o $@
	@echo "$@ was built"

$(OUTPUT_DIRECTORY)/$(OUTPUT_FILENAME).tex:	$(BASE_DEPENDENCIES)
	mkdir -p $(OUTPUT_DIRECTORY)
	$(CONTENT) | tee | $(PANDOC_COMMAND) $(LATEX) -o $@
	@echo "$@ was built"

$(OUTPUT_DIRECTORY)/$(OUTPUT_FILENAME).docx:	$(BASE_DEPENDENCIES)
	mkdir -p $(OUTPUT_DIRECTORY)
	$(CONTENT) | tee | $(PANDOC_COMMAND) $(DOCX) -o $@
	@echo "$@ was built"

# lantern documentation content settings 
DOCS_OUTPUT_DIRECTORY = public/docs
DOCS_IMAGES = $(shell find docs/images -type f)
DOCS_CONTENT = awk 'FNR==1 && NR!=1 {print "\n\n"}{print}' $(DOCS_CHAPTERS)
DOCS_DEPENDENCIES = $(MAKEFILE) $(CHECK) $(DOCS_CHAPTERS) $(DOCS_IMAGES)
DOCS = --defaults assets/defaults/docs.yml
DOCS_CHAPTERS += $(addprefix ./docs/chapters/,\
 introduction.md\
 technology.md\
 manuscripts.md\
 formatting.md\
 online-workflow.md\
 desktop-workflow.md\
 metadata.md\
 content.md\
 bibliographies.md\
 troubleshooting.md\
)

# documentation build commands
docs:	$(DOCS_OUTPUT_DIRECTORY)/index.html

# lantern documenation build recipes
$(DOCS_OUTPUT_DIRECTORY)/index.html:	$(DOCS_DEPENDENCIES)
	mkdir -p $(DOCS_OUTPUT_DIRECTORY)
	$(DOCS_CONTENT) | tee | $(PANDOC_COMMAND) $(DOCS) -o $@
	cp $(DOCS_IMAGES) $(DOCS_OUTPUT_DIRECTORY)
	cp assets/lib/* $(DOCS_OUTPUT_DIRECTORY)
	cp assets/styles/* $(DOCS_OUTPUT_DIRECTORY)
	@echo "$@ was built"