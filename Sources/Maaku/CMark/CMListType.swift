//
//  CMListType.swift
//  Maaku
//
//  Created by Kris Baker on 12/20/17.
//  Copyright © 2017 Kristopher Baker. All rights reserved.
//

import Foundation
import cmark_gfm

/// Represents a cmark list type.
public enum CMListType: UInt32, Sendable {

    /// The none list type.
    case none

    /// The unordered list type.
    case unordered

    /// The ordered list type.
    case ordered
}
