google.charts.load('current', {'packages':['intensitymap']});

function setCallback(fundingData) {
    google.charts.setOnLoadCallback(function() {
        drawChart(fundingData);
    });
}

function drawChart(fundingData) {
    var data = google.visualization.arrayToDataTable(fundingData);
    var chart = new google.visualization.GeoChart(document.getElementById('chart_div'));
    chart.draw(data, {region: "US", resolution: "provinces"});
}
