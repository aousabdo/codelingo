create_prompt <- function(input_language, output_language, input_code){
  
  if(input_language == "Natrual Language"){
    paste0(
      " You are an expert programmer in all programming languages. Translate the natural language to "
      ,output_language
      , " code. Do not include \`\`\`.
      
    Example translating from natural language to JavaScript:
    Natural language:
    Print the numbers 0 to 9.
    JavaScript code:
    for (let i = 0; i < 10; i++) {
      console.log(i);
    }
    Natural language:"
    , input_code
    , output_language
    , "code (no \`\`\`)"
    )
  }else if(output_language == "Natural Language"){
    paste(
      "You are an expert programmer in all programming languages. Translate the "
      , input_language
      , " code to natural language in plain English that the average adult could understand. Respond as bullet points starting with -.
  
      Example translating from JavaScript to natural language:
  
      JavaScript code:
      for (let i = 0; i < 10; i++) {
        console.log(i);
      }
  
      Natural language:
      Print the numbers 0 to 9."
      
      , input_language
      , "code:"
      , input_code
      , "Natural language:"
      , sep = "\n"
    )
  }else{
    paste0("You are an expert programmer in all programming languages. Translate the "
          , input_language
          , " code to "
          , output_language
          , " code. Do not include \`\`\`.
  
      Example translating from JavaScript to Python:
  
      JavaScript code:
      for (let i = 0; i < 10; i++) {
        console.log(i);
      }
  
      Python code:
      for i in range(10):
        print(i)",
          
          input_language, "code:"
          , input_code
          , output_language
          , "code (no \`\`\`):")
  }
}

openai_chat_completions <- function(api_key, messages, model = "gpt-3.5-turbo", ...) {
  url <- "https://api.openai.com/v1/chat/completions"
  
  headers <- add_headers(
    "Content-Type" = "application/json",
    "Authorization" = paste("Bearer", api_key)
  )
  
  payload <- list(
    model = model,
    messages = messages
  )
  
  extra_args <- list(...)
  if (length(extra_args) > 0) {
    payload <- modifyList(payload, extra_args)
  }
  
  json_payload <- toJSON(payload, auto_unbox = TRUE)
  
  response <- POST(url, headers, body = json_payload, encode = "json")
  
  if (http_status(response)$category == "Success") {
    response_content <- fromJSON(content(response, "text"))
    return(response_content)
  } else {
    cat("Request failed. Status code:", response$status_code, "\n")
    return(NULL)
  }
}