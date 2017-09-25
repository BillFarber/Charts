xquery version "1.0-ml";

module namespace ured-model = "http://org.billFarber.marklogic/charts/ured";

import module namespace r2-model     = "http://org.billFarber.marklogic/charts/r2"   at "/models/r2-model.xqy";
import module namespace tr-model     = "http://org.billFarber.marklogic/charts/tr"   at "/models/tr-model.xqy";

declare namespace mdr  = "http://dtic.mil/mdr/record";
declare namespace meta = "http://dtic.mil/mdr/record/meta";
declare namespace r2   = "http://www.dtic.mil/comptroller/xml/schema/022009/r2";

declare variable $MAX-DOCUMENTS := 100000;

declare function ured-model:get-funding-elements($ured-accession-number, $divider) {
    ured-model:get-funding-elements-from-tuples($ured-accession-number, $divider)
};

declare function ured-model:get-funding-elements-from-tuples($ured-accession-number, $divider) {
    let $an-links := map:map()
    let $_ := map:put($an-links, "Center_Node", $ured-accession-number)

    let $pe-tuples := ured-model:get-pe-list($ured-accession-number)
    let $ct-tuples := ured-model:get-ct-list($ured-accession-number)

    let $pe-array := json:to-array()
    let $_ :=
        for $pe-tuple in $pe-tuples
        let $pe := $pe-tuple[1]
        let $r2-array := ured-model:get-r2-array-from-pe($pe)
        let $pe-links := map:map()
        let $_ := map:put($pe-links, "PE", $pe)
        let $_ := map:put($pe-links, "Links", $r2-array)
        return json:array-push($pe-array, $pe-links)

    let $ct-array := json:to-array()
    let $_ :=
        for $ct-tuple in $ct-tuples
        let $ct := $ct-tuple[1]
        let $tr-array := ured-model:get-tr-array-from-ct($ct)
        let $ct-links := map:map()
        let $_ := map:put($ct-links, "CT", $ct)
        let $_ := map:put($ct-links, "Links", $tr-array)
        return json:array-push($ct-array, $ct-links)

    let $_ := map:put($an-links, 'PE_Links', $pe-array)
    let $_ := map:put($an-links, 'CT_Links', $ct-array)
    let $elements := ured-model:create-elements-array($an-links, $divider)
    return xdmp:to-json-string($elements)
};

declare function ured-model:get-r2-array-from-pe($pe) {
    let $r2-uris := cts:uris(
        (),
        (),
        cts:and-query((
            cts:collection-query("/citation/R2"),
            cts:element-value-query(xs:QName("r2:ProgramElementNumber"), $pe)
        ))
    )
    let $r-array := json:to-array()
    let $_ :=
        for $r2-uri in $r2-uris[1 to 10]
        let $r2-accession-number := fn:tokenize(fn:tokenize($r2-uri, "/")[4],"\.")[1]
        return json:array-push($r-array, $r2-accession-number)
    return $r-array
};

declare function ured-model:get-tr-array-from-ct($ct) {
    let $tr-uris := cts:uris(
        (),
        (),
        cts:and-query((
            cts:collection-query("/citation/TR"),
            cts:field-value-query("ctPunctuated", $ct)
        ))
    )
    let $tr-array := json:to-array()
    let $_ :=
        for $tr-uri in $tr-uris[1 to 10]
        let $tr-accession-number := fn:tokenize(fn:tokenize($tr-uri, "/")[4],"\.")[1]
        return json:array-push($tr-array, $tr-accession-number)
    return $tr-array
};

declare function ured-model:get-pe-list($ured-accession-number) {
    cts:value-tuples(
        (
            cts:field-reference("pe")
        ),
        (),
        cts:and-query((
            cts:collection-query("/citation/URED"),
            cts:element-value-query(xs:QName("meta:AccessionNumber"), $ured-accession-number)
        ))
    )
};

declare function ured-model:get-ct-list($ured-accession-number) {
    cts:value-tuples(
        (
            cts:field-reference("ctPunctuated")
        ),
        (),
        cts:and-query((
            cts:collection-query("/citation/URED"),
            cts:element-value-query(xs:QName("meta:AccessionNumber"), $ured-accession-number)
        ))
    )
};

