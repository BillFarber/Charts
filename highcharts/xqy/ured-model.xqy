xquery version "1.0-ml";

module namespace ured-model = "http://org.billFarber.marklogic/charts/ured";

declare namespace mdr="http://dtic.mil/mdr/record";
declare namespace meta="http://dtic.mil/mdr/record/meta";

declare variable $MAX-DOCUMENTS := 10000;

declare function ured-model:get-funding() {
    ured-model:get-funding-from-tuples()
};

declare function ured-model:get-funding-from-tuples() {
    let $tuples := ured-model:get-matching-tuples()
let $_ := xdmp:log("tuples")
    let $state-dod-funding := map:map()
    let $_ :=
        for $tuple in $tuples
        let $state := $tuple[1]
        let $thisDodFunding := $tuple[2]
        return
            if (map:get($state-dod-funding, $state)) then
                let $currentTotalDodFunding := map:get($state-dod-funding, $state)[1]
                let $newTotalDodFunding := xs:integer($currentTotalDodFunding) + xs:integer($thisDodFunding)
                return map:put($state-dod-funding, $state, $newTotalDodFunding)
            else
                map:put($state-dod-funding, $state, $thisDodFunding)

    let $states := json:to-array()
    let $keys := map:keys($state-dod-funding)
    let $_ :=
        for $key in $keys
        let $state := map:map()
        let $_ := map:put($state, 'code', $key)
        let $_ := map:put($state, 'value', map:get($state-dod-funding, $key))
        return json:array-push($states, $state)

    let $json-state-dod-funding := xdmp:to-json-string($states)
    return $json-state-dod-funding
};

declare function ured-model:get-matching-tuples() {
    cts:value-tuples(
        (
            cts:element-reference(xs:QName("meta:State")),
            cts:element-reference(xs:QName("meta:TotalDODFunding"))
        ),
        (),
        cts:collection-query("/citation/URED")
    )
};

declare function ured-model:get-funding-from-docs() {
    let $docs := ured-model:get-matching-documents()

    let $state-dod-funding := map:map()
    let $_ :=
        for $doc in $docs
        let $state := $doc//meta:State[1]/text()
        let $thisDodFunding := xs:integer($doc//meta:TotalDODFunding[1]/text())
        return
            if (map:get($state-dod-funding, $state)) then
                let $currentTotalDodFunding := map:get($state-dod-funding, $state)[1]
                let $newTotalDodFunding := xs:integer($currentTotalDodFunding) + xs:integer($thisDodFunding)
                return map:put($state-dod-funding, $state, $newTotalDodFunding)
            else
                map:put($state-dod-funding, $state, $thisDodFunding)

    let $states := json:to-array()
    let $keys := map:keys($state-dod-funding)
    let $_ :=
        for $key in $keys
        let $state := map:map()
        let $_ := map:put($state, 'code', $key)
        let $_ := map:put($state, 'value', map:get($state-dod-funding, $key))
        return json:array-push($states, $state)

    let $json-state-dod-funding := xdmp:to-json-string($states)
    return $json-state-dod-funding
};

declare function ured-model:get-matching-documents() {
    fn:collection("/citation/URED")[1 to $MAX-DOCUMENTS]
};