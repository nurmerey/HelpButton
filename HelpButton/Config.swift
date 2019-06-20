//
//  Config.swift
//  HelpButton
//
//  Created by Nurmerey Shakhanova on 19/6/19.
//  Copyright © 2019 simulgirl. All rights reserved.
//

import Foundation

struct Config {
    // API Endpoint for Github gist
    static let gistPath = "https://api.github.com/gists"

    // Username for github, must equal token
    static let username = "nurmerey"

    // Github token (configure at https://github.com/settings/tokens)
    // Note that if you commit this to github, the token will be auto deleted
    static let token = ""

    // Device token, change to your favorite ble device UUID
    static let btDevice = "375DFD02-7B00-D7BC-ACA3-9CCFC2D7D415"

}

