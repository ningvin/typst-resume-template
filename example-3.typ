#import "resume.typ": *

#show: resume.with(
  name: "Max Mustermann",
  job-title: "Developer",
)

#image(width: 100%, "user-banner.png")

= Experience

#time-line(
  events: (
    (
      date: [since 2020],
      details: [
        *Job 2* \
        _Company 2_
        #{
          set par(justify: true)
          lorem(26)
        }
      ],
      add-height: 3.5em
    ),
    (
      date: [2019 - 2020],
      details: [
        *Job 1* \
        _Company 1_
        - bullet point 1
        - bullet point 2
      ]
    ),
  )
)

= Education

#time-line(
  events: (
    (
      date: [since 2023],
      details: [
        *Degree 3* \
        _Name of University_
        - detail 1
        - detail 2
        - detail 3
        - detail 4
      ]
    ),
    (
      date: [2020 - 2023],
      details: [
        *Degree 2* \
        _Name of University_
        #{
          set par(justify: true)
          lorem(26)
        }
      ]
    ),
  )
)

#time-line(
  events: (
    (
      date: [2014 - 2017],
      details: [
        *Degree 1* \
        _Name of University_
        - detail 1
        - detail 2
      ]
    ),
    (
      date: [2014],
      details: [
        *School Diploma* \
        _Name of School_
        - final grade
      ]
    ),
  )
)

#side-section[
  = Contact

  #icon-list(
    center-icons: false,
    items: (
      (
        icon: icons.location,
        body: [
          *Address* \
          Street & Number \
          ZIP Code & City
        ]
      ),
      (
        icon: icons.envelope,
        body: [
          *Email* \
          max.mustermann \
          \@pm.me
        ]
      ),
      (
        icon: icons.mobile,
        body: [
          *Phone* \
          +49 1234 5678
        ]
      ),
    )
  )
]

#side-section[
  = Languages

  #outline-skill-bar(
    skill: "German",
    description: "native",
    value: 1.0
  )

  #outline-skill-bar(
    skill: "English",
    description: "business fluent",
    value: 0.8
  )

  #outline-skill-bar(
    skill: "Dutch",
    description: "basic",
    value: 0.45
  )
]

#side-section[
  = Technologies

  #grid(
    columns: (1fr, 1fr),
    gutter: 0.5em,

    "Word",
    outline-skill-bar(
      value: 0.9
    ),
    "Excel",
    outline-skill-bar(
      value: 0.75
    ),
    "PowerPoint",
    outline-skill-bar(
      value: 1.0 // certified beast
    ),
  )
]
