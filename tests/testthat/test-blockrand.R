
set.seed(1)
res1 <- blockrand(100, blocksizes = c(1, 2))
res2 <- blockrand(100, blocksizes = 1:3, arms = c("Foo", "Bar"))

test_that("structure as expected", {
  expect_s3_class(res1, "data.frame")
  expect_equal(ncol(res1), 5)
  expect_equal(names(res1),
               c("seq_in_list", "block", "blocksize", "seq_in_block", "arm"))
})

test_that("seed produces consistent results", {
  set.seed(1)
  res3 <- blockrand(100, blocksizes = c(1, 2))
  expect_identical(res1, res3)
})

test_that("number of randomizations is sufficient", {
  expect_true(nrow(res1) > 100)
})

test_that("block sizes approximately correct", {
  freqs <- table(res2[res2$seq_in_block == 1, "blocksize"])
  expect_equal(freqs, c(8, 13, 6), ignore_attr = TRUE)
})

test_that("correct block sizes", {
  expect_true(all(res1$blocksize %in% c(2,4)))
  expect_true(all(res2$blocksize %in% c(2,4,6)))
})

test_that("arm labels", {
  expect_true(all(res1$arm %in% c("A", "B")))
  expect_true(all(res2$arm %in% c("Foo", "Bar")))
})

