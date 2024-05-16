#' Buscar el valor de Q
#'
#' @param valor_n Valor entero mayor o igual a 2, correspondiente al número de
#'    repeticiones por tratamiento. Si es igual o superior a 41, toma el valor 40.
#'
#' @param valor_k Valor entero mayor o igual a 3, correspondiente al número de
#'    tratamientos. Si es igual o superior a 41, toma el valor 40.
#'
#' @param valor_alfa Valor equivalente a 0.05 o 0.01, correspondiente al valor
#'    de significación del test. Por defecto toma el valor 0.05.
#'
#' @return Valor tabulado proveniente de la tabla correspondiente a
#'    'valor_alfa' para el número de repeticiones 'valor_n' y el número de
#'    tratamientos 'valor_k.'
#'
#' @noRd
buscar_q <- function(valor_n, valor_k, valor_alfa = 0.05) {
  if (valor_n > 40) {
    valor_n <- 40
  } else if (valor_n < 2) {
    cli::cli_abort("Each treatment must have at least two observations.")
  }

  if (valor_k > 40) {
    valor_k <- 40
  } else if (valor_k < 3) {
    cli::cli_abort(paste(
      "There must be at least three treatments, but",
      valor_k,
      "were found."
    ))
  }

  if (valor_alfa == 0.05) {
    valor_q <- dplyr::filter(t95, t95$n == valor_n, t95$k == valor_k)$valor
  } else if (valor_alfa == 0.01) {
    valor_q <- dplyr::filter(t99, t95$n == valor_n, t95$k == valor_k)$valor
  }

  return(valor_q)
}

#' Graficar el dendrograma
#'
#' @param dendrograma Objeto de clase hclust.
#' @param c Valor numérico positivo, correspondiente al valor crítico.
#' @param abline_options Lista con argumentos opcionales para la función
#'    `abline`.
#' @param ... Argumentos opcionales para la función `plot`
#'
#' @noRd
graficar_dendrograma_dgc <- function(dendrograma, c, abline_options, ...) {
  # Si el usuario no especifica rotulos, utiliza algunos por defecto
  args <- list(...)
  plot_labels <- c("main", "sub", "xlab", "ylab")
  plot_args <- list(
    main = "Cluster dendrogram",
    sub = "Differences below the line are not significant.",
    xlab = "Groups",
    ylab = "Distance"
  )

  for (label in plot_labels) {
    if (label %in% names(args)) {
      plot_args <- plot_args[names(plot_args) != label]
    }
  }

  do.call(graphics::plot, c(list(dendrograma), plot_args, args))

  # Le da un estilo determinado a la linea si el usuario no especifica otro
  if (missing(abline_options)) {
    graphics::abline(h = c, col = "steelblue", lwd = 3, lty = 2)
  } else {
    do.call(graphics::abline, c(list(h = c), abline_options))
  }

  # Alerta si la linea no es visible
  if (c > max(dendrograma$height)) {
    cli::cli_alert_info("No differences were significant, the line may not be displayed.")
  } else if (c < min(dendrograma$height)) {
    cli::cli_alert_info("All differences were significant, the line may not be displayed.")
  }
}

