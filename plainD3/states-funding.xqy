xquery version "1.0-ml";

declare namespace mdr="http://dtic.mil/mdr/record";
declare namespace meta="http://dtic.mil/mdr/record/meta";

let $state-dod-funding := json:object()
let $docs := fn:collection("/citation/URED")[1 to 10000]
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
let $_ := xdmp:log($state-dod-funding)

let $json-state-dod-funding := xdmp:to-json-string($state-dod-funding)
(:
# Override for now since we don't have any data.
let $json-state-dod-funding := '{"OH":333879909, "CA":468538417, "AL":196231667, "DC":638867417, "NY":274322660, "VA":253093413, "WA":193118937, "MA":234529253, "MD":253492937, "RI":31140693, "FL":332283767, "PA":220010063, "TX":234320253, "MS":293400485, "NC":41756999, "CT":313433767, "NM":218060063, "NE":2420795, "GA":253093413, "IL":638867417, "CO":288180081, "NJ":313433767, "TN":440310436, "HI":120718301, "AZ":332133767, "IN":217966063, "MI":196624047, "MO":223317066, "MN":471943406, "LA":11434301, "OK":159241367, "UT":229102799, "NH":184926888, "DE":41884499, "GB":41410999, "WI":212804041, "KS":151060134, "NV":245980234, "AR":229271540, "US":355306183, "OR":312949013, "KY":253492937, "IA":166282958, "MT":121299576, "VT":22745273, "AT":108268412, "BR":0, "SC":190844937, "SU":5734912, "JP":17042058, "ES":108755387, "ID":12794036, "MY":25867912, "WV":5420622, "NU":6572515, "AU":106237463, "PH":170000, "ND":118629576, "ME":160202359, "SE":26666503, "HK":102030108, "CZ":22040102, "CN":70630403, "WY":114942771, "AK":137381988, "VN":111005083, "EG":0, "ET":0, "PR":269373038, "TR":268931038, "BE":270342660, "TW":17042058, "RU":11619721, "IT":271470660, "NO":153959903, "GR":187739719, "FR":26666503, "KE":225833373, "FI":31735284, "IE":22912273}'
:)

let $_ := xdmp:log($json-state-dod-funding)

let $_ := xdmp:set-response-content-type("text/html")
return (
    "<!DOCTYPE html>",
    <html lang="en">
        <head>
            <script src="/plainD3/js/d3.v3.min.js">A</script>
        </head>
        <body>
            <script src="/plainD3/js/states-funding.js">A</script>
            <script type="text/javascript">
                drawMap({$json-state-dod-funding});
            </script>
        </body>
    </html>
)