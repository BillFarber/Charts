xquery version "1.0-ml";

import module namespace charts-model = "http://org.billFarber.marklogic/charts"      at "/models/charts-model.xqy";
import module namespace r2-model     = "http://org.billFarber.marklogic/charts/r2"   at "/models/r2-model.xqy";
import module namespace tr-model     = "http://org.billFarber.marklogic/charts/tr"   at "/models/tr-model.xqy";
import module namespace ured-model   = "http://org.billFarber.marklogic/charts/ured" at "/models/ured-model.xqy";

declare namespace mdr  = "http://dtic.mil/mdr/record";
declare namespace meta = "http://dtic.mil/mdr/record/meta";

declare option xdmp:mapping "false";

let $accession-number := "EF000003"
let $accession-number := (xdmp:get-request-field("accessionNumber"), $accession-number)[1]
let $_ := xdmp:log(("$accession-number",$accession-number))
let $collection := charts-model:get-collection-from-accession-number($accession-number)
let $_ := xdmp:log(("$collection",$collection))

let $elements := 
        switch ($collection) 
            case "TR"   return tr-model:get-funding-elements($accession-number, 1)
            case "URED" return ured-model:get-funding-elements($accession-number, 1)
            case "R2"   return r2-model:get-funding-elements($accession-number, 1)
            default     return charts-model:empty-elements-list()

let $elements-script := fn:concat("var elements = ", $elements,";")
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
            <form action="/cytoscape/funding.xqy">
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