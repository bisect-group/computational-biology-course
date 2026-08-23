#import "@preview/touying:0.6.1": *
#import themes.metropolis: *
#import "@preview/fletcher:0.5.8" as fletcher: node, edge, diagram, shapes
#import "@preview/gentle-clues:1.3.1": *
#import "@preview/lilaq:0.6.0" as lq
#set text(font: "Aptos")
#show bibliography: none
#set figure(
  numbering: none
)
#let diagram = touying-reducer.with(
reduce: fletcher.diagram, cover: fletcher.hide)
// #set math.equation(numbering: "(1)")
#let tick = emoji.checkmark.box
#show: metropolis-theme.with(
  config-common(
    // handout: true // Uncomment if you want to collapse animations
  ),
  config-colors(
  primary: rgb("#04364A"),
  secondary: rgb("#176B87"),
  tertiary: rgb("#448C95"),
  neutral-lightest: rgb("#ffffff"),
  neutral-darkest: rgb("#000000"),
),
  config-info(
  title: text(size: 36pt)[*BLAST: Heuristic Alignment Algorithms*],
  author: text(size: 28pt)[*Nirav Bhatt*],
  institution: [
    #text(size: 20pt)[Wadhwani School of Artificial Intelligence (WSAI), IIT Madras]
    // #v(2cm)
    #stack(
      dir: ltr,
      spacing: 1fr,
      image("/pictures/WSAI Logo.png", height: 3cm),
      image("/pictures/iitm.png", height: 3cm),
    )
  ],
  // date: datetime.today().display(),
  // logo: ...   <- remove or comment out this line
),
  aspect-ratio: "16-9",
  footer: self => {
    set text(size: 12pt, fill: black)
    [Basic Local Alignment Search Tool (BLAST) #h(1fr)]
  },
  // header: self => self.info.title,
  // header-right: self => self.info.logo,
)
// #set heading(numbering: "1.1")
#set table(
  stroke: (1pt + gray)
)
#let cornflowerblue = rgb("#6495ED")
#let blue_box(title: none, icon: none, color: cornflowerblue, ..args) = clue(
// Define default values.
accent-color: color,
title: title,
icon: icon,
// Pass along all other arguments
..args
)
#let question = blue_box.with(title: "Question", icon: emoji.quest.white)
#let answer = blue_box.with(title: "Answer", icon: emoji.checkmark.box, color:green)
#let definition = blue_box.with(color: red)


#bibliography("/references.bib", style: "apa")

#title-slide()

== Recapping Alignment

- Recall sequence alignment
- It is a method to compare two sequences #pause
- It involves deciding a scoring matrix and dynamic programming to arrange sequences to maximize similarity #pause
- Alignments are of two types:
  - Global Alignment - Comparing two sequences in their entirety #pause
  - Local Alignment - Identifying conserved regions between two regions #pause
- There can be multiple local alignments between sequences


== Motivation

- Let's consider a scenario: You have obtained a DNA sequence from your experiment #pause
- Some natural questions that follow:
  - Is this a novel or pre-existing sequence? #pause
  - If it is a novel sequence, are there similar sequences that will help me understand its function? #pause
- *Both* the above questions can be addressed by comparing our sequence with those in the database

#alternatives[
  #question[For comparing sequences which alignment do we use - local or global?]
][
  #answer[#align(center, text(size: 24pt)[*Local!*])]
] 

#pause
#pause
-  Why? Because when comparing distant sequences, it is more likely that a given sequences will be conserved at small regions rather than the entire length of the sequences

== The multiplicative complexity of simple alignments

- Let's consider a query sequence of length $q$ and we want to search $n$ sequences in a database $D$ with average length $d$ #pause
- The time complexity of one Smith-Waterman alignment run is $cal(O)(q d)$ #pause
- For the entire database: $cal(O)(n q d)$ #pause
- The number of sequences in a database ($n$) is extremely large, therefore running multiple alignments is time consuming.
- *Solution:* Use Heuristics
#definition(title: "Definition: Heuristics")[
  Heuristic are strategies designed to efficiently tackle complex problems by providing approximate solutions when exact methods are impractical.
]

== Basic Local Alignment Search Tool (BLAST) 

- The Basic Local Alignment Search Tool (BLAST) was first described in 1990 by Altschul et al. to allow fast database searches 
- The goal: Given a query sequence, $Q$, of length $q$, and a database sequence, D, of length n, find all *ungapped local alignments* with score at least $S_"cutoff"$. 
- Here, $S$ is the alignment score, calculated using a scoring matrix

#example(title: "Example scoring matrix for DNA comparison")[
  #set align(center)
  #table(
    columns: 5, inset: 0.3em,
    none,[A],[T],[G],[C],
    [A],[+2],[-1],[+1],[-1],
    [T],[-1],[+2],[-1],[1],
    [G],[1],[-1],[+2],[-1],
    [C],[-1],[+1],[-1],[+2],
  )
]


// #let alignment_table()
#let match(value) = {
    text(fill: green.darken(25%),)[#value]
  }

#let mismatch(value) = {
  text(fill: red.lighten(20%),)[#value]
}