declare function ured-model:create-elements-array($an-links, $divider) {
    let $elements := json:to-array()

    let $center-accession-number := map:get($an-links, "Center_Node")
    let $tip-content := ured-model:get-tip-content($center-accession-number)
    let $center-element := ured-model:create-node-element($center-accession-number, 8 div $divider, $center-accession-number, "ured", $tip-content)
    let $_ := json:array-push($elements, $center-element)

    let $pe-obj-list := map:get($an-links, "PE_Links")
    let $_ :=
        for $pe-obj in json:array-values($pe-obj-list)
            let $pe := map:get($pe-obj, "PE")
            let $link-list := map:get($pe-obj, "Links")
            for $link-accession-number in json:array-values($link-list)
                let $tip-content := r2-model:get-tip-content($link-accession-number)
                let $node-element := ured-model:create-node-element($link-accession-number, 4 div $divider, $link-accession-number, "r2", $tip-content)
                let $_ := json:array-push($elements, $node-element)
                let $id := fn:concat($center-accession-number,"to",$link-accession-number)
                let $edge-element := ured-model:create-edge-element($id, $center-accession-number, $pe, $link-accession-number, "pe")
                return json:array-push($elements, $edge-element)

    let $ct-obj-list := map:get($an-links, "CT_Links")
    let $_ :=
        for $ct-obj in json:array-values($ct-obj-list)
            let $ct := map:get($ct-obj, "CT")
            let $link-list := map:get($ct-obj, "Links")
            for $link-accession-number in json:array-values($link-list)
                let $tip-content := tr-model:get-tip-content($link-accession-number)
                let $node-element := ured-model:create-node-element($link-accession-number, 4 div $divider, $link-accession-number, "tr", $tip-content)
                let $_ := json:array-push($elements, $node-element)
                let $id := fn:concat($center-accession-number,"to",$link-accession-number)
                let $edge-element := ured-model:create-edge-element($id, $center-accession-number, $ct, $link-accession-number, "ct")
                return json:array-push($elements, $edge-element)

    return $elements
};

