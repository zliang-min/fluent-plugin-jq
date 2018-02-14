SHELL=/bin/bash

# this is supposed to be used as travis build script
.PHONY: test
test:
	@echo printing evns:
	@env
	@echo ---
	@for n in 3 4 5; do \
	   docker run -it --rm -e CI=true --env-file <(env | grep TRAVIS_) -v $$(pwd):/app -w /app ruby:2.$$n-alpine /app/run_ci.sh; \
	   err=$$?; \
	   if [[ $$err -ne 0 ]]; then exit $$err; fi \
	 done