#let alignment_grid = {
  grid.with(
  column-gutter: 0pt, inset: 0pt, row-gutter: 5pt,
)
}

== Maximal Segment Pair

- Before proceeding to understand BLAST, a few definitions:

#definition(title: "Definition: Maximal Segment Pair (MSP)")[
  A maximal segment pair (MSP) is the highest-scoring *ungapped local alignment* between* two equal-length substrings*. An MSP is *locally maximal* if the score cannot be increased by extending or shortening the alignment. 
]
#example[
  
  #set align(center)
  // INFOR#text(fill: green.darken(25%))[MATION] \
  // #h(0.4em)AUTO#text(fill: green.darken(25%))[MATION]

  #alignment_grid(
    columns: 11,
    [I],[N],[F],[O],[R], match("M"), match("A"), match("T"),match("I"), match("O"), match("N"),
    [],[A],[U],[T],[O], match("M"), match("A"), match("T"),match("I"), match("O"), match("N"),
  )
  
]

- The goal of BLAST is to identify all *Locally Maximum Segment Pairs* between the query and database sequence. These are also known as *High Scoring Pairs (HSPs)*



== $k$-mers

#definition(title: [Definition: $k$-mer and $k$-mers])[
  $k$-mer is a contiguous string of length $k$. $k$-mers is a set of all the
contiguous substrings of length k that are contained in a given string
]
- k-mers for a sequence “TATGGGGTGC”
- k=1, {T, A, T, G, G, G, G, T, G, C}
- k=2, {TA, AT, TG, GG, GG, GG, GT, TG, GC}
// - k=3, {TAT, ATG, TGG, GGG, GGG, GGT, GTG, TGC}
- k=4, {TATG, ATGG, TGGG, GGGG, GGGT, GGTG, GTGC}
- What is the number of possible k-mers in a string of length n?

== BLAST Parameters


#show terms.item: (it) => {
  [#strong(emph(it.term)) : #it.description\ ]
}

/ Inputs: $Q$ - query of length $q$, $D$ - database sequence of length $d$
/ Parameters:
  - Scoring matrix, 
  - $S$ Minimum MSP score,
  - $k$ - length of $k$-mer,
  - $T$- minimum score for valid $k$-mer,
  // - $S_"dropoff"$ -
  #v(-1.8em)
/ Output: All MSPs with score $>= S_"cutoff"$

== BLAST Over
#{
  set align(center)
  diagram(
  node-fill: cornflowerblue.lighten(80%), node-outset: 5pt, node-inset: 0.5em, node-stroke: black.lighten(50%), node-corner-radius: 4pt,
  // debug: 3,
  
  node((0,0), name: <prep>)[*Preprocessing:* Construct $L$,a list of all $k$-mers that match $Q$ with score at least $T$], pause, 
  edge(<prep>, <seed>, "-|>",),
  node((0,1), name: <seed>)[*Seeding:* Identifying all exact matches of $L$ in $D$. This is the heuristic.], pause,
  edge(<seed>, <extend>, "-|>",),
  node((0,2), name: <extend>)[*Extension:* Extend alignments to find Local MSPs with score at least $S_"cutoff"$], pause,
  edge("-|>"),
  node((0,3), name: <stop>)[*Stopping:* Stop when score drops or query ends]
)
}

#{ // block for example 1


[
== Example 1 - DNA sequence


- Let's take a simple example first:
*Inputs*:\
- Query sequence: ATGCAT (length $q = 6$) \
- Database sequence: CATGCATG (length $d = 8$)

*Parameters:*\
- Scoring: match = +2, mismatch = -2
- $k$-mer length, $k=3$
- Minimum $k$-mer score, $T = 5$
- Minimum MSP score, $S_"cutoff" = 10$

== Example 1 - Preprocessing

- The input query $Q$: ATGCAT
- All the k-mers in the query:
#{
  show table.cell: it =>{
    set align(center)
    it
  }
  set align(center)
  table(
  columns: 4, inset: 10pt,
  table.header[*Position*][*Query $k$-mer*][*Score upon match*][*Keep? (Score $>= T (5)$)*],
[Pos 1–3],[ATG],[+2+2+2=6],[Yes], 
[Pos 2–4],[TGC],[+2+2+2=6],[Yes],
[Pos 3–5],[GCA],[+2+2+2=6],[Yes],
[Pos 4–6],[CAT],[+2+2+2=6],[Yes]
)
}
- For simplicity, in this example, assume that we only have *perfect matches*
]
[
== Example 1 - Seeding

- Matching all $k$-mers to the database sequence
]

