xquery version "1.0-ml";

module namespace tr-model = "http://org.billFarber.marklogic/charts/tr";

import module namespace ured-model     = "http://org.billFarber.marklogic/charts/ured"   at "/models/ured-model.xqy";

declare namespace mdr  = "http://dtic.mil/mdr/record";
declare namespace meta = "http://dtic.mil/mdr/record/meta";

declare function tr-model:get-funding-elements($accession-number, $divider) {
    tr-model:get-funding-elements-from-tuples($accession-number, $divider)
};

declare function tr-model:get-funding-elements-from-tuples($accession-number, $divider) {
    let $an-links := map:map()
    let $_ := map:put($an-links, "Center_Node", $accession-number)

    let $ct-tuples := tr-model:get-ct-list($accession-number)

    let $pe-array := json:to-array()

    let $ct-array := json:to-array()
    let $_ :=
        for $ct-tuple in $ct-tuples
        let $ct := $ct-tuple[1]
        let $tr-array := tr-model:get-ured-array-from-ct($ct)
        let $ct-links := map:map()
        let $_ := map:put($ct-links, "CT", $ct)
        let $_ := map:put($ct-links, "Links", $tr-array)
        return json:array-push($ct-array, $ct-links)

    let $_ := map:put($an-links, 'PE_Links', $pe-array)
    let $_ := map:put($an-links, 'CT_Links', $ct-array)
    let $elements := tr-model:create-elements-array($an-links, $divider)
    return xdmp:to-json-string($elements)
};

declare function tr-model:get-ured-array-from-ct($ct) {
    let $ured-uris := cts:uris(
        (),
        (),
        cts:and-query((
            cts:collection-query("/citation/URED"),
            cts:field-value-query("ctPunctuated", $ct)
        ))
    )
    let $ured-array := json:to-array()
    let $_ :=
        for $ured-uri in $ured-uris[1 to 10]
        let $ured-accession-number := fn:tokenize(fn:tokenize($ured-uri, "/")[4],"\.")[1]
        return json:array-push($ured-array, $ured-accession-number)
    return $ured-array
};

declare function tr-model:get-ct-list($accession-number) {
    cts:value-tuples(
        (
            cts:field-reference("ctPunctuated")
        ),
        (),
        cts:and-query((
            cts:collection-query("/citation/TR"),
            cts:element-value-query(xs:QName("meta:AccessionNumber"), $accession-number)
        ))
    )
};

declare function tr-model:create-elements-array($an-links, $divider) {
    let $elements := json:to-array()

    let $center-accession-number := map:get($an-links, "Center_Node")
    let $tip-content := tr-model:get-tip-content($center-accession-number)
    let $center-element := tr-model:create-node-element($center-accession-number, 8 div $divider, $center-accession-number, "tr", $tip-content)
    let $_ := json:array-push($elements, $center-element)

    let $pe-obj-list := map:get($an-links, "PE_Links")

    let $ct-obj-list := map:get($an-links, "CT_Links")
    let $_ :=
        for $ct-obj in json:array-values($ct-obj-list)
            let $ct := map:get($ct-obj, "CT")
            let $link-list := map:get($ct-obj, "Links")
            for $link-accession-number in json:array-values($link-list)
                let $tip-content := ured-model:get-tip-content($link-accession-number)
                let $node-element := tr-model:create-node-element($link-accession-number, 4 div $divider, $link-accession-number, "ured", $tip-content)
                let $_ := json:array-push($elements, $node-element)
                let $id := fn:concat($center-accession-number,"to",$link-accession-number)
                let $edge-element := tr-model:create-edge-element($id, $center-accession-number, $ct, $link-accession-number, "ct")
                return json:array-push($elements, $edge-element)

    return $elements
};

declare function tr-model:create-node-element($id, $ring, $label, $classes, $tip-content as xs:string?) {
    let $element-data := map:map()
    let $_ := map:put($element-data, "id", $id)
    let $_ := map:put($element-data, "ring", $ring)
    let $_ := map:put($element-data, "label", $label)
    let $_ := map:put($element-data, "tip", $tip-content)
    let $element := map:map()
    let $_ := map:put($element, "data", $element-data)
    let $_ := map:put($element, "classes", $classes)
    return $element
};

declare function tr-model:create-edge-element($id, $source, $predicate, $target, $classes) {
    let $element-data := map:map()
    let $_ := map:put($element-data, "id", $id)
    let $_ := map:put($element-data, "source", $source)
    let $_ := map:put($element-data, "predicate", $predicate)
    let $_ := map:put($element-data, "target", $target)
    let $element := map:map()
    let $_ := map:put($element, "data", $element-data)
    let $_ := map:put($element, "classes", $classes)
    return $element
};

declare function tr-model:get-tip-content($accession-number) {
    let $uri := fn:concat("/citation/TR/",$accession-number,".xml")
    let $doc := fn:doc($uri)
    let $collection := xs:string($doc/mdr:Record/meta:Metadata/meta:Collections/meta:Collection)[1]
    let $title := xs:string($doc/mdr:Record/meta:Metadata/meta:UnclassifiedTitle)
    let $creation-date := xs:string($doc/mdr:Record/meta:Metadata/meta:CitationCreationDate)
    let $abstract := xs:string($doc/mdr:Record/meta:Metadata/meta:Abstract)
    let $tip := fn:concat('<div>',
        '<b>Collection:</b>',$collection,
        '<br><b>Title:</b>',$title,
        '<br><b>Creation Date:</b>',$creation-date,
        '<br><b>Abstract:</b>',$abstract,
        '</div>'
    )
    return $tip
};
