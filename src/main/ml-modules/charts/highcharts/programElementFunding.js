$(function() {
    title = titleText;
    data = seriesData;
    year = firstYear;

    Highcharts.chart('container', {

        title: {
            text: title
        },

        yAxis: {
            title: {
                text: 'Funding in Dollars'
            }
        },

        legend: {
            layout: 'vertical',
            align: 'right',
            verticalAlign: 'middle'
        },

        plotOptions: {
            series: {
                label: {
                    connectorAllowed: false
                },
                pointStart: year
            }
        },

        series: data,

        responsive: {
            rules: [{
                condition: {
                    maxWidth: 500
                },
                chartOptions: {
                    legend: {
                        layout: 'horizontal',
                        align: 'center',
                        verticalAlign: 'bottom'
                    }
                }
            }]
        }

    });
})