import Foundation
import Prelude

func traverse<S, A, B>(
  _ f: @escaping (A) -> B?
)
-> (S)
-> [B]?
where S: Sequence, S.Element == A {
  
  { xs in
    var ys: [B] = []
    for x in xs {
      guard let y = f(x) else { return nil }
      ys.append(y)
    }
    return ys
  }
}

func sequence<A>(_ xs: [A?]) -> [A]? {
  xs |> traverse(identity)
}

let certificates = [
  NSData(contentsOfFile: Bundle.module.path(forResource: "AmazonRootCA1", ofType: "cer")!)!,
  NSData(contentsOfFile: Bundle.module.path(forResource: "AmazonRootCA2", ofType: "cer")!)!,
  NSData(contentsOfFile: Bundle.module.path(forResource: "AmazonRootCA3", ofType: "cer")!)!,
  NSData(contentsOfFile: Bundle.module.path(forResource: "AmazonRootCA4", ofType: "cer")!)!,
  NSData(contentsOfFile: Bundle.module.path(forResource: "SFSRootCAG2", ofType: "cer")!)!
]

func serverCertificates(_ serverTrust: SecTrust) -> [SecCertificate]? {
  (0 ..< SecTrustGetCertificateCount(serverTrust)).reversed()
    <¡> { SecTrustGetCertificateAtIndex(serverTrust, $0) }
    |> sequence
}

func certificatesData(_ certs: [SecCertificate]) -> [Data] {
  certs.map { cert in
    let certData = SecCertificateCopyData(cert)
    let data = CFDataGetBytePtr(certData)
    let size = CFDataGetLength(certData)
    return NSData(bytes: data, length: size) as Data
  }
}

func chainIsValid(_ serverChain: [Data]) -> Bool {
  for serverCert in serverChain {
    for cert in certificates {
      if cert.isEqual(to: serverCert) {
        return true
      }
    }
  }
  return false
}

class SessionDelegate: NSObject, URLSessionDelegate {
  func urlSession(
    _ session: URLSession,
    didReceive challenge: URLAuthenticationChallenge,
    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
  ) {
    guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
          let serverTrust = challenge.protectionSpace.serverTrust,
          SecTrustEvaluateWithError(serverTrust, nil),
          let serverCertificates = serverCertificates(serverTrust),
          chainIsValid(certificatesData(serverCertificates))
    else {
      completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
      return
    }
    completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: serverTrust))
  }
}

let session = URLSession(
  configuration: .ephemeral,
  delegate: SessionDelegate(),
  delegateQueue: nil
)
