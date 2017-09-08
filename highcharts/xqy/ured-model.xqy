xquery version "1.0-ml";

module namespace ured-model = "http://org.billFarber.marklogic/charts/ured";

declare namespace mdr="http://dtic.mil/mdr/record";
declare namespace meta="http://dtic.mil/mdr/record/meta";

declare variable $MAX-DOCUMENTS := 100000;

declare function ured-model:get-funding() {
    ured-model:get-complex-funding-from-docs()
};

declare function ured-model:get-complex-funding-from-tuples() {
    let $_ := xdmp:log("TUPLES")
    let $tuples := ured-model:get-matching-tuples()
let $_ := xdmp:log(("count", fn:count($tuples)))

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

declare function ured-model:get-matching-tuples() {
    cts:value-tuples(
        (
            cts:field-reference("poa"),
            cts:field-reference("pst"),
            cts:field-reference("totaldodfunding")
        ),
        (),
        cts:collection-query("/citation/URED")
    )
};

declare function ured-model:get-complex-funding-from-docs() {
    let $_ := xdmp:log("DOCS")
    let $docs := ured-model:get-matching-documents()
let $_ := xdmp:log(("count", fn:count($docs)))

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
