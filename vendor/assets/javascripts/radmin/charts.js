//to change default tooltip styles, the tooltip div has an id of flotTip (i.e. use #flotTip)

/**
 *  Options for different graphs
 *
 */

var flot_options_sin_cos = {
    colors: get_flot_colors(),

    series: {
        lines: {
            show: true,
            lineWidth: 4,
            steps: false
        },
        points: {
            show: true,
            radius: 4,
            fill: true
        }
    },
    legend: {
        position: 'ne'
    },
    custom_tooltip: true,
    use_both: true,
    xaxis: {
        mode: "time"
    },
    grid: {
        borderWidth: 2,
        hoverable: true
    }
};

var flot_options_vertical = {
    colors: get_flot_colors(),
    grid: {
        hoverable: true,
        borderWidth: 2
    },
    bars: {
        show: true,
        align: 'center',
        barWidth: 0.15
    },
    legend: {
        show: true
    },
    tooltip: true,
    tooltipOpts: {
        content: '%s: %y'
    }
};

//clone the vertical options, then make changes
var flot_options_horizontal = jQuery.extend({}, flot_options_vertical, {
    bars: {
        barWidth: 0.25,
        show: true,
        align: 'center'
    },
    tooltipOpts: {
        content: '%s: %x'
    }
});

var flot_options_line = {
    colors: get_flot_colors(),

    grid: {
        hoverable: true,
        borderWidth: 2
    },
    lines: {
        show: true,
        lineWidth: 4,
        steps: false,
        fillColor: {
            colors: [{
                opacity: 0.1
            }, {
                opacity: 0.5
            }]
        }
    },
    points: {
        show: true
    },
    xaxis: {
        tickDecimals: 0,
        tickSize: 1
    },
    tooltip: true,
    tooltipOpts: {
        content: '%s - %x: %y'
    }

};

var flot_options_pie = {
    colors: get_flot_colors(),
    series: {
        pie: {
            show: true,
            stroke: {
                width: 3
            }
        }
    },
    grid: {
        hoverable: true
    },

    tooltip: true,
    tooltipOpts: {
        content: '%s: %y'
    }
};

var flot_options_doughnut = jQuery.extend({}, flot_options_pie, {
    series: {
        pie: {
            show: true,
            innerRadius: 0.55,
            stroke: {
                width: 5
            }
        }
    }
});

/**
 * Functions that draw graphs
 *
 */

function flot_sin_cos(placeholder_id, user_options) {
    var placeholder = $('#' + placeholder_id);
    var options = jQuery.extend({}, user_options);
    options.use_both = options.use_both === true ? true : false;

    if(placeholder.length <= 0) {
        return false;
    }

    var sin = [],
        cos = [],
        data_set = [];

    for(var i = 0; i < 14; i += 0.5) {
        sin.push([i, Math.sin(i)]);
        if(options.use_both) {
            cos.push([i, Math.cos(i)]);
        }
    }

    data_set.push({
        data: sin,
        label: "sin(x)"
    });

    if(options.use_both) {
        data_set.push({
            data: cos,
            label: "cos(x)"
        });
    }

    var plot = $.plot(placeholder, data_set, options);

    function showTooltip(x, y, contents) {
        $('<div id="tooltip">' + contents + '</div>').css({
            position: 'absolute',
            display: 'none',
            top: y + 5,
            left: x + 5,
            border: '1px solid #fdd',
            padding: '2px',
            'background-color': '#fee',
            opacity: 0.80
        }).appendTo("body").fadeIn(200);
    }

    var previousPoint = null;
    placeholder.bind("plothover", function(event, pos, item) {
        $("#x").text(pos.x.toFixed(2));
        $("#y").text(pos.y.toFixed(2));
        if(options.custom_tooltip) {
            if(item) {
                if(previousPoint != item.dataIndex) {
                    previousPoint = item.dataIndex;

                    $("#tooltip").remove();
                    var x = item.datapoint[0].toFixed(2),
                        y = item.datapoint[1].toFixed(2);

                    showTooltip(item.pageX, item.pageY, item.series.label + " of " + x + " = " + y);
                }
            } else {
                $("#tooltip").remove();
                previousPoint = null;
            }
        }
    });

    placeholder.bind("plotclick", function(event, pos, item) {
        if(item) {
            $("#clickdata").text("You clicked point " + item.dataIndex + " in " + item.series.label + ".");
            plot.highlight(item.series, item.datapoint);
        }
    });
}


