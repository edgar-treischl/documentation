# (PART\*) Creating user interfaces {-}

# Basic UI

## Introduction {-}



As you saw in the previous chapter, Shiny encourages separation of the code that generates your user interface (`ui`) from the code that drives your app's behavior (`server`). In this chapter, we'll dive much deeper into the UI side of things.

All web pages are constructed out of HTML, and Shiny user interfaces are no different--although they are generally expressed using R, their ultimate job is to produce HTML. As a Shiny app author, you can use high-level layout functions in R that keep you far away from the details of HTML. You can also work with HTML tags directly to achieve any level of customization you want. These approaches are by no means exclusive; you can mix high-level functions with low-level HTML as much as you like.

This chapter will focus on some of the high-level R functions that Shiny provides for input, output, and layout, while the chapter on [Advanced UI][] delves into using lower-level features for authoring HTML directly. If you're new to Shiny, you should read this chapter regardless of your level of HTML knowledge, as inputs and outputs are essential parts of any Shiny app.

### Outline {-}

* Section \@ref(inputs) covers input controls.
* Section \@ref(outputs) covers output containers.
* Section \@ref(layout) covers page and layout functions, which you can use to arrange inputs and outputs.

## Inputs {#inputs}

As we saw in the previous chapter, functions like `sliderInput`, `selectInput`, `textInput`, and `numericInput` are used to insert input controls into your UI.

The first parameter of an input function is always the input ID; this is a simple string that is composed of alphanumeric characters and/or underscore (no spaces, dashes, periods, or other special characters please!). Generally, there is a second parameter `label` that is used to create a human-readable label for the control. Any remaining parameters are specific to the particular input function, and can be used to customize the input control.

For example, a typical call to `sliderInput` might look something like this:

```r
shiny::sliderInput("min", "Limit (minimum)", min = 0, max = 100, value = 50)
```



In the server function, the value of this slider would be accessed via `input$min`.

It's absolutely vital that each input have a *unique* ID. Using the same ID value for more than one input or output in the same app will result in errors or incorrect results.

Shiny itself comes with a variety of input functions out of the box:

- `sliderInput`
- `selectInput`/`selectizeInput`
- `checkboxGroupInput`/`checkboxInput`/`radioButtons`
- `dateInput`/`dateRangeInput`
- `fileInput`
- `numericInput`
- `textInput`/`passwordInput`
- `actionButton`

Each input function has its own unique look and functionality, and takes different arguments. But they all share the same two properties of 1) taking a unique input ID, and 2) exposing values to the server function via a slot in the `input` object.

## Outputs {#outputs}

Output functions are used to tell Shiny _where_ and _how_ to place outputs that are defined in the app's server.

Like inputs, outputs take a unique ID as their first argument. These IDs must be unique among all inputs _and_ outputs!

Unlike inputs, outputs generally start out as empty rectangles, that need to be fed data from the server in order to actually appear.

## Layouts and panels {#layout}

Shiny includes several classes of UI functions that behave like neither inputs nor outputs. Rather, these functions help with the layout and formatting of your UI.

### Page functions

The first function you're likely to encounter in a Shiny UI is a page function. Page functions expect to be the outermost function call in your UI, and set up your web page to contain other content.

The most common page function is `fluidPage`.

```r
fluidPage(..., title = NULL, theme = NULL)
```

`fluidPage` sets up your page to use the Bootstrap CSS framework. Bootstrap provides your web page with attractive settings for typography and spacing, and also preloads dozens of CSS rules that can be invoked to visually organize and enhance specific areas of your UI. We'll take advantage of quite a few of these Bootstrap rules as we proceed through this chapter.

The "fluid" in `fluidPage` means the page's content may resize its width (but not height) as the size of the browser window changes. (The other option is "fixed", which means the page contents will never exceed 960 pixels in width.)

* sidebar
* tabset
* bootstrap grid
