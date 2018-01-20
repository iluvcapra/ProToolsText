//
//  AppDelegate.swift
//  PText Convert
//
//  Created by Jamie Hardt on 12/23/17.
//

import Cocoa
import PKit // for error reporting

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSAlertDelegate {

    let errorDomain = "PTextConvertErrorDomain"

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
        savePanel.allowedFileTypes = ["csv"]
        savePanel.isExtensionHidden = false
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
            convertSucceeded()
        } catch let error as PTTextFileParser.ParseTokenError {
            let errorMessage = error.localizedDescription
            let presentedError = NSError(domain: errorDomain, code: -1,
                                         userInfo: [NSLocalizedDescriptionKey : errorMessage])
            
            NSApp.presentError(presentedError)
        } catch let error {
            let presentedError = NSError(domain: errorDomain, code: -1, userInfo: [NSUnderlyingErrorKey : error])
            NSApp.presentError(presentedError)
        }
    }
    
    func convertSucceeded() {
        let alert = NSAlert()
        alert.addButton(withTitle: "OK")
        //alert.addButton(withTitle: "Reveal File")
        //alert.addButton(withTitle: "Open in Filemaker Pro")
        
        alert.delegate = self
        
        alert.messageText = "Conversion succeeded."
        alert.runModal()
    }


}

