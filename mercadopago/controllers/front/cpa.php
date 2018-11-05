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
 *  @author    Guisardo
 *  @license   http://opensource.org/licenses/osl-3.0.php  Open Software License (OSL 3.0)
 *  International Registered Trademark & Property of MercadoPago
 */
if (!function_exists('http_build_query')) { 
    function http_build_query($data, $prefix='', $sep='', $key='') { 
        $ret = array(); 
        foreach ((array)$data as $k => $v) { 
            if (is_int($k) && $prefix != null) { 
                $k = rawurlencode($prefix . $k); 
            } 
            if ((!empty($key)) || ($key === 0))  $k = $key.'['.rawurlencode($k).']'; 
            if (is_array($v) || is_object($v)) { 
                array_push($ret, http_build_query($v, '', $sep, $k)); 
            } else { 
                array_push($ret, $k.'='.rawurlencode($v)); 
            } 
        } 
        if (empty($sep)) $sep = ini_get('arg_separator.output'); 
        return implode($sep, $ret); 
    }// http_build_query 
}//if

include_once dirname(__FILE__) . '/../../mercadopago.php';
class MercadoPagoCpaModuleFrontController extends ModuleFrontController
{
	public static $COUNTRY_ID = 44;
    public function init()
    {
        parent::init();

        $this->ajax = true;
    }

    public function displayAjax()
    {
	    $expiration = 30 * 60;

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
	    header('Cache-Control: public, max-age='.$expiration);
   	
        $jsonResponse = array();

        $allowed_host = 'tienda.ropitas.com.ar';
        $host = parse_url($_SERVER['HTTP_REFERER'], PHP_URL_HOST);
        if(substr($host, 0 - strlen($allowed_host)) == $allowed_host) {
            if (isset($_GET['state'])) {
                $jsonResponse = $this->getPostalCode($_GET['keyword'], $_GET['state']);
            } else {
                $jsonResponse = $this->getStateCodes();
            }
        }
        header('content-type: text/json');
        echo json_encode($jsonResponse);
    }

    private function getPostalCode($keyword=false, $stateCode=false)
    {
        error_reporting(E_ALL); ini_set('display_errors', '1'); 
        $filteredCodes = array();
        if ($stateCode) {
            $validCode = false;
            $validStateCodes = $this->getStateCodes();
            foreach ($validStateCodes as $validStateCode) {
                if ($stateCode === $validStateCode['code']) {
                    $validCode = $validStateCode['code'];
                    break;
                }
            }
            if ($validCode && $keyword) {
                $keyword = Db::getInstance()->escape($keyword);

                $containsNumbers = preg_match('/\\d/', $keyword) > 0;
                $query = '
select distinct zip_code,
concat(
';
                if ($containsNumbers) {
                    $query .= '
case when s5 != \'\' then
concat(
s1,
\' \',
s5, \' \',
addr_num.addr_snum, \', \'
)
else
\'\'
end,
';
                }

                $query .= 'p3,
case when p3 != p4 then
concat(\', \', p4)
else
\'\'
end
) as zip_place,
case when p3 != p4 then
p4
else
p3
end as zip_parent
 from
(
select *
 from psks_cpa_search_texts
where state_code = \''.$validCode.'\'
and match(p1,p2,p3,p4,p5';

                if ($containsNumbers) {
                    $query .= '
,s2,s3,s4,s5,s6,s1
';
                }

                    $query .= '
) against(\''.$keyword.'\')
) as addr_name
';

                if ($containsNumbers) {
                    $query .= '
right join
(
select *
from psks_cpa_search_numbers
where match(addr_snum) against (\''.$keyword.'\')
) as addr_num on addr_num.addr_num between addr_name.desde and addr_name.hasta
';
                }
//                $query .= '
//LIMIT 1, 20
//';
//echo $query;
                $filteredDBCodes = Db::getInstance(_PS_USE_SQL_SLAVE_)->executeS($query);
                if ($filteredDBCodes) {
                    foreach ($filteredDBCodes as $postalCode) {
                        $filteredCodes[] = array(
                            'code' => $postalCode['zip_code'],
                            'place' =>  $postalCode['zip_place'],
                            'parent' => $postalCode['zip_parent']
                        );
                        //if (count($filteredCodes) >= 20) {
                        //    break;
                        //}
                    }
                }
            }
        }
        return $filteredCodes;
    }

    private function getStateCodes() {	
    	$statesCodes = array();
    	foreach ($this->getStates() as $key => $stateInfo) {
    		$statesCodes[] = array(
    			'code' => $stateInfo['iso_code']
    		);
    	}
    	return $statesCodes;
    }
    private function getStates() {
		return array_filter(State::getStates('es', true), function ($state) {
        	return $state['id_country'] == MercadoPagoCpaModuleFrontController::$COUNTRY_ID;
        });
    }

}
