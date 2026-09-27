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
  title: text(size: 36pt)[*Differential Gene Expression Analysis*],
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
    [Differential Gene Expression Analysis #h(1fr)]
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

== Introduction

- RNA seqeuencing provides us with a snapshot of the biological activity #pause
- But it isn't informative to just know the state of one cell #pause
- We need to compare it to other conditions #pause

#example[
  Identifying genes having a statistically different expression levels in a diseased individual and healthy individual. Such genes are referred to as "dysregulated genes".
]

- The conditions between which comparisons happen are called *Factors*

= Basic Mathematical Setup

== Problem Setup

- Two sources of information: gene expression data and factor data #pause
- *Objective:* identify genes whose expression levels are associated with factors (disease condition, age, biomarkers) #pause
- Gene expression data (e.g. microarray, log scale) is a genes $times$ samples matrix $Y$:
  $
    Y_(j i) = "(log) expression of the" j"-th gene in the" i"-th sample"
  $
  #pause
- Expression of the $j$-th gene across all $N$ samples:
  $
    Y_j = mat(Y_(j 1), Y_(j 2), dots.h, Y_(j N))^T
  $

== The Design Matrix

- Factor data is stored in a *full-rank design matrix* $X in RR^(N times m)$ #pause
- Each column of $X$ is either
  - a *covariate*: age, weight, molecular phenotypes, biomarkers, or
  - a *factor*: groups (healthy vs disease) or treatments #pause

#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  align: center + horizon,
  [
    *Continuous covariates*
    $
      X = mat(
        23, 80;
        24, 63;
        25, 92;
        26, 84;
        27, 69;
      )
    $
    #text(size: 16pt)[Columns: Age (years), Weight (kg)]
  ],
  [
    *Categorical factor*
    $
      X = mat(
        1, 0;
        1, 0;
        0, 1;
        0, 1;
        0, 1;
      )
    $
    #text(size: 16pt)[Columns: Healthy, Disease]
  ],
)

= Linear Models (Microarray Data)

== The Linear Model

- Linear model between $Y_j$ (or normalized $Y_j$) and $X$:
  $
    Y_j = X beta_j + epsilon_j
  $
  #pause
- $beta_j in RR^m$ is an $m$-dimensional coefficient vector for gene $j$ #pause

#definition(title: "Interpretation of the coefficients")[
  One interpretation of $beta_(j k)$: the *expected level (or value)* of gene $j$ in the $k$-th factor (covariate).
]

== Estimation of $beta_j$

- *Least squares*, when all samples have the same error variance #pause
- *Weighted least squares*, if
  $
    "Var"(Y_j) = W_j sigma_j^2
  $
  - $sigma_j^2$: error variance associated with the $j$-th gene
  - $W_j$: positive definite weight matrix #pause
- Estimated value:
  $
    hat(beta)_j = (X^T W_j^(-1) X)^(-1) X^T W_j^(-1) Y_j
  $
  (with $W_j = I$ this reduces to ordinary least squares, $hat(beta)_j = (X^T X)^(-1) X^T Y_j$)

== Covariance of the Estimates

- The covariance of the estimated coefficients:
  $
    "Cov"(hat(beta)_j) = s_j^2 V_j, quad V_j = (X^T W_j^(-1) X)^(-1)
  $
  #pause
- $s_j^2$ is the estimate of the error variance $sigma_j^2$:
  $
    s_j^2 = 1/(N - m) (Y_j - X hat(beta)_j)^T W_j^(-1) (Y_j - X hat(beta)_j)
  $

== Contrast Matrix

- Often we are interested in *combinations* of the $hat(beta)_j$, e.g. differences between groups #pause
- Three groups: Healthy (H), Moderate (M), Disease (D). Each column of $C$ is one contrast:

