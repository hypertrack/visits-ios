import Foundation
import NonEmpty


public extension URLError {
  var prettyPrinted: NonEmptyString {
    """
    URL:            \(failureURLString ?? "Broken URL")
    OS Desctiption: \(localizedDescription)
    Description:    \(errorDescription)
    User Info:      \(errorUserInfo)
    """
  }
  
  var errorDescription: NonEmptyString {
    let output: NonEmptyString
    switch code {
    case .appTransportSecurityRequiresSecureConnection:
      output = "App Transport Security disallowed a connection because there is no secure network connection."
    case .backgroundSessionInUseByAnotherProcess:
      output = "An app or app extension attempted to connect to a background session that is already connected to a process."
    case .backgroundSessionRequiresSharedContainer:
      output = "The shared container identifier of the URL session configuration is needed but has not been set."
    case .backgroundSessionWasDisconnected:
      output = "The app is suspended or exits while a background data task is processing."
    case .badServerResponse:
      output = "The URL Loading system received bad data from the server."
    case .badURL:
      output = "A malformed URL prevented a URL request from being initiated."
    case .callIsActive:
      output = "A connection was attempted while a phone call is active on a network that does not support simultaneous phone and data communication (EDGE or GPRS)."
    case .cancelled:
      output = "An asynchronous load has been canceled."
    case .cannotCloseFile:
      output = "A download task couldn’t close the downloaded file on disk."
    case .cannotConnectToHost:
      output = "An attempt to connect to a host failed."
    case .cannotCreateFile:
      output = "A download task couldn’t create the downloaded file on disk because of an I/O failure."
    case .cannotDecodeContentData:
      output = "Content data received during a connection request had an unknown content encoding."
    case .cannotDecodeRawData:
      output = "Content data received during a connection request could not be decoded for a known content encoding."
    case .cannotFindHost:
      output = "The host name for a URL could not be resolved."
    case .cannotLoadFromNetwork:
      output = "A request to load an item only from the cache could not be satisfied."
    case .cannotMoveFile:
      output = "A download task was unable to move a downloaded file on disk."
    case .cannotOpenFile:
      output = "A download task was unable to open the downloaded file on disk."
    case .cannotParseResponse:
      output = "A task could not parse a response."
    case .cannotRemoveFile:
      output = "A download task was unable to remove a downloaded file from disk."
    case .cannotWriteToFile:
      output = "A download task was unable to write to the downloaded file on disk."
    case .clientCertificateRejected:
      output = "A server certificate was rejected."
    case .clientCertificateRequired:
      output = "A client certificate was required to authenticate an SSL connection during a request."
    case .dataLengthExceedsMaximum:
      output = "The length of the resource data exceeds the maximum allowed."
    case .dataNotAllowed:
      output = "The cellular network disallowed a connection."
    case .dnsLookupFailed:
      output = "The host address could not be found via DNS lookup."
    case .downloadDecodingFailedMidStream:
      output = "A download task failed to decode an encoded file during the download."
    case .downloadDecodingFailedToComplete:
      output = "A download task failed to decode an encoded file after downloading."
    case .fileDoesNotExist:
      output = "A file does not exist."
    case .fileIsDirectory:
      output = "A request for an FTP file resulted in the server responding that the file is not a plain file, but a directory."
    case .httpTooManyRedirects:
      output = "A redirect loop has been detected or the threshold for number of allowable redirects has been exceeded (currently 16)."
    case .internationalRoamingOff:
      output = "The attempted connection required activating a data context while roaming, but international roaming is disabled."
    case .networkConnectionLost:
      output = "A client or server connection was severed in the middle of an in-progress load."
    case .noPermissionsToReadFile:
      output = "A resource couldn’t be read because of insufficient permissions."
    case .notConnectedToInternet:
      output = "The Internet connection appears to be offline."
    case .redirectToNonExistentLocation:
      output = "A redirect was specified by way of server response code, but the server did not accompany this code with a redirect URL."
    case .requestBodyStreamExhausted:
      output = "A body stream is needed but the client did not provide one."
    case .resourceUnavailable:
      output = "A requested resource couldn’t be retrieved."
    case .secureConnectionFailed:
      output = "An attempt to establish a secure connection failed."
    case .serverCertificateHasBadDate:
      output = "A server certificate had a date which indicates it has expired, or is not yet valid."
    case .serverCertificateHasUnknownRoot:
      output = "A server certificate was not signed by any root server."
    case .serverCertificateNotYetValid:
      output = "A server certificate is not yet valid."
    case .serverCertificateUntrusted:
      output = "A server certificate was signed by a root server that isn’t trusted."
    case .timedOut:
      output = "An asynchronous operation timed out."
    case .unknown:
      output = "The URL Loading System encountered an error that it can’t interpret."
    case .unsupportedURL:
      output = "A properly formed URL couldn’t be handled by the framework."
    case .userAuthenticationRequired:
      output = "Authentication is required to access a resource."
    case .userCancelledAuthentication:
      output = "An asynchronous request for authentication has been canceled by the user."
    case .zeroByteResource:
      output = "A server reported that a URL has a non-zero content length, but terminated the network connection gracefully without sending any data."
    default:
      output = "Unrecognized error."
    }
    return output + " (\(code.rawValue))"
  }

}

