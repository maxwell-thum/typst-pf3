#import "template.typ": *
#import "lamproof.typ": *

#show: project

*Theorem 1: *

#pfstep("label-1")[Text of step 1.][
  #pfstep("label-1.1")[#case[
      Case 1
  ]][
    #pfsketch Brief sketch to get the intuition across.
    
    #pf Paragraph proof. #qed
  ]

  #pfstep("label-1.2")[#case[
    Case 2
  ]][
    #pfstep("label-1.2.1")[Text of step][
      #pfstep("label-1.2.1.1")[
        #assume[
          1. a
          2. b
          3. c
        ]
        #prove[
          + d
          + e
        ]
      ][
        #pf #lorem(20) #qed
      ]

      #qedstep[#pf by contradiction #qed]
    ]
    #qedstep[#pf by example #qed]
  ]

  #qedstep[
    #pf By #stepref("label-1.1") and #stepref("label-1.2"). #qed
  ]
]

#pflet[
  $alpha := 2^sigma$
]

#pfstep("label-2")[
  #suffices[
    ...
  ]
  ][
  #pf By #stepref("label-1"), ... #qed
]

#qedstep[
  #pf ... #qed
]

*Claim 2: *

#pfstep("label-1")[Step 1 of claim 2][
  #pf ... #qed
]

#qedstep[
  #pf ... #qed
]
