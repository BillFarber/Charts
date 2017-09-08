xquery version "1.0-ml";

import module namespace ured-model = "http://org.billFarber.marklogic/charts/ured" at "/highcharts/xqy/ured-model.xqy";

declare namespace mdr="http://dtic.mil/mdr/record";
declare namespace meta="http://dtic.mil/mdr/record/meta";

let $funding := ured-model:get-funding()
let $draw-script := fn:concat("var stateData = ", $funding[1],"; var funding = ", $funding[2], "; var minStateFunding = ", $funding[3], "; var maxStateFunding = ", $funding[4], ";")

let $_ := xdmp:set-response-content-type('text/html')
return (
    text{ '<!DOCTYPE html>' },
    <html>
        <title>Highcharts Sample Choropleth</title>
        <head>
            <script src="//ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js">&nbsp;</script>
            <script src="//ajax.googleapis.com/ajax/libs/jqueryui/1.10.3/jquery-ui.min.js">&nbsp;</script>
            
            <script src="https://code.highcharts.com/highcharts.js">&nbsp;</script>
            <script src="https://code.highcharts.com/maps/modules/map.js">&nbsp;</script>
            <script src='/highcharts/js/us-all.js'>&nbsp;</script>

            <script src='/highcharts/support.js'>&nbsp;</script>
            <script type="text/javascript">{$draw-script}</script>
            <script src='/highcharts/highchartsStateChoropleth.js'>&nbsp;</script>
        </head>
        <body>
            <div id='container' style='height: 600px; min-width: 400px; max-width: 700px; margin: 0 auto'></div>
        </body>
    </html>
)