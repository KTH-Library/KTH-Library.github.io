FROM kthb/kontarion:latest

# system library required by R packages
RUN apt update && apt install -y libpoppler-cpp-dev

RUN install2.r --error \
	pdftools \
	magick
