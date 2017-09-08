xquery version "1.0-ml";

module namespace ured-model = "http://org.billFarber.marklogic/charts/ured";

declare namespace mdr="http://dtic.mil/mdr/record";
declare namespace meta="http://dtic.mil/mdr/record/meta";

declare variable $MAX-DOCUMENTS := 10000;

declare function ured-model:get-funding() {
    ured-model:get-complex-funding-from-tuples()
};

declare function ured-model:get-complex-funding-from-tuples() {
    let $tuples := ured-model:get-matching-tuples()

    let $state-dod-funding := map:map()
    let $_ :=
        for $tuple in $tuples
        let $performingOrganization := $tuple[1]
        let $state := $tuple[2]
        let $thisDodFunding := $tuple[3]

        return
            if (exists(map:get($state-dod-funding, $state))) then
                let $stateMap := map:get($state-dod-funding, $state)
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
                return map:put($state-dod-funding, $state, $stateMap)

    let $states := json:to-array()
    let $keys := map:keys($state-dod-funding)
    let $min-state-dod-funding := 99999999999999999
    let $max-state-dod-funding := 0
    let $_ :=
        for $key in $keys
        let $state := map:map()
        let $_ := map:put($state, 'code', $key)
        let $stateMap := map:get($state-dod-funding, $key)
        let $stateTotal := map:get($stateMap, "TOTAL")
        let $_ :=
            if ($stateTotal < $max-state-dod-funding) then
                xdmp:set($min-state-dod-funding, $stateTotal)
            else ()
        let $_ :=
            if ($stateTotal > $max-state-dod-funding) then
                xdmp:set($max-state-dod-funding, $stateTotal)
            else ()
        let $_ := map:put($state, 'value', $stateTotal)
        return json:array-push($states, $state)

    let $json-state-dod-funding := xdmp:to-json-string($states)
    return ($json-state-dod-funding, $state-dod-funding, $min-state-dod-funding, $max-state-dod-funding)
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
    let $docs := ured-model:get-matching-documents()

    let $state-dod-funding := map:map()
    let $_ :=
        for $doc in $docs
        let $state := $doc//meta:State[1]/text()
        let $thisDodFunding := xs:integer($doc//meta:TotalDODFunding[1]/text())
        let $performingOrganization := $doc//meta:PerformingOrganization[1]/meta:CageCodeOrganization/meta:CompanyName/text()

        return
            if (exists(map:get($state-dod-funding, $state))) then
                let $stateMap := map:get($state-dod-funding, $state)
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
                return map:put($state-dod-funding, $state, $stateMap)

    let $states := json:to-array()
    let $keys := map:keys($state-dod-funding)
    let $min-state-dod-funding := 99999999999999999
    let $max-state-dod-funding := 0
    let $_ :=
        for $key in $keys
        let $state := map:map()
        let $_ := map:put($state, 'code', $key)
        let $stateMap := map:get($state-dod-funding, $key)
        let $stateTotal := map:get($stateMap, "TOTAL")
        let $_ :=
            if ($stateTotal < $max-state-dod-funding) then
                xdmp:set($min-state-dod-funding, $stateTotal)
            else ()
        let $_ :=
            if ($stateTotal > $max-state-dod-funding) then
                xdmp:set($max-state-dod-funding, $stateTotal)
            else ()
        let $_ := map:put($state, 'value', $stateTotal)
        return json:array-push($states, $state)

    let $json-state-dod-funding := xdmp:to-json-string($states)
    return ($json-state-dod-funding, $state-dod-funding, $min-state-dod-funding, $max-state-dod-funding)
};

declare function ured-model:get-matching-documents() {
    fn:collection("/citation/URED")[1 to $MAX-DOCUMENTS]
};
