test_that("se usa correctamente la consola", {
  expect_output(dgc_test(PlantGrowth$weight, PlantGrowth$group))
  expect_output(dgc_test(PlantGrowth$weight, PlantGrowth$group, console = F),
    regexp = NA
  )
})

test_that("se detecta alpha incorrecto", {
  expect_warning(dgc_test(PlantGrowth$weight, PlantGrowth$group, alpha = 999))
  expect_no_warning(dgc_test(PlantGrowth$weight, PlantGrowth$group, alpha = 0.05))
  expect_no_warning(dgc_test(PlantGrowth$weight, PlantGrowth$group, alpha = 0.01))
})

test_that("se muestran corectamente las alertas", {
  expect_no_message(dgc_test(PlantGrowth$weight, PlantGrowth$group, alpha = 0.05))
  expect_message(dgc_test(PlantGrowth$weight, PlantGrowth$group, alpha = 0.01),
    regexp = "No differences"
  )
  expect_message(dgc_test(iris$Sepal.Length, iris$Species),
    regexp = "All differences"
  )
})

test_that("se muestra corectamente el error por columna inexistente", {
  modelo <- lm(data = PlantGrowth, weight ~ group)
  expect_no_error(dgc_test(modelo, "group"))
  expect_error(dgc_test(modelo, "columna_inexistente"),
    regexp = "The column.*cannot be found in"
  )
})

test_that("se muestran corectamente los errores por k y n", {
  expect_error(dgc_test(mtcars$mpg, mtcars$vs),
    regexp = "at least.*treatments"
  )
  expect_error(dgc_test(mtcars$mpg, mtcars$wt),
    regexp = "at least.*observations"
  )
})

test_that("se devuelven errores por tipo o longitud de objeto inapropiado", {
  expect_error(dgc_test(PlantGrowth$weight[1:29], PlantGrowth$group),
    regexp = "variable lengths"
  )
  expect_error(dgc_test(PlantGrowth$weight, PlantGrowth$group[1:29]),
    regexp = "variable lengths"
  )
  expect_error(dgc_test(PlantGrowth$weight, "PlantGrowth$group"))
  expect_error(dgc_test(PlantGrowth$weight, PlantGrowth$group, show_plot = "Yes"))
  expect_error(dgc_test(PlantGrowth$weight, PlantGrowth$group, console = "Yes"))
  expect_error(dgc_test(PlantGrowth$weight, PlantGrowth$group, abline_options = 2))
})

test_that("se configuran correctamente los graficos", {
  expect_no_error(dgc_test(PlantGrowth$weight, PlantGrowth$group, col = "red"))
  expect_no_error(dgc_test(PlantGrowth$weight, PlantGrowth$group,
    abline_options = list(col = "orange")
  ))
  expect_no_error(dgc_test(PlantGrowth$weight, PlantGrowth$group,
    abline_options = list(col = "purple"), col = "green"
  ))
})

test_that("los returns son correctos", {
  expect_type(dgc_test(PlantGrowth$weight, PlantGrowth$group)$stats,
    type = "list"
  )
  expect_type(dgc_test(PlantGrowth$weight, PlantGrowth$group)$groups,
    type = "list"
  )
  expect_type(dgc_test(PlantGrowth$weight, PlantGrowth$group)$groups[[1]],
    type = "integer"
  )
  expect_type(dgc_test(PlantGrowth$weight, PlantGrowth$group)$parameters,
    type = "list"
  )
  expect_length(dgc_test(PlantGrowth$weight, PlantGrowth$group)$parameters, n = 5)
  if (length(dgc_test(PlantGrowth$weight, PlantGrowth$group)$parameters) == 5) {
    expect_type(dgc_test(PlantGrowth$weight, PlantGrowth$group)$parameters[[1]],
      type = "integer"
    )
    for (i in 2:4) {
      expect_type(dgc_test(PlantGrowth$weight, PlantGrowth$group)$parameters[2:5][[i]],
        type = "double"
      )
    }
  }
})
