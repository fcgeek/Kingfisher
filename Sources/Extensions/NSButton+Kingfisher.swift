//
//  NSButton+Kingfisher.swift
//  Kingfisher
//
//  Created by Jie Zhang on 14/04/2016.
//
//  Copyright (c) 2018 Wei Wang <onevcat@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


import AppKit

extension KingfisherClass where Base: NSButton {
    
    /// Sets an image to the button with a requested resource.
    ///
    /// - Parameters:
    ///   - resource: The `Resource` object contains information about the resource.
    ///   - placeholder: A placeholder to show while retrieving the image from the given `resource`.
    ///   - options: An options set to define image setting behaviors. See `KingfisherOptionsInfo` for more.
    ///   - progressBlock: Called when the image downloading progress gets updated. If the response does not contain an
    ///                    `expectedContentLength`, this block will not be called.
    ///   - completionHandler: Called when the image retrieved and set finished.
    /// - Returns: A task represents the image downloading.
    ///
    /// - Note:
    /// Internally, this method will use `KingfisherManager` to get the requested resource, from either cache
    /// or network. Since this method will perform UI changes, you must call it from the main thread.
    /// Both `progressBlock` and `completionHandler` will be also executed in the main thread.
    ///
    @discardableResult
    public func setImage(with resource: Resource?,
                         placeholder: Image? = nil,
                         options: KingfisherOptionsInfo? = nil,
                         progressBlock: DownloadProgressBlock? = nil,
                         completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil)
        -> DownloadTask?
    {
        guard let resource = resource else {
            base.image = placeholder
            webURL = nil
            completionHandler?(.failure(KingfisherError.imageSettingError(reason: .emptyResource)))
            return nil
        }
        
        let options = KingfisherManager.shared.defaultOptions + (options ?? .empty)
        if !options.keepCurrentImageWhileLoading {
            base.image = placeholder
        }
        
        webURL = resource.downloadURL
        let task = KingfisherManager.shared.retrieveImage(
            with: resource,
            options: options,
            progressBlock: { receivedSize, totalSize in
                guard resource.downloadURL == self.webURL else { return }
                progressBlock?(receivedSize, totalSize)
            },
            completionHandler: { result in
                DispatchQueue.main.safeAsync {
                    guard resource.downloadURL == self.webURL else {
                        let error = KingfisherError.imageSettingError(
                            reason: .notCurrentSource(result: result.value, error: result.error, source: .network(resource)))
                        completionHandler?(.failure(error))
                        return
                    }
                    
                    self.imageTask = nil
                    
                    switch result {
                    case .success(let value):
                        self.base.image = value.image
                        completionHandler?(result)
                    case .failure:
                        if let image = options.onFailureImage {
                            self.base.image = image
                        }
                        completionHandler?(result)
                    }
                }
            })
        
        imageTask = task
        return task
    }
    
    /// Cancels the image download task of the button if it is running.
    /// Nothing will happen if the downloading has already finished.
    public func cancelImageDownloadTask() {
        imageTask?.cancel()
    }
    
    /// Sets an alternate image to the button with a requested resource.
    ///
    /// - Parameters:
    ///   - resource: The `Resource` object contains information about the resource.
    ///   - placeholder: A placeholder to show while retrieving the image from the given `resource`.
    ///   - options: An options set to define image setting behaviors. See `KingfisherOptionsInfo` for more.
    ///   - progressBlock: Called when the image downloading progress gets updated. If the response does not contain an
    ///                    `expectedContentLength`, this block will not be called.
    ///   - completionHandler: Called when the image retrieved and set finished.
    /// - Returns: A task represents the image downloading.
    ///
    /// - Note:
    /// Internally, this method will use `KingfisherManager` to get the requested resource, from either cache
    /// or network. Since this method will perform UI changes, you must call it from the main thread.
    /// Both `progressBlock` and `completionHandler` will be also executed in the main thread.
    ///
    @discardableResult
    public func setAlternateImage(with resource: Resource?,
                                  placeholder: Image? = nil,
                                  options: KingfisherOptionsInfo? = nil,
                                  progressBlock: DownloadProgressBlock? = nil,
                                  completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil)
        -> DownloadTask?
    {
        guard let resource = resource else {
            base.alternateImage = placeholder
            alternateWebURL = nil
            completionHandler?(.failure(KingfisherError.imageSettingError(reason: .emptyResource)))
            return nil
        }
        
        let options = KingfisherManager.shared.defaultOptions + (options ?? .empty)
        if !options.keepCurrentImageWhileLoading {
            base.alternateImage = placeholder
        }
        
        alternateWebURL = resource.downloadURL
        let task = KingfisherManager.shared.retrieveImage(
            with: resource,
            options: options,
            progressBlock: { receivedSize, totalSize in
                guard resource.downloadURL == self.alternateWebURL else { return }
                progressBlock?(receivedSize, totalSize)
            },
            completionHandler: { result in
                DispatchQueue.main.safeAsync {
                    guard resource.downloadURL == self.alternateWebURL else {
                        let error = KingfisherError.imageSettingError(
                            reason: .notCurrentSource(result: result.value, error: result.error, source: .network(resource)))
                        completionHandler?(.failure(error))
                        return
                    }
                    
                    self.alternateImageTask = nil
                    
                    switch result {
                    case .success(let value):
                        self.base.alternateImage = value.image
                        completionHandler?(result)
                    case .failure:
                        if let image = options.onFailureImage {
                            self.base.alternateImage = image
                        }
                        completionHandler?(result)
                    }
                }
            })
        
        alternateImageTask = task
        return task
    }
    
 
    /// Cancels the alternate image download task of the button if it is running.
    /// Nothing will happen if the downloading has already finished.
    public func cancelAlternateImageDownloadTask() {
        alternateImageTask?.cancel()
    }
}


// MARK: - Associated Object
private var lastURLKey: Void?
private var imageTaskKey: Void?

private var lastAlternateURLKey: Void?
private var alternateImageTaskKey: Void?

extension KingfisherClass where Base: NSButton {
    
    /// Gets the image URL binded to this button.
    public private(set) var webURL: URL? {
        get { return getAssociatedObject(base, &lastURLKey) }
        set { setRetainedAssociatedObject(base, &lastURLKey, newValue) }
    }
    
    private var imageTask: DownloadTask? {
        get { return getAssociatedObject(base, &imageTaskKey) }
        set { setRetainedAssociatedObject(base, &imageTaskKey, newValue)}
    }
    
    
    /// Gets the image URL binded to this button.
    public private(set) var alternateWebURL: URL? {
        get { return getAssociatedObject(base, &lastAlternateURLKey) }
        set { setRetainedAssociatedObject(base, &lastAlternateURLKey, newValue) }
    }
    
    private var alternateImageTask: DownloadTask? {
        get { return getAssociatedObject(base, &alternateImageTaskKey) }
        set { setRetainedAssociatedObject(base, &alternateImageTaskKey, newValue)}
    }
}
