# WPZipArchive

WPZipArchive is a simple utility class for zipping and unzipping files on iOS and Mac.

* Unzip zip files
* Unzip password protected zip files
* Create new zip files
* Append to existing zip files
* Zip files
* Zip-up `NSData` instances (with a filename)

## Installation and Setup

### CocoaPods

`pod install WPZipArchive`

### Manual

1. Add the `WPZipArchive` and `minizip` folders to your project.
2. Add the `libz` library to your target

WPZipArchive requires ARC.

## Usage

### Objective-C

```objective-c
#import <WPZipArchive/WPZipArchive.h>

// Create
[WPZipArchive createZipFileAtPath: zipPath withContentsOfDirectory: sampleDataPath];

// Unzip
[WPZipArchive unzipFileAtPath:zipPath toDestination: unzipPath];
```

### Swift

```swift
@import WPZipArchive

// Create
WPZipArchive.createZipFileAtPath(zipPath, withContentsOfDirectory: sampleDataPath)

// Unzip
WPZipArchive.unzipFileAtPath(zipPath, toDestination: unzipPath)
```

## License

WPZipArchive is protected under the [MIT license](https://github.com/samsoffes/ssziparchive/raw/master/LICENSE) and our slightly modified version of [Minizip](http://www.winimage.com/zLibDll/minizip.html) 1.1 is licensed under the [Zlib license](http://www.zlib.net/zlib_license.html).

## Acknowledgments

* [@soffes](https://github.com/soffes) for creating [SSZipArchive](https://github.com/ZipArchive/ZipArchive).
* [aish](http://code.google.com/p/ziparchive) for creating [ZipArchive](http://code.google.com/p/ziparchive), the project that inspired SSZipArchive.
* [@randomsequence](https://github.com/randomsequence) for implementing the creation support tech.
* [@johnezang](https://github.com/johnezang) for help along the way.
