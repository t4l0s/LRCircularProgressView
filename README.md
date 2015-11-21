# LRCircularProgressView

LRCircularProgressView is a simple UIView subclass for displaying and animating progress.

![](https://cloud.githubusercontent.com/assets/9881051/11318494/eb7ecacc-9054-11e5-9359-0361b6fc7b1f.gif)

## Installation

You can easily install LRCircularProgressView with [CocoaPods](https://cocoapods.org) by adding following line to your project's pods file:

	pod 'LRCircularProgressView'

Alternatively just download the source and add it to your local project. No further dependencies have to be resolved.

## Usage

You can easily add an configure the view using the the Xcode Interface Designer. 
The Text within the progressview can easily be modified as shown in the following example:


```ObjC
self.progressView = [LRCircularProgressView new]; // or from IB

NSMutableAttributedString *attrString = [NSMutableAttributedString new];
    [attrString appendAttributedString: [[NSAttributedString alloc] initWithString: @"Loading\n"]];
    [attrString addAttribute: LRCircularProgressPlaceholderKey value: @"%.0f" range: NSMakeRange(attrString.length - 1, 1)];
    [attrString appendAttributedString: [[NSAttributedString alloc] initWithString: @"%"]];
    
self.progressView.title = attrString;
[self.progressView sizeToFit];

[self.progressView setProgress: 1.f animated: YES];
```

## License

The code is MIT licensed.
