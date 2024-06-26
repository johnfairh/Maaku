//
//  CMNode+ASTManipulation.swift
//  Maaku
//
//  Created by Tim Learmont on 5/29/19.
//  Copyright © 2019 Kristopher Baker. All rights reserved.
//

import Foundation
import cmark_gfm
import cmark_gfm_extensions

/// Extension for manipulating ndoe values and the Abstract Syntax Tree
public extension CMNode {
    enum ASTError: Error {
        case canNotSetValue
        case canNotInsert
        case documentMismatch
    }

    func setStringValue(_ newValue: String) throws {
        // cmark_node_set_literal copies the string
        if cmark_node_set_literal(cmarkNode, newValue) != 1 {
            throw ASTError.canNotSetValue
        }
    }

    func setHeadingLevel(_ newValue: Int32) throws {
        if cmark_node_set_heading_level(cmarkNode, newValue) != 1 {
            throw ASTError.canNotSetValue
        }
    }

    func setFencedCodeInfo(_ newValue: String) throws {
        // cmark_node_set_fence_info copies the string
        if cmark_node_set_fence_info(cmarkNode, newValue) != 1 {
            throw ASTError.canNotSetValue
        }
    }

    func setCustomOnEnter(_ newValue: String) throws {
        // cmark_node_set_on_enter copies the string
        if cmark_node_set_on_enter(cmarkNode, newValue) != 1 {
            throw ASTError.canNotSetValue
        }
    }

    func setCustomOnExit(_ newValue: String) throws {
        // cmark_node_set_on_exit copies the string
        if cmark_node_set_on_exit(cmarkNode, newValue) != 1 {
            throw ASTError.canNotSetValue
        }
    }

    func setListType(_ newValue: CMListType) throws {
        if cmark_node_set_list_type(cmarkNode, cmark_list_type(newValue.rawValue)) != 1 {
            throw ASTError.canNotSetValue
        }
    }

    func setListDelimiterType(_ newValue: CMDelimiterType) throws {
        if cmark_node_set_list_delim(cmarkNode, cmark_delim_type(newValue.rawValue)) != 1 {
            throw ASTError.canNotSetValue
        }
    }

    func setListStartingNumber(_ newValue: Int32) throws {
        if cmark_node_set_list_start(cmarkNode, newValue) != 1 {
            throw ASTError.canNotSetValue
        }
    }

    func setListTight(_ newValue: Bool) throws {
        if cmark_node_set_list_tight(cmarkNode, newValue ? 1 : 0) != 1 {
            throw ASTError.canNotSetValue
        }
    }

    func setLinkDestination(_ newValue: String) throws {
        // cmark_node_set_url copies the string
        if cmark_node_set_url(cmarkNode, newValue) != 1 {
            throw ASTError.canNotSetValue
        }
    }

    func setLinkURL(_ newValue: URL) throws {
        try setLinkDestination(newValue.absoluteString)
    }

    func setLinkTitle(_ newValue: String) throws {
        // cmark_node_set_title copies the string
        if cmark_node_set_title(cmarkNode, newValue) != 1 {
            throw ASTError.canNotSetValue
        }
    }

    func setLiteral(_ newValue: String) throws {
        // cmark_node_set_literal copies the string
        if cmark_node_set_literal(cmarkNode, newValue) != 1 {
            throw ASTError.canNotSetValue
        }
    }

    func setTaskCompleted(_ newValue: Bool) throws {
        if cmark_gfm_extensions_set_tasklist_item_checked(cmarkNode, newValue) != 1 {
            throw ASTError.canNotSetValue
        }
    }

    func setUserData<T: AnyObject>(unretained: T) {
        let unmanaged = Unmanaged.passUnretained(unretained)
        cmark_node_set_user_data(cmarkNode, unmanaged.toOpaque())
    }

    func setUserData<T: AnyObject>(retained: T) {
        let unmanaged = Unmanaged.passRetained(retained)
        cmark_node_set_user_data(cmarkNode, unmanaged.toOpaque())
    }

    func getUserDataUnretained<T: AnyObject>(kind: T.Type) -> T? {
        guard let opaque = cmark_node_get_user_data(cmarkNode) else {
            return nil
        }
        let unmanaged = Unmanaged<T>.fromOpaque(opaque)
        return unmanaged.takeUnretainedValue()
    }

    func getUserDataRetained<T: AnyObject>(kind: T.Type) -> T? {
        guard let opaque = cmark_node_get_user_data(cmarkNode) else {
            return nil
        }
        let unmanaged = Unmanaged<T>.fromOpaque(opaque)
        return unmanaged.takeRetainedValue()
    }

