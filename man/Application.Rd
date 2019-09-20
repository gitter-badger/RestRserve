% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Application.R
\docType{data}
\name{Application}
\alias{Application}
\title{Creates application - RestRserve usage starts from here}
\format{\link[R6:R6Class]{R6::R6Class} object.}
\description{
Creates Application object.
Application converts user-supplied R code into high-performance
REST API by allowing to easily register R functions for handling http-requests.
}
\section{Construction}{


Constructor for \code{Application}.\preformatted{Application$new(middleware = list(), content_type = "text/plain", ...)
}
\itemize{
\item \code{middleware} :: \code{list} of \link{Middleware}\cr
List of middlewares.
\item \code{content_type} :: \code{character(1)}\cr
Default response body content (media) type. \code{"text/plain"} by default.
}
}

\section{Fields}{

\itemize{
\item \code{logger} :: \link{Logger}\cr
Logger object to trace requests process. Alternatively one can use loggers from lgr package as a
drop-in replacement. \code{Logger} and loggers created by \code{lgr} packages share same syntax.
\item \code{content_type} :: \code{chararcter(1)}\cr
Default response body content type.
\item \code{HTTPError} :: \code{HTTPErrorFactory}\cr
Helper to raise HTTP errors.
\item \code{ContentHandlers} :: \code{ContentHandler}\cr
Helper to decode request body and encode response body.
\item \code{endpoints} :: \code{named list()}\cr
Prints all the registered routes with allowed methods.
}
}

