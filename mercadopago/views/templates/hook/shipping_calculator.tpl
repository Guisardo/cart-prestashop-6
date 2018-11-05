{**
* 2007-2015 PrestaShop
*
* NOTICE OF LICENSE
*
* This source file is subject to the Open Software License (OSL 3.0)
* that is bundled with this package in the file LICENSE.txt.
* It is also available through the world-wide-web at this URL:
* http://opensource.org/licenses/osl-3.0.php
* If you did not receive a copy of the license and are unable to
* obtain it through the world-wide-web, please send an email
* to license@prestashop.com so we can send you a copy immediately.
*
* DISCLAIMER
*
* Do not edit or add to this file if you wish to upgrade PrestaShop to newer
* versions in the future. If you wish to customize PrestaShop for your
* needs please refer to http://www.prestashop.com for more information.
*
*  @author    guisardo
*  @copyright Copyright (c) MercadoPago [http://www.mercadopago.com]
*  @license   http://opensource.org/licenses/osl-3.0.php  Open Software License (OSL 3.0)
*  International Registered Trademark & Property of MercadoPago
*}
<script type="text/template" id="shippingCalculator">
<div class="shippingContainer">
    <div style="width: 220px; margin: 0 auto;">
        <img src="{$base_dir_ssl|escape:'htmlall':'UTF-8'}modules/mercadopago/views/img/shipper.png" style="width: 30px; float: left; margin-left: 7px;">
        <ul style="text-align: right; margin-right: 7px; width: 176px; display: inline-block;">
            <li style="margin-right: -2px;">Costo total de envío a:
                <input type="text" style="width: 40px; text-align: center;" placeholder="CP" title="Código Postal"></input>
            </li>
        </ul>
    </div>
</div>
</script>
<script type="text/template" id="shippingCPA">
<li style="white-space: nowrap; float: right;">
Consultá tu Código Postal <u><a href="/costos-envio">acá</a></u>
</li>
</script>
<script type="text/template" id="shippingOption">
<li style="text-align: right;">[[name]]: [[list_cost]]</li>
</script>
<script type="text/javascript">
$(document).ready(function() {
    var shippingOptionsTpl = $('#shippingCalculator').text();
    var shippingCPATpl = $('#shippingCPA').text();
    var shippingOptionTpl = $('#shippingOption').text();
    window.shippingCalculator = function ($calculator_parent, $callback) {
        var $shippingOptions = false;
        var updateShippingCost = function(_shippingOptions) {
            var _oldCP = '';
            if ($shippingOptions) {
                _oldCP = $shippingOptions.find('input').val();
                $shippingOptions.remove();
            }
            $shippingOptions = $(shippingOptionsTpl);
            $calculator_parent.find('.shippingContainer').remove();
            $calculator_parent.append($shippingOptions);
            var $input = $shippingOptions.find('input');
            if ((('ontouchstart' in window) && !/chrome/i.test(navigator.userAgent)) ||
                    /chrome.+mobile/i.test(navigator.userAgent)) {
                $input.attr('type', 'number');
                $input.attr('min', 1000);
                $input.attr('max', 9999);
            } else {
                $input.attr('type', 'text');
                $input.attr('pattern', '\\d{4}');
            }
            var $optionList = $shippingOptions.find('ul');
            if (_shippingOptions.destination) {
                $input.val(_shippingOptions.destination.zip_code);
                for (var i = 0; i < _shippingOptions.options.length; i++) {
                    $optionList.append(shippingOptionTpl.replace('[[name]]', _shippingOptions.destination.state.name).replace('[[list_cost]]', _shippingOptions.options[i].list_cost));
                }
                if (_oldCP != '') {
                    $input.focus();
                }
            } else {
                $input.val(_oldCP);
                $optionList.append(shippingCPATpl);
            }
            var _keyUpTimeout = false;
            $input.on('click', function () {
                this.setSelectionRange(0, this.value.length);
            });
            $input.on('keypress', function(e) {
                if(e.keyCode == 13)
                {
                    event.preventDefault();
                    return false;
                }
            });
            $input.on('change keyup', function(e) {
                if (e.keyCode === 27 && $input.val() !== '') {
                    $input.val('');
                } else if (e.keyCode === 27 && $input.val() === '') {
                    $.fancybox.close();
                    return;
                }
                $shippingOptions.find('img').removeClass('ld ld-wander-h x2');
                clearTimeout(_keyUpTimeout);
                if (this.value == '' || (1000 <= this.value && this.value <= 9999)) {
                    $shippingOptions.find('img').addClass('ld ld-wander-h x2');
                    _keyUpTimeout = setTimeout(delayedCheck, 1000);
                }
            });
        }
        var delayedCheck = function() {
            var _data = {};
            if ($shippingOptions) {
                _data.z = $shippingOptions.find('input').val();
            }
            $.getJSON('/modules/mercadopago/shipping.php', _data).success(function(resp) {
                updateShippingCost(resp);
                if ($callback) {
                    $callback(resp);
                }
            });
        }
        delayedCheck();
    };
    var shippingCalculatorFromHash = function () {
        if (location.hash === '#shippingModal') {
            $('<a href="#shippingModal" />').fancybox({
                'autoSize': false,
                'scrolling': 'no',
                'width': 220,
                'height': 42,
                'minHeight': 50,
                'afterClose': function () {
                    location.hash = '';
                },
                'afterShow': function () {
                    window.scrollTo(0, 0);
                    $.fancybox.reposition();
                    setTimeout(function () {
                        $('#shippingModal input').focus();
                    }, 2000);
                }
            }).click();
        }
    };
    $(window).on('hashchange', shippingCalculatorFromHash);

    $shippingParentForModal = $('<div style="display: none;"><div id="shippingModal" class="shippingModalParent" /></div>');
    $('body').append($shippingParentForModal);
    shippingCalculator($shippingParentForModal.find('#shippingModal'));

    shippingCalculatorFromHash();
    shippingCalculator($('.box-info-product'));
});
</script>