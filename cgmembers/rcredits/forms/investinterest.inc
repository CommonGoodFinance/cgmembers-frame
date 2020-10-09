<?php
namespace CG\Web;
use CG\Web as w;
use CG as r;
use CG\Backend as be;
use CG\Util as u;
use CG\Db as db;

/**
 * Do whatever.
 */
function formInvestInterest($form, &$sta, $args = '') {
  $mya = w\eLinkAcct($sta, $args, 'any');
  
  u\setDft($source2, nni($_COOKIE, 'ad'));
  $source2 = hidFld($source2);

  $title = t('Investment Clubs');
  $subtext = t('<p>Do you have savings? Do you wish you could invest them in locally-owned companies and projects that advance the well being of everyone in your community &mdash; instead of in huge corporations that have no accountability and don\’t add anything to the local economy?</p><p><b>Investment Clubs</b> are a way to fund great local projects &mdash; especially ones that have difficulty getting other funding &mdash; without the costly burdens of regulation and reporting.</p><p><b>The basic idea</b> is that we each put $100 or more in the pool, then we get together quarterly (online or in person) to make investment decisions.<p><p><b class="loud">Complete this form to be notified</b> when a club is forming in your area.', '_a', atag('/invest/interest'));

  $comments = areaFld(t('Comments:'), [t('(optional)')]);
  $submit = t('Keep me in the loop!');
  
  if ($mya) {
    $fullName = $phone = $email = $zip = $source = NULL;
  } else {
    $code = r\acct(1)->iCardCode(IBY_SELF); // inviter is admin for now; invitation() will set $iCode=IBY_SELF
    $source = sourceFld();
    $phone = phoneFld(REQ . t('Phone:'), [t('Your phone number')]);
    $zip = zipFld();
    $fullName = textFld(REQ . t('Name:'), [t('Your full name')]);
    $email = emailFld(REQ . t('Email:'), [t('Email')]);
  }
  
  return cgform(compact(ray('title subtext fullName phone email zip source comments submit')));
}

function formInvestInterest_validate($form, &$sta) {
  if ($mya = w\eLinkAcct($sta)) return; // nothing to check for members
  
  extract(just('fullName phone email zip', $sta['input']));

  if ($err = u\badName($fullName)) return say($err, ['field' => 'fullName'], 'fullName');
  $fullName = u\normalizeCase($fullName);
  
  if ($err = u\badPhone($phone)) return say($err, 'phone');
  if (!emailOkay($email, FALSE, nn($myid) ? r\acct($myid) : '')) return;
  if ($err = u\badZip($zip)) return say($err, 'zip');
  
  u\preray(compact(ray('fullName phone email zip')), $sta['input']);
}

function formInvestInterest_submit($form, &$sta) {
  $mya = w\eLinkAcct($sta); 

  $a = $mya ? $mya->agentA : NULL;
  $dbFields = 'fullName email flags phone zip notes source';
  extract(just('comments source2 ' . $dbFields, $sta['input'], NULL));

  $notes = $comments ? (r\stampNote($comments) . ($a ? $a->notes : '')) : '';
  $flags = ($a ? $a->flags : u\bit(B_NONUDGE)) | u\bit(B_ICLUBQ);
  if ($a) $fullName = $a->fullName;
  r\tellAdmin(t('Interest in iClub'), compact(ray($dbFields)) + ($a ? [] : ray('NEW!', '1')));
  $msg = t('<p>Your interest has been noted! We\'ll keep you in the loop.</p>');

  if ($a) {
    $a->update('flags notes', $flags, $notes);
  } else {
    $acctType = hidFld(CO_PERSONAL);
    u\setDft($source, '');
    if ($source2) $source = trim(mb_strtoupper($source2) . "-$source");
    list ($city, $state, $latitude, $longitude) = r\zipCity($zip);
    $info = []; foreach (ray($dbFields) as $k) if (isset($$k)) $info[$k] = $$k;
    if (!$a = new r\Acct($info)) return softErr(t('cannot create account'));
//    r\setAcct($a->id, $sta);
    $a->stepDone('signup');
    $msg .= t('<p>Meanwhile, if you\'re not yet in %PROJECT, <%a>check it out</a>!</p>', '_a', atag(PROMO_URL));
  }
  say($msg);
  return go('empty');
}