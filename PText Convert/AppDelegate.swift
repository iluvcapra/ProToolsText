//
//  AppDelegate.swift
//  PText Convert
//
//  Created by Jamie Hardt on 12/23/17.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @IBAction func convertTextExport(_ sender : AnyObject) {
        let openPanel = NSOpenPanel()
        
        if openPanel.runModal() != NSApplication.ModalResponse.OK {
            return
        }
        
        guard let inputUrl = openPanel.url else {
            return
        }
        
        let savePanel = NSSavePanel()
        savePanel.prompt = "Export All"
        savePanel.message = "Select Export Folder and Export File Nase Name."
        savePanel.title = "Export"
        savePanel.nameFieldLabel = "Base Name:"
        
        if savePanel.runModal() != NSApplication.ModalResponse.OK  {
            return
        }
        
        let engine = CSVConversionEngine()
        
        guard let exportUrl = savePanel.url else {
            return
        }
        
        do {
            try engine.convert(fileURL: inputUrl,
                       encoding: String.Encoding.utf8,
                       to: exportUrl)
        } catch let error {
            NSApp.presentError(error)
        }
    }
    


}

