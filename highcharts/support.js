var colors = ['#0200D0', '#C40401', '#02C401', '#0204C1'];
seriesData = function(stateCode) {
    var keys = [];
    var data = [];
    var colorCt = 0;
    for (var key in funding[stateCode]) {
        if (key != "TOTAL") {
            colorCt++;
            series = {
                name: key,
//                color: colors[colorCt],
                y: funding[stateCode][key]
            }
            data.push(series);
        };
    };
    return data;
};

statePopup = function(stateCode) {
    var $div = $('<div></div>')
        .dialog({
            title: this.name,
            width: 400,
            height: 300
        });

    window.chart = new Highcharts.Chart({
        chart: {
            renderTo: $div[0],
            type: 'pie',
            width: 370,
            height: 240
        },
        title: {
            text: null
        },
        series: [{
            name: 'Votes',
            data: seriesData(stateCode),
            tooltip : {
                followPointer : false,
                valuePrefix: '$'
            },
            dataLabels: {
                format: '<b>{point.name}</b> {point.percentage:.1f}%'
            }
        }]
    });
    
    return false;
};