xquery version "1.0-ml";

module namespace charts-model = "http://org.billFarber.marklogic/charts";

declare namespace mdr  = "http://dtic.mil/mdr/record";
declare namespace meta = "http://dtic.mil/mdr/record/meta";

declare function charts-model:get-collection-from-accession-number($accession-number) {
    let $uri := cts:uris(
        (),
        (),
        cts:element-value-query(xs:QName("meta:AccessionNumber"), $accession-number)
    )[1]
    let $collection := fn:tokenize($uri, "/")[3]
    return $collection
};

declare function charts-model:empty-elements-list() {
    let $elements := json:to-array()
    return xdmp:to-json-string($elements)
};