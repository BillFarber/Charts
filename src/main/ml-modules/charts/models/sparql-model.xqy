xquery version "1.0-ml";

module namespace sparql-model = "http://org.billFarber.marklogic/sparql";

import module namespace sem          = "http://marklogic.com/semantics"              at "/MarkLogic/semantics.xqy";

import module namespace charts-model = "http://org.billFarber.marklogic/charts"      at "/models/charts-model.xqy";
import module namespace r2-model     = "http://org.billFarber.marklogic/charts/r2"   at "/models/r2-model.xqy";
import module namespace tr-model     = "http://org.billFarber.marklogic/charts/tr"   at "/models/tr-model.xqy";
import module namespace ured-model   = "http://org.billFarber.marklogic/charts/ured" at "/models/ured-model.xqy";

declare namespace sparql-results = "http://www.w3.org/2005/sparql-results#";

declare function sparql-model:get-funding-elements-from-triples($accession-number, $divider) {
    let $uri := charts-model:get-uri-from-accession-number($accession-number)
    let $collection := charts-model:get-collection-from-uri($uri)
    return
        if ($collection eq "R2") then
            sparql-model:get-funding-elements-from-r2-triples($accession-number, $uri, $divider)
        else
            if ($collection eq "URED") then
                sparql-model:get-funding-elements-from-ured-triples($accession-number, $uri, $divider)
            else
                sparql-model:get-funding-elements-from-tr-triples($accession-number, $uri, $divider)
};

declare function sparql-model:get-funding-elements-from-tr-triples($accession-number, $uri, $divider) {

    let $an-links := map:map()
    let $_ := map:put($an-links, "Center_Node", $accession-number)

    let $triples := sparql-model:get-funding-tr-triples($accession-number)
    let $_ := xdmp:log(("$triples", $triples))
    let $xmlTriples := sem:query-results-serialize($triples)

    let $pe-array := json:to-array()
    let $ct-array := json:to-array()

    let $_ :=
        for $result in $xmlTriples/sparql-results:results/sparql-results:result
        let $ured-uri := $result/sparql-results:binding[@name="uredURI"]/sparql-results:literal/text()
        let $ured-accession-number := fn:tokenize(fn:tokenize($ured-uri, "/")[4],"\.")[1]
        let $ured-array := json:to-array()
        let $_ := json:array-push($ured-array, $ured-accession-number)
        let $ct-links := map:map()
        let $_ := map:put($ct-links, "CT", $result/sparql-results:binding[@name="ct"]/sparql-results:literal/text())
        let $_ := map:put($ct-links, "Links", $ured-array)
        return json:array-push($ct-array, $ct-links)

    let $_ := map:put($an-links, 'PE_Links', $pe-array)
    let $_ := map:put($an-links, 'CT_Links', $ct-array)
    let $_ := xdmp:log(("$an-links", $an-links))

    let $elements := sparql-model:create-elements-array($an-links, $divider)
    let $_ := xdmp:log(("$elements", $elements))
    return xdmp:to-json-string($elements)
};

