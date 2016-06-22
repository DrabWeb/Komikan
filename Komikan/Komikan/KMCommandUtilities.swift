//
//  KMCommandUtilities.swift
//  Komikan
//
//  Created by Seth on 2016-01-13.
//

import Cocoa

class KMCommandUtilities {
    // The NSTask for the last command we ran
    var lastCommandTask : NSTask!;
    
    // Runs the specified command as a shell script, returns the output
    func runCommand(launchPath : String, arguments : [String], waitUntilExit : Bool) -> String {
        // Print to the log what command we are running
        print("KMCommandUtilities: Running command \"" + launchPath + " " + String(arguments) + "\"");
        
        // Reset lastCommandTask
        lastCommandTask = NSTask();
        
        // Set the launch path to the launch path we passed
        lastCommandTask.launchPath = launchPath;
        
        // Set the arguments to be the arguments string split at every space
        lastCommandTask.arguments = arguments;
        
        // Create a pipe to get the output
        let pipe = NSPipe();
        
        // Set the tasks output to our pipe
        lastCommandTask.standardOutput = pipe;
        
        // Set the error output to our pipe
        lastCommandTask.standardError = pipe;
        
        // Launch the task
        lastCommandTask.launch();
        
        // If we said to wait until the command finished...
        if(waitUntilExit) {
            // Wait until it is done
            lastCommandTask.waitUntilExit();
        }
        
        // Create a data variable with the data output of the command
        let data = pipe.fileHandleForReading.readDataToEndOfFile();
        
        // Create an output variable to the output data as a UTF8 string
        let output: String = NSString(data: data, encoding: NSUTF8StringEncoding) as! String;
        
        // Return the output
        return output;
    }
}