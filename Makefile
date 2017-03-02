
BIN=archsat
MAIN=src/main.native

all: bin

doc:
	cd doc && $(MAKE)

bin:
	$(MAKE) -C src bin
	cp $(MAIN) $(BIN)

lib:
	$(MAKE) -C src lib

test:
	$(MAKE) -C src test

install: bin
	./$(BIN) --help=groff > $(MANDIR)/man1/$(BIN).1
	cp $(BIN) $(BINDIR)/

uninstall:
	rm -f $(MANDIR)/man1/$(BIN).1 $(BINDIR)/$(BIN)

clean:
	cd src && $(MAKE) clean
	rm -f $(BIN)

.PHONY: doc bin install uninstall clean

