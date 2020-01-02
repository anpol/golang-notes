MD_FILES = $(wildcard *.md)
MD_HTML_FILES = $(patsubst %.md,%.html,$(MD_FILES))

RST_FILES = $(wildcard *.rst)
RST_HTML_FILES = $(patsubst %.rst,%.html,$(RST_FILES))

HTML_FILES = ${MD_HTML_FILES} ${RST_HTML_FILES}

all : $(HTML_FILES)

clean :
	rm $(HTML_FILES)

$(MD_HTML_FILES): %.html: %.md Makefile
	pandoc --from markdown+autolink_bare_uris --to html --standalone --css ~/.dotfiles/pandoc/css/github-pandoc.css --toc $< -o $@

$(RST_HTML_FILES): %.html: %.rst Makefile
	rst2html.py $< $@
