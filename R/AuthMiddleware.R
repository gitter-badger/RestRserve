#' @title Creates authorization middleware object
#'
#' @usage NULL
#' @format [R6::R6Class] object.
#'
#' @description
#' Adds various authorizations to [Application].
#' This class inherits [Middleware].
#'
#' @section Construction:
#'
#' ```
#' AuthMiddleware$new(auth_backend, routes, match = "exact", id = "AuthMiddleware")
#' ````
#'
#' * `auth_backend` :: [AuthBackend]\cr
#'   Authentication backend.
#'
#' * `routes` :: `character()`\cr
#'   Routes paths to protect.
#'
#' * `match` :: `character()`\cr
#'   How routes will be matched: `"exact"` or `"partial"` (as prefix).
#'
#' * `id` :: `character(1)`\cr
#'   Middleware id
#'
#' @export
#'
#' @seealso
#' [Middleware] [Application]
#'
#' @family AuthBackend
#'
AuthMiddleware = R6::R6Class(
  classname = "AuthMiddleware",
  inherit = Middleware,
  public = list(
    initialize = function(auth_backend, routes, match = "exact", id = "AuthMiddleware") {
      checkmate::assert_class(auth_backend, "AuthBackend")
      checkmate::assert_character(routes, pattern = "^/")
      checkmate::assert_subset(match, c("exact", "partial"))
      checkmate::assert_string(id, min.chars = 1L)

      if (length(match) == 1L) {
        match = rep(match, length(routes))
      }
      if (length(routes) != length(match)) {
        stop("length 'match' must be 1 or equal length 'routes'")
      }

      private$auth_backend = auth_backend
      self$id = id

      self$process_request = function(request, response) {
        prefixes_mask = match == "partial"
        if ((request$path %in% routes[!prefixes_mask]) || any(startsWith(request$path, routes[prefixes_mask]))) {
          return(private$auth_backend$authenticate(request, response))
        }
      }

      self$process_response = function(request, response) {
        return(TRUE)
      }
    }
  ),
  private = list(
    auth_backend = NULL
  )
)
