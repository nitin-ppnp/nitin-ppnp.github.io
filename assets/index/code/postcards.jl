# This file was generated, do not modify it. # hide
#hideall
posts = [
  (name="OpenCLBoostCompute", pic="BoostCompute.png", title="OpenCL using Boost Compute",link="/OpenCLBoostCompute/"),
  (name="AMASSContacts", pic="smplconts/card_img.gif", title="Generating contact points for AMASS dataset",link="/AMASSContacts/")
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