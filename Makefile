.PHONY: package test format

INCLUDE=.

test:
	pytest -W error

format:
	mojo format .

package:
	mkdir -p build/
	mojo package geo_features/ -o build/geo_features.mojopkg
