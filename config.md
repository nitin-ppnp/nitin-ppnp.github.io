<!--
Add here global page variables to use throughout your
website.
The website_* must be defined for the RSS to work
-->
@def website_title = "Jigyasa"
@def website_descr = "Computer vision, Macine learning, Brain and Intelligence"
@def website_url   = "https://nitin-ppnp.github.io/"

@def author = "Nitin Saini"

<!--
Add here global latex commands to use throughout your
pages. It can be math commands but does not need to be.
For instance:
* \newcommand{\phrase}{This is a long phrase to copy.}
-->
\newcommand{\R}{\mathbb R}
\newcommand{\scal}[1]{\langle #1 \rangle}
\newcommand{\card}[3]{
  @@card
    @@button
        [![#1](/assets/!#2)](!#3)
        @@title
        #1
        @@
    @@
  @@
}
\newcommand{\utterances}{
  ~~~
  <script src="https://utteranc.es/client.js"
        repo="nitin-ppnp/nitin-ppnp.github.io/"
        issue-term="pathname"
        theme="github-light"
        crossorigin="anonymous"
        async>
  </script>
  ~~~
}
