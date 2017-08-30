//google.charts.load('current', {'packages':['intensitymap']});

google.charts.setOnLoadCallback(drawChart);

      function drawChart() {
        var data = google.visualization.arrayToDataTable([
          ['Country', 'Population (mil)', 'Area (km2)'],
          ['CN',            1324,           9640821],
          ['IN',            1133,           3287263],
          ['US',            304,            9629091],
          ['ID',            232,            1904569],
          ['BR',            187,            8514877]
        ]);

        var chart = new google.visualization.IntensityMap(document.getElementById('chart_div'));

        chart.draw(data, {});
}