//
//  KMCommandUtilities.swift
//  Komikan
//
//  Created by Seth on 2016-01-13.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa

class KMCommandUtilities {
    // Runs the specified command as a shell script, returns the output
    func runCommand(launchPath : String, arguments : [String]) -> String {
        // Print to the log what command we are running
        print("Running command \"" + launchPath + " " + String(arguments) + "\"");
        
        // Create a task to launch the command
        let task = NSTask();
        
        // Set the launch path to the launch path we passed
        task.launchPath = launchPath;
        
        // Set the arguments to be the arguments string split at every space
        task.arguments = arguments;
        
        // Create a pipe to get the output
        let pipe = NSPipe();
        
        // Set the tasks output to our pipe
        task.standardOutput = pipe;
        
        // Set the error output to our pipe
        task.standardError = pipe;
        
        // Launch the task
        task.launch();
        
        // Wait until it is done
        task.waitUntilExit();
        
        // Create a data variable with the data output of the command
        let data = pipe.fileHandleForReading.readDataToEndOfFile();
        
        // Create an output variable to the output data as a UTF8 string
        let output: String = NSString(data: data, encoding: NSUTF8StringEncoding) as! String;
        
        // Return the output
        return output;
    }
}