#grid(
  columns: (1fr, 1.3fr),
  gutter: 1em,
  align: center + horizon,
  [
    #table(
      columns: 4,
      align: center,
      inset: 8pt,
      [$C$], [*H − M*], [*M − D*], [*D − H*],
      [$beta_(j 1)$ (H)], [$1$], [$0$], [$-1$],
      [$beta_(j 2)$ (M)], [$-1$], [$1$], [$0$],
      [$beta_(j 3)$ (D)], [$0$], [$-1$], [$1$],
    )
  ],
  [
    $
      tilde(beta)_j = C^T hat(beta)_j = vec(
        hat(beta)_(j 1) - hat(beta)_(j 2),
        hat(beta)_(j 2) - hat(beta)_(j 3),
        hat(beta)_(j 3) - hat(beta)_(j 1),
      )
    $
    $
      "Cov"(tilde(beta)_j) = s_j^2 C^T V_j C
    $
  ],
)

== Testing Coefficients Separately

- Each coefficient of $tilde(beta)_j$ is tested separately, $H_0: tilde(beta)_(j k) = 0$ #pause
  $
    t_(j k) = tilde(beta)_(j k) / (s_j sqrt(v_(j k)))
  $
  - $v_(j k)$: $k$-th diagonal element of $C^T V_j C$ (of $V_j$ when testing $hat(beta)_j$ directly) #pause
- Under $H_0$, $t_(j k)$ follows a *t-distribution* with degrees of freedom
  $
    d_j = N - "rank"(X) = N - m
  $

== Two Groups: The Two-Sample t-Test

- For two factors (groups), the t-test above is *equivalent to the two-sample t-test* #pause
- With $X$ = [Healthy, Disease] indicators and $W_j = I$:
  $
    hat(beta)_j = vec(overline(Y)_H, overline(Y)_D), quad V_j = mat(1\/n_H, 0; 0, 1\/n_D)
  $
  #pause
- The contrast $c = (1, -1)^T$ gives
  $
    t_j = (overline(Y)_H - overline(Y)_D) / (s_j sqrt(1\/n_H + 1\/n_D)), quad d_j = N - 2
  $
  which is exactly the pooled-variance two-sample t-statistic.

= RNA-seq Data: Poisson Model

== Why Not OLS for RNA-seq?

#grid(
  columns: (1fr, 1.1fr),
  gutter: 1em,
  align: horizon,
  [
    - RNA-seq produces *count data*
      - Non-negative integers
      - Do not follow a Normal distribution
    - Hence we *cannot* use the linear regression model (OLS) as done earlier
  ],
  [
    #align(center)[
      #lq.diagram(
        width: 11cm,
        height: 6.5cm,
        title: [RNA-count frequency plot for one gene],
        xlabel: [Number of reads],
        ylabel: [Frequency],
        xlim: (0, 160),
        ylim: (0, 40),
        lq.bar(
          (10, 30, 50, 70, 90, 110, 130, 150),
          (32, 18, 10, 4, 0, 0, 2, 1),
          width: 20,
          fill: rgb("#176B87"),
        ),
      )
      #text(size: 14pt)[Right-skewed, bounded at zero: not Normal]
    ]
  ],
)

== The Poisson Model

- Model the count $Y_j$ for the $j$-th gene with a Poisson distribution, $Y_j tilde "Poisson"(lambda_j)$:
#definition(title: "Possion Distribution")[
  $ P(Y_j = Y_(i j); lambda) = frac(lambda^Y_(i j) e^(-lambda),Y_(i j) !) $
]
  #pause
- $lambda_j$: average number of reads #pause
- Mean and variance are equal:
  $
    E[Y_j] = "Var"[Y_j] = lambda_j
  $

#text(size: 16pt)[Notation from here on: $Y_(i j)$ = count of gene $j$ in sample $i$.]

== Poisson Regression

- Experiment with $m$ design variables $x = mat(x_1, x_2, dots.h, x_m)^T$ #pause
- Model between $lambda_j$ and $x$:
  $
    log lambda_j = beta_(0 j) + beta_(1 j) x_1 + beta_(2 j) x_2 + dots.h + beta_(m j) x_m
    = beta_(0 j) + x^T beta_j
  $
  where $beta_j = mat(beta_(1 j), beta_(2 j), dots.h, beta_(m j))^T$ #pause

#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  [#question[Why model $log lambda_j$ instead of $lambda_j$?] #pause],
  answer[$lambda_j > 0$, but $beta_(0 j) + x^T beta_j$ can be any real number. The log maps $(0, infinity)$ onto $RR$.],
)

