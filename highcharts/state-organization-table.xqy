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
let $selected-year := "2017"
let $selected-year := (xdmp:get-request-field("year"), $selected-year)[1]

let $uris := ured-model:get-funding-for-state-and-organization($state, $organization, $query-text, $selected-year)
let $_ := xdmp:log(("$uris",$uris))

let $table-title := fn:concat("URED Records for ", $organization, " in ", $state)

let $_ := xdmp:set-response-content-type('text/html')
return (
    text{ '<!DOCTYPE html>' },
    <html>
        <title>URED Funding by State/Organization</title>
        <head>
            <style type="text/css">{'
                tr:nth-child(even) {
                    background-color: #c5c5c5;
                }
                tr:nth-child(odd) {
                    background-color: #e6e6e6;
                }
            '}</style>
        </head>
        <body>
             <div><b><u>{$table-title}</u></b></div>
            <br></br>
            <table>
                <tr><th>Accession Number</th><th>Title</th><th>Creation Date</th><th>Objective</th></tr>
                {
                    for $uri in $uris
                    let $doc := fn:doc($uri)
                    let $an := xs:string($doc/mdr:Record/meta:Metadata/meta:AccessionNumber)
                    let $title := xs:string($doc/mdr:Record/meta:Metadata/meta:Title)
                    let $creation-date := xs:string($doc/mdr:Record/meta:Metadata/meta:CitationCreationDate)
                    let $objective := xs:string($doc/mdr:Record/meta:Metadata/meta:Objective)
                    let $link := fn:concat("/cytoscape/funding.xqy?accessionNumber=",$an)
                    return <tr class='clickable-row' data-href='{$link}'><td><a href="{$link}">{$an}</a></td><td>{$title}</td><td>{$creation-date}</td><td>{$objective}</td></tr>
                }
            </table>
        </body>
    </html>
)