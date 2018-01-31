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

    @IBOutlet var savePanelAuxiliaryView : NSView?
    @IBOutlet var outputFormatSelector   : NSPopUpButton?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func csvConvert(from inputUrl : URL, to exportUrl :  URL) throws {
            let engine = CSVConversionEngine()
            try engine.convert(fileURL: inputUrl,
                               encoding: String.Encoding.utf8,
                               to: exportUrl)

    }
    
    func xmlConvert(from inputUrl : URL, to exportUrl :  URL) throws {
            let engine = XMLConversionEngine()
            try engine.convert(fileURL: inputUrl, to: exportUrl)
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
        savePanel.prompt = "Export"
        savePanel.message = "Select Export Folder and Export File Nase Name."
        savePanel.title = "Export"
        savePanel.nameFieldLabel = "Export:"
        savePanel.isExtensionHidden = false
        savePanel.accessoryView = savePanelAuxiliaryView
        if savePanel.runModal() != NSApplication.ModalResponse.OK  {
            return
        }
        
        guard let exportUrl = savePanel.url, let outputFormatTag = outputFormatSelector?.selectedTag() else {
            return
        }
        
        do {
            
            switch outputFormatTag {
            case 0:
                try csvConvert(from : inputUrl, to: exportUrl)
            case 1:
                try xmlConvert(from: inputUrl, to: exportUrl)
            default:
                break
            }
            
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

