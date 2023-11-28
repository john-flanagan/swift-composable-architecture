import SwiftUI

@available(iOS, deprecated: 17, message: "TODO")
public enum PerceptionLocals {
  @TaskLocal public static var isInPerceptionTracking = false
}

@available(iOS, deprecated: 17, message: "TODO")
@MainActor
public struct WithPerceptionTracking<Content: View>: View {
  @State var id = 0
  let content: () -> Content
  public init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content
  }
  public var body: Content {
    if #available(iOS 17, *) {  // TODO: other platforms
      return self.content()
    } else {
      let _ = self.id
      return withPerceptionTracking {
        PerceptionLocals.$isInPerceptionTracking.withValue(true) {
          self.content()
        }
      } onChange: {
        Task { @MainActor in
          self.id += 1
        }
      }
    }
  }
}

@resultBuilder
@MainActor
public enum ObservedBody {
  /// Wrap the final result in a `WithPerceptionTracking` view
  public static func buildFinalResult<Content>(_ content: Content) -> WithPerceptionTracking<Content> {
    WithPerceptionTracking<Content> { content }
  }

  /// Pass through remaining result builder methods to `SwiftUI.ViewBuilder`

  public static func buildExpression<Content: View>(_ content: Content) -> Content {
    ViewBuilder.buildExpression(content)
  }

  public static func buildBlock() -> EmptyView {
    ViewBuilder.buildBlock()
  }

  public static func buildBlock<Content: View>(_ content: Content) -> Content {
    ViewBuilder.buildBlock(content)
  }

  public static func buildBlock<each Content: View>(_ content: repeat each Content) -> TupleView<(repeat each Content)> {
    ViewBuilder.buildBlock(repeat each content)
  }

  public static func buildIf<Content: View>(_ content: Content?) -> Content? {
    ViewBuilder.buildIf(content)
  }

  public static func buildEither<TrueContent: View, FalseContent: View>(first: TrueContent) -> _ConditionalContent<TrueContent, FalseContent> {
    ViewBuilder.buildEither(first: first)
  }

  public static func buildEither<TrueContent: View, FalseContent: View>(second: FalseContent) -> _ConditionalContent<TrueContent, FalseContent> {
    ViewBuilder.buildEither(second: second)
  }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension ObservedBody {
  public static func buildLimitedAvailability<Content: View>(_ content: Content) -> AnyView {
    ViewBuilder.buildLimitedAvailability(content)
  }
}
