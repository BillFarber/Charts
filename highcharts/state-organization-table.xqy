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

let $uris := ured-model:get-funding-for-state-and-organization($state, $organization, $query-text)
let $_ := xdmp:log(("$uris",$uris))

let $_ := xdmp:set-response-content-type('text/html')
return (
    text{ '<!DOCTYPE html>' },
    <html>
        <title>URED Funding by State/Organization</title>
        <head>
        </head>
        <body>
            <table border="1">
            {
                for $uri in $uris
                let $doc := fn:doc($uri)
                let $an := xs:string($doc/mdr:Record/meta:Metadata/meta:AccessionNumber)
                let $title := xs:string($doc/mdr:Record/meta:Metadata/meta:Title)
                let $link := fn:concat("/cytoscape/funding.xqy?accessionNumber=",$an)
                return <tr><td><a href="{$link}">{$an}</a></td><td>{$title}</td></tr>
            }
            </table>
        </body>
    </html>
)