DOCUMENT=emane-guide.pdf

BUILD_DIR_PDF=pdf
BUILD_DIR_SITE=site

INPUTS= \
 preface.txt \
 getting-started.txt \
 introduction.txt \
 paradigms.txt \
 applications.txt \
 physical-layer.txt \
 control-messages.txt \
 events.txt \
 antenna-patterns.txt \
 rf-pipe-radio-model.txt \
 ieee80211abg-radio-model.txt\
 tdma-radio-model.txt \
 bent-pipe-radio-model.txt \
 comm-effect-utility-model.txt \
 virtual-transport.txt \
 raw-transport.txt \
 eel-event-generator.txt \
 antenna-gain.txt

MARKDOWN_PDF = \
 $(addprefix $(BUILD_DIR_PDF)/,$(INPUTS:.txt=.md))

MARKDOWN_SITE = \
 $(addprefix $(BUILD_DIR_SITE)/,$(INPUTS:.txt=.md)) \
 $(BUILD_DIR_SITE)/license.md

.PHONY: site pdf

$(BUILD_DIR_PDF)/%.md: %.txt
	-mkdir -p $(BUILD_DIR_PDF)
	adjacentlink-doc -i $< -o $@

$(BUILD_DIR_SITE)/%.md: %.txt
	-mkdir -p $(BUILD_DIR_SITE)
	adjacentlink-doc -i $< -o $@ -t site

all:

pdf: $(BUILD_DIR_PDF)/$(DOCUMENT)

site: $(MARKDOWN_SITE)

$(BUILD_DIR_PDF)/$(DOCUMENT): doc-header-pdf.md $(MARKDOWN_PDF)
	pandoc \
	-i doc-header-pdf.md \
         $(MARKDOWN_PDF) \
	 --number-sections \
	 --highlight-style pygments.theme \
	 -f markdown+raw_tex+header_attributes+multiline_tables \
	 -V colorlinks \
	 -o $(BUILD_DIR_PDF)/$(DOCUMENT)

clean:	site-clean pdf-clean
	rm -f images/auto-generated-*

pdf-clean:
	rm -rf $(BUILD_DIR_PDF)

site-clean:
	rm -f $(MARKDOWN_SITE)
	cd site && bundle exec jekyll clean

