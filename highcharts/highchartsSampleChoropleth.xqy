xquery version "1.0-ml";

import module namespace ured-model = "http://org.billFarber.marklogic/charts/ured" at "/models/ured-model.xqy";

declare namespace mdr="http://dtic.mil/mdr/record";
declare namespace meta="http://dtic.mil/mdr/record/meta";

let $query-text := xdmp:get-request-field("queryText")
let $selected-year := "2017"
let $selected-year := (xdmp:get-request-field("year"), $selected-year)[1]
let $year-options := (2010 to 2017)

let $funding := ured-model:get-funding($query-text, $selected-year)
let $draw-script := fn:concat("var stateData = ", $funding[1],"; var funding = ", $funding[2], "; var minStateFunding = ", $funding[3], "; var maxStateFunding = ", $funding[4], ";", " var selectedYear = ", $selected-year, ";")

let $_ := xdmp:set-response-content-type('text/html')
return (
    text{ '<!DOCTYPE html>' },
    <html>
        <title>Highcharts Sample Choropleth</title>
        <head>
            <script src="//ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js">&nbsp;</script>
            <script src="//ajax.googleapis.com/ajax/libs/jqueryui/1.10.3/jquery-ui.min.js">&nbsp;</script>

<link href="https://ajax.googleapis.com/ajax/libs/jqueryui/1.12.1/themes/base/jquery-ui.css" rel="stylesheet" type="text/css" />
<link href="https://netdna.bootstrapcdn.com/font-awesome/3.2.1/css/font-awesome.css" rel="stylesheet" type="text/css" />

            <script src="/highcharts/highcharts.js">&nbsp;</script>
            <script src="/highcharts/map.js">&nbsp;</script>
            <script src='/highcharts/js/us-all.js'>&nbsp;</script>

            <script src='/highcharts/support.js'>&nbsp;</script>
            <script type="text/javascript">{$draw-script}</script>
        </head>
        <body>
            <script src='/highcharts/highchartsStateChoropleth.js'>&nbsp;</script>
            <div id="queryInput" style="float:left;">
                 <form action="/highcharts/highchartsSampleChoropleth.xqy">
                    {
                        for $year in $year-options
                        return
                            if ($year eq xs:integer($selected-year)) then
                                <div><input type="radio" name="year" value="{$year}" checked="checked" > {$year}</input></div>
                            else
                                <div><input type="radio" name="year" value="{$year}" > {$year}</input></div>
                    }
                    <br></br>
                    Query:<br></br>
                    <input type="text" name="queryText" value="{$query-text}"></input><br></br>
                    <input type="submit" value="Submit"></input>
                </form> 
            </div>
            <div id='container' style='height: 600px; width: 800px; min-width: 400px; max-width: 1000px; margin: 0 auto'>
            </div>
        </body>
    </html>
)