import SwiftUI

@available(iOS, deprecated: 17, message: "TODO")
public enum PerceptionLocals {
  @TaskLocal public static var isInPerceptionTracking = false
}

@available(iOS, deprecated: 17, message: "TODO")
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

public struct DeferredContent<Content: View> {
  let content: () -> Content
}

@resultBuilder
public enum ObservedBody {
  /// Wrap the final result in a `WithPerceptionTracking` view
  public static func buildFinalResult<Content: View>(_ content: DeferredContent<Content>) -> WithPerceptionTracking<Content> {
    WithPerceptionTracking<Content>(content: content.content)
  }

  public static func buildExpression<Content: View>(_ content: @autoclosure @escaping () -> Content) -> DeferredContent<Content> {
    DeferredContent(content: content)
  }

  public static func buildBlock() -> DeferredContent<EmptyView> {
    DeferredContent { EmptyView() }
  }

  public static func buildBlock<Content>(_ content: DeferredContent<Content>) -> DeferredContent<Content> {
    content
  }

  public static func buildBlock<each Content: View>(
    _ content: repeat DeferredContent<each Content>
  ) -> DeferredContent<TupleView<(repeat each Content)>> {
    DeferredContent(content: { ViewBuilder.buildBlock(repeat (each content).content()) })
  }

  public static func buildIf<Content: View>(_ content: DeferredContent<Content>?) -> DeferredContent<Content?> {
    DeferredContent(content: { content?.content() })
  }

  public static func buildEither<TrueContent: View, FalseContent: View>(
    first: DeferredContent<TrueContent>
  ) -> DeferredContent<_ConditionalContent<TrueContent, FalseContent>> {
    DeferredContent(content: { ViewBuilder.buildEither(first: first.content()) })
  }

  public static func buildEither<TrueContent: View, FalseContent: View>(
    second: DeferredContent<FalseContent>
  ) -> DeferredContent<_ConditionalContent<TrueContent, FalseContent>> {
    DeferredContent(content: { ViewBuilder.buildEither(second: second.content()) })
  }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension ObservedBody {
  public static func buildLimitedAvailability<Content: View>(_ content: DeferredContent<Content>) -> DeferredContent<AnyView> {
    DeferredContent(content: { ViewBuilder.buildLimitedAvailability(content.content()) })
  }
}
