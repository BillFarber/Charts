xquery version "1.0-ml";

declare namespace mdr="http://dtic.mil/mdr/record";
declare namespace meta="http://dtic.mil/mdr/record/meta";

let $docs := fn:collection("/citation/URED")[1 to 10000]

let $state-dod-funding := map:map()
let $_ :=
    for $doc in $docs
    let $state := $doc//meta:State[1]/text()
    let $thisDodFunding := xs:integer($doc//meta:TotalDODFunding[1]/text())
    return
      if (map:get($state-dod-funding, $state)) then
        let $currentTotalDodFunding := map:get($state-dod-funding, $state)[1]
        let $newTotalDodFunding := xs:integer($currentTotalDodFunding) + xs:integer($thisDodFunding)
        return map:put($state-dod-funding, $state, $newTotalDodFunding)
      else 
        map:put($state-dod-funding, $state, $thisDodFunding)

let $states := json:to-array()
let $keys := map:keys($state-dod-funding)
let $_ :=
    for $key in $keys
    let $state := map:map()
    let $_ := map:put($state, 'code', $key)
    let $_ := map:put($state, 'value', map:get($state-dod-funding, $key))
    return json:array-push($states, $state)

let $json-state-dod-funding := xdmp:to-json-string($states)
let $draw-script := fn:concat("drawChart(",$json-state-dod-funding,");")

let $_ := xdmp:set-response-content-type('text/html')
return (
    text{ '<!DOCTYPE html>' },
    <html>
        <title>Highcharts Sample Choropleth</title>
        <head>
            <script src='/highcharts/lib/jquery-3.1.1.min.js'>&nbsp;</script>
            <script src='/highcharts/lib/highmaps.js'>&nbsp;</script>
            <script src='/highcharts/lib/data.js'>&nbsp;</script>
            <script src='/highcharts/lib/us-all.js'>&nbsp;</script>
        </head>
        <body>
            <div id='container' style='height: 600px; min-width: 400px; max-width: 700px; margin: 0 auto'></div>
            <script src='/highcharts/highchartsStateChoropleth.js'>&nbsp;</script>
            <script type="text/javascript">{$draw-script}</script>
        </body>
    </html>
)