<?php
namespace CG\Web;
use CG\Web as w;
use CG as r;
use CG\Backend as be;
use CG\Util as u;
use CG\Db as db;

const SIMPLE_CO_LIST = '%simple-list%';

/**
 * Return a formatted list of member companies
 * Call:
 *   coList(which, region) --  categorized
 *   coList()              --  no categories, each company appears just once, in alphabetical order
 * @param string $which: word search for business name or industry
 * @param mixed $region: community (the default), zip (maybe partial), state abbrev, or country (maybe partial)
 */
function coList($which = SIMPLE_CO_LIST, $region = '') {
  global $mya;

  $stateCrit = '(s.abbreviation=:region OR c.name=:region)';
  
  list ($region, $crit) =
    !$region ? [($mya and $mya->id != 1) ? $mya->community : r\serverUid(), 'u.uid=:region'] // center on user or region
  : (preg_match('/[A-Z]{3}/', $region) ? [$region . '.', 'u.name=:region'] // eg NEW or MIW
  : (preg_match('/[0-9]{1,5}/', $region) ? [$region . '%', 'u.zip LIKE :region'] // eg 013 or 01002
  : [$region, $stateCrit] // eg MA or Germany
  ));

  $table = 'users u LEFT JOIN r_states s ON s.id=u.state LEFT JOIN r_countries c ON c.id=u.country';
  $res = db\get('latitude AS lat,longitude AS lon', $table, $crit, compact('region'));
  if (!$res) return participatingCompanies(''); // nothing in that area
  
  extract($res); // get lat,lon
  $regionCrit = tr('%DISTANCE_BETWEEN<%NEIGHBOR_MAX OR ') . $stateCrit;

  if ($which == SIMPLE_CO_LIST) {
    list ($fields, $order) = ['u.uid', 'u.fullName'];
    $which = '';
  } else {
    $fields = 'u.uid, a.base, a.ancestor as selIid, a.ancestorIndustry as industry, abbreviation AS st';
    $order = 'industry, u.fullName';
    $which = u\ignoreSuffix($which, 'ants ant ian es ers ing er or ion s');
    $which = str_replace(' ', '%', \db_like(" $which ")); // allow abbreviations of each word
  }

  $sql = <<<EOF
    SELECT DISTINCT $fields
    FROM users u 
    LEFT JOIN r_user_industries ui ON ui.uid=u.uid
    LEFT JOIN ancestors a on a.base=ui.iid
    LEFT JOIN r_states s ON s.id=u.state
    LEFT JOIN r_countries c ON c.id=u.country
    WHERE :IS_CO AND u.uid>:CANONIC_ACCTS AND :IS_OK AND ($regionCrit) AND (u.fullName LIKE :which OR a.baseIndustry LIKE :which)
    ORDER BY $order
EOF;

  $result = db\q($sql, compact(ray('region which lat lon')));
  $rows = [];
  foreach ($result as $row) {
    if (!nn($xrow) or $xrow->uid != $row->uid) $rows[] = $row; // eliminate dups within class (DISTINCT fails)
    $xrow = $row;
  }
  return participatingCompanies((array) $rows);
}

/**
 * Return a list of participating companies for the given community.
 * @param assoc $rows: information to display (either on members site or on promo site)
 */
function participatingCompanies($rows) {
  $model = <<< X
<div class="row">
  <div class="cmpy-img"><img src="%img" alt="profile picture" /></div>
  <div class="cmpy-name-does">
    <div class="cmpy-name">%name</div>
    <div class="cmpy-does">%desc</div>
  </div>
  <div class="cmpy-contact">%contact</div>
  <div class="cmpy-buttons">%buttons</div>
</div>
X;
  $iModel = '<div class="cmpy-ind-wrapper"><div class="cmpy-ind">%industry</div>';

  if (!$rows) return t('No companies there yet. Invite them!');
  $res = '';
  $_newClass = 'class="company-listing"';
  $NEW = t(' <small %newClass> NEW!</small>', compact('_newClass'));

  $lastSelIid = -1;  // negative record ids are, we hope, unlikely
  $firstTime = TRUE;
  foreach ($rows as $rowObject) {
    $row = (array)$rowObject;
    $uid = $row['uid'];
    $a = r\acct($uid);
    if (!($a->coCan(CO_PRIVATE))) {
      $industry = $row['industry'] ?: tr('Unclassified');
      $selIid = $row['selIid'] ?: -2;
      if ($selIid != $lastSelIid) {
        if (! $firstTime) {
          $res .= '</div>';
        }
        $firstTime = false;
        $res .= tr($iModel, 'industry', $industry) . "\n";
        $lastSelIid = $selIid;
      }
      $website = $a->website ? "http://$a->website" : "/member/$a->name";
      $name = w\lnk($website, $a->bestName);
      $buttons = $a->coType == CO_NONPROFIT 
      ? buttonHtml($a, t('Donate'), 'donate', 'success')
      : buttonHtml($a, t('Buy<br>Credit'), 'credit', 'primary');
/*      $buttons = buttonHtml($a, t('Buy Credit'), 'credit', 'danger')
      . buttonHtml($a, t('Buy Gift'), 'gift', 'primary')
      . buttonHtml($a, $a->coType == CO_NONPROFIT ? t('Donate') : t('Pay'), 'other', 'success');
      */
      $contact = "$a->city, $a->st<br>$a->phoneDash";
      $new = ($a->activated > REQUEST_TIME - 9 * WEEK_SECS) ? $NEW : '';
      $img = $a->photoSrc(TRUE) ?: 'images/no-photo-available.jpg';
      $res .= tr($model, '_name _buttons desc _contact img', "$name$new", $buttons, strtolower($a->shortDesc)
      , $contact, $img) . "\n";
    }
  }
  if (! $firstTime) $res .= '</div>';
  return $res;
}

function buttonHtml($a, $text, $for, $style) {
  $class = "cgpay-$for";
  return w\btn("/pay-with-cg/company=$a->mainQid&for=$for", $text, $style, '', compact('class') + away());
}