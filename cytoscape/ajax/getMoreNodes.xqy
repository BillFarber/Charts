xquery version "1.0-ml";

import module namespace ured-model = "http://org.billFarber.marklogic/charts/ured" at "/models/ured-model.xqy";

declare namespace mdr="http://dtic.mil/mdr/record";
declare namespace meta="http://dtic.mil/mdr/record/meta";

let $elements := json:to-array()
let $tip-content := "New node tooltip"
let $center-accession-number := "AD000043"
let $link-accession-number := "AB123456"
let $node-element := ured-model:create-node-element($link-accession-number, 16, $link-accession-number, "tr", $tip-content)
let $_ := json:array-push($elements, $node-element)
let $id := fn:concat($center-accession-number,"to",$link-accession-number)
let $edge-element := ured-model:create-edge-element($id, $center-accession-number, "xxxx", $link-accession-number, "ct")
let $_ := json:array-push($elements, $edge-element)

let $_ := xdmp:set-response-content-type('application/json')

return xdmp:to-json-string($elements)