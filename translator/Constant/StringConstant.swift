//
//  StringConstant.swift
//
//  Created by Michael Carolius on 13/04/18.
//  Copyright © 2018 MC. All rights reserved.
//

import Foundation

//MARK : REGULAR EXPRESSION

public let STRING_REGULAREXPRESSION_PERSONNAME: String = "^[A-Za-z\\s]{1,}[\\.]{0,1}[A-Za-z\\s]{0,}$"
public let STRING_REGULAREXPRESSION_ALPHABET: String = "^[a-zA-Z]+$"
public let STRING_REGULAREXPRESSION_NUMERIC: String = "^[0-9]*$"
public let STRING_REGULAREXPRESSION_ALPHABETNUMERIC: String = "^[a-zA-Z0-9]+$"
public let STRING_REGULAREXPRESSION_EMAIL: String = "^[\\w!#$%&'*+\\-/=?\\^_`{|}~]+" +
"(\\" +
".[\\w!#$%&'*+\\-/=?\\^_`{|}~]+)*@(" +
"(" + "([\\-\\w]+\\.)+[a-zA-Z]{2,4})|(([0-9]{1,3}\\.){3}[0-9]{1,3}))$";
public let STRING_REGULAREXPRESSION_MOBILEPHONE: String = "\\+" +
"(9[976]\\d|8[987530]\\d|6[987]\\d|5[90]\\d|42\\d|3[875]\\d|2" +
"[98654321]\\d|9[8543210]|8[6421]|6[6543210]|5[87654321]|4[987654310]|3[9643210" +
"]|2[70]|7|1)\\d{1,14}$"

public let BUNDLEID: String = Bundle.main.bundleIdentifier!

//MARK : LANGUAGE CULTURE

public let STRING_CULTURE_INDONESIAN: String = "id-ID"
public let STRING_CULTURE_ENGLISH: String = "en-US"


//MARK : KEY

public let STRING_KEY: String = "LZQ1Yit8"
public let URL_REQUESTAPI_TRANSLATE: String = "http://47.75.13.70/translate/translate.php"
public let URL_REQUESTAPI_ADS: String = "http://47.75.13.70/advertising/ReqAppAd.php"
public let URL_REQUESTAPI_APPPURCHASEADS: String = "http://47.75.13.70/user_order/AppUserOrder.php"


//MARK : IN-APP PRODUCT
public let INAPP_PRODUCT = "com.tms.ltranslate1"



//Request
public let STRING_SERVER_KEY_REQUEST_PRIVATE: String = "2F2B9A548B65E9D6"
public let STRING_SERVER_KEY_REQUEST_PUBLIC: String = "C3RHC2l1BNBHBG1lCMFO"
//Response
public let STRING_SERVER_KEY_RESPONSE_PRIVATE: String = "069D1D5B28385806"
public let STRING_SERVER_KEY_RESPONSE_PUBLIC: String = "C3VUZGFRZWXHCGE"


