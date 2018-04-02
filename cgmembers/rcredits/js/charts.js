/**
 * @file
 * Display one or all Common Good data graphs
 * @param string whichChart "all" or the name of a specific chart to display
 * @param string growth
 * @param string totalR
 * @param string totalUsd
 * @param string velocity
 * @param string netUsdIn
 * @param string txs
 * @param string fees
 * A JSON-encoded data object is embedded in the page (see var ch below). Each element is a data object for one graph.
 * NOTE!: This script is used in an iframe of cg4.us/chart.php, which in turn includes this script (here for version control)
 */

var getv = parseQuery($('#script-charts').attr('src').replace(/^[^\?]+\??/,''));
//alert($('#script-charts').attr('src').replace(/^[^\?]+\??/,''));
var ctty = getv['ctty'];
var chart = getv['chart'];
var site = getv['site'];

var ch = $('#chart-data').html();
ch = ch.substr(4, ch.length - 7); // trim off the comment markers
ch = JSON.parse(ch);
var vs = ch['vs'];

$('#ctty').change(function () {recall(chart, $(this).val());});
$('#chart').change(function () {
  fixChartClass($(this));
  recall($(this).val(), ctty);}
);
fixChartClass($('#chart'));

var usd = vs['totalUsd']; // unused (yet)
var fees = vs['fees']; // unused
var chartWidth = 600;
var chartHeight = 400;

// (should be on member site instead) $('#edit-ctty').change(function () {window.location = baseUrl + '/community/graphs/qid=' + $(this).val();});

google.setOnLoadCallback(window[vs['whichChart']]);  

google.load('visualization', '1.0', {'packages':['corechart']});

function allChart() {
  growthChart();
  fundsChart();
  velocityChart();
  bankingChart();
  volumeChart();
  issuedChart();
}

function myRows(table, dataName) {
  var dataSet = ch[dataName];
  for (i in dataSet) {
    dataSet[i][0] = new Date(dataSet[i][0] * 1000);
    table.addRow(dataSet[i]);    
  }
};

function growthChart() {
  var data = new google.visualization.DataTable();
  data.addColumn('date', 'Date');
  data.addColumn('number', 'Members');
  data.addColumn('number', 'In process');
  data.addColumn('number', 'Companies');
  myRows(data, 'growthData');
  
  //ch['growthData']);

  var options = {
    title: 'Accounts: ' + vs['growth'],
    width: chartWidth, height: chartHeight,
    colors: ['green', 'orange', 'blue'],
    series: {
      0: {areaOpacity: 0},
      1: {areaOpacity: 0},
      2: {areaOpacity: 0}
    },
    hAxis: {format: 'yyyy', gridlines: {count: 5}, title: '', titleTextStyle: {color: 'darkgray'}},
    legend: {position: 'bottom'}
  };

  var chart = new google.visualization.AreaChart(document.getElementById('growthChart'));
  chart.draw(data, options);
}

function fundsChart() {
  var data = new google.visualization.DataTable();
  data.addColumn('date', 'Date');
  data.addColumn('number', 'Credit');
  data.addColumn('number', 'USD');
  data.addColumn('number', 'Runny');
  data.addColumn('number', 'Top 5');
  data.addColumn('number', 'Runny Balance');
  data.addColumn('number', 'In Use');
//  data.addRows(ch['fundsData']);
  myRows(data, 'fundsData');

  var options = {
    title: 'Total Funds in the System: ' + vs['totalR'],
    width: chartWidth, height: chartHeight,
    colors: ['green', 'blue', 'yellow', 'red', 'magenta', 'orange'],
    series: {
      2: {areaOpacity: 0},
      3: {areaOpacity: 0},
      4: {areaOpacity: 0},
      5: {areaOpacity: 0}
    },
    hAxis: {format: 'yyyy', gridlines: {count: 5}, title: '', titleTextStyle: {color: 'darkgray'}},
    legend: {position: 'right'}
  };

  var chart = new google.visualization.AreaChart(document.getElementById('fundsChart'));
  chart.draw(data, options);
}

