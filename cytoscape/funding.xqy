xquery version "1.0-ml";

import module namespace ured-model = "http://org.billFarber.marklogic/charts/ured" at "/models/ured-model.xqy";

declare namespace mdr="http://dtic.mil/mdr/record";
declare namespace meta="http://dtic.mil/mdr/record/meta";

declare option xdmp:mapping "false";

let $ured-accession-number := "EF000003"
let $elements := ured-model:get-funding-elements($ured-accession-number)
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
            max-width: 800px;
            height: 700px;
            margin: auto;
        }
      '}</style>
      <meta charset="UTF-8"/>
    </head>
    <body>
        <div>
          <p>Cytoscape</p>
          <div id="cytoscape-container"></div>
          <script type="text/javascript">{$elements-script}</script>
          <script src="/cytoscape/lib/cytoscape.js"></script>
          <script src="/cytoscape/funding.js"></script>
        </div>
    </body>
  </html>
)