function flot_vertical_bar(placeholder_id, user_options, data_set) {
    var placeholder = $('#' + placeholder_id);
    var options = jQuery.extend({}, user_options);

    if(placeholder.length <= 0) {
        return false;
    }

    if(data_set === null || data_set === undefined) {
        data_set = [
            [
                [1, 50],
                [2, 24],
                [3, 13],
                [4, 23],
                [5, 9]
            ],
            [
                [1, 5],
                [2, 35],
                [3, 16],
                [4, 9],
                [5, 45]
            ],
            [
                [1, 17],
                [2, 36],
                [3, 62],
                [4, 30],
                [5, 24]
            ]
        ];
    }

    $.plot(placeholder, [{
        data: data_set[0],
        label: 'Data set 1',
        bars: {
            order: 1
        }
    }, {
        data: data_set[1],
        label: 'Data set 2',
        bars: {
            order: 2
        }
    }, {
        data: data_set[2],
        label: 'Data set 3',
        bars: {
            order: 3
        }
    }], options);
}

function flot_line(placeholder_id, user_options, data_set, labels) {
    var placeholder = $('#' + placeholder_id);
    var options = jQuery.extend({}, user_options);

    if(placeholder.length <= 0) {
        return false;
    }
    if(data_set === null || data_set === undefined){
        data_set = [
            [
                [1999, 3.0],
                [2000, 3.9],
                [2001, 2.0],
                [2002, 1.2],
                [2003, 1.3],
                [2004, 2.5],
                [2005, 2.0],
                [2006, 3.1],
                [2007, 2.9],
                [2008, 0.9]
            ],
            [
                [1999, 0.1],
                [2000, 2.9],
                [2001, 0.2],
                [2002, 0.3],
                [2003, 1.4],
                [2004, 2.7],
                [2005, 1.9],
                [2006, 2.0],
                [2007, 2.3],
                [2008, 0.7]
            ],
            [
                [1999, 4.4],
                [2000, 3.7],
                [2001, 0.8],
                [2002, 1.6],
                [2003, 2.5],
                [2004, 3.6],
                [2005, 2.9],
                [2006, 2.8],
                [2007, 2.0],
                [2008, 1.1]
            ]
        ];
    }

    if(labels === null || labels === undefined){
        labels = ["Europe (EU27)", "Japan", "USA"];
    }

    var data = [];
    var total_data_set = data_set.length;
    for(var i = 0; i < total_data_set; i++){
        if(data_set[i] !== undefined && labels[i] !== undefined){
            var temp_data = {
                label: labels[i],
                data: data_set[i],
                lines: {
                    lineWidth: 3
                }
            };
            if(i === 0){
                temp_data.lines.fill = true;
            }
            data.push(temp_data);
        }
    }

    $.plot(placeholder, data, options);
}

function flot_horizontal_bar(placeholder_id, user_options) {
    if(user_options.bars.horizontal === false || user_options.bars.horizontal === undefined) {
        user_options.bars.horizontal = true;
    }

    var data_set = [
        [
            [50, 1],
            [24, 2],
            [13, 3],
            [23, 4],
            [9, 5]
        ],
        [
            [5, 1],
            [35, 2],
            [16, 3],
            [9, 4],
            [45, 5]
        ],
        [
            [17, 1],
            [36, 2],
            [52, 3],
            [30, 4],
            [24, 5]
        ]
    ];


    flot_vertical_bar(placeholder_id, user_options, data_set);
}

function flot_pie(placeholder_id, user_options, data_set) {
    var placeholder = $('#' + placeholder_id);
    var options = jQuery.extend({}, user_options);

    if(placeholder.length <= 0) {
        return false;
    }
    if(data_set === null || data_set === undefined) {
        data_set = [10, 30, 90, 70];
    }

    var data = [{
        label: "Data set 1",
        data: data_set[0]
    }, {
        label: "Data set 2",
        data: data_set[1]
    }, {
        label: "Data set 3",
        data: data_set[2]
    }, {
        label: "Data set 4",
        data: data_set[3]
    }];

    $.plot(placeholder, data, options);

}