function velocityChart() {
  var data = new google.visualization.DataTable();
  data.addColumn('date', 'Date');
  data.addColumn('number', 'Velocity');
//  data.addRows(ch['velocityData']);
  myRows(data, 'velocityData');

  var options = {
    title: 'Circulation Velocity: ' + vs['velocity'],
    width: chartWidth, height: chartHeight,
    hAxis: {
      format: 'yyyy',
      gridlines: {count: 5},
      title: 'What fraction of Common Good Credits turn over monthly', 
      titleTextStyle: {color: 'darkgray'}
    },
    legend: 'none'
  };

  var chart = new google.visualization.LineChart(document.getElementById('velocityChart'));
  chart.draw(data, options);
}

function bankingChart() {
  var data = new google.visualization.DataTable();
  data.addColumn('date', 'Date');
  data.addColumn('number', 'FROM Bank');
  data.addColumn('number', 'TO Bank');
  data.addColumn('number', 'Trade OUT');
  data.addColumn('number', 'Trade IN');
//  data.addRows(ch['bankingData']);
  myRows(data, 'bankingData');

  var options = {
    title: 'Monthly USD Transfers: ' + vs['netUsdIn'],
    width: chartWidth, height: chartHeight,
    colors: ['blue', 'orange', 'green', 'yellow'],
    series: {
      1: {areaOpacity: 1},
      2: {areaOpacity: 0},
      3: {areaOpacity: 0}
    },
    hAxis: {format: 'yyyy', gridlines: {count: 5}, title: '', titleTextStyle: {color: 'darkgray'}},
    legend: {position: 'right'}
  };

  var chart = new google.visualization.AreaChart(document.getElementById('bankingChart'));
  chart.draw(data, options);
}

function volumeChart() {
  var data = new google.visualization.DataTable();
  data.addColumn('date', 'Date');
  data.addColumn('number', 'p2p');
  data.addColumn('number', 'p2b');
  data.addColumn('number', 'b2b');
  data.addColumn('number', 'b2p');
//  data.addRows(ch['volumeData']);
  myRows(data, 'volumeData');

  var options = {
    title: 'Monthly Transactions: ' + vs['txs'],
    width: chartWidth, height: chartHeight,
    colors: ['orange', 'green', 'blue', 'red'],
    hAxis: {format: 'yyyy', gridlines: {count: 5}, title: '(logarithmic scale)', titleTextStyle: {color: 'darkgray'}},
    vAxis: {logScale: true},
    legend: {position: 'bottom'}
  };

  var chart = new google.visualization.LineChart(document.getElementById('volumeChart'));
  chart.draw(data, options);
}

function issuedChart() {
  var data = new google.visualization.DataTable();
  data.addColumn('string', 'Type');
  data.addColumn('number', 'Amount');
  var dataSet = ch['issuedData'];
  for (i in dataSet) data.addRow(dataSet[i]);
  
  var options = {
    title: 'Common Good Credits Issued To-Date: ' + vs['totalR'],
    width: chartWidth, height: chartHeight,
//    pieStartAngle: 240,
    pieSliceText: 'percentage',
    slices: {0: {offset: 0.1},
             1: {offset: 0.1},
             2: {offset: 0.1},
             3: {offset: 0.1},
             4: {offset: 0.2},
             5: {offset: 0.2},
             6: {offset: 0.2},
             7: {offset: 0.2},
             8: {offset: 0.2},
    },    
    is3D: true,
    legend: {position: 'right'}
  };

  var chart = new google.visualization.PieChart(document.getElementById('issuedChart'));
  chart.draw(data, options);
}

function recall(chart, ctty) {
  var myUrl = site == 'dev' ? 'http://localhost/cgMembers/rcredits/misc' : 'https://cg4.us';
  window.location = myUrl + '/chart.php?chart=' + chart + '&ctty=' + ctty + '&site=' + site;
};

function fixChartClass(context) {
  $('option', context).removeClass();
  $(':selected', context).addClass('selected');
}