== Example: A Three-Group Study

- Groups: Healthy (H), Moderate (M), Disease (D)
  $
    beta_j = vec(beta_(H j), beta_(M j), beta_(D j)), quad x = vec(x_H, x_M, x_D)
  $
  #pause
- Study with 8 individuals:

#align(center)[
  #table(
    columns: 9,
    align: center,
    inset: 7pt,
    [*Sample $i$*], [1], [2], [3], [4], [5], [6], [7], [8],
    [$Y_(i j)$], [100], [80], [30], [40], [60], [0], [10], [40],
    [$x_H$], [0], [0], [0], [1], [1], [0], [0], [1],
    [$x_M$], [0], [1], [0], [0], [0], [1], [0], [0],
    [$x_D$], [1], [0], [1], [0], [0], [0], [1], [0],
  )
]

#text(size: 16pt)[The three indicator rows form the columns of the $8 times 3$ design matrix $X$.]

== The Model for the Example

- Then, the model for gene $j$ in sample $i$:
  $
    Y_(i j) tilde "Poisson"(lambda_(i j)) = "Poisson"(e^(beta_(0 j) + x_i^T beta_j))
  $
  #pause

#warning(title: "Identifiability")[
  With an intercept $beta_(0 j)$ *and* all three indicators, $X$ is not full rank, since $x_H + x_M + x_D = 1$ for every sample. In practice one indicator is dropped (a reference level, e.g. Healthy); $beta_(M j)$ and $beta_(D j)$ then become log fold changes relative to Healthy.
]

== Fitting the Model: Likelihood

- To establish the relationship between $Y_j$ and the $x$ variables, we need to *fit a model* #pause
- Construct the likelihood function (or the log-likelihood):
  $
    cal(L)(beta_(0 j), beta_j | Y_j, X)
    = product_(i=1)^N P(Y = Y_(i j) | x_i)
    = product_(i=1)^N (lambda_(i j)^(Y_(i j)) e^(-lambda_(i j))) / (Y_(i j)!)
  $
  #pause
- where $lambda_(i j) = e^(beta_(0 j) + x_i^T beta_j)$ and $beta_j$ is a vector

== Log-Likelihood and Estimation

$
  ell = sum_(i=1)^N [Y_(i j) log lambda_(i j) - lambda_(i j) - log Y_(i j)!]
  = sum_(i=1)^N [Y_(i j) (beta_(0 j) + x_i^T beta_j) - e^(beta_(0 j) + x_i^T beta_j)] + "const"
$
#pause
- Set the derivatives to zero:
  $
    (partial ell) / (partial beta_(0 j)) = sum_(i=1)^N (Y_(i j) - lambda_(i j)) = 0,
    quad
    (partial ell) / (partial beta_(k j)) = sum_(i=1)^N x_(i k) (Y_(i j) - lambda_(i j)) = 0
  $
  #pause
- Solving (numerically, e.g. Newton–Raphson / IRLS) gives $hat(beta)_(0 j), hat(beta)_(1 j), dots.h, hat(beta)_(m j)$

== Overdispersion

#let od-idx = range(30)
#let od-mean = od-idx.map(i => calc.pow(10.0, i / 10))
#let od-var = od-idx.map(i => {
  let m = calc.pow(10.0, i / 10)
  m + 0.1 * m * m * calc.exp(0.5 * calc.sin(2.7 * i))
})

#grid(
  columns: (1fr, 1.1fr),
  gutter: 1em,
  align: horizon,
  [
    - Poisson distribution:
      $
        E[Y_(i j) | x_i] = "Var"[Y_(i j) | x_i] = lambda_(i j)
      $
    - RNA-seq data:
      $
        "Var"[Y_(i j) | x_i] > E[Y_(i j) | x_i]
      $
    - Genes with higher mean count have higher variance
    - The Poisson model *underestimates* the variance
  ],
  [
    #align(center)[
      #lq.diagram(
        width: 11cm,
        height: 7cm,
        xlabel: [Mean count],
        ylabel: [Variance],
        xscale: "log",
        yscale: "log",
        legend: (position: left + top),
        lq.scatter(od-mean, od-var, label: [Genes (illustrative)]),
        lq.plot(od-mean, od-mean, mark: none, label: [Poisson: Var = mean (45° line)]),
      )
    ]
  ],
)

