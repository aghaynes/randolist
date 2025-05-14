
# dataset
#strata: strata variable
#arm: balanced result
#arm2: balanced result overall, imbalanced result within strata
#arm3: imbalanced result
#arm4: 3 arms, almost balanced
#arm4: 3 arms, imbalanced
testdat <- tibble::tribble(
  ~strata, ~arm, ~arm2, ~arm3, ~arm4, ~arm5,
  1,1,1,1,1,1,
  1,2,1,1,2,2,
  1,1,1,1,3,3,
  1,2,1,1,1,1,
  1,1,1,1,2,2,
  1,2,2,2,3,2,
  1,1,1,1,1,1,
  1,2,2,2,2,2,
  1,1,1,1,3,1,
  1,2,2,2,1,1,
  2,1,1,1,2,2,
  2,2,2,2,3,3,
  2,1,2,1,1,1,
  2,2,2,2,2,3,
  2,1,2,1,3,3,
  2,2,2,1,1,1,
  2,1,1,1,2,2,
  2,2,2,1,3,3,
  2,1,1,1,1,3,
  2,2,2,1,2,2,
)
# testdat |> count(strata, arm3)
# testdat |> count(strata, arm4)
# testdat |> count(arm4)
# testdat |> count(strata, arm5)


test_that("imbalance works for balanced data", {
  expect_equal(imbalance(testdat, arm)$imbalance, 0)
  expect_equal(strataimbalance(testdat, arm, strata)$imbalance, c(0, 0))
  expect_equal(imbalance(testdat, arm2)$imbalance, 0)
  expect_equal(imbalance(testdat, arm4)$imbalance, 1)
})
test_that("imbalance works for imbalanced data", {
  expect_equal(strataimbalance(testdat, arm2, strata)$imbalance, c(4, 4))
  expect_equal(strataimbalance(testdat, arm3, strata)$imbalance, c(4, 6))
  expect_equal(imbalance(testdat, arm4)$imbalance, 1)
  expect_equal(strataimbalance(testdat, arm5, strata)$imbalance, c(4,3))
})

