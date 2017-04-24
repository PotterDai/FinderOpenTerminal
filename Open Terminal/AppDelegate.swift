//
//  AppDelegate.swift
//  Open Terminal
//
//  Created by Quentin PÂRIS on 23/02/2016.
//  Copyright © 2016 QP. All rights reserved.
//

import Cocoa
import Darwin

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillFinishLaunching(_ aNotification: Notification) {
        let appleEventManager:NSAppleEventManager = NSAppleEventManager.shared()
        appleEventManager.setEventHandler(self, andSelector: #selector(AppDelegate.handleGetURLEvent(_:replyEvent:)), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        SwiftySystem.execute("/usr/bin/pluginkit", arguments: ["pluginkit", "-e", "use", "-i", "fr.qparis.openterminal.Open-Terminal-Finder-Extension"])
        SwiftySystem.execute("/usr/bin/killall",arguments: ["Finder"])
        helpMe()
        exit(0)
    }
    
    func handleGetURLEvent(_ event: NSAppleEventDescriptor?, replyEvent: NSAppleEventDescriptor?) {
        if let url = URL(string: event!.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))!.stringValue!) {
             let unwrappedPath = url.path
                if(FileManager.default.fileExists(atPath: unwrappedPath)) {

                    let arg =   "tell application \"System Events\"\n" +
                                // Check if Terminal.app is running
                                    "if (application process \"Terminal\" exists) then\n" +
                                        // if Terminal.app is running make sure it is in the foreground
                                        "tell application \"Terminal\"\n" +
                                            "activate\n" +
                                        "end tell\n" +
                                        // Open a new window in the Terminal.app by triggering ⌘+n
                                        "tell application \"System Events\" to tell process \"Terminal\" to keystroke \"n\" using command down\n" +
                                    "else\n" +
                                        // If Terminal.app is not running bring it up
                                        "tell application \"Terminal\"\n" +
                                            "activate\n" +
                                        "end tell\n" +
                                    "end if\n" +
                                "end tell\n" +
                                // Switch to the requested directory and clear made input
                                "tell application \"Terminal\"\n" +
                                    // Without the delay every second request will not cd into the direcory
                                    "delay 0.01\n" +
                                    "do script \"cd '\(unwrappedPath)' && clear\" in window 1\n" +
                                "end tell"
                    
                    SwiftySystem.execute("/usr/bin/osascript", arguments: ["-e", arg])
                } else {
                    helpMe("The specified directory does not exist")
                }
                
            
        }
        
        exit(0)
    }
    
    fileprivate func helpMe(_ customMessage: String) {
        let alert = NSAlert ()
        alert.messageText = "Information"
        alert.informativeText = customMessage
        alert.runModal()
    }
    
    fileprivate func helpMe() {
        helpMe("This application adds a Open Terminal item in every Finder context menus.\n\n(c) Quentin PÂRIS 2016 - http://quentin.paris")
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

