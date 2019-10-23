#! make

biblioflex.html:
	# needs pandoc system lib and tinytex R package
	# tinytex::install_tinytex()
	R -e "rmarkdown::render('biblioflex.Rmd')"

encrypt-report:
	# using docker image gaow/staticrypt for the utility
	# takes the ".html" from the present working directory, use your own file
	# outputs a "-x.html" file that needs unlocking with the given password

	docker run --rm -u $(UID):$(GID) -v "$(PWD):/tmp" -e SECRET=$(SECRET) gaow/staticrypt \
		staticrypt /tmp/biblioflex.html $(SECRET) -o /tmp/index-x.html
	mv index-x.html index.html

clean:
	rm biblioflex.html

