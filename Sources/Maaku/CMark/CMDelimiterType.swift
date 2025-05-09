//
//  CMDelimiterType.swift
//  Maaku
//
//  Created by Kris Baker on 12/20/17.
//  Copyright © 2017 Kristopher Baker. All rights reserved.
//

import Foundation
import cmark_gfm

/// Represents a cmark delimiter type.
public enum CMDelimiterType: UInt32, Sendable {

    /// The none delimiter type.
    case none

    /// The period delimiter type.
    case period

    /// The paren delimiter type.
    case paren
}
