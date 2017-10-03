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
                shortName: orgFunding[0].substring(0,15),
                color: colors[colorCt],
                y: orgFunding[1]
            }
            data.push(series);
            colorCt++;
        };
    };
    return data;
};

statePopup = function(selectedYear, stateCode, stateName) {
    var $div = $('<div style="border: 1px solid black; text-align: center;"></div>')
        .dialog({
            title: stateName,
            width: 600,
            height: 400
        });
    window.chart = new Highcharts.Chart({
        chart: {
            renderTo: $div[0],
            type: 'pie',
            width: 595,
            height: 375
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
                format: '<b>{point.shortName}</b> {point.percentage:.1f}%'
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