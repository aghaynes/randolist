
test_that("two values result in 1:1", {
  expect_equal(pascalprops(2), c(0.5, 0.5))
})

test_that("three values result in 1:2:1", {
  expect_equal(pascalprops(3), c(0.33, 0.67, 0.33), tolerance = .05)
})

test_that("three values result in 1:3:3:1", {
  expect_equal(pascalprops(4), c(0.25, 0.75, 0.75, 0.25))
})


