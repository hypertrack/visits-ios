import NonEmpty
import Prelude
import SwiftUI
import Tagged
import Types
import Views


public struct SignUpQuestionsScreen: View {
  
  public enum QuestionsStatus: Equatable {
    case signingUp(BusinessManages, ManagesFor, SignUpRequest)
    case answering(Either<BusinessManages, ManagesFor>?, Either<SignUpQuestionsFocus, CognitoError>?)
  }
  
  public struct State: Equatable {
    let questionsStatus: QuestionsStatus
    var questionsAnswered: Bool {
      switch questionsStatus {
      case .signingUp: return true
      case .answering: return false
      }
    }
    var questionSelected: SignUpQuestionsFocus? {
      switch questionsStatus {
      case let .answering(_, .some(.left(q))),
           let .signingUp(_, _, .notSent(.some(q), _)): return q
      default: return nil
      }
    }
    var signingUp: Bool {
      switch questionsStatus {
      case .signingUp(_, _, .inFlight): return true
      default: return false
      }
    }
    
    var businessManages: BusinessManages? {
      switch questionsStatus {
      case let .signingUp(bm, _, _),
           let .answering(.left(bm), _): return bm
      default:
        return nil
      }
    }
    
    var managesFor: ManagesFor? {
      switch questionsStatus {
      case let .signingUp(_, mf, _),
           let .answering(.right(mf), _):
        return mf
      default:
        return nil
      }
    }
    
    var error: CognitoError? {
      switch questionsStatus {
      case let .signingUp(_, _, .notSent(_, .some(er))),
           let .answering(_, .right(er)):
        return er
      default:
        return nil
      }
    }
    
    public init(questionsStatus: QuestionsStatus) {
      self.questionsStatus = questionsStatus
    }
  }
  public enum Action: Equatable {
    case businessManagesTapped
    case managesForTapped
    case businessManagesChanged(BusinessManages?)
    case managesForChanged(ManagesFor?)
    case deselectQuestions
    case backButtonTapped
    case acceptButtonTapped
    case cancelSignUpTapped
  }
  
  let state: State
  let send: (Action) -> Void
  @Environment(\.colorScheme) var colorScheme
  
  public init(
    state: State,
    send: @escaping (Action) -> Void
  ) {
    self.state = state
    self.send = send
  }
  
