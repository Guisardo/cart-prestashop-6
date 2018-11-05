<?php
/**
 * 2007-2015 PrestaShop.
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
 */

include_once dirname(__FILE__).'/../../mercadopago.php';
class MercadoPagoCpaSearchModuleFrontController extends ModuleFrontController
{
    public function initContent()
    {
        $this->display_column_left = false;
        parent::initContent();
        $this->displayFinder();
    }

    private function displayFinder()
    {
        $mercadopago = $this->module;
		if (Context::getContext()->customer->logged && !$zip_code) {
		    $cart = Context::getContext()->cart;
		    if ($cart->id_address_delivery) {
		        $state = new State((integer) $address_delivery->id_state);
		        $data['city_name'] = $state->city;
		        $data['state_name'] = $state->name;
		        $address_delivery = new Address((integer) $cart->id_address_delivery);
		        $data['zip_code'] = $address_delivery->postcode;
		    }
		}
        $data['this_path_ssl'] = (Configuration::get('PS_SSL_ENABLED') ? 'https://' : 'http://').
                                 htmlspecialchars($_SERVER['HTTP_HOST'], ENT_COMPAT, 'UTF-8').__PS_BASE_URI__;
        $data['states'] = $this->getStateCodes();
        $this->context->smarty->assign($data);
        $this->setTemplate('cpafinder.tpl');
    }
    private function getStateCodes() {	
    	$statesCodes = array();
    	foreach ($this->getStates() as $key => $stateInfo) {
    		$statesCodes[] = array(
    			'code' => $stateInfo['iso_code'],
    			'name' => $stateInfo['name']
    		);
    	}
    	return $statesCodes;
    }
    private function getStates() {
		return array_filter(State::getStates('es', true), function ($state) {
        	return $state['id_country'] == Context::getContext()->country->id;
        });
    }
}