declare function ured-model:create-node-element($id, $ring, $label, $classes, $tip-content as xs:string?) {
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

declare function ured-model:create-edge-element($id, $source, $predicate, $target, $classes) {
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

declare function ured-model:get-tip-content($ured-accession-number) {
    let $uri := fn:concat("/citation/URED/",$ured-accession-number,".xml")
    let $doc := fn:doc($uri)
    let $collection := xs:string($doc/mdr:Record/meta:Metadata/meta:Collections/meta:Collection)[1]
    let $title := xs:string($doc/mdr:Record/meta:Metadata/meta:Title)
    let $creation-date := xs:string($doc/mdr:Record/meta:Metadata/meta:CitationCreationDate)
    let $objective := xs:string($doc/mdr:Record/meta:Metadata/meta:Objective)
    let $tip := fn:concat('<div>',
        '<b>Collection:</b>',$collection,
        '<br><b>Title:</b>',$title,
        '<br><b>Creation Date:</b>',$creation-date,
        '<br><b>Objective:</b>',$objective,
        '</div>'
    )
    return $tip
};







declare function ured-model:get-funding-for-state-and-organization($state-code, $performingOrganization, $query-text) {
    ured-model:get-state-and-organization-funding-from-tuples($state-code, $performingOrganization, $query-text)
};

declare function ured-model:get-state-and-organization-funding-from-tuples($state-code, $performingOrganization, $query-text) {
    let $word-query :=
        if ($query-text) then
            cts:word-query($query-text)
        else ()
    return
        cts:uris(
            (),
            (),
            cts:and-query((
                cts:collection-query("/citation/URED"),
                cts:field-value-query("pst", $state-code),
                cts:field-value-query("poa", $performingOrganization),
                $word-query
            ))
        )
};







declare function ured-model:get-funding($query-text) {
    ured-model:get-complex-funding-from-tuples($query-text)
};

declare function ured-model:get-complex-funding-from-tuples($query-text) {
    let $tuples := ured-model:get-matching-tuples($query-text)

    let $state-funding-by-organization := map:map()
    let $_ :=
        for $tuple in $tuples
        let $performingOrganization := $tuple[1]
        let $state-code := $tuple[2]
        let $thisDodFunding := $tuple[3]
        return ured-model:group-state-funding-by-organization(
                    $state-funding-by-organization, $performingOrganization, $state-code, $thisDodFunding)

    let $state-totals := json:to-array()
    let $keys := map:keys($state-funding-by-organization)
    let $min-state-dod-funding := 99999999999999999
    let $max-state-dod-funding := 0
    let $_ :=
        for $key in $keys
        let $state-total-map := map:map()
        let $_ := map:put($state-total-map, 'code', $key)
        let $stateMap := map:get($state-funding-by-organization, $key)
        let $stateTotal := map:get($stateMap, "TOTAL")
        let $_ :=
            if ($stateTotal < $max-state-dod-funding) then
                xdmp:set($min-state-dod-funding, $stateTotal)
            else ()
        let $_ :=
            if ($stateTotal > $max-state-dod-funding) then
                xdmp:set($max-state-dod-funding, $stateTotal)
            else ()
        let $_ := map:put($state-total-map, 'value', $stateTotal)
        return json:array-push($state-totals, $state-total-map)

    let $json-state-dod-funding := xdmp:to-json-string($state-totals)
    return ($json-state-dod-funding, $state-funding-by-organization, $min-state-dod-funding, $max-state-dod-funding)
};

declare function ured-model:group-state-funding-by-organization($state-funding-by-organization, $performingOrganization, $state-code, $thisDodFunding) {
    if (exists(map:get($state-funding-by-organization, $state-code))) then
        let $stateMap := map:get($state-funding-by-organization, $state-code)
        let $currentStateTotal := map:get($stateMap, "TOTAL")
        let $newStateTotal := xs:integer($currentStateTotal) + xs:integer($thisDodFunding)
        let $_ := map:put($stateMap, "TOTAL", $newStateTotal)
        return
            if (map:get($stateMap, $performingOrganization)) then
                let $currentTotalDodFunding := map:get($stateMap, $performingOrganization)[1]
                let $newTotalDodFunding := xs:integer($currentTotalDodFunding) + xs:integer($thisDodFunding)
                return map:put($stateMap, $performingOrganization, $newTotalDodFunding)
            else
                map:put($stateMap, $performingOrganization, $thisDodFunding)
        else
            let $stateMap := map:map()
            let $_ := map:put($stateMap, $performingOrganization, $thisDodFunding)
            let $_ := map:put($stateMap, "TOTAL", $thisDodFunding)
            return map:put($state-funding-by-organization, $state-code, $stateMap)
};

declare function ured-model:get-matching-tuples($query-text) {
    let $word-query :=
        if ($query-text) then
            cts:word-query($query-text)
        else ()
    return
        cts:value-tuples(
            (
                cts:field-reference("poa"),
                cts:field-reference("pst"),
                cts:field-reference("totaldodfunding"),
                cts:field-reference("pe")
            ),
            (),
            cts:and-query((
                cts:collection-query("/citation/URED"),
                $word-query
            ))
        )
};

declare function ured-model:get-complex-funding-from-docs() {
    let $docs := ured-model:get-matching-documents()

    let $state-funding-by-organization := map:map()
    let $_ :=
        for $doc in $docs
        let $performingOrganization := $doc//meta:PerformingOrganization[1]/meta:CageCodeOrganization/meta:CompanyName/text()
        let $state-code := $doc//meta:State[1]/text()
        let $thisDodFunding := xs:integer($doc//meta:TotalDODFunding[1]/text())
        return ured-model:group-state-funding-by-organization(
                    $state-funding-by-organization, $performingOrganization, $state-code, $thisDodFunding)

    let $state-totals := json:to-array()
    let $keys := map:keys($state-funding-by-organization)
    let $min-state-dod-funding := 99999999999999999
    let $max-state-dod-funding := 0
    let $_ :=
        for $key in $keys
        let $state-total-map := map:map()
        let $_ := map:put($state-total-map, 'code', $key)
        let $stateMap := map:get($state-funding-by-organization, $key)
        let $stateTotal := map:get($stateMap, "TOTAL")
        let $_ :=
            if ($stateTotal < $max-state-dod-funding) then
                xdmp:set($min-state-dod-funding, $stateTotal)
            else ()
        let $_ :=
            if ($stateTotal > $max-state-dod-funding) then
                xdmp:set($max-state-dod-funding, $stateTotal)
            else ()
        let $_ := map:put($state-total-map, 'value', $stateTotal)
        return json:array-push($state-totals, $state-total-map)

    let $json-state-dod-funding := xdmp:to-json-string($state-totals)
    return ($json-state-dod-funding, $state-funding-by-organization, $min-state-dod-funding, $max-state-dod-funding)
};

declare function ured-model:get-matching-documents() {
    fn:collection("/citation/URED")[1 to $MAX-DOCUMENTS]
};
