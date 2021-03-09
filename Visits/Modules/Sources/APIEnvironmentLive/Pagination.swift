import Combine
import NonEmpty
import Tagged


typealias PaginationToken = Tagged<PaginationTokenTag, NonEmptyString>
enum PaginationTokenTag {}

func paginate<Pagination, Page, PaginationError, Value>(
  getPage: @escaping (Pagination?) -> AnyPublisher<Page, PaginationError>,
  valuesFromPage: @escaping (Page) -> [Value],
  paginationFromPage: @escaping (Page) -> Pagination?
) -> AnyPublisher<[Value], PaginationError> {
  let paginationPublisher = CurrentValueSubject<Pagination?, Never>(nil)
  
  return paginationPublisher
    .setFailureType(to: PaginationError.self)
    .flatMap { pagination in
      getPage(pagination)
    }
    .handleEvents(receiveOutput: { page in
      if let pagination = paginationFromPage(page) {
        paginationPublisher.send(pagination)
      } else {
        paginationPublisher.send(completion: .finished)
      }
    })
    .reduce([Value](), { values, page in
      valuesFromPage(page) + values
    })
    .eraseToAnyPublisher()
}
