//
//  Globals.swift
//  InvestingInMe
//
//  Created by Johnny Nguyen on 2018-02-08.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

/**
 A list of our constants of what we need. Helps us organize our files
*/
public enum Constants {
  /// Google Client's id
  public static let clientID = "475360847667-9ndpdrrtcck7bei646mcnjmloplv2rh6.apps.googleusercontent.com"
  /// ImageView Placeholder
  public static let placeholderImage = "https://via.placeholder.com/100?text=NO%20IMAGE"
  
  public static let duration: Int = 86400
  
  /// Image Placeholder lists
  public enum Icon {
    public static let person = "ic_person"
    public static let menu = "ic_menu"
    public static let backArrow = "ic_arrow_back"
    public static let delete = "ic_delete_forever"
    public static let feature = "ic_stars_18pt"
    public static let moreHorizontal = "ic_more_horiz"
    public static let search = "ic_search"
    public static let sort = "ic_sort"
    public static let addCircle = "ic_add_circle"
    public static let done = "ic_done"
    public static let close = "ic_close"
    public static let modeEdit = "ic_mode_edit"
    public static let assignmentLate = "ic_assignment_late"
    public static let mailbox = "ic_markunread_mailbox"
    public static let send = "ic_send"
  }
  
  /// Gets us our API URL
  #if STAGING
    public static let API_URL = "https://staging.investingin.me/api/v1"
    public static let ONESIGNAL_APP_ID = "11339727-8f38-4474-b2b5-b3e9c0079c70"
    public static let PRIVACY_POLICY_URL = "https://staging.investingin.me/investinginmePrivacyPolicy.pdf"
    public static let TERMS_OF_SERVICE_URL = "https://staging.investingin.me/investinginmeTermsandConditions.pdf"
  #elseif PRODUCTION
    public static let API_URL = "https://investingin.me/api/v1"
    public static let ONESIGNAL_APP_ID = "f901df8c-a61c-4e17-87e6-cc0c6887ab11"
    public static let PRIVACY_POLICY_URL = "https://investingin.me/investinginmePrivacyPolicy.pdf"
    public static let TERMS_OF_SERVICE_URL = "https://investingin.me/investinginmeTermsandConditions.pdf"
  #endif
}
