xquery version "1.0-ml";

import module namespace r2-model = "http://org.billFarber.marklogic/charts/r2" at "/models/r2-model.xqy";

declare namespace mdr="http://dtic.mil/mdr/record";
declare namespace meta="http://dtic.mil/mdr/record/meta";

let $program-element := "PE00000"
let $program-element := (xdmp:get-request-field("programElement"), $program-element)[1]
let $funding := r2-model:get-funding-over-time($program-element)
let $data-script := fn:concat("var titleText = '", $funding[1], "'; var firstYear = ", $funding[2], "; var seriesData = ", $funding[3], ";")
let $_ := xdmp:log(("$data-script", $data-script))

let $_ := xdmp:set-response-content-type('text/html')
return (
    text{ '<!DOCTYPE html>' },
    <html>
        <title>Program Element Funding</title>
        <head>
            <script src="//ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js">&nbsp;</script>
            <script src="//ajax.googleapis.com/ajax/libs/jqueryui/1.10.3/jquery-ui.min.js">&nbsp;</script>
            <link href="https://ajax.googleapis.com/ajax/libs/jqueryui/1.12.1/themes/base/jquery-ui.css" rel="stylesheet" type="text/css" />
            <link href="https://netdna.bootstrapcdn.com/font-awesome/3.2.1/css/font-awesome.css" rel="stylesheet" type="text/css" />

            <script src="/highcharts/highcharts.js">&nbsp;</script>
            <script type="text/javascript">{$data-script}</script>
        </head>
        <body>
            <div id="queryInput" style="float:left;">
                 <form action="/highcharts/programElementFunding.xqy">
                    <input type="text" name="programElement" value="{$program-element}"></input><br></br>
                    <input type="submit" value="Submit"></input>
                </form> 
            </div>
            <div id='container' style='height: 600px; width: 800px; min-width: 400px; max-width: 1000px; margin: 0 auto'>
            </div>
            <script src='/highcharts/programElementFunding.js'>&nbsp;</script>
        </body>
    </html>
)