\section{Methods}{

\itemize{
\item \code{add_route(path, method, FUN, match = c("exact", "partial", "regex"), ...)}\cr
\code{character(1)}, \code{character(1)}, \code{character(1)} -> \code{invisible(self)} - \link{Application} \cr
Adds endpoint and register user-supplied R function as a handler.

Allowed methods at the moment: GET, HEAD, POST, PUT, DELETE, OPTIONS, PATCH.

\code{match} parameter defines how route will be processed.
\itemize{
\item \code{exact} - match route as is. Returns 404 if route is not matched.
\item \code{partial} - match route as prefix. Returns 404 if prefix are not matched.
\item \code{regex} - match route as template. Returns 404 if template pattern not matched.
}

User function \code{FUN} \strong{must} take two arguments: first is \code{request}
(\link{Request}) and second is \code{response} (\link{Response}).

The goal of the user function is to \strong{modify} \code{response} or throw
exception (call \code{\link[=raise]{raise()}} or \code{\link[=stop]{stop()}}).

Both \code{response} and \code{request} objects modified in-place and internally
passed further to RestRserve execution pipeline.
\item \code{add_get(path, FUN, match = c("exact", "partial", "regex"), ..., add_head = TRUE)}\cr
\code{character(1)}, \code{character(1)}, \code{character(1)}, \code{any}, \code{logical(1)} -> \code{invisible(self)} - \link{Application} \cr
Shorthand to \code{add_route} with \code{GET} method. With \code{add_head = TRUE} HEAD method
handlers will be added (with \code{add_head()}).
\item \code{add_post(path, FUN, match = c("exact", "partial", "regex"), ...)}\cr
\code{character(1)}, \code{character(1)}, \code{character(1)}, \code{any} -> \code{invisible(self)} - \link{Application} \cr
Shorthand to \code{add_route} with \code{POST} method.
\item \code{add_static(path, file_path, content_type = NULL, ...)}\cr
\code{character(1)}, \code{character(1)}, \code{character(1)}, \code{any} -> \code{invisible(self)} - \link{Application} \cr
Adds GET method to serve file or directory at \code{file_path}.

If \code{content_type = NULL} then MIME code \code{content_type}  will be inferred
automatically (from file extension).

If it will be impossible to guess about file type then \code{content_type} will
be set to \code{"application/octet-stream"}.
\item \code{append_middleware(...)}\cr
\code{list()} of \link{Middleware} -> \code{invisible(self)} - \link{Application} \cr
Appends middleware to handlers pipeline.
\item \code{process_request(request)}\cr
\link{Request} -> \code{list()}\cr
Process incoming request and generate Rserve compatible answer with
\link{Response} \code{to_rserve()}. Useful for tests your handlers before
deploy application.
\item \code{run(http_port = 8001L, ..., background = FALSE)}\cr
\code{integer(1)}, \code{any}, \code{logical(1)} -> \code{NULL} \cr
Starts RestRserve application from current R session.
\itemize{
\item \code{http_port} - http port for application. Negative values (such as -1)
means not to expose plain http.
\item \code{...} - key-value pairs of the Rserve configuration. If contains
\code{"http.port"} then \code{http_port} will be silently replaced with its value.
\item \code{background} - whether to try to launch in background process on UNIX
systems. Ignored on windows.
}
\item \code{print_endpoints_summary()}\cr
-> \code{invisible(self)} - \link{Application} \cr
Prints all the registered routes with allowed methods.
\item \code{add_openapi(path = "/openapi.yaml", file_path = "openapi.yaml")}
\code{character(1)}, \code{named list()}, \code{character(1)} -> \code{invisible(self)} - \link{Application} \cr
Adds endpoint to serve \href{https://www.openapis.org/}{OpenAPI} description of
available methods.
\item \code{add_swagger_ui(path = "/swagger", path_openapi = "/openapi.yaml", use_cdn = TRUE, path_swagger_assets = "/__swagger__/", file_path = "swagger-ui.html")}\cr
\code{character(1)}, \code{character(1)}, \code{logical(1)}, \code{character(1)}, \code{character(1)} -> \code{invisible(self)} - \link{Application} \cr
Adds endpoint to show \href{https://swagger.io/tools/swagger-ui/}{Swagger UI}.
}
}

\examples{
# init logger
app_logger = Logger$new()
# set log level for the middleware
app_logger$set_log_level("debug")
# set logger name
app_logger$set_name("MW Logger")
# init middleware to logging
mw = Middleware$new(
  process_request = function(rq, rs) {
    app_logger$info(sprintf("Incomming request (id \%s): \%s", rq$request_id, rq$path))
  },
  process_response = function(rq, rs) {
    app_logger$info(sprintf("Outgoing response (id \%s): \%s", rq$request_id, rs$status))
  },
  name = "awesome-app-logger"
)

# init application
app = Application$new(middleware = list(mw))

# set internal log level
app$logger$set_log_level("error")

# define simply request handler
status_handler = function(rq, rs) {
  rs$set_body("OK")
  rs$set_content_type("text/plain")
  rs$set_status_code(200L)
}
# add route
app$add_get("/status", status_handler, "exact")

# add static file handler
desc_file = system.file("DESCRIPTION", package = "RestRserve")
# add route
app$add_static("/desc", desc_file, "text/plain")

# define say message handler
say_handler = function(rq, rs) {
  who = rq$parameters_path[["user"]]
  msg = rq$parameters_query[["message"]]
  if (is.null(msg)) msg <- "Hello"
  rs$set_body(paste(who, "say", dQuote(msg)))
  rs$set_content_type("text/plain")
  rs$set_status_code(200L)
}
# add route
app$add_get("/say/{user}", say_handler, "regex")

# print endpoint
app$endpoints

# test app
# simulate requests
not_found_rq = Request$new(path = "/no")
status_rq = Request$new(path = "/status")
desc_rq = Request$new(path = "/desc")
say_rq = Request$new(path = "/say/anonym", parameters_query = list("message" = "Hola"))
# process prepared requests
app$process_request(not_found_rq)
app$process_request(status_rq)
app$process_request(desc_rq)
app$process_request(say_rq)

# run app
# app$run(8001L)

}
\seealso{
\link{HTTPError} \link{ContentHandlers} \link{Middleware}
\link{Request} \link{Response}
}
\keyword{datasets}