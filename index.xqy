let $_ := xdmp:set-response-content-type("text/html")
return (
    text{ '<!DOCTYPE html>' },
    <html>
        <body>
            <h1>Hard-coded Samples</h1>
            <ul>
                <li><a href="plainD3/states-funding.xqy">Plain D3 Choropleth</a></li>
                <li><a href="highchartsSampleChoropleth.xqy">Highcharts Choropleth</a></li>
                <br>&nbsp;</br>
                <li><a href="staticGraph.xqy">Cytoscape Network Graph</a></li>
            </ul>
        </body>
    </html>
)