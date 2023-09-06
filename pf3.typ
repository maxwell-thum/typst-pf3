/*
  pf3
  Written by Maxwell Thum (@maxwell-thum on GitHub)
  Last modified: September 5, 2023 
  
  Based on the LaTeX style "pf2" by Leslie Lamport (https://lamport.azurewebsites.net/latex/pf2.sty)
  See also "How to Write a 21st Century Proof" by Lamport (2011) (https://lamport.azurewebsites.net/pubs/proof.pdf)
*/
/*
  TODO: 
  - When custom elements are added to Typst, make #pfstep one so that its behaviors can be customized throughout a document using set rules.
*/
#let currentstep = state("currentstep", (0,)) // array of integers representing the current step
#let pfdict = state("pfdict", (:)) // dictionary of steps corresponding to each label. currently steps are stored as a pair (array, string/content). this is because it is easier to find the proof depth from the array than the string (for qed throwing out steps which should no longer be referenced), but seemingly very difficult or impossible for #stepref to correctly format the step number given that its format in #pfstep is determined by a parameter of #pfstep. 


// these produce the corresponding text and indent the argument for visual clarity
#let assume(cont) = grid(
  columns: (4.5em, 1fr),
  smallcaps("Assume:"), cont
)
#let prove(cont) = grid(
  columns: (4.5em, 1fr),
  smallcaps("Prove:"), cont
)

#let case(cont) = grid(
  columns: 2,
  smallcaps("Case:") + h(0.25em), cont
)
#let suffices(cont) = grid(
  columns: 2,
  smallcaps("Suffices:") + h(0.25em), cont
)

#let pflet(cont) = grid(
  columns: 2,
  smallcaps("Let:") + h(0.25em), cont
)
#let pfdef(cont) = grid(
  columns: 2,
  smallcaps("Define:") + h(0.25em), cont
)

// these just produce text
#let pf = smallcaps("Proof:")
#let pfsketch = smallcaps("Proof sketch:")

// ideally this (or your favorite alternative symbol) is placed at the end of every *completed* paragraph proof. i imagine this will helps one keep track of unfinished proofs.
#let qed = math.qed


#let shortstepnumbering(steparray) = [#sym.angle.l] + str(steparray.len()) + [#sym.angle.r#steparray.at(-1)]

// step of a structured proof.
#let pfstep(
  hidepf: false, // you can optionally hide a specific step's proof.
  pfhidelevel: 128, // deepest proof level to show. (optional; intended only to be customized with set rules once custom elements are added to Typst)
  pflongindent: false, // if set to true, each indent is the full length of the step number. (optional; ditto)
  pfmixednumbers : 1, // use short step numbers for all levels >= N. (optional; ditto)
  pflongnumbers : false, // use long step numbers for all levels. in practice you could also just set pfmixednumbers to be very large. (optional; ditto)
  steplabel, // step name label for referencing (note this is required)
  claim, // text/claim of step
  pf_content // proof of step
) = {
  // increment current step number
  currentstep.update(x => {
    x.push(x.pop()+1)
    return x
  })

  locate(loc => {
    let currentstep_array = currentstep.at(loc) // current step number array
    
    // corresponding formatted step number
    let currentstep_number = {
      if currentstep_array.len() >= pfmixednumbers and not pflongnumbers {
        shortstepnumbering(currentstep_array)
      } else {
        currentstep_array.map(str).join(".")
      }
    }

    // add label/step number pair to dictionary
    pfdict.update(x => {
      x.insert(steplabel, (currentstep_array,currentstep_number))
      return x
    })
    
    if pflongindent { 
      grid(
        columns: 2,
        rows: 1,
        currentstep_number + "." + h(0.25em),
        [
          #claim
    
          // show this step if the proof depth is <= pfhidelevel and it hasn't been hidden manually
          #if (not hidepf and currentstep_array.len() < pfhidelevel ) {
            // now that we might add substeps, add a 0 to the end of the step number array
            currentstep.update(x => {
              x.push(0)
              return x
            })
            
            pf_content
            
            // after the step is proved, remove the leftover substep index
            currentstep.update(x => {
              x.pop()
              return x
            })
          }
        ]
      )
    } else [
      // display the proof number followed by the step's claim
      #grid(
        columns: 2,
        rows: 1,
        currentstep_number + "." + h(0.25em),
        [#claim]
      )
  
      // show this step if the proof depth is <= pfhidelevel and it hasn't been hidden manually
      #if (not hidepf and currentstep_array.len() < pfhidelevel ) {
        // now that we might add substeps, add a 0 to the end of the step number array
        currentstep.update(x => {
          x.push(0)
          return x
        })
        
        // indent the proof of the step 
        pad(left: 1em, pf_content) 
        
        // after the step is proved, remove the leftover substep index
        currentstep.update(x => {
          x.pop()
          return x
        })
      }
    ]

    
  })
}

// final proof step (necessary for top-level proofs!)
#let qedstep(pf_content) = {
  pfstep("qed", "Q.E.D.", pf_content) // display a proof step with generic "qed" label and claim "Q.E.D."
  
  // (only needed for top-level steps) at the end of the step, reset the lowest-level step counter to 0
  currentstep.update(x => {
    x.last() = 0
    return x
  })

  // remove the "qed" key from the dictionary
  locate(loc => if pfdict.at(loc).keys().contains("qed") {
    pfdict.update(x => {
      x.remove("qed")
      return x
  })})

  // remove the dictionary keys of the previous steps at this level so they can no longer be referred to
  locate(loc => pfdict.update(x => {
    for steplabel in x.keys() {
      if x.at(steplabel).first().len() >= currentstep.at(loc).len() {
        x.remove(steplabel)
      }
    }
    return x
  }))
}

#let stepref(steplabel) = locate(loc => pfdict.at(loc).at(steplabel).last())
