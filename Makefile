
all:
	docker build -t test .
	docker build --build-arg FROM=test:latest -t test:flat - < Dockerfile-flatten

dockerfile-kasm-desktop-noble: dockerfile-kasm-desktop
	sed "s#^FROM .*#FROM docker.io/kasmweb/ubuntu-noble-desktop:develop#" $< > $@
	docker build -t kasmweb--desktop:noble -f $@ .

desktop: dockerfile-kasm-desktop-noble Dockerfile
	docker build -t kasmweb--desktop:noble \
		--build-arg BASE_IMAGE=kasmweb--desktop:noble \
		-f Dockerfile
#
#docker.io/kasmweb/ubuntu-noble-desktop:develop
#kasmweb/desktop:1.15.0-rolling
