xquery version "1.0-ml";

import module namespace charts-model = "http://org.billFarber.marklogic/charts"      at "/models/charts-model.xqy";
import module namespace r2-model     = "http://org.billFarber.marklogic/charts/r2"   at "/models/r2-model.xqy";
import module namespace tr-model     = "http://org.billFarber.marklogic/charts/tr"   at "/models/tr-model.xqy";
import module namespace ured-model   = "http://org.billFarber.marklogic/charts/ured" at "/models/ured-model.xqy";

declare namespace mdr="http://dtic.mil/mdr/record";
declare namespace meta="http://dtic.mil/mdr/record/meta";

let $accession-number := xdmp:get-request-field("accessionNumber")
let $_ := xdmp:log(("$accession-number",$accession-number))
let $collection := charts-model:get-collection-from-accession-number($accession-number)
let $_ := xdmp:log(("$collection",$collection))

let $elements := 
        switch ($collection) 
            case "TR"   return tr-model:get-funding-elements($accession-number)
            case "URED" return ured-model:get-funding-elements($accession-number)
            case "R2"   return r2-model:get-funding-elements($accession-number)
            default     return charts-model:empty-elements-list()
let $_ := xdmp:log(("$elements",$elements))

let $_ := xdmp:set-response-content-type('application/json')
return $elements