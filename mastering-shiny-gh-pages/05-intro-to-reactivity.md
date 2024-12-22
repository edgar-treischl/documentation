# (PART\*) Reactive programming {-}

# Reactive programming basics

## Introduction {-}

In the previous chapters, we talked about creating user interfaces. Now we'll move on to discuss the server side of Shiny, where we use R code at runtime to make our user interfaces come alive!

In Shiny, you express your server logic using reactive programming. Reactive programming is an elegant and powerful programming paradigm, but it can be disorienting at first for the average R user, who is used to executing code at the R console or in a linearly executed R script.

This chapter will provide a gentle walkthrough of reactive programming, introducing some of the most basic reactive constructs you'll use in your Shiny apps.

### Outline {-}

* Section \@ref(server-function) introduces you to the _server function_, the body of which will be the site of most of your reactive programming.
* Section \@ref(input) introduces the `input` object, the humble center of most reactive programs.
* Section \@ref(output) introduces the `output` object, a place to hang logic that populates outputs in the UI.
* Section \@ref(inputs-and-outputs) shows the consequences of accessing `input` values from your `output` logic—the simplest form of reactivity.
* Section \@ref(reactive-exprs) introduces _reactive expressions_, which provide a way to model intermediate computations. Reactive expressions are key to writing Shiny apps that perform well and are easy to reason about.

## The server function

The typical Shiny app boilerplate looks like this:


```r
library(shiny)

ui <- fluidPage(
  # UI goes here
)

server <- function(input, output, session) {
  # Server logic goes here
}

shinyApp(ui, server)
```

As you can see, the `server` function is a function that you (the app author) define, and pass to Shiny via the `shinyApp` function. You'll never invoke a server function yourself; rather, Shiny invokes it whenever a new session begins. (A session begins each time the Shiny app is loaded by a browser.) You can think of the server function as the logic for _initializing_ a new session.

Almost all of the reactive programming you'll do in Shiny will be directly in the server function, at least at first. This is because each time the server function is executed, it creates a private scope for that particular session. Novice Shiny app authors often wonder whether it's safe for two users to connect to a single Shiny app at the same time—how does Shiny keep track of whose inputs and outputs are whose? It's this private scoping that makes it possible, even natural, to maintain separation between sessions.

Every local variable you create in the body of the server function will be private, accessible only to a particular session. Most of the time, we'll also want our reactive interactions to be private to each session, too: when user A moves a slider, you usually want outputs to update ony for user A, not user B. Therefore, we'll write our reactive logic in the server function.

### Server function parameters

Server functions always take three parameters: `input`, `output`, and `session`. (For legacy reasons, `session` is optional, but you should include it.) You'll never create these objects yourself; rather, they are created by Shiny when a session begins. Each `input`, `output`, and `session` connects back to a specific browser tab; we'll use these objects to communicate back and forth with the browser.

For the moment, we'll focus on `input` and `output`, and leave `session` for later chapters.

## Input {#input}

The `input` object is a list-like object that contains all the input data sent from the browser, stored by input ID. If your UI contains a numeric input control with an input ID of `count`:


```r
numericInput("count", label = "Number of values", value = 100)
```

then `input$count` will initially contain the value `100`. As the user changes the value in the browser, `input$count` will be updated automatically by Shiny.

Unlike a typical R list, `input` objects are read-only. The following line will not work:


```r
# Throws an error
input$count <- 10
```

The reason for this restriction is that `input` is supposed to reflect what's happening in the browser; the browser is the "single source of truth". Being able to directly modify the `input` object would introduce a second source of truth, which could then be in conflict with the state of the browser.

One more important thing about `input` is that it's a bit selective about who is allowed to read it. This server function will throw an error:


```r
server <- function(input, output, session) {
  message("The value of input$count is ", input$count)
}
```

To new Shiny app authors, this is an extremely surprising limitation! But rest assured that `input`'s selectivity is a feature, not a bug. To explain why, we'll first need to talk about outputs.

## Output {#output}

Shiny UIs not only contain inputs, but outputs as well. The various `*Output` UI functions—`plotOutput`, `tableOutput`, `verbatimTextOutput`—merely insert empty boxes, or placeholders, into your UI. The `output` object is how you provide Shiny with instructions for populating these empty boxes.

You use the `output` object by wrapping a code block with a render function, then assigning all of that to a slot on the `output` object. Like this:


```r
server <- function(input, output, session) {
  output$hist_plot <- renderPlot({
    # Choose 100 random values from a normal distribution,
    # and create a histogram
    hist(rnorm(100))
  })
}
```

This snippet assumes that the UI contains a `plotOutput("hist_plot")`. The render function you use (`renderPlot`) must match with the output function (`plotOutput`), and the output slot (`hist_plot`) must match with the output ID.

