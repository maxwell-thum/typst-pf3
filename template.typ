#let project(title: "", authors: (), body) = {
  // Set the document's basic properties.
  set document(author: authors, title: title)
  set page(paper: "us-letter")
  set text(font: "New Computer Modern", lang: "en")
  show math.equation: set text(weight: 400)
  set par(justify: true)


  body
}