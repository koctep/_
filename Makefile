DEST_DIR	?= ebin
SRC_DIR 	?= src
ERLS_SRC 	= $(wildcard $(SRC_DIR)/*.erl)
APPS_SRC 	= $(wildcard $(SRC_DIR)/*.app.src)
MODULES 	= $(basename $(notdir $(ERLS_SRC)))
APPS 			= $(basename $(notdir $(APPS_SRC)))
DEST_BEAMS= $(addsuffix .beam, $(addprefix $(DEST_DIR)/, $(MODULES)))
DEST_APPS = $(addprefix $(DEST_DIR)/, $(APPS))
VSN 			:= $(shell git describe --tags)

.PHONY: all clean

all: $(DEST_BEAMS) $(DEST_APPS)

$(DEST_DIR)/%.beam: $(SRC_DIR)/%.erl $(DEST_DIR)
	erlc -o $(DEST_DIR) $<

$(DEST_DIR)/%.app: $(SRC_DIR)/%.app.src $(DEST_DIR)
	cat $< | sed 's/\(vsn.*\)git/\1"$(VSN)"/' > $@

clean:
	rm -rf $(DEST_DIR)

$(DEST_DIR):
	mkdir -p $(DEST_DIR)
