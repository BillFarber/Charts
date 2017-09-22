xquery version "1.0-ml";

import module namespace ured-model = "http://org.billFarber.marklogic/charts/ured" at "/models/ured-model.xqy";

declare namespace mdr="http://dtic.mil/mdr/record";
declare namespace meta="http://dtic.mil/mdr/record/meta";

let $state := xdmp:get-request-field("state")
let $organization := xdmp:get-request-field("organization")
let $query-text := xdmp:get-request-field("queryText")
let $_ := xdmp:log(("$state",$state))
let $_ := xdmp:log(("$organization",$organization))
let $_ := xdmp:log(("$query-text",$query-text))

let $ured-uris := ured-model:get-funding-for-state-and-organization($state, $organization, $query-text)
let $_ := xdmp:log(("$ured-uris",$ured-uris))

let $_ := xdmp:set-response-content-type('text/html')
return (
    text{ '<!DOCTYPE html>' },
    <html>
        <title>URED Funding by State/Organization</title>
        <head>
        </head>
        <body>
            <table>
                <tr><td>A0</td><td>A1</td></tr>
                <tr><td>B0</td><td>B1</td></tr>
                <tr><td>C0</td><td>C1</td></tr>
            </table>
        </body>
    </html>
)