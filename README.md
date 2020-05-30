# UFConvertorWidget

By using the app you will be able to convert UF (Unidad de Fomento) to Chilean Pesos with the assistance of the [MindicadorChile](https://mindicador.cl/)'s API.

# Developing notes 

While using Swift 5.2, I started by implementing the request model, the view of the application, then I was able to create a framework with  the request model, resquest response and currency convertor error files and use it to develop the widget part.

To draw the chart a use the [Cocoa Pod Charts](http://cocoadocs.org/docsets/Charts/2.0.9/index.html) version 2.0.9

And finally, I created units test to verify the request model.


##Sources 

### Charts
[Cocoa Pod Charts](http://cocoadocs.org/docsets/Charts/2.0.9/index.html) - created by Daniel Cohen Gindi, inspired by Philipp Jahoda

[Chart in Swift - Setting Up a Basic Line Chart Using iOS Charts](https://www.youtube.com/watch?v=mWhwe_tLNE8&list=PL_csAAO9PQ8bjzg-wxEff1Fr0Y5W1hrum&index=5) - Youtube video by Rebeloper - Rebel Developer

### Today Extension
[Today Extension Tutorial: Getting Started](https://www.raywenderlich.com/697-today-extension-tutorial-getting-started) - by  Michael Katz

[iOS Swift 4: Today Extension](https://stfalcon.com/en/blog/post/today-extension-swift-4) - by Maxim Vasilevsky

### Framework 
[Custom Frameworks: Sharing Code | Swift 4, Xcode 9](https://www.youtube.com/watch?v=GMYxlkOE35k) - by Kilo Loco

### Handling dark mode

[How To Adopt Dark Mode In Your iOS App 🌙
](https://www.fivestars.blog/code/ios-dark-mode-how-to.html) - by Federico Zanetello




