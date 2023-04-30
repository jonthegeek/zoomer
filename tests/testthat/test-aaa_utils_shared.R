test_that(".chr2csv collapses character vectors", {
  expect_identical(.chr2csv(letters[1:3]), "a,b,c")
  expect_identical(.chr2csv(1:3), "1,2,3")
  expect_identical(.chr2csv(c(letters[1:3], NA)), "a,b,c")
  expect_identical(.chr2csv(c(NA, letters[1:3])), "a,b,c")
})
