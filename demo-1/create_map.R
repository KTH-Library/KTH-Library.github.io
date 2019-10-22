library(leaflet)

markers <- read.csv('geodata.csv')
m <- leaflet()
m <- addTiles(m)

getMyIcon <- function(npubs){
    if (npubs < 100) {markColor <- 'lightgreen'}
    else if (npubs < 1000) {markColor <- 'green'}
    else if (npubs < 50000) {markColor <- 'orange'}
    else {markColor <- 'red'}
    return(awesomeIcons(icon = 'book', iconColor = 'black', library = 'glyphicon', markerColor = markColor))
}

for (j in 1:length(markers$name)) {
    m <- addAwesomeMarkers(m, lng=as.numeric(markers$longitude[j]), lat=as.numeric(markers$latitude[j]), popup=paste(markers$artiklar[j],"publications <br> in",markers$name[j]), icon=getMyIcon(markers$artiklar[j]), options = markerOptions(npubs=markers$artiklar[j]), clusterOptions = markerClusterOptions(maxClusterRadius=120, iconCreateFunction=JS("function (cluster) {
    var markers = cluster.getAllChildMarkers();
    var count = 0;
    for( var i = 0; i<markers.length; i++ ) {
      count = count + markers[i].options.npubs;
    }
    var c = ' marker-cluster-';
    if (count < 1000) {  
      c += 'small';  
    } else if (count < 50000) {  
      c += 'medium';  
    } else { 
      c += 'large';
    }
    return new L.DivIcon({ html: '<div><span>' + count + '</span></div>', className: 'marker-cluster' + c, iconSize: new L.Point(40, 40) });

  }")), clusterId = "cluster1")
}
