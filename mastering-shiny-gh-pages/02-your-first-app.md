# Your first Shiny app

## Introduction {-}

In this chapter, we'll create a simple Shiny app. Along the way, you'll learn the basic structure of a Shiny app, and how to save and run Shiny apps using the RStudio IDE. You'll also take your first steps into reactive programming.

### Outline {-}

* Section \@ref(create-app) presents the minimum boilerplate that's needed to get a Shiny app running.
* Section \@ref(running) shows you how to start and stop Shiny.
* Section \@ref(adding-ui) walks you through adding UI elements to your app.
* Section \@ref(server-function) adds some basic behavior to the app, by adding some logic to the server function.
* Section \@ref(reactive-expr) takes our server function logic a step further, with reactive expressions.

## Create app dir and file {#create-app}

There are several ways to create a Shiny app. The simplest is to create a new directory for your app, and put a single file called `app.R` in it. This `app.R` file will be used to tell Shiny both how your app should look, and how it should behave.

(Tip: In RStudio IDE, you can easily create a new directory and `app.R` file in one step using **File | New File | Shiny Web App**.)

Open up the `app.R` file and make its contents look like this:

```r
library(shiny)

ui <- "Hello, world!"

server <- function(input, output, session) {
}

shinyApp(ui, server)
```

This is a complete, if trivially simple, Shiny app. Looking closely at the code above, our `app.R` does four things:

1. Calls `library(shiny)` to load the package.
2. Defines the user interface (UI) for our app—in this case, nothing but the words "Hello, world!"
3. Specifies the behavior of our app by defining a `server` function. Currently empty, but we'll be back to revisit this shortly.
4. Calls `shinyApp(ui, server)` to construct a Shiny application object from the UI and server previously defined.

## Running and stopping {#running}

Run this Shiny app in RStudio now by pressing `Ctrl+Shift+Enter`, or by clicking the **Run App** button in the document toolbar; go ahead and try either.

If you're not using RStudio, you can use `setwd()` to change the current working directory to the app dir, and call `shiny::runApp()` (or alternatively, don't change the current working directory and pass the path to the app dir to `runApp()` as an argument).

You should see a web application launch in a new window, with only the words "Hello, world!"

![](images/02-your-first-shiny-app/helloworld.png)<!-- -->

This is RStudio's Shiny app window. From here, you can click "Open in Browser" to view the app in your system default web browser, which can be helpful for testing or debugging. (If you prefer to always launch straight into your system default web browser, or alternatively, in RStudio's Viewer pane, you can use the Run App button's dropdown menu to choose one of those instead.)

Before you close the app, go back to your main RStudio window and look at the R console. You'll notice that the console says something like: "Listening on http://127.0.0.1:3827". This is telling you the URL where your app can be found: 127.0.0.1 is a standard address that means "this computer" and 3827 is a port number. (Your port number will likely be different, as Shiny chooses a random port number for each R session, to make it easy to run multiple Shiny apps simultaneously.) You can enter that URL into any compatible[^1] web browser to open another copy of your app.

[^1]: Notably, Internet Explorer versions earlier than IE11 are not compatible when running Shiny directly from your R session. However, Shiny apps deployed on Shiny Server or ShinyApps.io can work with IE10 (earlier versions of IE are no longer supported).

The second thing to notice is that R is busy: the R prompt isn't visible, and the console toolbar displays a stop sign icon. While a Shiny app is running, it "blocks" the R console. You can't run new commands at the R console until after the Shiny app either stops of its own accord, or (much more commonly) is interrupted.

Go ahead and stop your app using any one of these options:

- Click the stop sign icon on the R console toolbar
- Press the `Esc` key (Note: the keyboard focus must be in either the RStudio console or editor)
- Close the Shiny app window
- Non-RStudio users: However you normally interrupt running R code, e.g. `Ctrl+C` or `Esc`

## Adding UI controls {#adding-ui}

Next, we'll add some inputs and outputs to our UI so it's not *quite* so minimal. Change your `ui` variable to look like this:

```r
ui <- fluidPage(
  selectInput("dataset", label = "Dataset",
    choices = ls("package:datasets")
  ),
  verbatimTextOutput("summary"),
  tableOutput("table")
)
```

