$(function() {
  data = stateData;
  // Make codes uppercase to match the map data
  $.each(data, function() {
    this.code = this.code.toUpperCase();
  });

  // Instantiate the map
  Highcharts.mapChart('container', {

    chart: {
      borderWidth: 1
    },

    title: {
      text: 'Funding in Dollars'
    },

    legend: {
      layout: 'horizontal',
      borderWidth: 0,
      backgroundColor: 'rgba(255,255,255,0.85)',
      floating: true,
      verticalAlign: 'top',
      y: 25
    },

    mapNavigation: {
      enabled: true
    },

    colorAxis: {
      min: 50000000,
      type: 'linear',
      minColor: '#EEEEFF',
      maxColor: '#000022',
      stops: [
        [0, '#EFEFFF'],
        [0.67, '#4444FF'],
        [1, '#000022']
      ]
    },

    series: [{
      animation: {
        duration: 1000
      },
      data: data,
      mapData: Highcharts.maps['countries/us/us-all'],
      joinBy: ['postal-code', 'code'],
      dataLabels: {
        enabled: true,
        color: '#FFFFFF',
        format: '{point.code}'
      },
      name: 'Research Funding',
      tooltip: {
          numberFormat: '{point.code}: ${point.value}'
      },
      point: {
          events: {
              click: function(e) { statePopup(this.code); }
          }
      }
    }]
  });
})