#' @title Creates middleware object
#'
#' @usage NULL
#' @format [R6::R6Class] object.
#'
#' @description
#' Creates Middleware object.
#'
#' Middleware is a very useful concept which allows to perform
#' preprocessing of requests and post-processing of responses. Middleware has
#' an access to both `request` and  `response` objects and can modify them.
#' This way each request can be checked/modified before passing handler and
#' response can be post processed (for example this way we developer can set up
#' custom error messages).
#'
#' @section Construction:
#'
#' ```
#' Middleware$new(
#'   process_request  = function(request, response) TRUE,
#'   process_response = function(request, response) TRUE,
#'   id = "Middleware"
#' )
#' ````
#'
#' * `process_request` :: `function`\cr
#'   Modify `request` or `response` objects or  throw exception using
#'   `[HTTPError]` helper. This function evaluate before router handler called.
#'
#' *  `process_response` :: `function`\cr
#'   Modify `request` or `response` objects or  throw exception using
#'   `[HTTPError]` helper. This function evaluate after router handler called.
#'
#' * `id` :: `character(1)`\cr
#'   Middleware id
#'
#' @section Fields:
#'
#' * `process_request` :: `function`\cr
#'   Function which takes 2 arguments - `request` and `response` objects (class
#'   [Request] and [Response] correspondingly) and modify
#'   `request` and `response` or throw exception using [HTTPError] helper.
#'
#'   Function is called before request is routed to handler.
#'
#'   Usually `process_request` is used to perform logging, check authorization, etc.
#'
#' * `process_response` :: `funciotn`\cr
#'   Function which takes 2 arguments - `request` and `response` objects (class
#'   [Request] and [Response] correspondingly) and modify
#'   `request` and `response` or throw exception using [HTTPError] helper.
#'
#'   Function is called after request is processed by handler.
#'
#'   Usually `process_response` is used to perform logging, custom error handling, etc.
#'
#' * `id` :: `character(1)`\cr
#'   Middleware id
#'
#' @export
#'
#' @seealso [Request] [Response] [Application]
#'
Middleware = R6::R6Class(
  classname = "Middleware",
  public = list(
    process_request = NULL,
    process_response = NULL,
    id = NULL,
    initialize = function(
      process_request  = function(request, response) TRUE,
      process_response = function(request, response) TRUE,
      id = "Middleware") {

        checkmate::assert_function(process_request, nargs = 2L)
        checkmate::assert_function(process_response, nargs = 2L)
        checkmate::assert_string(id)

        self$process_request  = process_request
        self$process_response = process_response
        self$id = id
    }
  )
)
