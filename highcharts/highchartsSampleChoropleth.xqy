xquery version "1.0-ml";

import module namespace ured-model = "http://org.billFarber.marklogic/charts/ured" at "/highcharts/xqy/ured-model.xqy";

declare namespace mdr="http://dtic.mil/mdr/record";
declare namespace meta="http://dtic.mil/mdr/record/meta";

let $json-state-dod-funding := ured-model:get-funding()
let $draw-script := fn:concat("drawChart(",$json-state-dod-funding,");")

let $_ := xdmp:set-response-content-type('text/html')
return (
    text{ '<!DOCTYPE html>' },
    <html>
        <title>Highcharts Sample Choropleth</title>
        <head>
            <script src='/highcharts/js/jquery-3.1.1.min.js'>&nbsp;</script>
            <script src='/highcharts/js/highmaps.js'>&nbsp;</script>
            <script src='/highcharts/js/data.js'>&nbsp;</script>
            <script src='/highcharts/js/us-all.js'>&nbsp;</script>
        </head>
        <body>
            <div id='container' style='height: 600px; min-width: 400px; max-width: 700px; margin: 0 auto'></div>
            <script src='/highcharts/highchartsStateChoropleth.js'>&nbsp;</script>
            <script type="text/javascript">{$draw-script}</script>
        </body>
    </html>
)