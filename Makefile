.PHONY: package test format clean install-py-packages

install-py-packages:
	conda env create -p venv --file environment.yml

clean:
	rm -rf ~/.modular/.mojo_cache build/geo_features.mojopkg

test:
	pytest -W error

format:
	mojo format .

package:
	mkdir -p build/
	mojo package geo_features/ -o build/geo_features.mojopkg