// Need to add this everytime you create this figure because touying's native multicolumn support depends on grid function and this will affect that too.
show alignment_grid.cell: it => {
  set text(size: 24pt, weight: "bold")
  set align(center)
  it
}
let ex1_align1 = alignment_grid(
  columns: 8,
  grid.header[C][#match[A]][#match[T]][#match[G]][C][A][T][G],
  grid.header[][#match[A]][#match[T]][#match[G]][][][][],
)
let ex1_align2 = alignment_grid(
  columns: 8,
  grid.header[C][A][#match[T]][#match[G]][#match[C]][A][T][G],
  grid.header[][][#match[T]][#match[G]][#match[C]][][][],
)
let ex1_align3 = alignment_grid(
  columns: 8,
  grid.header[C][A][T][#match[G]][#match[C]][#match[A]][T][G],
  grid.header[][][][#match[G]][#match[C]][#match[A]][][],
)
let ex1_align4 = alignment_grid(
  columns: 8,
  grid.header[C][A][T][G][#match[C]][#match[A]][#match[T]][G],
  grid.header[][][][][#match[C]][#match[A]][#match[T]][],
)
{
  set align(center)
diagram(
  spacing: 1em, node-fill:none, node-stroke: none,
  node((0,0))[#ex1_align1], 
  node((0,1))[#ex1_align2], 
  node((0,2))[#ex1_align3], 
  node((0,3))[#ex1_align4]
)
}
[
== Example 1 - Seeding and Extension

- Extend on both sides till score decreases or you reach query end
]
{
  set par(spacing: 0.5em)
  set align(center)
diagram(
  spacing: 1em, node-fill:none, node-stroke: none,
  node((0,0), name: <step1>)[#ex1_align2 $S_"current" = 6$], pause, edge("-|>")[Extend right], 
  node((0.8,2), name: <rightstep1>)[
    #alignment_grid(
  columns: 8,
  grid.header[C][A][#match[T]][#match[G]][#match[C]][#match[A]][T][G],
  grid.header[][][#match[T]][#match[G]][#match[C]][#match[A]][][],
)
$S_"current" = 8$
  ], pause,
  edge("-|>"),
  node((2,2), name: <rightstep2>)[
    #alignment_grid(
  columns: 8,
  grid.header[C][A][#match[T]][#match[G]][#match[C]][#match[A]][#match[T]][G],
  grid.header[][][#match[T]][#match[G]][#match[C]][#match[A]][#match[T]][],
)
$S_"current" = 10$
  ], pause, 
  edge("-|>"),
  node((4,2), name:<stop>)[
    #emoji.sign.stop \ Further extension\ reduces score \ and query ended
  ], 
  pause,
  edge(<rightstep2>,<leftstep3>, "-|>")[Extend left],
  node((3,0), name: <leftstep3>)[
    #alignment_grid(
  columns: 8,
  grid.header[C][#match[A]][#match[T]][#match[G]][#match[C]][#match[A]][#match[T]][G],
  grid.header[][#match[A]][#match[T]][#match[G]][#match[C]][#match[A]][#match[T]][],
)
$S_"current" = 12$
  ], pause,
  edge(<leftstep3>,<stop>, "-|>"),
)
v(1em)
stack(dir: ltr, spacing: 1em)[Final Alignment:][
  #alignment_grid(
  columns: 8,
  grid.header[C][#match[A]][#match[T]][#match[G]][#match[C]][#match[A]][#match[T]][G],
  grid.header[][#match[A]][#match[T]][#match[G]][#match[C]][#match[A]][#match[T]][],
)
][
  $S = 12 >= S_"cutoff " (10)$
]
}

}

#slide(title: [Example 2 - Protein Sequence, slightly more complicated], composer: (1fr, 1fr))[
  *Inputs*:
- Query sequence: MALWDY (length $q = 6$) \
- Database sequence: PMALYYG (length $d = 7$)

*Parameters:*
- Scoring: BLOSUM62
- $k$-mer length, $k=3$
- Minimum $k$-mer score, $T = 10$
- Minimum MSP score, $S_"cutoff" = 13$
][
  
#figure(
  image("/pictures/Blosum62.png"),
  caption: [BLOSUM62 Scoring matrix\ (Source: LabXchange.com)]
)
]

== Example 2 - Preprocessing

- The input query $Q$: MALWDY
- Let's focus on one $k$-mer: ALW
- Now identify the $k$-mers of the same length that align and have a score greater than $T = 10$. Some examples:
#{
  show table.cell: it =>{
    set align(center)
    it
  }
  set align(center)
  table(
  columns: 4, inset: 10pt,
  table.header[*Query $k$-mer*][*Target $k$-mer*][*Score *][*Keep? (Score $>= T (10)$)*],
[ALW],[ALW],[+4+4+11=19],[Yes],
[ALW],[ALF],[+4+4+1=9],[No],
[ALW],[SLW],[+1+4+11=16],[Yes],
[ALW],[AMW],[+4+2+11=17],[Yes],
[ALW],[ALY],[+4+4+2=10],[Yes]
)
}

== Example 2 – Protein Seeding and Extension (BLASTP)

- Extend using substitution matrix scores (e.g., BLOSUM62) until score decreases or sequence end

#{
  set par(spacing: 0.5em)
  set align(center)
  show alignment_grid.cell: it => {
  set text(size: 24pt, weight: "bold")
  set align(center)
  it
}
  diagram(
    spacing: 1em, node-fill: none, node-stroke: none,
    
    // Initial Seed Hit
    node((0,0), name: <step1>)[
      #alignment_grid(
        columns: 7,
        grid.header[P][M][#match[A]][#match[L]][#match[Y]][Y][G],
        grid.header[][][#match[A]][#match[L]][#match[W]][][],
      )
      $S_"current" = 10$ \ #(text(size: 0.8em, fill: gray)[BLOSUM62: A-A(+4), L-L(+4), W-Y(+2)])
    ], 
    pause, 
    
    edge("-|>", label-anchor: "north-east", label-sep: -1pt)[Extend left], 

    // Step 1: Extend Left
    node((0.8,2), name: <leftstep1>)[
      #alignment_grid(
        columns: 7,
        grid.header[P][#match[M]][#match[A]][#match[L]][#match[Y]][Y][G],
        grid.header[][#match[M]][#match[A]][#match[L]][#match[W]][][],
      )
      $S_"current" = 15$ \ #(text(size: 0.8em, fill: gray)[Added M-M (+5)])
    ], 
    pause,

    edge("-|>", label-anchor: "north-west", label-sep: -1pt)[Extend right],

    // Step 2: Extend Right (Mismatch)
    node((2,0), name: <rightstep2>)[
      #alignment_grid(
        columns: 7,
        grid.header[P][#match[M]][#match[A]][#match[L]][#match[Y]][#mismatch[Y]][G],
        grid.header[][#match[M]][#match[A]][#match[L]][#match[W]][#mismatch[D]][],
      )
      $S_"current" = 12$ \ #(text(size: 0.8em, fill: red)[D-Y Mismatch (-3)])
    ], 
    pause, 

    edge("-|>")[Score drop],

    // Stop Node
    node((4,2), name:<stop>)[
      #emoji.sign.stop \ Score decayed \ Trimmed & Stopped
    ], 
  )

  v(1em)
  stack(dir: ltr, spacing: 1em)[Final Trimmed Alignment:][
    #alignment_grid(
      columns: 7,
      grid.header[P][#match[M]][#match[A]][#match[L]][#match[Y]][Y][G],
      grid.header[][#match[M]][#match[A]][#match[L]][#match[W]][][],
    )
  ][
    $S_"peak" = 15 >= S_"cutoff" (13)$
  ]
}

== Next steps: How significant is an alignment?

- How does one differentiate from a genuine alignment versus something that could have come up by chance?
- We need to verify that the chance of our result is greater than the chance if the query and database sequences were random
 

== What is the probability of a single alignment by chance? <lamb_prob>

- Consider an alignment of two random sequences with a score $S$, what is the probability of $S > S_"cutoff"$
- Intuitively, as $S_"cutoff"$ increases, the chance of random sequence alignment producing this score drastically reduces
- We can model this using an exponential distribution
#definition(title: "Exponential Distribution")[
  $ f(x; lambda) = lambda e^(-lambda x); #h(0.5em) lambda >0,   x in [0, infinity) $
]
Now, the probability of obtaining a score of at least $S_"cutoff"$ can be calculated using the survival function:

$ P(S >= S_"cutoff") = 1 - op("CDF")(x) =  e^(-lambda S_"cutoff") $

== How do we identify the correct $lambda$ 

- Recall the probability of obtaining score of at least $S$ is $P(S >= S) = e^(-lambda S)$
- S is score that is decided using a scoring matrix. #pause But scoring matrices are *arbitrary*
Consider the two cases:
#{
  set align(center)
  grid(
  columns: (1fr,1fr), align: center,
  [
  #example(title:"Case 1", )[
    #set align(center)
    #show alignment_grid.cell: it => {
  set text(size: 24pt, weight: "bold")
  set align(center)
  it
}
Scoring: Match: +2;\ mismatch and gaps: -1
    #alignment_grid(
      columns: 3,
      [A],[T],[G],
      [A],[C],[C]
    )
    Final Score is *2*
  ]
],[
  #example(title:"Case 2", )[
    #set align(center)
    #show alignment_grid.cell: it => {
  set text(size: 24pt, weight: "bold")
  set align(center)
  it
}
Scoring: Match: +4;\ mismatch: -1 and gaps: 0
    #alignment_grid(
      columns: 5,
      [A],[T],[G],[-],[-],
      [A],[-],[-],[C],[C]
    )
    Final Score is *2*
  ]
]
)
}
- Which is the correct alignment? 

== A principled way to think about alignment scoring

- A measure is sequence similarity is a quantification of how likely two residues (DNA/RNA/Protein) align with one another #pause
  - Therefore we can take a probabilistic approach to quantifying sequence similarity #pause
- Probabilities of alignment between two residues can be quantified by studying previously aligned sequences


== A concrete example

If one studies 100,000 aligned columns in evolutionarily related proteins, and Leucine (L) is aligned with Isoleucine (I) 3000 times, then
- the probability of leucine and isoleucine aligning, $p_"(L, I)"= 0.03$
- the marginal probabilities of leucine and isoleucine in the data are $p_"L"$ and $p_"I"$ respectively
- Odds of seeing aligned Leucine and Isoleucine aligned in a given sequence:
$ "Odds" = frac(p_"(L, I)", p_"L" p_"I") $

- $"Odds" > 1 =>$ the alignment is less likely to have occurred due to random chance
- $"Odds" <= 1 =>$ the alignment is more likely to have occurred due to random chance

- As a convention, we report the logarithm odds

== Probabilistic Interpretation

- Generalizing, the log-odds "score" of similarity between two residues ($i,j$) in an alignment is:
$ s_(i j) = ln(frac(q_(i j), p_i p_j)) $
- Rearranging, we get: $q_(i j) = p_i p_j e^(s_(i j))$. And since, $q_(i j)$ is a probability $sum_limits(i j) q_(i j) = 1$.\
- Now, let's consider an arbitrary scoring paradigm $s'_(i j)$ and the relation between $s_(i j)$ and $s_(i j)$ is $s_(i j) = lambda s_'(i j)$, then
$ q = sum_limits(i j) p_i p_j e^(lambda s'_(i j)) = 1 $
- $lambda$, therefore is the parameter that helps us convert an arbitrary score to an universal score based on probability
- In practice, $lambda$ is pre-calculated for different scoring matrices

== What is the number of alignments expected between random sequences?

Let $y$ be defined as the Expected number of alignments for given query sequence $Q$ (of length $q$) and database sequence $D$ (of length $d$) and cutoff score $S_"cutoff"$.
- Intuitively:
  - $y prop q d$, because the longer sequences, more likely that residues match randomly
  - $y prop frac(1, S)$, because the higher the score, the less likely that alignment random residues reach that value 
  - Since we consider those alignments that satisfy $S >= S_"cutoff"$, #link(<lamb_prob>)[
    #set text(fill: blue.darken(50%))
    $y prop P(S >= S_"cutoff")$
  ]
Bringing it all together:

$ y = K q d e^(-lambda S_"cutoff") $

where $K$ is a scaling parameter. A higher $y$ means that one expects more random matches.



== How statistically significant are the alignments?

The value $y$ is the average number (or rate) of hit for the given sequences and whose alignment has a score $S$ is:
$ y = K q d e^(-lambda S) $

 
For calculating the the probability for $c$ matches, model using the Poisson distribution. 
#definition(title: "Possion Distribution")[
  $ P(x = k; lambda) = frac(lambda^k e^(-lambda),k!) $
]

- The Poisson distribution models the number of discrete, independent random events that occur during a fixed interval of time or space at a constant average rate \ \ 

- In our case, the probability of finding a random alignment in the *space* of a sequence alignment follows a Poisson distribution @karlinMethodsAssessingStatistical1990a

- For given query sequence $Q$ (of length $q$) and database sequence $D$ (of length $d$) and cutoff score $S_"cutoff"$, how do we calculate if the obtained alignments are non-random?

To calculate significance - calculate probability of at least one random alignment

$ 
P(x >= 1) &= 1 - P(x = 0) \
 &= 1 - frac(y^0 e^(-y),0!)  \
 &= 1 - e^(-y)
$


#let small_table(..args) = {
  show table.cell: it => {
    set align(center + horizon)
    set text(size: 16pt)
    it
  }
  set align(center)
  table(..args)
}


// ---------------------------------------------------------------------
//  ALSO: add a label to your existing slide so the K section can link
//  back to the lambda equation, the way slide 21 links to <lamb_prob>.
//
//  Change line 552 from:
//      == Probabilistic Interpretation
//  to:
//      == Probabilistic Interpretation <lambda_eq>
// ---------------------------------------------------------------------



// #####################################################################
//  PART A --- How do we determine K?   (5 slides)
// #####################################################################



#slide(title: [Let's consider an example], repeat: auto, self => [
  #only("1")[
  Consider the following example:
  - Query: ATAT
  - Database sequence: CATATATGGG
  - Scoring: match - +2, mismatch - -1
  - What happens as we move the alignment of query sequence along the database?
] #pause

#{

  set par(spacing: 0.5em)
  set align(center)

  let db = ("C", "A", "T", "A", "T", "A", "T", "G", "G", "G")
  let query = ("A", "T", "A", "T")
  // Score of every offset p = 1..7 of the query along the database
  let profile = (-4, 8, -4, 8, -4, 2, -4)

  // Colour a letter by whether the query/database pair at that column matches
  let paint(q, letter) = if q == letter { match(letter) } else { mismatch(letter) }

  // Two-row alignment grid with the query starting at database column `p` (1-indexed).
  // The cell show rule is kept local: `alignment_grid.cell` is really `grid.cell`, so
  // letting it escape would restyle lilaq's and touying's internal grids too.
  let alignment_at(p) = {
    show alignment_grid.cell: it => {
      set text(size: 24pt, weight: "bold")
      set align(center)
      it
    }
    // index into `query` for database column i (1-indexed), or none if unaligned
    let q-index(i) = {
      let j = i - p + 1
      if j >= 1 and j <= query.len() { j } else { none }
    }
    // Uniform column widths so the query row stays in lockstep with the database
    // row and the panel does not jitter between subslides.
    alignment_grid(
      columns: (20pt,) * db.len(),
      grid.header(
        ..range(1, db.len() + 1).map(i => {
          let j = q-index(i)
          if j == none { [#db.at(i - 1)] } else { paint(query.at(j - 1), db.at(i - 1)) }
        }),
      ),
      grid.header(
        ..range(1, db.len() + 1).map(i => {
          let j = q-index(i)
          if j == none { [] } else { paint(db.at(i - 1), query.at(j - 1)) }
        }),
      ),
    )
  }

  // One subslide: alignment at offset `p` on the left, score profile so far on the right.
  // NOTE: `fletcher.diagram`, NOT the `diagram` alias from the preamble. That alias is a
  // touying-reducer, and touying never reduces content nested inside `alternatives` /
  // `only` / `uncover`, so the unreduced mark escapes to the page and panics.
  let panel(p, xs, ys) = fletcher.diagram(
    node-fill: none, node-stroke: none,
    node((0, 0))[
      #alignment_at(p)
      #v(0.5em)
      $S = #profile.at(p - 1)$
    ],
    edge("-|>")[Scored],
    node((2, 0))[
      #lq.diagram(
        width: 8cm, height: 6.5cm,
        xlabel: [Position on Database],
        ylabel: [Score],
        xlim: (0, 8),
        ylim: (-5, 9),
        lq.plot(xs, ys, mark: "o"),
      )
    ],
  )

  alternatives(
    panel(1, (1,), profile.slice(0, 1)),
    panel(2, (1, 2), profile.slice(0, 2)),
    panel(3, (1, 2, 3), profile.slice(0, 3)),
    panel(4, (1, 2, 3, 4), profile.slice(0, 4)),
    panel(7, range(1, 8), profile),
  )
} 

#only(6)[
  #set align(center) 
#question[Are there really 2 high scoring alignments?]
]
])

== Overlapping alignments

- Consider the two high scoring alignments of the examples again: #pause

#{
  set align(center)
  show alignment_grid.cell: it => {
      set text(size: 24pt, weight: "bold")
      set align(center)
      it  
    }

  alignment_grid(
  columns: (20pt,)*10,
  grid.header[C][#match[A]][#match[T]][#text(size: 28pt, fill: green.darken(25%))[A]][#text(size: 28pt, fill: green.darken(25%))[T]][A][T][G][G][G],
  grid.header[][#match[A]][#match[T]][#text(size: 28pt, fill: green.darken(25%))[A]][#text(size: 28pt, fill: green.darken(25%))[T]][][][][][],
  grid.header[][][][#text(size: 28pt, fill: green.darken(25%))[A]][#text(size: 28pt, fill: green.darken(25%))[T]][#match[A]][#match[T]][][][],
)
} #pause
- The center AT is repeated in both the cases.  #pause
- This means that they cannot be treated as separate alignments #pause
- And this exactly what $K$ will correct


== What is $K$ actually doing?

- Recall the expected number of random alignments: $y = K q d e^(-lambda S_"cutoff")$ #pause
- If we ignore $K$, then we are overestimating the number of random alignments. This is because high scoring alignments have dependencies within them 
- $K$ fixes the *search-space axis* --- it converts the nominal search space $q d$ into an _effective_ one #pause


#definition(title: [Definition: The parameter $K$])[
  $K$ is the scaling parameter that converts the nominal search space $q d$ into the *effective number of independent positions* at which a locally maximal alignment could begin. Typically $K < 1$.
]


// == When do $lambda$ and $K$ exist at all?

// - Karlin--Altschul theory does not apply to every scoring matrix
// - Given background residue frequencies $p_i$, *two* conditions are required:

// #grid(
//   columns: (1fr, 1fr), gutter: 1em,
//   definition(title: "Condition 1: Negative expected score")[
//     $ sum_limits(i j) p_i p_j s_(i j) < 0 $
//     Otherwise the score of a random alignment grows linearly with length, everything looks significant, and local alignment degenerates into *global* alignment.
//   ],
//   definition(title: "Condition 2: Some positive score exists")[
//     $ exists thin i,j quad "such that" quad s_(i j) > 0 $
//     Otherwise no alignment ever scores above zero and there is nothing to find.
//   ]
// )

// #pause
// - Under these conditions, $lambda$ is the *unique positive root* of the equation from #link(<lambda_eq>)[#text(fill: blue.darken(50%))[the probabilistic interpretation]]:
// $ sum_limits(i j) p_i p_j e^(lambda s_(i j)) = 1 $
// - One scalar equation, solved numerically by Newton's method. 


// == Quick check: does our own matrix qualify?

// #example(title: [Example 1's scoring: match $= +2$, mismatch $= -2$])[
//   With $p_A = p_T = p_G = p_C = 0.25$, four of the sixteen residue pairs match:
//   $ bb(E)(s) = 4/16 (+2) + 12/16 (-2) = 0.5 - 1.5 = -1 < 0 $
//   Condition 1 is satisfied. #tick
// ]

// // #pause

// #example(title: [Now try: match $= +2$, mismatch $= -0.5$])[
//   $ bb(E)(s) = 4/16 (+2) + 12/16 (-0.5) = 0.5 - 0.375 = +0.125 > 0 $
//   Condition 1 *fails*. No valid $lambda$ exists, and every statistic we derived collapses.
// ]


// == Recap: every parameter we have met

// #small_table(
//   columns: 3, inset: 7pt,
//   table.header[*Symbol*][*Meaning*][*Set by*],
//   [$q, d$], [query / database sequence length], [data],
//   [$k$ (or $W$)], [word length], [user (BLASTP 3, BLASTN 11)],
//   [$T$], [minimum word score to count as a hit], [user (BLASTP 11)],
//   [$A$], [max distance between two hits on a diagonal], [user (40)],
//   [$X_u, X_g, X_f$], [dropoff tolerances], [user],
//   [$S_g$], [score needed to trigger gapped extension], [$approx 22$ bits],
//   [$S_"cutoff"$], [score needed to report a hit], [user],
//   [$lambda$], [score-scale parameter], [matrix + gap costs],
//   [$K$], [search-space correction], [matrix + gap costs],
//   [$H$], [relative entropy (information per position)], [matrix + gap costs],
//   [$S'$], [bit score, $(lambda S - ln K) slash ln 2$], [computed],
//   [$E$], [expected number of chance hits, $q' d' 2^(-S')$], [computed],
// )

== How do we determine K?

$K$ can be calculated empirically @sf_local_nodate:

Steps:
- Randomly generate pairs of queries and database sequences 
- Use Smith-Waterman algorithm to identify the local alignment between the two sequences and store the maximum alignment scores $S_max$
- #cite(<sf_local_nodate>, form: "prose"), showed that the maximum score follows an extreme value gumbel distribution
#definition(title: [Extreme Value Gumbel Distribution])[
  $ F(x) = exp(-exp(- frac(x - mu, beta))) $
]

== How do we determine K?

#definition(title: [Extreme Value Gumbel Distribution])[
  $ F(x) = exp(-exp(- frac(x - mu, beta))) $
]
- In the case of local alignment, $mu = ln(K m n)/beta$
Which means,
$ F(x) = P(S_max <= x) = exp(-K m n e^(-lambda x))  $

Solving the above equation will give us the required value of $K$.

BLAST calculates a universal score, $S' = frac(lambda S - ln K, ln 2)$, which is then reported instead of unnormalized scores.

== Why do we need gaps?

- Real homologies contain insertions and deletions. An ungapped extension cannot capture that effectively. #pause
- What original BLAST did instead:
  - Report *several separate HSPs* lying close to one another #pause
  - Combine their significance #pause
- The problem with that:
  - The combined result is only significant if you find *every* constituent HSP #pause
  - Miss one and the whole hit is lost #pause
  - To avoid missing them you must keep $T$ low --- many hits, many extensions, slow




#{ // block for example 3

[
== Example 3 - When ungapped alignment fails

*Inputs:*
- Query sequence: ACGTTGCA (length $q = 8$)
- Database sequence: ACGTAATGCA (length $d = 10$)

*Parameters:*
- Scoring: match $= +2$, mismatch $= -2$
- Gap cost (simplified affine): $-(3 + 1 times "length")$ (Original BLAST does not have gaps)
- $k$-mer length, $k = 3$; minimum $k$-mer score, $T = 6$
- Minimum MSP score, $S_"cutoff" = 10$
]

// Re-declared per your line-262 note: this show rule must be
// re-applied inside every block that draws an alignment_grid.
show alignment_grid.cell: it => {
  set text(size: 22pt, weight: "bold")
  set align(center)
  it
}

let ex3_hsp1 = alignment_grid(
  columns: 10,
  grid.header[#match[A]][#match[C]][#match[G]][#match[T]][A][A][T][G][C][A],
  grid.header[#match[A]][#match[C]][#match[G]][#match[T]][][][][][][],
)
let ex3_hsp2 = alignment_grid(
  columns: 10,
  grid.header[A][C][G][T][A][A][#match[T]][#match[G]][#match[C]][#match[A]],
  grid.header[][][][][][][#match[T]][#match[G]][#match[C]][#match[A]],
)
// The two gapped columns are the DB residues with no query partner,
// so they are marked with #mismatch, not #match.
let ex3_gapped = alignment_grid(
  columns: 10,
  grid.header[#match[A]][#match[C]][#match[G]][#match[T]][#mismatch[A]][#mismatch[A]][#match[T]][#match[G]][#match[C]][#match[A]],
  grid.header[#match[A]][#match[C]][#match[G]][#match[T]][#mismatch[-]][#mismatch[-]][#match[T]][#match[G]][#match[C]][#match[A]],
)

[
== Example 3 - Ungapped BLAST finds two HSPs
]
{
  set par(spacing: 0.5em)
  set align(center)
  diagram(
    spacing: 1em, node-fill: none, node-stroke: none,
    node((0,0))[
      #ex3_hsp1
      Seed CGT #h(1em) $S = 8$
    ],
    pause,
    node((0,1))[
      #ex3_hsp2
      Seed TGC #h(1em) $S = 8$
    ],
  )
  v(0.8em)
}
[
- Neither reaches $S_"cutoff" = 10$. *Ungapped BLAST reports nothing.*
]

[
== Example 3 - A gap rescues the alignment

- Gapped BLAST joins the two HSPs across the diagonal shift:
]
{
  set par(spacing: 0.5em)
  set align(center)
  v(0.5em)
  ex3_gapped
  v(1em)
}
[
$ S = 8 times (+2) - (3 + 2 times 1) = 16 - 5 = 11 >= S_"cutoff" (10) $

- The *same evidence*, assembled differently, crosses the threshold
- The joined score is 11, not 16 --- the two-residue gap is charged $-5$
- But how do we include gaps in BLAST?
]

}


== Paying for it: the two-hit method

- A gapped DP extension costs far more than an ungapped one. Two moves recover the time.

// *Move 1 --- gapping alone lets you raise $T$*

// #small_table(
//   columns: 3, inset: 8pt,
//   table.header[][*Must find*][*Tolerable per-HSP miss rate $P$*],
//   [BLAST 1990], [_both_ HSPs: $2P - P^2 <= 0.05$], [$P < 0.025$],
//   [Gapped BLAST], [_one_ HSP: $P^2 <= 0.05$], [$P <= 0.22$],
// )

// #pause

// *Move 2 --- require two hits*

#definition(title: "Definition: The two-hit rule")[
  Invoke an ungapped extension only when *two non-overlapping word hits of score $>= T$ lie on the same diagonal, within distance $A$ of one another*. The extension starts from the second hit.
]

#pause
// - Two hits are far stronger evidence than one, so $T$ can be lowered back to 11: *more hits, far fewer extensions*
- Defaults for Protein BLAST: $k = 3$, $T = 11$, $A = 40$


== Does the two-hit method work?

- The paper's worked case: broad bean leghemoglobin I vs horse $beta$-globin @altschulGappedBLASTPSIBLAST1997

#small_table(
  columns: 4, inset: 10pt,
  table.header[*Heuristic*][*$T$*][*Word hits found*][*Extensions triggered*],
  [One-hit], [13], [15], [15],
  [Two-hit], [11], [37], [*2*],
)

#pause

- More than twice as many hits, and *one-seventh* as many extensions
- And it is _more_ sensitive than the one-hit heuristic for HSPs above $approx 33$ bits

#pause

#definition(title: "Why this works")[
  A genuine HSP long enough to matter almost always contains *two* word hits. An isolated hit almost never grows into anything. Requiring two is a cheap test that discards nearly all the noise before paying for an extension.
]


== Extending Examples 1 and 2: the $X$-drop rule

- Our earlier examples said: _extend until the score decreases_
- *BLAST does not do this.* A single mismatch would terminate almost every real alignment.

#definition(title: [Definition: $X$-drop extension])[
  Keep extending while
  $ S_"current" > S_"best so far" - X $
  then stop and *trim back to the best-scoring position*. \
  $X$ is a tolerance for temporary dips in score.
]




== How do we include gaps in the result? 
#pause

#answer[Smith-Waterman Algorithm] #pause 
Full steps: 
- *Seed:* Match two kmers of the query with the database within $A$ distance of one another #pause
- *Extend:* run Smith-Waterman algorithm outward in both directions from the two sides #pause
- *Result:* Alignment flanked by the two seed sequences
  // - Earlier heuristics confined the alignment to a fixed predefined *band*, and so could not follow an alignment that wandered off it #pause
  // - The $X_g$ region shapes itself around wherever the alignment actually goes #pause

// #definition(title: [Definition: The trigger score $S_g$])[
//   Run a gapped extension only if the ungapped HSP score exceeds $S_g$, chosen so that roughly *one gapped extension is invoked per 50 database sequences* ($S_g approx 22$ bits for a typical protein query).
// ]


== The full gapped BLAST pipeline

#{
  set align(center)
  set text(size: 17pt)
  diagram(
    node-fill: cornflowerblue.lighten(80%), node-outset: 4pt, node-inset: 0.5em,
    node-stroke: black.lighten(50%), node-corner-radius: 4pt,

    node((0,0), name: <prep2>)[*Preprocessing*\ construct $L$,\ all $k$-mers matching $Q$ with score $>= T$], pause,
    edge(<prep2>, <seed2>, "-|>"),
    node((1,0), name: <seed2>)[*Seeding*\ find all hits of $L$ in $D$], pause,
    edge(<seed2>, <twohit>, "-|>"),
    node((1,1), name: <twohit>)[*Two-hit test*\ two non-overlapping hits,\ within distance $A$?], pause,
    edge(<twohit>, <ungap>, "-|>", label-side: right)[yes],
    edge(<twohit>, <discard>, "-|>", label-side: left)[no],
    node((1,2), name: <discard>, fill: red.lighten(85%))[*Discard*], // pause,
    node((0,1), name: <ungap>)[*Ungapped extension* \ Between two hits, with tolerance $X$], pause,
    edge(<ungap>, <gaptest>, "-|>"),
    node((0,2), name: <gaptest>)[*Is HSP score $>= S_g$?*], pause,
    edge(<gaptest>, <gapext>, "-|>", label-side: left)[yes],
    edge(<gaptest>, <discard>, "-|>", label-side: left)[no],
    node((0,3), name: <gapext>)[*Gapped extension* Smith-Waterman], pause,
    edge(<gapext>, <report>, "-|>"),
    node((1,3), name: <report>)[*Report:* if score $>= S_"cutoff"$,\ compute significance],

  )
}
