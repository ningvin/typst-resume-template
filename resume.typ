// used to collect side sections
#let side-sections = state("side-sections", ())

// function that lets you create a fancy resume;
// the resume is divided into two parts:
//   - the main content panel
//   - a side panel to the left of it
#let resume(
  // the title; not displayed anywhere, but put into the document's metadata
  document-title: "Resume",
  // your name
  name: "",
  // an optional image to show in the title of the side panel
  image-path: none,
  // a job title (or anything really) to display below your name (optional)
  job-title: none,
  // the font to use throughout the resume
  font: "Roboto",

  // various spacing/margin settings
  margin-x: 1.3cm,
  margin-y: 2cm,
  side-panel-width: 6cm,
  main-content-margin-left: 0.8cm,

  // the primary color is used for the main content, as well as the
  // background of the side panel
  primary-color: rgb(40, 40, 40),
  secondary-color: white,

  // the actual resume content; filled automagically when using
  // the show rule from the examples
  body
) = {
  // set metadata
  set document(title: document-title, author: name)

  // apply font
  set text(font: font)

  // setup page
  set page(
    margin: (
      left: margin-x,
      top: margin-y,
      right: margin-x,
      bottom: margin-y
    ),
    // colored background for side panel
    background: place(
      dx: margin-x,
      left + top,
      rect(
        fill: primary-color,
        height: 100%,
        width: side-panel-width
      )
    )
  )

  // helper function/hack to change the alpha value
  // of a given color; as of me writing this, there
  // is no such function in typst as far as I am
  // aware
  let change-opacity(
    // the new alpha to apply; has to be passed as a hex string
    alpha: "c8",
    // the original color, expected to not have an alpha value yet,
    // i.e. be of the form rgb("#......") and NOT rgb("#........")
    color
  ) = {
    // example: color = white
    let to-str = repr(color)
    // example: to-str is now equal to "rgb(\"#ffffff\")"
    let trimmed = to-str.trim(at: start, "rgb(\"").trim(at: end, "\")")
    // example: trimmed is now equal to "#ffffff"
    return rgb(trimmed + alpha)
  }

  // build the title content, that is:
  //   - name (+ optinal job description/subtitle)
  //   (- optional image)
  let title = {
    let name-row-gutter = 1em
    // adjust gutter in case no job title is given
    // to avoid extra empty space
    if job-title == none {
      name-row-gutter = 0em
    }

    // helper function to construct the name content with
    // variable background transparency
    let make-name(
      // background transparency of the block enclosing the name
      background-alpha: "ff"
    ) = {
      block(
        inset: (x: 1em, y: 1em),
        width: 100%,
        fill: change-opacity(alpha: background-alpha, secondary-color),

        {
          // align the name and job title as a whole to the center
          align(center + horizon,
            grid(
              columns: (auto,),
              rows: (auto, auto),
              row-gutter: name-row-gutter,

              align(
                left,
                text(
                  size: 18pt,
                  weight: 800,
                  name
                )
              ),
              if job-title != none {
                // again, the job title is optional
                align(
                  left,
                  text(
                    size: 11pt,
                    weight: 500,
                    job-title
                  )
                )
              }
            )
          )
        }
      )
    }

    if image-path != none {
      // an image has been supplied
      let image-obj = image(width: side-panel-width, image-path)

      // grab the current style...
      style(styles => {
        // ...to measure the image's height
        let image-height = measure(image-obj, styles).height

        box(
          // seems to need explicit height for the absolut placement
          // of the name content to work, otherwise the box takes up
          // the entire height of the page when "bottom" is specified
          // as placement for the name content
          height: image-height,
          {
            // the image...
            image(image-path)
            // ...overlayed by the semi transparent name content
            place(bottom, make-name(background-alpha:"c8"))
            // NOTE: getting overlapping stuff to work can be
            // a bit tricky; ensure that both objects are placed
            // in a common container (a box in this case) as
            // "place" works relative to the parent container
          }
        )
      })
    } else {
      // no image supplied, no worries: simply emit the name content
      // fully opaque
      make-name(background-alpha: "ff")
    }
  }

  // build the side panel content
  let side-panel-content = {
    block(
      inset: (x: 1em),
      // side sections are modelled as state, which I pretty much stole from
      // the official newsletter template; you could probably do this way
      // easier, but here goes...
      locate(loc => {
        // apply general font settings for all side sections
        set text(weight: 400)

        for element in side-sections.final(loc) {
          // change the way headings are styled in side sections;
          // each heading gets capitalized and an underline spanning
          // the whole available width is placed below
          show heading: it => {
            text(weight: 400, upper(it))
            v(0.5em)
          }

          // with the configuration and show rule for headings out of
          // the way, now follows the actual side section content
          element

          // the underline
          line(length: 100%)

          // as well as some weak spacing so consecutive side sections
          // are not all up and close to each other
          v(40pt, weak: true)
        }
      })
    )
  }

  // build the main content
  let main-content = {
    // again, style the headings in a fancy way
    show heading: it => {
      if it.level > 1 {
        // but only the top level ones
        it
      } else {
        grid(
          row-gutter: 0.5em,
          grid(
            columns: (auto, 1fr),
            column-gutter: 0.5em,
            // basically an arrow/angle bracket...
            align(horizon, image(height: 1.2em, "angle-right-solid.svg")),
            // ...followed by the actual heading text...
            align(horizon, text(weight: 400, upper(it)))
          ),
          // ...and an underline spanning the whole width placed below
          line(length: 100%)
        )
        // + some additional spacing
        v(1em)
      }
    }

    // the actual content
    body
  }

  // the overall page is structured as a grid with two columns,
  // one for the side panel on the left with a fixed width and
  // one for the main content panel, which will take up the
  // remaining space
  grid(
    columns: (side-panel-width, 1fr),
    column-gutter: main-content-margin-left,

    // for theming purposes, the different colors are applied
    // via the corresponding "set" commands; this is not perfect,
    // but I am not aware of a better way
    {
      // the side panel
      set line(stroke: secondary-color)
      set rect(fill: secondary-color, stroke: secondary-color)
      set text(fill: primary-color)
      // the title...
      title
      v(1em)
      set text(fill: secondary-color)
      // ...followed by the side panel content
      side-panel-content
    },
    {
      // the main content
      set line(stroke: primary-color)
      set rect(fill: primary-color)
      set circle(fill: primary-color, stroke: primary-color)
      set text(fill: primary-color)
      main-content
    }
  )
}

