.PHONY: package test format

INCLUDE=.

test:
	pytest

format:
	mojo format .

package:
	mkdir -p build/
	mojo package geo_features/ -o build/geo_features.mojopkg
