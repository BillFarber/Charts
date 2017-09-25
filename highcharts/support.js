var colors = ['#0200D0', '#C40401', '#02C401', '#0204C1'];
var maxOrganizations = 3;

seriesData = function(stateCode) {
    var data = [];
    var stateFunding = funding[stateCode];
    var sortableStateFunding = [];
    for (var organization in stateFunding) {
        sortableStateFunding.push([organization, stateFunding[organization]]);
    }
    sortableStateFunding.sort(function(a, b) {
        return b[1] - a[1];
    });

    var colorCt = 0;
    for (var key in sortableStateFunding) {
        var orgFunding = sortableStateFunding[key];
        if ((orgFunding[0] != "TOTAL") && (colorCt < maxOrganizations)) {
            series = {
                name: orgFunding[0],
                color: colors[colorCt],
                y: orgFunding[1]
            }
            data.push(series);
            colorCt++;
        };
    };
    return data;
};

statePopup = function(selectedYear, stateCode) {
    var $div = $('<div></div>')
        .dialog({
            title: this.name,
            width: 600,
            height: 400
        });

    window.chart = new Highcharts.Chart({
        chart: {
            renderTo: $div[0],
            type: 'pie',
            width: 600,
            height: 400
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
            },
            point : {
                events : {
                    click : function(e) {
                        var state = stateCode;
                        var organization = this.name;
                        window.location.href = "/highcharts/state-organization-table.xqy?state="+state+"&organization="+organization+"&year="+selectedYear;
                    }
                }
            }
        }]
    });
    
    return false;
};