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
let $_ := json:array-push($states, ('State', 'Funding'))
let $keys := map:keys($state-dod-funding)
let $_ :=
    for $key in $keys
    return json:array-push($states, (fn:concat($key), map:get($state-dod-funding, $key)))

let $json-state-dod-funding := xdmp:to-json-string($states)
let $data-script := fn:concat("setCallback(",$json-state-dod-funding,");")

let $_ := xdmp:set-response-content-type("text/html")
return (
    "<!DOCTYPE html>",
    <html lang="en">
        <head>
            <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js">A</script>
        </head>
        <body>
            <script type="text/javascript" src="/googleCharts/state-funding.js">A</script>
            <script type="text/javascript">{$data-script}</script>
            <div id="chart_div"></div>
        </body>
    </html>
)