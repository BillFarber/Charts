var drawMap = function(funding) {
//Width and height of map
    var width = 960;
    var height = 500;

    // D3 Projection
    var projection = d3.geo.albersUsa()
        .translate([width/2, height/2])      // translate to center of screen
        .scale([1000]);                      // scale things down so see entire US

    // Define path generator
    var path = d3.geo.path()                // path generator that will convert GeoJSON to SVG paths
        .projection(projection);            // tell path generator to use albersUsa projection

    // Define linear scale for output
    var color = d3.scale.linear().range(["rgb(213,222,217)","rgb(69,173,168)","rgb(84,36,55)","rgb(217,91,67)"]);

    // Create SVG element and append map to the SVG
    var svg = d3.select("body")
                .append("svg")
                .attr("width", width)
                .attr("height", height);

    // Append Div for tooltip to SVG
    var div = d3.select("body")
                .append("div")
                .attr("class", "tooltip")
                .style("opacity", 0);

    var colors = [
        "rgb(247,222,235)",
        "rgb(239,198,219)",
        "rgb(225,158,202)",
        "rgb(214,107,174)",
        "rgb(198,66,146)",
        "rgb(181,33,113)",
        "rgb(156,8,81)",
        "rgb(107,8,48)"
    ];

    var defaultColor = "rgb(0,0,0)";
    var maxStateFunding = 0;
    for (var key in funding) {
        if (funding.hasOwnProperty(key)) {
            if (funding[key] > maxStateFunding) {
                maxStateFunding = funding[key];
            }
        }
    }

    d3.json("/plainD3/data/us-states.json", function(json) {
        svg.selectAll("path")
            .data(json.features)
            .enter()
            .append("path")
            .attr("d", path)
            .style("stroke", "#fff")
            .style("stroke-width", "1")
            .style("fill", function(d) {
                stateFunding = funding[d.abbreviation];
                if (stateFunding != undefined) {
                    fundingLevel = Math.floor((stateFunding / maxStateFunding * 100 / 16) + 1);
                    return colors[fundingLevel];
                } else  {
                    return defaultColor;
                }
            });
    });
}