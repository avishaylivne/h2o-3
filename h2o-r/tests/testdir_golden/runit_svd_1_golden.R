setwd(normalizePath(dirname(R.utils::commandArgs(asValues=TRUE)$"f")))
source("../../scripts/h2o-r-test-setup.R")



test.svd.golden <- function() {
  # Import data: 
  Log.info("Importing USArrests.csv data...") 
  arrestsR <- read.csv(locate("smalldata/pca_test/USArrests.csv"), header = TRUE)
  arrestsH2O <- h2o.uploadFile(locate("smalldata/pca_test/USArrests.csv"), destination_frame = "arrestsH2O")
  
  Log.info("Compare with SVD")
  fitR <- svd(arrestsR, nv = 4)
  fitH2O <- h2o.svd(arrestsH2O, nv = 4, transform = "NONE", max_iterations = 2000)
  
  Log.info("Compare singular values (D)")
  Log.info(paste("R Singular Values:", paste(fitR$d, collapse = ", ")))
  Log.info(paste("H2O Singular Values:", paste(fitH2O@model$d, collapse = ", ")))
  expect_equal(fitH2O@model$d, fitR$d, tolerance = 1e-6)
  
  Log.info("Compare right singular vectors (V)")
  vH2O <- h2o.getFrame(fitH2O@model$v_key$name)
  vH2O.mat <- as.data.frame(vH2O)
  Log.info("R Right Singular Vectors"); print(fitR$v)
  Log.info("H2O Right Singular Vectors"); print(vH2O.mat)
  isFlipped1 <- checkSignedCols(vH2O.mat, fitR$v, tolerance = 1e-5)
  
  Log.info("Compare left singular vectors (U)")
  uH2O <- h2o.getFrame(fitH2O@model$u_key$name)
  uH2O.mat <- as.matrix(uH2O)
  Log.info("R Left Singular Vectors:"); print(head(fitR$u))
  Log.info("H2O Left Singular Vectors:"); print(head(uH2O.mat))
  isFlipped2 <- checkSignedCols(uH2O.mat, fitR$u, tolerance = 5e-5)
  expect_equal(isFlipped1, isFlipped2)
  
  
}

doTest("SVD Golden Test: USArrests", test.svd.golden)