declare function sparql-model:get-funding-elements-from-ured-triples($accession-number, $uri, $divider) {

    let $an-links := map:map()
    let $_ := map:put($an-links, "Center_Node", $accession-number)

    let $triples := sparql-model:get-funding-ured-triples($accession-number)
    let $_ := xdmp:log(("$triples", $triples))
    let $xmlTriples := sem:query-results-serialize($triples)

    let $pe-array := json:to-array()
    let $ct-array := json:to-array()

    let $_ :=
        for $result in $xmlTriples/sparql-results:results/sparql-results:result
        let $r2-uri := $result/sparql-results:binding[@name="r2URI"]/sparql-results:literal/text()
        let $r2-accession-number := fn:tokenize(fn:tokenize($r2-uri, "/")[4],"\.")[1]
        let $r2-array := json:to-array()
        let $_ := json:array-push($r2-array, $r2-accession-number)
        let $pe-links := map:map()
        let $_ := map:put($pe-links, "PE", $result/sparql-results:binding[@name="pe"]/sparql-results:literal/text())
        let $_ := map:put($pe-links, "Links", $r2-array)
        return json:array-push($pe-array, $pe-links)

    let $_ :=
        for $result in $xmlTriples/sparql-results:results/sparql-results:result
        let $tr-uri := $result/sparql-results:binding[@name="trURI"]/sparql-results:literal/text()
        let $tr-accession-number := fn:tokenize(fn:tokenize($tr-uri, "/")[4],"\.")[1]
        let $tr-array := json:to-array()
        let $_ := json:array-push($tr-array, $tr-accession-number)
        let $ct-links := map:map()
        let $_ := map:put($ct-links, "CT", $result/sparql-results:binding[@name="ct"]/sparql-results:literal/text())
        let $_ := map:put($ct-links, "Links", $tr-array)
        return json:array-push($ct-array, $ct-links)

    let $_ := map:put($an-links, 'PE_Links', $pe-array)
    let $_ := map:put($an-links, 'CT_Links', $ct-array)
    let $_ := xdmp:log(("$an-links", $an-links))

    let $elements := sparql-model:create-elements-array($an-links, $divider)
    let $_ := xdmp:log(("$elements", $elements))
    return xdmp:to-json-string($elements)
};

declare function sparql-model:get-funding-elements-from-r2-triples($accession-number, $uri, $divider) {

    let $an-links := map:map()
    let $_ := map:put($an-links, "Center_Node", $accession-number)

    let $triples := sparql-model:get-funding-r2-triples($accession-number)
    let $_ := xdmp:log(("$triples", $triples))
    let $xmlTriples := sem:query-results-serialize($triples)

    let $pe-array := json:to-array()
    let $ct-array := json:to-array()

    let $_ :=
        for $result in $xmlTriples/sparql-results:results/sparql-results:result
        let $ured-uri := $result/sparql-results:binding[@name="uredURI"]/sparql-results:literal/text()
        let $ured-accession-number := fn:tokenize(fn:tokenize($ured-uri, "/")[4],"\.")[1]
        let $ured-array := json:to-array()
        let $_ := json:array-push($ured-array, $ured-accession-number)
        let $pe-links := map:map()
        let $_ := map:put($pe-links, "PE", $result/sparql-results:binding[@name="pe"]/sparql-results:literal/text())
        let $_ := map:put($pe-links, "Links", $ured-array)
        return json:array-push($pe-array, $pe-links)


    let $_ := map:put($an-links, 'PE_Links', $pe-array)
    let $_ := map:put($an-links, 'CT_Links', $ct-array)
    let $_ := xdmp:log(("$an-links", $an-links))

    let $elements := sparql-model:create-elements-array($an-links, $divider)
    let $_ := xdmp:log(("$elements", $elements))
    return xdmp:to-json-string($elements)
};

declare function sparql-model:get-funding-r2-triples($accession-number) {
    let $uri := charts-model:get-uri-from-accession-number($accession-number)
    let $params :=
        map:new((
            map:entry("r2URI", $uri)
        ))
    let $results := sem:sparql('
        SELECT ?r2URI ?pe ?uredURI
        WHERE {
            ?r2URI <rdf:type> "R2" .
            ?r2URI <http://dtic.mil/mdr/pe> ?pe .

            ?uredURI <http://dtic.mil/mdr/pe> ?pe .
            ?uredURI <rdf:type> "URED"
        } LIMIT 15',
        $params
    )
    return $results
};

declare function sparql-model:get-funding-ured-triples($accession-number) {
    let $uri := charts-model:get-uri-from-accession-number($accession-number)
    let $params :=
        map:new((
            map:entry("uredURI", $uri)
        ))
    let $results := sem:sparql('
        SELECT ?r2URI ?pe ?uredURI ?ct ?trURI
        WHERE {
            ?r2URI <rdf:type> "R2" .
            ?r2URI <http://dtic.mil/mdr/pe> ?pe .

            ?uredURI <http://dtic.mil/mdr/pe> ?pe .
            ?uredURI <rdf:type> "URED".
            ?uredURI <http://dtic.mil/mdr/contractNumber> ?ct .

            ?trURI <http://dtic.mil/mdr/contractNumber> ?ct .
            ?trURI <rdf:type> "TR"
        } LIMIT 15',
        $params
    )
    return $results
};

