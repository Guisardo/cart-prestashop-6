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
*  @author    MercadoPago
*  @copyright Copyright (c) MercadoPago [http://www.mercadopago.com]
*  @license   http://opensource.org/licenses/osl-3.0.php  Open Software License (OSL 3.0)
*  International Registered Trademark & Property of MercadoPago
*}
<script type="text/javascript" src="https://maps.google.com/maps/api/js?key=AIzaSyBGZ9Acw-CKIHL1kddrRwG4dn2JG5jJwko&"></script>
<link rel="stylesheet" href="{$this_path_ssl|escape:'htmlall':'UTF-8'}modules/mercadopago/views/css/cpasearch.css" type="text/css" media="all" />
<div class="section">
  <div class="container">
    <div class="row">
      <div class="col-md-12">
        <div class="panel panel-primary">
          <div class="panel-heading collapsed" data-toggle="collapse" data-target="#pnl_search">
            <h3 class="panel-title">
            	{l s='Buscador' mod='mercadopago'} <span class="fa fa-caret-down"></span>
            </h3>
          </div>
          <div id="pnl_search" class="panel-collapse collapse">
	          <div class="panel-body">
	            <div class="col-md-12">
	              <form class="form-horizontal" role="form" id="frm_search">
	                <div class="form-group">
	                  <div class="col-sm-2">
	                    <label for="inputState" class="control-label">{l s='Provincia' mod='mercadopago'}</label>
	                  </div>
	                  <div class="col-sm-10">
	                    <div class="btn-group dropdown-menu-right w-100" id="dd_states">
	                      <a class="btn btn-primary dropdown-toggle w-100" data-toggle="dropdown"> <span>{l s='Provincia' mod='mercadopago'}</span> <span class="fa fa-caret-down"></span></a>
	                      <ul class="dropdown-menu dropdown-menu-right w-100" role="menu">
		                    {foreach from=$states item=state}
							<li>
							  <a data-code="{$state.code}">{$state.name}</a>
							</li>
							{/foreach}
	                      </ul>
	                    </div>
	                  </div>
	                </div>
	                <div class="form-group">
	                  <div class="col-sm-2">
	                    <label for="inputLugar" class="control-label">{l s='Dirección o localidad' mod='mercadopago'}</label>
	                  </div>
	                  <div class="col-sm-10">
	                    <input type="text" class="form-control" id="inputLugar" style="color: #686666;" disabled placeholder="{l s='Lugar' mod='mercadopago'}">
    					<span class="label label-warning col-sm-offset-10 hide">{l s='* No hay resultados' mod='mercadopago'}</span>
	                  </div>
	                </div>
	                <div class="form-group">
	                  <div class="col-sm-10 col-sm-offset-2 text-right">
	                    <button type="button" class="btn btn-primary">{l s='¡ Buscar !' mod='mercadopago'}</button>
	                  </div>
	                </div>
	              </form>
	            </div>
	        </div>
          </div>
        </div>
        <div class="panel panel-primary">
          <div class="panel-heading" data-toggle="collapse" data-target="#pnl_results">
            <h3 class="panel-title">
            	{l s='Resultados' mod='mercadopago'} <span class="fa fa-caret-right"></span>
            </h3>
          </div>
          <div id="pnl_results" class="panel-collapse collapse in">
	          <div class="panel-body">
	            <div class="col-md-4">
					<div class="btn-group dropdown-menu-right w-100" id="dd_substates" style="display: none; margin-bottom: 5px;">
					  <a class="btn btn-info dropdown-toggle w-100" data-toggle="dropdown"> <span></span> <span class="fa fa-caret-down"></span></a>
					  <ul class="dropdown-menu dropdown-menu-right w-100" role="menu">
					  </ul>
					</div>
					<ul class="list-group">
					</ul>
	            </div>
	            <div class="col-md-4 hide" style="margin-top: 15px; margin-bottom: 15px;" id="shipping_cost">
	            	<div style="width: 235px; margin: 0 auto;" class="text-center">
					    <img src="{$this_path_ssl|escape:'htmlall':'UTF-8'}/modules/mercadopago/views/img/shipper.png" style="width: 30px; display: block; margin-left: 7px;">
					    <h2 class="text-center" style="padding-left: 52px; margin-top: -60px;">
					    	<span class="hide">{l s='Costo de envío del pedido:' mod='mercadopago'}</span> <span class="hide" style="display: inline-block;"></span>
					    	<span>{l s='Elija un código postal para calcular el envío' mod='mercadopago'}</span>
					    </h2>
						<a class="btn btn-default button button-medium" href="https://tienda.ropitas.com.ar/" title="{l s='Comprar' mod='mercadopago'}">
							<span>{l s='Comprar' mod='mercadopago'}<i class="icon-chevron-right right"></i></span>
						</a>
					</div>
	            </div>
	            <div class="col-md-4 hide">
	              <img style="margin: 0 auto;" class="center-block img-circle img-responsive" data-mapurl="https://maps.googleapis.com/maps/api/staticmap?center=Argentina&amp;key=AIzaSyBGZ9Acw-CKIHL1kddrRwG4dn2JG5jJwko&amp;zoom=9&amp;size=200x200&amp;sensor=false" src="https://maps.googleapis.com/maps/api/staticmap?center=Argentina&amp;key=AIzaSyBGZ9Acw-CKIHL1kddrRwG4dn2JG5jJwko&amp;zoom=3&amp;size=200x200&amp;sensor=false">
	            </div>
	          </div>
	      </div>
        </div>
      </div>
    </div>
  </div>
</div>
<script type="text/template" id="result_item">
	<li class="btn btn-default inactive w-100" style="white-space: inherit;"><span></span> <span class="fa fa-map-marker"></span></li>
</script>
<script type="text/template" id="result_substate">
	<li>
	  <a></a>
	</li>
</script>

<script type="text/javascript" src="{$this_path_ssl|escape:'htmlall':'UTF-8'}js/vendor/alphanum.js?v=1.1"></script>
<script type="text/javascript" src="{$this_path_ssl|escape:'htmlall':'UTF-8'}modules/mercadopago/views/js/cpasearch.js?v=1.0.12"></script>
