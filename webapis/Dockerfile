FROM kthb/kontarion:latest

RUN apt update && apt install -y libpoppler-cpp-dev

RUN install2.r --error \
	pdftools \
	magick