#' DGC Test
#'
#' Di Rienzo, Guzman and Casanoves test for multiple comparisons.
#' Implements a cluster-based method for identifying groups of nonhomogeneous
#' means.
#'
#' @param y Either a model (created with `lm()` o `aov()`) or a numerical vector
#'    with the values of the response variable for each unit.
#' @param trt If `y` is a model, it corresponds to the column indicating the
#'    treatments. If `y` is a vector, it's a vector of the same length as `y`
#'    with the treatments for each unit.
#' @param alpha Value equivalent to 0.05 or 0.01, corresponding to the
#'    significance level of the test. The default value is 0.05.
#' @param show_plot Logical value indicating whether the constructed dendrogram
#'    should be plotted or not.
#' @param console Logical value indicating whether the results should be printed
#'    on the console or not.
#' @param abline_options List with optional arguments for the line in the
#'    dendrogram.
#' @param ... Optional arguments for the `plot()` function.
#'
#' @returns A list with three `data.frame`:
#'    \item{stats}{`data.frame` containing summary statistics by treatment.}
#'    \item{groups}{data.frame indicating the group to which each treatment is
#'    assigned.}
#'    \item{parameters}{`data.frame` with the values used for the test.
#'    `treatments` is the total number of treatments, `alpha` is the
#'    significance level used, `c` is the cut-off criterion for the dendrogram
#'    (the height of the horizontal line of the dendrogram), `q` is the 1-alpha
#'    quantile of the distribution of Q (distance from the root node) under the
#'    null hypothesis and `SEM` SEM is an estimate of the standard error of the
#'    mean.}
#' @export
#'
#' @examples
#' data("PlantGrowth")
#' # Using vectors -------------------------------------------------------
#' weights <- PlantGrowth$weight
#' treatments <- PlantGrowth$group
#' dgc_test(y = weights, trt = treatments, show_plot = FALSE)
#' # Using a model ------------------------------------------------------
#' model <- lm(weights ~ treatments)
#' dgc_test(y = model, trt = "treatments", show_plot = FALSE)
#' @references Di Rienzo, J.A., Guzmán, A.W., Casanoves, F. (2002): A multiple
#' comparisons method based on the distribution of the root node distance of a
#' binary tree. J. Agr.Biol. Environ. Stat. 7: 1-14.
#' @author Santiago Garcia Sanchez
dgc_test <- function(y, trt, alpha = 0.05, show_plot = T, console = T,
                     abline_options, ...) {
  # Permite que `y` sea un vector e identifica los grupos
  if (!"aov" %in% class(y) && !"lm" %in% class(y)) {
    y <- stats::aov(y ~ trt)
    grupos <- colnames(y$model)[2]
  } else {
    grupos <- trt
    # `trt` debe ser el nombre de una columna
    if (length(colnames(y$model)[which(colnames(y$model) == grupos)]) != 1) {
      cli::cli_abort(paste0(
        "The column '", trt,
        "' cannot be found in `y`"
      ))
    }
  }

  # Identifica las variables por su rol
  datos <- y$model
  colnames(datos)[1] <- "var_y"
  colnames(datos)[which(colnames(datos) == grupos)] <- "tratamiento"

  # Evita errores con R CMD check
  tratamiento <- var_y <- NULL

  # `k` es necesario para obtener `Q`
  datos <- datos %>%
    dplyr::group_by(tratamiento) %>%
    dplyr::summarise(
      r = dplyr::n(),
      media = mean(var_y),
      de = stats::sd(var_y),
      mediana = stats::median(var_y),
      min = min(var_y),
      max = max(var_y)
    )

  k <- nrow(datos)

  # `n` es necesario para obtener `Q`
  if (length(unique(datos$r)) == 1) {
    n <- unique(datos$r)
  } else {
    # Si los grupos son desiguales, se aplica la media armonica
    n <- round(psych::harmonic.mean(datos$r))
  }

  # `alpha` debe tener un valor apropiado para calcular `Q`
  if (alpha != 0.05 & alpha != 0.01) {
    cli::cli_warn(
      paste0("`alpha` must be either 0.05 o 0.01", ", not '", alpha, "'", ".
             alpha = 0.05 will be used by default.")
    )
    alpha <- 0.05
  }
  valor_q <- buscar_q(n, k, alpha)

  # Se construye la tabla ANOVA para obtener MSE
  MSE <- stats::anova(y)[3][[1]][2]
  valor_c <- valor_q * sqrt(MSE / n)

  # Se construye una matriz con las distancea euclidianas
  matriz_d <- stats::dist(datos$media, method = "euclidean") %>%
    usedist::dist_setNames(datos$tratamiento)

  # Se aplica el enlace promedio para los clusters
  dendrograma <- stats::hclust(matriz_d, method = "average")

  if (show_plot) {
    graficar_dendrograma_dgc(dendrograma, valor_c, abline_options, ...)
  }

  # Listas para return
  estadisticas <- as.data.frame(datos[order(datos$media), ])
  grupos <- procs::proc_sort(as.data.frame(stats::cutree(dendrograma, h = valor_c)))
  colnames(grupos) <- "group"
  parametros <- data.frame(
    "treatments" = k, "alpha" = alpha,
    "c" = valor_c, "q" = valor_q, "SEM" = sqrt(MSE / n)
  )

  if (console) {
    print(grupos)
    cat("Treatments within the same group are not significantly different\n")
  }

  output <- list("stats" = estadisticas, "groups" = grupos, "parameters" = parametros)
  invisible(output)
}
