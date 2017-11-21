xquery version "1.0-ml";

module namespace r2-model = "http://org.billFarber.marklogic/charts/r2";

import module namespace ured-model   = "http://org.billFarber.marklogic/charts/ured" at "/models/ured-model.xqy";

declare namespace mdr  = "http://dtic.mil/mdr/record";
declare namespace meta = "http://dtic.mil/mdr/record/meta";
declare namespace r2   = "http://www.dtic.mil/comptroller/xml/schema/022009/r2";

declare function r2-model:get-funding-over-time($program-element) {
    let $uris := cts:uris(
        (),
        (),
        cts:and-query((
            cts:collection-query("/citation/R2"),
            cts:element-value-query(xs:QName("r2:ProgramElementNumber"), $program-element),
            cts:element-query(xs:QName("r2:ProgramElementFunding"), cts:and-query(()))
        ))
    )
    let $pe-funding := json:to-array()
    let $year-map := map:map()
    let $_ := map:put($year-map, "base-year", xs:integer(3000))
    let $_ :=
        for $uri in $uris
        let $budget-year := fn:doc($uri)/mdr:Record/r2:R2ExhibitList/r2:R2Exhibit/r2:ProgramElement/r2:BudgetYear/text()
        let $new-base-year := fn:min((map:get($year-map, "base-year"), xs:integer($budget-year)))
        return map:put($year-map, "base-year", $new-base-year)
    let $base-year := map:get($year-map, "base-year")

    let $_ :=
        for $uri in $uris
        let $doc := fn:doc($uri)
        let $accession-number := $doc/mdr:Record/meta:Metadata/meta:AccessionNumber/text()
        let $budget-year := xs:integer($doc/mdr:Record/r2:R2ExhibitList/r2:R2Exhibit/r2:ProgramElement/r2:BudgetYear/text())
        let $series-name := fn:concat($accession-number, "(", $budget-year, ")")
        let $this-r2 := map:map()
        let $_ := map:put($this-r2, "name", $series-name)
        let $funding := json:to-array()
        let $current-year-funding := xs:float($doc/mdr:Record//r2:ProgramElementFunding/r2:CurrentYear/text())
        let $year-one-funding := xs:float($doc/mdr:Record//r2:ProgramElementFunding/r2:BudgetYearOne/text())
        let $year-two-funding := xs:float($doc/mdr:Record//r2:ProgramElementFunding/r2:BudgetYearTwo/text())
        let $year-three-funding := xs:float($doc/mdr:Record//r2:ProgramElementFunding/r2:BudgetYearThree/text())
        let $year-four-funding := xs:float($doc/mdr:Record//r2:ProgramElementFunding/r2:BudgetYearFour/text())
        let $year-five-funding := xs:float($doc/mdr:Record//r2:ProgramElementFunding/r2:BudgetYearFive/text())
        let $_ :=
            for $i in ($base-year to ($budget-year - 1))
            return json:array-push($funding, "")
        let $_ := json:array-push($funding, $current-year-funding)
        let $_ := json:array-push($funding, $year-one-funding)
        let $_ := json:array-push($funding, $year-two-funding)
        let $_ := json:array-push($funding, $year-three-funding)
        let $_ := json:array-push($funding, $year-four-funding)
        let $_ := json:array-push($funding, $year-five-funding)
        let $_ := map:put($this-r2, "data", $funding)
        order by $budget-year ascending
        return json:array-push($pe-funding, $this-r2)
    let $pe-funding-string := xdmp:to-json-string($pe-funding)

    let $_ := xdmp:log(("$pe-funding-string", $pe-funding-string))
    return (
        fn:concat($program-element, " funding"),
        $base-year,
        $pe-funding-string
    )
};

(:
        "[
            {
                name: 'Installation',
                data: [43934, 52503, 57177, 69658, 97031, 119931, 137133, 154175]
            }, {
                name: 'Manufacturing',
                data: [24916, 24064, 29742, 29851, 32490, 30282, 38121, 40434]
            }
        ]"
:)

declare function r2-model:get-funding-elements($accession-number, $divider) {
    r2-model:get-funding-elements-from-tuples($accession-number, $divider)
};

declare function r2-model:get-funding-elements-from-tuples($accession-number, $divider) {
    let $an-links := map:map()
    let $_ := map:put($an-links, "Center_Node", $accession-number)

    let $pe-tuples := r2-model:get-pe-list($accession-number)

    let $pe-array := json:to-array()
    let $_ :=
        for $pe-tuple in $pe-tuples
        let $pe := $pe-tuple[1]
        let $r2-array := r2-model:get-ured-array-from-pe($pe)
        let $pe-links := map:map()
        let $_ := map:put($pe-links, "PE", $pe)
        let $_ := map:put($pe-links, "Links", $r2-array)
        return json:array-push($pe-array, $pe-links)

    let $ct-array := json:to-array()

    let $_ := map:put($an-links, 'PE_Links', $pe-array)
    let $_ := map:put($an-links, 'CT_Links', $ct-array)
    let $elements := r2-model:create-elements-array($an-links, $divider)
    return xdmp:to-json-string($elements)
};

declare function r2-model:get-ured-array-from-pe($pe) {
    let $ured-uris := cts:uris(
        (),
        (),
        cts:and-query((
            cts:collection-query("/citation/URED"),
            cts:element-value-query(xs:QName("meta:ProgramElement"), $pe)
        ))
    )
    let $r-array := json:to-array()
    let $_ :=
        for $ured-uri in $ured-uris[1 to 10]
        let $ured-accession-number := fn:tokenize(fn:tokenize($ured-uri, "/")[4],"\.")[1]
        return json:array-push($r-array, $ured-accession-number)
    return $r-array
};

declare function r2-model:get-pe-list($accession-number) {
    cts:value-tuples(
        (
            cts:field-reference("pe")
        ),
        (),
        cts:and-query((
            cts:collection-query("/citation/R2"),
            cts:element-value-query(xs:QName("meta:AccessionNumber"), $accession-number)
        ))
    )
};

declare function r2-model:create-elements-array($an-links, $divider) {
    let $elements := json:to-array()

    let $center-accession-number := map:get($an-links, "Center_Node")
    let $tip-content := r2-model:get-tip-content($center-accession-number)
    let $center-element := r2-model:create-node-element($center-accession-number, 8 div $divider, $center-accession-number, "r2", $tip-content)
    let $_ := json:array-push($elements, $center-element)

    let $pe-obj-list := map:get($an-links, "PE_Links")
    let $_ :=
        for $pe-obj in json:array-values($pe-obj-list)
            let $pe := map:get($pe-obj, "PE")
            let $link-list := map:get($pe-obj, "Links")
            for $link-accession-number in json:array-values($link-list)
                let $tip-content := ured-model:get-tip-content($link-accession-number)
                let $node-element := r2-model:create-node-element($link-accession-number, 4 div $divider, $link-accession-number, "ured", $tip-content)
                let $_ := json:array-push($elements, $node-element)
                let $id := fn:concat($center-accession-number,"to",$link-accession-number)
                let $edge-element := r2-model:create-edge-element($id, $center-accession-number, $pe, $link-accession-number, "pe")
                return json:array-push($elements, $edge-element)

    return $elements
};

declare function r2-model:create-node-element($id, $ring, $label, $classes, $tip-content as xs:string?) {
    let $element-data := map:map()
    let $_ := map:put($element-data, "id", $id)
    let $_ := map:put($element-data, "ring", $ring)
    let $_ := map:put($element-data, "label", $label)
    let $_ := map:put($element-data, "tip", $tip-content)
    let $_ := map:put($element-data, "pe", fn:tokenize($id, "_")[1])
    let $element := map:map()
    let $_ := map:put($element, "data", $element-data)
    let $_ := map:put($element, "classes", $classes)
    return $element
};

declare function r2-model:create-edge-element($id, $source, $predicate, $target, $classes) {
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

declare function r2-model:get-tip-content($accession-number) {
    let $uri := fn:concat("/citation/R2/",$accession-number,".xml")
    let $doc := fn:doc($uri)
    let $collection := xs:string($doc/mdr:Record/meta:Metadata/meta:Collections/meta:Collection)[1]
    let $creation-date := xs:string($doc/mdr:Record/meta:Metadata/meta:CitationCreationDate)
    let $title := xs:string($doc/mdr:Record//r2:ProgramElement/r2:ProgramElementTitle)[1]
    let $budget-year := xs:string($doc/mdr:Record//r2:ProgramElement/r2:BudgetYear)[1]
    let $tip := fn:concat('<div>',
        '<b>Collection:</b>',$collection,
        '<br><b>Creation Date:</b>',$creation-date,
        '<br><b>Title:</b>',$title,
        '<br><b>Budget Year:</b>',$budget-year,
        '</div>'
    )
    return $tip
};
