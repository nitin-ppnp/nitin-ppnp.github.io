@def title = "Jigyasa Landing"
@def hasmath = true
@def hascode = true
<!-- Note: by default hasmath == true and hascode == false. You can change this in
the config file by setting hasmath = false for instance and just setting it to true
where appropriate -->


```julia:postcards
#hideall
posts = [
  (name="OpenCLBoostCompute", pic="BoostCompute.png", title="OpenCL using Boost Compute",link="/OpenCLBoostCompute/")
  ]

"@@cards @@row" |> println
for post in posts
  """
  @@column
    \\card{$(post.title)}{$(post.pic)}{$(post.link)}
  @@
  """ |> println
end
println("@@ @@") # end of cards + row
```
\textoutput{postcards}

