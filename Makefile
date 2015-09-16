OUTDIR ?= ebin
ERL_SRC := $(wildcard src/*.erl)
APP_SRC = $(wildcard src/*.app.src)
BEAMS = $(foreach erl, $(ERL_SRC), $(shell echo $(erl) | sed 's/\.erl$$/\.beam/'))
APPS = $(foreach app, $(APP_SRC), $(shell echo $(app) | sed 's/\.app.src$$/\.app/'))
VSN = $(shell git describe --tags)

.PHONY: all clean

all: $(BEAMS) $(APPS) $(OUTDIR)

$(OUTDIR):
	mkdir -p $(OUTDIR)

%.beam: $(OUTDIR)
	erlc -o $(OUTDIR) $*.erl

%.app: $(OUTDIR)
	cat $*.app.src | sed 's/\(vsn.*\)git/\1"$(VSN)"/'

clean:
	rm -rf $(OUTDIR)