    /// Inserts this node into the AST before the given node
    ///
    /// - Parameters:
    ///     - beforeNode: the node that this node will be inserted before.
    ///
    func insertIntoTree(beforeNode: CMNode) throws {
        // There should only be one node at the top level (the Document node),
        // so if node we're trying to add before is the document node, don't allow.
        // We also don't allow mutliple document nodes, so that's an error, too
        guard (beforeNode.type != .document) && (self.type != .document) else {
            throw ASTError.canNotInsert
        }
        referencedMemoryOwner = beforeNode.referencedMemoryOwner ?? beforeNode
        if cmark_node_insert_before(beforeNode.cmarkNode, self.cmarkNode) != 1 {
            throw ASTError.canNotInsert
        }
    }

    /// Remove this node along with its children from the AST
    func unlink() {
        referencedMemoryOwner = nil
        cmark_node_unlink(cmarkNode)
    }

    /// Inserts this node into the AST after the given node
    ///
    /// - Paremeters:
    ///     - afterNode: the node that this node will be inserted after.
    func insertIntoTree(afterNode: CMNode) throws {
        // There should only be one node at the top level (the Document node),
        // so if node we're trying to add before is the document node, don't allow.
        // We also don't allow mutliple document nodes, so that's an error, too
        guard (afterNode.type != .document) && (self.type != .document) else {
            throw ASTError.canNotInsert
        }
        referencedMemoryOwner = afterNode.referencedMemoryOwner ?? afterNode
        if cmark_node_insert_after(afterNode.cmarkNode, self.cmarkNode) != 1 {
            throw ASTError.canNotInsert
        }
    }

    /// Inserts this node into the AST as the first child of the given node.
    ///
    /// All previous children of the given node will come after this node.
    ///
    /// - Paremeters:
    ///     - asFirstChildOf: the node that this node will be inserted after.
    func insertIntoTree(asFirstChildOf parent: CMNode) throws {
        // We don't allow mutliple document nodes, so if the node we're trying to insert is a doc node,
        // that's an error.
        guard self.type != .document else {
            throw ASTError.canNotInsert
        }
        referencedMemoryOwner = parent.referencedMemoryOwner ?? parent
        if cmark_node_prepend_child(parent.cmarkNode, self.cmarkNode) != 1 {
            throw ASTError.canNotInsert
        }
    }

    /// Inserts this node into the AST as the last child of the given node.
    ///
    /// All previous children of the given node will come before this node
    ///
    /// - Paremeters:
    ///     - afterNode: the node that this node will be inserted after.
    func insertIntoTree(asLastChildOf parent: CMNode) throws {
        // We don't allow mutliple document nodes, so if the node we're trying to insert is a doc node,
        // that's an error.
        guard self.type != .document else {
            throw ASTError.canNotInsert
        }
        referencedMemoryOwner = parent.referencedMemoryOwner ?? parent
        if cmark_node_append_child(parent.cmarkNode, self.cmarkNode) != 1 {
            throw ASTError.canNotInsert
        }
    }

    /// Create a new node and add as the last child of the given parent
    ///
    /// - Parameters:
    ///     - type: the type of the node to be created
    ///     - extension: the extension for this node (or nil if this type is a base type).
    ///     - parent: the node that will be the parent of the newly created node.
    ///         This is only needed because our current memory management scheme requires
    ///         all nodes to be owned by a parent node. Any nodes without parents might
    ///         end up having their data freed incorrectly.
    convenience init?(type: CMNodeType, `extension`: CMExtensionOption? = nil, parent: CMNode? = nil) {
        let node: UnsafeMutablePointer<cmark_node>
        if `extension` != nil {
           node = cmark_node_new_with_ext(cmark_node_type(type.rawValue), `extension`!.syntaxExtension)
        } else {
            node = cmark_node_new(cmark_node_type(type.rawValue))
        }
        self.init(cmarkNode: node, memoryOwner: parent)
        if let parent = parent {
            do {
                try insertIntoTree(asLastChildOf: parent)
            } catch {
                return nil
            }
        }
    }

    /// Create a new node not in any document tree
    ///
    /// - Parameters:
    ///     - type: the type of the node to be created
    ///     - extension: the extension for this node (or nil if this type is a base type).
    convenience init(type: CMNodeType, `extension`: CMExtensionOption? = nil) {
        let node: UnsafeMutablePointer<cmark_node>
        if `extension` != nil {
           node = cmark_node_new_with_ext(cmark_node_type(type.rawValue), `extension`!.syntaxExtension)
        } else {
            node = cmark_node_new(cmark_node_type(type.rawValue))
        }
        self.init(cmarkNode: node, memoryOwner: nil)
    }
}
