<?php
$expiration = 6000;

$headers = apache_request_headers();
header("Expires: " . gmdate('D, d M Y H:i:s \G\M\T', time() + $expiration));
header("Last-Modified: ".gmdate("D, d M Y H:i:s", time())." GMT"); 

if(isset($headers['If-Modified-Since'])) {
  if(@strtotime($headers['If-Modified-Since']) > (time() - $expiration))
  {
    header('Not Modified',true,304);
    exit;
  }
}
header('Cache-Control: private, max-age='.$expiration);


if (!defined('_PS_ROOT_DIR_')) {
    define('_PS_ROOT_DIR_', dirname(__FILE__).'/../../');
}

require_once(_PS_ROOT_DIR_.'/config/config.inc.php');
require_once(_PS_ROOT_DIR_.'/init.php');

include dirname(__FILE__).'/includes/MPApi.php';

$mp = new MPApi(
            Configuration::get('MERCADOPAGO_CLIENT_ID'),
            Configuration::get('MERCADOPAGO_CLIENT_SECRET')
        );

$zip_code = $_GET['z'];
$cart = Context::getContext()->cart;
if (Context::getContext()->customer->logged && !$zip_code) {
    if ($cart->id_address_delivery) {
        $address_delivery = new Address((integer) $cart->id_address_delivery);
        $zip_code = $address_delivery->postcode;
    }
}

header('Content-Type: application/json');
if ($zip_code) {

    if (in_array($zip_code, array(
        '9410',
        '9411',
        '9420',
        '9421'
    ))) {
        echo '{
    "custom_message": {
        "display_mode": null,
        "reason": ""
    },
    "options": [
        {
            "tags": [],
            "id": 386467783,
            "estimated_delivery_time": {
                "unit": "hour",
                "shipping": 24,
                "schedule": null,
                "pay_before": null,
                "time_frame": {
                    "to": null,
                    "from": null
                },
                "offset": {
                    "shipping": 24,
                    "date": "2018-01-17T00:00:00.000-03:00"
                },
                "date": "2018-01-16T00:00:00.000-03:00",
                "type": "known_frame",
                "handling": 24
            },
            "list_cost": "385 aprox.",
            "currency_id": "ARS",
            "shipping_option_type": "address",
            "shipping_method_type": "standard",
            "name": "Normal a domicilio",
            "display": "recommended",
            "cost": "385 aprox.",
            "discount": {
                "promoted_amount": 0,
                "rate": 0,
                "type": "none"
            },
            "shipping_method_id": 73328
        }
    ],
    "destination": {
        "zip_code": "'.$zip_code.'",
        "extended_attributes": null,
        "state": {
            "id": "AR-T",
            "name": "Tierra del Fuego"
        },
        "country": {
            "id": "AR",
            "name": "Argentina"
        },
        "city": {
            "id": null,
            "name": null
        }
    }
}';
    } else {
        $paramsMP = array(
            "dimensions" => "7x28x21,1",
            "zip_code" => $zip_code,
            "item_price"=> "100.58",
            'free_method' => '', // optional
            "default_shipping_method" => 501045
        );

        $response = $mp->calculateEnvios($paramsMP);

        $shipping_options = json_encode($response['response'], JSON_PRETTY_PRINT);

        $shipping_options = $response['response'];

        $sql = "
select id_zone from "._DB_PREFIX_."cpa_cp_1974_shipping_zone
where cod_postal = ".$zip_code."
        ";
        $id_zone = Db::getInstance()->getValue($sql);
        $shipping_options['id_zone'] = $id_zone;

        if ($id_zone) {
            $result = Carrier::getCarriers((int)Configuration::get('PS_LANG_DEFAULT'), true, false, (int)$id_zone);

            foreach ($result as $carrier) {
                if (strpos($carrier['name'], "MercadoEnv", 0) === false) {
                    $carrier_options = (array) $carrier;
                    $carrier_obj = new Carrier((int)$carrier['id_carrier'])
                    $carrier_options['cost'] = (($carrier['shipping_method'] == Carrier::SHIPPING_METHOD_FREE) ? 0 : $carrier_obj->getDeliveryPriceByWeight(1, (int)$id_zone));
                    $carrier_options['img'] = file_exists(_PS_SHIP_IMG_DIR_.(int)$carrier['id_carrier'].'.jpg') ? _THEME_SHIP_DIR_.(int)$carrier['id_carrier'].'.jpg' : '';

                    $shipping_options['options'][] = $carrier_options;
                }
            }

        }

        echo json_encode($shipping_options, JSON_PRETTY_PRINT);
    }
} else {
    echo '{}';
}
