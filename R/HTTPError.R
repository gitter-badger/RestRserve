HTTPError = R6::R6Class(
  classname = 'HTTPError',
  inherit = RestRserveResponse,
  public = list(
    initialize = function(body, content_type, headers, status_code, serializer) {
      super$initialize(body, content_type, headers, status_code, serializer)
    }
  )
)

#' @name HTTPErrorFactory
#' @title helps to generate http error responces
#' @description helps to generate http error responces. See \link{raise} for example.
#' @section Methods:
#' \describe{
#'   \item{\code{$new(content_type = "text/plain", serializer = NULL)}}{Factory constructor.
#'   \describe{
#'     \item{content_type}{type of the error response. \code{"text/plain"} by default}
#'     \item{serializer}{\code{NULL} (default) or function. Specify how encode response body. If \code{NULL}
#'       then RestRserve will try to automatically encode body properly according to \code{content_type} argument}
#'     }
#'   }
#' }
#' @export
HTTPErrorFactory = R6::R6Class(
  classname = 'HTTPErrorFactory',
  inherit = RestRserveResponse,
  public = list(
    initialize = function(content_type = "text/plain", serializer = NULL) {
      super$set_content_type(content_type, serializer)
    },
    #------------------------------------------------------------------------
    error = function(status_code, body, headers = character(0)) {
      private$prepare_response(status_code, body, headers)
    },
    #------------------------------------------------------------------------
    bad_request = function(body = NULL, headers = character(0)) {
      private$prepare_response(400L, body, headers)
    },
    #------------------------------------------------------------------------
    unauthorized = function(body = NULL, headers = character(0)) {
      private$prepare_response(401L, body, headers)
    },
    #------------------------------------------------------------------------
    forbidden = function(body = NULL, headers = character(0)) {
      private$prepare_response(403L, body, headers)
    },
    #------------------------------------------------------------------------
    not_found = function(body = NULL, headers = character(0)) {
      private$prepare_response(404L, body, headers)
    },
    #------------------------------------------------------------------------
    method_not_allowed = function(body = NULL, headers = character(0)) {
      private$prepare_response(405L, body, headers)
    },
    #------------------------------------------------------------------------
    not_acceptable = function(body = NULL, headers = character(0)) {
      private$prepare_response(406L, body, headers)
    },
    #------------------------------------------------------------------------
    conflict = function(body = NULL, headers = character(0)) {
      private$prepare_response(409L, body, headers)
    },
    #------------------------------------------------------------------------
    gone = function(body = NULL, headers = character(0)) {
      private$prepare_response(410L, body, headers)
    },
    #------------------------------------------------------------------------
    length_required = function(body = NULL, headers = character(0)) {
      private$prepare_response(411L, body, headers)
    },
    #------------------------------------------------------------------------
    precondition_failed = function(body = NULL, headers = character(0)) {
      private$prepare_response(412L, body, headers)
    },
    #------------------------------------------------------------------------
    payload_too_large = function(body = NULL, headers = character(0)) {
      private$prepare_response(413L, body, headers)
    },
    #------------------------------------------------------------------------
    uri_too_long = function(body = NULL, headers = character(0)) {
      private$prepare_response(414L, body, headers)
    },
    #------------------------------------------------------------------------
    unsupported_media_type = function(body = NULL, headers = character(0)) {
      private$prepare_response(415L, body, headers)
    },
    #------------------------------------------------------------------------
    range_not_satisfiable = function(body = NULL, headers = character(0)) {
      private$prepare_response(416L, body, headers)
    },
    #------------------------------------------------------------------------
    unprocessable_entity = function(body = NULL, headers = character(0)) {
      private$prepare_response(417L, body, headers)
    },
    #------------------------------------------------------------------------
    locked = function(body = NULL, headers = character(0)) {
      private$prepare_response(423L, body, headers)
    },
    #------------------------------------------------------------------------
    failed_dependency = function(body = NULL, headers = character(0)) {
      private$prepare_response(424L, body, headers)
    },
    #------------------------------------------------------------------------
    precondition_required = function(body = NULL, headers = character(0)) {
      private$prepare_response(428L, body, headers)
    },
    #------------------------------------------------------------------------
    too_many_requests = function(body = NULL, headers = character(0)) {
      private$prepare_response(429L, body, headers)
    },
    #------------------------------------------------------------------------
    request_header_fields_too_large = function(body = NULL, headers = character(0)) {
      private$prepare_response(431L, body, headers)
    },
    #------------------------------------------------------------------------
    unavailable_for_legal_reasons = function(body = NULL, headers = character(0)) {
      private$prepare_response(451L, body, headers)
    },
    #------------------------------------------------------------------------
    internal_server_error = function(body = NULL, headers = character(0)) {
      private$prepare_response(500L, body, headers)
    },
    #------------------------------------------------------------------------
    not_implemented = function(body = NULL, headers = character(0)) {
      private$prepare_response(501L, body, headers)
    },
    #------------------------------------------------------------------------
    bad_gateway = function(body = NULL, headers = character(0)) {
      private$prepare_response(502L, body, headers)
    },
    #------------------------------------------------------------------------
    service_unavailable = function(body = NULL, headers = character(0)) {
      private$prepare_response(503L, body, headers)
    },
    #------------------------------------------------------------------------
    gateway_timeout = function(body = NULL, headers = character(0)) {
      private$prepare_response(504L, body, headers)
    },
    #------------------------------------------------------------------------
    version_not_supported = function(body = NULL, headers = character(0)) {
      private$prepare_response(505L, body, headers)
    },
    #------------------------------------------------------------------------
    insufficient_storage = function(body = NULL, headers = character(0)) {
      private$prepare_response(507L, body, headers)
    },
    #------------------------------------------------------------------------
    loop_detected = function(body = NULL, headers = character(0)) {
      private$prepare_response(508L, body, headers)
    },
    #------------------------------------------------------------------------
    network_authentication_required = function(body = NULL, headers = character(0)) {
      private$prepare_response(511L, body, headers)
    }
  ),

  private = list(
    prepare_response = function(status_code, body, headers) {
      # default standard message
      if (is.null(body)) {
        body = paste(status_code, status_codes[[as.character(status_code)]])
      }
      HTTPError$new(
        body = body,
        content_type = self$content_type,
        headers = headers,
        status_code = status_code,
        serializer = self$serializer
      )
    }
  )
)

#' @name raise
#' @title interrupts request handling
#' @description interrupts request handling and signals RestRserve to return HTTPError
#' @param x instance of \code{HTTPError}. Can be created using \link{HTTPErrorFactory} -
#' see examples.
#' @export
#' @examples
#' err_factory = HTTPErrorFactory$new()
#' caught_http_exception = try(raise(err_factory$bad_request()), silent = TRUE)
#' condition = attr(caught_http_exception, 'condition')
#' # response is an instance of HTTPError
#' # and valid RestRserve instace because HTTPError inherits from RestRserveResponse
#' identical(condition$response$body, "400 Bad Request")
raise = function(x) {
  exception = errorCondition('raise', response = x, class = class(x))
  stop(exception)
}