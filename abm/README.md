# Static content for ABM 2018 - KTH

The Makefile contains a target `encrypt-report` which can be used with a secret passphrase like so:

		export SECRET=mysecretpassphrase
		make encrypt-report

Currently "secrets" are not checked in to this repository.

The "flexdashboard" rendered output `biblioflex.html` is the name of the unencrypted dashboard report.

## Background

This shows an example of how static HTML files can be published (with passphrase encryption) through GitHub Pages.

NB: Dependencies are "docker" for running the Makefile target and the content for the reports as .html file(s).

## Workflow

1. Locally, in this repo, add some static content - a file with flexdashboard HTML named "biblioflex.html" in this case.

1. Then run "make encrypt-report" locally.

1. Push the "index.html" file to the repository.

It will then be available at <https://KTH-Library.github.io/abm> since it is the default content served in the directory named "abm".

