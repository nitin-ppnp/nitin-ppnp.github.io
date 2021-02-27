# This file was generated, do not modify it. # hide
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