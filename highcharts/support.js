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
            data: [{
                name: 'IAC',
                color: '#0200D0',
                y: funding[stateCode].IAC
            }, {
                name: 'Acme',
                color: '#C40401',
                y: funding[stateCode].Acme
            }, {
                name: 'Boeing',
                color: '#C40401',
                y: funding[stateCode].Boeing
            }, {
                name: 'Carnitas',
                color: '#02C401',
                y: funding[stateCode].Carnitas
            }, {
                name: 'DefenseIndustrialComplex',
                color: '#0204C1',
                y: funding[stateCode].DefenseIndustrialComplex
            }],
            dataLabels: {
                format: '<b>{point.name}</b> {point.percentage:.1f}%'
            }
        }]
    });
    
    return false;
};