//
//  ViewController.swift
//  DownloadMultipleFilesWithProgress
//
//  Created by Kondya on 27/03/19.
//  Copyright © 2019 Kondya. All rights reserved.
//

import UIKit




class ViewController: UIViewController, URLSessionDelegate, URLSessionDownloadDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    
    private let byteFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressView.transform = progressView.transform.scaledBy(x: 1, y: 20)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    var count = 0
    func processURLs(){
        
        //setup queue and set max conncurrent to 1
        let queue = OperationQueue()
        queue.name = "Download queue"
        queue.maxConcurrentOperationCount = 1
        
        let url = URL(string: "http://kathakids.pleximus.co/uploads/1/20190324095702S1P2.mp3")
        let u1 = URL(string: "http://kathakids.pleximus.co/uploads/1/20181219174535S1P3.mp3")
        let u2 = URL(string: "http://kathakids.pleximus.co/uploads/1/20190324095832S1P4.mp3")
        let u3 = URL(string: "http://kathakids.pleximus.co/uploads/1/20190324095911S1P5.mp3")
       
        
        let urls = [url,u1,u2,u3]
        
        count = urls.count
        for url in urls {
            let operation = BlockOperation { () -> Void in
                print("starting download")
                self.download(url: url!)
            }
            
            queue.addOperation(operation)
        }
    }
    
    func download(url:URL)  {
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        session.downloadTask(with: url).resume()
    }
    @IBAction func downloadImage(sender : AnyObject) {
        // A 10MB image from NASA
        
        self.processURLs()
        
    }
    
    var dic = ["":0.0]
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
//        let written = byteFormatter.string(fromByteCount: totalBytesWritten)
//        let expected = byteFormatter.string(fromByteCount: totalBytesExpectedToWrite)
//        //print("Downloaded \(written) / \(expected)")
        if let url = downloadTask.originalRequest?.url {
           dic[url.lastPathComponent] = Double(Float(totalBytesWritten) / Float(totalBytesExpectedToWrite))
       }
        var fff : Float?
        for (_, value) in dic {
           
             print("Float(value)\(String(describing: Float(value)))")
            fff = fff ?? 0 + Float(value)
            
           
        }
        print("ffffff\(String(describing: fff))")
        DispatchQueue.main.async {
            
            self.progressView.progress = Float(fff ?? 0);//Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            print(self.progressView.progress)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        // The location is only temporary. You need to read it or copy it to your container before
        // exiting this function. UIImage(contentsOfFile: ) seems to load the image lazily. NSData
        // does it right away.
        if let data = try? Data(contentsOf: location), let image = UIImage(data: data) {
            DispatchQueue.main.async {
                self.imageView.contentMode = .scaleAspectFit
                self.imageView.clipsToBounds = true
                self.imageView.image = image
            }
        } else {
           print("file")
            
        }
        
    }
}
