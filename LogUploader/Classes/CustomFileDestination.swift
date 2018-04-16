//
//  CustomFileDestination.swift
//  LogUploader
//
//  Created by Yilmaz, Ihsan on 16.04.18.
//

import Foundation
import XCGLogger

/// The class which handles file open/close operations and
/// log uploaders can AND wil upload. Subclass this and override
/// write(:_) method to create your own file formats.
open class CustomFileDestination: StructDestination {
    /// Logger that owns the destination object
    open override var owner: XCGLogger? {
        didSet {
            if owner != nil {
                openFile()
            }
            else {
                closeFile()
            }
        }
    }
    
    /// FileURL of the file to log to
    open var fileURL: URL {
        didSet {
            openFile()
        }
    }
    
    public var defaultFileExtension: String {
        return self.fileURL.pathExtension
    }
    
    /// File handle for the log file
    open var logFileHandle: FileHandle? = nil
    open var uploaderConfiguration: LogUploaderConfiguration?
    
    public init(owner: XCGLogger? = nil, fileURL: URL, identifier: String = "", uploaderConf: LogUploaderConfiguration?) {
        
        self.fileURL = fileURL
        
        self.uploaderConfiguration = uploaderConf
        super.init(owner: owner, identifier: identifier)
        
        if owner != nil {
            openFile()
        }
    }
    
    deinit {
        // close file stream if open
        closeFile()
    }
    
    open func openFile() {
        guard let owner = owner else {
            return
        }
        
        if logFileHandle != nil {
            closeFile()
        }
        
        let fileManager = FileManager.default
        let fileExists = fileManager.fileExists(atPath: fileURL.path)
        
        if !fileExists {
            fileManager.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
        }
        
        do {
            logFileHandle = try FileHandle(forWritingTo: fileURL)
        } catch let error {
            owner.error("Unable to open file at path \(fileURL.path). Reason: \(error)")
        }
    }
    
    /// Close the log file.
    ///
    open func closeFile() {
        logFileHandle?.synchronizeFile()
        logFileHandle?.closeFile()
        logFileHandle = nil
    }
    
    /// Force any buffered data to be written to the file.
    ///
    /// - parameter closure: An optional closure to execute after the file has been flushed.
    ///
    open func flush(closure: (() -> Void)? = nil) {
        if let logQueue = logQueue {
            logQueue.async {
                self.logFileHandle?.synchronizeFile()
                closure?()
            }
        }
        else {
            logFileHandle?.synchronizeFile()
            closure?()
        }
    }
    
    open override func output(log: Log) {
        // Override this function and write details to the file which is already open
        precondition(false, "Must override this")
    }
    
}