= Negative Binomial Regression

== The Negative Binomial Model

$
  Y_(i j) tilde "NB"(mu_(i j), alpha_j)
$
#pause
$
  E[Y_(i j)] = mu_(i j), quad "Var"(Y_(i j)) = mu_(i j) (1 + alpha_j mu_(i j)) = mu_(i j) + alpha_j mu_(i j)^2
$
#pause
- $alpha_j$: *over-dispersion parameter*, gene-specific #pause
- $alpha_j = 0 ==>$ the NB distribution reduces to the *Poisson* distribution

== Negative Binomial Probability Mass Function

- Writing $sigma_(i j)^2 = mu_(i j)(1 + alpha_j mu_(i j))$ for the variance:
  $
    Pr(Y_j = Y_(i j)) = binom(Y_(i j) + r_(i j) - 1, Y_(i j))
    (1 - mu_(i j) / sigma_(i j)^2)^(Y_(i j))
    (mu_(i j) / sigma_(i j)^2)^(r_(i j)),
    quad r_(i j) = mu_(i j)^2 / (sigma_(i j)^2 - mu_(i j))
  $
  #pause
- Since $sigma_(i j)^2 - mu_(i j) = alpha_j mu_(i j)^2$, we get $r_(i j) = 1 \/ alpha_j$, i.e.
  $
    Pr(Y_j = Y_(i j)) = binom(Y_(i j) + 1\/alpha_j - 1, Y_(i j))
    ((alpha_j mu_(i j)) / (1 + alpha_j mu_(i j)))^(Y_(i j))
    (1 / (1 + alpha_j mu_(i j)))^(1\/alpha_j)
  $

#text(size: 16pt)[The binomial coefficient with non-integer argument is understood via the Gamma function: $Gamma(y + r) \/ (Gamma(r) thin y!)$.]

== Modelling the Mean: Normalization

$
  mu_(i j) = c_(i j) thin q_(i j)
$

- $mu_(i j)$: mean count for gene $j$ in the $i$-th sample
- $c_(i j)$: scaling factor (normalization)
- $q_(i j)$: the true concentration of fragments from gene $j$ in sample $i$ #pause
- Assume $c_(i j) = c_i$: *one constant for all genes* in the $i$-th sample #pause
- Model between $q_(i j)$ and the design variables:
  $
    log_2 (q_(i j)) = beta_(0 j) + x_i^T beta_j = beta_(0 j) + x_(i 1) beta_(1 j) + x_(i 2) beta_(2 j) + dots.h
  $

== Estimation of the Size Factors $c_i$

#grid(
  columns: (1.1fr, 1fr),
  gutter: 1em,
  align: horizon,
  [
    - Median-of-ratios estimate for the $i$-th sample:
      $
        c_i = op("median", limits: #true)_(j : Y_j^R != 0) Y_(i j) / Y_j^R
      $
    - Pseudo-reference: geometric mean of gene $j$ across samples
      $
        Y_j^R = (product_(i=1)^N Y_(i j))^(1\/N)
      $
    - Genes with a zero count in any sample have $Y_j^R = 0$ and are excluded
  ],
  [
    #example(title: "Toy example (2 samples)")[
      #set text(size: 15pt)
      #table(
        columns: 5,
        align: center,
        inset: 5pt,
        [*Gene*], [$Y_(1 j)$], [$Y_(2 j)$], [$Y_j^R$], [*Ratios*],
        [A], [10], [20], [14.14], [0.71, 1.41],
        [B], [50], [100], [70.71], [0.71, 1.41],
        [C], [0], [5], [0], [excluded],
        [D], [30], [90], [51.96], [0.58, 1.73],
      )
      $c_1 = 0.71, quad c_2 = 1.41$: sample 2 is sequenced about twice as deeply.
    ]
  ],
)

== Likelihood for the NB Model

