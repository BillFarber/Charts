let $_ := xdmp:set-response-content-type("text/html")
return (
    text{ '<!DOCTYPE html>' },
    <html>
        <body>
            <h1>MDR Sample Visualizations</h1>
            <ul>
                <li><a href="highcharts/highchartsSampleChoropleth.xqy">URED Funding by State</a></li>
                <li><a href="cytoscape/funding.xqy">R2-URED-TR link graph</a></li>
                <li><a href="highcharts/programElementFunding.xqy">Program Element Funding</a></li>
            </ul>
        </body>
    </html>
)