declare function sparql-model:get-funding-tr-triples($accession-number) {
    let $uri := charts-model:get-uri-from-accession-number($accession-number)
    let $params :=
        map:new((
            map:entry("trURI", $uri)
        ))
    let $results := sem:sparql('
        SELECT ?uredURI ?ct ?trURI
        WHERE {
            ?uredURI <rdf:type> "URED".
            ?uredURI <http://dtic.mil/mdr/contractNumber> ?ct .

            ?trURI <http://dtic.mil/mdr/contractNumber> ?ct .
            ?trURI <rdf:type> "TR"
        } LIMIT 15',
        $params
    )
    return $results
};

declare function sparql-model:create-elements-array($an-links, $divider) {
    let $elements := json:to-array()

    let $center-accession-number := map:get($an-links, "Center_Node")
    let $collection := charts-model:get-collection-from-accession-number($center-accession-number)
    let $center-element :=
        if ($collection eq "R2") then
            let $tip-content := r2-model:get-tip-content($center-accession-number)
                return r2-model:create-node-element($center-accession-number, 8 div $divider, $center-accession-number, "r2", $tip-content)
        else
            if ($collection eq "URED") then
                let $tip-content := ured-model:get-tip-content($center-accession-number)
                return ured-model:create-node-element($center-accession-number, 8 div $divider, $center-accession-number, "ured", $tip-content)
            else
                let $tip-content := tr-model:get-tip-content($center-accession-number)
                return tr-model:create-node-element($center-accession-number, 8 div $divider, $center-accession-number, "tr", $tip-content)

    let $_ := json:array-push($elements, $center-element)

    let $pe-obj-list := map:get($an-links, "PE_Links")
    let $_ :=
        for $pe-obj in json:array-values($pe-obj-list)
            let $pe := map:get($pe-obj, "PE")
            let $link-list := map:get($pe-obj, "Links")
            for $link-accession-number in json:array-values($link-list)
                let $collection := charts-model:get-collection-from-accession-number($link-accession-number)
                let $node-element := 
                    if ($collection eq "R2") then
                        let $tip-content := r2-model:get-tip-content($link-accession-number)
                        return r2-model:create-node-element($link-accession-number, 4 div $divider, $link-accession-number, "r2", $tip-content)
                    else
                        let $tip-content := ured-model:get-tip-content($link-accession-number)
                        return ured-model:create-node-element($link-accession-number, 4 div $divider, $link-accession-number, "ured", $tip-content)
                let $_ := json:array-push($elements, $node-element)
                let $id := fn:concat($center-accession-number,"to",$link-accession-number)
                let $edge-element := r2-model:create-edge-element($id, $center-accession-number, $pe, $link-accession-number, "pe")
                return json:array-push($elements, $edge-element)

    let $ct-obj-list := map:get($an-links, "CT_Links")
    let $_ :=
        for $ct-obj in json:array-values($ct-obj-list)
            let $ct := map:get($ct-obj, "CT")
            let $link-list := map:get($ct-obj, "Links")
            for $link-accession-number in json:array-values($link-list)
                let $collection := charts-model:get-collection-from-accession-number($link-accession-number)
                let $node-element :=
                    if ($collection eq "TR") then
                        let $tip-content := tr-model:get-tip-content($link-accession-number)
                        return tr-model:create-node-element($link-accession-number, 4 div $divider, $link-accession-number, "tr", $tip-content)
                    else
                        let $tip-content := ured-model:get-tip-content($link-accession-number)
                        return ured-model:create-node-element($link-accession-number, 4 div $divider, $link-accession-number, "ured", $tip-content)
                let $_ := json:array-push($elements, $node-element)
                let $id := fn:concat($center-accession-number,"to",$link-accession-number)
                let $edge-element := ured-model:create-edge-element($id, $center-accession-number, $ct, $link-accession-number, "ct")
                return json:array-push($elements, $edge-element)

    return $elements
};