$
  cal(L)(beta_(0 j), beta_j, alpha_j | Y_j, X) = product_(i=1)^N Pr(Y_(i j))
  = product_(i=1)^N binom(Y_(i j) + r_(i j) - 1, Y_(i j))
  (1 - mu_(i j) / sigma_(i j)^2)^(Y_(i j))
  (mu_(i j) / sigma_(i j)^2)^(r_(i j))
$
#pause
- where
  $
    mu_(i j) = c_i thin 2^(beta_(0 j) + x_i^T beta_j)
  $
  #pause
- Estimate the parameters $beta_(0 j)$, $beta_j$ (a vector) and $alpha_j$ by maximizing $cal(L)$:
  $
    (hat(beta)_(0 j), hat(beta)_j, hat(alpha)_j) = op("arg max", limits: #true)_(beta_(0 j), beta_j, alpha_j) cal(L)(beta_(0 j), beta_j, alpha_j | Y_j, X)
  $
  #pause
- Then perform *Wald test(s)* on the $hat(beta)_j$ values or on contrasts $tilde(beta)_j$

= Hypothesis Testing: The Wald Test

== The Wald Test

- For a coefficient of $beta_j$:
  $
    H_0: beta_j = 0 quad "vs" quad H_1: beta_j != 0
    #h(2em) "or" #h(2em)
    H_0: beta_j = theta quad "vs" quad H_1: beta_j != theta
  $
  #pause
- Wald statistic:
  $
    W = (hat(beta)_j - theta)^2 / "Var"(hat(beta)_j)
  $
  #pause
- Under $H_0$, $W tilde chi^2$-distribution with *1 degree of freedom*

== The Wald Statistic in DESeq2

- DESeq2 uses $sqrt(W)$ as the statistic:
  $
    W_s = sqrt(W) = (hat(beta)_j - theta) / "SE"(hat(beta)_j)
  $

- $W_s$ is approximately standard Normal for large samples; it follows a t-distribution only under several strong assumptions #pause


#info(title: "Several parameters at once")[
  The Wald test can also compare multiple parameters at the same time. For $q$ contrasts $C^T beta_j$:
  $
    W = (C^T hat(beta)_j - theta)^T (C^T Sigma_j C)^(-1) (C^T hat(beta)_j - theta) tilde chi^2_q,
    quad Sigma_j = "Cov"(hat(beta)_j)
  $
]

= Summary

== Microarray vs RNA-seq

#align(center)[
  #table(
    columns: 3,
    align: (left, center, center),
    inset: 10pt,
    [], [*Microarray*], [*RNA-seq*],
    [Data], [Continuous (log) intensities], [Non-negative integer counts],
    [Distribution], [Normal], [Negative Binomial ($alpha_j = 0$: Poisson)],
    [Model], [$Y_j = X beta_j + epsilon_j$], [$log_2 q_(i j) = beta_(0 j) + x_i^T beta_j$],
    [Normalization], [Before fitting], [Size factors $c_i$ in the mean],
    [Estimation], [(Weighted) least squares], [Maximum likelihood (numerical)],
    [Test], [t-test, $d_j = N - m$], [Wald test, $W_s = hat(beta)_j \/ "SE"$],
  )
]

== The DESeq2-Style Workflow

#v(1fr)
#align(center)[
  #text(size: 16pt)[
    #diagram(
      spacing: (1.4em, 1.5em),
      node-stroke: 1pt + rgb("#176B87"),
      node-fill: rgb("#176B87").lighten(85%),
      node-corner-radius: 5pt,
      node((0, 0), [Raw counts \ $Y_(i j)$]),
      pause,
      edge("-|>"),
      node((1, 0), [Size factors \ $c_i$ (median of ratios)]),
      pause,
      edge("-|>"),
      node((2, 0), [NB GLM \ $mu_(i j) = c_i q_(i j)$]),
      pause,
      edge("-|>"),
      node((3, 0), [MLE of \ $beta_(0 j), beta_j, alpha_j$]),
      pause,
      edge("-|>"),
      node((4, 0), [Wald test \ $W_s = hat(beta)_j \/ "SE"$]),
    )
  ]
]
#v(1fr)
