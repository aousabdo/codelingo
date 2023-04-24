library(shiny)
library(shinythemes)
library(httr)
library(jsonlite)
library(shinyjs) 

source("gloabal.R")

ui <- fluidPage(
  

  
  useShinyjs(), 
  
  # Add custom JavaScript function to resize the textarea
  tags$head(
    tags$script(HTML("
    function resizeTextarea(textareaId) {
      var textarea = document.getElementById(textareaId);
      textarea.style.height = 'auto';
      textarea.style.height = (textarea.scrollHeight) + 'px';
    }
  ")),
    # Include the .png favicon
    tags$link(rel = "icon", href = "ADSS_Mini_Logo_2.png", type = "image/png")
  ),
  
  theme = shinytheme("cyborg"),
  
  tags$head(tags$style(HTML("
  body {
    background-color: #040117;
  }
    .shiny-output-error {
      display: none;
    }
    .shiny-output-error:before {
      display: none;
    }
  "))),
  
  titlePanel(
    title = div(style = "text-align: center;",
                div("CodeLingo", style = "font-size: 40px;"),
                div("AI Programming Language Translator", style = "font-size: 26px;")
    ),
    windowTitle = NULL
  ),
  
  fluidRow(
    column(12, align = "center",
           passwordInput("api_key", "Enter your OpenAI API Key:", ""),
           fileInput("upload_code"
                     , "Upload script, or paste script in window below:"
                     , accept = c(".R", ".py", ".js", ".java", ".rb", ".cpp", ".cs", ".go", ".php")),
           tags$head(tags$style(".shiny-input-container select {
                             background-color: #34495e;
                             color: white;
                           }"))
    )
  ),
  fluidRow(
    column(width = 1, offset = 5, align = "left",
           selectInput("model", label = NULL, choices = c("GPT-3.5", "GPT-4"), selectize = FALSE),
           tags$head(tags$style(".shiny-input-container select {
                               font-size: 18px;
                               height: 48px;
                             }"))
    ),
    column(width = 1, align = "right",
           actionButton("translate", "Translate", style = "background-color: #7d1fc4; color: white; font-size: 18px; padding: 10px 20px;")
    )
  )
  ,
  
  fluidRow(
    column(5, align = "center", offset = 1,
           div(class = "custom-select",
               selectInput("input_language", label = HTML('<span style="font-size: 18px;">Input Language:</span>'),
                           choices = c("Auto Detect", "R", "Python", "Scala", "Ruby", "Assembly Language",
                                       "JavaScript", "Java", "Ruby", "C++", "C#", "C", "SAS",
                                       "Go", "PHP", "Matlab", "TypeScript", "TSX", "Perl", "Julia"),
                           width = "100%")
           ),
           tags$head(tags$style(".selectize-input, .selectize-dropdown {background-color: #34495e; color: white;}
                        .selectize-dropdown {border: none; text-align: left;}
                        .custom-select .selectize-input {background-color: #34495e; border-color: #34495e;}
                        .custom-select .selectize-dropdown {color: white; background-color: #2c3e50;}
                        .selectize-input::after {border-top-color: white !important;}")),
           tags$textarea(id = "input_code"
                         , oninput = "resizeTextarea(this);" 
                         , placeholder = "Enter your code here or upload a file"
                         , rows = 15
                         , style = "width: 100%; background-color: #1f2130; color: white; font-size: 16px; resize: none; border: 1px solid #1f2130;")
    ),
    column(5, align = "center",
           div(class = "custom-select",
               selectInput("output_language", HTML('<span style="font-size: 18px;">Output Language:</span>'),
                           choices = c("R", "Python", "Scala", "Ruby", "JavaScript", "Java", "Ruby", "Assembly Language"
                                       , "C++", "C#", "C","Go", "PHP", "Natural Language", "SAS",
                                       "Matlab", "TypeScript", "TSX", "Perl", "Julia"),
                           width = "100%")
           ),
           tags$head(tags$style(".selectize-input, .selectize-dropdown {background-color: #34495e; color: white;}
                             .selectize-dropdown {border: none; text-align: left;}
                             .custom-select .selectize-input {background-color: #34495e;}
                             .custom-select .selectize-dropdown {color: white; background-color: #2c3e50;}")),
           tags$textarea(id = "output_code"
                         , oninput = "resizeTextarea(this);"
                         , placeholder = "Translated code will appear here"
                         , rows = 15
                         , style = "width: 100%; background-color: #1f2130; color: white; font-size: 16px; resize: none; border: 1px solid #1f2130;"
                         , readonly = TRUE),
           downloadButton("download_code", "Download Translated Code")
    )
  ),
  
  div(style = "text-align: right; margin-bottom: 10px; margin-top: 20px; margin-right: 30px;",
      a(href = "https://www.analyticadss.com", target = "_blank",
        img(src = "ADSS_Logo.png", width = "200px", height = "50px", style = "display: inline-block;")
      )
  )
  
)

server <- function(input, output, session) {
  output$download_code <- downloadHandler(
    filename = function() {
      file_ext <- switch(input$output_language,
                         "R" = ".R",
                         "Python" = ".py",
                         "Scala" = ".scala", 
                         "Ruby" = ".rb",
                         "JavaScript" = ".js",
                         "Java" = ".java",
                         "Ruby" = ".rb",
                         "Assembly Language" = ".asm",
                         "C++" = ".cpp",
                         "C#" = ".cs",
                         "C" = ".c",
                         "Go" = ".go",
                         "PHP" = ".php", 
                         "Matlab" = ".m", 
                         "TypeScript" = ".ts", 
                         "TSX" = ".tsx", 
                         "SAS"= ".sas",
                         "Perl" = ".pl",
                         "Julia" = ".jl")
      paste0("translated_code", file_ext)
    },
    content = function(file) {
      writeLines(input$output_code, file)
    },
    contentType = "text/plain"
  )
  
  observeEvent(input$upload_code, {
    req(input$upload_code)
    code <- readLines(input$upload_code$datapath)
    updateTextAreaInput(session, "input_code", value = paste(code, collapse = "\n"))
  })
  
  observeEvent(input$translate, {
    req(input$api_key, input$input_code)
    
    if (input$input_language == "Auto Detect") {
      messages <- list(list(role = "system"
                            , content = paste("Detect the programming language of the following code snippet:"
                                              , input$input_code)))
      detected_language_response <- openai_chat_completions(input$api_key, messages)
      detected_language <- detected_language_response$choices$message$content
      
      invisible(cat("Detected ", detected_language, "\n"))
      
    } else {
      detected_language <- input$input_language
    }
    
    # messages <- list(list(role = "system"
    #                       , content = paste("Translate the following"
    #                                         , detected_language, "code to"
    #                                         , input$output_language
    #                                         , "code, just give me the code with no comments:"
    #                                         , input$input_code)))
    
    messages <- list(list(role = "system"
                          #                     , content = paste("You are an expert programmer in all programming languages. Translate the "
                          #                                       , detected_language
                          #                                       , " code to "
                          #                                       , input$output_language
                          #                                       , " code. Do not include \`\`\`.
                          # 
                          # Example translating from JavaScript to Python:
                          # 
                          # JavaScript code:
                          # for (let i = 0; i < 10; i++) {
                          #   console.log(i);
                          # }
                          # 
                          # Python code:
                          # for i in range(10):
                          #   print(i)",
                          # 
                          #                                       detected_language, "code:",
                          #                                       input$input_code,
                          #                                       input$output_language, "code (no \`\`\`):")
                          , content = create_prompt(input_language = detected_language
                                                    , output_language = input$output_language
                                                    , input_code = input$input_code)
    ))
    
    model <- ifelse(input$model == "GPT-3.5", "gpt-3.5-turbo", "gpt-4")
    
    translation_response <- openai_chat_completions(input$api_key
                                                    , messages
                                                    , model = model
                                                    , temperature = 0
    )
    
    if (!is.null(translation_response)) {
      translated_code <- translation_response$choices$message$content
      updateTextAreaInput(session, "output_code", value = translated_code)
    } else {
      updateTextAreaInput(session, "output_code", value = "Translation failed. Please check your API key and input.")
    }
  })
  
  # Add new observer for clearing textbox areas when the user selects a new language
  observeEvent(input$input_language, {
    updateTextAreaInput(session, "input_code", value = "")
  })
  
  observeEvent(c(input$input_language, input$output_language), {
    updateTextAreaInput(session, "output_code", value = "")
  })
  
  # to make the code boxes dynamic  
  # observe({
  #   input$input_code
  #   runjs(sprintf("resizeTextarea('input_code');"))
  # })
  # 
  # observe({
  #   input$output_code
  #   runjs(sprintf("resizeTextarea('output_code');"))
  # })
}

shinyApp(ui = ui, server = server)

