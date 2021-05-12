import NonEmpty
import Prelude
import SwiftUI
import Tagged
import Types
import Views


public struct SignUpQuestionsScreen: View {
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
  
  let state: SignUpState.Questions.Status
  let send: (Action) -> Void
  @Environment(\.colorScheme) var colorScheme
  
  var questionsAnswered: Bool {
    switch state {
    case     .signingUp:   return true
    case let .answering(a):
      switch (a.businessManages, a.managesFor) {
      case (.some, .some): return true
      default:             return false
      }
    }
  }
  
  var questionSelected: SignUpState.Questions.Status.Answering.Focus? {
    switch state {
    case let .answering(a): return a.focus
    case     .signingUp:    return nil
    }
  }
  var signingUp: Bool {
    switch state {
    case .signingUp: return true
    case .answering: return false
    }
  }
  
  var businessManages: BusinessManages? {
    switch state {
    case let .answering(a): return a.businessManages
    case let .signingUp(s): return s.businessManages
    }
  }
  
  var managesFor: ManagesFor? {
    switch state {
    case let .answering(a): return a.managesFor
    case let .signingUp(s): return s.managesFor
    }
  }
  
  var error: CognitoError? {
    switch state {
    case let .answering(a): return a.error
    case     .signingUp:    return nil
    }
  }
  
  public init(
    state: SignUpState.Questions.Status,
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
            .foregroundColor(questionsAnswered ? Color.dodgerBlue : .ghost)
            .animation(.default)
            .cornerRadius(4)
        }
        VStack(spacing: 0) {
          Section {
            HStack {
              Text("My business manages:")
                .font(.normalMedium)
              Spacer()
              Button((businessManages.map(toAnswer(_:)) ?? answerNotSet).rawValue) {
                if questionSelected == .some(.businessManages) {
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
            .padding(.bottom, questionSelected == .some(.businessManages) ? 0 : CGFloat(13))
            .padding(.horizontal, 16)
            if questionSelected == .some(.businessManages) {
              HStack {
                Picker(
                  selection: Binding<BusinessManagesQuestions>(
                    get: { toQuestion(businessManages) },
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
              Button((managesFor.map(toAnswer(_:)) ?? answerNotSet).rawValue) {
                if questionSelected == .some(.managesFor) {
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
            .padding(.bottom, questionSelected == .some(.managesFor) ? 0 : CGFloat(13))
            .padding(.horizontal, 16)
            if questionSelected == .some(.managesFor) {
              HStack {
                Picker(
                  selection: Binding<ManagesForQuestions>(
                    get: { toQuestion(managesFor) },
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
        if let error = error {
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
            variant: questionsAnswered ?
              signingUp ? .destructive() : .normal(title: "Accept & Continue")
              : .disabled(title: "Accept & Continue"),
            showActivityIndicator: signingUp,
            truncationMode: nil
          ) {
            if signingUp {
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
      state: .answering(
        .init(businessManages: .deliveries, managesFor: .myCustomersFleet)
      ),
      send: {_ in }
    )
    .previewScheme(.dark)
  }
}
