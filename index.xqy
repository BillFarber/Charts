let $_ := xdmp:set-response-content-type("text/html")
return (
    text{ '<!DOCTYPE html>' },
    <html>
        <body>
            <h1>Hard-coded Samples</h1>
            <ul>
                <li><a href="plainD3/states-funding.xqy">Plain D3 Choropleth</a></li>
                <li><a href="highcharts/highchartsSampleChoropleth.xqy">Highcharts Choropleth</a></li>
                <li><a href="googleCharts/states-funding.xqy">Google Charts States Choropleth</a></li>
                <li><a href="googleCharts/country-funding.xqy">Google Charts Country Choropleth</a></li>
                <br>&nbsp;</br>
                <li><a href="cytoscape/funding.xqy">Funding Link Graph</a></li>
            </ul>
        </body>
    </html>
)