# SvgVectorView

A pure Swift/SwiftUI view that renders SVG path data.

This is is the bare minimum that I needed for my project - not all SVG commands are supported - pull requests welcome.

An example:

```swift
struct SvgVector_Previews: PreviewProvider {
    static var previews: some View {
        SvgVectorView(pathData:  square)
            .frame(width: 100, height: 100)
        SvgVectorView(pathData:  circle)
            .frame(width: 100, height: 100)
        SvgVectorView(pathData:  key)
            .scaleEffect(CGSize(width: 0.25, height: 0.25))
            .frame(width: 200, height: 200)
        
    }
    static let circle = "M48,24c0,13.255-10.745,24-24,24S0,37.255,0,24S10.745,0,24,0S48,10.745,48,24z"
    static let square = "M32,12H16c-2.2,0-4,1.8-4,4v16c0,2.2,1.8,4,4,4h16c2.2,0,4-1.8,4-4V16C36,13.8,34.2,12,32,12z M34,32c0,1.103-0.897,2-2,2H16c-1.103,0-2-0.897-2-2V16c0-1.103,0.897-2,2-2h16c1.103,0,2,0.897,2,2V32z"
    static let key = """
M356.5 16.375l-174.906 255.22 1.53 1.06 31.97 22.314 175.062-255.5L356.5 16.374zm90.063 62.22c-20.16 29.418-44.122 23.1-68.25 8.905l-48.688 72.875c21.278 16.55 36.46 35.645 18.594 61.72l42.967 29.468 28.907-42.157-14.72-9.156c-3.167 1.844-6.85 2.906-10.78 2.906-11.85 0-21.47-9.62-21.47-21.47 0-11.847 9.62-21.436 21.47-21.436s21.437 9.59 21.437 21.438c0 .195-.025.4-.03.593l15.906 9.907 17.938-26.218-37.688-23.5 11.03-17.72 14.94 9.313 10.093-16.188 24.25 15.094 17.092-24.94-43-29.436zM141.22 268.624c-.31.01-.628.023-.94.063-.827.104-1.652.284-2.53.562-3.51 1.11-7.4 4.066-10.125 7.938-2.724 3.87-4.16 8.487-4 12.125.16 3.637 1.257 6.338 5.25 9.125l76.594 53.468c3.283 2.293 5.727 2.35 9.124 1.156 3.396-1.192 7.323-4.26 10.125-8.218 2.8-3.96 4.352-8.66 4.31-12.188-.04-3.53-.89-5.787-4.374-8.22L148.03 270.97c-2.546-1.78-4.657-2.42-6.81-2.345zM84.28 312.78c-24.354.41-45.504 9.52-57.655 27.25-16.95 24.737-11.868 59.753 9.625 90.283-1.838 4.72-2.875 9.84-2.875 15.187 0 23.243 19.07 42.313 42.313 42.313 8.635 0 16.692-2.625 23.406-7.125 43.208 18.488 88.07 12.714 108.28-16.782 18.695-27.28 10.884-66.912-16.374-99.312l-63.094-44.03c-14.016-5.107-28.07-7.7-41.25-7.783-.792-.004-1.59-.012-2.375 0zm-8.593 109.126c13.143 0 23.594 10.45 23.594 23.594 0 13.143-10.45 23.625-23.593 23.625-13.142 0-23.624-10.482-23.624-23.625s10.482-23.594 23.624-23.594z
"""
}
```
Produces

![An example](example.PNG)


## How it works
I've a parser that walks through the SVG and generates `Commands` (an enum) which are then processed generating a `Path`.

All the code is in [Sources\SvgVectorView\SvgVectorView.swift](Sources\SvgVectorView\SvgVectorView.swift)