  public var body: some View {
    GeometryReader { geometry in
      VStack {
        Title(title: "Sign up for a new account")
        Text(" ")
          .font(.smallMedium)
        HStack {
          Rectangle()
            .frame(width: 8, height: 8)
            .foregroundColor(.dodgerBlue)
            .cornerRadius(4)
          Rectangle()
            .frame(width: 24, height: 8)
            .foregroundColor(state.questionsAnswered ? Color.dodgerBlue : .ghost)
            .animation(.default)
            .cornerRadius(4)
        }
        VStack(spacing: 0) {
          Section {
            HStack {
              Text("My business manages:")
                .font(.normalMedium)
              Spacer()
              Button((state.businessManages.map(toAnswer(_:)) ?? answerNotSet).rawValue) {
                if state.questionSelected == .some(.businessManages) {
                  send(.deselectQuestions)
                } else {
                  send(.businessManagesTapped)
                }
              }
              .animation(nil)
              .font(.normalMedium)
              .lineLimit(1)
            }
            .padding(.top, 13)
            .padding(.bottom, state.questionSelected == .some(.businessManages) ? 0 : CGFloat(13))
            .padding(.horizontal, 16)
            if state.questionSelected == .some(.businessManages) {
              HStack {
                Picker(
                  selection: Binding<BusinessManagesQuestions>(
                    get: { toQuestion(state.businessManages) },
                    set: { send(.businessManagesChanged(fromQuestions($0))) }
                  ),
                  label: Text("")
                ) {
                  Text(answerNotSet.rawValue).tag(BusinessManagesQuestions.notSet)
                  Text(toAnswer(.deliveries).rawValue).tag(BusinessManagesQuestions.deliveries)
                  Text(toAnswer(.visits).rawValue).tag(BusinessManagesQuestions.visits)
                  Text(toAnswer(.rides).rawValue).tag(BusinessManagesQuestions.rides)
                }
                .onTapGesture {
                  send(.deselectQuestions)
                }
              }
              .padding(.horizontal, 16)
              .animation(.default)
            }
          }
          .frame(width: geometry.size.width)
          .background(colorScheme == .dark ? Color.gunPowder : .white)
          Spacer()
            .frame(height: 1)
          Section {
            HStack {
              Text("for")
                .font(.normalMedium)
              Spacer()
              Button((state.managesFor.map(toAnswer(_:)) ?? answerNotSet).rawValue) {
                if state.questionSelected == .some(.managesFor) {
                  send(.deselectQuestions)
                } else {
                  send(.managesForTapped)
                }
              }
              .animation(nil)
              .font(.normalMedium)
              .lineLimit(1)
            }
            .padding(.top, 13)
            .padding(.bottom, state.questionSelected == .some(.managesFor) ? 0 : CGFloat(13))
            .padding(.horizontal, 16)
            if state.questionSelected == .some(.managesFor) {
              HStack {
                Picker(
                  selection: Binding<ManagesForQuestions>(
                    get: { toQuestion(state.managesFor) },
                    set: { send(.managesForChanged(fromQuestions($0))) }
                  ),
                  label: Text("")
                ) {
                  Text(answerNotSet.rawValue).tag(ManagesForQuestions.notSet)
                  Text(toAnswer(.myFleet).rawValue).tag(ManagesForQuestions.myFleet)
                  Text(toAnswer(.myCustomersFleet).rawValue).tag(ManagesForQuestions.myCustomersFleet)
                }
                .onTapGesture {
                  send(.deselectQuestions)
                }
              }
              .padding(.horizontal, 16)
              .animation(.default)
            }
          }
          .frame(width: geometry.size.width)
          .background(colorScheme == .dark ? Color.gunPowder : .white)
        }
        if let error = state.error {
          HStack {
            Text(error.string)
              .lineLimit(3)
              .font(.smallMedium)
              .foregroundColor(.radicalRed)
            Spacer()
          }
          .padding(.horizontal, 16)
        }
        HStack {
          SecondaryButton(title: "Back") {
            send(.backButtonTapped)
          }
          .frame(width: 55)
          .padding(.trailing, 20)
          PrimaryButton(
            variant: state.questionsAnswered ?
              state.signingUp ? .destructive() : .normal(title: "Accept & Continue")
              : .disabled(title: "Accept & Continue"),
            showActivityIndicator: state.signingUp,
            truncationMode: nil
          ) {
            if state.signingUp {
              send(.cancelSignUpTapped)
            } else {
              send(.acceptButtonTapped)
            }
          }
        }
        .padding(.top, 16)
        .padding(.horizontal, 16)
        LinkedText(
          .text(
            "By clicking on the Accept & Continue button I agree to ",
            next: .link(
              URL(string: "https://www.hypertrack.com/terms")!,
              text: "Terms of Service",
              next: .text(
                " and ",
                next: .endingWithLink(
                  URL(string: "https://www.hypertrack.com/agreement")!,
                  text: "HyperTrack SaaS Agreement"
                )
              )
            )
          )
        )
        .frame(width: geometry.size.width - 32)
        .clipped()
        Spacer()
      }
      .animation(.default)
      .modifier(AppBackground())
      .edgesIgnoringSafeArea(.all)
      .onTapGesture {
        send(.deselectQuestions)
      }
    }
  }
}

let answerNotSet: NonEmptyString = "Not set"

enum BusinessManagesQuestions: String, Identifiable {
  case visits
  case deliveries
  case rides
  case notSet
  
  var id: String { self.rawValue }
}

enum ManagesForQuestions: String, Identifiable {
  case myFleet
  case myCustomersFleet
  case notSet
  
  var id: String { self.rawValue }
}

func fromQuestions(_ bm: BusinessManagesQuestions) -> BusinessManages? {
  switch bm {
  case .visits:     return .visits
  case .deliveries: return .deliveries
  case .rides:      return .rides
  case .notSet:     return nil
  }
}

func fromQuestions(_ mf: ManagesForQuestions) -> ManagesFor? {
  switch mf {
  case .myFleet:          return .myFleet
  case .myCustomersFleet: return .myCustomersFleet
  case .notSet:           return nil
  }
}

func toQuestion(_ bm: BusinessManages?) -> BusinessManagesQuestions {
  switch bm {
  case .none:              return .notSet
  case .some(.visits):     return .visits
  case .some(.deliveries): return .deliveries
  case .some(.rides):      return .rides
  }
}

func toQuestion(_ mf: ManagesFor?) -> ManagesForQuestions {
  switch mf {
  case .none:                    return .notSet
  case .some(.myFleet):          return .myFleet
  case .some(.myCustomersFleet): return .myCustomersFleet
  }
}

func toAnswer(_ bm: BusinessManages) -> NonEmptyString {
  switch bm {
  case .visits:     return "Visits"
  case .deliveries: return "Deliveries"
  case .rides:      return "Rides"
  }
}

func toAnswer(_ mf: ManagesFor) -> NonEmptyString {
  switch mf {
  case .myFleet:          return "My fleet"
  case .myCustomersFleet: return "My customer's fleet"
  }
}

struct SignUpQuestionsScreen_Previews: PreviewProvider {
  static var previews: some View {
    SignUpQuestionsScreen(
      state: .init(
        questionsStatus: .answering(
          .right(.myCustomersFleet),
          .left(.businessManages)
        )
      ),
      send: {_ in }
    )
    .previewScheme(.dark)
  }
}
