.PHONY: package test format

INCLUDE=.

test:
	mojo run -I ${INCLUDE} geo_features/test/main.mojo

format:
	mojo format .

package:
	mkdir -p build/
	mojo package geo_features/ -o build/geo_features.mojopkg
