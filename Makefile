.PHONY: clean docker

clean:
	dzil clean
docker:
	docker build . -t redirector