// add a section to the side panel
#let side-section(body) = side-sections.update(it => it + (body,))

// a time line of events to showcase in your resume, e.g.
// your degrees or previous jobs
#let time-line(
  // a list of events; each event is expected to be a dictionary
  // with the following entries:
  //   - "date": when the event happened; can be any content, e.g.:
  //      - a timespan ("2019 - 2023")
  //      - a date ("01.01.2020")
  //      - something else entirely
  //   - "details": a description of the event, e.g.:
  //      - job title, company and description of responsibilities
  //      - degree, university and grades
  //      - something else entirely
  //   - "add-height": optional hacky parameter to adjust the length
  //                   of the time line; only necessary if you supply
  //                   some text in the event details that is long
  //                   enough to be auto-wrapped; see the examples
  //                   for more information
  events: (),
) = {
  // need to make some measurements later, so grab the styles now
  style(styles => {
    let event-bubble-size = 0.7em // somewhat arbitrary, but works

    let index = 1
    let content = () // this is populated with the actual content

    // the time line is constructed as a grid of three columns:
    //   1. the dots and lines for the nice visuals
    //   2. the dates
    //   3. the details

    for event in events {
      // iterate over the events, producing a "flattened" array
      // of content that we can later pass to the "grid" function;
      // i.e. this:
      //   ((date-1, detail-1), (date-2, detail-2))
      // becomes this:
      //   (line-content-1, date-content-1, detail-content-1, line-content-2, date-content-2, detail-content-2)
      let details = {
        event.details
        if (index != events.len()) {
          // ajdust the spacing of consecutive events;
          // NOTE: we cannot simply set a row-gutter later
          // as that would result in gaps in the lines
          v(1em)
        }
      }

      // populate the content array
      content.push(
        // 1. the line content
        grid(
          rows: (event-bubble-size, auto),

          // a dot...
          circle(
            stroke: 1pt // to avoid single pixel gaps
            // NOTE: fill is derived from the top level "set" rules
          ),
          // ...followed by a vertical line, except for the last event
          // in the time line
          if index != events.len() {
            // specifying a size of 100% did not work for me, the height
            // seems to have to be fixed; the details column takes up the
            // most height in pretty much all the cases, so we need to match
            // it in height; therefore we need to measure it...
            let details-height = measure(details, styles).height
            // ...but this does not use the correct styles/spacing in this
            // context; this is problematic if the contents of the details
            // column are long enough to be auto-wrapped when placed in the
            // final three column grid, as the height measured above will
            // not take the reduced width into account (manual line breaks
            // will however not be a problem)
            if "add-height" in event {
              // therefore, the user can provide some additional height to
              // add the the line as a workaround/hack
              details-height += event.add-height
              // it may be possible to do some fancy state/query stuff to
              // calculate the height in the correct context, or there may
              // be an even simpler solution altogether
            }

            grid(
              // to center the line, we place it in a three column
              // grid where the outer two columns take up as much
              // space as possible
              columns: (1fr, 1pt, 1fr),

              none,
              rect(
                width: 1pt,
                height: details-height,
                stroke: none
              ),
              none
            )
          }
        )
      )
      // 2. the date content
      content.push(event.date)
      // 3. the details content
      content.push(details)

      index += 1
    }

    // now that the content has been flattened, place it in
    // the final grid
    grid(
      columns: (event-bubble-size, auto, 1fr),
      column-gutter: 1em,

      ..content
    )
  })
}