This example uses four functions we haven't seen before.

- `fluidPage` is one of several **layout functions**, designed to take other UI objects as arguments, and renders them with some kind of modification. In this case, `fluidPage` brings in a bunch of CSS styling, from the famous [Bootstrap](http://getbootstrap.com/docs/3.3/) CSS library. It also inserts a container that is suitable for splitting into rows and columns (though we aren't ready to do that just yet). 
- `selectInput` is an **input control**, which lets the user interact with the app by providing a value. In this case, it's a fancy select box with the title "Dataset" and lets you choose one of the built-in datasets that come with R.
- `verbatimTextOutput` and `tableOutput` are **output controls**, telling Shiny *where* to put rendered output (we'll get into the *how* in a moment). `verbatimTextOutput` displays preformatted text (in HTML parlance, it uses a `<pre>` tag), and `tableOutput` displays tabular data (e.g. a data frame or matrix) in a nice looking HTML table.

Go ahead and run the app again. You'll now see a select box with a set of names, and very little else. We've defined the UI, but haven't yet told Shiny what data to put in the outputs.

Layout functions and input/output controls are used for different purposes, but they're similar in a pretty fundamental way: **they're all just fancy ways to generate HTML**. If you execute any of these function calls, you'll see HTML printed out at the console. Don't be afraid to poke around to see how these various layouts and controls work under the hood. Later in this book (TODO: XREF), we'll show you how to create your own custom HTML-generating functions.

### Input and output IDs

Another important property that input and output controls share is that **they always take an ID string as their first argument**. In this case, we've used `"dataset"`, `"summary"`, and `"table"` as the identifiers for these inputs and outputs. We'll use these identifiers in the next step to read from inputs and write to outputs.

It's absolutely critical that identifiers be unique! In a given app, you can't have two inputs named `"dataset"`, two outputs named `"plot"`, or an input and an output named `"choices"`. No matter how complex your app gets, you must make sure every ID is unique (though we'll talk about one approach to keep this manageable in the chapter on modules (TODO: XREF)).

You should also avoid using special characters in your identifiers, especially space and dash. Generally, it's best to stick to the kind of names you'd use for variables or data frame columns in R, with the added restriction of avoiding periods. (Like R, numbers and underscores may not start an identifier, but they are permitted elsewhere.)

## Adding behavior {#server-function}

Next, we'll bring the outputs to life by defining them in the server function.

Shiny uses a *reactive programming* framework to make apps interactive. We'll explore reactive programming in much more detail in a future chapter (TODO: XREF), but for now, just be aware that it often involves telling Shiny *how* to perform a computation, not ordering Shiny to actually go *do it*. It's like the difference between giving someone a recipe, versus demanding they go make you a sandwich.

In this simple case, we're going to tell Shiny how to fill in the `summary` and `table` outputs—we're providing the "recipes" for those outputs. Replace your empty `server` function with this:

```r
server <- function(input, output, session) {
  output$summary <- renderPrint({
    dataset <- get(input$dataset, "package:datasets", inherits = FALSE)
    summary(dataset)
  })
  
  output$table <- renderTable({
    dataset <- get(input$dataset, "package:datasets", inherits = FALSE)
    dataset
  })
}
```

Almost every output you'll write in Shiny will follow this same pattern.

```r
output$IDENTIFIER <- renderTYPE({
  # Expression that generates whatever kind of output
  # renderTYPE expects
})
```

The left-hand side of the assignment operator (`<-`), `output$IDENTIFIER`, indicates that you're providing the recipe for the Shiny output with the matching ID. (Note that the ID is quoted in the UI, but not in the server.)

The right-hand side of the assignment specifies uses a specific *render function* to wrap a code block that you provide; in the example above, we use `renderPrint` and `renderTable` wrap our app-specific logic. Each `renderXXX` function is designed to work with a particular `xxxOutput` function (and vice versa).

Each `renderXXX` function also has expectations about what kind of objects should be returned (or what actions taken, like plotting or printing to the console) from its code block.

In this case, we're using `renderPrint` for the `summary` output. `renderPrint` is designed to be used with `verbatimTextOutput`. Whenever `renderPrint` executes its code body, it captures any output that would normally go to the R console, and sends it to the `verbatimTextOutput`.

Similarly, the `renderTable` we're using for the `table` output must always be used with `tableOutput`. `renderTable` doesn't care about what's printed to the R console, but it does want its code block to return either `NULL`, or a data frame or matrix.

**Outputs are *reactive*; Shiny automatically knows when to recalculate them.** Because both of the rendering code blocks we wrote read `input$dataset`, whenever the value of `input$dataset` changes (i.e. the user changes their selection in the UI), both outputs will recalculate and update in the browser.

## Extracting common values with reactive expressions {#reactive-expr}

Even in this simple example, we have some code that's duplicated: the line

```r
dataset <- get(input$dataset, "package:datasets", inherits = FALSE)
```

is present in both outputs. In every kind of programming, it's poor practice to have duplicated code; it can be computationally wasteful, and more importantly, it increases the difficulty of maintaining or debugging the code.

In traditional R scripting, we use two techniques to deal with duplicated code: either we capture the value using a *variable* (if we only need to do the calculation once), or capture the computation itself using a *function* (if we need to perform the calculation multiple times, possibly based on different inputs).

But often in reactive programming, neither of these choices satisfy. Using a variable won't work:

```r
# Don't do this!
server <- function(input, output, session) {
  dataset <- get(input$dataset, "package:datasets", inherits = FALSE)

  output$summary <- renderPrint({
    summary(dataset)
  })
  
  output$table <- renderTable({
    dataset
  })
}
```

In this code, we're attempting to calculate the value of `dataset` just once, as the session starts. But the value of `input$dataset` may change over time. We noted a few paragraphs ago that Shiny outputs are reactive (they re-execute as necessary); the same cannot be said for free-floating code like this. So the result of extracting a variable like this is tha the `dataset` variable will assume some value at startup based on the initial value of `input$dataset`, and stay at that value forever. This is clearly not what we want, and is such an easy trap to fall into that in fact Shiny detects this condition and throws an error immediately.

If using a variable won't work, how about a function? This will work, and takes care of the code duplication, but it does result in duplicated effort:

```r
# Don't do this!
server <- function(input, output, session) {
  getDataset <- function() {
    get(input$dataset, "package:datasets", inherits = FALSE)
  }

  output$summary <- renderPrint({
    summary(getDataset())
  })
  
  output$table <- renderTable({
    getDataset()
  })
}
```

We get the correct behavior this time, at least—we're calling `getDataset()` from within our output code, so Shiny will know to recalculate the outputs when `input$dataset` changes. However, for each change to `input$dataset`, `getDataset` is going to be called twice, and its work is therefore going to be performed twice. (In this example, the work being done in `getDataset` is totally trivial so it doesn't actually matter; just imagine we're doing a more expensive operation like retrieving a dataset from a web service or database, or fitting a model over a large dataset, or performing simulations.)

Reactive programming needs a different mechanism than variables or functions, for reusing calculated values. Fortunately, Shiny provides just that in the form of **reactive expressions**, created by wrapping a block of code with `reactive({...})`. You assign the reactive expression object to a variable, and *call the variable like a function* to retrieve its value.

```r
# Much better
server <- function(input, output, session) {
  dataset <- reactive({
    get(input$dataset, "package:datasets", inherits = FALSE)
  })

  output$summary <- renderPrint({
    summary(dataset())
  })
  
  output$table <- renderTable({
    dataset()
  })
}
```

This looks much like the previous example, where we introduced a `getDataset` function. But a reactive expression behaves differently than a function: it only runs its code the first time it is called (e.g. from `renderPrint` and `renderTable`), then caches the resulting value until reactivity gives it a reason to believe its cached result is no longer valid (in this case, a change to `input$dataset` would be the only reason). Once that happens, the next time it's called, it will execute its code again, and cache the resulting value, and so on.

To summarize: while variables calculate the value only once (not often enough), and functions calculate the value every time they're called (too often), reactive expressions calculate the value only when it might have changed (just right!).

We'll get into reactive programming much more in a later chapter (TODO: XREF), but even armed with a cursory knowledge of inputs, outputs, and reactive expressions, it's possible to build quite useful Shiny apps!

## Exercises

TODO
