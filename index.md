## Welcome to the GitHub Pages for the KTH Library - Bibliometrics

These GitHub pages contain POCs, presentations and other documentation related primarily to the DAUF project.

Note that [several other public repositories from KTH](https://github.com/search?q=KTH) are available, for example:

- [https://github.com/KTH](https://github.com/KTH)
- [https://github.com/KTH-biblioteket](https://github.com/KTH-biblioteket)

### DAUF-project

DAUF is an acronym for "Datadriven Analys och Uppföljning av KTHs Forskning".

Several services and activities are delivered through this project.  
For example:

- Public app for Annual Bibliometric Monitoring: [Annual Bibliometric Monitoring Dashboard - KTH 2021](https://kth.se/abm/public)

System requirements: 

- Latest stable version of most popular web browsers; Firefox, Chrome/Chromium, MS Edge v 80 or later
- Microsoft IE and earlier versions of MS Edge (< 80) are not supported, please use an alternative above

### Public project documentation

Presentations / Demos:

- [Annual Bibliometric Monitoring Dashboard - KTH 2018](/abm/) *
- [Presentation web slides](/slides/) *
- [Web slides - Demo 1 - 2019-10-22](/demo-1/)
- [Web slides - Demo 2 - 2019-12-05](/demo-2/)
- [Web slides - Demo 3 - 2020-03-24](/demo-3/)
- [Web slides - Demo 4 - 2020-05-26](/demo-4/)
- [Web slides - Demo 5 - 2020-11-10](/demo-5/)
- [Web slides - Demo 6 - 2021-03-15](/demo-6/)
- [Web slides - Demo 7 - 2021-10-12](/demo-7/)
- [Web slides - Demo 8 - 2022-04-05 - DAUF-project and KTH Publication Analysis app](/demo-8/)  
- [Web slides - Demo - Centre leaders - 2022-10-26](/demo-centres/)  

__NB.__ Some presentations are outdated but are kept on record here.

### Technical documentation

Confluence documentation:

- [System configuration described in KTH's Confluence](https://confluence.sys.kth.se/confluence/pages/viewpage.action?pageId=70784672)

Slides providing overviews:

- [Overview slides for Operations and maintenance](/operations/)
- [Documentation for performance optimization practices and tools](/performance/)
- [Documentation for development workflow for ABM - using GitHub Flow](/workflow/)
- [Documentation for styling in ABM](/styling/)

Technical documentation for the components used in ABM:

- [Documentation for `kontarion-bundle`](https://gita.sys.kth.se/kthb/kontarion-bundle) - how to operate and use the full application bundle (**Note** that this is behind login in KTHs local git instance 'Gita')
- [Documentation for `kontarion` source code at GitHub](https://github.com/KTH-Library/kontarion) - how to operate and use the image bundling the ABM application and its dependencies
- [Documentation for `kontarion` binaries at Docker Hub](https://hub.docker.com/r/kthb/kontarion)
- [Documentation for `bibliomatrix` R package at GitHub](https://github.com/KTH-Library/bibliomatrix) - how to operate and develop the R package that contains the ABM application, REST API and embedded public data
- [Documentation for `ktheme` R package at GitHub](https://github.com/KTH-Library/ktheme) - how to use KTH's graphical profile assets from R (for plotting or generating web content with the KTH style)
- [Documentation for ABM load testing tools](https://gita.sys.kth.se/kthb/kontarion-bundle/tree/master/shinyload) - how to load test the ABM components
- [Documentation for `kthapi` R package at GitHub](https://github.com/KTH-Library/kthapi) - data access from KTH APIs using R (Profiles, Directory)
- [Documentation for `kthcorpus` R package at GitHub](https://github.com/KTH-Library/kthcorpus) - data curation tools for the KTH publication corpus (Publications, Authors)
- [Documentation for `bibliotools` R package at GitHub](https://github.com/KTH-Library/bibliotools) - various authenticated apps, APIs and tools, including the KTH Publication Analysis app (hosted in a private repo)

Build logs:

- [Build logs for `bibliomatrix`](https://github.com/KTH-Library/bibliomatrix/actions/workflows/R-CMD-check.yaml)
- [Build logs for `kontarion`](https://github.com/KTH-Library/kontarion/actions/workflows/push-kontarion.yml)