### Imperative vs. declarative

TODO: Make this a sidebar (somehow)?

You might read this code and think it means, "Render the plot `hist(rnorm(100L))`, and fill `plotOutput("hist_plot")` with it." But this intuition is wrong, in a subtle but important way. This code does not _instruct_ Shiny to render the plot and send it to the browser, but instead, tells Shiny _how it could_ render the plot, if and when Shiny wanted to. This is the difference between _imperative_ programming, which is what we're used to, and _declarative_ programming, which is what Shiny demands.

Imperative programming is about issuing specific commands, to be carried out immediately. Declarative programming is about expressing some higher-level goals or constraints, and relying on someone else (in this case, Shiny) to decide how and/or when to translate that into action.

Imperative says: "Go make me a sandwich."

Declarative says: "Ensure there is a sandwich in the refrigerator at all times." (Sorry, sometimes Declarative can be a demanding jerk.)

You may actually be more familiar with declarative programming than you think. SQL and regular expressions are examples of declarative programming. Excel formulas are too.

The correct, declarative reading of the code snippet above is "Whenever you (Shiny) want to render the `hist` output, be sure to do it as a plot, and the logic for doing so is `hist(rnorm(100L))`." It's totally up to Shiny whether and when to actually render the plot; maybe right away, maybe quite a bit later, maybe many times, maybe never. This isn't to imply that Shiny is capricious and arbitrary, only that it's Shiny's responsibility, instead of the app author's, to decide when render logic is actually executed.

(On the other hand, the *contents* of the output's code block—i.e. the rendering logic you supply—may be pretty imperative. It's specifically the assignment of the render function to `output$hist_plot` that's declarative.)

## Using inputs from outputs {#inputs-and-outputs}

The above rendering logic, `hist(rnorm(100))`, isn't very exciting; the user can't interact with this app in any way (unless you count reloading the browser, which would generate a new batch of values). Let's modify the output to use the input. The complete app is below:


```r
library(shiny)

ui <- fluidPage(
  numericInput("count", label = "Number of values", value = 100),
  plotOutput("hist_plot")
)

server <- function(input, output, session) {
  output$hist_plot <- renderPlot({
    # Choose input$count random values from a normal distribution,
    # and create a histogram
    hist(rnorm(input$count))
  })
}

shinyApp(ui, server)
```

Run this app, and you'll notice that as you change the `count` input, the output updates immediately. This is reactive programming at work! When one thing (`input$count`) changes, other things (`output$hist_plot`) automatically and immediately respond.

Let's see what happens if we add a few more inputs and outputs. In this next example, we've added a new input that affects the histogram: `input$bins` is used to suggest a number of bins to the `hist()` function. We've also added a table output, that limits itself to displaying the first `input$rows` of the data.


```r
library(shiny)

ui <- fluidPage(
  numericInput("count", label = "Number of values", value = 100),
  numericInput("bins", label = "Bins (approx)", value = 10),
  plotOutput("hist_plot"),
  numericInput("rows", label = "Rows to show", 10),
  tableOutput("value_table")
)

server <- function(input, output, session) {
  output$hist_plot <- renderPlot({
    # Choose input$count random values from a normal distribution,
    # and create a histogram
    values <- rnorm(input$count)
    hist(values, breaks = input$bins)
  })
  
  output$value_table <- renderTable({
    # Choose input$count random values from a normal distribution,
    # and display the first input$rows
    values <- rnorm(input$count)
    data.frame(head(values, input$rows))
  }, colnames = FALSE)
}

shinyApp(ui, server)
```

By careful inspection of the code, we can see that `input$count` affects both outputs, while `input$bins` affects only the plot and `input$rows` affects only the table. Run the app, and you'll see that Shiny knows this too. If you change `input$bins`, the plot is affected but the table is not. If you change `input$rows`, the table is affected but the plot is not.

The point of this example is to demonstrate that Shiny doesn't simply re-render all of its outputs whenever an input has changed. Somehow, without a lot of help from us, Shiny figures out which inputs should affect which outputs. This is the most "magical" aspect of reactive programming, and we'll eventually pull back the curtain in section TODO; for now, just trust that it works.

### Outputs are atomic

Shiny is smart enough to discern that an output needs to be updated. However, it's not nearly smart enough to know if it can get away with running only part of the output's code block. For example, the code for `hist_plot` has two lines:


```r
values <- rnorm(input$count)
hist(values, breaks = input$bins)
```

As a human looking at this code, you might conclude that when `input$bins` changes, it's not necessary to re-run both lines; if we still had access to the existing `values` variable, merely running the second line might be enough.

Shiny doesn't try to be this clever. Instead, an output's render code block is always executed in its entirety, whether it's two lines of code or two hundred. In this way, each output represents an indivisible unit.
