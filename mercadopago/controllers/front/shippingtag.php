<?php
include_once dirname(__FILE__).'/../../mercadopago.php';
class MercadoPagoShippingTagModuleFrontController extends ModuleFrontController
{
  public function init()
  {
    parent::init();

    $this->ajax = true;
  }

  public function displayAjax()
  {
  	$tag_shipment = false;
    if ($id_order = Tools::getValue('id_order')) {
        $order = new Order((int)$id_order);
        $mercadopago = $this->module;


        $id_order_carrier = $order->getIdOrderCarrier();

        $order_carrier = new OrderCarrier($id_order_carrier);
        $id_mercadoenvios_service_code = $mercadopago->isMercadoEnvios($order_carrier->id_carrier);

        if ($id_mercadoenvios_service_code > 0 || $order->payment == 'MercadoLibre') {
            $order_payments = $order->getOrderPayments();
            foreach ($order_payments as $order_payment) {
                $result = $mercadopago->mercadopago->getPaymentStandard(trim(explode(' / ', $order_payment->transaction_id)[0]));
                if ($result['status'] == '200') {
                    $payment_info = $result['response'];
                    if (isset($payment_info['collection'])) {
                        if ($payment_info['collection']['merchant_order_id'] == null) {
                            $merchant_order_id = $payment_info['collection']['order_id'];
                            $access_token = $mercadopago->mercadopago->getAccessToken();
                            $result_merchant = MPRestCli::getShipment('/orders/' . $merchant_order_id . '?access_token=' . $access_token);

                            $tag_shipment = $mercadopago->mercadopago->getTagShipment(
                                $result_merchant['response']['shipping']['id']
                            );

                        } else {
                            $merchant_order_id = $payment_info['collection']['merchant_order_id'];
                            $result_merchant = $mercadopago->mercadopago->getMerchantOrder($merchant_order_id);

                            $return_tracking = $mercadopago->setTracking(
                                $order,
                                $result_merchant['response']['shipments'],
                                $order_carrier->tracking_number == ''
                            );

                            $tag_shipment = $mercadopago->mercadopago->getTagShipment(
                                $return_tracking['shipment_id']
                            );

                        }

                        break;
                    }
                }
            }
        }
    }

    if ($tag_shipment) {
    	Tools::redirect($tag_shipment);
    } else {
    	echo $mercadopago->l('Etiqueta no encontrada');
    }
  }


}