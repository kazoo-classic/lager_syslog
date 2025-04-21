.PHONY: rel stagedevrel deps test

all: deps compile

compile:
	./rebar compile

deps:
	@mkdir -p deps
	@if [ ! -d "deps/lager" ] && [ -d "../lager" ]; then ln -sf ../../lager deps/lager; fi
	@if [ ! -d "deps/syslog" ] && [ -d "../syslog" ]; then ln -sf ../../syslog deps/syslog; fi
	@if [ ! -d "deps/lager" ] || [ ! -d "deps/syslog" ]; then ./rebar get-deps; fi

clean:
	./rebar clean

distclean: clean
	./rebar delete-deps

test:
	./rebar eunit

##
## Doc targets
##
docs:
	./rebar doc

APPS = kernel stdlib sasl erts ssl tools os_mon runtime_tools crypto inets \
	xmerl webtool snmp public_key mnesia eunit syntax_tools compiler
COMBO_PLT = $(HOME)/.riak_combo_dialyzer_plt

check_plt: compile
	dialyzer --check_plt --plt $(COMBO_PLT) --apps $(APPS)

build_plt: compile
	dialyzer --build_plt --output_plt $(COMBO_PLT) --apps $(APPS)

dialyzer: compile
	@echo
	@echo Use "'make check_plt'" to check PLT prior to using this target.
	@echo Use "'make build_plt'" to build PLT prior to using this target.
	@echo
	@sleep 1
	dialyzer -Wno_return --plt $(COMBO_PLT) ebin | \
	    fgrep -v -f ./dialyzer.ignore-warnings

cleanplt:
	@echo 
	@echo "Are you sure?  It takes about 1/2 hour to re-build."
	@echo Deleting $(COMBO_PLT) in 5 seconds.
	@echo 
	sleep 5
	rm $(COMBO_PLT)

