let $_ := xdmp:set-response-content-type('text/html')
return (
    text{ '<!DOCTYPE html>' },
    <html>
        <title>Highcharts Sample Choropleth</title>
        <head>
            <script src='lib/jquery-3.1.1.min.js'>A</script>
            <script src='lib/highchartsLib/highmaps.js'>A</script>
            <script src='lib/highchartsLib/data.js'>A</script>
            <script src='lib/highchartsLib/us-all.js'>A</script>
        </head>
        <body>
            <div id='container' style='height: 500px; min-width: 310px; max-width: 600px; margin: 0 auto'></div>
            <script src='highchartsSampleChoropleth.js'>A</script>
        </body>
    </html>
)