google.charts.load('current', {'packages':['intensitymap']});
google.charts.setOnLoadCallback(drawChart);

function drawChart() {
    var data = google.visualization.arrayToDataTable([
    ['State', 'Foo Factor'],
    ['US-IL', 200],
    ['US-IN', 300],
    ['US-IA', 20],
    ['US-RI', 150]
]);

    var chart = new google.visualization.GeoChart(document.getElementById('chart_div'));

    chart.draw(data, {region: "US", resolution: "provinces"});
}
