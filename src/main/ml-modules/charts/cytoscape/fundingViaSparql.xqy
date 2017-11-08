xquery version "1.0-ml";

import module namespace sparql-model = "http://org.billFarber.marklogic/sparql" at "/models/sparql-model.xqy";

declare option xdmp:mapping "false";

let $accession-number := "0601103A_1_2040A_PB_2011"
let $accession-number := (xdmp:get-request-field("accessionNumber"), $accession-number)[1]
let $_ := xdmp:log(("$accession-number",$accession-number))

let $selected-layout := "concentric"
let $selected-layout := (xdmp:get-request-field("layout"), $selected-layout)[1]
let $layouts := ("cose", "concentric", "circle")

let $elements := sparql-model:get-funding-elements-from-triples($accession-number, 1)

let $elements-script := fn:concat("var elements = ", $elements,"; var layoutName = '", $selected-layout, "';")
let $_ := xdmp:log(("$elements-script",$elements-script))

return
(
  xdmp:set-response-content-type("text/html"),
  "<!DOCTYPE html>",
  <html xmlns="http://www.w3.org/1999/xhtml">
    <head>
      <title>Cytoscape Network Visualization</title>
      <style type="text/css">{'
        #cytoscape-container {
            max-width: 700px;
            height: 600px;
            margin: auto;
        }
      '}</style>
      <meta charset="UTF-8"/>
    </head>
    <body>
          <div id="queryInput" style="float:left;">
            <form action="/cytoscape/fundingViaSparql.xqy">
                    {
                        for $layout in $layouts
                        return
                            if ($layout eq $selected-layout) then
                                <div><input type="radio" name="layout" value="{$layout}" checked="checked" > {$layout}</input></div>
                            else
                                <div><input type="radio" name="layout" value="{$layout}" > {$layout}</input></div>
                    }
                    <br></br>
                Accession Number:<br></br>
                <input type="text" name="accessionNumber" value="{$accession-number}"></input><br></br>
                <input type="submit" value="Submit"></input>
            </form> 
          </div>
          <div id="cytoscape-container" style='height: 700px; width: 1000px; min-width: 400px; max-width: 1000px; margin: 0 auto'></div>
          <script type="text/javascript">{$elements-script}</script>
          <script src="/cytoscape/lib/jquery-3.1.1.min.js">&nbsp;</script>
          <script src="/cytoscape/lib/cytoscape.js">&nbsp;</script>
          <script src="/cytoscape/lib/jquery.qtip.min.js">&nbsp;</script>
          <link href="/cytoscape/lib/jquery.qtip.min.css" rel="stylesheet" type="text/css" />
          <script src="/cytoscape/lib/cytoscape-qtip.js">&nbsp;</script>
          <script src="/cytoscape/lib/cytoscape-cxtmenu.js">&nbsp;</script>
          <script src="/cytoscape/funding.js">&nbsp;</script>
    </body>
  </html>
)