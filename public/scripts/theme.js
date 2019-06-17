var switcher_div = $('#color-switcher');
var switcher_control = $('#color-switcher-control');
var switcher_is_transitioning = false;

var switcher_div_style = {
	'width': switcher_control.children('a:first').width(),
	'z-index': 2,
	'top': '+=78px',
	'left': '-=5px'
};

var switcher_control_style = {
	'z-index': 3,
	'position': 'relative'
};

function get_flot_colors() {
    if(radmin_current_theme === 'pink') {
        return ['#E63E5D', '#97AF22', '#9D3844', '#533436', '#082D35'];
    } else if(radmin_current_theme === 'green') {
        return ['#42826C', '#FFC861', '#A5C77F', '#6d9f00', '#002F32'];
    } else {
        return ['#49AFCD', '#FF6347', '#38849A', '#BF4A35', '#999', '#555'];
    }

    return ['#49AFCD', '#FF6347', '#38849A', '#BF4A35', '#999', '#555'];
}

function get_sparkline_colors(){
	if(radmin_current_theme === 'pink') {
        return ['#E63E5D', '#97AF22'];
    } else if(radmin_current_theme === 'green') {
        return ['#42826C', '#FFC861'];
    } else {
        return ['#49AFCD', '#FF6347'];
    }

    return ['#49AFCD', '#FF6347'];
}

function position_color_switcher(initial){
	if(switcher_is_transitioning) {
		return false;
	}
	var showing = switcher_div.is(':visible');
	if(initial){
		showing = true;
	}
	if(showing){
		switcher_div_style.top = '+=78px';
	} else {
		switcher_div_style.top = '+=0';
	}
	
	switcher_div.clonePosition(switcher_control, {cloneHeight: false});
	switcher_control.css(switcher_control_style);

	switcher_div.css(switcher_div_style);
}

function set_theme_url(event){
	if($(this).hasClass('pink')){
		window.location.hash = '#!theme=pink';
	} else if($(this).hasClass('green')){
		window.location.hash = '#!theme=green';
	} else {
		window.location.hash = '#!theme=default';
	}
	
	set_theme();
	//reload the page
	location.reload();

}

function set_theme(){
	var theme_hash = window.location.hash.replace('#!theme=','');
	if(theme_hash == 'pink'){
		radmin_current_theme = 'pink';
		$('#main-stylesheet').attr({'href': 'css/radmin-pink.css'});
	}  else if (theme_hash == 'green'){
		radmin_current_theme = 'green';
		$('#main-stylesheet').attr({'href': 'css/radmin-green.css'});
	} else {
		radmin_current_theme = 'default';
		$('#main-stylesheet').attr({'href': 'css/radmin.css'});
	}
}

function toggle_color_switcher(event){
	if(switcher_is_transitioning){
		return false;
	}
	
	position_color_switcher();
	switcher_is_transitioning = true;
	
	if(switcher_div.is(':visible')){
		switcher_div.animate({
		    top: '-=78px',
		  	}, 1000, function() {
		    // Animation complete.
		    switcher_div.hide('slow');
		    switcher_is_transitioning = false;
		});
	} else {
		switcher_div.show();
		switcher_div.animate({
		    top: '+=78px',
		  	}, 1000, function (){
		  		switcher_is_transitioning = false;
		  	});
	}
	
	return;
}

var radmin_current_theme = 'default';
set_theme();