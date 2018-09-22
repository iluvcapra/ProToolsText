//
//  AppDelegate.swift
//  PText Convert
//
//  Created by Jamie Hardt on 12/23/17.
//

import Cocoa
import PKit // for error reporting

let errorDomain = "PTextConvertErrorDomain"

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSAlertDelegate {

    @IBOutlet var savePanelAuxiliaryView : NSView?
    @IBOutlet var outputFormatSelector   : NSPopUpButton?
    
    var activeSavePanel : NSSavePanel?
    
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
    
    func xmlConvert(from inputUrl : URL, to exportUrl :  URL,
                    style stylesheet : XMLConversionEngine.Stylesheet ) throws {
            let engine = XMLConversionEngine()
            engine.stylesheet = stylesheet
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
        
        activeSavePanel = savePanel
        defer {
            activeSavePanel = nil
        }
        
        savePanel.prompt = "Export"
        savePanel.message = "Select Export Folder and Export File Nase Name."
        savePanel.title = "Export"
        savePanel.nameFieldLabel = "Export:"
        savePanel.isExtensionHidden = false
        savePanel.accessoryView = savePanelAuxiliaryView
        savePanel.allowsOtherFileTypes = false
        savePanel.allowedFileTypes = ["csv"]
        if savePanel.runModal() != NSApplication.ModalResponse.OK  {
            return
        }
        
        guard let exportUrl = savePanel.url, let outputFormatTag = outputFormatSelector?.selectedTag() else {
            return
        }
        
        do {
            switch outputFormatTag {
            case 0:     try csvConvert(from : inputUrl, to: exportUrl)
            case 10:    try xmlConvert(from: inputUrl,
                                       to: exportUrl, style: .none)
            case 20:     try xmlConvert(from: inputUrl,
                                       to: exportUrl, style: .basic)
            case 30:     try xmlConvert(from: inputUrl,
                                       to: exportUrl, style: .adr)
            case 40:     try xmlConvert(from: inputUrl,
                                       to: exportUrl, style: .filemaker)
            default:    break
            }
            
            convertSucceeded()
        
        } catch let error as PTTextFileParser.ParseTokenError {
            let errorMessage = error.localizedDescription
            let presentedError = NSError(domain: errorDomain, code: -1,
                                         userInfo: [NSLocalizedDescriptionKey : errorMessage])
            
            NSApp.presentError(presentedError)
        } catch let error {
            NSApp.presentError(error)
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

    //MARK: Save Panel Auxiliary View method
    
    @IBAction func selectOutputFormat(_ sender : AnyObject?) {
        if  let menuButton = sender as? NSPopUpButton,
            let panel = activeSavePanel  {
            
            let newExt : String
            switch menuButton.selectedTag() {
            case 00:     newExt = "csv"
            case 10:    newExt = "xrawpttext"
            case 20:    newExt = "xpttext"
            case 30:    newExt = "xadr"
            case 40:    newExt = "xml"
            default:    newExt = "csv"
            }
            
            panel.allowedFileTypes = [newExt]
        }
    }

}

