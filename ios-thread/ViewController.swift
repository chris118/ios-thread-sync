//
//  ViewController.swift
//  ios-thread
//
//  Created by Chris on 2018/8/7.
//  Copyright © 2018年 putao. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let url = "https://www.jianshu.com/p/fb4fb80aefb8"
    var request : URLRequest!
    let sesstion = URLSession.shared
    let lock = NSLock()
    let sync = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        request = URLRequest(url: URL(string: url)!)
    }
    
    @IBAction func objc_sync_enter() {
        for  i in 0...10 {
            ObjectiveC.objc_sync_enter(sync)
            let task = sesstion.dataTask(with: request) { [weak self](data, response, error) in
                print(" task \(i)")
                ObjectiveC.objc_sync_exit(self?.sync ?? 0)
            }
            task.resume()
            
        }
    }
    
    @IBAction func synchronizedTap(_ sender: Any) {
        for  i in 0...10 {
           lock.lock()
            let task = sesstion.dataTask(with: request) { [weak self](data, response, error) in
                self?.lock.unlock()
                print(" task \(i)")
            }
            task.resume()
            
        }
    }
    @IBAction func dispatchGroup_tap(_ sender: Any) {
        let group = DispatchGroup.init()

        for  i in 0...10 {
            group.enter()
            let task = sesstion.dataTask(with: request) { (data, response, error) in
                print(" task \(i)")
                 group.leave()
            }
            task.resume()
        }
        group.notify(queue: DispatchQueue.main) {
            print("end")
        }
    }
    
    @IBAction func dispatch_semaphore_signal_tap(_ sender: Any) {
        let sem = DispatchSemaphore(value: 0)
        
        for  i in 0...10 {
            let task = sesstion.dataTask(with: request) { (data, response, error) in
                sem.signal()
                print(" task \(i)")
            }
            task.resume()
            sem.wait() //阻塞
        }
    }
}

