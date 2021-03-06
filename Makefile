TEST_DIR = test/common test/unit test/local test/saucelabs test/ghostdriver

DEFAULT:
	@echo
	@echo '  make test -> run the unit, midway, and e2e tests (start selenium with chromedriver first).'
	@echo '  make test_unit -> run the unit tests'
	@echo '  make test_midway -> run the midway tests (start selenium with chromedriver first).'
	@echo '  make test_e2e -> run the e2e tests (start selenium with chromedriver first).'
	@echo '  make test_e2e_sauce -> run the e2e tests on tests (set SAUCE_USERNAME/SAUCE_ACCESS_KEY first).'
	#@echo '  make test_ghostdriver -> run the ghostdriver tests (start ghostdriver first).'
	#@echo '  make test_coverage -> generate test coverage (install jscoverage first).'
	@echo '  mapping -> build the mapping (implemented only).'
	@echo '  full_mapping -> build the mapping (full).'
	@echo '  unsupported_mapping -> build the mapping (unsupported).'
	@echo

test: test_unit test_midway test_e2e

test_unit:
	SAUCE_USERNAME= SAUCE_ACCESS_KEY= ./node_modules/.bin/mocha --bail test/specs/*-specs.js

test_midway:
	BROWSER=chrome ./node_modules/.bin/mocha test/midway/*-specs.js -g '@skip-chrome|@multi' -i
	BROWSER=firefox ./node_modules/.bin/mocha test/midway/*-specs.js -g '@skip-firefox|@multi' -i
	./node_modules/.bin/mocha test/midway/*-specs.js -g '@multi'

test_e2e:
	BROWSER=chrome ./node_modules/.bin/mocha test/e2e/*-specs.js -g '@skip-chrome' -i
	BROWSER=firefox ./node_modules/.bin/mocha test/e2e/*-specs.js -g '@skip-firefox' -i


# run saucelabs test, configure username/key first
test_e2e_sauce:
ifdef TRAVIS
	# secure env variables are not available for pull reuqests
	# so you won't be able to run test against Sauce on these
ifneq ($(TRAVIS_PULL_REQUEST),false)
	@echo 'Skipping Sauce Labs tests as this is a pull request'
else
	SAUCE=1 make test_e2e
endif
else
	JOB_ID=`git rev-parse --short HEAD`  SAUCE=1 make test_e2e
endif

# todo: reconfigure that
# run ghostdriver test, start ghostdriver first
# test_ghostdriver:
# 	./node_modules/.bin/mocha --bail test/ghostdriver/*-test.js

# todo: setup coverage using new tests
# run test coverage, install jscoverage first
# test_coverage:
# 	rm -rf lib-cov
# 	jscoverage --no-highlight lib lib-cov --exclude=bin.js
# 	WD_COV=1 ./node_modules/.bin/mocha --bail --reporter html-cov \
# 	test/unit/*-test.js \
# 	test/local/*-test.js \
# 	test/saucelabs/*-test.js \
#   > coverage.html

_dox:
	@mkdir -p tmp
	@./node_modules/.bin/dox -r < lib/webdriver.js > tmp/webdriver-dox.json
	@./node_modules/.bin/dox -r < lib/element.js > tmp/element-dox.json

# build the mapping (implemented only)
mapping: _dox
	@node doc/mapping-builder.js

# build the mapping (full)
full_mapping: _dox
	@node doc/mapping-builder.js full

# build the mapping (unsupported)
unsupported_mapping: _dox
	@node doc/mapping-builder.js unsupported

.PHONY: \
	test \
	DEFAULT \
	test_unit \
	test_midway \
	test_e2e \
	test_saucelabs \
	test_coverage \
	test_ghostdriver \
	build_mapping \
	build_full_mapping \
	_dox
