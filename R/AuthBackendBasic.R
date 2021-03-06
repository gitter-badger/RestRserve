#' @title Basic authorization backend
#'
#' @usage NULL
#' @format [R6::R6Class] object.
#'
#' @description
#' Creates AuthBackendBasic class object.
#'
#' @section Construction:
#'
#' ```
#' AuthBackendBasic$new(FUN)
#' ````
#'
#' * `FUN` :: `function`\cr
#'   `character(1)`, `character(1)` -> `logical(1)` \cr
#'   Function to perform authentication which takes two arguments - `user` and `password`.
#'   Returns boolean - whether access is allowed for a requested `user` or not.
#'
#' @section Methods:
#'
#' * `authenticate(request, response)`\cr
#'   [Request], [Response] -> `NULL`\cr
#'   Provide authentication for the given request.
#'
#' @references
#' [RFC7617](https://tools.ietf.org/html/rfc7617)
#' [Wikipedia](https://en.wikipedia.org/wiki/Basic_access_authentication)
#'
#' @export
#'
#' @seealso [AuthMiddleware] [Request] [Response]
#'
#' @family AuthBackend
#'
#' @examples
#' # init users database
#' user_db = list(
#'   "user-1" = "password-1",
#'   "user-2" = "password-2"
#' )
#' # define authentication handler
#' auth_fun = function(user, password) {
#'   if (is.null(user_db[[user]])) return(FALSE) # not found
#'   if (!identical(user_db[[user]], password)) return(FALSE) # incorrect
#'   return(TRUE)
#' }
#' # init backend
#' auth_backend = AuthBackendBasic$new(FUN = auth_fun)
#'
#' # test backend
#' # define credentials (see RFC)
#' creds = jsonlite::base64_enc("user-1:password-1")
#' # generate request headers
#' h = list("Authorization" = sprintf("Basic %s", creds))
#' # simulate request
#' rq = Request$new(path = "/", headers = h)
#' # init response object
#' rs = Response$new()
#' # perform authentication
#' auth_backend$authenticate(rq, rs) # TRUE
#'
AuthBackendBasic = R6::R6Class(
  "AuthBackendBasic",
  inherit = AuthBackend,
  public = list(
    initialize = function(FUN) {
      super$initialize(FUN, "Basic")
    },
    authenticate = function(request, response) {
      user_password = private$extract_credentials(request, response)
      res = private$auth_fun(user_password[[1]], user_password[[2]])
      if (isTRUE(res)) {
        return(TRUE)
      } else {
        raise(self$HTTPError$unauthorized(
          body = "401 Invalid Username/Password",
          headers = list("WWW-Authenticate" = "Basic"))
        )
      }
    }
  ),
  private = list(
    extract_credentials = function(request, response) {
      token = super$parse_auth_token_from_request(request, response)
      #-------------------------------------------------------
      token = try(rawToChar(jsonlite::base64_dec(token)), silent = TRUE)
      if (inherits(token, "try-error")) {
        raise(self$HTTPError$unauthorized(
          body = "401 Invalid Authorization Header: Unable to decode credentials",
          headers = list("WWW-Authenticate" = "Basic"))
        )
      }
      #-------------------------------------------------------
      result = try({
        result = strsplit(token, ":", TRUE)[[1]]
        if (length(result) != 2) {
          raise(self$HTTPError$unauthorized(
            body = "401 Invalid Authorization Header: user-password should be vector of 2",
            headers = list("WWW-Authenticate" = "Basic"))
          )
        }
        list(user = result[[1]], password = result[[2]])
      }, silent = TRUE)
      #-------------------------------------------------------
      if (inherits(result, "try-error")) {
        raise(self$HTTPError$unauthorized(
          body = "401 Invalid Authorization Header: Unable to decode credentials",
          headers = list("WWW-Authenticate" = "Basic"))
        )
      }
      #-------------------------------------------------------
      result
    }
  )
)
