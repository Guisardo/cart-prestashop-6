$(function() {
	var isFirstLoad = 2;
	var $frm_search = $('#frm_search'); 
	var $dd_states = $('#dd_states');
	var $pnl_search = $('#pnl_search');
	var $pnl_results = $('#pnl_results');
	var $shipping_cost = $('#shipping_cost');
	var $dd_substates = $('#dd_substates');

	$dd_states.on('click', 'li a', function(){
		var $this = $(this);
		$dd_states.find('li').removeClass('active');
		$this.parent().addClass('active');
		$dd_states.find('a span:eq(0)').attr('data-code', $this.data('code')).text($this.text());
		$frm_search.find('input').removeAttr('disabled').val('').focus();
	});
	$dd_substates.on('click', 'li a', function(){
		var $this = $(this);
		var $result_list = $pnl_results.find('ul.list-group');
		$dd_substates.find('li').removeClass('active');
		$this.parent().addClass('active');
		$dd_substates.find('a span:eq(0)').text($this.text());
		$result_list.find('[data-parent]').hide();
		$result_list.find('[data-parent="' + $this.text() + '"]').show();
		$pnl_results.find('.col-md-4:eq(1)').removeClass('hide');

		$shipping_cost.find('h2 span:eq(2)').removeClass('hide');
		$shipping_cost.find('h2 span:lt(2), h2 ul').addClass('hide');
		if ($result_list.find('[data-parent="' + $this.text() + '"]').length === 1) {
			$result_list.find('[data-parent="' + $this.text() + '"]:eq(0)').click();
		} else {
			var state = $dd_states.find('a span:eq(0)').text();
			getCoordinates($this.text() + ', ' + state + ', Argentina', setMap);
		}
	});

	$frm_search.on('keypress', 'input', function (e) {
	    if (e.keyCode === 13) {
            $frm_search.find('button').focus().click();
	        return false;
	    }
	});

	$frm_search.on('click', 'button', function () {
		var $result_list = $pnl_results.find('ul.list-group');
		$result_list.empty();
		$dd_substates.find('ul').empty();
		$shipping_cost.find('h2 span:eq(2)').removeClass('hide');
		$shipping_cost.find('h2 span:lt(2), h2 ul').addClass('hide');
		$frm_search.find('span.label-warning').addClass('hide');
		$pnl_results.find('.col-md-4').addClass('hide');

		var state = $dd_states.find('a span:eq(0)').attr('data-code');
		var keyword = $frm_search.find('input').val().normalize('NFD').replace(/[\u0300-\u036f]/g, "").trim().toUpperCase();

		if (keyword !== '') {		
			$.getJSON('/index.php?fc=module&module=mercadopago&controller=cpa' +
				'&state=' + state +
				'&keyword=' + keyword
				).success(function(codes) {
					var bestFound = false;
					var zipParents = [];
					var tpl_resultItem = $('#result_item').html();
					$(codes).each(function() {
						if (this['code']) {
							var $newItem = $(tpl_resultItem);
							$newItem.find('span:eq(0)').html(this['place'] + ' (CP ' + this['code'] + ')');
							$newItem.attr('data-name', this['place']);
							$newItem.attr('data-code', this['code']);
							if ($result_list.find('[data-parent="' + this['parent'] + '"]').length === 0) {
								zipParents.push(this['parent']);
							}
							$newItem.attr('data-parent', this['parent']);

							$result_list.append($newItem);
							if (this['place'].toUpperCase() === keyword) {
								bestFound = this['parent'];
								zipParents.shift();
								//$newItem.click();
							}
						}
					});
					if ($pnl_results.find('ul.list-group li').length > 0) {
						$pnl_search.collapse('hide');
						$pnl_results.collapse('show');
						//if (!bestFound) {
						//	$pnl_results.find('ul.list-group li:eq(0)').click();
						//}
						$dd_substates.hide();
						if ($result_list.find('[data-parent]').length > 20) {
							zipParents = zipParents.sort(alphanumCase);
			                if (bestFound) {
				                zipParents.unshift(bestFound)
				            }

							var tpl_resultSubstate = $('#result_substate').html();
							$(zipParents).each(function() {
								var $newItem = $(tpl_resultSubstate);
								$newItem.find('a').text(this);
								$dd_substates.find('ul').append($newItem);
							});
							$dd_substates.show();

							$result_list.find('[data-parent]').hide();
							if (bestFound) {
								$dd_substates.find('li a:eq(0)').click();
							} else {
								$dd_substates.find('a span:eq(0)').text('Elija localidad');
							}
						}
						$pnl_results.find('.col-md-4:eq(0)').removeClass('hide');
						if ($result_list.find('[data-parent]:visible').length === 1) {
							$result_list.find('[data-parent]:visible').click();
						} else if (bestFound) {
							$result_list.find('[data-name="' + bestFound + '"]').click();
						}
					} else {
						$frm_search.find('span.label-warning').removeClass('hide');
						$pnl_results.collapse('hide');					
						setTimeout(function() {
							$('#pnl_search input').focus();
						}, 500);
					}
					toggleCaret($pnl_results.prev());
					toggleCaret($pnl_search.prev());
			});
		}
	});

	var toggleCaret = function($panel) {
		if (isFirstLoad !== 0) {
			isFirstLoad -= 1;
			return;
		}
		var $caret = $panel.find('span.fa');

		if ($panel.hasClass('collapsed')) {
			$caret.removeClass('fa-caret-down').addClass('fa-caret-right');
		} else {
			$caret.removeClass('fa-caret-right').addClass('fa-caret-down');
		}
	};
	$pnl_search.on("hide.bs.collapse", function(){
		toggleCaret($(this).prev().addClass('collapsed'));
	});
	$pnl_search.on("show.bs.collapse", function(){
		toggleCaret($(this).prev().removeClass('collapsed'));
		setTimeout(function() {
			$('#pnl_search input').focus();
		}, 500);
	});
	$pnl_results.on("hide.bs.collapse", function(){
		toggleCaret($(this).prev().addClass('collapsed'));
		$pnl_search.collapse('show');
		setTimeout(function() {
			toggleCaret($('#pnl_search').prev());
			$('#pnl_search input').focus();
		}, 500);
	});
	$pnl_results.on("show.bs.collapse", function(){
		toggleCaret($(this).prev().removeClass('collapsed'));
	});
	$pnl_results.collapse('hide');

	$pnl_results.on('click', 'ul.list-group li', function() {
		$this = $(this);
		$pnl_results.find('.col-md-4:eq(1)').removeClass('hide');
		$pnl_results.find('ul li').removeClass('active').addClass('inactive').removeClass('btn-success').addClass('btn-default');
		$this.removeClass('inactive').addClass('active').removeClass('btn-default').addClass('btn-success');

		$shipping_cost.find('h2 span:eq(2)').addClass('hide');
		$shipping_cost.find('h2 span:lt(2), h2 ul').removeClass('hide');

        $.getJSON('/modules/mercadopago/shipping.php', {
        	z: $this.data('code')
        }).success(function(resp) {
        	if (resp.options && resp.options.length > 0) {
				$ul = $shipping_cost.css({
					visibility: 'visible'
				}).find('h2 ul');

				shipping_options = resp.options.sort(function(a, b) {
					return alphanumCase(a.list_cost.toString(), b.list_cost.toString());
				});
				$(shipping_options).each(function() {
					$ul.append('<li style="vertical-align: middle;padding: 5px;"><span style="vertical-align: middle;margin-right: 5px;">$ ' + (this.list_cost*1.0).toFixed(2).toString().replace('.', ',') + '</span><img src="' + this.img + '" height="23"></li>');
				});

				setTimeout(function() {
				    $('html, body').animate({
				    	scrollTop: $('#shipping_cost').offset().top - 40
				    }, 'slow');
				}, 500);
        	}
        });

		var state = $dd_states.find('a span:eq(0)').text();
		getCoordinates($this.data('name') + ', ' + state + ', Argentina', setMap);
	});


	var setMap = function(coordinates) {
		var $g_map = $pnl_results.find('[data-mapurl]');
		var g_map_url = $g_map.data('mapurl');
		if (coordinates) {
			g_map_url = g_map_url.replace('Argentina', coordinates);
		}
		$g_map.attr('src', g_map_url);
		$pnl_results.find('.col-md-4:eq(2)').removeClass('hide');
	}
	var getCoordinates = function(place, cb) {
		var geocoder = new google.maps.Geocoder();
		geocoder.geocode({'address': place}, function (results, status) {
			if (results.length === 0) {
				var placeSplit = place.split(', ');
				place = placeSplit.slice(1, placeSplit.length - 1).join(', ');
				getCoordinates(place, cb);
			} else {
				cb(results[0].geometry.location.lat() + ',' + results[0].geometry.location.lng());
			}
		});
	};
}());
