let $_ := xdmp:set-response-content-type("text/html")
return (
    text{ '<!DOCTYPE html>' },
    <html>
        <body>
            <h1>Hard-coded Samples</h1>
            <ul>
                <li><a href="highchartsSampleChoropleth.xqy">Highcharts Choropleth</a></li>
                <li><a href="staticGraph.xqy">Cytoscape Network Graph</a></li>
            </ul>
        </body>
    </html>
)