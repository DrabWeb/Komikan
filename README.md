# Komikan
A Manga reader and manager for OSX

## Downloads
Requires at least OSX 10.10 Yosemite. Tested on OSX 10.11 El Capitan

<a href="https://github.com/DrabWeb/Komikan/releases">https://github.com/DrabWeb/Komikan/releases</a>

## Features

### Application

<img src="https://raw.githubusercontent.com/DrabWeb/Komikan/master/Screenshots/Application.png"></img>

> * Custom Vibrant look
> * All native and programmed in Swift
> * Distraction Free Mode - Darken everything behind Komikan


### Collection Management

<img src="https://raw.githubusercontent.com/DrabWeb/Komikan/master/Screenshots/Collection Management.png"></img>

> * Import single or multiple Manga at once
> * Supports ZIP, RAR, CBZ, CBR and Folders of images
> * Grid and List views
> * Set Series, Artist, Writer, Tags, Group, Favourite, mark as
        l-lewd..., set published dates and more on import
> * Edit any of the above after import(Either one at a time or by groups)
> * Use JSON to predefine info about multiple or single Manga
> * Fetch Metadata from <a href="http://mcd.iosphe.re/">http://mcd.iosphe.re/</a>
> * Custom cover images(Uses first page of Manga by default)
> * Never moves or deletes your original Manga files
> * Sorting by Title, Series and Artist, Group and more
> * Put your Manga into groups
> * Group view to see your individual Series, Artists, Authors and Groups
> * Drag and Drop import
> * Easy collection moving between computers/reinstalls
> * See how much percent you are done a Manga
> * Cover image compression for faster loading
> * Size the grid to maximize screen usage


### Reader

<img src="https://raw.githubusercontent.com/DrabWeb/Komikan/master/Screenshots/Reader.png"></img>

> * Vibrant
> * Bookmarks
> * Track pad gestures for page flipping and zooming
> * Saturation, Brightness, Contrast and Sharpness Controls
> * Dual page(LtR and RtL)
> * Thumbnail based page jumping
> * Zoom in and out
> * Notes for each manga with rich text support(Size, alignment, images, ETC.)
> * Ignore pages that match a set regex(E.g. ignore credits pages)
> * Page rotation
> * Fast
> * Fit window to Page size


### Search

<img src="https://raw.githubusercontent.com/DrabWeb/Komikan/master/Screenshots/Search.png"></img>

> * Search by lots of terms

> > * Title(And exclude titles)
> > * Series(And exclude series)
> > * Artist(And exclude artists)
> > * Writer(And exclude writers)
> > * Tags(And exclude tags)
> > * Groups(And exclude groups)
> > * Favourites
> > * Read
> > * Percent finished
> > * L-lewd...
> > * Published date

> * Very similar to EH searching
> * Optional simplified search terms
> * Search Lists - A simple graphical front end for searching


### L-lewd... mode

<img src="https://raw.githubusercontent.com/DrabWeb/Komikan/master/Screenshots/EH Downloading.png"></img>

> * Mark Manga as l-lewd...
> * Only shows Manga that are marked l-lewd... when in l-lewd.. mode
> * Downloading from ``` g.e-hentai.org ``` and ``` exhentai.org ```
> * Login to ``` exhentai.org ``` from the Application
> * Choose to use Japanese or English title
> * Automatic marking of l-lewd... mode for downloads from EH depending on if they are in the ``` Non-H ``` category

## Compiling

> Cocoapods is not the most stable with Swift, so you have to go through these steps first to compile Komikan.

> * Open Xcode and try to compile the app. It should come up with errors.
> * Quit Xcode
> * Open Komikan's ``` Podfile ``` and comment out the ``` use_frameworks! ``` with a ``` # ```, then save the file
> * Do a ``` pod install ``` in the directory where the ``` Podfile ``` is
> * When its done, reopen Komikan and Xcode and try to compile
> * It will bring up ~17 errors, quit it again
> * Reopen the ``` Podfile ``` and uncomment the ``` use_frameworks! ``` line, then save the file
> * Do another ``` pod install ```, and wait for it to finish
> * Reopen Komikan in Xcode and run it, it should now compile

</br>
> Troubleshooting

> * If it still doesnt compile, make sure you open the ``` .xcworkspace ``` and not the ``` .xcodeproj ```