// display a "skill bar" showcasing your proficiency in a specific skill
#let skill-bar(
  // the name of the skill (optional)
  skill: none,
  // a description of your proficiency (optional)
  description: none,
  // a value between 0.0 and 1.0 corresponding to your proficiency
  value: 0.5,
  // the color used for the "unfilled" part; ideally this would be
  // derived from the theme colors automatically
  empty-color: rgb(220, 220, 220),
  // the height of the skill bar
  height: 0.5em
) = {
  if skill != none or description != none {
    [#box(strong(skill)) #h(1fr) #box(text(description))]
    // only adjust spacing if either skill or description are provided
    v(-7pt)
  }
  grid(
    // basically a single row grid with two columns that each containg a
    // colored box, sized based on the value parameter
    columns: (100% * value, 100% - (100% * value)),
    rows: (height),

    rect(width: 100%, height: 100%),
    box(fill: empty-color, width: 100%, height: 100%)
  )
}

// pretty much identical to the skill bar, but has an outline
// and the empty part is transparent
#let outline-skill-bar(
  // the name of the skill (optional)
  skill: none,
  // a description of your proficiency (optional)
  description: none,
  // a value between 0.0 and 1.0 corresponding to your proficiency
  value: 0.5,
  // the height of the skill bar
  height: 0.5em
) = {
  if skill != none or description != none {
    [#box(strong(skill)) #h(1fr) #box(text(description))]
    v(-7pt)
  }
  block(
    height: height,
    {
      rect(
        width: 100%,
        height: height,
        fill: none
      )
      place(
        top + left,
        rect(
          width: 100% * value,
          height: height,
          stroke: none
        )
      )
    }
  )
}

// show a list of items with icons as bullet points
#let icon-list(
  // a list of items; each item is expected to be a dictionary
  // with the following entries:
  //   - "icon": path to an image
  //   - "body": the item's content
  items: (),
  // bool indicating if the icons should be centered vertically
  // relative to the body
  center-icons: false
) = {
  for item in items {
    grid(
      columns: (2em, 1fr),

      // one column for the icon with fixed width
      align(
        if center-icons {
          center + horizon
        } else {
          center
        },
        image(height: 1em, item.icon)
      ),
      // one column for the actual content
      align(
        horizon,
        [#h(5pt) #box(item.body)]
      )
    )
  }
}

// dictionary to access the icons shipping with this template
// for convenience
#let icons = (
  envelope: "envelope-solid-white.svg",
  location: "location-dot-solid-white.svg",
  mobile: "mobile-solid-white.svg",
  phone: "phone-solid-white.svg"
)
