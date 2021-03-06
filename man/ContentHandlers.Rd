% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/EncodeDecodeMiddleware.R
\docType{data}
\name{ContentHandlers}
\alias{ContentHandlers}
\alias{ContentHandlersFactory}
\title{Content handlers collection}
\format{\link[R6:R6Class]{R6::R6Class} object.}
\description{
Controls how RestRserve encodes and decodes different content types.
Designed to work jointly with \link{EncodeDecodeMiddleware}
}
\section{Fields}{

\itemize{
\item \code{handlers} :: \code{environment()}\cr
Handlers storage environment.
}
}

\section{Methods}{

\itemize{
\item \code{get_encode(content_type)}\cr
\code{character(1)} -> \code{function}\cr
Get encoder function for the specific content type.
\item \code{get_decode(content_type)}\cr
\code{character(1)} -> \code{function}\cr
Get decoder function for the specific content type.
\item \code{set_encode(content_type, FUN)}\cr
\code{character(1)}, \code{function} -> \code{self}\cr
Set handler to encode body for the specific content type.
\item \code{set_decode(content_type, FUN)}\cr
\code{character(1)}, \code{function} -> \code{self}\cr
Set handler to decode body for the specific content type.
\item \code{reset()}\cr
-> \code{self}\cr
Resets all the content handlers to RestRserve defaults.
\item \code{to_list}\cr
-> \code{list}\cr
Convert handlers to list.
}
}

\seealso{
\link{Application} \link{EncodeDecodeMiddleware}
}
\keyword{internal}
