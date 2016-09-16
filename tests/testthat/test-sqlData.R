# query and data.frame are generated from these
vars <- data.frame(
  names = c("fctr", "chr", "vchr", "numi", "numf", "lgl"),
  sqltypes = c("nchar(10)", "nchar(10)", "nvarchar(10)",
               "integer", "float(53)", "bit"),
  rtypesin = c("factor", "character", "character",
               "integer", "numeric", "logical"),
  rtypesout = c("character", "character", "character",
                "integer", "numeric", "logical"),
  stringsAsFactors = FALSE
)
chrs <- c("char'1", "123", NA)
nums <- c(pi, 2*pi, NA)
lgls <- c(TRUE, FALSE, NA)

lst <- lapply(vars$rtypesin, function(ty) {
  switch(ty,
         "factor" = factor(chrs),
         "character" = chrs,
         "integer" = as.integer(nums),
         "numeric" = nums,
         "logical" = lgls)               
})
dat <- as.data.frame(lst, stringsAsFactors = FALSE, col.names = vars$names)

sqlDataFunc <- getMethod("sqlData", "SQLServerConnection")
sqlAppendTableFunc <- getMethod("sqlAppendTable", "SQLServerConnection")
fakecon <- NULL

# probably unnecessary
test_that("functions are found", {
  expect_is(sqlDataFunc, "MethodDefinition")
  expect_is(sqlAppendTableFunc, "MethodDefinition")
})



context("sqlData")

test_that("data.frame 'in' has the right formats", {
  expect_true(all(sapply(dat, class) == vars$rtypes))
})

datmod <- sqlDataFunc(fakecon, dat)

test_that("correct 'out' formats", {
  expect_is(datmod, "data.frame")
  expect_true(all(sapply(datmod, class) == "character"))
})

test_that("'NA's are converted to 'NULL' simple strings, not quoted", {
  expect_true(all(is.na(dat) == (datmod == "NULL")))
})



# if we have a connection available, test inserts/uploads
if (have_test_server("sqlserver")) {
  conn <- dbConnect(SQLServer(), "TEST")
  if (inherits(conn, "SQLServerConnection")) {

    tblname <- "testtable"

    qry <- SQL(paste0(
      "CREATE TABLE ", tblname, " (\n  ",
      "id UNIQUEIDENTIFIER DEFAULT NEWSEQUENTIALID(),\n  ",
      paste(vars$names, vars$sqltypes, sep = " ", collapse = " null,\n  "),
      "\n)"
    ))

    
    test_that("'create table' works", {
      if (dbExistsTable(conn, tblname)) {
        dbExecute(conn, paste("DROP TABLE", tblname))
      }
      expect_equal(dbExecute(conn, qry), 0)
      expect_true(dbExistsTable(conn, tblname))
    })

    # make sure table setup is correct before moving on
    test_that("table structure is correct", {
      ret <- dbGetQuery(conn, paste("SELECT TOP 0 * FROM", tblname))
      expect_true(all(colnames(ret) == c("id", vars$names)))
      expect_true(all(sapply(ret, class) == c("character", vars$rtypesout)))
    })

    test_that("'sqlAppendTable' works in a direct insert (all fields)", {
      insqry <- sqlAppendTable(conn, tblname, dat)
      expect_is(insqry, c("character", "SQL"))
      expect_equal(dbExecute(conn, insqry), nrow(dat))

      ret <- dbGetQuery(conn, paste("SELECT * FROM", tblname))
      expect_equal(nrow(ret), nrow(dat))
      expect_true(all(is.na(ret[,vars$names]) == is.na(dat)))
    })

  }
}
